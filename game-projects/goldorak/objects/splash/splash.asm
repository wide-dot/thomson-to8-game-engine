        INCLUDE "./global/global-object-preambule-includes.asm"
        
start   _ObjectInitRoutines #routines
routines
        fdb   Init
        fdb   Display

Init
        ldb   #LAYER_BACKGROUND
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldd   #Img_Background    
        std   image_set,u
        ldd   #XY_CENTERED_FULL_IMAGE
        std   xy_pixel,u
        inc   routine,u
Display
        jmp   DisplaySprite
