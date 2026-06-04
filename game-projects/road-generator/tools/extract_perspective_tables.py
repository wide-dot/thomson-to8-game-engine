#!/usr/bin/env python3
"""
Extrait depuis FILE59.bin les 3 tables de perspective utilisées par le rendu
route Lotus, et les sort en .asm 6809.

## Layout de FILE59 (5120 oct = 0x1400)

FILE59 est chargé en RAM ST à $2fd40 (déterminé par hypothèse cohérente avec
les xref CARS.REL : $2fd80 = +0x40, $30d40 = +0x1000, $30e40 = +0x1100).

| Offset      | Taille  | Rôle                                              |
|-------------|---------|---------------------------------------------------|
| 0x0000-003F | 64 oct  | header zéros                                      |
| 0x0040-023F | 512 oct | table 1/n × 2^20  (group 1 — base, k=1)           |
| 0x0240-043F | 512 oct | table 1/n × 9     (group 2)                       |
| 0x0440-063F | 512 oct | table 1/n × 17    (group 3)                       |
| 0x0640-083F | 512 oct | table 1/n × 25    (group 4)                       |
| 0x0840-0A3F | 512 oct | table 1/n × 33    (group 5)                       |
| 0x0A40-0C3F | 512 oct | table 1/n × 41    (group 6)                       |
| 0x0C40-0E3F | 512 oct | table 1/n × 49    (group 7)                       |
| 0x0E40-0FFF | 448 oct | table 1/n × 57    (group 8, tronqué)              |
| 0x1000-10FF | 256 oct | Y_HORIZON   (128 mots, courbe 1/Z descendant 95→39)|
| 0x1100-11FF | 256 oct | SCALING     (128 mots, descendant 4095→160)       |
| 0x1200-13FF | 512 oct | bloc final (= 4ème table mots ?)                  |

## Usage 68000 (cf. CARS.REL.asm.txt offset 8698 = FUN_78a98)

    lea  $30d40, A4      ; A4 = ptr horizon
    lea  $30e40, A3      ; A3 = ptr scaling
    ; pour chaque ligne :
    muls.w  (A3)+, D6    ; D6 = altitude * scaling
    swap    D6           ; high word
    add.w   (A4)+, D6    ; + horizon → Y_ecran

## Conversion TO8

- Y_horizon : pas de conversion (= coord Y écran, identique car 200 lignes
  TO8 et ST sont les mêmes verticalement).
- Scaling : pas de conversion (= ratio sans dimension pixel).
- 1/n × 2^20 : pas de conversion (= ratio).

## Output

engine/projection/PerspectiveTables.asm
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FILE59_LOAD_ADDR = 0x2FD40     # adresse runtime ST (hypothèse vérifiée)
ADDR_TABLE_RECIP = 0x2FD80     # = +0x40, group 1 (k=1)
ADDR_TABLE_HORIZON = 0x30D40   # = +0x1000
ADDR_TABLE_SCALING = 0x30E40   # = +0x1100

OFF_RECIP_BASE = ADDR_TABLE_RECIP - FILE59_LOAD_ADDR    # 0x0040
OFF_HORIZON    = ADDR_TABLE_HORIZON - FILE59_LOAD_ADDR  # 0x1000
OFF_SCALING    = ADDR_TABLE_SCALING - FILE59_LOAD_ADDR  # 0x1100

N_LINES        = 128            # 128 mots par table perspective
RECIP_GROUP_SIZE = 0x200        # 512 oct = 128 longs par groupe 1/n
RECIP_NB_GROUPS  = 8            # nb groupes 1/n × k (k = 1,9,17,...,57)


def emit_words_table(name: str, values: list, lines: list, comment: str,
                     per_line: int = 8, signed: bool = True):
    lines.append("")
    lines.append("* " + "─" * 70)
    lines.append(f"* {name}")
    for chunk in [comment[i:i+68] for i in range(0, len(comment), 68)]:
        lines.append(f"*   {chunk}")
    lines.append("* " + "─" * 70)
    lines.append(name)
    for i in range(0, len(values), per_line):
        row = values[i:i+per_line]
        if signed:
            hex_vals = ",".join(f"${v & 0xFFFF:04X}" for v in row)
        else:
            hex_vals = ",".join(f"${v:04X}" for v in row)
        # Annotation décimale en commentaire
        dec_vals = " ".join(f"{v:5d}" for v in row)
        lines.append(f"        fdb   {hex_vals}    ; [{i:3d}..{i+len(row)-1:3d}] {dec_vals}")


def emit_longs_table(name: str, values: list, lines: list, comment: str,
                     per_line: int = 4):
    """Émet une table de longs (fqb en lwasm = fdb,fdb = 4 octets)."""
    lines.append("")
    lines.append("* " + "─" * 70)
    lines.append(f"* {name}")
    for chunk in [comment[i:i+68] for i in range(0, len(comment), 68)]:
        lines.append(f"*   {chunk}")
    lines.append("* " + "─" * 70)
    lines.append(name)
    for i in range(0, len(values), per_line):
        row = values[i:i+per_line]
        # 1 long = 2 fdb (high word, low word)
        hex_vals = ",".join(f"${(v >> 16) & 0xFFFF:04X},${v & 0xFFFF:04X}"
                            for v in row)
        lines.append(f"        fdb   {hex_vals}    ; [{i:3d}..{i+len(row)-1:3d}]")


def main(argv):
    p = argparse.ArgumentParser(description="Extrait tables perspective Lotus")
    script_dir = Path(__file__).resolve().parent
    default_src = (script_dir.parent / 'lotus-ste' / 'doc' / 'extraction'
                   / 'unpacked' / 'FILE59.bin')
    default_out = (script_dir.parent / 'engine' / 'projection'
                   / 'PerspectiveTables.asm')
    p.add_argument('--src', type=Path, default=default_src)
    p.add_argument('-o', '--output', type=Path, default=default_out)
    args = p.parse_args(argv[1:])

    if not args.src.exists():
        print(f"❌ Source introuvable : {args.src}", file=sys.stderr)
        return 1
    data = args.src.read_bytes()
    print(f"📂 Source : {args.src}  ({len(data)} oct)")
    print(f"📂 Destination : {args.output}")

    # --- Extraction ---
    horizon = list(struct.unpack(f'>{N_LINES}h',
                                 data[OFF_HORIZON:OFF_HORIZON + N_LINES*2]))
    scaling = list(struct.unpack(f'>{N_LINES}h',
                                 data[OFF_SCALING:OFF_SCALING + N_LINES*2]))

    # NOTE : les 8 groupes Persp_Recip_k01..k57 ne sont PLUS émis ici.
    # Ils sont désormais générés en binaire compacté 2-tier par
    # tools/build_persp_recip_paged.py → Persp_Recip_paged.bin.
    # Cette extraction garde uniquement Horizon + Scaling (= résident) +
    # les EQUs de dispatch + A4_table (= LUT précomputée pour le depth dither).

    # --- Émission .asm ---
    out_lines = [
        " ifndef PerspectiveTables_included",
        "PerspectiveTables_included equ 1",
        "* " + "=" * 70,
        "* PerspectiveTables.asm — TABLES PERSPECTIVE PRÉCALCULÉES",
        "* ",
        "* Extraites de FILE59.bin (= FILE59.SCR décompressé) par",
        "* tools/extract_perspective_tables.py.",
        "* ",
        "* Layout source ST :",
        f"*   FILE59 chargé à ${FILE59_LOAD_ADDR:04X}",
        f"*   1/n × k tables : ${ADDR_TABLE_RECIP:04X} ({RECIP_NB_GROUPS} groupes × 128 longs)",
        f"*   Y horizon      : ${ADDR_TABLE_HORIZON:04X} ({N_LINES} mots signés)",
        f"*   Scaling factor : ${ADDR_TABLE_SCALING:04X} ({N_LINES} mots signés)",
        "* ",
        "* Conversion TO8 : aucune (= ratios + coord Y, dimensions verticales",
        "* identiques 200 lignes ST/TO8 ; pas d'axe horizontal X à halver ici).",
        "* ",
        "* Référence 68000 : CARS.REL.asm.txt FUN_78a98 (= ram:$78a98, off $8698)",
        "* " + "=" * 70,
    ]

    # Persp_Horizon et Persp_Scaling sont migrées dans Persp_Recip_paged.bin
    # à offset $C00..$DFF (= runtime $5C00..$5DFF). Émet juste les EQUs.
    out_lines.append("")
    out_lines.append("* " + "─" * 70)
    out_lines.append("* Persp_Horizon — Y horizon par ligne (128 mots, courbe 1/Z)")
    out_lines.append("*   Migré dans Persp_Recip_paged.bin à $5C00 (= padding zone).")
    out_lines.append("*   Lue par SparseProjection : ldu #Persp_Horizon ; 256,u = Persp_Scaling")
    out_lines.append("*   Valeurs (= référence) : " + ", ".join(str(v) for v in horizon[:8]) + ", ...")
    out_lines.append("* " + "─" * 70)
    out_lines.append("Persp_Horizon                   equ $5C00           ; 256 oct (128 mots)")
    out_lines.append("")
    out_lines.append("* " + "─" * 70)
    out_lines.append("* Persp_Scaling — facteur scaling par ligne (128 mots, décroît 4095→160)")
    out_lines.append("*   Migré dans Persp_Recip_paged.bin à $5D00.")
    out_lines.append("*   Lue par SparseProjection (via 256,u).")
    out_lines.append("*   Valeurs (= référence) : " + ", ".join(str(v) for v in scaling[:8]) + ", ...")
    out_lines.append("* " + "─" * 70)
    out_lines.append("Persp_Scaling                   equ $5D00           ; 256 oct (128 mots)")

    # ──────────────────────────────────────────────────────────────────
    # EQUs FILE59 paged (= layout 2-tier compact) + A4_table résident.
    # Voir build_persp_recip_paged.py pour la génération du binaire.
    # ──────────────────────────────────────────────────────────────────
    out_lines.append("")
    out_lines.append("* " + "─" * 70)
    out_lines.append("* FILE59 step LUT — TABLE 2-TIER COMPACTÉE (PAGÉE)")
    out_lines.append("*")
    out_lines.append("*   $5000..$53FF  Plage A : entries 0..511 packed 2 oct/entry")
    out_lines.append("*   $5400..$5BFF  Plage B : entries 512..1023 full 4 oct/entry")
    out_lines.append("*   $5C00..$5DFF  Persp_Horizon + Persp_Scaling (= migrés du résident)")
    out_lines.append("*   $5E00..$5FFF  Padding zéros (= 512 oct dispo)")
    out_lines.append("*")
    out_lines.append("* Génération : tools/build_persp_recip_paged.py")
    out_lines.append("* Consommation : LinearInterp.asm via dispatch cmpd #LI_PLAGE_BOUNDARY")
    out_lines.append("* " + "─" * 70)
    out_lines.append("LI_TABLE_A_BASE                 equ $5000")
    out_lines.append("LI_TABLE_B_BASE                 equ $5400")
    out_lines.append("LI_PLAGE_BOUNDARY               equ 512")

    # A4_table — précomputed floor(256/N) pour N=0..63
    out_lines.append("")
    out_lines.append("* " + "─" * 70)
    out_lines.append("* A4_table — précomputed depth dither step (= floor(256/N))")
    out_lines.append("*   Equivalent au calcul 68k : A4 = (1/N × 2^20 × 16) >> 16 = 256/N")
    out_lines.append("*   Indexed by N = nombre de lignes interp. Valeurs ∈ [4..128] → 8 bits.")
    out_lines.append("*   N=0,1 : path delta_zero/delta_one (jamais utilisé multi-line).")
    out_lines.append("* " + "─" * 70)
    out_lines.append("A4_table")
    a4_vals = [0 if n < 2 else 256 // n for n in range(64)]
    for i in range(0, 64, 8):
        line = a4_vals[i:i+8]
        hex_vals = ",".join(f"${v:02X}" for v in line)
        dec_vals = " ".join(f"{v:3d}" for v in line)
        out_lines.append(f"        fcb   {hex_vals}    ; N={i:2d}..{i+7:2d} : {dec_vals}")

    out_lines.append("")
    out_lines.append(" endc")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(out_lines) + "\n")

    # --- Récap ---
    print(f"   Persp_Horizon   : {N_LINES} mots — première 8 = "
          f"{horizon[:8]}")
    print(f"   Persp_Scaling   : {N_LINES} mots — première 8 = "
          f"{scaling[:8]}")
    print(f"   A4_table        : 64 oct (= floor(256/N) pour N=0..63)")
    print(f"   LI_TABLE_*      : 3 EQUs pour dispatch FILE59 paged")
    print(f"\n✓ {args.output} écrit")
    print(f"  (régénère le .bin paged via : python3 tools/build_persp_recip_paged.py)")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
