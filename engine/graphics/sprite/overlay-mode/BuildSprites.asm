* ---------------------------------------------------------------------------
* CheckSpritesRefresh
* -------------------
* Subroutine to determine if sprites are gonna be erased and/or drawn
* Read Display Priority Structure (back to front)
* priority: 0 - unregistred
* priority: 1 - register non moving overlay sprite
* priority; 2-8 - register moving sprite (2:front, ..., 8:back)  
*
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
* input REG : none
* ---------------------------------------------------------------------------

_image_center_parity     equ dp_engine    ; word - a byte with left zero pad byte
_image_subset            equ dp_engine+2  ; word 
_mapping_frame           equ dp_engine+4  ; word - ptr to page and routine address
_page_draw_routine       equ dp_engine+6  ; byte - compilated sprite page
_draw_routine            equ dp_engine+7  ; word - compilated sprite routine address
_x1_pixel                equ dp_engine+9  ; word
_y1_pixel                equ dp_engine+11 ; word
_x_size                  equ dp_engine+13 ; word - a byte with left zero pad byte
_y_size                  equ dp_engine+15 ; word - a byte with left zero pad byte
_x_pos                   equ dp_engine+17 ; word
_y_pos                   equ dp_engine+19 ; word
_image_set               equ dp_engine+21 ; word
_nbchild                 equ dp_engine+23 ; byte
_render_flags            equ dp_engine+24 ; byte

        setdp dp/256

BuildSprites
        anda  #0         ; init tmp variables
        sta   _x_size
        sta   _y_size
        sta   _image_center_parity

        ldu   Tbl_Priority_Last_Entry+16
        beq   >
        jsr   @process   
!       ldu   Tbl_Priority_Last_Entry+14
        beq   >
        jsr   @process   
!       ldu   Tbl_Priority_Last_Entry+12
        beq   >
        jsr   @process   
!       ldu   Tbl_Priority_Last_Entry+10
        beq   >
        jsr   @process   
!       ldu   Tbl_Priority_Last_Entry+8
        beq   >
        jsr   @process               
!       ldu   Tbl_Priority_Last_Entry+6
        beq   >
        jsr   @process      
!       ldu   Tbl_Priority_Last_Entry+4
        beq   >
        jsr   @process  
!       ldu   Tbl_Priority_Last_Entry+2
        beq   >
        jmp   @process
!       rts
@nextobject1
        ldu   rsv_priority_prev_obj,u
        bne   @process   
        rts
@process
        lda   render_flags,u
        bita  #render_hide_mask             ; skip hidden sprites
        bne   @nextobject1 
        bita  #render_subobjects_mask       ; is this a child multisprite sprite object?
        lbne  @multisprite
        sta   _render_flags     
;
; ****************************************************
; SingleSprite rendering
; ----------------------
; ****************************************************
;
        ; compute imageset
        ; ----------------
;
;       load image index for this object       
        ldx   #Img_Page_Index
        anda  #0           
        ldb   id,u                          ; get object id
        lda   d,x                           ; retrieve page that store imagesets for this object id
        _SetCartPageA        
        ldx   image_set,u                   ; get current imageset associated with this object
;
;       store image properties in dp
        ldd   image_x_size,x                
        sta   _x_size+1
        stb   _y_size+1
        ldb   image_center_offset,x
        sex
        std   _image_center_parity          ; store image center parity
;
;       set the active image subset based on mirror flags
        lda   _render_flags
        anda  #render_xmirror_mask|render_ymirror_mask
        ldb   a,x
        beq   @nextobject1                  ; no defined subset images
        leax  b,x                           ; read imageset index that match image mirror
        stx   _image_subset
;
        ; compute mapping frame
        ; ---------------------
        ; The image subset reference up to 4 version of an image
        ; Draw/Erase, Draw routines and shifted version by 1 pixel of these two routines
        ; The following code set the appropriate routine that will draw the image
        ; First thing is to check if the image position is odd or even
        ; and select the appropriate routine. If no routine is found, it will select the avaible routine.
        ; -- only use the Draw routine here --
;
        lda   _render_flags
        anda  #render_playfieldcoord_mask
        beq   @a                            ; branch if position is already expressed in screen coordinate
        ldd   x_pos,u 
        std   _x_pos
        subd  glb_camera_x_pos
        bra   @b
@a      ldb   x_pixel,u                     ; compute mapping_frame 
@b      eorb  _image_center_parity+1        ; case of odd image center switch shifted image with normal
        andb  #1                            ; index of sub image is encoded in two bits: 00|B0, 01|D0, 10|B1, 11|D1         
        aslb                                ; set bit1 for 1px shifted image  
        orb   #1                            ; set bit0 for overlay sprite
@c      lda   b,x
        beq   @nodefinedframe
        leax  a,x                           ; read image subset index
        stx   _mapping_frame
        bra   >
@nodefinedframe
        eorb  #%00000010                    ; check if there is an alternate shifted image available
        beq   @d
        inc   _image_center_parity+1        ; ajust offset for alternate
        bra   @e
@d      dec   _image_center_parity+1
@e      lda   b,x
        beq   @nextobject1                  ; no defined frame, nothing will be displayed
        leax  a,x                           ; read image subset index
        stx   _mapping_frame
!
        lda   page_draw_routine,x           ; save compiled sprite routine
        sta   _page_draw_routine
        ldd   draw_routine,x
        std   _draw_routine
;
        ; check out of range position 
        ; ---------------------------       
        lda   _render_flags
        bita  #render_no_range_ctrl_mask
        lbne  @computescreenaddress         ; skip out of range control if option is set
        anda  #render_playfieldcoord_mask
        beq   @screencoordinates            ; branch if position is already expressed in screen coordinate
;
        ; playfield coordinates
        ldd   y_pos,u
        std   _y_pos
@processPlayfieldCoordinates
        ldx   _image_subset
        ldb   image_subset_x1_offset,x
        sex
        std   _x1_pixel
        ldb   image_subset_y1_offset,x
        sex
        std   _y1_pixel
;
        ldd   _x_pos 
        addd  _x1_pixel
        addd  glb_camera_x_offset 
        addd  glb_camera_x_offset ; use border from other side of the screen 
        cmpd  glb_camera_x_pos
        blt   @nextobject
;
        addd  _x_size
        subd  #160 ; screen width
        subd  glb_camera_x_offset ; use border from other side of the screen 
        subd  glb_camera_x_offset ; use border from other side of the screen 
        cmpd  glb_camera_x_pos
        bge   @nextobject
;
        ldd   _y_pos 
        addd  _y1_pixel
        addd  glb_camera_y_offset 
        cmpd  glb_camera_y_pos
        blt   @nextobject
;
        addd  _y_size
        subd  #200 ; screen height
        cmpd  glb_camera_y_pos
        bge   @nextobject
;
;       convert playfield position to screen position
;       ---------------------------------------------
        ldd   _y_pos 
        addd  glb_camera_y_offset
        subd  glb_camera_y_pos        
        stb   @ypx
        ldd   _x_pos                        ; convert playfield position to screen position
        addd  glb_camera_x_offset
        subd  _image_center_parity
        subd  glb_camera_x_pos
        bcc   >                             ; no carry, continue
        subb  #$60                          ; skip x position (ignore 160-255 values )
        dec   @ypx                          ; move y position one line up
!       tfr   b,a
        ldb   #0 ; d is loaded with xy_pixel
@ypx    equ   *-1         
        bra   @computescreenaddress
@nextobject
        ldu   rsv_priority_prev_obj,u
        lbne  @process   
        rts
@screencoordinates
        ; screen coordinates
        ldb   y_pixel,u                     ; check if sprite is fully in screen vertical range
        ldx   _image_subset
        addb  image_subset_y1_offset,x
        cmpb  #screen_bottom
        bhi   @nextobject
        cmpb  #screen_top
        blo   @nextobject        
        stb   _y1_pixel+1
        addb  _y_size+1
        cmpb  #screen_bottom
        bhi   @nextobject
        cmpb  #screen_top
        blo   @nextobject        
        cmpb  _y1_pixel+1                    ; check wrapping
        blo   @nextobject
;               
        lda   _render_flags                 ; check if sprite is fully in screen horizontal range
        bita  #render_xloop_mask
        bne   @setposition
;
        ldb   x_pixel,u
        ldx   _image_subset
        addb  image_subset_x1_offset,x
        cmpb  #screen_right
        bhi   @nextobject
        cmpb  #screen_left
        blo   @nextobject
        stb   _x1_pixel+1
        addb  _x_size+1
        cmpb  #screen_right
        bhi   @nextobject
        cmpb  #screen_left
        blo   @nextobject
        cmpb  _x1_pixel+1                   ; check wrapping
        blo   @nextobject 
@setposition
        ldd   xy_pixel,u                    ; load x position (48-207) and y position (28-227) in one operation
        suba  _image_center_parity+1
        suba  #48                           ; move x ref. to 0
        bcc   >                             ; no carry, continue
        suba  #$60                          ; x-loop, skip x_pixel (160-255)
        decb                                ; get x position one line up
!       subb  #28                           ; move y ref. to 0
@computescreenaddress
        lsra                                ; x=x/2, sprites moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB enterlace  
        bcs   @ram2                         ; Branch if write must begin in RAM2 first
@ram1
        sta   @lbyte1
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$C000                        ; (dynamic)
@lbyte1 equ   *-1
        std   glb_screen_location_2
        suba  #$20
        std   glb_screen_location_1     
        bra   >
@ram2
        sta   @lbyte2
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$A000                        ; (dynamic)
@lbyte2 equ   *-1      
        std   glb_screen_location_2
        addd  #$2001
        std   glb_screen_location_1
!
        lda   _page_draw_routine
        _SetCartPageA        
        stu   @u                 
        ldu   glb_screen_location_2
        jsr   [_draw_routine]               ; draw compilated sprite on screen
        ldu   #0                 
@u      equ   *-2
;
        lda   _render_flags
        ora   #render_hide_mask             ; set hide flag
        sta   render_flags,u        
@nextobject2
        ldu   rsv_priority_prev_obj,u
        lbne  @process   
@rts    rts
;
; ****************************************************
; MultiSprite rendering
; ---------------------
; ****************************************************
;
@multisprite
        ora   #render_hide_mask             ; set hide flag
        sta   render_flags,u  
        lda   mainspr_childsprites,u
        sta   _nbchild
        ldb   id,u                          ; get object id
        stb   @id
        leay  sub2_x_pos,u
@computeimageset
        ; compute imageset
        ; ----------------
        ldx   #Img_Page_Index               ; this code set the active image subset based on mirror flags
        lda   128,x                         ; (dynamic) retrieve page that store imagesets for this object id
@id     equ   *-1
        _SetCartPageA        
        ldx   4,y ; get child imageset
        stx   _image_set
        ldb   image_center_offset,x
        sex
        std   _image_center_parity          ; store image center parity
        ldb   ,x                            ; ND_ image
        leax  b,x                           ; read imageset index
        stx   _image_subset
        ldd   2,y
        std   _y_pos
        ldd   ,y
        std   _x_pos
        jsr   @processMulti
        dec   _nbchild
        beq   @nextobject2
        leay  next_subspr,y
        bra   @computeimageset
@processMulti

        ; compute mapping frame
        ; ---------------------
        ; The image subset reference up to 4 version of an image
        ; Draw/Erase, Draw routines and shifted version by 1 pixel of these two routines
        ; The following code set the appropriate routine that will draw the image
        ; First thing is to check if the image position is odd or even
        ; and select the appropriate routine. If no routine is found, it will select the avaible routine.
;
        subd  glb_camera_x_pos
        eorb  _image_center_parity+1        ; case of odd image center switch shifted image with normal
        andb  #1                            ; index of sub image is encoded in two bits: 00|B0, 01|D0, 10|B1, 11|D1         
        aslb                                ; set bit1 for 1px shifted image  
        orb   #1                            ; set bit0 for overlay sprite
@c      lda   b,x
        beq   @nodefinedframe
        leax  a,x                           ; read image subset index
        stx   _mapping_frame
        bra   >
@rts    rts
@nodefinedframe
        eorb  #%00000010                    ; check if there is an alternate shifted image available
        beq   @d
        inc   _image_center_parity+1        ; ajust offset for alternate
        bra   @e
@d      dec   _image_center_parity+1
@e      lda   b,x
        beq   @rts                          ; no defined frame, nothing will be displayed
        leax  a,x                           ; read image subset index
        stx   _mapping_frame
!
        lda   page_draw_routine,x           ; save compiled sprite routine
        sta   _page_draw_routine
        ldd   draw_routine,x
        std   _draw_routine
;
        ldx   _image_subset
        ldb   image_subset_x1_offset,x
        sex
        std   _x1_pixel
        ldb   image_subset_y1_offset,x
        sex
        std   _y1_pixel
        ldx   _image_set
        ldd   image_x_size,x
        sta   _x_size+1
        stb   _y_size+1
;
        ldd   _x_pos 
        addd  _x1_pixel
        addd  glb_camera_x_offset 
        addd  glb_camera_x_offset ; use border from other side of the screen 
        cmpd  glb_camera_x_pos
        blt   @rts
;
        addd  _x_size
        subd  #160 ; screen width
        subd  glb_camera_x_offset ; use border from other side of the screen 
        subd  glb_camera_x_offset ; use border from other side of the screen 
        cmpd  glb_camera_x_pos
        bge   @rts
;
        ldd   _y_pos 
        addd  _y1_pixel
        addd  glb_camera_y_offset 
        cmpd  glb_camera_y_pos
        blt   @rts
;
        addd  _y_size
        subd  #200 ; screen height
        cmpd  glb_camera_y_pos
        bge   @rts
;
        ldd   _y_pos 
        addd  glb_camera_y_offset
        subd  glb_camera_y_pos        
        stb   @ypx
        ldd   _x_pos                        ; convert playfield position to screen position
        addd  glb_camera_x_offset
        subd  _image_center_parity
        subd  glb_camera_x_pos
        bcc   >                             ; no carry, continue
        subb  #$60                          ; skip x position (ignore 160-255 values )
        dec   @ypx                          ; move y position one line up
!       tfr   b,a
        ldb   #0 ; d is loaded with xy_pixel
@ypx    equ   *-1        
        lsra                                ; x=x/2, sprites moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB enterlace  
        bcs   @ram2                         ; Branch if write must begin in RAM2 first
@ram1
        sta   @lbyte1
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$C000                        ; (dynamic)
@lbyte1 equ   *-1
        std   glb_screen_location_2
        suba  #$20
        std   glb_screen_location_1     
        bra   >
@ram2
        sta   @lbyte2
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$A000                        ; (dynamic)
@lbyte2 equ   *-1      
        std   glb_screen_location_2
        addd  #$2001
        std   glb_screen_location_1
!
        lda   _page_draw_routine
        _SetCartPageA        
        pshs  u,y                 
        ldu   glb_screen_location_2
        jsr   [_draw_routine]               ; draw compilated sprite on screen
        puls  u,y,pc   