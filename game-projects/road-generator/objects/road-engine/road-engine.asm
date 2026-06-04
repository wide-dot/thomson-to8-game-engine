; ============================================================================
; Object — RoadEngine (objet paginé "hors pool dynamique")
;
; Déporte hors de la main RAM : code projection (SparseProjection + LinearInterp)
; ET les données circuit (Circuit_22_hard_5), dans une page cartouche
; $0000-$3FFF (RAM inscriptible). Libère la main pour les OST des sprites.
;
; Routines (invoquées via `_RunObjectRoutineB ObjID_RoadEngine,#n`) :
;   #0 = Init : pose Circuit_base/nb + pointeurs buffers. Appelé 1× AU BOOT
;               (avant la physique, qui lit Circuit_base/segment_idx).
;   #1 = Main : projection (SparseProjection puis LinearInterp). 1×/frame.
;
; Résidents (main.glb) : Circuit_base, Circuit_nb_segments, Proj_buffer_ptr,
; Sparse_Buffer, Dense_Buffer, Proj_min_y/count/first/last, PlayerOne_State,
; dp_extreg. Locaux ici : circuit data, SP/LI scratch, LinearInterp_buffer_in/out.
; ============================================================================
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/struct/LotusCarState.struct.asm"

RoadEngine
        aslb
        ldx   #RoadEngine_Routines
        jmp   [b,x]
RoadEngine_Routines
        fdb   RoadEngine_Init
        fdb   RoadEngine_Main

RoadEngine_Init
        * Circuit (déporté ici) → Circuit_base/nb résidents (lus par physics/SP)
        ldd   #Circuit_22_hard_5_segments
        std   Circuit_base
        ldd   Circuit_22_hard_5_nb_segments
        std   Circuit_nb_segments
        * Pointeurs buffers projection (Sparse/Dense résidents)
        ldd   #Sparse_Buffer
        std   Proj_buffer_ptr
        std   LinearInterp_buffer_in
        ldd   #Dense_Buffer
        std   LinearInterp_buffer_out
        rts

RoadEngine_Main
        ldu   #PlayerOne_State
        lbsr  SparseProjection
        lbsr  LinearInterp
        rts

        INCLUDE "./engine/projection/SparseProjection.asm"
        INCLUDE "./engine/projection/LinearInterp.asm"
        INCLUDE "./engine/circuits/22_hard_5.asm"

* Sparse_Buffer (intermédiaire SP→LI, non lu par DrawFrameRoad) : déporté ici
* (page RoadEngine, RAM inscriptible). Libère 1280 oct de main.
Sparse_Buffer                     fill  0,1280
