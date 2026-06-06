# Lotus Circuit Editor (outil dev interne)

Conception : `lotus-ste/doc/extraction/43_circuit_editor_design.md`. Maquette de référence :
`tools/circuit_editor_mockups.html` (v3). Le **backend ne réimplémente rien** : il appelle le
pipeline Python existant (`tools/road_bake.py`, `simulate_dfr_pipeline.py`) = source de vérité.

## Lancer (scripts — macOS / Linux / Windows)

Prérequis : **Python 3** et **Node.js ≥ 18**. Depuis `tools/circuit-editor/` :

```bash
# 1) installer les prérequis (venv + deps backend + npm install)  — une seule fois
python install.py          # ou ./install.sh (macOS/Linux)  /  install.bat (Windows)

# 2) lancer backend + frontend ensemble (Ctrl-C arrête les deux proprement)
python run.py              # ou ./run.sh (macOS/Linux)  /  run.bat (Windows)
```

Puis ouvrir **http://localhost:5180** (le backend tourne sur http://127.0.0.1:8765).

Le cœur est en Python (`install.py` / `run.py`) pour être cross-platform ; les
`.sh` / `.bat` ne sont que de fins wrappers. `run.py` arrête tout l'arbre de
process (backend + vite/node) sur Ctrl-C **ou** SIGTERM (`kill` / Docker).

### Lancement manuel (équivalent, si besoin)
```bash
# Backend (depuis game-projects/road-generator/)
.venv/bin/python3 tools/circuit-editor/backend/app.py     # -> http://127.0.0.1:8765
# Frontend
cd tools/circuit-editor/frontend && npm run dev           # -> http://localhost:5180
```

## État (Phase 0/1)
- ✅ Backend FastAPI : `/circuits`, `/circuit/{id}`, `/shape/{id}`, `/segment/{id}/{seg}`,
  `/render?circuit&pos&steer` (vraie frame PNG), `/palette/to8`.
- ✅ Frontend Svelte+Vite+TS : layout v3, simulateur (vraie frame), ruban 3D + plan (vraies
  données via /shape), scrub (marqueur ⇄ simulateur), data segment, palette TO8 (affichage).
- ⏳ Phase 2 : édition (sliders → recompile → preview, persistance réordonnancement, keyframes).
- ⏳ Phase 3 : éditeur palette (reteinte). Phase 4 : compile .asm + import/décompile.

## Empaquetage (plus tard)
Tauri (sidecar Python) pour une fenêtre native légère — cf. doc 43 §5.
