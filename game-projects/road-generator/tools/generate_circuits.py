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


PALETTE_NB_ENTRIES = 28    # 28 mots = 56 oct (mots 0..27 du header)
META_FIELDS = [             # (label, offset dans header 162-oct, taille)
    ('Pays',        56,  10),
    ('Lieu',        66,  32),
    ('Description', 98,  32),
    ('Hazards',    130,  32),
]


def decode_palette_word(word: int):
    """Décode 1 mot palette ST → (R, G, B) ∈ [0..7]^3.

    Stockage : STe 12-bit (4 bits par canal, LSB en bit 3 = "extension" STe).
    Le shifter ST masque cet LSB et shift droit par 1 → couleur effective
    `(raw & $EEE) >> 1`. Source : FUN_74584.
    """
    eff = (word & 0xEEE) >> 1
    return (eff >> 8) & 0x7, (eff >> 4) & 0x7, eff & 0x7


def rgb_3bit_to_8bit(v: int) -> int:
    """Normalise une valeur 3-bit (0..7) en 8-bit (0..252). v*36 ; cf.
    extract_palettes.py (= linéaire, garde la même rampe que l'extracteur PNG)."""
    return v * 36


def palette_to_hex_list(blob: bytes) -> list:
    """Renvoie la liste des 28 couleurs au format '#RRGGBB' (8-bit normalisé)."""
    out = []
    for i in range(PALETTE_NB_ENTRIES):
        word = (blob[i*2] << 8) | blob[i*2+1]
        r, g, b = decode_palette_word(word)
        out.append(f"#{rgb_3bit_to_8bit(r):02X}{rgb_3bit_to_8bit(g):02X}"
                   f"{rgb_3bit_to_8bit(b):02X}")
    return out


def extract_metadata(blob: bytes) -> dict:
    """Décode les 4 champs texte fixed-width du header.

    Le séparateur `/` sert de padding et de séparateur intra-champ — on le
    convertit en espace pour l'affichage. Voir circuits_catalog.md.
    """
    out = {}
    for label, off, size in META_FIELDS:
        raw = blob[off:off+size].decode('latin-1')
        out[label] = raw.rstrip('/').replace('/', ' ')
    return out


def emit_segment(seg_idx: int, src12: bytes, lines: list):
    """Émet 1 segment runtime (16 oct = 12 source + 4 padding) en 1 ligne.

    Format segment (12 oct source) :
      +0  int8  delta_curve
      +1  int8  delta_pitch
      +2  uint8 sprite_id_0     +3  int8 lat_pos_0   (mot 1)
      +4  uint8 sprite_id_1     +5  int8 lat_pos_1   (mot 2)
      +6  uint8 sprite_id_2     +7  int8 lat_pos_2   (mot 3)
      +8  uint8 sprite_id_3     +9  int8 lat_pos_3   (mot 4)
      +A..B    flags (mot 5)

    Vérifié par parsing 68000 FUN_40B4 : 4 appels FUN_4190 (add_file) =
    4 sprites par segment, chaque mot = (sprite_id, lateral_pos signed).
    lat_pos < 0 = gauche (ex. $EE = -18), > 0 = droite (ex. $12 = +18).

    Annotation inline conditionnelle : affiche seulement les champs non-triviaux,
    avec colonnes fixed-width pour alignement vertical.
    """
    delta_curve = struct.unpack('b', bytes([src12[0]]))[0]
    delta_pitch = struct.unpack('b', bytes([src12[1]]))[0]
    # 4 sprites : (id, lat_pos signed) aux offsets [2..9]
    sprites = []
    for k in range(4):
        sid = src12[2 + k*2]
        lat = struct.unpack('b', bytes([src12[2 + k*2 + 1]]))[0]
        if sid != 0:
            sprites.append(f"#{k}:${sid:02X}@{lat:+d}")
    flags = (src12[10] << 8) | src12[11]
    # Décodage sémantique des bits du mot 5 :
    #   bit 0 ($0001) = pit lane (= route alternative stands)
    #   bit 1 ($0002) = start line (set par parser sur 1er segment)
    flag_names = []
    if flags & 0x0001: flag_names.append("PIT")
    if flags & 0x0002: flag_names.append("START")
    flag_other = flags & ~0x0003   # bits non documentés
    if flag_other:     flag_names.append(f"?${flag_other:04X}")

    col_curve  = f"curve={delta_curve:+d}" if delta_curve != 0 else ""
    col_pitch  = f"pitch={delta_pitch:+d}" if delta_pitch != 0 else ""
    col_flags  = f"flags=[{'|'.join(flag_names)}]" if flag_names else ""
    col_sprites = " ".join(sprites)

    has_any = col_curve or col_pitch or col_flags or col_sprites
    if has_any:
        # curve=+NNN (10), pitch=+NNN (10), flags=$XXXX (12), sprites...
        line_suffix = (f"  {col_curve:<10}{col_pitch:<10}{col_flags:<12}"
                       f"{col_sprites}").rstrip()
    else:
        line_suffix = ""

    hex_vals = ",".join(f"${b:02X}" for b in src12)
    lines.append(f"        fcb   {hex_vals},$00,$00,$00,$00  ; seg {seg_idx:3d}{line_suffix}")


def emit_palette_header(palette_blob: bytes, lines: list, per_line: int = 8):
    """Émet la palette en commentaires (`*`), N entrées par ligne, format
    `idx:#RRGGBB`. Pas de fdb — ces données ne sont PAS chargées au runtime
    (palette TO8 différente de ST), c'est purement documentaire."""
    colors = palette_to_hex_list(palette_blob)
    for i in range(0, len(colors), per_line):
        chunk = colors[i:i+per_line]
        entries = " ".join(f"{i+k:02d}:{c}" for k, c in enumerate(chunk))
        lines.append(f"*   {entries}")


def generate_circuit_asm(bin_path: Path, out_path: Path, name: str):
    n, palette_block, segments = parse_circuit_bin(bin_path)
    total_seg_size = (n + WRAPAROUND_COUNT) * SEGMENT_RT_SIZE
    meta = extract_metadata(palette_block)

    lines = [
        "* " + "=" * 70,
        f"* Circuit_{name} — N={n} segments",
        f"* Source       : {bin_path.name} (extrait de FILE30)",
        "*",
        f"* Pays         : {meta['Pays']}",
        f"* Lieu         : {meta['Lieu']}",
        f"* Description  : {meta['Description']}",
        f"* Hazards      : {meta['Hazards']}",
        "*",
        "* Palette ST (28 entrées, RGB 8-bit normalisé — runtime-effectif après",
        "* shift `(raw & $EEE) >> 1` du shifter ; cf. extract_palettes.py) :",
    ]
    emit_palette_header(palette_block, lines, per_line=8)
    lines += [
        "* Palette base : mots [00..15]",
        "* Sky gradient : mots [16..27]",
        "*",
        "* Format segment 16 oct (= table $31140 runtime Lotus) :",
        "*   +0   int8  delta_curve",
        "*   +1   int8  delta_pitch",
        "*   +2   uint8 sprite_id_0    +3  int8  lat_pos_0   (mot 1)",
        "*   +4   uint8 sprite_id_1    +5  int8  lat_pos_1   (mot 2)",
        "*   +6   uint8 sprite_id_2    +7  int8  lat_pos_2   (mot 3)",
        "*   +8   uint8 sprite_id_3    +9  int8  lat_pos_3   (mot 4)",
        "*   +A..B    flags (mot 5) :",
        "*              bit 0 ($0001) = PIT lane (= route alternative stands)",
        "*                              PRÉSENT DANS LE SOURCE, sur les segments concernés",
        "*              bit 1 ($0002) = START line",
        "*                              JAMAIS dans le source — setté par FUN_40B4 au race-init",
        "*                              uniquement sur le segment 0 (via ori.b #$2, ($B, A0))",
        "*   +C..F    padding (rempli runtime par look-ahead courbure)",
        "*",
        "* sprite_id ∈ [$80..$AB] sélectionne le fichier sprite FILExx.SCR à",
        "* charger (FUN_4190 = add_file). lat_pos est signed : < 0 = gauche route,",
        "* > 0 = droite. Les 4 sprites peuvent être placés à des positions",
        "* indépendantes le long du segment et de chaque côté de la route.",
        "*",
        f"* {WRAPAROUND_COUNT} segments wraparound dupliqués à la fin pour look-ahead",
        "* projection sans wrap mod N.",
        f"* Taille totale : {2 + total_seg_size} oct"
        f" (nb_segments 2 + segments {total_seg_size}).",
        "* " + "=" * 70,
        "",
        f"Circuit_{name}_nb_segments",
        f"        fdb   {n}",
        "",
        f"Circuit_{name}_segments",
    ]

    for i in range(n):
        src12 = segments[i * SEGMENT_SRC_SIZE : (i + 1) * SEGMENT_SRC_SIZE]
        emit_segment(i, src12, lines)

    lines.append("* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──")
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
