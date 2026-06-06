#!/usr/bin/env python3
"""
prepare_circuits.py — ONE-SHOT (regénère les copies).

Copie les circuits d'origine (engine/circuits/*.asm) dans le projet de l'éditeur
(tools/circuit-editor/circuits/). L'éditeur travaille sur CES copies : les
originaux du jeu ne sont jamais touchés. Relancer ce script pour rafraîchir les
copies depuis les originaux.

Usage : .venv/bin/python3 tools/circuit-editor/prepare_circuits.py
"""
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]            # .../road-generator
SRC = ROOT / "engine" / "circuits"
DST = ROOT / "tools" / "circuit-editor" / "circuits"
DST.mkdir(parents=True, exist_ok=True)

n = 0
for asm in sorted(SRC.glob("*.asm")):
    shutil.copy2(asm, DST / asm.name)
    n += 1
    print(f"  {asm.name}")

print(f"\n✓ {n} circuits copiés dans {DST}")
