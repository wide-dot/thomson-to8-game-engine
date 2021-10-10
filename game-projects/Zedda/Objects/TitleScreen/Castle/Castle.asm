; ---------------------------------------------------------------------------
; Object - Castle
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"
	INCLUDE "./Objects/SFX/PaletteFade/PaletteFade.idx"

Castle
        lda   routine,u
        asla
        ldx   #Castle_Routines
        jmp   [a,x]

Castle_Routines
        fdb   Castle_Init
        fdb   Castle_Wait	
        fdb   Castle_Main
        fdb   Castle_End

Castle_Init
	inc   routine,u
        ldd   #508                     ; nb of frames before fade in
        std   ext_variables,u
        rts

Castle_Wait
        ldd   ext_variables,u
	subd  #1
	std   ext_variables,u
	beq   @a
	rts
@a      inc   routine,u

        ldb   #$08
        stb   priority,u

        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ldd   #$8076
        std   xy_pixel,u

        ldd   #Img_Castle
        std   image_set,u

        ldx   #Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x     
	ldb   #0                       ; wait two frames between palette update                      
        stb   subtype,x        
        ldd   #White_palette
        std   pal_src,x
        ldd   #Pal_Flash
        std   pal_dst,x  	

        jmp   DisplaySprite	

Castle_Main
        inc   routine,u
        jmp   DisplaySprite

Castle_End
        jmp   DisplaySprite
   	