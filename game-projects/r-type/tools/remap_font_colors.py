#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
remap_font_colors.py - remappe les index de couleur (nibbles) de la fonte
"STAGE-CLEARED" dupliquee dans objects/levels/hud/hud.asm.

Chaque "LDA #$XY" de la fonte charge un octet ecrit a l'ecran = 2 pixels, soit
2 index couleur 4-bit. On remappe nibble par nibble selon REMAP. Ne touche QUE
le bloc fonte (apres le header "STAGE-CLEARED FONT"), pas les DRAW_Img_hud_*.

Idempotent tant que les cibles ne sont pas elles-memes des sources.
"""
import re
import sys

# CORRECTION : swap des index 1 <-> 13 sur la fonte DEJA remappee.
# (effet cumule depuis la fonte d'origine : 4->1, 1->13, 9->6, 8->5)
# /!\ involution : ne PAS relancer (relancer ré-inverse 1 et 13).
REMAP = {13: 1, 1: 13}

PATH = "objects/levels/hud/hud.asm"
MARKER = "STAGE-CLEARED FONT"
PAT = re.compile(r'(LDA\s+#\$)([0-9A-Fa-f])([0-9A-Fa-f])')


def remap_nibble(c):
    v = REMAP.get(int(c, 16), int(c, 16))
    if v > 0xF:
        raise ValueError("index cible %X > 15 (1 nibble): %r" % (v, c))
    return format(v, 'x')


def main():
    with open(PATH, encoding="utf-8") as f:
        lines = f.readlines()

    start = next((i for i, l in enumerate(lines) if MARKER in l), None)
    if start is None:
        sys.exit("marqueur '%s' introuvable dans %s" % (MARKER, PATH))

    before = {}
    for l in lines[start:]:
        for m in PAT.finditer(l):
            b = (m.group(2) + m.group(3)).lower()
            before[b] = before.get(b, 0) + 1

    cnt = [0]

    def repl(m):
        cnt[0] += 1
        return m.group(1) + remap_nibble(m.group(2)) + remap_nibble(m.group(3))

    for i in range(start, len(lines)):
        lines[i] = PAT.sub(repl, lines[i])

    with open(PATH, "w", encoding="utf-8") as f:
        f.writelines(lines)

    print("bloc fonte depuis ligne %d" % (start + 1))
    print("octets LDA distincts AVANT :", dict(sorted(before.items())))
    print("remappes : %d occurrences (%d octets distincts)" % (cnt[0], len(before)))


if __name__ == "__main__":
    main()
