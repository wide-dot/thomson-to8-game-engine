* ---------------------------------------------------------------------------
* Tilemaps - Subroutines to draw multiple backgrounds of tiles
*
* input REG : none
*
* ---------------------------------------------------------------------------

        INCLUDE "./Engine/Graphics/Tilemap/DataTypes/Layer.equ"
        INCLUDE "./Engine/Graphics/Tilemap/DataTypes/Submap.equ"        

glb_submap_index_inactive  equ   $FFFF                     ; force background refresh if used in glb_submap_index_buf0/1
glb_submap_addr            equ   0
glb_submap_page            equ   2
glb_submap_index           equ   3
glb_submap_index_buf0      equ   5
glb_submap_index_buf1      equ   7
glb_submap_location_buf0   equ   9
glb_submap_location_buf1   equ   11
glb_submap_size            equ   13

glb_submap                 fill  0,glb_submap_size*(glb_submap_nb+1)
glb_submap_end

parallax_x_pos             fdb   0

DrawTilemaps
	ldx   #glb_submap+glb_submap_size
@loop	cmpx  #glb_submap_end
	bne   @a
	rts
@a	
	lda   glb_submap_page,x
	beq   @next
	stx   @dyn+1
	ldy   #glb_submap
	sta   glb_submap_page,y
	ldd   glb_submap_addr,x
	std   glb_submap_addr,y
	ldd   glb_submap_index,x
	std   glb_submap_index,y
	ldd   glb_submap_index_buf0,x
	std   glb_submap_index_buf0,y
	ldd   glb_submap_index_buf1,x
	std   glb_submap_index_buf1,y
	ldd   glb_submap_location_buf0,x
	std   glb_submap_location_buf0,y
	ldd   glb_submap_location_buf1,x
	std   glb_submap_location_buf1,y
	jsr   @run
@dyn	
	ldx   #0
	ldy   #glb_submap
	ldd   glb_submap_index,y
	std   glb_submap_index,x
	ldd   glb_submap_index_buf0,y
	std   glb_submap_index_buf0,x
	ldd   glb_submap_index_buf1,y
	std   glb_submap_index_buf1,x
	ldd   glb_submap_location_buf0,y
	std   glb_submap_location_buf0,x
	ldd   glb_submap_location_buf1,y
	std   glb_submap_location_buf1,x
@next
	leax  glb_submap_size,x
	bra   @loop
@run
        lda   glb_submap+glb_submap_page
        ldx   glb_submap+glb_submap_addr
        _SetCartPageA        

        ; TODO loop thru all submap layers        
        ldu   submap_layers,x

        ; Transform a camera position into an index to submap table
        ; This routine use a submap layer parameter (layer_tile_size_divider)
        ; to make a faster division at runtime
        
        leay  layer_tilemap,u
        sty   @dyn2+1
        ldb   layer_tile_size_divider_x,u
        stb   @dynb1+1
        ldb   layer_parallax_X,u
	beq   @skip
        lda   <glb_camera_x_pos+1
	mul
	clr   parallax_x_pos
	sta   parallax_x_pos+1
        ldb   layer_parallax_X,u
	lda   <glb_camera_x_pos
	mul
	addd  parallax_x_pos
	std   parallax_x_pos
	bra   @parallax
@skip
	ldd   <glb_camera_x_pos
	std   parallax_x_pos
@parallax 
	subd  submap_x_pos,x
@dynb1  bra   *+2
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd                                                
        std   @dyn1+1
        ldb   layer_tile_size_divider_y,u
        stb   @dynb2+1
        ldd   <glb_camera_y_pos
        subd  submap_y_pos,x
@dynb2  bra   *+2
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        lda   layer_width,u
        mul                                           ; to use map larger than 256*256 tiles, use tile groups (TODO)
@dyn1   addd  #0                                      ; (dynamic) add x position to index 
@dyn2   addd  #0                                      ; (dynamic) add layer map data address to index
        
        ; now we have to check if this submap index (register d) was the one already rendered (or not) on this buffer
        ; the goal is to avoid the full redraw of background if it's already there ...
        
        tst   glb_Cur_Wrk_Screen_Id                   ; read current screen buffer for write operations
        bne   DTM_Buffer1
                
DTM_Buffer0
        cmpd  glb_submap+glb_submap_index_buf0
        bne   @a
	std   glb_submap+glb_submap_index
	; process tile position on screen
	lda   parallax_x_pos+1
	anda  #%00000111               ; mask for 8px wide tile TODO make it a parameter
	nega
	ldb   <glb_camera_y_pos+1
	andb  #%00000111               ; mask for 8px wide tile TODO make it a parameter
	negb
	addd  layer_vp_offset,u
        jsr   TLM_XYToAddress
	cmpd  glb_submap+glb_submap_location_buf0
	bne   @b
	rts
@a      std   glb_submap+glb_submap_index_buf0
        std   glb_submap+glb_submap_index
	; process tile position on screen
	lda   parallax_x_pos+1
	anda  #%00000111               ; mask for 8px wide tile TODO make it a parameter
	nega
	ldb   <glb_camera_y_pos+1
	andb  #%00000111               ; mask for 8px wide tile TODO make it a parameter
	negb
	addd  layer_vp_offset,u
        jsr   TLM_XYToAddress
@b	std   glb_submap+glb_submap_location_buf0
        bra   DrawTileInit

DTM_Buffer1        
        cmpd  glb_submap+glb_submap_index_buf1
        bne   @a
	std   glb_submap+glb_submap_index
	; process tile position on screen
	lda   parallax_x_pos+1
	anda  #%00000111               ; mask for 8px wide tile TODO make it a parameter
	nega
	ldb   glb_camera_y_pos+1
	andb  #%00000111               ; mask for 8px wide tile TODO make it a parameter
	negb
	addd  layer_vp_offset,u
        jsr   TLM_XYToAddress
	cmpd  glb_submap+glb_submap_location_buf1
	bne   @b
	rts
@a      std   glb_submap+glb_submap_index_buf1
        std   glb_submap+glb_submap_index
	; process tile position on screen
	lda   parallax_x_pos+1
	anda  #%00000111               ; mask for 8px wide tile TODO make it a parameter
	nega
	ldb   <glb_camera_y_pos+1
	andb  #%00000111               ; mask for 8px wide tile TODO make it a parameter
	negb
	addd  layer_vp_offset,u
	jsr   TLM_XYToAddress
@b	std   glb_submap+glb_submap_location_buf1

DrawTileInit
	lda   #1
	sta   glb_camera_move
        lda   layer_vp_tiles_x,u
        sta   dyn_x+1                                 ; init column counter
        sta   dyn_xi+1                                ; init column counter
        lda   layer_vp_tiles_y,u
        sta   dyn_y+1                                 ; init row counter        
        lda   layer_mem_step_x,u
        sta   dyn_sx+1
        ldd   layer_mem_step_y,u
        std   dyn_sy+1
        lda   layer_width,u
        suba  layer_vp_tiles_x,u
        deca
        sta   dyn_w+1
        ldu   layer_tiles_location,u
        stu   dyn_Tls+1
        bra   DrawTileLayer

DrawTileRow  
        dec   dyn_y+1
dyn_sy  ldd   #$0000                                  ; (dynamic) y memory step
        ldx   <glb_screen_location_1
        leax  d,x
        stx   <glb_screen_location_1
        ldx   <glb_screen_location_2
        leax  d,x
        stx   <glb_screen_location_2  
dyn_xi  lda   #$00
        sta   dyn_x+1                                 ; init column counter
        bra   DrawTileLayer
        
DrawTileColumn        
        dec   dyn_x+1
dyn_sx  ldb   #$00                                    ; (dynamic) x memory step
        ldx   <glb_screen_location_1
        abx
        stx   <glb_screen_location_1
        ldx   <glb_screen_location_2
        abx
        stx   <glb_screen_location_2                
                
DrawTileLayer        
        ldu   glb_submap+glb_submap_index
        lda   #0
        ldb   ,u                                      ; load tile index in b (0-256)
	beq   skip                                   ; skip empty tile (index 0)
        std   @dyn+1                                  ; multiply d by 3
        _lsld
@dyn    addd  #$0000                                  ; (dynamic)
        leau  1,u
        stu   glb_submap+glb_submap_index
dyn_Tls ldu   #0000                                   ; (dynamic) Tileset
        leau  d,u
        pulu  a,x                                     ; a: tile routine page, x: tile routine address

        ; draw compilated tile
        ldu   <glb_screen_location_2     
        stx   glb_Address        
        jsr   RunPgSubRoutine        
        
dyn_x   lda   #$00                                    ; (dynamic) current column index
        tsta
        bne   DrawTileColumn
dyn_y   lda   #$00                                    ; (dynamic) current row index
dyn_w   ldb   #$00
        ldu   glb_submap+glb_submap_index
        leau  b,u        
        stu   glb_submap+glb_submap_index
        tsta
        bne   DrawTileRow
                                                      ; TODO set here the background refresh flag   
        rts

skip    leau  1,u
        stu   glb_submap+glb_submap_index
	bra   dyn_x

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
        std   <glb_screen_location_2
        subd  #$2000
        std   <glb_screen_location_1     
        rts
TLM_XYToAddressRAM2First
        sta   TLM_dyn2+2
        lda   #$28                          ; 40 bytes per line in RAMA or RAMB
        mul
TLM_dyn2        
        addd  #$A000                        ; (dynamic)
        std   <glb_screen_location_2
        addd  #$2001
        std   <glb_screen_location_1
        rts
