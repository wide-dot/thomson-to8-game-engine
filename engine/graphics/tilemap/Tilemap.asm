* ---------------------------------------------------------------------------
* Tilemap - Subroutines to draw a background of tiles
*
* input REG : none
*
* ---------------------------------------------------------------------------

        INCLUDE "./engine/graphics/tilemap/data-types/layer.equ"
        INCLUDE "./engine/graphics/tilemap/data-types/submap.equ"        

glb_submap_index_inactive equ   $FFFF                     ; force background refresh if used in glb_submap_index_buf0/1

glb_submap                fdb   $0000                     ; location of submap data structure
glb_submap_page           fdb   $00                       ; location of submap data structure
glb_submap_index          fdb   $0000                     ; index in submap tile table that matches camera position
glb_submap_index_buf0     fdb   glb_submap_index_inactive ; actual submap index that matches screen buffer 0 content
glb_submap_index_buf1     fdb   glb_submap_index_inactive ; actual submap index that matches screen buffer 1 content

DrawTilemap

        lda   glb_submap_page
        ldx   glb_submap        
        _SetCartPageA        

        ; TODO loop thru all submap layers        
        ldu   submap_layers,x

        ; Transform a camera position into an index into submap table
        ; This routine use a submap layer parameter (layer_tile_size_divider)
        ; to make a faster division at runtime
        
        leay  layer_tilemap,u
        sty   @dyn2+1
        ldb   layer_tile_size_divider_x,u
        stb   @dynb1+1
        ldd   <glb_camera_x_pos
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
        cmpd  glb_submap_index_buf0
        beq   DTM_Return
        std   glb_submap_index_buf0
        std   glb_submap_index
        bra   DrawTileInit

DTM_Return
        rts        
        
DTM_Buffer1        
        cmpd  glb_submap_index_buf1
        beq   DTM_Return
        std   glb_submap_index_buf1
        std   glb_submap_index

DrawTileInit
	lda   #1
	sta   glb_camera_move
        ldd   layer_vp_offset,u
        addd  #$A000
        std   <glb_screen_location_1
        ldd   layer_vp_offset,u        
        addd  #$C000
        std   <glb_screen_location_2
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
        ldu   glb_submap_index
        lda   #0
        ldb   ,u                                      ; load tile index in b (0-256)
	beq   skip                                   ; skip empty tile (index 0)
        std   @dyn+1                                  ; multiply d by 3
        _lsld
@dyn    addd  #$0000                                  ; (dynamic)
        leau  1,u
        stu   glb_submap_index
dyn_Tls ldu   #0000                                   ; (dynamic) Tileset
        leau  d,u
        pulu  a,x                                     ; a: tile routine page, x: tile routine address

        ; draw compilated tile
        ldu   <glb_screen_location_2   
        sta   PSR_Page  
        stx   PSR_Address        
        jsr   RunPgSubRoutine        
        
dyn_x   lda   #$00                                    ; (dynamic) current column index
        tsta
        bne   DrawTileColumn
dyn_y   lda   #$00                                    ; (dynamic) current row index
dyn_w   ldb   #$00
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