* ---------------------------------------------------------------------------
* DrawSprites
* ------------
* Subroutine to draw sprites on screen
* Read Display Priority Structure (back to front)
* priority: 0 - unregistred
* priority: 1 - register non moving overlay sprite
* priority; 2-8 - register moving sprite (2:front, ..., 8:back)  
*
* input REG : none
* ---------------------------------------------------------------------------
									   
DrawSprites

DRS_Start
        lda   glb_Cur_Wrk_Screen_Id         ; read current screen buffer for write operations
        bne   DRS_P8B1
        
DRS_P8B0                                    
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+16 ; read DPS from priority 8 to priority 1
        beq   DRS_P7B0
        jsr   DRS_ProcessEachPriorityLevelB0   
DRS_P7B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+14
        beq   DRS_P6B0
        jsr   DRS_ProcessEachPriorityLevelB0  
DRS_P6B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+12
        beq   DRS_P5B0
        jsr   DRS_ProcessEachPriorityLevelB0  
DRS_P5B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+10
        beq   DRS_P4B0
        jsr   DRS_ProcessEachPriorityLevelB0  
DRS_P4B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+8
        beq   DRS_P3B0
        jsr   DRS_ProcessEachPriorityLevelB0              
DRS_P3B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+6
        beq   DRS_P2B0
        jsr   DRS_ProcessEachPriorityLevelB0     
DRS_P2B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+4
        beq   DRS_P1B0
        jsr   DRS_ProcessEachPriorityLevelB0 
DRS_P1B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+2
        beq   DRS_rtsB0
        jsr   DRS_ProcessEachPriorityLevelB0
DRS_rtsB0        
        rts
        
DRS_P8B1
        ldx   DPS_buffer_1+buf_Tbl_Priority_First_Entry+16 ; read DPS from priority 8 to priority 1
        beq   DRS_P7B1
        jsr   DRS_ProcessEachPriorityLevelB1   
DRS_P7B1
        ldx   DPS_buffer_1+buf_Tbl_Priority_First_Entry+14
        beq   DRS_P6B1
        jsr   DRS_ProcessEachPriorityLevelB1   
DRS_P6B1
        ldx   DPS_buffer_1+buf_Tbl_Priority_First_Entry+12
        beq   DRS_P5B1
        jsr   DRS_ProcessEachPriorityLevelB1   
DRS_P5B1
        ldx   DPS_buffer_1+buf_Tbl_Priority_First_Entry+10
        beq   DRS_P4B1
        jsr   DRS_ProcessEachPriorityLevelB1   
DRS_P4B1
        ldx   DPS_buffer_1+buf_Tbl_Priority_First_Entry+8
        beq   DRS_P3B1
        jsr   DRS_ProcessEachPriorityLevelB1             
DRS_P3B1
        ldx   DPS_buffer_1+buf_Tbl_Priority_First_Entry+6
        beq   DRS_P2B1
        jsr   DRS_ProcessEachPriorityLevelB1    
DRS_P2B1
        ldx   DPS_buffer_1+buf_Tbl_Priority_First_Entry+4
        beq   DRS_P1B1
        jsr   DRS_ProcessEachPriorityLevelB1
DRS_P1B1
        ldx   DPS_buffer_1+buf_Tbl_Priority_First_Entry+2
        beq   DRS_rtsB1
        jsr   DRS_ProcessEachPriorityLevelB1
DRS_rtsB1        
        rts

DRS_ProcessEachPriorityLevelB0    
        lda   rsv_render_flags,x
        anda  #rsv_render_displaysprite_mask
        lbeq  DRS_NextObjectB0
        
        lda   rsv_prev_render_flags_0,x
        lbmi  DRS_NextObjectB0
        lda   render_flags,x
        anda  #render_overlay_mask
        bne   DRS_DrawWithoutBackupB0
        lda   rsv_erase_nb_cell,x        
        jsr   BgBufferAlloc                 ; allocate free space to store sprite background data
        cmpy  #$0000                        ; y contains cell_end of allocated space 
        lbeq   DRS_NextObjectB0             ; branch if no more free space
        leau  ,y                            ; cell_end for background data        
DRS_DrawWithoutBackupB0        
        ldd   xy_pixel,x                    ; load x position (48-207) and y position (28-227) in one operation
        suba  rsv_image_center_offset,x
        jsr   DRS_XYToAddress
        ldd   rsv_mapping_frame,x
        std   rsv_prev_mapping_frame_0,x    ; save previous mapping_frame
        lda   rsv_page_draw_routine,x
        _SetCartPageA        
        stx   DRS_dyn3B0+1                  ; save x reg
        ldy   #glb_screen_location_2
        jsr   [rsv_draw_routine,x]          ; backup background and draw sprite on working screen buffer
        bra   DRS_dyn3B0
        jsr   DecMapAlpha
        bra   DRS_dyn3B0       
        jsr   zx0_decompress	
DRS_dyn3B0        
        ldx   #$0000                        ; (dynamic) restore x reg
        stu   rsv_bgdata_0,x                ; store pointer to saved background data
        ldd   xy_pixel,x                    ; load x position (48-207) and y position (28-227) in one operation
        lsra                                ; x position precision is x_pixel/2 and mapping_frame with or without 1px shit
        std   rsv_prev_xy_pixel_0,x         ; save previous x_pixel and y_pixel in one operation             
        ldd   rsv_xy1_pixel,x               ; load x' and y' in one operation
        std   rsv_prev_xy1_pixel_0,x        ; save as previous x' and y'        
        ldd   rsv_xy2_pixel,x               ; load x'' and y'' in one operation
        std   rsv_prev_xy2_pixel_0,x        ; save as previous x'' and y''
        lda   rsv_erase_nb_cell,x
        sta   rsv_prev_erase_nb_cell_0,x
        lda   rsv_page_erase_routine,x
        sta   rsv_prev_page_erase_routine_0,x
        ldd   rsv_erase_routine,x
        std   rsv_prev_erase_routine_0,x
        lda   rsv_prev_render_flags_0,x
        ora   #rsv_prev_render_onscreen_mask
        ldb   render_flags,x
        bitb  #render_overlay_mask
        beq   DRS_NoOverlayB0
        ora   #rsv_prev_render_overlay_mask
        bra   DRS_UpdateRenderFlagB0
        
DRS_NoOverlayB0
        anda   #^rsv_prev_render_overlay_mask

DRS_UpdateRenderFlagB0        
        sta   rsv_prev_render_flags_0,x     ; set the onscreen flag and save overlay flag
        lda   rsv_render_flags,x
        ora   #rsv_render_onscreen_mask     ; sprite is on screen
        sta   rsv_render_flags,x
        
DRS_NextObjectB0        
        ldx   rsv_priority_next_obj_0,x
        lbne  DRS_ProcessEachPriorityLevelB0   
        rts

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

DRS_XYToAddress
        suba  #$30
        bcc   DRS_XYToAddressPositive
        suba  #$60                          ; get x position one line up, skipping (160-255)
        decb
DRS_XYToAddressPositive        
        subb  #$1C                          ; TODO same thing as x for negative case
        lsra                                ; x=x/2, sprites moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB enterlace  
        bcs   DRS_XYToAddressRAM2First      ; Branch if write must begin in RAM2 first
DRS_XYToAddressRAM1First
        sta   DRS_dyn1+2
        lda   #$28                          ; 40 bytes per line in RAMA or RAMB
        mul
DRS_dyn1        
        addd  #$C000                        ; (dynamic)
        std   glb_screen_location_2
        subd  #$2000
        std   glb_screen_location_1     
        rts
DRS_XYToAddressRAM2First
        sta   DRS_dyn2+2
        lda   #$28                          ; 40 bytes per line in RAMA or RAMB
        mul
DRS_dyn2        
        addd  #$A000                        ; (dynamic)
        std   glb_screen_location_2
        addd  #$2001
        std   glb_screen_location_1
        rts
        
DRS_ProcessEachPriorityLevelB1
        lda   rsv_render_flags,x
        anda  #rsv_render_displaysprite_mask
        lbeq  DRS_NextObjectB1
        
        lda   rsv_prev_render_flags_1,x
        lbmi  DRS_NextObjectB1
        lda   render_flags,x
        anda  #render_overlay_mask
        bne   DRS_DrawWithoutBackupB1
        lda   rsv_erase_nb_cell,x        
        jsr   BgBufferAlloc                 ; allocate free space to store sprite background data
        cmpy  #$0000                        ; y contains cell_end of allocated space
        lbeq   DRS_NextObjectB1             ; branch if no more free space
        leau  ,y                            ; cell_end for background data        
DRS_DrawWithoutBackupB1        
        ldd   xy_pixel,x                    ; load x position (48-207) and y position (28-227) in one operation
        suba  rsv_image_center_offset,x
        jsr   DRS_XYToAddress
        ldd   rsv_mapping_frame,x
        std   rsv_prev_mapping_frame_1,x    ; save previous mapping_frame
        lda   rsv_page_draw_routine,x
        _SetCartPageA        
        stx   DRS_dyn3B1+1                  ; save x reg
        ldy   #glb_screen_location_2
        jsr   [rsv_draw_routine,x]
        bra   DRS_dyn3B1        
        jsr   DecMapAlpha
        bra   DRS_dyn3B1        
        jsr   zx0_decompress	
DRS_dyn3B1        
        ldx   #$0000                        ; (dynamic) restore x reg
        stu   rsv_bgdata_1,x                ; store pointer to saved background data
        ldd   xy_pixel,x                    ; load x position (48-207) and y position (28-227) in one operation
        lsra                                ; x position precision is x_pixel/2 and mapping_frame with or without 1px shit
        std   rsv_prev_xy_pixel_1,x         ; save previous x_pixel and y_pixel in one operation         
        ldd   rsv_xy1_pixel,x               ; load x' and y' in one operation
        std   rsv_prev_xy1_pixel_1,x        ; save as previous x' and y'        
        ldd   rsv_xy2_pixel,x               ; load x'' and y'' in one operation
        std   rsv_prev_xy2_pixel_1,x        ; save as previous x'' and y''
        lda   rsv_erase_nb_cell,x
        sta   rsv_prev_erase_nb_cell_1,x
        lda   rsv_page_erase_routine,x
        sta   rsv_prev_page_erase_routine_1,x
        ldd   rsv_erase_routine,x
        std   rsv_prev_erase_routine_1,x                        
        lda   rsv_prev_render_flags_1,x
        ora   #rsv_prev_render_onscreen_mask
        ldb   render_flags,x
        bitb  #render_overlay_mask
        beq   DRS_NoOverlayB1
        ora   #rsv_prev_render_overlay_mask
        bra   DRS_UpdateRenderFlagB1
        
DRS_NoOverlayB1
        anda   #^rsv_prev_render_overlay_mask

DRS_UpdateRenderFlagB1
        sta   rsv_prev_render_flags_1,x     ; set the onscreen flag and save overlay flag
        lda   rsv_render_flags,x
        ora   #rsv_render_onscreen_mask     ; sprite is on screen
        sta   rsv_render_flags,x        
                
DRS_NextObjectB1        
        ldx   rsv_priority_next_obj_1,x
        lbne  DRS_ProcessEachPriorityLevelB1   
        rts