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
        INCLUDE "./global/scale.asm"
        INCLUDE "./global/object.const.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.macro.asm"

moveByScript.NEGXSTEP equ scale.XN1PX
moveByScript.POSXSTEP equ scale.XP1PX
moveByScript.NEGYSTEP equ scale.YN1PX
moveByScript.POSYSTEP equ scale.YP1PX

map_width       equ 720
viewport_width  equ 144
viewport_height equ 18

        org   $6100
        clr   NEXT_GAME_MODE
        jsr   InitGlobals
		jsr   InitDrawSprites
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
        jsr   moveByScript.register

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
        jsr   checkpoint.load

; play music
        _MountObject ObjID_ymm02
        _MusicInit_objymm #0,#MUSIC_LOOP,#0
        _MountObject ObjID_vgc02
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

        lda   mainloop.state            ; load checkpoint requested ?
        beq   >
        ldu   #palettefade             ; yes check palette fade
        lda   routine,u                ; is palette fade over ?
        cmpa  #o_fade_routine_idle
        bne   >
        jsr   checkpoint.load
!
        jsr   LoopRun
        jmp   LevelMainLoop

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------

UserIRQ
        jsr   gfxlock.bufferSwap.check
	jsr   PalUpdateNow
        _MountObject ObjID_ymm02
        _MusicFrame_objymm
        _MountObject ObjID_vgc02
        _MusicFrame_objvgc
        rts


MusicCallbackYMBoss
        _MountObject ObjID_ymm02
        _MusicInit_objymm #2,#MUSIC_LOOP,#0
        rts

MusicCallbackSNBoss
        _MountObject ObjID_vgc02
        _MusicInit_objvgc #2,#MUSIC_LOOP,#0
        rts

LoopRun
        jsr   Scroll
        jsr   ObjectWave

        _Collision_Do AABB_list_friend,AABB_list_ennemy

        _Collision_Do AABB_list_player,AABB_list_bonus
        _Collision_Do AABB_list_player,AABB_list_foefire
        _Collision_Do AABB_list_player,AABB_list_ennemy

        _Collision_Do AABB_list_forcepod,AABB_list_foefire
        _Collision_Do AABB_list_forcepod,AABB_list_ennemy

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
        _MountObject ObjID_ymm02
        _MusicInit_objymm #1,#MUSIC_NO_LOOP,#MusicCallbackYMBoss
        _MountObject ObjID_vgc02
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
        ldy   #AABB_lists
        ldx   #AABB_lists.nb
!       std   ,y++
        leax  -1,x
        bne   <
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
*  Checkpoint positions in 24px tiles
* ---------------------------------------------------------------------------
checkpoint.positions
        fcb 0
        fcb -1

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        INCLUDE "./game-mode/08/ram_data.asm"

* ---------------------------------------------------------------------------
* CUSTOM routines
* ---------------------------------------------------------------------------
        INCLUDE "./global/checkpoint.asm"
        INCLUDE "./global/moveXPos8.8.asm"
        INCLUDE "./global/moveYPos8.8.asm"
        INCLUDE "./global/projectile.asm"
        INCLUDE "./global/setDirectionTo.asm"

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
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"
        INCLUDE "./engine/graphics/animation/moveByScript.asm"

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; tilemap
        INCLUDE "./engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-even.asm"  

        ; collision
        INCLUDE "./engine/collision/collision.asm"
        INCLUDE "./engine/objects/collision/terrainCollision.main.asm"

        ; random numbers
        INCLUDE "./engine/math/RandomNumber.asm"

        ; music and sound fx
        INCLUDE "./engine/sound/soundFX.data.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.const.asm"
        INCLUDE "./engine/objects/sound/ymm/ymm.data.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"
