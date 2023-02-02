        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"

map_width       equ 1680
viewport_width  equ 140
viewport_height equ 168

        org   $6100
        jsr   InitGlobals
        jsr   LoadAct
        jsr   InitJoypads

; init backgound for tile rendering
        jsr   LoadObject_u
        lda   #ObjID_LevelInit
        sta   id,u

        jsr   WaitVBL
        jsr   RunObjects ; print start frame on buffer 0, will also register map locations
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites

        jsr   WaitVBL
        jsr   RunObjects ; print start frame on buffer 1
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites

; init player one
        lda   #ObjID_Player1
        sta   player1+id

; init scroll
        jsr   InitScroll

; init user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

; play music !
        ldx   #Snd_S01
        jsr   PlayMusic

* ---------------------------------------------------------------------------
* MAIN GAME LOOP
* ---------------------------------------------------------------------------

LevelMainLoop
        jsr   WaitVBL
        jsr   ReadJoypads
        jsr   Scroll
        jsr   ObjectWave
        _RunObject ObjID_Player1,#player1
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawTiles
        jsr   DrawSprites
        _MountObject ObjID_Mask
        jsr   ,x
        bra   LevelMainLoop

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
	jsr   PalUpdateNow
        jmp   MusicFrame

* ---------------------------------------------------------------------------
*
* Foe shoots, returns x_vel or y_vel values from object stored in x
*
* Entry : a = direction (a will be destroyed during the process)
*             Bit 0-1
*             0 -> horizontal
*             1 -> 30% angle (from horizon)
*             2 -> 60% angle (from horizon)
*             3 -> vertical
*             Bit 2 : 
*             0 -> kill tracking OFF
*             1 -> kill tracking ON
* Rerturn : d = x_vel or y_vel (depending of the function called)
*
* ---------------------------------------------------------------------------

ReturnShootDirection_X
        pshs  y,a
        bita  #$04
        bne   @xkilltracking
        ldd   glb_camera_x_pos
        addd  #70
        tfr   d,y
        jmp   @xkilltrackingcontinue
@xkilltracking
        ldy   player1+x_pos
        ldd   glb_camera_x_pos
        addd  #70                       ; Center screen x (140 / 2)
        tfr   d,y
@xkilltrackingcontinue
        puls  a
        cmpy  x_pos,u
        blt   @xpos
        ldy   #Foeshoottable
        jmp   @xcontinue
@xpos
        ldy   #Foeshoottable+14
@xcontinue
        anda  #$03
        asla
        ldd   a,y
        puls  y,pc

ReturnShootDirection_Y
        pshs  y
        bita  #$04
        bne   @ykilltracking
        ldy   #84                       ; Center screen y (168 / 2)
        jmp   @ykilltrackingcontinue
@ykilltracking
        ldy   player1+y_pos
@ykilltrackingcontinue
        cmpy  y_pos,u
        blt   @ypos
        ldy   #Foeshoottable+6
        jmp   @ycontinue
@ypos
        ldy   #Foeshoottable+20
@ycontinue
        anda  #$03
        asla
        ldd   a,y
        puls  y,pc

Foeshoottable
        fdb $120
        fdb $100
        fdb $80
        fdb $0
        fdb $80
        fdb $100
        fdb $120
        fdb -$120
        fdb -$100
        fdb -$80
        fdb -$0
        fdb -$80
        fdb -$100
        fdb -$120

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/01/ram_data.asm"

* ---------------------------------------------------------------------------
* ENGINE routines
* ---------------------------------------------------------------------------
;DO_NOT_WAIT_VBL equ 1



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
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/ObjectWave.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"

        ; sprite
        INCLUDE "./engine/graphics/codec/DecRLE00.asm"
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; tilemap
        INCLUDE "./engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered.asm"  

        ; sound
        INCLUDE "./engine/sound/Svgm.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"