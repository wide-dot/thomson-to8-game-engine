"""
dcmoto_trace.py — Parser streaming pour traces dcmoto (.txt).

Format ligne trace dcmoto :
    PC OPCODE_HEX MNEM OPERAND CYCLES TOTAL_CYC D=XXXX X=XXXX Y=XXXX U=XXXX
    S=XXXX DP=XX CC=XX | Banques: SYST=0 ROM=1 RAM=XX MEMO=0 VIDEO=X

Exemple :
    8461 EDA1 STD ,Y++ 8 37812 D=2EEC X=6485 Y=681D U=5D84 S=9EFE DP=9F CC=C0 | ...

API streaming (= jamais charger toute la trace en RAM) :

    from dcmoto_trace import iter_lines, TraceLine, find_calls, dump_buffer_writes

    # Itère toutes les lignes parsées
    for tl in iter_lines('dist/dcmoto_trace.txt'):
        if tl.pc == 0x818E:
            print(f"SparseProjection appelé à cycle {tl.total_cyc}")

    # Trouve toutes les invocations d'une fonction
    for start_line, end_line in find_calls(trace_path, func_addr=0x8353, return_addr=0x617F):
        ...

    # Dump les writes vers un buffer dans une plage de lignes
    mem = dump_buffer_writes(trace_path, buffer_addr=0x6779, buffer_size=1152,
                             start_line=7797, end_line=10961)
"""

import re
from collections import namedtuple


# Tuple compact (évite overhead dict per ligne, important sur 850k+ lignes)
TraceLine = namedtuple('TraceLine', [
    'line_no',      # numéro de ligne dans la trace (1-based, hors header "**** TRACE BEGIN ****")
    'pc',           # int : program counter
    'opcode',       # str : opcode hex (e.g., 'EDA1')
    'mnem',         # str : mnemonic (e.g., 'STD')
    'operand',      # str : operand text (e.g., ',Y++')
    'cycles',       # int : cycles pour cette instruction
    'total_cyc',    # int : total cycles depuis début trace
    'd', 'x', 'y', 'u', 's',  # int : registres (état APRÈS exécution)
    'dp', 'cc',     # int : 8-bit
    'rama_bank',    # int : valeur RAM= (banque RAM sélectionnée)
])


# Regex pour la ligne de trace.
# Tolérante : mnem variable width, operand peut être vide.
_LINE_RE = re.compile(
    r'^([0-9A-F]{4})\s+'                          # PC
    r'([0-9A-F]{2,10})\s+'                        # opcode hex
    r'(\S+)(?:\s+(\S+))?\s+'                      # mnem, operand
    r'(\d+(?:/\d+)?)\s+'                          # cycles (e.g., "8" ou "6/5")
    r'(\d+)\s+'                                   # total_cyc
    r'D=([0-9A-F]{4})\s+'
    r'X=([0-9A-F]{4})\s+'
    r'Y=([0-9A-F]{4})\s+'
    r'U=([0-9A-F]{4})\s+'
    r'S=([0-9A-F]{4})\s+'
    r'DP=([0-9A-F]{2})\s+'
    r'CC=([0-9A-F]{2})'
    r'.*?RAM=([0-9A-F]{2})',
    re.IGNORECASE
)


def iter_lines(trace_path, line_range=None):
    """Stream les lignes d'une trace dcmoto en TraceLine.

    line_range : tuple (start, end) optionnel pour skip rapide vers une zone.
                 Les numéros line_no de la trace commencent à 1 pour la
                 première ligne d'instruction (= 'TRACE BEGIN' header skippé).
    """
    start, end = (line_range or (None, None))
    line_no = 0
    with open(trace_path) as f:
        for raw in f:
            # Skip header marker
            if raw.startswith('****'):
                continue
            # La 1ère ligne du fichier est une ligne d'init (= D=XXXX seul,
            # sans PC/opcode/mnem). On la skip.
            m = _LINE_RE.match(raw)
            if not m:
                continue
            line_no += 1
            if start is not None and line_no < start:
                continue
            if end is not None and line_no > end:
                break
            # Premier cycle (e.g., "6/5") : prend la 1ère valeur
            cycles_str = m.group(5).split('/')[0]
            yield TraceLine(
                line_no=line_no,
                pc=int(m.group(1), 16),
                opcode=m.group(2),
                mnem=m.group(3),
                operand=m.group(4) or '',
                cycles=int(cycles_str),
                total_cyc=int(m.group(6)),
                d=int(m.group(7), 16),
                x=int(m.group(8), 16),
                y=int(m.group(9), 16),
                u=int(m.group(10), 16),
                s=int(m.group(11), 16),
                dp=int(m.group(12), 16),
                cc=int(m.group(13), 16),
                rama_bank=int(m.group(14), 16),
            )


def find_calls(trace_path, func_addr, return_addr=None):
    """Trouve toutes les invocations de func_addr.

    Une invocation = (entry_line_no, exit_line_no).
    entry = la ligne où PC == func_addr (= 1ère instruction de la fonction)
    exit = la ligne juste après le RTS de cette invocation

    Si return_addr est fourni, on l'utilise pour matcher l'exit (= 1ère
    ligne après l'invocation où PC == return_addr). Sinon on track la
    profondeur de stack via JSR/BSR/RTS (plus coûteux mais plus robuste).

    Yields : (entry_line_no, exit_line_no) tuples.
    """
    if return_addr is not None:
        # Mode rapide : match func_addr puis 1ère occurrence de return_addr
        entry = None
        for tl in iter_lines(trace_path):
            if entry is None and tl.pc == func_addr:
                entry = tl.line_no
            elif entry is not None and tl.pc == return_addr:
                yield (entry, tl.line_no)
                entry = None
    else:
        # Mode robuste : track stack depth
        entry = None
        depth = 0
        for tl in iter_lines(trace_path):
            if entry is None and tl.pc == func_addr:
                entry = tl.line_no
                depth = 1
            elif entry is not None:
                # Track BSR/JSR/LBSR (increment), RTS (decrement)
                if tl.mnem in ('JSR', 'BSR', 'LBSR'):
                    depth += 1
                elif tl.mnem in ('RTS', 'PULS') and 'PC' in tl.operand:
                    depth -= 1
                    if depth == 0:
                        yield (entry, tl.line_no + 1)
                        entry = None
                elif tl.mnem == 'RTS':
                    depth -= 1
                    if depth == 0:
                        yield (entry, tl.line_no + 1)
                        entry = None


def dump_buffer_writes(trace_path, buffer_addr, buffer_size, line_range=None):
    """Extrait les writes vers [buffer_addr, buffer_addr+buffer_size).

    Détecte les writes via :
    - STD ,Y / STD ,Y++ / STD ,-Y / STD n,Y → écrit D à l'addr Y (avec
      éventuel auto-inc/dec et offset)
    - STA / STB / STD à adresse extended directe

    Approche pragmatique : on tracke Y/X/U dans la TraceLine (= état APRÈS
    exécution). Pour les modes auto-inc/dec, l'addr d'écriture est calculée
    en inversant l'effet.

    Returns : dict {addr (int): byte_value (int 0-255)}
    """
    buffer_end = buffer_addr + buffer_size
    mem = {}

    def store_word(addr, val):
        if buffer_addr <= addr < buffer_end:
            mem[addr] = (val >> 8) & 0xFF
        if buffer_addr <= addr + 1 < buffer_end:
            mem[addr + 1] = val & 0xFF

    def store_byte(addr, val):
        if buffer_addr <= addr < buffer_end:
            mem[addr] = val & 0xFF

    for tl in iter_lines(trace_path, line_range):
        op = tl.operand
        m = tl.mnem
        if m not in ('STD', 'STA', 'STB', 'STX', 'STY', 'STU'):
            continue

        # === Adressage indirect via registres ===
        # Y/X/U postfix après auto-inc/dec dans la TraceLine, donc on
        # inverse pour retrouver l'adresse d'écriture pre-update.
        if ',Y++' in op:
            # auto-inc 2 : Y a été incrémenté de 2 → write addr = Y - 2
            addr = (tl.y - 2) & 0xFFFF
            if m == 'STD': store_word(addr, tl.d)
            elif m in ('STA', 'STB'):
                # ,Y+ pour byte n'existe pas en 6809 (juste ,Y++ pour 16-bit)
                # mais STD inc by 2 ne fait pas STA inc by 1...
                # Skip : pas standard
                pass
            continue
        if ',Y+' in op:
            addr = (tl.y - 1) & 0xFFFF
            if m in ('STA', 'STB'):
                store_byte(addr, tl.d & 0xFF if m == 'STB' else (tl.d >> 8) & 0xFF)
            continue
        if ',--Y' in op:
            # pre-dec by 2 : Y a été décrémenté → write addr = Y (post)
            addr = tl.y
            if m == 'STD': store_word(addr, tl.d)
            continue
        if ',-Y' in op:
            addr = tl.y
            if m in ('STA', 'STB'):
                store_byte(addr, tl.d & 0xFF if m == 'STB' else (tl.d >> 8) & 0xFF)
            continue
        if op == ',Y':
            if m == 'STD': store_word(tl.y, tl.d)
            elif m == 'STA': store_byte(tl.y, (tl.d >> 8) & 0xFF)
            elif m == 'STB': store_byte(tl.y, tl.d & 0xFF)
            continue
        # ,U / ,X variants
        if ',U++' in op:
            addr = (tl.u - 2) & 0xFFFF
            if m == 'STD': store_word(addr, tl.d)
            continue
        if ',--U' in op:
            if m == 'STD': store_word(tl.u, tl.d)
            continue
        if op == ',U':
            if m == 'STD': store_word(tl.u, tl.d)
            continue
        if ',X++' in op:
            addr = (tl.x - 2) & 0xFFFF
            if m == 'STD': store_word(addr, tl.d)
            continue
        if op == ',X':
            if m == 'STD': store_word(tl.x, tl.d)
            continue

        # === STD/STA/STB extended ($XXXX direct) ===
        if op.startswith('$'):
            try:
                addr = int(op[1:], 16)
            except ValueError:
                continue
            if m == 'STD': store_word(addr, tl.d)
            elif m == 'STA': store_byte(addr, (tl.d >> 8) & 0xFF)
            elif m == 'STB': store_byte(addr, tl.d & 0xFF)

    return mem


def decode_dense_triplets(mem, dense_addr, y_range=(0, 192)):
    """Décode un dump dense buffer mémoire → triplets (Y_screen, flags, width, extra).

    Layout : 6 oct par scanline = flags (16-bit) + width (16-bit) + extra (16-bit)
    """
    triplets = {}
    for y in range(*y_range):
        addr = dense_addr + y * 6
        if not all((addr + i) in mem for i in range(6)):
            continue
        flags = (mem[addr] << 8) | mem[addr + 1]
        width = (mem[addr + 2] << 8) | mem[addr + 3]
        extra = (mem[addr + 4] << 8) | mem[addr + 5]
        # Sign-extend
        if flags & 0x8000: flags -= 0x10000
        if extra & 0x8000: extra -= 0x10000
        triplets[y] = {'flags': flags, 'width': width, 'extra': extra}
    return triplets


def decode_sparse_slots(mem, sparse_addr, count):
    """Décode un dump sparse buffer → list of slots (X, Y, Y_min, D0a).

    Layout : 8 oct par slot.
    """
    slots = []
    for i in range(count):
        addr = sparse_addr + i * 8
        if not all((addr + o) in mem for o in range(8)):
            break
        def w(off):
            v = (mem[addr + off] << 8) | mem[addr + off + 1]
            return v - 0x10000 if v & 0x8000 else v
        slots.append({
            'X': w(0), 'Y': w(2), 'Y_min': w(4), 'D0a': w(6)
        })
    return slots
