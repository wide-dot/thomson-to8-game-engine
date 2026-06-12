---
name: thomson-to8-engine-new-game
description: "Décrit la création d'un nouveau jeu dans game-projects/ avec le Thomson TO8/TO9 game engine (Bento8 / wide-dot) : organisation des dossiers, fichiers de configuration .properties (projet, game-mode, objet), squelette du main.asm (point d'entrée $6100, double buffering gfxlock, IRQ utilisateur, allocation dynamique d'objets), squelette d'un objet (table de routines, jump table indirect, AnimateSprite, DisplaySprite), conventions de palette et d'act, déclaration RAM (Dynamic_Object_RAM, nb_dynamic_objects, ext_variables_size), pipeline de compilation par le java-generator BuildDisk. Utiliser lors de la création d'un nouveau game-project, de l'ajout d'un nouveau game-mode (titre, niveau, écran de chargement), de l'ajout d'un nouvel objet (joueur, ennemi, projectile, décor, HUD), de la configuration des cibles fd/t2/t2flash (disquette, cartouche megarom T2, cartouche flash SDDRIVE), du choix d'un sprite-pack (background-erase, overlay, ext-pack), de la définition d'animations (v00 simple ou v02 advanced avec durée et flags par frame), ou du paramétrage du builder LWASM (pragma, includeDirs, define, debug, useCache, maxTries). Mots-clés : game-projects, config-windows.properties, config-macos.properties, config-linux.properties, main.properties, gameModeBoot, gameMode.X, engine.asm.boot.fd, engine.asm.boot.t2, engine.asm.boot.t2flash, engine.asm.RAMLoader.fd, engine.asm.RAMLoaderManager, builder.lwasm, builder.diskName, builder.t2Name, builder.generatedCode, builder.constAnim, builder.to8.memoryExtension, builder.compilatedSprite, engine.asm.mainEngine, object.X, palette.X, actBoot, act.X.palette, act.X.screenBorder, act.X.backgroundImage, act.X.backgroundSolid, act.X.objectPlacement, gameModeCommon, code=, common-code=, sprite.X, animation.X, animation-data, sound.X, data.X, tileset.X, spriteIndex, animationIndex, RAM, NB0, NB1, ND0, ND1, XB0, XB1, YB0, YB1, XYB0, XYB1, DMAP, DZX0, _full, _autopal, _resetAnim, _goBackNFrames, _goToAnimation, _nextRoutine, _resetAnimAndSubRoutine, _nextSubRoutine, InitGlobals, InitStack, InitDrawSprites, LoadAct, IrqInit, IrqSync, IrqOn, Irq_user_routine, Irq_one_frame, UserIRQ, gfxlock, _gfxlock.init, _gfxlock.on, _gfxlock.off, _gfxlock.loop, gfxlock.bufferSwap, EraseSprites, DrawSprites, CheckSpritesRefresh, UnsetDisplayPriority, AnimateSprite, AnimateSpriteSync, DisplaySprite, RunObjects, LoadObject_u, LoadObject_x, UnloadObject_u, ObjID_, GmID_, Pal_, Ani_, Img_, Bgi_, _MountObject, _RunObjectSwap, routine,u, id,u, subtype,u, anim,u, priority,u, render_flags,u, status_flags,u, x_pos, y_pos, x_pixel, y_pixel, xy_pixel, x_vel, y_vel, Dynamic_Object_RAM, nb_dynamic_objects, nb_graphical_objects, ext_variables_size, object_size, AABB_lists, AABB_list, $6100, $9F00, sprite-background-erase-pack, sprite-background-erase-ext-pack, sprite-overlay-pack, ZX0, Exomizer, knapsack, LWASM, fd, t2, T2 flash, SDDRIVE."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Créer un nouveau game dans le framework Bento8 / wide-dot (Thomson TO8/TO9)

Ce skill explique comment créer un **nouveau jeu** dans le repo `thomson-to8-game-engine` selon les conventions actuelles du framework. Il décrit la structure de dossiers, les fichiers `.properties` à fournir, et le squelette ASM 6809 à écrire.

Pour des informations exhaustives sur chaque fichier ou syntaxe, voir les références listées en fin de page.

---

## Vue d'ensemble — anatomie d'un game-project

Tout jeu vit dans `game-projects/<nom-du-jeu>/`. La structure canonique est :

```
game-projects/<nom-du-jeu>/
├── config-windows.properties        ← configuration du build (obligatoire)
├── config-macos.properties          ← variante optionnelle
├── config-linux.properties          ← variante optionnelle
├── config-windows.t2.properties     ← variante optionnelle pour cartouche T2
├── game-mode/
│   └── <mode>/
│       ├── main.properties          ← déclaration du game-mode
│       ├── main.asm                 ← code 6809 du game-mode (ORG $6100)
│       └── ram-data.asm             ← variables RAM, déclaration Dynamic_Object_RAM
└── objects/
    └── <objet>/
        ├── <objet>.properties       ← code, sprites, animations
        ├── <objet>.asm              ← code 6809 de l'objet (table de routines)
        └── image/                   ← PNG sources
```

Le **java-generator** (`java-generator/`, classe `BuildDisk`) lit le `config-<os>.properties`, parcourt récursivement les `main.properties` de chaque `gameMode.X`, puis chaque `object.X`, génère les constantes `ObjID_<nom>`, `GmID_<nom>`, `Ani_<nom>`, `Img_<nom>`, `Pal_<nom>`, `Bgi_<nom>`, compile les sprites en code 6809 dépaqueté, et empaquète tout dans une image disquette `.fd` ou cartouche `.t2`/`.t2flash`.

Pour la structure de dossiers et conventions de nommage en détail, voir [references/project-organization.md](references/project-organization.md).

---

## Les trois niveaux de fichiers `.properties`

### 1. Niveau projet : `config-<os>.properties`

À la racine du game-project. Définit :

- les chemins vers le loader engine (`engine.asm.boot.fd/t2/t2flash`, `engine.asm.RAMLoader*`)
- le game-mode de démarrage (`gameModeBoot=...`) et la liste des game-modes (`gameMode.X=./game-mode/X/main.properties`)
- les paramètres du builder (`builder.lwasm`, `builder.diskName`, `builder.debug`, `builder.compilatedSprite.useCache`, etc.)

Voir [references/config-properties.md](references/config-properties.md) pour la liste exhaustive des ~25 clés acceptées.

### 2. Niveau game-mode : `game-mode/<mode>/main.properties`

Déclare un mode de jeu (titre, niveau, écran de chargement). Contient :

- le chemin du `main.asm` (`engine.asm.mainEngine=...`)
- la liste des objets actifs dans ce mode (`object.<Nom>=...`)
- la liste des palettes (`palette.Pal_<Nom>=...`)
- la définition des actes (sous-états sans rechargement disquette : `actBoot`, `act.<nom>.palette/screenBorder/backgroundImage/...`)

Voir [references/gamemode-properties.md](references/gamemode-properties.md).

### 3. Niveau objet : `objects/<objet>/<objet>.properties`

Déclare un objet (joueur, ennemi, décor, HUD). Contient :

- le chemin du code asm (`code=...`)
- les sprites (`sprite.Img_X=image.png;variants`)
- les animations (`animation.Ani_X=fps;Img_A;Img_B;_resetAnim`)
- optionnellement sons, données binaires, tilesets

Voir [references/object-properties.md](references/object-properties.md).

---

## Le code ASM 6809

### Squelette d'un game-mode (`main.asm`)

Le pattern de référence (école « code inliné classique » utilisée par `r-type`, `bubble-bobble`, `sonic-2`, `2026`) est :

```asm
        opt   c,ct

SOUND_CARD_PROTOTYPE equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"

        org   $6100

        jsr   InitGlobals
        jsr   InitDrawSprites
        jsr   InitStack
        jsr   LoadAct               ; généré par le builder à partir de actBoot

        ; allouer l'objet de départ
        jsr   LoadObject_u
        lda   #ObjID_<Player>
        sta   id,u

        ; configurer l'IRQ utilisateur
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn

MainLoop
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop

UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        rts

        INCLUDE "./game-mode/<mode>/ram-data.asm"

        ; routines moteur à inclure en queue (cf. référence)
        INCLUDE "./engine/InitGlobals.asm"
        ; ... etc
```

Voir [references/mainasm-skeleton.md](references/mainasm-skeleton.md) pour le squelette complet (toutes les includes engine, UserIRQ avec son, déclaration de `ram-data.asm`, variantes overlay/background-erase, etc.).

### Squelette d'un objet (`<objet>.asm`)

Tout objet suit cette structure :

```asm
        INCLUDE "./engine/macros.asm"

<Nom>                                  ; point d'entrée = nom exact de l'objet (camelcase ou PascalCase)
        lda   routine,u
        asla                           ; multiplie par 2 (table de fdb)
        ldx   #<Nom>_Routines
        jmp   [a,x]                    ; saut indirect

<Nom>_Routines
        fdb   Init                     ; routine 0
        fdb   Main                     ; routine 1
        ; ... autant de routines que nécessaire

Init
        ldd   #Ani_<defaultAnim>
        std   anim,u
        ldb   #4                       ; priorité d'affichage (1=front, 8=back)
        stb   priority,u
        ; Position centre du sprite — règle : center = ceil(taille/2)-1
        ; (cf. references/object-skeleton.md, point critique !)
        ldd   #$80AF                   ; position écran (x_pixel=$80, y_pixel=$AF)
        std   xy_pixel,u
        ; OBLIGATOIRE si le sprite est compilé en variant ND* (sans backup) :
        ; sinon l'engine cherche un erase qui n'existe pas → sprite invisible
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        inc   routine,u                ; passe en routine 1 au prochain RunObjects
        rts

Main
        ; logique frame par frame
        jsr   AnimateSprite
        jmp   DisplaySprite
```

Voir [references/object-skeleton.md](references/object-skeleton.md) pour les offsets OST (`x_pos`, `y_pos`, `x_vel`, `render_flags`, `status_flags`, `routine_secondary`, `anim_frame`, etc.), les variantes de boucle, les conventions d'`Init`/`Main`, la manipulation de l'AABB de collision, et les patterns Sync vs non-Sync.

---

## Workflow recommandé pour créer un nouveau jeu

1. **Copier un projet existant proche du besoin** (par exemple `game-projects/2026/` ou `game-projects/test/` pour un projet minimaliste) plutôt que partir d'une feuille blanche
2. **Renommer** les références : `builder.diskName`, `builder.t2Name`, les noms des game-modes (`gameModeBoot`, `gameMode.X`)
3. **Adapter `config-windows.properties`** : pointer les loader engine, fixer les paramètres builder, déclarer le ou les game-modes
4. **Créer le game-mode initial** : `main.properties` + `main.asm` + `ram-data.asm`
5. **Créer un premier objet minimal** (joueur ou décor) : `<obj>.properties` + `<obj>.asm` + un sprite PNG
6. **Lancer le build** Java :
   ```bash
   cd java-generator
   mvn clean compile assembly:single
   java -jar target/build-disk-*.jar ../game-projects/<nom>/config-windows.properties
   ```
7. **Tester** dans DCMOTO ou un émulateur (le `.fd` est dans `./dist/<diskName>.fd` du game-project)

---

## Conventions de nommage des constantes générées

Le builder crée automatiquement ces constantes à partir des entrées `.properties` :

| Préfixe | Source | Exemple |
|---------|--------|---------|
| `ObjID_<Nom>` | `object.<Nom>=...` dans `main.properties` | `ObjID_Player`, `ObjID_Bubble` |
| `GmID_<Nom>` | `gameMode.<Nom>=...` dans `config-<os>.properties` | `GmID_TitleScreen`, `GmID_level01` |
| `Pal_<Nom>` | `palette.<Nom>=...` dans `main.properties` | `Pal_background`, `Pal_black` |
| `Img_<Nom>` | `sprite.Img_<Nom>=...` dans l'`.properties` de l'objet | `Img_Player_Idle_001` |
| `Ani_<Nom>` | `animation.Ani_<Nom>=...` dans l'`.properties` de l'objet | `Ani_Player_Walk` |
| `Bgi_<actName>` | `act.<actName>.backgroundImage=...` | `Bgi_default`, `Bgi_titleScreen` |

Le nom dans le `.properties` est conservé tel quel — pas de transformation. La convention de fait dans le repo est **PascalCase** pour `ObjID_/GmID_`, **Pal_/Img_/Ani_** comme préfixe explicite.

---

## Pitfalls fréquents

- **`<addr` (Direct Page) dans le code main d'un game-mode** : DP n'est PAS positionné automatiquement dans le code résident. Toujours utiliser l'adressage étendu (`sta horizon_y` et pas `sta <horizon_y`) sauf si on a explicitement fait `tfr a,dp` juste avant. Le bug est silencieux : la donnée écrit en `(DP)*256+offset`, pas à l'adresse attendue. Cf. [references/mainasm-skeleton.md](references/mainasm-skeleton.md) section « Règle critique Direct Page ». Exception : dans `UserIRQ`, DP=$E7 garanti par le monitor → `<$DA`/`<$DB` etc. OK.
- **Sprite ND* sans `render_overlay_mask`** : le plus piégeux — sprite compilé en variant `ND0`/`ND1`/`XD*`/etc. (Normal Draw sans backup) ET `render_overlay_mask` non posé dans `render_flags,u` à l'init → le sprite est **invisible**, sans erreur. L'engine attend un code d'erase qui n'existe pas. Cf. [references/object-skeleton.md](references/object-skeleton.md) section « Règles critiques ».
- **Position d'un sprite calculée comme `taille/2`** : la convention CENTER utilise `ceil(taille/2)-1`, pas `taille/2`. Sprite 160 px centré X = `x_pixel = 79`, pas 80. Si erreur d'un pixel, peut faire déborder hors écran et l'engine **ne dessine pas du tout** (clipping out). Cf. [references/object-skeleton.md](references/object-skeleton.md).
- **`InitDrawSprites` manquant** : si on utilise `sprite-background-erase-pack` ou `-ext-pack`, l'appel à `InitDrawSprites` est obligatoire avant `LoadObject_u` (sinon les buffers d'effacement ne sont pas alloués).
- **`palette` manquante dans le `main.properties`** : le builder lève une exception « palette not found ». Au moins une `palette.Pal_X=...` est obligatoire.
- **Le `act` référencé par `actBoot` n'existe pas** : aucune erreur au build, mais `LoadAct` ne fera rien et l'écran restera noir.
- **Oubli d'`inc routine,u` dans `Init`** : l'objet reste bloqué en routine 0 et `Init` est rappelée à chaque frame.
- **`Dynamic_Object_RAM` sous-dimensionné** : si `nb_dynamic_objects` est trop petit, `LoadObject_u` retourne avec le flag Z mis (échec) ; toujours tester ce flag après l'appel.
- **`builder.to8.memoryExtension=N`** limite à 16 pages RAM (256 Ko). Mettre `Y` (32 pages / 512 Ko) pour tout jeu non-trivial, sauf si on cible une machine sans extension.

---

## Références détaillées

- [references/project-organization.md](references/project-organization.md) — Arborescence canonique, dossiers obligatoires/optionnels, conventions de nommage, `cfg/`, `global/`, `resources/`, `tmp/`, `generated-code/`, `dist/`
- [references/config-properties.md](references/config-properties.md) — Toutes les clés du `config-<os>.properties` : `engine.asm.boot.fd/t2/t2flash`, `engine.asm.RAMLoader*`, `gameModeBoot`, `gameMode.X`, `builder.lwasm/pragma/includeDirs/define`, `builder.debug/logToConsole/parallel`, `builder.diskName/t2Name/generatedCode/constAnim`, `builder.to8.memoryExtension`, `builder.compilatedSprite.useCache/maxTries`, `builder.exobin`, `builder.hxcfe`, variantes fd / t2 / t2flash
- [references/gamemode-properties.md](references/gamemode-properties.md) — `engine.asm.mainEngine`, `gameModeCommon.<n>`, `object.<Nom>`, `palette.<Nom>`, `actBoot`, `act.<nom>.palette/screenBorder/backgroundImage/backgroundSolid/objectPlacement`, sémantique de l'Act, ordre d'attribution des `ObjID_`
- [references/object-properties.md](references/object-properties.md) — `code`, `common-code`, `sprite.X=file;variants;RAM` avec syntaxe complète (`NB0,NB1,ND0,ND1,XB0,XB1,YB0,YB1,XYB0,XYB1,DMAP,DZX0`, ref image, `:` autopal, `_full`/_autopal), `animation.X` v00 et v02, `animation-data`, `sound.X`, `data.X`, `tileset.X=file;nb,cols,rows,centerMode,mapFile,mapBitDepth`, `spriteIndex=RAM`, `animationIndex=RAM`
- [references/mainasm-skeleton.md](references/mainasm-skeleton.md) — Squelette `main.asm` complet école 2 (`gfxlock`+IRQ+LoadObject_u), variantes avec/sans musique YM2413+SN76489, choix du sprite-pack (`sprite-background-erase-pack` vs `-ext-pack` vs `sprite-overlay-pack`), section UserIRQ canonique, déclaration `ram-data.asm`, includes engine recommandées et leur ordre
- [references/object-skeleton.md](references/object-skeleton.md) — Squelette d'objet (entry point + jump table), offsets OST `id`/`subtype`/`render_flags`/`status_flags`/`priority`/`anim`/`anim_frame`/`anim_frame_duration`/`anim_flags`/`x_pos`/`y_pos`/`xy_pixel`/`x_pixel`/`y_pixel`/`x_vel`/`y_vel`/`routine`/`routine_secondary`/`routine_tertiary`/`routine_quaternary`, conventions Init/Main, `AnimateSprite` vs `AnimateSpriteSync`, `DisplaySprite`, dépôts d'AABB pour la collision (`_Collision_AddAABB`), création d'objets fils (`LoadObject_x` + `sta id,x`)
