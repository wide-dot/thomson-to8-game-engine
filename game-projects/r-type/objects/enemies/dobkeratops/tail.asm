; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
tail.priority     equ ext_variables+9
tail.explodeDelay equ ext_variables+10
tail.xVelSign     equ ext_variables+11
tail.yVelSign     equ ext_variables+12

; temporary variables
tail.instances    equ dp_extreg

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   InstanciateTail ; reserved for parent object only
        fdb   Run             ; start routine for tails elements
        fdb   MoveOut

InstanciateTail
        ; init presets
        ldy   #data_143AC

        ; init number of tail elements
        ldb   #18+1           ; 18x tail elements + 1x tail end
        stb   <tail.instances

        pshs  u
InstanceLoop
        jsr   LoadObject_x
        bne   >
        jmp   InstanceEnd
!
        ; object id
        _ldd  ObjID_dobkeratops_tail,1
        sta   id,x
        stb   routine,x

        ; priority of each element
        ldb   #0
tail.curPriority equ *-1        
        stb   tail.priority,x
        inc   tail.curPriority

        ; display priority
        ldb   #4
        stb   priority,x

        ; init sprite position
        clra
        ldb   1,y
        std   y_pos,x
        ldb   ,y
        addd  glb_camera_x_pos
        std   x_pos,x

        ; init sprite image
        ldb   2,y
        ldu   #tail.images
        ldd   b,u
        std   image_set,x

        ; delay before explosion
        ldb   #20
curExplodeDelay equ *-1
        stb   tail.explodeDelay,x
        addb  #4                  ; replaced preset by code 
        stb   curExplodeDelay

        ; init animation script
        ldd   3,y
        std   anim,x   
        std   prev_anim,x

        ; set inital velocity
        ldd   #0
        std   x_vel,x
        std   y_vel,x
        std   tail.xVelSign,x ; and tail.yVelSign

        ; set initial delay
        ldb   #$20
        stb   anim_frame,x

        ; display settings
        lda   #render_playfieldcoord_mask
        sta   render_flags,x

        ; move to next preset
        leay   5,y
        dec    <tail.instances
        bne    InstanceLoop

InstanceEnd
        puls  u
        jmp   UnloadObject_u

Run
        ; apply velocity by script in sync with framerate
        ; -----------------------------------------------
        ldy   gfxlock.frameDrop.count_w ; take number of elapsed frame since last render and apply all moves
        beq   @end
@loop
        ldd   x_pos+1,u                ; x_pos must be followed by x_sub in memory
        addd  x_vel,u
        std   x_pos+1,u                ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
        adca  tail.xVelSign,u
        sta   x_pos,u                  ; update high byte of x_pos
;
        ldd   y_pos+1,u                ; y_pos must be followed by y_sub in memory
        addd  y_vel,u
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
        adca  tail.yVelSign,u
        sta   y_pos,u                  ; update high byte of y_pos
;
        dec   anim_frame,u
        bne   @continue
;
        ldb   #$10
        stb   anim_frame,u
        ldx   anim,u                   ; load next preset
        lda   ,x
        cmpa  #$80                     ; end marker
        bne   >
        ldx   prev_anim,u              ; reinit animation
        stx   anim,u
!
        ldd   ,x
        std   x_vel,u
        tfr   a,b
        sex                            ; velocity is positive or negative, take care of that
        sta   tail.xVelSign,u
        ldd   2,x
        std   y_vel,u
        tfr   a,b
        sex                            ; velocity is positive or negative, take care of that
        sta   tail.yVelSign,u
        leax  4,x
        stx   anim,u
@continue
        leay  -1,y
        bne   @loop
@end        
        jmp   DisplaySprite

MoveOut
        ldd   x_vel,u
        addd  #$-20
        std   x_vel,u
        jsr   ObjectMoveSync
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jmp   Run
!       jmp   DeleteObject

tail.images
        fdb   Img_dobkeratops_tail_0
        fdb   Img_dobkeratops_tail_1
        fdb   Img_dobkeratops_tail_2
        fdb   Img_dobkeratops_tail_end

        INCLUDE "./objects/enemies/dobkeratops/tail_animation.asm"
