                                                      *; ---------------------------------------------------------------------------
                                                      *; Level
                                                      *; DEMO AND ZONE LOOP (MLS values $08, $0C; bit 7 set indicates that load routine is running)
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_3EC4:
                                                      *Level:
                                                      *        bset    #GameModeFlag_TitleCard,(Game_Mode).w ; add $80 to screen mode (for pre level sequence)
                                                      *        tst.w   (Demo_mode_flag).w      ; test the old flag for the credits demos (now unused)
                                                      *        bmi.s   +
                                                      *        move.b  #MusID_FadeOut,d0
                                                      *        bsr.w   PlaySound       ; fade out music
                                                      *+
                                                      *        bsr.w   ClearPLC
                                                      *        bsr.w   Pal_FadeToBlack
                                                      *        tst.w   (Demo_mode_flag).w
                                                      *        bmi.s   Level_ClrRam
                                                      *        move    #$2700,sr
                                                      *        bsr.w   ClearScreen
                                                      *        jsr     (LoadTitleCard).l ; load title card patterns
                                                      *        move    #$2300,sr
                                                      *        moveq   #0,d0
                                                      *        move.w  d0,(Timer_frames).w
                                                      *        move.b  (Current_Zone).w,d0
                                                      *
                                                      *        ; multiply d0 by 12, the size of a level art load block
                                                      *        add.w   d0,d0
                                                      *        add.w   d0,d0
                                                      *        move.w  d0,d1
                                                      *        add.w   d0,d0
                                                      *        add.w   d1,d0
                                                      *
                                                      *        lea     (LevelArtPointers).l,a2
                                                      *        lea     (a2,d0.w),a2
                                                      *        moveq   #0,d0
                                                      *        move.b  (a2),d0 ; PLC1 ID
                                                      *        beq.s   +
                                                      *        bsr.w   LoadPLC
                                                      *+
                                                      *        moveq   #PLCID_Std2,d0
                                                      *        bsr.w   LoadPLC
                                                      *        bsr.w   Level_SetPlayerMode
                                                      *        moveq   #PLCID_Miles1up,d0
                                                      *        tst.w   (Two_player_mode).w
                                                      *        bne.s   +
                                                      *        cmpi.w  #2,(Player_mode).w
                                                      *        bne.s   Level_ClrRam
                                                      *        addq.w  #PLCID_MilesLife-PLCID_Miles1up,d0
                                                      *+
                                                      *        tst.b   (Graphics_Flags).w
                                                      *        bpl.s   +
                                                      *        addq.w  #PLCID_Tails1up-PLCID_Miles1up,d0
                                                      *+
                                                      *        bsr.w   LoadPLC
                                                      *; loc_3F48:
                                                      *Level_ClrRam:
                                                      *        clearRAM Sprite_Table_Input,Sprite_Table_Input_End
                                                      *        clearRAM Object_RAM,Object_RAM_End ; clear object RAM
                                                      *        clearRAM MiscLevelVariables,MiscLevelVariables_End
                                                      *        clearRAM Misc_Variables,Misc_Variables_End
                                                      *        clearRAM Oscillating_Data,Oscillating_variables_End
                                                      *        ; Bug: The '+C0' shouldn't be here; CNZ_saucer_data is only $40 bytes large
                                                      *        clearRAM CNZ_saucer_data,CNZ_saucer_data_End+$C0
                                                      *
                                                      *        cmpi.w  #chemical_plant_zone_act_2,(Current_ZoneAndAct).w ; CPZ 2
                                                      *        beq.s   Level_InitWater
                                                      *        cmpi.b  #aquatic_ruin_zone,(Current_Zone).w ; ARZ
                                                      *        beq.s   Level_InitWater
                                                      *        cmpi.b  #hidden_palace_zone,(Current_Zone).w ; HPZ
                                                      *        bne.s   +
                                                      *
                                                      *Level_InitWater:
                                                      *        move.b  #1,(Water_flag).w
                                                      *        move.w  #0,(Two_player_mode).w
                                                      *+
                                                      *        lea     (VDP_control_port).l,a6
                                                      *        move.w  #$8B03,(a6)             ; EXT-INT disabled, V scroll by screen, H scroll by line
                                                      *        move.w  #$8200|(VRAM_Plane_A_Name_Table/$400),(a6)      ; PNT A base: $C000
                                                      *        move.w  #$8400|(VRAM_Plane_B_Name_Table/$2000),(a6)     ; PNT B base: $E000
                                                      *        move.w  #$8500|(VRAM_Sprite_Attribute_Table/$200),(a6)  ; Sprite attribute table base: $F800
                                                      *        move.w  #$9001,(a6)             ; Scroll table size: 64x32
                                                      *        move.w  #$8004,(a6)             ; H-INT disabled
                                                      *        move.w  #$8720,(a6)             ; Background palette/color: 2/0
                                                      *        move.w  #$8C81,(a6)             ; H res 40 cells, no interlace
                                                      *        tst.b   (Debug_options_flag).w
                                                      *        beq.s   ++
                                                      *        btst    #button_C,(Ctrl_1_Held).w
                                                      *        beq.s   +
                                                      *        move.w  #$8C89,(a6)     ; H res 40 cells, no interlace, S/H enabled
                                                      *+
                                                      *        btst    #button_A,(Ctrl_1_Held).w
                                                      *        beq.s   +
                                                      *        move.b  #1,(Debug_mode_flag).w
                                                      *+
                                                      *        move.w  #$8ADF,(Hint_counter_reserve).w ; H-INT every 223rd scanline
                                                      *        tst.w   (Two_player_mode).w
                                                      *        beq.s   +
                                                      *        move.w  #$8A6B,(Hint_counter_reserve).w ; H-INT every 108th scanline
                                                      *        move.w  #$8014,(a6)                     ; H-INT enabled
                                                      *        move.w  #$8C87,(a6)                     ; H res 40 cells, double res interlace
                                                      *+
                                                      *        move.w  (Hint_counter_reserve).w,(a6)
                                                      *        clr.w   (VDP_Command_Buffer).w
                                                      *        move.l  #VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w
                                                      *        tst.b   (Water_flag).w  ; does level have water?
                                                      *        beq.s   Level_LoadPal   ; if not, branch
                                                      *        move.w  #$8014,(a6)     ; H-INT enabled
                                                      *        moveq   #0,d0
                                                      *        move.w  (Current_ZoneAndAct).w,d0
                                                      *    if ~~useFullWaterTables
                                                      *        subi.w  #hidden_palace_zone_act_1,d0
                                                      *    endif
                                                      *        ror.b   #1,d0
                                                      *        lsr.w   #6,d0
                                                      *        andi.w  #$FFFE,d0
                                                      *        lea     (WaterHeight).l,a1      ; load water height array
                                                      *        move.w  (a1,d0.w),d0
                                                      *        move.w  d0,(Water_Level_1).w ; set water heights
                                                      *        move.w  d0,(Water_Level_2).w
                                                      *        move.w  d0,(Water_Level_3).w
                                                      *        clr.b   (Water_routine).w       ; clear water routine counter
                                                      *        clr.b   (Water_fullscreen_flag).w       ; clear water movement
                                                      *        move.b  #1,(Water_on).w ; enable water
                                                      *; loc_407C:
                                                      *Level_LoadPal:
                                                      *        moveq   #PalID_BGND,d0
                                                      *        bsr.w   PalLoad_Now     ; load Sonic's palette line
                                                      *        tst.b   (Water_flag).w  ; does level have water?
                                                      *        beq.s   Level_GetBgm    ; if not, branch
                                                      *        moveq   #PalID_HPZ_U,d0 ; palette number $15
                                                      *        cmpi.b  #hidden_palace_zone,(Current_Zone).w
                                                      *        beq.s   Level_WaterPal ; branch if level is HPZ
                                                      *        moveq   #PalID_CPZ_U,d0 ; palette number $16
                                                      *        cmpi.b  #chemical_plant_zone,(Current_Zone).w
                                                      *        beq.s   Level_WaterPal ; branch if level is CPZ
                                                      *        moveq   #PalID_ARZ_U,d0 ; palette number $17
                                                      *; loc_409E:
                                                      *Level_WaterPal:
                                                      *        bsr.w   PalLoad_Water_Now       ; load underwater palette (with d0)
                                                      *        tst.b   (Last_star_pole_hit).w ; is it the start of the level?
                                                      *        beq.s   Level_GetBgm    ; if yes, branch
                                                      *        move.b  (Saved_Water_move).w,(Water_fullscreen_flag).w
                                                      *; loc_40AE:
                                                      *Level_GetBgm:
                                                      *        tst.w   (Demo_mode_flag).w
                                                      *        bmi.s   +
                                                      *        moveq   #0,d0
                                                      *        move.b  (Current_Zone).w,d0
                                                      *        lea_    MusicList,a1
                                                      *        tst.w   (Two_player_mode).w
                                                      *        beq.s   Level_PlayBgm
                                                      *        lea_    MusicList2,a1
                                                      *; loc_40C8:
                                                      *Level_PlayBgm:
                                                      *        move.b  (a1,d0.w),d0            ; load from music playlist
                                                      *        move.w  d0,(Level_Music).w      ; store level music
                                                      *        bsr.w   PlayMusic               ; play level music
                                                      *        move.b  #ObjID_TitleCard,(TitleCard+id).w ; load Obj34 (level title card) at $FFFFB080
                                                      *; loc_40DA:
                                                      *Level_TtlCard:
                                                      *        move.b  #VintID_TitleCard,(Vint_routine).w
                                                      *        bsr.w   WaitForVint
                                                      *        jsr     (RunObjects).l
                                                      *        jsr     (BuildSprites).l
                                                      *        bsr.w   RunPLC_RAM
                                                      *        move.w  (TitleCard_ZoneName+x_pos).w,d0
                                                      *        cmp.w   (TitleCard_ZoneName+titlecard_x_target).w,d0 ; has title card sequence finished?
                                                      *        bne.s   Level_TtlCard           ; if not, branch
                                                      *        tst.l   (Plc_Buffer).w          ; are there any items in the pattern load cue?
                                                      *        bne.s   Level_TtlCard           ; if yes, branch
                                                      *        move.b  #VintID_TitleCard,(Vint_routine).w
                                                      *        bsr.w   WaitForVint
                                                      *        jsr     (Hud_Base).l
                                                      *+
                                                      *        moveq   #PalID_BGND,d0
                                                      *        bsr.w   PalLoad_ForFade ; load Sonic's palette line
                                                      *        bsr.w   LevelSizeLoad
                                                      *        jsrto   (DeformBgLayer).l, JmpTo_DeformBgLayer
                                                      *        clr.w   (Vscroll_Factor_FG).w
                                                      *        move.w  #-$E0,(Vscroll_Factor_P2_FG).w
                                                      *
                                                      *        clearRAM Horiz_Scroll_Buf,Horiz_Scroll_Buf_End
                                                      *
                                                      *        bsr.w   LoadZoneTiles
                                                      *        jsrto   (loadZoneBlockMaps).l, JmpTo_loadZoneBlockMaps
                                                      *        jsr     (LoadAnimatedBlocks).l
                                                      *        jsrto   (DrawInitialBG).l, JmpTo_DrawInitialBG
                                                      *        jsr     (ConvertCollisionArray).l
                                                      *        bsr.w   LoadCollisionIndexes
                                                      *        bsr.w   WaterEffects
                                                      *        bsr.w   InitPlayers
                                                      *        move.w  #0,(Ctrl_1_Logical).w
                                                      *        move.w  #0,(Ctrl_2_Logical).w
                                                      *        move.w  #0,(Ctrl_1).w
                                                      *        move.w  #0,(Ctrl_2).w
                                                      *        move.b  #1,(Control_Locked).w
                                                      *        move.b  #1,(Control_Locked_P2).w
                                                      *        move.b  #0,(Level_started_flag).w
                                                      *; Level_ChkWater:
                                                      *        tst.b   (Water_flag).w  ; does level have water?
                                                      *        beq.s   +       ; if not, branch
                                                      *        move.b  #ObjID_WaterSurface,(WaterSurface1+id).w ; load Obj04 (water surface) at $FFFFB380
                                                      *        move.w  #$60,(WaterSurface1+x_pos).w ; set horizontal offset
                                                      *        move.b  #ObjID_WaterSurface,(WaterSurface2+id).w ; load Obj04 (water surface) at $FFFFB3C0
                                                      *        move.w  #$120,(WaterSurface2+x_pos).w ; set different horizontal offset
                                                      *+
                                                      *        cmpi.b  #chemical_plant_zone,(Current_Zone).w   ; check if zone == CPZ
                                                      *        bne.s   +                       ; branch if not
                                                      *        move.b  #ObjID_CPZPylon,(CPZPylon+id).w ; load Obj7C (CPZ pylon) at $FFFFB340
                                                      *+
                                                      *        cmpi.b  #oil_ocean_zone,(Current_Zone).w        ; check if zone == OOZ
                                                      *        bne.s   Level_ClrHUD            ; branch if not
                                                      *        move.b  #ObjID_Oil,(Oil+id).w ; load Obj07 (OOZ oil) at $FFFFB380
                                                      *; Level_LoadObj: misnomer now
                                                      *Level_ClrHUD:
                                                      *        moveq   #0,d0
                                                      *        tst.b   (Last_star_pole_hit).w  ; are you starting from a lamppost?
                                                      *        bne.s   Level_FromCheckpoint    ; if yes, branch
                                                      *        move.w  d0,(Ring_count).w       ; clear rings
                                                      *        move.l  d0,(Timer).w            ; clear time
                                                      *        move.b  d0,(Extra_life_flags).w ; clear extra lives counter
                                                      *        move.w  d0,(Ring_count_2P).w    ; ditto for player 2
                                                      *        move.l  d0,(Timer_2P).w
                                                      *        move.b  d0,(Extra_life_flags_2P).w
                                                      *; loc_41E4:
                                                      *Level_FromCheckpoint:
                                                      *        move.b  d0,(Time_Over_flag).w
                                                      *        move.b  d0,(Time_Over_flag_2P).w
                                                      *        move.b  d0,(SlotMachine_Routine).w
                                                      *        move.w  d0,(SlotMachineInUse).w
                                                      *        move.w  d0,(Debug_placement_mode).w
                                                      *        move.w  d0,(Level_Inactive_flag).w
                                                      *        move.b  d0,(Teleport_timer).w
                                                      *        move.b  d0,(Teleport_flag).w
                                                      *        move.w  d0,(Rings_Collected).w
                                                      *        move.w  d0,(Rings_Collected_2P).w
                                                      *        move.w  d0,(Monitors_Broken).w
                                                      *        move.w  d0,(Monitors_Broken_2P).w
                                                      *        move.w  d0,(Loser_Time_Left).w
                                                      *        bsr.w   OscillateNumInit
                                                      *        move.b  #1,(Update_HUD_score).w
                                                      *        move.b  #1,(Update_HUD_rings).w
                                                      *        move.b  #1,(Update_HUD_timer).w
                                                      *        move.b  #1,(Update_HUD_timer_2P).w
                                                      *        jsr     (ObjectsManager).l
                                                      *        jsr     (RingsManager).l
                                                      *        jsr     (SpecialCNZBumpers).l
                                                      *        jsr     (RunObjects).l
                                                      *        jsr     (BuildSprites).l
                                                      *        jsrto   (AniArt_Load).l, JmpTo_AniArt_Load
                                                      *        bsr.w   SetLevelEndType
                                                      *        move.w  #0,(Demo_button_index).w
                                                      *        move.w  #0,(Demo_button_index_2P).w
                                                      *        lea     (DemoScriptPointers).l,a1
                                                      *        moveq   #0,d0
                                                      *        move.b  (Current_Zone).w,d0     ; load zone value
                                                      *        lsl.w   #2,d0
                                                      *        movea.l (a1,d0.w),a1
                                                      *        tst.w   (Demo_mode_flag).w
                                                      *        bpl.s   +
                                                      *        lea     (EndingDemoScriptPointers).l,a1
                                                      *        move.w  (Ending_demo_number).w,d0
                                                      *        subq.w  #1,d0
                                                      *        lsl.w   #2,d0
                                                      *        movea.l (a1,d0.w),a1
                                                      *+
                                                      *        move.b  1(a1),(Demo_press_counter).w
                                                      *        tst.b   (Current_Zone).w        ; emerald_hill_zone
                                                      *        bne.s   +
                                                      *        lea     (Demo_EHZ_Tails).l,a1
                                                      *        move.b  1(a1),(Demo_press_counter_2P).w
                                                      *+
                                                      *        move.w  #$668,(Demo_Time_left).w
                                                      *        tst.w   (Demo_mode_flag).w
                                                      *        bpl.s   +
                                                      *        move.w  #$21C,(Demo_Time_left).w
                                                      *        cmpi.w  #4,(Ending_demo_number).w
                                                      *        bne.s   +
                                                      *        move.w  #$1FE,(Demo_Time_left).w
                                                      *+
                                                      *        tst.b   (Water_flag).w
                                                      *        beq.s   ++
                                                      *        moveq   #PalID_HPZ_U,d0
                                                      *        cmpi.b  #hidden_palace_zone,(Current_Zone).w
                                                      *        beq.s   +
                                                      *        moveq   #PalID_CPZ_U,d0
                                                      *        cmpi.b  #chemical_plant_zone,(Current_Zone).w
                                                      *        beq.s   +
                                                      *        moveq   #PalID_ARZ_U,d0
                                                      *+
                                                      *        bsr.w   PalLoad_Water_ForFade
                                                      *+
                                                      *        move.w  #-1,(TitleCard_ZoneName+titlecard_leaveflag).w
                                                      *        move.b  #$E,(TitleCard_Left+routine).w  ; make the left part move offscreen
                                                      *        move.w  #$A,(TitleCard_Left+titlecard_location).w
                                                      *
                                                      *-       move.b  #VintID_TitleCard,(Vint_routine).w
                                                      *        bsr.w   WaitForVint
                                                      *        jsr     (RunObjects).l
                                                      *        jsr     (BuildSprites).l
                                                      *        bsr.w   RunPLC_RAM
                                                      *        tst.b   (TitleCard_Background+id).w
                                                      *        bne.s   -       ; loop while the title card background is still loaded
                                                      *
                                                      *        lea     (TitleCard).w,a1
                                                      *        move.b  #$16,TitleCard_ZoneName-TitleCard+routine(a1)
                                                      *        move.w  #$2D,TitleCard_ZoneName-TitleCard+anim_frame_duration(a1)
                                                      *        move.b  #$16,TitleCard_Zone-TitleCard+routine(a1)
                                                      *        move.w  #$2D,TitleCard_Zone-TitleCard+anim_frame_duration(a1)
                                                      *        tst.b   TitleCard_ActNumber-TitleCard+id(a1)
                                                      *        beq.s   +       ; branch if the act number has been unloaded
                                                      *        move.b  #$16,TitleCard_ActNumber-TitleCard+routine(a1)
                                                      *        move.w  #$2D,TitleCard_ActNumber-TitleCard+anim_frame_duration(a1)
                                                      *+       move.b  #0,(Control_Locked).w
                                                      *        move.b  #0,(Control_Locked_P2).w
                                                      *        move.b  #1,(Level_started_flag).w
                                                      *
                                                      *; Level_StartGame: loc_435A:
                                                      *        bclr    #GameModeFlag_TitleCard,(Game_Mode).w ; clear $80 from the game mode
                                                      *