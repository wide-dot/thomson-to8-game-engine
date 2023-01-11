Level
        lda   routine,u
        asla
        ldx   #Level_Routines
        jmp   [a,x]

Level_Routines
        fdb   Level_Init_0
        fdb   Level_Init_1
        fdb   Level_End

Level_Init_0
        ldd   #Img_lvl01_init
        std   image_set,u
	ldd   #$806B
        std   xy_pixel,u
	ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
	inc   routine,u
        jmp   DisplaySprite	

Level_Init_1
	inc   routine,u
        jmp   DisplaySprite

Level_End
        jmp   DeleteObject

