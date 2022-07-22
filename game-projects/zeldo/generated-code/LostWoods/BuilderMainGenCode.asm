* Generated Code

Pal_Triangle
        fdb   $0000
        fdb   $be00
        fdb   $6900
        fdb   $3500
        fdb   $2300
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0300
        fdb   $8906
        fdb   $be00
        fdb   $3500
        fdb   $0000
        fdb   $0000

Pal_Flash_G
        fdb   $f000
        fdb   $760d
        fdb   $430a
        fdb   $1105
        fdb   $1105
        fdb   $8906
        fdb   $3402
        fdb   $2201
        fdb   $1101
        fdb   $4000
        fdb   $2000
        fdb   $1000
        fdb   $be00
        fdb   $3500
        fdb   $dd02
        fdb   $ee00

Pal_Flash
        fdb   $0000
        fdb   $760d
        fdb   $430a
        fdb   $1105
        fdb   $1105
        fdb   $8906
        fdb   $3402
        fdb   $2201
        fdb   $1101
        fdb   $4000
        fdb   $2000
        fdb   $1000
        fdb   $be00
        fdb   $3500
        fdb   $1901
        fdb   $0300

Pal_Title
        fdb   $0000
        fdb   $760d
        fdb   $430a
        fdb   $1105
        fdb   $1105
        fdb   $8906
        fdb   $3402
        fdb   $2201
        fdb   $1101
        fdb   $4000
        fdb   $0300
        fdb   $8906
        fdb   $be00
        fdb   $3500
        fdb   $1901
        fdb   $0300

Pal_TriangleTmp
        fdb   $0000
        fdb   $be00
        fdb   $6900
        fdb   $3500
        fdb   $2300
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0300
        fdb   $8906
        fdb   $be00
        fdb   $3500
        fdb   $0000
        fdb   $0000

Pal_Flash_R
        fdb   $0f00
        fdb   $760d
        fdb   $430a
        fdb   $1105
        fdb   $1105
        fdb   $8906
        fdb   $3402
        fdb   $2201
        fdb   $1101
        fdb   $4000
        fdb   $2000
        fdb   $1000
        fdb   $be00
        fdb   $3500
        fdb   $1901
        fdb   $0f00

Pal_Flash_B
        fdb   $000f
        fdb   $760d
        fdb   $430a
        fdb   $1105
        fdb   $1105
        fdb   $8906
        fdb   $3402
        fdb   $2201
        fdb   $1101
        fdb   $4000
        fdb   $2000
        fdb   $1000
        fdb   $be00
        fdb   $3500
        fdb   $5e0e
        fdb   $090f

Pal_LostWoods2
        fdb   $1000
        fdb   $2000
        fdb   $3000
        fdb   $1201
        fdb   $2301
        fdb   $3501
        fdb   $6803
        fdb   $3102
        fdb   $6203
        fdb   $ff0f
        fdb   $4d01
        fdb   $1200
        fdb   $7902
        fdb   $4000
        fdb   $0000
        fdb   $1b06

Pal_LostWoods3
        fdb   $1000
        fdb   $2000
        fdb   $3000
        fdb   $1201
        fdb   $2301
        fdb   $3501
        fdb   $6803
        fdb   $3102
        fdb   $6203
        fdb   $ff0f
        fdb   $4d01
        fdb   $1200
        fdb   $7902
        fdb   $4000
        fdb   $0000
        fdb   $1b06

Pal_LostWoods1
        fdb   $1000
        fdb   $2000
        fdb   $3000
        fdb   $1201
        fdb   $2301
        fdb   $3501
        fdb   $6803
        fdb   $3102
        fdb   $6203
        fdb   $ff0f
        fdb   $4d01
        fdb   $1200
        fdb   $7902
        fdb   $4000
        fdb   $0000
        fdb   $1b06

Obj_Index_Page
        fcb   $00
        fcb   $6C
        fcb   $6C
        fcb   $6C
        fcb   $6C
        fcb   $6B
        fcb   $67
        fcb   $6A
        fcb   $67
Obj_Index_Address
        fcb   $00,$00
        fcb   $00,$00
        fcb   $38,$C6
        fcb   $37,$C8
        fcb   $01,$38
        fcb   $00,$00
        fcb   $13,$14
        fcb   $00,$00
        fcb   $12,$C0
Smps_Zelda 
        fcb   $6C,$20,$C0,$29,$E1
        fcb   $00
Img_Page_Index
        fcb   $00
        fcb   $67
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $8F
        fcb   $80
        fcb   $80
        fcb   $80
Ani_Page_Index
        fcb   $00
        fcb   $64
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $80
Ani_Asd_Index
        fdb   $0000
        fdb   $01D9
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0667
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
        ldd   #Pal_Triangle
        std   Cur_palette
        clr   Refresh_palette
        rts