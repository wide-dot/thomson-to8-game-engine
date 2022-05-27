; ---------------------------------------------------------------------------
; Object - Sword
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"

* ---------------------------------------------------------------------------
* Subtypes
* ---------------------------------------------------------------------------
Sub_SwordMain           equ 0
Sub_SwordTile           equ 1

* ---------------------------------------------------------------------------
* Object Status Table offsets
* - two variables can share same space if used by two different subtypes
* - take care of words and bytes and space them accordingly
* ---------------------------------------------------------------------------

* subtype Sub_SwordMain
w_Sword_timer           equ ext_variables
b_Sword_nb_sub_tile     equ ext_variables+2
w_Sword_sub_init_ypos   equ ext_variables+3
b_Sword_flash_idx       equ ext_variables+5

Sword_Main
        lda   subtype,u
        asla
        ldx   #Sword_SubType
        jmp   [a,x]

Sword_SubType
        fdb   Sword
        fdb   Sword_Tile

Sword
        lda   routine,u
        asla
        ldx   #Sword_Routines
        jmp   [a,x]

Sword_Routines
        fdb   Sword_Init
        fdb   Sword_Wait
        fdb   Sword_Move
	fdb   Sword_Flash
        fdb   Sword_End	

Sword_Init
        * Wait n frames before launch
	inc   routine,u
        ldd   #464
        std   w_Sword_timer,u
        lda   #8
	sta   b_Sword_nb_sub_tile,u	
        ldd   #$00BD-screen_top
	std   w_Sword_sub_init_ypos,u
	lda   #0
	sta   b_Sword_flash_idx,u
	rts

Sword_Wait
        ldd   w_Sword_timer,u
	subd  #1
	std   w_Sword_timer,u
	beq   @a
	rts
	* Set camera position
@a      ldd   #$0000
        std   <glb_camera_x_pos
        ldd   #$00C6
        std   <glb_camera_y_pos	

        * Allocate and init all sub objects
        * Title overlay
	jsr   SingleObjLoad
        _ldd  ObjID_Sword,Sub_SwordTile     ; this set object id and subtype
	std   ,x
        ldd   #Img_Title_overlay
        std   image_set,x
        lda   render_flags,x
        ora   #render_overlay_mask
        sta   render_flags,x	
        ldd   #$857A
	std   xy_pixel,x	
	ldb   #1
        stb   priority,x

        * Sword tiles
@b	jsr   SingleObjLoad
        _ldd  ObjID_Sword,Sub_SwordTile     ; this set object id and subtype
	std   ,x
        lda   b_Sword_nb_sub_tile,u
	bne   @a
	inc   routine,u
	rts
@a      asla
        ldy   #Sword_Images
        ldy   a,y
        sty   image_set,x
        lda   render_flags,x
        ora   #render_playfieldcoord_mask        
        sta   render_flags,x   	
        ldd   #$005E-screen_left
	std   x_pos,x	
	ldd   w_Sword_sub_init_ypos,u
	subd  #16
        std   w_Sword_sub_init_ypos,u
        std   y_pos,x
	ldb   #2
        stb   priority,x
        dec   b_Sword_nb_sub_tile,u
	bra   @b

Sword_Move
        ldd   <glb_camera_y_pos	
	subd  #16
	std   <glb_camera_y_pos	
	bls   @a
        rts
@a      inc   routine,u
        ldd   #0
	std   <glb_camera_y_pos	

Sword_Flash
        * Set new color palette
	lda   b_Sword_flash_idx,u
	cmpa  #31
	bne   @a
        inc   routine,u
	ldd   #White_palette
	std   Cur_palette
        clr   Refresh_palette
	rts
@a	ldx   #Sword_Palettes
        anda  #$03
	asla
	ldd   a,x
        std   Cur_palette
        clr   Refresh_palette
	inc   b_Sword_flash_idx,u
	rts      

Sword_End
        rts

Sword_Tile
        jmp   DisplaySprite

Sword_Images
        fdb   0
	fdb   Img_Sword_1
	fdb   Img_Sword_2
	fdb   Img_Sword_3
	fdb   Img_Sword_4
	fdb   Img_Sword_4	
	fdb   Img_Sword_5
	fdb   Img_Sword_6
	fdb   Img_Sword_7	

Sword_Palettes
        fdb   Pal_Flash_R
        fdb   Pal_Flash_G
        fdb   Pal_Flash_B
        fdb   Pal_Flash