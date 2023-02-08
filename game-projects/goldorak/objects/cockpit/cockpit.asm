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
        jsr   ReadJoypads
        ldb   Fire_Press
        bitb  #c1_button_A_mask
        beq   >
        _SetImage_U #Img_Background_02,#XY_CENTERED_FULL_IMAGE,#LAYER_BACKGROUND,#render_overlay_mask
        pshs U
        _NewManagedObject_U #ObjID_Vignettes
        puls U
        inc   routine,u
!       jmp   DisplaySprite

Display_02
        jmp   DisplaySprite
