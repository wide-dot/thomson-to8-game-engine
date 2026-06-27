; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/math/rnd.macro.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/enemies_properties.asm"

; temporary variables
AABB_0              equ ext_variables   ; AABB struct (9 bytes)
explosion.instances equ dp_extreg+9

rtnid.WaitEndStage equ 5
rtnid.WaitExplode  equ 7
nerveLock.WAIT     equ 24                ; safety cap (~= nerve erase length): bounds the
                                         ;   freeze if nervesErasing ever fails to reach 0

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Intro
        fdb   WaitExplosions
        fdb   MonsterOut
        fdb   MonsterMouth
        fdb   WaitEndStage
        fdb   AlreadyDeleted
        fdb   WaitExplode

Init
        ; init sprite position
        ldd   #1516
        std   x_pos,u
        ldd   #106
        std   y_pos,u

        ; display priority
        ldb   #7
        stb   priority,u

        ; display settings
        lda   #render_playfieldcoord_mask|render_overlay_mask
        sta   render_flags,u

        ; init animation
        ldd   #360                      ; manual adjustment by video (instead of $200)
        std   anim_frame,u

        ; init image
        ldx   #0
        stx   image_set,u

        lda   #nerveLock.WAIT           ; death freeze: safety-cap countdown
        sta   nerveLock.wait
        clr   hitFlash.active            ; boss hit flash state
        clr   hitFlash.prevP

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        lda   #dobkeratops_monster_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  dobkeratops_monster_hitbox_x,dobkeratops_monster_hitbox_y
        std   AABB_0+AABB.rx,u

        inc   routine,u

Intro
        ldd   anim_frame,u
        subd  gfxlock.frameDrop.count_w
        std   anim_frame,u
        cmpd  #$60
        bls   >
        rts
!  
        ; create explosions
        lda   #4
        sta   <explosion.instances
@loop
        jsr   LoadObject_x
        bne   >
        jmp   InstanceEnd
!
        _ldd  ObjID_explosion,explosion.subtype.smallx3
        std   id,x
        _rnda 0,12
        suba  #6
        ldy   x_pos,u
        leay  a,y
        sty   x_pos,x
        jsr   RandomNumber
        _rnda 0,24
        suba  #12
        ldy   y_pos,u
        leay  a,y
        sty   y_pos,x
        dec   <explosion.instances
        bne   @loop
InstanceEnd
        inc   routine,u
        rts

WaitExplosions
        ldb   anim_frame+1,u
        subb  gfxlock.frameDrop.count
        bhi   >
        addb  #$1f
        inc   routine,u
!       stb   anim_frame+1,u
        rts

MonsterOut
        ldb   anim_frame+1,u
        asrb
        asrb
        andb  #%00000110
        ldx   #monster.getout.images
        ldd   b,x
        std   image_set,u
        ldb   anim_frame+1,u
        subb  gfxlock.frameDrop.count
        bhi   >
        inc   routine,u
        ldb   #$c0
!       stb   anim_frame+1,u
        jmp   DisplaySprite

monster.getout.images
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_3
        fdb   Img_dobkeratops_monster_2
        fdb   Img_dobkeratops_monster_1

MonsterMouth
        ldx   gfxlock.frame.gameCount
        cmpx  main.timestamp.moveAlienStart
        blo   >
        jsr   main.followDobkeratops
        ldd   main.dobkeratops.move.left      ; butee reached at the pixel? (frame-drop safe)
        bne   >
 IFDEF invincible
        jmp   MonsterKill                     ; invincible test mode: the boss explodes on the butee
 ELSE
        clr   player1+ext_variables+AABB.p    ; normal play: the boss reaching the butee kills P1
        lda   #rtnid.WaitEndStage             ; (boss stays frozen on the butee, firing saws)
        sta   routine,u
 ENDC
!
WaitEndStage
        lda   gfxlock.frameDrop.count
        ldb   anim_frame+1,u
@loop   decb
        andb  #$7f ; 111 1111
        stb   anim_frame+1,u
        cmpb  #$30 ; 011 0000
        bne   >
        jsr   CreateSawChain
!       deca
        bne   @loop
        andb  #$70 ; 111 0000
        lsrb
        lsrb
        lsrb
        ldx   #monster.fire.images
        ldd   b,x
        std   image_set,u
        jsr   UpdateHitBox
        jmp   DisplaySprite

CreateSawChain
        pshs  d
        jsr   LoadObject_x
        beq   >
        _ldd  ObjID_dobkeratops_saw,0
        sta   id,x
        stb   routine,x
        ldd   x_pos,u
        subd  #6
        std   x_pos,x
        ldd   y_pos,u
        addd  #9
        std   y_pos,x
!       puls  d,pc

monster.fire.images
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_5
        fdb   Img_dobkeratops_monster_6
        fdb   Img_dobkeratops_monster_5
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_4

UpdateHitBox
        ; boss hit flash. The palette change must be QUEUED (modify the working
        ; palette buffer + clear PalRefresh); the IRQ PalUpdateNow applies it at
        ; the next VBL. A direct $E7DA poke here tears (mid-frame). In game
        ; Pal_current = Pal_buffer (set by the fade object), so we edit Pal_buffer.
        ; undo last frame's white on index 12
        lda   hitFlash.active
        beq   @noUnflash
        clr   hitFlash.active
        ldd   Pal_game+24                  ; index 12 normal colour
        std   Pal_buffer+24
        clr   PalRefresh                   ; queue -> IRQ PalUpdateNow at next VBL
@noUnflash
        lda   AABB_0+AABB.p,u
        beq   MonsterKill
        ; hit this frame? the boss damage potential dropped since last frame
        cmpa  hitFlash.prevP
        bhs   @noHit
        ldd   #$ff0f                        ; flash index 12 white (max), queued
        std   Pal_buffer+24
        clr   PalRefresh
        lda   #1
        sta   hitFlash.active
        ldb   #1
        jsr   gfxlock.screenBorder.update
@noHit  lda   AABB_0+AABB.p,u
        sta   hitFlash.prevP
        cmpa  #dobkeratops_monster_hitdamage/2
        bhs   >
        sta   main.dobkeratops.halfDamage ; arcade: past half damage the nerves self-destruct
!       ; update the hitbox screen position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u
        rts

MonsterKill
        ; boss death: reached 0 HP (UpdateHitBox) OR arrived on the left butee
        ; (MonsterMouth). Freeze the whole boss now (bossDefeated -> body @frozen,
        ; jaw/tail hold).
        lda   #1
        sta   globals.bossDefeated
        ; alien already moving out (past moveAlienStart)? the optic nerves were
        ; destroyed/erased long ago (>=140 frames) -> explode THIS frame, no wait.
        ; (reliable, independent of the nervesErasing counter)
        ldx   gfxlock.frame.gameCount
        cmpx  main.timestamp.moveAlienStart
        bhs   @explodeNow
        ; otherwise the nerves may still be on screen: wait unless none is erasing
        lda   main.dobkeratops.halfDamage
        beq   @forceErase                    ; instant kill (half not reached): force + wait
        lda   main.dobkeratops.nervesErasing
        bne   @wait                          ; nerves still erasing -> wait for them
@explodeNow
        lda   #1
        sta   main.dobkeratops.explode       ; explode now
        jmp   Delete
@forceErase
        lda   #1
        sta   main.dobkeratops.halfDamage    ; trigger surviving nerves, then wait
@wait
        lda   #rtnid.WaitExplode
        sta   routine,u
        rts

* boss is frozen: wait for the optic-nerve erase to finish, then release the
* explosions (jaw + tail + boss) and the boss tile-erase via the explode flag.
WaitExplode
        lda   main.dobkeratops.nervesErasing
        beq   >                             ; nerve erase finished -> release
        lda   nerveLock.wait
        beq   >                             ; safety cap reached -> release anyway
        dec   nerveLock.wait
        jmp   DisplaySprite                 ; still erasing -> hold, keep monster shown
!       lda   #1
        sta   main.dobkeratops.explode       ; release jaw/tail/boss explosions + tile-erase

Delete
        ldb   #dobkeratops_monster_scoreIdx
        jsr   AwardScore
        jsr   LoadObject_x
        beq   @delete
        _ldd   ObjID_explosion,explosion.subtype.smallx3
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jsr   LoadObject_x
        beq   >
        lda   #ObjID_dobkeratops_explosion
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
!
        lda   #6
        sta   routine,u
        jmp   DeleteObject

AlreadyDeleted
        rts

nerveLock.wait
        fcb   0 ; death-freeze safety-cap countdown (frames), set at Init

hitFlash.active
        fcb   0 ; 1 = palette index 12 is white this frame (restore next frame)
hitFlash.prevP
        fcb   0 ; boss damage potential last frame (hit = it dropped)
