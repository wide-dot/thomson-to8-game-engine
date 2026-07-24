        opt   c,ct
* Sparse_Buffer déporté dans l'objet RoadEngine (comme le mode road) : ce flag
* fait sauter sa def dans ram-data.asm (partagé). RoadEngine #0 sert encore à
* poser Circuit_base/nb (lus par la physique) ; #1 (SP+LI) N'EST PLUS appelé.
SPARSE_BUFFER_DEPORTED equ 1

* ==============================================================================
* road-generator — Game Mode "road-stream"
* ------------------------------------------------------------------------------
* Variante STREAMING du mode road : au lieu de calculer SparseProjection +
* LinearInterp à chaque frame (~37k cyc), on LIT des Dense_Buffer précalculés
* (format DIFF/KEYFRAME) streamés depuis des pages cart, et on applique le diff
* au Dense_Buffer résident (RoadStreamDecode). DrawFrameRoad est INCHANGÉ.
*
* Données : objects/road-stream-data/ (chunks + index), générées par
* tools/road_pack.py --emit-build --circuit 22_hard_5. Cf. doc 42.
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

        ; --- Copy page 3 → page 0 RAMA/RAMB demi-pages (patterns + persp) ---
        lda   #3
        jsr   CopyPageATo0

        jsr   LoadAct                   ; palette + bordure

        ; --- Alloue l'objet PlayerOne (physique) ---
        lda   #ObjID_PlayerOne
        sta   <player1+id
        clr   <player1+routine

        ; --- Init RoadEngine #0 : pose Circuit_base/Circuit_nb_segments
        ;     (lus par la physique). SP+LI ne sont PLUS appelés (#1 jamais lancé). ---
        _RunObjectRoutineB ObjID_RoadEngine,#0

        ; --- Configure l'IRQ utilisateur ---
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                      ; sync VBL
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn

        ; --- Init joypad engine API ---
        jsr   InitJoypads

        ; --- Init palette statique ---
        ldd   #Pal_Road
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow

* ==============================================================================
* Main Loop
* ------------------------------------------------------------------------------
* ReadJoypads → PlayerOne(physique) → RoadStreamDecode(applique le DIFF au
* Dense_Buffer) → DrawFrameRoad → DFR_border_mask → swap. ZÉRO SP/LI.
* ==============================================================================
MainLoop
        jsr   ReadJoypads               ; lit $E7CC + Dpad_Held/Press
        _RunObject ObjID_PlayerOne,#player1   ; physique : track_pos, segment_idx
        jsr   RunObjects
        jsr   RoadStreamDecode          ; lit la frame cible et l'applique au Dense_Buffer

        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   UnsetDisplayPriority

        jsr   DrawFrameRoad             ; route complète : horizon→bas, 2 banques, dithering
        jsr   DFR_border_mask           ; mask 8px L+R des n scanlines rendues
        jsr   DrawSprites
        _gfxlock.off
        _gfxlock.loop
        jmp   MainLoop                  ; jmp : _gfxlock.loop étendu (frame-drop cap) met MainLoop hors portée d'un bra

* ==============================================================================
* UserIRQ (50 Hz, sync VBL)
* ==============================================================================
UserIRQ
        jsr   gfxlock.bufferSwap.check
        rts

* ==============================================================================
* RAM data (partagé avec le mode road : Dense_Buffer, Proj_*, OST...)
* ==============================================================================
        INCLUDE "./game-mode/road/ram-data.asm"

* ==============================================================================
* Engine routines
* ==============================================================================
        ; --- Utilitaires ---
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/ram/CopyPageATo0.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"

        ; --- Object management ---
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"

        ; --- Sprite pack ---
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"

        ; --- Lotus port : physics tick (input lu via Dpad_Held de ReadJoypads) ---
        INCLUDE "./engine/physics/Lotus_PhysicsTick.asm"
        INCLUDE "./engine/math/Mul9x16.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/joypad/InitJoypads.asm"

        ; --- Patterns externs (Road_R*/Road_draw_KX_JY dans la pattern bank) ---
        INCLUDE "./game-mode/road/generated/road_patterns_externs.inc"

        ; --- Table de dispatch Road_lines + rendu route (INCHANGÉS) ---
        INCLUDE "./engine/projection/RoadLinesTable.asm"
        INCLUDE "./engine/projection/RoadDrawDispatch.asm"
        INCLUDE "./engine/projection/DrawFrameRoad.asm"

        ; --- STREAMING : décodeur DIFF + index résident du circuit ---
        INCLUDE "./engine/projection/RoadStreamDecode.asm"
        INCLUDE "./objects/road-stream-data/22_hard_5_index.asm"

        ; --- DOIT être en dernier (dépendances ifdef) ---
        INCLUDE "./engine/InitGlobals.asm"
