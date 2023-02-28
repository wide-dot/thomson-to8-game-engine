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
; compute collision damage
        lda   AABB.p,u
        bmi   @u_invincibility
        ldb   AABB.p,x
        bmi   @x_invincibility
        clrb 
        suba  AABB.p,x
        bmi   @loose
@win    sta   AABB.p,u                 ; win or draw
        stb   AABB.p,x
        bra   @continue
@loose  nega                           ; loose
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
!       clr   AABB.p,x                 ; cap lowest value to 0
        bra   @continue
;
@x_invincibility
        lda   AABB.p,u
        suba  AABB.p,x
        bcc   >
!       clr   AABB.p,u                 ; cap lowest value to 0
        bra   @continue