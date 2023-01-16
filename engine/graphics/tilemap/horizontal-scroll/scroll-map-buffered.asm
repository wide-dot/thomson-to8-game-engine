* ---------------------------------------------------------------------------
* Horizontal scroll with pre computed buffered map
* ------------------------------------------------
*
* This horizontal scroll moves by 1px
* The tilemap is set at build time with 4 bytes :
* 00 <00:page> <0000:address>
* there is no tile index, page|address point to compilated tile routine
* ---------------------------------------------------------------------------

        SETDP   dp/256

; parameters to set before using InitScroll and Scroll routines
scroll_vp_h_tiles         fcb   10  ; viewport tiles on x axis
scroll_vp_v_tiles         fcb   12  ; viewport tiles on y axis
scroll_tile_width         fcb   0   ; tile width
scroll_tile_height        fcb   0   ; tile height
scroll_vp_x_pos           fcb   0   ; viewport x location on screen
scroll_map_width          fcb   0   ; map width in tiles
scroll_map equ *+2
                          fdb   0
                          fdb   0
scroll_map_page equ *+1
                          fcb   0
                          fcb   0

; routine variables
tile_buffer               fdb   0
tile_buffer_page          fcb   0
scroll_tile_pos_offset    fcb   0   ; current camera x position offset from tile_pos
scroll_map_x_pos          fcb   0   ; current tile position in the map
scroll_stop               fcb   0   ; flag that stops scroll
scroll_frame              fcb   0   ; current scroll frame id 0-3
scroll_parity             fcb   0   ; current tileset (0:no shift, 1:shifted by 1 px to the left)

; tmp variables
scroll_lcpt               equ   dp_engine
scroll_ccpt               equ   dp_engine+1
scroll_loc_exg            equ   dp_engine+2

* ---------------------------------------------------------------------------
* InitScroll
* ----------
*
* ---------------------------------------------------------------------------

InitScroll
        lda   #3
        sta   scroll_frame                       ; first Scroll call will inc frame to 0
        ldd   #-1
        std   glb_camera_x_pos                   ; first Scroll call will inc camera to 0
        stb   scroll_tile_pos_offset             ; first Scroll call will inc offset to 0
        lda   scroll_tile_width                  ; set video memory steps between each tiles
        asra
        asra
        sta   scroll_m_step3
        sta   scroll_m_step4
        ldb   scroll_tile_width
        andb  #%00000010                         ; check if tile width is a multiple of 4px (2, 6, 10, 14, ...)
        beq   >                                  ; if so keep the memory steps the same
        ldb   #1
        stb   scroll_loc_offset
        inca
        sta   scroll_m_step1
        sta   scroll_m_step2
!       lda   scroll_tile_height                 ; set video memory byte offset for a tile height (40 bytes per line)
        ldb   #40
        mul
        std   s_line1
        std   s_line2
        lda   scroll_map_width                   ; compute map line size 
        ldb   #4
        mul
        std   map_line_width
        std   map_line_width2
        lda   scroll_vp_x_pos
        anda  #%11111110                         ; this routine only accept even position on screen for tiles
        sta   scroll_vp_x_pos
        rts

* ---------------------------------------------------------------------------
* Scroll
* ----------
* Drive scroll with a dedicated frame pattern :
* A A x x B B x x
* A : draw tiles
* A : draw tiles
* B : draw tiles shifted
* B : draw tiles shifted
* x : no draw
* ---------------------------------------------------------------------------

Scroll
; apply frame pattern
        lda   scroll_stop
        beq   >
        rts                                      ; scroll is stopped, return
!       clr   glb_camera_move                    ; desactivate tiles drawing
        ldb   scroll_frame                       ; load last frame number (0-3)
        incb                                     ; increment to current frame number
        andb  #%00000011                         ; modulo 4 to keep frame number btw 0-3
        stb   scroll_frame                       ; store frame id
        cmpb  #1                                 ; is frame 2 or 3 ? (no tile drawing)
        bgt   @end                               ; if so branch
        beq   @skip   
        ; move camera and swap between tiles and shifted tiles
        lda   scroll_parity                      ; swap tileset only on first of the 4 frames
        coma
        sta   scroll_parity
        ldx   #scroll_map_page
        ldb   a,x
        stb   tile_buffer_page
        asla
        ldx   #scroll_map
        ldx   a,x
        stx   tile_buffer
        inc   glb_camera_x_pos+1
        bcc   >
        inc   glb_camera_x_pos
!       lda   scroll_tile_pos_offset             ; rendering position offset for tiles
        inca
        cmpa  scroll_tile_width                  ; test for tile width
        bne   >
        inc   scroll_map_x_pos                   ; move next tile
        lda   #0                                 ; reinit offset   
!       sta   scroll_tile_pos_offset
@skip   lda   #1                                 ; frame 0 or 1 we want to draw tiles
        sta   <glb_force_sprite_refresh          ; force sprites to do a full refresh (background will be changed)
        sta   glb_camera_move                    ; set flag to activate tile drawing
        rts
@end    ldd   glb_camera_x_pos
        cmpd  #map_width-viewport_width          ; check end of map
        bne   >                                  ; if so no need to swap the tiles, only set scroll_stop
        inc   scroll_stop
!       rts

* ---------------------------------------------------------------------------
* DrawTiles
* ---------
*
* ---------------------------------------------------------------------------

DrawTiles
        lda   glb_camera_move
        bne   @a
        rts
@a

        ; disable page backup (page swap macros)
        ; mandatory if using T2 and direct access to E7E6
        lda   #0
        sta   glb_Page

        ; compute number of tiles to render
        ; saves one tile col when camera pos is a multiple of tile size
        ; ---------------------------------------------------------------------
        ldb   scroll_vp_h_tiles        ; nb of tile in screen width
        lda   scroll_tile_pos_offset
        bne   >
        decb
!       stb   scroll_ccpt              ; nb of tile to render in screen width
        stb   scroll_ccpt_bck
        stb   scroll_ccpt_bck2

        lda   scroll_vp_v_tiles                  ; nb of tile in screen height
        sta   scroll_lcpt

        ; compute top left tile position on screen
        ; ---------------------------------------------------------------------
        ldb   scroll_tile_pos_offset
        andb  #%11111110               ; the shifted tileset will be drawn at the same position as the unshifted version
        negb                           ; substract tile offset
        addb  scroll_vp_x_pos          ; add viewport offset
        addb  #80                      ; if tile need to be rendered off screen on the left get some margin that will be remove later
        lsrb                           ; x=x/2, a byte is made of two pixels
        lsrb                           ; x=x/2, RAMA RAMB interlace
        bcs   @ram2                    ; Branch if write must begin in RAM2 first
        lda   #$C0
        subd  #80/4                    ; remove margin in video memory size
        std   <glb_screen_location_2
        suba  #$20
        bra   >
@ram2   lda   #$A0
        subd  #80/4                    ; remove margin in video memory size
        std   <glb_screen_location_2
        addd  #$2001
!       std   <glb_screen_location_1
        std   s_loc1_1
        std   s_loc1_2

        ldd   <glb_screen_location_2
        subd  <glb_screen_location_1
        std   delta3
        std   delta4
        addd  #0
scroll_loc_offset equ *-1
        std   delta1
        std   delta2

        ; compute position in buffer
        ; ---------------------------------------------------------------------

        ldb   scroll_map_x_pos
        lda   #4
        mul                            ; tiles takes 4 bytes in buffer so x_pos*4 
        addd  tile_buffer              ; add base address

; **************************************
; * Tile rendering Loop
; **************************************

        ldy   <glb_screen_location_1   ; y is ptr to draw location in video memory

scroll_lloop
        ; tiles in col
        ; ****************
        tfr   d,u                      ; u is the ptr in map
        std   ls_pos1                  ; store position in map
        std   ls_pos2                  ; store position in map
        lda   tile_buffer_page
        sta   $E7E6
        jmp   scroll_cloop2

scroll_cloop1
        pulu  d,x                      ; get a: b:draw routine page, x:draw routine addr
@c      stb   $E7E6                    ; mount page to run tile rendering routine
        beq   empty_tile               ; if zero this is an empty tile
        pshs  u                        ; backup u before draw routine
        leau  ,y                       ; load location_2 for draw routine
        pshs  y                        ; backup y before draw routine
        leay  $1234,y
delta1  set   *-2
        sty   <glb_screen_location_1   ; sets location_1 for draw routine
        jsr   ,x                       ; call tile draw routine (glb_screen_location_1 will be used in this routine)
        puls  y,u
        lda   tile_buffer_page
        sta   $E7E6
        leay  40,y                     ; move ahead in video memory
scroll_m_step1 equ *-1
        dec   scroll_ccpt              ; decrement column cpt
        bne   scroll_cloop2            ; loop if tile remains

        lda   #0                       ; restore number of tiles to draw in column
scroll_ccpt_bck equ   *-1
        sta   scroll_ccpt

        ; last tile in col
        ; ****************
        pulu  d,x                      ; get a: b:draw routine page, y:draw routine addr
        stb   $E7E6
        bne   >
        inc   glb_alphaTiles           ; this is an empty tile so set transparency flag
        bra   @skip
!       pshs  u                        ; backup u before draw routine
        sty   <glb_screen_location_1   ; sets location_1 for draw routine
        leau  $1234,y                  ; load location_2 for draw routine
delta4  set   *-2
        pshs  y                        ; backup u before draw routine
        jsr   ,x
        puls  y,u
@skip

        ; next line
        ; ****************

        ldy   #0                       ; start of line in video memory
s_loc1_1 equ   *-2
        leay  $FFFF,y                  ; move in video memory by height of a tile (n lines)
s_line1 equ   *-2
        sty   s_loc1_1                 ; save for next line

        ldd   #0
ls_pos1 equ   *-2                      ; line start pos in map
        addd  #0                       ; move one line down in map
map_line_width equ *-2
        dec   scroll_lcpt              ; decrement line counter
        bne   scroll_lloop             ; loop until the end
        rts

empty_tile
        lda   tile_buffer_page
        sta   $E7E6
        inc   glb_alphaTiles           ; this is an empty tile so set transparency flag
        lda   scroll_ccpt
empty_tile_loop
        leay  40,y                     ; move ahead in video memory
scroll_m_step2 equ *-1
        deca
        beq   scroll_ccpt_bck-1        ; if no more tiles in col, branch to last tile in col
        ldb   1,u                      ; process next tile
        beq   >                        ; branch if tile is empty
        sta   scroll_ccpt              ; else render tile
        jmp   scroll_cloop2
!       leau  4,u                      ; move to next tile
        bra   empty_tile_loop2

; -----------------------------------------------------------------------------

scroll_cloop2
        pulu  d,x                      ; get a: b:draw routine page, x:draw routine addr
@c      stb   $E7E6                    ; mount page to run tile rendering routine
        beq   empty_tile2              ; if zero this is an empty tile
        pshs  u                        ; backup u before draw routine
        sty   <glb_screen_location_1   ; sets location_1 for draw routine
        leau  $1234,y                  ; load location_2 for draw routine
delta3  set   *-2
        pshs  y                        ; backup y before draw routine
        jsr   ,x                       ; call tile draw routine (glb_screen_location_1 will be used in this routine)
        puls  y,u
        lda   tile_buffer_page
        sta   $E7E6
        leay  40,y                     ; move ahead in video memory
scroll_m_step3 equ *-1
        dec   scroll_ccpt              ; decrement column cpt
        lbne  scroll_cloop1            ; loop if tile remains

        lda   #0                       ; restore number of tiles to draw in column
scroll_ccpt_bck2 equ   *-1
        sta   scroll_ccpt

        ; last tile in col
        ; ****************
        pulu  d,x                      ; get a: b:draw routine page, y:draw routine addr
        stb   $E7E6
        bne   >
        inc   glb_alphaTiles           ; this is an empty tile so set transparency flag
        bra   @skip
!       pshs  u                        ; backup u before draw routine
        leau  ,y                       ; load location_2 for draw routine
        pshs  y                        ; backup y before draw routine
        leay  $1234,y
delta2  set   *-2
        sty   <glb_screen_location_1   ; sets location_1 for draw routine
        jsr   ,x
        puls  y,u
@skip

        ; next line
        ; ****************

        ldy   #0                       ; start of line in video memory
s_loc1_2 equ   *-2
        leay  $FFFF,y                  ; move in video memory by height of a tile (n lines)
s_line2 equ   *-2
        sty   s_loc1_2                 ; save for next line

        ldd   #0
ls_pos2 equ   *-2                      ; line start pos in map
        addd  #0                       ; move one line down in map
map_line_width2 equ *-2
        dec   scroll_lcpt              ; decrement line counter
        lbne  scroll_lloop             ; loop until the end
        rts

empty_tile2
        lda   tile_buffer_page
        sta   $E7E6
        inc   glb_alphaTiles           ; this is an empty tile so set transparency flag
        lda   scroll_ccpt
empty_tile_loop2
        leay  40,y                     ; move ahead in video memory
scroll_m_step4 equ *-1
        deca
        beq   scroll_ccpt_bck2-1       ; if no more tiles in col, branch to last tile in col
        ldb   1,u                      ; process next tile
        beq   >                        ; branch if tile is empty
        sta   scroll_ccpt              ; else render tile
        jmp   scroll_cloop1
!       leau  4,u                      ; move to next tile
        jmp   empty_tile_loop
