#!/usr/bin/env python3
"""
Extracteur des tables physiques Lotus depuis CARS.REL → .asm 6809.

CARS.REL est chargé à $70400 sur Atari ST. Donc :
    file_offset = ram_addr - $70400

Tables utilisées par FUN_00075dec (= tick physique central, doc 21) :

    $7ca9c   76 shorts BE  engine torque ACCEL  (peak ≈ 96 vers RPM idx 24-31)
    $7cb34   76 shorts BE  engine torque NORMAL (cruise/coast, valeurs négatives)
    $7cbcc    5 shorts BE  gear_mul (divisor RPM par gear 0..4)
    $7cbf8   ~50 bytes signed  lateral damping (par bucket position latérale)

Le 6809 est big-endian comme le 68000 — les valeurs peuvent être copiées
telles quelles (fdb = 16-bit BE, fcb signé = 8-bit signed).

Usage :
    python3 tools/extract_physics_tables.py [-o OUT.asm]
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# ── Constantes Lotus ─────────────────────────────────────────────────────────
CARS_REL_BASE = 0x70400          # base offset de chargement CARS.REL sur ST

TABLES = [
    # (ram_addr, count, element_type, name, comment)
    (0x7ca9c, 76, 'short', 'PhysTable_EngineAccel',
     'Engine torque ACCEL — indexé par (rpm >> 7), peak ≈ 96 vers idx 24-31, '
     'négatif au-delà de 60 (= over-rev / redline)'),
    (0x7cb34, 76, 'short', 'PhysTable_EngineNormal',
     'Engine torque NORMAL (cruise) — toujours négatif, -5 → -700 selon RPM'),
    (0x7cbcc,  5, 'short', 'PhysTable_GearMul',
     "gear_mul (divisor) par gear 0..4 : 15701, 25685, 38528, 51200, 63488"),
    (0x7cbf8, 64, 'byte_signed', 'PhysTable_LateralDamp',
     'Lateral damping par (lateral_render + $200) >> 4 ∈ [8,56]. '
     'Valeur = shift amount appliqué à `speed -= speed >> damp >> 1`. '
     '6 aux extrêmes (= herbe), 0 au centre (= asphalte).'),
]


def extract_table(data: bytes, ram_addr: int, count: int, elem_type: str):
    """Extrait une table depuis CARS.REL. Renvoie liste d'entiers signés."""
    file_offset = ram_addr - CARS_REL_BASE
    if elem_type == 'short':
        size = 2
        fmt = '>h'
    elif elem_type == 'byte_signed':
        size = 1
        fmt = 'b'
    else:
        raise ValueError(elem_type)
    values = []
    for i in range(count):
        chunk = data[file_offset + i*size : file_offset + (i+1)*size]
        values.append(struct.unpack(fmt, chunk)[0])
    return values


def emit_table(name: str, comment: str, ram_addr: int, values, elem_type: str,
               lines: list[str]):
    lines.append("")
    lines.append("* " + "─" * 70)
    lines.append(f"* {name}")
    lines.append(f"* Source : CARS.REL RAM ${ram_addr:04X} "
                 f"(file +${ram_addr - CARS_REL_BASE:04X})")
    # comment multi-ligne
    for chunk in [comment[i:i+68] for i in range(0, len(comment), 68)]:
        lines.append(f"*   {chunk}")
    lines.append("* " + "─" * 70)
    lines.append(name)

    if elem_type == 'short':
        # fdb par paquets de 8 valeurs
        per_line = 8
        for i in range(0, len(values), per_line):
            row = values[i:i+per_line]
            hex_vals = ",".join(f"${v & 0xFFFF:04X}" for v in row)
            lines.append(f"        fdb   {hex_vals}    ; [{i:2d}..{i+len(row)-1:2d}]")
    elif elem_type == 'byte_signed':
        # fcb par paquets de 16
        per_line = 16
        for i in range(0, len(values), per_line):
            row = values[i:i+per_line]
            hex_vals = ",".join(f"${v & 0xFF:02X}" for v in row)
            lines.append(f"        fcb   {hex_vals}    ; [{i:2d}..{i+len(row)-1:2d}]")


def main(argv):
    p = argparse.ArgumentParser(
        description="Extrait les tables physiques Lotus → .asm 6809")
    script_dir = Path(__file__).resolve().parent
    default_src = (script_dir.parent / 'lotus-ste' / 'gamefiles' / 'source'
                   / 'CARS.REL')
    default_out = (script_dir.parent / 'engine' / 'physics'
                   / 'PhysicsTables_ST_reference.asm')
    p.add_argument('--src', type=Path, default=default_src,
                   help=f"Chemin CARS.REL (défaut : {default_src})")
    p.add_argument('-o', '--output', type=Path, default=default_out,
                   help=f"Fichier .asm de sortie (défaut : {default_out})")
    args = p.parse_args(argv[1:])

    if not args.src.exists():
        print(f"❌ Source introuvable : {args.src}", file=sys.stderr)
        return 1

    data = args.src.read_bytes()
    print(f"📂 Source : {args.src} ({len(data):,} octets)")
    print(f"📂 Destination : {args.output}")
    print(f"📐 Base RAM ↔ file offset : ${CARS_REL_BASE:04X}")

    # Header ASM
    out_lines = [
        "        opt   c",
        "* " + "=" * 70,
        "* PhysicsTables.asm",
        "* ",
        "* Tables physiques Lotus Esprit Turbo Challenge — extraites de",
        "* CARS.REL (Atari ST original) par tools/extract_physics_tables.py.",
        "* ",
        "* Format conservé fidèlement (big-endian, valeurs identiques).",
        "* Consommé par PlayerTick (cf. lotus-ste/.../21_TICK_PHYSIQUE_JOUEUR.md).",
        "* " + "=" * 70,
    ]

    for ram_addr, count, elem_type, name, comment in TABLES:
        values = extract_table(data, ram_addr, count, elem_type)
        emit_table(name, comment, ram_addr, values, elem_type, out_lines)
        print(f"   {name:<28} : {count} × {elem_type:<12} @ ${ram_addr:04X}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(out_lines) + "\n")
    print(f"\n✓ {args.output} écrit")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
