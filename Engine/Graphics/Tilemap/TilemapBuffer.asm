* ---------------------------------------------------------------------------
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
glb_map_width         fcb   0

; variables
h_tl                  fcb   0 ; nb of full sized (middle) horizontal chunks
h_tl_bck              fcb   0
v_tl                  fcb   0 ; nb of full sized (middle) vertical chunks
c_h_tl                fcb   0 ; variable that stores current left, middle or right width of chunks
l_h_tl                fcb   0
r_h_tl                fcb   0
r_h_tl_bck            fcb   0
c_v_tl                fcb   0 ; variable that stores current up, middle or bottom height of chunks
u_v_tl                fcb   0
b_v_tl                fcb   0
c_h_tl_bck            fcb   0 ; backup value of horizontal width of chunks
c_v_tl_bck            fcb   0 ; backup value of vertical height of chunks
cur_c	              fcb   0 ; current chunk id
x_off                 fdb   0 ; position in top left chunk
y_off                 fdb   0 ; position in top left chunk
cur_y_off             fdb   0 ; current y offset

b_loc                 fdb   0 ; location in buffer

tmb_last_0            fill  0,8
tmb_last_1            fill  0,8
tmb_buffer_x          equ   0 ; last location in buffer (x axis)
tmb_buffer_y          equ   2 ; last location in buffer (y axis)
tmb_camera_x          equ   4 ; last camera position (x axis)
tmb_camera_y          equ   6 ; last camera position (y axis)

ComputeDeltaTileBuffer
;
;        ; compute position in cycling buffer
;        ; ---------------------------------------------------------------------
;
;        tst   glb_Cur_Wrk_Screen_Id
;        bne   @scr1
;	ldx   tmb_last_0
;	bra   @scr0
;@scr1	ldx   tmb_last_1
;@scr0
;
;	; check if full refresh is needed
;        ; glb_tmb_full_refresh can be set manually before routine call
;	tst   glb_tmb_full_refresh
;	bne   @skip
;	ldd   <glb_camera_y_pos
;	subd  camera_y,x
;	stb   glb_tmb_y_offset
;	cmpd  #16*11
;	bge   @refrsh
;	cmpd  #-16*11
;	ble   @refrsh
;	ldd   <glb_camera_x_pos
;	subd  camera_x,x
;	stb   glb_tmb_x_offset
;	cmpd  #16*11
;	bge   @refrsh
;	cmpd  #-16*11
;	ble   @refrsh
;	bra   @skip
;@refrsh	lda   #1
;	sta   glb_tmb_full_refresh
;@skip
;
;        ldd   <glb_camera_x_pos
;	std   camera_x,x
;        anda  #%00000000                    ; col mask (0-32)
;        andb  #%11111000                    ; tile width 8px (>>3) 
;        _lsrd                               ; col size 4 bytes (<<2)
;        pshs  d,x
;        ldd   <glb_camera_y_pos+1
;	std   camera_y,x
;        anda  #%00000000
;        andb  #%11110000                    ; line mask (0-16)
;        _lsld                               ; tile height 16px (>>4) 
;        _lsld                               ; line skip 128 bytes (<<7)
;        _lsld
;	tst   glb_tmb_full_refresh
;	bne   @refrsh
;    	cmpd  b_loc_y,x                     ; check vertical change
;	beq   @x_axis                       ; branch if no change on y axis
;     	tfr   d,u
;	subd  b_loc_y,x                     ; compute vertical change
;	_asld                               ; divide d by 128 in a (compute nb of tile lines)
;	bra   @a
;@refrsh tfr   d,u
;	lda   #11                           ; full height in tiles
;@a	stu   b_loc_y,x                     ; backup new value as old
;	ldb   #18
;	stb   glb_tmb_width
;; il manque le addd de b_x
;	sta   glb_tmb_height                ; number of vertical tiles to draw (positive or negative)
;	bmi   @a
;	ldd   
;        std   glb_tmb_offset                ; fill tiles down
;	jsr   FeedTileBuffer 
;	bra   @b
;@a	; fill tiles up
;        jsr   FeedTileBuffer
;@b      bpl   @continue
;        puls  d,x,pc                        ; a full render was done no need to draw on x_axis
;@continue
;	puls  d,x
;    	cmpd  b_loc_x,x                     ; check horizontal change
;	beq   @end
;        tfr   d,u
;    	subd  b_loc_x,x                     ; check horizontal change
;	stu   b_loc_x,x                     ; backup new value as old
;	_asrd
;	_asrd
;	stb   glb_tmb_width
;; todo check values >screen width
;; set other params
;	bmi   @a
;	; fill tiles right
;	jsr   FeedTileBuffer 
;	bra   @c
;@a	; fill tiles left
;@c      jsr   FeedTileBuffer
@end    rts

; ****************************************************************************************************************************
; * FeedTileBuffer
; * Feed the tile buffer, based on camera x and y and a number of tiles in width and height
; * 
; * glb_tmb_x      (0-32767)                  
; * glb_tmb_y      (0-32767)          
; * glb_tmb_width  (1-20)       
; * glb_tmb_height (1-13)        
; *
; ****************************************************************************************************************************

FeedTileBuffer
        ; check if a map was registred and mount the map
        ; ---------------------------------------------------------------------

	lda   glb_map_pge
	bne   @a
	rts
@a
        _SetCartPageA        
        ldu   glb_map_adr

        ; compute position in cycling buffer
        ; ---------------------------------------------------------------------
 
        ldd   #0                            ; (dynamic)
glb_tmb_x equ *-2
        anda  #%00000000                    ; col mask (0-32)
        andb  #%11111000                    ; tile width 8px (>>3) 
        _lsrd                               ; col size 4 bytes (<<2)
	std   @dyn
        ldd   #0                            ; (dynamic)
glb_tmb_y equ *-2
        anda  #%00000000
        andb  #%11110000                    ; line mask (0-16)
        _lsld                               ; tile height 16px (>>4) 
        _lsld                               ; line skip 128 bytes (<<7)
        _lsld
        addd  #0                            ; (dynamic) add x position to index 
@dyn    equ   *-2
        addd  #tile_buffer
        std   b_loc

        ; transform a camera position into an index to map (64x128px chunks)
        ; ---------------------------------------------------------------------
        ldd   glb_tmb_x
        _lsrd
        _lsrd
        _lsrd
        _lsrd 
        _lsrd
        _lsrd                                                 
        std   @dyn1+1
        ldd   glb_tmb_y
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
        
	; compute tile offset in chunks
        ; ---------------------------------------------------------------------

	lda   glb_tmb_x+1
	anda  #%00111000
	asra
	asra
	sta   x_off+1                                 ; horizontal offset to first tile in top left chunk
	asra  
	suba  #8                                      ; chunk hold 8 tiles in a row
	nega
	cmpa  #0
glb_tmb_width equ *-1                                 ; (dynamic) nb of tile in screen width 
	bge   @onehc                                  ; branch if requested tiles in width are covered by the first chunk 
	sta   l_h_tl                                  ; save nb of tiles in left chunks
	lda   glb_tmb_width
	suba  l_h_tl
	tfr   a,b
	asrb
	asrb
	asrb
	stb   h_tl_bck                                ; nb of full sized (middle) horizontal chunks
	anda  #%00000111                              ; skip middle chunks that are 8 tiles wide
	sta   r_h_tl                                  ; save nb of horizontal tiles in right chunks
	sta   r_h_tl_bck
        bra   @y
@onehc  lda   #0                                      ; only one chunk involved
	sta   h_tl_bck
	sta   r_h_tl
        lda   glb_tmb_width
        sta   l_h_tl
@y

	ldb   glb_tmb_y+1
	andb  #%01110000                              ; get tile position in chunk
	stb   y_off+1                                 ; vertical offset to first tile in top left chunk
	asrb  
	asrb  
	asrb  
	asrb  
	subb  #8                                      ; chunk hold 8 tiles in a col
	negb
	cmpb  #0
glb_tmb_height equ *-1                                ; (dynamic) nb of tile in screen width 
	bge   @onevc                                  ; branch if requested tiles in width are covered by the first chunk 
	stb   u_v_tl                                  ; save nb of vertical tiles in top chunks
	lda   glb_tmb_height                          ; (dynamic) nb of tile in screen height
	suba  u_v_tl
	bpl   @a                                      ; branch if more than one chunk is involved
@b      lda   #0                                      ; only one chunk involved
	sta   v_tl
	sta   b_v_tl
        bra   @end
@a	beq   @b
	tfr   a,b
	asrb
	asrb
	asrb
	stb   v_tl                                    ; nb of full sized (middle) vertical chunks
	anda  #%00000111                              ; skip middle chunks that are 8 tiles high
	sta   b_v_tl                                  ; save nb of vertical tiles in bottom chunks
	bra   @end
@onevc  lda   #0                                      ; only one chunk involved
	sta   v_tl
	sta   b_v_tl
        lda   glb_tmb_height
        sta   u_v_tl
@end

	; load chunks
	; --------------------
        lda   glb_map_chunk_pge
        _SetCartPageA

	ldb   u_v_tl                   ; first line begin with upper vertical chunk height
	stb   c_v_tl_bck

	ldd   x_off                    ; offset in top left chunk is horizontal and vertical
	addd  y_off
	std   chunk_offset
@vloop
	stx   @start_pos_bck
	stx   start_pos
	ldb   h_tl_bck                 ; load nb of middle chunks (8 tiles width) on x axis for one row
	stb   h_tl
	ldd   b_loc
        andb  #%10000000
        std   cl_pos_bck
	ldb   l_h_tl                   ; nb of tiles on left chunk
        stb   c_h_tl                   ; store in current nb of tiles               
	lda   c_v_tl_bck               ; compute location for next row
	ldb   #128                     ; ...
	mul                            ; ...
	addd  b_loc                    ; ...
        anda  #%00000111
        adda  #tile_buffer/256 ; add base address
	std   @l1_bck                  ; save location for next row
@hloop
  	jsr   LoadChunk
	ldd   b_loc                    ; compute location for next col
	addd  #4
        anda  #%00000000
        andb  #%01111100 ; cycle thru this line (0-127) by 4 bytes
        addd  #0
cl_pos_bck equ *-2
        std   b_loc                    ; set location for next col
	lda   h_tl                     ; check number of middle chunks
	beq   @rc
	ldb   #8                       ; middle chunks are 8 tiles width
	stb   c_h_tl
	deca
	sta   h_tl
	bra   @hloop
@rc     ldb   r_h_tl                   ; check right chunk
	beq   @hexit
        stb   c_h_tl
	stb   r_h_tl_bck
	clr   r_h_tl
	bra   @hloop
@hexit  lda   r_h_tl_bck
	sta   r_h_tl
      	ldd   #0
@l1_bck equ   *-2
	std   b_loc                    ; set location for next row
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
	beq   @end
	sta   c_v_tl_bck
@b	decb
	stb   v_tl
	ldd   x_off
	std   chunk_offset             ; offset in next row of chunk is only horizontal
	jmp   @vloop
@end    rts

LoadChunk
        ldd   b_loc
        andb  #%10000000
        std   cl_pos                                  ; save line start for cycling buffer
	ldb   c_h_tl                                  ; preprocess line return
	aslb                                          ; buffer : 4 bytes per tile in width
	aslb
	lda   #0
	_negd
	addd  #128+4                                  ; one line in buffer and one tile width
	std   r_stp_1

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
        ldu   b_loc
	sta   1,u
	stx   2,u
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
        ldd   #4                                    ; nb of linear memory bytes between two tiles in a column
        addd  b_loc
        anda  #%00000000
        andb  #%01111100 ; cycle thru this line (0-127) by 4 bytes
        addd  #0
cl_pos  equ   *-2
        std   b_loc
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

	; End of DrawChunk, restore map of chunks page
        ; ------------------------------------------------------------------
EndOfChunk
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
        addd  b_loc
        anda  #%00000111
        adda  #tile_buffer/256 ; add base address
        std   b_loc
        andb  #%10000000
        std   cl_pos                                  ; save start of line for cycling buffer
	jmp   DrawTile

cpt_x fcb 0

; ****************************************************************************************************************************
; *
; *
; *
; *
; *
; *
; *
; *
; *
; *
; *
; ****************************************************************************************************************************

DrawBufferedTile

        lda   glb_force_sprite_refresh
        bne   @a
        rts
@a

        ; compute number of tiles to render
        ; saves one tile row or col when camera pos is a multiple of tile size
        ; ---------------------------------------------------------------------
        ldb   #18-1                         ; nb of tile in screen width 
        lda   <glb_camera_x_pos+1
        anda  #%00000111
        bne   @skip
        decb
@skip   stb   DBT_ccpt
        stb   DBT_ccpt_bck

        ldb   #11                           ; nb of tile in screen height
        lda   <glb_camera_y_pos+1
        anda  #%00001111
        bne   @skip
        decb
@skip   stb   DBT_lcpt

        ; compute top left tile position on screen
        ; position is rounder to 2 px horizontally beacuse of 2px per byte
        ; and vertically beacuse of interlacing
        ; ---------------------------------------------------------------------
        lda   <glb_camera_x_pos+1
        anda  #%00000110                    ; mask for 8px tile in width
        nega
        adda  #12                           ; on screen position of camera

        ldb   <glb_camera_y_pos+1
        andb  #%00001110                    ; mask for 16px tile in height
        negb
        addb  #20                           ; on screen position of camera

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
        pshs  d
        std   s_loc2
        suba  #$20
        std   <glb_screen_location_1     
        bra   @end
@RAM2First
        sta   @dyn2
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$A000                        ; (dynamic)
@dyn2   equ   *-1        
        std   <glb_screen_location_2
        pshs  d
        std   s_loc2
        addd  #$2001
        std   <glb_screen_location_1
@end
        pshs  d
        std   s_loc1

        ; compute position in cycling buffer
        ; ---------------------------------------------------------------------
        ldd   <glb_camera_x_pos
        anda  #%00000000                    ; col mask (0-32)
        andb  #%11111000                    ; tile width 8px (>>3) 
        _lsrd                               ; col size 4 bytes (<<2)
        std   @dyn2
        anda  #%00000000
        ldb   <glb_camera_y_pos+1
        andb  #%11110000                    ; line mask (0-16)
        _lsld                               ; tile height 16px (>>4) 
        _lsld                               ; line skip 128 bytes (<<7)
        _lsld
        addd  #0                            ; (dynamic) add x position to index 
@dyn2   equ   *-2
        addd  #tile_buffer
        tfr   d,u

; **************************************
; * Tile rendering Loop
; **************************************

DBT_lloop
        std   ls_pos
        andb  #%10000000
        std   l_pos

        ; tiles in col
        ; ****************
DBT_cloop
        pulu  d,x
        pshs  u
        stb   $E7E6
        beq   @skip
        ldu   <glb_screen_location_2
        jsr   ,x
@skip   puls  d,x,u
        leau  2,u
        stu   <glb_screen_location_2
        leax  2,x
        stx   <glb_screen_location_1
        pshs  x,u
        anda  #%00000000
        andb  #%01111100 ; cycle thru this line (0-127) by 4 bytes
        addd  #0
l_pos   equ   *-2
        tfr   d,u

        dec   DBT_ccpt
        bne   DBT_cloop

        lda   #0
DBT_ccpt_bck equ   *-1
        sta   DBT_ccpt
 
        ; last tile in col
        ; ****************

        pulu  d,x
        pshs  u
        stb   $E7E6
        beq   @skip
        ldu   <glb_screen_location_2
        jsr   ,x
@skip   puls  d,x,u

 
        ; next line
        ; ****************

        ldu   #0
s_loc2  equ   *-2
        leau  40*16,u
        stu   <glb_screen_location_2
        stu   s_loc2
        ldx   #0
s_loc1  equ   *-2
        leax  40*16,x
        stx   <glb_screen_location_1
        stx   s_loc1
        pshs  x,u
        
        ldd   #0
ls_pos  equ   *-2              ; line start pos
        addd  #128
        anda  #%00000111
        adda  #tile_buffer/256 ; add base address
        tfr   d,u

        dec   DBT_lcpt
        bne   DBT_lloop
@rts    puls  x,u
        rts

DBT_lcpt     fcb   0
DBT_ccpt     fcb   0

        align 2048
tile_buffer
        fill  0,16*128

