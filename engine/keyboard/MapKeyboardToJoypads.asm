********************************************************************************
* Get Keyboard codes
*
********************************************************************************

MapKeyboardToJoypads
        ldb   Dpad_Press
        lda   Key_Press
        cmpa  #8
        bne   >
        orb   #c1_button_left_mask
        bra   @saveDpad
!       cmpa  #9
        bne   >
        orb   #c1_button_right_mask
        bra   @saveDpad
!       cmpa  #10
        bne   >
        orb   #c1_button_down_mask
        bra   @saveDpad
!       cmpa  #11
        bne   >
        orb   #c1_button_up_mask
        bra   @saveDpad
!       ldb   Fire_Press
        cmpa  #13
        bne   >
        orb   #c1_button_A_mask
        bra   @saveFire
!       cmpa  #32
        bne   >
        orb   #c1_button_B_mask
        bra   @saveFire
        rts
@saveDpad
        stb   Dpad_Press
        rts
@saveFire
        stb   Fire_Press
        rts