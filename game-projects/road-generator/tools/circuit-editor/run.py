#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Lance le Circuit Editor — macOS / Linux / Windows.

Démarre le backend FastAPI (port 8765) et le frontend Vite (port 5180),
puis attend. Ctrl-C arrête proprement les deux. Usage : python run.py
"""
import os
import sys
import time
import signal
import shutil
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent          # tools/circuit-editor
ROOT = HERE.parents[1]                           # game-projects/road-generator
VENV = ROOT / ".venv"
IS_WIN = os.name == "nt"
BACKEND_URL = "http://127.0.0.1:8765"
FRONTEND_URL = "http://localhost:5180"


def venv_python() -> Path:
    return VENV / ("Scripts/python.exe" if IS_WIN else "bin/python3")


def spawn(cmd, cwd, shell):
    """Lance un process dans son PROPRE groupe (pour tuer tout l'arbre ensuite —
    indispensable car `npm run dev` engendre des enfants node/esbuild)."""
    kw = {"cwd": cwd, "shell": shell}
    if IS_WIN:
        kw["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP
    else:
        kw["start_new_session"] = True       # = setsid : nouveau groupe -> killpg
    return subprocess.Popen(cmd, **kw)


def kill_tree(p, force=False):
    """Tue le process ET ses descendants, cross-platform."""
    if p.poll() is not None:
        return
    try:
        if IS_WIN:
            subprocess.run(["taskkill", "/T", ("/F" if force else "/PID"), str(p.pid)]
                           if not force else ["taskkill", "/F", "/T", "/PID", str(p.pid)],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            os.killpg(os.getpgid(p.pid), signal.SIGKILL if force else signal.SIGTERM)
    except Exception:
        try:
            p.kill() if force else p.terminate()
        except Exception:
            pass


def main() -> int:
    py = venv_python()
    if not py.exists():
        print("✗ venv absent — lance d'abord :  python install.py")
        return 1
    if not (HERE / "frontend" / "node_modules").exists():
        print("✗ node_modules absent — lance d'abord :  python install.py")
        return 1

    npm = "npm.cmd" if IS_WIN else "npm"
    if shutil.which(npm) is None and shutil.which("npm") is None:
        print("✗ npm introuvable — installe Node.js puis relance.")
        return 1

    # Handlers EXPLICITES : override le SIG_IGN éventuellement hérité (job lancé en
    # arrière-plan) et gère SIGTERM (kill / Docker / systemd) -> arrêt gracieux.
    def _request_stop(signum, frame):
        raise KeyboardInterrupt
    signal.signal(signal.SIGINT, _request_stop)
    try:
        signal.signal(signal.SIGTERM, _request_stop)
    except (ValueError, OSError):
        pass                                   # SIGTERM indispo (ex. thread non-principal)

    print("▶ Backend  →", BACKEND_URL)
    print("▶ Frontend →", FRONTEND_URL)
    print("  (Ctrl-C pour tout arrêter)\n")

    procs = []
    try:
        # backend : python du venv ; app.py résout ses chemins via __file__ (cwd-indépendant)
        procs.append(spawn([str(py), str(HERE / "backend" / "app.py")], cwd=str(ROOT), shell=False))
        # frontend : npm run dev dans frontend/ (shell pour résoudre npm/npm.cmd partout)
        procs.append(spawn(f"{npm} run dev", cwd=str(HERE / "frontend"), shell=True))

        # boucle de surveillance : si l'un meurt, on arrête l'autre
        while True:
            for p in procs:
                if p.poll() is not None:
                    print(f"\n⚠ un process s'est arrêté (code {p.returncode}) — fermeture…")
                    return p.returncode or 0
            time.sleep(0.5)
    except KeyboardInterrupt:
        print("\n⏹ arrêt demandé…")
        return 0
    finally:
        for p in procs:
            kill_tree(p)                       # SIGTERM au groupe (arrêt doux)
        deadline = time.time() + 6
        for p in procs:
            try:
                p.wait(timeout=max(0.1, deadline - time.time()))
            except Exception:
                kill_tree(p, force=True)        # SIGKILL au groupe si récalcitrant
        print("✓ arrêté.")


if __name__ == "__main__":
    sys.exit(main())
