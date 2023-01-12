* ---------------------------------------------------------------------------
* Horizontal scroll with pre computed buffered map
* ------------------------------------------------
*
* The tilemap is set at build time with 4 bytes :
* 00 <00:page> <0000:address>
* there is no tile index, page|address point to compilated tile routine
* ---------------------------------------------------------------------------

        SETDP   dp/256

; parameters to set before using InitScroll and Scroll routines
scroll_vp_h_tiles         fcb   10  ; viewport tiles on x axis
scroll_vp_v_tiles         fcb   12  ; viewport tiles on y axis
scroll_vp_x_pos           fcb   0   ; viewport x location on screen
scroll_tile_width         fcb   0   ; tile width
scroll_map equ *+2
                          fdb   0
                          fdb   0
scroll_map_page equ *+1
                          fcb   0
                          fcb   0

; routine variables
tile_buffer               fdb   0
tile_buffer_page          fdb   0
scroll_tile_pos_offset    fcb   0   ; current camera x position offset from tile_pos
scroll_tile_pos_offset_b  fcb   0            
scroll_map_x_pos          fcb   0   ; current tile position in the map
scroll_stop               fcb   0   ; flag that stops scroll
scroll_frame              fcb   0   ; current scroll frame id 0-3
scroll_parity             fcb   0   ; current tileset (0:no shift, 1:shifted by 1 px to the left)

; tmp variables
scroll_lcpt               equ   dp_engine
scroll_ccpt               equ   dp_engine+1

* ---------------------------------------------------------------------------
* InitScroll
* ----------
*
* ---------------------------------------------------------------------------

InitScroll
        ldd   #-1
        std   glb_camera_x_pos                   ; first Scroll call will inc camera to 0
        lda   #1
        stb   scroll_tile_pos_offset_b           ; first Scroll call will dec offset to 0
        ldb   scroll_vp_v_tiles                  ; nb of tile in screen height
        stb   scroll_lcpt
        neg   scroll_tile_width                  ; saves some cycles in computation
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
        ldb   scroll_frame                       ; load actual frame number (0-3)
        cmpb  #1                                 ; is frame 2 or 3 ? (no tile drawing)
        bgt   >                                  ; if so branch
        lda   #1                                 ; else frame 0 or 1 we want to draw tiles
        sta   <glb_force_sprite_refresh          ; force sprites to do a full refresh (background will be changed)
        sta   glb_camera_move                    ; set flag to activate tile drawing
!       incb                                     ; increment to next frame number
        cmpb  #4                                 ; loop frames between 0-3 
        beq   >
        stb   scroll_frame                       ; store next frame id
        rts
!       ldb   #0                                 ; reset next frame id
        stb   scroll_frame

; move camera and swap between tiles and shifted tiles
        ldd   glb_camera_x_pos
        addd  #1
        cmpd  #map_width-viewport_width+1        ; check end of map
        beq   >                                  ; if so no need to swap the tiles, only set scroll_stop
        std   glb_camera_x_pos
        lda   scroll_tile_pos_offset_b           ; rendering position offset for tiles
        inca
        cmpa  scroll_tile_width                  ; test for tile width
        bne   >
        inc   scroll_map_x_pos                   ; move next tile
        lda   #0                                 ; reinit offset   
!       sta   scroll_tile_pos_offset_b
        lda   scroll_parity                      ; swap tileset
        coma
        sta   scroll_parity
        ldx   #scroll_map_page
        ldb   a,x
        stb   tile_buffer_page
        asla
        ldx   #scroll_map
        ldx   a,x
        stx   tile_buffer
        rts
!       inc   scroll_stop
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
        anda  #0
        sta   glb_Page

        ; compute number of tiles to render
        ; saves one tile col when camera pos is a multiple of tile size
        ; ---------------------------------------------------------------------
        ldb   scroll_vp_h_tiles              ; nb of tile in screen width
        lda   scroll_tile_pos_offset_b
        beq   >
        incb
!       stb   scroll_ccpt
        stb   scroll_ccpt_bck

        ; compute top left tile position on screen
        ; ---------------------------------------------------------------------
        lda   scroll_vp_x_pos
        lsra                                ; x=x/2, tiles moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB interlace
        bcs   @RAM2First                    ; Branch if write must begin in RAM2 first
@RAM1First
        sta   @dyn1
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$C000                        ; (dynamic)
@dyn1   equ   *-1

        subd  scroll_tile_pos_offset
        ;addd  #441 ; tileset should be declared with TILE8x16 center parameter in properties
        ;addd  #442 ; tileset should be declared with TILE8x16 center parameter in properties - TODO CAR !
        std   <glb_screen_location_2
        suba  #$20
        std   <glb_screen_location_1
        bra   @end
@RAM2First
        sta   @dyn2
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$A000                        ; (dynamic)
@dyn2   equ   *-1

        suba  scroll_tile_pos_offset
        ;addd  #441 ; tileset should be declared with TILE8x16 center parameter in properties
        ;addd  #442 ; tileset should be declared with TILE8x16 center parameter in properties - TODO CAR !
        std   <glb_screen_location_2
        addd  #$2001
        std   <glb_screen_location_1
@end    std   s_loc1

        ldd   <glb_screen_location_2
        subd  <glb_screen_location_1
        std   delta
        std   delta2
        ;std   delta3

        ; compute position in cycling buffer
        ; ---------------------------------------------------------------------

; OPTIM SAM
        ldb   <glb_camera_y_pos+1                     
        lda   #256/16                                 ; each 16px steps in y add $100 - TODO VAR !
        mul
        std   @d
        ;ldd   <glb_camera_x_pos
        ;andb  #%11110000                              ; each 16px steps in x add $04 - TODO VAR !
        ;_lsrd ; TODO VAR !
        ;_lsrd ; TODO VAR !
        lda   scroll_tile_width
        asla
        asla
        addd  #0
@d      equ *-2

        addd  tile_buffer                              ; add base address

        ;ldu   #scroll_hprio_tiles+5                      ; high priority tiles queue
        ;stu   hi_ptr

; **************************************
; * Tile rendering Loop
; **************************************

        ; OPTIM SAM: ici l'idée est de garder le maximum de trucs dans les registres
        ; car les accès mémoire sont couteux. U contient alors les données sur le
        ; tile_buffer. Le PULU effectue le +4, et le modulo (buffer 128 octets)
        ; se fait par CMPU/BNE qui est finalement le plus rapide (8 cycles l'essentiel
        ; du temps) car on accède pas à la mémoire. Y contient glb_screeb_location_1
        ; lequel n'est mis à jour que lorsque c'est necessaire (paresseusement). Ainsi
        ; sur les tiles vide on va très très vite. La variable glb_screeb_location_2
        ; est elle aussi mise à jour que lorsque c'est nécéssaire, sa valeur étant
        ; déduite de glb_screen_location_1 par un offset constant pré-calculé. Donc au
        ; final sur les tiles vides (au moins la moitié des cas), la boucle revient
        ; à faire PULU et LEAY. C'est très très rapide, et tout tient dans 128 octets
        ; ce qui permet d'utiliser des sauts 8 bits.

        ldy   <glb_screen_location_1

scroll_lloop
        ; tiles in col
        ; ****************
        tfr   d,u
        std   ls_pos
        ;andb  #%10000000 - TODO VAR !
        std   l_pos2
        std   l_pos4
        ;addd  #%10000000 - TODO VAR !
        std   l_pos
        std   l_pos3

scroll_cloop
        pulu  d,x                       ; get a: b:draw routine page, x:draw routine addr
        cmpu  #0
l_pos   set   *-2
        bne   @c
        ldu   #0
l_pos2  set   *-2
@c      stb   $E7E6
        beq   empty_tile
        ;tsta
        ;bmi   highpri
loc_tmp equ   glb_screen_location_2
        stu   <loc_tmp                  ; saves U
        sty   <glb_screen_location_1    ; sets location_1 for draw routine
        leau  $1234,y                   ; load location_2 for draw routine
delta   set   *-2
        sty   @y
        jsr   ,x                        ; call tile draw routine (glb_screen_location_1 will be used in this routine)
        ldy   #0
@y      equ   *-2
        ldu   <loc_tmp                  ; restore U
NXT_cloop
        ;leay  2,y                       ; advances glb_screen_location_1
        leay  4,y                       ; advances glb_screen_location_1 - TODO VAR !!!

        dec   scroll_ccpt
        bne   scroll_cloop

        lda   #0
scroll_ccpt_bck equ   *-1
        sta   scroll_ccpt

        ; last tile in col
        ; ****************

        pulu  d,x                       ; get a: b:draw routine page, y:draw routine addr
        stb   $E7E6
        bne   @a
        inc   glb_alphaTiles            ; if a tile contains transparency, set the tag
        bra   @skip
@a      sty   <glb_screen_location_1    ; sets location_1 for draw routine
        leau  $1234,y                   ; load location_2 for draw routine
delta2  set   *-2
        sty   @y
        jsr   ,x
        ldy   #0
@y      equ   *-2
@skip

        ; next line
        ; ****************

        ldy   #0
s_loc1  equ   *-2
        leay  40*16,y ; TODO - VAR !
        sty   s_loc1

        ldd   #0
ls_pos  equ   *-2               ; line start pos
        ;addd  #128 ; TODO - VAR !
        inca ; TODO - VAR !
        ;anda  #%00000111
        suba  tile_buffer
        cmpa  #10 ; TODO - VAR ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! end buffer $80+ nb lignes de la map: 10 dans notre cas
        bne   >
        lda   #0
!       adda  tile_buffer  ; add base address

        dec   scroll_lcpt
        bne   scroll_lloop
@rts    ;ldx   hi_ptr
        ;clr   -5,x              ; end marker for high priority tiles
        rts

highpri ;stu   <loc_tmp
        ;ldu   #0
hi_ptr  set   *-2
        ;pshu  b,x,y                     ; saves prio,draw routine addr,location_1
        ;leax  $1234,y                   ; compute location_2
delta3  set   *-2
        ;stx   5,u                       ; save in high prio queue
        ;leau  7+5,u
        ;stu   hi_ptr
        ;ldu   <loc_tmp
        ;bra   NXT_cloop

empty_tile
        inc   glb_alphaTiles
        lda   scroll_ccpt
@a      ;leay  2,y
        leay  4,y                       ; advances glb_screen_location_1 - TODO VAR !!!
        deca
        beq   scroll_ccpt_bck-1
        ldb   1,u
        beq   @b
        sta   scroll_ccpt
        jmp   scroll_cloop
@b      leau  4,u
        cmpu  #0
l_pos3  set   *-2
        bne   @a
        ldu   #0
l_pos4  set   *-2
        bra   @a
