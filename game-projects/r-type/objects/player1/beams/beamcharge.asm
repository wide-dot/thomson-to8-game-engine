
; ---------------------------------------------------------------------------
; Object - Beam Charge
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./objects/player1/player1.equ"

Beamcharge
        lda   routine,u
        asla
        ldx   #Beamcharge_Routines
        jmp   [a,x]
Beamcharge_Routines
        fdb   Init
        fdb   Live
        fdb   AlreadyDeleted
Init
	ldd   #Ani_beamcharge
        std   anim,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
Live
	lda   player1+beam_value
	beq   >
	ldd   player1+x_pos
	addd  #13
	std   x_pos,u
	ldd   player1+y_pos
	std   y_pos,u
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
!
	inc   routine,u
	jmp   DeleteObject
AlreadyDeleted
        rts