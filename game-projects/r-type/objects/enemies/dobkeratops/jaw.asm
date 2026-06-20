; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"

rtnid.WaitEndStage equ 3
rtnid.AlreadyDeleted equ 4

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Wait
        fdb   Run
        fdb   WaitEndStage
        fdb   AlreadyDeleted

Init
        ; init sprite position
        ldd   #1497
        std   x_pos,u
        ldd   #77
        std   y_pos,u

        ; display priority
        ldb   #7
        stb   priority,u

        ; display settings
        lda   #render_playfieldcoord_mask|render_xloop_mask
        sta   render_flags,u

        ; init animation
        ldd   #0
        std   anim_frame,u

        ; init image
        ldx   #Img_dobkeratops_jaw_0
        stx   image_set,u

        inc   routine,u

Wait
        ldd   anim_frame,u
        addd  gfxlock.frameDrop.count_w
        cmpd  #360                      ; manual adjustment by video
        blo   >
        inc   routine,u
        ldd   #0
!       
        std   anim_frame,u
        jmp   DisplaySprite

Run
        lda   globals.bossDefeated
        bne   @toEnd                       ; boss dead: stop following, go to hold/explode
        ldx   gfxlock.frame.count
        cmpx  main.timestamp.moveAlienStart
        blo   >
        jsr   main.followDobkeratops
        cmpx  main.timestamp.moveAlienEnd
        blo   >
@toEnd  lda   #rtnid.WaitEndStage
        sta   routine,u
!
WaitEndStage
        jmp   Animate

Animate
        lda   globals.bossDefeated
        beq   @anim                        ; boss alive: normal jaw animation
        lda   main.dobkeratops.explode      ; boss dead: held frozen until released
        bne   Explode
        jmp   DisplaySprite                ; frozen in place, explosion pending
@anim
        ldd   anim_frame,u
        addd  gfxlock.frameDrop.count_w
        cmpd  #$180                     ; up to x180 (384)
        blo   >                         ; branch if not reached
        subd  #$180                     ; or reset counter to 0
!
        std   anim_frame,u       
        ldx   #Img_dobkeratops_jaw_0    ; image : jaw wide open
        cmpd  #$c0                      ; compare to 192
        blo   >                         ; branch if inferior
        ldx   #Img_dobkeratops_jaw_1    ; image : jaw mid open
        cmpd  #$d0                      ; compare 208
        blo   >                         ; branch if inferior
        cmpd  #$170                     ; compare to 368
        bhs   >                         ; branch if superior or equal
        ldx   #Img_dobkeratops_jaw_2    ; image : jaw low open
!
        stx   image_set,u
        jmp   DisplaySprite

Explode
        jsr   LoadObject_x
        beq   >
        _ldd   ObjID_explosion,explosion.subtype.smallx2
        std   id,x ; and subtype
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
!
        lda   #rtnid.AlreadyDeleted
        sta   routine,u
        jmp   DeleteObject

AlreadyDeleted
        rts     