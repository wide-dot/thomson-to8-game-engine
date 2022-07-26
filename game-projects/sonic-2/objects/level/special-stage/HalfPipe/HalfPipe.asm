; ---------------------------------------------------------------------------
; Object - Special Stage
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Two objects in one to reduce the call of page swap routine
;
; ---------------------------------------------------------------------------

        INCLUDE "./objects/level/special-stage/SSBomb/Constants.asm"
        INCLUDE "./engine/macros.asm"   
        
HalfPipe_Img_Duration equ 5 ; (min value = 5) track maximum refresh rate: 50Hz/HalfPipe_Img_Duration= x fps
HalfPipe_one_z_step   equ (HalfPipe_Img_z_depth*256)/HalfPipe_Img_Duration

SpecialStage
        lda   routine,u
        asla
        ldx   #SpecialStage_Routines
        jmp   [a,x]

SpecialStage_Routines
        fdb   SpecialStage_Init
        fdb   SpecialStage_Main
        
                                                      *; ===========================================================================
                                                      *; loc_4F64:
SpecialStage_Init                                     *SpecialStage:
        inc   routine,u
        lda   Current_Special_Stage                                              
        cmpa  #7                                      *    cmpi.b  #7,(Current_Special_Stage).w
        blo   @a                                      *    blo.s   +
        clr   Current_Special_Stage                   *    move.b  #0,(Current_Special_Stage).w
@a                                                    *+
                                                      *    move.w  #SndID_SpecStageEntry,d0 ; play that funky special stage entry sound
                                                      *    bsr.w   PlaySound
                                                      *    move.b  #MusID_FadeOut,d0 ; fade out the music
                                                      *    bsr.w   PlayMusic
                                                      *    bsr.w   Pal_FadeToWhite
                                                      *    tst.w   (Two_player_mode).w
                                                      *    beq.s   +
                                                      *    move.w  #0,(Two_player_mode).w
                                                      *    st.b    (SS_2p_Flag).w ; set to -1
                                                      *    bra.s   ++
                                                      *; ===========================================================================
                                                      *+
                                                      *    sf.b    (SS_2p_Flag).w ; set to 0
                                                      *; (!)
                                                      *+
                                                      *    move    #$2700,sr       ; Mask all interrupts
                                                      *    lea (VDP_control_port).l,a6
                                                      *    move.w  #$8B03,(a6)     ; EXT-INT disabled, V scroll by screen, H scroll by line
                                                      *    move.w  #$8004,(a6)     ; H-INT disabled
                                                      *    move.w  #$8ADF,(Hint_counter_reserve).w ; H-INT every 224th scanline
                                                      *    move.w  #$8200|(VRAM_SS_Plane_A_Name_Table1/$400),(a6)  ; PNT A base: $C000
                                                      *    move.w  #$8400|(VRAM_SS_Plane_B_Name_Table/$2000),(a6)  ; PNT B base: $A000
                                                      *    move.w  #$8C08,(a6)     ; H res 32 cells, no interlace, S/H enabled
                                                      *    move.w  #$9003,(a6)     ; Scroll table size: 128x32
                                                      *    move.w  #$8700,(a6)     ; Background palette/color: 0/0
                                                      *    move.w  #$8D00|(VRAM_SS_Horiz_Scroll_Table/$400),(a6)       ; H scroll table base: $FC00
                                                      *    move.w  #$8500|(VRAM_SS_Sprite_Attribute_Table/$200),(a6)   ; Sprite attribute table base: $F800
                                                      *    move.w  (VDP_Reg1_val).w,d0
                                                      *    andi.b  #$BF,d0
                                                      *    move.w  d0,(VDP_control_port).l
                                                      *
                                                      *; /------------------------------------------------------------------------\
                                                      *; | We're gonna zero-fill a bunch of VRAM regions. This was done by macro, |
                                                      *; | so there's gonna be a lot of wasted cycles.                            |
                                                      *; \------------------------------------------------------------------------/
                                                      *
                                                      *    dmaFillVRAM 0,VRAM_SS_Plane_A_Name_Table2,VRAM_SS_Plane_Table_Size ; clear Plane A pattern name table 1
                                                      *    dmaFillVRAM 0,VRAM_SS_Plane_A_Name_Table1,VRAM_SS_Plane_Table_Size ; clear Plane A pattern name table 2
                                                      *    dmaFillVRAM 0,VRAM_SS_Plane_B_Name_Table,VRAM_SS_Plane_Table_Size ; clear Plane B pattern name table
                                                      *    dmaFillVRAM 0,VRAM_SS_Horiz_Scroll_Table,VRAM_SS_Horiz_Scroll_Table_Size  ; clear Horizontal scroll table
                                                      *
                                                      *    clr.l   (Vscroll_Factor).w
                                                      *    clr.l   (unk_F61A).w
                                                      *    clr.b   (SpecialStage_Started).w
                                                      *
                                                      *; /------------------------------------------------------------------------\
                                                      *; | Now we clear out some regions in main RAM where we want to store some  |
                                                      *; | of our data structures.                                                |
                                                      *; \------------------------------------------------------------------------/
                                                      *    ; Bug: These '+4's shouldn't be here; clearRAM accidentally clears an additional 4 bytes
                                                      *    clearRAM SS_Sprite_Table,SS_Sprite_Table_End+4
                                                      *    clearRAM SS_Horiz_Scroll_Buf_1,SS_Horiz_Scroll_Buf_1_End+4
                                                      *    clearRAM SS_Misc_Variables,SS_Misc_Variables_End+4
                                                      *    clearRAM SS_Sprite_Table_Input,SS_Sprite_Table_Input_End
                                                      *    clearRAM SS_Object_RAM,SS_Object_RAM_End
                                                      *
                                                      *    ; However, the '+4' after SS_Misc_Variables_End is very useful. It resets the
                                                      *    ; VDP_Command_Buffer queue, avoiding graphical glitches in the Special Stage.
                                                      *    ; In fact, without reset of the VDP_Command_Buffer queue, Tails sprite DPLCs and other
                                                      *    ; level DPLCs that are still in the queue erase the Special Stage graphics the next
                                                      *    ; time ProcessDMAQueue is called.
                                                      *    ; This '+4' doesn't seem to be intentional, because of the other useless '+4' above,
                                                      *    ; and because a '+2' is enough to reset the VDP_Command_Buffer queue and fix this bug.
                                                      *    ; This is a fortunate accident!
                                                      *    ; Note that this is not a clean way to reset the VDP_Command_Buffer queue because the
                                                      *    ; VDP_Command_Buffer_Slot address shall be updated as well. They tried to do that in a
                                                      *    ; clean way after branching to ClearScreen (see below). But they messed up by doing it
                                                      *    ; after several WaitForVint calls.
                                                      *    ; You can uncomment the two lines below to clear the VDP_Command_Buffer queue intentionally.
                                                      *    ;clr.w  (VDP_Command_Buffer).w
                                                      *    ;move.l #VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w
                                                      *
                                                      *    move    #$2300,sr
                                                      *    lea (VDP_control_port).l,a6
                                                      *    move.w  #$8F02,(a6)     ; VRAM pointer increment: $0002
                                                      *    bsr.w   ssInitTableBuffers
                                                      *    bsr.w   ssLdComprsdData
        ; moved to HalfPipe_Init                      *    move.w  #0,(SpecialStage_CurrentSegment).w
                                                      *    moveq   #PLCID_SpecialStage,d0
                                                      *    bsr.w   RunPLC_ROM
                                                      *    clr.b   (Level_started_flag).w
                                                      *    move.l  #0,(Camera_X_pos).w ; probably means something else in this context
                                                      *    move.l  #0,(Camera_Y_pos).w
                                                      *    move.l  #0,(Camera_X_pos_copy).w
                                                      *    move.l  #0,(Camera_Y_pos_copy).w
                                                      *    cmpi.w  #1,(Player_mode).w  ; is this a Tails alone game?
                                                      *    bgt.s   +           ; if yes, branch
        ldu   #MainCharacter
        ;lda   #ObjID_SSSonic
        ;sta   id,u                                    *    move.b  #ObjID_SonicSS,(MainCharacter+id).w ; load Obj09 (special stage Sonic)
                                                      *    tst.w   (Player_mode).w     ; is this a Sonic and Tails game?
                                                      *    bne.s   ++          ; if not, branch
                                                      *+   move.b  #ObjID_TailsSS,(Sidekick+id).w ; load Obj10 (special stage Tails)
        ;ldu   #SpecialStageHUD
        ;lda   #ObjID_SSHUD
        ;sta   id,u                                    *+   move.b  #ObjID_SSHUD,(SpecialStageHUD+id).w ; load Obj5E (special stage HUD)
        ;ldu   #SpecialStageStartBanner
        ;lda   #ObjID_StartBanner
        ;sta   id,u                                    *    move.b  #ObjID_StartBanner,(SpecialStageStartBanner+id).w ; load Obj5F (special stage banner)
        ;ldu   #SpecialStageNumberOfRings
        ;lda   #ObjID_SSNumberOfRings
        ;sta   id,u                                    *    move.b  #ObjID_SSNumberOfRings,(SpecialStageNumberOfRings+id).w ; load Obj87 (special stage ring count)
        lda   #$00
        sta   SS_Offset_X                             *    move.w  #$80,(SS_Offset_X).w
        sta   SS_Offset_Y                             *    move.w  #$36,(SS_Offset_Y).w
                                                      *    bsr.w   SSPlaneB_Background
                                                      *    bsr.w   SSDecompressPlayerArt
        jsr   SSInitPalAndData                        *    bsr.w   SSInitPalAndData
        
        ; Set Key Frame
        ; --------------------------------------------
        
        ldb   #$02                     ; load page 2
        stb   $E7E5                    ; in data space ($A000-$DFFF)
        ldx   #Bgi_specialStage
        jsr   DrawFullscreenImage
        
 IFDEF TRACK_INTERLACED        
        ldx   #$3333
        jsr   ClearInterlacedEvenDataMemory
 ENDC
 
 IFDEF TRACK_HALFLINES        
        ldx   #$3333
        jsr   ClearInterlacedOddDataMemory
 ENDC
                    
        lda   $E7DD                    ; set border color
        anda  #$F0
        adda  #$03                     ; color ref
        sta   $E7DD
        anda  #$0F
        adda  #$80
        sta   glb_screen_border_color+1    ; maj WaitVBL
        jsr   WaitVBL
        ldb   #$03                     ; load page 3
        stb   $E7E5                    ; data space ($A000-$DFFF)
        ldx   #Bgi_specialStage
        jsr   DrawFullscreenImage
        
 IFDEF TRACK_INTERLACED        
        ldx   #$3333
        jsr   ClearInterlacedOddDataMemory
 ENDC
 
 IFDEF TRACK_HALFLINES        
        ldx   #$3333
        jsr   ClearInterlacedOddDataMemory
 ENDC    
                        
        lda   #IdImg_tk_key_004        ; store original image id for access
        sta   SSTrack_mapping_frame    ; of perspective data
        
        ldd   #Pal_HalfPipe
        std   Cur_palette
        clr   Refresh_palette        
        
                                                      *    move.l  #$C0000,(SS_New_Speed_Factor).w
                                                      *    clr.w   (Ctrl_1_Logical).w
                                                      *    clr.w   (Ctrl_2_Logical).w
                                                      *
                                                      *-   move.b  #VintID_S2SS,(Vint_routine).w
        jsr   WaitVBL                                 *    bsr.w   WaitForVint
                                                      *    move.b  (SSTrack_drawing_index).w,d0
                                                      *    bne.s   -
                                                      *
        ; Init Track_Draw
        ; --------------------------------------------
        ldu   #HalfPipeEven
        lda   #ObjID_HalfPipe                                                      
        sta   id,u                              
        jsr   HalfPipe_Init
        ldu   #HalfPipeOdd
        lda   #ObjID_HalfPipe                                                      
        sta   id,u                              
        jsr   HalfPipe_Init                           *    bsr.w   SSTrack_Draw           
                                                      *
                                                      *-   move.b  #VintID_S2SS,(Vint_routine).w
                                                      *    bsr.w   WaitForVint
                                                      *    bsr.w   SSTrack_Draw
                                                      *    bsr.w   SSLoadCurrentPerspective
                                                      *    bsr.w   SSObjectsManager
                                                      *    move.b  (SSTrack_duration_timer).w,d0
                                                      *    subq.w  #1,d0
                                                      *    bne.s   -
                                                      *
                                                      *    jsr (Obj5A_CreateRingsToGoText).l
                                                      *    bsr.w   SS_ScrollBG
                                                      *    jsr (RunObjects).l
                                                      *    jsr (BuildSprites).l
                                                      *    bsr.w   RunPLC_RAM
                                                      *    move.b  #VintID_CtrlDMA,(Vint_routine).w
                                                      *    bsr.w   WaitForVint
        lda   #$01                     ; 1: play 60hz track at 50hz, 0: do not skip frames
        sta   Smps.60HzData 
        jsr   IrqSet50Hz
        
        jsr   YM2413_DrumModeOn
        ldx   #Smps_SpecialStage                      *    move.w  #MusID_SpecStage,d0
        jmp   PlayMusic                               *    bsr.w   PlayMusic
                                                      *    move.w  (VDP_Reg1_val).w,d0
                                                      *    ori.b   #$40,d0
                                                      *    move.w  d0,(VDP_control_port).l
        ; Pal fade in                                 *    bsr.w   Pal_FadeFromWhite
                                                      *
                                                      *-   bsr.w   PauseGame
                                                      *    move.w  (Ctrl_1).w,(Ctrl_1_Logical).w
                                                      *    move.w  (Ctrl_2).w,(Ctrl_2_Logical).w
                                                      *    cmpi.b  #GameModeID_SpecialStage,(Game_Mode).w ; special stage mode?
                                                      *    bne.w   SpecialStage_Unpause        ; if not, branch
                                                      *    move.b  #VintID_S2SS,(Vint_routine).w
                                                      *    bsr.w   WaitForVint
                                                      *    bsr.w   SSTrack_Draw
                                                      *    bsr.w   SSSetGeometryOffsets
                                                      *    bsr.w   SSLoadCurrentPerspective
                                                      *    bsr.w   SSObjectsManager
                                                      *    bsr.w   SS_ScrollBG
                                                      *    jsr (RunObjects).l
                                                      *    jsr (BuildSprites).l
                                                      *    bsr.w   RunPLC_RAM
                                                      *    tst.b   (SpecialStage_Started).w
                                                      *    beq.s   -
                                                      *
                                                      *    moveq   #PLCID_SpecStageBombs,d0
                                                      *    bsr.w   LoadPLC
        rts                                           *
SpecialStage_Main                                     *-   bsr.w   PauseGame
                                                      *    cmpi.b  #GameModeID_SpecialStage,(Game_Mode).w ; special stage mode?
                                                      *    bne.w   SpecialStage_Unpause        ; if not, branch
                                                      *    move.b  #VintID_S2SS,(Vint_routine).w
                                                      *    bsr.w   WaitForVint
                                                      
                                                      
                                                      
 IFDEF TRACK_INTERLACED                                                      
        lda   $E7E5
        cmpa  #$02
        beq   SSM_Odd
 ENDC
                    
        ldu   #HalfPipeEven              
        jsr   HalfPipe_Display
 
 IFDEF TRACK_INTERLACED        
        bra   SSM_Skip
SSM_Odd
 ENDC
 
 IFDEF TRACK_HALFLINES  
 ELSE                     
        ldu   #HalfPipeOdd
        jsr   HalfPipe_Display                        *    bsr.w   SSTrack_Draw
 ENDC   
SSM_Skip              
        jsr   SSSetGeometryOffsets                    *    bsr.w   SSSetGeometryOffsets
        ; moved to SSBomb                             *    bsr.w   SSLoadCurrentPerspective
        jsr   SSObjectsManager                        *    bsr.w   SSObjectsManager
                                                      *    bsr.w   SS_ScrollBG
                                                      *    bsr.w   PalCycle_SS
                                                      *    tst.b   (SS_Pause_Only_flag).w
                                                      *    beq.s   +
                                                      *    move.w  (Ctrl_1).w,d0
                                                      *    andi.w  #(button_start_mask<<8)|button_start_mask,d0
                                                      *    move.w  d0,(Ctrl_1_Logical).w
                                                      *    move.w  (Ctrl_2).w,d0
                                                      *    andi.w  #(button_start_mask<<8)|button_start_mask,d0
                                                      *    move.w  d0,(Ctrl_2_Logical).w
                                                      *    bra.s   ++
                                                      *; ===========================================================================
                                                      *+
                                                      *    move.w  (Ctrl_1).w,(Ctrl_1_Logical).w
                                                      *    move.w  (Ctrl_2).w,(Ctrl_2_Logical).w
                                                      *+
                                                      *    jsr (RunObjects).l
                                                      *    tst.b   (SS_Check_Rings_flag).w
                                                      *    bne.s   +
                                                      *    jsr (BuildSprites).l
                                                      *    bsr.w   RunPLC_RAM
        rts                                           *    bra.s   -
                                                      *; ===========================================================================
                                                      *+
                                                      *    andi.b  #7,(Emerald_count).w
                                                      *    tst.b   (SS_2p_Flag).w
                                                      *    beq.s   +
                                                      *    lea (SS2p_RingBuffer).w,a0
                                                      *    move.w  (a0)+,d0
                                                      *    add.w   (a0)+,d0
                                                      *    add.w   (a0)+,d0
                                                      *    add.w   (a0)+,d0
                                                      *    add.w   (a0)+,d0
                                                      *    add.w   (a0)+,d0
                                                      *    bra.s   ++
                                                      *; ===========================================================================
                                                      *+
                                                      *    move.w  (Ring_count).w,d0
                                                      *    add.w   (Ring_count_2P).w,d0
                                                      *+
                                                      *    cmp.w   (SS_Perfect_rings_left).w,d0
                                                      *    bne.s   +
                                                      *    st.b    (Perfect_rings_flag).w
                                                      *+
                                                      *    bsr.w   Pal_FadeToWhite
                                                      *    tst.w   (Two_player_mode_copy).w
                                                      *    bne.w   loc_540C
                                                      *    move    #$2700,sr
                                                      *    lea (VDP_control_port).l,a6
                                                      *    move.w  #$8200|(VRAM_Menu_Plane_A_Name_Table/$400),(a6)     ; PNT A base: $C000
                                                      *    move.w  #$8400|(VRAM_Menu_Plane_B_Name_Table/$2000),(a6)    ; PNT B base: $E000
                                                      *    move.w  #$9001,(a6)     ; Scroll table size: 64x32
                                                      *    move.w  #$8C81,(a6)     ; H res 40 cells, no interlace, S/H disabled
                                                      *    bsr.w   ClearScreen
                                                      *    jsrto   (Hud_Base).l, JmpTo_Hud_Base
                                                      *    clr.w   (VDP_Command_Buffer).w
                                                      *    move.l  #VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w
                                                      *    move    #$2300,sr
                                                      *    moveq   #PalID_Result,d0
                                                      *    bsr.w   PalLoad_Now
                                                      *    moveq   #PLCID_Std1,d0
                                                      *    bsr.w   LoadPLC2
                                                      *    move.l  #vdpComm(tiles_to_bytes(ArtTile_VRAM_Start+2),VRAM,WRITE),d0
                                                      *    lea SpecialStage_ResultsLetters(pc),a0
                                                      *    jsrto   (LoadTitleCardSS).l, JmpTo_LoadTitleCardSS
                                                      *    move.l  #vdpComm(tiles_to_bytes(ArtTile_ArtNem_SpecialStageResults),VRAM,WRITE),(VDP_control_port).l
                                                      *    lea (ArtNem_SpecialStageResults).l,a0
                                                      *    bsr.w   NemDec
                                                      *    move.w  (Player_mode).w,d0
                                                      *    beq.s   ++
                                                      *    subq.w  #1,d0
                                                      *    beq.s   +
                                                      *    clr.w   (Ring_count).w
                                                      *    bra.s   ++
                                                      *; ===========================================================================
                                                      *+
                                                      *    clr.w   (Ring_count_2P).w
                                                      *+
                                                      *    move.w  (Ring_count).w,(Bonus_Countdown_1).w
                                                      *    move.w  (Ring_count_2P).w,(Bonus_Countdown_2).w
                                                      *    clr.w   (Total_Bonus_Countdown).w
                                                      *    tst.b   (Got_Emerald).w
                                                      *    beq.s   +
                                                      *    move.w  #1000,(Total_Bonus_Countdown).w
                                                      *+
                                                      *    move.b  #1,(Update_HUD_score).w
                                                      *    move.b  #1,(Update_Bonus_score).w
                                                      *    move.w  #MusID_EndLevel,d0
                                                      *    jsr (PlaySound).l
                                                      *
                                                      *    clearRAM SS_Sprite_Table_Input,SS_Sprite_Table_Input_End
                                                      *    clearRAM SS_Object_RAM,SS_Object_RAM_End
                                                      *
                                                      *    move.b  #ObjID_SSResults,(SpecialStageResults+id).w ; load Obj6F (special stage results) at $FFFFB800
                                                      *-
                                                      *    move.b  #VintID_Level,(Vint_routine).w
                                                      *    bsr.w   WaitForVint
                                                      *    jsr (RunObjects).l
                                                      *    jsr (BuildSprites).l
                                                      *    bsr.w   RunPLC_RAM
                                                      *    tst.w   (Level_Inactive_flag).w
                                                      *    beq.s   -
                                                      *    tst.l   (Plc_Buffer).w
                                                      *    bne.s   -
                                                      *    move.w  #SndID_SpecStageEntry,d0
                                                      *    bsr.w   PlaySound
                                                      *    bsr.w   Pal_FadeToWhite
                                                      *    tst.w   (Two_player_mode_copy).w
                                                      *    bne.s   loc_540C
                                                      *    move.b  #GameModeID_Level,(Game_Mode).w ; => Level (Zone play mode)
                                                      *    rts
                                                      *; ===========================================================================
                                                      *
                                                      *loc_540C:
                                                      *    move.w  #VsRSID_SS,(Results_Screen_2P).w
                                                      *    move.b  #GameModeID_2PResults,(Game_Mode).w ; => TwoPlayerResults
                                                      *    rts
                                                      *; ===========================================================================
                                                      *
                                                      *; loc_541A:
                                                      *SpecialStage_Unpause:
                                                      *    move.b  #MusID_Unpause,(Music_to_play).w
                                                      *    move.b  #VintID_Level,(Vint_routine).w
                                                      *    bra.w   WaitForVint

                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *
                                                      *;sub_5534
SSObjectsManager                                      *SSObjectsManager:

        ; Frame should be fully rendered

        lda   SSTrack_drawing_index                   *    cmpi.b  #4,(SSTrack_drawing_index).w
        bne   SSObjectsManager_return                 *    bne.w   return_55DC

        ; Run only each time a new segment is loaded
        ; testing LSB only is ok 
                                                      *    moveq   #0,d0
        ldb   SpecialStage_CurrentSegment+1           *    move.b  (SpecialStage_CurrentSegment).w,d0
        cmpb  SpecialStage_LastSegment2+1             *    cmp.b   (SpecialStage_LastSegment2).w,d0
        beq   SSObjectsManager_return                 *    beq.w   return_55DC
        stb   SpecialStage_LastSegment2+1             *    move.b  d0,(SpecialStage_LastSegment2).w
        
        ; Get current segment length
                                                      *    movea.l (SS_CurrentLevelLayout).w,a1
        lda   HalfPipe_Seq                            *    move.b  (a1,d0.w),d3
        anda  #$7F              ; ignore orientation  *    andi.w  #$7F,d3
        asla
        ldx   #Ani_SSTrack_Len                        *    lea (Ani_SSTrack_Len).l,a0
        ldd   a,x                                     *    move.b  (a0,d3.w),d3
                                                      *    add.w   d3,d3
                                                      *    add.w   d3,d3
        std   SS_Seg_Len_x4

        ; Read object locations
        
        ldx   SS_CurrentLevelObjectLocations          *    movea.l (SS_CurrentLevelObjectLocations).w,a0
SSObjectsManager_LoadObject                           *-
        jsr   SSSingleObjLoad                         *    bsr.w   SSSingleObjLoad
        bne   SSObjectsManager_return                 *    bne.s   return_55DC
                                                      *    moveq   #0,d0
        ldb   ,x+                                     *    move.b  (a0)+,d0
        bmi   SSObjectsManager_LoadSegmentType        *    bmi.s   ++
        tfr   b,a                                     *    move.b  d0,d1
        anda  #$40                                    *    andi.b  #$40,d1
        bne   SSObjectsManager_Bomb                   *    bne.s   +
                                                      *    addq.w  #1,(SS_Perfect_rings_left).w
        lda   #$01
@a      sta   subtype,u                                
        lda   #ObjID_SSBomb
        sta   id,u                                    *    move.b  #ObjID_SSRing,id(a1)
        lda   #$00        
        aslb                                          *    add.w   d0,d0
        rola
        aslb                                          *    add.w   d0,d0
        rola
        addd  SS_Seg_Len_x4                           *    add.w   d3,d0
        std   ss_z_pos,u                              *    move.w  d0,objoff_30(a1)
        std   ss_z_pos_img_start,u
        lda   ,x+
        sta   angle,u                                 *    move.b  (a0)+,angle(a1)
        bra   SSObjectsManager_LoadObject             *    bra.s   -
                                                      *; ===========================================================================
SSObjectsManager_Bomb                                 *+
        andb  #$3F                                    *    andi.w  #$3F,d0
        lda   #$00
        bra   @a                                                     
                                                      *    move.b  #ObjID_SSBomb,id(a1)
                                                      *    add.w   d0,d0
                                                      *    add.w   d0,d0
                                                      *    add.w   d3,d0
                                                      *    move.w  d0,objoff_30(a1)
                                                      *    move.b  (a0)+,angle(a1)
                                                      *    bra.s   -
                                                      *; ===========================================================================
SSObjectsManager_LoadSegmentType                      *+
        stx   SS_CurrentLevelObjectLocations          *    move.l  a0,(SS_CurrentLevelObjectLocations).w
        incb                                          *    addq.b  #1,d0
        beq   SSObjectsManager_return ;$FF            *    beq.s   return_55DC
        incb                                          *    addq.b  #1,d0
        beq   SSObjectsManager_LoadCheckpoint ;$FE    *    beq.s   ++
        incb                                          *    addq.b  #1,d0
        beq   SSObjectsManager_Emerald                *    beq.s   +
        ldd   #$FF00
        sta   SS_NoCheckpoint_flag                    *    st.b    (SS_NoCheckpoint_flag).w
        stb   SS_NoCheckpointMsg_flag                 *    sf.b    (SS_NoCheckpointMsg_flag).w
        bra   SSObjectsManager_LoadCheckpoint         *    bra.s   ++
                                                      *; ===========================================================================
SSObjectsManager_Emerald                              *+
                                                      *    tst.b   (SS_2p_Flag).w
                                                      *    bne.s   +
        ;lda   #ObjID_SSEmerald                        *    move.b  #ObjID_SSEmerald,id(a1)
        ;sta   id,u
        bra   *
        rts                                           *    rts
                                                      *; ===========================================================================
SSObjectsManager_LoadCheckpoint                       *+
        ;lda   #ObjID_SSMessage                        *    move.b  #ObjID_SSMessage,id(a1)
        ;sta   id,u                                                      
                                                      *
SSObjectsManager_return                               *return_55DC:
        rts                                           *    rts
                                                      *; End of function SSObjectsManager
                                                      
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *;sub_7650
SSSetGeometryOffsets                                  *SSSetGeometryOffsets:
        lda   SSTrack_drawing_index                   *    move.b  (SSTrack_drawing_index).w,d0                    ; Get drawing position
        ;cmpa  SS_player_anim_frame_timer              *    cmp.b   (SS_player_anim_frame_timer).w,d0               ; Compare to player frame duration
        beq   @a                                      *    beq.s   +                                               ; If both are equal, branch
        rts                                           *    rts
                                                      *; ===========================================================================
                                                      *+
                                                      *    moveq   #0,d0
@a      lda   SSTrack_mapping_frame                   *    move.b  (SSTrack_mapping_frame).w,d0                    ; Get current track mapping frame
        asla                                          *    add.w   d0,d0                                           ; Convert to index
        ldx   #SSCurveOffsets
        leax  a,x                                     *    lea SSCurveOffsets(pc,d0.w),a2                          ; Load current curve offsets into a2
        lda   ,x+                                     *    move.b  (a2)+,d0                                        ; Get x offset
        tst   SSTrack_Orientation                     *    tst.b   (SSTrack_Orientation).w                         ; Is track flipped?
        beq   @b                                      *    beq.s   +                                               ; Branch if not
        nega                                          *    neg.b   d0                                              ; Change sign of offset
@b                                                    *+
                                                      *    ext.w   d0                                              ; Extend to word
                                                      *    addi.w  #$80,d0                                         ; Add 128 (why?)
        sta   SS_Offset_X                             *    move.w  d0,(SS_Offset_X).w                              ; Set X geometry offset
        lda   ,x                                      *    move.b  (a2),d0                                         ; Get y offset
                                                      *    ext.w   d0                                              ; Extend to word
                                                      *    addi.w  #$36,d0                                         ; Add $36 (why?)
        sta   SS_Offset_Y                             *    move.w  d0,(SS_Offset_Y).w                              ; Set Y geometry offset
        rts                                           *    rts
                                                      *; End of function SSSetGeometryOffsets
                                                      *
                                                      *; ===========================================================================
                                                      *; Position offsets to sort-of rotate the plane sonic/tails are in
                                                      *; when the special stage track is curving, so they follow it better.
                                                      *; Each word seems to be (x_offset, y_offset)
                                                      *; See also Ani_SpecialStageTrack.
SSCurveOffsets                                        *SSCurveOffsets: ; word_768A:
        fcb   $13,0,$13,0,$13,0,$13,0                 *    dc.b $13,   0,   $13,   0,   $13,   0,   $13,   0   ; $00
        fcb   9,-$A,0,-$1C,0,-$1C,0,-$20              *    dc.b   9, -$A,     0,-$1C,     0,-$1C,     0,-$20   ; $04
        fcb   0,-$24,0,-$2A,0,-$10,0,6                *    dc.b   0,-$24,     0,-$2A,     0,-$10,     0,   6   ; $08
        fcb   0,$E,0,$10,0,$12,0,$12                  *    dc.b   0,  $E,     0, $10,     0, $12,     0, $12   ; $0C
        fcb   9,$12                                   *    dc.b   9, $12                                       ; $10; upward curve
        fcb   0,0,0,0,0,0,0,0                         *    dc.b   0,   0,     0,   0,     0,   0,     0,   0   ; $11; straight
        fcb   $13,0,$13,0,$13,0,$13,0                 *    dc.b $13,   0,   $13,   0,   $13,   0,   $13,   0   ; $15
        fcb   $B,$C,0,$C,0,$12,0,$A                   *    dc.b  $B,  $C,     0,  $C,     0, $12,     0,  $A   ; $19
        fcb   0,8,0,2,0,$10,0,-$20                    *    dc.b   0,   8,     0,   2,     0, $10,     0,-$20   ; $1D
        fcb   0,-$1F,0,-$1E,0,-$1B,0,-$18             *    dc.b   0,-$1F,     0,-$1E,     0,-$1B,     0,-$18   ; $21
        fcb   0,-$E                                   *    dc.b   0, -$E                                       ; $25; downward curve
        fcb   $13,0,$13,0,$13,0,$13,0                 *    dc.b $13,   0,   $13,   0,   $13,   0,   $13,   0   ; $26
        fcb   $13,0,$13,0                             *    dc.b $13,   0,   $13,   0                           ; $2B; turning
        fcb   $13,0,$13,0,$13,0,$13,0                 *    dc.b $13,   0,   $13,   0,   $13,   0,   $13,   0   ; $2C
        fcb   $B,0                                    *    dc.b  $B,   0                                       ; $30; exit turn
        fcb   0,0,0,0,0,0,0,0                         *    dc.b   0,   0,     0,   0,     0,   0,     0,   0   ; $31
        fcb   0,0,0,0,3,0                             *    dc.b   0,   0,     0,   0,     3,   0               ; $35; straight    		                                                  
                                                      
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
         
; search for a free object slot
; OUT
; [u]: object slot
; [cc|z]: 1=found 0=not found                                                       
                                                      *; sub_6F8E:
SSSingleObjLoad                                       *SSSingleObjLoad:
        ldu   #Dynamic_Object_RAM                     *    lea (SS_Dynamic_Object_RAM).w,a1
                                                      *    move.w  #(SS_Dynamic_Object_RAM_End-SS_Dynamic_Object_RAM)/object_size-1,d5
                                                      *
@b      tst   id,u                                    *-   tst.b   id(a1)
        beq   @a                                      *    beq.s   +   ; rts
        leau  next_object,u                           *    lea next_object(a1),a1 ; a1=object
        cmpu  #Dynamic_Object_RAM_End                 *    dbf d5,-
        bne   @b                                      *+
        lda   #$FF
@a      rts                                           *    rts
                                                      *; End of function sub_6F8E                                                                                                            

                                                      *;sub_77A2
SSInitPalAndData                                      *SSInitPalAndData:
                                                      *    clr.b   (Current_Special_Act).w
        ; moved to HalfPipe_Init                      *    move.b  #-1,(SpecialStage_LastSegment2).w
        ldd   #0
        std   Ring_count                              *    move.w  #0,(Ring_count).w
                                                      *    move.w  #0,(Ring_count_2P).w
                                                      *    move.b  #0,(Perfect_rings_flag).w
                                                      *    move.b  #0,(Got_Emerald).w
                                                      *    move.b  #4,(SS_Star_color_2).w
                                                      *    lea (SS2p_RingBuffer).w,a2
                                                      *    moveq   #0,d0
                                                      *    move.w  d0,(a2)+
                                                      *    move.w  d0,(a2)+
                                                      *    move.w  d0,(a2)+
                                                      *    move.w  d0,(a2)+
                                                      *    move.w  d0,(a2)+
                                                      *    move.w  d0,(a2)+
                                                      *    moveq   #PalID_SS,d0
                                                      *    bsr.w   PalLoad_ForFade
                                                      *    lea_    SpecialStage_Palettes,a1
                                                      *    moveq   #0,d0
        ldb   Current_Special_Stage                   *    move.b  (Current_Special_Stage).w,d0
        aslb                                          *    add.w   d0,d0
                                                      *    move.w  d0,d1
                                                      *    tst.b   (SS_2p_Flag).w
                                                      *    beq.s   +
                                                      *    cmpi.b  #4,d0
                                                      *    blo.s   +
                                                      *    addi_.w #6,d0
                                                      *+
                                                      *    move.w  (a1,d0.w),d0
                                                      *    bsr.w   PalLoad_ForFade
        ldx   #SpecialObjectLocations                 *    lea (SSRAM_MiscKoz_SpecialObjectLocations).w,a0
        abx                                           *    adda.w  (a0,d1.w),a0
        ldd   ,x
        leax  d,x
        stx   SS_CurrentLevelObjectLocations          *    move.l  a0,(SS_CurrentLevelObjectLocations).w
        
        ldb   Current_Special_Stage
        aslb        
        ldx   #SpecialLevelLayout                     *    lea (SSRAM_MiscNem_SpecialLevelLayout).w,a0
        abx                                           *    adda.w  (a0,d1.w),a0
        ldd   ,x
        leax  d,x        
        stx   SS_CurrentLevelLayout                   *    move.l  a0,(SS_CurrentLevelLayout).w
        rts                                           *    rts
                                                      *; End of function SSInitPalAndData     

Ani_SSTrack_Len
;        fdb (24*4)+HalfPipe_Img_z_depth ; 0
;        fdb (24*4)+HalfPipe_Img_z_depth ; 1
;        fdb (12*4)+HalfPipe_Img_z_depth ; 2
;        fdb (16*4)+HalfPipe_Img_z_depth ; 3
;        fdb (11*4)+HalfPipe_Img_z_depth ; 4
;        fdb 0    ; 5
         fdb (24*4) ; 0
         fdb (24*4) ; 1
         fdb (12*4) ; 2
         fdb (16*4) ; 3
         fdb (11*4) ; 4
         fdb 0    ; 5

SpecialLevelLayout
        INCLUDEBIN "./game-mode/special-stage/Special stage level layouts.bin"
        
        ; -------------------------------------------------------------------------------------------------------------        
        ; Level Layout
        ; -------------------------------------------------------------------------------------------------------------
        ;
        ; Index (words)
        ; -----
        ; Offset to each level data (7 word offsets for the 7 levels)
        ;
        ; Orientation/Track (bytes)
        ; -----------------
        ; $0x Towards right
        ; $8x Towards left
        ; $x0 Turn the rise
        ; $x1 Turn then drop
        ; $x2 Turn then straight
        ; $x3 straight
        ; $x4 Straight then turn       
        ; -------------------------------------------------------------------------------------------------------------
        
SpecialObjectLocations
        INCLUDEBIN "./game-mode/special-stage/Special stage object location lists.bin"
        
        ; -------------------------------------------------------------------------------------------------------------             
        ; Object Locations
        ; -------------------------------------------------------------------------------------------------------------
        ;        
        ; Index (words)
        ; -----
        ; Offset to each level data (7 word offsets for the 7 levels)
        ;
        ; Segment Objects (group of bytes)
        ; ---------------                               
        ; byte : bit6 (0:ring,1:bomb) bit5-0 ($00-$17 : 0-23 position in frame $00:near, $17 far, 24 frames is maximum for a segment in original game)
        ; byte : (angle : $00 right, $40 center, $80 left, $c0 top)
        ; byte : $ff (end of regular segment), $fe (end of checkpoint segment), $fd (end of choas emerald segment), $fc (end of rings message segment)
        ;
        ; -------------------------------------------------------------------------------------------------------------        

SpecialPerspective
        INCLUDEBIN "./game-mode/special-stage/Special stage object perspective data.bin" 

        ; -------------------------------------------------------------------------------------------------------------
        ; Perspective data
        ; -------------------------------------------------------------------------------------------------------------
        ;        
        ; Index (words)
        ; -----
        ; Offset to each halfpipe image perspective data (56 word offsets for the 56 images)
        ;
        ; Image perspective data
        ; ----------------------      
        ;  1 word : n number of z_pos defined for this frame from 1 (camera front) to n (far away)
        ;  n groups of 6 bytes : 7b dd b8 e6 00 00   that defines an elipse arc
        ;                        |  |  |  |  |  |___ angle min (excl.) of visible area (0: no invisible area)
        ;                        |  |  |  |  |______ angle max (incl.) of visible area
        ;                        |  |  |  |_________ y radius
        ;                        |  |  |____________ x radius
        ;                        |  |_______________ y origin
        ;                        |__________________ x origin
        ;
        ; -------------------------------------------------------------------------------------------------------------  
        
; ---------------------------------------------------------------------------
; Object - Half Pipe for Special Stage
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Half pipe is rendered interlaced
; ---------------------------------------------------------------------------

HalfPipe_Init
        ldb   #$05
        stb   priority,u
        
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u        
        
        ldd   #$807F
        cmpu  #HalfPipeEven
        beq   @a        
        incb                           ; +1 for odd line
        std   xy_pixel,u
        rts
@a      std   xy_pixel,u

        ldd   Vint_runcount
        std   HalfPipe_Vint_Track_Image          ; store number of vint between two rendered images
        std   HalfPipe_Vint_Main_Loop            ; store number of vint between two main loops execution
        
        ; load start of sequences for this level
        ; ----------------------------------------------
        
        ldx   SS_CurrentLevelLayout
        stx   SpecialStage_CurrentSegment

        ; load first animation id
        ; -----------------------
        
        ldb   ,x                
        stb   HalfPipe_Seq
        andb  #$7F
        leax  -1,x
        stx   SpecialStage_LastSegment2          ; init last segment to another value to run ObjectManager
        
        ldx   #Ani_SpecialStageTrack
        aslb        
        abx
        ldd   ,x
        std   anim,u
        jmp   AnimateSprite
        
HalfPipe_Display
        cmpu  #HalfPipeEven
        beq   @a
        ldx   #HalfPipeEven
        ldd   image_set,x                        ; clone image_set when secondary HalfPipe sprite is running
        std   image_set,u
        lda   render_flags,x
        sta   render_flags,u     
        jmp   DisplaySprite                      ; return
@a
        
        ldd   Vint_runcount
        subd  HalfPipe_Vint_Main_Loop
        stb   HalfPipe_Nb_Elapsed_Frames         ; ajust object z speed

        ldd   Vint_runcount
        std   HalfPipe_Vint_Main_Loop
        subd  HalfPipe_Vint_Track_Image
        stb   SSTrack_drawing_index
        
        ; if n-2 image is different from n-1 image
        ; we must call HalfPipe_KeepSameTrackImage
        ; otherwise it would drop an intermediate image
        ldd   rsv_prev_mapping_frame_0,u
        cmpd  rsv_prev_mapping_frame_1,u
        bne   HalfPipe_KeepSameTrackImage
        
        ldb   SSTrack_drawing_index
        cmpb  #HalfPipe_Img_Duration             ; ensure track is not refreshed more than max fps 
        bge   HalfPipe_LoadNewTrackImage
        
HalfPipe_KeepSameTrackImage
 IFGE (HalfPipe_one_z_step-255)
        ldb   HalfPipe_Nb_Elapsed_Frames         ; 8x16 bit mul (fix this code, remove stack usage) 
        ldy   #HalfPipe_one_z_step               ; TODO NEVER TESTED 
        pshs  y,d,cc                             ; USAGE WHEN track refresh rate >= 12fps (HalfPipe_Img_Duration <= 4)
	lda   4,s                                ; CAP to HalfPipe_Img_z_depth
        mul
        std   3,s
        tfr   y,d
        ldb   2,s
        clr   2,s
        mul
        addd  2,s
        std   2,s
	puls  pc,y,d,cc
	sty   HalfPipe_z_step
	jmp   DisplaySprite
 ELSE		
        lda   HalfPipe_Nb_Elapsed_Frames         ; 8x8 bit mul is the way to go
        ldb   #HalfPipe_one_z_step               ; look for one main loop duration and adjust
        mul                                      ; object position to keep a constant speed
        cmpd  #((HalfPipe_Img_z_depth*256)/2)
        bls   @a
        ldd   #((HalfPipe_Img_z_depth*256)/2)    ; one sub step can not be more than an img z depth
@a      std   HalfPipe_z_step
        jmp   DisplaySprite                      ; return
 ENDC
        
HalfPipe_LoadNewTrackImage
        ldd   Vint_runcount
        std   HalfPipe_Vint_Track_Image
        clr   SSTrack_drawing_index
        jsr   AnimateSprite
        jsr   GetImgIdA
        sta   SSTrack_mapping_frame
        
        ; chain animations (AnimateSprite will inc routine_secondary after each animation ends)
        ; -------------------------------------------------------------------------------------
        
        lda   routine_secondary,u
        asla
        ldx   #HalfPipe_SubRoutines
        jmp   [a,x]

HalfPipe_SubRoutines
        fdb   HalfPipe_Continue
        fdb   HalfPipe_LoadNewSequence
        
HalfPipe_LoadNewSequence
        ldx   SpecialStage_CurrentSegment
        leax  1,x
        stx   SpecialStage_CurrentSegment

        lda   HalfPipe_Seq
        anda  #$7F
        ldb   ,x        
        stb   HalfPipe_Seq
        andb  #$7F
        cmpd  #$0203                        ; special case    
        bne   @a
        ldd   #Ani_Straight_From_TurnThenStraight
        std   anim,u
        bra   @d
@a      cmpd  #$0002                        ; special case    
        bne   @b
        ldd   #Ani_TurnThenStraight_From_Rise
        std   anim,u
        bra   @d
@b      cmpd  #$0102                        ; special case    
        bne   @c
        ldd   #Ani_TurnThenStraight_From_Drop
        std   anim,u
        bra   @d
@c      ldx   #Ani_SpecialStageTrack        ; use lookup table
        aslb
        abx
        ldd   ,x
        std   anim,u
@d      ldd   #0
        sta   routine_secondary,u
        std   prev_anim,u                   ; force loading of new animation
        jsr   AnimateSprite
        jsr   GetImgIdA
        sta   SSTrack_mapping_frame

HalfPipe_Continue

        ; set orirentation of track
        ; -------------------------
        
        lda   HalfPipe_Seq_UpdFlip
        beq   @a
        ldb   HalfPipe_Seq_UpdFlip+1
        bpl   @b   
        lda   render_flags,u
        ora   #render_xmirror_mask          ; set flip - left orientation
        sta   render_flags,u
        lda   #$FF
        sta   SSTrack_Orientation
        bra   @c
@b      lda   render_flags,u
        anda   #^render_xmirror_mask        ; unset flip - right orientation
        sta   render_flags,u
        lda   #0
        sta   SSTrack_Orientation
@c      com   HalfPipe_Seq_UpdFlip
@a      ldd   image_set,u                   ; orientation can only change on specific frames
        cmpd  #Img_tk_036
        beq   @d
        cmpd  #Img_tk_044
        beq   @d       
        cmpd  #Img_tk_002
        beq   @d
        jmp   DisplaySprite
@d      com   HalfPipe_Seq_UpdFlip
        ldb   HalfPipe_Seq
        stb   HalfPipe_Seq_UpdFlip+1
        jmp   DisplaySprite
        
Ani_SpecialStageTrack
        fdb   Ani_TurnThenRise
        fdb   Ani_TurnThenDrop
        fdb   Ani_TurnThenStraight
        fdb   Ani_Straight
        fdb   Ani_StraightThenTurn        
                                                      