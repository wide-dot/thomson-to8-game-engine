* ---------------------------------------------------------------------------
* Tilemaps - Subroutines to draw multiple backgrounds of tiles
*
* input REG : none
*
* ---------------------------------------------------------------------------

        INCLUDE "./Engine/Graphics/Tilemap/DataTypes/map16bits.equ"

; data structure for current loaded map
; -------------------------------------
glb_map_pge           fcb   0
glb_map_adr           fdb   0
glb_map_chunk_pge     fcb   0 ; map data to chunk tiles (8x8 tiles group)
glb_map_chunk_adr     fdb   0 ; map data to chunk tiles (8x8 tiles group)
glb_map_defchunk0_pge fcb   0 ; chunk data to tiles (8x16 px)
glb_map_defchunk0_adr fdb   0 ; chunk data to tiles (8x16 px)
glb_map_defchunk1_pge fcb   0 ; chunk data to tiles (8x16 px)
glb_map_defchunk1_adr fdb   0 ; chunk data to tiles (8x16 px)
glb_map_tiles_pge     fcb   0 ; tile index
glb_map_tiles_adr     fdb   0 ; tile index
glb_old_camera_x_pos0 fdb   0
glb_old_camera_x_pos1 fdb   0
glb_old_camera_y_pos0 fdb   0
glb_old_camera_y_pos1 fdb   0
glb_map_width         fcb   0
glb_camera_init       equ   $FFFF ; force refresh if used in glb_old_camera...
glb_chunks            fdb   0,0   ; 4 chunks to be rendered on screen

map_idx1              fdb   0
map_idx2              fdb   0
map_idx3              fdb   0
map_idx4              fdb   0
map_idx1_pge          fcb   0
map_idx2_pge          fcb   0
map_idx3_pge          fcb   0
map_idx4_pge          fcb   0
nb_tiles_x            fcb   0
nb_tiles_xr           fcb   0
nb_tiles_y            fcb   0
nb_tiles_yr           fcb   0

DrawTilemaps
        ; check if a map was registred
	; and mount the map
	lda   glb_map_pge
	bne   @a
	rts
@a
        _SetCartPageA        
        ldu   glb_map_adr

	; check if camera has moved
	; and if tiles need an update
        tst   glb_Cur_Wrk_Screen_Id
        bne   @b1
@b0     ldx   glb_camera_x_pos
	cmpx  glb_old_camera_x_pos0
	bne   @endx0
	ldd   glb_camera_y_pos
	cmpd  glb_old_camera_y_pos0
	bne   @endy0
        rts
@b1     ldx   glb_camera_x_pos
	cmpx  glb_old_camera_x_pos1
	bne   @endx1
	ldd   glb_camera_y_pos
	cmpd  glb_old_camera_y_pos1
	bne   @endy1
        rts
@endx0 	ldd   glb_camera_y_pos
@endy0	std   glb_old_camera_y_pos0
	stx   glb_old_camera_x_pos0
	bra   @end
@endx1 	ldd   glb_camera_y_pos
@endy1	std   glb_old_camera_y_pos1
	stx   glb_old_camera_x_pos1
@end

	; screen will be refreshed
	lda   #1
	sta   glb_force_sprite_refresh

	; process first tile position on screen
	lda   glb_camera_x_pos+1
	anda  #%00000111                              ; mask for 8px tile in width
	nega
	ldb   glb_camera_y_pos+1
	andb  #%00001111                              ; mask for 16px tile in height
	negb
	addd  #$3820                                  ; hardcoded position on screen x=8, y=20
        jsr   TLM_XYToAddress

        ; Transform a camera position into an index to map (made of 64x128px chunks)
        ldd   glb_camera_x_pos
        _lsrd
        _lsrd
        _lsrd
        _lsrd 
        _lsrd
        _lsrd                                                 
        std   @dyn1+1
        ldd   glb_camera_y_pos
        _lsrd
        _lsrd
        _lsrd
        _lsrd 
        _lsrd
        _lsrd   
        ldx   layer_mul_ref,u
	ldd   d,x                                     ; use precalculated values to get y in map (16 bits mul)
@dyn1   addd  #0                                      ; (dynamic) add x position to index 
        addd  glb_map_chunk_adr                       ; (dynamic) add map data address to index
        
	; get the 4 chunk id
	tfr   d,x
        lda   glb_map_chunk_pge
        _SetCartPageA
    	ldd   ,x                                     
	std   glb_chunks                              ; get the chunk 1 (up, left) and 2 (up, right)
	lda   #0
	ldb   glb_map_width
	ldd   d,x
	std   glb_chunks+2                            ; get the chunk 3 (down, left) and 3 (down, right)

	; load chunk
	lda   glb_chunks+3
	bpl   @a
        ldx   glb_map_defchunk1_adr
	anda  #%01111111
	ldb   glb_map_defchunk1_pge
	bra   @b
@a      ldx   glb_map_defchunk0_adr
@b	ldb   glb_map_defchunk0_pge
	stb   map_idx4_pge
	ldb   #0
	asra
	leau  d,x
	stu   map_idx4

	lda   glb_chunks+2
	bpl   @a
        ldx   glb_map_defchunk1_adr
	anda  #%01111111
	ldb   glb_map_defchunk1_pge
	bra   @b
@a      ldx   glb_map_defchunk0_adr
@b	ldb   glb_map_defchunk0_pge
	stb   map_idx3_pge
	ldb   #0
	asra
	leau  d,x
	stu   map_idx3

	lda   glb_chunks+1
	bpl   @a
        ldx   glb_map_defchunk1_adr
	anda  #%01111111
	ldb   glb_map_defchunk1_pge
	bra   @b
@a      ldx   glb_map_defchunk0_adr
@b	ldb   glb_map_defchunk0_pge
	stb   map_idx2_pge
	ldb   #0
	asra
	leau  d,x
	stu   map_idx2

	lda   glb_chunks
	bpl   @a
        ldx   glb_map_defchunk1_adr
	anda  #%01111111
	ldb   glb_map_defchunk1_pge
	bra   @b
@a      ldx   glb_map_defchunk0_adr
@b	ldb   glb_map_defchunk0_pge
        stb   map_idx1_pge
	_SetCartPageB
	ldb   #0
	asra
	leau  d,x
	stu   map_idx1
	stu   map_idx

DrawTileInit
	lda   glb_camera_x_pos+1
	anda  #%00111000                              ; get tile position in chunk
	asra
	asra
	leau  a,u
	asra  
	suba  #8                                      ; chunk hold 8 tiles in a row
	nega
	sta   nb_tiles_x
	sta   dyn_x+1                                 ; init left chunk process
	lda   #18
	suba  nb_tiles_x
	sta   nb_tiles_xr                             ; init right chunk process

	ldb   glb_camera_y_pos+1
	andb  #%01110000                              ; get tile position in chunk
	leau  b,u                                     ; u points to first tile to draw in chunk
	asrb  
	asrb  
	asrb  
	asrb  
	subb  #16                                     ; chunk hold 16 tiles in a col
	negb
	stb   nb_tiles_y
	stb   dyn_y+1                                 ; init upper chunks process
	lda   #10
        sta   dyn_y+1                                 ; init row counter        
	suba  nb_tiles_y
	sta   nb_tiles_yr                             ; init lower chunks process

        ; Main loop for drawing tiles
        ; ---------------------------
DrawTile
        ldd   #0                                      ; load tile index in d (16 bits)
map_idx equ   *-2
	lbeq   DrawTileNextColumn                     ; skip empty tile (index 0)

        std   @dyn+1                                  ; multiply tile index by 3 to load tile page and addr
        _lsld
@dyn    addd  #0                                      ; (dynamic)
        ldu   glb_map_tiles_adr
        leau  d,u
	_GetCartPageA                                 ; backup Chunk index page 
	sta   @dyn_pg+1
	lda   glb_map_tiles_pge
        _SetCartPageA                                 ; set Tile index page
        pulu  a,x                                     ; a: tile routine page, x: tile routine address
        ldy   #glb_screen_location_2     
        _SetCartPageA                                 ; set data page for sub routine to call
        jsr   [,x]                                    ; draw compilated tile
@dyn_pg lda   #$00
        _SetCartPageA                                 ; restore Chunk index page

        ; Check end of line of current Chunk
        ; ----------------------------------        
dyn_x   lda   #0                                      ; (dynamic) current column index - Chunk 1 et 3 : init at nb_tiles_x - Chunk 2 et 4 : init at nb_tiles_xr
        bne   DrawTileNextColumn 
@alt_x  lda   #0
	bne   EndOfLine
	lda   nb_tiles_xr
	sta   dyn_x+1
	com   @alt_x+1
@alt_y  lda   #0
        bne   @downright
@upright
        ldu   map_idx2
	ldb   map_idx2_pge
	bra   @upstart
@downright
        ldu   map_idx4
	ldb   map_idx4_pge
@upstart
	_SetCartPageB
        lda   #8                                      ; set current line in chunk
	ldb   nb_tiles_y
	subb  dyn_y+1
	mul
	leau  d,u
        stu   map_idx
	bra   DrawTileNextColumn_b
        ;
DrawTileNextColumn        
        dec   dyn_x+1
        ldd   map_idx
        addd  #2
        std   map_idx
        ;
DrawTileNextColumn_b
	; move tile position on screen to next column
        ldd   #8/4                                    ; nb of linear memory bytes between two tiles in a column
        addd  glb_screen_location_1
        std   glb_screen_location_1
        ldd   #8/4                                    ; nb of linear memory bytes between two tiles in a column
        addd  glb_screen_location_2
        std   glb_screen_location_2  
	jmp   DrawTile
        ;
        ; Check end of line of current Chunk
        ; ----------------------------------
EndOfLine                                             ; end of line on right chunk, do we need to go to bottom chunk or exit ?
dyn_y   lda   #0                                      ; (dynamic) current row index - Chunk 1 et 2 : init at nb_tiles_y - Chunk 3 et 4 : init at nb_tiles_yr
        bne   @chunks
	lda   nb_tiles_yr
	sta   dyn_y+1
	com   @alt_y+1
	bne   @downleft
	rts                                           ; end of the 4 chunks !
@chunks
        lda   @alt_y+1
        bne   @downleft
@upleft
        ldu   map_idx1
	ldb   map_idx1_pge
	bra   @downstart
@downleft
        ldu   map_idx3
	ldb   map_idx3_pge
@downstart
	lda   nb_tiles_x
	sta   dyn_x+1
	_SetCartPageB
        lda   #8                                      ; set current line in chunk
	ldb   nb_tiles_yr
	subb  dyn_y+1
	mul
	leau  d,u
	stu   map_idx
	bra   DrawTileNextRow
@downchunks

DrawTileNextRow
        dec   dyn_y+1
        ldd   map_idx
        addd  #2
        std   map_idx

	; move tile position on screen to next line
        ldd   #(40*64)-(152/4-8/4)                    ; nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
        addd  glb_screen_location_1
        std   glb_screen_location_1
        ldd   #(40*64)-(152/4-8/4)
        addd  glb_screen_location_2
        std   glb_screen_location_2 
	jmp   DrawTile

********************************************************************************
* x_pixel and y_pixel coordinate system
* x coordinates:
*    - off-screen left 00-2F (0-47)
*    - on screen 30-CF (48-207)
*    - off-screen right D0-FF (208-255)
*
* y coordinates:
*    - off-screen top 00-1B (0-27)
*    - on screen 1C-E3 (28-227)
*    - off-screen bottom E4-FF (228-255)
********************************************************************************

TLM_XYToAddress
        suba  #$30
        bcc   TLM_XYToAddressPositive
        suba  #$60                          ; get x position one line up, skipping (160-255)
        decb
TLM_XYToAddressPositive        
        subb  #$1C                          ; TODO same thing as x for negative case
        lsra                                ; x=x/2, sprites moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB enterlace  
        bcs   TLM_XYToAddressRAM2First      ; Branch if write must begin in RAM2 first
TLM_XYToAddressRAM1First
        sta   TLM_dyn1+2
        lda   #$28                          ; 40 bytes per line in RAMA or RAMB
        mul
TLM_dyn1        
        addd  #$C000                        ; (dynamic)
        std   glb_screen_location_2
        subd  #$2000
        std   glb_screen_location_1     
        rts
TLM_XYToAddressRAM2First
        sta   TLM_dyn2+2
        lda   #$28                          ; 40 bytes per line in RAMA or RAMB
        mul
TLM_dyn2        
        addd  #$A000                        ; (dynamic)
        std   glb_screen_location_2
        addd  #$2001
        std   glb_screen_location_1
        rts
