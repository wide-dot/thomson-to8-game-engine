---
name: thomson-to8-engine-object-management
description: "Décrit le système de gestion d'objets du Thomson TO8/TO9 game engine (Bento8/wide-dot) : allocation dynamique d'objets via LoadObject_u / LoadObject_x, libération via UnloadObject, exécution cyclique RunObjects sur run-list doublement chaînée (run_object_prev / run_object_next), pile d'allocation STACK_SLOT_ADDRESS / STACK_POINTER, état OST (Object Status Table) avec offsets id, subtype, render_flags, priority, anim, x_pos, y_pos, x_pixel, y_pixel, x_vel, y_vel, x_acl, y_acl, routine, routine_secondary/tertiary/quaternary, déplacements ObjectMove / ObjectMoveSync (synchro framerate), gravité ObjectFall / ObjectFallSync, marquage hors-écran MarkObjGone / MarkObjGone2 / MarkObjGone3 avec respawn_index, Obj_GetOrientationToPlayer pour IA, ObjectWave et ObjectWave-subtype pour spawn d'ennemis par script, ObjectDp pour joueur en Direct Page, _MountObject / _RunObject / _RunObjectSwap / RunPgSubRoutine pour exécution cross-page, ManagedObjects_ClearAll pour reset complet. Utiliser pour comprendre le cycle de vie d'un objet, gérer l'allocation/libération de slots, lancer une routine d'objet depuis le code main, créer des sous-objets (LoadObject_x préserve u), gérer un joueur principal en Direct Page, scripter l'apparition d'ennemis par vagues, détruire automatiquement les objets sortis de l'écran, ou faire courir un objet sans qu'il soit dans la run-list. Mots-clés : LoadObject_u, LoadObject_x, UnloadObject_u, UnloadObject_x, RunObjects, RunFrozenObjects, ManagedObjects_ClearAll, InitStack, STACK_POINTER, STACK_SLOT_ADDRESS, Dynamic_Object_RAM, Dynamic_Object_RAM_End, nb_dynamic_objects, nb_graphical_objects, ext_variables_size, object_size, object_base_size, object_rsvd_size, object_list_first, object_list_last, object_list_next, run_object_prev, run_object_next, id, subtype, subtype_w, render_flags, render_xmirror_mask, render_ymirror_mask, render_overlay_mask, render_playfieldcoord_mask, render_xloop_mask, render_todelete_mask, render_subobjects_mask, render_hide_mask, priority, anim, prev_anim, sub_anim, anim_frame, anim_frame_duration, anim_flags, status_flags, status_xflip_mask, status_yflip_mask, image_set, x_pos, x_sub, y_pos, y_sub, xy_pixel, x_pixel, y_pixel, x_vel, y_vel, x_acl, y_acl, routine, routine_secondary, routine_tertiary, routine_quaternary, ObjectMove, ObjectMoveSync, ObjectFall, ObjectFallSync, MarkObjGone, MarkObjGone2, MarkObjGone3, Obj_respawn_index, Obj_respawn_data, Object_Respawn_Table, respawn_index, Obj_GetOrientationToPlayer, Gotp_Closest_Player, Gotp_Player_Is_Left, Gotp_Player_Is_Above, Gotp_Player_H_Distance, Gotp_Player_V_Distance, MainCharacter, Sidekick, ObjectWave, ObjectWave_Init, objectWave.do, objectWave.init, objectWave.data.page, objectWave.data.cursor, wave_frame_drop, ObjectDp_Clear, dp, dp_engine, dp_extreg, _MountObject, _RunObject, _RunObjectSwap, _RunObjectSwapRoutine, _RunObjectRoutineA, RunPgSubRoutine, PSR_Page, PSR_Address, PSR_Param, Obj_Index_Page, Obj_Index_Address, ObjID_, sub-routines, sub_anim, state machine."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Gestion d'objets — Thomson TO8/TO9 Game Engine

Le système de gestion d'objets est le **cœur du framework**. Chaque entité du jeu (joueur, ennemi, projectile, décor, HUD) est un *objet* — une structure de données fixe en RAM (l'OST, *Object Status Table*) à laquelle est associé un code asm exécuté chaque frame par `RunObjects`.

Ce skill couvre : allocation/libération d'objets, format de l'OST, exécution cyclique via la run-list, déplacements et gravité, scripts de spawn, IA via orientation joueur, exécution cross-page d'objets.

---

## Vue d'ensemble du cycle de vie

```
┌─────────────────────────────────────────────────────────────┐
│  POOL D'OBJETS — Dynamic_Object_RAM (taille fixe)           │
│  [slot 0] [slot 1] [slot 2] ... [slot N-1]                  │
│                                                              │
│  STACK_SLOT_ADDRESS → pile des slots libres                  │
│  STACK_POINTER     → pointeur sommet de pile                 │
└─────────────────────────────────────────────────────────────┘

InitStack          ──→  remplit la pile avec tous les slots libres
                       (au boot, dans main.asm)

LoadObject_u/x     ──→  dépile un slot, l'ajoute en queue de run-list
                       retourne u/x = slot, Z=0
                       (Z=1 si pile vide → échec)

[user code]        ──→  sta #ObjID_X, id,u   (lie le slot à un objet logique)

RunObjects         ──→  parcourt object_list_first → ... → object_list_last
                       (chaînée via run_object_next)
                       pour chaque, mount sa page + jsr code
                       (chaque frame, depuis MainLoop)

UnloadObject_u/x   ──→  délink du chaînage, repush dans la pile
                       efface l'OST (object_size bytes à 0)
```

---

## Pool d'objets — `Dynamic_Object_RAM`

Chaque objet occupe `object_size` octets. La taille de `object_size` est :

```asm
object_size = object_base_size + ext_variables_size + object_rsvd_size
```

| Composant | Valeur typique | Rôle |
|-----------|----------------|------|
| `object_base_size` | 38 octets | Champs standards (id, render_flags, x_pos, ..., routine_quaternary) |
| `ext_variables_size` | 0-20 octets | Variables additionnelles spécifiques au jeu (déclaré dans `ram-data.asm`) |
| `object_rsvd_size` | ~12 octets | Champs réservés engine (rsv_render_flags, rsv_mapping_frame, ...) |

Donc en pratique `object_size ≈ 50-58` octets selon `ext_variables_size`.

Le pool global est déclaré dans `ram-data.asm` :
```asm
nb_dynamic_objects                equ 22                ; nb max d'objets vivants
ext_variables_size                equ 9                 ; pour 1 AABB par objet

Dynamic_Object_RAM                
                                  fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End
```

Voir [references/ost-layout.md](references/ost-layout.md) pour la liste exhaustive des offsets OST.

---

## Allocation — `LoadObject_u` / `LoadObject_x`

Dépile un slot libre, le lie en queue de la run-list.

```asm
        jsr   LoadObject_u              ; retourne u = pointeur sur slot, Z=0 si OK
        beq   @no_slot                  ; Z=1 → pile vide, échec
        lda   #ObjID_Bullet
        sta   id,u                      ; lier le slot à l'objet logique
        ldd   #100
        std   x_pos,u
        ; ... autre init ...
@no_slot
```

**Différence `_u` vs `_x`** :
- `LoadObject_u` : retourne `u`, **préserve x** (utile dans une routine qui a déjà besoin de u après)
- `LoadObject_x` : retourne `x`, **préserve u** (utile quand on appelle depuis une routine d'objet qui doit garder `u` pour l'OST du parent)

Convention dans le repo : utiliser `_u` au boot dans `main.asm`, `_x` depuis une routine d'objet pour créer un enfant.

Voir [references/allocation-and-deallocation.md](references/allocation-and-deallocation.md).

---

## Libération — `UnloadObject_u` / `UnloadObject_x`

Délink l'objet du chaînage et efface ses `object_size` octets (utilise des `pshu d,x,y` pour effacer 6 octets à la fois, optimisé).

```asm
        jsr   UnloadObject_u            ; après cet appel, u n'est plus valide
        rts                             ; sortir immédiatement
```

**Alternative recommandée** : poser `render_todelete_mask` dans `render_flags,u` et laisser le moteur supprimer l'objet à la prochaine `EraseSprites` :

```asm
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u
```

Cette voie évite les pièges de désallocation manuelle et garantit que le moteur efface aussi le sprite avant de libérer le slot.

---

## Exécution — `RunObjects`

Appelée chaque frame depuis `MainLoop`. Parcourt la run-list :

```asm
RunObjects
        ldu   object_list_first         ; tête de liste
        beq   @rts                      ; liste vide
!       ldb   id,u                      ; objet logique du slot
        beq   @skip                     ; slot booké mais sans ID → skip
        ldx   #Obj_Index_Page
        abx
        lda   ,x                        ; charge la page mémoire de l'objet
        _SetCartPageA                   ; mount cette page en zone cartouche
        aslb                            ; *2 pour l'adresse (table 2 octets/entry)
        ldx   #Obj_Index_Address
        abx
        ldd   run_object_next,u         ; sauve le suivant AVANT exec
        std   object_list_next          ; (au cas où l'objet se supprime)
        jsr   [,x]                      ; appel indirect du code de l'objet
        ldu   run_object_next,u         ; passer au suivant
        bne   <
        ldu   #0
object_list_next equ *-2
        bne   <
@rts    rts
```

Points clés :
- L'engine **mount automatiquement la page mémoire** de l'objet avant son exécution (via `_SetCartPageA`). Le code de l'objet est résolu via `Obj_Index_Page[id]` + `Obj_Index_Address[id*2]`, deux tables générées par le builder Java.
- Le `next` est **sauvegardé avant l'appel** : un objet peut donc se supprimer (ou créer un enfant) sans casser le parcours.
- Un objet avec `id=0` est un slot **réservé mais pas encore initialisé** — il est skippé sans exécution.

`RunFrozenObjects` : variante qui ne fait que **lever le flag `render_hide_mask`** sur tous les objets, sans exécuter leur code. Utile pour un mode pause/cinematic où les objets sont visibles mais figés.

`ManagedObjects_ClearAll` : remise à zéro totale du pool. Utilisé lors d'une transition de game-mode (cf. `LoadGameMode`).

Voir [references/runobjects-execution.md](references/runobjects-execution.md).

---

## OST — résumé des offsets clés

Détails complets dans [references/ost-layout.md](references/ost-layout.md). Vue d'ensemble :

| Offset | Symbole | Rôle |
|--------|---------|------|
| 0 | `id` | ObjID_ (0 = libre) |
| 1 | `subtype` / `subtype_w` | Variante (1 ou 2 octets — overlap `render_flags`) |
| 2 | `render_flags` | Bits de rendu |
| 3-6 | `run_object_prev/next` | Chaînage run-list (engine) |
| 7 | `priority` | 0=invisible, 1=front, 8=back |
| 8-9 | `anim` | Pointeur `Ani_<X>` |
| 12-13 | `anim_frame` / `anim_frame_duration` | État d'animation |
| 14 | `status_flags` / `anim_flags` | Orientation (xflip/yflip) ou flags d'animation |
| 16-17 | `image_set` | `Img_<X>` courant |
| 18-23 | `x_pos`/`x_sub` + `y_pos`/`y_sub` | Position playfield 16.8 |
| 24-25 | `xy_pixel` (= `x_pixel`+`y_pixel`) | Position écran 8 bits |
| 26-29 | `x_vel` / `y_vel` | Vitesse signed 8.8 |
| 30-33 | `x_acl` / `y_acl` | Accélération signed 8.8 (gravité) |
| 34-37 | `routine` / `routine_secondary/tertiary/quaternary` | State machines |
| 38+ | `ext_variables` | Espace utilisateur (AABB, compteurs, etc.) |

---

## Déplacements — `ObjectMove` / `ObjectMoveSync`

Applique `x_vel`/`y_vel` à `x_pos`/`y_pos` (fixed-point 8.8). `ObjectMove` fait une seule passe, `ObjectMoveSync` multiplie par `gfxlock.frameDrop.count_w` (compatible framerate adaptatif).

```asm
        ; Dans la routine Main d'un objet
        jsr   ObjectMove                ; non synchronisé
        ; OU
        jsr   ObjectMoveSync            ; synchro framerate
```

Pour la gravité : `ObjectFall` / `ObjectFallSync` ajoute `x_acl`/`y_acl` à `x_vel`/`y_vel`.

Voir [references/move-and-physics.md](references/move-and-physics.md) pour les formules fixed-point, l'usage des sub-pixels, et les patterns plateformer.

---

## Marquer un objet hors-écran — `MarkObjGone` / `MarkObjGone2` / `MarkObjGone3`

Utilisé en queue de `Main` à la place de `jmp DisplaySprite`. Compare `x_pos` à `glb_camera_x_pos_coarse` ; si l'objet est trop loin de la caméra, l'engine appelle `DeleteObject` ; sinon il appelle `DisplaySprite`.

Variantes :
- `MarkObjGone` : utilise `x_pos,u`, supprime si > $40+160+$20+$40 pixels hors écran (wide-dot factor)
- `MarkObjGone2` : prend la position en `d` plutôt que via `x_pos,u`
- `MarkObjGone3` : variante qui fait `rts` au lieu de `DisplaySprite` quand l'objet est dans l'écran (utile quand on a déjà appelé DisplaySprite ailleurs)

Tous trois nettoient `Object_Respawn_Table` à `respawn_index,u` (clear du bit 7) pour permettre la re-spawn ultérieure de l'objet quand la caméra reviendra.

Voir [references/respawn-and-cleanup.md](references/respawn-and-cleanup.md).

---

## IA — `Obj_GetOrientationToPlayer`

Retourne dans des variables globales la position relative du joueur le plus proche par rapport à l'objet (`u`) :

| Variable | Valeur |
|----------|--------|
| `Gotp_Closest_Player` | Pointeur vers `MainCharacter` ou `Sidekick` (le plus proche) |
| `Gotp_Player_Is_Left` | 0 = joueur à gauche de l'objet, 2 = à droite |
| `Gotp_Player_Is_Above` | 0 = joueur au-dessus, 2 = en-dessous |
| `Gotp_Player_H_Distance` | Distance horizontale signée |
| `Gotp_Player_V_Distance` | Distance verticale signée |

Utilisé par les ennemis qui cherchent à se diriger vers le joueur, viser, etc. Suppose que `MainCharacter` (et optionnellement `Sidekick`) sont définis comme adresses globales.

---

## Spawn d'ennemis par script — `ObjectWave`

Système déclaratif pour faire apparaître des objets à des moments précis basés sur un compteur (typiquement `gfxlock.frame.count`).

Deux variantes :
- **`objectWave.do`** (legacy, 8 octets par entrée) — `time + id + subtype + x_pos + y_pos`
- **`ObjectWave` (`-subtype`)** (moderne, 5 octets par entrée) — `time + id + subtype_w(2 octets)`. `subtype_w` chevauche `render_flags` donc impose des précautions.

Pattern d'usage :
```asm
        _objectWave.init #ObjID_LevelWave,#0       ; init pointeur cursor
        ; ...
        ; Dans MainLoop, à chaque frame
        _objectWave.do gfxlock.frame.count
```

Le script lui-même est une liste binaire de tuples placée à une page connue (référencée par `objectWave.data.page` / `objectWave.data.cursor`). Le marker de fin est `0` (8-octet) ou `$FFFF` (5-octet subtype).

Voir [references/objectwave-scripting.md](references/objectwave-scripting.md).

---

## Joueur en Direct Page — `ObjectDp`

Optimisation : placer le joueur principal en Direct Page ($9F00-$9FFF) pour économiser un cycle par accès aux champs OST.

```asm
; Dans ram-data.asm
player1                           equ   dp                ; alias DP

; Dans le code du joueur
        ldd   <x_pos                    ; (2 cycles) au lieu de ldd x_pos,u (3 cycles + offset)
```

L'objet n'est PAS dans la run-list — il faut le faire tourner manuellement depuis `MainLoop` :
```asm
        ldu   #player1
        _RunObject ObjID_Player,#player1   ; macro qui mount la page + jsr
```

`ObjectDp_Clear` efface la zone DP (de `dp` à `dp_extreg`) au boot.

---

## Exécution cross-page — `_MountObject`, `_RunObject`, `_RunObjectSwap`, `RunPgSubRoutine`

Quand on veut appeler une routine d'un autre objet **depuis le code d'un objet en cours d'exécution**, il faut gérer le changement de page mémoire (le code de l'objet appelé peut être dans une autre page que celui de l'appelant).

| Macro | Quand utiliser |
|-------|----------------|
| `_MountObject ObjID_X` | Mount la page de l'objet X dans `A`, charge son adresse dans `X`. Ne saute pas. Utile pour appeler manuellement `jsr ,x`. Préserve la page sortante ? **NON**. Préférer `_RunObjectSwap` si on est dans une routine appelée par RunObjects. |
| `_RunObject ObjID_X,#data` | Mount + ldu data + jsr. Pas de gestion de page de retour — usage limité. |
| `_RunObjectSwap ObjID_X,#data` | Sauvegarde la page courante, mount X, exécute via `RunPgSubRoutine`, restaure la page. Sûr. |
| `RunPgSubRoutine` | Sous-jacent : utilise `PSR_Page`, `PSR_Address`, `PSR_Param` pour appeler une routine et restaurer la page. |

```asm
; Appel manuel sécurisé depuis une routine d'objet
        _RunObjectSwap ObjID_AudioController,#audio_data
        ; à ce stade la page courante est restaurée
```

Voir [references/cross-page-execution.md](references/cross-page-execution.md).

---

## Pitfalls

- **Sprite ND* sans `render_overlay_mask`** : sprite invisible, échec silencieux. Pour tout objet dont le sprite est compilé en variant `ND0`/`ND1`/`XD*`/`YD*`/`XYD*`, ajouter dans `Init` : `lda render_flags,u; ora #render_overlay_mask; sta render_flags,u`. Sinon l'engine cherche un code d'erase inexistant.
- **Position du sprite calculée comme `taille/2`** : la convention CENTER utilise `ceil(taille/2)-1`. Sprite 160 px centré X = `x_pixel = 79`, pas 80. Si le sprite déborde et que `render_xloop_mask` n'est pas activé, l'engine ne dessine pas du tout.
- **`InitStack` non appelé** au boot : `LoadObject_u` retourne toujours Z=1.
- **`Dynamic_Object_RAM` sous-dimensionné** (`nb_dynamic_objects` trop petit) : échecs silencieux de `LoadObject_u` ; toujours tester Z après l'appel.
- **`object_size` mal calculé** : si `ext_variables_size` est plus grand que ce que les variables locales utilisent, on gaspille de la RAM ; si plus petit, on déborde sur les `rsv_*`.
- **Allouer un objet pendant `RunObjects` sans précautions** : OK car `object_list_next` est sauvé avant l'exec, mais le nouvel objet sera ajouté en queue et exécuté **dans la même frame** (utile ou non selon le besoin).
- **Modifier `id,u` à 0 dans Main** : libère le slot pour `RunObjects` qui le skippera ; mais le slot n'est pas remis dans la pile → fuite. Préférer `UnloadObject_u` ou `render_todelete_mask`.
- **Oublier `inc routine,u` dans Init** : l'init est rappelée à chaque frame, l'objet ne fait jamais autre chose.
- **Appeler `_MountObject X` sans sauvegarder la page courante** depuis le code d'un objet : au retour, la page courante n'est plus celle du caller → crash. Utiliser `_RunObjectSwap` ou sauver/restaurer manuellement la page.
- **`subtype_w` qui chevauche `render_flags`** (cas `ObjectWave-subtype`) : poser les `render_flags` AVANT de lire `subtype_w`, sinon on écrase un octet de subtype.
- **Délier un objet via `UnloadObject_u` puis continuer à utiliser `u`** : crash silencieux (la mémoire est encore là mais peut être réallouée).

---

## Références détaillées

- [references/ost-layout.md](references/ost-layout.md) — Layout complet de l'OST : tous les offsets de 0 à `object_size`, tailles, sémantique de chaque champ, dépendances entre champs (id+subtype, x_pos+x_sub, x_pixel+y_pixel), zone réservée engine (`rsv_*`), espace utilisateur `ext_variables`, calcul dimensionnel
- [references/allocation-and-deallocation.md](references/allocation-and-deallocation.md) — `InitStack` initialisation, `LoadObject_u` vs `LoadObject_x` (sémantique pile et chaînage), `UnloadObject_u/x` avec génération dynamique d'instructions PSHU pour effacement rapide, `ManagedObjects_ClearAll`, comparaison avec `render_todelete_mask`, patterns d'erreur (slot épuisé)
- [references/runobjects-execution.md](references/runobjects-execution.md) — `RunObjects` parcours détaillé, `object_list_first/last/next`, mécanisme `_SetCartPageA` cross-page, gestion de la self-suppression et création de fils en cours d'exécution, `RunFrozenObjects` (mode pause), `Obj_Index_Page`/`Obj_Index_Address` (tables générées par le builder Java)
- [references/move-and-physics.md](references/move-and-physics.md) — `ObjectMove` détail asm avec sign extend, `ObjectMoveSync` boucle de multiplication par `gfxlock.frameDrop.count_w`, `ObjectFall`/`ObjectFallSync`, format fixed-point 8.8 pour `x_vel`/`y_vel`, `x_acl`/`y_acl`, patterns plateformer (h_top_speed, v_top_speed, gravity), sub-pixels et leur impact sur la précision
- [references/respawn-and-cleanup.md](references/respawn-and-cleanup.md) — `MarkObjGone` / `MarkObjGone2` / `MarkObjGone3` comparaison, `Object_Respawn_Table`, `Obj_respawn_index`, `Obj_respawn_data`, `respawn_index` dans l'OST, sémantique du bit 7 (objet déjà spawné/à respawner), wide-dot factor, intégration avec scrolling
- [references/objectwave-scripting.md](references/objectwave-scripting.md) — `objectWave.do` (legacy, 8 octets) vs `ObjectWave` subtype (5 octets), format binaire des scripts, marqueur de fin (`0` vs `$FFFF`), `_objectWave.init`/`do` macros, `wave_frame_drop` (pour reprendre l'animation à la frame correcte si plusieurs spawns ont été manqués), placement des scripts en page paginée, `gfxlock.frame.count` comme compteur de référence
- [references/cross-page-execution.md](references/cross-page-execution.md) — `_MountObject` vs `_RunObject` vs `_RunObjectSwap` vs `_RunObjectSwapRoutine` vs `_RunObjectRoutineA`, sémantique de chaque, sécurité du retour de page, `RunPgSubRoutine` détail (sauvegarde page sortante, paramètre `PSR_Param`), patterns d'appel d'audio engine, de subroutine partagée
- [references/direct-page-object.md](references/direct-page-object.md) — `ObjectDp_Clear`, alias `player1 equ dp`, accès direct-page `<x_pos`, économie de cycles, exécution manuelle hors run-list, contraintes (placement en début de page, taille limitée à 256 octets), interaction avec `dp_engine` / `dp_extreg`
- [references/state-machines.md](references/state-machines.md) — Usage de `routine` primaire + `routine_secondary/tertiary/quaternary`, pattern jump-table-indexed, exemples de state machines en parallèle (animation séparée du déplacement), conventions `_routine` suffixe (`Init_routine equ 0`, `Ground_routine equ 1`, ...), interaction avec animation v00/v02 tag `_nextRoutine`
