; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/math/rnd.macro.asm"

; temporary variables
explosion.instances equ dp_extreg

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
        fdb   Run

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
        _ldd   ObjID_enemiesblastsmall,1
        sta   id,x
        stb   subtype,x
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
!       stb   anim_frame+1,u
        jmp   DisplaySprite

monster.getout.images
        fdb   Img_dobkeratops_monster_4
        fdb   Img_dobkeratops_monster_3
        fdb   Img_dobkeratops_monster_2
        fdb   Img_dobkeratops_monster_1

Run
        jmp   DisplaySprite
