; wrapper for zx0 mega

zx0_6809_mega_wrap
        stu   @x
        ldu   glb_screen_location_1                                      
        cmpx  #0                       
        beq   >                        ; branch if no data part 1
        jsr   zx0_decompress
!
        ldx   #0                       ; (dynamic) load next data ptr
@x      equ   *-2
        beq   @rts
        ldd   #0                       
        std   @x                       ; clear exit flag for second pass
        ldu   glb_screen_location_2
        jmp   zx0_decompress
@rts    rts

ZX0_DISABLE_DISABLING_INTERRUPTS equ 1

        INCLUDE "./Engine/Compression/zx0/zx0_6809_mega.asm"
        setdp   dp/256