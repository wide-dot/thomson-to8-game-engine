#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Installe les prérequis du Circuit Editor — macOS / Linux / Windows.

  - crée le venv Python (.venv à la racine road-generator) s'il manque,
  - installe les deps backend (fastapi, uvicorn, httpx, Pillow),
  - lance `npm install` pour le frontend.

Idempotent : relançable sans danger. Usage : python install.py
"""
import os
import sys
import shutil
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent          # tools/circuit-editor
ROOT = HERE.parents[1]                           # game-projects/road-generator
VENV = ROOT / ".venv"
IS_WIN = os.name == "nt"


def venv_python() -> Path:
    return VENV / ("Scripts/python.exe" if IS_WIN else "bin/python3")


def sh(cmd, **kw):
    """Exécute une commande (liste ou str) en l'affichant ; lève si échec."""
    printable = cmd if isinstance(cmd, str) else " ".join(str(c) for c in cmd)
    print("    $", printable)
    subprocess.check_call(cmd, **kw)


def main() -> int:
    print("== Circuit Editor — installation ==\n")

    # 1) venv Python -----------------------------------------------------------
    py = venv_python()
    if py.exists():
        print("• venv déjà présent :", VENV)
    else:
        print("• Création du venv :", VENV)
        sh([sys.executable, "-m", "venv", str(VENV)])
        py = venv_python()
        if not py.exists():
            print("✗ échec de la création du venv.")
            return 1

    # 2) deps backend (dans le venv) -------------------------------------------
    req = HERE / "backend" / "requirements.txt"
    print("• Dépendances backend (pip) …")
    try:
        sh([str(py), "-m", "pip", "install", "--upgrade", "pip"], stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        pass  # pip déjà à jour / réseau : non bloquant
    sh([str(py), "-m", "pip", "install", "-r", str(req)])

    # 3) frontend (npm) --------------------------------------------------------
    npm = "npm.cmd" if IS_WIN else "npm"
    if shutil.which(npm) is None and shutil.which("npm") is None:
        print("\n⚠ npm introuvable — installe Node.js ≥ 18 puis relance ce script :")
        print("    macOS   : brew install node")
        print("    Windows : https://nodejs.org  (ou  winget install OpenJS.NodeJS)")
        print("    Linux   : sudo apt install nodejs npm   (ou nvm)")
        return 1
    print("• Dépendances frontend (npm install) …")
    sh(f"{npm} install", cwd=str(HERE / "frontend"), shell=True)

    print("\n✓ Installation terminée.")
    print("  Lance l'éditeur avec :  python run.py")
    print("  (ou ./run.sh sous macOS/Linux, run.bat sous Windows)")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as e:
        print(f"\n✗ commande échouée (code {e.returncode}).")
        sys.exit(e.returncode or 1)
