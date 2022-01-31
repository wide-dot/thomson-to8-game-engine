* ---------------------------------------------------------------------------
* CheckSpritesRefresh
* -------------------
* Subroutine to determine if sprites are gonna be erased and/or drawn
* Read Display Priority Structure (back to front)
* priority: 0 - unregistred
* priority: 1 - register non moving overlay sprite
* priority; 2-8 - register moving sprite (2:front, ..., 8:back)  
*
* input REG : none
* ---------------------------------------------------------------------------

cur_priority            fdb   $00
cur_ptr_sub_obj_erase   fdb   $0000
cur_ptr_sub_obj_draw    fdb   $0000

glb_camera_x_pos        fdb   $0000 ; camera x position in palyfield coordinates
glb_camera_y_pos        fdb   $0000 ; camera y position in palyfield coordinates
                                
* ---------------------------------------------------------------------------
* Sub Priority Objects List - SOL
* ---------------------------------------------------------------------------

Tbl_Sub_Object_Erase          fill  0,nb_graphical_objects*2    ; entries of objects that have erase flag in the order back to front
Tbl_Sub_Object_Draw           fill  0,nb_graphical_objects*2    ; entries of objects that have draw flag in the order back to front                                
                                           
CheckSpritesRefresh

CSR_Start
        ldd   #Tbl_Sub_Object_Erase
        std   cur_ptr_sub_obj_erase
        ldd   #Tbl_Sub_Object_Draw
        std   cur_ptr_sub_obj_draw
        lda   glb_Cur_Wrk_Screen_Id         ; read current screen buffer for write operations
        bne   CSR_SetBuffer1
        
CSR_SetBuffer0        
        lda   #rsv_buffer_0                 ; set offset to object variables that belongs to screen buffer 0
        sta   CSR_ProcessEachPriorityLevel+2    
CSR_P8B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+16 ; read DPS from priority 8 to priority 1
        beq   CSR_P7B0
        lda   #$08
        sta   cur_priority        
        jsr   CSR_ProcessEachPriorityLevel   
CSR_P7B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+14
        beq   CSR_P6B0
        lda   #$07
        sta   cur_priority        
        jsr   CSR_ProcessEachPriorityLevel   
CSR_P6B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+12
        beq   CSR_P5B0
        lda   #$06
        sta   cur_priority        
        jsr   CSR_ProcessEachPriorityLevel   
CSR_P5B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+10
        beq   CSR_P4B0
        lda   #$05
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel   
CSR_P4B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+8
        beq   CSR_P3B0
        lda   #$04
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel               
CSR_P3B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+6
        beq   CSR_P2B0
        lda   #$03
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel      
CSR_P2B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+4
        beq   CSR_P1B0
        lda   #$02
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel  
CSR_P1B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+2
        beq   CSR_rtsB0
        lda   #$01
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel
CSR_rtsB0        
        rts
        
CSR_SetBuffer1       
        lda   #rsv_buffer_1                 ; set offset to object variables that belongs to screen buffer 1
        sta   CSR_ProcessEachPriorityLevel+2        
CSR_P8B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+16 ; read DPS from priority 8 to priority 1
        beq   CSR_P7B1
        lda   #$08
        sta   cur_priority        
        jsr   CSR_ProcessEachPriorityLevel   
CSR_P7B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+14
        beq   CSR_P6B1
        lda   #$07
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel   
CSR_P6B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+12
        beq   CSR_P5B1
        lda   #$06
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel   
CSR_P5B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+10
        beq   CSR_P4B1
        lda   #$05
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel   
CSR_P4B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+8
        beq   CSR_P3B1
        lda   #$04
        sta   cur_priority
        jsr   CSR_ProcessEachPriorityLevel               
CSR_P3B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+6
        beq   CSR_P2B1
        lda   #$03
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel      
CSR_P2B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+4
        beq   CSR_P1B1
        lda   #$02
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel  
CSR_P1B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+2
        beq   CSR_rtsB1
        lda   #$01
        sta   cur_priority                       
        jsr   CSR_ProcessEachPriorityLevel
CSR_rtsB1        
        rts

CSR_ProcessEachPriorityLevel
        leax  16,u                          ; dynamic offset, x point to object variables relative to current writable buffer (beware that rsv_buffer_0 and rsv_buffer_1 should be equ >=16)
        
CSR_CheckDelHide
        lda   render_flags,u
        anda  #render_hide_mask|render_todelete_mask
        lbne  CSR_DoNotDisplaySprite      

CSR_CheckRefresh        
        lda   rsv_render_flags,u
        anda  #rsv_render_checkrefresh_mask ; branch if checkrefresh is true
        lbne  CSR_CheckErase

CSR_UpdSpriteImageBasedOnMirror

        ; an image set is made of 1 to 4 image subsets
        ; each subset represent a mirrored version of the image (N: normal, X: x mirror, Y: y mirror, XY: xy mirror)
        ; this code set the active image subset based on mirror flags

        lda   rsv_render_flags,u
        ora   #rsv_render_checkrefresh_mask
        sta   rsv_render_flags,u            ; set checkrefresh flag to true
        
        ldy   #Img_Page_Index               ; call page that store imageset for this object
        lda   #$00
        ldb   id,u
        lda   d,y
        _SetCartPageA        
        
        lda   render_flags,u                ; set image to display based on x and y mirror flags
        anda  #render_xmirror_mask|render_ymirror_mask
        ldy   image_set,u
        ldb   image_center_offset,y
        stb   rsv_image_center_offset,u        
        ldb   a,y
        leay  b,y                           ; read image set index
        sty   rsv_image_subset,u
        
CSR_CheckPlayFieldCoord
        lda   render_flags,u
        anda  #render_playfieldcoord_mask
        beq   CSR_ComputeMappingFrame       ; branch if position is already expressed in screen coordinate

        ; purpose here is to check if image coordinate in the playfield
        ; can be converted to screen position, if not it is flagged out of range

        ldd   x_pos,u
        subd  glb_camera_x_pos
        lblo  CSR_SetOutOfRange             ; out of range if x_pos < glb_camera_x_pos
        tsta 
        lbne  CSR_SetOutOfRange             ; out of range if x_pos + 256 > glb_camera_x_pos
        stb   x_pixel,u

        ldd   y_pos,u
        subd  glb_camera_y_pos
        lblo  CSR_SetOutOfRange             ; out of range if y_pos < glb_camera_y_pos
        tsta 
        lbne  CSR_SetOutOfRange             ; out of range if y_pos + 256 > glb_camera_y_pos
        stb   y_pixel,u
        bra   CSR_ComputeMappingFrame
        
CSR_DoNotDisplaySprite
        lda   priority,u                     
        cmpa  cur_priority 
        bne   CSR_NextObject                ; next object if this one is a new priority record (no need to erase) 
        
        lda   rsv_render_flags,u
        anda  #^rsv_render_erasesprite_mask&^rsv_render_displaysprite_mask ; set erase and display flag to false
        sta   rsv_render_flags,u
                
        ldb   buf_prev_render_flags,x
        bpl   CSR_NextObject                ; branch if not on screen
        
        ora   #rsv_render_erasesprite_mask  ; set erase flag to true if on screen                  
        sta   rsv_render_flags,u
        
        ldy   cur_ptr_sub_obj_erase         ; maintain list of changing sprites to erase
        stu   ,y++
        sty   cur_ptr_sub_obj_erase 
        
CSR_NextObject
        ldu   buf_priority_next_obj,x
        lbne  CSR_ProcessEachPriorityLevel   
        rts

CSR_ComputeMappingFrame

        ; The image subset reference up to 4 version of an image
        ; Draw/Erase, Draw routines and shifted version by 1 pixel of these two routines
        ; The following code set the appropriate routine that will draw the image
        ; First thing is to check if the image position is odd or even
        ; and select the appropriate routine. If no routine is found, it will select the avaible routine.
        ; The selected image will also be based on image type overlay or not (Simple Draw or Draw/Erase)

@a      ldb   x_pixel,u                     ; compute mapping_frame 
@b      eorb  rsv_image_center_offset,u     ; case of odd image center switch shifted image with normal
        andb  #1                            ; index of sub image is encoded in two bits: 00|B0, 01|D0, 10|B1, 11|D1         
        aslb                                ; set bit2 for 1px shifted image  
        lda   render_flags,u            
        anda  #render_overlay_mask          ; set bit1 for normal (background save) or overlay sprite (no background save)
        beq   @c
        incb
@c
        lda   b,y
        beq   CSR_NoDefinedFrame
        leay  a,y                           ; read image subset index
        sty   rsv_mapping_frame,u
        bra   CSR_UpdateMetadata
CSR_NoDefinedFrame
        eorb  #%00000010                    ; check if there is an alternate shifted image available
        beq   @e
        inc   rsv_image_center_offset,u     ; ajust offset for alternate
        bra   @f
@e      dec   rsv_image_center_offset,u
@f      tst   b,y
        bne   @c        

        ldy   #0                            ; no defined frame, nothing will be displayed
        sty   rsv_mapping_frame,u
        lda   render_flags,u
        ora   #render_hide_mask             ; set hide flag
        sta   render_flags,u
        jmp   CSR_CheckErase
                
CSR_UpdateMetadata
        lda   erase_nb_cell,y               ; copy current image metadata into object data
        sta   rsv_erase_nb_cell,u           ; this is needed to avoid a lot of page switch 
        lda   page_draw_routine,y           ; during following routines
        sta   rsv_page_draw_routine,u
        ldd   draw_routine,y
        std   rsv_draw_routine,u
        lda   page_erase_routine,y
        sta   rsv_page_erase_routine,u
        ldd   erase_routine,y
        std   rsv_erase_routine,u
        
CSR_CheckPosition        
        ldb   y_pixel,u                     ; check if sprite is fully in screen vertical range
        ldy   rsv_image_subset,u
        addb  image_subset_y1_offset,y
        cmpb  #screen_bottom
        bhi   CSR_SetOutOfRange
        cmpb  #screen_top
        blo   CSR_SetOutOfRange        
        stb   rsv_y1_pixel,u
        ldy   image_set,u
        addb  image_y_size,y
        cmpb  #screen_bottom
        bhi   CSR_SetOutOfRange
        cmpb  #screen_top
        blo   CSR_SetOutOfRange        
        stb   rsv_y2_pixel,u
        cmpb  rsv_y1_pixel,u                ; check wrapping
        blo   CSR_SetOutOfRange
                
        lda   render_flags,u                ; check if sprite is fully in screen horizontal range
        bita  #render_xloop_mask
        bne   CSR_DontCheckXFrontier   
        
        ldb   x_pixel,u
        ldy   rsv_image_subset,u
        addb  image_subset_x1_offset,y
        cmpb  #screen_right
        bhi   CSR_SetOutOfRange
        cmpb  #screen_left
        blo   CSR_SetOutOfRange
        stb   rsv_x1_pixel,u
        ldy   image_set,u
        addb  image_x_size,y
        cmpb  #screen_right
        bhi   CSR_SetOutOfRange
        cmpb  #screen_left
        blo   CSR_SetOutOfRange
        stb   rsv_x2_pixel,u
        cmpb  rsv_x1_pixel,u                ; check wrapping
        blo   CSR_SetOutOfRange 
                
        bra   CSR_DontCheckXFrontier_end        
        
CSR_DontCheckXFrontier  
        ldb   x_pixel,u
        ldy   rsv_image_subset,u
        addb  image_subset_x1_offset,y
        stb   rsv_x1_pixel,u
        
        ldy   image_set,u
        addb  image_x_size,y
        stb   rsv_x2_pixel,u      

CSR_DontCheckXFrontier_end        
        lda   rsv_render_flags,u
        anda  #^rsv_render_outofrange_mask  ; unset out of range flag
        sta   rsv_render_flags,u
        bra   CSR_CheckErase
                
CSR_SetOutOfRange
        lda   rsv_render_flags,u
        ora   #rsv_render_outofrange_mask   ; set out of range flag
        sta   rsv_render_flags,u

CSR_CheckErase
        stx   CSR_CheckDraw+1
        lda   buf_priority,x
        cmpa  cur_priority 
        lbne  CSR_CheckDraw
        
        ldy   cur_ptr_sub_obj_erase
        
        lda   rsv_render_flags,u
        anda  #rsv_render_outofrange_mask
        beq   CSR_CheckErase_InRange
        lda   buf_prev_render_flags,x
        lbpl  CSR_SetEraseDrawFalse         ; branch if object is not on screen    
        bra   CSR_SetEraseTrue
                
CSR_CheckErase_InRange        
        lda   buf_prev_render_flags,x
        lbpl  CSR_SetEraseFalse             ; branch if object is not on screen
        ldd   xy_pixel,u
        lsra                                ; x position precision is x_pixel/2 and mapping_frame with or without 1px shit, y position precision is y_pixel  
        cmpd  buf_prev_xy_pixel,x
        bne   CSR_SetEraseTrue              ; branch if object moved since last frame
        ldd   rsv_mapping_frame,u
        cmpd  buf_prev_mapping_frame,x
        bne   CSR_SetEraseTrue              ; branch if object image changed since last frame
        lda   priority,u
        cmpa  buf_priority,x
        bne   CSR_SetEraseTrue              ; branch if object priority changed since last frame
        bra   CSR_SubEraseSpriteSearchInit  ; branch if object is on screen but unchanged since last frame
        
CSR_SetEraseTrue        
        lda   rsv_render_flags,u
        ora   #rsv_render_erasesprite_mask
        sta   rsv_render_flags,u
        
        stu   ,y++
        sty   cur_ptr_sub_obj_erase
                
        jmp   CSR_CheckDraw
        
CSR_SubEraseSpriteSearchInit

        * search a collision with a sprite under the current sprite
        * the sprite under should have to be erased or displayed
        * in this case it forces the refresh of the current sprite that was not supposed to be refreshed
        * as a sub loop, this should be optimized as much as possible ... I hope it is
        * there are two lists because a sprite can be erased at a position
        * and displayed at another position : both cases should be tested !

        ldx   cur_ptr_sub_obj_erase       
        lda   glb_Cur_Wrk_Screen_Id         ; read current screen buffer for write operations
        bne   CSR_SubEraseSearchB1
        
CSR_SubEraseSearchB0
        cmpx  #Tbl_Sub_Object_Erase
        beq   CSR_SubDrawSpriteSearchInit   ; branch if no more sub objects
        ldy   ,--x
        
CSR_SubEraseCheckCollisionB0
        ldd   rsv_prev_xy1_pixel_0,y        ; sub entry : rsv_prev_x_pixel_0 and rsv_prev_y_pixel_0 in one instruction
        cmpa  rsv_x2_pixel,u                ;     entry : x_pixel + rsv_mapping_frame.x_size
        bhi   CSR_SubEraseSearchB0
        cmpb  rsv_y2_pixel,u                ;     entry : y_pixel + rsv_mapping_frame.y_size
        bhi   CSR_SubEraseSearchB0
        ldd   rsv_prev_xy2_pixel_0,y        ; sub entry : rsv_prev_x_pixel_0 + rsv_prev_mapping_frame_0.x_size and rsv_prev_y_pixel_0 + rsv_prev_mapping_frame_0.y_size in one instruction
        cmpa  rsv_x1_pixel,u                ;     entry : x_pixel
        blo   CSR_SubEraseSearchB0
        cmpb  rsv_y1_pixel,u                ;     entry : y_pixel
        blo   CSR_SubEraseSearchB0
        
        ldy   cur_ptr_sub_obj_erase
        bra   CSR_SetEraseTrue              ; found a collision

CSR_SubEraseSearchB1
        cmpx  #Tbl_Sub_Object_Erase
        beq   CSR_SubDrawSpriteSearchInit   ; branch if no more sub objects
        ldy   ,--x
        
CSR_SubEraseCheckCollisionB1
        ldd   rsv_prev_xy1_pixel_1,y        ; sub entry : rsv_prev_x_pixel_1 and rsv_prev_y_pixel_1 in one instruction
        cmpa  rsv_x2_pixel,u                ;     entry : x_pixel + rsv_mapping_frame.x_size
        bhi   CSR_SubEraseSearchB1
        cmpb  rsv_y2_pixel,u                ;     entry : y_pixel + rsv_mapping_frame.y_size
        bhi   CSR_SubEraseSearchB1
        ldd   rsv_prev_xy2_pixel_1,y        ; sub entry : rsv_prev_x_pixel_1 + rsv_prev_mapping_frame_1.x_size and rsv_prev_y_pixel_1 + rsv_prev_mapping_frame_1.y_size in one instruction
        cmpa  rsv_x1_pixel,u                ;     entry : x_pixel
        blo   CSR_SubEraseSearchB1
        cmpb  rsv_y1_pixel,u                ;     entry : y_pixel
        blo   CSR_SubEraseSearchB1
        
        ldy   cur_ptr_sub_obj_erase
        bra   CSR_SetEraseTrue              ; found a collision

CSR_SubDrawSpriteSearchInit
        ldx   cur_ptr_sub_obj_draw
        
CSR_SubDrawSearch
        cmpx  #Tbl_Sub_Object_Draw
        beq   CSR_SetEraseFalse             ; branch if no more sub objects
        ldy   ,--x

CSR_SubDrawCheckCollision
        ldd   rsv_xy1_pixel,y               ; sub entry : x_pixel and y_pixel in one instruction
        cmpa  rsv_x2_pixel,u                ;     entry : x_pixel + rsv_mapping_frame.x_size
        bhi   CSR_SubDrawSearch
        cmpb  rsv_y2_pixel,u                ;     entry : y_pixel + rsv_mapping_frame.y_size
        bhi   CSR_SubDrawSearch
        ldd   rsv_xy2_pixel,y               ; sub entry : x_pixel + rsv_mapping_frame.x_size and y_pixel + rsv_mapping_frame.y_size in one instruction
        cmpa  rsv_x1_pixel,u                ;     entry : x_pixel
        blo   CSR_SubDrawSearch
        cmpb  rsv_y1_pixel,u                ;     entry : y_pixel
        blo   CSR_SubDrawSearch
        
        ldy   cur_ptr_sub_obj_erase
        jmp   CSR_SetEraseTrue              ; found a collision

CSR_SetEraseFalse
        lda   rsv_render_flags,u 
        anda  #^rsv_render_erasesprite_mask
        sta   rsv_render_flags,u        
               
CSR_CheckDraw
        ldx   #$FFFF                        ; dynamic restore x
        lda   priority,u
        cmpa  cur_priority 
        lbne  CSR_NextObject
        
        ldy   cur_ptr_sub_obj_draw
        
        lda   rsv_render_flags,u
        anda  #rsv_render_outofrange_mask
        bne   CSR_SetDrawFalse              ; branch if object image is out of range
        ldd   rsv_mapping_frame,u
        beq   CSR_SetDrawFalse              ; branch if object have no image
        lda   render_flags,u
        anda  #render_hide_mask
        bne   CSR_SetDrawFalse              ; branch if object is hidden
        
CSR_SetDrawTrue 
        lda   rsv_render_flags,u
        ora   #rsv_render_displaysprite_mask ; set displaysprite flag   
        sta   rsv_render_flags,u         
        
        bita  #rsv_render_erasesprite_mask
        beq   CSR_SDT1
        bra   CSR_SDT2
CSR_SDT1                      
        ldb   buf_prev_render_flags,x
        bmi   CSR_SetHide
        bra   CSR_SDT3      
CSR_SDT2                      
        ldb   buf_prev_render_flags,x
        bpl   CSR_SetHide
CSR_SDT3
        stu   ,y++
        sty   cur_ptr_sub_obj_draw          ; maintain list of changing sprites to draw, should be to draw and ((on screen and to erase) or (not on screen and not to erase)) 

CSR_SetHide        
        lda   render_flags,u
        ora   #render_hide_mask             ; set hide flag
        sta   render_flags,u        
        
        ldu   buf_priority_next_obj,x
        lbne  CSR_ProcessEachPriorityLevel   
        rts

CSR_SetEraseDrawFalse 
        lda   rsv_render_flags,u 
        anda  #^rsv_render_erasesprite_mask
        sta   rsv_render_flags,u 

CSR_SetDrawFalse 
        lda   rsv_render_flags,u
        anda  #^rsv_render_displaysprite_mask
        sta   rsv_render_flags,u
        
        ldu   buf_priority_next_obj,x
        lbne   CSR_ProcessEachPriorityLevel   
        rts      
