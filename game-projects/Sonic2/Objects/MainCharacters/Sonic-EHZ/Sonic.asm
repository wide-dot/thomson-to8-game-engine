; ---------------------------------------------------------------------------
; Object - Sonic
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"   

TestImageSet
        lda   routine,u
        asla
        ldx   #TitleScreen_Routines
        jmp   [a,x]

TitleScreen_Routines
        fdb   Init
        fdb   Move
Init
        ldd   #SonAni_Walk
        std   anim,u
        ldb   #$04
        stb   priority,u
        ldd   #128
        std   x_pos,u
        ldd   #576+100
        std   y_pos,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u  
        inc   routine,u
Move
TestLeft
        lda   Dpad_Held
        bita  #c1_button_left_mask
        beq   TestRight   
	ldd   glb_camera_x_pos
	subd  speed
	bpl   @l
	ldd   #0
@l	std   glb_camera_x_pos
	addd  #128
	std   x_pos,u
        bra   TestUp
TestRight        
	lda   Dpad_Held
        bita  #c1_button_right_mask
        beq   TestUp   
	ldd   glb_camera_x_pos
	addd  speed
	cmpd  #88*64-160
	bls   @r
	ldd   #88*64-160
@r	std   glb_camera_x_pos
	addd  #128
	std   x_pos,u
TestUp
	lda   Dpad_Held
        bita  #c1_button_up_mask
        beq   TestDown   
	ldd   glb_camera_y_pos
	subd  speed
	subd  speed
	bpl   @u
	ldd   #0
@u	std   glb_camera_y_pos
	addd  #128
	std   y_pos,u
        bra   TestBtn
TestDown
	lda   Dpad_Held
        bita  #c1_button_down_mask
        beq   TestBtn   
	ldd   glb_camera_y_pos
	addd  speed
	addd  speed
	cmpd  #8*128-192
	bls   @d
	ldd   #8*128-192
@d	std   glb_camera_y_pos
	addd  #128
	std   y_pos,u
TestBtn
        ldb   Fire_Press
        bitb  #c1_button_A_mask
        beq   Continue
	ldd   speed
	addd  #2
	cmpd  #16
	bne   @a
	ldd   #2
@a	std   speed
Continue
        jsr   AnimateSpriteSync   
        jmp   DisplaySprite

speed   fdb   10

