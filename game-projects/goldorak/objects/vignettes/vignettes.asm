        INCLUDE "./global/global-object-preambule-includes.asm"

_WaitAndDisplaySprite MACRO
                ldd Vint_runcount ; B est à 0 : 256 / 50 Hz == toutes les 8 secondes environ
                lslb              ; toutes les 4 secondes
                lslb              ; toutes les 2 secondes        
                bne @display      ; si ce n'est pas à zéro on part afficher le sprite en cours
                inc   routine,u   ; sinon, on incrémente la routine pour afficher la prochaine image
@display        jmp   DisplaySprite
        ENDM
        
start           _ObjectInitRoutines #routines
routines
                fdb   Vignette_01
                fdb   Vignette_01        
                fdb   Bulle_01
                fdb   Bulle_01
                fdb   Vignette_02
                fdb   Vignette_02
                fdb   Bulle_02
                fdb   Final


Vignette_01
                _SetImage_U #Img_Vignette_01,#$5353,#1,#render_overlay_mask
                _WaitAndDisplaySprite
Bulle_01
                _SetImage_U #Img_Bulle_01,#$9550,#1,#render_overlay_mask
                _WaitAndDisplaySprite
        
Vignette_02
                _SetImage_U #Img_Vignette_02,#$A0A5,#1,#render_overlay_mask
                _WaitAndDisplaySprite

Bulle_02
                _SetImage_U #Img_Bulle_02,#$6398,#1,#render_overlay_mask
                INC routine,U
Final           ldb Fire_Press                
                bne >
                bra @end
!               lda #$FF
                sta ChangeGameMode
@end            jmp DisplaySprite
