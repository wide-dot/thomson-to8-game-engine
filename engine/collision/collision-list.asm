        INCLUDE "./engine/collision/struct_AABB.equ"

; Collision : (de)referencement d'un AABB dans une liste chainee. Appele par les
; OBJETS (via _Collision_AddAABB / _Collision_RemoveAABB) qui tournent en page
; cartouche -> ces routines DOIVENT rester residentes (page 1). La passe de
; detection Collision_Do est separee dans collision-do.asm (peut sortir du
; resident quand seul le main l'appelle).
; ------------------------------------------------------------------------------

; La boite ajoutee repart de liens PROPRES. Sans cela elle gardait ce qui
; trainait a ses offsets prev/next dans le slot OST au moment de l'ajout : la
; branche liste-vide ci-dessous n'ecrivait ni l'un ni l'autre, et la branche
; liste-non-vide ne posait que prev. Constate en aout 2026 sur un jeu : une
; liste a un seul element dont le next valait $0200, donc Collision_Do partait
; dans le vide des le premier noeud et les tirs ne touchaient plus rien de cette
; liste. C'est aussi ce que demandait _Collision_CleanLinksAABB avant un
; changement de liste, qui devient inutile.
Collision_AddAABB
        ldu   2,y
        beq   >
        stx   AABB.next,u
        stx   2,y
        stu   AABB.prev,x              ; u = ancienne queue, a lire avant de le
        ldu   #0                       ; remettre a zero
        stu   AABB.next,x
        rts
!       stx   2,y
        stx   ,y
        ldu   #0
        stu   AABB.prev,x
        stu   AABB.next,x
        rts

; ------------------------------------------------------------------------------

; Retirer une boite ABSENTE de la liste doit rester sans effet. Sans le test
; ci-dessous, un tel appel tombait dans @noNext avec y et u a zero, puis posait
; tail = 0 et head = 0 : la liste etait videe d'un coup et TOUTES les autres
; boites deschainees. Les objets concernes restaient affiches et mobiles mais
; devenaient incollisionnables, et l'appel suivant a Collision_AddAABB repartait
; sur une liste vide en laissant les orphelines derriere. Panne silencieuse,
; aleatoire, et sans rapport visible avec son declencheur.
;
; Une boite est dans la liste si son prev est non nul, ou si elle en est la tete.
Collision_RemoveAABB
        ldu   AABB.prev,x
        bne   @linked
        cmpx  0
Collision_Remove_4 equ *-2
        beq   @linked
        rts                            ; absente : ne rien faire
@linked
        ldy   AABB.next,x
        beq   @noNext
        ldu   AABB.prev,x
        stu   AABB.prev,y
        beq   @noPrev
        sty   AABB.next,u
        bra   @clean
@noPrev sty   0
Collision_Remove_1 equ *-2
        bra   @clean
@noNext ldu   AABB.prev,x
        beq   >
        sty   AABB.next,u
!       stu   0
Collision_Remove_2 equ *-2
        bne   @clean
        stu   0
Collision_Remove_3 equ *-2
; Les liens de la boite retiree sont remis a zero. Sans ca un second retrait
; verrait un prev perime non nul, prendrait le test d'appartenance pour un
; succes et repartirait dans le chainage d'une liste qu'elle a quittee. C'est
; aussi ce que demandait _Collision_CleanLinksAABB avant un changement de liste,
; qui devient donc inutile.
@clean  ldu   #0
        stu   AABB.prev,x
        stu   AABB.next,x
        rts
