* Generated Code

Pal_EHZ
        fdb   $3206
        fdb   $630e
        fdb   $a60e
        fdb   $0100
        fdb   $1400
        fdb   $3b00
        fdb   $1000
        fdb   $6000
        fdb   $9200
        fdb   $0009
        fdb   $100b
        fdb   $1b01
        fdb   $5c03
        fdb   $0000
        fdb   $3303
        fdb   $ca0d

Obj_Index_Page
        fcb   $00
        fcb   $64
        fcb   $64
        fcb   $64
        fcb   $64
        fcb   $64
        fcb   $64
Obj_Index_Address
        fcb   $00,$00
        fcb   $3B,$FB
        fcb   $36,$85
        fcb   $35,$1D
        fcb   $28,$53
        fcb   $02,$18
        fcb   $02,$03
Map_EHZ 
        fcb   $88,$3B,$F9,$3F,$F9
        fcb   $00
Chunk_EHZ_0 
        fcb   $95,$00,$00,$39,$80
        fcb   $00
Img_Page_Index
        fcb   $00
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $94
        fcb   $80
        fcb   $80
Ani_Page_Index
        fcb   $00
        fcb   $80
        fcb   $80
        fcb   $80
        fcb   $64
        fcb   $80
        fcb   $80
Ani_Asd_Index
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $0000
        fdb   $3270
        fdb   $0000
        fdb   $0000
LoadAct
        ldb   #$02                     * load page 2
        stb   $E7E5                    * in data space ($A000-$DFFF)
        ldx   #$DDDD                   * set Background solid color
        jsr   ClearDataMem
        lda   $E7DD                    * set border color
        anda  #$F0
        adda  #$0D                     * color ref
        sta   $E7DD
        anda  #$0F
        adda  #$80
        sta   glb_screen_border_color+1    * maj WaitVBL
        jsr   WaitVBL
        ldb   #$03                     * load page 3
        stb   $E7E5                    * data space ($A000-$DFFF)
        ldx   #$DDDD                   * set Background solid color
        jsr   ClearDataMem
        ldd   #Pal_EHZ
        std   Cur_palette
        clr   Refresh_palette
        rts