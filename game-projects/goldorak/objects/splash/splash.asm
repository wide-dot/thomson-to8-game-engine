
XY_CENTERED_FULL_IMAGE EQU $807F 
LAYER_BACKGROUND EQU #7

start   lda   routine,u
        asla
        ldx   #routines
        jmp   [a,x]
routines
        fdb   Init
        fdb   Display


Init
        ldb   LAYER_BACKGROUND                       ; ici je suis perdu 
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   XY_CENTERED_FULL_IMAGE
        std   xy_pixel,u
        inc   routine,u
Display
        ldd   #Img_Background    
        std   image_set,u
        jmp   DisplaySprite
