#!/usr/bin/env python3
"""
Circuit Editor — backend FastAPI (Phase 0-2).

Pont HTTP au-dessus du pipeline Python EXISTANT (source de vérité). L'éditeur ne
réimplémente RIEN : il appelle road_bake / simulate_dfr_pipeline via ces endpoints.

Phase 2 : modèle de segments MUTABLE en mémoire (par circuit). Les PATCH modifient
les deltas/flags ; /render et /shape reflètent l'édition immédiatement.

Lancer (depuis game-projects/road-generator) :
  .venv/bin/python3 tools/circuit-editor/backend/app.py        # -> :8765

Endpoints :
  GET   /circuits                       -> liste
  GET   /circuit/{cid}                  -> meta
  GET   /shape/{cid}                    -> deltas par segment (intégrables)
  GET   /segment/{cid}/{seg}            -> données segment
  PATCH /segment/{cid}/{seg}            -> modifie delta_curve/pitch/flags (clamp int8)
  POST  /reset/{cid}                    -> recharge depuis le .asm disque
  GET   /render?circuit&pos&steer&v     -> PNG (vraie frame) ; v = cache-buster
  GET   /palette/to8                    -> niveaux TO8 (EF9369)
"""
import sys, io, re, json, zipfile, tempfile, math as _math, random as _rng
from pathlib import Path
from functools import lru_cache
from typing import Optional

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools"))
import road_bake as rb
from simulate_dfr_pipeline import parse_circuit

from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="Lotus Circuit Editor backend")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

TO8_LEVELS = [0, 97, 122, 143, 158, 171, 184, 194, 204, 212, 219, 227, 235, 242, 250, 255]
SUBPOS = rb.SUBPOS_PER_SEG
# assets locaux à l'éditeur (indépendants des originaux du jeu)
TEX_DIR = Path(__file__).resolve().parent.parent / "assets"          # textures (cf prepare_textures.py)
CIRCUITS_DIR = Path(__file__).resolve().parent.parent / "circuits"   # NATIF (lecture seule, cf prepare_circuits.py)
SAVED_DIR = Path(__file__).resolve().parent.parent / "saved"         # ÉDITÉ persisté (JSON)
SAVED_DIR.mkdir(parents=True, exist_ok=True)


def _native_circuits() -> list[str]:
    return sorted(p.stem for p in CIRCUITS_DIR.glob("*.asm"))


def _saved_path(cid: str) -> Path:
    return SAVED_DIR / f"{cid}.json"


def _saved_circuits() -> list[str]:
    return sorted(p.stem for p in SAVED_DIR.glob("*.json"))


def _has_native(cid: str) -> bool:
    return (CIRCUITS_DIR / f"{cid}.asm").exists()


def _write_saved(cid: str):
    segs, nb = STATE[cid]["segs"], STATE[cid]["nb"]
    _saved_path(cid).write_text(json.dumps({"nb": nb, "segs": segs}))


def _local_nb(cid: str):
    asm = (CIRCUITS_DIR / f"{cid}.asm").read_text()
    m = re.search(rf'Circuit_{cid}_nb_segments\s*\n?\s*fdb\s+(\d+)', asm)
    return int(m.group(1)) if m else None

# --- modèle MUTABLE par circuit (segments éditables) ---
STATE: dict[str, dict] = {}   # cache de session (copie de travail mutable)


@lru_cache(maxsize=1)
def assets():
    return rb.load_assets()


def track(cid: str):
    """Charge (1×) les segments en mémoire. Priorité : SAUVEGARDE éditée > NATIF."""
    st = STATE.get(cid)
    if st is None:
        sp = _saved_path(cid)
        if sp.exists():                                  # version éditée persistée
            d = json.loads(sp.read_text())
            st = STATE[cid] = {"segs": [list(s) for s in d["segs"]], "nb": d["nb"]}
        else:                                            # natif (lecture seule)
            path = CIRCUITS_DIR / f"{cid}.asm"
            if not path.exists():
                raise HTTPException(404, f"circuit inconnu: {cid}")
            segs = [list(t) for t in parse_circuit(path, cid)]
            st = STATE[cid] = {"segs": segs, "nb": _local_nb(cid)}
    return st["segs"], st["nb"]


class SegPatch(BaseModel):
    delta_curve: Optional[int] = None
    delta_pitch: Optional[int] = None
    pit: Optional[bool] = None
    start: Optional[bool] = None


def clamp8(v: int) -> int:
    return max(-128, min(127, int(v)))


def _all_circuits():
    return sorted(set(_native_circuits()) | set(_saved_circuits()))


@app.get("/circuits")
def circuits():
    # 'saved' = circuits ayant une version éditée persistée ; 'custom' = sans natif
    saved = set(_saved_circuits())
    native = set(_native_circuits())
    return {"circuits": _all_circuits(), "saved": sorted(saved),
            "custom": sorted(saved - native)}


@app.post("/circuit/new")
def new_circuit(name: str = "", nb_segs: int = 64):
    """Crée un circuit vierge (données À PART, auto-sauvé). Jamais le natif."""
    if not name:
        i = 1
        while f"circuit_{i:02d}" in _all_circuits():
            i += 1
        name = f"circuit_{i:02d}"
    if name in _all_circuits():
        raise HTTPException(409, f"circuit '{name}' existe déjà")
    segs = [[0, 0, False, False] for _ in range(nb_segs)]
    segs[0][3] = True                 # START au segment 0
    STATE[name] = {"segs": segs, "nb": nb_segs}
    _write_saved(name)                # persiste tout de suite (données à part)
    return {"id": name, "nb_segments": nb_segs, "created": True}


@app.get("/circuit/{cid}")
def circuit_meta(cid: str):
    _, nb = track(cid)
    return {"id": cid, "nb_segments": nb, "nb_subpos": nb * SUBPOS, "subpos_per_seg": SUBPOS}


@app.get("/shape/{cid}")
def shape(cid: str):
    segs, nb = track(cid)
    return {
        "n": nb,
        "delta_curve": [segs[i][0] for i in range(nb)],
        "delta_pitch": [segs[i][1] for i in range(nb)],
        "flags": [{"pit": bool(segs[i][2]), "start": bool(segs[i][3])} for i in range(nb)],
    }


def _seg_json(cid, segs, nb, i):
    dc, dp, pit, start = segs[i]
    _dense, min_y = rb.project_pos(segs, nb, i * SUBPOS, assets())
    return {"circuit": cid, "segment": i, "delta_curve": dc, "delta_pitch": dp,
            "flags": {"pit": bool(pit), "start": bool(start)}, "min_y": min_y}


@app.get("/segment/{cid}/{seg}")
def get_segment(cid: str, seg: int):
    segs, nb = track(cid)
    if not (0 <= seg < nb):
        raise HTTPException(404, "segment hors plage")
    return _seg_json(cid, segs, nb, seg)


@app.patch("/segment/{cid}/{seg}")
def patch_segment(cid: str, seg: int, p: SegPatch):
    segs, nb = track(cid)
    if not (0 <= seg < nb):
        raise HTTPException(404, "segment hors plage")
    s = segs[seg]
    if p.delta_curve is not None:
        s[0] = clamp8(p.delta_curve)
    if p.delta_pitch is not None:
        s[1] = clamp8(p.delta_pitch)
    if p.pit is not None:
        s[2] = bool(p.pit)
    if p.start is not None:
        s[3] = bool(p.start)
    return _seg_json(cid, segs, nb, seg)


@app.patch("/circuit/{cid}/resize")
def resize_circuit(cid: str, nb_segs: int):
    """Redimensionne le circuit. Segments existants préservés.
    Agrandissement : ajoute des segments zéro en fin.
    Réduction   : diminue nb (segments masqués, retrouvés si on regrandit).
    """
    segs, nb = track(cid)
    nb_segs = max(1, min(200, int(nb_segs)))
    if nb_segs > len(segs):
        for _ in range(nb_segs - len(segs)):
            segs.append([0, 0, False, False])
    STATE[cid]["nb"] = nb_segs
    return {"id": cid, "nb_segments": nb_segs,
            "nb_subpos": nb_segs * SUBPOS}


@app.post("/save/{cid}")
def save(cid: str):
    """Persiste les édits courants dans saved/{cid}.json (jamais le natif)."""
    track(cid)                # s'assure que STATE[cid] existe
    _write_saved(cid)
    return {"ok": True, "circuit": cid, "saved": True}


@app.post("/reset/{cid}")
def reset(cid: str):
    """Revient au NATIF : supprime la sauvegarde éditée + recharge la copie disque.
    Circuit custom (sans natif) -> remis à blanc (mêmes nb) et re-sauvé."""
    has_native = _has_native(cid)
    nb_custom = STATE[cid]["nb"] if cid in STATE else 64
    sp = _saved_path(cid)
    if sp.exists():
        sp.unlink()
    STATE.pop(cid, None)
    if has_native:
        track(cid)                                   # recharge le natif
    else:
        segs = [[0, 0, False, False] for _ in range(nb_custom)]
        segs[0][3] = True
        STATE[cid] = {"segs": segs, "nb": nb_custom}
        _write_saved(cid)                            # custom -> reste un circuit (blanc)
    return {"ok": True, "circuit": cid, "native": has_native}


def _nearest_level(v: int) -> int:
    return min(range(16), key=lambda i: abs(TO8_LEVELS[i] - v))


# Palette de DÉFAUT 16 couleurs (level-triples [R4,G4,B4], "index 1..16") :
#  - 1..7 = palette native des textures (idx 1..7 : rumble, blanc, herbes, gris...)
#  - 8..16 = spectre utilitaire (éditable, non utilisé par la route)
_DEFAULT_PAL: list[list[int]] | None = None
def _default_palette():
    global _DEFAULT_PAL
    if _DEFAULT_PAL is not None:
        return _DEFAULT_PAL
    from PIL import Image as _Im
    im = _Im.open(TEX_DIR / 'normal_dark.png')
    pal = im.getpalette()
    out: list[list[int]] = []
    for idx in range(1, 8):   # idx texture 1..7 -> palette "1..7"
        r, g, b = pal[idx*3], pal[idx*3+1], pal[idx*3+2]
        out.append([_nearest_level(r), _nearest_level(g), _nearest_level(b)])
    # 8..16 : spectre par défaut
    spectrum = [[0,0,0],[0,5,12],[9,12,15],[0,12,11],[14,13,4],[13,8,2],[9,3,11],[6,4,2],[8,8,8]]
    out += spectrum
    _DEFAULT_PAL = out[:16]
    return _DEFAULT_PAL


@app.get("/palette/default")
def palette_default():
    """Palette 16 couleurs (level-triples) par défaut. index 0 = transparent (non listé)."""
    return {"levels": _default_palette(), "to8": TO8_LEVELS}


def _parse_palette(pal: str) -> list[tuple[int, int, int]] | None:
    """'l,l,l,...' (48 entiers = 16 niveaux R,G,B) -> 16 RGB. None si invalide."""
    if not pal:
        return None
    try:
        flat = [int(x) for x in pal.split(',')]
        return [(TO8_LEVELS[flat[i*3]], TO8_LEVELS[flat[i*3+1]], TO8_LEVELS[flat[i*3+2]])
                for i in range(len(flat) // 3)]
    except Exception:
        return None


@app.get("/render")
def render(circuit: str, pos: int = 0, steer: int = 0, v: int = 0, pal: str = "", bg: str = ""):
    segs, nb = track(circuit)
    pos %= nb * SUBPOS
    dense, _min_y = rb.project_pos(segs, nb, pos, assets())
    palette = _parse_palette(pal)         # 16 RGB, rendu par INDEX (idx texture -> palette[idx-1])
    bg_rgb = (60, 130, 60)
    if bg:
        try:
            bg_rgb = tuple(int(x) for x in bg.split(','))[:3]
        except Exception:
            pass
    img = rb.render(dense, steer=steer, phase=(pos * 256) & 0x7FF,
                    full_line=True, bg_color=bg_rgb, tex_dir=TEX_DIR, palette=palette)
    buf = io.BytesIO(); img.save(buf, "PNG")
    return Response(content=buf.getvalue(), media_type="image/png",
                    headers={"Cache-Control": "no-store"})


@app.get("/geometry/{cid}")
def geometry(cid: str):
    """Géométrie FIDÈLE pour plan + ruban, via la récurrence du moteur :
       D0 += delta_curve  (courbure)        -> cap(heading) ∝ D0
       D1 += -2*delta_pitch (pente)         -> D3 += D1 -> élévation ∝ D3
    Intégrée per-substep (16/segment, comme SP). Échelle normalisée (le moteur
    n'a pas de carte monde : on préserve sens des virages + angles relatifs)."""
    import math
    segs, nb = track(cid)
    SUB = SUBPOS
    # 1) accumulateurs moteur, per-substep
    D0 = 0.0; D1 = 0.0; D3 = 0.0
    head_raw = []   # D0 (∝ heading)
    elev_raw = []   # D3 (∝ élévation)
    for i in range(nb):
        dc, dp = segs[i][0], segs[i][1]
        for _ in range(SUB):
            D0 += dc
            D1 += -2 * dp
            D3 += D1
            head_raw.append(D0)
            elev_raw.append(D3)
    n = len(head_raw)
    rms = lambda a: (sum(v * v for v in a) / len(a)) ** 0.5 if a else 0.0
    # 2) calibration cap : 1 tour complet (2π) — circuits Lotus = boucle simple.
    D0_final = head_raw[-1] if head_raw else 0.0
    KH = (2 * math.pi / D0_final) if abs(D0_final) > 1e-6 else (0.55 / rms(head_raw)) if rms(head_raw) > 1e-9 else 0.0
    # 3) ALTITUDE = double-cumsum(delta_pitch) — vérifié contre D3 du moteur (la
    #    position verticale écran de SP vient de D3 = cumsum(cumsum(-2·delta_pitch))).
    #    delta_pitch = "taux de pente" (analogue vertical de delta_curve) :
    #      pente   = cumsum(delta_pitch)         (= D1, analogue du cap)
    #      altitude = cumsum(pente) = double-cumsum (= D3, analogue de la position latérale)
    #    Signe + : dp>0 = montée -> altitude croît -> Z>0 = au-dessus. (single cumsum
    #    donnerait la PENTE, pas l'altitude -> non représentatif des collines vues.)
    slope = 0.0; H = 0.0; heights = []
    for i in range(nb):
        slope += segs[i][1]
        H += slope
        heights.append(H)
    hmax = max((abs(v) for v in heights), default=1.0) or 1.0
    # 4) position plan (intègre la direction), 1 point/segment
    x = y = 0.0
    px, py, pz, ph = [], [], [], []
    for s in range(n):
        ang = head_raw[s] * KH
        x += math.sin(ang); y += math.cos(ang)
        if s % SUB == 0:
            i = (s // SUB) % nb
            px.append(round(x, 3)); py.append(round(y, 3))
            pz.append(round(heights[i] / hmax, 4)); ph.append(round(ang, 4))
    return {"n": nb, "x": px, "y": py, "z": pz, "heading": ph}


@app.get("/palette/to8")
def palette_to8():
    return {"levels": TO8_LEVELS, "channels": 3, "colors": 16 ** 3}


# ── A1 — Proportional Edit ───────────────────────────────────────────────────
def _smooth_w(d: int, radius: int) -> float:
    t = max(0.0, 1.0 - d / max(1, radius + 1))
    return 0.5 - 0.5 * _math.cos(_math.pi * t)   # falloff smooth (cosinus)


@app.patch("/circuit/{cid}/prop")
def prop_edit(cid: str, seg: int, field: str, value: int,
              radius: int = 4, strength: float = 1.0):
    """Édition proportionnelle À SOMME NULLE sur la fenêtre (impact LOCAL).
    radius = portée, strength = amplitude voisins. Le bump brut (centre = delta,
    voisins = delta·smooth·force) est recentré pour que Σ = 0 sur la fenêtre :
    -> le cap (courbure) et l'altitude+pente (tangage, fenêtre symétrique) REVIENNENT
    après la fenêtre. L'impact ne déborde plus le rayon, et la fermeture de boucle
    (Σdelta_curve) est préservée."""
    segs, nb = track(cid)
    if not (0 <= seg < nb):
        raise HTTPException(404, "segment hors plage")
    fi = 0 if field == "curve" else 1
    delta = clamp8(value) - segs[seg][fi]
    if delta == 0:
        return shape(cid)
    strength = max(0.0, min(2.0, strength))

    # fenêtre circulaire + amplitudes brutes (centre plein, voisins atténués × force)
    win = []   # (i, dist)
    for i in range(nb):
        dist = min(abs(i - seg), nb - abs(i - seg))
        if dist <= radius:
            win.append((i, dist))
    raw = [delta * (1.0 if d == 0 else _smooth_w(d, radius) * strength) for (_, d) in win]
    M = len(raw)
    mean = sum(raw) / M if M else 0.0          # somme nulle -> impact local + boucle préservée
    for (i, _d), r in zip(win, raw):
        segs[i][fi] = clamp8(segs[i][fi] + round(r - mean))

    return shape(cid)   # shape complet = frontend recharge tout


# ── B1/B3 — Générateur de circuits ───────────────────────────────────────────
def _build_sections(profile, nb, rng, turns, elev):
    """Retourne [(length, dc, dp), ...] dont la somme des longueurs = nb."""
    secs = []

    if profile == "oval":
        q = max(2, nb // 4)
        arc_dc = max(-6, round(-128 / max(1, 2 * (nb - 2 * q))))
        secs = [(q, 0, 0), (nb // 2 - q, arc_dc, 0),
                (q, 0, 0), (nb - nb // 2 - q, arc_dc, 0)]

    elif profile == "technique":
        i = 0
        while i < nb:
            L = rng.randint(3, max(3, nb // 10))
            t = rng.choices(["L", "R", "S"], weights=[5, 3, 2])[0]
            dc = round(rng.uniform(2, 6) * turns) * (-1 if t == "L" else 1 if t == "R" else 0)
            dp = round(rng.gauss(0, 1.5) * elev)
            secs.append((min(L, nb - i), dc, dp))
            i += L

    elif profile == "flowing":
        block = max(6, nb // 6)
        for start in range(0, nb, block):
            L = min(block + rng.randint(-2, 2), nb - start)
            dc = round(rng.gauss(0, 2.5) * turns)
            dp = round(rng.gauss(0, 1.0) * elev)
            secs.append((max(1, L), dc, dp))

    elif profile == "street":
        i = 0
        while i < nb:
            # straight then sharp turn
            sl = rng.randint(4, max(4, nb // 8))
            tl = rng.randint(2, 5)
            dc = rng.choice([-6, -5, 5, 6])
            dc = round(dc * turns)
            secs.append((min(sl, nb - i), 0, round(rng.gauss(0, .5) * elev)))
            i += sl
            if i < nb:
                secs.append((min(tl, nb - i), dc, 0))
                i += tl

    elif profile in ("montagne", "hillclimb"):
        # mostly gently curved with strong elevation
        block = max(4, nb // 8)
        for start in range(0, nb, block):
            L = min(block + rng.randint(-1, 1), nb - start)
            dc = round(rng.gauss(0, 1.5) * turns)
            dp = round(rng.gauss(0, 3.0) * elev)
            secs.append((max(1, L), dc, dp))

    else:  # fallback straight
        secs = [(nb, 0, 0)]

    return secs


def _apply_sections(segs, nb, secs):
    i = 0
    for L, dc, dp in secs:
        for j in range(L):
            if i < nb:
                segs[i][0] = clamp8(dc)
                segs[i][1] = clamp8(dp)
                i += 1


def _enforce_closure(segs, nb):
    """Ajuste les dc pour que Σ(dc[i]) = -128 (une boucle complète)."""
    target = -128
    for _ in range(nb * 6):   # plusieurs passes jusqu'à convergence
        total = sum(segs[i][0] for i in range(nb))
        diff = target - total
        if diff == 0:
            break
        step = 1 if diff > 0 else -1
        # trouve un segment qui peut absorber le step
        for i in range(nb):
            new_v = segs[i][0] + step
            if -6 <= new_v <= 6:
                segs[i][0] = new_v
                break


@app.post("/circuit/{cid}/generate")
def generate_circuit(cid: str, profile: str = "oval", seed: int = 42,
                     turns: float = 0.6, elev: float = 0.5):
    """Génère un circuit selon le profil + graine. Respecte la contrainte de fermeture."""
    segs, nb = track(cid)
    rng = _rng.Random(seed)

    # reset
    for i in range(nb):
        segs[i] = [0, 0, False, i == 0]

    secs = _build_sections(profile, nb, rng, turns, elev)
    _apply_sections(segs, nb, secs)
    _enforce_closure(segs, nb)

    return {"id": cid, "nb_segments": nb, "generated": True,
            "closure_check": sum(segs[i][0] for i in range(nb))}


# ── EXPORT ───────────────────────────────────────────────────────────────────
def _cache_yaw_pitch(segs, nb):
    """yaw/pitch cumulés (& 0xFF) par segment, étendus aux 8 wraparound."""
    yaw, pit = [], []
    ya = pa = 0
    for j in range(nb + 8):
        yaw.append(ya & 0xFF); pit.append(pa & 0xFF)
        s = segs[j % nb]
        ya += s[0]; pa += s[1]
    return yaw, pit


def _native_asm(cid, segs, nb):
    """Régénère le .asm natif Lotus. Si circuit natif (même nb) : patch du texte
    original (préserve sprites/LUT, recalcule cache). Sinon : émission minimale."""
    path = CIRCUITS_DIR / f"{cid}.asm"
    if not (path.exists() and _local_nb(cid) == nb):
        return _native_asm_minimal(cid, segs, nb)
    yaw, pit = _cache_yaw_pitch(segs, nb)
    seg_re = re.compile(r'^(\s+fcb\s+)\$[0-9A-Fa-f]{2},\$[0-9A-Fa-f]{2}(.*;\s*seg\s+(\d+).*)$')
    out, in_seg, in_cache = [], False, False
    for ln in path.read_text().splitlines():
        if f'Circuit_{cid}_segment_cache' in ln:
            in_seg, in_cache = False, True; out.append(ln); continue
        if f'Circuit_{cid}_segments' in ln:
            in_seg, in_cache = True, False; out.append(ln); continue
        m = seg_re.match(ln)
        if m and (in_seg or in_cache):
            j = int(m.group(3))
            if in_seg and 0 <= j < nb:
                dc, dp, pf, sf = segs[j]
                b0 = (0x80 if pf else 0) | (dc & 0x7F)
                b1 = (0x80 if sf else 0) | (dp & 0x7F)
                out.append(f"{m.group(1)}${b0:02X},${b1:02X}{m.group(2)}")
            elif in_cache and 0 <= j < len(yaw):
                out.append(f"{m.group(1)}${yaw[j]:02X},${pit[j]:02X}{m.group(2)}")
            else:
                out.append(ln)
        else:
            out.append(ln)
    return "\n".join(out) + "\n"


def _native_asm_minimal(cid, segs, nb):
    yaw, pit = _cache_yaw_pitch(segs, nb)
    L = [f"* Circuit_{cid} — {nb} segments (export éditeur ; sans sprites).",
         f"Circuit_{cid}_nb_segments", f"        fdb   {nb}", "",
         f"Circuit_{cid}_sprite_lut",
         "        fcb   " + ",".join("$00" for _ in range(16)) + "", "",
         f"Circuit_{cid}_segments"]
    for i in range(nb + 8):
        dc, dp, pf, sf = segs[i % nb]
        b0 = (0x80 if pf else 0) | (dc & 0x7F)
        b1 = (0x80 if (sf and i < nb) else 0) | (dp & 0x7F)
        tag = f"; seg {i}" + ("" if i < nb else f" (wraparound de seg {i-nb})")
        L.append(f"        fcb   ${b0:02X},${b1:02X},$00,$00,$00,$00,$00,$00  {tag}")
    L += ["", f"Circuit_{cid}_segment_cache"]
    for i in range(nb + 8):
        L.append(f"        fcb   ${yaw[i]:02X},${pit[i]:02X},$00,$00  ; seg {i}")
    return "\n".join(L) + "\n"


# index 0 de la palette engine = clé de transparence (convention default.png / build).
TRANSPARENT_KEY = (253, 0, 255)


def _palette_rgb(pal: str):
    """16 RGB de la palette courante (pal = level-indices) ; défaut éditeur si absent/invalide."""
    targets = _parse_palette(pal)
    if not targets:
        targets = [(TO8_LEVELS[l[0]], TO8_LEVELS[l[1]], TO8_LEVELS[l[2]]) for l in _default_palette()]
    return targets


def _recolor_textures(pal: str):
    """normal_dark/light.png reteintées avec la palette courante (PLTE index i -> couleur i)."""
    from PIL import Image as _Im
    targets = _palette_rgb(pal)
    flat = [0, 0, 0]                       # index 0
    for i in range(1, 256):
        c = targets[i - 1] if i - 1 < len(targets) else (0, 0, 0)
        flat += [c[0], c[1], c[2]]
    out = {}
    for name in ('normal_dark.png', 'normal_light.png'):
        im = _Im.open(TEX_DIR / name).copy()
        im.putpalette(flat[:768])
        b = io.BytesIO(); im.save(b, 'PNG'); out[name] = b.getvalue()
    return out


def _engine_palette_png(targets) -> bytes:
    """PNG palette au format engine (mode P 1x1) lu par `palette.Pal_Road`.
    PLTE[0] = clé transparente ; PLTE[i] = targets[i-1] -> register TO8 i = couleur de
    l'index texture i (donc couleurs EN JEU = preview éditeur)."""
    from PIL import Image as _Im
    flat = list(TRANSPARENT_KEY)
    for i in range(1, 256):
        c = targets[i - 1] if 0 <= i - 1 < len(targets) else (0, 0, 0)
        flat += [c[0], c[1], c[2]]
    im = _Im.new('P', (1, 1), 0)
    im.putpalette(flat[:768])
    b = io.BytesIO(); im.save(b, 'PNG'); return b.getvalue()


def _readme(cid, nb, nchunks):
    root = f"objects/circuits/{cid}"
    return (
        f"Export éditeur — circuit '{cid}' ({nb} segments)\n"
        f"{'='*50}\n\n"
        f"Arborescence (à dézipper À LA RACINE du projet road-generator) :\n\n"
        f"{root}/\n"
        f"  {cid}.asm                Circuit au format natif Lotus (mode road classique).\n"
        f"  stream/                  Données 'mode stream' (diff-streaming) prêtes à intégrer :\n"
        f"    generated/*.bin        {nchunks} chunks de 16 Ko (1 page cart chacun).\n"
        f"    chunk_NN.asm/.properties  objets code-only (1 par page).\n"
        f"    {cid}_index.asm        index résident (frame -> page+addr).\n"
        f"    OBJECTS_SNIPPET...txt  lignes 'object.RoadStreamPN=' à coller dans le main.properties.\n"
        f"  images/palette.png       palette engine (lue par palette.Pal_Road) = palette courante.\n"
        f"  images/normal_*.png      lignes de route reteintées (référence visuelle).\n\n"
        f"Les chemins internes (INCLUDEBIN, code=, object=) pointent déjà vers\n"
        f"./{root}/stream/ — aucune réécriture nécessaire si dézippé à la racine.\n\n"
        f"Intégration mode stream :\n"
        f"  1. Dézipper à la racine du projet.\n"
        f"  2. Coller les lignes de stream/OBJECTS_SNIPPET.properties.txt dans le\n"
        f"     main.properties du game-mode road-stream (déclarer dans CET ordre).\n"
        f"  3. INCLUDE \"./{root}/stream/{cid}_index.asm\" dans le main.asm du game-mode.\n"
        f"  4. palette.Pal_Road=./{root}/images/palette.png  dans le main.properties.\n"
        f"  (1 circuit par build : symboles RoadStream_* globaux. cf. doc 42.)\n\n"
        f"Intégration mode classique : INCLUDE \"./{root}/{cid}.asm\".\n")


@app.get("/export/{cid}")
def export(cid: str, pal: str = ""):
    segs, nb = track(cid)
    segs = [list(s) for s in segs]
    # cible engine : objects/circuits/<cid>/{stream,images} — un circuit/build (symboles globaux).
    root = f"objects/circuits/{cid}"          # racine engine-relative du circuit
    base = f"./{root}/stream"                 # inscrit en dur dans les INCLUDEBIN/code=/object=
    buf = io.BytesIO()
    with tempfile.TemporaryDirectory() as td:
        outdir = Path(td) / "stream"
        import road_pack as rp
        st = rp.emit_build_from_segs(segs, nb, S=2, KF=64, outdir=outdir,
                                     assets=assets(), circuit=cid, base_path=base)
        native = _native_asm(cid, segs, nb)
        tex = _recolor_textures(pal)
        with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
            z.writestr(f"{root}/{cid}.asm", native)
            for f in sorted(outdir.rglob("*")):
                if f.is_file():
                    z.write(f, f"{root}/stream/{f.relative_to(outdir)}")
            z.writestr(f"{root}/images/palette.png", _engine_palette_png(_palette_rgb(pal)))  # palette engine
            z.writestr(f"{root}/images/normal_dark.png", tex['normal_dark.png'])
            z.writestr(f"{root}/images/normal_light.png", tex['normal_light.png'])
            z.writestr(f"{root}/README.txt", _readme(cid, nb, st['nchunks']))
    buf.seek(0)
    return Response(content=buf.getvalue(), media_type="application/zip",
                    headers={"Content-Disposition": f'attachment; filename="{cid}.zip"'})


# ── Déploiement : rend un circuit ACTIF dans l'engine (un circuit / build) ───
# Patch idempotent par marqueurs sentinelles. Au 1er passage (pas de marqueur),
# repère la zone par regex stable puis installe les marqueurs ; ensuite il
# remplace simplement l'intérieur du bloc, quel que soit l'ancien circuit.
DEPLOY_FILES = {
    'properties':   "game-mode/road-stream/main.properties",
    'main_asm':     "game-mode/road-stream/main.asm",
    'road_engine':  "objects/road-engine/road-engine.asm",
}
RE_PROP_OBJECTS = re.compile(r"^object\.RoadStreamP\d+=[^\n]*(?:\n^object\.RoadStreamP\d+=[^\n]*)*", re.M)
RE_ASM_INDEX    = re.compile(r'^[ \t]*INCLUDE[ \t]+"[^"\n]*_index\.asm"[^\n]*', re.M)
RE_RE_INIT      = re.compile(r'^[ \t]*\*[^\n]*Circuit \(déporté ici\)[^\n]*\n[ \t]*ldd[^\n]*\n[ \t]*std[^\n]*\n[ \t]*ldd[^\n]*\n[ \t]*std[^\n]*', re.M)
RE_RE_INCLUDE   = re.compile(r'^[ \t]*INCLUDE[ \t]+"\./(?:engine|objects)/circuits/[^"\n]*\.asm"[^\n]*', re.M)
RE_PROP_PALETTE = re.compile(r"^palette\.Pal_Road=[^\n]*", re.M)


def _block(cc, key, inner):
    return f"{cc} === circuit-editor:{key} BEGIN (auto — ne pas éditer) ===\n{inner}\n{cc} === circuit-editor:{key} END ==="


def _patch_block(text, cc, key, inner, fallback):
    """Remplace le bloc marqué <key> par `inner` (idempotent). Si le marqueur est
    absent, l'installe à la place du 1er match de `fallback`. Lève si introuvable."""
    blk = _block(cc, key, inner)
    bre = re.compile(rf"^{re.escape(cc)} === circuit-editor:{re.escape(key)} BEGIN.*?"
                     rf"{re.escape(cc)} === circuit-editor:{re.escape(key)} END ===", re.M | re.S)
    if bre.search(text):
        return bre.sub(lambda m: blk, text, count=1)
    new, n = fallback.subn(lambda m: blk, text, count=1)
    if not n:
        raise HTTPException(500, f"site d'injection '{key}' introuvable dans le fichier cible")
    return new


def _deploy_patches(cid, nchunks):
    """Calcule les textes patchés EN MÉMOIRE (rien écrit). Lève si un site manque."""
    pf, af, rf = (ROOT / DEPLOY_FILES[k] for k in ('properties', 'main_asm', 'road_engine'))
    prop_inner = "\n".join(f"object.RoadStreamP{k}=./objects/circuits/{cid}/stream/chunk_{k:02d}.properties"
                           for k in range(nchunks))
    pal_inner  = f"palette.Pal_Road=./objects/circuits/{cid}/images/palette.png"
    idx_inner  = f'        INCLUDE "./objects/circuits/{cid}/stream/{cid}_index.asm"'
    init_inner = ("        * Circuit (déporté ici) → Circuit_base/nb résidents (lus par physics/SP)\n"
                  f"        ldd   #Circuit_{cid}_segments\n"
                  "        std   Circuit_base\n"
                  f"        ldd   Circuit_{cid}_nb_segments\n"
                  "        std   Circuit_nb_segments")
    inc_inner  = f'        INCLUDE "./objects/circuits/{cid}/{cid}.asm"'
    pt = _patch_block(pf.read_text(), "#", "road-stream-objects", prop_inner, RE_PROP_OBJECTS)
    pt = _patch_block(pt,             "#", "road-stream-palette", pal_inner,  RE_PROP_PALETTE)
    at = _patch_block(af.read_text(), "*", "road-stream-index",   idx_inner,  RE_ASM_INDEX)
    rt = rf.read_text()
    rt = _patch_block(rt, "*", "active-init",    init_inner, RE_RE_INIT)
    rt = _patch_block(rt, "*", "active-include", inc_inner,  RE_RE_INCLUDE)
    return {pf: pt, af: at, rf: rt}


@app.post("/deploy/{cid}")
def deploy(cid: str, pal: str = ""):
    segs, nb = track(cid)
    segs = [list(s) for s in segs]
    cdir = ROOT / "objects" / "circuits" / cid
    sdir = cdir / "stream"
    imgdir = cdir / "images"
    base = f"./objects/circuits/{cid}/stream"
    import road_pack as rp
    st = rp.emit_build_from_segs(segs, nb, S=2, KF=64, outdir=sdir,
                                 assets=assets(), circuit=cid, base_path=base)
    # calcule TOUS les patches avant d'écrire (atomicité : pas de demi-déploiement config)
    patches = _deploy_patches(cid, st['nchunks'])
    (cdir / f"{cid}.asm").write_text(_native_asm(cid, segs, nb))
    imgdir.mkdir(parents=True, exist_ok=True)
    (imgdir / "palette.png").write_bytes(_engine_palette_png(_palette_rgb(pal)))   # palette engine courante
    for path, txt in patches.items():
        path.write_text(txt)
    return {"ok": True, "circuit": cid, "nchunks": st['nchunks'], "frames": st['N'],
            "deployed_dir": str(cdir.relative_to(ROOT)),
            "patched": [DEPLOY_FILES['properties'], DEPLOY_FILES['main_asm'], DEPLOY_FILES['road_engine']]}


REF_PALETTE_PNG = ROOT / "game-mode" / "road" / "palette" / "default.png"


@app.post("/palette/sync-reference")
def palette_sync_reference():
    """Recopie les RGB de la palette par défaut éditeur dans l'image de référence
    engine (game-mode/road/palette/default.png) -> un déploiement SANS édition de
    palette donne en jeu les mêmes couleurs que le preview par défaut."""
    targets = [(TO8_LEVELS[l[0]], TO8_LEVELS[l[1]], TO8_LEVELS[l[2]]) for l in _default_palette()]
    REF_PALETTE_PNG.write_bytes(_engine_palette_png(targets))
    return {"ok": True, "ref": str(REF_PALETTE_PNG.relative_to(ROOT)),
            "colors": [list(c) for c in targets]}


@app.get("/health")
def health():
    return {"ok": True, "circuits": len(_all_circuits())}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8765)
