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

        ; --- Charge le circuit via JUMP TABLE (= interchangeable) ---
        ; Layout d'un .asm circuit (généré par tools/generate_circuits.py) :
        ;   +0..1   fdb → ptr nb_segments
        ;   +2..3   fdb → ptr segments
        ;   +4..5   nb_segments (uint16)
        ;   +6..    segments × 16 oct
        ; → Circuit_base = pointeur DIRECT sur premier segment (= jump[+2]).
        ldx   #Circuit_23_hard_6        ; X = base jump table circuit choisi
        ldd   [,x]                      ; D = nb_segments (indirect via ptr +0)
        std   Circuit_nb_segments
        ldd   2,x                       ; D = ptr segments (direct)
        std   Circuit_base
        std   Current_segment_ptr       ; init = premier segment

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

        ; --- Lotus port : input buffer + physics tick + circuit step ---
        INCLUDE "./game-mode/road/input/lotus.input.buffer.asm"
        INCLUDE "./engine/physics/Lotus_PhysicsTick.asm"
        INCLUDE "./engine/circuit/Circuit_step.asm"

        ; --- Données circuit (= sortie de generate_circuits.py) ---
        INCLUDE "./engine/circuits/23_hard_6.asm"

        ; --- DOIT être en dernier (dépendances ifdef sur ce qui précède) ---
        INCLUDE "./engine/InitGlobals.asm"
