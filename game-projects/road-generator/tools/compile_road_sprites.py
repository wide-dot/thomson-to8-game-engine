#!/usr/bin/env python3
"""
Buffers route TO8 v4 — modèle fdb + extraction prélude/épilogue d'herbe.

Architecture :
- 1 image source : normal_dark.png (PNG indexes 1..16, 0=transparent), copiée
  telle quelle en .work/master.png = l'unique entrée effective du traitement.
- 1 mapping couleur : index_map.json (à côté du source, ou --index-map).
  Chaque index PNG source (= un rôle : rumble/grass/asphalt/lines) est projeté
  vers un nibble TO8 par bank : {"lines": {"source": 7, "dark": 6, "light": 7}}.
  Tout le pipeline (chunking, herbe, dédup) travaille en espace CANONIQUE
  (nibble = index PNG − 1) ; les tables dark/light ne sont appliquées qu'à
  l'émission des immédiats ldd/ldx. index_map_identity.json reproduit la
  sortie historique (dark = identité, light = +1) byte-identique.
- 3 binaires générés :
  • road_patterns_dark.asm  (ORG $4000) : Road_pshu_dx + Road_R* + Road_draw_KX_JY (dark)
  • road_patterns_light.asm (ORG $4000) : structure identique, nibbles remappés
  • road_buffers.asm        (ORG $0000) : buffers fdb (header K,M,J + cœur) + Road_lines

Modèle d'exécution (côté appelant, hors générateur) :

    Chaque buffer = header (3 octets : K, M, J) suivi de M fdb (le cœur).
    "Herbe" = la valeur la plus fréquente, traitée comme prélude/épilogue
    implicite via les variants Road_draw_KX_JY déroulés dans la pattern bank.

    Caller :
        ldy   Road_lines + 8*line_idx + 2*variant
        ; A = K, B = M après ldd ,y ; J accessible en 2,y
        ; calcule K' = min(10, max(0, K - entry_idx))
        ;        J' = min(10, max(0, entry_idx + 10 - K - M))
        ; F = 10 - K' - J'
        ; pose Y sur le cœur : Y = (buffer + 3) + max(0, entry_idx - K)*2
        ; saute vers Road_draw_K[K']_J[J']

    Le variant Road_draw_KX_JY contient les pshu d'herbe déroulés :
        ldd  #grass_d  (embarqué)
        ldx  #grass_x
        pshu d,x × K'
        jsr  [,Y++] × F
        ldd  #grass_d  ; recharge si J' > 0 (le cœur change D/X)
        ldx  #grass_x
        pshu d,x × J'
        rts

Bank switching dark/light : swap hardware $4000-$5FFF (les routines patternS
et les variants draw y vivent), les buffers sont stables (palette-agnostiques).

Pipeline d'assemblage :
  1. lwasm road_patterns_dark.asm  → bin + map
  2. parse map → road_externs.inc (EQU pour Road_pshu_dx + Road_R* + Road_draw_*)
  3. lwasm road_buffers.asm (include externs.inc) → bin
  4. lwasm road_patterns_light.asm → bin
  5. diff dark.map / light.map → fatal si discordance

Usage (depuis project root) :
    python3 tools/compile_road_sprites.py --batch tools/road_sprites_source

Outputs :
    game-mode/road/generated/      (= bin patterns + asm/inc inclus dans résident)
    objects/road-buffers/generated/ (= road_buffers.bin INCLUDEBIN'é par wrapper)
    tools/.work/road_lines_ram/    (= master.png + previews + intermédiaires lwasm)
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from collections import Counter
from pathlib import Path

from road_common import (
    WINDOW_PX,
    measure_effective_width,
    pixels_to_bm16,
    read_png_indexed,
    write_asm,
    write_png_indexed,
)

# ── Constantes ────────────────────────────────────────────────────────────────
CHUNK_BYTES_RAM = 4
CHUNK_SCREEN_PX_RAM = 16
WINDOW_CHUNKS = WINDOW_PX // CHUNK_SCREEN_PX_RAM        # = 10


SRC_VARIANT = 'normal_dark'

ASM_BUFFERS        = 'road_buffers.asm'
ASM_LINES_TABLE    = 'road_lines_table.asm'
ASM_DISPATCH       = 'road_draw_dispatch.asm'
ASM_PATTERNS_DARK  = 'road_patterns_dark.asm'
ASM_PATTERNS_LIGHT = 'road_patterns_light.asm'
INC_PATTERNS       = 'road_patterns_externs.inc'
INC_BUFFERS        = 'road_buffers_externs.inc'

# === Arborescence de sortie (relatif au project root = cwd lors de l'exec) ===
# Convention : tout ce qui est généré vit dans un répertoire `generated/`.
WORK_DIR_REL       = 'tools/.work/road_lines_ram'         # intermédiaires lwasm (.asm sources, .map, .lst)
GAME_GENERATED_REL = 'game-mode/road/generated'           # bin patterns + asm/inc inclus dans résident
OBJ_GENERATED_REL  = 'objects/road-buffers/generated'     # bin INCLUDEBIN'é par le wrapper objet

# Chemins INCLUDE embarqués dans les .asm intermédiaires (= depuis .work/).
# Résolus par lwasm avec cwd=project root.
INC_PATTERNS_PATH  = f'./{GAME_GENERATED_REL}/{INC_PATTERNS}'
INC_BUFFERS_PATH   = f'./{GAME_GENERATED_REL}/{INC_BUFFERS}'

PATTERNS_ORG    = 0x4000
BUFFERS_ORG     = 0x0000
LINES_TABLE_ORG = 0x0000   # blob relocatable, addresses Line_NNNN absolues

PSHU_LABEL = 'Road_pshu_dx'


# ── Mapping index couleur (index_map.json) ───────────────────────────────────
# Espace CANONIQUE = nibble (index PNG − 1), tel que produit par pixels_to_bm16.
# Le mapping projette chaque nibble canonique vers le nibble TO8 de chaque bank.

INDEX_MAP_DEFAULT = 'index_map.json'
PALETTES = ('dark', 'light')


def load_index_map(path: Path):
    """Charge index_map.json → {'dark': [16], 'light': [16]} (None = non mappé)
       + rôles pour les logs. Clés '_*' ignorées (commentaires)."""
    data = json.loads(path.read_text())
    nib_maps = {pal: [None] * 16 for pal in PALETTES}
    roles = {}                                   # canonical nibble → role name
    for role, spec in data.items():
        if role.startswith('_'):
            continue
        src = spec['source']
        if not (1 <= src <= 16):
            raise ValueError(f"{path.name}: '{role}' source={src} hors 1..16")
        canon = src - 1
        if canon in roles:
            raise ValueError(f"{path.name}: source {src} déclaré deux fois "
                             f"('{roles[canon]}' et '{role}')")
        roles[canon] = role
        for pal in PALETTES:
            v = spec[pal]
            if not (0 <= v <= 15):
                raise ValueError(f"{path.name}: '{role}' {pal}={v} hors 0..15")
            nib_maps[pal][canon] = v
    if not roles:
        raise ValueError(f"{path.name}: aucun rôle défini")
    return nib_maps, roles


def check_map_coverage(pixels, roles, map_path: Path):
    """Vérifie que chaque index PNG non-transparent de l'image a un rôle mappé."""
    used = set()
    for row in pixels:
        used.update(row)
    used.discard(0)
    missing = sorted(p for p in used if (p - 1) not in roles)
    if missing:
        raise ValueError(
            f"index PNG {missing} présents dans l'image mais absents de "
            f"{map_path.name} — compléter le mapping")
    unused = sorted(roles[c] for c in roles if (c + 1) not in used)
    if unused:
        print(f"  ⚠ rôles mappés mais absents de l'image : {', '.join(unused)}")
    return sorted(p - 1 for p in used)


def map_nibbles(word, nmap):
    """Applique nmap (list[16]) aux 4 nibbles d'un mot 16 bits."""
    out = 0
    for shift in (12, 8, 4, 0):
        n = (word >> shift) & 0xF
        m = nmap[n]
        if m is None:
            raise ValueError(f"nibble canonique {n} non mappé (mot ${word:04X})")
        out |= m << shift
    return out


def map_ops(ops, nmap):
    """Applique map_nibbles aux immédiats d'un chunk_load_ops."""
    return tuple((mn, map_nibbles(val, nmap)) for mn, val in ops)


# ── Master + previews (.work) ────────────────────────────────────────────────

def _load_preview_palette():
    """Palette TO8 pour les previews : tools/_palette.json (entrée i = couleur
       du nibble TO8 i−1, entrée 0 = transparent). Fallback : niveaux de gris."""
    pal_json = Path(__file__).resolve().parent / '_palette.json'
    colors = [(0, 0, 0)] * 17
    if pal_json.exists():
        hexes = json.loads(pal_json.read_text())
        for i, h in enumerate(hexes[:17]):
            colors[i] = tuple(int(h[j:j + 2], 16) for j in (1, 3, 5))
    else:
        for i in range(1, 17):
            colors[i] = ((i - 1) * 17,) * 3
    return colors


def prepare_master_and_previews(src_dir: Path, work_dir: Path,
                                nib_maps, roles, map_path: Path):
    """Copie le source en .work/master.png (= l'unique entrée effective, en
       espace source), vérifie la couverture du mapping, puis émet
       preview_dark/light.png = master avec les nibbles remappés + vraie
       palette, pour contrôle visuel du mapping. Les previews sont des
       ARTEFACTS régénérés à chaque run, jamais des entrées."""
    src = src_dir / f"{SRC_VARIANT}.png"
    if not src.exists():
        raise FileNotFoundError(f"PNG absent : {src}")
    master = work_dir / 'master.png'
    shutil.copyfile(src, master)
    print(f"  master : {src} → {master.relative_to(Path.cwd())}")

    width, height, pixels = read_png_indexed(master)
    used_canon = check_map_coverage(pixels, roles, map_path)
    for canon in used_canon:
        maps = ' '.join(f"{pal}={nib_maps[pal][canon]}" for pal in PALETTES)
        print(f"    {roles[canon]:<8} (source {canon + 1}) → {maps}")
    to8_used = sorted({nib_maps[pal][c] for pal in PALETTES for c in used_canon})
    free_low = sorted(set(range(8)) - set(to8_used))
    print(f"  index TO8 consommés : {to8_used}  (libres dans 0..7 : {free_low})")

    palette = _load_preview_palette()
    for pal in PALETTES:
        nmap = nib_maps[pal]
        out = [[0 if p == 0 else nmap[(p - 1) & 0x0F] + 1 for p in row]
               for row in pixels]
        path = work_dir / f'preview_{pal}.png'
        write_png_indexed(path, width, height, out, palette)
        print(f"  preview {pal:<5} : {path.relative_to(Path.cwd())}")
    return master


# ── Chunking ─────────────────────────────────────────────────────────────────

def plane_to_chunks(plane_bytes):
    """Découpe un plan en chunks de 4 octets, rightmost en premier."""
    n = len(plane_bytes)
    if n % CHUNK_BYTES_RAM != 0:
        raise ValueError(f"plan non multiple de {CHUNK_BYTES_RAM} : {n}")
    chunks = []
    pos = n
    while pos > 0:
        chunks.append(tuple(plane_bytes[pos - CHUNK_BYTES_RAM:pos]))
        pos -= CHUNK_BYTES_RAM
    return chunks


def chunk_load_ops(chunk):
    """ldd #AB + ldx #XhXl — toujours full charge."""
    A, B, Xh, Xl = chunk
    return (('ldd', (A << 8) | B), ('ldx', (Xh << 8) | Xl))


# ── Mesure prélude / épilogue d'herbe ─────────────────────────────────────────

def measure_grass(chunks, grass):
    """Renvoie (K, J) : longueur prélude / épilogue de chunks == grass.
       Cas full-grass (K+J > N) : on rabat tout en prélude (K = N, J = 0)."""
    n = len(chunks)
    if n == 0:
        return 0, 0
    K = 0
    while K < n and chunks[K] == grass:
        K += 1
    if K == n:
        return n, 0
    J = 0
    while J < n - K and chunks[n - 1 - J] == grass:
        J += 1
    return K, J


def measure_grass_pixels(content_d, grass_pix, chunk_px=CHUNK_SCREEN_PX_RAM):
    """K, J unifiés basés sur les PIXELS (= pas plane-spécifique).

    Chunk = chunk_px (16) pixels consécutifs de content_d. Un chunk est
    "grass-only" si TOUS ses pixels = grass_pix.
    K = nombre de chunks grass-only à la DROITE de content_d (= chunks reversed
    leading). J = idem à GAUCHE (= chunks reversed trailing).

    Garantit K_RAMA == K_RAMB == K (idem M et J) → dispatch runtime utilise
    même entry_idx pour les 2 passes → road synchro sur écran."""
    n_chunks = len(content_d) // chunk_px
    K = 0
    while K < n_chunks:
        end = len(content_d) - K * chunk_px
        start = end - chunk_px
        if all(content_d[i] == grass_pix for i in range(start, end)):
            K += 1
        else:
            break
    if K == n_chunks:
        return n_chunks, 0
    J = 0
    while J < n_chunks - K:
        start = J * chunk_px
        end = start + chunk_px
        if all(content_d[i] == grass_pix for i in range(start, end)):
            J += 1
        else:
            break
    return K, J


# ── Pool ─────────────────────────────────────────────────────────────────────

class RoadPool:
    def __init__(self, nib_maps):
        self.nib_maps = nib_maps                     # {'dark': [16], 'light': [16]}
        self.usage: Counter = Counter()              # ops canonique → count
        self.label_map: dict[tuple, str] = {}        # ops canonique → Road_RNNNNN
        self._id = 0
        self.grass_value: tuple | None = None        # 4-tuple bytes canoniques
        self.grass_ops: dict[str, tuple] = {}        # palette → load_ops herbe mappés
        self.kmj_records: list[tuple] = []           # (K, M, J) par buffer logique

    def set_grass(self, grass_bytes):
        self.grass_value = grass_bytes
        ops_c = chunk_load_ops(grass_bytes)
        for pal in PALETTES:
            self.grass_ops[pal] = map_ops(ops_c, self.nib_maps[pal])

    def register(self, ops_c):
        if ops_c not in self.label_map:
            self.label_map[ops_c] = f"Road_R{self._id:05d}"
            self._id += 1
        self.usage[ops_c] += 1
        return self.label_map[ops_c]

    def record_kmj(self, K, M, J):
        self.kmj_records.append((K, M, J))

    def collect_variants(self) -> set:
        """Énumère tous les (K', J') nécessaires.

        MODÈLE leftEdge (fix fidèle 68k) : la position route = leftEdge_chunks,
        donc J' = clamp(leftEdge_chunks, 0, 10) et K' = 10 - clamp(right, 0, 10)
        peuvent prendre TOUTE valeur avec K' + J' <= WINDOW_CHUNKS (= triangle
        complet, 66 combos). L'ancien modèle entry-based ne produisait que K'<=5
        (car K buffer <= 5 + entry >= 0) → routines K'>5 absentes → route qui
        DISPARAÎT quand un virage la pousse à gauche écran. On émet donc TOUT le
        triangle K'+J' <= 10 (superset de l'ancien set).
        """
        variants = set()
        for K_prime in range(WINDOW_CHUNKS + 1):
            for J_prime in range(WINDOW_CHUNKS + 1 - K_prime):
                variants.add((K_prime, J_prime))
        return variants

    # ── Émission ──

    def emit(self, lines, variant_set, palette):
        """Émet ORG, pshu stub, toutes les routines Road_R*, puis les variants."""
        lines.append(f"        ORG   ${PATTERNS_ORG:04X}")
        lines.append("")
        lines.append("* ─── Stub pshu (palette-agnostique, dupliqué 2 banks) ───")
        lines.append(PSHU_LABEL)
        lines.append("        pshu  d,x")
        lines.append("        rts")
        lines.append("")
        lines.append(f"* ─── {len(self.label_map)} routines ld ({palette}) ───")
        nmap = self.nib_maps[palette]
        for ops_c, label in sorted(self.label_map.items(), key=lambda kv: kv[1]):
            (_, d), (_, x) = map_ops(ops_c, nmap)
            lines.append(f"* uses={self.usage[ops_c]}  D=${d:04X} X=${x:04X}")
            lines.append(label)
            lines.append(f"        ldd   #${d:04X}")
            lines.append(f"        ldx   #${x:04X}")
            lines.append("        pshu  d,x")
            lines.append("        rts")
        # variants
        (_, g_d), (_, g_x) = self.grass_ops[palette]
        lines.append("")
        lines.append(f"* ─── {len(variant_set)} variants Road_draw_KX_JY ({palette}) ───")
        lines.append(f"*   herbe : D=${g_d:04X} X=${g_x:04X}")
        lines.append("*   Optim : si Y libre et N≥3, on fait `leay ,x` puis pshu d,x,y")
        lines.append("*           (11cy/6o vs 9cy/4o de pshu d,x). Setup = +4cy (leay).")
        for (K, J) in sorted(variant_set):
            F = WINDOW_CHUNKS - K - J
            label = f"Road_draw_K{K}_J{J}"
            lines.append("")
            lines.append(f"* {label} : K'={K} prélude / F={F} cœur / J'={J} épilogue")
            lines.append(label)
            if F == 0:
                # Pas de jsr : Y libre dès le départ → 1 seul bloc fusionné
                N = K + J
                if N > 0:
                    lines.append(f"        ldd   #${g_d:04X}")
                    lines.append(f"        ldx   #${g_x:04X}")
                    self._emit_pshu_block(lines, N, can_use_y=True)
            else:
                if K > 0:
                    # Prélude : Y doit être préservée pour les jsr suivants
                    lines.append(f"        ldd   #${g_d:04X}")
                    lines.append(f"        ldx   #${g_x:04X}")
                    self._emit_pshu_block(lines, K, can_use_y=False)
                # Optim cycles : jsr [,y] + jsr [2k,y] (= offsets fixes au lieu
                # d'auto-increment). Y n'a pas besoin d'avancer car l'épilogue
                # le réassigne via leay ,x. Cycles : 13 → 10 (1er) puis 11 (suite).
                for i in range(F):
                    offset = i * 2
                    if offset == 0:
                        lines.append("        jsr   [,y]")
                    else:
                        lines.append(f"        jsr   [{offset},y]")
                if J > 0:
                    # Épilogue : Y peut être clobber (rien après ne la lit)
                    lines.append(f"        ldd   #${g_d:04X}")
                    lines.append(f"        ldx   #${g_x:04X}")
                    self._emit_pshu_block(lines, J, can_use_y=True)
            lines.append("        rts")

    @staticmethod
    def _emit_pshu_block(lines, N, *, can_use_y):
        """Émet la séquence pshu équivalant à N×pshu d,x (= 4N octets).
           Si can_use_y et N>=3 : `leay ,x` puis greedy pshu d,x,y / pshu d,x / pshu d.
           Sinon : N × pshu d,x (modèle de base)."""
        if can_use_y and N >= 3:
            lines.append("        leay  ,x")
            bytes_total = N * 4
            n_dxy = bytes_total // 6
            rem = bytes_total - 6 * n_dxy        # ∈ {0, 2, 4}
            for _ in range(n_dxy):
                lines.append("        pshu  d,x,y")
            if rem == 4:
                lines.append("        pshu  d,x")
            elif rem == 2:
                lines.append("        pshu  d")
        else:
            for _ in range(N):
                lines.append("        pshu  d,x")


# ── BufferStore (dedup par (M, cœur_labels)) ─────────────────────────────────
# K et J ne sont PAS lus au runtime : DrawFrameRoad recalcule K'/J' depuis
# leftEdge (= DFR_curve_chunk_shift) + M seul. Le header est donc réduit à
# `fcb M` (1 oct au lieu de 3) et la dédup se fait sur (M, labels) — deux
# buffers identiques en cœur+M mais d'ancien K/J distincts fusionnent.

class BufferStore:
    def __init__(self):
        self.map: dict[tuple, str] = {}     # (M, labels) → name
        self.order: list[tuple] = []
        self._id = 0

    def register(self, M, label_tuple):
        key = (M, label_tuple)
        if key in self.map:
            return self.map[key]
        name = f"Line_{self._id:04d}"
        self._id += 1
        self.map[key] = name
        self.order.append(key)
        return name

    def emit(self, lines):
        for key in self.order:
            M, labels = key
            name = self.map[key]
            lines.append("")
            lines.append(f"* {name}  M={M}")
            lines.append(name)
            lines.append(f"        fcb   ${M:02X}")
            for lbl in labels:
                lines.append(f"        fdb   {lbl}")


# ── Construction du cœur fdb ─────────────────────────────────────────────────

def build_core_labels(core_chunks, J, pool: RoadPool) -> tuple:
    """Construit la séquence fdb du cœur. Chaque chunk = pattern PLEIN (ldd/ldx/pshu).

       L'héritage PSHU_LABEL (= un chunk identique au précédent réutilisait son D/X
       via un `pshu` nu) a été RETIRÉ : quand le clipping droit (coreOff) faisait du
       1er chunk dessiné une position héritée, D/X n'étaient jamais chargés → pixels
       parasites sur une banque (cf. artefact ligne 164). L'optim ne couvrait que
       ~1.1 % des chunks (75/6944) → gain négligeable, risque élevé. Les patterns
       pleins existent déjà dans le pool → coût mémoire ~nul. (J : non utilisé,
       conservé pour la signature.)

       Dédup en espace CANONIQUE : deux chunks fusionnent ssi leurs pixels source
       sont identiques — jamais parce qu'un mapping les rend identiques dans UNE
       seule bank (les deux banks émettent la même liste de routines)."""
    labels = []
    for chunk in core_chunks:
        labels.append(pool.register(chunk_load_ops(chunk)))
    return tuple(labels)


# ── Pass 1 : collecte des chunks par buffer logique ──────────────────────────

def collect_all_chunks(png: Path):
    """Renvoie list[ (line_idx, dict {(shift,plane): chunks canoniques} ) ]
       et la hauteur de l'image. `png` = le master (copie .work du source).

       Pipeline de padding en deux étapes :
       1. Pad LEFT : ajoute `start` px de grass à gauche du content naturel,
          alignant le bord gauche du content à PNG_x = 0 (= la position du
          bord gauche de la ligne la plus large).
       2. Pad RIGHT : ajoute juste ce qu'il faut pour que la longueur totale
          soit un multiple de CHUNK_SCREEN_PX_RAM (= 16 px).
       Couleur de pad = leftmost pixel de la ligne la plus large (= grass)."""
    if not png.exists():
        raise FileNotFoundError(f"PNG absent : {png}")
    _, height, pixels = read_png_indexed(png)

    # ── Pre-pass : trouve la ligne la plus large + couleur grass ────────────
    max_eff_w = 0
    max_start = 0
    max_y = -1
    for y in range(height):
        s, e, eff = measure_effective_width(pixels[y])
        if eff > max_eff_w:
            max_eff_w = eff
            max_start = s
            max_y = y
    if max_eff_w == 0:
        return [None] * height, height
    grass_pix = pixels[max_y][max_start]
    print(f"  Ligne la plus large : y={max_y}, eff_w={max_eff_w}, start={max_start}")
    print(f"  Couleur grass = palette index {grass_pix} "
          f"(pixel le plus à gauche de la ligne {max_y})")

    out = []
    n_padded_left = 0
    n_padded_right = 0
    for y in range(height):
        try:
            start, end, eff_w = measure_effective_width(pixels[y])
            if eff_w == 0 or eff_w < WINDOW_PX:
                out.append(None)
                continue
            # Pad LEFT : aligne le bord gauche du content au PNG_x = 0
            # en préfixant `start` px de grass.
            pad_left = start
            content_d = [grass_pix] * pad_left + list(pixels[y][start:end])
            # Pad RIGHT : complète à droite avec grass jusqu'au prochain
            # multiple de CHUNK_SCREEN_PX_RAM (= chunking BM16 OK).
            pad_right = (-len(content_d)) % CHUNK_SCREEN_PX_RAM
            content_d = content_d + [grass_pix] * pad_right
            if pad_left > 0:
                n_padded_left += 1
            if pad_right > 0:
                n_padded_right += 1
            entry = {}

            # ── Découpage cœur (K,M,J) INVARIANT au shift s0/s1 ──────────────
            # measure_grass_pixels mesuré PAR shift faisait diverger K/M/J entre
            # s0 et s1 : la rotation 1 px fait basculer un pixel de bord dans le
            # chunk voisin → un chunk passe cœur↔herbe → M différent. Au runtime,
            # LE est calculé avec le M du variant 0, mais le dispatch lit le M du
            # variant sélectionné (1,y) → mismatch → SAUT de 16 px (lignes du haut).
            #
            # Fix : on force le MÊME fenêtrage sur les 2 shifts = l'UNION des
            # cœurs : K=min(K_s0,K_s1), J=min(J_s0,J_s1) (extent le plus large,
            # couvre la route dans les 2 décalages). Le chunk en trop pour un
            # shift y est tout-herbe (inoffensif). Les PIXELS restent par shift
            # (core_d = chunks[K:K+M] sur le contenu tourné) → s1 affiche bien la
            # route 1 px à droite, mais dans les MÊMES chunks que s0.
            shift_content = {}
            K_shift = {}
            J_shift = {}
            for shift in (0, 1):
                if shift == 0:
                    sd = list(content_d)
                else:
                    # s1 = rotation droite 1 px en content = affichage 1 px à droite
                    sd = content_d[-1:] + content_d[:-1]
                shift_content[shift] = sd
                # K/J unifiés basés sur pixels de sd (= mêmes pour RAMA et RAMB).
                K_uni, J_uni = measure_grass_pixels(sd, grass_pix)

                # OPTIM #178 : Force K_uni = 5 quand naturel ≥ 5 (= stabilise K).
                # Sans ça, K oscille 5↔6 entre line_idx adjacents → entry_idx
                # change → road shift de 16 px visible. Appliqué PAR shift AVANT
                # l'union pour préserver la stabilisation existante.
                if K_uni > 5:
                    K_uni = 5
                K_shift[shift] = K_uni
                J_shift[shift] = J_uni

            # Union des extents → cœur commun aux 2 shifts (min = plus large).
            K_common = min(K_shift[0], K_shift[1])
            J_common = min(J_shift[0], J_shift[1])

            for shift in (0, 1):
                sd = shift_content[shift]
                entry[(shift, 'kj_uni')] = (K_common, J_common)
                rama, ramb = pixels_to_bm16(sd)
                entry[(shift, 'RAMA')] = plane_to_chunks(rama)
                entry[(shift, 'RAMB')] = plane_to_chunks(ramb)
            out.append(entry)
        except Exception as e:
            print(f"  ERR ligne {y}: {e}", file=sys.stderr)
            out.append(None)
    valid = sum(1 for e in out if e is not None)
    print(f"  Lignes valides : {valid}/{height}, "
          f"pad-LEFT sur {n_padded_left}, pad-RIGHT sur {n_padded_right}")
    return out, height


def detect_grass(all_entries):
    """Trouve la valeur de chunk (canonique) la plus fréquente en position 0."""
    counter = Counter()
    for entry in all_entries:
        if entry is None:
            continue
        for key, chunks in entry.items():
            if key[1] == 'kj_uni':
                continue
            if chunks:
                counter[chunks[0]] += 1
    if not counter:
        return None
    return counter.most_common(1)[0][0]


# ── Pass 2 : génération des buffers logiques ─────────────────────────────────

def process_entry(chunks, K_uni, J_uni,
                  pool: RoadPool, store: BufferStore) -> str:
    """Pour un buffer (un plan/shift d'une ligne) : utilise K/J unifiés
    (= calculés depuis les pixels, identiques RAMA/RAMB) pour garantir le
    sync visuel. Le cœur reste plane-spécifique."""
    K, J = K_uni, J_uni
    M = len(chunks) - K - J
    if M < 0:
        M = 0
    labels = build_core_labels(chunks[K:K + M], J, pool)
    pool.record_kmj(K, M, J)
    return store.register(M, labels)


def build_all(all_entries, pool: RoadPool, store: BufferStore):
    """Renvoie line_table : liste (par ligne) du dict {(shift,plane): buf_label}."""
    line_table = []
    for entry in all_entries:
        if entry is None:
            line_table.append(None)
            continue
        out = {}
        for key, chunks in entry.items():
            if key[1] == 'kj_uni':
                continue
            shift, plane = key
            K_uni, J_uni = entry[(shift, 'kj_uni')]
            out[key] = process_entry(chunks, K_uni, J_uni, pool, store)
        line_table.append(out)
    return line_table


# ── Émission asm ─────────────────────────────────────────────────────────────

def emit_buffers_asm(out_path: Path, store: BufferStore) -> None:
    lines = [
        " opt c",
        "; " + "=" * 72,
        "; Road RAM v4 — buffers fdb (header M + cœur)",
        f";   ORG ${BUFFERS_ORG:04X}. Pattern externs : {INC_PATTERNS_PATH}",
        "; Format buffer : fcb M ; fdb cœur[0]..cœur[M-1]  (K/J non lus au runtime)",
        "; Tient dans une bank 16 Ko ($4000..$7FFF par exemple).",
        "; " + "=" * 72,
        f'        INCLUDE "{INC_PATTERNS_PATH}"',
        f"        ORG   ${BUFFERS_ORG:04X}",
        "",
        "* " + "=" * 70,
        f"* {len(store.order)} buffers uniques (dédoublonnés sur M,cœur)",
        "* " + "=" * 70,
    ]
    store.emit(lines)
    write_asm(out_path, lines)


def emit_dispatch_data_asm(out_path: Path, variant_set, k_max=10, j_max=10) -> None:
    """Émet la portion data de Road_draw_dispatch ((k_max+1) × (j_max+1) fdb)
       pour inclusion dans le résident. Pour chaque (K', J') :
       - si présent dans variant_set : fdb Road_draw_K{K}_J{J}
       - sinon : fdb $0000 (skip sécurisé au runtime).
       Le wrapper engine/projection/RoadDrawDispatch.asm fournit le label
       Road_draw_dispatch.

       j_max = 10 : la window fait 10 chunks donc J' (= grass trailing) peut
       valoir 0..10. Avec j_max=6 (= valeur historique), les buffers avec
       window tombant entièrement dans le J grass (= K+M < entry_idx) auraient
       J'=10 réel mais clamp à 6 → F faussement > M → lecture hors cœur."""
    available = set(variant_set)
    nj = j_max + 1
    lines = [
        "* " + "=" * 70,
        f"* road_draw_dispatch.asm — DATA UNIQUEMENT ({k_max+1}x{nj} fdb), AUTO-GÉNÉRÉ",
        "* Inclus par engine/projection/RoadDrawDispatch.asm qui fournit le label",
        "* Road_draw_dispatch. NE PAS éditer à la main.",
        f"* Index (K' x {nj} + J') x 2.  $0000 = combinaison non utilisée (skip).",
        "* " + "=" * 70,
    ]
    for K in range(k_max + 1):
        entries = []
        for J in range(nj):
            if (K, J) in available:
                entries.append(f"Road_draw_K{K}_J{J}")
            else:
                entries.append("$0000")
        lines.append(f"* K={K}")
        # Émis en 2 lignes fdb pour lisibilité (= 1ère moitié + 2ème moitié)
        half = (nj + 1) // 2
        lines.append(f"        fdb   {','.join(entries[:half])}")
        lines.append(f"        fdb   {','.join(entries[half:])}")
    write_asm(out_path, lines)


def emit_lines_table_data_asm(out_path: Path, line_table) -> None:
    """Émet la portion data (fdb only) de Road_lines pour inclusion dans le résident.
       Le wrapper engine/projection/RoadLinesTable.asm fournit le label Road_lines
       et les INCLUDE externs avant cet INCLUDE."""
    lines = [
        "* " + "=" * 70,
        "* road_lines_table.asm — DATA UNIQUEMENT (fdb), AUTO-GÉNÉRÉ",
        "* Inclus par engine/projection/RoadLinesTable.asm qui fournit le label",
        "* Road_lines et les INCLUDE externs. NE PAS éditer à la main.",
        "* Layout par ligne : fdb RAMA_s0, RAMA_s1, RAMB_s0, RAMB_s1",
        "* " + "=" * 70,
    ]
    for line_idx, entry in enumerate(line_table):
        if entry is None:
            lines.append(f"        fdb   $0000,$0000,$0000,$0000   ; ligne {line_idx:03d}")
        else:
            r0 = entry[(0, 'RAMA')]
            r1 = entry[(1, 'RAMA')]
            b0 = entry[(0, 'RAMB')]
            b1 = entry[(1, 'RAMB')]
            lines.append(f"        fdb   {r0},{r1},{b0},{b1}   ; ligne {line_idx:03d}")
    write_asm(out_path, lines)


def emit_patterns_asm(out_path: Path, pool: RoadPool, variant_set, palette: str):
    lines = [
        " opt c",
        "; " + "=" * 72,
        f"; Road RAM v4 — pattern bank {palette} @ ${PATTERNS_ORG:04X}",
        "; Structure identique dark/light, valeurs uniquement diffèrent.",
        "; " + "=" * 72,
    ]
    pool.emit(lines, variant_set, palette)
    write_asm(out_path, lines)


# ── Externs + map ────────────────────────────────────────────────────────────

MAP_RX = re.compile(r'Symbol:\s+(\S+)\s+\([^)]*\)\s*=\s*([0-9A-Fa-f]+)')


def parse_map(map_path: Path) -> dict[str, int]:
    syms = {}
    for line in map_path.read_text().splitlines():
        m = MAP_RX.match(line)
        if m:
            syms[m.group(1)] = int(m.group(2), 16)
    return syms


PATTERN_PREFIXES = ('Road_R', 'Road_draw_')
PATTERN_EXACT = {PSHU_LABEL}
BUFFER_PREFIX  = ('Line_',)


def write_pattern_externs(syms: dict[str, int], out_path: Path) -> int:
    lines = [
        "* " + "=" * 70,
        f"* {out_path.name} — généré, ne pas éditer",
        "* Adresses pattern bank (swappable dark/light) :",
        "*   Road_pshu_dx, Road_R*, Road_draw_KX_JY",
        "* " + "=" * 70,
    ]
    keep = [(n, a) for n, a in syms.items()
            if n in PATTERN_EXACT or n.startswith(PATTERN_PREFIXES)]
    keep.sort(key=lambda r: r[1])
    for name, addr in keep:
        lines.append(f"{name:<20} equ   ${addr:04X}")
    write_asm(out_path, lines)
    return len(keep)


def write_buffer_externs(syms: dict[str, int], out_path: Path) -> int:
    lines = [
        "* " + "=" * 70,
        f"* {out_path.name} — généré, ne pas éditer",
        "* Adresses des buffers Line_NNNN (zone $0000-$3FFF).",
        "* " + "=" * 70,
    ]
    keep = [(n, a) for n, a in syms.items() if n.startswith(BUFFER_PREFIX)]
    keep.sort(key=lambda r: r[1])
    for name, addr in keep:
        lines.append(f"{name:<14} equ   ${addr:04X}")
    write_asm(out_path, lines)
    return len(keep)


def compare_pattern_maps(dark_map, light_map) -> list[str]:
    diffs = []
    names = {n for n in (set(dark_map) | set(light_map))
             if n in PATTERN_EXACT or n.startswith(PATTERN_PREFIXES)}
    for name in sorted(names):
        d = dark_map.get(name)
        l = light_map.get(name)
        if d != l:
            if d is not None and l is not None:
                diffs.append(f"  {name}: dark=${d:04X} light=${l:04X}")
            else:
                diffs.append(f"  {name}: dark={d} light={l}")
    return diffs


# ── Stats ────────────────────────────────────────────────────────────────────

def print_stats(pool, store, line_table, variant_set):
    n_routines = len(pool.label_map)
    n_buffers = len(store.map)
    total_chunks = sum(len(k[1]) for k in store.order)
    pshu_chunks = sum(1 for k in store.order for lbl in k[1] if lbl == PSHU_LABEL)
    R_chunks = total_chunks - pshu_chunks
    n_lines = sum(1 for e in line_table if e is not None)
    headers_bytes = n_buffers * 1            # header réduit à 1 oct (M seul)
    cœur_bytes = total_chunks * 2
    table_bytes = len(line_table) * 8
    variants_bytes = sum(
        6 + 2*K + 2*(WINDOW_CHUNKS - K - J) + (6 if J > 0 else 0) + 2*J + 1
        for K, J in variant_set
    )
    # 6 = 2 * (ldd + ldx) = 6, +2 par pshu, +2 par jsr, +6 si recharge avant J, +1 rts
    # approx
    print(f"  routines pattern uniques : {n_routines}")
    print(f"  buffers fdb uniques      : {n_buffers}")
    print(f"  variants draw uniques    : {len(variant_set)}")
    print(f"  herbe : D=${pool.grass_ops['dark'][0][1]:04X} "
          f"X=${pool.grass_ops['dark'][1][1]:04X}  "
          f"(light D=${pool.grass_ops['light'][0][1]:04X} "
          f"X=${pool.grass_ops['light'][1][1]:04X})")
    print(f"  total chunks (cœurs)     : {total_chunks}")
    print(f"    dont rechargeants      : {R_chunks}")
    print(f"    dont {PSHU_LABEL:<14}   : {pshu_chunks}")
    print(f"  lignes valides           : {n_lines}/{len(line_table)}")
    print(f"  estim tailles :")
    print(f"    headers buffers : {headers_bytes} o")
    print(f"    cœurs fdb       : {cœur_bytes} o")
    print(f"    Road_lines      : {table_bytes} o")
    routines_bytes = n_routines * 9 + 3   # +3 = Road_pshu_dx
    print(f"    patterns ld    : ~{routines_bytes} o (×2 banks)")
    print(f"    draw variants  : ~{variants_bytes} o (×2 banks)")
    print(f"    total estimé   : ~{headers_bytes+cœur_bytes+table_bytes + 2*(routines_bytes+variants_bytes)} o")


# ── Pipeline lwasm ───────────────────────────────────────────────────────────

def lwasm_run(lwasm, asm_path, bin_path, *, include_dir):
    import subprocess
    # Note : on ajoute -I. (= cwd = project root) en plus de -I{include_dir}
    # pour que les INCLUDE de la forme "./game-mode/road/generated/xxx.inc"
    # embarqués dans les .asm intermédiaires soient résolus.
    # Sinon lwasm les cherche depuis le dossier du .asm source et échoue.
    cmd = [
        str(lwasm),
        '-I.', f'-I{include_dir}', '-f', 'raw',
        '-o', str(bin_path),
        f'--map={bin_path.with_suffix(".map")}',
        f'--list={bin_path.with_suffix(".lst")}',
        str(asm_path),
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    return r.returncode, r.stderr


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument('input', type=Path, nargs='?')
    p.add_argument('-o', '--output', type=Path)
    p.add_argument('--batch', action='store_true')
    p.add_argument('--no-asm', action='store_true')
    p.add_argument('--index-map', type=Path, default=None,
                   help=f"mapping index→nibbles TO8 (défaut : "
                        f"<src_dir>/{INDEX_MAP_DEFAULT})")
    args = p.parse_args(argv[1:])

    if not args.batch or args.input is None:
        p.print_help()
        return 1

    src_dir = args.input
    project_root = Path.cwd()
    work_dir = project_root / WORK_DIR_REL
    game_gen = project_root / GAME_GENERATED_REL
    obj_gen  = project_root / OBJ_GENERATED_REL
    for d in (work_dir, game_gen, obj_gen):
        d.mkdir(parents=True, exist_ok=True)

    map_path = args.index_map or (src_dir / INDEX_MAP_DEFAULT)
    print(f"── Mapping couleur : {map_path} ──")
    nib_maps, roles = load_index_map(map_path)

    print("── Master + previews ──")
    master = prepare_master_and_previews(src_dir, work_dir,
                                         nib_maps, roles, map_path)

    print("── Pass 1 : lecture master.png + chunking ──")
    all_entries, height = collect_all_chunks(master)

    print("── Détection de l'herbe ──")
    grass = detect_grass(all_entries)
    if grass is None:
        print("  ERR : aucune ligne valide", file=sys.stderr)
        return 1
    print(f"  herbe (canonique) = bytes {tuple(f'${b:02X}' for b in grass)}")

    print("── Pass 2 : extraction prélude/épilogue + build cœurs ──")
    pool = RoadPool(nib_maps)
    pool.set_grass(grass)
    store = BufferStore()
    line_table = build_all(all_entries, pool, store)

    print("── Collecte des variants (K', J') ──")
    variant_set = pool.collect_variants()
    print(f"  {len(variant_set)} couples (K', J') distincts requis")

    print_stats(pool, store, line_table, variant_set)

    print(f"\n── Émission .asm intermédiaires dans {WORK_DIR_REL}/ ──")
    p_buf = work_dir / ASM_BUFFERS
    p_pd  = work_dir / ASM_PATTERNS_DARK
    p_pl  = work_dir / ASM_PATTERNS_LIGHT
    emit_buffers_asm(p_buf, store)
    emit_patterns_asm(p_pd, pool, variant_set, 'dark')
    emit_patterns_asm(p_pl, pool, variant_set, 'light')
    print(f"  → {p_buf.name}, {p_pd.name}, {p_pl.name}")

    print(f"\n── Émission data-only ASM dans {GAME_GENERATED_REL}/ ──")
    p_lt_final = game_gen / ASM_LINES_TABLE
    emit_lines_table_data_asm(p_lt_final, line_table)
    print(f"  → {p_lt_final.relative_to(project_root)}")

    p_disp_final = game_gen / ASM_DISPATCH
    emit_dispatch_data_asm(p_disp_final, variant_set)
    print(f"  → {p_disp_final.relative_to(project_root)}")

    if args.no_asm:
        return 0

    lwasm = Path(__file__).resolve().parents[3] / "tools" / "macos" / "lwasm"
    if not lwasm.exists():
        print("⚠ lwasm introuvable, skip assemble", file=sys.stderr)
        return 0

    print("\n── Pipeline d'assemblage ──")

    # 1. patterns dark → externs patterns (écrits directement dans game-mode/generated/)
    pd_bin = p_pd.with_suffix('.bin')
    rc, err = lwasm_run(lwasm, p_pd, pd_bin, include_dir=work_dir)
    if rc != 0:
        print(f"  ✗ {p_pd.name}:\n{err}", file=sys.stderr)
        return 2
    sz_pd = pd_bin.stat().st_size
    print(f"  ✓ {pd_bin.name}: {sz_pd:,} o")

    dark_syms = parse_map(pd_bin.with_suffix('.map'))
    inc_pat_final = game_gen / INC_PATTERNS
    n_inc_p = write_pattern_externs(dark_syms, inc_pat_final)
    print(f"  ✓ {inc_pat_final.relative_to(project_root)}: {n_inc_p} EQU")

    # 2. buffers → externs buffers (Line_NNNN)
    pb_bin = p_buf.with_suffix('.bin')
    rc, err = lwasm_run(lwasm, p_buf, pb_bin, include_dir=work_dir)
    if rc != 0:
        print(f"  ✗ {p_buf.name}:\n{err}", file=sys.stderr)
        return 2
    sz_pb = pb_bin.stat().st_size
    print(f"  ✓ {pb_bin.name}: {sz_pb:,} o ({sz_pb/1024:.1f} Ko)")
    if sz_pb > 16 * 1024:
        print(f"  ✗ buffers > 16 Ko ({sz_pb}) — ne tient pas dans une bank",
              file=sys.stderr)
        return 4

    buf_syms = parse_map(pb_bin.with_suffix('.map'))
    inc_buf_final = game_gen / INC_BUFFERS
    n_inc_b = write_buffer_externs(buf_syms, inc_buf_final)
    print(f"  ✓ {inc_buf_final.relative_to(project_root)}: {n_inc_b} EQU")

    # 3. patterns light + check cohérence dark↔light
    pl_bin = p_pl.with_suffix('.bin')
    rc, err = lwasm_run(lwasm, p_pl, pl_bin, include_dir=work_dir)
    if rc != 0:
        print(f"  ✗ {p_pl.name}:\n{err}", file=sys.stderr)
        return 2
    sz_pl = pl_bin.stat().st_size
    print(f"  ✓ {pl_bin.name}: {sz_pl:,} o")

    light_syms = parse_map(pl_bin.with_suffix('.map'))
    diffs = compare_pattern_maps(dark_syms, light_syms)
    if diffs:
        print("  ✗ DISCORDANCE d'adresses entre dark et light :", file=sys.stderr)
        for d in diffs[:20]:
            print(d, file=sys.stderr)
        return 3
    if sz_pd != sz_pl:
        print(f"  ✗ Tailles différentes : dark={sz_pd}, light={sz_pl}", file=sys.stderr)
        return 3
    print(f"  ✓ Cohérence dark↔light vérifiée ({sz_pd} o chacun)")

    # 4. Publication des .bin aux destinations finales game-level
    print("\n── Publication binaires (game-mode/generated/ + objects/generated/) ──")
    pd_dst = game_gen / 'road_patterns_dark.bin'
    pl_dst = game_gen / 'road_patterns_light.bin'
    pb_dst = obj_gen / 'road_buffers.bin'
    shutil.copy2(pd_bin, pd_dst)
    shutil.copy2(pl_bin, pl_dst)
    shutil.copy2(pb_bin, pb_dst)
    print(f"  ✓ {pd_dst.relative_to(project_root)}")
    print(f"  ✓ {pl_dst.relative_to(project_root)}")
    print(f"  ✓ {pb_dst.relative_to(project_root)}")
    sz_lt = p_lt_final.stat().st_size

    total = 2*sz_pd + sz_pb + sz_lt
    print(f"\n  Tailles :")
    print(f"    bank patterns (×2)   : {sz_pd:,} o chacune (swap dark/light)")
    print(f"    bank buffers         : {sz_pb:,} o ({sz_pb/1024:.1f} Ko, < 16 Ko ✓)")
    print(f"    table Road_lines     : {sz_lt:,} o (en main.asm)")
    print(f"    total occupation     : {total:,} o ({total/1024:.1f} Ko)")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
