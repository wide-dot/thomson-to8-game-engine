; common utilities
    INCLUDE "./engine/InitGlobals.asm"
    INCLUDE "./engine/ram/BankSwitch.asm"
    INCLUDE "./engine/palette/PalUpdateNow.asm"
    INCLUDE "./engine/ram/ClearDataMemory.asm"

    INCLUDE "./engine/object-management/RunObjects.asm"
    INCLUDE "./engine/level-management/LoadGameMode.asm"
    
; IRQ
    INCLUDE "./engine/irq/Irq.asm"        


