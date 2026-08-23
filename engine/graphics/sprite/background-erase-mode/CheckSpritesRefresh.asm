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
                                
* ---------------------------------------------------------------------------
* Sub Priority Objects List - SOL
* ---------------------------------------------------------------------------

cur_priority                  equ dp_engine   ; byte
cur_ptr_sub_obj_erase         equ dp_engine+1 ; word
cur_ptr_sub_obj_draw          equ dp_engine+3 ; word

Tbl_Sub_Object_Erase          fill  0,nb_graphical_objects*2    ; entries of objects that have erase flag in the order back to front
Tbl_Sub_Object_Draw           fill  0,nb_graphical_objects*2    ; entries of objects that have draw flag in the order back to front                                

        setdp dp/256

CheckSpritesRefresh

CSR_Start
        ldd   #Tbl_Sub_Object_Erase
        std   cur_ptr_sub_obj_erase
        ldd   #Tbl_Sub_Object_Draw
        std   cur_ptr_sub_obj_draw
        lda   gfxlock.backBuffer.id         ; read current screen buffer for write operations
        bne   CSR_SetBuffer1
        
CSR_SetBuffer0        
        lda   #rsv_buffer_0                 ; set offset to object variables that belongs to screen buffer 0

* set up tyhe various U offst in code        
        sta   CSR_PEPL_LeaxB
        adda  #buf_prev_render_flags
        sta   CSR_PEPL_LeaxC
        adda  #buf_priority_next_obj-buf_prev_render_flags
        sta   CSR_PEPL_LeaxA

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
        bsr   CSR_ProcessEachPriorityLevel      
CSR_P2B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+4
        beq   CSR_P1B0
        lda   #$02
        sta   cur_priority                       
        bsr   CSR_ProcessEachPriorityLevel  
CSR_P1B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+2
        bne   CSR_rtsB0
        rts
CSR_rtsB0
        lda   #$01
        sta   cur_priority                       
        bra   CSR_ProcessEachPriorityLevel
        
CSR_SetBuffer1       
        lda   #rsv_buffer_1                 ; set offset to object variables that belongs to screen buffer 1

* set up tyhe variosu U offst in code        
        sta   CSR_PEPL_LeaxB
        adda  #buf_prev_render_flags
        sta   CSR_PEPL_LeaxC
        adda  #buf_priority_next_obj-buf_prev_render_flags
        sta   CSR_PEPL_LeaxA
CSR_P8B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+16 ; read DPS from priority 8 to priority 1
        beq   CSR_P7B1
        lda   #$08
        sta   cur_priority        
        bsr   CSR_ProcessEachPriorityLevel   
CSR_P7B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+14
        beq   CSR_P6B1
        lda   #$07
        sta   cur_priority                       
        bsr   CSR_ProcessEachPriorityLevel   
CSR_P6B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+12
        beq   CSR_P5B1
        lda   #$06
        sta   cur_priority                       
        bsr   CSR_ProcessEachPriorityLevel   
CSR_P5B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+10
        beq   CSR_P4B1
        lda   #$05
        sta   cur_priority                       
        bsr   CSR_ProcessEachPriorityLevel   
CSR_P4B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+8
        beq   CSR_P3B1
        lda   #$04
        sta   cur_priority
        bsr   CSR_ProcessEachPriorityLevel               
CSR_P3B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+6
        beq   CSR_P2B1
        lda   #$03
        sta   cur_priority                       
        bsr   CSR_ProcessEachPriorityLevel      
CSR_P2B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+4
        beq   CSR_P1B1
        lda   #$02
        sta   cur_priority                       
        bsr   CSR_ProcessEachPriorityLevel  
CSR_P1B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_First_Entry+2
        bne   CSR_rtsB1
        rts
CSR_rtsB1        
        lda   #$01
        sta   cur_priority                       
*        jsr   CSR_ProcessEachPriorityLevel
*CSR_rtsB1        
*        rts

CSR_ProcessEachPriorityLevel
* delayed
*        leax  16,u                          ; dynamic offset, x point to object variables relative to current writable buffer (beware that rsv_buffer_0 and rsv_buffer_1 should be equ >=16)
        
CSR_CheckDelHide
        lda   render_flags,u
        anda  #render_hide_mask|render_todelete_mask
        bne   CSR_DoNotDisplaySprite      
        ; BUGFIX (2026-08-23) : image_set==0 means "no image" (see constants.asm).
        ; DisplaySprite returns early in that case and therefore never unregisters
        ; an object that was registered while it still had an image, so a stale
        ; entry stays in the DPS. Treat it like a hidden sprite: erase what was
        ; drawn before, draw nothing new. Without this guard the null pointer is
        ; dereferenced against whatever sits at offset $0000 of the object image
        ; page: harmless zeros on a RAM page (.fd/.sd), but the cartridge header
        ; on a T2/ROM build, which sends the engine into an erased flash bank.
        ldx   image_set,u
        beq   CSR_DoNotDisplaySprite

CSR_CheckRefresh  
        lda   rsv_render_flags,u      
        bita  #rsv_render_checkrefresh_mask ; branch if checkrefresh is true
        beq   >
        jmp   CSR_CheckErase
!

CSR_UpdSpriteImageBasedOnMirror

        ; an image set is made of 1 to 4 image subsets
        ; each subset represent a mirrored version of the image (N: normal, X: x mirror, Y: y mirror, XY: xy mirror)
        ; this code set the active image subset based on mirror flags

*        lda   rsv_render_flags,u
        ora   #rsv_render_checkrefresh_mask
        sta   rsv_render_flags,u            ; set checkrefresh flag to true
        
        ldx   #Img_Page_Index               ; call page that store imageset for this object
        ldb   id,u
        lda   b,x
        _SetCartPageA        
        
        ldx   image_set,u
        ldb   image_center_offset,x
        stb   rsv_image_center_offset,u        
        
        lda   render_flags,u                ; set image to display based on x and y mirror flags
        anda  #render_xmirror_mask|render_ymirror_mask
        ldb   a,x
        abx                                 ; read image set index
        stx   rsv_image_subset,u
        
CSR_CheckPlayFieldCoord
        lda   render_flags,u
        anda  #render_playfieldcoord_mask
        beq   CSR_ComputeMappingFrame       ; branch if position is already expressed in screen coordinate

        ; purpose here is to check if image coordinate in the playfield
        ; can be converted to screen position, if not it is flagged out of range

        ldd   x_pos,u
        subd  <glb_camera_x_pos
*        adca  #0
*        adca  #0
        tsta
        bne   CSR_oor                       ; out of range if x_pos<glb_camera_x_pos or x_pos + 256 > glb_camera_x_pos

!       addb  glb_camera_x_offset+1
        stb   x_pixel,u
;
        ldd   y_pos,u
        subd  <glb_camera_y_pos
*        adca  #0
*        adca  #0
        tsta
        bne   CSR_oor                       ; out of range if ypos<glb_camera_y_pos or y_pos + 256 > glb_camera_y_pos
        
        addb  glb_camera_y_offset+1
        stb   y_pixel,u
        bra   CSR_ComputeMappingFrame
        
CSR_DoNotDisplaySprite
        lda   priority,u                     
        cmpa  cur_priority 
        bne   CSR_NextObject                ; next object if this one is a new priority record (no need to erase) 
        
        lda   rsv_render_flags,u
        anda  #^rsv_render_erasesprite_mask&^rsv_render_displaysprite_mask ; set erase and display flag to false
        sta   rsv_render_flags,u

        ldb   CSR_PEPL_LeaxC                ; cas rare on réutilise un offset modifie ailleurs
        ldb   b,u
        bpl   CSR_NextObject                ; branch if not on screen
        
        ora   #rsv_render_erasesprite_mask  ; set erase flag to true if on screen                  
        sta   rsv_render_flags,u
        
        ldx   cur_ptr_sub_obj_erase         ; maintain list of changing sprites to erase
        stu   ,x++
        stx   cur_ptr_sub_obj_erase 
        
CSR_NextObject
        ldu   16,u                          ; inclue buf_priority_next_obj a l'init
CSR_PEPL_LeaxA set *-1    
        bne   CSR_ProcessEachPriorityLevel   
        rts

CSR_oor jmp   CSR_SetOutOfRange             ; out of range if x_pos + 256 > glb_camera_x_pos

CSR_ComputeMappingFrame

        ; The image subset reference up to 4 version of an image
        ; Draw/Erase, Draw routines and shifted version by 1 pixel of these two routines
        ; The following code set the appropriate routine that will draw the image
        ; First thing is to check if the image position is odd or even
        ; and select the appropriate routine. If no routine is found, it will select the avaible routine.
        ; The selected image will also be based on image type overlay or not (Simple Draw or Draw/Erase)

@a      lda   x_pixel,u                     ; compute mapping_frame 
@b      eora  rsv_image_center_offset,u     ; case of odd image center switch shifted image with normal
        anda  #1                            ; index of sub image is encoded in two bits: 00|B0, 01|D0, 10|B1, 11|D1         
        asla                                ; set bit2 for 1px shifted image  
        ldb   render_flags,u            
        andb  #render_overlay_mask          ; set bit1 for normal (background save) or overlay sprite (no background save)
        beq   @c
        inca
@c
        ldb   a,x
        beq   CSR_NoDefinedFrame
@d      abx                                 ; read image subset index
        stx   rsv_mapping_frame,u
        bra   CSR_UpdateMetadata
CSR_NoDefinedFrame
        eora  #%00000010                    ; check if there is an alternate shifted image available
        ; BUGFIX (2026-08-20, found on the v2 port) : the fallback direction
        ; was tested on Z, which never comes with draw variants (bit0 set by
        ; render_overlay_mask) — the shifted -> unshifted fallback took inc
        ; instead of dec, 2px left. Test the shift bit itself. (The 8-bit
        ; adjust is sound here : suba applies the offset modulo 256.)
        bita  #%00000010
        beq   @e
        inc   rsv_image_center_offset,u     ; ajust offset for alternate
        bra   @f
@e      dec   rsv_image_center_offset,u
@f      ldb   a,x
        bne   @d        
; ici b=0 donc clra suffit
        clra                                ; no defined frame, nothing will be displayed
        std   rsv_mapping_frame,u
        lda   render_flags,u
        ora   #render_hide_mask             ; set hide flag
        sta   render_flags,u
        jmp   CSR_CheckErase
                
CSR_UpdateMetadata
        lda   erase_nb_cell,x               ; copy current image metadata into object data
        sta   rsv_erase_nb_cell,u           ; this is needed to avoid a lot of page switch 
        lda   page_draw_routine,x           ; during following routines
        sta   rsv_page_draw_routine,u
        ldd   draw_routine,x
        std   rsv_draw_routine,u
        lda   page_erase_routine,x
        sta   rsv_page_erase_routine,u
        ldd   erase_routine,x
        std   rsv_erase_routine,u
        
CSR_CheckPosition        
        ldb   y_pixel,u                     ; check if sprite is fully in screen vertical range
        ldx   rsv_image_subset,u
        addb  image_subset_y1_offset,x
        cmpb  #screen_bottom
        bhi   CSR_SetOutOfRange
        cmpb  #screen_top
        blo   CSR_SetOutOfRange        
        stb   rsv_y1_pixel,u
        ldx   image_set,u
        addb  image_y_size,x
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
        ldx   rsv_image_subset,u
        addb  image_subset_x1_offset,x
        cmpb  #screen_right
        bhi   CSR_SetOutOfRange
        cmpb  #screen_left
        blo   CSR_SetOutOfRange
        tfr   b,a
        andb  #%11111110                    ; lower round for background save (byte step)
        stb   rsv_x1_pixel,u
        ldx   image_set,u
        adda  image_x_size,x
        cmpa  #screen_right
        bhi   CSR_SetOutOfRange
        cmpa  #screen_left
        blo   CSR_SetOutOfRange
        ora   #1                            ; upper round for background save (byte step)
        sta   rsv_x2_pixel,u
        cmpa  rsv_x1_pixel,u                ; check wrapping
        bhs   CSR_DontCheckXFrontier_end        
        bra   CSR_SetOutOfRange 
                
        
CSR_DontCheckXFrontier  
        ldb   x_pixel,u
        ldx   rsv_image_subset,u
        addb  image_subset_x1_offset,x
        tfr   b,a
        andb  #%11111110                    ; lower round for background save (byte step)
        stb   rsv_x1_pixel,u
        ldx   image_set,u
        adda  image_x_size,x
        ora   #1
        sta   rsv_x2_pixel,u

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
        leay  16,u
CSR_PEPL_LeaxB set *-1
        lda   buf_priority,y
        cmpa  cur_priority 
        beq   >
        jmp   CSR_CheckDraw
!        
        lda   rsv_render_flags,u
        anda  #rsv_render_outofrange_mask
        beq   CSR_CheckErase_InRange
        lda   buf_prev_render_flags,y
        bmi   CSR_SetEraseTrue
        jmp   CSR_SetEraseDrawFalse         ; branch if object is not on screen    
                
CSR_CheckErase_InRange        
        lda   buf_prev_render_flags,y
        bmi   >
        jmp   CSR_SetEraseFalse             ; branch if object is not on screen
!	lda   <glb_force_sprite_refresh
	bne   CSR_SetEraseTrue
        ldd   xy_pixel,u
        lsra                                ; x position precision is x_pixel/2 and mapping_frame with or without 1px shit, y position precision is y_pixel  
        subd  buf_prev_xy_pixel,y
        bne   CSR_SetEraseTrue              ; branch if object moved since last frame
        ldd   rsv_mapping_frame,u
        subd  buf_prev_mapping_frame,y
        bne   CSR_SetEraseTrue              ; branch if object image changed since last frame
        lda   priority,u
        cmpa  buf_priority,y
*       bne   CSR_SetEraseTrue              ; branch if object priority changed since last frame
        beq   CSR_SubEraseSpriteSearchInit  ; branch if object is on screen but unchanged since last frame
        
CSR_SetEraseTrue        
        lda   rsv_render_flags,u
        ora   #rsv_render_erasesprite_mask
        sta   rsv_render_flags,u
        
        ldx   cur_ptr_sub_obj_erase
        stu   ,x++
        stx   cur_ptr_sub_obj_erase
                
        bra   CSR_CheckDraw
        
CSR_SubEraseSpriteSearchInit

        * search a collision with a sprite under the current sprite
        * the sprite under should have to be erased or displayed
        * in this case it forces the refresh of the current sprite that was not supposed to be refreshed
        * as a sub loop, this should be optimized as much as possible ... I hope it is
        * there are two lists because a sprite can be erased at a position
        * and displayed at another position : both cases should be tested !

        ldx   cur_ptr_sub_obj_erase       
        lda   gfxlock.backBuffer.id         ; read current screen buffer for write operations
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
        
        jmp   CSR_SetEraseTrue              ; found a collision

CSR_SetEraseFalse
        lda   rsv_render_flags,u 
        anda  #^rsv_render_erasesprite_mask
        sta   rsv_render_flags,u        
               
CSR_CheckDraw
        lda   priority,u
        cmpa  cur_priority 
        beq   >
        jmp   CSR_NextObject
!        
        lda   rsv_render_flags,u
        anda  #rsv_render_outofrange_mask
        bne   CSR_SetDrawFalse              ; branch if object image is out of range
        ldd   rsv_mapping_frame,u
        beq   CSR_SetDrawFalse              ; branch if object have no image
        lda   render_flags,u
        anda  #render_hide_mask
        bne   CSR_SetDrawFalse              ; branch if object is hidden
        
CSR_SetDrawTrue 
        ldb   16,u                          ; dynamic restore x
CSR_PEPL_LeaxC set *-1
        lda   rsv_render_flags,u
        ora   #rsv_render_displaysprite_mask ; set displaysprite flag   
        sta   rsv_render_flags,u         
        
        bita  #rsv_render_erasesprite_mask
        bne   CSR_SDT2
CSR_SDT1                      
        tstb
        bpl   CSR_SDT3
        bra   CSR_SetHide
         
CSR_SDT2                      
        tstb
        bpl   CSR_SetHide
CSR_SDT3
        ldx   cur_ptr_sub_obj_draw
        stu   ,x++
        stx   cur_ptr_sub_obj_draw          ; maintain list of changing sprites to draw, should be to draw and ((on screen and to erase) or (not on screen and not to erase)) 

CSR_SetHide        
        lda   render_flags,u
        ora   #render_hide_mask             ; set hide flag
        sta   render_flags,u        
        
        jmp   CSR_NextObject

CSR_SetEraseDrawFalse 
        lda   rsv_render_flags,u 
        anda  #^rsv_render_erasesprite_mask
        sta   rsv_render_flags,u 

CSR_SetDrawFalse 
        lda   rsv_render_flags,u
        anda  #^rsv_render_displaysprite_mask
        sta   rsv_render_flags,u
        
        jmp   CSR_NextObject