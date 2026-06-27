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
        INCLUDE "./objects/explosion/explosion.const.asm"
        INCLUDE "./objects/enemies_properties.asm"

AABB_0  equ ext_variables   ; AABB struct (9 bytes)

rtnid.RunEyes   equ 2          ; nerve en combat (hitbox arme, vulnerable)
rtnid.DeleteEye equ 3
rtnid.MoveAlien equ 4
rtnid.DeleteAlien equ 5
rtnid.FreezeAlien equ 7        ; (6 = DeleteAlienEnd) clean double-buffer stop on boss death
rtnid.IntroEye  equ 9          ; nerve en phase intro: INVULNERABLE jusqu'a l'emergence du monstre

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Run
        fdb   RunEyes
        fdb   DeleteEye
        fdb   MoveAlien
        fdb   DeleteAlien
        fdb   DeleteAlienEnd
        fdb   FreezeAlien
        fdb   FreezeAlienStop
        fdb   IntroEye

Init
        ; init sprite position
        ldd   #1507
        std   x_pos,u
        ldd   #100
        std   y_pos,u

        ; reinit wave frame drop that share the same position as anim_frame_duration
        clr   anim_frame_duration,u

        ; display priority and setup image
        ldd   subtype,u
        stb   priority,u
        ldx   #SubImages
        asla
        ldx   a,x
        stx   image_set,u

        ; display settings
        lda   #render_playfieldcoord_mask|render_xloop_mask
        ldb   subtype,u
        cmpb  #4
        blo   @orbit
        cmpb  #8
        blo   @foregroundOrbitAndNerves
        ora   #render_overlay_mask ; alien background
        bra   >
@foregroundOrbitAndNerves
        ldx   #EyesObjects
        subb  #4
        aslb
        stu   b,x ; backup object pointer
        bra   >
!       sta   render_flags,u
@end    inc   routine,u
        jmp   DisplaySprite
@orbit
        ; four orbits (nerves) : phase INTRO invulnerable. Le hitbox n'est PAS arme ici
        ; (sinon l'eye est destructible des son apparition). IntroEye l'arme a
        ; gameCount == timestamp.NERV_VULNERABLE (spawn monstre + fenetre intro arcade $280).
        ldx   #EraserObjects
        aslb
        stu   b,x ; backup object pointer
        tstb
        bne   >
        ldb   #4               ; first orbit spawned: reset the nerve counter
        stb   eyesAlive        ; (arcade: parent +0x34 nerves-alive)
!       ora   #render_overlay_mask
        sta   render_flags,u
        lda   #rtnid.IntroEye
        sta   routine,u
        jmp   DisplaySprite

SubImages
        fdb   0 ; no image at startup for eraser 0
        fdb   0 ; no image at startup for eraser 1
        fdb   0 ; no image at startup for eraser 2
        fdb   0 ; no image at startup for eraser 3

        fdb   Img_dobkeratops_eye100
        fdb   Img_dobkeratops_eye300
        fdb   Img_dobkeratops_eye310
        fdb   Img_dobkeratops_eye320

        fdb   Img_dobkeratops_alienN0
        fdb   Img_dobkeratops_alienN1
        fdb   Img_dobkeratops_alienN2
        fdb   Img_dobkeratops_alienN3
        fdb   Img_dobkeratops_alienN4

AABBOffsets
        fdb   -32,-60
        fdb     1,-12
        fdb     1,24
        fdb   -32,64

Run
        ldb   subtype,u
        cmpb  #8
        beq   @alienN0
        bhi   @alienNx
        jmp   DisplaySprite
@alienNx
        ldx   gfxlock.frame.gameCount
        cmpx  #timestamp.DELETE_ALIEN_BODY
        blo   >
        jsr   DeleteObject
!       jmp   DisplaySprite
@alienN0
        lda   globals.bossDefeated
        bne   @frozen          ; boss killed: stop repainting, the overlay paint
        ldx   gfxlock.frame.gameCount ; persists and the tile-erase blits eat it
        cmpx  #timestamp.ERASE_NERV_START
        blo   @checkEyes
        bsr   Run.killEyes     ; nerve free-life timeout (arcade: nerve +0x3E expires)
@checkEyes
        lda   eyesAlive
        bne   >
        ; all nerves gone: alien moves out (arcade: background scroll resumes)
        lda   #rtnid.MoveAlien
        sta   routine,u
        ldd   #-$0018
        std   x_vel,u
!
        jmp   DisplaySprite
@frozen rts

Run.killEyes
        ; remove hitboxes of the surviving eyes, each kill is then
        ; processed by RunEyes (score, explosion, erase animation)
        ldx   EraserObjects
        beq   >
        clr   AABB_0+AABB.p,x
!       ldx   EraserObjects+2
        beq   >
        clr   AABB_0+AABB.p,x
!       ldx   EraserObjects+4
        beq   >
        clr   AABB_0+AABB.p,x
!       ldx   EraserObjects+6
        beq   >
        clr   AABB_0+AABB.p,x
!       rts

IntroEye
        ; nerve invulnerable jusqu'a timestamp.NERV_VULNERABLE. L'arcade arme la nerve
        ; $280 frames apres T0 (= spawn du boss, ou monstre et nerves sont simultanes dans
        ; create_dobkeratops). Le portage etale les spawns wave -> on ancre sur un gameCount
        ; absolu (spawn monstre + $280), pas sur le spawn de l'orbite (qui precede le monstre).
        ldx   gfxlock.frame.gameCount
        cmpx  #timestamp.NERV_VULNERABLE
        blo   @wait                    ; pas encore l'heure -> invulnerable
        _Collision_AddAABB AABB_0,AABB_list_ennemy
        lda   #dobkeratops_eye_hitdamage ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  dobkeratops_eye_hitbox_x,dobkeratops_eye_hitbox_y ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        ldx   #AABBOffsets
        ldb   subtype,u
        aslb
        aslb
        abx
        ldd   x_pos,u
        subd  glb_camera_x_pos
        addd  ,x
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        subd  glb_camera_y_pos
        addd  2,x
        stb   AABB_0+AABB.cy,u
        lda   #rtnid.RunEyes   ; nerve armee -> combat
        sta   routine,u
@wait   jmp   DisplaySprite

RunEyes
        lda   main.dobkeratops.halfDamage ; arcade: monster past half damage kills the nerves
        bne   @erase
        lda   globals.bossDefeated     ; arcade +0x32 children-explode: boss dead ->
        bne   @erase                   ;   erase any nerve still alive on a fast kill
        lda   AABB_0+AABB.p,u
        beq   @erase
        ldx   #AABBOffsets
        ldb   subtype,u
        aslb
        aslb        
        abx
        ldd   x_pos,u
        subd  glb_camera_x_pos
        addd  ,x
        stb   AABB_0+AABB.cx,u
        jmp   DisplaySprite
@erase
        ; unregister this orbit (its slot will be recycled)
        ; and update the nerve counter (arcade: parent +0x34)
        ldx   #EraserObjects
        ldb   subtype,u
        aslb
        ldy   #0
        sty   b,x
        dec   eyesAlive
        bne   >
        jsr   main.dobkeratops.allEyesDead ; all nerves dead: alien recedes
!
        ; globals.score update
        ldd   globals.score
        addd  #dobkeratops_eye_score
        std   globals.score
        ; delete eyes object
        ldb   subtype,u
        cmpb  #1
        bne   >
        ldx   EyesObjects
        lda   #rtnid.DeleteEye
        sta   routine,x
!       cmpb  #3
        bne   >
        ldx   EyesObjects+2
        lda   #rtnid.DeleteEye
        sta   routine,x
        ; create explosion
!       jsr   LoadObject_x
        beq   > ; branch if no more free object slot
        ; init explosion properties
        _ldd   ObjID_explosion,explosion.subtype.smallx2
        std   id,x
        ldy   #AABBOffsets
        ldb   subtype,u
        aslb
        aslb
        leay  b,y
        ldd   x_pos,u
        addd  ,y
        std   x_pos,x
        ldd   y_pos,u
        addd  2,y
        std   y_pos,x
!       lda   #rtnid.DeleteEye
        sta   routine,u
        inc   main.dobkeratops.nervesErasing ; this orbit nerve starts erasing (death lock)
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        ; create a new eraser object with one frame ahead for double buffering
        jsr   LoadObject_x
        beq   > ; branch if no more free object slot
        ldd   id,u ; id and subtype
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   priority,u
        sta   priority,x
        lda   render_flags,u
        sta   render_flags,x
        lda   routine,u
        sta   routine,x
        clr   anim_frame_duration,x
        clr   anim_frame,x                  ; play the copy from frame 0 so it reaches
                                            ;   @end and decrements (slot may be non-zero)
        inc   main.dobkeratops.nervesErasing ; its double-buffer copy erases too
!       rts
DeleteEye
        ldb   subtype,u
        ldx   #EraserImages
        aslb
        ldx   b,x         ; get animation list for this subtype
        lda   anim_frame,u
        asla
        ldd   a,x         ; get current frame
        cmpd  #-1
        beq   @end
        std   image_set,u ; update image
        inc   anim_frame,u
        jmp   DisplaySprite
@end
        ldb   subtype,u
        cmpb  #4
        bhs   @endCascade
        dec   main.dobkeratops.nervesErasing ; orbit nerve erase animation finished
@endCascade
        cmpb  #5
        bne   >
        ldx   EyesObjects+4
        lda   #rtnid.DeleteEye
        sta   routine,x
!       cmpb  #6
        bne   >
        ldx   EyesObjects+6
        lda   #rtnid.DeleteEye
        sta   routine,x
!       
        jmp   DeleteObject

MoveAlien
        lda   globals.bossDefeated
        bne   @frozen          ; boss killed: stop repainting, the overlay paint
        ldx   gfxlock.frame.gameCount ; persists and the tile-erase blits eat it
        cmpx  main.timestamp.moveAlienStart
        blo   >
        ldd   #Img_dobkeratops_alien
        std   image_set,u
        jsr   main.followDobkeratops
        ldd   main.dobkeratops.move.left      ; butee reached at the pixel? (frame-drop safe)
        bne   >
        lda   #rtnid.DeleteAlien
        sta   routine,u
!       jmp   DisplaySprite
@frozen
        ; the alien was moving, so the two video pages hold positions ~1px apart. Redraw at the
        ; frozen position on BOTH pages before stopping, else it flickers until the boss-erase
        ; covers it (clean double-buffer stop, same idea as DeleteAlien at the butee).
        lda   #rtnid.FreezeAlien
        sta   routine,u
        jmp   DisplaySprite                  ; page 1 at the frozen position

DeleteAlien
        inc   routine,u
        jmp   DisplaySprite ; print last frame at the same location for double buffering
DeleteAlienEnd
        jmp   DeleteObject
FreezeAlien
        inc   routine,u                      ; -> FreezeAlienStop
        jmp   DisplaySprite                  ; page 2 at the same position -> both pages reconciled
FreezeAlienStop
        rts                                  ; no more 1px flicker; frozen alien persists until erase

EraserImages
        fdb   EraserImages0
        fdb   EraserImages1
        fdb   EraserImages2
        fdb   EraserImages3
        fdb   ForegroundImages0
        fdb   ForegroundImages1
        fdb   ForegroundImages2
        fdb   ForegroundImages3

EraserImages0
        fdb   Img_dobkeratops_erase0_0
        fdb   Img_dobkeratops_erase0_1
        fdb   Img_dobkeratops_erase0_2
        fdb   Img_dobkeratops_erase0_3
        fdb   Img_dobkeratops_erase0_4
        fdb   Img_dobkeratops_erase0_5
        fdb   Img_dobkeratops_erase0_6
        fdb   Img_dobkeratops_erase0_7
        fdb   Img_dobkeratops_erase0_8
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   Img_dobkeratops_erase0_9
        fdb   Img_dobkeratops_erase0_10
        fdb   Img_dobkeratops_erase0_11
        fdb   Img_dobkeratops_erase0_12
        fdb   Img_dobkeratops_erase0_13
        fdb   Img_dobkeratops_erase0_14
        fdb   Img_dobkeratops_erase0_15
        fdb   -1 ; end of list
        
EraserImages1
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   Img_dobkeratops_erase1_2
        fdb   Img_dobkeratops_erase1_3
        fdb   Img_dobkeratops_erase1_4
        fdb   Img_dobkeratops_erase1_5
        fdb   Img_dobkeratops_erase1_6
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   Img_dobkeratops_erase1_10
        fdb   Img_dobkeratops_erase1_11
        fdb   -1 ; end of list

EraserImages2
        fdb   Img_dobkeratops_erase2_0
        fdb   Img_dobkeratops_erase2_1
        fdb   Img_dobkeratops_erase2_2
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   Img_dobkeratops_erase2_3
        fdb   Img_dobkeratops_erase2_4
        fdb   Img_dobkeratops_erase2_5
        fdb   Img_dobkeratops_erase2_6
        fdb   Img_dobkeratops_erase2_7
        fdb   Img_dobkeratops_erase2_8
        fdb   Img_dobkeratops_erase2_9
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   Img_dobkeratops_erase2_10
        fdb   Img_dobkeratops_erase2_11
        fdb   -1 ; end of list
        
EraserImages3
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame
        fdb   0 ; empty frame        
        fdb   Img_dobkeratops_erase3_0
        fdb   Img_dobkeratops_erase3_1
        fdb   Img_dobkeratops_erase3_2
        fdb   Img_dobkeratops_erase3_3
        fdb   Img_dobkeratops_erase3_4
        fdb   Img_dobkeratops_erase3_5
        fdb   Img_dobkeratops_erase3_6
        fdb   Img_dobkeratops_erase3_7
        fdb   Img_dobkeratops_erase3_8
        fdb   Img_dobkeratops_erase3_9
        fdb   -1 ; end of list

ForegroundImages0
        fdb   Img_dobkeratops_eye101
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye102
        fdb   Img_dobkeratops_eye103
        fdb   Img_dobkeratops_eye104
        fdb   -1 ; end of list

ForegroundImages1
        fdb   Img_dobkeratops_eye301
        fdb   -1 ; end of list

ForegroundImages2
        fdb   Img_dobkeratops_eye311
        fdb   Img_dobkeratops_eye312
        fdb   Img_dobkeratops_eye313
        fdb   -1 ; end of list

ForegroundImages3
        fdb   Img_dobkeratops_eye321
        fdb   Img_dobkeratops_eye322
        fdb   Img_dobkeratops_eye322
        fdb   Img_dobkeratops_eye322
        fdb   Img_dobkeratops_eye322
        fdb   Img_dobkeratops_eye322
        fdb   Img_dobkeratops_eye322
        fdb   -1 ; end of list

EraserObjects
        fdb   0 ; 0
        fdb   0 ; 1
        fdb   0 ; 2
        fdb   0 ; 3

EyesObjects
        fdb   0 ; 10
        fdb   0 ; 30
        fdb   0 ; 31
        fdb   0 ; 32

eyesAlive
        fcb   0 ; number of nerves still alive (arcade: parent +0x34)