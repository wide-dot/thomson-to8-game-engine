#!/usr/bin/env python3
"""
Génère Persp_Recip_paged.bin avec layout 2-tier compact.

## Layout source FILE59.bin (= 5120 oct, 1280 entries 32-bit)

Indexée par `(diff_aligned + N) × 4`, où `diff_aligned` est multiple de 16
et `N` est le nombre de lignes pour l'interpolation linéaire.

Entries 0..1023 (= byte 0..$FFF) = step values `(diff_aligned/N) × 2^16`
truncated à multiple de $1000. Pattern :
  - Entries 0..511 (= byte 0..$7FF) : `byte 0 = 0` ET `byte 3 = 0`
    → tout l'info tient dans bytes 1+2 = 16-bit packed.
  - Entries 512..1023 (= byte $800..$FFF) : `byte 0 != 0` possible (= overflow)
    → encoding 32-bit complet nécessaire.

Entries 1024..1279 (= byte $1000..$13FF) = Persp_Horizon + Persp_Scaling +
autre table. PAS utilisées par LinearInterp comme step values. Extraites
séparément en résident via extract_perspective_tables.py.

## Layout cible Persp_Recip_paged.bin (= 4096 oct)

  $5000..$53FF (= 1024 oct) : Plage A (entries 0..511, packed 2 oct/entry)
  $5400..$5BFF (= 2048 oct) : Plage B (entries 512..1023, full 4 oct/entry)
  $5C00..$5CFF (=  256 oct) : Persp_Horizon (= migré du résident, FILE59+$1000)
  $5D00..$5DFF (=  256 oct) : Persp_Scaling (= migré du résident, FILE59+$1100)
  $5E00..$5FFF (=  512 oct) : zéros (= padding, dispo pour future data)

Total data utile : 3072 oct (vs 4096 dans l'ancien layout linéaire).

## Encodage Plage A

Long original $00 B1 B2 $00 (= 32-bit big-endian, bytes 0+3 toujours nuls)
encodé comme 2 octets [B1, B2] dans la table A.

Au runtime, on reconstruit `D3 = $00 B1 B2 $00` via :
  ldd ,x          ; A=B1, B=B2
  std LI_d3_int+1 ; écrit [B1][B2] aux offsets +1, +2 = LI_d3_int+1 + LI_d3_frac+0
  ; LI_d3_int+0 et LI_d3_frac+1 restent à $00 (= jamais touchés après init)

## Dispatch côté LinearInterp

  index = diff_aligned + N
  if index < 512 : lookup Plage A (offset = index × 2)
  else           : lookup Plage B (offset = (index - 512) × 4)

## Usage

  python3 tools/build_persp_recip_paged.py
  python3 tools/build_persp_recip_paged.py --src PATH --dst PATH
"""

import argparse
import struct
import sys
from pathlib import Path


PLAGE_A_END = 512        # index boundary (entries 0..511 in plage A)
PLAGE_B_END = 1024       # plage B covers entries 512..1023

# Option A (fix overflow patterns 66 routines) : le persp est désormais packé
# APRÈS les patterns dans la demi-page → base runtime $5200 (au lieu de $5000),
# et le padding 512 o final est retiré pour que tout rentre dans $5200-$5FFF.
RUNTIME_BASE = 0x5200    # base cart-view du persp (= LI_TABLE_A_BASE asm)
TABLE_A_OFFSET = 0       # plage A à offset 0 (= $5200 runtime)
TABLE_B_OFFSET = PLAGE_A_END * 2   # = 1024 (= $5600 runtime)

# Tables migrées du résident vers le paged binary :
HORIZON_OFFSET = 0xC00   # = $5E00 runtime (256 oct)
SCALING_OFFSET = 0xD00   # = $5F00 runtime (256 oct)
PERSP_TABLE_SIZE = 256   # 128 mots × 2 oct

# Taille = fin de Scaling (= $E00 = 3584 o), SANS padding : rentre pile dans la
# demi-page juste après les patterns (4497 o + 3584 o = 8081 ≤ 8192).
TABLE_SIZE_TOTAL = SCALING_OFFSET + PERSP_TABLE_SIZE   # 0xE00 = 3584

# Offsets dans FILE59.bin source :
FILE59_HORIZON_SRC = 0x1000
FILE59_SCALING_SRC = 0x1100


def main(argv):
    p = argparse.ArgumentParser(description="Génère Persp_Recip_paged.bin 2-tier")
    script_dir = Path(__file__).resolve().parent
    default_src = (script_dir.parent / 'lotus-ste' / 'doc' / 'extraction'
                   / 'unpacked' / 'FILE59.bin')
    default_dst = (script_dir.parent / 'engine' / 'projection'
                   / 'Persp_Recip_paged.bin')
    p.add_argument('--src', type=Path, default=default_src)
    p.add_argument('--dst', type=Path, default=default_dst)
    p.add_argument('--check', action='store_true',
                   help="Vérifie l'invariant byte 0/3 = 0 pour la plage A")
    args = p.parse_args(argv[1:])

    if not args.src.exists():
        print(f"❌ Source introuvable : {args.src}", file=sys.stderr)
        return 1

    src_data = args.src.read_bytes()
    print(f"📂 Source : {args.src}  ({len(src_data)} oct)")
    print(f"📂 Destination : {args.dst}")

    if len(src_data) < PLAGE_B_END * 4:
        print(f"❌ FILE59.bin trop court : {len(src_data)} < "
              f"{PLAGE_B_END * 4} oct attendus", file=sys.stderr)
        return 2

    # --- Vérification invariant Plage A ---
    bad_a = []
    for i in range(PLAGE_A_END):
        off = i * 4
        b0, b1, b2, b3 = src_data[off:off+4]
        if b0 != 0 or b3 != 0:
            bad_a.append((i, b0, b1, b2, b3))
    if bad_a:
        print(f"⚠️  {len(bad_a)} entries de Plage A violent l'invariant "
              f"byte 0 = 0 ET byte 3 = 0 :")
        for x in bad_a[:5]:
            print(f"    entry {x[0]}: bytes = {x[1]:02X} {x[2]:02X} "
                  f"{x[3]:02X} {x[4]:02X}")
        if not args.check:
            print(f"    (continuera quand même, mais l'encoding 16-bit va "
                  f"PERDRE l'info)")

    # --- Génération Plage A (= packed 16-bit) ---
    plage_a = bytearray(PLAGE_A_END * 2)
    for i in range(PLAGE_A_END):
        off = i * 4
        b1 = src_data[off + 1]
        b2 = src_data[off + 2]
        plage_a[i * 2 + 0] = b1
        plage_a[i * 2 + 1] = b2

    # --- Génération Plage B (= full 32-bit, copie directe) ---
    plage_b_size = (PLAGE_B_END - PLAGE_A_END) * 4
    plage_b = bytearray(plage_b_size)
    for i in range(PLAGE_A_END, PLAGE_B_END):
        src_off = i * 4
        dst_off = (i - PLAGE_A_END) * 4
        plage_b[dst_off:dst_off+4] = src_data[src_off:src_off+4]

    # --- Extraction tables résidentes migrées ---
    persp_horizon = src_data[FILE59_HORIZON_SRC:FILE59_HORIZON_SRC + PERSP_TABLE_SIZE]
    persp_scaling = src_data[FILE59_SCALING_SRC:FILE59_SCALING_SRC + PERSP_TABLE_SIZE]

    # --- Assemble paged binary ---
    out = bytearray(TABLE_SIZE_TOTAL)
    out[TABLE_A_OFFSET:TABLE_A_OFFSET + len(plage_a)] = plage_a
    out[TABLE_B_OFFSET:TABLE_B_OFFSET + len(plage_b)] = plage_b
    out[HORIZON_OFFSET:HORIZON_OFFSET + PERSP_TABLE_SIZE] = persp_horizon
    out[SCALING_OFFSET:SCALING_OFFSET + PERSP_TABLE_SIZE] = persp_scaling
    # reste = zéros (= padding $5E00..$5FFF)

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_bytes(bytes(out))

    print(f"✓ Plage A      : {len(plage_a):4d} oct (entries 0..{PLAGE_A_END-1}, packed 2 oct/entry) → ${RUNTIME_BASE + TABLE_A_OFFSET:04X}")
    print(f"✓ Plage B      : {len(plage_b):4d} oct (entries {PLAGE_A_END}..{PLAGE_B_END-1}, full 4 oct/entry) → ${RUNTIME_BASE + TABLE_B_OFFSET:04X}")
    print(f"✓ Persp_Horizon: {PERSP_TABLE_SIZE:4d} oct (128 mots) → ${RUNTIME_BASE + HORIZON_OFFSET:04X}")
    print(f"✓ Persp_Scaling: {PERSP_TABLE_SIZE:4d} oct (128 mots) → ${RUNTIME_BASE + SCALING_OFFSET:04X}")
    used = len(plage_a) + len(plage_b) + 2*PERSP_TABLE_SIZE
    print(f"✓ Padding      : {TABLE_SIZE_TOTAL - used:4d} oct (zéros, dispo future) → ${RUNTIME_BASE + SCALING_OFFSET + PERSP_TABLE_SIZE:04X}")
    print(f"✓ Total : {len(out)} oct écrits dans {args.dst}")

    # --- Roundtrip test sur quelques entries ---
    print(f"\n=== Roundtrip test sur 10 entries critiques ===")
    test_indices = [0, 1, 18, 19, 20, 100, 250, 510, 511, 512]
    for idx in test_indices:
        src_off = idx * 4
        orig = struct.unpack('>I', src_data[src_off:src_off+4])[0]
        if idx < PLAGE_A_END:
            a_off = idx * 2
            packed = (out[TABLE_A_OFFSET + a_off] << 8) | out[TABLE_A_OFFSET + a_off + 1]
            reconstructed = packed << 8
            zone = "A"
        else:
            b_off = (idx - PLAGE_A_END) * 4
            reconstructed = struct.unpack(
                '>I', bytes(out[TABLE_B_OFFSET + b_off:TABLE_B_OFFSET + b_off + 4])
            )[0]
            zone = "B"
        ok = "✓" if orig == reconstructed else "✗"
        print(f"  {ok} [{idx:4d}] plage {zone} : orig=${orig:08X} "
              f"reconstructed=${reconstructed:08X}")

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
