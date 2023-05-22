; -----------------------------------------------------------------------------
; loadFirePreset
; --------------
; B : preset id from Object Wave
;
; input value is an index between 0-15 (bit4-7)
; data table store 16 presets of 3 words * 4 levels of difficulty
; -----------------------------------------------------------------------------

        INCLUDE "./global/object.const.asm"

loadFirePreset ; fca7
        ldx   #loadFirePreset.data
        andb  #$f0                     ; index value is stored in bits 4-7 (16 val)
        lsrb                           ; shift 4 times to right and mul by 6 (bytes)
        lsrb
        std   @b
        lsrb
        addb  #0
@b      equ   *-2
        leax  d,x

        lda   #6*16
        ldb   globals.difficulty       ; 4 level of difficulty 
        mul
        leax  d,x

        ldd   ,x
        std   fireDirectionPreset,u    ; and fireThreshold,u
        ldd   2,x
        std   fireReset,u

        jsr   RandomNumber
        lda   #0                       ; code was made simplier as a threshold of 0 means no fire
        aslb
        aslb
        stb   @b
        ldb   fireThreshold,u
        decb
        andb  #0
@b      equ   *-1
        std   fireCounter,u
        rts

loadFirePreset.data
        INCLUDE "./global/preset/preset-fire.asm"

; -----------------------------------------------------------------------------
; createFoeFire
; --------------
; B : preset id from Object Wave
;
; input value is an index between 0-15 (bit4-7)
; data table store 16 presets of 3 words * 4 levels of difficulty
; -----------------------------------------------------------------------------

createFoeFire ; 0xfa3a
        ldd   fireCounter,u
        addd  #1
        std   fireCounter,u
        cmpa  #0
        bne   >
        cmpb  firtshreshold,u
        beq   LAB_0000_fa50
!       cmpd  fireReset,u
        bhs   LAB_0000_fa4b
        rts
LAB_0000_fa4b
        ldd   #0
        std   fireCounter,u
LAB_0000_fa50
        ldb   fireDirectionPreset,u
        beq   LAB_0000_fa93            ; 0 in fireDirectionPreset means no fire
        jsr   LoadObject_x
        beq   LAB_0000_fa93
        lda   #ObjID_foefire
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        ldx   #player1
        ldy   #createFoeFire.data
        jsr   setDirectionTo           ; rtsurn value is y += (0-63)
        lda   #64
        ldb   fireDirectionPreset,u
        mul
        leay  d,y
        ldd   ,y                       ; load computed direction
        std   x_vel,x
        ldd   2,y
        std   y_vel,x
        ldd   #3
        std   var20,x
LAB_0000_fa93
        rts

; -----------------------------------------------------------------------------
; setDirectionTo
; --------------
; X : target object
;
; -----------------------------------------------------------------------------

setDirectionTo ; 0x2189
        MOV        SI,word ptr [BP + 0x4]
        MOV        DI,word ptr [BP + 0x8]
        MOV        DX,word ptr [BX + 0x4]
        MOV        BX,word ptr [BX + 0x8]
        MOV        AX,DI
        ADD        AX,0x8
        SUB        AX,BX
        JC         LAB_0000_21b5
        MOV        AX,DI
        SUB        AX,0x8
        SUB        AX,BX
        JNC        LAB_0000_21ca
        MOV        AX,SI
        SUB        AX,DX
        JNC        LAB_0000_21b1
        MOV        BX,0x10
        rts
LAB_0000_21b1
        MOV        BX,0x30
        rts
LAB_0000_21b5
        MOV        AX,SI
        ADD        AX,0x8
        SUB        AX,DX
        JC         LAB_0000_21e0
        MOV        AX,SI
        SUB        AX,0x8
        SUB        AX,DX
        JNC        LAB_0000_2203
        XOR        BX,BX
        rts
LAB_0000_21ca
        MOV        AX,SI
        ADD        AX,0x8
        SUB        AX,DX
        JC         LAB_0000_2226
        MOV        AX,SI
        SUB        AX,0x8
        SUB        AX,DX
        JNC        LAB_0000_2249
        MOV        BX,0x20
        rts
LAB_0000_21e0
         MOV        AX,DX
         SUB        AX,SI
         MOV        CX,BX
         SUB        CX,DI
         SUB        AX,CX
         ADD        AX,0x20
         CMP        AX,0x40
         JC         LAB_0000_21fb
         TEST       AX,0x8000
         JZ         LAB_0000_21ff
         MOV        BX,0x4
         rts
LAB_0000_21fb
        MOV        BX,0x8
        rts
LAB_0000_21ff
        MOV        BX,0xc
        rts
LAB_0000_2203
        MOV        AX,SI
        SUB        AX,DX
        MOV        CX,BX
        SUB        CX,DI
        SUB        AX,CX
        ADD        AX,0x20
        CMP        AX,0x40
        JC         LAB_0000_221e
        TEST       AX,0x8000
        JZ         LAB_0000_2222
        MOV        BX,0x3c
        rts
LAB_0000_221e
        MOV        BX,0x38
        rts
LAB_0000_2222
        MOV        BX,0x34
        rts
LAB_0000_2226
        MOV        AX,DX
        SUB        AX,SI
        MOV        CX,DI
        SUB        CX,BX
        SUB        AX,CX
        ADD        AX,0x20
        CMP        AX,0x40
        JC         LAB_0000_2241
        TEST       AX,0x8000
        JZ         LAB_0000_2245
        MOV        BX,0x1c
        rts
LAB_0000_2241
        MOV        BX,0x18
        rts
LAB_0000_2245
        MOV        BX,0x14
        rts
LAB_0000_2249
        MOV        AX,SI
        SUB        AX,DX
        MOV        CX,DI
        SUB        CX,BX
        SUB        AX,CX
        ADD        AX,0x20
        CMP        AX,0x40
        JC         LAB_0000_2264
        TEST       AX,0x8000
        JZ         LAB_0000_2268
        MOV        BX,0x24
        rts
LAB_0000_2264
        MOV        BX,0x28
        rts
LAB_0000_2268
        MOV        BX,0x2c
        rts

createFoeFire.data
        INCLUDE "./global/preset/preset-fireVelocity.asm"
