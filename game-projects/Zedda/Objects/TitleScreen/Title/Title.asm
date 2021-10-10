; ---------------------------------------------------------------------------
; Object - Title
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"
	INCLUDE "./Objects/SFX/PaletteFade/PaletteFade.idx"

Title
        lda   routine,u
        asla
        ldx   #Title_Routines
        jmp   [a,x]

Title_Routines
        fdb   Title_Init
        fdb   Title_Wait
        fdb   Title_FadeIn
	fdb   Title_WaitFadeIn
        fdb   Title_End

Title_Init
	inc   routine,u
        ldd   #414                     ; nb of frames before fade in
        std   ext_variables,u
	rts

Title_Wait
        ldd   ext_variables,u
	subd  #1
	std   ext_variables,u
	beq   @a
	rts
@a      ldd   #Img_Title
        std   image_set,u
	ldd   #$857A
        std   xy_pixel,u
	ldb   #4
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
	inc   routine,u
        jmp   DisplaySprite	

Title_FadeIn
        ldx   #Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x     
	ldb   #4                       ; wait two frames between palette update                      
        stb   subtype,x        
        ldd   #Pal_Triangle
        std   pal_src,x
        ldd   #Pal_Title
        std   pal_dst,x     
	inc   routine,u  
        ldd   #16                      ; nb of frames before priority swap
        std   ext_variables,u	 	
        jmp   DisplaySprite

Title_WaitFadeIn
        ldd   ext_variables,u
        subd  #1
	std   ext_variables,u
        beq   Title_SetPriority
        jmp   DisplaySprite
        
Title_SetPriority
	inc   routine,u        
	ldb   #2
        stb   priority,u	
        jmp   DisplaySprite

Title_End
        jmp   DisplaySprite
