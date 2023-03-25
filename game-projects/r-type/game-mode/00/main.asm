
DEBUG   equ     1
SOUND_CARD_PROTOTYPE equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/objects/palette/fade/fade.equ"
        INCLUDE "./global/macro.asm"

viewport_width  equ 144
viewport_height equ 180

 ; value in animation script

        org   $6100

        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads

        jsr   WaitVBL

; init user irq


        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        lda   #GmID_title
        sta   glb_Cur_Game_Mode



	ldu   #addr_logo

        jsr   LoadObject_x		; Logo R
	stx   ,u++
        lda   #ObjID_logo_r
        sta   id,x

        jsr   LoadObject_x		; Logo Dot
	stx   ,u++
        lda   #ObjID_logo_dot
        sta   id,x

        jsr   LoadObject_x		; Logo T
	stx   ,u++
        lda   #ObjID_logo_t
        sta   id,x

        jsr   LoadObject_x		; Logo Y
	stx   ,u++
        lda   #ObjID_logo_y
        sta   id,x

        jsr   LoadObject_x		; Logo P
	stx   ,u++
        lda   #ObjID_logo_p
        sta   id,x


        jsr   LoadObject_x		; Logo E
	stx   ,u
        lda   #ObjID_logo_e
        sta   id,x

* ---------------------------------------------------------------------------
* PHASE 1 : Letters move from right to left
* ---------------------------------------------------------------------------

Phase1Init

	ldu   #addr_logo
	ldy   #logo_startx
	lda   #6
	sta   @phase1initloopnum
Phase1InitLoop
	ldx   ,u++
	ldd   ,y++
        std   x_pos,x
        ldd   #100
        std   y_pos,x
	ldd   #-$200
	std   x_vel,x
	lda   #0
@phase1initloopnum equ *-1
	deca
	sta   @phase1initloopnum
	bne   Phase1InitLoop
Phase1Live

	ldu   #addr_logo
	ldx   ,u
	ldd   x_pos,x
	cmpd  #35
	ble   Phase2Init

        jsr   WaitVBL
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   Phase1Live

* ---------------------------------------------------------------------------
* PHASE 2 : Letters expand to the right
* ---------------------------------------------------------------------------

Phase2Init
	ldx   ,u
	ldy   #logo_finalpos
	ldd   ,y
	std   x_pos,x
	ldy   #logo_xvel
	lda   #6
	sta   @phase2initloopnum
Phase2InitLoop
	ldx   ,u++
	ldd   ,y++
	std   x_vel,x
	lda   #0
@phase2initloopnum equ *-1
	deca
	sta   @phase2initloopnum
	bne   Phase2InitLoop
Phase2Live

	ldu   #addr_logo
	ldx   2,u
	ldd   x_pos,x
	cmpd  #50
	bge   Phase3Init

        jsr   WaitVBL
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   Phase2Live

* ---------------------------------------------------------------------------
* PHASE 3 : Re-align the logo, move the TM
* ---------------------------------------------------------------------------

Phase3Init
	ldu   #addr_logo
	ldy   #logo_finalpos
	lda   #6
	sta   @phase3initloopnum
Phase3InitLoop
	ldx   ,u++
	ldd   #0
	std   x_vel,x
	ldd   ,y++
	std   x_pos,x
	lda   #0
@phase3initloopnum equ *-1
	deca
	sta   @phase3initloopnum
	bne   Phase3InitLoop

        jsr   LoadObject_x		; Logo TM
	stx   addr_tm
        lda   #ObjID_logo_tm
        sta   id,x
	ldd   #0
	std   x_pos,x
	std   y_pos,x
	ldd   #690
	std   x_vel,x
	ldd   #650
	std   y_vel,x

Phase3Live

	ldu   #addr_tm
	ldx   ,u
	ldd   y_pos,x
	cmpd  #125
	bge   Phase4Init
	ldd   x_pos,x
	cmpd  #133
	bge   Phase4Init

        jsr   WaitVBL
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   Phase3Live

* ---------------------------------------------------------------------------
* PHASE 4 : Move the logo and TM down
* ---------------------------------------------------------------------------

Phase4Init

	ldu   #addr_logo
	lda   #6
	sta   @phase4initloopnum
Phase4InitLoop
	ldx   ,u++
	ldd   #200
	std   y_vel,x
	lda   #0
@phase4initloopnum equ *-1
	deca
	sta   @phase4initloopnum
	bne   Phase4InitLoop

	ldu   #addr_tm
	ldx   ,u
	ldd   #0
	std   x_vel,x
	ldd   #200
	std   y_vel,x
	ldd   #138
	std   x_pos,x
	ldd   #130
	std   y_pos,x

Phase4Live

	ldu   #addr_logo
	ldx   ,u
	ldd   y_pos,x
	cmpd  #126
	bge   Phase5Init

        jsr   WaitVBL
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   Phase4Live


* ---------------------------------------------------------------------------
* PHASE 5 : Stop the logo and TM. start the music and display the text
* ---------------------------------------------------------------------------

Phase5Init

	ldu   #addr_logo
	lda   #6
	sta   @phase5initloopnum
Phase5InitLoop
	ldx   ,u++
	ldd   #0
	std   y_vel,x
	lda   #0
@phase5initloopnum equ *-1
	deca
	sta   @phase5initloopnum
	bne   Phase5InitLoop

	ldu   #addr_tm
	ldx   ,u
	ldd   #0
	std   y_vel,x

        jsr   LoadObject_x		; Text
        lda   #ObjID_text
        sta   id,x

        jsr   IrqOff
        _MountObject ObjID_ymm
        _MusicInit_objymm #0,#MUSIC_LOOP,#0
        _MountObject ObjID_vgc
        _MusicInit_objvgc #0,#MUSIC_LOOP,#0
        jsr   IrqOn


Phase5Live

        _MountObject ObjID_text
        lda   ,x                        ; Test if type writer is done
        cmpa  #$39                      ; Op code for RTS
        beq   Phase6Live
        jsr   WaitVBL
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   Phase5Live


* ---------------------------------------------------------------------------
* PHASE 6 : Check for fire button
* ---------------------------------------------------------------------------

Phase6Live

        ; press fire
        lda   Fire_Press
        anda  #c1_button_A_mask
        bne   Phase7Init
        jsr   WaitVBL
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   Phase6Live

* ---------------------------------------------------------------------------
* PHASE 7 : Launch Level 1
* ---------------------------------------------------------------------------
Phase7Init
        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow

        jsr   IrqOff                    
        jsr   resetsn
        jsr   resetym
        lda   #GmID_level01
        sta   GameMode
        jsr   LoadGameModeNow


addr_logo	fdb 0     * R
		fdb 0     * Dot
		fdb 0     * T
		fdb 0     * Y
		fdb 0     * P
		fdb 0     * E

addr_tm         fdb 0

logo_startx	fdb 150
		fdb 146
		fdb 150
		fdb 150
		fdb 150
		fdb 149

logo_xvel	fdb 0
		fdb 84
		fdb 132
		fdb 216
		fdb 300
		fdb 384

logo_finalpos	fdb 32
		fdb 50
		fdb 67
		fdb 90
		fdb 112
		fdb 134


* ---------------------------------------------------------------------------
* MUSIC - RESET SN
* ---------------------------------------------------------------------------

resetsn
        lda   #$9F
        sta   SN76489.D
        lda   #$BF
        sta   SN76489.D
        lda   #$DF
        sta   SN76489.D
        lda   #$FF
        sta   SN76489.D  
        rts

* ---------------------------------------------------------------------------
* MUSIC - RESET YM
* ---------------------------------------------------------------------------

resetym
        ldd   #$200E
        stb   YM2413.A
        nop                            ; (wait of 2 cycles)
        ldb   #0                       ; (wait of 2 cycles)
        sta   YM2413.D                 ; note off for all drums     
        lda   #$20                     ; (wait of 2 cycles)
        brn   *                        ; (wait of 3 cycles)
@c      exg   a,b                      ; (wait of 8 cycles)                                      
        exg   a,b                      ; (wait of 8 cycles)                                      
        sta   YM2413.A
        nop
        inca
        stb   YM2413.D
        cmpa  #$29                     ; (wait of 2 cycles)
        bne   @c                       ; (wait of 3 cycles)
        rts

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
	jsr   PalUpdateNow
        _MountObject ObjID_ymm
        _MusicFrame_objymm
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts



* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/00/ram_data.asm"

* ---------------------------------------------------------------------------
* ENGINE routines
* ---------------------------------------------------------------------------

        ; common utilities
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"
        ;INCLUDE "./engine/math/CalcSine.asm"
        ;INCLUDE "./engine/math/Mul9x16.asm"

        ; joystick
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ObjectMove.asm"
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/ObjectDp.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"
        INCLUDE "./engine/graphics/animation/AnimateMoveSync.asm"

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"

        INCLUDE "./engine/level-management/LoadGameMode.asm"

