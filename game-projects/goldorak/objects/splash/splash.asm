        INCLUDE "./global/global-object-preambule-includes.asm"
        
start   _object.routines.init #routines
routines
        fdb Init
        fdb WaitForJoystick
        fdb Display

Init
        _image.set.u #Img_Background_01,#XY_CENTERED_FULL_IMAGE,#LAYER_BACKGROUND,#render_overlay_mask
        _object.routines.next
WaitForJoystick
        _joysticks.test Fire_Press,#c1_button_A_mask
        beq Display
        _objectManager.new.x #ObjID_Vignettes
        _image.set.u #Img_Background_02,#XY_CENTERED_FULL_IMAGE,#LAYER_BACKGROUND,#render_overlay_mask              
        _object.routines.next
Display
        jmp DisplaySprite


