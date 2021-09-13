* ---------------------------------------------------------------------------
* BgBufferAlloc
* -------------
* Subroutine to allocate memory into background buffer
*
* input  REG : [a] number of requested cells
* output REG : [y] cell_end or 0000 if no more space
* ---------------------------------------------------------------------------

BgBufferAlloc
        pshs  b,x
        ldb   glb_Cur_Wrk_Screen_Id         ; read current screen buffer for write operations
        bne   BBA1                          ; branch if buffer 1 is current
        
BBA0        
        ldx   #Lst_FreeCellFirstEntry_0     ; save previous cell.next_entry into x for future update
        ldy   Lst_FreeCellFirstEntry_0      ; load first cell for screen buffer 0
        bra   BBA_Next
        
BBA1        
        ldx   #Lst_FreeCellFirstEntry_1     ; save previous cell.next_entry into x for future update
        ldy   Lst_FreeCellFirstEntry_1      ; load first cell for screen buffer 1
        
BBA_Next
        beq   BBA_rts                       ; loop thru all entries, branch if no more free space
        cmpa  nb_cells,y                    ; compare current nb of free cells with requested
        beq   BBA_FitCell                   ; branch if current free cells is the same size than requested
        bls   BBA_DivideCell                ; branch if current free cells are greater than requested
        leax  next_entry,y                  ; save previous cell.next_entry into x for future update        
        ldy   next_entry,y                  ; move to next entry
        bra   BBA_Next
          
BBA_FitCell
        ldd   next_entry,y
        std   ,x                            ; chain previous cell with next cell
        clr   nb_cells,y                    ; delete current cell
        ldy   cell_end,y                    ; return cell_end
        bra   BBA_rts
        
BBA_DivideCell
        sta   BBA_dyn+1
        ldb   nb_cells,y
BBA_dyn
        subb  #$00                          ; substract requested cells to nb_cells
        stb   nb_cells,y                    ; update nb_cells
        
        ldb   #cell_size
        mul
        eora  #$FF                          ; set negative
        eorb  #$FF                          ; set negative        
        addd  #$01
        ldx   cell_end,y
        stx   cell_end_return+2        
        leax  d,x                           ; cell_end = cell_end - (number of requested cells * nb of bytes in a cell)
        stx   cell_end,y                    ; update cell_end
cell_end_return        
        ldy   #$0000
BBA_rts
        puls  b,x,pc