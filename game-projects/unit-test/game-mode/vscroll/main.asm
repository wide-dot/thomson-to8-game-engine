
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"

        ; global init
        org   $6100
        jsr   InitGlobals
        jsr   InitStack        
        jsr   LoadAct
        jsr   InitJoypads

        ; scroll setup
        _vscroll.setMap #ObjID_level1Map
        _vscroll.setMapHeight #158*16
        _vscroll.setTileset #ObjID_level1TileA,#ObjID_level1TileB
        _vscroll.setBuffer #ObjID_scrollA,#ObjID_scrollB
        _vscroll.setCameraPos #158*16-200
        _vscroll.setCameraSpeed #ctrlspeed
        _vscroll.setViewport #0,#200

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
        jsr   ReadJoypads
        jsr   RunObjects

        lda   Dpad_Press
TestUp
        bita  #c1_button_up_mask
        beq   TestDown   
        ldx   ctrlspeed
        leax  -$0005,x
        stx   ctrlspeed
        bra   >
TestDown
        bita  #c1_button_down_mask
        beq   >
        ldx   ctrlspeed
        leax  $0005,x
        stx   ctrlspeed
!       _vscroll.setCameraSpeed ctrlspeed

        _gfxlock.on
        jsr   vscroll.do
        jsr   vscroll.move
        _gfxlock.off

        _gfxlock.loop
        bra   LevelMainLoop

ctrlspeed fdb $ff80

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
        jsr   gfxlock.bufferSwap.check
	jmp   PalUpdateNow

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/vscroll/ramdata.asm"

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
        INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.asm"
