# Context Resume — Port Lotus Esprit TO8

Document de reprise pour nouvelle session. État au 2026-06-02, fin de session.

## Projet

Port Lotus Esprit Turbo Challenge (Atari ST 68k) → Thomson TO8 (6809), via le framework Bento8. Objectif : **fidélité au code 68k d'origine**, adapté aux contraintes TO8 (160 px BM16, banques mémoire 16 Ko).

Path : `/Users/benoitrousseau/Documents/Claude/Projects/thomson-to8-game-engine/game-projects/road-generator/`

## Pipeline rendu route (chaîne SP → LI → DFR)

```
PlayerOne_State  →  SparseProjection (SP)  →  Sparse_Buffer (72 slots × 8 oct)
                       ↓ slot.X, slot.Y, slot.D0a
                    LinearInterp (LI)  →  Dense_Buffer (192 lignes × 6 oct triplets)
                       ↓ flags, width, extra par scanline
                    DrawFrameRoad (DFR)  →  VRAM (96 scanlines × 40 oct × 2 banks RAMA/RAMB)
```

Voir `MEMORY.md` pour les golden rules et conventions.

## Outils Python (tools/)

### Simulateur byte-perfect ASM
- `tools/simulate_dfr_pipeline.py` — reproduit SP + LI + DFR avec FILE59 + A4_table réels. Match runtime byte-perfect.
- `tools/lwmap.py` — parse .lwmap → dict {symbol: addr}.
- `tools/dcmoto_trace.py` — parser streaming trace dcmoto (.txt). Handles 130+ MB traces.
- `tools/extract_road_state.py` — CLI : extrait sparse/dense par frame, compare avec sim Python.

### Usage typique
```bash
# Résumé toutes frames
python3 tools/extract_road_state.py --trace dist/dcmoto_trace.txt

# Frame N détaillée + compare avec sim
python3 tools/extract_road_state.py --trace dist/dcmoto_trace.txt \
    --frame 1 --compare-sim --seg 58 --nibble 9 --circuit 22_hard_5
```

## État actuel du code (post-revert fix #176)

### DrawFrameRoad.asm — formule entry restaurée
```asm
* entry_idx = max(0, N - 17 + chunk_shift)
lda ,y                ; A = K
adda 1,y              ; A = K + M
adda 2,y              ; A = K + M + J = N
suba #17
adda <DFR_curve_chunk_shift
bpl DFR_da_entry_ok
clra                  ; clamp à 0
```

Le shift product est négaté :
```asm
lbsr Mul16x16HiSigned ; D = (combined × width) >> 16
coma; comb; addd #1   ; D = -product (négation 16-bit)
* Décomposition chunk_shift + sub_pix
```

### Optims gardées (sûres et appliquées)
- **#177-1** : `lateral_scaled = lateral_pos × 8` hoisté hors boucle scanline (= calculé 1× au début de DrawFrameRoad au lieu de 96×). Stocké en extended : `DFR_lateral_scaled fdb 0`.
- **#178** : K=5 force dans `tools/compile_road_sprites.py` (= trim K naturel à 5 max, stabilise K constant).
- **#171** : `PlayerOne_Init` lit `Circuit_nb_segments` (= `ACTIVE_CIRCUIT_NB`) et fait `-6` au lieu de hardcoder 250. Marche pour n'importe quel circuit.
- **#150** : `SP_mul_full` utilise Knuth Alg M tronquée 4-MUL inline (= équivalent `Mul16x16HiSigned`) au lieu de l'ancien 2× Mul9x16 approximé. Précision +1 LSB sur slot.Y.

### Reverts effectués (mes erreurs)
- **#176** : `entry = K + M//2 - screen_block` REVERTÉ. La sémantique K/M/J du générateur (K=grass-RIGHT, J=grass-LEFT) ne match pas l'hypothèse `K + M/2 = road center`. Cause "affichage cassé".
- **#177-2** : `addd #81` fusion REVERTÉ (= dépendait du contexte position-based).
- **#177-3** : byte 2 buffer = `K+M/2` REVERTÉ (= back to J, nécessaire pour formule OLD `N = K+M+J`).

## Bug NON résolu — clamp asymétrique (tâche #180 in_progress)

### Symptôme
"Un bout de route près de l'horizon complètement décalé visuellement" (user feedback).

### Cause technique
Quand `chunk_shift` est très négatif (= virage fort), `raw_entry = N - 17 + chunk_shift < 0` → clamp à 0 → `chunk_shift` part **perdue**. **MAIS** `sub_pix` (= partie 0-15 px du shift) continue à shifter U cursor via `byte_offset = sub_pix >> 2`. Résultat : road shifted dans la **MAUVAISE DIRECTION** par 12-16 px.

### Exemple concret (Y=44 d'une trace)
- product = 17, après négation = -17 px
- `chunk_shift = -17 >> 4 = -2` (signed shift)
- `sub_pix = -17 & 15 = 15`
- raw_entry = 1 + (-2) = -1 → clamp 0
- byte_offset = 15 >> 2 = 3 → U shift +12 px → road **RIGHT** au lieu de **LEFT**

### Solution proposée par l'user (= correcte mais pas encore implémentée)
**"Travailler en pixels TOUT du long, décomposer en bloc + sub seulement à la fin."**

Le fix concret : dans `DFR_dispatch_and_draw`, après détection `raw_entry < 0` et clamp entry à 0, **ZÉROER aussi sub_pix + byte_offset + rama_bank_off + variants** pour ne pas appliquer une fraction du shift. Le road snap au chunk boundary au lieu d'avoir un décalage asymétrique.

### Code à appliquer (DFR_dispatch_and_draw)

Localiser :
```asm
DFR_dispatch_and_draw
        lda   ,y                         ; A = K
        adda  1,y                        ; A = K + M
        adda  2,y                        ; A = K + M + J = N
        suba  #17
        adda  <DFR_curve_chunk_shift
        bpl   DFR_da_entry_ok
        clra                             ; clamp à 0
DFR_da_entry_ok
        sta   <DFR_tmp_base
```

Modifier pour :
```asm
DFR_dispatch_and_draw
        lda   ,y                         ; A = K
        adda  1,y                        ; A = K + M
        adda  2,y                        ; A = K + M + J = N
        suba  #17
        adda  <DFR_curve_chunk_shift
        bpl   DFR_da_entry_ok

        * BUG FIX #180 : raw_entry < 0 → zéro sub_pix pour éviter asymétrie
        * Sans ça : chunk_shift perdu au clamp mais sub_pix continue à shifter U
        * → road shift 12-16 px dans la MAUVAISE direction (= bug horizon visible).
        * Fix : snap road à chunk boundary (= zero out all sub_pix-derived shift).
        clra                             ; entry = 0
        clr   <DFR_curve_sub_pix
        clr   <DFR_byte_offset
        clr   <DFR_rama_bank_off
        clr   <DFR_rama_variant_b        ; variant_tbl[0] = (0, 4)
        ldb   #4
        stb   <DFR_ramb_variant_b
        * NOTE : ce code s'exécute en milieu de scanline. byte_offset/variants
        * ont déjà été utilisés pour set U avant DFR_dispatch_and_draw. Donc U
        * a déjà été shifté incorrectement. Il faut soit :
        *   (a) Déplacer le check entry AVANT le U setup (= refactor structure DFR)
        *   (b) Détecter clamp ICI et reconstruire U correct
        * À DÉCIDER. Approche (a) plus propre mais nécessite restructurer ~30 lignes.
DFR_da_entry_ok
        sta   <DFR_tmp_base
```

**ATTENTION** : Le zéroing dans dispatch_and_draw est TROP TARD car U a déjà été setup avec byte_offset avant l'appel. Il faut soit :
1. **Déplacer la détection de clamp AVANT le U setup** (= refactor `DFR_main_loop` pour calculer entry une fois avant les 2 passes RAMB/RAMA)
2. **Détecter clamp dans dispatch ET corriger U inline** (= soustraire byte_offset×1 puis rama_bank_off×1 selon pass)

Approche 1 plus propre.

## Tâches pendantes

| # | Description | Priorité |
|---|---|---|
| #180 | Fix clamp asymétrique (zéro sub_pix quand entry clampe) | **CRITIQUE — bug visuel actif** |
| #117 | Migrer A4_table vers $4FC0-$4FFF | basse |
| #118 | Java BuildDisk : multi-data per page avec auto-padding | basse |
| #122 | Cleanup lotus_input.buffer (= ancien dossier input/) | basse |
| #145 | Porter Lotus_PhysicsTick complet (gear/RPM/torque) | critique mais hors scope route |
| #148 | DFR : implémenter flags PIT/START sur slot.X bits 0-1 | moyenne |
| #151 | AiCar : porter logique IA complète (= MOCK actuellement) | basse |
| #152 | Sprites bord-piste : FUN_74dac loops 2/3 | basse |
| #153 | Cleanup : retirer DFR_DEBUG_CURVE_TEST + P1M_TEST_FREEZE | basse |
| #155 | Investigation artefacts virages/bosses | moyenne |

## Conventions importantes

- **NE PAS RE-INVENTER** des fixes "intuitifs". Le port DOIT rester fidèle au 68k.
- Le `coma; comb; addd #1` qui négate le product est INTENTIONNEL (= task #144 valide ça vs convention 68k).
- La formule `entry = N - 17 + chunk_shift` fonctionne grâce au padding générateur `J = 12 - M//2`. Ne pas la changer pour `K + M/2 - x` (= mauvaise sémantique).
- `K = grass-RIGHT` (= chunks à la droite de content_d), `J = grass-LEFT`. Ne pas inverser.
- Le simulateur Python `simulate_dfr_pipeline.py` est byte-perfect avec le runtime (vérifié 68/68 widths frame typique).

## Trace runtime de référence

`dist/dcmoto_trace.txt` — capturée par dcmoto émulateur. Format ligne :
```
PC OPCODE HEX MNEM OPERAND CYC TOTAL_CYC D=XXXX X=XXXX Y=XXXX U=XXXX S=XXXX DP=XX CC=XX | Banques: ...
```

Adresses clés (= lues depuis `generated-code/road/FD/main.lwmap`) :
```
SparseProjection = $818E
LinearInterp     = $8353
DrawFrameRoad    = $8D91 (varie selon build)
Sparse_Buffer    = $6279
Dense_Buffer     = $6779
Proj_count       = $8189
```

## Build

`./build.sh --run` (= macOS). Le script utilise `tools/macos/lwasm`. Dans la sandbox Linux on a utilisé `tools/linux-aarch64/lwasm` via patch temporaire.

Pour régénérer Road_lines après modif générateur :
```bash
python3 tools/compile_road_sprites.py --batch tools/road_sprites_source
```

## Reprise recommandée

1. Lire ce document
2. Lire le diff DFR récent : `git diff HEAD~5 engine/projection/DrawFrameRoad.asm`
3. Implémenter task #180 (= clamp sub_pix avec entry) en **approche 1** (= move entry check before U setup)
4. Builder + tester visuellement sur macOS
5. Si OK → close task #180

## Historique des erreurs (= pour ne pas refaire)

- ❌ Fix K=5 force seul (= aide partielle mais ne résout pas le bug horizon)
- ❌ Position-based `entry = K + M/2 - screen_block` (= sémantique K/M/J inversée)
- ❌ Compensation U via `leau a,u` (= écrit sur scanline adjacente)
- ❌ Reverter au lieu de fixer (= la solution était simple, juste zéroer sub_pix au clamp)

L'user a été ferme : **"je n'ai pas compris le problème"** quand mes explications étaient verbeuses. Garder les explications COURTES et CONCRÈTES.
