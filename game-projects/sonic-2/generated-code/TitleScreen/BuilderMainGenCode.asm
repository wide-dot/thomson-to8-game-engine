* Generated Code

Pal_Island
        fdb   $410b
        fdb   $0000
        fdb   $100c
        fdb   $6a02
        fdb   $2000
        fdb   $4000
        fdb   $4a01
        fdb   $2600
        fdb   $bb0b
        fdb   $7100
        fdb   $a400
        fdb   $420a
        fdb   $000e
        fdb   $740b
        fdb   $2301
        fdb   $0000

Pal_SEGA
        fdb   $ff0f
        fdb   $4404
        fdb   $1101
        fdb   $0000
        fdb   $0300
        fdb   $0f00
        fdb   $5e03
        fdb   $2501
        fdb   $b70b
        fdb   $740b
        fdb   $410b
        fdb   $100b
        fdb   $110c
        fdb   $0008
        fdb   $100b
        fdb   $100b

Pal_TitleScreen
        fdb   $ff0f
        fdb   $0000
        fdb   $0800
        fdb   $0200
        fdb   $5d03
        fdb   $1600
        fdb   $4f00
        fdb   $2700
        fdb   $ff00
        fdb   $f300
        fdb   $f80f
        fdb   $640e
        fdb   $2205
        fdb   $000e
        fdb   $0100
        fdb   $0000

Pal_SEGAMid
        fdb   $ff0f
        fdb   $4404
        fdb   $1101
        fdb   $0000
        fdb   $0300
        fdb   $0f00
        fdb   $5e03
        fdb   $2501
        fdb   $b70b
        fdb   $740b
        fdb   $410b
        fdb   $100b
        fdb   $110c
        fdb   $0008
        fdb   $ff0f
        fdb   $100b

Pal_SonicAndTailsIn
        fdb   $0000
        fdb   $ff0f
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $ff0f
        fdb   $ff0f

Pal_SEGAEnd
        fdb   $ff0f
        fdb   $4404
        fdb   $1101
        fdb   $0000
        fdb   $0300
        fdb   $0f00
        fdb   $5e03
        fdb   $2501
        fdb   $b70b
        fdb   $740b
        fdb   $410b
        fdb   $100b
        fdb   $110c
        fdb   $0008
        fdb   $ff0f
        fdb   $ff0f

Obj_Index_Page
        fcb   $00
        fcb   $64
        fcb   $64
        fcb   $64
        fcb   $64
        fcb   $64
Obj_Index_Address
        fcb   $00,$00
        fcb   $12,$D7
        fcb   $0D,$14
        fcb   $0C,$62
        fcb   $09,$B8
        fcb   $02,$26
Pcm_SEGA 
        fcb   $9F,$00,$00,$30,$BA
        fcb   $00
Smps_TitleScreen 
        fcb   $88,$00,$00,$01,$96
        fcb   $00
Smps_Sparkle 
        fcb   $80,$03,$34,$03,$49
        fcb   $00
Img_Page_Index
        fcb   $00
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $88
        fcb   $8C
Ani_Page_Index
        fcb   $00
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $80
Ani_Asd_Index
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $079F
        fdb   $0349
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
        ldd   #Pal_SEGA
        std   Cur_palette
        clr   Refresh_palette
        rts