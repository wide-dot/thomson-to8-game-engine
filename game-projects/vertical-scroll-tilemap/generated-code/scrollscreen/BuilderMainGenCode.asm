* Generated Code

Palette_scrollscreen
        fdb   $0000
        fdb   $0f00
        fdb   $ff0f
        fdb   $0002
        fdb   $ff00
        fdb   $f20f
        fdb   $000f
        fdb   $2000
        fdb   $f000
        fdb   $0300
        fdb   $2e00
        fdb   $ee02
        fdb   $e002
        fdb   $2202
        fdb   $020e
        fdb   $200c

Obj_Index_Page
        fcb   $00
        fcb   $64
        fcb   $65
Obj_Index_Address
        fcb   $00,$00
        fcb   $01,$7F
        fcb   $00,$00
Img_Page_Index
        fcb   $00
        fcb   $80
        fcb   $80
Ani_Page_Index
        fcb   $00
        fcb   $80
        fcb   $80
Ani_Asd_Index
        fdb   $0000
        fdb   $0000
        fdb   $0000
LoadAct
        ldb   #$02                     * load page 2
        stb   $E7E5                    * in data space ($A000-$DFFF)
        ldx   #$0000                   * set Background solid color
        jsr   ClearDataMem
        lda   $E7DD                    * set border color
        anda  #$F0
        adda  #$00                     * color ref
        sta   $E7DD
        anda  #$0F
        adda  #$80
        sta   gfxlock.screenBorder.color
 IFDEF gfxlock.bufferSwap.do
        jsr   gfxlock.bufferSwap.do
 ENDC
 IFDEF WaitVBL
        jsr   WaitVBL
 ENDC
        ldb   #$03                     * load page 3
        stb   $E7E5                    * data space ($A000-$DFFF)
        ldx   #$0000                   * set Background solid color
        jsr   ClearDataMem
        ldd   #Palette_scrollscreen
        std   Pal_current
        clr   PalRefresh
        rts