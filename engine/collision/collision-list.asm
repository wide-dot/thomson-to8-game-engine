        INCLUDE "./engine/collision/struct_AABB.equ"

; Collision : (de)referencement d'un AABB dans une liste chainee. Appele par les
; OBJETS (via _Collision_AddAABB / _Collision_RemoveAABB) qui tournent en page
; cartouche -> ces routines DOIVENT rester residentes (page 1). La passe de
; detection Collision_Do est separee dans collision-do.asm (peut sortir du
; resident quand seul le main l'appelle).
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
