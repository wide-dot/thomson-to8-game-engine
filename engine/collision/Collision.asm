        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_player_first
        fdb   0
AABB_player_last
        fdb   0

AddPlayerAABB
        pshs  u
        ldu   AABB_player_last
        beq   >
        stx   AABB.next,u
        stx   AABB_player_last
        stu   AABB.prev,x
        puls  u,pc
!       stx   AABB_player_last
        stx   AABB_player_first
        puls  u,pc

RemovePlayerAABB
        pshs  d,y,u
        ldy   AABB.next,x 
        beq   @noNext
        ldu   AABB.prev,x
        stu   AABB.prev,y
        beq   @noPrev
        sty   AABB.next,u
        puls  d,y,u,pc
@noPrev sty   AABB_player_first
        puls  d,y,u,pc
@noNext ldu   AABB.prev,x
        beq   >
        sty   AABB.next,u
!       stu   AABB_player_last
        bne   @end
        stu   AABB_player_first
@end    puls  d,y,u,pc

AABB_ai_first
        fdb   0
AABB_ai_last
        fdb   0

AddAiAABB
        pshs  u
        ldu   AABB_ai_last
        beq   >
        stx   AABB.next,u
        stx   AABB_ai_last
        stu   AABB.prev,x
        puls  u,pc
!       stx   AABB_ai_last
        stx   AABB_ai_first
        puls  u,pc

RemoveAiAABB
        pshs  d,y,u
        ldy   AABB.next,x 
        beq   @noNext
        ldu   AABB.prev,x
        stu   AABB.prev,y
        beq   @noPrev
        sty   AABB.next,u
        puls  d,y,u,pc
@noPrev sty   AABB_ai_first
        puls  d,y,u,pc
@noNext ldu   AABB.prev,x
        beq   >
        sty   AABB.next,u
!       stu   AABB_ai_last
        bne   @end
        stu   AABB_ai_first
@end    puls  d,y,u,pc

DoCollision
        ldu   AABB_player_first        ; all pairs testing
        beq   @rts                     ; no AABB in the player AABB list, quit
@loopu  ldb   AABB.p,u
        beq   @skipu                   ; no more potential, skip this AABB
        ldx   AABB_ai_first
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
        bhi   @break
        lda   AABB.ry,u
        adda  AABB.ry,x
        asla
        sta   @ry
        asra
        adda  AABB.cy,u
        suba  AABB.cy,x
        cmpa  #0
@ry     equ *-1 
        bhi   @break
!
        ldb   #0                       ; compute collision damage
        lda   AABB.p,u 
        suba  AABB.p,x
        beq   @draw
        bmi   @loose
@draw   stb   AABB.p,u
        stb   AABB.p,x
        bra   @break
@win    sta   AABB.p,u
        stb   AABB.p,x
        bra   @break
@loose  lda   AABB.p,x
        suba  AABB.p,u
        sta   AABB.p,x
        stb   AABB.p,u
@break
@skipx  ldx   AABB.next,x
        bne   @loopx
@skipu  ldu   AABB.next,u
        bne   @loopu
@rts    rts
