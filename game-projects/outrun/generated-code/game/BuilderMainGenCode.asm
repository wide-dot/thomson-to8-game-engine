* Generated Code

Pal_default
        fdb   $0000
        fdb   $1101
        fdb   $4404
        fdb   $bb0b
        fdb   $0005
        fdb   $000a
        fdb   $100b
        fdb   $200e
        fdb   $3000
        fdb   $9001
        fdb   $0b00
        fdb   $1b00
        fdb   $0200
        fdb   $1400
        fdb   $3800
        fdb   $bb00

Obj_Index_Page
        fcb   $00
        fcb   $64
        fcb   $64
Obj_Index_Address
        fcb   $00,$00
        fcb   $16,$C8
        fcb   $01,$6D
Snd_01 
        fcb   $80,$2A,$BF,$3C,$96
        fcb   $00
Snd_02 
        fcb   $80,$0C,$5E,$2A,$BF
        fcb   $00
Snd_03 
        fcb   $81,$00,$00,$22,$15
        fcb   $00
Snd_04 
        fcb   $80,$02,$7F,$0C,$5E
        fcb   $00
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
        sta   glb_screen_border_color+1    * maj WaitVBL
        jsr   WaitVBL
        ldb   #$03                     * load page 3
        stb   $E7E5                    * data space ($A000-$DFFF)
        ldx   #$0000                   * set Background solid color
        jsr   ClearDataMem
        ldd   #Pal_default
        std   Pal_current
        clr   PalRefresh
        rts