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

image_center_parity     equ dp_engine    ; byte
image_subset            equ dp_engine+1  ; word 
mapping_frame           equ dp_engine+3  ; word - ptr to page and routine address
page_draw_routine_val   equ dp_engine+5  ; byte - compilated sprite page
draw_routine_val        equ dp_engine+6  ; word - compilated sprite routine address
x1_pixel                equ dp_engine+8  ; word
y1_pixel                equ dp_engine+10 ; word
x_size                  equ dp_engine+12 ; word
y_size                  equ dp_engine+14 ; word

        setdp dp/256

BuildSprites
        anda  #0         ; init tmp variables
        sta   x_size
        sta   y_size

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
        anda  #render_hide_mask             ; skip hidden sprites
        bne   @nextobject1
;
        ; compute imageset
        ; ----------------
        ldx   #Img_Page_Index               ; this code set the active image subset based on mirror flags
        anda  #0           
        ldb   id,u                          ; get object id
        lda   d,x                           ; retrieve page that store imagesets for this object id
        _SetCartPageA        
        lda   render_flags,u
        anda  #render_xmirror_mask|render_ymirror_mask
        ldx   image_set,u                   ; get current imageset associated with this object
        ldb   image_center_offset,x
        stb   image_center_parity           ; store image center parity
        ldb   a,x
        beq   @nextobject1                  ; no defined subset images
        leax  b,x                           ; read imageset index
        stx   image_subset
;
        ; compute mapping frame
        ; ---------------------
        ; The image subset reference up to 4 version of an image
        ; Draw/Erase, Draw routines and shifted version by 1 pixel of these two routines
        ; The following code set the appropriate routine that will draw the image
        ; First thing is to check if the image position is odd or even
        ; and select the appropriate routine. If no routine is found, it will select the avaible routine.
;
        lda   render_flags,u
        anda  #render_playfieldcoord_mask
        beq   @a                            ; branch if position is already expressed in screen coordinate
        ldd   x_pos,u
        subd  glb_camera_x_pos
        bra   @b
@a      ldb   x_pixel,u                     ; compute mapping_frame 
@b      eorb  image_center_parity           ; case of odd image center switch shifted image with normal
        andb  #1                            ; index of sub image is encoded in two bits: 00|B0, 01|D0, 10|B1, 11|D1         
        aslb                                ; set bit1 for 1px shifted image  
        orb   #1                            ; set bit0 for overlay sprite
@c      lda   b,x
        beq   @nodefinedframe
        leax  a,x                           ; read image subset index
        stx   mapping_frame
        bra   >
@nodefinedframe
        eorb  #%00000010                    ; check if there is an alternate shifted image available
        beq   @d
        inc   image_center_parity           ; ajust offset for alternate
        bra   @e
@d      dec   image_center_parity
@e      lda   b,x
        beq   @nextobject1                  ; no defined frame, nothing will be displayed
        leax  a,x                           ; read image subset index
        stx   mapping_frame
!
        lda   page_draw_routine,x           ; save compiled sprite routine
        sta   page_draw_routine_val
        ldd   draw_routine,x
        std   draw_routine_val
;
        ; check out of range position 
        ; ---------------------------       
        lda   render_flags,u
        bita  #render_no_range_ctrl_mask
        lbne  @computescreenaddress         ; skip out of range control if option is set
        anda  #render_playfieldcoord_mask
        beq   @screencoordinates            ; branch if position is already expressed in screen coordinate
;
        ; playfield coordinates
        ldx   image_subset
        ldb   image_subset_x1_offset,x
        sex
        std   x1_pixel
        ldb   image_subset_y1_offset,x
        sex
        std   y1_pixel
        ldx   image_set,u
        ldd   image_x_size,x
        sta   x_size+1
        stb   y_size+1
;
        ldd   x_pos,u
        addd  x1_pixel
        addd  x_size
        cmpd  glb_camera_x_pos
        ble   @nextobject             ; out of range if x_pos + center x offset + width <= glb_camera_x_pos
;
        ldd   x_pos,u
        addd  x1_pixel
        subd  glb_camera_width
        cmpd  glb_camera_x_pos
        bge   @nextobject             ; out of range if x_pos + center x offset >= glb_camera_x_pos + glb_camera_width
;
        ldd   y_pos,u
        addd  y1_pixel
        addd  glb_camera_y_offset 
        cmpd  glb_camera_y_pos
        ble   @nextobject             ; out of range if top screen border is crossed : top screen >= y_pos + center y offset
;
        addd  y_size
        subd  #200 ; screen height
        cmpd  glb_camera_y_pos
        bge   @nextobject             ; out of range if bottom screen border is crossed : y_pos + center y offset + y size >= bottom screen
;
        ldd   x_pos,u                 ; convert playfield position to screen position
        addd  glb_camera_x_offset
        subd  glb_camera_x_pos
        stb   x_pixel,u
        ldd   y_pos,u
        addd  glb_camera_y_offset
        subd  glb_camera_y_pos
        stb   y_pixel,u        
        lda   x_pixel,u        
        bra   @computescreenaddress
@nextobject
        ldu   rsv_priority_prev_obj,u
        lbne  @process   
        rts
@screencoordinates
        ; screen coordinates
        ldb   y_pixel,u                     ; check if sprite is fully in screen vertical range
        ldx   image_subset
        addb  image_subset_y1_offset,x
        cmpb  #screen_bottom
        bhi   @nextobject
        cmpb  #screen_top
        blo   @nextobject        
        stb   y1_pixel+1
        ldx   image_set,u
        addb  image_y_size,x
        cmpb  #screen_bottom
        bhi   @nextobject
        cmpb  #screen_top
        blo   @nextobject        
        cmpb  y1_pixel+1                    ; check wrapping
        blo   @nextobject
;               
        lda   render_flags,u                ; check if sprite is fully in screen horizontal range
        bita  #render_xloop_mask
        bne   @setposition
;
        ldb   x_pixel,u
        ldx   image_subset
        addb  image_subset_x1_offset,x
        cmpb  #screen_right
        bhi   @nextobject
        cmpb  #screen_left
        blo   @nextobject
        stb   x1_pixel+1
        ldx   image_set,u
        addb  image_x_size,x
        cmpb  #screen_right
        bhi   @nextobject
        cmpb  #screen_left
        blo   @nextobject
        cmpb  x1_pixel+1                    ; check wrapping
        blo   @nextobject 
@setposition
        ldd   xy_pixel,u                    ; load x position (48-207) and y position (28-227) in one operation
        suba  #48                           ; move x ref. to 0
        bcc   >                             ; no carry, continue
        suba  #$60                          ; x-loop, skip x_pixel (160-255)
        decb                                ; get x position one line up
!       subb  #28                           ; move y ref. to 0
@computescreenaddress
        suba  image_center_parity
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
        lda   page_draw_routine_val
        _SetCartPageA        
        stu   @u                   
        ldu   glb_screen_location_2
        jsr   [draw_routine_val]            ; draw compilated sprite on screen
        ldu   #$0000
@u      equ   *-2
;
@sethide        
        lda   render_flags,u
        ora   #render_hide_mask             ; set hide flag
        sta   render_flags,u        
        ldu   rsv_priority_prev_obj,u
        lbne  @process   
        rts

                                                      *BuildSprites_P1_MultiDraw:
                                                      *        move.l  a4,-(sp)
                                                      *        lea     (Camera_X_pos).w,a4
                                                      *        movea.w art_tile(a0),a3
                                                      *        movea.l mappings(a0),a5
                                                      *        moveq   #0,d0
                                                      *        move.b  mainspr_width(a0),d0
                                                      *        move.w  x_pos(a0),d3
                                                      *        sub.w   (a4),d3
                                                      *        move.w  d3,d1
                                                      *        add.w   d0,d1
                                                      *        bmi.w   BuildSprites_P1_MultiDraw_NextObj
                                                      *        move.w  d3,d1
                                                      *        sub.w   d0,d1
                                                      *        cmpi.w  #320,d1
                                                      *        bge.w   BuildSprites_P1_MultiDraw_NextObj
                                                      *        addi.w  #128,d3
                                                      *        btst    #4,d4
                                                      *        beq.s   +
                                                      *        moveq   #0,d0
                                                      *        move.b  mainspr_height(a0),d0
                                                      *        move.w  y_pos(a0),d2
                                                      *        sub.w   4(a4),d2
                                                      *        move.w  d2,d1
                                                      *        add.w   d0,d1
                                                      *        bmi.w   BuildSprites_P1_MultiDraw_NextObj
                                                      *        move.w  d2,d1
                                                      *        sub.w   d0,d1
                                                      *        cmpi.w  #224,d1
                                                      *        bge.w   BuildSprites_P1_MultiDraw_NextObj
                                                      *        addi.w  #256,d2
                                                      *        bra.s   ++
                                                      *+
                                                      *        move.w  y_pos(a0),d2
                                                      *        sub.w   4(a4),d2
                                                      *        addi.w  #128,d2
                                                      *        cmpi.w  #-32+128,d2
                                                      *        blo.s   BuildSprites_P1_MultiDraw_NextObj
                                                      *        cmpi.w  #32+128+224,d2
                                                      *        bhs.s   BuildSprites_P1_MultiDraw_NextObj
                                                      *        addi.w  #128,d2
                                                      *+
                                                      *        moveq   #0,d1
                                                      *        move.b  mainspr_mapframe(a0),d1
                                                      *        beq.s   +
                                                      *        add.w   d1,d1
                                                      *        movea.l a5,a1
                                                      *        adda.w  (a1,d1.w),a1
                                                      *        move.w  (a1)+,d1
                                                      *        subq.w  #1,d1
                                                      *        bmi.s   +
                                                      *        move.w  d4,-(sp)
                                                      *        bsr.w   ChkDrawSprite_2P
                                                      *        move.w  (sp)+,d4
                                                      *+
                                                      *        ori.b   #$80,render_flags(a0)
                                                      *        lea     sub2_x_pos(a0),a6
                                                      *        moveq   #0,d0
                                                      *        move.b  mainspr_childsprites(a0),d0
                                                      *        subq.w  #1,d0
                                                      *        bcs.s   BuildSprites_P1_MultiDraw_NextObj
                                                      *
                                                      *-       swap    d0
                                                      *        move.w  (a6)+,d3
                                                      *        sub.w   (a4),d3
                                                      *        addi.w  #128,d3
                                                      *        move.w  (a6)+,d2
                                                      *        sub.w   4(a4),d2
                                                      *        addi.w  #256,d2
                                                      *        addq.w  #1,a6
                                                      *        moveq   #0,d1
                                                      *        move.b  (a6)+,d1
                                                      *        add.w   d1,d1
                                                      *        movea.l a5,a1
                                                      *        adda.w  (a1,d1.w),a1
                                                      *        move.w  (a1)+,d1
                                                      *        subq.w  #1,d1
                                                      *        bmi.s   +
                                                      *        move.w  d4,-(sp)
                                                      *        bsr.w   ChkDrawSprite_2P
                                                      *        move.w  (sp)+,d4
                                                      *+
                                                      *        swap    d0
                                                      *        dbf     d0,-
                                                      *; loc_16C7E:
                                                      *BuildSprites_P1_MultiDraw_NextObj:
                                                      *        movea.l (sp)+,a4
                                                      *        bra.w   BuildSprites_P1_NextObj