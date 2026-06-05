#!/usr/bin/env python3
"""
Pipeline complet route en Python pour comparaison runtime trace.

Reproduit byte-perfect :
  1. SparseProjection (= 72 substeps, slot.X/Y per substep).
  2. LinearInterp (= sparse → dense triplets per scanline).
  3. DrawFrameRoad curve compute (= chunk_shift + sub_pix per scanline).

Usage : simulate_dfr_pipeline.py <CIRCUIT_ID> <SEGMENT> <NIBBLE> [<LATERAL_POS>]

Ex : simulate_dfr_pipeline.py 22_hard_5 130 8 -192
     → simule frame avec virage gauche maximal, position seg 130 nibble 8.

Output : table per-scanline avec chaque valeur intermédiaire pour comparaison
avec dcmoto_trace.txt :

  Y_screen | slot.X | width | extra | combined | product | -prod | chunk | sub | net_px
"""

import sys
import re
from pathlib import Path


# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

def signed16(v):
    v &= 0xFFFF
    return v - 0x10000 if v & 0x8000 else v


def signed8(v):
    v &= 0xFF
    return v - 0x100 if v & 0x80 else v


def signed_shr(v, n):
    """Signed shift right n bits (= floor division by 2^n)."""
    if v >= 0:
        return v >> n
    # For negative, use 2's complement arithmetic shift
    v = (v & 0xFFFF) >> n
    # Sign extend back
    sign_bits = 0xFFFF << (16 - n)  # bits that were "shifted in"
    return signed16(v | sign_bits)


# ─────────────────────────────────────────────────────────────────────────────
# Circuit + FILE59 loaders
# ─────────────────────────────────────────────────────────────────────────────

def parse_circuit(asm_path, circuit_id):
    """Parse Circuit_<id>_segments from .asm file.

    Returns list of 256 (delta_curve, delta_pitch, pit_flag, start_flag).
    """
    segments = []
    in_seg = False
    label_target = f'Circuit_{circuit_id}_segments'
    label_cache = f'Circuit_{circuit_id}_segment_cache'

    with open(asm_path) as f:
        for ln in f:
            if label_target in ln and label_cache not in ln:
                in_seg = True
                continue
            if label_cache in ln:
                in_seg = False
                continue
            if not in_seg:
                continue
            m = re.match(r'^\s+fcb\s+([^;]+);\s+seg\s+(\d+)', ln)
            if not m:
                continue
            byte_vals = []
            for tok in m.group(1).strip().split(','):
                tok = tok.strip()
                byte_vals.append(int(tok[1:], 16) if tok.startswith('$') else int(tok))
            if len(byte_vals) != 8:
                continue
            curve_raw = byte_vals[0]
            pitch_raw = byte_vals[1]

            pit = (curve_raw & 0x80) != 0
            start = (pitch_raw & 0x80) != 0

            cv = curve_raw & 0x7F
            if cv & 0x40:
                cv -= 128
            pt = pitch_raw & 0x7F
            if pt & 0x40:
                pt -= 128

            segments.append((cv, pt, pit, start))
    return segments


def load_perspective_tables(file59_path):
    """Read Persp_Horizon ($1000, 128 mots) + Persp_Scaling ($1100, 128 mots)."""
    data = file59_path.read_bytes()
    horizon, scaling = [], []
    for i in range(128):
        h = int.from_bytes(data[0x1000 + i*2 : 0x1000 + i*2 + 2], 'big', signed=True)
        s = int.from_bytes(data[0x1100 + i*2 : 0x1100 + i*2 + 2], 'big', signed=True)
        horizon.append(h)
        scaling.append(s)
    return horizon, scaling


# A4_table copié byte-pour-byte depuis PerspectiveTables.asm (= 64 oct).
# Indexé par N_lines : a4 = A4_TABLE[N & 0xFF] si index < 64, sinon 0 (= path
# delta_zero/delta_one, jamais utilisé en multi-line).
A4_TABLE = [
    0x00, 0x00, 0x80, 0x55, 0x40, 0x33, 0x2A, 0x24,  # N= 0.. 7
    0x20, 0x1C, 0x19, 0x17, 0x15, 0x13, 0x12, 0x11,  # N= 8..15
    0x10, 0x0F, 0x0E, 0x0D, 0x0C, 0x0C, 0x0B, 0x0B,  # N=16..23
    0x0A, 0x0A, 0x09, 0x09, 0x09, 0x08, 0x08, 0x08,  # N=24..31
    0x08, 0x07, 0x07, 0x07, 0x07, 0x06, 0x06, 0x06,  # N=32..39
    0x06, 0x06, 0x06, 0x05, 0x05, 0x05, 0x05, 0x05,  # N=40..47
    0x05, 0x05, 0x05, 0x05, 0x04, 0x04, 0x04, 0x04,  # N=48..55
    0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,  # N=56..63
]


def load_persp_recip_paged(paged_path):
    """Load Persp_Recip_paged.bin (= 4 Ko, mappée à $5000 en runtime).

    Layout :
      offset 0x000..0x3FF : Plage A (entries 0..511, packed 2 oct/entry)
      offset 0x400..0xBFF : Plage B (entries 512..1023, full 4 oct/entry)

    Returns raw bytes (caller dispatch sur idx < 512 / ≥ 512).
    """
    return paged_path.read_bytes()


def li_lookup_step(file59_paged, idx):
    """Reproduit byte-perfect le lookup FILE59 dans LinearInterp.asm.

    idx = ((D4 - D0_int) & $FFF0 + N_lines) & 0xFFFF (= unsigned 16-bit).
    Dispatch : idx < 512 → Plage A (packed 2 oct), sinon Plage B (full 4 oct).

    Returns (D3_int, D3_frac) = step value reconstructed comme signed 16-bit
    high word + unsigned 16-bit low word (= 32-bit fixed-point step).
    """
    if idx < 512:
        # Plage A : packed 2 oct → reconstruct $00:B1:B2:$00
        # ASM : ldd [A_BASE + idx*2] → A=B1, B=B2 ; std LI_d3_int+1
        # Bytes [+0, +3] de D3 restent $00. D3_int = $00:B1 = unsigned B1.
        # D3_frac = $B2:$00 = B2 << 8.
        off = idx * 2
        B1 = file59_paged[off]
        B2 = file59_paged[off + 1]
        D3_int = B1                # signed high byte 0, low byte = B1 (= positif 0..255)
        D3_frac = B2 << 8           # high byte = B2, low byte = $00
    else:
        # Plage B : full 4 oct directement à offset 1024 + (idx-512)*4
        base = 1024
        off = base + (idx - 512) * 4
        b0 = file59_paged[off]
        b1 = file59_paged[off + 1]
        b2 = file59_paged[off + 2]
        b3 = file59_paged[off + 3]
        D3_int = (b0 << 8) | b1
        # Signed sur 16 bits (= peut être négatif si b0 >= $80)
        if D3_int & 0x8000:
            D3_int -= 0x10000
        D3_frac = (b2 << 8) | b3
    return D3_int, D3_frac


# ─────────────────────────────────────────────────────────────────────────────
# SparseProjection (= 72 substeps)
# ─────────────────────────────────────────────────────────────────────────────

def sparse_projection(segments, seg_start, nibble, horizon, scaling):
    """Reproduit FUN_78a98 / SparseProjection.asm.

    Returns list of dicts (substep_idx, slot_X, slot_Y, scaling_used, D0..D3, flag).
    """
    NB_SEG = 256
    D0 = D1 = D2 = D3 = 0
    slots = []
    horizon_idx = 0
    min_y = 0x60

    def load_seg(off):
        cv, pt, pit, start = segments[(seg_start + off) % NB_SEG]
        D4 = cv
        D5 = pt * 2  # delta_pitch × 2
        flag = (1 if pit else 0) | (2 if start else 0)
        return D4, D5, flag

    def mul16x16_knuth_signed(u, v):
        """Reproduit ASM Knuth Alg M tronquée (= SP_mul_full après fix #150).

        Calcule (u_signed × v_unsigned) >> 16 avec u_lo×v_lo dropped + sign
        correction. Match byte-perfect le nouveau SP_mul_full (vs ancien
        2× Mul9x16 qui perdait 1 LSB de précision sur le lo contrib).
        """
        u_u = u & 0xFFFF
        v_u = v & 0xFFFF
        u_hi, u_lo = (u_u >> 8) & 0xFF, u_u & 0xFF
        v_hi, v_lo = (v_u >> 8) & 0xFF, v_u & 0xFF
        t1 = u_hi * v_hi
        mid = u_hi * v_lo + u_lo * v_hi
        hi_unsigned = t1 + (mid >> 8)
        if u < 0:
            hi_unsigned -= v
        return signed16(hi_unsigned & 0xFFFF)

    def substep(D0, D1, D2, D3, D4, D5, flag, hi, strip_start, is_first):
        D0 = signed16(D0 + D4)
        D1 = signed16(D1 - D5)
        D2 = signed16(D2 + D0)
        D3 = signed16(D3 + D1)

        # slot.X = D2 with bits 0-1 stripped, OR flag
        slot_X = (D2 & 0xFFFC) | flag
        if not is_first:
            slot_X &= 0xFFFD  # strip bit 1 (START) on non-first

        slot_X = signed16(slot_X)

        # slot.Y = (D3 × scaling[hi]) >> 16 + horizon[hi]
        # ASM utilise SP_mul_d3_by_scaling avec fast paths signed_8 + Knuth M16
        # fallback. Pour D3 in [-128, 127] les fast paths sont exacts (lo contrib
        # = 0). Pour D3 hors range, Knuth M16 reproduit ASM byte-perfect.
        if -128 <= D3 <= 127:
            # Fast path : (D3_lo × sHi) >> 8, lo contrib = 0
            sHi = (scaling[hi] >> 8) & 0xFF
            if D3 >= 0:
                Y_high = (D3 * sHi) >> 8
            else:
                # ASM négate D3_lo, mul, négate result
                abs_d3 = (-D3) & 0xFF
                Y_high = -((abs_d3 * sHi) >> 8)
            Y_high = signed16(Y_high)
        else:
            Y_high = mul16x16_knuth_signed(D3, scaling[hi])
        slot_Y = signed16(Y_high + horizon[hi])

        return D0, D1, D2, D3, slot_X, slot_Y

    def add_slot(idx, X, Y, sc):
        slots.append({
            'substep': idx,
            'slot_X': X,
            'slot_Y': Y,
            'scaling': sc,
            'D0': D0, 'D1': D1, 'D2': D2, 'D3': D3,
        })

    def post(X, Y):
        """add_slot + advance horizon_idx + test horizon. Retourne True si exit.
        SYNC ASM (fix bge->bhs) : le test est NON-SIGNÉ (cmpd #$60 ; bhs). Un Y
        négatif (route qui crête au-dessus du haut d'écran) devient grand unsigned
        (>=$60) → EXIT. Et min_y n'est mis à jour QUE si pas d'exit (= ordre ASM :
        bhs AVANT le cmpd min_y), sinon le slot crête négatif polluait min_y."""
        nonlocal horizon_idx, min_y
        add_slot(horizon_idx, X, Y, scaling[horizon_idx])
        horizon_idx += 1
        if (Y & 0xFFFF) >= 0x60:        # UNSIGNED
            return True
        if min_y > Y:
            min_y = Y
        return False

    # Loop 1 : (15 - nibble) substeps in seg 0
    D4, D5, flag = load_seg(0)
    for i in range(15 - nibble):
        D0, D1, D2, D3, X, Y = substep(D0, D1, D2, D3, D4, D5, flag, horizon_idx, True, False)
        if post(X, Y):
            apply_horizon_stamp(slots); return slots, min_y

    # Loop 2 : 7 segments × (1 first + 15 normal) = 16 substeps/segment
    # SYNC ASM (fix sawtooth) : l'ASM fait 16 substeps/segment (loop2 inner = 15).
    # Total = (15-nibble) + 7×16 + (1+nibble) = 128 substeps.
    for outer in range(7):
        D4, D5, flag = load_seg(outer + 1)
        D0, D1, D2, D3, X, Y = substep(D0, D1, D2, D3, D4, D5, flag, horizon_idx, False, True)
        if post(X, Y):
            apply_horizon_stamp(slots); return slots, min_y
        for inner in range(15):
            D0, D1, D2, D3, X, Y = substep(D0, D1, D2, D3, D4, D5, flag, horizon_idx, True, False)
            if post(X, Y):
                apply_horizon_stamp(slots); return slots, min_y

    # Loop 3 : 9th segment, first + (nibble) substeps
    D4, D5, flag = load_seg(8)
    D0, D1, D2, D3, X, Y = substep(D0, D1, D2, D3, D4, D5, flag, horizon_idx, False, True)
    if post(X, Y):
        apply_horizon_stamp(slots); return slots, min_y
    for i in range(nibble):
        D0, D1, D2, D3, X, Y = substep(D0, D1, D2, D3, D4, D5, flag, horizon_idx, True, False)
        if post(X, Y):
            apply_horizon_stamp(slots); return slots, min_y

    apply_horizon_stamp(slots)
    return slots, min_y


def apply_horizon_stamp(slots):
    """Reproduit SP_write_horizon_stamp (= LAB_$8b08 du 68k FUN_78a98).

    À la fin de SP, le FIRST slot (= sparse[0]) est REMPLACÉ par une "ancre"
    horizon-style pour servir d'extrémité bottom-of-viewport à LinearInterp :

        slot[0].X     = old_X.low & 1  (= préserve juste bit 0 = flag PIT)
        slot[0].Y     = $60 = 96  (= bottom of viewport)
        slot[0].Y_min = $60 = 96
        slot[0].D0a   = 0

    Sans ce stamp, sim slot[0].Y = 95 (= horizon[0]+0) et LinearInterp fait
    delta = sparse[1].Y - 95 → N_lines + 1 trop petit → step interpolation
    plus large → widths sim DIFFÈRENT runtime de +6 par ligne à la zone close.
    """
    if not slots:
        return
    s0 = slots[0]
    s0['slot_X'] = s0['slot_X'] & 1  # preserve only bit 0 (= PIT flag)
    s0['slot_Y'] = 0x60               # = 96
    # Y_min/D0a ne sont pas dans le dict slot mais utilisés en runtime via
    # decode_sparse_slots côté tool. Ici on track juste slot_X/slot_Y/scaling/D0..D3.


# ─────────────────────────────────────────────────────────────────────────────
# LinearInterp (= sparse → dense triplets)
# ─────────────────────────────────────────────────────────────────────────────

def linear_interp(slots, file59_paged):
    """Reproduit BYTE-PERFECT LinearInterp.asm : sparse → dense triplets.

    Logique reproduite (cf. engine/projection/LinearInterp.asm) :

      Prologue:
        D1 = sparse[N-1].Y
        D0_int = scaling[N-1], D0_frac = 0
        D7 = (N-2) × 256
        Y_dense = D1  (= premier write au Y_screen du dernier slot)

      Outer iter (N-1 fois, backward de sparse[N-2] vers sparse[0]) :
        D5 = sparse[i].Y, D2 = sparse[i].X, D4 = scaling[i]
        delta = D1 - D5
        if delta == 0 : LI_delta_zero  → D0=D4, D7-=$100, continue
        if delta == -1: LI_delta_one   → 1 write + LI_c1c
        if delta < -1 : LI_normal_interp (multi-line via FILE59 lookup)
        if delta > 0  : LI_back_step    → Y rewind, no write

      Normal interp :
        N_lines = -delta
        A4 = A4_table[N_lines & $FF]
        idx = ((D4 - D0_int) & $FFF0 + N_lines) & 0xFFFF
        D3 = FILE59[idx] (= step 16.16 fixed-point)
        Inner loop (N_lines - 1 iter) : write (D2, D0_int, D7), D7 -= A4,
                                        D0 += D3
        Tail (1 write) : write (D2, D0_int, D7), D7 -= A4, round (lo=$00,
                         hi += 1)
        D1 = D5, D0 = D4, D0_frac = 0, D7 -= $100

    Returns dict: Y_screen → {flags, width, extra, D0_frac (debug)}.
    """
    dense = {}

    if len(slots) < 2:
        return dense

    N = len(slots)

    # --- Prologue ---
    D1 = slots[N - 1]['slot_Y']
    D0_int = slots[N - 1]['scaling']
    D0_frac = 0
    D7 = signed16((N - 2) * 256)
    Y_write = D1  # Y_screen du prochain write (= dense_ptr / 6)

    # --- Outer loop : N - 1 transitions ---
    for outer_iter in range(N - 1):
        i = N - 2 - outer_iter
        D5 = slots[i]['slot_Y']
        D2 = slots[i]['slot_X']
        D4 = slots[i]['scaling']

        delta = signed16(D1 - D5)

        if delta == 0:
            # LI_delta_zero : pas de write, D0 = D4, D7 -= $100
            D0_int = D4
            D0_frac = 0
            D7 = signed16(D7 - 0x100)
            continue

        if delta > 0:
            # LI_back_step : Y -= 6 × delta (= rewind dense ptr)
            Y_write -= delta
            # LI_c1c : D1 = D5
            D1 = D5
            # LI_delta_zero : D0 = D4, D0_frac = 0
            D0_int = D4
            D0_frac = 0
            # LI_c20 : D7 -= $100
            D7 = signed16(D7 - 0x100)
            continue

        if delta == -1:
            # LI_delta_one : 1 write au Y_write courant
            if 0 <= Y_write < 200:
                dense[Y_write] = {
                    'flags': D2, 'width': D0_int, 'extra': D7,
                    'D0_frac': D0_frac,
                }
            Y_write += 1
            D1 = D5
            D0_int = D4
            D0_frac = 0
            D7 = signed16(D7 - 0x100)
            continue

        # --- LI_normal_interp : delta < -1 (= multi-line interpolation) ---
        N_lines = -delta  # positive 16-bit

        # A4 = A4_table[N_lines & $FF]
        n_idx = N_lines & 0xFF
        A4 = A4_TABLE[n_idx] if n_idx < 64 else 0
        # En ASM, byte +0 de LI_a4 reste $00 → A4 = $00:A4_low (= unsigned 0..255)

        # --- D3 lookup ---
        # ASM : ldd LI_d4 ; subd LI_d0_int ; andb #$F0 ; addd LI_d1
        diff = (D4 - D0_int) & 0xFFFF
        # andb #$F0 = clear low nibble of low byte (= conserve high byte +
        # high nibble du low byte)
        diff = diff & 0xFFF0
        idx = (diff + N_lines) & 0xFFFF
        # cmpd #512 + bhs = unsigned compare → diff négatif (>= $8000) part
        # automatiquement en plage B.
        D3_int, D3_frac = li_lookup_step(file59_paged, idx)

        # --- Inner loop : (N_lines - 1) writes ---
        # ASM : subd #2 ; stb LI_loop_cnt ; dec + bpl → boucle N_lines - 1 fois
        for k in range(N_lines - 1):
            if 0 <= Y_write < 200:
                dense[Y_write] = {
                    'flags': D2, 'width': D0_int, 'extra': D7,
                    'D0_frac': D0_frac,
                }
            Y_write += 1

            # D7 -= A4 (signed 16)
            D7 = signed16(D7 - A4)

            # D0 += D3 (32-bit add, big-endian propagation)
            new_frac = D0_frac + D3_frac
            carry = 1 if new_frac > 0xFFFF else 0
            D0_frac = new_frac & 0xFFFF
            D0_int = signed16(D0_int + D3_int + carry)

        # --- Tail : 1 write + D7 -= A4 + round ---
        if 0 <= Y_write < 200:
            dense[Y_write] = {
                'flags': D2, 'width': D0_int, 'extra': D7,
                'D0_frac': D0_frac,
            }
        Y_write += 1

        # D7 -= A4, puis round : clrb (lo=0) ; adda #1 (hi += 1)
        D7 = signed16(D7 - A4)
        D7_hi = (D7 >> 8) & 0xFF
        D7_hi = (D7_hi + 1) & 0xFF
        D7 = signed16((D7_hi << 8) | 0)

        # LI_c1c : D1 = D5
        D1 = D5
        # LI_delta_zero : D0 = D4, D0_frac = 0
        D0_int = D4
        D0_frac = 0
        # LI_c20 : D7 -= $100
        D7 = signed16(D7 - 0x100)

    return dense


# ─────────────────────────────────────────────────────────────────────────────
# DrawFrameRoad curve compute (per scanline)
# ─────────────────────────────────────────────────────────────────────────────

def dfr_compute_curve(slot_X, width, lateral_chunks_shift, sub_pix):
    """Reproduit le calcul curve dans DFR_have_data.

    Returns dict avec combined_factor, product, neg_product, chunk_shift, sub_pix_out, net_px.
    """
    # lateral_scaled = (chunks × 16 + sub_pix) × 8 = chunks × 128 + sub_pix × 8
    lateral_pos_px = lateral_chunks_shift * 16 + sub_pix
    lateral_scaled = signed16(lateral_pos_px * 8)

    # Strip bits 0-1 of slot.X (= flags PIT/START)
    slot_x_clean = signed16(slot_X & 0xFFFC)

    combined = signed16(slot_x_clean + lateral_scaled)

    # product = (combined × width) >> 16 signed
    product_full = combined * width
    product_hi = signed16(product_full >> 16)

    # Negate (= Lotus convention)
    neg_product = signed16(-product_hi)

    # Decompose into chunk_shift + sub_pix
    decomp_sub_pix = neg_product & 0x0F
    decomp_chunk_shift = signed_shr(neg_product, 4)

    # Net pixel offset = chunk * 16 + sub_pix
    net_px = decomp_chunk_shift * 16 + decomp_sub_pix

    return {
        'slot_x_clean': slot_x_clean,
        'lateral_scaled': lateral_scaled,
        'combined': combined,
        'product': product_hi,
        'neg_product': neg_product,
        'chunk_shift': decomp_chunk_shift,
        'sub_pix_out': decomp_sub_pix,
        'net_px': net_px,
    }


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 4:
        print("Usage: simulate_dfr_pipeline.py <CIRCUIT_ID> <SEGMENT> <NIBBLE> [<LATERAL_POS>]")
        print("Ex   : simulate_dfr_pipeline.py 22_hard_5 130 8 -192")
        sys.exit(1)

    circuit_id = sys.argv[1]
    seg_idx = int(sys.argv[2])
    nibble = int(sys.argv[3])
    lateral_pos = int(sys.argv[4]) if len(sys.argv) > 4 else 0

    # Decompose lateral_pos into chunks_shift + sub_pix (same as P1M_apply_lateral)
    chunks_shift = signed_shr(lateral_pos, 4)
    lateral_sub_pix = lateral_pos & 0x0F

    project_root = Path('/sessions/pensive-exciting-rubin/mnt/thomson-to8-game-engine/game-projects/road-generator')
    if not project_root.exists():
        project_root = Path('/Users/benoitrousseau/Documents/Claude/Projects/thomson-to8-game-engine/game-projects/road-generator')

    circuit_asm = project_root / 'engine' / 'circuits' / f'{circuit_id}.asm'
    file59 = project_root / 'lotus-ste' / 'doc' / 'extraction' / 'unpacked' / 'FILE59.bin'
    paged_bin = project_root / 'engine' / 'projection' / 'Persp_Recip_paged.bin'

    if not circuit_asm.exists():
        print(f"ERROR: circuit not found: {circuit_asm}")
        sys.exit(1)
    if not paged_bin.exists():
        print(f"ERROR: Persp_Recip_paged.bin not found at: {paged_bin}")
        print("       Run: python3 tools/build_persp_recip_paged.py")
        sys.exit(1)

    segments = parse_circuit(circuit_asm, circuit_id)
    horizon, scaling = load_perspective_tables(file59)
    file59_paged = load_persp_recip_paged(paged_bin)

    print(f"═══ Test state ═══")
    print(f"Circuit  : {circuit_id} ({len(segments)} segments parsed)")
    print(f"Position : seg {seg_idx}, nibble {nibble}")
    print(f"Lateral  : pos = {lateral_pos:+d}  → chunks_shift = {chunks_shift:+d}, sub_pix = {lateral_sub_pix}")
    print()
    print(f"=== Segments visibles (= seg .. seg+8) ===")
    for off in range(9):
        cv, pt, pit, start = segments[(seg_idx + off) % 256]
        flags = ('PIT ' if pit else '    ') + ('START' if start else '     ')
        marker = ' ← player here' if off == 0 else ''
        print(f"  seg {seg_idx + off:3d}  cv={cv:+3d}  pt={pt:+3d}  {flags}{marker}")
    print()

    # Run SparseProjection
    slots, min_y = sparse_projection(segments, seg_idx, nibble, horizon, scaling)
    print(f"=== SparseProjection : {len(slots)} substeps, min_y = {min_y} ===")
    print(f"  sub | Y    | slot_X     | scaling | D3      ")
    print(f"  ----+------+------------+---------+---------")
    for s in slots[:24]:
        print(f"  {s['substep']:3d} | {s['slot_Y']:4d} | {s['slot_X']:+10d} | {s['scaling']:5d}   | {s['D3']:+7d}")
    if len(slots) > 24:
        print(f"  ... ({len(slots) - 24} substeps de plus)")
    print()

    # Run LinearInterp (= byte-perfect ASM avec lookup FILE59 réel)
    dense = linear_interp(slots, file59_paged)
    print(f"=== LinearInterp : {len(dense)} dense triplets (byte-perfect ASM) ===")
    print(f"  Y    | flags   | width | extra  | D0_frac")
    print(f"  -----+---------+-------+--------+--------")
    y_sorted = sorted(dense.keys())
    for y in y_sorted:
        t = dense[y]
        print(f"  {y:4d} | {t['flags']:+7d} | {t['width']:5d} | {t['extra']:+6d} | ${t.get('D0_frac', 0):04X}")
    print()

    # Run DFR curve compute per scanline
    print(f"=== DrawFrameRoad curve compute per scanline ===")
    print(f"  Y    | slot.X    | width | lat_sc  | combined | product | -prod | chunk | sub | net_px")
    print(f"  -----+-----------+-------+---------+----------+---------+-------+-------+-----+-------")
    for y in y_sorted:
        t = dense[y]
        r = dfr_compute_curve(t['flags'], t['width'], chunks_shift, lateral_sub_pix)
        print(f"  {y:4d} | {r['slot_x_clean']:+9d} | {t['width']:5d} | {r['lateral_scaled']:+7d} | {r['combined']:+8d} | {r['product']:+7d} | {r['neg_product']:+5d} | {r['chunk_shift']:+5d} | {r['sub_pix_out']:3d} | {r['net_px']:+6d}")


if __name__ == '__main__':
    main()
