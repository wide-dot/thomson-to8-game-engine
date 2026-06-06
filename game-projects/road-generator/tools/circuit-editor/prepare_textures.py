#!/usr/bin/env python3
"""
prepare_textures.py — ONE-SHOT (à lancer une seule fois).

Crée une COPIE locale des textures de route dans le projet de l'éditeur
(tools/circuit-editor/assets/), indépendante de l'export pipeline
(tools/road_sprites_source/). Dans la copie, la zone TRANSPARENTE (index 0) est
remplie avec l'index de couleur HERBE de chaque texture :
  - normal_dark.png  : idx 0 -> idx 3 (herbe foncée 30,90,30)
  - normal_light.png : idx 0 -> idx 4 (herbe claire 60,130,60)

=> la ligne route couvre alors toute sa largeur d'herbe (jusqu'aux bords de la
texture), et l'herbe alterne dark/light comme la route. Le fond non-dessiné
(au-dessus de l'horizon) reste géré séparément par l'éditeur.

Usage : .venv/bin/python3 tools/circuit-editor/prepare_textures.py
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]          # .../road-generator
SRC = ROOT / "tools" / "road_sprites_source"
DST = ROOT / "tools" / "circuit-editor" / "assets"
DST.mkdir(parents=True, exist_ok=True)

# (fichier, index herbe à utiliser pour remplir le transparent)
JOBS = [("normal_dark.png", 3), ("normal_light.png", 4)]

for name, grass_idx in JOBS:
    im = Image.open(SRC / name)
    assert im.mode == "P", f"{name} doit être indexé (mode P), trouvé {im.mode}"
    data = list(im.getdata())
    n0 = data.count(0)
    data = [grass_idx if v == 0 else v for v in data]
    out = Image.new("P", im.size)
    out.putpalette(im.getpalette())
    out.putdata(data)
    out.save(DST / name)   # PNG indexé, sans tRNS
    print(f"{name}: {n0} px transparents -> idx {grass_idx} | écrit {DST / name}")

print(f"\n✓ copies prêtes dans {DST}")
