        INCLUDE "./global/global-object-preambule-includes.asm"
        
start   _ObjectInitRoutines #routines
routines
        fdb   Init
        fdb   Display_01
        fdb   Display_02

Init
        _SetImage_U #Img_Background_01,#XY_CENTERED_FULL_IMAGE,#LAYER_BACKGROUND,#render_overlay_mask
        inc   routine,u
Display_01
                ldb   Fire_Press
                bitb  #c1_button_A_mask
                beq   @display
                pshs U
                _NewManagedObject_U #ObjID_Vignettes
                puls U
                _SetImage_U #Img_Background_02,#XY_CENTERED_FULL_IMAGE,#LAYER_BACKGROUND,#render_overlay_mask              
                inc routine,u
@display  
Display_02
                jmp   DisplaySprite


