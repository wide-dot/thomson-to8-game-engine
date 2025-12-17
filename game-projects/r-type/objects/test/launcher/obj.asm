; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #Img_launcher
        std   image_set,u
        ldd   #80
        std   x_pos,u
        ldd   #100
        std   y_pos,u

        ldb   #1
        stb   fireVelocityPreset,u
        ldx   #target
        stx   FoeFireTarget

        inc   routine,u

Live
        jsr    ApplyDirection

        lda   Fire_Press
        anda  #c1_button_B_mask
        beq   @end
        ldb   fireVelocityPreset,u        
        incb
        cmpb  #8
        bne   >
        ldb   #1
!       stb   fireVelocityPreset,u
@end
        lda   Fire_Press
        anda  #c1_button_A_mask
        beq   >
        lda   Obj_Index_Page+ObjID_createFoeFire
        sta   PSR_Page   
        ldd   Obj_Index_Address+2*ObjID_createFoeFire
        std   PSR_Address                  
        jmp   RunPgSubRoutine
!
        jsr   CheckRange
        jmp   DisplaySprite
        
ApplyDirection
        lda   Dpad_Held
TestLeft
        bita  #c1_button_left_mask
        beq   TestRight   
        ldx   x_pos+1,u
        leax  -$40,x
        stx   x_pos+1,u
        bra   TestUp
TestRight        
        bita  #c1_button_right_mask
        beq   TestUp   
        ldx   x_pos+1,u
        leax  $40,x
        stx   x_pos+1,u
TestUp
        bita  #c1_button_up_mask
        beq   TestDown   
        ldx   y_pos+1,u
        leax  -$80,x
        stx   y_pos+1,u
        bra   @rts
TestDown
        bita  #c1_button_down_mask
        beq   @rts   
        ldx   y_pos+1,u
        leax  $80,x
        stx   y_pos+1,u
@rts    rts

CheckRange
        ldd   x_pos,u
        cmpd  #159
        ble   >
        ldd   #159
        bra   @y
!       cmpd  #0
        bge   >
        ldd   #0
@y      std   x_pos,u
!       ldd   y_pos,u
        cmpd  #199
        ble   >
        ldd   #199
        bra   @end
!       cmpd  #0
        bge   >
        ldd   #0
@end    std   y_pos,u
!       rts
