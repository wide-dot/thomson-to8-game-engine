; ---------------------------------------------------------------------------
; Object - Triangle
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"

Triangle
        lda   routine,u
        asla
        ldx   #Triangle_Routines
        jmp   [a,x]

Triangle_Routines
        fdb   Triangle_Init
        fdb   Triangle_Main
        fdb   Triangle_MainOdd
	fdb   Triangle_Final

Triangle_Init

        ; Init Object
        ; --------------------------------------------
        ldb   #3
        stb   priority,u

        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ldd   #$807F
        std   xy_pixel,u

        ldd   #Ani_01
        std   anim,u

        jsr   AnimateSprite        

Triangle_Main
        inc   routine,u
        jmp   DisplaySprite

Triangle_MainOdd
        dec   routine,u
        jsr   AnimateSprite

	ldd   anim,u
	cmpd  #Ani_08
	bne   @a
	inc   routine,u                ; go to final state
        jmp   DisplaySprite	
@a      jsr   GetImgIdA                ; preprocessed palette color switch
        cmpa  oldPal
        beq   @b
        sta   oldPal
        stu   @dyn+1
        ldb   #0
        ldy   #Pal_Triangle+2          ; offset because cycling colors indexes are 1-4
        ldu   #Pal_TriangleTmp
        _lsrd
        _lsrd
        lsrb
        lsrb
        lsrb
        lsrb
        lsrb
        ldx   b,y
        stx   8,u
        _lsrd
        _lsrd
        lsrb
        lsrb
        lsrb
        lsrb
        lsrb
        ldx   b,y
        stx   6,u
        _lsrd
        _lsrd
        lsrb
        lsrb
        lsrb
        lsrb
        lsrb
        ldx   b,y
        stx   4,u
        _lsrd
        _lsrd
        lsrb
        lsrb
        lsrb
        lsrb
        lsrb
        ldx   b,y
        stx   2,u
        stu   Cur_palette
        clr   Refresh_palette       
@dyn    ldu   #0                       ; (dynamic)
@b      jmp   DisplaySprite        

Triangle_Final
        jmp   DisplaySprite

oldPal  fcb   27 ; 0b00011011 means 0 1 2 3, each number on 2 bits