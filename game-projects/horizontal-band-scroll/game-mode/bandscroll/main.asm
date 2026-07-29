
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/graphics/tilemap/hscroll/hscroll.macro.asm"
        INCLUDE "./objects/band/band.0.0.bin.hscroll.equ"

        ; global init
        org   $6100
        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads

        ; scroll setup : band at top of screen so that irq S spill ends
        ; in the unused $9FF4-$9FFF / $BFF4-$BFFF areas
        _hscroll.setBuffer #ObjID_bandA,#ObjID_bandB
        _hscroll.setExitOffset #hscroll.band.EXIT_OFFSET
        _hscroll.setGuardColor #hscroll.band.GUARD
        _hscroll.setViewport #0,#hscroll.band.HEIGHT
        _hscroll.setCameraPos #0
        _hscroll.setCameraSpeed ctrlspeed

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

        ; speed control based on joypad
        ; (capped to one 2px step by frame)
        ; ---------------------------------
        jsr   ReadJoypads
        lda   Dpad_Held
TestLeft
        bita  #c1_button_left_mask
        beq   TestRight
        ldx   ctrlspeed
        leax  -$0010,x
        cmpx  #-$0200                  ; max 2px by frame, leftward
        bge   >
        ldx   #-$0200
        bra   >
TestRight
        bita  #c1_button_right_mask
        beq   @exit
        ldx   ctrlspeed
        leax  $0010,x
        cmpx  #$0200                   ; max 2px by frame, rightward
        ble   >
        ldx   #$0200
!       stx   ctrlspeed
        _hscroll.setCameraSpeed ctrlspeed
@exit

        ; gfx write
        ; ---------
        _gfxlock.on
        jsr   hscroll.do
        jsr   hscroll.move
        _gfxlock.off

        _gfxlock.loop
        jmp   LevelMainLoop

ctrlspeed fdb $0080

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
        jsr   gfxlock.bufferSwap.check
        jmp   PalUpdateNow

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/bandscroll/ramdata.asm"

* ==============================================================================
* Routines
* ==============================================================================

        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/graphics/tilemap/hscroll/hscroll.asm"
