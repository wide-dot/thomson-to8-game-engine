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
        ;fill  0,16*128

        fill  0,4*128
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$25
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,$64,$3E,$7A
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
        fcb   0,0,0,0
;
        fill  0,2*128
