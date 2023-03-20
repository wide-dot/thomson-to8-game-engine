
Menu
        lda   routine,u
        asla
        ldx   #Menu_Routines
        jmp   [a,x]

Menu_Routines
        fdb   Menu_Init1
        fdb   Menu_Init2
        fdb   Menu_Init3
        fdb   Menu_Chip
        fdb   Menu_Port

Menu_Init1
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u
        ldx   #Img_Back
        stx   image_set,u
        inc   routine,u
        jmp   DisplaySprite

Menu_Init2
        inc   routine,u
        jmp   DisplaySprite

Menu_Init3
        ldd   #Pal_Menu
        std   Pal_current
        clr   PalRefresh
        inc   routine,u
        jmp   DisplaySprite

Menu_Chip
        lda   Dpad_Press
        ldb   menu_sel_chip
        bita  #c_button_up_mask|c_button_down_mask
        beq   >
        comb
        stb   menu_sel_chip
!       lda   Fire_Press
        bita  #c_button_A_mask|c_button_B_mask
        beq   @continue
        tstb
        bne   @loadym
        inc   routine,u
        jmp   DisplaySprite
@loadym
        ldb   #GmID_ymplayer
        stb   GameMode
        jmp   DoChangeGameMode
@continue
        negb
        aslb
        ldx   #MenuPal
        ldx   b,x
        stx   Pal_current
        clr   PalRefresh
        jmp   DisplaySprite

Menu_Port
        lda   Dpad_Press
        ldb   menu_sel_port
        bita  #c_button_left_mask
        beq   >
        decb
        bpl   >
        ldb   #3
!       bita  #c_button_right_mask
        beq   >
        incb
        cmpb  #4
        blo   >
        ldb   #0
!       stb   menu_sel_port
        lda   Fire_Press
        bita  #c_button_A_mask|c_button_B_mask
        beq   >
        ldb   #GmID_snplayer
        stb   GameMode
        jmp   DoChangeGameMode
!       ldx   #Img_SNPort
        stx   image_set,u
        aslb
        ldx   #MenuPal
        ldx   b,x
        stx   Pal_current
        clr   PalRefresh
        jmp   DisplaySprite

MenuPal
        fdb   Pal_Opt1
        fdb   Pal_Opt2
        fdb   Pal_Opt3
        fdb   Pal_Opt4

