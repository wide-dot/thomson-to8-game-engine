; ---------------------------------------------------------------------------
; Object - Bubble
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm" 

Init_routine       equ 0
Ground_routine     equ 1
Jump_routine       equ 2
Fall_routine       equ 3
FallSlowly_routine equ 4

Bubble
        lda   routine,u
        asla
        ldx   #Bubble_Routines
        jmp   [a,x]

Bubble_Routines
        fdb   Init      
        fdb   Live
        fdb   End

Init
        ldb   #$04
        stb   priority,u

        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u

        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u

        ldd   #127
        std   x_pos,u
        ldd   #127
        std   y_pos,u

        ldd   #Img_Bubble_001
        std   image_set,u

        jmp   DisplaySprite

Live
        rts

End
        rts