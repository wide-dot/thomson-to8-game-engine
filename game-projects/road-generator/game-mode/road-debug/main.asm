        opt   c,ct

* ==============================================================================
* road-generator — Game Mode "road-debug"
* ------------------------------------------------------------------------------
* MODE DEBUG validation du PLACEMENT (indépendant du mode "road").
*
* Affiche 200 lignes empilées (scanline Y=0..199 → line_idx=Y, la plus étroite
* en haut). Toutes posées au MÊME offset horizontal global DFR_dbg_offset,
* calé à gauche (px 0) à offset 0. LEFT/RIGHT règlent l'offset au pixel près.
*
* AUCUNE projection / perspective / physique : on appelle directement
* DrawFrameRoad_Debug. Le boot, les includes et les assets sont IDENTIQUES au
* mode "road" (= même conf), seule la MainLoop change.
* ==============================================================================

SOUND_CARD_PROTOTYPE equ 1

* ============================================================================
* Circuit selection — conservé identique au mode road (le circuit n'est pas
* parcouru en debug, mais on garde la même conf pour résoudre les symboles).
* ============================================================================
ACTIVE_CIRCUIT_NB    equ Circuit_22_hard_5_nb_segments
ACTIVE_CIRCUIT_BASE  equ Circuit_22_hard_5_segments

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"

        org   $6100

* ==============================================================================
* Init (identique au mode road)
* ==============================================================================
        jsr   InitGlobals
        jsr   InitDrawSprites
        jsr   InitStack

        ; --- Copy page 3 → page 0 RAMA/RAMB demi-pages (patterns dark/light) ---
        lda   #3
        jsr   CopyPageATo0

        jsr   LoadAct                   ; palette + bordure (cf. main.properties)

        ; --- Alloue l'objet PlayerOne (inerte en debug : jamais RunObjects) ---
        lda   #ObjID_PlayerOne
        sta   <player1+id
        clr   <player1+routine

        ; --- Charge le circuit (conf identique ; non parcouru en debug) ---
        ldd   ACTIVE_CIRCUIT_NB
        std   Circuit_nb_segments
        ldd   #ACTIVE_CIRCUIT_BASE
        std   Circuit_base

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

        ; --- Pointeurs buffers projection (setup conservé, non utilisé en debug) ---
        ldd   #Sparse_Buffer
        std   Proj_buffer_ptr
        std   LinearInterp_buffer_in
        ldd   #Dense_Buffer
        std   LinearInterp_buffer_out

        ; --- État debug initial : offset 0, dark (prc 0), 1re ligne 0 ---
        ldd   #0
        std   DFR_dbg_offset
        clr   DFR_dbg_prc
        clr   DFR_dbg_line_base

* ==============================================================================
* Main Loop debug
* ------------------------------------------------------------------------------
* LEFT/RIGHT (front montant Dpad_Press) ajustent DFR_dbg_offset de ±1 px,
* clampé [0, 159]. Puis on dessine les 200 lignes à cet offset.
* ==============================================================================
* DFR_dbg_offset SIGNÉ, plage [-256, +256] (= course max : chaque ligne sort
* de l'écran des 2 côtés → clamp grass aux extrêmes). Maintenu (Dpad_Held) =
* balayage continu 1 px/frame. Sens : RIGHT → route à DROITE (l'inversion est
* dans leftEdge=80-offset côté DrawFrameRoad_Debug).
MainLoop
        jsr   ReadJoypads               ; calcule Dpad_Held + Dpad_Press

        * --- LEFT : offset -1 (→ route à gauche), clamp -256 ---
        lda   Dpad_Held
        bita  #c1_button_left_mask      ; bit 2
        beq   ML_chk_right
        ldd   DFR_dbg_offset
        cmpd  #-256
        ble   ML_chk_right              ; signé : déjà au min
        subd  #1
        std   DFR_dbg_offset
ML_chk_right
        * --- RIGHT : offset +1 (→ route à droite), clamp +256 ---
        lda   Dpad_Held
        bita  #c1_button_right_mask     ; bit 3
        beq   ML_chk_up
        ldd   DFR_dbg_offset
        cmpd  #256
        bge   ML_chk_up                 ; signé : déjà au max
        addd  #1
        std   DFR_dbg_offset
ML_chk_up
        * --- UP : scroll vers le haut de la plage (line_base -1), clamp 0 ---
        lda   Dpad_Held
        bita  #c1_button_up_mask        ; bit 0
        beq   ML_chk_down
        lda   DFR_dbg_line_base
        beq   ML_chk_down               ; déjà à 0
        deca
        sta   DFR_dbg_line_base
ML_chk_down
        * --- DOWN : scroll vers le bas (line_base +1), clamp 55 (=254-199) ---
        lda   Dpad_Held
        bita  #c1_button_down_mask      ; bit 1
        beq   ML_chk_fire
        lda   DFR_dbg_line_base
        cmpa  #55                       ; line_base+199 <= 254
        bhs   ML_chk_fire               ; déjà au max
        inca
        sta   DFR_dbg_line_base
ML_chk_fire
        * --- FIRE (front montant) : bascule PRC = thème couleur dark/light ---
        lda   Fire_Press
        beq   ML_draw
        lda   DFR_dbg_prc
        eora  #1
        sta   DFR_dbg_prc
ML_draw
        _gfxlock.on
        jsr   DrawFrameRoad_Debug       ; 200 lignes (rendu -2 à cheval) au DFR_dbg_offset
        jsr   DFR_border_mask_dbg       ; bordure noire 8px L+R, pleine hauteur
        _gfxlock.off
        _gfxlock.loop
        lbra  MainLoop                  ; branche longue (la MainLoop dépasse 127 oct)

* ==============================================================================
* UserIRQ (50 Hz, sync VBL) — identique au mode road
* ==============================================================================
UserIRQ
        jsr   gfxlock.bufferSwap.check
        rts

* ==============================================================================
* RAM data (réutilise celle du mode road : même layout)
* ==============================================================================
        INCLUDE "./game-mode/road/ram-data.asm"

* ==============================================================================
* Engine routines (identiques au mode road — même conf)
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

        ; --- Lotus port : physics tick (inclus pour résoudre les symboles) ---
        INCLUDE "./engine/physics/Lotus_PhysicsTick.asm"

        ; --- Lotus port : projection (incluse, non appelée en debug) ---
        INCLUDE "./engine/math/Mul9x16.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/projection/SparseProjection.asm"
        INCLUDE "./engine/projection/LinearInterp.asm"

        ; --- Lotus port : EQU patterns ---
        INCLUDE "./game-mode/road/generated/road_patterns_externs.inc"

        ; --- Lotus port : tables Road_lines + dispatch ---
        INCLUDE "./engine/projection/RoadLinesTable.asm"
        INCLUDE "./engine/projection/RoadDrawDispatch.asm"

        ; --- Lotus port : rendu route (contient DrawFrameRoad_Debug) ---
        INCLUDE "./engine/projection/DrawFrameRoad.asm"

        ; --- Données circuit ---
        INCLUDE "./engine/circuits/22_hard_5.asm"

        ; --- DOIT être en dernier (dépendances ifdef) ---
        INCLUDE "./engine/InitGlobals.asm"
