        INCLUDE "./engine/macros.asm" 

Obj01
        lda   routine,u
        asla
        ldx   #Obj01_Index
        jmp   [a,x]

Obj01_Index
        fdb   Obj01_Init
        fdb   Obj01_Main

Obj01_Init
        ldd   #Img_ball
        std   image_set,u
        lda   #2
        sta   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #$80-12
        std   x_pos,u
        ldd   #$7F-20
        std   y_pos,u
        inc   routine,u

Obj01_Main
        ldd   x_pos,u
        bmi   >
        cmpd  #$80+80-12
        bgt   >
        ldd   y_pos,u
        bmi   >
        cmpd  #$7F+100-20
        bgt   >
        jsr   ObjectMove
        jmp   DisplaySprite
!       jmp   DeleteObject
