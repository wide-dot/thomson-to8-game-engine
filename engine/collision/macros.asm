; usage:
;
; in the main code :
; AABB_List_friend fdb   0,0
; AABB_List_ennemy fdb   0,0
; AABB_List_player fdb   0,0
; AABB_List_bonus  fdb   0,0
; 
; in the object code :
; AABB_0 equ ext_variables ; 9 bytes
;
; _Collision_AddAABB AABB_0,AABB_list_friend
; _Collision_RemoveAABB AABB_0,AABB_list_friend
; _Collision_CleanLinksAABB AABB_0
; _Collision_Do AABB_list_friend,AABB_list_ennemy
;
; WARNING !
; - When a box change from a list to another, you MUST use CleanLinksAABB after removing and before adding
; - Never use a single box in two or more lists
; --------------------------------------

_Collision_AddAABB MACRO
        pshs  u,x,y
        leax  \1,u
        ldy   #\2
        jsr   Collision_AddAABB
        puls  u,x,y
 ENDM

; --------------------------------------

_Collision_RemoveAABB MACRO
        pshs  d,u,x,y
        ldx   #\2
        stx   Collision_Remove_1
        stx   Collision_Remove_3
        leax  2,x
        stx   Collision_Remove_2
        leax  \1,u
        jsr   Collision_RemoveAABB
        puls  d,u,x,y
 ENDM

; --------------------------------------

_Collision_CleanLinksAABB MACRO
        ldd   #0
        std   \1+AABB.prev,u
        std   \1+AABB.next,u
 ENDM

; --------------------------------------

_Collision_Do MACRO
        ldd   \1
        std   Collision_Do_1
        ldd   \2
        std   Collision_Do_2
        jsr   Collision_Do
 ENDM
