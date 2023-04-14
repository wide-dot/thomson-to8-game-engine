;DO_NOT_WAIT_VBL equ 1
DEBUG   equ     1
SOUND_CARD_PROTOTYPE equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/objects/palette/fade/fade.equ"
        INCLUDE "./global/macro.asm"
        INCLUDE "./global/variables.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/objects/collision/terrainCollision.macro.asm"
        
map_width       equ 1152-24
viewport_width  equ 144
viewport_height equ 180

 ; checkpoint positions in 24px tiles
CHECKPOINT_00      equ 0
CHECKPOINT_01      equ 24

        org   $6100
        clr   NEXT_GAME_MODE
        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct
        jsr   InitJoypads
        _terrainCollision.init ObjID_collision

        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
	jsr   PalUpdateNow

; register animation data object
        ldb   #ObjID_animation
        jsr   AnimateMoveSyncRegister

; init score and lives at level 1
        ldd   #0
        std   score
        ldd   #2
        std   lives

; register map locations for scroll
        _MountObject ObjID_LevelInit
        jsr   ,x

        _MountObject ObjID_LevelInit_s
        jsr   ,x

        _MountObject ObjID_LevelWave
        jsr   ,x

        jsr   gfxlock.bufferSwap.do
        jsr   RunObjects

; init scroll
        jsr   InitScroll
        lda   #CHECKPOINT_00
        jsr   checkpoint.load

; play music
        _MountObject ObjID_ymm07
        _MusicInit_objymm #0,#MUSIC_LOOP,#0
        _MountObject ObjID_vgc07
        _MusicInit_objvgc #0,#MUSIC_LOOP,#0

; init user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn 

* ---------------------------------------------------------------------------
* MAIN GAME LOOP
* ---------------------------------------------------------------------------

LevelMainLoop
        jsr   ReadJoypads

        lda   checkpoint.state          ; load checkpoint requested ?
        beq   >
        ldu   #palettefade             ; yes check palette fade
        lda   routine,u                ; is palette fade over ?
        cmpa  #o_fade_routine_idle
        bne   >
        lda   #CHECKPOINT_01           ; yes load checkpoint
        jsr   checkpoint.load
!
        jsr   KTST
        bcc   >
        jsr   GETC
        cmpb  #$41 ; touche A
        bne   >
        jsr   Palette_FadeOut
        lda   #1
        sta   checkpoint.state
!
        jsr   LoopRun
        jmp   LevelMainLoop

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
        jsr   gfxlock.bufferSwap.check
	jsr   PalUpdateNow
        _MountObject ObjID_ymm07
        _MusicFrame_objymm
        _MountObject ObjID_vgc07
        _MusicFrame_objvgc
        rts


MusicCallbackYMBoss
        _MountObject ObjID_ymm07
        _MusicInit_objymm #2,#MUSIC_LOOP,#0
        rts

MusicCallbackSNBoss
        _MountObject ObjID_vgc07
        _MusicInit_objvgc #2,#MUSIC_LOOP,#0
        rts


* ---------------------------------------------------------------------------
*
* Foe shoots, returns x_vel or y_vel values from object stored in u
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
        pshs  y
        ldy   player1+x_pos
        bita  #$04
        bne   @xkilltrackingcontinue
        ldy   glb_camera_x_pos
        leay  70,y
@xkilltrackingcontinue
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
        ldy   player1+y_pos
        bita  #$04
        bne   @ykilltrackingcontinue
        ldy   #84                       ; Center screen y (168 / 2)
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



LoopRun
        jsr   Scroll
        jsr   ObjectWave
        _Collision_Do AABB_list_friend,AABB_list_ennemy
        _Collision_Do AABB_list_player,AABB_list_bonus
        _RunObject ObjID_fade,#palettefade
        _RunObject ObjID_Player1,#player1
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        _gfxlock.on
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawTiles
        jsr   DrawSprites
        _MountObject ObjID_Mask
        jsr   ,x
        _MountObject ObjID_hud
        jsr   ,x
        _gfxlock.off
        _gfxlock.loop

        lda  NEXT_GAME_MODE
        bne  Start_Music_Boss_Routine

        rts

Start_Music_Boss_Routine

        jsr   IrqOff
        _MountObject ObjID_ymm07
        _MusicInit_objymm #1,#MUSIC_NO_LOOP,#MusicCallbackYMBoss
        _MountObject ObjID_vgc07
        _MusicInit_objvgc #1,#MUSIC_NO_LOOP,#MusicCallbackSNBoss
        jsr   IrqOn

        clr   NEXT_GAME_MODE

        rts

* ---------------------------------------------------------------------------
* Collision_ClearLists
*
* ---------------------------------------------------------------------------

Collision_ClearLists
        ldd   #0
        std   AABB_list_friend
        std   AABB_list_friend+2
        std   AABB_list_ennemy
        std   AABB_list_ennemy+2
        std   AABB_list_player
        std   AABB_list_player+2
        std   AABB_list_bonus
        std   AABB_list_bonus+2
        rts

* ---------------------------------------------------------------------------
* Palette_FadeIn
*
* ---------------------------------------------------------------------------

Palette_FadeIn
        ldu   #palettefade
        clr   routine,u
        ldd   Pal_current
        std   o_fade_src,u
        ldd   #Pal_game
        std   o_fade_dst,u
        lda   #6
        sta   o_fade_wait,u
        ldd   #Palette_FadeCallback
        std   o_fade_callback,u
        rts

* ---------------------------------------------------------------------------
* Palette_FadeOut
*
* ---------------------------------------------------------------------------

Palette_FadeOut
        ldu   #palettefade
        clr   routine,u
        ldd   Pal_current
        std   o_fade_src,u
        ldd   #Pal_black
        std   o_fade_dst,u
        clr   o_fade_wait,u
        ldd   #Palette_FadeCallback
        std   o_fade_callback,u
        rts

* ---------------------------------------------------------------------------
* Palette_FadeCallback
*
* ---------------------------------------------------------------------------

Palette_FadeCallback
        rts

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        INCLUDE "./game-mode/07/ram_data.asm"

* ---------------------------------------------------------------------------
* CUSTOM routines
* ---------------------------------------------------------------------------
        INCLUDE "./global/checkpoint.asm"

* ---------------------------------------------------------------------------
* ENGINE routines
* ---------------------------------------------------------------------------

        ; common utilities
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
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
        INCLUDE "./engine/object-management/ObjectWave-subtype.asm"
        INCLUDE "./engine/object-management/ObjectDp.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"
        INCLUDE "./engine/graphics/animation/AnimateMoveSync.asm"

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; tilemap
        INCLUDE "./engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-even.asm"  

        ; collision
        INCLUDE "./engine/collision/collision.asm"
        INCLUDE "./engine/objects/collision/terrainCollision.main.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"
