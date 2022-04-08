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
        ldd   #576
        std   y_pos,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u  
        inc   routine,u
Move
        lda   Dpad_Held
        ldb   Fire_Press
TestLeft
        bita  #c1_button_left_mask
        beq   TestRight   
        ldd   x_pos,u
	subd  speed
	std   x_pos,u
	ldd   <glb_camera_x_pos
	subd  speed
	std   <glb_camera_x_pos
        bra   TestUp
TestRight        
        bita  #c1_button_right_mask
        beq   TestUp   
        ldd   x_pos,u
	addd  speed
	std   x_pos,u
	ldd   <glb_camera_x_pos
	addd  speed
	std   <glb_camera_x_pos
TestUp
        bita  #c1_button_up_mask
        beq   TestDown   
        ldd   y_pos,u
	subd  speed
	std   y_pos,u
	ldd   <glb_camera_y_pos
	subd  speed
	std   <glb_camera_y_pos
        bra   TestBtn
TestDown
        bita  #c1_button_down_mask
        beq   TestBtn   
	ldd   y_pos,u
	addd  speed
	std   y_pos,u
	ldd   <glb_camera_y_pos
	addd  speed
	std   <glb_camera_y_pos
TestBtn
        bitb  #c1_button_A_mask
        beq   Continue
	ldd   speed
	addd  #2
	cmpd  #10
	bne   Comtinue
	ldd   #0
	std   speed
Continue
        jsr   AnimateSprite   
        jmp   DisplaySprite

speed   fdb   2
