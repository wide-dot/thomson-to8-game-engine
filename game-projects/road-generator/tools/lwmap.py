"""
lwmap.py — Parser pour fichiers .lwmap produits par lwasm.

Format ligne (= ce qu'on parse) :
    Symbol: NAME (./path/to/file.bin) = HEX_ADDR

Usage :
    from lwmap import load_lwmap

    syms = load_lwmap('generated-code/road/FD/main.lwmap')
    sparse_addr = syms['Sparse_Buffer']      # int (e.g., 0x6279)
    li_entry    = syms['LinearInterp']       # int (e.g., 0x8353)

API :
    load_lwmap(path)     → dict {symbol: int_addr}
    find_default_map()   → Path du main.lwmap par défaut du projet road-generator
    require(syms, *names) → vérifie présence + retourne tuple(addrs) ou lève
"""

import re
from pathlib import Path


_LINE_RE = re.compile(
    r'^\s*Symbol:\s+(\S+)\s+\([^)]+\)\s+=\s+([0-9A-Fa-f]+)\s*$'
)


def load_lwmap(path):
    """Parse un .lwmap → dict {symbol_name (str): address (int)}.

    Doublons : la dernière définition gagne (lwasm en émet parfois pour les
    EQU partagés entre modules).
    """
    path = Path(path)
    syms = {}
    with open(path) as f:
        for line in f:
            m = _LINE_RE.match(line)
            if m:
                syms[m.group(1)] = int(m.group(2), 16)
    return syms


def find_default_map(project_root=None):
    """Localise le main.lwmap du road-generator.

    Si project_root est None, remonte depuis le fichier courant jusqu'à
    trouver un dossier nommé 'road-generator'.
    """
    if project_root is None:
        cur = Path(__file__).resolve().parent
        while cur != cur.parent:
            if cur.name == 'road-generator':
                project_root = cur
                break
            cur = cur.parent
        else:
            raise FileNotFoundError(
                "Impossible de trouver le dossier 'road-generator' "
                "en remontant depuis " + str(Path(__file__).parent)
            )
    candidate = Path(project_root) / 'generated-code' / 'road' / 'FD' / 'main.lwmap'
    if not candidate.exists():
        raise FileNotFoundError(f"main.lwmap introuvable : {candidate}")
    return candidate


def require(syms, *names):
    """Vérifie présence des symboles, retourne tuple(addrs) ou KeyError.

    Usage :
        sp, li, dfr = require(syms, 'SparseProjection', 'LinearInterp', 'DrawFrameRoad')
    """
    missing = [n for n in names if n not in syms]
    if missing:
        raise KeyError(f"Symboles manquants dans le lwmap : {missing}")
    return tuple(syms[n] for n in names)


if __name__ == '__main__':
    # Smoke test : dump les symboles utiles du pipeline route
    import sys
    map_path = sys.argv[1] if len(sys.argv) > 1 else find_default_map()
    syms = load_lwmap(map_path)
    print(f"Loaded {len(syms)} symbols from {map_path}")
    print()
    print("Symboles pipeline route :")
    keys = [
        'SparseProjection', 'LinearInterp', 'DrawFrameRoad',
        'Sparse_Buffer', 'Dense_Buffer',
        'Proj_count', 'Proj_min_y',
        'LinearInterp_buffer_in', 'LinearInterp_buffer_out',
        'LI_outer_loop', 'LI_normal_interp', 'LI_inner_loop',
        'LI_normal_tail', 'LI_delta_one', 'LI_delta_zero',
        'DFR_main_loop', 'DFR_have_data', 'DFR_dense_ptr',
        'SP_mul_d3_by_scaling', 'SP_mul_full',
        'dp_extreg',
    ]
    for k in keys:
        if k in syms:
            print(f"  {k:30s} = ${syms[k]:04X}")
        else:
            print(f"  {k:30s} = (absent)")
