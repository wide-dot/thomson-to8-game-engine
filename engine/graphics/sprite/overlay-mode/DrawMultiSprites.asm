* ---------------------------------------------------------------------------
* DrawMultiSprites
* ----------------
* Subroutine to draw sprites and multi-sprites on screen
* Use this routine only when a full refresh is made each frame
* All sprites must be overlay type, no mix allowed with background save type
* Read Display Priority Structure (back to front)
* priority: 0 - unregistred
* priority; 1-8 - registered sprite (2:front, ..., 8:back)  
*
* input REG : none
* ---------------------------------------------------------------------------


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

                                                      *BuildSprites_P1_LevelLoop:
                                                      *        move.w  (a4),d0 ; does this priority level have any objects?
                                                      *        beq.w   BuildSprites_P1_NextLevel       ; if not, check next one
                                                      *        move.w  d0,-(sp)
                                                      *        moveq   #2,d6
                                                      *; loc_1698C:
                                                      *BuildSprites_P1_ObjLoop:
                                                      *        movea.w (a4,d6.w),a0 ; a0=object
                                                      *        tst.b   id(a0)
                                                      *        beq.w   BuildSprites_P1_NextObj
                                                      *        andi.b  #$7F,render_flags(a0)
                                                      *        move.b  render_flags(a0),d0
                                                      *        move.b  d0,d4
                                                      *        btst    #6,d0
                                                      *        bne.w   BuildSprites_P1_MultiDraw
                                                      *        andi.w  #$C,d0
                                                      *        beq.s   BuildSprites_P1_ScreenSpaceObj
                                                      *        lea     (Camera_X_pos).w,a1
                                                      *        moveq   #0,d0
                                                      *        move.b  width_pixels(a0),d0
                                                      *        move.w  x_pos(a0),d3
                                                      *        sub.w   (a1),d3
                                                      *        move.w  d3,d1
                                                      *        add.w   d0,d1
                                                      *        bmi.w   BuildSprites_P1_NextObj
                                                      *        move.w  d3,d1
                                                      *        sub.w   d0,d1
                                                      *        cmpi.w  #320,d1
                                                      *        bge.s   BuildSprites_P1_NextObj
                                                      *        addi.w  #128,d3
                                                      *        btst    #4,d4
                                                      *        beq.s   BuildSprites_P1_ApproxYCheck
                                                      *        moveq   #0,d0
                                                      *        move.b  y_radius(a0),d0
                                                      *        move.w  y_pos(a0),d2
                                                      *        sub.w   4(a1),d2
                                                      *        move.w  d2,d1
                                                      *        add.w   d0,d1
                                                      *        bmi.s   BuildSprites_P1_NextObj
                                                      *        move.w  d2,d1
                                                      *        sub.w   d0,d1
                                                      *        cmpi.w  #224,d1
                                                      *        bge.s   BuildSprites_P1_NextObj
                                                      *        addi.w  #256,d2
                                                      *        bra.s   BuildSprites_P1_DrawSprite
                                                      *; ===========================================================================
                                                      *; loc_16A00:
                                                      *BuildSprites_P1_ScreenSpaceObj:
                                                      *        move.w  y_pixel(a0),d2
                                                      *        move.w  x_pixel(a0),d3
                                                      *        addi.w  #128,d2
                                                      *        bra.s   BuildSprites_P1_DrawSprite
                                                      *; ===========================================================================
                                                      *; loc_16A0E:
                                                      *BuildSprites_P1_ApproxYCheck:
                                                      *        move.w  y_pos(a0),d2
                                                      *        sub.w   4(a1),d2
                                                      *        addi.w  #128,d2
                                                      *        cmpi.w  #-32+128,d2
                                                      *        blo.s   BuildSprites_P1_NextObj
                                                      *        cmpi.w  #32+128+224,d2
                                                      *        bhs.s   BuildSprites_P1_NextObj
                                                      *        addi.w  #128,d2
                                                      *; loc_16A2A:
                                                      *BuildSprites_P1_DrawSprite:
                                                      *        movea.l mappings(a0),a1
                                                      *        moveq   #0,d1
                                                      *        btst    #5,d4
                                                      *        bne.s   +
                                                      *        move.b  mapping_frame(a0),d1
                                                      *        add.w   d1,d1
                                                      *        adda.w  (a1,d1.w),a1
                                                      *        move.w  (a1)+,d1
                                                      *        subq.w  #1,d1
                                                      *        bmi.s   ++
                                                      *+
                                                      *        bsr.w   DrawSprite_2P
                                                      *+
                                                      *        ori.b   #$80,render_flags(a0)
                                                      *; loc_16A50:
                                                      *BuildSprites_P1_NextObj:
                                                      *        addq.w  #2,d6
                                                      *        subq.w  #2,(sp)
                                                      *        bne.w   BuildSprites_P1_ObjLoop
                                                      *        addq.w  #2,sp
                                                      *; loc_16A5A:
                                                      *BuildSprites_P1_NextLevel:
                                                      *        lea     $80(a4),a4
                                                      *        dbf     d7,BuildSprites_P1_LevelLoop
                                                      *        move.b  d5,(Sprite_count).w
                                                      *        cmpi.b  #80,d5
                                                      *        bhs.s   +
                                                      *        move.l  #0,(a2)
                                                      *        bra.s   BuildSprites_P2
                                                      *+
                                                      *        move.b  #0,-5(a2)                                                      

                                                      *; ===========================================================================
                                                      *; loc_16B9A:
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