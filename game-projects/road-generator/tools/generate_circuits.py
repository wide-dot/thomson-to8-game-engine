#!/usr/bin/env python3
"""
Génère les fichiers .asm 6809 pour les circuits Lotus.

Format source (= sortie de parse_circuits.py dans lotus-ste) :
    +00..01     NB_SEGMENTS (uint16 BE)
    +02..A3     palette + params (162 octets = 81 shorts BE)
    +A4..       NB_SEGMENTS × 12 octets de segments source

Format émis (= équivalent runtime $31140 de Lotus, doc 11) :
    nb_segments  fdb  N
    palette      fcb  ... (162 octets — conservés pour rendu futur)
    segments     fcb  ... (N+8 segments × 16 octets)
                         où chaque segment = 12 src + 4 padding (zéros)
                         et les 8 derniers segments = copie des 8 premiers
                         (pour buffer wraparound projection)

Format segment 12 octets (cf. lotus-ste/.../11_circuit_format_CONFIRMED.md) :
    +0  int8   delta_curve   (horizontal curvature delta)
    +1  int8   delta_pitch   (vertical pitch delta)
    +2..3      mot 1         (width / palette idx / type — non décodé ici)
    +4..5      sprite_id_1 + low byte (high byte = FILExx à activer)
    +6..7      sprite_id_2 + low byte
    +8..9      sprite_id_3 + low byte
    +A..B      mot 5         (flags)

Note TO8 : les valeurs sont des deltas/IDs/flags, AUCUNE n'est en pixels
horizontaux → pas de division par 2 ici.

Usage :
    python3 tools/generate_circuits.py                  # batch tous circuits
    python3 tools/generate_circuits.py --circuit 00_training
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# ── Constantes ───────────────────────────────────────────────────────────────
SEGMENT_SRC_SIZE = 12        # source (Lotus .bin)
SEGMENT_RT_SIZE = 16         # runtime (= ce qu'on émet)
WRAPAROUND_COUNT = 8         # 8 segments dupliqués à la fin pour look-ahead
PALETTE_PARAMS_SIZE = 162    # 81 shorts


def parse_circuit_bin(path: Path):
    """Renvoie (n_segments, palette_bytes, segments_bytes)."""
    data = path.read_bytes()
    if len(data) < 2 + PALETTE_PARAMS_SIZE:
        raise ValueError(f"Fichier trop petit : {len(data)} octets")
    n = struct.unpack('>H', data[0:2])[0]
    palette = data[2:2 + PALETTE_PARAMS_SIZE]
    seg_start = 2 + PALETTE_PARAMS_SIZE
    expected_size = seg_start + n * SEGMENT_SRC_SIZE
    if len(data) != expected_size:
        raise ValueError(f"Taille incohérente : {len(data)} vs attendu {expected_size} "
                         f"(N={n} segments × {SEGMENT_SRC_SIZE} oct + header)")
    segments = data[seg_start:]
    return n, palette, segments


def emit_byte_block(label: str, blob: bytes, lines: list, per_line: int = 16,
                    comment_each: int = 0):
    """Émet un bloc de bytes via `fcb`. Optionnellement commenté tous les N octets."""
    for i in range(0, len(blob), per_line):
        row = blob[i:i + per_line]
        hex_vals = ",".join(f"${b:02X}" for b in row)
        if comment_each and (i % comment_each == 0):
            lines.append(f"        fcb   {hex_vals}    ; +${i:03X}")
        else:
            lines.append(f"        fcb   {hex_vals}")


def emit_commented_byte_block(blob: bytes, lines: list, per_line: int = 16):
    """Émet un bloc de bytes en COMMENTAIRES (data préservée pour consultation,
    pas chargée au runtime)."""
    for i in range(0, len(blob), per_line):
        row = blob[i:i + per_line]
        hex_vals = ",".join(f"${b:02X}" for b in row)
        # Préfixe `;` → ligne ignorée par l'assembleur
        lines.append(f";       fcb   {hex_vals}    ; +${i:03X}")


def emit_segment(seg_idx: int, src12: bytes, lines: list):
    """Émet 1 segment runtime (16 octets = 12 source + 4 padding)."""
    # Annotation lisible
    delta_curve = struct.unpack('b', bytes([src12[0]]))[0]    # signed int8
    delta_pitch = struct.unpack('b', bytes([src12[1]]))[0]
    sprite1 = src12[4]
    sprite2 = src12[6]
    sprite3 = src12[8]
    lines.append(f"* seg {seg_idx:3d}  curve={delta_curve:+4d}  pitch={delta_pitch:+4d}  "
                 f"sprites=${sprite1:02X},${sprite2:02X},${sprite3:02X}")
    # 12 octets source + 4 octets padding (= 0, sera rempli au runtime par
    # l'équivalent de FUN_00074eac qui calcule les bornes courbure look-ahead)
    hex_vals = ",".join(f"${b:02X}" for b in src12)
    lines.append(f"        fcb   {hex_vals},$00,$00,$00,$00")


def generate_circuit_asm(bin_path: Path, out_path: Path, name: str):
    n, palette, segments = parse_circuit_bin(bin_path)

    lines = [
        "        opt   c",
        "* " + "=" * 70,
        f"* Circuit_{name}.asm — généré par tools/generate_circuits.py",
        f"* Source : lotus-ste/doc/extraction/circuits/{bin_path.name}",
        "* ",
        f"* NB_SEGMENTS    = {n}",
        f"* SEGMENTS (RT)  = ({n}+{WRAPAROUND_COUNT}) × {SEGMENT_RT_SIZE} octets ="
        f" {(n + WRAPAROUND_COUNT) * SEGMENT_RT_SIZE} octets",
        f"* TAILLE TOTALE  ≈ {6 + (n + WRAPAROUND_COUNT) * SEGMENT_RT_SIZE} octets"
        f" (jump table 6 + segments)",
        "* ",
        "* NOTE : la palette ST (162 oct) est PRÉSERVÉE EN COMMENTAIRE plus bas",
        "* pour consultation, mais PAS chargée au runtime (palette TO8 différente).",
        "* ",
        "* ── JUMP TABLE (= en-tête de circuit, layout fixe pour tous) ──",
        "*   +0 : fdb  → adresse du mot nb_segments (uint16 BE)",
        "*   +2 : fdb  → adresse du premier segment (= base + 6)",
        "*",
        "* Permet à un loader générique d'accéder à n'importe quel circuit :",
        "*   ldx   #Circuit_xxxx        ; X = jump table base",
        "*   ldd   [0,x]                ; D = nb_segments  (indirect via ptr +0)",
        "*   ldd   2,x                  ; D = ptr segments (direct)",
        "* ",
        "* Format segment 16 oct (= équivalent table $31140 runtime Lotus) :",
        "*   +0  int8  delta_curve",
        "*   +1  int8  delta_pitch",
        "*   +2..3    mot 1 (width / palette idx / type)",
        "*   +4..5    sprite_id_1 + flags",
        "*   +6..7    sprite_id_2 + flags",
        "*   +8..9    sprite_id_3 + flags",
        "*   +A..B    mot 5 (flags)",
        "*   +C..F    padding (rempli runtime par calcul bornes courbure)",
        "* ",
        "* Les 8 derniers segments sont une COPIE des 8 premiers (wraparound",
        "* pour look-ahead de la projection).",
        "* " + "=" * 70,
        "",
        f"Circuit_{name}",
        f"        fdb   Circuit_{name}_nb_segments    ; +0 : ptr nb_segments",
        f"        fdb   Circuit_{name}_segments       ; +2 : ptr segments",
        "",
        f"Circuit_{name}_nb_segments",
        f"        fdb   ${n:04X}            ; = {n} segments",
        "",
        "* ── PALETTE ST (162 oct, COMMENTÉE — pas chargée au runtime) ──",
        f";Circuit_{name}_palette",
    ]
    emit_commented_byte_block(palette, lines, per_line=16)

    lines.append("")
    lines.append(f"Circuit_{name}_segments")
    for i in range(n):
        src12 = segments[i * SEGMENT_SRC_SIZE : (i + 1) * SEGMENT_SRC_SIZE]
        emit_segment(i, src12, lines)

    # Wraparound : 8 premiers dupliqués
    lines.append("")
    lines.append("* " + "─" * 60)
    lines.append(f"* Wraparound : copie des 8 premiers segments (look-ahead projection)")
    lines.append("* " + "─" * 60)
    for k in range(WRAPAROUND_COUNT):
        src12 = segments[k * SEGMENT_SRC_SIZE : (k + 1) * SEGMENT_SRC_SIZE]
        emit_segment(n + k, src12, lines)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines) + "\n")
    return n


def main(argv):
    script_dir = Path(__file__).resolve().parent
    p = argparse.ArgumentParser(description="Génère les .asm 6809 des circuits Lotus")
    default_src = (script_dir.parent / 'lotus-ste' / 'doc' / 'extraction'
                   / 'circuits')
    default_out = (script_dir.parent / 'engine' / 'circuits')
    p.add_argument('--src', type=Path, default=default_src,
                   help=f"Dossier des .bin (défaut : {default_src})")
    p.add_argument('-o', '--output', type=Path, default=default_out,
                   help=f"Dossier sortie (défaut : {default_out})")
    p.add_argument('--circuit', type=str, default=None,
                   help="Nom d'un circuit spécifique (sans .bin), défaut : tous")
    args = p.parse_args(argv[1:])

    if not args.src.is_dir():
        print(f"❌ Source introuvable : {args.src}", file=sys.stderr)
        return 1

    print(f"📂 Source : {args.src}")
    print(f"📂 Destination : {args.output}")

    if args.circuit:
        bins = [args.src / f"{args.circuit}.bin"]
        if not bins[0].exists():
            print(f"❌ Circuit introuvable : {bins[0]}", file=sys.stderr)
            return 1
    else:
        bins = sorted(args.src.glob("*.bin"))

    total_ok = 0
    total_err = 0
    for bin_path in bins:
        name = bin_path.stem
        out_path = args.output / f"{name}.asm"
        try:
            n = generate_circuit_asm(bin_path, out_path, name)
            size_total = 2 + PALETTE_PARAMS_SIZE + (n + WRAPAROUND_COUNT) * SEGMENT_RT_SIZE
            print(f"  ✓ {name:<20}  N={n:3d}  total={size_total} oct")
            total_ok += 1
        except Exception as e:
            print(f"  ✗ {name}: {e}", file=sys.stderr)
            total_err += 1

    print(f"\n✓ {total_ok} circuits générés, {total_err} erreurs")
    return 0 if total_err == 0 else 2


if __name__ == '__main__':
    sys.exit(main(sys.argv))
