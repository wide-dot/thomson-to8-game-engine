* ---------------------------------------------------------------------------
* WORK IN PROGRESS, THIS IS CRAP ...
* ---------------------------------------------------------------------------

        INCLUDE "./engine/graphics/tilemap/data-types/map-16bits.equ"
        SETDP   dp/256

tile_buffer fdb 0

; tmp variables
DBT_lcpt              equ   dp_engine
DBT_ccpt              equ   dp_engine+1

;tmb_vp_h_tiles        equ   18 ; viewport tiles on x axis
tmb_vp_h_tiles        equ   9  ; viewport tiles on x axis - TODO VAR !
;tmb_vp_v_tiles        equ   11 ; viewport tiles on y axis
tmb_vp_v_tiles        equ   12  ; viewport tiles on y axis - TODO VAR !

tmb_x_pos   fdb 0
tmb_x_tiles fcb 0

DrawBufferedTile
        lda   glb_camera_move
        bne   @a
        rts
@a

        ; disable page backup (page swap macros)
        ; mandatory if using T2 and direct access to E7E6
        anda  #0
        sta   glb_Page

        ; temporary solution to not div by 14 in the following code
        ldd   <glb_camera_x_pos
        subd  tmb_x_pos
        cmpd  #14
        bne   >
        inc   tmb_x_tiles
        ldd   glb_camera_x_pos
        std   tmb_x_pos
!       

        ; compute number of tiles to render
        ; saves one tile row or col when camera pos is a multiple of tile size
        ; ---------------------------------------------------------------------
        ldb   #tmb_vp_h_tiles              ; nb of tile in screen width
;        lda   <glb_camera_x_pos+1
        ; anda  #%00000111
;        anda  #%00001111 ; TODO VAR !
;        bne   @skip
;        decb
@skip   stb   DBT_ccpt
        stb   DBT_ccpt_bck

        ldb   #tmb_vp_v_tiles               ; nb of tile in screen height
;        lda   <glb_camera_y_pos+1
;        anda  #%00001111 ;  TODO VAR !
;        bne   @skip
;        decb
@skip   stb   DBT_lcpt

        ; compute top left tile position on screen
        ; ---------------------------------------------------------------------
        lda   <glb_camera_x_pos+1
        ;anda  #%00000110                    ; mask for 8px tile in width
        ;anda  #%00001111                    ; mask for 16px tile in width - TODO VAR !
        lda   tmb_x_pos
        nega
        ;adda  #12                           ; on screen position of camera
        adda  #10                           ; on screen position of camera - TODO VAR !

        ldb   <glb_camera_y_pos+1
        ;andb  #%00001110                    ; mask for 16px tile in height
        ;andb  #%00001111                    ; mask for 16px tile in height - TODO VAR !
        ;negb
        ;addb  #20                           ; on screen position of camera - TODO VAR !

        lsra                                ; x=x/2, sprites moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB interlace
        bcs   @RAM2First                    ; Branch if write must begin in RAM2 first
@RAM1First
        sta   @dyn1
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$C000                        ; (dynamic)
@dyn1   equ   *-1
        ;addd  #441 ; tileset should be declared with TILE8x16 center parameter in properties
        addd  #442 ; tileset should be declared with TILE8x16 center parameter in properties - TODO CAR !
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
        ;addd  #441 ; tileset should be declared with TILE8x16 center parameter in properties
        addd  #442 ; tileset should be declared with TILE8x16 center parameter in properties - TODO CAR !
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
        lda   tmb_x_pos
        asla
        asla
        addd  #0
@d      equ *-2

        addd  tile_buffer                              ; add base address

        ;ldu   #tmb_hprio_tiles+5                      ; high priority tiles queue
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

DBT_lloop
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

DBT_cloop
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

        dec   DBT_ccpt
        bne   DBT_cloop

        lda   #0
DBT_ccpt_bck equ   *-1
        sta   DBT_ccpt

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

        dec   DBT_lcpt
        bne   DBT_lloop
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
        lda   DBT_ccpt
@a      ;leay  2,y
        leay  4,y                       ; advances glb_screen_location_1 - TODO VAR !!!
        deca
        beq   DBT_ccpt_bck-1
        ldb   1,u
        beq   @b
        sta   DBT_ccpt
        jmp   DBT_cloop
@b      leau  4,u
        cmpu  #0
l_pos3  set   *-2
        bne   @a
        ldu   #0
l_pos4  set   *-2
        bra   @a
