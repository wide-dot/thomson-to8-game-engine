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
	bne   @continue1
	ldd   glb_camera_y_pos
	cmpd  glb_old_camera_y_pos1
	bne   @continue1
        rts
@endx0 	ldd   glb_camera_y_pos
@endy0	std   glb_old_camera_y_pos0
	stx   glb_old_camera_x_pos0
	bra   @end
@endx1 	ldd   glb_camera_y_pos
@endy1	std   glb_old_camera_y_pos1
	stx   glb_old_camera_x_pos1
@end

	lda   glb_map_pge
	bne   @a
	rts
@a
        _SetCartPageA        
        ldu   glb_map_adr

        lda   layer_map_width,u
	sta   

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
	leay  d,x                                     ; y now points to start of chunk definition

	; process tile position on screen
	lda   glb_camera_x_pos+1
	anda  #%00000111                              ; mask for 8px tile in width
	nega
	ldb   glb_camera_y_pos+1
	andb  #%00001111                              ; mask for 16px tile in height
	negb
	addd  #$381C                                  ; hardcoded position on screen x=56, y=28
        jsr   TLM_XYToAddress

DrawTileInit
	lda   #1
	sta   glb_force_sprite_refresh

	








        lda   #10                                     ; nb vertical tiles - 1
        sta   dyn_y+1                                 ; init row counter        
        lda   8/4                                     ; nb of linear memory bytes between two tiles in a column
        sta   dyn_sx+1
        ldd   (40*64)-(152/4-8/4)                     ; nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
        std   dyn_sy+1
        lda   glb_map_width
        suba  #19                                     ; nb horizontal tiles
        sta   dyn_w+1
        ldu   glb_map_tiles_adr
        bra   DrawTileLayer

DrawTileRow  
        dec   dyn_y+1
dyn_sy  ldd   #$0000                                  ; (dynamic) y memory step
        ldx   glb_screen_location_1
        leax  d,x
        stx   glb_screen_location_1
        ldx   glb_screen_location_2
        leax  d,x
        stx   glb_screen_location_2  
dyn_xi  lda   #18                                     ; nb horizontal tiles - 1
        sta   dyn_x+1                                 ; init column counter
        bra   DrawTileLayer
        
DrawTileColumn        
        dec   dyn_x+1
dyn_sx  ldb   #$00                                    ; (dynamic) x memory step
        ldx   glb_screen_location_1
        abx
        stx   glb_screen_location_1
        ldx   glb_screen_location_2
        abx
        stx   glb_screen_location_2                
                
DrawTileLayer        
        ldu   glb_submap_index
        lda   #0
        ldb   ,u                                      ; load tile index in b (0-256)
	beq   skip                                    ; skip empty tile (index 0)
        std   @dyn+1                                  ; multiply d by 3
        _lsld
@dyn    addd  #0                                      ; (dynamic)
        leau  1,u
        stu   glb_submap_index
        ldu   glb_map_tiles_adr
        leau  d,u
        pulu  a,x                                     ; a: tile routine page, x: tile routine address

        ; draw compilated tile
        ldy   #glb_screen_location_2     
        stx   glb_Address        
        jsr   RunPgSubRoutine        
        
dyn_x   lda   #0                                      ; (dynamic) current column index
        tsta
        bne   DrawTileColumn
dyn_y   lda   #0                                      ; (dynamic) current row index
dyn_w   ldb   #0
        ldu   glb_submap_index
        leau  b,u        
        stu   glb_submap_index
        tsta
        bne   DrawTileRow
                                                      ; TODO set here the background refresh flag   
        rts

skip    leau  1,u
        stu   glb_submap_index
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
