
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
        ldd   #$7F7F
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
        fdb   Pal_WBIII
        fdb   Pal_DD
        fdb   Pal_Ys

ImageList
        fdb   Img_OutRun
        fdb   Img_WBIII
        fdb   Img_DD
        fdb   Img_Ys