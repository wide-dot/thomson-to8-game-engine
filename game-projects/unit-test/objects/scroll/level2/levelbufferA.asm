    INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"
@loop
        INCLUDEBIN "./objects/scroll/level2/level.start.0.vscroll"
        _vscroll.buffer.linex8
        jmp   @loop