    ;INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"
@loop
        INCLUDE "./engine/graphics/tilemap/vscroll/buffer.asm"
        _vscroll.buffer.line
        jmp   @loop