# Passation — Session rendu route TO8 (Lotus port)

> Date : 2026-06-04. Document de bascule vers Claude Code (qui peut lancer
> `build.sh` + lwasm sur macOS — ce que l'environnement précédent ne pouvait pas :
> `tools/macos/lwasm` est un binaire **Mach-O x86_64**, non exécutable sous Linux).

---

## 0. TL;DR — où on en est

- **6 bugs corrigés** cette session (rendu route) + **mode debug complet** créé.
- **Lead A IMPLÉMENTÉ + MESURÉ** (2026-06-04) : dispatch scindé en `DFR_dispatch_compute`
  (1×/scanline) + `DFR_dispatch_draw` (1×/passe). Gain mesuré **~77 cyc/scanline** (.lst) :
  ~7,4 k cyc/frame en mode normal (96 lignes), ~15,4 k en debug (200 lignes). Les 2 modes
  assemblent (`build.sh` + `build-debug.sh` → « Build réussi »). Détails §6.
- Tout le code des correctifs est **déjà en place** (sources `.asm` + générateur `.py`).
  Le mode normal et le mode debug partagent `DrawFrameRoad.asm`.

---

## 1. Contexte projet

Port de **Lotus Esprit Turbo Challenge** (rendu route en perspective) de l'Atari ST
(68000) vers **Thomson TO8** (6809), via le framework **Bento8**.
Répertoire : `game-projects/road-generator/`.

**Principe directeur (règle d'or)** : RESPECTER le code/principes 68k ; ADAPTER les
structures de données pour minimiser le runtime 6809, **jamais tronquer/approximer** la
restitution.

Mode vidéo : **BM16** (160 px, 4 px/octet… voir §2).

---

## 2. Architecture du rendu route (essentiel)

### Pipeline
`SparseProjection` → `Sparse_Buffer` → `LinearInterp` → `Dense_Buffer` (triplets
flags/width/extra par scanline) → **`DrawFrameRoad`** → VRAM.

### BM16 / VRAM
- RAMB `$A000-$BF3F`, RAMA `$C000-$DF3F`, **40 octets/ligne/banque**.
- `RAMA[k]` = px(4k, 4k+1), `RAMB[k]` = px(4k+2, 4k+3) → **les plans alternent tous
  les 2 px**. 1 octet/plan = 2 px ; 1 « chunk » = 4 octets/plan = 16 px écran.
- `byte_offset +1` (décale U d'1 octet, les 2 plans) = **+4 px** écran.
- Couleurs : **herbe = index palette 3 → nibble stocké 2** (`$22`) ;
  **bordure noire = index 8** (`$88`).

### Données générées (par `tools/compile_road_sprites.py`)
- **`road_buffers.bin`** (objets/road-buffers/generated) : 255 lignes (`line_idx`
  0..254), chaque buffer `Line_NNNN` = header **`fcb K,M,J`** (K=herbe droite,
  M=cœur chunks, J=herbe gauche) + `M` `fdb` de pointeurs vers patterns `Road_R*`.
  4 variants par ligne : `[RAMA_s0, RAMA_s1, RAMB_s0, RAMB_s1]` (s1 = contenu tourné
  1 px = sous-pixel). Table d'indexation = `Road_lines` (8 oct/ligne).
- **`road_patterns_dark.bin` / `road_patterns_light.bin`** : les routines `Road_R*`
  (`ldd #D; ldx #X; pshu d,x; rts`) + `Road_draw_KX_JY` (déroulées) dans la **bank
  pattern mappée à `$4000-$7FFF`** (dark ou light selon le bit **PRC**).
- Couleur teinte (dark/light) = **PRC** = bit 0 de `$E7C3` (sélection demi-page).

### Rendu par scanline (boucle dans `DrawFrameRoad` / `DrawFrameRoad_Debug`)
1. `line_idx` → `lines_base = Road_lines + idx*8`. Lecture `M` = `1,y` du buffer.
2. **leftEdge (px)** = `(CENTER + neg_product) − (M&~1)*8` (voir §4 fixes).
   Décomposé : `LE = leftEdge>>4` (chunks, signé, → `DFR_curve_chunk_shift`),
   `sub_pix = leftEdge&15` (0..15).
3. `sub_pix` → `byte_offset` (>>2) + variant (s0/s1 × plane-first) + `rama_bank_off`
   via **`DFR_subpix_tbl`** (table 16×4, lookup `abx`).
4. **2 passes** : RAMB (`U_RAMB + byte_offset`) puis RAMA (`+ rama_bank_off`), chacune
   `lbsr DFR_dispatch_and_draw`.
5. `DFR_dispatch_and_draw` : `right=LE+M` ; `J'=clamp(LE,0,10)` (herbe gauche) ;
   `K'=10−clamp(right,0,10)` (herbe droite) ; index `(K'*11+J')*2` →
   `Road_draw_dispatch[index]` = ptr routine ; `coreOff=max(0,right−10)*2` ;
   `leay 3+coreOff,y` → cœur ; `jsr` routine.
6. Convention **U = fin_de_ligne − 2** (« à cheval ») : la route déborde 8 px L/R sous
   les bordures, masquées par `DFR_border_mask` (normal) / `DFR_border_mask_dbg` (debug).

### Adresses clés (dans `generated-code/roaddebug/FD/main.lst`)
| Symbole | Adr | Rôle |
|---|---|---|
| `Road_pshu_dx` | `$4000` | (ancien stub hérité, **plus utilisé** — voir fix #6) |
| `Road_draw_dispatch` | `$8CD0` | table 66 ptrs (K',J') |
| `DFR_subpix_tbl` | `$8DCF` | table sub_pix → byte_offset/variants |
| `DFR_dispatch_and_draw` | `$8F7D` | dispatch (cible du Lead A) |
| `DrawFrameRoad_Debug` | `$9032` | routine debug 200 lignes |
| `DFR_dbg_loop` | `$9064` | boucle par scanline (debug) |
| `DFR_border_mask_dbg` | `$90EF` | masque bordure debug |
| `MainLoop` (debug) | `$616E` | |

---

## 3. Fichiers & WORKFLOW BUILD (critique pour Claude Code)

### Sources modifiées cette session
- **`engine/projection/DrawFrameRoad.asm`** — LE renderer, PARTAGÉ par les 2 modes.
  Contient `DrawFrameRoad` (normal), `DrawFrameRoad_Debug` (debug), le dispatch partagé,
  `DFR_subpix_tbl`, les masques bordure, `Mul16x16HiSigned`.
- **`tools/compile_road_sprites.py`** — générateur des buffers/patterns.
- **`game-mode/road-debug/main.asm` + `main.properties`** — NOUVEAU mode debug.
- **`config-macos-debug.properties`** + **`build-debug.sh`** — build du mode debug.

### Commandes
```bash
# Mode normal (le jeu) — gameModeBoot=road
./build.sh            # → dist/road-generator.fd
./build.sh --run      # + lance dcmoto

# Mode debug — gameModeBoot=roaddebug
./build-debug.sh          # → dist/road-generator-debug.fd
./build-debug.sh --run

# Régénérer les buffers/patterns (APRÈS toute modif du générateur .py)
python3 tools/compile_road_sprites.py --batch tools/road_sprites_source
#   → réécrit objects/road-buffers/generated/road_buffers.bin
#           game-mode/road/generated/road_lines_table.asm
#           game-mode/road/generated/road_patterns_{dark,light}.bin
#   (utilise ../../tools/macos/lwasm pour assembler les intermédiaires)
```
> ⚠️ Prérequis build : **Java 11+ ET Maven** (`mvn` était ABSENT dans l'env précédent →
> le jar pré-build existe déjà dans `../../java-generator/target/`, mais un `--clean`
> nécessite mvn). lwasm = `../../tools/macos/lwasm` (macOS).

### Mesure / profilage
- **`.lst`** : `generated-code/<mode>/FD/main.lst` — annotations cycles `[N]` par
  instruction. (Tous les `.lst` sont dans `generated-code/`, rangés par game-mode.)
- **Trace** : `dist/dcmoto_trace.txt` — trace CPU dcmoto (format :
  `PC OPCODE MNEMO OPERANDE CYCLES CUMUL D=.. X=.. Y=.. U=.. S=.. ...`).
- **Profilage par zone** (script ad hoc, parse PC + cycles, agrège par plage d'adresses) :
  voir §6 pour les chiffres déjà obtenus.

---

## 4. Correctifs appliqués cette session (TOUS en place dans le code)

Ordre chronologique. Le rendu route avait plusieurs bugs, débusqués via le **mode debug**
(banc d'essai « pyramide » : 200 lignes empilées, validation au pixel).

1. **Table sub_pix 16-entrées** (`DFR_subpix_tbl`, DrawFrameRoad.asm) remplaçant les 3
   dérivations + `DFR_variant_tbl`. 1 lookup `abx`. Partagé (boucle normale + debug + test).

2. **Suppression `DFR_saved_M`** (store mort).

3. **`DFR_SCREEN_CENTER`** : 80 → 72 → **88** (valeur finale). `88 = centre écran 80 +
   8 px` pour compenser la convention `U=−2` (= −8 px). Centre la route droite à
   l'écran px 80. (Le 72 = « 68k $90/2 » ne tenait pas compte du −2, jamais validé sur
   le mode normal — voir §8 « réserve centrage ».)

4. **Fix parité M impair** (`andb #$FE` / `anda #$FE` sur M **avant** le `×8`) — dans la
   **boucle normale** (`DrawFrameRoad`, ~ligne 428) ET `DrawFrameRoad_Debug`.
   `leftEdge = CENTER + neg_product − (M&~1)*8`. Les lignes à M **impair** étaient
   décalées de **−8 px** (la route est centrée sur une frontière de chunk ; un cœur de
   M impair se cale sur un *centre* de chunk → demi-chunk d'écart). `(M&~1)*8` étant un
   multiple de 16, `sub_pix` tombe sur la valeur centrée. M **réel** relu en `1,y` au
   dispatch (le `&~1` ne touche que le calcul de position). Validé sur trace : M=1..15 OK.

5. **Générateur : variants à M cohérent** (`compile_road_sprites.py`, boucle de chunking).
   Avant : K/M/J mesurés **par shift** s0/s1 → la rotation 1 px faisait basculer un pixel
   de bord dans un chunk voisin → **M différent entre s0 et s1** → au runtime, `LE`
   calculé avec le M du variant 0 ≠ M lu au dispatch → **saut de 16 px**. Fix : mesurer
   les 2 shifts puis prendre l'**union** `K=min(K_s0,K_s1)`, `J=min(J_s0,J_s1)` et
   l'appliquer aux 2 → même M. Validé : **0/255** ligne incohérente. **Nécessite
   régénération** des buffers.

6. **Générateur : suppression de l'héritage `PSHU_LABEL`** (`build_core_labels` : toujours
   `pool.register`, plus de stub `pshu` nu). L'optim (un chunk identique au précédent
   réutilisait son D/X via un `pshu` nu) cassait sous **clipping fort** : quand le 1er
   chunk dessiné (coreOff) tombait sur une position héritée, D/X n'étaient jamais chargés
   → **pixels parasites sur une banque** (artefact ligne 164). L'optim ne couvrait que
   1,1 % des chunks (75/6944) → gain nul, risque élevé. Coût mémoire ~nul (les patterns
   pleins existent déjà). **Nécessite régénération**. (Existait aussi en latence sur le
   mode normal.)

> Les fixes 1,2,3,4 sont dans `DrawFrameRoad.asm` (partagé) → présents dans les 2 modes
> après `build.sh`/`build-debug.sh`. Les fixes 5,6 sont dans les **buffers** (régénérer
> avec le générateur, puis rebuild).

---

## 5. Mode debug (`game-mode/road-debug/`) — banc d'essai

`DrawFrameRoad_Debug` : 200 lignes empilées, `line_idx = DFR_dbg_line_base + Y`
(Y=0..199), chaque ligne **centrée** (px 80) et décalée du même `DFR_dbg_offset`.
Rendu `U=−2` + `DFR_border_mask_dbg` (noir idx 8, pleine hauteur). Pas de projection.

**Commandes** (variables exportées par `DrawFrameRoad.asm`, pilotées par
`road-debug/main.asm`) :
- **GAUCHE/DROITE** (`Dpad_Held`) → `DFR_dbg_offset` ±1, signé `[−256,+256]`. Balayage
  horizontal au pixel ; aux extrêmes la route sort de l'écran (clamp grass). RIGHT →
  route à droite.
- **HAUT/BAS** (`Dpad_Held`) → `DFR_dbg_line_base` ±1, clamp `[0,55]` (200 lignes
  affichées, `line_base+199 ≤ 254`). Scroll vertical dans `line_idx` 0..254.
- **FIRE** (`Fire_Press`, front montant ; boutons A/B) → bascule `DFR_dbg_prc` (0/1) =
  **thème couleur dark/light** (bit PRC `$E7C3`).
- Total **255 lignes** = `line_idx` 0..254 (table à 255 entrées, `ROAD_LINES_MAX_IDX=254`).

Masques boutons (engine/joypad/ReadJoypads.asm) : `c1_button_up_mask`=$01,
`down`=$02, `left`=$04, `right`=$08 ; `Fire_Held`/`Fire_Press` (octets séparés).

> Note build : la `MainLoop` du debug a dépassé 127 oct → le bouclage utilise **`lbra
> MainLoop`** (pas `bra`).

---

## 6. ⏳ TÂCHE EN COURS — Lead A : hoister le dispatch (à implémenter + mesurer)

### Profilage (depuis `dist/dcmoto_trace.txt`, mode debug)
| Zone | Part |
|---|---|
| Patterns + Road_draw (`pshu` de dessin, `$4000-$7FFF`) | **48,7 %** |
| Boucle `DrawFrameRoad_Debug` (setup/scanline) | 24,7 % |
| **`DFR_dispatch_and_draw`** (appelé **2×**/scanline) | **23,0 %** |
| Masque + input + reste | ~3,6 % |

≈ 48 % dessin réel, ≈ 48 % overhead de calcul.

### L'idée (profite au MODE NORMAL = objectif)
`DFR_dispatch_and_draw` calcule `K'/J'/index/ptr routine/coreOff` à partir de **`LE`**
(`DFR_curve_chunk_shift`) et **`M`** (`1,y`). Pour une scanline donnée, `LE` est fixe et
— **depuis le fix #5 (variants M cohérents)** — `M` est **identique** sur les buffers
RAMB et RAMA. Donc les 2 passes recalculent **exactement la même chose** (dont un `mul`
11 cyc). → Calculer **une seule fois par scanline**, partager entre les 2 passes.

### Design proposé (split compute / draw)
1. **`DFR_dispatch_compute`** (1×/scanline ; `LE` dans `DFR_curve_chunk_shift`, `M` en
   `1,y` avec Y = buffer variant-0) → produit :
   - `DFR_route_ptr` (fdb, ptr routine `Road_draw_K'_J'`, 0 si non implémentée),
   - `DFR_core_off` (fcb, = `3 + max(0,right−10)*2`, l'offset total dans le buffer).
   (= le corps actuel de `DFR_dispatch_and_draw` jusqu'au calcul de coreOff, en stockant
   au lieu de dessiner.)
2. **`DFR_dispatch_draw`** (par passe ; Y = buffer du variant, U posé) :
   ```
   ldx <DFR_route_ptr
   beq  draw_skip
   lda <DFR_core_off
   leay a,y            ; Y → cœur (header + coreOff déjà inclus)
   jsr  ,x
   draw_skip: rts
   ```
3. **Les 2 boucles** (`DrawFrameRoad` normal ET `DrawFrameRoad_Debug`) : après calcul de
   `LE`, `lbsr DFR_dispatch_compute` ; tester `DFR_route_ptr` (0 → skip scanline) ; puis
   RAMB (poser Y=variant RAMB, U) `lbsr DFR_dispatch_draw` ; RAMA idem.

### Stockage
DP quasi plein (`dp_extreg` 28 oct, seul **+5 libre**). → mettre `DFR_route_ptr` (2) +
`DFR_core_off` (1) en **mémoire étendue** (comme `DFR_dbg_offset`), +1 cyc/accès,
négligeable. (Pas besoin de persistance inter-scanline : recalculé chaque scanline.)

### Gain attendu (à CONFIRMER par build + .lst)
Le compute ≈ **100-125 cyc**, passé de 2× à 1×/scanline → **~100 cyc/scanline économisés**.
- Mode **normal** (96 scanlines) : **~9,6 k cyc/frame**.
- Mode debug (200) : ~20 k.
Frame TO8 ≈ 20 000 cyc @ 50 Hz → le rendu route dépasse déjà le budget (frame drops) ;
−10 k/frame sur le mode normal = gain notable sur le framerate.

### ✅ FAIT (2026-06-04, Claude Code)
1. ✅ Split implémenté dans `DrawFrameRoad.asm` : `DFR_dispatch_compute` (calcul
   K'/J'/index/ptr/coreOff → `DFR_route_ptr` fdb + `DFR_core_off` fcb, **étendus**, pas DP)
   + `DFR_dispatch_draw` (`ldx route_ptr ; beq skip ; ldb core_off ; leay b,y ; jsr ,x`).
   Les 2 boucles (`DrawFrameRoad` + `DrawFrameRoad_Debug`) : `lbsr DFR_dispatch_compute`
   1× (Y=buffer RAMB, M lu en `1,y` — **identique RAMA depuis fix #5**, compute préserve
   Y), puis `lbsr DFR_dispatch_draw` par passe. `core_off` inclut le skip header (+3).
2. ✅ `./build.sh` + `./build-debug.sh` → « Build réussi » (0 erreur).
3. ✅ **Mesuré (.lst)** — coûts overhead/scanline (chemin typique, hors dessin pattern) :
   | | OLD (`dispatch_and_draw` ×2) | NEW (compute ×1 + draw ×2) | Δ |
   |---|---|---|---|
   | cyc/scanline | ~292 | ~215 | **−77** |

   compute = lbsr 9 + corps ~126 = 135 ; draw = (lbsr 9 + 31)×2 = 80. Mode normal (96
   lignes) ≈ **−7,4 k cyc/frame** ; debug (200) ≈ **−15,4 k**. (Légèrement < l'estimé
   ~100/scanline du design car le store/load route_ptr+core_off en étendu rogne ~14 cyc ;
   gain net solide quand même.)
4. ✅ **Test VISUEL confirmé** dans dcmoto (2026-06-04) : rendu identique. Optim validée.

> Variante plus légère si le split est trop risqué : **cache** dans
> `DFR_dispatch_and_draw` (comparer `(LE,M)` à un cache ; sur hit, réutiliser
> route_ptr/coreOff). Pas de modif des boucles, mais ~24 cyc de check/appel rognent le
> gain (~42 cyc/scanline net au lieu de ~100). Le split est préférable.

---

## 6bis. ✅ Batch micro-optims du driver de scanline (2026-06-04)

Après Lead A, analyse du **driver `DrawFrameRoad`** (la boucle qui pilote l'affichage des
lignes). 6 optims appliquées **au mode normal uniquement** (le jeu ; debug inchangé, il
réutilise ses propres vars et builde toujours). Mesuré sur `.lst` : corps de boucle
**490 → 457 cyc** = **−33 cyc/scanline** ≈ **−3 170 cyc/frame** (96 lignes). Rendu
inchangé (optim pure) — **à valider visuellement**.

1. **Code mort** : `ldx <DFR_dense_ptr` en fin de décodage sub_pix supprimé (`DFR_curve_done`
   écrasait X via `tfr d,x` sans le lire ; `DFR_DEBUG_CURVE_TEST=0`). −5.
2. **Lecture M via X** : `ldx ,x ; ldb 1,x` au lieu de `ldd ,x ; tfr d,y ; ldb 1,y`. −6.
3. **`DFR_width_x2` hoisté** dans l'étape (1) (D contient déjà width) → plus de re-`ldd 2,x`
   en (4). −6.
4. **PRC base hoistée** : `DFR_prc_base = $E7C3 & $FE` lue 1×/frame (seule la boucle road
   écrit $E7C3), per-scanline `ldb <DFR_prc_base` au lieu de `ldb $E7C3 ; andb #$FE`. −3.
5. **U_RAMA dérivé** : `U_RAMA = U_RAMB + $2000` (passe RAMA), 1 seul curseur avancé en fin
   de boucle. `DFR_U_RAMA` (dp_extreg+20) n'est plus utilisé qu'en mode debug. −10.
6. **Boucle par down-counter** : `DFR_y_curr` réutilisé comme compteur NB_ROAD_LINES→0
   (`dec ; lbne`), `DFR_y_limit` plus utilisé en normal. −8.

> Combiné Lead A + batch ≈ **−10,6 k cyc/frame** sur le rendu route (mode normal).
> **Irréductible** (règle d'or) : patterns `pshu` (~48,7 %), `Mul16x16HiSigned` (~80 cyc,
> calcul fidèle de la position perspective, déjà tronqué + early-exit `u==0`).

## 6ter. ✅ Vague 1 — inline + adressage (2026-06-04)

Suite de l'analyse « précalcul / déroulage / SMC ». **Mode normal uniquement.**

- **B1 — `Mul16x16HiSigned` inliné** au site DrawFrameRoad (la sous-routine reste pour
  `player-one.asm`, 2e appelant). Supprime `lbsr`+`rts` (−14) **+ le `cmpd #0`** devenu
  inutile (`std` pose déjà Z) (−5). → **−19 cyc/scanline.**
- **D1 — `ldy b,x`** (indexé-accumulateur) pour charger les pointeurs buffer RAMB/RAMA :
  `ldx lines_base ; ldb variant ; ldy b,x` au lieu de `ldd/addb/adca/tfr/ldy`. **−14**
  (−7 × 2 passes, mesuré : corps de boucle hors-mul 448 → 434).

**Vague 1 = −33 cyc/scanline ≈ −3 170 cyc/frame.** Binaire +31 oct ($9AAA→$9AC9 ;
1078 oct libres avant $9F00). Rendu inchangé — **validé visuellement** (à confirmer).

> **A1 (table `center_base`) ABANDONNÉ** après recomptage cyclé précis : on a *toujours*
> besoin de `line_idx` pour `lines_base` (×8), donc la lecture table + sauvegarde/restaure
> de l'index mange le gain → **~−8 cyc seulement** pour +510 oct + routine de boot.
> Mauvais ratio. (Mon estimé initial de −27 était faux : il oubliait le coût de garder
> `line_idx`.) Le `Mul16x16` (corps ~75 cyc) et les patterns restent irréductibles.

## 6quater. ✅ Vague 2 — SMC + inline dispatch (2026-06-04)

**Mode normal uniquement.**

- **C1 — SMC des constantes/frame en immédiats** (fidèle au 68k qui SMC ses constantes) :
  le prologue patche les opérandes immédiats de 3 instructions de la boucle au lieu de
  stocker en mémoire. `DFR_smc_lateral addd #imm` (était `addd DFR_lateral_scaled` ext,
  7→4), `DFR_smc_phase addd #imm` (6→4), `DFR_smc_prc ldb #imm` (4→2). → **−7 cyc/scanline.**
  (Code en RAM $8Exx → SMC OK ; DrawFrameRoad non ré-entrant, re-patché chaque frame.)
- **B2 — inline `dispatch_compute` (1×) + `dispatch_draw` (2×)** dans la boucle normale :
  supprime 3× (`lbsr` 9 + `rts` 5) = **−42 cyc/scanline.** route_ptr/core_off passent
  toujours par la mémoire (le `jsr` pattern de RAMB détruit les registres avant RAMA).
  Labels inline `DFR_nc_*`/`DFR_ndb_`/`DFR_nda_`. **Sous-routines conservées pour le debug.**

**Vague 2 = −49 cyc/scanline ≈ −4 700 cyc/frame.** Binaire +~110 oct ($9AC9→$9B20 ;
991 oct libres avant $9F00). Rendu inchangé — **à valider visuellement**.

> **Bilan cumulé session** (mode normal) : Lead A + batch + V1 + V2 ≈ **−15 à −20 k cyc/frame**
> sur le rendu route. Reste : corps `Mul16x16` (~75 cyc, fidèle) + patterns `pshu` (~48 %).
> Pistes restantes faibles (B3 unroll ~−5 mauvais ratio ; D2 retrait null-test ~−9 à vérifier).

## 7. Leads d'optim différés

- **Lead B (debug-only) — ABANDONNÉ** : en debug `sub_pix` est constant sur les 200
  lignes (car `(M&~1)*8` est ×16 → `leftEdge mod 16 = base mod 16`), donc on pourrait
  hoister le décode sub_pix + simplifier `LE = base_chunk − (M>>1)`. **Non retenu** : ne
  profite qu'au debug (en normal `neg_product` varie → `sub_pix` varie). L'utilisateur ne
  veut optimiser que ce qui impacte le **jeu final**.
- **Lead C** : pour les lignes entièrement hors écran (clamp tout-herbe), brancher vers
  une routine « herbe seule » en **sprite compilé** (comme les bordures noires) sans
  toucher les buffers. À CONFIRMER d'abord : ce cas arrive-t-il vraiment **au runtime du
  jeu** (amplitude réelle de la projection) ? Pas certain → vérifier l'amplitude avant.

---

## 8. Gotchas & faits techniques

- **lwasm 4.24** : `fcb X,Y` OK mais `fcb X, Y` (**espace après virgule dans l'opérande**)
  plante « Bad expression ». Pas de parenthèses imbriquées en opérande immédiate
  (précalculer via EQU).
- **Branches** : si une boucle dépasse ±127 oct, `bra`→`lbra` (cf. MainLoop debug).
- **« Miroir » du leftEdge** : à cause de l'ordre des `pshu` (l'herbe gauche `J'` se
  dessine côté adresses hautes), l'écran est inversé par rapport à `leftEdge`. **Ne pas
  se fier à une dérivation analytique du sens** — valider via la trace. Sens validé :
  `leftEdge = base − offset`, RIGHT → route à droite ; `sub_pix=8` → route centrée px 80.
- **Réserve centrage mode normal** : `DFR_SCREEN_CENTER=88` centre la route droite à
  l'écran px 80 (centre géométrique), valeur **validée en debug** (trace). Le 68k centre
  à `$90/2 = 72` (légèrement à gauche). Si on veut le décentrage 68k exact, ajuster la
  constante — **idéalement avec une trace du MODE NORMAL** (jamais capturée ; seul le
  debug l'a été). À valider visuellement après le prochain `./build.sh`.
- **Cohérence des 2 modes** : `DrawFrameRoad.asm` est partagé. Le debug hardcode son
  centre (`ldd #88`) ; le normal utilise `DFR_SCREEN_CENTER` (=88). Les 2 utilisent le
  même `DFR_dispatch_and_draw`, `DFR_subpix_tbl`, convention `U=−2`, et fix parité.

---

## 9. Outils & docs

- `tools/verify_dispatch_coverage.py` — vérifie que les 66 routines (K',J') couvrent
  toute l'amplitude (0 trou, 0 débordement cœur).
- `tools/compile_road_sprites.py` — générateur (fixes #5, #6 dedans).
- `tools/oracle_road_position.py`, `tools/render_road_frame.py`,
  `tools/extract_road_draw_position.py` — oracles/raster BM16 (analyse position route).
- Doc fond : `lotus-ste/doc/extraction/41_road_render_ST_vs_STE.md` (méthodes de rendu
  ST procédural vs patch STE, débunk du « dither », raster palette statique/circuit).
- Mémoire persistante (faits clés) : voir `spaces/.../memory/` (TO8 VRAM, golden rules,
  road subpixel, leftEdge positioning, lotus road render methods).

### Analyse trace — snippet de profilage par zone (réutilisable)
```python
import re, collections
rx=re.compile(r"^([0-9A-F]{4}) .*?\s(\d+)\s+(\d+)\s+D=")
by=collections.Counter(); tot=0
for ln in open("dist/dcmoto_trace.txt",errors="replace"):
    m=rx.match(ln)
    if m: pc=int(m.group(1),16); c=int(m.group(2)); by[pc]+=c; tot+=c
# agréger par plage : DFR_dispatch_and_draw $8F7D-$9031, boucle $9032-$90EE, etc.
```
Reconstruction VRAM depuis les `pshu` (pour vérifier les pixels d'une ligne) : parser
`PSHU` (opérandes → octets `[A,B,Xhi,Xlo(,Yhi,Ylo)]` à `[U..U+n]`), prendre la 1re
écriture par adresse, décoder `RAMA[k]=px(4k,4k+1)`, `RAMB[k]=px(4k+2,4k+3)`.
