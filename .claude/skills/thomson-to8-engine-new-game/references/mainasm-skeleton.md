# Squelette `main.asm` d'un game-mode

Ce document décrit le **squelette canonique** d'un `main.asm` selon le pattern utilisé par les game-projects récents (`r-type`, `bubble-bobble`, `sonic-2`, `2026`). Le code utilise `gfxlock` pour le double buffering, l'IRQ utilisateur synchronisé sur le VBL, et l'allocation **dynamique** d'objets via `LoadObject_u`.

---

## Architecture en couches

Un `main.asm` est structuré en **5 sections** :

1. **Préambule** — defines, INCLUDEs des macros/constantes
2. **Code d'initialisation** — au démarrage, à partir de `$6100`
3. **Boucle principale** — `MainLoop` qui tourne en boucle
4. **UserIRQ** — interruption appelée à chaque VBL (palette, son, swap buffer)
5. **RAM data + routines moteur** — fin du fichier (INCLUDE du `ram-data.asm` + des routines engine)

---

## Squelette commenté complet

```asm
        opt   c,ct                          ; LWASM options : c=case sensitive, ct=cycle timings

* ==============================================================================
* Defines
* ==============================================================================
SOUND_CARD_PROTOTYPE equ 1                  ; ancien port carte son SN76489 (si applicable)
;SN76489_JUMPER_LOW   equ 1                 ; jumper bas (optionnel selon hardware)
;DEBUG                equ 1                 ; flag debug (active des traces)

* ==============================================================================
* Includes — constantes, macros, équivalences
* ==============================================================================
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        ; INCLUDE "./engine/collision/macros.asm"            ; si collisions AABB
        ; INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"  ; si scroll vertical
        ; INCLUDE "./engine/objects/sound/ymm/ymm.macro.asm"  ; si musique YM2413

; ------- Macros musicales (à reprendre dans chaque game-mode si pas centralisé) -------
MUSIC_NO_LOOP   EQU 0
MUSIC_LOOP      EQU 1

_MusicInit_objvgc MACRO
        lda   \1
        ldy   \3
        ldb   \2
        jsr   ,x
        ENDM

_MusicInit_objymm MACRO
        lda   \1
        ldy   \3
        ldb   \2
        jsr   ,x
        ENDM

_MusicFrame_objvgc MACRO
        ldb   #$80
        jsr   ,x
        ENDM

_MusicFrame_objymm MACRO
        ldb   #$80
        jsr   ,x
        ENDM

* ==============================================================================
* Point d'entrée — chargé en $6100 par le RAMLoader engine
* ==============================================================================
        org   $6100

        jsr   InitGlobals                   ; clear direct page + init globals engine
        jsr   InitDrawSprites               ; init buffers d'effacement (sprite-bg-erase)
        jsr   InitStack                     ; init pile d'allocation objets
        jsr   LoadAct                       ; code généré par le builder selon actBoot
        jsr   InitJoypads                   ; init lecture manettes (si jeu joué au joypad)
        ; jsr   InitRNG                     ; init générateur aléatoire (si utilisé)

        ; --- Optionnel : ouverture/fermeture de l'écran/palette en début de mode ---
        ldd   #Pal_current_palette
        std   Pal_current
        clr   PalRefresh
        ; jsr   PalUpdateNow                ; force update immédiate

        ; --- Allocation des objets dynamiques de départ ---
        jsr   LoadObject_u                  ; alloue un slot, retourne u (Z=1 si plein)
        beq   @noslot                       ; tester Z pour gérer le cas plein
        lda   #ObjID_Player                 ; identifiant de l'objet (généré par builder)
        sta   id,u                          ; lie le slot à l'objet logique
        ; sta   subtype,u                   ; optionnel : variante de l'objet
@noslot

        ; --- Initialisation musique (si applicable) ---
        _MountObject ObjID_ymm              ; charge la page de l'objet musique YMM
        _MusicInit_objymm #0,#MUSIC_LOOP,#0 ; track 0, en boucle, fade 0

        _MountObject ObjID_vgc              ; charge la page de l'objet musique VGC (SN76489)
        _MusicInit_objvgc #0,#MUSIC_LOOP,#0

        ; --- Configuration de l'IRQ utilisateur ---
        jsr   IrqInit                       ; init système IRQ
        ldd   #UserIRQ                      ; pointeur vers notre routine d'IRQ
        std   Irq_user_routine
        lda   #255                          ; sync : ligne 255 = hors zone visible (VBL)
        ldx   #Irq_one_frame                ; déclenche une fois par frame
        jsr   IrqSync
        _gfxlock.init                       ; init du double-buffering gfxlock
        jsr   IrqOn                         ; active les interruptions

* ==============================================================================
* Boucle principale
* ==============================================================================
MainLoop
        jsr   RunObjects                    ; exécute toutes les routines des objets vivants
        ; --- Tests de collision (si applicable) ---
        ; _Collision_Do AABB_list_player,AABB_list_enemy
        jsr   CheckSpritesRefresh           ; détermine quels sprites doivent être redessinés
        _gfxlock.on                         ; verrouille la phase de rendu (swap buffer side)
        jsr   EraseSprites                  ; efface les sprites de la frame précédente
        jsr   UnsetDisplayPriority          ; reset prio pour le tri à venir
        jsr   DrawSprites                   ; dessine les sprites (avec leur priorité)
        _gfxlock.off                        ; libère la phase de rendu
        _gfxlock.loop                       ; gestion du compteur de frames + flip ID
        bra   MainLoop

* ==============================================================================
* IRQ utilisateur (appelée 50 fois par seconde sur le VBL)
* ==============================================================================
UserIRQ
        jsr   gfxlock.bufferSwap.check      ; échange les buffers vidéo si rendu prêt
        jsr   PalUpdateNow                  ; applique les changements de palette
        ; --- Sound frame tick (si applicable) ---
        _MountObject ObjID_ymm
        _ymm.processFrame
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts

* ==============================================================================
* RAM Data — déclaration de l'OST (Object Status Table)
* ==============================================================================
        INCLUDE "./game-mode/<mode>/ram-data.asm"

; Variables RAM spécifiques au game-mode (optionnel)
; main.object.count  fcb   0
; main.playerOne     fdb   0

* ==============================================================================
* Routines moteur — inclues à la fin du fichier
* ==============================================================================

        ; --- Utilitaires ---
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"

        ; --- Joypad ---
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; --- Object management ---
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        ; INCLUDE "./engine/object-management/ObjectMoveSync.asm"   ; si déplacements

        ; --- Animation ---
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"
        ; INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"  ; version sync

        ; --- Sprite pack (CHOISIR UN SEUL) ---
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"
        ; INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  ; encoding étendu
        ; INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"               ; mode overlay (legacy)

        ; --- Sound (si musique) ---
        INCLUDE "./engine/objects/sound/ymm/ymm.const.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.data.asm"
        ; INCLUDE "./engine/sound/sn76489.asm"
        ; INCLUDE "./engine/sound/ym2413.asm"

        ; --- Math (si nécessaire) ---
        ; INCLUDE "./engine/math/CalcSine.asm"
        ; INCLUDE "./engine/math/RandomNumber.asm"

        ; --- Collision (si nécessaire) ---
        ; INCLUDE "./engine/collision/collision.asm"

        ; --- DOIT être en DERNIER (dépendances ifdef sur ce qui précède) ---
        INCLUDE "./engine/InitGlobals.asm"
```

---

## Choix du sprite-pack

Trois packs sont disponibles dans `engine/graphics/sprite/` :

### `sprite-background-erase-pack.asm` (par défaut, recommandé)

Inclut : `DisplaySprite`, `CheckSpritesRefresh`, `EraseSprites`, `UnsetDisplayPriority`, `DrawSprites`, `BgBufferAlloc`, `DeleteObject`.

- Mode **backup/draw/erase** : chaque sprite mobile sauvegarde le fond avant de se dessiner, et le restaure quand il disparaît.
- Exige des sprites compilés avec variante `B` (`NB0,NB1,XB0,XB1`...).
- Appel `InitDrawSprites` obligatoire au boot.
- Pattern : `EraseSprites` → `UnsetDisplayPriority` → `DrawSprites`.

### `sprite-background-erase-ext-pack.asm` (encoding étendu)

Identique au précédent **sauf** `DrawSprites.asm` → `DrawSpritesExtEnc.asm`.

- Permet des sprites avec **encodage RLE/ZX0** pour les images de fond ou grands sprites (variante `DMAP`, `DZX0`).
- Choisir ce pack si on utilise des objets avec sprites encodés.

### `sprite-overlay-pack.asm` (mode overlay, legacy)

Inclut : `DisplaySprite`, `BuildSprites`, `DeleteObject`.

- Mode **overlay** : les sprites sont fusionnés dans un buffer overlay (ancienne approche, utilisée par `test/`).
- Plus simple, moins performant en cas de nombreux sprites mobiles.
- Nécessite `OverlayMode equ 1` en préambule.
- Pattern (boucle main) : `BuildSprites` au lieu de `EraseSprites + DrawSprites`.

**Recommandation** : choisir `background-erase-pack` (ou `-ext-pack` si tu as des sprites encodés) pour tout nouveau projet.

---

## Variantes de boucle principale

### Avec gfxlock (pattern moderne, école 2)

```asm
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
```

### Avec WaitVBL (pattern simple, école 1)

```asm
MainLoop
        jsr   WaitVBL                  ; attend le retour vertical
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        bra   MainLoop
```

Plus simple mais sans double-buffering : risque de **tearing** visible en bas d'écran si la frame déborde.

### Avec collision avant rendu

```asm
MainLoop
        jsr   RunObjects
        _Collision_Do AABB_list_player,AABB_list_enemy
        _Collision_Do AABB_list_player,AABB_list_bonus
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop
```

Les `AABB_list_X` sont déclarées dans `ram-data.asm` (cf. ci-dessous).

---

## `ram-data.asm` — squelette canonique

Le fichier `ram-data.asm` (inclus depuis `main.asm`) déclare l'**OST** (Object Status Table) et ses dimensions.

### Version minimale (sans collision)

```asm
; RAM variables

* ===========================================================================
* Object Constants
* ===========================================================================

ext_variables_size                equ 0    ; octets supplémentaires par objet dynamique
nb_dynamic_objects                equ 8    ; nb max d'objets vivants simultanément
nb_graphical_objects              equ 8    ; max 64 (sprites visibles à l'écran)

Dynamic_Object_RAM
                                  fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End
```

### Version avec préchargement statique (école legacy, pattern `test`)

Permet d'avoir des objets **toujours présents** dès le démarrage, sans appel à `LoadObject_u`.

```asm
ext_variables_size                equ 0
nb_dynamic_objects                equ 3
nb_graphical_objects              equ 3

Object_RAM
SS_Object_RAM
Dynamic_Object_RAM                fcb   ObjID_Back
                                  fill  0,object_size-1
                                  fcb   ObjID_Back2
                                  fill  0,object_size-1
                                  fcb   ObjID_Player
                                  fill  0,object_size-1
Dynamic_Object_RAM_End
SS_Object_RAM_End
Object_RAM_End
```

### Version avec collisions AABB (pattern bubble-bobble, r-type)

```asm
ext_variables_size                equ 9    ; espace pour structs AABB (9 octets par AABB)
nb_dynamic_objects                equ 22
nb_graphical_objects              equ 12

Dynamic_Object_RAM                
                                  fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End

* ===========================================================================
* Collision lists
* ===========================================================================
AABB_lists.nb                     equ   (AABB_endLists-AABB_lists)/2
AABB_lists
AABB_list_player                  fdb   0,0
AABB_list_enemy                   fdb   0,0
AABB_list_bonus                   fdb   0,0
AABB_endLists
```

### Avec objet en Direct Page (pattern r-type — accès rapide au joueur)

```asm
ext_variables_size                equ 20
nb_dynamic_objects                equ 57
nb_graphical_objects              equ 57

* OST en Direct Page (accès 1 cycle plus rapide)
player1                           equ   dp                  ; alias DP pour le joueur
palettefade                       fcb   ObjID_fade          ; objet fade pré-chargé
                                  fill  0,object_size-1

Dynamic_Object_RAM                fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End
```

---

## Dimensions de l'OST — comment choisir

| Paramètre | Effet | Recommandation |
|-----------|-------|----------------|
| `nb_dynamic_objects` | Nb max d'objets vivants. Chaque objet prend `object_size` octets. | Commencer petit (8-16), augmenter si `LoadObject_u` échoue (Z=1) |
| `nb_graphical_objects` | Max 64 (limite engine). Combien de sprites à l'écran simultanément. | Tenir compte des sprites du HUD + des explosions transitoires |
| `ext_variables_size` | Octets supplémentaires alloués à chaque objet. | `0` minimum, `9` pour 1 AABB, `20` pour structs complexes (player avec ring-buffer, etc.) |

`object_size` est défini dans `engine/constants.asm` : `object_base_size + ext_variables_size + object_rsvd_size`. La taille de base est ~34 octets.

---

## UserIRQ — patterns selon les besoins

### Minimal (palette seule)

```asm
UserIRQ
        jmp   PalUpdateNow
```

### Avec gfxlock buffer swap

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        rts
```

### Avec musique YMM + VGC

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        _MountObject ObjID_ymm
        _ymm.processFrame
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts
```

### Avec effet raster palette (SMPS, sonic-2)

```asm
UserIRQ_Raster_Smps
        jsr   PalRaster_1c              ; change la palette à mi-écran
        jmp   MusicFrame
```

---

## Définition du game-mode courant et suivant

Pour permettre les transitions de game-mode (ex : titre → niveau 1) :

```asm
        lda   #GmID_level01
        sta   glb_Cur_Game_Mode

        ; Plus tard, pour basculer vers un autre mode :
        lda   #GmID_level02
        sta   glb_Next_Game_Mode
        ; puis dans la boucle main, après détection :
        ; jsr   LoadGameMode
```

`LoadGameMode` (dans `engine/level-management/LoadGameMode.asm`) déclenche le rechargement disquette/cartouche du game-mode suivant.

---

## Pattern avec includes factorisés (école goldorak)

Si tu factorises tes INCLUDEs dans `global/global-preambule-includes.asm` et `global/global-trailer-includes.asm` (pattern goldorak), ton `main.asm` devient :

```asm
        INCLUDE "./global/global-preambule-includes.asm"
        org   $6100

        _gameMode.init #GmID_splash             ; macro qui fait Init + Stack + LoadAct + Joypads
        _objectManager.new.u #ObjID_Splash       ; macro qui fait LoadObject_u + sta id
        _music.init.SN76489 #Vgc_intro,#MUSIC_LOOP,#0
        _music.init.YM2413 #Ym_intro,#MUSIC_LOOP,#0
        _music.init.IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame

MainLoop
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jsr   WaitVBL
        bra   MainLoop

UserIRQ
        jsr   PalUpdateNow
        rts

        INCLUDE "./game-mode/splash/ram-data.asm"
        INCLUDE "./global/global-trailer-includes.asm"
```

Ce pattern est très lisible mais nécessite de packager les macros (`_gameMode.init`, `_objectManager.new.u`, `_music.init.*`) — actuellement dans `goldorak/global/global-macros.asm`, **pas encore dans `engine/`**.

---

## ⚠️ Règle critique : Direct Page (DP) dans le code main

Dans le code résident (entre `org $6100` et la fin du MainLoop), **le registre DP du 6809 n'est PAS positionné automatiquement**. Sa valeur est inconnue (souvent 0, parfois résiduelle d'un setup précédent).

Conséquence : **ne jamais utiliser `<addr` (adressage direct page) dans le code main**. Toujours l'adressage étendu :

```asm
; Init / MainLoop / UserIRQ du game-mode :
        lda   #50
        sta   horizon_y       ; ✅ étendu : adresse 16 bits, indépendant du DP
        ; sta <horizon_y      ← ❌ écrit en (DP_actuel)*256 + offset — pas où prévu

        lda   horizon_y       ; ✅ lecture étendue OK
```

**Seules exceptions** où `<addr` est OK :
1. **Dans UserIRQ** : le monitor a positionné `DP = $E7` avant d'appeler le handler (puis `IrqManager` fait `setdp $E7`). Donc `<$DA`, `<$DB` (registres palette) etc. fonctionnent. C'est ce qui permet aux routines `PalUpdateNow`/`PalRaster_1c` d'être rapides.
2. **Dans une routine qui set DP localement** via `pshs dp; ldd #$XX; tfr b,dp; setdp $XX` (et restore avec `puls dp` à la sortie). Pattern utilisé par les routines engine.
3. **Code joueur en DP** (pattern `ObjectDp` : OST du joueur en $9F00-$9FFF, le DP est explicitement positionné à $9F avant `_RunObject ObjID_Player,#player1`).

Pour la grande majorité du code applicatif, l'**adressage étendu** est la règle. La perte d'1 cycle/accès est négligeable et évite des bugs silencieux indétectables (la valeur va dans la mauvaise zone mémoire sans erreur).

Voir le skill `thomson-to8-engine-memory-model/references/direct-page-usage.md` pour les détails complets.

---

## Pitfalls

- **`<addr` dans le code main sans setup DP** : écriture/lecture à la mauvaise adresse, bug silencieux. Cf. section dédiée ci-dessus.
- **Oublier `org $6100`** : le code se place à l'adresse 0 par défaut et plante au boot.
- **`InitDrawSprites` manqué** quand on utilise `sprite-background-erase-pack` ou `-ext-pack` : pas de crash mais les buffers d'erase sont à 0 et le rendu est cassé.
- **`InitStack` manqué** : `LoadObject_u` retourne toujours Z=1 (pile vide) car la pile d'allocation n'est pas initialisée.
- **`IrqOn` avant `_gfxlock.init`** : `gfxlock.status` n'est pas initialisé, le rendu est cassé.
- **`InitGlobals.asm` mis en haut des INCLUDEs** : il dépend de symboles définis par d'autres modules (ifdef chain), il **doit être à la fin**.
- **Sprite-pack mélangé avec overlay** : `BuildSprites` et `DrawSprites` ne sont **pas compatibles** ensemble — choisir un seul pack.
- **`org $6100` placé après l'INCLUDE des macros** : les `MACRO` doivent être définies avant `org` car LWASM compile en deux passes.
