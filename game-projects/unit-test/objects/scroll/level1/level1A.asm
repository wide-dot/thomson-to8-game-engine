    INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"
@loop
        INCLUDEBIN "./objects/scroll/level1/level1.start.0.0.bin.vscroll"
        _vscroll.buffer.linex8
        jmp   @loop