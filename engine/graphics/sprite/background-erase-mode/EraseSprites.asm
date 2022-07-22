* ---------------------------------------------------------------------------
* EraseSprites
* ------------
* Subroutine to erase sprites on screen
* Read Display Priority Structure (front to back)
* priority: 0 - unregistred
* priority: 1 - register non moving overlay sprite
* priority; 2-8 - register moving sprite (2:front, ..., 8:back)  
*
* input REG : none
* ---------------------------------------------------------------------------
                                                                
* ---------------------------------------------------------------------------
* Background Backup Cells - BBC
* ---------------------------------------------------------------------------

* ----- Cell variables
nb_cells                      equ   0
cell_start                    equ   1
cell_end                      equ   3
next_entry                    equ   5
entry_size                    equ   7

* ----- Cells List
nb_free_cells                 equ   128
cell_size                     equ   64     ; 64 bytes x 128 from $4000 to $5FFF
cell_start_adr                equ   $6000

Lst_FreeCellFirstEntry_0      fdb   Lst_FreeCell_0 ; Pointer to first entry in free cell list (buffer 0)
Lst_FreeCell_0                fcb   nb_free_cells ; init of first free cell
                              fdb   cell_start_adr-cell_size*nb_free_cells
                              fdb   cell_start_adr
                              fdb   $0000
                              fill  0,(entry_size*(nb_free_cells/2))-1 ; (buffer 0)
                              
Lst_FreeCellFirstEntry_1      fdb   Lst_FreeCell_1 ; Pointer to first entry in free cell list (buffer 1)
Lst_FreeCell_1                fcb   nb_free_cells ; init of first free cell
                              fdb   cell_start_adr-cell_size*nb_free_cells
                              fdb   cell_start_adr
                              fdb   $0000
                              fill  0,(entry_size*(nb_free_cells/2))-1 ; (buffer 1)                                                
                                                                           
EraseSprites
	lda   #0
	sta   <glb_force_sprite_refresh

ESP_Start
        lda   glb_Cur_Wrk_Screen_Id         ; read current screen buffer for write operations
        bne   ESP_P1B1

ESP_P1B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_Last_Entry+2 ; read DPS from priority 1 to priority 8
        beq   ESP_P2B0
        lda   #$01
        sta   ESP_CheckPriorityB0+1        
        jsr   ESP_ProcessEachPriorityLevelB0
ESP_P2B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_Last_Entry+4
        beq   ESP_P3B0
        lda   #$02
        sta   ESP_CheckPriorityB0+1        
        jsr   ESP_ProcessEachPriorityLevelB0   
ESP_P3B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_Last_Entry+6
        beq   ESP_P4B0
        lda   #$03
        sta   ESP_CheckPriorityB0+1        
        jsr   ESP_ProcessEachPriorityLevelB0   
ESP_P4B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_Last_Entry+8
        beq   ESP_P5B0
        lda   #$04
        sta   ESP_CheckPriorityB0+1        
        jsr   ESP_ProcessEachPriorityLevelB0   
ESP_P5B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_Last_Entry+10
        beq   ESP_P6B0
        lda   #$05
        sta   ESP_CheckPriorityB0+1        
        jsr   ESP_ProcessEachPriorityLevelB0               
ESP_P6B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_Last_Entry+12
        beq   ESP_P7B0
        lda   #$06
        sta   ESP_CheckPriorityB0+1        
        jsr   ESP_ProcessEachPriorityLevelB0      
ESP_P7B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_Last_Entry+14
        beq   ESP_P8B0
        lda   #$07
        sta   ESP_CheckPriorityB0+1        
        jsr   ESP_ProcessEachPriorityLevelB0  
ESP_P8B0
        ldu   DPS_buffer_0+buf_Tbl_Priority_Last_Entry+16
        beq   ESP_rtsB0
        lda   #$08
        sta   ESP_CheckPriorityB0+1                   
        jsr   ESP_ProcessEachPriorityLevelB0
ESP_rtsB0        
        rts
        
ESP_P1B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_Last_Entry+2 ; read DPS from priority 1 to priority 8
        beq   ESP_P2B1
        lda   #$01
        sta   ESP_CheckPriorityB1+1        
        jsr   ESP_ProcessEachPriorityLevelB1
ESP_P2B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_Last_Entry+4
        beq   ESP_P3B1
        lda   #$02
        sta   ESP_CheckPriorityB1+1        
        jsr   ESP_ProcessEachPriorityLevelB1   
ESP_P3B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_Last_Entry+6
        beq   ESP_P4B1
        lda   #$03
        sta   ESP_CheckPriorityB1+1        
        jsr   ESP_ProcessEachPriorityLevelB1   
ESP_P4B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_Last_Entry+8
        beq   ESP_P5B1
        lda   #$04
        sta   ESP_CheckPriorityB1+1        
        jsr   ESP_ProcessEachPriorityLevelB1   
ESP_P5B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_Last_Entry+10
        beq   ESP_P6B1
        lda   #$05
        sta   ESP_CheckPriorityB1+1        
        jsr   ESP_ProcessEachPriorityLevelB1               
ESP_P6B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_Last_Entry+12
        beq   ESP_P7B1
        lda   #$06
        sta   ESP_CheckPriorityB1+1        
        jsr   ESP_ProcessEachPriorityLevelB1      
ESP_P7B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_Last_Entry+14
        beq   ESP_P8B1
        lda   #$07
        sta   ESP_CheckPriorityB1+1        
        jsr   ESP_ProcessEachPriorityLevelB1  
ESP_P8B1
        ldu   DPS_buffer_1+buf_Tbl_Priority_Last_Entry+16
        beq   ESP_rtsB1
        lda   #$08
        sta   ESP_CheckPriorityB1+1        
        jsr   ESP_ProcessEachPriorityLevelB1
ESP_rtsB1        
        rts

* -----------------------------------------------
* BUFFER0
* -----------------------------------------------

ESP_ProcessEachPriorityLevelB0
        lda   rsv_priority_0,u
        
ESP_CheckPriorityB0
        cmpa  #0                            ; dynamic current priority
        lbne   ESP_NextObjectB0             ; do not process this entry (case of priority change)
        
ESP_UnsetCheckRefreshB0
        lda   rsv_render_flags,u
        ;ldb   render_flags,u               ; this option is deprecated, may be activated in future 
        ;andb  #render_motionless_mask      ; tell display engine to compute sub image and position check only once until the flag is removed
        ;bne   ESP_CheckEraseB0
        anda  #^rsv_render_checkrefresh_mask ; unset checkrefresh flag
        sta   rsv_render_flags,u        
        
ESP_CheckEraseB0
        anda  #rsv_render_erasesprite_mask
        lbeq   ESP_NextObjectB0
        ldb   rsv_prev_render_flags_0,u
        andb  #rsv_prev_render_overlay_mask
        bne   ESP_UnsetOnScreenFlagB0
        
ESP_CallEraseRoutineB0
        lda   rsv_prev_page_erase_routine_0,u
        _SetCartPageA
        ldx   rsv_prev_erase_routine_0,u
        stu   ESP_CallEraseRoutineB0_00+1   ; backup u (pointer to object)                
        ldu   rsv_bgdata_0,u                ; cell_start background data        
        jsr   ,x                            ; erase sprite on working screen buffer
        stu   BBF_cell_end                  ; cell_end background data as parameter to BBF
ESP_CallEraseRoutineB0_00        
        ldu   #$0000                        ; restore u (pointer to object)
        ldd   rsv_bgdata_0,u                ; cell_start
        subd  #16
        andb  #256-cell_size                ; round cell_start to cell size
        std   BBF_cell_start                ; cell_start rounded stored in x
                        
ESP_FreeEraseBufferB0
        lda   rsv_prev_erase_nb_cell_0,u     ; get nb of cell to free
        sta   BBF_nb_cells
        stu   BBF_rts+1
        ldu   #Lst_FreeCell_0
        stu   BBF_AddNewEntry+1
        ldu   #Lst_FreeCellFirstEntry_0        
        stu   BBF_SetNewEntryPrevLink+1     ; init prev address destination as Lst_FreeCellFirstEntry                
        ldu   Lst_FreeCellFirstEntry_0      ; load first cell for screen buffer 0
        jsr   BgBufferFree                  ; free background data in memory
        
ESP_UnsetOnScreenFlagB0
        lda   rsv_prev_render_flags_0,u
        anda  #^rsv_prev_render_onscreen_mask ; sprite is no longer on screen
        sta   rsv_prev_render_flags_0,u
        lda   rsv_render_flags,u
        anda  #^rsv_render_onscreen_mask      ; sprite is no longer on screen
        sta   rsv_render_flags,u

ESP_NextObjectB0
        ldu   rsv_priority_prev_obj_0,u
        lbne   ESP_ProcessEachPriorityLevelB0   
        rts      

* -----------------------------------------------        
* BUFFER1
* -----------------------------------------------        
                
ESP_ProcessEachPriorityLevelB1
        lda   rsv_priority_1,u
        
ESP_CheckPriorityB1
        cmpa  #0                            ; dynamic current priority
        lbne   ESP_NextObjectB1             ; do not process this entry (case of priority change)
        
ESP_UnsetCheckRefreshB1
        lda   rsv_render_flags,u
        ;ldb   render_flags,u               ; this option is deprecated, may be activated in future 
        ;andb  #render_motionless_mask      ; tell display engine to compute sub image and position check only once until the flag is removed
        ;bne   ESP_CheckEraseB1
        anda  #^rsv_render_checkrefresh_mask ; unset checkrefresh flag (CheckSpriteRefresh)
        sta   rsv_render_flags,u        
        
ESP_CheckEraseB1
        anda  #rsv_render_erasesprite_mask
        lbeq   ESP_NextObjectB1
        ldb   rsv_prev_render_flags_1,u
        andb  #rsv_prev_render_overlay_mask
        bne   ESP_UnsetOnScreenFlagB1        
        
ESP_CallEraseRoutineB1
        lda   rsv_prev_page_erase_routine_1,u
        _SetCartPageA
        ldx   rsv_prev_erase_routine_1,u
        stu   ESP_CallEraseRoutineB1_00+1   ; backup u (pointer to object)                
        ldu   rsv_bgdata_1,u                ; cell_start background data        
        jsr   ,x                            ; erase sprite on working screen buffer
        stu   BBF_cell_end                  ; cell_end background data as parameter to BBF
ESP_CallEraseRoutineB1_00        
        ldu   #$0000                        ; restore u (pointer to object)
        ldd   rsv_bgdata_1,u                ; cell_start
        subd  #16
        andb  #256-cell_size                ; round cell_start to cell size
        std   BBF_cell_start                ; cell_start rounded stored in x
                        
ESP_FreeEraseBufferB1
        lda   rsv_prev_erase_nb_cell_1,u       
        sta   BBF_nb_cells         
        stu   BBF_rts+1
        ldu   #Lst_FreeCell_1
        stu   BBF_AddNewEntry+1
        ldu   #Lst_FreeCellFirstEntry_1        
        stu   BBF_SetNewEntryPrevLink+1          
        ldu   Lst_FreeCellFirstEntry_1
        jsr   BgBufferFree                  ; free background data in memory
        
ESP_UnsetOnScreenFlagB1
        lda   rsv_prev_render_flags_1,u
        anda  #^rsv_prev_render_onscreen_mask ; sprite is no longer on screen 
        sta   rsv_prev_render_flags_1,u
        lda   rsv_render_flags,u
        anda  #^rsv_render_onscreen_mask      ; sprite is no longer on screen
        sta   rsv_render_flags,u
        
ESP_NextObjectB1
        ldu   rsv_priority_prev_obj_1,u
        lbne   ESP_ProcessEachPriorityLevelB1   
        rts
        
* ---------------------------------------------------------------------------
* BgBufferFree
* ------------
* Subroutine to free memory from background buffer
* ---------------------------------------------------------------------------
     
BBF_nb_cells   fcb   $00
BBF_cell_start fdb   $0000
BBF_cell_end   fdb   $0000       
BBF_prev       fdb   $0000

        ; search position of the new free cells in the linked list
        ; linked list is ordered by cell_end (address) descending
        ; starting at Lst_FreeCellFirstEntry_x
        ; ----------------------------------------------------------

BgBufferFree        
        beq   BBF_AddLastEntry
BBF_SearchPos 
        ldx   cell_end,u
        cmpx  BBF_cell_end
        blo   BBF_CombineNext
        stu   BBF_prev
        ldd   next_entry,u                  ; test next entry
        beq   BBF_CombinePrevNoNext
        leax  next_entry,u                  ; there is a next entry, save next_entry position
        stx   BBF_SetNewEntryPrevLink+1   
        ldu   next_entry,u                  ; move to next entry        
        bra   BBF_SearchPos        
        
        ; try to combine with next block
        ; ----------------------------------------------------------        
        
BBF_CombineNext
        stu   BBF_SetNewEntryNextentry+1
        ldx   BBF_cell_start
        cmpx  cell_end,u
        bne   BBF_CombinePrev
        ldx   BBF_cell_end
        stx   cell_end,u
        lda   nb_cells,u
        adda  BBF_nb_cells
        sta   nb_cells,u
        
BBF_CombineNextAndPrev
        ldy   BBF_prev
        cmpx  cell_start,y
        bne   BBF_rts
        ldx   cell_start,u
        stx   cell_start,y
        lda   nb_cells,u        
        adda  nb_cells,y
        sta   nb_cells,y
        ldd   next_entry,u
        std   next_entry,y
        lda   #$00
        sta   nb_cells,u                    ; delete the entry
        bra   BBF_rts
                
        ; try to combine with prev block 
        ; ----------------------------------------------------------      
        
BBF_CombinePrevNoNext
        ldd   #$0000
        std   BBF_SetNewEntryNextentry+1
BBF_CombinePrev
        ldx   BBF_cell_end
        cmpx  cell_start,u
        bne   BBF_AddNewEntry
        ldx   BBF_cell_start
        stx   cell_start,u
        lda   nb_cells,u        
        adda  BBF_nb_cells
        sta   nb_cells,u
        bra   BBF_rts   

        ; Add New Entry
        ; ----------------------------------------------------------
        
BBF_AddLastEntry
        ldd   #$0000
        std   BBF_SetNewEntryNextentry+1        
BBF_AddNewEntry
        ldu   #$0000                        ; (dynamic) start of linked list data index
BBF_FindFreeSlot
        ldb   nb_cells,u                    ; read Lst_FreeCell as a table (not a linked list)
        beq   BBF_SetNewEntry               ; branch if empty entry
        leau  entry_size,u                  ; move to next entry
        bra   BBF_FindFreeSlot              ; loop             

BBF_SetNewEntry        
        lda   BBF_nb_cells              
        sta   nb_cells,u                    ; store released cells
        ldd   BBF_cell_start
        std   cell_start,u                  ; store cell start adress
        ldd   BBF_cell_end
        std   cell_end,u                    ; store cell end adress
        
BBF_SetNewEntryNextentry        
        ldd   #$0000                        ; (dynamic) value is dynamically set
        std   next_entry,u                  ; link to 0000 if no more entry or next_entry
        
BBF_SetNewEntryPrevLink        
        stu   >$0                           ; (dynamic) set Lst_FreeCellFirstEntry or prev_entry.next_entry with new entry
        
BBF_rts
        ldu   #$0000
        rts
                