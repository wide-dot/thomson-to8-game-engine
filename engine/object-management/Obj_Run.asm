; ===========================================================================
; Obj_Run - appel d'objet factorise (alternative aux macros _MountObject /
; _RunObject / _RunObjectRoutineB qui s'expansent EN LIGNE a chaque site).
; Un site d'appel devient quelques chargements de registres + un jsr -> reduit
; la taille du code resident. Utilise par R-Type stage 1 (cf. Obj_Run.macro.asm).
;
; A n'appeler QUE depuis le code RESIDENT (page 1) : ces routines changent la
; page cartouche sans la restaurer, comme _MountObject. Depuis un objet monte,
; utiliser _RunObjectSwapRoutine (page-saving) a la place.
; ===========================================================================

Obj_Mount                       ; B = ObjID -> page montee, X = adresse objet (clobber A,B,X)
        ldx   #Obj_Index_Page
        lda   b,x               ; A = numero de page de l'objet
        _SetCartPageA           ; monte la page (sta $E7E6 ; jsr SetCartPageA en T2)
        aslb                    ; B = ObjID*2 (index mot)
        ldx   #Obj_Index_Address
        ldx   b,x               ; X = adresse d'entree de l'objet
        rts

Obj_Run                         ; B = ObjID (, U = data optionnel) -> lance l'objet (tail)
        bsr   Obj_Mount
        jmp   ,x

Obj_RunB                        ; A = ObjID, B = routine -> lance l'objet (B = routine)
        stb   @rt               ; ecriture dynamique : range la routine dans l'operande ci-dessous
        tfr   a,b               ; B = ObjID pour le mount
        bsr   Obj_Mount
        ldb   #0                ; B = routine (operande auto-modifie par stb @rt)
@rt     equ   *-1
        jmp   ,x
