        opt   c,ct

* ==============================================================================
* road-generator — Game Mode "road"
* ------------------------------------------------------------------------------
* Port Lotus Esprit Turbo Challenge sur TO8.
*
* ==============================================================================

SOUND_CARD_PROTOTYPE equ 1

* ============================================================================
* Circuit selection — pour changer de circuit modifier UNIQUEMENT ces 3 lignes.
* Les labels Circuit_<id>_nb_segments / Circuit_<id>_segments sont définis
* par engine/circuits/<id>.asm (cf. liste 00_training..32_hard_15).
*
* Note : forward EQU resolus en pass-2 lwasm. L'INCLUDE est plus bas.
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
        jsr   CopyPageATo0

        jsr   LoadAct                   ; palette + bordure (cf. main.properties)

        ; --- Alloue l'objet PlayerOne ---
        ; Note : PlayerOne OST est dans Dynamic_Object_RAM (= l'engine
        ; gère le lifecycle via RunObjects), MAIS son alias `player1=dp`
        ; permet l'adressage direct depuis le code de l'objet.
        ; Init de player1 OST (en DP) :
        lda   #ObjID_PlayerOne
        sta   <player1+id
        clr   <player1+routine         ; commence en Init routine

        ; --- Charge le circuit ---
        ; Chaque circuit expose 2 labels publics :
        ;   Circuit_xxx_nb_segments  : 1 mot (uint16) = N
        ;   Circuit_xxx_segments     : (N+8) × 16 octets
        ldd   ACTIVE_CIRCUIT_NB         ; = Circuit_<id>_nb_segments
        std   Circuit_nb_segments
        ldd   #ACTIVE_CIRCUIT_BASE      ; = Circuit_<id>_segments
        std   Circuit_base
        ; segment_idx du joueur initialisé à 0 dans PlayerOne_Init.

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

        ; --- Init pointeurs buffers projection (= setup une fois) ---
        ; Le pipeline projection :
        ;   PlayerOne_State + Circuit_base → SparseProjection → Sparse_Buffer
        ;   Sparse_Buffer → LinearInterp → Dense_Buffer
        ;   Dense_Buffer → DrawFrameRoad → VRAM
        ldd   #Sparse_Buffer
        std   Proj_buffer_ptr
        std   LinearInterp_buffer_in
        ldd   #Dense_Buffer
        std   LinearInterp_buffer_out

* ==============================================================================
* Main Loop
* ==============================================================================
MainLoop
        jsr   ReadJoypads               ; engine: lit $E7CC + calcule Dpad_Held + Dpad_Press
        _RunObject ObjID_PlayerOne,#player1
        jsr   RunObjects                ; PlayerOne → drain input → PhysicsTick
                                         ; (update speed, segment_idx, track_pos)

        * --- DEBUG STEP 3 : projection RÉACTIVÉE ---
        * SparseProjection lit l'état Lotus + circuit, projette les segments
        * sparses dans Sparse_Buffer. LinearInterp interpole en triplets dans
        * Dense_Buffer. DrawFrameRoad lit width par scanline (= effet
        * perspective), avec fallback Line_0254 sur triplet vide.
        ldu   #PlayerOne_State
        jsr   SparseProjection
        jsr   LinearInterp

        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   UnsetDisplayPriority

        * --- PRC est piloté per-scanline par DrawFrameRoad (bit 10 LI_d7) ---
        * Plus de hardcode global ici : le dithering perspective-cohérent est
        * fait par DFR_main_loop via la valeur extra du triplet Dense_Buffer.

        jsr   DrawFrameRoad             ; route complète : horizon→bas, 2 banques, dithering
        jsr   DFR_border_mask           ; mask 8px L+R des n scanlines rendues sur les 2 banks
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
        INCLUDE "./engine/ram/CopyPageATo0.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"

        ; --- Object management ---
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"

        ; --- Animation ---
        ;INCLUDE "./engine/graphics/animation/AnimateSprite.asm"

        ; --- Sprite pack ---
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"

        ; --- Lotus port : physics tick (input lu via Dpad_Held de ReadJoypads) ---
        INCLUDE "./engine/physics/Lotus_PhysicsTick.asm"

        ; --- Lotus port : projection sparse (task #C) ---
        INCLUDE "./engine/math/Mul9x16.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/joypad/InitJoypads.asm"

        INCLUDE "./engine/projection/SparseProjection.asm"

        ; --- Lotus port : interpolateur linéaire (task #D) ---
        ; LinearInterp utilise la table FILE59 2-tier paged à $5000-$5BFF
        ; (= cf PerspectiveTables.asm LI_TABLE_A_BASE/LI_TABLE_B_BASE).
        ; A4 dither lookup via A4_table résident (64 oct).
        INCLUDE "./engine/projection/LinearInterp.asm"

        ; --- Lotus port : EQU patterns (= adresses Road_R*/Road_draw_KX_JY
        ; dans la pattern bank, valides quand celle-ci est mountée à $4000) ---
        INCLUDE "./game-mode/road/generated/road_patterns_externs.inc"

        ; --- Lotus port : table de dispatch Road_lines (~2 Ko résident).
        ; Lookup par scanline → ptr vers Line_NNNN dans road_buffers
        ; (cart zone $0000-$3FFF quand la page road_buffers est mountée). ---
        INCLUDE "./engine/projection/RoadLinesTable.asm"
        INCLUDE "./engine/projection/RoadDrawDispatch.asm"

        ; --- Lotus port : rendu route (task #E v1 minimal) ---
        INCLUDE "./engine/projection/DrawFrameRoad.asm"

        ; --- Données circuit (= sortie de generate_circuits.py) ---
        INCLUDE "./engine/circuits/22_hard_5.asm"

        ; --- DOIT être en dernier (dépendances ifdef sur ce qui précède) ---
        INCLUDE "./engine/InitGlobals.asm"
