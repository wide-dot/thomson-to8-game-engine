        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"

        org   $6100
        jsr   LoadAct
        bra   *

        INCLUDE "./engine/palette/color/Pal_black.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
