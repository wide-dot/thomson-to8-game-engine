        opt   c,ct

SOUND_CARD_PROTOTYPE equ 1 ; ancien port carte son SN79486
SN76489_JUMPER_LOW equ 1 ; jumper set (low address)
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.macro.asm"

MUSIC_NO_LOOP   EQU 0
MUSIC_LOOP      EQU 1

_MusicInit_objvgc MACRO
        lda   \1
        ldy   \3
        ldb   \2 ; should be placed just before the jsr
        jsr   ,x
        ENDM

_MusicInit_objymm MACRO
        lda   \1
        ldy   \3
        ldb   \2 ; should be placed just before the jsr
        jsr   ,x
        ENDM

_MusicFrame_objvgc MACRO
        ldb   #$80 ; should be placed just before the jsr
        jsr   ,x
        ENDM

_MusicFrame_objymm MACRO
        ldb   #$80 ; should be placed just before the jsr
        jsr   ,x
        ENDM

        org   $6100
        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct
        jsr   PalUpdateNow
        jsr   InitJoypads
        jsr   InitRNG

        ; disable ym soundtrack
        ldd   #$E7F4
        std   DYN.YM2413.A
        std   DYN.YM2413.D

        ; init music
        _MountObject ObjID_ymm01
        _MusicInit_objymm #0,#MUSIC_NO_LOOP,#0  ; initialize the YM2413 player 
        _MountObject ObjID_vgc01
        _MusicInit_objvgc #0,#MUSIC_NO_LOOP,#0  ; initialize the SN76489 vgm player with a vgc data stream

        ; init user irq
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        jsr   IrqOn 

        ; clear screen
        jsr   gfxlock.bufferSwap.do 

        ldx   #$0000
        jsr   ClearDataMem
        jsr   gfxlock.bufferSwap.do 

        ldx   #$0000
        jsr   ClearDataMem
        jsr   gfxlock.bufferSwap.do

        ; scroll setup
        _vscroll.setMap #ObjID_levelMap
        _vscroll.setMapHeight #38*16
        _vscroll.setTileset256 ObjID_levelTileA0,ObjID_levelTileB0
        _vscroll.setTileNb #61
        _vscroll.setBuffer #ObjID_scrollA,#ObjID_scrollB
        _vscroll.setCameraPos #0
        _vscroll.setCameraSpeed #$0100
        _vscroll.setViewport #0,#200

        ; init palette
        ldd   #Pal_bb
        std   Pal_current
        clr   PalRefresh
	    jsr   PalUpdateNow

        ; scroll to the first level
        ldd   #200
        std   scroll.goUntil.pos
        jsr   scroll.goUntil

        ; instanciate objects
        jsr   LoadObject_u
        lda   #ObjID_Player
        sta   id,u
        stu   main.playerOne

!       jsr   LoadObject_u
        beq   >
        lda   #ObjID_Bubble
        sta   id,u
        lda   main.object.count
        sta   subtype,u
        inca
        sta   main.object.count
        cmpa  #10
        bne   <
!

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   ReadJoypads
        _Collision_Do AABB_list_player,AABB_list_bubble
        jsr   RunObjects
        jsr   CheckSpritesRefresh     
        _gfxlock.on                                         
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites   
        _gfxlock.off
        _gfxlock.loop   
        tst   main.object.count
        beq   >
        jmp   LevelMainLoop
!       ldu   main.playerOne
        lda   routine,u
        cmpa  #1 ; Ground_routine
        bne   LevelMainLoop

        ; play full soundtrack
        ldd   #YM2413.A
        std   DYN.YM2413.A
        ldd   #YM2413.D
        std   DYN.YM2413.D

        ; scroll to the end level
        lda   #5
        sta   routine,u
        lda   render_flags,u
        ora   #render_overlay_mask        
        sta   render_flags,u

        ldd   #Level2
        std   room.level
        _vscroll.setCameraSpeed #$0100
        ldd   #400
        std   scroll.goUntil.pos
        jsr   scroll.goUntil

        ldu   main.playerOne
        lda   #6
        sta   routine,u
        lda   render_flags,u
        anda  #^render_overlay_mask        
        sta   render_flags,u

        jsr   scroll.doOneLoop
        jsr   scroll.doOneLoop

* ==============================================================================
* Outro Loop
* ==============================================================================

LevelEndLoop
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh     
        _gfxlock.on                                         
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites   
        _gfxlock.off
        _gfxlock.loop   
        jmp   LevelEndLoop

UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        _MountObject ObjID_ymm01
        _MusicFrame_objymm
        _MountObject ObjID_vgc01
        _MusicFrame_objvgc
        rts

scroll.goUntil.pos fdb 0
scroll.goUntil
@loop
        jsr   scroll.doOneLoop
        ldd   scroll.goUntil.pos
        subd  #10
        cmpd  vscroll.camera.y
        bhi   @loop

        ; fine scroll
        _vscroll.setCameraSpeed #$0040 

@loop
        jsr   scroll.doOneLoop
        ldd   scroll.goUntil.pos
        subd  #1
        cmpd  vscroll.camera.y
        bhi   @loop

        ; stop scroll
        _vscroll.setCameraSpeed #0 

        jsr   scroll.doOneLoop
        jsr   scroll.doOneLoop
        rts

scroll.doOneLoop
        jsr   ReadJoypads
        jsr   RunObjects
	    lda   #1
	    sta   <glb_force_sprite_refresh
        jsr   CheckSpritesRefresh  
        _gfxlock.on 
        jsr   EraseSprites                 
        jsr   vscroll.do
        jsr   vscroll.move
        jsr   UnsetDisplayPriority
        jsr   DrawSprites 
        _gfxlock.off
        _gfxlock.loop
        rts

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        
        INCLUDE "./game-mode/bonne-annee/ram.asm"        

main.object.count fcb   0
main.playerOne    fdb   0
DYN.YM2413.A      fdb   0
DYN.YM2413.D      fdb   0

* ==============================================================================
* Routines
* ==============================================================================

;-----------------------------------------------------------------
; room.checkSolid
; input  REG : [A] x pixel position of sensor on screen
; input  REG : [B] y pixel position of sensor on screen
; output REG : [CC Z] zero flag is set if no collision
;-----------------------------------------------------------------
; check a solid tile collision in screen coordinates
;-----------------------------------------------------------------

room.level fdb Level1
room.checkSolid
        ldx   room.level
        lsrb            ; (y_pos * 4 bytes per row) / tile height
        andb #%11111100
        abx
        lsra
        lsra
        tfr   a,b
        anda  #%00000111
        lsrb
        lsrb
        lsrb            ; x_pos / tile width / 8 bits per byte
        abx
        ldb   ,x
        ldx   #room.mask
        andb  a,x
        rts

room.mask
        fcb   %10000000
        fcb   %01000000
        fcb   %00100000
        fcb   %00010000
        fcb   %00001000
        fcb   %00000100
        fcb   %00000010
        fcb   %00000001

Level1
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111000111111111,%1111111110001111
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111000111111111,%1111111110001111
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111000111111111,%1111111110001111
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111111111111111,%1111111111111111
Level2
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011

        ;fdb   %1101010101100011,%0011000110111011
        ;fdb   %1101010101010100,%0010101010010011
        ;fdb   %1101010101010111,%0010101010010011
        ;fdb   %1101010101010100,%0010101010010011
        ;fdb   %1101110101010100,%0010101010010011
        ;fdb   %1101010101110111,%0011101110010011

        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011

        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100011111111111,%1111111111100011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1101111100111110,%0111110010110011
        fdb   %1100001100110010,%0000110010110011
        fdb   %1101111100101010,%0111110011111011
        fdb   %1101100000100110,%0110000011111011
        fdb   %1101111100111110,%0111110000110011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1100000000000000,%0000000000000011
        fdb   %1111111111111111,%1111111111111111

        ; utilities
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/palette/color/Pal_black.asm"
        INCLUDE "./engine/math/CalcSine.asm"
        INCLUDE "./engine/math/RandomNumber.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"

        ; joystick
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ObjectFallSync.asm"
        INCLUDE "./engine/object-management/ObjectMoveSync.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSpriteSync.asm"

        ; sound
        INCLUDE "./engine/irq/Irq.asm"	

        ; sprite
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

        ; collision
        INCLUDE "./engine/collision/collision.asm"

        ; scroll
        INCLUDE "./engine/graphics/tilemap/vscroll/vscroll.asm"

        ; music
        INCLUDE "./engine/sound/ym2413.asm"
        INCLUDE "./engine/sound/sn76489.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"
