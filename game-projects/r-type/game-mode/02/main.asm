
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        org   $6100
        jsr   InitGlobals
        jsr   LoadAct
        jsr   InitJoypads

        ldd   #48
        std   glb_camera_x_offset
        ldd   #28
        std   glb_camera_y_offset

        jsr   LoadObject_u
        lda   #ObjID_LevelInit
        sta   id,u

 ; print start frame on buffer 0 - todo replace with simple draw routine
        jsr   WaitVBL
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites

 ; print start frame on buffer 1 - todo replace with simple draw routine
        jsr   WaitVBL
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites

        jsr   LoadObject_u
        lda   #ObjID_Player1
        sta   id,u

        ldx   #Tls_lvl02
        stx   tile_buffer

LevelMainLoop
        jsr   WaitVBL
        jsr   PalUpdateNow
        jsr   ReadJoypads
        jsr   Scroll
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawBufferedTile
        jsr   DrawSprites
        _MountObject ObjID_Mask
        jsr   ,x
        bra   LevelMainLoop

Scroll
        clr   glb_camera_move
        clr   glb_camera_update
        ldb   scroll_frame
        cmpb  #1
        bgt   >
        lda   #1
        sta   <glb_force_sprite_refresh
        sta   glb_camera_move
!       incb
        cmpb  #4
        bne   >
        ldb   #0
        lda   scroll_idx
        beq   @skip
        ldx   glb_camera_x_pos
        leax  2,x
        cmpx  #1008-128+2
        beq   >
        com   glb_camera_update
        stx   glb_camera_x_pos
@skip   coma
        sta   scroll_idx
        asla
        ldx   #scroll_map
        ldx   a,x
        stx   tile_buffer
!       stb   scroll_frame
        rts

scroll_frame
        fcb   0
scroll_idx
        fcb   0
        fdb   Tls_lvl02_s
scroll_map
        fdb   Tls_lvl02
glb_camera_update
        fdb   0

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/02/ram_data.asm"

        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        ;INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"

        ; joystick
        INCLUDE "./engine/joypad/InitJoypads.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"

        ; object management
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/ObjectMove.asm"

        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"

        ; sprite
        INCLUDE "./engine/graphics/Codec/DecRLE00.asm"
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"  

        ; tilemap
        INCLUDE "./engine/graphics/tilemap/TilemapBuffer_alt.asm"  

        align 256
Tls_lvl02
        INCLUDEGEN Tls_lvl02 buffer
        ; pre-rendered tilemap buffer
        ; free    (byte) reserved for future use - can be used for layer information
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile in the map]

        align 256
Tls_lvl02_s
        INCLUDEGEN Tls_lvl02_s buffer
        ; pre-rendered tilemap buffer
        ; free    (byte) reserved for future use - can be used for layer information
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile in the map]
