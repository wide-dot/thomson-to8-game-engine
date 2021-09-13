; ---------------------------------------------------------------------------
; Object - Coffee
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"

Coffee
        lda   routine,u
        asla
        ldx   #Coffee_Routines
        jmp   [a,x]

Coffee_Routines
        fdb   Coffee_Init
        fdb   Coffee_Main

Coffee_Init

        ; Set Key Frame
        ; --------------------------------------------

        ldb   #$02                         ; load page 2
        stb   $E7E5                        ; in data space ($A000-$DFFF)
        ldx   #Bgi_titleScreen
        jsr   DrawFullscreenImage

        lda   $E7DD                        ; set border color
        anda  #$F0  
        adda  #$08                         ; color ref
        sta   $E7DD
        anda  #$0F
        adda  #$80
        sta   glb_screen_border_color+1    ; maj WaitVBL
        jsr   WaitVBL
        ldb   #$03                         ; load page 3
        stb   $E7E5                        ; data space ($A000-$DFFF)
        ldx   #Bgi_titleScreen
        jsr   DrawFullscreenImage

        ldd   #Pal_Coffee
        std   Cur_palette
        clr   Refresh_palette
        jsr   WaitVBL

        ; Init Object
        ; --------------------------------------------
        ldb   #$08
        stb   priority,u

        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ldd   #$807F
        std   xy_pixel,u

        ldd   #Ani_Coffee
        std   anim,u

        ; Init Sound Driver
        ; --------------------------------------------
        jsr   PSGInit
        jsr   IrqSet50Hz
        ldx   #Psg_001
        jsr   PSGPlay
        
        inc   routine,u

Coffee_Main
        jsr   AnimateSprite
        jmp   DisplaySprite
