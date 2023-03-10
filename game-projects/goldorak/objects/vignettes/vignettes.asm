        INCLUDE "./global/global-object-preambule-includes.asm"

_WaitAndDisplaySprite MACRO
                ldd Vint_runcount ; B est à 0 : 256 / 50 Hz == toutes les 8 secondes environ
                lslb              ; toutes les 4 secondes
                lslb              ; toutes les 2 secondes        
                bne @display      ; si ce n'est pas à zéro on part afficher le sprite en cours
                inc   routine,u   ; sinon, on incrémente la routine pour afficher la prochaine image
@display        jmp   DisplaySprite
        ENDM
        
start           _object.routines.init #routines
routines
                fdb   Vignette_01
                fdb   Vignette_01        
                fdb   Bulle_01
                fdb   Bulle_01
                fdb   Vignette_02
                fdb   Vignette_02
                fdb   Bulle_02
                fdb   WaitPress
                fdb   Final


Vignette_01
                _image.set.u #Img_Vignette_01,#$5353,#1,#render_overlay_mask
                _WaitAndDisplaySprite
Bulle_01
                _image.set.u #Img_Bulle_01,#$9550,#1,#render_overlay_mask
                _WaitAndDisplaySprite
        
Vignette_02
                _image.set.u #Img_Vignette_02,#$A0A5,#1,#render_overlay_mask
                _WaitAndDisplaySprite

Bulle_02
                _image.set.u #Img_Bulle_02,#$6398,#1,#render_overlay_mask
                INC routine,U
WaitPress       ldb Fire_Press                
                bne @fade
                bra Final
@fade           _palette.fade #Palette_splash,#Pal_black,PALETTE_FADER,#$00,#DoChangeGameMode,#$FF
                INC routine,U

Final          jmp DisplaySprite

     
