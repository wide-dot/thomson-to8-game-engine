        INCLUDE "./global/global-object-preambule-includes.asm"
        
start   _object.routines.init #routines
routines
        fdb   Init
        fdb   Display

Init
        _image.set.u #Img_Floppy,#XY_CENTERED_FULL_IMAGE,#LAYER_BACKGROUND,#render_overlay_mask
        inc   routine,u
Display               
        jmp   DisplaySprite


