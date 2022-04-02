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

; variables
h_tl                  fcb   0 ; nb of full sized (middle) horizontal chunks
v_tl                  fcb   0 ; nb of full sized (middle) vertical chunks
c_h_tl                fcb   0 ; variable that stores current left, middle or right width of chunks
l_h_tl                fcb   0
r_h_tl                fcb   0
c_v_tl                fcb   0 ; variable that stores current up, middle or bottom height of chunks
u_v_tl                fcb   0
b_v_tl                fcb   0
c_h_tl_bck            fcb   0 ; backup value of horizontal width of chunks, used to process lines
cur_c	              fcb   0 ; current chunk id

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

	; Force sprite to be refreshed when background changes
	; ----------------------------------------------------
	lda   #1
	sta   glb_force_sprite_refresh

	; compute top left tile position on screen
	; ----------------------------------------
	lda   glb_camera_x_pos+1
	anda  #%00000111                              ; mask for 8px tile in width
	nega
	ldb   glb_camera_y_pos+1
	andb  #%00001111                              ; mask for 16px tile in height
	negb
	addd  #$3422                                  ; hardcoded position on screen x=4, y=6
        jsr   TLM_XYToAddress

        ; Transform a camera position into an index to map (made of 64x128px chunks)
	; --------------------------------------------------------------------------
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
	andb  #%11111110                              ; faster than _lsrd (last shift for 128px map) and lsld (2 bytes index in mul ref)
        leax  layer_mul_ref,u
	ldd   d,x                                     ; use precalculated values to get y in map (16 bits mul)
@dyn1   addd  #0                                      ; (dynamic) add x position to index 
        addd  glb_map_chunk_adr                       ; (dynamic) add map data address to index
        
	; Compute tile offset in chunks
	; -----------------------------
	lda   glb_camera_x_pos+1
	anda  #%00111000
	asra
	asra
	leau  a,u                                     ; save left chunk horizontal tile offset
	asra  
	suba  #8                                      ; chunk hold 8 tiles in a row
	nega
	sta   l_h_tl                                  ; save nb of tiles in left chunks
	lda   #20                                     ; a row on screen is made of 20 horizontal tiles
	suba  l_h_tl
	tfr   a,b
	asrb
	asrb
	asrb
	stb   h_tl                                    ; nb of full sized (middle) horizontal chunks
	anda  #%00000111                              ; skip middle chunks that are 8 tiles wide
	sta   r_h_tl                                  ; save nb of horizontal tiles in right chunks



	ldb   glb_camera_y_pos+1
	andb  #%01110000                              ; get tile position in chunk
	leau  b,u                                     ; u points to first tile to draw in top left chunk
	stu   map_idx
	asrb  
	asrb  
	asrb  
	asrb  
	subb  #8                                      ; chunk hold 8 tiles in a col
	negb
	stb   u_v_tl                                  ; save nb of vertical tiles in top chunks
	stb   cpt_cy+1                                ; init nb of row of tiles to process on upper Chunks
	lda   #13                                     ; a col on screen is made of 13 vertical tiles
	suba  u_v_tl
	tfr   a,b
	asrb
	asrb
	asrb
	stb   v_tl                                    ; nb of full sized (middle) vertical chunks
	anda  #%00000111                              ; skip middle chunks that are 8 tiles high
	sta   b_v_tl                                  ; save nb of vertical tiles in bottom chunks

	; load the 12 chunks
	; ------------------
	tfr   d,x
        lda   glb_map_chunk_pge
        _SetCartPageA

	ldb   u_v_tl                   ; first line begin with upper vertical chunk height
	stb   c_v_tl
@vloop
	stx   @start_pos
	lda   l_h_tl
	jsr   LoadChunk
@hloop
	lda   #8
	jsr   LoadChunk
	lda   h_tl                     ; there is at least one middle horizontal chunk
	deca
	sta   h_tl
	bne   @hloop
	lda   r_h_tl
	jsr   LoadChunk
	ldb   glb_map_width
	ldx   #0
@start_pos equ *-2
	abx
	ldb   v_tl                     ; are we in middle or bottom chunk ?
	bne   @a
	bmi   @end
	lda   #8                       ; middle
	sta   c_v_tl
	bra   @b
@a	lda   b_v_tl                   ; bottom
	sta   c_v_tl
@b	decb
	stb   v_tl
	bra   @vloop
@end    rts

LoadChunk
        sta   c_h_tl
	lda   ,x+
	bpl   @a
        ldy   glb_map_defchunk1_adr
	anda  #%01111111
	ldb   glb_map_defchunk1_pge
	bra   @b
@a      ldu   glb_map_defchunk0_adr
@b	ldb   glb_map_defchunk0_pge
	stb   chk_idx_pge
	ldb   #0
	_asrd
	leau  d,u
	stu   chk_cur_idx

DrawChunk
        lda   #0
chk_idx_pge equ *-1
	_SetCartPageA                                 ; set chunk definition page
	ldu   #0                                      ; load position in chunk
chk_cur_idx equ *-2
	lda   c_h_tl
	sta   c_h_tl_bck

DrawTile
        ldd   ,u++                                    ; load tile index in d (16 bits)
	beq   NextCol                                   
@draw
        std   @dyn+1                                  ; multiply tile index by 3 to load tile page and addr
        _lsld
@dyn    addd  #0                                      ; (dynamic)
	stu   @restore_u
        ldu   glb_map_tiles_adr
        leau  d,u
	lda   glb_map_tiles_pge
        _SetCartPageA                                 ; set tile index page
        pulu  a,x                                     ; a: tile routine page, x: tile routine address
        ldy   #glb_screen_location_2     
        _SetCartPageA                                 ; set compilated tile data page
        jsr   ,x                                      ; draw compilated tile
        lda   chk_idx_pge
        _SetCartPageA                                 ; restore chunk index page
	ldu   #0
@restore_u equ *-2

NextCol
        dec   cur_tx                                  ; check remaining tiles in this row
        beq   EndOfLine
	; move tile position on screen to next column
        ldd   #8/4                                    ; nb of linear memory bytes between two tiles in a column
        addd  glb_screen_location_1
        std   glb_screen_location_1
        ldd   #8/4                                    ; nb of linear memory bytes between two tiles in a column
        addd  glb_screen_location_2
        std   glb_screen_location_2  
	bra   DrawTile

        ; Check end of line of current Chunk
        ; ----------------------------------
EndOfLine                                             ; end of line on right chunk, do we need to go to bottom chunk or exit ?
	ldd   #20                                     ; init number of tiles per row
	stb   cpt_h
	sta   cur_c                                   ; reset chunk id

DrawTileNextRow
        dec   c_v_tl
	test ici

	; move tile position on screen to next line
        ldd   #(40*16)-(160/4-8/4)                    ; nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
        addd  glb_screen_location_1
        std   glb_screen_location_1
        ldd   #(40*16)-(160/4-8/4)
        addd  glb_screen_location_2
        std   glb_screen_location_2 
	jmp   DrawTile

	; restore map of chunks page
        lda   glb_map_chunk_pge
        _SetCartPageA
	rts

cpt_x fcb 0

********************************************************************************
* Load Chunk data
********************************************************************************

LoadChunk
        pshs  b
	bpl   @a
        ldy   glb_map_defchunk1_adr
	anda  #%01111111
	ldb   glb_map_defchunk1_pge
	bra   @b
@a      ldy   glb_map_defchunk0_adr
@b	ldb   glb_map_defchunk0_pge
	stb   ,u+
	ldb   #0
	_asrd
	leay  d,y
	sty   ,u++
	puls  b,pc

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
