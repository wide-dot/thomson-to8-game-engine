        INCLUDE "./global/global-object-preambule-includes.asm"

start   
        _object.routines.init #routines
routines
        fdb   Init
        fdb   Display

Init
        _image.set.u #Img_Cockpit,#XY_CENTERED_FULL_IMAGE,#1,#render_playfieldcoord_mask
        ldd #80
        std x_pos,U
        ldd #178
        std y_pos,U
        inc routine,u
Display      
        jmp DisplaySprite
