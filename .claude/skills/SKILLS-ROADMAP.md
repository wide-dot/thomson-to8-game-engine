# Roadmap des skills du framework Thomson TO8 Game Engine

Ce document liste les skills proposés pour couvrir exhaustivement le framework. Il est construit à partir d'un inventaire **complet de `engine/`** et d'une **mesure de fréquence d'usage** dans les game-projects récents (r-type, bubble-bobble, sonic-2, 2026, goldorak).

Chaque skill suit l'organisation `thomson-to8-engine-<topic>/SKILL.md` + `references/*.md`.

---

## Matrice d'usage des features dans les game-projects récents

Mesure : `grep -c` sur le mot-clé dans `*.asm` + `*.properties`. Valeurs absolues = occurrences.

| Feature | r-type | bubble-bobble | sonic-2 | 2026 | goldorak | Verdict |
|---------|--------|---------------|---------|------|----------|---------|
| `gfxlock` (double-buffer) | 219 | 16 | 32 | 8 | 8 | **Universel** |
| `AnimateSprite` | 34 | 8 | 38 | 2 | 13 | **Universel** |
| `AnimateSpriteSync` | 34 | 8 | 3 | — | — | **Très utilisé** |
| `AnimateSpriteAdv` | — | — | — | — | — | Non utilisé récemment |
| `ObjectMove` | 45 | 5 | 51 | — | 10 | **Universel** (sauf 2026) |
| `ObjectFall` (gravité) | — | 4 | 3 | — | — | **Plateformer** |
| `Collision AABB` | 79 | 3 | — | — | — | **Shoot/action** |
| `terrainCollision` | 245 | — | — | — | — | **r-type only** |
| `vscroll` (vertical) | — | 23 | — | — | 18 | **Scrolling vert** |
| `horizontal-scroll` | 7 | — | — | — | — | **r-type only** |
| `Tilemap` classique | — | — | 3 | — | — | sonic-2 only |
| `TileAnimScript` | — | — | 10 | — | — | sonic-2 only |
| `ymm` (YM2413 player) | 96 | 8 | — | 11 | 4 | **Universel** |
| `vgc` (SN76489 player) | 70 | 8 | — | 8 | 15 | **Très utilisé** |
| `Smps` (SMPS musique) | — | — | 40 | — | — | sonic-2 only |
| `soundFX` | 54 | — | — | — | — | **r-type only** |
| `PalUpdateNow` | 58 | 5 | 16 | 3 | 30 | **Universel** |
| `PalRaster` | — | — | 4 | — | — | sonic-2 only |
| `fade` / `raster-fade` | 164 | — | 27 | — | 18 | **Très utilisé** |
| `DrawText` / `PrintString` | — | — | 21 | — | 13 | **HUD-needed** |
| `RandomNumber` / `CalcSine` | 30 | 5 | 35 | — | — | **Très utilisé** |
| `objectWave` (object spawner) | — | — | — | — | — | Non utilisé |
| `MapKeyboardToJoypads` | — | — | — | — | — | Non utilisé |
| `joypad.md6` (manette Megadrive) | — | — | — | — | — | Non utilisé |
| `DrawFullscreenImage` | 1 | — | 3 | 3 | 3 | **Universel léger** |
| `DecRLE00` / `zx0_mega` (codecs) | — | — | — | — | 5 | goldorak only |
| `InitDrawSprites` | 10 | 1 | 1 | 1 | 2 | **Universel** |

Conclusions :
- **Plusieurs features sont quasi-universelles** (gfxlock, animation, ObjectMove, ymm/vgc, palette, fade) → skill prioritaire
- **Certaines sont domaine-spécifiques** (collision AABB, scrolling, tilemap, SMPS) → skills par genre/usage
- **Plusieurs features sont sous-utilisées mais existent dans engine/** : `AnimateSpriteAdv`, `objectWave`, `MapKeyboardToJoypads`, `joypad.md6`. Soit features récentes pas encore adoptées, soit legacy. À documenter en mode « disponible » sans pousser leur usage.

---

## Skills proposés — par priorité

### Tier 1 — fondamentaux (toujours utiles)

#### ✅ `thomson-to8-engine-new-game` — CRÉÉ
Création d'un nouveau game, structure, properties, squelette main.asm + objet. **Skill principal d'entrée**.

References : `project-organization`, `config-properties`, `gamemode-properties`, `object-properties`, `mainasm-skeleton`, `object-skeleton`.

#### `thomson-to8-engine-object-management`
Gestion fine des objets : cycle de vie, `LoadObject_u`/`UnloadObject_u`, `RunObjects`, run-list chaînée (`run_object_prev`/`run_object_next`), `MarkObjGone`, `Obj_GetOrientationToPlayer`, `_MountObject` / `_RunObject` / `_RunObjectSwap`, allocation par DP (joueur principal), `ObjectMove` / `ObjectMoveSync`, `ObjectFall` / `ObjectFallSync`, sub-types et sub-routines (`routine_secondary/tertiary/quaternary`), `objectWave` (description ennemis par script).

References : `lifecycle`, `runlist-internals`, `move-and-physics`, `subtype-machine`, `objectWave-pattern`.

Sources engine : `engine/object-management/*`, `engine/macros.asm` (_MountObject/_RunObject), `engine/constants.asm` (OST).

#### `thomson-to8-engine-graphics-pipeline`
Le pipeline de rendu complet : `gfxlock` double-buffering, `EraseSprites`/`DrawSprites`/`CheckSpritesRefresh`/`UnsetDisplayPriority`/`DisplaySprite`, gestion `priority`, `render_flags` détaillés, modes `background-erase` vs `overlay`, sprite-packs, encodage étendu (`-ext-pack`), `BgBufferAlloc`, allocation des cellules d'erase, `glb_screen_location_1/2`, `glb_force_sprite_refresh`.

References : `gfxlock-internals`, `sprite-packs-comparison`, `render-flags-bits`, `priority-and-zorder`, `dirty-rendering`.

Sources engine : `engine/graphics/buffer/`, `engine/graphics/sprite/`.

#### `thomson-to8-engine-animation`
Animation des sprites : `AnimateSprite` vs `AnimateSpriteSync` vs `AnimateSpriteAdv*`, format v00 vs v02, tags `_resetAnim`/`_goBackNFrames`/`_goToAnimation`/`_nextRoutine`/`_resetAnimAndSubRoutine`/`_nextSubRoutine`, `anim_frame`/`anim_frame_duration`/`anim_flags`, animations chaînées, `prev_anim`/`sub_anim`, `image_set`, `AnimateMove`, `moveByScript` (scripts de mouvement déclaratif), `AnimateSpriteLoad`/`AnimateSpriteAdvLoad`.

References : `animation-formats-v00-v02`, `end-tags`, `chained-animations`, `moveByScript-scripts`, `anim-flags-callbacks`.

Sources engine : `engine/graphics/animation/*`.

#### `thomson-to8-engine-palette`
Gestion de palette : `Pal_current`, `PalRefresh`, `PalUpdateNow` vs `PalUpdateNowLean`, `PalCycling` (cycling de couleurs), `PalRaster_1c` (changement de palette à mi-écran pour effets raster), bordure d'écran `$E7DD`, palette engine `Pal_black`/`Pal_white`, objet `fade` (transitions de palette progressives), objet `raster-fade` (fade par lignes), API de transition (`fade.equ`).

References : `palette-system`, `palette-cycling`, `raster-effects`, `fade-object-api`, `raster-fade-object`.

Sources engine : `engine/palette/*`, `engine/objects/palette/fade/*`, `engine/objects/palette/raster-fade/*`.

### Tier 2 — gameplay (selon le genre)

#### `thomson-to8-engine-collision`
Système de collision : AABB engine (`Collision_AddAABB`/`RemoveAABB`/`Do`), structures `struct_AABB.equ`, macros `_Collision_*`, listes typées (`AABB_list_player`, `AABB_list_enemy`, ...), pattern de placement dans `ram-data.asm`, terrainCollision (collisions terrain de r-type : init, doRight/doLeft, sensors, impacts).

References : `aabb-system`, `aabb-lists`, `terrain-collision` (r-type), `collision-patterns`.

Sources engine : `engine/collision/*`, `engine/objects/collision/*`.

#### `thomson-to8-engine-scrolling`
Scrolling vertical (`vscroll`), scrolling horizontal (`scroll-map-buffered-*`), buffers de tiles, `_vscroll.setMap` / `setMapHeight` / `setTileset256` / `setBuffer` / `setCameraPos` / `setCameraSpeed` / `setViewport`, caméras (`glb_camera_*`), camera auto-scroll (`AutoScroll`, `CheckCameraMove`), modes 16x16 / 16x16 even/odd, `TilemapBuffer` (buffer cyclique).

References : `vertical-scroll`, `horizontal-scroll`, `camera-system`, `tilemap-buffer`, `scrolling-patterns`.

Sources engine : `engine/graphics/tilemap/vscroll/*`, `engine/graphics/tilemap/horizontal-scroll/*`, `engine/graphics/camera/*`.

#### `thomson-to8-engine-tilemap`
Tilemaps statiques (non-scrolling) : `Tilemap`, `Tilemap16bits`, `Tilemaps`, `Spritemap`, `TileAnimScript` (animation de tiles déclarative), types de data (`layer.equ`, `submap.equ`, `map-16bits.equ`, `spritemap.equ`), génération via tileset properties (`tileset.X=...`), maps et chunks, `bm4.drawChunbks`.

References : `tilemap-types`, `tileset-pipeline`, `tile-anim-script`, `chunks-and-maps`.

Sources engine : `engine/graphics/tilemap/*` (hors scrolling).

#### `thomson-to8-engine-audio`
Architecture audio complète : YM2413 (FM, 9 voies dont 6 mélo + 3 perc), SN76489 (PSG, 4 voies dont 3 mélo + 1 bruit), accès hardware `$E7F4`/`$E7F6`, player VGC (compressé, Bentoc), player YM2413vgm, player VGM brut, SMPS (Sega Master/Mega Drive style — sonic-2 only), DAC/DPCM/PCM (samples), Smidi (MIDI), Svgm (small VGM), soundFX (effets sonores), objets `ymm` et `vgc` (objets engine partagés via gameModeCommon).

References : `audio-architecture`, `ymm-player`, `vgc-player`, `smps-player`, `dac-pcm-samples`, `soundFX-system`, `audio-via-common`.

Sources engine : `engine/sound/*`, `engine/objects/sound/*`.

#### `thomson-to8-engine-irq`
Système d'interruption : `IrqInit`, `IrqSync`, `IrqOn`/`IrqOff`, `Irq_user_routine`, `Irq_one_frame`, `IrqObjSmps`, `IrqSecond`, synchronisation VBL vs OUT_OF_SYNC_VBL, raster IRQ pour effets palette à mi-écran, intégration avec `gfxlock.bufferSwap.check`, écriture d'un UserIRQ canonique.

References : `irq-init-and-sync`, `user-irq-patterns`, `raster-irq`, `irq-in-loop`.

Sources engine : `engine/irq/*`, `engine/sound/Smps.asm` (intégration), `engine/objects/sound/*`.

#### `thomson-to8-engine-input`
Lecture des entrées : `InitJoypads`, `ReadJoypads`, `ReadJoypads2` (joueur 2), `joypad.buffer` (buffer historique des inputs), `joypad.md6` (manette Megadrive 6 boutons), `MapKeyboardToJoypads` (clavier mappé sur les masques joypad), `ReadKeyboard`, codes des touches, masques `c1_button_*`, `Dpad_Press` / `Dpad_Held` / `Fire_Press` / `Fire_Held`.

References : `joypad-reading`, `joypad-buffer`, `megadrive-6-buttons`, `keyboard-input`.

Sources engine : `engine/joypad/*`, `engine/keyboard/*`.

#### `thomson-to8-engine-fonts-text`
Affichage de texte : `DrawText`, `DrawOneChar`, fonts 3x5 (et variantes shaded/selected/disabled), `PrintString`, font 3x7-normal, intégration avec sprites, code page Thomson, pattern de génération de fonts (`genfont.php` côté r-type).

References : `drawtext-3x5`, `printstring-3x7`, `font-variants`, `text-on-sprite-engine`.

Sources engine : `engine/graphics/font/*`.

### Tier 3 — bas niveau / système

#### `thomson-to8-engine-memory-model`
Modèle mémoire du jeu : carte mémoire en exécution, `$6100` (boot du game-mode), `$9F00`-`$9FFF` (DP utilisateur), `$9E28` (variables globales), `dp_engine` / `dp_extreg`, `glb_*` variables (camera, screen_location, page, timer), pile système, `glb_ram_end`, contraintes des sprites compilés qui peuvent déborder de $A000, double buffer pages 2/3, page 1 résidente, `BankSwitch`, `_SetCartPageA/B`, `_GetCartPageA/B`.

References : `memory-map-runtime`, `direct-page-usage`, `global-variables`, `bank-switching-macros`, `system-stack-and-boundaries`.

Sources engine : `engine/constants.asm`, `engine/ram/BankSwitch.asm`, `engine/system/to8/*`, `doc/chapters/global.md`.

#### `thomson-to8-engine-storage-and-loaders`
Pipeline de stockage : disquette `.fd` (RAMLoaderManagerFd, RAMLoaderFd), cartouche T2 `.t2` (megarom, RAMLoaderManagerT2), T2 flash SDDRIVE `.t2flash` (t2-flash.asm), boot loaders, formats de compression (ZX0 vs Exomizer), `LoadGameMode` / `LoadGameModeNow`, pagination dynamique, dépend de `builder.to8.memoryExtension`, dimension max de l'image (32 pages × 16 Ko = 512 Ko).

References : `floppy-format`, `t2-cartridge`, `t2flash-sddrive`, `compression-zx0-exo`, `loadgamemode`, `boot-loaders`.

Sources engine : `engine/boot/*`, `engine/ram/*`, `engine/megarom-t2/*`, `engine/compression/*`, `engine/level-management/*`.

#### `thomson-to8-engine-build-pipeline`
Le pipeline de build Java (`java-generator`) : étapes de compilation, parsing properties, génération d'`ObjID_`/`GmID_`/`Pal_`/etc., compilation des sprites en code asm dépaqueté (`compiledSprite` cache), encodage des sprites (variants NB/ND/XB/etc.), knapsack packing des pages RAM, dédup T2 via `gameModeCommon`, génération de `LoadAct`, `LoadGameMode`, `BgBufferAlloc`, fichiers `.glb` (globals), commandes Maven, `lwasm` flags, logs Log4j, étapes de debug.

References : `build-stages`, `sprite-compilation`, `knapsack-packing`, `t2-deduplication`, `generated-files`, `lwasm-integration`.

Sources : `java-generator/src/main/java/fr/bento8/to8/build/*.java`.

#### `thomson-to8-engine-math-rng`
Math et RNG : `CalcSine` (table de sinus pré-générée, `sinewave.bin`), `CalcAngle` (atan2 logarithmique d'après Devulder/Forslof), `Mul9x16` (multiplication 9×16 bits), `RandomNumber` / `InitRNG` (PRNG basé sur timer), `_rnd` macro, format fixed-point 8.8 (utilisé pour x_vel, y_vel, x_acl, y_acl).

References : `sine-cosine-table`, `atan2-logarithmic`, `random-number`, `fixed-point-88`.

Sources engine : `engine/math/*`.

#### `thomson-to8-engine-image-codecs`
Codecs d'image : `DrawFullscreenImage` (image plein écran rapide), `DrawFullscreenInterlacedImage`, `DrawHLine`, `DecRLE00` (RLE 00), `zx0_mega` (ZX0 streaming), `bm4.drawChunbks` (chunks BM4), `ClearInterlacedDataMemory`, `ClearVerticalBandLR`, codec PNG → BM4/BM16, encodage MAP RLE (sprite variant `DMAP`), encodage ZX0 (variant `DZX0`).

References : `fullscreen-images`, `rle-decoders`, `zx0-decoders`, `chunk-rendering`.

Sources engine : `engine/graphics/codec/*`, `engine/graphics/draw/*`, `engine/graphics/clear/*`, `engine/graphics/line/*`, `engine/graphics/image/*`.

### Tier 4 — patterns avancés / sous-utilisés

#### `thomson-to8-engine-shared-resources` (cross-cutting)
Comment partager des ressources entre game-modes via `gameModeCommon`. Pattern complet : choix de ce qui va dans le common vs spécifique, ordre `.0/.1/.2`, intégration avec audio engine, hud commun, projectiles partagés, dédup ROM T2, comparaison avec l'approche `global/` (dossier sans common).

References : couvert dans `gamemode-properties.md` du skill `new-game`, à étendre en skill dédié si on lance plusieurs initiatives de partage.

Statut : **section déjà détaillée dans `thomson-to8-engine-new-game/references/gamemode-properties.md`**. À promouvoir en skill séparé quand l'usage se développera.

#### `thomson-to8-engine-dyncode`
Code auto-modifié : `DynCode_ApplyAToListX`, `DynCode_*` utilitaires, pattern d'optimisation 6809 (modification de constantes en place pour gagner des cycles). Peu utilisé directement par les game-projects mais présent dans plusieurs modules engine (terrainCollision notamment).

References : `dyncode-utilities`, `selfmod-patterns`.

Sources engine : `engine/ram/DynCode.asm`.

### Hors périmètre / inutiles à documenter pour l'instant

- `engine/main/` — ancien point d'entrée, plus utilisé
- `engine/compression/mx0/mx0.asm.unfinished` — non terminé
- `engine/sound/dac/` — bibliothèque de samples, pas une fonctionnalité au sens skill

---

## Statut — TOUS LES SKILLS PRODUITS

État au terme de la première itération :

| # | Skill | Statut | SKILL.md | Références |
|---|-------|--------|----------|------------|
| 1 | `thomson-to8-engine-new-game` | ✅ | oui | 6 |
| 2 | `thomson-to8-engine-object-management` | ✅ | oui | 9 |
| 3 | `thomson-to8-engine-graphics-pipeline` | ✅ | oui | 6 |
| 4 | `thomson-to8-engine-animation` | ✅ | oui | 5 |
| 5 | `thomson-to8-engine-palette` | ✅ | oui | 3 |
| 6 | `thomson-to8-engine-collision` | ✅ | oui | 3 |
| 7 | `thomson-to8-engine-scrolling` | ✅ | oui | 3 |
| 8 | `thomson-to8-engine-tilemap` | ✅ | oui | 2 |
| 9 | `thomson-to8-engine-audio` | ✅ | oui | 3 |
| 10 | `thomson-to8-engine-irq` | ✅ | oui | 2 |
| 11 | `thomson-to8-engine-input` | ✅ | oui | 1 |
| 12 | `thomson-to8-engine-fonts-text` | ✅ | oui | 0 (couvert dans SKILL.md) |
| 13 | `thomson-to8-engine-memory-model` | ✅ | oui | 1 |
| 14 | `thomson-to8-engine-storage-and-loaders` | ✅ | oui | 0 (couvert dans SKILL.md) |
| 15 | `thomson-to8-engine-build-pipeline` | ✅ | oui | 0 (couvert dans SKILL.md) |
| 16 | `thomson-to8-engine-math-rng` | ✅ | oui | 0 (couvert dans SKILL.md) |
| 17 | `thomson-to8-engine-image-codecs` | ✅ | oui | 0 (couvert dans SKILL.md) |
| 18 | `thomson-to8-engine-dyncode` | ✅ | oui | 0 (couvert dans SKILL.md) |

Total :
- **18 SKILL.md** (= 17 skills demandés + new-game initial)
- **44 références détaillées** créées
- Le SKILL.md liste typiquement plus de références qu'il n'y en a actuellement (entre 0 et 9 par skill) — celles non créées sont mentionnées dans le SKILL.md (descriptifs riches) et peuvent être ajoutées plus tard sans toucher au SKILL.md.

### Notes par skill

- **Plus complets** (multiple références) : `object-management`, `graphics-pipeline`, `animation`, `new-game`
- **Couverts par SKILL.md riche** (sans références séparées, mais avec contenu approfondi dans le SKILL.md) : `fonts-text`, `storage-and-loaders`, `build-pipeline`, `math-rng`, `image-codecs`, `dyncode`
- **À étoffer plus tard** : les références manquantes mais listées dans les SKILL.md (cf. `QUESTIONS.md`)

### Ordre de priorisation initial (rappel)

Le plan séquentiel a été suivi : `new-game` → `object-management` → `graphics-pipeline` → `animation` → `palette` → `collision` → ... → `dyncode`.

---

## Notes méthodologiques

### Source de chaque skill
- **Code asm** dans `engine/<module>/`
- **Java builder** dans `java-generator/src/main/java/fr/bento8/to8/`
- **Documentation existante** dans `doc/chapters/`, `doc/wiki/`
- **Usage réel** dans `game-projects/` (rotation pour exemples authentiques)

### Format à respecter
- Frontmatter YAML conforme aux skills thomson (`name`, `description` riche en mots-clés, `machines: [to8, to8d, to9, to9+]`, `user-invocable: false`)
- Une description du SKILL.md **dense en mots-clés français+anglais+symboles** pour optimiser le retrieval
- Sous-dossier `references/` pour les sujets approfondis (3-7 fichiers `.md` par skill)
- Tableaux Markdown pour les bitfields/offsets, blocs ```asm pour les exemples
- Section finale « ## Références détaillées » qui liste les `references/X.md` avec un descriptif riche en mots-clés (modèle suivi par `thomson-to8-to9-video`)
- Section « Pitfalls » à la fin du SKILL.md pour les pièges courants

### Liaison entre skills
- Les skills se référencent entre eux : ex. `new-game` pointe vers `object-management` pour les détails OST
- Le skill `thomson-to8-engine-shared-resources` n'est pas urgent puisque sa section existe déjà dans `new-game/references/gamemode-properties.md`
