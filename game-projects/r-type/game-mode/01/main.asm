DO_NOT_WAIT_VBL equ 1

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/objects/palette/fade/fade.equ"

map_width       equ 1792
viewport_width  equ 140
viewport_height equ 168

 ; A = tile position in x, B = nb of pre-scrolled tiles
CHECKPOINT_00 equ $0202
CHECKPOINT_01 equ $3802

        org   $6100
        sta   ,-u
        pshu  a
        jsr   InitGlobals
        jsr   LoadAct
        jsr   InitJoypads

; register map locations for scroll
        _MountObject ObjID_LevelInit
        jsr   ,x

        jsr   WaitVBL
        jsr   RunObjects

; init scroll
        jsr   InitScroll

; load checkpoints
        ldd   #CHECKPOINT_00
        jsr   Game_LoadCheckpoint_x

; init user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

; play music
        ldx   #Snd_S01
        jsr   PlayMusic

* ---------------------------------------------------------------------------
* MAIN GAME LOOP
* ---------------------------------------------------------------------------

LevelMainLoop
        jsr   WaitVBL
        jsr   ReadJoypads

        lda   checkpoint_load          ; load checkpoint requested ?
        beq   >
        ldu   #palettefade             ; yes check palette fade
        lda   routine,u                ; is palette fade over ?
        cmpa  #o_fade_routine_idle
        bne   >
        ldd   #CHECKPOINT_01           ; yes load checkpoint
        jsr   Game_LoadCheckpoint_x
!
        jsr   KTST
        bcc   >
        jsr   GETC
        cmpb  #$41 ; touche A
        bne   >
        jsr   Palette_FadeOut
        lda   #1
        sta   checkpoint_load
!
        jsr   Scroll
        jsr   ObjectWave
        _Collision_Do AABB_list_friend,AABB_list_ennemy
        _RunObject ObjID_fade,#palettefade
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
* Game_Checkpoint_x
*
* A blank palette is expected on entry (any color)
* D = position in map (A = x | B = y tile number starting from 0)
* ---------------------------------------------------------------------------
checkpoint_load fcb 0

Game_LoadCheckpoint_x
        std   @d
        clr   checkpoint_load
;
        ; clear object data
        jsr   ObjectDp_Clear
        jsr   ManagedObjects_ClearAll
        jsr   DisplaySprite_ClearAll
        jsr   Collision_ClearLists
;
        ; clear the two screen buffers to black
        ldx   #0
        jsr   ClearDataMem
        _SwitchScreenBuffer
        ldx   #0
        jsr   ClearDataMem
        _SwitchScreenBuffer
;
        ; pre scroll to desired position
        ldd   #0
@d equ *-2
        jsr   Scroll_PreScrollTo
;

        ; init player one
        lda   #ObjID_Player1
        sta   player1+id

        ; fade in
        jsr   Palette_FadeIn

        ; set object wave position based on new camera position
        jmp   ObjectWave_Init

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
        lda   #0
        sta   o_fade_wait,u
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

        INCLUDE "./game-mode/01/ram_data.asm"

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
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/ObjectWave.asm"
        INCLUDE "./engine/object-management/ObjectDp.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; tilemap
        INCLUDE "./engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered.asm"  

        ; sound
        INCLUDE "./engine/sound/Svgm.asm"

        ; collision
        INCLUDE "./engine/collision/collision.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"