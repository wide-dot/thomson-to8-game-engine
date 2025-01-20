; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

x_pos_origin  equ ext_variables
y_pos_origin  equ ext_variables+2
frame         equ ext_variables+4
y_vel_step    equ ext_variables+5
parent        equ ext_variables+7
missed_frames equ ext_variables+9
child_frame   equ ext_variables+10

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   InitMaster  ; 0
        fdb   RunMaster   ; 1
        fdb   RunCommon   ; 2
        fdb   InitSlave   ; 3
        fdb   RunSlave    ; 4

InitMaster
        ldd   x_pos,u
        std   x_pos_origin,u
        ldd   y_pos,u
        std   y_pos_origin,u
        ldb   #2
        stb   child_frame,u
InitCommon
        ldd   #$2040         ; counter variable x30 and x10 in original game
        std   anim_frame,u   ; using two different counters in anim_frame
        inc   routine,u
        ldb   #5
        stb   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #-$0180
        std   x_vel,u
        rts

RunMaster
        lda   gfxlock.frameDrop.count
@loop   dec   anim_frame+1,u
        ldb   anim_frame+1,u        
        andb  #3
        bne   >
        jsr   CreateSlave
!       jsr   SawMoveXLeft
        dec   anim_frame,u
        bne   >
        jsr   CheckPlayerOnePos
        jmp   RunMaster2
!       deca
        bne   @loop

!       jsr   UpdateFrame
        jmp   DisplaySprite

RunMaster2
@loop   jsr   SawMoveXLeft
        jsr   SawMoveY
        deca
        bne   @loop
        bra   <

CreateSlave
        pshs  d
        jsr   LoadObject_x
        beq   >
        _ldd  ObjID_dobkeratops_saw,3 ; InitSlave
        sta   id,x
        stb   routine,x
        ldd   x_pos_origin,u
        std   x_pos,x
        ldd   y_pos_origin,u
        std   y_pos,x
        lda   #$20
        sta   anim_frame,x
        stu   parent,x
        ldb   child_frame,u
        addb  #2
        ldb   child_frame,u
        stb   frame,x
        lda   ,s                       ; get remaining frame drops to process
        deca
        sta   missed_frames,x
!       puls  d,pc

SawMoveXLeft
        pshs  d
        ldd   x_vel,u
        addd  x_pos+1,u                ; x_pos must be followed by x_sub in memory
        std   x_pos+1,u                ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
        adca  #$FF                     ; parameter is modified by the result of sign extend
        sta   x_pos,u                  ; update high byte of x_pos
        puls  d,pc

SawMoveY
        pshs  d
        ldb   y_vel,u
        sex                            ; velocity is positive or negative, take care of that
        sta   @b
        ldd   y_pos+1,u                ; y_pos must be followed by y_sub in memory
        addd  y_vel,u
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
@b      equ   *-1
        sta   y_pos,u                  ; update high byte of y_pos
        ldd   y_vel,u
        addd  y_vel_step,u             ; special code here, build up x_vel
        std   y_vel,u
        puls  d,pc

CheckPlayerOnePos
        pshs  d
        ldd   #-12                    ; set a velocity value based on y position of player one
        ldx   <player1+y_pos          ; on arcade velocity is $20, but added one frame on 2
        cmpx  #102                    ; so after scale (*.75) and /2 (every frame, gives 12
        bls   @end   
        ldd   #0
        cmpx  #115
        bls   @end   
        ldd   #12
@end    std   y_vel_step,u
        inc   routine,u
        puls  d,pc

RunCommon
        jsr   SawMoveSync
        ldd   x_pos,u
        addd  #8
        cmpd  glb_camera_x_pos
        bhi   >
        jmp   DeleteObject
!       jsr   UpdateFrame
        jmp   DisplaySprite

InitSlave
        jmp   InitCommon

RunSlave
        lda   gfxlock.frameDrop.count
        adda  missed_frames,u
@loop   jsr   SawMoveXLeft
        jsr   SawMoveY
        dec   anim_frame,u
        bne   >
        jsr   GetParentVel
!       deca
        bne   @loop
        jsr   UpdateFrame
        clr   missed_frames,u
        jmp   DisplaySprite

GetParentVel
        pshs  d
        ldx   parent,u
        ldd   y_vel_step,x
        std   y_vel_step,u
        lda   #2 ; RunCommon
        sta   routine,u
        puls  d,pc

SawMoveSync
; apply XY velocity in sync with framerate
; ----------------------------------------
        ldx   gfxlock.frameDrop.count_w ; take number of elapsed frame since last render and multiply by velocity
        bne   @loop1
        ldx   #1
@loop1   
        ldb   x_vel,u
        sex                            ; velocity is positive or negative, take care of that
        sta   @a+1
        ldd   x_pos+1,u                ; x_pos must be followed by x_sub in memory
        addd  x_vel,u
        std   x_pos+1,u                ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
@a
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
        sta   x_pos,u                  ; update high byte of x_pos
;
        ldb   y_vel,u
        sex                            ; velocity is positive or negative, take care of that
        sta   @b+1
        ldd   y_pos+1,u                ; y_pos must be followed by y_sub in memory
        addd  y_vel,u
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
@b
        adca  #$00                     ; (dynamic) parameter is modified by the result of sign extend
        sta   y_pos,u                  ; update high byte of y_pos
        ldd   y_vel,u
        addd  y_vel_step,u             ; special code here, build up x_vel
        std   y_vel,u
        leax  -1,x
        bne   @loop1
        rts

UpdateFrame
        ldb   frame,u        ; original code use global counter
        addb  #2             ; to have a nice rotating effect
        andb  #6             ; here get continuous image transitions
        stb   frame,u
        ldx   #saw.images
        ldd   b,x
        std   image_set,u
        rts

saw.images
        fdb   Img_dobkeratops_saw_0
        fdb   Img_dobkeratops_saw_1
        fdb   Img_dobkeratops_saw_2
        fdb   Img_dobkeratops_saw_3
