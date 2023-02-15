        INCLUDE "./global/global-object-preambule-includes.asm"
        
start   _ObjectInitRoutines #routines
routines
        fdb   Init
        fdb   Display

Init
        _SetImage_U #Img_Floppy,#XY_CENTERED_FULL_IMAGE,#LAYER_BACKGROUND,#render_overlay_mask
        inc   routine,u
Display               
        jmp   DisplaySprite


