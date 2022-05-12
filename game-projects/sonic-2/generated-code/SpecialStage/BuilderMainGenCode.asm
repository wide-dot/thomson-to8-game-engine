* Generated Code

Pal_HalfPipe
        fdb   $ff0f
        fdb   $3300
        fdb   $1101
        fdb   $0000
        fdb   $0300
        fdb   $0f00
        fdb   $6f03
        fdb   $1600
        fdb   $3a00
        fdb   $6f00
        fdb   $ff00
        fdb   $600a
        fdb   $3006
        fdb   $2004
        fdb   $310e
        fdb   $0008

Obj_Index_Page
        fcb   $00
        fcb   $64
        fcb   $65
Obj_Index_Address
        fcb   $00,$00
        fcb   $02,$0F
        fcb   $00,$00
Smps_SpecialStage 
        fcb   $83,$00,$00,$05,$66
        fcb   $00
Img_Page_Index
        fcb   $00
        fcb   $83
        fcb   $83
Ani_Page_Index
        fcb   $00
        fcb   $80
        fcb   $82
Ani_Asd_Index
        fdb   $0000
        fdb   $031D
        fdb   $0000
Bgi_specialStage 
        fcb   $A9,$00,$00
LoadAct
        ldb   #$02                     * load page 2
        stb   $E7E5                    * in data space ($A000-$DFFF)
        ldx   #Bgi_specialStage
        jsr   DrawFullscreenImage
        lda   $E7DD                    * set border color
        anda  #$F0
        adda  #$03                     * color ref
        sta   $E7DD
        anda  #$0F
        adda  #$80
        sta   glb_screen_border_color+1    * maj WaitVBL
        jsr   WaitVBL
        ldb   #$03                     * load page 3
        stb   $E7E5                    * data space ($A000-$DFFF)
        ldx   #Bgi_specialStage
        jsr   DrawFullscreenImage
        ldd   #Pal_HalfPipe
        std   Cur_palette
        clr   Refresh_palette
        rts