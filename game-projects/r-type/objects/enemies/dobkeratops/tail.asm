; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/enemies_properties.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
tail.priority     equ ext_variables+9
tail.explodeDelay equ ext_variables+10
tail.xVelSign     equ ext_variables+11
tail.yVelSign     equ ext_variables+12

rtnid.WaitEndStage equ 2

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
        fdb   WaitEndStage

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

        lda   <tail.instances
        anda  #1
        beq   >
        ; register hit box
        _Collision_AddAABB_x AABB_0,AABB_list_ennemy

        lda   #dobkeratops_tail_hitdamage
        sta   AABB_0+AABB.p,x
        _ldd  dobkeratops_tail_hitbox_x,dobkeratops_tail_hitbox_y
        std   AABB_0+AABB.rx,x
!

        ; move to next preset
        leay   5,y
        dec    <tail.instances
        bne    InstanceLoop

InstanceEnd
        puls  u
        jmp   UnloadObject_u

Run
        ldx   gfxlock.frame.count
        cmpx  #timestamp.MOVE_ALIEN_START
        blo   >
        ldd   x_pos,u
        subd  #2
        std   x_pos,u
        cmpx  #timestamp.MOVE_ALIEN_END
        blo   >
        lda   #rtnid.WaitEndStage
        sta   routine,u
!
WaitEndStage
        ; apply velocity by script in sync with framerate
        ; -----------------------------------------------
        ldy gfxlock.frameDrop.count_w ; ta@e number of elapsed frame since last render and apply all moves
        bne @setup
        ldy #1
@setup
        ldd x_vel,u
        bmi @setup1
        ldx y_vel,u
        bmi @setup01
@setup00
        stx @loopy00+1
        std @loopx00+1
@loopx00
        ldd #0
        addd x_pos+1,u
        std x_pos+1,u
        bcc @loopy00
        inc x_pos,u
@loopy00
         ldd #0
         addd y_pos+1,u
         std y_pos+1,u
         bcc >
         inc y_pos,u
!
         dec anim_frame,u
         beq @next
         leay -1,y
         bne @loopx00
         jmp @end
;
@setup01
        stx @loopy01+1
        std @loopx01+1
@loopx01
        ldd #0
        addd x_pos+1,u
        std x_pos+1,u
        bcc @loopy01
        inc x_pos,u
@loopy01
        ldd #0
        addd y_pos+1,u
        std y_pos+1,u
        bcs >
        dec y_pos,u
!
        dec anim_frame,u
        beq @next
        leay -1,y
        bne @loopx01
        jmp @end     
;
@setup1
        ldx y_vel,u
        bmi @setup11
@setup10
        stx @loopy10+1
        std @loopx10+1
@loopx10
        ldd #0
        addd x_pos+1,u
        std x_pos+1,u
        bcs @loopy10
        dec x_pos,u
@loopy10
        ldd #0
        addd y_pos+1,u
        std y_pos+1,u
        bcc >
        inc y_pos,u
!
        dec anim_frame,u
        beq @next
        leay -1,y
        bne @loopx10
        bra @end
;
@setup0
        stx y_vel,u
        bmi @setup01
        jmp @setup00
;
@next
        lda #$10
        sta anim_frame,u
        ldx anim,u
        ldd ,x
        cmpa #$80
        bne >
        ldx prev_anim,u
        ldd ,x
!
        leax 4,x
        stx anim,u
        ldx -2,x
        leay -1,y
        beq @end1
        std x_vel,u
        bpl @setup0
        stx y_vel,u
        bpl @setup10
;
@setup11
        stx @loopy11+1
        std @loopx11+1
@loopx11
        ldd #0
        addd x_pos+1,u
        std x_pos+1,u
        bcs @loopy11
        dec x_pos,u
@loopy11
        ldd #0
        addd y_pos+1,u
        std y_pos+1,u
        bcs >
        dec y_pos,u
!
        dec anim_frame,u
        beq @next
        leay -1,y
        bne @loopx11
        bra @end     
;
@end1
       std x_vel,u
       stx y_vel,u
@end
        ; update hitbox
        lda   AABB_0+AABB.p,u
        beq   >
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u
!
        jmp   DisplaySprite

DeleteTail
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject

tail.images
        fdb   Img_dobkeratops_tail_0
        fdb   Img_dobkeratops_tail_1
        fdb   Img_dobkeratops_tail_2
        fdb   Img_dobkeratops_tail_end

        INCLUDE "./objects/enemies/dobkeratops/tail_animation.asm"
