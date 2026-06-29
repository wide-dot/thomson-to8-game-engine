#!/usr/bin/env python3
"""dcmoto-watch.py - annote une trace d'execution DCMoto avec l'adresse
effective (EA) de chaque acces memoire.

Le trace DCMoto montre l'operande (ex: "STD $08,U") mais PAS l'adresse effective
des modes indexes/directs : impossible de grep par adresse. Cet outil la calcule
depuis l'etat registre et l'ajoute en fin de ligne, ce qui rend la trace
greppable par adresse memoire -> watchpoint post-mortem :

    dcmoto-watch.py trace.txt              # ecrit trace.txt.ea
    grep "EA=652E" trace.txt.ea            # toutes les ecritures/lectures de $652E

Calcul : l'instruction de la ligne N utilise l'etat registre AFFICHE par la
ligne N-1 (la trace affiche les registres APRES execution).

Annotation : UN tag "EA=adr" par OCTET touche (pas de plage), pour rester
greppable par adresse exacte -> grep "EA=652E" trouve TOUTE instruction qui
ecrit cet octet, y compris l'octet haut d'un store 16 bits ou un octet au
milieu d'un push. Couverture des ecritures :
  ST* (STA/STB = 1 o ; STD/STX/STY/STU/STS = 2 o) et RMW INC/DEC/CLR/COM/NEG/
       ASL/LSR/ROL/ROR/ASR (1 o). Modes etendu, direct (via DP), indexe (offset
       constant 5/8/16 bits, accumulateur A/B/D, auto inc/dec).
  PSHS/PSHU (liste de registres), JSR/BSR/LBSR (PC, 2 o), SWI/SWI2/SWI3 (12 o)
       -> un EA= par octet de la plage pile.
  PTR= indirect [...] : pointeur calcule (la cible finale exige l'etat memoire).
Lectures (LD*/CMP*/ADD*...) aussi taggees EA= (acces, pas seulement ecriture) :
filtrer par mnemonique au grep si besoin. Non couvert : PULS/PULU/RTS (lectures
pile), PC-relatif (exige la longueur d'instruction).

Suite possible (non implementee) : detecteur de debordement inter-OST, resolution
de symboles depuis le .lst, reconstruction de pile d'appels.
"""
import re, sys, argparse

def s8(v):  return v - 256   if v & 0x80   else v
def s16(v): return v - 65536 if v & 0x8000 else v

REGSIZE = {'CC':1,'A':1,'B':1,'DP':1,'D':2,'X':2,'Y':2,'U':2,'S':2,'PC':2}

# mnemoniques accedant un MOT (2 octets) ; tout le reste = 1 octet
WORD = {'LDD','STD','LDX','STX','LDY','STY','LDU','STU','LDS','STS',
        'CMPD','CMPX','CMPY','CMPU','CMPS','ADDD','SUBD'}

def stack_write(mnem, op, regs):
    """plage [lo,hi] ecrite sur la pile par les instructions de push. None sinon.
    (PULS/PULU/RTS = lectures, non couvertes ici.)"""
    if mnem in ('PSHS', 'PSHU'):
        sr = 'S' if mnem == 'PSHS' else 'U'
        total = sum(REGSIZE.get(r, 0) for r in op.split(',')) if op else 0
    elif mnem in ('JSR', 'BSR', 'LBSR'):
        sr, total = 'S', 2                       # push du PC de retour
    elif mnem in ('SWI', 'SWI2', 'SWI3'):
        sr, total = 'S', 12                      # push complet (CC,A,B,DP,X,Y,U,PC)
    else:
        return None
    S = regs.get(sr)
    if not S or not total:
        return None
    return (S - total) & 0xFFFF, (S - 1) & 0xFFFF

LINE = re.compile(r'^([0-9A-F]{4})\s+\S+\s+(\S+)(?:\s+(\S+))?(?:\s|$)')
REG  = re.compile(r'\b(D|X|Y|U|S|DP)=([0-9A-F]+)')

def parse(line):
    m = LINE.match(line)
    if not m:
        return None
    mnem, op = m.group(2), m.group(3)
    if op is not None and op[0].isdigit():   # en fait le compteur de cycles, pas un operande
        op = None
    regs = {k: int(v, 16) for k, v in REG.findall(line)}
    return mnem, op, regs

def ea(op, regs):
    """(adresse, indirect) en utilisant regs = etat AVANT l'instruction. None si non-memoire."""
    if op is None or op.startswith('#'):
        return None
    m = re.fullmatch(r'\[?\$([0-9A-F]{4})\]?', op)               # etendu (ou [etendu])
    if m:
        return int(m.group(1), 16), op.startswith('[')
    m = re.fullmatch(r'<\$([0-9A-F]{1,2})', op)                   # direct (page DP)
    if m:
        return ((regs.get('DP', 0) & 0xFF) << 8) | int(m.group(1), 16), False
    if ',' in op:                                                # indexe
        indirect = op.startswith('[')
        offstr, base = op.strip('[]').rsplit(',', 1)
        if 'PC' in base:
            return None
        nbminus = len(base) - len(base.lstrip('-'))
        rname = base.strip('+-')
        if rname not in ('X', 'Y', 'U', 'S'):
            return None
        if offstr not in ('', 'A', 'B', 'D') and not re.fullmatch(r'-?\$?[0-9A-F]+', offstr):
            return None                                          # liste de registres (PSHS...), pas un offset
        R = regs.get(rname)
        if R is None:
            return None
        if offstr in ('', 'A', 'B', 'D'):
            if offstr == '':
                off = -nbminus                                   # ,R / ,R+ / ,R++ / ,-R / ,--R
            else:
                D = regs.get('D', 0)
                off = D if offstr == 'D' else (s8(D >> 8) if offstr == 'A' else s8(D & 0xFF))
        else:
            neg = offstr.startswith('-')
            h = offstr.lstrip('-').lstrip('$')
            v = int(h, 16)
            v = s8(v) if len(h) <= 2 else s16(v)
            off = -v if neg else v
        return (R + off) & 0xFFFF, indirect
    return None

def main():
    ap = argparse.ArgumentParser(description="Annote une trace DCMoto avec l'adresse effective de chaque acces memoire.")
    ap.add_argument('trace', help='fichier trace DCMoto')
    ap.add_argument('-o', '--output', help='sortie (defaut: <trace>.ea)')
    args = ap.parse_args()
    out_path = args.output or args.trace + '.ea'

    prev = None
    n = tagged = 0
    with open(args.trace, errors='replace') as f, open(out_path, 'w') as out:
        for line in f:
            line = line.rstrip('\n')
            p = parse(line)
            tag = ''
            if p and prev:
                mnem, op = p[0], p[1]
                hits, ptr = [], None
                wr = stack_write(mnem, op, prev[2])             # PSHS/PSHU/JSR/BSR/SWI -> plage pile
                if wr and wr[0] <= wr[1]:
                    hits = list(range(wr[0], wr[1] + 1))        # un octet par case de pile
                elif mnem not in ('PULS', 'PULU', 'TFR', 'EXG'):
                    r = ea(op, prev[2])                         # regs AVANT = ligne precedente
                    if r:
                        addr, indirect = r
                        if indirect:
                            ptr = addr                          # cible reelle inconnue (exige la memoire)
                        else:
                            size = 2 if mnem in WORD else 1
                            hits = [(addr + k) & 0xFFFF for k in range(size)]
                if hits:
                    tag = '  ' + ' '.join('EA=%04X' % a for a in hits)
                    tagged += 1
                elif ptr is not None:
                    tag = '  PTR=%04X' % ptr
                    tagged += 1
            out.write(line + tag + '\n')
            if p:
                prev = p
                n += 1
    print("%s : %d instructions, %d annotees (EA/PTR)" % (out_path, n, tagged), file=sys.stderr)

if __name__ == '__main__':
    main()
