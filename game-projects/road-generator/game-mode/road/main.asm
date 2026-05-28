        opt   c,ct

* ==============================================================================
* road-generator — Game Mode "road"
* ------------------------------------------------------------------------------
* Port Lotus Esprit Turbo Challenge sur TO8.
*
* Étape 1 (actuelle) :
*   - Objet ObjID_Road affiche road.png (sprite de base, palette statique).
*   - PAS de rasters palette : rendu fixe pour valider la chaîne d'affichage.
*   - La perspective sera ajoutée ensuite par sprites préshiftés
*     convertis depuis lotus-ste/doc/extraction/road_lines/.
*
* Architecture (inspirée de sonic-2/title-screen) :
*   - Boucle principale : RunObjects + DrawSprites
*   - IRQ utilisateur minimal (juste sync buffer)
* ==============================================================================

SOUND_CARD_PROTOTYPE equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"

        org   $6100

* ==============================================================================
* Init
* ==============================================================================
        jsr   InitGlobals
        jsr   InitDrawSprites
        jsr   InitStack

        ; --- Copy page 3 → page 0 RAMA/RAMB demi-pages ---
        ; Page 3 a été chargée par le RAMLoader avec :
        ;   $0000-$0D7A : RoadPatternsDark
        ;   $1000-$1FFF : Persp_Recip A (lecture interpolateur quand PRC=0)
        ;   $2000-$2D7A : RoadPatternsLight
        ;   $3000-$3FFF : Persp_Recip B (lecture interpolateur quand PRC=1)
        ; → après copie, page 0 RAMA = dark+RecipA / RAMB = light+RecipB,
        ;   visibles alternativement à $4000-$5FFF via le bit PRC.
        ; DOIT être appelé AVANT gfxlock.init (= avant que pages 2/3 deviennent
        ; des back-buffers actifs).
        lda   #3
        jsr   CopyPageToDemiPage0

        jsr   LoadAct                   ; palette + bordure (cf. main.properties)

        ; --- Alloue l'objet Road (sprite affiché) ---
        jsr   LoadObject_u
        beq   @noslot1
        lda   #ObjID_Road
        sta   id,u
@noslot1

        ; --- Alloue l'objet PlayerOne ---
        ; Note : PlayerOne OST est dans Dynamic_Object_RAM (= l'engine
        ; gère le lifecycle via RunObjects), MAIS son alias `player1=dp`
        ; permet l'adressage direct depuis le code de l'objet.
        ; Init de player1 OST (en DP) :
        lda   #ObjID_PlayerOne
        sta   player1+id
        clr   player1+routine          ; commence en Init routine

        ; --- Charge le circuit (labels directs, pas de jump table) ---
        ; Chaque circuit expose 2 labels publics :
        ;   Circuit_xxx_nb_segments  : 1 mot (uint16) = N
        ;   Circuit_xxx_segments     : (N+8) × 16 octets
        ; Pas d'indirection nécessaire — taille fixe et labels stables.
        ldd   Circuit_01_easy_1_nb_segments
        std   Circuit_nb_segments
        ldd   #Circuit_01_easy_1_segments
        std   Circuit_base
        ; segment_idx du joueur initialisé à 0 dans PlayerOne_Init.

        ; --- Init palette statique (depuis road.png) ---
        ldd   #Pal_Road
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow

        ; --- Configure l'IRQ utilisateur ---
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #50                       ; sync VBL
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn

* ==============================================================================
* Main Loop
* ==============================================================================
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

* ==============================================================================
* UserIRQ (50 Hz, sync VBL)
* ------------------------------------------------------------------------------
* Plus de raster palette ici — juste la synchro du buffer graphique.
* ==============================================================================
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   lotus_input.add           ; push état joystick dans buffer (50 Hz)
        rts

* ==============================================================================
* RAM data (Dynamic_Object_RAM, etc.)
* ==============================================================================
        INCLUDE "./game-mode/road/ram-data.asm"

* ==============================================================================
* Engine routines
* ==============================================================================

        ; --- Utilitaires ---
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/ram/CopyPageToDemiPage0.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"

        ; --- Object management ---
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"

        ; --- Animation ---
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"

        ; --- Sprite pack (background-erase, mode draw ND0 supporté) ---
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"

        ; --- Lotus port : input buffer + physics tick ---
        ; (Plus de Circuit_step : segment_idx est cached dans LotusCarState
        ;  et maintenu directement par Lotus_PhysicsTick.)
        INCLUDE "./game-mode/road/input/lotus.input.buffer.asm"
        INCLUDE "./engine/physics/Lotus_PhysicsTick.asm"

        ; --- Lotus port : projection sparse (task #C) ---
        INCLUDE "./engine/math/Mul9x16.asm"
        INCLUDE "./engine/projection/SparseProjection.asm"

        ; --- Lotus port : interpolateur linéaire (task #D) ---
        ; FILE59_BASE_FOR_INTERP est défini en EQU dans LinearInterp.asm
        ; comme Persp_Recip_k01-$40 (= fallback résident, imprécis pour
        ; les indices < $40 mais OK en pratique).
        INCLUDE "./engine/projection/LinearInterp.asm"

        ; --- Données circuit (= sortie de generate_circuits.py) ---
        INCLUDE "./engine/circuits/01_easy_1.asm"

        ; --- DOIT être en dernier (dépendances ifdef sur ce qui précède) ---
        INCLUDE "./engine/InitGlobals.asm"
