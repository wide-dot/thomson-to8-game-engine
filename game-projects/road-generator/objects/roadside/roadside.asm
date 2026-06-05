; ============================================================================
; Object — Roadside (sprites bord-de-piste) — CODE-ONLY (hors run-list)
;
; Approche RETENUE = BLIT DIRECT par frame (PAS de pool OST / DisplaySprite).
; Cf. lotus-ste/doc/extraction/41_roadside_objects_plan.md.
;
; Cet objet est le CONTENEUR : sprites compilés (déclarés ;ND0,NB0 dans
; roadside.properties, 6 sprites × 8 niveaux), la table image_set ci-dessous,
; et (à venir) Roadside_BlitAll = Phase 2 (lit Roadside_DrawList résident et
; blitte chaque sprite direct via DRS_XYToAddress + jsr [draw_routine]).
;
; Invocation future : _RunObjectRoutineB ObjID_Roadside,#n (mount page + dispatch,
; sans OST). Pour l'instant Roadside_BlitAll = placeholder (cleanup : tout le
; mécanisme pool/OST B3-B5 a été retiré).
; ============================================================================
        INCLUDE "./engine/macros.asm"

Roadside
        aslb
        ldx   #Roadside_Routines
        jmp   [b,x]
Roadside_Routines
        fdb   Roadside_BlitAll

Roadside_BlitAll
        * TODO Phase 2 : itérer Roadside_DrawList résident {imgsel,x_pixel,y_pixel}×N,
        * résoudre image_set via Roadside_ImgTable, blitter direct dans le back-buffer
        * (déréf mapping_frame variante overlay -> DRS_XYToAddress -> mount page draw
        *  -> ldu glb_screen_location_2 -> jsr [draw_routine]).
        rts

* ----------------------------------------------------------------------
* Roadside_ImgTable — image_set par (sprite_idx 1..7) × (level 0..7).
* sprite_idx -> FILE via Circuit_xx_sprite_lut : 1=$82(absent->alias $83),
* 2=$83, 3=$87, 4=$81, 5=$8F, 6=$90, 7=$80.
* ----------------------------------------------------------------------
Roadside_ImgTable
        fdb   Img_Roadside_83_L0,Img_Roadside_83_L1,Img_Roadside_83_L2,Img_Roadside_83_L3
        fdb   Img_Roadside_83_L4,Img_Roadside_83_L5,Img_Roadside_83_L6,Img_Roadside_83_L7  ; idx1 ($82 absent -> alias $83)
        fdb   Img_Roadside_83_L0,Img_Roadside_83_L1,Img_Roadside_83_L2,Img_Roadside_83_L3
        fdb   Img_Roadside_83_L4,Img_Roadside_83_L5,Img_Roadside_83_L6,Img_Roadside_83_L7  ; idx2 $83
        fdb   Img_Roadside_87_L0,Img_Roadside_87_L1,Img_Roadside_87_L2,Img_Roadside_87_L3
        fdb   Img_Roadside_87_L4,Img_Roadside_87_L5,Img_Roadside_87_L6,Img_Roadside_87_L7  ; idx3 $87
        fdb   Img_Roadside_81_L0,Img_Roadside_81_L1,Img_Roadside_81_L2,Img_Roadside_81_L3
        fdb   Img_Roadside_81_L4,Img_Roadside_81_L5,Img_Roadside_81_L6,Img_Roadside_81_L7  ; idx4 $81
        fdb   Img_Roadside_8F_L0,Img_Roadside_8F_L1,Img_Roadside_8F_L2,Img_Roadside_8F_L3
        fdb   Img_Roadside_8F_L4,Img_Roadside_8F_L5,Img_Roadside_8F_L6,Img_Roadside_8F_L7  ; idx5 $8F
        fdb   Img_Roadside_90_L0,Img_Roadside_90_L1,Img_Roadside_90_L2,Img_Roadside_90_L3
        fdb   Img_Roadside_90_L4,Img_Roadside_90_L5,Img_Roadside_90_L6,Img_Roadside_90_L7  ; idx6 $90
        fdb   Img_Roadside_80_L0,Img_Roadside_80_L1,Img_Roadside_80_L2,Img_Roadside_80_L3
        fdb   Img_Roadside_80_L4,Img_Roadside_80_L5,Img_Roadside_80_L6,Img_Roadside_80_L7  ; idx7 $80
