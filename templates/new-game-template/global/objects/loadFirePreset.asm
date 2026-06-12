Object
        ldy   #Routines
        jmp   [a,y]

Routines
        fdb   loadFirePreset
        fdb   loadFirePresetBug

; -----------------------------------------------------------------------------
; loadFirePreset
; --------------
; B : preset id from Object Wave (bit4-7)
;
; data table store 16 presets of 4 bytes * 4 levels of difficulty
; -----------------------------------------------------------------------------

loadFirePreset ; 0xfca7
        ldx   #loadFirePreset.data
        andb  #$f0
        lsrb
        lsrb
        abx

        lda   #4*16                    ; 4 bytes by 16 presets
        ldb   globals.difficulty       ; 4 level of difficulty 
        mul
        leax  d,x

        ldd   ,x
        std   fireVelocityPreset,u    ; and fireThreshold,u
        ldd   2,x
        std   fireReset,u

        jsr   RandomNumber
        lda   #0
        aslb
        aslb
        stb   @b
        ldb   fireThreshold,u
        decb
        andb  #0
@b      equ   *-1
        std   fireCounter,u
        rts

; -----------------------------------------------------------------------------
; loadFirePresetBug
; -----------------
; B : preset id from Object Wave (bit0-4)
;
; this is a dedicated version for objet bug
; -----------------------------------------------------------------------------

loadFirePresetBug ; 0xfca7
        ldy   #loadFirePreset.data
        aslb                           ; a preset is define by 4 bytes
        aslb
        leay  b,y                      
        lda   #4*16                    ; a level of difficulty owns 16 presets
        ldb   globals.difficulty
        mul
        leay  d,y

        ldd   ,y
        std   fireVelocityPreset,x     ; and fireThreshold,x
        ldd   2,y
        std   fireReset,x

        jsr   RandomNumber
        clra
        andb  #$0f
        std   fireCounter,x
        rts

loadFirePreset.data
        INCLUDE "./global/preset/18e10_preset-fire.asm"
