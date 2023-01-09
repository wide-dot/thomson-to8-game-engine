
Backgrnd
    CLRA
PALETTE_SAME
    PSHS A             ;
    ASLA               ;
    STA $E7DB          ;
    LDD #$0000         ;* all colors same color
    STB $E7DA          ;
    STA $E7DA          ;
    PULS A             ;
    INCA               ;
    CMPA #$10          ;
    BNE PALETTE_SAME   ;

        lda   routine,u
        asla
        ldx   #Backgrnd_Routines
        jmp   [a,x]

loop_count
    DEC   var_count
    BNE   loop_count
reset_count
    lda   #255
    sta   var_count


Backgrnd_Routines
        fdb   Backgrnd_Back1
        fdb   Backgrnd_Back1
        fdb   Backgrnd_Back2
        fdb   Backgrnd_Back2
        fdb   Backgrnd_Back3
        fdb   Backgrnd_Back3
        fdb   Backgrnd_Back4
        fdb   Backgrnd_Back4
        fdb   Backgrnd_Back5
        fdb   Backgrnd_Back5
        fdb   Backgrnd_Back6
        fdb   Backgrnd_Back6
        fdb   Backgrnd_Back7
        fdb   Backgrnd_Back7
        fdb   Backgrnd_Back1
        fdb   Backgrnd_Back1
        fdb   Backgrnd_Back8
        fdb   Backgrnd_Back8
        fdb   Backgrnd_Main

Backgrnd_Back1
    ldd   #Pal_01
    std   Pal_current
*    clr   PalRefresh
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldd   #Img_back1
        std   image_set,u
        inc   routine,u
        jmp   Backgrnd_Main

Backgrnd_Back2
    ldd   #Pal_02
    std   Pal_current
*    clr   PalRefresh
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldd   #Img_back2
        std   image_set,u
        inc   routine,u
        jmp   Backgrnd_Main

Backgrnd_Back3
    ldd   #Pal_03
    std   Pal_current
*    clr   PalRefresh
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldd   #Img_back3
        std   image_set,u
        inc   routine,u
        jmp   Backgrnd_Main
Backgrnd_Back4
    ldd   #Pal_04
    std   Pal_current
*    clr   PalRefresh
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldd   #Img_back4
        std   image_set,u
        inc   routine,u
        jmp   Backgrnd_Main
Backgrnd_Back5
    ldd   #Pal_05
    std   Pal_current
*    clr   PalRefresh
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldd   #Img_back5
        std   image_set,u
        inc   routine,u
        jmp   Backgrnd_Main
Backgrnd_Back6
    ldd   #Pal_06
    std   Pal_current
*    clr   PalRefresh
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldd   #Img_back6
        std   image_set,u
        inc   routine,u
        jmp   Backgrnd_Main
Backgrnd_Back7
    ldd   #Pal_07
    std   Pal_current
*    clr   PalRefresh
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldd   #Img_back7
        std   image_set,u
        inc   routine,u
        jmp   Backgrnd_Main
Backgrnd_Back8
    ldd   #Pal_08
    std   Pal_current
*    clr   PalRefresh
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldd   #Img_back8
        std   image_set,u
        inc   routine,u
        jmp   Backgrnd_Main

Backgrnd_Main
        clr   PalRefresh
        jmp   DisplaySprite


var_count fcb 255
