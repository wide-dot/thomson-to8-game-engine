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
        INCLUDE "./objects/animation/anim-data.equ"


AABB_0  equ ext_variables   ; AABB struct (9 bytes)
nb_bugs equ ext_variables+9
timer   equ ext_variables+10

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   InitMain
        fdb   LiveMain
        fdb   Init
        fdb   Live
        fdb   AlreadyDeleted

InitMain
        ldb   subtype_w,u              ; load nb of sprites in wave
        lslb
        lslb
        ldx   #Preset3034Index
        abx
        lda   3,x
        sta   nb_bugs,u
        ; todo load the missing parameter

        ldx   #anim_bug                ; load animation based on wave parameter
        ldb   subtype_w+1,u
        lsrb
        lsrb
        lsrb
        andb  #%00001110
        jsr   AnimateMoveSyncInit

        ldb   subtype_w+1,u            ; load x and y pos based on wave parameter
        andb  #$0F
        stb   @type
        aslb
        ldx   #PresetXYIndex
        abx
        clra
        ldb   1,x
        std   y_pos,u
        ldd   #0
@type   equ   *-2
        cmpa  #3
        blo   >
        cmpa  #9
        bhs   >
        ldb   #24                      ; see arcade rom (0x61EB) : ADD word ptr [SI + 0x4],0x40
!       clra
        addb  ,x
        addd  glb_camera_x_pos
        std   x_pos,u

        inc   routine,u

        lda   #2                       ; see arcade rom (0x61EF) : MOV word ptr [SI + 0x36],0x2
        suba  anim_frame_duration,u    ; contains late frames from wave
        sta   timer,u
        beq   >
        bmi   >
        rts

LiveMain
        lda   timer,u
        suba  gfxlock.frameDrop.count
        sta   timer,u
        beq   >
        bpl   @rts
!       sta   @late
        adda  #$10
        sta   timer,u
        dec   nb_bugs,u
        bmi   @delete
        jsr   LoadObject_x
        beq   @rts
        lda   id,u
        sta   id,x
        lda   #0
@late   equ   *-1
        nega
        sta   anim_frame_duration,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   #2                       ; set init routine for child bugs
        sta   routine,x
        ldb   #6
        stb   priority,x
        lda   #render_playfieldcoord_mask
        sta   render_flags,x
        ldd   anim,u
        std   anim,x
        ldd   sub_anim,u
        std   sub_anim,x
@rts    rts
@delete
        jmp   UnloadObject_u           ; not a sprite we need to use unloadObject

Init
        _Collision_AddAABB AABB_0,AABB_list_ennemy
        lda   #bug_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  bug_hitbox_x,bug_hitbox_y
        std   AABB_0+AABB.rx,u

        ; moves skipped frames before object creation
        ldb   anim_frame_duration,u
        jsr   AnimateMoveSteps

        inc   routine,u
        bra   >                        ; skip framerate compensation for init

Live
        jsr   AnimateMoveSync
!       ldx   sub_anim,u
        beq   @delete
        jsr   ObjectMove
;
        lda   AABB_0+AABB.p,u
        beq   @destroy
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u
;
        ldx   #ImageIndex
        ldb   anim_frame,u
        lslb
        ldd   b,x
        std   image_set,u
;
        jmp   DisplaySprite
@destroy 
        ldd   score
        addd  #bug_score
        std   score
        jsr   LoadObject_x
        beq   @delete
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
@delete
        lda   #4
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts
PresetXYIndex
        INCLUDE "./global/preset-xy.asm"
Preset3034Index
        INCLUDE "./objects/enemies/bug/preset-3034.asm"
