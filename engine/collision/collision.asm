        INCLUDE "./engine/collision/struct_AABB.equ"

; use ./engine/collision/macros.asm
; ------------------------------------------------------------------------------

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

; ------------------------------------------------------------------------------

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

; ------------------------------------------------------------------------------
; hitbox types is based on potential :
;
; -128 to -1 : invincible hitbox, potential is never changed
; 0          : disabled hitbox
; 1 to 126   : hitbox with remaining potential, when collide potential decrease (min 0)
; 127        : weak hitbox, when collide hitbox is directly disabled and do no harm to other hitbox
; ------------------------------------------------------------------------------

Collision_Do
        ldu   #0                       ; all pairs testing
Collision_Do_1 equ *-2
        beq   @rts                     ; no AABB in the first AABB list, quit
@loopu  ldb   AABB.p,u
        beq   @skipu                   ; no more potential, skip this AABB
        ldx   #0
Collision_Do_2 equ *-2
        beq   @rts                     ; no AABB in the second AABB list, quit
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
;
; compute collision damage
        ldb   AABB.p,x
        bpl   >
        ldb   AABB.p,u
        bmi   @continue                 ; X and U are invincible, no changes
        clr   AABB.p,u                  ; X is invincible, U Loose
        bra   @continue
!       lda   AABB.p,u
        bpl   >
@xWeak  clr   AABB.p,x                  ; U is invincible, X Loose
        bra   @continue
!       cmpb  #127
        beq   @xWeak
        cmpa  #127
        beq   @uWeak
        clrb 
        suba  AABB.p,x
        bmi   @loose
@win    sta   AABB.p,u                ; win or draw
        stb   AABB.p,x
        bra   @continue
@uWeak  clr   AABB.p,u                ; U is weak box, U Loose
        bra   @continue
@loose  nega                          ; loose
        sta   AABB.p,x
        stb   AABB.p,u
@continue
@skipx  ldx   AABB.next,x
        bne   @loopx
@skipu  ldu   AABB.next,u
        bne   @loopu
@rts    rts

