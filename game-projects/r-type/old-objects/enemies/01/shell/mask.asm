; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

parent         equ  ext_variables
old_pos_0      equ  ext_variables+2
old_pos_1      equ  ext_variables+4

Object
        ldx   parent,u
        beq   @rts
        ldd   #Img_shell_mask
        std   image_set,u
        lda   #1                                 ; frame 0 we want to draw tiles
        sta   <glb_force_sprite_refresh          ; force sprites to do a full refresh (background will be changed)
        tst   glb_Cur_Wrk_Screen_Id
        beq   >                                  ; process the previous frame position, so test is inverted
        ldd   xy_pixel,x
        std   old_pos_0,u
        ldd   old_pos_1,u
        std   xy_pixel,u
        jmp   DisplaySprite
!       ldd   xy_pixel,x
        std   old_pos_1,u
        ldd   old_pos_0,u
        std   xy_pixel,u
        jmp   DisplaySprite
@rts    rts