* ---------------------------------------------------------------------------
* Horizontal scroll with pre computed buffered map
* ------------------------------------------------
*
* This horizontal scroll moves by 1px
* The tilemap is set at build time with 3 bytes :
* <00:page> <0000:address>
* there is no tile index, page|address point to compilated tile routine
* as an horizontal scroll, data are arranged in columns
* ---------------------------------------------------------------------------

        SETDP   dp/256

; parameters to set before using InitScroll and Scroll routines
scroll_wait_frames        fcb   0   ; number of frames to wait between key frames
scroll_vp_h_tiles         fcb   0   ; viewport tiles on x axis
scroll_vp_v_tiles         fcb   0   ; viewport tiles on y axis
scroll_tile_width         fcb   0   ; tile width
scroll_tile_height        fcb   0   ; tile height
scroll_vp_x_pos           fcb   0   ; viewport x location on screen (odd value will be converted to even position)
scroll_vp_y_pos           fcb   0   ; viewport y location on screen
scroll_map_width          fcb   0   ; map width in tiles
scroll_map equ *+2
                          fdb   0
                          fdb   0
scroll_map_page equ *+1
                          fcb   0
                          fcb   0

; private variables
tile_buffer               fdb   0
tile_buffer_page          fcb   0
scroll_remain_frames      fcb   0   ; countdown to next scroll step
scroll_tile_pos_offset    fcb   0   ; current camera x position offset from tile_pos
scroll_map_pos            fdb   0   ; current tile position in the map
scroll_stop               fcb   0   ; flag that stops scroll
scroll_frame              fcb   0   ; current scroll frame id 0-3
scroll_parity             fcb   0   ; current tileset (0:no shift, 1:shifted by 1 px to the left)

; tmp variables
scroll_lcnt               equ   dp_engine
scroll_ccnt               equ   dp_engine+1

* ---------------------------------------------------------------------------
* InitScroll
* ----------
*
* ---------------------------------------------------------------------------

InitScroll
        lda   #0
        sta   scroll_frame
        sta   scroll_parity
        ldd   #-1
        std   glb_camera_x_pos                   ; first Scroll call will inc camera to 0
        stb   scroll_tile_pos_offset             ; first Scroll call will inc offset to 0

        lda   scroll_tile_height                 ; set video memory steps between each tiles in line
        ldb   #40
        mul
        std   scroll_ml_step1
        std   scroll_ml_step2

        lda   scroll_tile_width                  ; set video memory steps between each tiles in columns
        asra
        asra
        sta   scroll_mc_step

        lda   scroll_vp_x_pos
        anda  #%11111110                         ; this routine only accept even position on screen for tiles
        sta   scroll_vp_x_pos

        lda   scroll_wait_frames
        sta   scroll_remain_frames

        ldd   scroll_map+2
        std   scroll_map_pos
        rts

* ---------------------------------------------------------------------------
* Scroll
* ----------
* Drive scroll at a constant framerate
* ---------------------------------------------------------------------------

Scroll
        clr   glb_camera_move                    ; desactivate tiles drawing
        lda   scroll_stop
        beq   >
        rts                                      ; scroll is stopped, return
!       ldb   scroll_frame                       ; load frame number
        beq   @keyfrm                            ; frame 0 is the key frame
        cmpb  #1
        bne   @skipfrm
        bra   @updbuf
@keyfrm
        lda   scroll_remain_frames
        suba  Vint_Main_runcount
        bpl   >
        lda   scroll_wait_frames                 ; next frame will be keyframe
        bra   @nxtkey
!       incb                                     ; next frame will not be key frame
        stb   scroll_frame
@nxtkey sta   scroll_remain_frames
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
        ldd   glb_camera_x_pos
        addd  #1
        std   glb_camera_x_pos
        cmpd  #map_width-viewport_width          ; check end of map (only when the 2 buffers are updated)
        bne   >                                  ; if so no need to swap the tiles, only set scroll_stop
        inc   scroll_stop
!       lda   scroll_tile_pos_offset             ; rendering position offset for tiles
        inca
        cmpa  scroll_tile_width                  ; test for tile width
        bne   >
        lda   scroll_vp_v_tiles
        ldb   #3                                 ; a tile is 3 bytes in map (page, addr)
        mul
        addd  scroll_map_pos
        std   scroll_map_pos                     ; move next tile column
        lda   #0                                 ; reinit offset   
!       sta   scroll_tile_pos_offset
        lda   #1                                 ; frame 0 we want to draw tiles
        sta   <glb_force_sprite_refresh          ; force sprites to do a full refresh (background will be changed)
        sta   glb_camera_move                    ; set flag to activate tile drawing
        rts
@updbuf
        lda   #1                                 ; frame 1 we want to draw tiles
        sta   <glb_force_sprite_refresh          ; force sprites to do a full refresh (background will be changed)
        sta   glb_camera_move                    ; set flag to activate tile drawing
@skipfrm
        incb                                     ; no frame to draw
        lda   scroll_remain_frames
        suba  Vint_Main_runcount
        sta   scroll_remain_frames
        bpl   >
        lda   scroll_wait_frames
        sta   scroll_remain_frames
        ldb   #0                                 ; next frame is key frame 0
!       stb   scroll_frame  
        rts

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
        ; add one tile col when camera pos is not a multiple of tile size
        ; ---------------------------------------------------------------------
        lda   scroll_vp_h_tiles        ; nb of tile in screen width
        ldb   scroll_tile_pos_offset
        beq   >
        inca
!       sta   scroll_ccnt              ; nb of tile column to render

        ; compute top left tile position on screen
        ; ---------------------------------------------------------------------
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

        ldd   <glb_screen_location_2
        subd  <glb_screen_location_1
        std   delta

; **************************************
; * Tile rendering Loop
; **************************************
        ldy   <glb_screen_location_1   ; y is ptr to draw location in video memory
        lda   scroll_vp_y_pos          ; apply vertical vieport offset
        ldb   #40
        mul
        leay  d,y
        sty   start_pos

        ldu   scroll_map_pos
        ldd   tile_buffer
        leau  d,u

        lda   tile_buffer_page
        sta   $E7E6

scroll_cloop                           ; column loop
        lda   scroll_vp_v_tiles
        sta   scroll_lcnt

scroll_lloop                           ; line loop
        pulu  b,x                      ; get b:draw routine page, x:draw routine addr
@c      stb   $E7E6                    ; mount page to run tile rendering routine
        beq   empty_tile               ; if zero this is an empty tile
        sty   <glb_screen_location_1   ; sets location_1 for draw routine
        pshs  u
        leau  $1234,y                  ; load location_2 for draw routine
delta   set   *-2
        jsr   ,x                       ; call tile draw routine (glb_screen_location_1 will be used in this routine)
        puls  u
        lda   tile_buffer_page
        sta   $E7E6
        ldy   <glb_screen_location_1
        leay  $1234,y                  ; move ahead in video memoryone tile down
scroll_ml_step1 equ *-2
        dec   scroll_lcnt              ; decrement line cnt
        bne   scroll_lloop             ; loop if tile remains

scroll_end_line
        dec   scroll_ccnt              ; decrement column cnt
        beq   @rts
        ldy   #0                       ; restore column start pos
start_pos equ *-2
        leay  40,y
scroll_mc_step equ *-1
        sty   start_pos
        bra   scroll_cloop             ; loop until the end
@rts    rts

empty_tile
        lda   tile_buffer_page
        sta   $E7E6
        lda   scroll_lcnt
empty_tile_loop
        leay  $1234,y                  ; move ahead in video memoryone tile down
scroll_ml_step2 equ *-2
        deca
        beq   scroll_end_line          ; if no more tiles in line, branch
        ldb   1,u                      ; process next tile
        beq   >                        ; branch if tile is empty
        sta   scroll_lcnt              ; else render tile
        bra   scroll_lloop
!       leau  3,u                      ; move to next tile
        bra   empty_tile_loop

* ---------------------------------------------------------------------------
* Scroll_JumpToPos
*
* A = final position in map (in tiles)
* B = tiles to pre-scroll before position
* ---------------------------------------------------------------------------

Scroll_PreScrollTo
        stb   @prescroll_width
        suba  @prescroll_width
        ldb   scroll_vp_v_tiles
        aslb
        addb  scroll_vp_v_tiles        ; position is x * map vertical height * 3 bytes (page, addr)
        mul
        std   scroll_map_pos           ; position in map data
        ldb   scroll_tile_width
        mul
        subd  #1                       ; camera x_pos must be initialized to desired pos -1
        std   glb_camera_x_pos
        lda   #0
        sta   scroll_frame
        sta   scroll_parity
        deca                           ; tile_pos_offset must be initialized to -1
        sta   scroll_tile_pos_offset
        lda   scroll_tile_width
        ldb   @prescroll_width
        mul
        addd  glb_camera_x_pos
        std   @limit
!       ldb   #-1
        stb   scroll_remain_frames     ; force refresh
        jsr   Scroll
        jsr   DrawTiles
        _SwitchScreenBuffer
        ldd   glb_camera_x_pos
        cmpd  #0
@limit equ *-2
        bmi   <
        rts
@prescroll_width fcb 0