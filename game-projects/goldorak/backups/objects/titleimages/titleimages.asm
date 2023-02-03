    lda   var_count_buffer
    cmpa  #2
    BLT   start
****************
    ldd   var_count16
    ADDD  #1
    std   var_count16
    ldd   var_count16
    cmpd  #200              * temporisation time for next background display
    BEQ   >
        *RTS
        JMP display_text
!       *** reset all
    ldd   #0                *| reset count to 0
    std   var_count16       *| reset count to display next background image
    std   var_count16Tx     *| reset count stop to re-display text
    sta   var_count_buffer  *| reset buffer to display in 2 video buffer
        sta var_flag_displayText *| reset display text flag
    lda var_intro_slides_num    *| oncrement
    inca                        *| slide
    sta var_intro_slides_num    *| number
        lda var_intro_slides_num
        cmpa #8
        BLT >
            lda #0                      *| reset
            sta var_intro_slides_num    *| slide number to 0

!  *-----------------------------
   CLRA               ;
PALETTE_SAME
   PSHS A             ;
   ASLA               ;
   STA $E7DB          ;
   LDD #$0000         ;* all colors same color
   STB $E7DA          ;
   STA $E7DA          ;
   PULS A             ;
   INCA               ;
   CMPA #$0          ; $F+1
   BNE PALETTE_SAME   ;
   *-----------------------------

    RTS
****************
start   lda   var_count_buffer
        inca
        sta   var_count_buffer

        lda   routine,u
        asla
        ldx   #Backgrnd_Routines
        jmp   [a,x]
Backgrnd_Routines
        fdb   Backgrnd_BackMain1
        fdb   Backgrnd_BackMain2

Backgrnd_BackMain1
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u

        ldx   #BackPal
        lda   cur_back
        asla
        ldy   a,x
        sty   Pal_current
*        clr   PalRefresh
        ldx   #BackImages
        ldy   a,x
        sty   image_set,u
        inc   routine,u
        jmp   DisplaySprite

Backgrnd_BackMain2
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u

        ldx   #BackPal
        lda   cur_back
        asla
        ldy   a,x
        sty   Pal_current
*        clr   PalRefresh
        ldx   #BackImages
        ldy   a,x
        sty   image_set,u
        dec   routine,u
        inc   cur_back
        lda   cur_back
        cmpa  #8
        bne   >
        clr   cur_back
!
        jsr   Backgrnd_Fade
        jmp   DisplaySprite

Backgrnd_Fade
        **** fade image
        jsr   LoadObject_x
        lda   #ObjID_PaletteFade
        sta   id,x
        ldd   #Pal_black            * palette source
        std   ext_variables,x
        ldd   Pal_current * #Pal_02         * palette destination
        std   ext_variables+2,x
        ****
        RTS

display_text
        lda var_flag_displayText
        cmpa #0
        BEQ >
        RTS
!           lda #1
            sta var_flag_displayText
            jsr   LoadObject_x
            lda   #ObjID_IntroTextes1
            sta   id,x
            RTS

BackPal
        fdb   Pal_01
        fdb   Pal_02
        fdb   Pal_03
        fdb   Pal_04
        fdb   Pal_05
        fdb   Pal_06
        fdb   Pal_07
        fdb   Pal_08
BackImages
        fdb   Img_back1
        fdb   Img_back2
        fdb   Img_back3
        fdb   Img_back4
        fdb   Img_back5
        fdb   Img_back6
        fdb   Img_back7
        fdb   Img_back8

cur_back  fcb 0
var_count fcb 0
var_count_buffer fcb 0
var_count16 fdb 0
