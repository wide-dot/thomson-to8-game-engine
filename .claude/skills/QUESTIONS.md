# Questions ouvertes — à valider avec l'utilisateur

Fichier alimenté au fil de la rédaction des skills. Chaque entrée précise le contexte et le skill concerné.

---

## Q1 — `MainCharacter` / `Sidekick` (skill object-management)

`Obj_GetOrientationToPlayer` (engine/object-management/Obj_GetOrientationToPlayer.asm) référence des symboles `MainCharacter` et `Sidekick` qui ne sont **pas définis dans engine/**. Ce sont des conventions à mettre en place dans le code du game-mode (typiquement des pointeurs vers les OST des joueurs 1 et 2).

**Question** : faut-il documenter la convention attendue (ex: `MainCharacter equ player1` pour solo, `Sidekick equ player2` pour coop) ? Ou laisser comme un détail à charge du projet ? Pour l'instant documenté brièvement, à compléter selon la pratique.

## Q2 — `respawn_index` offset (skill object-management)

`MarkObjGone*` utilise `respawn_index,u` mais ce champ n'a pas d'offset standard dans `engine/constants.asm`. Convention :
- Le champ doit être déclaré dans le projet (dans `ext_variables_size`)
- Pas de macro/equ standard pour son offset
- Cf. r-type qui utilise `respawn_index equ ext_variables+X` pour son offset

**Question** : faut-il pousser une convention engine (ex: `respawn_index equ ext_variables`) ? Pas urgent.

## Q3 — `animate-internals.md` non écrit (skill animation)

Le SKILL.md liste 6 références mais une (`animate-internals.md`) n'a pas été créée car son contenu (résolution `anim,u`, `Ani_Asd_Index`, application `status_flags`) est déjà couvert dans `animate-routines.md` et `animation-formats.md`. À écrire si l'utilisateur veut une ressource dédiée à la mécanique interne, sinon les autres suffisent.

## Q4 — Références non écrites par skill (récap exhaustif)

Pour optimiser le temps de la première itération, certaines références listées dans les SKILL.md n'ont pas été créées séparément — leur contenu est intégré au SKILL.md lui-même. Référence à compléter plus tard si besoin :

- **animation** : `animate-internals.md` (déjà couvert ailleurs)
- **palette** : `palette-cycling.md`, `raster-fade-object.md`, `screen-border.md`
- **collision** : `collision-patterns.md`
- **scrolling** : (toutes faites)
- **tilemap** : `spritemap.md`, `tileset-pipeline.md`
- **audio** : `dac-pcm-samples.md`, `audio-via-common.md`
- **irq** : `raster-irq.md`
- **input** : `joypad-buffer.md`, `megadrive-6-buttons.md`, `keyboard-input.md`
- **fonts-text** : `drawtext.md`, `printstring.md`
- **memory-model** : `memory-map-runtime.md`, `direct-page-usage.md`, `global-variables.md`, `system-stack-and-boundaries.md`
- **storage-and-loaders** : `boot-loaders.md`, `ram-loader-manager.md`, `compression-zx0-exo.md`, `load-game-mode.md`
- **build-pipeline** : `build-stages.md`, `knapsack-packing.md`, `t2-deduplication.md`
- **math-rng** : `sine-cosine-table.md`, `atan2-logarithmic.md`, `random-number.md`, `fixed-point-88.md`
- **image-codecs** : `fullscreen-images.md`, `rle-decoders.md`, `zx0-decoders.md`, `clear-routines.md`
- **dyncode** : `dyncode-utilities.md`, `selfmod-patterns.md`

Les SKILL.md décrivent ces sujets de manière approfondie — les références séparées seraient pour aller encore plus en détail.

## Q5 — Frontmatter `machines`

Tous les skills ont `machines: [to8, to8d, to9, to9+]`. Cohérent avec le périmètre de l'engine. Question : faut-il distinguer plus finement (e.g. extension RAM 512 Ko seulement TO8) ? Pour l'instant uniforme.

## Q6 — Tests / évaluation des skills

Aucune évaluation systématique faite. Pour valider qu'un skill est bien indexé/récupéré par retrieval, il faudrait tester une question type "Comment X ?" et vérifier que le bon skill est sélectionné. À faire dans une phase ultérieure (via `anthropic-skills:skill-creator` qui propose des évaluations).

## Q7 — École goldorak (macros engine)

L'utilisateur a indiqué qu'il commençait à porter les macros style goldorak (`_gameMode.init`, `_objectManager.new.u`, `_music.init.*`) côté `engine/`. Quand ce sera plus avancé, plusieurs skills devront être mis à jour pour les mentionner comme alternative au pattern verbeux actuel :
- `new-game` (squelette main.asm avec macros)
- `object-management` (`_objectManager.new.*`)
- `audio` (`_music.init.*`)

Pas urgent — à reprendre quand les macros seront stabilisées.

## Q8 — `gameModeCommon` à promouvoir en skill séparé ?

Pour l'instant `gameModeCommon` est documentée dans `new-game/references/gamemode-properties.md` (section approfondie). Quand l'usage se développera, peut devenir un skill séparé `thomson-to8-engine-shared-resources` qui couvre :
- Patterns de partage audio/HUD/projectiles
- Comparaison avec dossier `global/`
- Optimisation ROM T2
- Migration progressive de la duplication vers gameModeCommon

À planifier après que r-type ait commencé à l'utiliser.

---
