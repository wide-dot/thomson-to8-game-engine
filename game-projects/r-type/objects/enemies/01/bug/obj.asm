; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

bug_a       equ ext_variables    ; Current amplitude    * 
bug_d       equ ext_variables+1    ; Direction (1 = up, 0 = down)    * 
Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldd   #Ani_bug
        std   anim,u
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        ldd   x_pos,u
        subd  #1
        std   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        lda   bug_d,u
        beq   bug_down
        lda   bug_a,u
        cmpa  #$28
        beq   bug_switchuptodown
        inca
        sta   bug_a,u
        ldd   y_pos,u
        subd  #1
        std   y_pos,u
        jsr   AnimateSprite
        jmp   DisplaySprite
bug_switchuptodown
        clr   bug_d,u
        jsr   AnimateSprite
        jmp   DisplaySprite
bug_down
        lda   bug_a,u
        beq   bug_switchdowntoup
        deca
        sta   bug_a,u
        ldd   y_pos,u
        addd  #1
        std   y_pos,u
        jsr   AnimateSprite
        jmp   DisplaySprite
bug_switchdowntoup
        lda   #$01
        sta   bug_d,u
        jsr   AnimateSprite
        jmp   DisplaySprite
        
!       jmp   DeleteObject

S