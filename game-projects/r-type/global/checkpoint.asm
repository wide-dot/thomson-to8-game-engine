* ---------------------------------------------------------------------------
* Game_Checkpoint
*
* A blank palette is expected on entry (any color)
* A = final position in map (in 24px tiles)
* ---------------------------------------------------------------------------
checkpoint.state fcb 0

checkpoint.load
        clrb
        ldx   #checkpoint.positions
@loop   lda   b,x
        cmpa  scroll_tile_pos
        bhi   >
        incb
        bra   @loop
!       decb
        lda   b,x
        sta   @a
        sta   @b
        clr   checkpoint.state
;
        ; clear object data
        jsr   ObjectDp_Clear
        jsr   ManagedObjects_ClearAll
        jsr   InitStack
        jsr   DisplaySprite_ClearAll
        jsr   EraseSprites_ClearAll
        jsr   Collision_ClearLists
;
        ; clear the two screen buffers to black
        ldx   #$0000
        jsr   ClearDataMem
        _SwitchScreenBuffer
        ldx   #$0000
        jsr   ClearDataMem
        _SwitchScreenBuffer
;
        ; pre scroll to desired position
        lda   #0
@a equ *-1
        jsr   checkpoint.scroll
;
        ; init player one
        lda   #ObjID_Player1
        sta   player1+id
;
        ; fade in
        jsr   Palette_FadeIn
;
        ; set object wave position based on new camera position
        lda   #128
        ldb   #0
@b      equ   *-1
        mul
        std   gfxlock.frame.count
        std   gfxlock.frame.lastCount
        jmp   ObjectWave_Init

checkpoint.scroll
        sta   scroll_tile_pos          ; terrain collision tiles are 24px width
        asla                           ; rendered tiles are 12px width
        sta   @a
        ldb   scroll_vp_v_tiles
        aslb
        addb  scroll_vp_v_tiles        ; position is x * map vertical height * 3 bytes (page, addr)
        mul
        std   scroll_map_pos           ; position in map data
        lda   #0
@a      equ   *-1
        ldb   scroll_tile_width
        mul
        std   glb_camera_x_pos
        std   glb_camera_x_pos_old
        subd  #1
        std   buffer_x_pos
        std   buffer_x_pos+2

        lda   scroll_vp_h_tiles
        ldb   scroll_vp_x_pos
        std   @d
        lda   #0
        sta   scroll_vp_h_tiles      ; nb of horizontal tiles to render
        sta   scroll_tile_pos_offset
        sta   scroll_tile_pos_offset24
        lda   #8+144-4
        sta   scroll_vp_x_pos        ; offset to left screen
        lda   scroll_map_page_even
        sta   tile_buffer_page
        ldx   scroll_map_even
        stx   tile_buffer
@loop1
        lda   #3
        sta   @cpt
        inc   scroll_vp_h_tiles
@loop2
        lda   #1
        sta   glb_camera_move
        jsr   DrawTiles
        _SwitchScreenBuffer
        jsr   DrawTiles
        _SwitchScreenBuffer
        lda   scroll_vp_x_pos
        suba  #4
        sta   scroll_vp_x_pos
        dec   @cpt
        bne   @loop2
        cmpa  #4
        bne   @loop1
        ldd   #0
@d      equ   *-2
        sta   scroll_vp_h_tiles
        stb   scroll_vp_x_pos
        rts
@cpt    fcb   0
