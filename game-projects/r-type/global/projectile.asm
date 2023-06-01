        INCLUDE "./global/projectile.macro.asm"

; -----------------------------------------------------------------------------
; tryFoeFire
; --------------
;
; -----------------------------------------------------------------------------

tryFoeFire ; 0xfa3a
        ldb   fireThreshold,u
        stb   @b
        ldd   fireCounter,u
        ldx   gfxlock.frameDrop.count_w
!       addd  #1
        cmpd  #0
@b      equ   *-1
        beq   LAB_0000_fa50
        cmpd  fireReset,u
        bhs   LAB_0000_fa4b
        leax  -1,x
        bne   <
        std   fireCounter,u
!       rts
LAB_0000_fa4b
        ldd   #0
LAB_0000_fa50
        std   fireCounter,u
        ldb   fireVelocityPreset,u
        beq   <                        ; 0 in fireVelocityPreset means no fire
        lda   Obj_Index_Page+ObjID_createFoeFire
        sta   PSR_Page   
        ldd   Obj_Index_Address+2*ObjID_createFoeFire
        std   PSR_Address                  
        jmp   RunPgSubRoutine
