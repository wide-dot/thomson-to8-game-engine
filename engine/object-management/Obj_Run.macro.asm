; ===========================================================================
; Macros d'appel d'objet factorise (routines dans Obj_Run.asm).
; Suffixe = parametre transmis a l'objet : U = pointeur data (OST), B = commande.
; Pas de suffixe = aucun parametre. A n'utiliser que depuis la page residente.
; ===========================================================================

_Obj_Mount MACRO        ; \1 = ObjID -> mount seul, X = adresse objet
        ldb   #\1
        jsr   Obj_Mount
 ENDM

_Obj_Run MACRO          ; \1 = ObjID -> lance l'objet sans parametre
        ldb   #\1
        jsr   Obj_Run
 ENDM

_Obj_RunU MACRO         ; \1 = ObjID, \2 = #data -> lance l'objet (U = data/OST)
        ldb   #\1
        ldu   \2
        jsr   Obj_Run
 ENDM

_Obj_RunB MACRO         ; \1 = ObjID, \2 = #routine -> lance l'objet (B = routine)
        lda   #\1
        ldb   \2
        jsr   Obj_RunB
 ENDM

_Obj_Jmp MACRO          ; \1 = ObjID -> tail-call l'objet (rts objet -> appelant)
        ldb   #\1
        jmp   Obj_Run
 ENDM
