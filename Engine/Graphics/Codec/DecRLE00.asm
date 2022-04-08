*------------------------------------------------------------------------------*
*                                                                              *
* Decode RLE image data with transparency                                      *
* Samuel Devulder (01/10/2021)                                                 *
*                                                                              *
*------------------------------------------------------------------------------*
* Data :                                                                       *
* ------                                                                       *
* 00 000000              => end of data                                        *
* 00 nnnnnn              => write ptr offset n:1,63 (unsigned)                 *
* 01 000000 vvvvvvvv     => right pixel is transparent, v : byte to add        *
* 01 nnnnnn vvvvvvvv     => n: nb of byte to repeat (unsigned), value          *
* 10 000000 vvvvvvvv     => left pixel is transparent, v: byte to add          *
* 10 nnnnnn vvvvvvvv ... => n: nb of bytes to write (unsigned), values         *
* 11 nnnnnn nnnnnnnn     => write ptr offset n:-8192,8191 (14 bits signed)     *
*                                                                              *
* Registers :                                                                  *
* -----------                                                                  *
* y  : Ptr to data part 1                                                      *
* u  : Ptr to data part 2                                                      *
* glb_screen_location_1 : Ptr to screen part 1                                 *
* glb_screen_location_2 : Ptr to screen part 2                                 *
*------------------------------------------------------------------------------*


DecMapAlpha
        ldx   <glb_screen_location_1
        stu   @end+2
        cmpy  #0                       
        beq   @end                     ; branch if no data part 1
        bra   @loop
@l10x
        ldb   ,y+                      ; non-identical bytes
        stb   ,x+
        suba  #2
        bne   @l10x
@loop
        lda   ,y+                      ; new chunk
        lsla
        bcc   @l0x
        beq   @maskl        
        bpl   @l10x
@l11x
        lsla                           ; 14 bits offset
        asra
        asra 
        ldb   ,y+
        leax  d,x
        bra   @loop
@l0x
        beq   @end
        bmi   @l01x
@skip
        ldb   -1,y                     ; 6 bits offset
        abx
        bra   @loop
@l01x
        anda  #%01111111
        beq   @maskr
        ldb   ,y+
@repeat
        stb   ,x+                      ; repeat identical bytes
        suba  #2
        bne   @repeat
        bra   @loop
@maskr
        ldb   #$0f                     ; write half byte (transparency px on right)
        andb  ,x
        orb   ,y+
        stb   ,x+
        bra   @loop
@maskl
        ldb   #$f0                     ; write half byte (transparency px on left)
        andb  ,x
        orb   ,y+
        stb   ,x+
        bra   @loop
@end    
        ldy   #0                       ; (dynamic) load next data ptr
        beq   @rts
        ldd   #0                       
        std   @end+2                   ; clear exit flag for second pass
        ldx   <glb_screen_location_2
        bra   @loop
@rts    rts