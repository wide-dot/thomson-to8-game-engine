        
_chunk MACRO
        ldd   #0
        ldx   #0
        ldy   #0
        ldu   #0
        pshs  d,x,y,u
 ENDM

_line MACRO
        _chunk
        _chunk
        _chunk
        _chunk
        _chunk
 ENDM

_linex8 MACRO
        _line
        _line
        _line
        _line
        _line
        _line
        _line
        _line
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
        _line
        jmp   @loop
