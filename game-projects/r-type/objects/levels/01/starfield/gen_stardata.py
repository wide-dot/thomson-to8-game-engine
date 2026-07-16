#!/usr/bin/env python3
"""Genere stardata.asm : les adresses VRAM des etoiles, precalculees.

Pourquoi : l'adresse d'une etoile ne depend que de (plan, tour, offset, etoile),
toutes connues a la compilation -- x_base et y sont des constantes, l'offset ne
prend que 144 valeurs entieres, et le nombre de tours est fixe. Le calcul
d'adresse (banque + x/4 + 40*y + wrap) disparait au profit d'un `ldx <off>,u`.

La table vit dans la PAGE CARTOUCHE de l'objet : gratuite en RAM residente, et
valable pour les DEUX buffers video (le pager permute les pages physiques,
l'adresse logique ne change pas).

TOURS (laps) -- pourquoi le plan 0 en a 2 --------------------------------------
Le defilement est cyclique : l'offset boucle sur 144 colonnes, donc tout se
repete a l'identique toutes les 144 trames. Le plan 0 (1 px/trame) repasse ~4
fois pendant l'intro -> on voit le motif "toujours au meme endroit". Pour casser
ca, le plan 0 a DEUX tours de table : a chaque tour, chaque etoile reapparait a
une hauteur (y) differente. Periode portee de 144 a 288 trames (~5,75 s).

Le y d'une etoile ne peut changer QUE quand elle est hors ecran, c.-a-d. a
l'instant PRECIS ou elle sort a gauche et reapparait a droite (le "wrap"). Sinon
elle sauterait verticalement en plein ecran. Le generateur simule donc le
defilement colonne par colonne et n'avance le y d'une etoile qu'a son wrap :
la table encode la bonne hauteur a chaque ligne, sans aucun saut visible.

Les plans 1 et 2 sont lents (0,5 et 0,25 px/trame) : leurs periodes (5,75 s et
11,5 s) depassent deja l'intro, ils gardent donc UN seul tour.

CONTRAINTE PARITE : tous les x_base sont PAIRS. Le wrap ajoute 144 (pair), donc
parite(x) == parite(off) pour toutes les etoiles d'un plan et a tous les tours.
Le nibble est connu par plan et par passe, pas par etoile -> 2 o/entree et pas
de test de parite par etoile.

NOMBRE D'ETOILES PAR PLAN : 8 pour le plan 0, 7 pour les autres. Le corps
deroule de obj.asm place le bloc de la 8e etoile EN TETE et enchaine sur la 1re
(cf. obj.asm). La 8e etoile est la DERNIERE de la liste (offset 14).

Usage : python3 gen_stardata.py > stardata.asm
"""

X_MIN, X_MAX, SPAN = 8, 151, 144        # ciel ouvert : colonnes 8..151
Y_MIN, Y_MAX = 11, 154                  # rangees de tuiles 0..11

# Par plan : (nb_tours, [ (x_base PAIR, [y par tour]) ]).
# Le plan 0 a 2 tours -> chaque etoile porte 2 hauteurs (une par tour). Les
# plans 1 et 2 ont 1 tour -> une seule hauteur.
#
# Le plan 0 (blanc, rapide, le plus lisible) est en DEUX AMAS de 4 : deux
# paquets separes par ~44 colonnes de vide, qui se lisent comme du hasard plutot
# que l'ancienne regle graduee (espacement quasi constant). Les deux hauteurs de
# chaque etoile sont bien separees pour que le 2e tour tombe ailleurs en y.
PLANES = [
    ("starTab_p0", 2, [
        # amas A
        (16, [24, 96]),
        (26, [58, 138]),
        (38, [33, 112]),
        (48, [79, 20]),
        # amas B
        (92, [128, 41]),
        (104, [146, 88]),
        (118, [95, 150]),
        (130, [131, 63]),
    ]),
    ("starTab_p1", 1, [
        (20, [71]), (44, [15]), (62, [124]), (88, [39]),
        (104, [148]), (120, [66]), (134, [104]),
    ]),
    ("starTab_p2", 1, [
        (8, [53]), (28, [136]), (52, [29]), (70, [101]),
        (92, [145]), (108, [12]), (122, [76]),
    ]),
]


def wrap(x_base, off):
    """x = x_base - off ramene dans 8..151 (identique a l'ASM : bcs puis cmpa/bhs)."""
    d = x_base - off
    a = d & 0xFF
    if d < 0 or a < X_MIN:
        a = (a + SPAN) & 0xFF
    return a


def vram_addr(x, y):
    """Modele BM16 confirme en tache 1. Plans INVERSES : $C000 si (x AND 2)=0."""
    base = 0xC000 if (x & 2) == 0 else 0xA000
    return base + (x >> 2) + 40 * y


def plane_rows(stars, laps):
    """Simule laps*144 colonnes. Le y d'une etoile n'avance qu'a son wrap (sortie
    a gauche), donc aucun saut vertical a l'ecran. Retourne la liste des lignes,
    chaque ligne etant la liste des adresses VRAM des etoiles a cette colonne."""
    n = len(stars)
    yidx = [0] * n
    prev_x = [None] * n
    rows = []
    for g in range(laps * SPAN):
        off = g % SPAN
        row = []
        for i, (xb, ylist) in enumerate(stars):
            x = wrap(xb, off)
            # wrap = x a bondi vers la droite par rapport a la colonne precedente
            if prev_x[i] is not None and x > prev_x[i]:
                yidx[i] = (yidx[i] + 1) % len(ylist)
            prev_x[i] = x
            y = ylist[yidx[i]]
            assert X_MIN <= x <= X_MAX, (xb, off, x)
            assert Y_MIN <= y <= Y_MAX, "y hors ciel : %d" % y
            assert (x & 1) == (off & 1), "parite rompue : %d %d" % (xb, off)
            a = vram_addr(x, y)
            assert 0xA000 <= a <= 0xDFFF, "adresse hors VRAM : %04X" % a
            row.append(a)
        rows.append(row)
    # invariant de couture : apres laps wraps, chaque etoile est revenue a son y0
    for i, (xb, ylist) in enumerate(stars):
        assert laps % len(ylist) == 0, "tours %d incompatibles avec %d hauteurs" % (laps, len(ylist))
    return rows


def main():
    print("; ===========================================================================")
    print("; stardata.asm - GENERE PAR gen_stardata.py, NE PAS EDITER A LA MAIN.")
    print(";")
    print("; Adresses VRAM precalculees : [plan][tour][offset 0..143][etoile], 2 o/entree.")
    print("; Une entree = l'adresse VRAM complete (banque incluse) de l'etoile a cette")
    print("; colonne. Le tracage devient un `ldx <offset>,u`, U pointant deja sur le")
    print("; bon tour (StarSetup ajoute tour*lapStride).")
    print(";")
    print("; Le plan 0 a 2 tours (hauteurs differentes a chaque passage), les plans 1 et")
    print("; 2 en ont 1. Le PAS et le lapStride sont publies dans planeTable (obj.asm).")
    print("; Tous les x_base sont PAIRS -> parite(x) == parite(off) -> nibble par plan.")
    print("; ===========================================================================")

    total = 0
    for label, laps, stars in PLANES:
        for x_base, ylist in stars:
            assert x_base % 2 == 0, "x_base doit etre PAIR : %d" % x_base
            assert X_MIN <= x_base <= X_MAX, "x_base hors ciel : %d" % x_base

        rows = plane_rows(stars, laps)
        print("")
        print("; --- %s : %d etoiles, %d tour(s), pas = %d octets, lapStride = %d octets"
              % (label, len(stars), laps, len(stars) * 2, len(stars) * 2 * SPAN))
        print("; %s" % ", ".join("(x=%d,y=%s)" % (xb, "/".join(map(str, yl))) for xb, yl in stars))
        print(label)
        for lap in range(laps):
            if laps > 1:
                print("; tour %d" % lap)
            for off in range(SPAN):
                words = ["$%04X" % a for a in rows[lap * SPAN + off]]
                # pas d'espace apres les virgules : lwasm rejette "fdb 1, 2"
                print("        fdb   %s" % ",".join(words))
                total += len(words) * 2

    print("")
    print("; total table : %d octets (page cartouche)" % total)


if __name__ == "__main__":
    main()
