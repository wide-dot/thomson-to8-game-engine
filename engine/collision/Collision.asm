        INCLUDE "./engine/collision/struct_AABB.equ"

; use ./engine/collision/macros.asm
; --------------------------------------

Collision_AddAABB
        ldu   2,y
        beq   >
        stx   AABB.next,u
        stx   2,y
        stu   AABB.prev,x
        rts
!       stx   2,y
        stx   ,y
        rts

; --------------------------------------

Collision_RemoveAABB
        ldy   AABB.next,x 
        beq   @noNext
        ldu   AABB.prev,x
        stu   AABB.prev,y
        beq   @noPrev
        sty   AABB.next,u
        rts
@noPrev sty   0
Collision_Remove_1 equ *-2
        rts
@noNext ldu   AABB.prev,x
        beq   >
        sty   AABB.next,u
!       stu   0
Collision_Remove_2 equ *-2
        bne   @end
        stu   0
Collision_Remove_3 equ *-2
@end    rts

; --------------------------------------

Collision_Do
        ldu   #0                       ; all pairs testing
Collision_Do_1 equ *-2
        beq   @rts                     ; no AABB in the player AABB list, quit
@loopu  ldb   AABB.p,u
        beq   @skipu                   ; no more potential, skip this AABB
        ldx   #0
Collision_Do_2 equ *-2
        beq   @rts                     ; no AABB in the ai AABB list, quit
@loopx  ldb   AABB.p,x
        beq   @skipx                   ; no more potential, skip this AABB
;
        lda   AABB.rx,u                ; compute collision
        adda  AABB.rx,x
        asla
        sta   @rx
        asra
        adda  AABB.cx,u
        suba  AABB.cx,x
        cmpa  #0
@rx     equ *-1 
        bhi   @continue
        lda   AABB.ry,u
        adda  AABB.ry,x
        asla
        sta   @ry
        asra
        adda  AABB.cy,u
        suba  AABB.cy,x
        cmpa  #0
@ry     equ *-1 
        bhi   @continue
!
        ldb   #0                       ; compute collision damage
        lda   AABB.p,u
        bmi   @u_invincibility
        tst   AABB.p,x
        bmi   @x_invincibility
        suba  AABB.p,x
        beq   @draw
        bmi   @loose
@draw   stb   AABB.p,u
        stb   AABB.p,x
        bra   @continue
@win    sta   AABB.p,u
        stb   AABB.p,x
        bra   @continue
@loose  lda   AABB.p,x
        suba  AABB.p,u
        sta   AABB.p,x
        stb   AABB.p,u
@continue
@skipx  ldx   AABB.next,x
        bne   @loopx
@skipu  ldu   AABB.next,u
        bne   @loopu
@rts    rts
;
@u_invincibility
        lda   AABB.p,x
        bmi   @continue                ; two invincible hitboxes
        suba  AABB.p,u
        bcc   >
        lda   #0                       ; cap lowest value to 0
!       sta   AABB.p,x
        bra   @continue
;
@x_invincibility
        lda   AABB.p,u
        suba  AABB.p,x
        bcc   >
        lda   #0                       ; cap lowest value to 0
!       sta   AABB.p,u
        bra   @continue