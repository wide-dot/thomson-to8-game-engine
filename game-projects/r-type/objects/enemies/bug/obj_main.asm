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
        INCLUDE "./objects/animation/index.equ"
        INCLUDE "./global/projectile.macro.asm"

AABB_0        equ ext_variables   ; AABB struct (9 bytes)
nb_bugs       equ ext_variables+9
preset        equ ext_variables+10
presetOffset  equ ext_variables+11
timer         equ ext_variables+12

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   InitCreator
        fdb   LiveCreator
        fdb   Init
        fdb   Live
        fdb   AlreadyDeleted

InitCreator
        ldb   subtype,u                ; load nb of sprites in wave
        andb  #3
        lslb
        ldx   #Preset19250
        ldd   b,x
        sta   presetOffset,u
        stb   nb_bugs,u

        ldx   #anim_192EC              ; load animation based on wave parameter
        ldb   subtype+1,u
        lsrb
        lsrb
        lsrb
        andb  #%00001110
        abx
        jsr   moveByScript.initialize

        ldb   subtype+1,u              ; load x and y pos based on wave parameter
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

LiveCreator
        lda   timer,u
        suba  gfxlock.frameDrop.count
        sta   timer,u
        beq   >
        bpl   @rts
!       sta   @late
        adda  #$10
        sta   timer,u
        ldd   x_pos,u
        subd  glb_camera_x_pos
        subd  #8+6                     ; 0x6204 CMP word ptr [BP + 0x4],0x150 ; left screen limit, will destroy bug creator if crossed (at x=336-320=16)
        bmi   @delete                  ; branch if out of screen's left
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
        ldd   anim,u
        std   anim,x
        ldd   sub_anim,u
        std   sub_anim,x
        ldb   presetOffset,u
        addb  preset,u
        ldy   #Preset19260
        ldb   b,y
        _loadFirePresetBug
        ldb   preset,u
        incb
        cmpb  #5
        bne   >
        ldb   #0
!       stb   preset,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,x
        dec   nb_bugs,u
        beq   @delete
@rts    rts
@delete
        jmp   UnloadObject_u           ; not a sprite we need to use unloadObject

Init
        ; register hit box
        _Collision_AddAABB AABB_0,AABB_list_ennemy

        lda   #bug_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  bug_hitbox_x,bug_hitbox_y
        std   AABB_0+AABB.rx,u

        ; moves skipped frames before object creation
        ldd   #endCheck
        std   moveByScript.callback
        ldb   anim_frame_duration,u ; b is a parameter to runByB, don't throw it before the call
        lda   #2
        sta   anim_frame_duration,u ; now use as animation speed by moveByScript
        jsr   moveByScript.runByB

        inc   routine,u
        bra   >                        ; skip framerate compensation for init

Live
        ldd   #endCheck
        std   moveByScript.callback
        jsr   moveByScript.runByFrameDrop
!       lda   moveByScript.anim.end
        bne   @delete
;
        jsr   tryFoeFire
;
        lda   AABB_0+AABB.p,u
        beq   @destroy
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
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

endCheck
        lda   moveByScript.anim.end
        beq   >
        clr   moveByScript.anim.loops  ; exit parent loop
!       rts

PresetXYIndex
        INCLUDE "./global/preset/18dd0_preset-xy.asm"
Preset19250
        INCLUDE "./global/preset/19250_preset-bug.asm"
Preset19260
        INCLUDE "./global/preset/19260_preset-bug.asm"
