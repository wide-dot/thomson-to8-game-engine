; ---------------------------------------------------------------------------
; Subroutine to generate a pseudo-random number in d
; By Samuel Devulder
; ---------------------------------------------------------------------------

InitRNG
        ldd   $E7E6
        std   RNG_seed
        rts

RandomNumber
        ldd   #0
RNG_seed equ *-2
        lsra              
        rorb              
        eorb  RNG_seed
        stb   @a
        rorb              
        eorb  RNG_seed+1
        tfr   b,a         
        eora  #0          
@a      equ   *-1
        std   RNG_seed
        rts
