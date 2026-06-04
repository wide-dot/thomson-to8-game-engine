#!/usr/bin/env python3
"""
oracle_road_position.py — ORACLE de positionnement horizontal de la route.

But : combler l'angle mort qui a fait échouer les sessions précédentes.
`simulate_dfr_pipeline.py` s'arrête au curve-compute (chunk_shift / sub_pix)
et ne modélise NI le clamp d'entry NI l'application byte_offset/U du dispatch.
Le bug vit précisément là.

Cet oracle calcule, par scanline et sur données projetées RÉELLES (SP+LI
byte-perfect importés du simulateur), DEUX choses côte à côte :

  1. PORT 6809 (= ce que DFR_dispatch_and_draw fait RÉELLEMENT) :
     - neg_product (= décalage latéral voulu, en px TO8)
     - décomposition chunk_shift (>>4 signé) + sub_pix (&15)
     - entry_raw = (K+M+J) - 17 + chunk_shift   [K,M,J lus du .bin réel]
     - entry_clamped = max(0, entry_raw)         [le clamp bpl/clra]
     - byte_offset = sub_pix >> 2                 [appliqué à U, AVANT le clamp]
     → met en évidence la DÉSYNC : quand entry clampe, le chunk est perdu
       mais byte_offset continue de décaler U.

  2. RÉFÉRENCE 68k (FUN_0007661e, lue du binaire CARS.REL) :
     - centerX = CENTER - product                 [TO8 : CENTER=80, product déjà /2]
     - leftEdge = centerX - demi-largeur
     - leftEdge_chunks = asr #4 (SIGNÉ, peut valoir -1, JAMAIS clampé à 0)
     - sub_pix_68k = leftEdge & 15
     → chunk ET sub sortent de la MÊME valeur leftEdge = jamais désynchronisés.

Usage :
    python3 tools/oracle_road_position.py <CIRCUIT_ID> <SEG> <NIBBLE> [<LATERAL>]
    ex : python3 tools/oracle_road_position.py 22_hard_5 130 8 0

Le but n'est PAS de trancher le signe écran par raisonnement (les commentaires
source se contredisent à cause du sens de tracé pshu) mais de SORTIR LES CHIFFRES
pour qu'on décide sur faits.
"""

import sys
import re
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from simulate_dfr_pipeline import (
    parse_circuit, load_perspective_tables, sparse_projection,
    linear_interp, load_persp_recip_paged, dfr_compute_curve,
    signed16, signed_shr,
)


def find_project_root():
    here = Path(__file__).resolve().parent.parent
    if (here / 'engine').exists():
        return here
    # fallback macOS
    p = Path('/Users/benoitrousseau/Documents/Claude/Projects/thomson-to8-game-engine/game-projects/road-generator')
    return p


def load_line_offsets(externs_path):
    """road_buffers_externs.inc : 'Line_0000 equ $0000' → {idx_label: offset}."""
    offs = {}
    pat = re.compile(r'^(Line_\d+)\s+equ\s+\$([0-9A-Fa-f]+)')
    with open(externs_path) as f:
        for ln in f:
            m = pat.match(ln.strip())
            if m:
                offs[m.group(1)] = int(m.group(2), 16)
    return offs


def load_lines_table(table_path):
    """road_lines_table.asm : 'fdb Line_a,Line_b,Line_c,Line_d ; ligne NNN'
    → list indexée par line_idx de [s0_rama, s1_rama, s0_ramb, s1_ramb]."""
    table = []
    pat = re.compile(r'fdb\s+(Line_\d+)\s*,\s*(Line_\d+)\s*,\s*(Line_\d+)\s*,\s*(Line_\d+)')
    with open(table_path) as f:
        for ln in f:
            m = pat.search(ln)
            if m:
                table.append([m.group(1), m.group(2), m.group(3), m.group(4)])
    return table


def read_kmj(bin_bytes, offset):
    """Header buffer = 3 octets K, M, J à l'offset donné dans road_buffers.bin."""
    return bin_bytes[offset], bin_bytes[offset + 1], bin_bytes[offset + 2]


def port_dispatch(K, M, J, chunk_shift, sub_pix):
    """Émule DFR_dispatch_and_draw (entry + clamp + K'/J') + byte_offset.

    Reproduit EXACTEMENT l'ASM lignes 546-612 de DrawFrameRoad.asm.
    """
    N = K + M + J
    entry_raw = signed16(N - 17 + chunk_shift)          # suba #17 ; adda chunk_shift
    clamped = entry_raw < 0
    entry = 0 if clamped else entry_raw                  # bpl / clra

    # K' = clamp(K - entry, 0, 10)
    kp = K - entry
    kp = 0 if kp < 0 else (10 if kp > 10 else kp)
    # J' = clamp(entry + 10 - K - M, 0, 10)
    jp = entry + 10 - K - M
    jp = 0 if jp < 0 else (10 if jp > 10 else jp)
    core_off = max(0, entry - K)

    byte_offset = (sub_pix >> 2)        # appliqué à U dans la main loop (AVANT dispatch)
    return {
        'N': N, 'entry_raw': entry_raw, 'entry': entry, 'clamped': clamped,
        'Kp': kp, 'Jp': jp, 'core_off': core_off, 'byte_offset': byte_offset,
    }


def ref_68k(slot_x_clean, width, lateral_scaled, center=80):
    """Référence FUN_0007661e adaptée TO8 (160px, demi-résolution).

    68k : centerX = $90 - ((D3_mod * width*2)>>16) ; le port a déjà retiré le *2
    (demi-résolution). On garde la MÊME décomposition atomique signée.
    leftEdge = centerX - demi-largeur ; demi-largeur_TO8 = (width>>4) (= D0).
    """
    combined = signed16(slot_x_clean + lateral_scaled)
    product = signed16((combined * width) >> 16)         # déjà /2 (pas de *2)
    centerX = signed16(center - product)
    half = width >> 4                                    # 68k D0 = width/16
    # TO8 : la demi-résolution → demi-largeur écran = half/2 ; on teste les deux
    half_to8 = half >> 1
    leftEdge = signed16(centerX - half_to8)
    left_chunks = signed_shr(leftEdge, 4)                # asr #4 SIGNÉ (peut être -1)
    sub_pix = leftEdge & 0x0F
    return {
        'product': product, 'centerX': centerX, 'half_to8': half_to8,
        'leftEdge': leftEdge, 'left_chunks': left_chunks, 'sub_pix': sub_pix,
    }


def main():
    if len(sys.argv) < 4:
        print("Usage: oracle_road_position.py <CIRCUIT_ID> <SEG> <NIBBLE> [<LATERAL>]")
        sys.exit(1)
    circuit_id = sys.argv[1]
    seg = int(sys.argv[2])
    nibble = int(sys.argv[3])
    lateral = int(sys.argv[4]) if len(sys.argv) > 4 else 0

    root = find_project_root()
    circuit_asm = root / 'engine' / 'circuits' / f'{circuit_id}.asm'
    file59 = root / 'lotus-ste' / 'doc' / 'extraction' / 'unpacked' / 'FILE59.bin'
    paged = root / 'engine' / 'projection' / 'Persp_Recip_paged.bin'
    externs = root / 'game-mode' / 'road' / 'generated' / 'road_buffers_externs.inc'
    table = root / 'game-mode' / 'road' / 'generated' / 'road_lines_table.asm'
    buffers_bin = root / 'objects' / 'road-buffers' / 'generated' / 'road_buffers.bin'

    for p in (circuit_asm, file59, paged, externs, table, buffers_bin):
        if not p.exists():
            print(f"ERREUR: introuvable {p}")
            sys.exit(1)

    segments = parse_circuit(circuit_asm, circuit_id)
    horizon, scaling = load_perspective_tables(file59)
    file59_paged = load_persp_recip_paged(paged)
    line_offsets = load_line_offsets(externs)
    lines_table = load_lines_table(table)
    bin_bytes = buffers_bin.read_bytes()

    # lateral → chunks_shift + sub_pix (comme P1M_apply_lateral)
    chunks_shift = signed_shr(lateral, 4)
    lateral_sub = lateral & 0x0F
    lateral_scaled = signed16(lateral * 8)

    slots, _ = sparse_projection(segments, seg, nibble, horizon, scaling)
    dense = linear_interp(slots, file59_paged)
    ys = sorted(dense.keys())

    print(f"=== ORACLE positionnement route : {circuit_id} seg={seg} nibble={nibble} lateral={lateral:+d} ===")
    print(f"    ({len(ys)} scanlines projetées)\n")
    print("  Y  | width| slotX | negProd | chunk| sub |  K  M  J | e_raw e_clp CLAMP | bOff || 68k:left_chk subL  clipNeg")
    print("  ---+------+-------+---------+------+-----+----------+-------------------+------++-----------------------------")

    n_chunk_nonzero = 0
    n_clamp = 0
    n_68k_negchunk = 0
    desync_px_total = 0
    for y in ys:
        t = dense[y]
        width = t['width']
        cc = dfr_compute_curve(t['flags'], width, chunks_shift, lateral_sub)
        slot_x = cc['slot_x_clean']
        negp = cc['neg_product']
        chunk = cc['chunk_shift']
        sub = cc['sub_pix_out']

        line_idx = (width >> 4)
        if line_idx > 254:
            line_idx = 254
        if line_idx < len(lines_table):
            label = lines_table[line_idx][0]        # variant s0 RAMA
            off = line_offsets.get(label)
            K, M, J = read_kmj(bin_bytes, off) if off is not None else (5, 0, 12)
        else:
            K, M, J = 5, 0, 12

        pd = port_dispatch(K, M, J, chunk, sub)
        ref = ref_68k(slot_x, width, lateral_scaled)

        if chunk != 0:
            n_chunk_nonzero += 1
        if pd['clamped']:
            n_clamp += 1
            # px de chunk perdu au clamp (alors que byte_offset s'applique quand même)
            desync_px_total += abs(pd['entry_raw']) * 16
        if ref['left_chunks'] < 0:
            n_68k_negchunk += 1

        clamp_mark = 'CLAMP' if pd['clamped'] else '  -  '
        clipneg = 'NEG!' if ref['left_chunks'] < 0 else ''
        print(f"  {y:3d}| {width:4d} | {slot_x:+5d} | {negp:+7d} | {chunk:+4d} | {sub:3d} |"
              f" {K:2d} {M:2d} {J:2d} | {pd['entry_raw']:+5d} {pd['entry']:+4d}  {clamp_mark} |"
              f" {pd['byte_offset']:3d}  || {ref['left_chunks']:+9d}  {ref['sub_pix']:3d}   {clipneg}")

    print()
    print("=== SYNTHÈSE ===")
    print(f"  scanlines |chunk_shift|>0 (= sens/désync importe)   : {n_chunk_nonzero}/{len(ys)}")
    print(f"  scanlines où le PORT clampe entry à 0 (= désync)    : {n_clamp}/{len(ys)}")
    print(f"  scanlines où le 68k aurait left_chunks < 0 (clip)   : {n_68k_negchunk}/{len(ys)}")
    print(f"  px de chunk PERDUS au clamp (byte_offset persiste)  : {desync_px_total} px cumulés")
    print()
    print("  Lecture : sur les lignes CLAMP, le PORT jette entry_raw<0 (= perd")
    print("  |entry_raw|*16 px de décalage chunk) MAIS applique quand même bOff")
    print("  (sub_pix>>2) à U. Le 68k, lui, garde left_chunks SIGNÉ (colonne NEG!)")
    print("  et décompose sub depuis la même valeur → jamais de désync.")


if __name__ == '__main__':
    main()
