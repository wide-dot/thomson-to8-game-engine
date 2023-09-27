
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"

        ; global init
        org   $6100
        jsr   InitGlobals
        jsr   LoadAct
        jsr   joypad.md6.init

        ; irq setup
        ldd   #UserIRQ
        std   Irq_user_routine
        jsr   IrqInit
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn

* ==========================================================================
* Main Loop
* ==========================================================================
LevelMainLoop

        jsr   joypad.md6.read
        lda   joypad.md6.ctrl0.held

        ; reset palette color
        ldy   #Pal_off
        ldx   #$2202 ; dark grey color
        stx   12,y   ; A
        stx   14,y   ; B
        stx   24,y   ; right
        stx   26,y   ; left
        stx   28,y   ; down
        stx   30,y   ; up
        ldx   #$4404 ; mid grey color
        stx   16,y   ; Mode
        stx   18,y   ; X
        stx   20,y   ; Y
        stx   22,y   ; Z
        ldx   #$2701 ; light orange color
TestUp
        bita  #joypad.md6.up
        beq   TestDown   
        stx   30,y
        bra   TestLeft
TestDown
        bita  #joypad.md6.down
        beq   TestLeft
        stx   28,y
TestLeft
        bita  #joypad.md6.left
        beq   TestRight   
        stx   26,y
        bra   TestA
TestRight
        bita  #joypad.md6.right
        beq   TestA
        stx   24,y
TestA
        bitb  #joypad.md6.a
        beq   TestB
        stx   12,y
TestB
        bitb  #joypad.md6.b
        beq   TestMode
        stx   14,y
TestMode
        bitb  #joypad.md6.mode
        beq   TestX
        stx   16,y
TestX
        bitb  #joypad.md6.x
        beq   TestY
        stx   18,y
TestY
        bitb  #joypad.md6.y
        beq   TestZ
        stx   20,y
TestZ
        bitb  #joypad.md6.z
        beq   >
        stx   22,y
!       clr   PalRefresh

        _gfxlock.on
        ; all routines that writes to video memory ...
        _gfxlock.off

        _gfxlock.loop
        jmp   LevelMainLoop

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
        jsr   gfxlock.bufferSwap.check
	jmp   PalUpdateNow

* ==============================================================================
* Routines
* ==============================================================================

        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/joypad/joypad.md6.asm"
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"
