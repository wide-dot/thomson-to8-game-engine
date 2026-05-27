#!/usr/bin/env python3
"""
Conversion tables physiques Lotus ST → TO8.

Le TO8 en mode BM16 a 160 px de résolution horizontale contre 320 px
sur Atari ST → **toutes les valeurs liées à la vitesse/position
HORIZONTALE sont divisées par 2** pour conserver la perception identique.

## Règles de division (RIGOUREUX : seulement horizontal X)

ATTENTION subtilité : `speed` (struct[+0x10]) = vitesse FORWARD le long du
circuit, PAS la vitesse horizontale sur écran. Ne pas confondre. Idem
`MAX_SPEED`, `BRAKE_DECEL`, etc. → tous forward.

L'axe horizontal écran = lateral (`struct[+0x00]`), influencé par steering
(`struct[+0x12]`) × 5 × speed + steering_accum (`struct[+0x14]`) × 12 × speed
+ impulse (`struct[+0x72]`) × 0x8000.

| Valeur | Action | Justification |
|---|---|---|
| `LATERAL_HI/LO` (±0x180) | **`/ 2`** | clamp X → écran TO8 = ST/2 |
| `STEERING_MAX` (0x20) | **`/ 2`** | max steering × 5 × speed = max contribution latérale → /2 |
| `STEERING_DELTA` (2) | **`/ 2`** | préserve timing d'atteinte STEERING_MAX (responsiveness) |
| Engine torque (ACCEL, NORMAL) | identique | deltas SPEED forward, pas horizontal |
| `gear_mul` | identique | RPM ← speed forward, pas horizontal |
| `MAX_SPEED`, `BRAKE_DECEL`, `CRASH_DECEL` | identique | forward |
| `TARGET_SPEED` (0xA00, FUN_760ae) | identique | cible speed forward |
| `RPM_*`, `UPSHIFT_RPM`, `DOWNSHIFT_RPM` | identique | régime moteur |
| Lateral damping table | identique | = shift count (ratio sans dim) |
| `RECOVERY_TICKS` (25), `GEAR_COUNT` (5) | identique | temps / count |

## Halving

Utilise la division entière "floor" (= équivalent 68000 ASR.W #1) :
    -5 // 2 = -3 (vers -∞)
Préserve la cohérence pour valeurs signées.

Usage :
    python3 tools/convert_physics_tables_to8.py [-o OUT.asm]
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# ── Constantes Lotus (base $70400 sur Atari ST) ─────────────────────────────
CARS_REL_BASE = 0x70400

# ── Tables extraites (ram_addr, count, elem_type, name, halve?, comment) ────
TABLES = [
    (0x7ca9c, 76, 'short', False, 'PhysTable_EngineAccel',
     'Engine torque ACCEL — indexé par (rpm >> 7). '
     'IDENTIQUE ST : delta speed forward, pas horizontal.'),
    (0x7cb34, 76, 'short', False, 'PhysTable_EngineNormal',
     'Engine torque NORMAL (cruise). IDENTIQUE ST.'),
    (0x7cbcc,  5, 'short', False, 'PhysTable_GearMul',
     'gear_mul (divisor RPM) par gear 0..4. IDENTIQUE ST.'),
    (0x7cbf8, 64, 'byte_signed', False, 'PhysTable_LateralDamp',
     'Lateral damping (= shift count). IDENTIQUE — ratio sans dimension pixel.'),
]

# ── Constantes physiques (extraites de pseudo-C FUN_75dec/FUN_75e30) ────────
# (name, st_value, halve?, comment)
CONSTANTS = [
    # === FORWARD (speed) — IDENTIQUE ST ===
    ('PHYS_MAX_SPEED',     0x01AA, False,
     'Speed forward max clamp. IDENTIQUE ST (axe forward, pas horizontal).'),
    ('PHYS_BRAKE_DECEL',   0x0030, False,
     'Delta speed/tick sur DOWN. IDENTIQUE ST (axe forward).'),
    ('PHYS_CRASH_DECEL',   0x0018, False,
     'Delta speed/tick en crash. IDENTIQUE ST (axe forward).'),
    ('PHYS_TARGET_SPEED',  0x0A00, False,
     'Cible régulation speed (FUN_760ae). IDENTIQUE ST.'),

    # === HORIZONTAL X (= écran TO8 = ST/2) — DIVISÉ PAR 2 ===
    ('PHYS_LATERAL_HI',    0x0180, True,
     'Borne sup lateral_pos integer. /2 pour TO8 (écran horizontal /2).'),
    ('PHYS_LATERAL_LO',    -0x0180, True,
     'Borne inf lateral_pos integer. /2.'),
    ('PHYS_STEERING_MAX',  0x0020, True,
     'Clamp steering ∈ [-$20, +$20]. /2 car steering × 5 × speed contribue à '
     'lateral_pos → halver STEERING_MAX divise la contribution X par 2.'),
    ('PHYS_STEERING_DELTA', 0x0002, True,
     'Delta steering/tick sur LEFT/RIGHT. /2 pour préserver le TIMING '
     'd\'atteinte de STEERING_MAX (responsiveness identique en temps).'),

    # === RPM / GEAR / TIME — IDENTIQUE ===
    ('PHYS_RPM_MIN',       1000,   False,
     'Floor RPM. IDENTIQUE (régime moteur).'),
    ('PHYS_RPM_MAX',       7999,   False,
     'Ceiling RPM. IDENTIQUE.'),
    ('PHYS_UPSHIFT_RPM',   4000,   False,
     'Seuil RPM upshift auto. IDENTIQUE.'),
    ('PHYS_DOWNSHIFT_RPM', 0x09C3, False,
     'Seuil RPM downshift auto. IDENTIQUE.'),
    ('PHYS_GEAR_COUNT',    5,      False,
     'Nombre de rapports (0..4). IDENTIQUE.'),
    ('PHYS_RECOVERY_TICKS', 25,    False,
     'Durée recovery (= 25 frames = 0.5s à 50Hz). IDENTIQUE (= temps).'),
]


def halve_signed(v: int) -> int:
    """Division floor par 2 (équivalent 68000 ASR.W #1)."""
    return v // 2   # Python // = floor pour signed


def extract_table_values(data: bytes, ram_addr: int, count: int, elem_type: str):
    file_offset = ram_addr - CARS_REL_BASE
    fmt, size = {'short': ('>h', 2), 'byte_signed': ('b', 1)}[elem_type]
    return [struct.unpack(fmt, data[file_offset + i*size : file_offset + (i+1)*size])[0]
            for i in range(count)]


def emit_table(name, comment, ram_addr, values, elem_type, halved, lines):
    lines.append("")
    lines.append("* " + "─" * 70)
    lines.append(f"* {name}")
    if halved:
        lines.append(f"* Source : CARS.REL RAM ${ram_addr:04X} "
                     f"(file +${ram_addr - CARS_REL_BASE:04X})  →  /2 pour TO8")
    else:
        lines.append(f"* Source : CARS.REL RAM ${ram_addr:04X} "
                     f"(file +${ram_addr - CARS_REL_BASE:04X})  →  identique")
    for chunk in [comment[i:i+68] for i in range(0, len(comment), 68)]:
        lines.append(f"*   {chunk}")
    lines.append("* " + "─" * 70)
    lines.append(name)

    if elem_type == 'short':
        per_line = 8
        for i in range(0, len(values), per_line):
            row = values[i:i+per_line]
            hex_vals = ",".join(f"${v & 0xFFFF:04X}" for v in row)
            lines.append(f"        fdb   {hex_vals}    ; [{i:2d}..{i+len(row)-1:2d}]")
    elif elem_type == 'byte_signed':
        per_line = 16
        for i in range(0, len(values), per_line):
            row = values[i:i+per_line]
            hex_vals = ",".join(f"${v & 0xFF:02X}" for v in row)
            lines.append(f"        fcb   {hex_vals}    ; [{i:2d}..{i+len(row)-1:2d}]")


def emit_constants(lines):
    lines.append("")
    lines.append("* " + "=" * 70)
    lines.append("* Constantes physiques (EQU) — TO8 = ST/2 pour valeurs horizontales")
    lines.append("* " + "=" * 70)
    width = max(len(name) for name, *_ in CONSTANTS)
    for name, st_value, halve, comment in CONSTANTS:
        v = halve_signed(st_value) if halve else st_value
        mark = ' /2' if halve else '   '
        if v < 0:
            val_str = f"${v & 0xFFFF:04X}"   # 16-bit two's complement
        else:
            val_str = f"${v:04X}" if v >= 0x100 else f"${v:02X}"
        lines.append(f"{name:<{width+2}} equ   {val_str:<8}  ; ST=${st_value & 0xFFFF:04X}{mark}  {comment}")


def main(argv):
    p = argparse.ArgumentParser(
        description="Convertit tables physiques Lotus ST → TO8 (/2 horizontal)")
    script_dir = Path(__file__).resolve().parent
    default_src = (script_dir.parent / 'lotus-ste' / 'gamefiles' / 'source'
                   / 'CARS.REL')
    default_out = (script_dir.parent / 'engine' / 'physics'
                   / 'PhysicsTables.asm')
    p.add_argument('--src', type=Path, default=default_src)
    p.add_argument('-o', '--output', type=Path, default=default_out)
    args = p.parse_args(argv[1:])

    if not args.src.exists():
        print(f"❌ Source introuvable : {args.src}", file=sys.stderr)
        return 1

    data = args.src.read_bytes()
    print(f"📂 Source : {args.src}")
    print(f"📂 Destination : {args.output}")
    print(f"📐 Conversion ST → TO8 : valeurs horizontales /2")

    out_lines = [
        "        opt   c",
        " ifndef PhysicsTables_included",
        "PhysicsTables_included equ 1",
        "* " + "=" * 70,
        "* PhysicsTables.asm — TABLES PHYSIQUES VERSION TO8",
        "* ",
        "* Converties depuis Lotus ST (CARS.REL) par",
        "* tools/convert_physics_tables_to8.py.",
        "* ",
        "* Règle : valeurs horizontales /2 (TO8 = 160px vs ST 320px).",
        "* ",
        "* Référence faithful ST : engine/physics/PhysicsTables_ST_reference.asm",
        "* Doc physique         : lotus-ste/.../21_TICK_PHYSIQUE_JOUEUR.md",
        "* " + "=" * 70,
    ]

    # 1) EQU constantes
    emit_constants(out_lines)

    # 2) Tables binaires
    for ram_addr, count, elem_type, halve, name, comment in TABLES:
        values = extract_table_values(data, ram_addr, count, elem_type)
        if halve:
            values = [halve_signed(v) for v in values]
        emit_table(name, comment, ram_addr, values, elem_type, halve, out_lines)
        print(f"   {name:<28} : {count} × {elem_type:<12} "
              f"{'/2' if halve else '  '}")

    # Fin du guard
    out_lines.append("")
    out_lines.append(" endc")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(out_lines) + "\n")
    print(f"\n✓ {args.output} écrit")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
