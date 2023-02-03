    INCLUDE "./engine/macros.asm"

    lda   var_count16Tx
    cmpa  #1
    BLT   >
    RTS

!       ldd   var_count16Tx
        ADDD  #1
        std   var_count16Tx

        SETDP   dp/256
*        lda #$80
*        sta glb_screen_border_color+1

_DrawTextSetPos MACRO
        ; param 1 : col number (0-39)
        ; param 2 : line number
        ; param 3 : pixels between lines
        ldd   #$C000+\1+\2*(\3*40)
        ENDM

***** mappage ascii routines
    ldd   #Text_0A
    std   DrawText_0A
    ldd   #Text_0C
    std   DrawText_0C
    ldd   #Text_0D
    std   DrawText_0D
    lda   #12               *| defnition text interlettrage
    sta   line_height       *|
*****

        ldx   #fnt_4x6_shd_sel
            lda var_intro_slides_num    *| test for select text
            cmpa #0                     *|
            BEQ tx0                     *|
            cmpa #1                     *|
            BEQ tx1                     *|
            cmpa #2                     *|
            BEQ tx2                     *|
            cmpa #3                     *|
            BEQ tx3                     *|
            cmpa #4                     *|
            BEQ tx4                     *|
            cmpa #5                     *|
            BEQ tx5                     *|
            cmpa #6                     *|
            BEQ tx6                     *|
tx0     RTS                     * slide 0 no text
tx1         ldy   #Txt_001       * select text 1
            bra   txok
tx2         ldy   #Txt_002       * select text 2
            bra   txok
tx3         ldy   #Txt_003       * select text 3
            bra   txok
tx4         ldy   #Txt_004       * select text 4
            bra   txok
tx5         ldy   #Txt_005       * select text 5
            bra   txok
tx6         ldy   #Txt_006       * select text 6
            bra   txok
txok    _DrawTextSetPos 1,4,12
        *std   ff_pos       * nc
        std   line_start    * sauvegarde du line_start
        std   DrawText_pos
        jsr   DrawText
        rts

Txt_001 fcc   "STARDATE 10.10.2.7.24 STARSYSTEM IU2"
        fcb   $D,$A
        fcc   " "
        fcb   $D,$A
        fcc   "THE BARRAX EMPIRE - A RUTHLESS SPECIES"
        fcb   $D,$A
        fcc   "WITH ONE THING ON THEIR MIND - RULING"
        fcb   $D,$A
        fcc   "THE UNIVERSE. EARTH DEFENSE FLEET HAVE"
        fcb   $D,$A
        fcc   "BEEN IN WAR WITH THE BARRAX EMPIRE FOR"
        fcb   $D,$A
        fcc   "CENTURIES WITH MANY CASUALTIES ON BOTH"
        fcb   $D,$A
        fcc   "SIDES........"
        fcb   $D,$A,0

Txt_002 fcc   "COMMANDER BERRY D.MAYERS AND COMMANDER"
        fcb   $D,$A
        fcc   "LORI BERGIN RETURNING HOME FROM A WELL"
        fcb   $D,$A
        fcc   "ACCOMPLISHED MISSION. THEIR ORDERS"
        fcb   $D,$A
        fcc   "WERE TO ELIMINATE ALL BARRAX LIFEFORM"
        fcb   $D,$A
        fcc   "ON PLANET URAINIA AND GATHER AS MUCH"
        fcb   $D,$A
        fcc   "INFORMATION ABOUT THE BARRAX FIGHTERS."
        fcb   $D,$A,0

Txt_003 fcc   "AS THE COMMANDERS BEGIN THEIR TRIP HOME"
        fcb   $D,$A
        fcc   "THEY WARE SUDDENLY ATTACKED FROM OUT OF"
        fcb   $D,$A
        fcc   "NOWHERE BY A HUGE BARRAX NOVA CROISER."
        fcb   $D,$A,0

Txt_004 fcc   "THE LAST TRANSMISSION FROM COMMANDER"
        fcb   $D,$A
        fcc   "MAYERS AND BERGIN WAS THIS...."
        fcb   $D,$A
        fcc   "ABILITY TO BECOME INVISIBLE FOR A"
        fcb   $D,$A
        fcc   "LIMITED AMOUNT OF TIME. FAST.T..ACCE..."
        fcb   $D,$A
        fcc   "..BRIGG.HT.LIGHT.BEAMING.US.UN.BOARD..."
        fcb   $D,$A,0

Txt_005 fcc   "COMMANDER BERRY D. MAYERS AND COMMANDER"
        fcb   $D,$A
        fcc   "LORI BERGIN PRESUMED TO HAVE BEEN"
        fcb   $D,$A
        fcc   "TAKEN ASHUSTAGE BY THE HUGE BARRAX"
        fcb   $D,$A
        fcc   "NOVA CRUISER."
        fcb   $D,$A,0

Txt_006 fcc   "YOUR MISSION CODE C61-178DE IS TO"
        fcb   $D,$A
        fcc   "RESCUE COMMANDER BERRY D. MAYERS AND"
        fcb   $D,$A
        fcc   "COMMANDER LORI BERGIN AND THEIR"
        fcb   $D,$A
        fcc   "STARSHIP. THE E.F.D INTER-TRAX"
        fcb   $D,$A
        fcc   "SCANNER PICKED UP SIGNALS FROM A HUGE"
        fcb   $D,$A
        fcc   "OBJECT MOVING TOWARDS PLANET TERRAINIA."
        fcb   $D,$A
        fcc   " "
        fcb   $D,$A
        fcc   "ENGAGE AND TERMINATE COMMANDERS!"
        fcb   $D,$A
        fcc   " "
        fcb   $D,$A
        fcc   "      GOOD LUCK!"
        fcb   $D,$A,0

*ascii routines
**************
Text_0A
       lda   #0
line_height equ *-1
       ldb   #40
       mul
       addd  DrawText_pos
       std   DrawText_pos
       std   line_start
       rts
Text_0C
       ldd   #0
ff_pos  equ *-2
       std   DrawText_pos
       std   line_start
       rts
Text_0D
       ldd   #0
line_start equ *-2
       std   DrawText_pos
       rts

        INCLUDE "./engine/graphics/font/DrawText/DrawText.asm"
        INCLUDE "./engine/graphics/font/DrawText/3x5_shaded_selected/asm/font_upper.asm"
