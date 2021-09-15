; RAM variables - Special stage
; TODO : split entre variables qui doivent etre globales (restent ici)
; et celles specifiques a l'objet (vont avec le code objet)

* ===========================================================================
* Object Subtypes
* ===========================================================================
Sub_SpecialStage_Init             equ 0
Sub_SpecialStage_Main             equ 1

* ===========================================================================
* Object Constants
* ===========================================================================

nb_level_objects                  equ 3
nb_reserved_objects               equ 2
nb_dynamic_objects                equ 45
nb_graphical_objects                        equ 60 * max 64 total

; Objects that will be run manually from Special Stage
SpecialStageHalfPipe              fill  0,object_size
HalfPipeEven                      fill  0,object_size
HalfPipeOdd                       fill  0,object_size

Object_RAM
SS_Object_RAM
MainCharacter                     fill  0,object_size
;Sidekick                         fill  0,object_size
;SpecialStageHUD                  fill  0,object_size
;SpecialStageStartBanner          fill  0,object_size
;SpecialStageNumberOfRings        fill  0,object_size
SpecialStageShadow_Sonic          fill  0,object_size
;SpecialStageShadow_Tails         fill  0,object_size
;SpecialStageTails_Tails          fill  0,object_size
Dynamic_Object_RAM                fill  0,nb_dynamic_objects*object_size
;SpecialStageResults              fill  0,object_size
;                                 fill  0,$C*object_size
;SpecialStageResults2             fill  0,object_size
;                                 fill  0,$51*object_size
Dynamic_Object_RAM_End            fill  0,object_size
SS_Object_RAM_End
Object_RAM_End

Current_Special_Stage             fcb   $00

Ring_count                        fdb   $0000
SS2p_RingBuffer                   fill  0,12

SS_Misc_Variables
;PNT_Buffer                        fill  0,$700
;PNT_Buffer_End
;SS_Horiz_Scroll_Buf_2             fill  0,$400
SSTrack_mappings_bitflags         fill  0,4
SSTrack_mappings_uncompressed     fill  0,4
SSTrack_anim                      fcb   $00
SSTrack_last_anim_frame           fcb   $00
SpecialStage_CurrentSegment       fdb   $0000
SSTrack_anim_frame                fcb   $00
SS_Alternate_PNT                  fcb   $00
SSTrack_drawing_index             fcb   $00 ; 0:new half-pipe frame is displayed in this loop, >0:no refresh of half-pipe in this loop
SSTrack_Orientation               fcb   $00
SS_Alternate_HorizScroll_Buf      fcb   $00
SSTrack_mapping_frame             fcb   $00
SS_Last_Alternate_HorizScroll_Buf fcb   $00
SS_New_Speed_Factor               fill  0,4
SS_Cur_Speed_Factor               fill  0,9
SSTrack_duration_timer            fdb   $0000
SS_player_anim_frame_timer        fcb   $00
;SpecialStage_LastSegment          fcb   $00
SpecialStage_Started              fill  0,5
SSTrack_last_mappings_copy        fill  0,4
SSTrack_last_mappings             fill  0,8
SSTrack_LastVScroll               fill  0,5
SSTrack_last_mapping_frame        fcb   $00
SSTrack_mappings_RLE              fill  0,4
SSDrawRegBuffer                   fill  0,12
SSDrawRegBuffer_End               fdb   $0000
SpecialStage_LastSegment2         fdb   $0000
SS_unk_DB4D                       fill  0,$15
SS_Ctrl_Record_Buf                fill  0,30
SS_Last_Ctrl_Record               fdb   $0000
SS_Ctrl_Record_Buf_End
;SS_CurrentPerspective             fdb   $0000
SS_Check_Rings_flag               fcb   $00
SS_Pause_Only_flag                fcb   $00
SS_CurrentLevelObjectLocations    fill  0,4
SS_Ring_Requirement               fdb   $0000
SS_CurrentLevelLayout             fill  0,5
SS_2P_BCD_Score                   fdb   $0000
SS_NoCheckpoint_flag              fcb   $00
SS_Checkpoint_Rainbow_flag        fcb   $00
SS_Rainbow_palette                fcb   $00
SS_Perfect_rings_left             fill  0,4
SS_Star_color_1                   fcb   $00
SS_Star_color_2                   fcb   $00
SS_NoCheckpointMsg_flag           fcb   $00
SS_NoRingsTogoLifetime            fdb   $0000
SS_RingsToGoBCD                   fdb   $0000
SS_HideRingsToGo                  fcb   $00
SS_TriggerRingsToGo               fcb   $00
SS_Misc_Variables_End
;SS_Horiz_Scroll_Buf_1             fill  0,$400
;SS_Horiz_Scroll_Buf_1_End
SS_Offset_X                       fcb   $00
SS_Offset_Y                       fcb   $00
SS_Swap_Positions_Flag            fcb   $00
;SS_Sprite_Table                   fill  0,$280    ; Sprite attribute table buffer
;SS_Sprite_Table_End               fill  0,$80     ; unused, but SAT buffer can spill over into this area when there are too many sprites on-screen

; TO8 Version
HalfPipe_Seq               fcb $00
HalfPipe_Seq_UpdFlip       fdb $0000
HalfPipe_Vint_Track_Image  fdb $0000
SS_Seg_Len_x4              fdb $0000
HalfPipe_z_step            fdb $0000
HalfPipe_Nb_Elapsed_Frames fcb $00 
HalfPipe_Vint_Main_Loop    fdb $0000
