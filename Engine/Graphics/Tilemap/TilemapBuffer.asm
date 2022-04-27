* ---------------------------------------------------------------------------
*
* ---------------------------------------------------------------------------

        INCLUDE "./Engine/Graphics/Tilemap/DataTypes/map16bits.equ"
        SETDP $9F

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

; tmp variables
h_tl                  equ   glb_tmp_var    ; nb of full sized (middle) horizontal chunks
h_tl_bck              equ   glb_tmp_var+1
v_tl                  equ   glb_tmp_var+2  ; nb of full sized (middle) vertical chunks
c_h_tl                equ   glb_tmp_var+3  ; variable that stores current left, middle or right width of chunks
l_h_tl                equ   glb_tmp_var+4 
r_h_tl                equ   glb_tmp_var+5 
r_h_tl_bck            equ   glb_tmp_var+6 
c_v_tl                equ   glb_tmp_var+7  ; variable that stores current up, middle or bottom height of chunks
u_v_tl                equ   glb_tmp_var+8 
b_v_tl                equ   glb_tmp_var+9 
c_h_tl_bck            equ   glb_tmp_var+10 ; backup value of horizontal width of chunks
c_v_tl_bck            equ   glb_tmp_var+11 ; backup value of vertical height of chunks
cur_c                 equ   glb_tmp_var+12 ; current chunk id
x_off                 equ   glb_tmp_var+13 ; x start position in top left chunk
y_off                 equ   glb_tmp_var+15 ; y start position in top left chunk
b_loc                 equ   glb_tmp_var+17 ; location in buffer
tmb_x                 equ   glb_tmp_var+19
tmb_y                 equ   glb_tmp_var+21

; persistant variables
tmb_old_camera_x      fdb   0 ; last camera position (x axis)
tmb_old_camera_y      fdb   0 ; last camera position (y axis)

tmb_vp_h_tiles        equ   18 ; viewport tiles on x axis
tmb_vp_v_tiles        equ   11 ; viewport tiles on y axis
tmb_vp_h_px           equ   tmb_vp_h_tiles*8
tmb_vp_v_px           equ   tmb_vp_v_tiles*16

InitTileBuffer
        ldd   <glb_camera_x_pos
        addd  #tmb_vp_h_px
        std   tmb_old_camera_x
        ldd   <glb_camera_y_pos
        addd  #tmb_vp_v_px
        std   tmb_old_camera_y
        rts

ComputeTileBuffer

        ; check if a map was registred
        ; ---------------------------------------------------------------------

        lda   glb_map_pge
        bne   @a
        rts
@a

        ; compute tiles that needs to be added to buffer
        ; ---------------------------------------------------------------------

        ; compute y location
        ldu   <glb_camera_y_pos
        ldd   tmb_old_camera_y
        subd  <glb_camera_y_pos
        beq   @next
        bpl   @a
        leau  tmb_vp_v_px,u
        leau  d,u
@a      stu   tmb_y
        ; compute height in tiles
        ldd   <glb_camera_y_pos
        _asrd
        _asrd
        _asrd
        _asrd
        std   @dyn
        ldd   tmb_old_camera_y
        _asrd
        _asrd
        _asrd
        _asrd
        subd   #0
@dyn    equ   *-2
        beq   @next
        bpl   @b
        _negd
@b      cmpd  #tmb_vp_v_tiles
        ble   @c
        ldb   #tmb_vp_v_tiles
@c      stb   glb_tmb_height
        ldd   <glb_camera_x_pos
        std   tmb_x
        lda   #tmb_vp_h_tiles
        sta   glb_tmb_width
        jsr   FeedTileBuffer
@next

        ; compute x location
        ldu   <glb_camera_x_pos
        ldd   tmb_old_camera_x
        subd  <glb_camera_x_pos
        beq   @exit
        bpl   @a
        leau  tmb_vp_h_px,u
        leau  d,u
@a      stu   tmb_x
        ; compute width in tiles
        ldd   <glb_camera_x_pos
        _asrd
        _asrd
        _asrd
        std   @dyn
        ldd   tmb_old_camera_x
        _asrd
        _asrd
        _asrd
        subd   #0
@dyn    equ   *-2
        beq   @exit
        bpl   @b
        _negd
@b      cmpd  #tmb_vp_h_tiles
        ble   @c
        ldb   #tmb_vp_h_tiles
@c      stb   glb_tmb_width
        ldd   <glb_camera_y_pos
        std   tmb_y
        lda   #tmb_vp_v_tiles
        sta   glb_tmb_height
        jsr   FeedTileBuffer
@exit
        ldd   <glb_camera_x_pos
        std   tmb_old_camera_x
        ldd   <glb_camera_y_pos
        std   tmb_old_camera_y
        rts

; ****************************************************************************************************************************
; * FeedTileBuffer
; * Feed the tile buffer, based on camera x and y and a number of tiles in width and height
; * 
; * tmb_x      (0-32767)                  
; * tmb_y      (0-32767)          
; * glb_tmb_width  (1-20)       
; * glb_tmb_height (1-13)        
; *
; ****************************************************************************************************************************

FeedTileBuffer

        ; mount the map
        ; ---------------------------------------------------------------------

        lda   glb_map_pge
        _SetCartPageA        
        ldu   glb_map_adr

        ; compute position in cycling buffer
        ; ---------------------------------------------------------------------
 
        ldb   tmb_x+1                       ; col mask (0-32)
        andb  #%11111000                    ; tile width 8px (>>3) 
        lsrb                                ; col size 4 bytes (<<2)
        stb   @dyn
        ldb   tmb_y+1                       
        anda  #%00000000
        andb  #%11110000                    ; line mask (0-16)
        _lsld                               ; tile height 16px (>>4) 
        _lsld                               ; line skip 128 bytes (<<7)
        _lsld
        addd  #0                            ; (dynamic) add x position to index 
@dyn    equ   *-1
        adda  #tile_buffer/256
        std   b_loc

        ; transform a camera position into an index to map (64x128px chunks)
        ; ---------------------------------------------------------------------
        ldd   tmb_x
        _lsrd
        _lsrd
        _lsrd
        _lsrd 
        _lsrd
        _lsrd                                                 
        std   @dyn1
        ldd   tmb_y
        _lsrd
        _lsrd
        _lsrd
        _lsrd 
        _lsrd
        _lsrd
        andb  #%11111110                              ; faster than _lsrd (last shift for 128px map) and lsld (2 bytes index in mul ref)
        leax  layer_mul_ref,u
        ldd   d,x                                     ; use precalculated values to get y in map (16 bits mul)
        addd  #0                                      ; (dynamic) add x position to index 
@dyn1   equ   *-2
        addd  glb_map_chunk_adr                       ; (dynamic) add map data address to index
        tfr   d,x
        
        ; compute tile offset in chunks
        ; ---------------------------------------------------------------------

        lda   tmb_x+1
        anda  #%00111000
        asra
        asra
        sta   x_off+1                                 ; horizontal offset to first tile in top left chunk
        asra  
        suba  #8                                      ; chunk hold 8 tiles in a row
        nega
        cmpa  #0
glb_tmb_width equ *-1                                 ; (dynamic) nb of tile in screen width 
        blt   @a                                      ; branch if requested tiles in width are covered by more chunks than the first one 
        lda   glb_tmb_width                           ; if not cap to the requested width
@a      sta   l_h_tl                                  ; save nb of tiles in left chunks
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

        lda   tmb_y+1
        anda  #%01110000                              ; get tile position in chunk
        sta   y_off+1                                 ; vertical offset to first tile in top left chunk
        asra  
        asra  
        asra  
        asra  
        suba  #8                                      ; chunk hold 8 tiles in a col
        nega
        cmpa  #0
glb_tmb_height equ *-1                                ; (dynamic) nb of tile in screen width 
        blt   @a                                      ; branch if requested tiles in width are covered by the first chunk 
        lda   glb_tmb_height
@a      sta   u_v_tl                                  ; save nb of vertical tiles in top chunks
        lda   glb_tmb_height                          ; (dynamic) nb of tile in screen height
        suba  u_v_tl
        tfr   a,b
        asrb
        asrb
        asrb
        stb   v_tl                                    ; nb of full sized (middle) vertical chunks
        anda  #%00000111                              ; skip middle chunks that are 8 tiles high
        sta   b_v_tl                                  ; save nb of vertical tiles in bottom chunks

        ; load chunks
        ; --------------------
        lda   glb_map_chunk_pge
        _SetCartPageA

        ldb   u_v_tl                   ; first line begin with upper vertical chunk height
        stb   c_v_tl_bck

        ldd   y_off                    ; offset in top left chunk is horizontal and vertical
        std   c_y_off
        addd  x_off
        std   chunk_offset
@vloop
        stx   @start_pos_bck           ; position in chunk map
        stx   start_pos
        ldb   h_tl_bck                 ; restore nb of middle chunks (8 tiles width) on x axis for one row
        stb   h_tl
        ldd   b_loc                    ; load location in cycling buffer
        andb  #%10000000               ; compute line start
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
        ldd   #0
c_y_off equ   *-2
        std   chunk_offset
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
@a      lda   b_v_tl                   ; bottom
        beq   @end
        sta   c_v_tl_bck
@b      decb
        stb   v_tl
        ldd   #0
        std   c_y_off
        ldd   x_off
        std   chunk_offset             ; offset in next row of chunk is only horizontal
        jmp   @vloop
@end    rts

LoadChunk
        ldd   b_loc
        andb  #%10000000
        std   cl_pos                                  ; save line start for cycling buffer
        ldb   c_h_tl                                  ; preprocess line return
        lslb                                          ; buffer : 4 bytes per tile in width
        lslb
        lda   #%11111111
        negb
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
@b      stb   chk_idx_pge
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
        ldy   b_loc
        ldd   ,u++                                    ; load tile index in d (16 bits)
        bne   @a
        ldd   #0
        std   ,y
        jmp   NextCol
@a      stu   @dyn2
        sta   @dyn0
        anda  #%10000000
        sta   ,y
        lda   #0
@dyn0   equ   *-1
        anda  #%01111111
        std   @dyn1                                   ; multiply tile index by 3 to load tile page and addr
        _lsld
        addd  #0                                      ; (dynamic)
@dyn1   equ   *-2
        ldu   glb_map_tiles_adr
        leau  d,u
        lda   glb_map_tiles_pge
        _SetCartPageA                                 ; set tile index page
        pulu  a,x                                     ; a: tile routine page, x: tile routine address
        sta   1,y
        stx   2,y
        lda   #0
chk_idx_pge equ *-1
        _SetCartPageA                                 ; restore chunk definition page
        ldu   #0
@dyn2   equ *-2

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

        lda   glb_camera_move
        bne   @a
        rts
@a

        ; compute number of tiles to render
        ; saves one tile row or col when camera pos is a multiple of tile size
        ; ---------------------------------------------------------------------
        ldb   #tmb_vp_h_tiles-1               ; nb of tile in screen width 
        lda   <glb_camera_x_pos+1
        anda  #%00000111
        bne   @skip
        decb
@skip   stb   DBT_ccpt
        stb   DBT_ccpt_bck

        ldb   #tmb_vp_v_tiles               ; nb of tile in screen height
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
        ldb   <glb_camera_x_pos+1           ; col mask (0-32)
        andb  #%11111000                    ; tile width 8px (>>3) 
        lsrb                                ; col size 4 bytes (<<2)
        stb   @dyn2
        ldb   <glb_camera_y_pos+1
        anda  #%00000000
        andb  #%11110000                    ; line mask (0-16)
        _lsld                               ; tile height 16px (>>4) 
        _lsld                               ; line skip 128 bytes (<<7)
        _lsld
        addd  #0                            ; (dynamic) add x position to index 
@dyn2   equ   *-1
        addd  #tile_buffer
        tfr   d,u

        ldy   #tmb_hprio_tiles              ; high priority tiles queue

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
        tsta
        bpl   @low
        stb   ,y+
        stx   ,y++
        ldx   <glb_screen_location_1
        stx   ,y++
        ldx   <glb_screen_location_2
        stx   ,y++
        bra   @skip
@low    ldu   <glb_screen_location_2
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
@rts    leas  4,s               ; empty the stack
        lda   #0
        sta   ,y                ; end marker for high priority tiles
        rts

DBT_lcpt     fcb   0
DBT_ccpt     fcb   0

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

DrawHighPriorityBufferedTile
        ldy   #tmb_hprio_tiles
        bra   @entry
@loop
        ldu   3,y
        stu   <glb_screen_location_1
        ldu   5,y
        leay  7,y
        jsr   [-6,y]  ; y register should be saved and restored (it works without, only for small tiles)
@entry
        ldb   ,y
        stb   $E7E6
        bne   @loop
        rts

tmb_hprio_tiles
        fill  0,tmb_vp_h_tiles*tmb_vp_v_tiles*7 ; all tiles in high priority ... that's crazy
        fcb   0 ; end marker

        align 2048
tile_buffer
        fill  0,16*128