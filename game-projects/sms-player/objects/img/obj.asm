
SoundTest
        ldb   snd_tst_new_game
        cmpb  snd_tst_cur_game
        bne   >
        jmp   DisplaySprite
!
        stb   snd_tst_cur_game

        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #$807F
        std   xy_pixel,u

        lda   snd_tst_cur_game
        asla

        ldx   #BackPal
        ldx   a,x
        stx   Pal_current
        clr   PalRefresh

        ldx   #ImageList
        ldx   a,x
        stx   image_set,u
        jmp   DisplaySprite

BackPal
        fdb   Pal_OutRun
        fdb   Pal_SOR
        fdb   Pal_SORII
        fdb   Pal_WBIII
        fdb   Pal_WBMW

ImageList
        fdb   Img_OutRun
        fdb   Img_SOR
        fdb   Img_SORII
        fdb   Img_WBIII
        fdb   Img_WBMW