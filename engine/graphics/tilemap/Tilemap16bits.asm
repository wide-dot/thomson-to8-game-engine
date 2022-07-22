* ---------------------------------------------------------------------------
* Tilemaps - Subroutines to draw multiple backgrounds of tiles
*
* input REG : none
*
* ---------------------------------------------------------------------------

        INCLUDE "./engine/graphics/tilemap/data-types/map-16bits.equ"

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
glb_map_width         fcb   0
glb_camera_init       equ   $FFFF ; force refresh if used in glb_old_camera...

; variables
h_tl                  fcb   0 ; nb of full sized (middle) horizontal chunks
h_tl_bck              fcb   0
v_tl                  fcb   0 ; nb of full sized (middle) vertical chunks
c_h_tl                fcb   0 ; variable that stores current left, middle or right width of chunks
l_h_tl                fcb   0
r_h_tl                fcb   0
c_v_tl                fcb   0 ; variable that stores current up, middle or bottom height of chunks
u_v_tl                fcb   0
b_v_tl                fcb   0
c_h_tl_bck            fcb   0 ; backup value of horizontal width of chunks
c_v_tl_bck            fcb   0 ; backup value of vertical height of chunks
cur_c	              fcb   0 ; current chunk id
x_off                 fdb   0 ; position in top left chunk
y_off                 fdb   0 ; position in top left chunk
cur_y_off             fdb   0 ; current y offset

DrawTilemaps
        ; check if a map was registred
	; and mount the map
	lda   glb_map_pge
	bne   @a
	rts
@a
        _SetCartPageA        
        ldu   glb_map_adr

	lda   glb_camera_move
	bne   @a
	rts
@a

	; compute top left tile position on screen
	; position is rounder to 2 px
	; horizontally beacuse of 2px per byte
	; vertically beacuse of interlacing
	; ----------------------------------------
	lda   <glb_camera_x_pos+1
	anda  #%00000110                    ; mask for 8px tile in width
	nega
	adda  #12                           ; on screen position of camera (full screen: 4)

	ldb   <glb_camera_y_pos+1
	andb  #%00001110                    ; mask for 16px tile in height
	negb
	addb  #20                           ; on screen position of camera (full screen: 6)

        lsra                                ; x=x/2, sprites moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB interlace  
        bcs   @RAM2First                    ; Branch if write must begin in RAM2 first
@RAM1First
        sta   @dyn1
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
	addd  #$C000                        ; (dynamic)
@dyn1   equ   *-1        
        std   <glb_screen_location_2
        subd  #$2000
        std   <glb_screen_location_1     
        bra   @end
@RAM2First
        sta   @dyn2
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
	addd  #$A000                        ; (dynamic)
@dyn2   equ   *-1        
        std   <glb_screen_location_2
        addd  #$2001
        std   <glb_screen_location_1
@end

        ; Transform a camera position into an index to map (made of 64x128px chunks)
	; --------------------------------------------------------------------------
        ldd   <glb_camera_x_pos
        _lsrd
        _lsrd
        _lsrd
        _lsrd 
        _lsrd
        _lsrd                                                 
        std   @dyn1+1
        ldd   <glb_camera_y_pos
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
	tfr   d,x
        
	; Compute tile offset in chunks
	; -----------------------------

	ldb   #18                                     ; nb of tile in screen width (fullscreen 20)
	lda   <glb_camera_x_pos+1
	anda  #%00000111
	bne   @skip
	decb
@skip   stb   scr_tile_x

	ldb   #11                                     ; nb of tile in screen height (fullscreen 13)
	lda   <glb_camera_y_pos+1
	anda  #%00001111
	bne   @skip
	decb
@skip   stb   scr_tile_y


	lda   <glb_camera_x_pos+1
	anda  #%00111000
	asra
	asra
	sta   x_off+1                                 ; horizontal offset to first tile in top left chunk
	asra  
	suba  #8                                      ; chunk hold 8 tiles in a row
	nega
	sta   l_h_tl                                  ; save nb of tiles in left chunks
	lda   #0                                      ; (dynamic) nb of tile in screen width 
scr_tile_x equ *-1
	suba  l_h_tl
	tfr   a,b
	asrb
	asrb
	asrb
	stb   h_tl_bck                                ; nb of full sized (middle) horizontal chunks
	anda  #%00000111                              ; skip middle chunks that are 8 tiles wide
	sta   r_h_tl                                  ; save nb of horizontal tiles in right chunks

	ldb   <glb_camera_y_pos+1
	andb  #%01110000                              ; get tile position in chunk
	stb   y_off+1                                 ; vertical offset to first tile in top left chunk
	asrb  
	asrb  
	asrb  
	asrb  
	subb  #8                                      ; chunk hold 8 tiles in a col
	negb
	stb   u_v_tl                                  ; save nb of vertical tiles in top chunks
	lda   #0                                      ; (dynamic) nb of tile in screen height
scr_tile_y equ *-1
	suba  u_v_tl
	tfr   a,b
	asrb
	asrb
	asrb
	stb   v_tl                                    ; nb of full sized (middle) vertical chunks
	anda  #%00000111                              ; skip middle chunks that are 8 tiles high
	sta   b_v_tl                                  ; save nb of vertical tiles in bottom chunks

	; load up to 12 chunks
	; --------------------
        lda   glb_map_chunk_pge
        _SetCartPageA

	ldb   u_v_tl                   ; first line begin with upper vertical chunk height
	stb   c_v_tl_bck
	ldb   y_off+1
	stb   cur_y_off+1
@vloop
	stx   @start_pos_bck
	stx   start_pos
	ldd   x_off
	addd  cur_y_off
	std   chunk_offset
	ldb   h_tl_bck
	stb   h_tl
	ldb   l_h_tl
	jsr   NextRight
	jsr   PrepDown
	jsr   LoadChunk
@hloop
	ldd   cur_y_off
	std   chunk_offset
	ldb   #8
	jsr   NextRight
	jsr   LoadChunk
	lda   h_tl                     ; there is at least one middle horizontal chunk
	deca
	sta   h_tl
	bne   @hloop
	ldd   cur_y_off
	std   chunk_offset
	ldb   r_h_tl
	jsr   NextDown
	jsr   LoadChunk
	ldb   glb_map_width
	ldx   #0
@start_pos_bck equ *-2
	abx
	ldb   v_tl                     ; are we in middle or bottom chunk ?
	beq   @a
	bmi   @end
	lda   #8                       ; middle
	sta   c_v_tl_bck
	bra   @b
@a	lda   b_v_tl                   ; bottom
	beq   @end                     ; TODO may be removed
	sta   c_v_tl_bck
@b	decb
	stb   v_tl
	clr   cur_y_off+1
	bra   @vloop
@end    rts

NextRight
        stb   c_h_tl                                  ; preprocess next chunk location based on current one
	aslb
	ldx   <glb_screen_location_1
	abx
	stx   c_stp_1
	ldx   <glb_screen_location_2
	abx
	stx   c_stp_2
	rts

PrepDown
	lda   c_v_tl_bck
	ldb   #40*4
	mul
	_asld
	_asld
	std   @bck
	addd  <glb_screen_location_1
	std   @l1_bck
	ldd   #0
@bck    equ   *-2
	addd  <glb_screen_location_2
	std   @l2_bck
	rts
NextDown
        stb   c_h_tl                                  ; preprocess next chunk location based on current one
      	ldd   #0
@l1_bck equ   *-2
	std   c_stp_1
      	ldd   #0
@l2_bck equ   *-2
	std   c_stp_2
	rts

LoadChunk
	ldb   c_h_tl                                  ; preprocess line return
	aslb                                          ; 2 bytes par tile in width
	lda   #0
	_negd
	addd  #40*16+2                                ; 16 lines of 40 bytes : one tile height (position is top left of last chunk, move it to top left of next chunk by adding 2 bytes)
	std   r_stp_1
	std   r_stp_2

	ldx   #0
start_pos equ *-2
	lda   ,x+
	bpl   @a
        ldu   glb_map_defchunk1_adr
	anda  #%01111111
	ldb   glb_map_defchunk1_pge
	bra   @b
@a      ldu   glb_map_defchunk0_adr
  	ldb   glb_map_defchunk0_pge
@b	stb   chk_idx_pge
	_SetCartPageB                                 ; set chunk definition page
	ldb   #0
	_asrd
	addd  #0                                      ; (dynamic) ajust position of first tile in chunk
chunk_offset  equ   *-2
	leau  d,u

        stx   start_pos
	stu   start_x                                 ; start position in chunk

DrawChunk
	lda   c_h_tl
 IFDEF T2
	lbeq  EndOfChunk
 ELSE
	beq   EndOfChunk
 ENDC
	sta   c_h_tl_bck
	lda   c_v_tl_bck
 IFDEF T2
	lbeq  EndOfChunk
 ELSE
	beq   EndOfChunk
 ENDC
	sta   c_v_tl

DrawTile
        ldd   ,u++                                    ; load tile index in d (16 bits)
 IFDEF T2
	lbeq  NextCol
 ELSE
	beq   NextCol
 ENDC

        std   @dyn+1                                  ; multiply tile index by 3 to load tile page and addr
        _lsld
@dyn    addd  #0                                      ; (dynamic)
	stu   @dyn1
        ldu   glb_map_tiles_adr
        leau  d,u
	lda   glb_map_tiles_pge
        _SetCartPageA                                 ; set tile index page
        pulu  a,x                                     ; a: tile routine page, x: tile routine address
        ldu   <glb_screen_location_2     
        _SetCartPageA                                 ; set compilated tile data page
        jsr   ,x                                      ; draw compilated tile
        lda   #0
chk_idx_pge equ *-1
        _SetCartPageA                                 ; restore chunk definition page
	ldu   #0
@dyn1   equ *-2

NextCol
        dec   c_h_tl                                  ; check remaining tiles in this row
        beq   EndOfRow

	; Move tile position on screen to next column
        ; -------------------------------------------
        ldd   #8/4                                    ; nb of linear memory bytes between two tiles in a column
        addd  <glb_screen_location_1
        std   <glb_screen_location_1
        ldd   #8/4                                    ; nb of linear memory bytes between two tiles in a column
        addd  <glb_screen_location_2
        std   <glb_screen_location_2  
 IFDEF T2
	jmp   DrawTile
 ELSE
	bra   DrawTile
 ENDC

        ; Check end of line of current Chunk
        ; ----------------------------------
EndOfRow                                              ; end of line on right chunk, do we need to go to bottom chunk or exit ?
        dec   c_v_tl
	bne   DrawNextRow

	; End of DrawChunk, set next location and restore map of chunks page
        ; ------------------------------------------------------------------
EndOfChunk
        ldd   #0                                      ; (dynamic) nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
c_stp_1 equ   *-2
        std   <glb_screen_location_1
        ldd   #0                                      ; (dynamic)
c_stp_2 equ   *-2
        std   <glb_screen_location_2 

        lda   glb_map_chunk_pge
        _SetCartPageA
	rts

DrawNextRow
	lda   c_h_tl_bck
	sta   c_h_tl

	ldu   #0                                      ; (dynamic)
start_x equ   *-2
	leau  16,u                                    ; a chunk is made of 8 tiles in width
	stu   start_x
	; Move tile position on screen to next row
	; -----------------------------------------
        ldd   #0                                      ; (dynamic) nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
r_stp_1 equ   *-2
        addd  <glb_screen_location_1
        std   <glb_screen_location_1
        ldd   #0                                      ; (dynamic)
r_stp_2 equ   *-2
        addd  <glb_screen_location_2
        std   <glb_screen_location_2 
	jmp   DrawTile

cpt_x fcb 0
