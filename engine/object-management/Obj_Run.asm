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

INLINED set 1                   ; inlined Obj_Mount for speed (takes more bytes however)

Obj_Mount                       ; B = ObjID -> page montee, X = adresse objet (clobber A,B,X)
        ifne INLINED
        ldx   #Obj_Index_Page
        lda   b,x               ; A = numero de page de l'objet
        _SetCartPageA           ; monte la page (sta $E7E6 ; jsr SetCartPageA en T2)
        aslb                    ; B = ObjID*2 (index mot)
        ldx   #Obj_Index_Address
        ldx   b,x               ; X = adresse d'entree de l'objet
        else
        ldx   #Obj_Index_Page
        abx
        lda   ,x                ; A = numero de page de l'objet
        _SetCartPageA           ; monte la page (sta $E7E6 ; jsr SetCartPageA en T2)
        abx                     ; B = ObjID*2 (index mot)
        ldx   <Obj_Index_Address-Obj_Index_Page,x               ; X = adresse d'entree de l'objet
        endc
        rts

Obj_Run                         ; B = ObjID (, U = data optionnel) -> lance l'objet (tail)
        ifne INLINED
        bsr   Obj_Mount
        jmp   ,x
        else
        ldx   #Obj_Index_Page
        abx
        lda   ,x                ; A = numero de page de l'objet
        _SetCartPageA           ; monte la page (sta $E7E6 ; jsr SetCartPageA en T2)
        abx                     ; B = ObjID*2 (index mot)
        jmp   [<Obj_Index_Address-Obj_Index_Page,x]               ; X = adresse d'entree de l'objet
        endc

Obj_RunB                        ; A = ObjID, B = routine -> lance l'objet (B = routine)
        ifne INLINED
        stb   @rt               ; ecriture dynamique : range la routine dans l'operande ci-dessous
        tfr   a,b               ; B = ObjID pour le mount
        bsr   Obj_Mount
        ldb   #0                ; B = routine (operande auto-modifie par stb @rt)
@rt     equ   *-1
        jmp   ,x
        else
        stb   @rt+1
        ldx   #Obj_Index_Page
        ldb   a,x               ; A = numero de page de l'objet
        _SetCartPageB           ; monte la page (sta $E7E6 ; jsr SetCartPageA en T2)
        asla                    ; B = ObjID*2 (index mot)
        ldx   #Obj_Index_Address
@rt     ldb   #0
        jmp   [a,x]             ; X = adresse d'entree de l'objet
        endc