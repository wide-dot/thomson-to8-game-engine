; DIRECT PAGE TEMP VARIABLES
; --------------------------
glb_d0   equ   direct_page+128
glb_d0_b equ   direct_page+129
glb_d1   equ   direct_page+130
glb_d1_b equ   direct_page+131
glb_d2   equ   direct_page+132
glb_d2_b equ   direct_page+133
; must be a free byte here for 24bits computation
glb_d3   equ   direct_page+135
glb_d3_b equ   direct_page+136
; must be a free byte here for 24bits computation
glb_d4   equ   direct_page+138
glb_d4_b equ   direct_page+139
glb_d5   equ   direct_page+140
glb_d5_b equ   direct_page+141
glb_d6   equ   direct_page+142
glb_d6_b equ   direct_page+143
glb_a3   equ   direct_page+144
glb_a3_b equ   direct_page+145
glb_a4   equ   direct_page+146
glb_a4_b equ   direct_page+147
glb_page equ   direct_page+148

                                                      * ; ===========================================================================
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to find which tile is in the specified location
                                                      * ; d2 = y_pos
                                                      * ; d3 = x_pos
                                                      * ; returns relevant block ID in (a1)
                                                      * ; a1 is pointer to block in chunk table
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
; unlinke in TilemapBuffer.asm
; maps are expected to be 128 chunks wide
; you will need to change this code if not 
                                                      * ; loc_1E596: Floor_ChkTile:
Find_Tile                                             * Find_Tile:
        lda   glb_map_chunk_pge
        _SetCartPageA    
        ldd   glb_d2                                  *         movea.w d2,d0   ; y_pos
        ; unlike original no interlace of background
        ; and foreground in tilemap                   *         add.w   d0,d0
        anda  #$0F
        andb  #$80                                    *         andi.w  #$F00,d0        ; rounded 2*y_pos
        std   glb_d0
        ; chunks are 64px wide instead of 128px
        ldd   glb_d3                                  *         movea.w d3,d1   ; x_pos
        _lsrd
        _lsrd                                         *         lsr.w   #3,d1
        stb   @d4_b                                   *         movea.w d1,d4
        _lsrd
        _lsrd
        _lsrd
        _lsrd                                         *         lsr.w   #4,d1   ; x_pos/128 = x_of_chunk
        anda  #0
        andb  #$3F ; chunk is 64px wide not 128px     *         andi.w  #$7F,d1
        addd  glb_d0                                  *         add.w   d1,d0   ; d0 is relevant chunk ID now
                                                      *         moveq   #-1,d1
        ldx   glb_map_chunk_adr                       *         clr.w   d1              ; d1 is now $FFFF0000 = Chunk_Table
        leax  d,x                                     *         lea     (Level_Layout).w,a1
        lda   ,x                                      *         move.b  (a1,d0.w),d1    ; move 128*128 chunk ID to d1
        bpl   @a
        ldx   glb_map_defchunk1_adr
        anda  #%01111111
        ldb   glb_map_defchunk1_pge
        bra   @b
@a      ldx   glb_map_defchunk0_adr
        ldb   glb_map_defchunk0_pge
@b      stb   chk_idx_pge
        _SetCartPageB
        andb  #0 ; shift right to get x128
        _asrd    ; instead of using a LUT             *         add.w   d1,d1
        leax  d,x                                     *         move.w  word_1E5D0(pc,d1.w),d1
        ldb   glb_d2_b                                *         movea.w d2,d0   ; y_pos
        andb  #$70                                    *         andi.w  #$70,d0
        abx                                           *         add.w   d0,d1
        ldb   #0
@d4_b   equ   *-1
        andb  #$E                                     *         andi.w  #$E,d4  ; x_pos/8
        abx                                           *         add.w   d4,d1
        ; x is loaded with address of block ID        *         movea.l d1,a1   ; address of block ID
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ; precalculated values for Find_Tile
                                                      * ; (Sonic 1 calculated it every time instead of using a table)
        ; table replaced by a shift                   * word_1E5D0:
                                                      * c := 0
                                                      *         rept 256
                                                      *                 dc.w    c
                                                      * c := c+$80
                                                      *         endm
                                                      * ; ===========================================================================

                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; Scans vertically for up to 2 16x16 blocks to find solid ground or ceiling.
                                                      * ; d2 = y_pos
                                                      * ; d3 = x_pos
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; d6 = $0000 for no flip, $0800 for vertical flip
                                                      * ; a3 = delta-y for next location to check if current one is empty
                                                      * ; a4 = pointer to angle buffer
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance in d1
                                                      * ; returns angle in (a4)
                                                      * 
                                                      * ; loc_1E7D0:
FindFloor                                             * FindFloor:
        _GetCartPageA
        sta   glb_page
        jsr   Find_Tile                               *         bsr.w   Find_Tile
        ldd   ,x                                      *         move.w  (a1),d0
        std   glb_d4                                  *         movea.w d0,d4

        ; keep tile id by filtering out flags
        ; unlike original game, this code allow 1024 8x16 tiles instead of 512
        ; because no hardware flip is available, we dont need the flags, but need more tiles
        ; priority flag was added to be able to do a quick check at rendering stage
        ; Each 8x16 tile has a two-byte value with the format PSST TIII IIII IIII
        ; P is the priority of the tile (0:background or 1:foreground)
        ; SS is the solidity of the tile in the alternate collision layer - 00 means not solid, 01 means top solid, 10 means left/right/bottom solid, and 11 means all solid
        ; TT is the solidity of the tile in the normal collision layer - 00 means not solid, 01 means top solid, 10 means left/right/bottom solid, and 11 means all solid
        ; III IIII IIII is the index of the 16x16 tile to use

        anda  #7                                      *         andi.w  #$3FF,d0
        std   glb_d0
        beq   loc_1E7E2                               *         beq.s   loc_1E7E2
        lda   glb_d4
        bita  glb_d5_b                                *         btst    d5,d4
        bne   loc_1E7F0                               *         bne.s   loc_1E7F0
                                                      * 
loc_1E7E2                                             * loc_1E7E2:
        ldd   glb_d2
        addd  glb_a3                                  *         add.w   a3,d2
        std   glb_d2
        jsr   FindFloor2                              *         bsr.w   FindFloor2
        ldd   glb_d2
        subd  glb_a3                                  *         sub.w   a3,d2
        std   glb_d2
        ldd   glb_d1
        addd  #$10
        std   glb_d1                                  *         addi.w  #$10,d1
        lda   glb_page
        _SetCartPageA
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1E7F0                                             * loc_1E7F0:      ; block has some solidity
        lda   glb_map_pge
        _SetCartPageA    
        ldx   Flip_Collision
        ldd   glb_d0 ; get tile id
        lda   d,x    ; get flip bits for this tile
        sta   glb_d4 ; store flip bits
        ldx   Collision_addr                          *         movea.l (Collision_addr).w,a2   ; pointer to collision data, i.e. blockID -> collisionID array
        ldd   glb_d0
        ldb   d,x    ; get collision id               *         move.b  (a2,d0.w),d0    ; get collisionID
        anda  #0
        std   glb_d0                                  *         andi.w  #$FF,d0
        beq   loc_1E7E2 ; no collision data           *         beq.s   loc_1E7E2
        lda   ColData_page
        _SetCartPageA   
        ldx   ColCurveMap                             *         lea     (ColCurveMap).l,a2
        abx
        lda   ,x     ; get angle for this tile        *         move.b  (a2,d0.w),(a4)  ; get angle from AngleMap --> (a4)
        sta   [glb_a4]
        ldd   glb_d0 ; load collision id
        _lsld        ; height index store 8 values
        _lsld        ; for each tiles (8px wide)
        _lsld        ; scale id x8
        std   glb_d0                                  *         lsl.w   #4,d0
        ldd   glb_d3
        std   glb_d1                                  *         movea.w d3,d1   ; x_pos
        lda   glb_d4
        bita  #1                                      *         btst    #$A,d4  ; adv.blockID in d4 - X flipping
        beq   >                                       *         beq.s   +
        com   glb_d1                                  *         not.w   d1
        com   glb_d1_b
        neg   [glb_a4]                                *         neg.b   (a4)
!                                                     * +
        bita  #2                                      *         btst    #$B,d4  ; Y flipping
        beq   >                                       *         beq.s   +
        ldb   [glb_a4]
        addb  #$40                                    *         addi.b  #$40,(a4)
        negb                                          *         neg.b   (a4)
        subb  #$40                                    *         subi.b  #$40,(a4)
        stb   [glb_a4]
!                                                     * +
        ldd   glb_d1
        anda  #0
        andb  #7 ; (mod 8)                            *         andi.w  #$F,d1  ; x_pos (mod 16)
        addd  glb_d0                                  *         add.w   d0,d1   ; d0 = 16*blockID -> offset in ColArray to look up
        ldx   ColArray                                *         lea     (ColArray).l,a2
        ldb   d,x                                     *         move.b  (a2,d1.w),d0    ; heigth from ColArray
        sex                                           *         ext.w   d0
        std   glb_d0
        lda   glb_d4
        eora  glb_d6_b                                *         eor.w   d6,d4
        bita  #2                                      *         btst    #$B,d4  ; Y flipping
        beq   >                                       *         beq.s   +
        ldd   glb_d0
        _negd                                         *         neg.w   d0
        std   glb_d0
!                                                     * +
        ldd   glb_d0                                  *         tst.w   d0
        lbeq  loc_1E7E2                               *         beq.s   loc_1E7E2       ; no collision
        bmi   loc_1E85E                               *         bmi.s   loc_1E85E
        cmpb  #$10                                    *         cmpi.b  #$10,d0
        beq   loc_1E86A                               *         beq.s   loc_1E86A
        ldd   glb_d2                                  *         movea.w d2,d1
        anda  #0
        andb  #$F                                     *         andi.w  #$F,d1
        addd  glb_d0                                  *         add.w   d1,d0
        std   glb_d0
        ldd   #$F                                     *         movea.w #$F,d1
        subd  glb_d0                                  *         sub.w   d0,d1
        std   glb_d1
        lda   glb_page
        _SetCartPageA
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1E85E                                             * loc_1E85E:
        ldd   glb_d2                                  *         movea.w d2,d1
        anda  #0
        andb  #$F                                     *         andi.w  #$F,d1
        std   glb_d1
        addd  glb_d0                                  *         add.w   d1,d0
        std   glb_d0
        lbpl   loc_1E7E2                               *         bpl.w   loc_1E7E2
                                                      * 
loc_1E86A                                             * loc_1E86A:
        ldd   glb_d2
        subd  glb_a3                                  *         sub.w   a3,d2
        std   glb_d2
        jsr   FindFloor2                              *         bsr.w   FindFloor2
        addd  glb_a3                                  *         add.w   a3,d2
        std   glb_d2
        ldd   glb_d1
        subd  #$10
        std   glb_d1                                  *         subi.w  #$10,d1
        lda   glb_page
        _SetCartPageA
        rts                                           *         rts
                                                      * ; End of function FindFloor
                                                      * 
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; Checks a 16x16 block to find solid ground or ceiling.
                                                      * ; d2 = y_pos
                                                      * ; d3 = x_pos
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; d6 = $0000 for no flip, $0800 for vertical flip
                                                      * ; a4 = pointer to angle buffer
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance in d1
                                                      * ; returns angle in (a4)
                                                      * 
                                                      * ; loc_1E878:
FindFloor2                                            * FindFloor2:
        jsr   Find_Tile                               *         bsr.w   Find_Tile
        ldd   ,x                                      *         move.w  (a1),d0
        std   glb_d4                                  *         movea.w d0,d4
        anda  #7                                      *         andi.w  #$3FF,d0
        std   glb_d0
        beq   loc_1E88A                               *         beq.s   loc_1E88A
        lda   glb_d4
        bita  glb_d5_b                                *         btst    d5,d4
        bne   loc_1E898                               *         bne.s   loc_1E898
                                                      * 
loc_1E88A                                             * loc_1E88A:
        ;                                             *         movea.w #$F,d1
        ldd   glb_d2                                  *         movea.w d2,d0
        andb  #$F                                     *         andi.w  #$F,d0
        std   glb_d0
        ldd   #$F
        subd  glb_d0                                  *         sub.w   d0,d1
        std   glb_d1
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1E898                                             * loc_1E898:
        lda   glb_map_pge
        _SetCartPageA    
        ldx   Flip_Collision
        ldd   glb_d0 ; get tile id
        lda   d,x    ; get flip bits for this tile
        sta   glb_d4 ; store flip bits
        ldx   Collision_addr                          *         movea.l (Collision_addr).w,a2
        ldd   glb_d0
        ldb   d,x    ; get collision id               *         move.b  (a2,d0.w),d0
        anda  #0                                      *         andi.w  #$FF,d0
        std   glb_d0
        beq   loc_1E88A ; no collision data           *         beq.s   loc_1E88A
        lda   ColData_page
        _SetCartPageA    
        ldx   ColCurveMap                             *         lea     (ColCurveMap).l,a2
        abx        
        lda   ,x     ; get angle for this tile        *         move.b  (a2,d0.w),(a4)
        sta   [glb_a4]
        ldd   glb_d0 ; load collision id
        _lsld        ; height index store 8 values
        _lsld        ; for each tiles (8px wide)
        _lsld        ; scale id x8
        std   glb_d0                                  *         lsl.w   #4,d0
        ldd   glb_d3
        std   glb_d1                                  *         movea.w d3,d1
        lda   glb_d4
        bita  #1                                      *         btst    #$A,d4
        beq   >                                       *         beq.s   +
        com   glb_d1                                  *         not.w   d1
        com   glb_d1_b
        neg   [glb_a4]                                *         neg.b   (a4)
!                                                     * +
        bita  #2                                      *         btst    #$B,d4
        beq   >                                       *         beq.s   +
        ldb   [glb_a4]
        addb  #$40                                    *         addi.b  #$40,(a4)
        negb                                          *         neg.b   (a4)
        subb  #$40                                    *         subi.b  #$40,(a4)
        stb   [glb_a4]
!                                                     * +
        ldd   glb_d1
        anda  #0
        andb  #7 ; (mod 8)                            *         andi.w  #$F,d1
        addd  glb_d0                                  *         add.w   d0,d1
        ldx   ColArray                                *         lea     (ColArray).l,a2
        ldb   d,x                                     *         move.b  (a2,d1.w),d0
        sex                                           *         ext.w   d0
        std   glb_d0
        lda   glb_d4
        eora  glb_d6_b                                *         eor.w   d6,d4
        bita  #2                                      *         btst    #$B,d4
        beq   >                                       *         beq.s   +
        ldd   glb_d0
        _negd                                         *         neg.w   d0
        std   glb_d0
!                                                     * +
        ldd   glb_d0                                  *         tst.w   d0
        lbeq  loc_1E88A                               *         beq.s   loc_1E88A
        bmi   loc_1E900                               *         bmi.s   loc_1E900
        ldd   glb_d2                                  *         movea.w d2,d1
        anda  #0
        andb  #$F                                     *         andi.w  #$F,d1
        addd  glb_d0                                  *         add.w   d1,d0
        std   glb_d0
        ldd   #$F                                     *         movea.w #$F,d1
        subd  glb_d0                                  *         sub.w   d0,d1
        std   glb_d1
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1E900                                             * loc_1E900:
        ldd   glb_d2                                  *         movea.w d2,d1
        anda  #0    
        andb  #$F                                     *         andi.w  #$F,d1
        std   glb_d1
        addd  glb_d0                                  *         add.w   d1,d0
        std   glb_d0
        lbpl  loc_1E88A                               *         bpl.w   loc_1E88A
        com   glb_d1                                  *         not.w   d1
        com   glb_d1_b
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * ; Checks a 16x16 block to find solid ground or ceiling. May check an additional
                                                      * ; 16x16 block up for ceilings.
                                                      * ; d2 = y_pos
                                                      * ; d3 = x_pos
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; d6 = $0000 for no flip, $0800 for vertical flip
                                                      * ; a4 = pointer to angle buffer
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance in d1
                                                      * ; returns angle in (a4)
                                                      * 
                                                      * ; loc_1E910: Obj_CheckInFloor:
Ring_FindFloor                                        * Ring_FindFloor:
                                                      *         bsr.w   Find_Tile
                                                      *         move.w  (a1),d0
                                                      *         movea.w d0,d4
                                                      *         andi.w  #$3FF,d0
                                                      *         beq.s   loc_1E922
                                                      *         btst    d5,d4
                                                      *         bne.s   loc_1E928
                                                      * 
                                                      * loc_1E922:
                                                      *         movea.w #$10,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E928:
                                                      *         movea.l (Collision_addr).w,a2
                                                      *         move.b  (a2,d0.w),d0
                                                      *         andi.w  #$FF,d0
                                                      *         beq.s   loc_1E922
                                                      *         lea     (ColCurveMap).l,a2
                                                      *         move.b  (a2,d0.w),(a4)
                                                      *         lsl.w   #4,d0
                                                      *         movea.w d3,d1
                                                      *         btst    #$A,d4
                                                      *         beq.s   +
                                                      *         not.w   d1
                                                      *         neg.b   (a4)
                                                      * +
                                                      *         btst    #$B,d4
                                                      *         beq.s   +
                                                      *         addi.b  #$40,(a4)
                                                      *         neg.b   (a4)
                                                      *         subi.b  #$40,(a4)
                                                      * +
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d0,d1
                                                      *         lea     (ColArray).l,a2
                                                      *         move.b  (a2,d1.w),d0
                                                      *         ext.w   d0
                                                      *         eor.w   d6,d4
                                                      *         btst    #$B,d4
                                                      *         beq.s   +
                                                      *         neg.w   d0
                                                      * +
                                                      *         tst.w   d0
                                                      *         beq.s   loc_1E922
                                                      *         bmi.s   loc_1E996
                                                      *         cmpi.b  #$10,d0
                                                      *         beq.s   loc_1E9A2
                                                      *         movea.w d2,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         movea.w #$F,d1
                                                      *         sub.w   d0,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E996:
                                                      *         movea.w d2,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         bpl.w   loc_1E922
                                                      * 
                                                      * loc_1E9A2:
                                                      *         sub.w   a3,d2
                                                      *         bsr.w   FindFloor2
                                                      *         add.w   a3,d2
                                                      *         subi.w  #$10,d1
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; Scans horizontally for up to 2 16x16 blocks to find solid walls.
                                                      * ; d2 = y_pos
                                                      * ; d3 = x_pos
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; d6 = $0000 for no flip, $0400 for horizontal flip
                                                      * ; a3 = delta-x for next location to check if current one is empty
                                                      * ; a4 = pointer to angle buffer
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance to left/right in d1
                                                      * ; returns angle in (a4)
                                                      * 
                                                      * ; loc_1E9B0:
FindWall                                              * FindWall:
        _GetCartPageA
        sta   glb_page
        jsr   Find_Tile                               *         bsr.w   Find_Tile
        ldd   ,x                                      *         move.w  (a1),d0
        std   glb_d4                                  *         movea.w d0,d4
        anda  #7                                      *         andi.w  #$3FF,d0        ; plain blockID
        std   glb_d0
        beq   loc_1E9C2                               *         beq.s   loc_1E9C2       ; no collision
        lda   glb_d4
        bita  glb_d5_b                                *         btst    d5,d4
        bne   loc_1E9D0                               *         bne.s   loc_1E9D0
                                                      * 
loc_1E9C2                                             * loc_1E9C2:
        ldd   glb_d3
        addd  glb_a3                                  *         add.w   a3,d3
        std   glb_d3
        jsr   FindWall2                               *         bsr.w   FindWall2
        ldd   glb_d3
        subd  glb_a3                                  *         sub.w   a3,d3
        std   glb_d3
        ldd   glb_d1
        addd  #$10
        std   glb_d1                                  *         addi.w  #$10,d1
        lda   glb_page
        _SetCartPageA
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1E9D0                                             * loc_1E9D0:
        lda   glb_map_pge
        _SetCartPageA    
        ldx   Flip_Collision
        ldd   glb_d0 ; get tile id
        lda   d,x    ; get flip bits for this tile
        sta   glb_d4 ; store flip bits
        ldx   Collision_addr                          *         movea.l (Collision_addr).w,a2
        ldd   glb_d0
        ldb   d,x    ; get collision id               *         move.b  (a2,d0.w),d0
        anda  #0
        std   glb_d0                                  *         andi.w  #$FF,d0 ; relevant collisionArrayEntry
        beq   loc_1E9C2 ; no collision data           *         beq.s   loc_1E9C2
        lda   ColData_page
        _SetCartPageA    
        ldx   ColCurveMap                             *         lea     (ColCurveMap).l,a2
        abx
        lda   ,x     ; get angle for this tile        *         move.b  (a2,d0.w),(a4)
        sta   [glb_a4]
        ldd   glb_d0 ; load collision id
        _lsld        ; height index store 8 values
        _lsld        ; for each tiles (8px wide)
        _lsld        ; scale id x8
        std   glb_d0                                  *         lsl.w   #4,d0   ; offset in collision array
        ldd   glb_d2
        std   glb_d1                                  *         movea.w d2,d1   ; y
        lda   glb_d4
        bita  #2                                      *         btst    #$B,d4  ; y-mirror?
        beq   >                                       *         beq.s   +
        com   glb_d1
        com   glb_d1_b                                *         not.w   d1
        ldb   [glb_a4]
        addb  #$40                                    *         addi.b  #$40,(a4)
        negb                                          *         neg.b   (a4)
        subb  #$40                                    *         subi.b  #$40,(a4)
        stb   [glb_a4]
!                                                     * +
        bita  #1                                      *         btst    #$A,d4  ; x-mirror?
        beq   >                                       *         beq.s   +
        neg   [glb_a4]                                *         neg.b   (a4)
!                                                     * +
        ldd   glb_d1
        _asrd    ; lower resolution of y axis to 8px
        anda  #0
        andb  #7 ; (mod 8)                            *         andi.w  #$F,d1  ; y
        addd  glb_d0                                  *         add.w   d0,d1   ; line to look up
        ldx   ColArray2                               *         lea     (ColArray2).l,a2        ; rotated collision array
        ldb   d,x                                     *         move.b  (a2,d1.w),d0    ; collision value
        sex                                           *         ext.w   d0
        std   glb_d0
        lda   glb_d4
        eora  glb_d6_b                                *         eor.w   d6,d4   ; set x-flip flag if from the right
        bita  #1                                      *         btst    #$A,d4  ; x-mirror?
        beq   >                                       *         beq.s   +
        ldd   glb_d0
        _negd                                         *         neg.w   d0
        std   glb_d0
!                                                     * +
        ldd   glb_d0                                  *         tst.w   d0
        lbeq   loc_1E9C2                               *         beq.s   loc_1E9C2
        bmi   loc_1EA3E                               *         bmi.s   loc_1EA3E
        cmpb  #$10                                    *         cmpi.b  #$10,d0
        beq   loc_1EA4A                               *         beq.s   loc_1EA4A
        ldd   glb_d3                                  *         movea.w d3,d1   ; x
        anda  #0
        andb  #$F                                     *         andi.w  #$F,d1
        addd  glb_d0                                  *         add.w   d1,d0
        std   glb_d0
        ldd   #$F                                     *         movea.w #$F,d1
        subd  glb_d0                                  *         sub.w   d0,d1
        std   glb_d1
        lda   glb_page
        _SetCartPageA
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1EA3E                                             * loc_1EA3E:
        ldd   glb_d3                                  *         movea.w d3,d1
        anda  #0
        andb  #$F                                     *         andi.w  #$F,d1
        std   glb_d1
        addd  glb_d0                                  *         add.w   d1,d0
        std   glb_d0
        lbpl   loc_1E9C2                               *         bpl.w   loc_1E9C2       ; no collision
                                                      * 
loc_1EA4A                                             * loc_1EA4A:
        ldd   glb_d3
        subd  glb_a3                                  *         sub.w   a3,d3
        std   glb_d3
        jsr   FindWall2                               *         bsr.w   FindWall2
        addd  glb_a3                                  *         add.w   a3,d3
        std   glb_d3
        ldd   glb_d1
        subd  #$10
        std   glb_d1                                  *         subi.w  #$10,d1
        lda   glb_page
        _SetCartPageA
        rts                                           *         rts
                                                      * ; End of function FindWall
                                                      * 
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; Checks a 16x16 blocks to find solid walls.
                                                      * ; d2 = y_pos
                                                      * ; d3 = x_pos
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; d6 = $0000 for no flip, $0400 for horizontal flip
                                                      * ; a4 = pointer to angle buffer
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance to left/right in d1
                                                      * ; returns angle in (a4)
                                                      * 
                                                      * ; loc_1EA58:
FindWall2                                             * FindWall2:
        jsr   Find_Tile                               *         bsr.w   Find_Tile
        ldd   ,x                                      *         move.w  (a1),d0
        std   glb_d4                                  *         movea.w d0,d4
        anda  #7                                      *         andi.w  #$3FF,d0
        std   glb_d0
        beq   loc_1EA6A                               *         beq.s   loc_1EA6A
        lda   glb_d4
        bita  glb_d5_b                                *         btst    d5,d4
        bne   loc_1EA78                               *         bne.s   loc_1EA78
                                                      * 
loc_1EA6A                                            * loc_1EA6A:
        ;                                             *         movea.w #$F,d1
        ldd   glb_d3                                  *         movea.w d3,d0
        andb  #$F                                     *         andi.w  #$F,d0
        std   glb_d0
        ldd   #$F
        subd  glb_d0                                  *         sub.w   d0,d1
        std   glb_d1
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1EA78                                             * loc_1EA78:
        lda   glb_map_pge
        _SetCartPageA    
        ldx   Flip_Collision
        ldd   glb_d0 ; get tile id
        lda   d,x    ; get flip bits for this tile
        sta   glb_d4 ; store flip bits
        ldx   Collision_addr                          *         movea.l (Collision_addr).w,a2
        ldd   glb_d0
        ldb   d,x    ; get collision id               *         move.b  (a2,d0.w),d0
        anda  #0
        std   glb_d0                                  *         andi.w  #$FF,d0
        beq   loc_1EA6A ; no collision data           *         beq.s   loc_1EA6A
        lda   ColData_page
        _SetCartPageA    
        ldx   ColCurveMap                             *         lea     (ColCurveMap).l,a2
        abx
        lda   ,x     ; get angle for this tile        *         move.b  (a2,d0.w),(a4)
        sta   [glb_a4]
        ldd   glb_d0 ; load collision id
        _lsld        ; height index store 8 values
        _lsld        ; for each tiles (8px wide)
        _lsld        ; scale id x8
        std   glb_d0                                  *         lsl.w   #4,d0
        ldd   glb_d2
        std   glb_d1                                  *         movea.w d2,d1
        lda   glb_d4
        bita  #2                                      *         btst    #$B,d4
        beq   >                                       *         beq.s   +
        com   glb_d1
        com   glb_d1_b                                *         not.w   d1
        ldb   [glb_a4]
        addb  #$40                                    *         addi.b  #$40,(a4)
        negb                                          *         neg.b   (a4)
        subb  #$40                                    *         subi.b  #$40,(a4)
        stb   [glb_a4]
!                                                     * +
        bita  #1                                      *         btst    #$A,d4  ; x-mirror?
        beq   >                                       *         beq.s   +
        neg   [glb_a4]                                *         neg.b   (a4)
!                                                     * +
        ldd   glb_d1
        _asrd    ; lower resolution of y axis to 8px
        anda  #0
        andb  #7 ; (mod 8)                            *         andi.w  #$F,d1
        addd  glb_d0                                  *         add.w   d0,d1
        ldx   ColArray2                               *         lea     (ColArray2).l,a2
        ldb   d,x                                     *         move.b  (a2,d1.w),d0
        sex                                           *         ext.w   d0
        std   glb_d0
        lda   glb_d4
        eora  glb_d6_b                                *         eor.w   d6,d4
        bita  #1                                      *         btst    #$A,d4
        beq   >                                       *         beq.s   +
        ldd   glb_d0
        _negd                                         *         neg.w   d0
        std   glb_d0
!                                                     * +
        ldd   glb_d0                                  *         tst.w   d0
        lbeq   loc_1EA6A                               *         beq.s   loc_1EA6A
        bmi   loc_1EAE0                               *         bmi.s   loc_1EAE0
        ldd   glb_d3                                  *         movea.w d3,d1   ; x
        anda  #0
        andb  #$F                                     *         andi.w  #$F,d1
        addd  glb_d0                                  *         add.w   d1,d0
        std   glb_d0
        ldd   #$F                                     *         movea.w #$F,d1
        subd  glb_d0                                  *         sub.w   d0,d1
        std   glb_d1
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1EAE0                                             * loc_1EAE0:
        ldd   glb_d3                                  *         movea.w d3,d1
        anda  #0
        andb  #$F                                     *         andi.w  #$F,d1
        std   glb_d1
        addd  glb_d0                                  *         add.w   d1,d0
        std   glb_d0
        lbpl  loc_1EA6A                               *         bpl.w   loc_1EA6A
        com   glb_d1                                  *         not.w   d1
        com   glb_d1_b
        rts                                           *         rts
                                                      * ; End of function FindWall2
                                                      * 

Primary_Angle                   fcb   0
Secondary_Angle                 fcb   0
Primary_Collision               fdb   0
Secondary_Collision             fdb   0
Flip_Collision                  fdb   0
Collision_addr                  fdb   0