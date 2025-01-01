    INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"
@loop
        INCLUDEBIN "./objects/scroll/level2/level.start.1.vscroll"
        _vscroll.buffer.linex8
        jmp   @loop