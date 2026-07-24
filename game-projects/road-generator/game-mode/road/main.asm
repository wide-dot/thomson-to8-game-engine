        opt   c,ct
* Sparse_Buffer déporté dans l'objet RoadEngine (page paginée) pour ce mode.
* Ce flag fait sauter sa def dans ram-data.asm (partagé avec road-debug qui,
* lui, n'a pas le flag → garde Sparse_Buffer résident, intact).
SPARSE_BUFFER_DEPORTED equ 1

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
; Circuit déporté dans l'objet RoadEngine (sélection + Circuit_base/nb posés
; par RoadEngine_Init). Plus d'ACTIVE_CIRCUIT_* ni d'INCLUDE circuit en main.

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

        ; --- Init RoadEngine (objet paginé) : pose Circuit_base/nb + buffer ptrs
        ;     AU BOOT, avant la physique (qui lit Circuit_base/segment_idx).
        ;     Le circuit est déporté dans la page RoadEngine.
        _RunObjectRoutineB ObjID_RoadEngine,#0
        ; segment_idx du joueur initialisé à 0 dans PlayerOne_Init.

        ; --- Sprites bord-de-piste (roadside) : voir lotus-ste/doc/extraction/
        ;     41_roadside_objects_plan.md. Approche RETENUE = BLIT DIRECT par frame
        ;     (pas de pool OST / DisplaySprite). À implémenter : Phase1 projection
        ;     dans RoadEngine -> Roadside_DrawList résident ; Phase2 Roadside_BlitAll
        ;     après DrawFrameRoad. (Pool OST B3/B4/B5 retiré = cleanup.)

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

        ; --- Init pointeurs buffers projection : déplacé dans l'objet RoadEngine
        ;     (qui détient SP/LI). Le pipeline : PlayerOne_State + Circuit_base
        ;     → RoadEngine{SparseProjection → Sparse_Buffer → LinearInterp →
        ;     Dense_Buffer} → DrawFrameRoad (main) → VRAM.

* ==============================================================================
* Main Loop
* ==============================================================================
MainLoop
        jsr   ReadJoypads               ; engine: lit $E7CC + calcule Dpad_Held + Dpad_Press
        _RunObject ObjID_PlayerOne,#player1   ; physique : track_pos, segment_idx
        jsr   RunObjects
        * RoadEngine #1 : SparseProjection + LinearInterp (alimente DrawFrameRoad).
        _RunObjectRoutineB ObjID_RoadEngine,#1

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
        jmp   MainLoop                  ; jmp : _gfxlock.loop étendu (frame-drop cap) met MainLoop hors portée d'un bra

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

        ; --- SparseProjection + LinearInterp : DÉPORTÉS dans l'objet RoadEngine
        ;     paginé (objects/road-engine/road-engine.asm). Plus inclus en main. ---

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
        ; Circuit 22_hard_5 : déporté dans l'objet RoadEngine (plus en main).

        ; --- DOIT être en dernier (dépendances ifdef sur ce qui précède) ---
        INCLUDE "./engine/InitGlobals.asm"
