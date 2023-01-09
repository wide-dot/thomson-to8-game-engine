        
_chunk MACRO
        ldd   #*
        ldx   #*
        ldy   #*
        ldu   #*
        pshs  d,x,y,u
 ENDM

_line MACRO
        _chunk
        _chunk
        _chunk
        _chunk
        _chunk
 ENDM

_linex10 MACRO
        _line
        _line
        _line
        _line
        _line
        _line
        _line
        _line
        _line
        _line
 ENDM
 
@loop   _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _linex10
        _line
        jmp   @loop
