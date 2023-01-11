        
_chunk MACRO
        ldd   #$DDDD
        ldx   #$DDDD
        ldy   #$DDDD
        ldu   #$DDDD
        pshs  d,x,y,u
 ENDM

_chunk1 MACRO
        ldd   #$CCCC
        ldx   #$CCCC
        ldy   #$CCCC
        ldu   #$CCCC
        pshs  d,x,y,u
 ENDM

_chunk2 MACRO
        ldd   #$BBBB
        ldx   #$BBBB
        ldy   #$BBBB
        ldu   #$BBBB
        pshs  d,x,y,u
 ENDM

_chunk3 MACRO
        ldd   #$AAAA
        ldx   #$AAAA
        ldy   #$AAAA
        ldu   #$AAAA
        pshs  d,x,y,u
 ENDM

_line MACRO
        _chunk
        _chunk
        _chunk
        _chunk
        _chunk
 ENDM

_line1 MACRO
        _chunk1
        _chunk1
        _chunk1
        _chunk1
        _chunk1
 ENDM

_line2 MACRO
        _chunk2
        _chunk2
        _chunk2
        _chunk2
        _chunk2
 ENDM

_line3 MACRO
        _chunk3
        _chunk3
        _chunk3
        _chunk3
        _chunk3
 ENDM

_linex8 MACRO
        _line
        _line1
        _line2
        _line3
        _line
        _line1
        _line2
        _line3
 ENDM
 
@loop   _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _linex8
        _line2
        jmp   @loop
