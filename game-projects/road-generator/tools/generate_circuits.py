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
SEGMENT_RT_SIZE = 8          # runtime compact TO8 (8 oct/seg, vs 16 oct Lotus 68k)
WRAPAROUND_COUNT = 8         # 8 segments dupliqués à la fin pour look-ahead
PALETTE_PARAMS_SIZE = 162    # 81 shorts

# Limite sprite IDs uniques par circuit (= 4 bits d'indexation dans Sprite_LUT)
SPRITE_LUT_MAX = 16


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


def compute_segment_cache(segments: bytes, n: int) -> list:
    """Pré-calcule en Python les 4 octets de cache par segment qui sont remplis
    au runtime par FUN_74dac dans le Lotus 68k original (offsets +0xC..+0xF).

    Les 4 octets restent inutilisés par le pipeline route v1 (SparseProjection
    + LinearInterp + DrawFrameRoad). Ils seront consommés plus tard par :
      - Lotus_PhysicsTick complet + AI cars  → yaw_abs, pitch_abs
      - DRAW_SPRITES (= FUN_7A64C port futur) → min_lat, max_lat (= culling H)

    En les pré-calculant ici, on évite le port de FUN_74dac en 6809. La routine
    Python est PUREMENT statique (= fonction des deltas + lat_pos du circuit,
    pas de dépendance camera).

    === Détail des 3 loops du 68k (= équivalents reproduits ici) ===

    Loop 1 ($4AAC) — yaw/pitch cumulés (modulo 256, signed) :
      cache[i].yaw_abs   = sum(delta_curve[0..i-1]) & 0xFF
      cache[i].pitch_abs = sum(delta_pitch[0..i-1]) & 0xFF

    Loop 2 ($4AD6) — bornes latérales des sprites (lat_pos = byte +3,+5,+7,+9) :
      Pour les 4 sprites du segment (skip si sprite_id == 0 ou == $82) :
        si lat < 0 (gauche)  : track le MAX (= le moins négatif = closest to 0)
        si lat >= 0 (droite) : track le MIN (= le moins positif)
      Init : d4 = -18, d5 = +18 (= défauts si aucun sprite)
      Stockage : d4 += 8, d5 -= 8 (= "marge" arbitraire)
      → cache[i].min_lat = d4, cache[i].max_lat = d5

    Loop 3 ($4B3A) — smooth backward (= filtre passe-bas anti-pop) :
      Parcourt les segments à L'ENVERS (= de N-1 vers 0)
      d4 init = -10, d5 init = +10
      Pour chaque seg : min_lat suit cache avec "rise fast / drop slow",
                       max_lat suit cache avec "drop fast / rise slow"
      Écrit dans cache[i] les valeurs filtrées finales.

    @return list of (yaw_abs, pitch_abs, min_lat, max_lat) tuples, 1 par seg
            (valeurs uint8 prêtes à émettre en fcb)
    """
    cache = []  # list of [yaw, pitch, min_lat, max_lat] per segment

    # === Loop 1 : yaw/pitch cumulés ===
    yaw = 0
    pitch = 0
    for i in range(n):
        seg = segments[i * SEGMENT_SRC_SIZE : (i + 1) * SEGMENT_SRC_SIZE]
        dc = struct.unpack('b', bytes([seg[0]]))[0]
        dp = struct.unpack('b', bytes([seg[1]]))[0]
        # On écrit AVANT d'ajouter le delta du segment courant
        cache.append([yaw & 0xFF, pitch & 0xFF, 0, 0])
        yaw   = (yaw   + dc) & 0xFF
        pitch = (pitch + dp) & 0xFF

    # === Loop 2 : bornes latérales (= lat_pos min/max) ===
    for i in range(n):
        seg = segments[i * SEGMENT_SRC_SIZE : (i + 1) * SEGMENT_SRC_SIZE]
        d4 = -18   # init min (gauche)
        d5 =  18   # init max (droite)
        for k in range(4):
            sid = seg[2 + k*2]
            lat = struct.unpack('b', bytes([seg[2 + k*2 + 1]]))[0]
            if sid == 0 or sid == 0x82:
                continue
            if lat < 0:
                if lat > d4:
                    d4 = lat
            else:
                if lat < d5:
                    d5 = lat
        d4 += 8
        d5 -= 8
        cache[i][2] = d4 & 0xFF
        cache[i][3] = d5 & 0xFF

    # === Loop 3 : smooth backward (= anti-pop des bornes latérales) ===
    d4 = -10
    d5 =  10
    for i in range(n - 1, -1, -1):
        # min_lat (= d4) : rise fast, drop slow
        d0 = struct.unpack('b', bytes([cache[i][2]]))[0]
        if d0 == d4:
            pass
        elif d0 >= d4:
            d4 = d0    # clamp UP (= moins négatif)
        else:
            d4 = d4 - 1   # decay slow DOWN
        cache[i][2] = d4 & 0xFF

        # max_lat (= d5) : drop fast, rise slow
        d0 = struct.unpack('b', bytes([cache[i][3]]))[0]
        if d0 == d5:
            pass
        elif d0 < d5:
            d5 = d0    # clamp DOWN
        else:
            d5 = d5 + 1   # rise slow UP
        cache[i][3] = d5 & 0xFF

    return cache


def build_sprite_lut(segments: bytes, n: int) -> list:
    """Scanne tous les segments du circuit pour extraire les sprite_ids uniques.

    Renvoie une liste ordonnée des IDs (= la LUT du circuit). Index dans
    cette liste = valeur 4-bit stockée dans le segment compact.

    Index 0 RÉSERVÉ pour "pas de sprite" (= sprite_id $00) → toujours présent
    en première position pour que sprite_idx=0 signifie "vide".
    """
    seen = set()
    order = [0]  # index 0 = "no sprite"
    for i in range(n):
        seg = segments[i * SEGMENT_SRC_SIZE : (i + 1) * SEGMENT_SRC_SIZE]
        for k in range(4):
            sid = seg[2 + k*2]
            if sid != 0 and sid not in seen:
                seen.add(sid)
                order.append(sid)
    if len(order) > SPRITE_LUT_MAX:
        raise ValueError(f"Trop de sprite_ids uniques ({len(order)} > {SPRITE_LUT_MAX})")
    return order


def emit_segment(seg_idx: int, src12: bytes, sprite_lut: list, is_start_seg: bool,
                 lines: list):
    """Émet 1 segment runtime COMPACT (8 oct, vs 16 oct du format Lotus 68k).

    Format compact 8 oct :
      +0  curve_raw   bit 7 = PIT flag, bits 0-6 = delta_curve en 7-bit signed
      +1  pitch_raw   bit 7 = START flag, bits 0-6 = delta_pitch en 7-bit signed
      +2  spr01       (sprite_idx_1 << 4) | sprite_idx_0   ← indices dans Sprite_LUT
      +3  spr23       (sprite_idx_3 << 4) | sprite_idx_2
      +4  lat_0       int8 signed (sprite 0 lateral position)
      +5  lat_1
      +6  lat_2
      +7  lat_3

    Contraintes vérifiées : max |curve|, |pitch| ≤ 6 → bits 7 libres pour
    flags PIT/START. Max 11 sprite_ids uniques par circuit → tient en 4 bits
    via sprite_lut.

    START flag : émis sur segment 0 uniquement (= ce que FUN_40B4 fait au
    runtime sur Atari ST).
    """
    delta_curve = struct.unpack('b', bytes([src12[0]]))[0]
    delta_pitch = struct.unpack('b', bytes([src12[1]]))[0]
    flags = (src12[10] << 8) | src12[11]
    pit_flag = (flags & 0x0001) != 0

    # Validation range pour 7-bit signed (-64..+63)
    if not (-64 <= delta_curve <= 63):
        raise ValueError(f"seg {seg_idx} : delta_curve {delta_curve} hors range 7-bit signed")
    if not (-64 <= delta_pitch <= 63):
        raise ValueError(f"seg {seg_idx} : delta_pitch {delta_pitch} hors range 7-bit signed")

    # Encodage curve_raw : bit 7 = PIT, bits 0-6 = curve 7-bit signed
    curve_raw = (delta_curve & 0x7F) | (0x80 if pit_flag else 0x00)
    # Encodage pitch_raw : bit 7 = START, bits 0-6 = pitch 7-bit signed
    pitch_raw = (delta_pitch & 0x7F) | (0x80 if is_start_seg else 0x00)

    # 4 sprites → 4-bit indices dans sprite_lut + lat_pos
    sprite_indices = []
    sprite_lats = []
    sprites_dbg = []
    for k in range(4):
        sid = src12[2 + k*2]
        lat = struct.unpack('b', bytes([src12[2 + k*2 + 1]]))[0]
        if sid == 0:
            sprite_indices.append(0)
            sprite_lats.append(0)
        else:
            idx = sprite_lut.index(sid)
            sprite_indices.append(idx)
            sprite_lats.append(lat & 0xFF)
            sprites_dbg.append(f"#{k}:${sid:02X}@{lat:+d}")

    spr01 = (sprite_indices[1] << 4) | sprite_indices[0]
    spr23 = (sprite_indices[3] << 4) | sprite_indices[2]
    bytes8 = [curve_raw, pitch_raw, spr01, spr23,
              sprite_lats[0], sprite_lats[1], sprite_lats[2], sprite_lats[3]]

    # Annotation lisible
    flag_names = []
    if pit_flag:      flag_names.append("PIT")
    if is_start_seg:  flag_names.append("START")
    col_curve   = f"curve={delta_curve:+d}" if delta_curve != 0 else ""
    col_pitch   = f"pitch={delta_pitch:+d}" if delta_pitch != 0 else ""
    col_flags   = f"flags=[{'|'.join(flag_names)}]" if flag_names else ""
    col_sprites = " ".join(sprites_dbg)

    has_any = col_curve or col_pitch or col_flags or col_sprites
    if has_any:
        line_suffix = (f"  {col_curve:<10}{col_pitch:<10}{col_flags:<14}"
                       f"{col_sprites}").rstrip()
    else:
        line_suffix = ""

    hex_vals = ",".join(f"${b:02X}" for b in bytes8)
    lines.append(f"        fcb   {hex_vals}  ; seg {seg_idx:3d}{line_suffix}")


def emit_palette_header(palette_blob: bytes, lines: list, per_line: int = 8):
    """Émet la palette en commentaires (`*`), N entrées par ligne, format
    `idx:#RRGGBB`. Pas de fdb — ces données ne sont PAS chargées au runtime
    (palette TO8 différente de ST), c'est purement documentaire."""
    colors = palette_to_hex_list(palette_blob)
    for i in range(0, len(colors), per_line):
        chunk = colors[i:i+per_line]
        entries = " ".join(f"{i+k:02d}:{c}" for k, c in enumerate(chunk))
        lines.append(f"*   {entries}")


SEGMENT_CACHE_SIZE = 4       # 4 octets de cache par segment (= pré-calcul Loop1+2+3)


def generate_circuit_asm(bin_path: Path, out_path: Path, name: str):
    n, palette_block, segments = parse_circuit_bin(bin_path)
    sprite_lut = build_sprite_lut(segments, n)
    lut_size = SPRITE_LUT_MAX  # toujours 16 oct (padding zéro) pour adressage simple
    total_seg_size = (n + WRAPAROUND_COUNT) * SEGMENT_RT_SIZE
    total_cache_size = (n + WRAPAROUND_COUNT) * SEGMENT_CACHE_SIZE
    seg_cache = compute_segment_cache(segments, n)
    meta = extract_metadata(palette_block)

    lines = [
        "* " + "=" * 70,
        f"* Circuit_{name} — N={n} segments (format compact 8 oct/seg)",
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
        "* === Format segment compact 8 oct (vs 16 oct Lotus 68k original) ===",
        "*   +0  curve_raw   bit 7 = PIT flag, bits 0-6 = delta_curve 7-bit signed",
        "*   +1  pitch_raw   bit 7 = START flag, bits 0-6 = delta_pitch 7-bit signed",
        "*   +2  spr01       (sprite_idx_1 << 4) | sprite_idx_0  ← index 4-bit dans LUT",
        "*   +3  spr23       (sprite_idx_3 << 4) | sprite_idx_2",
        "*   +4  lat_0       int8 signed (sprite 0 lateral position)",
        "*   +5  lat_1       int8 signed",
        "*   +6  lat_2       int8 signed",
        "*   +7  lat_3       int8 signed",
        "*",
        "* PIT/START flags : extraits par SparseProjection.asm via bit 7 des",
        "* bytes curve_raw/pitch_raw. PIT présent dans le source ; START forcé",
        "* sur segment 0 uniquement (= équivalent FUN_40B4 race-init du 68k).",
        "*",
        "* Sprite_LUT : index 0 = 'pas de sprite'. Indices 1..15 = sprite_id réel",
        "* (= FILExx.SCR à charger via add_file). Indexation 4-bit (max 16 IDs",
        f"* par circuit ; ce circuit : {len(sprite_lut)} entries utilisées).",
        "*",
        "* === Table parallèle Circuit_xx_segment_cache (4 oct/seg) ===",
        "* Pré-calculée à la génération (vs Loop 1/2/3 de FUN_74dac runtime 68k).",
        "*   +0  yaw_abs    : cumul delta_curve mod 256, signed",
        "*                   → futur : Lotus_PhysicsTick + AI cars",
        "*   +1  pitch_abs  : cumul delta_pitch mod 256, signed",
        "*                   → futur : Lotus_PhysicsTick complet (suspension/pentes)",
        "*   +2  min_lat    : rightmost negative sprite lat + 8, smoothed backward",
        "*                   → futur : DRAW_SPRITES culling horizontal gauche",
        "*   +3  max_lat    : leftmost positive sprite lat - 8, smoothed backward",
        "*                   → futur : DRAW_SPRITES culling horizontal droite",
        "* Adressage cache : Circuit_xx_segment_cache + idx × 4 (= ×4 simple).",
        "*",
        f"* {WRAPAROUND_COUNT} segments wraparound dupliqués à la fin pour look-ahead",
        "* projection sans wrap mod N (segments + cache).",
        f"* Taille totale : {2 + lut_size + total_seg_size + total_cache_size} oct"
        f" (nb_segments 2 + LUT {lut_size} + segments {total_seg_size}"
        f" + cache {total_cache_size}).",
        "* " + "=" * 70,
        "",
        f"Circuit_{name}_nb_segments",
        f"        fdb   {n}",
        "",
        f"Circuit_{name}_sprite_lut",
    ]

    # Émission de la LUT sprite IDs (padding zéro jusqu'à SPRITE_LUT_MAX)
    lut_padded = list(sprite_lut) + [0] * (SPRITE_LUT_MAX - len(sprite_lut))
    hex_vals = ",".join(f"${b:02X}" for b in lut_padded)
    lines.append(f"        fcb   {hex_vals}  ; LUT sprite_id (idx 0..{SPRITE_LUT_MAX-1})")
    lines.append("")
    lines.append(f"Circuit_{name}_segments")

    for i in range(n):
        src12 = segments[i * SEGMENT_SRC_SIZE : (i + 1) * SEGMENT_SRC_SIZE]
        is_start = (i == 0)
        emit_segment(i, src12, sprite_lut, is_start, lines)

    lines.append("* ── Wraparound (8 premiers segments dupliqués pour look-ahead) ──")
    for k in range(WRAPAROUND_COUNT):
        src12 = segments[k * SEGMENT_SRC_SIZE : (k + 1) * SEGMENT_SRC_SIZE]
        # Wraparound : pas de START flag (= déjà émis sur seg 0 réel)
        emit_segment(n + k, src12, sprite_lut, False, lines)

    # ── Table parallèle cache (yaw_abs, pitch_abs, min_lat, max_lat) ──
    lines.append("")
    lines.append(f"Circuit_{name}_segment_cache")
    for i in range(n):
        y, p, mi, ma = seg_cache[i]
        sy = struct.unpack('b', bytes([y]))[0]
        sp = struct.unpack('b', bytes([p]))[0]
        smi = struct.unpack('b', bytes([mi]))[0]
        sma = struct.unpack('b', bytes([ma]))[0]
        lines.append(f"        fcb   ${y:02X},${p:02X},${mi:02X},${ma:02X}"
                     f"  ; seg {i:3d}  yaw={sy:+4d} pitch={sp:+4d}"
                     f" min_lat={smi:+4d} max_lat={sma:+4d}")
    # Wraparound : duplique le cache des 8 premiers segments
    lines.append("* ── Wraparound cache (8 premiers dupliqués) ──")
    for k in range(WRAPAROUND_COUNT):
        y, p, mi, ma = seg_cache[k]
        lines.append(f"        fcb   ${y:02X},${p:02X},${mi:02X},${ma:02X}"
                     f"  ; seg {n+k:3d} (wraparound de seg {k})")

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
            size_total = (2 + SPRITE_LUT_MAX
                          + (n + WRAPAROUND_COUNT) * SEGMENT_RT_SIZE
                          + (n + WRAPAROUND_COUNT) * SEGMENT_CACHE_SIZE)
            print(f"  ✓ {name:<20}  N={n:3d}  total={size_total} oct")
            total_ok += 1
        except Exception as e:
            print(f"  ✗ {name}: {e}", file=sys.stderr)
            total_err += 1

    print(f"\n✓ {total_ok} circuits générés, {total_err} erreurs")
    return 0 if total_err == 0 else 2


if __name__ == '__main__':
    sys.exit(main(sys.argv))
