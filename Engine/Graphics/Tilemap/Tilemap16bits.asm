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
glb_map_idx           fdb   0
glb_old_camera_x_pos0 fdb   0
glb_old_camera_x_pos1 fdb   0
glb_old_camera_y_pos0 fdb   0
glb_old_camera_y_pos1 fdb   0
glb_map_width         fcb   0
glb_map_idx_init      equ   $FFFF ; force refresh if used in glb_old_camera...
glb_chunks            fdb   0,0   ; 4 chunks to be rendered on screen

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
	lda   glb_chunks
	bpl   @a
        ldx   glb_map_defchunk1_adr
	anda  #%01111111
	ldb   glb_map_defchunk1_pge
	bra   @b
@a      ldx   glb_map_defchunk0_adr
@b	ldb   glb_map_defchunk0_pge
	_SetCartPageB
	ldb   #0
	asra
	leau  d,x                                     ; u now points to start of chunk definition
	stu   map_idx

DrawTileInit
	lda   glb_camera_x_pos+1
	anda  #%00111000                              ; get tile position in chunk
	asra
	asra
	leay  a,y
	asra  
	suba  #8                                      ; chunk hold 8 tiles in a row
	nega
	sta   nb_tiles_x
	ldb   glb_camera_y_pos+1
	andb  #%01110000                              ; get tile position in chunk
	leay  b,y                                     ; y points to first tile to draw in chunk
	asrb  
	asrb  
	asrb  
	asrb  
	subb  #16                                     ; chunk hold 16 tiles in a col
	negb
	stb   nb_tiles_y

        lda   #10
        sta   dyn_y+1                                 ; init row counter        
        lda   glb_map_width
        suba  #19
	asla                                          ; 2 bytes index
        sta   dyn_w+1                                 ; we need to known how much tiles to move for next line    
        bra   DrawTile

DrawTileRow  
        dec   dyn_y+1

	; move tile position on screen to next line
        ldd   #(40*64)-(152/4-8/4)                    ; nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
        addd  glb_screen_location_1
        std   glb_screen_location_1
        ldd   #(40*64)-(152/4-8/4)
        addd  glb_screen_location_2
        std   glb_screen_location_2 

dyn_xi  lda   #18                                     ; nb horizontal tiles - 1 TODO ******************************** init new line for chunk 1 put nb_tile_x instead
        sta   dyn_x+1                                 ; init column counter
        bra   DrawTile
        
DrawTileColumn        
        dec   dyn_x+1

	; move tile position on screen to next column
        ldd   #8/4                                    ; nb of linear memory bytes between two tiles in a column
        addd  glb_screen_location_1
        std   glb_screen_location_1
        ldd   #8/4                                    ; nb of linear memory bytes between two tiles in a column
        addd  glb_screen_location_2
        std   glb_screen_location_2              

DrawTile
	ldu   #0                                      ; (dynamic)
map_idx equ   *-2
        ldd   ,u                                      ; load tile index in d (16 bits)
	beq   skip                                    ; skip empty tile (index 0)
        leau  2,u                                     ; move to next tile in chunk
        stu   map_idx
	
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
        
NextTile
dyn_x   lda   #0                                      ; (dynamic) current column index - Chunk 1 et 3 : init at nb_tiles_x - Chunk 2 et 4 : init at 18-nb_tiles_x
        bne   DrawTileColumn 

        ; end of tile line on current Chunk, move to next
        ldu   map_idx
	stu   glb_left_chunk_index
	ldu   glb_right_chunk_index
        stu   map_idx
	lda   #18
	suba  nb_tiles_x
	sta   dyn_x+1

dyn_w   ldb   #0                                      ; Chunk 1 bra load Chunk 2, Chunk 3 bra load Chunk 4
        ldu   map_idx
        leau  b,u
        stu   map_idx
dyn_y   lda   #0                                      ; (dynamic) current row index - Chunk 1 et 3 : init at nb_tiles_x - Chunk 2 et 4 : init at 18-nb_tiles_x
        lbne  DrawTileRow                             
        rts                                           ; Chunk 2 bra load Chunk 3, Chunk 4 bra end

skip    leau  2,u
        stu   map_idx
	bra   NextTile

glb_left_chunk_index fdb 0
glb_right_chunk_index fdb 0
nb_tiles_x fcb   0
nb_tiles_y fcb   0

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
