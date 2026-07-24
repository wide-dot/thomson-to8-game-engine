#!/usr/bin/env python3
"""Recopie les corps des vrais blits bg-erase de la tail (BCKDRAW=save+draw,
ERASE=restore) generes cote r-type, sur la page du master (harness de test),
avec labels renommes + tables de dispatch [img*4 + parite*2].
Usage: python3 tools/gen_tailmgr_blits.py   (depuis game-projects/unit-test)
"""
import re, os, sys

RT = os.path.abspath(os.path.join(os.path.dirname(__file__),
      "../../r-type/generated-code/dobkeratops_tail"))
OUT = os.path.abspath(os.path.join(os.path.dirname(__file__),
      "../objects/tailmgr/tailmgr_blits.asm"))
HEADER_RE = re.compile(r"^\s*(INCLUDE|ORG|SETDP|OPT)\b", re.I)
IMGS = ["0", "1", "2", "end"]

def body(path, oldlabel, newlabel):
    out = []
    for raw in open(path, encoding="latin-1"):
        line = raw.rstrip("\n")
        if HEADER_RE.match(line):
            continue
        # renomme le label principal (1re colonne) en notre label stable ;
        # les labels internes (ERASE_CODE_, SSAV_, DataSize) sont neutralises
        s = line.strip()
        if s.startswith(oldlabel):
            out.append(newlabel)
            continue
        if s.startswith("ERASE_CODE_") or s.startswith("SSAV_"):
            continue  # label interne inutile, le code suit
        if s.startswith("DataSize"):
            continue
        out.append(line)
    return "\n".join(out).rstrip() + "\n"

draw_tab, erase_tab, blits = [], [], []
for im in IMGS:
    for par in ("NB0", "NB1"):
        base = f"Img_dobkeratops_tail_{im}_0_{par}"
        d = os.path.join(RT, base + ".asm")
        e = os.path.join(RT, base + "_Erase.asm")
        if not os.path.exists(d) or not os.path.exists(e):
            sys.exit("introuvable: " + base + " (rebuild r-type d'abord)")
        dl = f"TMDraw_{im}_{par}"
        el = f"TMErase_{im}_{par}"
        blits.append(body(d, f"BCKDRAW_Img_dobkeratops_tail_{im}_0", dl))
        blits.append(body(e, f"ERASE_Img_dobkeratops_tail_{im}_0", el))
    draw_tab.append(f"        fdb   TMDraw_{im}_NB0,TMDraw_{im}_NB1")
    erase_tab.append(f"        fdb   TMErase_{im}_NB0,TMErase_{im}_NB1")

with open(OUT, "w", encoding="latin-1") as f:
    f.write("; GENERE par tools/gen_tailmgr_blits.py - NE PAS EDITER.\n")
    f.write("; Corps des vrais blits bg-erase de la tail, page master.\n")
    f.write("; Tables indexees [img*4 + parite*2] (img: 0,2,4,6 ; par: 0/1).\n")
    f.write("TMDrawTab\n" + "\n".join(draw_tab) + "\n")
    f.write("TMEraseTab\n" + "\n".join(erase_tab) + "\n\n")
    for b in blits:
        f.write(b + "\n")
print("OK ->", OUT, f"({len(blits)} blits)")
