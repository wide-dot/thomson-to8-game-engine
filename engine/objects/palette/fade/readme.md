Typical use :

```
        jsr   LoadObject_u
        beq   >
        lda   #ObjID_fade
        sta   id,u
        ldd   Pal_current
        std   ext_variables,u          ; source palette
        ldd   #Pal_game
        std   ext_variables+2,u        ; dest palette
        lda   #10
        sta   ext_variables+10,u       ; nb of frames between color change (0-n)
!```