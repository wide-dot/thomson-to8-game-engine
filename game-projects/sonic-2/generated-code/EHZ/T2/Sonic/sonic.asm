	opt   c,ct
	INCLUDE "./generated-code/EHZ/T2/main-engine.glb"
	INCLUDE "./generated-code/EHZ/T2/Sonic/Sonic_Animation.glb"
	org   $28FB
	setdp $FF

; ---------------------------------------------------------------------------
; Object - Sonic
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"   

WIDTH_FACTOR equ 1/2 ; BM16 is wide dot
Sonic_top_speed_tmp    equ glb_tmp_var
Sonic_acceleration_tmp equ glb_tmp_var+2
Sonic_deceleration_tmp equ glb_tmp_var+4

                                                      *; ===========================================================================
                                                      *; ----------------------------------------------------------------------------
                                                      *; Object 01 - Sonic
                                                      *; ----------------------------------------------------------------------------
                                                      *; Sprite_19F50: Object_Sonic:
Obj01                                                 *Obj01:
                                                      *  ; a0=character
                                                      *  tst.w   (Debug_placement_mode).w    ; is debug mode being used?
                                                      *  beq.s   Obj01_Normal            ; if not, branch
                                                      *  jmp (DebugMode).l
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_19F5C:
Obj01_Normal                                          *Obj01_Normal:
                                                      *  moveq   #0,d0
        lda   routine,u                               *  move.b  routine(a0),d0
        asla                                           
        ldx   #Obj01_Index                            *  move.w  Obj01_Index(pc,d0.w),d1
        jmp   [a,x]                                   *  jmp Obj01_Index(pc,d1.w)
                                                      *; ===========================================================================
                                                      *; off_19F6A: Obj01_States:
Obj01_Index                                           *Obj01_Index:  offsetTable
        fdb   Obj01_Init                              *      offsetTableEntry.w Obj01_Init       ;  0
        fdb   Obj01_Control                           *      offsetTableEntry.w Obj01_Control    ;  2
        fdb   Obj01_Hurt                              *      offsetTableEntry.w Obj01_Hurt       ;  4
        fdb   Obj01_Dead                              *      offsetTableEntry.w Obj01_Dead       ;  6
        fdb   Obj01_Gone                              *      offsetTableEntry.w Obj01_Gone       ;  8
        fdb   Obj01_Respawning                        *      offsetTableEntry.w Obj01_Respawning ; $A
                                                      *; ===========================================================================
                                                      *; loc_19F76: Obj_01_Sub_0: Obj01_Main:
Obj01_Init                                            *  Obj01_Init:
        inc   routine,u                               *  addq.b  #2,routine(a0)  ; => Obj01_Control
        _ldd  $13,9*WIDTH_FACTOR                      *  move.b  #$13,y_radius(a0) ; this sets Sonic's collision height (2*pixels)
        std   y_radius,u ; and x_radius               *  move.b  #9,x_radius(a0)
        ; unused                                      *  move.l  #Mapunc_Sonic,mappings(a0)
        lda   #$02                                    *            
        sta   priority,u                              *  move.b  #2,priority(a0)
        lda   #18*WIDTH_FACTOR                         
        sta   width_pixels,u                          *  move.b  #$18,width_pixels(a0)
        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u                          *  move.b  #4,render_flags(a0)
        ldd   #$600                                   *
        std   Sonic_top_speed                         *  move.w  #$600,(Sonic_top_speed).w   ; set Sonic's top speed
        ldd   #$000C                                  *
        std   Sonic_acceleration                      *  move.w  #$C,(Sonic_acceleration).w  ; set Sonic's acceleration
        ldd   #$0080
        std   Sonic_deceleration                      *  move.w  #$80,(Sonic_deceleration).w ; set Sonic's deceleration
        tst   Last_star_pole_hit                      *  tst.b   (Last_star_pole_hit).w
        bne   Obj01_Init_Continued                    *  bne.s   Obj01_Init_Continued
                                                      *  ; only happens when not starting at a checkpoint:
        ; unused                                      *  move.w  #make_art_tile(ArtTile_ArtUnc_Sonic,0,0),art_tile(a0)
        ; unused                                      *  bsr.w   Adjust2PArtPointer
        ldd   #$0C0D
        sta   top_solid_bit,u                         *  move.b  #$C,top_solid_bit(a0)
        sta   Saved_Solid_bits
        stb   lrb_solid_bit,u                         *  move.b  #$D,lrb_solid_bit(a0)
        ldd   x_pos,u                                 *               
        std   Saved_x_pos                             *  move.w  x_pos(a0),(Saved_x_pos).w
        ldd   y_pos,u                                 *               
        std   Saved_y_pos                             *  move.w  y_pos(a0),(Saved_y_pos).w
        ; unused                                      *  move.w  art_tile(a0),(Saved_art_tile).w
        ; moved                                       *  move.w  top_solid_bit(a0),(Saved_Solid_bits).w
                                                      *
Obj01_Init_Continued                                  *  Obj01_Init_Continued:
        ldd   #$0004
        sta   flips_remaining,u                       *  move.b  #0,flips_remaining(a0)
        stb   flip_speed,u                            *  move.b  #4,flip_speed(a0)
        ; unimplemented                               *  move.b  #0,(Super_Sonic_flag).w
        lda   #$1E
        sta   air_left,u                              *  move.b  #$1E,air_left(a0)
        ;ldd   x_pos,u
        ;subd  #$20*WIDTH_FACTOR
        ;std   x_pos,u                                 *  subi.w  #$20,x_pos(a0)
        ;ldd   y_pos,u
        ;addd  #4
        ;std   y_pos,u                                 *  addi_.w #4,y_pos(a0)
        ;ldd   #$0000                                  *
        ;std   Sonic_Pos_Record_Index                  *  move.w  #0,(Sonic_Pos_Record_Index).w
                                                      *
        ; init Sonic_Pos_Record_Buf with sonic's x and y pos
        ; init Sonic_Stat_Record_Buf at 0 (joyp control)
                                                      *  move.w  #$3F,d2
        ;jsr   Sonic_RecordPos                         *- bsr.w   Sonic_RecordPos
                                                      *  subq.w  #4,a1
                                                      *  move.l  #0,(a1)
                                                      *  dbf d2,-
                                                      *
        ;ldd   x_pos,u
        ;addd  #$20*WIDTH_FACTOR
        ;std   x_pos,u                                 *  addi.w  #$20,x_pos(a0)
        ;ldd   y_pos,u
        ;subd  #4
        ;std   y_pos,u                                 *  subi_.w #4,y_pos(a0)
                                                      *; ---------------------------------------------------------------------------
                                                      *; Normal state for Sonic
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A030: Obj_01_Sub_2:
Obj01_Control                                         *  Obj01_Control:
                                                      *  tst.w   (Debug_mode_flag).w ; is debug cheat enabled?
                                                      *  beq.s   +           ; if not, branch
                                                      *  btst    #button_B,(Ctrl_1_Press).w  ; is button B pressed?
                                                      *  beq.s   +           ; if not, branch
                                                      *  move.w  #1,(Debug_placement_mode).w ; change Sonic into a ring/item
                                                      *  clr.b   (Control_Locked).w      ; unlock control
                                                      *  rts
                                                      *; -----------------------------------------------------------------------
        tst   Control_Locked                          *+ tst.b   (Control_Locked).w  ; are controls locked?
        bne   >                                       *  bne.s   +           ; if yes, branch
        ldd   Ctrl_1
        std   Ctrl_1_Logical                          *  move.w  (Ctrl_1).w,(Ctrl_1_Logical).w   ; copy new held buttons, to enable joypad control
!                                                     *+
        lda   obj_control,u
        bita  #1                                      *  btst    #0,obj_control(a0)  ; is Sonic interacting with another object that holds him in place or controls his movement somehow?
        bne   >                                       *  bne.s   +           ; if yes, branch to skip Sonic's control
                                                      *  moveq   #0,d0
        lda   status,u                          *  move.b  status(a0),d0
        anda  #status_inair|status_jumporroll         *  andi.w  #6,d0   ; %0000 %0110
        ldx   #Obj01_Modes                            *  move.w  Obj01_Modes(pc,d0.w),d1
        jsr   [a,x]                                   *  jsr Obj01_Modes(pc,d1.w)    ; run Sonic's movement control code
!                                                     *+

        ; unimplemented                               *  cmpi.w  #-$100,(Camera_Min_Y_pos).w ; is vertical wrapping enabled?
                                                      *  bne.s   +               ; if not, branch
                                                      *  andi.w  #$7FF,y_pos(a0)         ; perform wrapping of Sonic's y position
                                                      *+

        jsr   Sonic_Display                            *  bsr.s   Sonic_Display
        ;jsr   Sonic_Super                             *  bsr.w   Sonic_Super
        ;jsr   Sonic_RecordPos                         *  bsr.w   Sonic_RecordPos
        ;jsr   Sonic_Water                             *  bsr.w   Sonic_Water
        ldd   Primary_Angle ; and Secondary_Angle      *  move.b  (Primary_Angle).w,next_tilt(a0)
        std   next_tilt,u   ; and tilt,u               *  move.b  (Secondary_Angle).w,tilt(a0)
        ;tst   WindTunnel_flag                         *  tst.b   (WindTunnel_flag).w
        ;beq   @a                                      *  beq.s   +
        ;tst   anim,u                                  *  tst.b   anim(a0)
        ;bne   @a                                      *  bne.s   +
        ;ldd   prev_anim,u                             *  move.b  prev_anim(a0),anim(a0)
        ;std   anim,u                                  
@a                                                     *+

        jsr   Sonic_Animate                            *  bsr.w   Sonic_Animate
        ;tst   obj_control,u                           *  tst.b   obj_control(a0)
        ;bmi   @a                                      *  bmi.s   +
        ;jsr   TouchResponse                           *  jsr (TouchResponse).l
@a                                                     *+

        rts                                           *  bra.w   LoadSonicDynPLC
                                                      *
                                                      *; ===========================================================================
                                                      *; secondary states under state Obj01_Control
                                                      *; off_1A0BE:
Obj01_Modes                                           *Obj01_Modes:  offsetTable
        fdb Obj01_MdNormal_Checks                     *      offsetTableEntry.w Obj01_MdNormal_Checks    ; 0 - not airborne or rolling
        fdb Obj01_MdAir                               *      offsetTableEntry.w Obj01_MdAir          ; 2 - airborne
        fdb Obj01_MdRoll                              *      offsetTableEntry.w Obj01_MdRoll         ; 4 - rolling
        fdb Obj01_MdJump                              *      offsetTableEntry.w Obj01_MdJump         ; 6 - jumping
                                                      *; ===========================================================================
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A0C6:
Sonic_Display                                         *Sonic_Display:
                                                      *  move.w  invulnerable_time(a0),d0
                                                      *  beq.s   Obj01_Display
                                                      *  subq.w  #1,invulnerable_time(a0)
                                                      *  lsr.w   #3,d0
                                                      *  bcc.s   Obj01_ChkInvin
                                                      *; loc_1A0D4:
Obj01_Display                                         *Obj01_Display:
        jsr   DisplaySprite                           *  jsr (DisplaySprite).l
                                                      *; loc_1A0DA:
Obj01_ChkInvin                                        *Obj01_ChkInvin:       ; Checks if invincibility has expired and disables it if it has.
                                                      *  btst    #status_sec_isInvincible,status_secondary(a0)
                                                      *  beq.s   Obj01_ChkShoes
                                                      *  tst.w   invincibility_time(a0)
                                                      *  beq.s   Obj01_ChkShoes  ; If there wasn't any time left, that means we're in Super Sonic mode.
                                                      *  subq.w  #1,invincibility_time(a0)
                                                      *  bne.s   Obj01_ChkShoes
                                                      *  tst.b   (Current_Boss_ID).w ; Don't change music if in a boss fight
                                                      *  bne.s   Obj01_RmvInvin
                                                      *  cmpi.b  #$C,air_left(a0)    ; Don't change music if drowning
                                                      *  blo.s   Obj01_RmvInvin
                                                      *  move.w  (Level_Music).w,d0
                                                      *  jsr (PlayMusic).l
                                                      *;loc_1A106:
Obj01_RmvInvin                                        *Obj01_RmvInvin:
                                                      *  bclr    #status_sec_isInvincible,status_secondary(a0)
                                                      *; loc_1A10C:
Obj01_ChkShoes                                        *Obj01_ChkShoes:       ; Checks if Speed Shoes have expired and disables them if they have.
                                                      *  btst    #status_sec_hasSpeedShoes,status_secondary(a0)
                                                      *  beq.s   Obj01_ExitChk
                                                      *  tst.w   speedshoes_time(a0)
                                                      *  beq.s   Obj01_ExitChk
                                                      *  subq.w  #1,speedshoes_time(a0)
                                                      *  bne.s   Obj01_ExitChk
                                                      *  move.w  #$600,(Sonic_top_speed).w
                                                      *  move.w  #$C,(Sonic_acceleration).w
                                                      *  move.w  #$80,(Sonic_deceleration).w
                                                      *  tst.b   (Super_Sonic_flag).w
                                                      *  beq.s   Obj01_RmvSpeed
                                                      *  move.w  #$A00,(Sonic_top_speed).w
                                                      *  move.w  #$30,(Sonic_acceleration).w
                                                      *  move.w  #$100,(Sonic_deceleration).w
                                                      *; loc_1A14A:
Obj01_RmvSpeed                                        *Obj01_RmvSpeed:
                                                      *  bclr    #status_sec_hasSpeedShoes,status_secondary(a0)
                                                      *  move.w  #MusID_SlowDown,d0  ; Slow down tempo
                                                      *  jmp (PlayMusic).l
                                                      *; ---------------------------------------------------------------------------
                                                      *; return_1A15A:
Obj01_ExitChk                                         *Obj01_ExitChk:
        rts                                           *  rts
                                                      *; End of subroutine Sonic_Display
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to record Sonic's previous positions for invincibility stars
                                                      *; and input/status flags for Tails' AI to follow
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
; unimplemented                                       *; loc_1A15C:
;Sonic_RecordPos                                       *Sonic_RecordPos:
                                                      *  move.w  (Sonic_Pos_Record_Index).w,d0
                                                      *  lea (Sonic_Pos_Record_Buf).w,a1
                                                      *  lea (a1,d0.w),a1
                                                      *  move.w  x_pos(a0),(a1)+
                                                      *  move.w  y_pos(a0),(a1)+
                                                      *  addq.b  #4,(Sonic_Pos_Record_Index+1).w
                                                      *
                                                      *  lea (Sonic_Stat_Record_Buf).w,a1
                                                      *  lea (a1,d0.w),a1
                                                      *  move.w  (Ctrl_1_Logical).w,(a1)+
                                                      *  move.w  status(a0),(a1)+
                                                      *
;        rts                                           *  rts
                                                      *; End of subroutine Sonic_RecordPos
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine for Sonic when he's underwater
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A186:
Sonic_Water                                           *Sonic_Water:
        tst   Water_flag                              *  tst.b   (Water_flag).w  ; does level have water?
        bne   Obj01_InWater                           *  bne.s   Obj01_InWater   ; if yes, branch
                                                      *
return_1A18C                                          *return_1A18C:
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A18E:
Obj01_InWater                                         *Obj01_InWater:
                                                      *  move.w  (Water_Level_1).w,d0
                                                      *  cmp.w   y_pos(a0),d0    ; is Sonic above the water?
                                                      *  bge.s   Obj01_OutWater  ; if yes, branch
                                                      *
                                                      *  bset    #6,status(a0)   ; set underwater flag
                                                      *  bne.s   return_1A18C    ; if already underwater, branch
                                                      *
                                                      *  movea.l a0,a1
                                                      *  bsr.w   ResumeMusic
                                                      *  move.b  #ObjID_SmallBubbles,(Sonic_BreathingBubbles+id).w ; load Obj0A (sonic's breathing bubbles) at $FFFFD080
                                                      *  move.b  #$81,(Sonic_BreathingBubbles+subtype).w
                                                      *  move.l  a0,(Sonic_BreathingBubbles+objoff_3C).w
                                                      *  move.w  #$300,(Sonic_top_speed).w
                                                      *  move.w  #6,(Sonic_acceleration).w
                                                      *  move.w  #$40,(Sonic_deceleration).w
                                                      *  tst.b   (Super_Sonic_flag).w
                                                      *  beq.s   +
                                                      *  move.w  #$500,(Sonic_top_speed).w
                                                      *  move.w  #$18,(Sonic_acceleration).w
                                                      *  move.w  #$80,(Sonic_deceleration).w
                                                      *+
                                                      *  asr.w   x_vel(a0)
                                                      *  asr.w   y_vel(a0)   ; memory operands can only be shifted one bit at a time
                                                      *  asr.w   y_vel(a0)
                                                      *  beq.s   return_1A18C
                                                      *  move.w  #$100,(Sonic_Dust+anim).w   ; splash animation
                                                      *  move.w  #SndID_Splash,d0    ; splash sound
                                                      *  jmp (PlaySound).l
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A1FE:
Obj01_OutWater                                        *Obj01_OutWater:
                                                      *  bclr    #6,status(a0) ; unset underwater flag
                                                      *  beq.s   return_1A18C ; if already above water, branch
                                                      *
                                                      *  movea.l a0,a1
                                                      *  bsr.w   ResumeMusic
                                                      *  move.w  #$600,(Sonic_top_speed).w
                                                      *  move.w  #$C,(Sonic_acceleration).w
                                                      *  move.w  #$80,(Sonic_deceleration).w
                                                      *  tst.b   (Super_Sonic_flag).w
                                                      *  beq.s   +
                                                      *  move.w  #$A00,(Sonic_top_speed).w
                                                      *  move.w  #$30,(Sonic_acceleration).w
                                                      *  move.w  #$100,(Sonic_deceleration).w
                                                      *+
                                                      *  cmpi.b  #4,routine(a0)  ; is Sonic falling back from getting hurt?
                                                      *  beq.s   +       ; if yes, branch
                                                      *  asl y_vel(a0)
                                                      *+
                                                      *  tst.w   y_vel(a0)
                                                      *  beq.w   return_1A18C
                                                      *  move.w  #$100,(Sonic_Dust+anim).w   ; splash animation
                                                      *  movea.l a0,a1
                                                      *  bsr.w   ResumeMusic
                                                      *  cmpi.w  #-$1000,y_vel(a0)
                                                      *  bgt.s   +
                                                      *  move.w  #-$1000,y_vel(a0)   ; limit upward y velocity exiting the water
                                                      *+
                                                      *  move.w  #SndID_Splash,d0    ; splash sound
                                                      *  jmp (PlaySound).l
                                                      *; End of subroutine Sonic_Water
                                                      *
                                                      *; ===========================================================================
                                                      *; ---------------------------------------------------------------------------
                                                      *; Start of subroutine Obj01_MdNormal
                                                      *; Called if Sonic is neither airborne nor rolling this frame
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A26E:
Obj01_MdNormal_Checks                                 *Obj01_MdNormal_Checks:
        lda   Ctrl_1_Press_Logical                    *  move.b  (Ctrl_1_Press_Logical).w,d0
        anda  button_B_mask|button_A_mask             *  andi.b  #button_B_mask|button_C_mask|button_A_mask,d0
        bne   Obj01_MdNormal                          *  bne.s   Obj01_MdNormal
        ldd   anim,u
        cmpd  #SonAni_Blink                           *  cmpi.b  #AniIDSonAni_Blink,anim(a0)
        beq   return_1A2DE                            *  beq.s   return_1A2DE
        cmpd  #SonAni_GetUp                           *  cmpi.b  #AniIDSonAni_GetUp,anim(a0)
        beq   return_1A2DE                            *  beq.s   return_1A2DE
        cmpd  #SonAni_Wait                            *  cmpi.b  #AniIDSonAni_Wait,anim(a0)
        bne   Obj01_MdNormal                          *  bne.s   Obj01_MdNormal
        lda   anim_frame,u                            
        cmpa  #$1E                                    *  cmpi.b  #$1E,anim_frame(a0)
        blo   Obj01_MdNormal                          *  blo.s   Obj01_MdNormal
        ldb   Ctrl_1_Held_Logical                     *  move.b  (Ctrl_1_Held_Logical).w,d0
        andb  #button_up_mask|button_down_mask|button_left_mask|button_right_mask|button_B_mask|button_A_mask *  andi.b  #button_up_mask|button_down_mask|button_left_mask|button_right_mask|button_B_mask|button_C_mask|button_A_mask,d0
        beq   return_1A2DE                            *  beq.s   return_1A2DE
        ldx   #SonAni_Blink
        stx   anim,u                                  *  move.b  #AniIDSonAni_Blink,anim(a0)
        cmpa  #$AC                                    *  cmpi.b  #$AC,anim_frame(a0)
        blo   return_1A2DE                            *  blo.s   return_1A2DE
        ldd   #SonAni_GetUp
        std   anim,u                                  *  move.b  #AniIDSonAni_GetUp,anim(a0)
        bra   return_1A2DE                            *  bra.s   return_1A2DE
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A2B8:
Obj01_MdNormal                                        *Obj01_MdNormal:
        jsr   Sonic_CheckSpindash                     *  bsr.w   Sonic_CheckSpindash
        jsr   Sonic_Jump                              *  bsr.w   Sonic_Jump
        jsr   Sonic_SlopeResist                       *  bsr.w   Sonic_SlopeResist
        jsr   Sonic_Move                              *  bsr.w   Sonic_Move
        jsr   Sonic_Roll                              *  bsr.w   Sonic_Roll
        jsr   Sonic_LevelBound                        *  bsr.w   Sonic_LevelBound
        jsr   ObjectMove                              *  jsr (ObjectMove).l
        jsr   AnglePos                                *  bsr.w   AnglePos
        jsr   Sonic_SlopeRepel                        *  bsr.w   Sonic_SlopeRepel
                                                      *
return_1A2DE                                          *return_1A2DE:
        rts                                           *  rts
                                                      *; End of subroutine Obj01_MdNormal
                                                      *; ===========================================================================
                                                      *; Start of subroutine Obj01_MdAir
                                                      *; Called if Sonic is airborne, but not in a ball (thus, probably not jumping)
Obj01_MdJump                                          *; loc_1A2E0: Obj01_MdJump
Obj01_MdAir                                           *Obj01_MdAir:
        jsr   Sonic_JumpHeight                        *  bsr.w   Sonic_JumpHeight
        jsr   Sonic_ChgJumpDir                        *  bsr.w   Sonic_ChgJumpDir
        jsr   Sonic_LevelBound                        *  bsr.w   Sonic_LevelBound
        jsr   ObjectMoveAndFall                        *  jsr (ObjectMoveAndFall).l
        ; moved in ObjectFall                          *  btst    #6,status(a0)   ; is Sonic underwater?
        ;                                              *  beq.s   +       ; if not, branch
        ;                                              *  subi.w  #$28,y_vel(a0)  ; reduce gravity by $28 ($38-$28=$10)
        ;                                              *+                                           
        jsr   Sonic_JumpAngle                         *  bsr.w   Sonic_JumpAngle
        jsr   Sonic_DoLevelCollision                  *  bsr.w   Sonic_DoLevelCollision
        rts                                           *  rts
                                                      *; End of subroutine Obj01_MdAir
                                                      *; ===========================================================================
                                                      *; Start of subroutine Obj01_MdRoll
                                                      *; Called if Sonic is in a ball, but not airborne (thus, probably rolling)
                                                      *; loc_1A30A:
Obj01_MdRoll                                          *Obj01_MdRoll:
        tst   pinball_mode,u                          *  tst.b   pinball_mode(a0)
        bne   >                                       *  bne.s   +
        jsr   Sonic_Jump                              *  bsr.w   Sonic_Jump
!                                                     *+
        jsr   Sonic_RollRepel                         *  bsr.w   Sonic_RollRepel
        jsr   Sonic_RollSpeed                         *  bsr.w   Sonic_RollSpeed
        jsr   Sonic_LevelBound                        *  bsr.w   Sonic_LevelBound
        jsr   ObjectMove                              *  jsr (ObjectMove).l
        jsr   AnglePos                                *  bsr.w   AnglePos
        jsr   Sonic_SlopeRepel                        *  bsr.w   Sonic_SlopeRepel
        rts                                           *  rts
                                                      *; End of subroutine Obj01_MdRoll
                                                      *; ===========================================================================
                                                      *; Start of subroutine Obj01_MdJump
                                                      *; Called if Sonic is in a ball and airborne (he could be jumping but not necessarily)
                                                      *; Notes: This is identical to Obj01_MdAir, at least at this outer level.
                                                      *;        Why they gave it a separate copy of the code, I don't know.
                                                      *; loc_1A330: Obj01_MdJump2:
        ; duplicate code                              *Obj01_MdJump:
        ; see Obj01_MdAir                             *  bsr.w   Sonic_JumpHeight
                                                      *  bsr.w   Sonic_ChgJumpDir
                                                      *  bsr.w   Sonic_LevelBound
                                                      *  jsr (ObjectMoveAndFall).l
                                                      *  btst    #6,status(a0)   ; is Sonic underwater?
                                                      *  beq.s   +       ; if not, branch
                                                      *  subi.w  #$28,y_vel(a0)  ; reduce gravity by $28 ($38-$28=$10)
                                                      *+
                                                      *  bsr.w   Sonic_JumpAngle
                                                      *  bsr.w   Sonic_DoLevelCollision
                                                      *  rts
        ; end of duplicate code                       *; End of subroutine Obj01_MdJump
                                                      *

ObjectMoveAndFall
        ldb   #$38                                    
        lda   status,u
        bita  #status_underwater                      
        beq   >             
        ldb   #$10
!       anda  #0
        std   @gravity
        ldx   Vint_Main_runcount_w
        bne   >
        ldx   #1
!       ldd   #0
        std   @y_vel
        ldy   #0
@y_vel  equ   -2
        ldd   y_vel,u
@loop   addd  #0
@gravity equ  *-2
        bcs   >
        leay  d,y
        leax  -1,x
        bne   @loop 
        bra   @a
!       subd  @gravity
        _negd 
        leay  d,y
        ldd   #0
@a      std   y_vel,u
        sty   @y_vel
        ;
        ldd   x_vel,u
        ldx   Vint_Main_runcount_w     ; take number of elapsed frame since last render and multiply by inertia/2
        beq   @ObjMv
!       addd  x_vel,u
        leax  -1,x
        bne   < 
@ObjMv  _asrd ; wide dot ratio
        std   @x_vel
                                       *    move.l  x_pos(a0),d2    ; load x position
                                       *    move.l  y_pos(a0),d3    ; load y position
                                       *    move.w  x_vel(a0),d0    ; load horizontal speed
                                       *    ext.l   d0
                                       *    asl.l   #8,d0   ; shift velocity to line up with the middle 16 bits of the 32-bit position
                                       *    add.l   d0,d2   ; add to x-axis position    ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
        ldb   @x_vel
        sex                            ; velocity is positive or negative, take care of that
        sta   @b
        ldd   #0
@x_vel  equ   *-2
        addd  x_pos+1,u                ; x_pos must be followed by x_sub in memory
        std   x_pos+1,u                ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
        adca  #$00                     ; parameter is modified by the result of sign extend
@b      equ   *-1
        sta   x_pos,u                  ; update high byte of x_pos
                                       *    move.w  y_vel(a0),d0    ; load vertical speed
                                       *    ext.l   d0
                                       *    asl.l   #8,d0   ; shift velocity to line up with the middle 16 bits of the 32-bit position
                                       *    add.l   d0,d3   ; add to y-axis position    ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
                                       *    move.l  d2,u_pos(a0)    ; update x-axis position
                                       *    move.l  d3,y_pos(a0)    ; update y-axis position
        ldb   @y_vel
        sex                            ; velocity is positive or negative, take care of that
        sta   @c
        ldd   @y_vel
        addd  y_pos+1,u                ; y_pos must be followed by y_sub in memory
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
        adca  #$00                     ; parameter is modified by the result of sign extend
@c      equ   *-1
        sta   y_pos,u                  ; update high byte of y_pos
        rts                            *    rts
                                       *; End of function ObjectMove
                                       *; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ObjectMove
        ldd   y_vel,u
        std   @y_vel
        ldd   x_vel,u
        bra   @ObjMv
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to make Sonic walk/run
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A35A:
Sonic_Move                                            *Sonic_Move:
        ldd   Sonic_top_speed
        std   Sonic_top_speed_tmp                     *  move.w  (Sonic_top_speed).w,d6
        lda   Vint_Main_runcount
        bne   >
        lda   #1
!       ldb   Sonic_acceleration+1
        mul
        std   Sonic_acceleration_tmp                  *  move.w  (Sonic_acceleration).w,d5
        lda   Vint_Main_runcount
        bne   >
        lda   #1
!       ldb   Sonic_deceleration+1
        mul
        std   Sonic_deceleration_tmp                  *  move.w  (Sonic_deceleration).w,d4
                                                      *    if status_sec_isSliding = 7
        tst   status_secondary,u                      *  tst.b   status_secondary(a0)
        lbmi  Obj01_Traction                          *  bmi.w   Obj01_Traction
                                                      *    else
                                                      *  btst    #status_sec_isSliding,status_secondary(a0)
                                                      *  bne.w   Obj01_Traction
                                                      *    endif
        tst   move_lock,u                             *  tst.w   move_lock(a0)
        lbne  Obj01_ResetScr                          *  bne.w   Obj01_ResetScr
        lda   Ctrl_1_Held_Logical
        anda  #button_left_mask                       *  btst    #button_left,(Ctrl_1_Held_Logical).w    ; is left being pressed?
        beq   Obj01_NotLeft                           *  beq.s   Obj01_NotLeft           ; if not, branch
        jsr   Sonic_MoveLeft                          *  bsr.w   Sonic_MoveLeft
                                                      *; loc_1A382:
Obj01_NotLeft                                         *Obj01_NotLeft:
        lda   Ctrl_1_Held_Logical                     *  btst    #button_right,(Ctrl_1_Held_Logical).w   ; is right being pressed?
        anda  #button_right_mask                       
        beq   Obj01_NotRight                          *  beq.s   Obj01_NotRight          ; if not, branch
        jsr   Sonic_MoveRight                         *  bsr.w   Sonic_MoveRight
                                                      *; loc_1A38E:
Obj01_NotRight                                        *Obj01_NotRight:
        lda   angle,u                                 *  move.b  angle(a0),d0
        adda  #$20                                    *  addi.b  #$20,d0
        anda  #$C0                                    *  andi.b  #$C0,d0     ; is Sonic on a slope?
        lbne  Obj01_ResetScr                          *  bne.w   Obj01_ResetScr  ; if yes, branch
        ldd   inertia,u                               *  tst.w   inertia(a0) ; is Sonic moving?
        lbne  Obj01_ResetScr                          *  bne.w   Obj01_ResetScr  ; if yes, branch
        ldb   status,u
        andb  #^status_pushing 
        stb   status,u                                *  bclr    #5,status(a0)
        ldx   #SonAni_Wait                            *  move.b  #AniIDSonAni_Wait,anim(a0)  ; use "standing" animation
        stx   anim,u
        bitb  #status_norgroundnorfall                *  btst    #3,status(a0)
        beq   Sonic_Balance                           *  beq.w   Sonic_Balance




        ; TODO fix object size
        bra   Sonic_Lookup
        ; --------------------
        lda   interact,u                              *  moveq   #0,d0
                                                      *  move.b  interact(a0),d0
                                                      *    if object_size=$40
                                                      *  lsl.w   #6,d0
                                                      *    else
        ldb   #object_size
        mul                                           *  mulu.w  #object_size,d0
                                                      *    endif
        ldx   #Object_RAM                             *  lea (Object_RAM).w,a1 ; a1=character
        leax  d,u                                     *  lea (a1,d0.w),a1 ; a1=object
        tst   status,x                                *  tst.b   status(a1)
        bmi   Sonic_Lookup                            *  bmi.w   Sonic_Lookup
        lda   #0                                      *  moveq   #0,d1
        ldb   width_pixels,x                          *  move.b  width_pixels(a1),d1
        std   @d1                                     *  move.w  d1,d2
        _lsld                                         *  add.w   d2,d2
        subb  #2                                      *  subq.w  #2,d2
        stb   @d2
        ldd   #0
@d1     equ   *-2
        addd  x_pos,u                                 *  add.w   x_pos(a0),d1
        subd  x_pos,x                                 *  sub.w   x_pos(a1),d1
        ;tst   Super_Sonic_flag                        *  tst.b   (Super_Sonic_flag).w
        ;bne   SuperSonic_Balance                      *  bne.w   SuperSonic_Balance
        cmpd  #2                                      *  cmpi.w  #2,d1
        blt   Sonic_BalanceOnObjLeft                  *  blt.s   Sonic_BalanceOnObjLeft
        cmpd  #0                                      *  cmp.w   d2,d1
@d2     equ   *-1
        bge   Sonic_BalanceOnObjRight                 *  bge.s   Sonic_BalanceOnObjRight
        bra   Sonic_Lookup                            *  bra.w   Sonic_Lookup

                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A3FE:
SuperSonic_Balance                                    *SuperSonic_Balance:
                                                      *  cmpi.w  #2,d1
                                                      *  blt.w   SuperSonic_BalanceOnObjLeft
                                                      *  cmp.w   d2,d1
                                                      *  bge.w   SuperSonic_BalanceOnObjRight
                                                      *  bra.w   Sonic_Lookup
                                                      *; ---------------------------------------------------------------------------
                                                      *; balancing checks for when you're on the right edge of an object
                                                      *; loc_1A410:
Sonic_BalanceOnObjRight                               *Sonic_BalanceOnObjRight:
                                                      *  btst    #0,status(a0)
                                                      *  bne.s   +
                                                      *  move.b  #AniIDSonAni_Balance,anim(a0)
                                                      *  addq.w  #6,d2
                                                      *  cmp.w   d2,d1
                                                      *  blt.w   Obj01_ResetScr
                                                      *  move.b  #AniIDSonAni_Balance2,anim(a0)
                                                      *  bra.w   Obj01_ResetScr
                                                      *  ; on right edge of object but facing left:
                                                      *+ move.b  #AniIDSonAni_Balance3,anim(a0)
                                                      *  addq.w  #6,d2
                                                      *  cmp.w   d2,d1
                                                      *  blt.w   Obj01_ResetScr
                                                      *  move.b  #AniIDSonAni_Balance4,anim(a0)
                                                      *  bclr    #0,status(a0)
                                                      *  bra.w   Obj01_ResetScr
                                                      *; ---------------------------------------------------------------------------
                                                      *; balancing checks for when you're on the left edge of an object
                                                      *; loc_1A44E:
Sonic_BalanceOnObjLeft                                *Sonic_BalanceOnObjLeft:
                                                      *  btst    #0,status(a0)
                                                      *  beq.s   +
                                                      *  move.b  #AniIDSonAni_Balance,anim(a0)
                                                      *  cmpi.w  #-4,d1
                                                      *  bge.w   Obj01_ResetScr
                                                      *  move.b  #AniIDSonAni_Balance2,anim(a0)
                                                      *  bra.w   Obj01_ResetScr
                                                      *  ; on left edge of object but facing right:
                                                      *+ move.b  #AniIDSonAni_Balance3,anim(a0)
                                                      *  cmpi.w  #-4,d1
                                                      *  bge.w   Obj01_ResetScr
                                                      *  move.b  #AniIDSonAni_Balance4,anim(a0)
                                                      *  bset    #0,status(a0)
                                                      *  bra.w   Obj01_ResetScr
                                                      *; ---------------------------------------------------------------------------
                                                      *; balancing checks for when you're on the edge of part of the level
                                                      *; loc_1A48C:
Sonic_Balance                                         *Sonic_Balance:
                                                      *  jsr (ChkFloorEdge).l
                                                      *  cmpi.w  #$C,d1
                                                      *  blt.w   Sonic_Lookup
                                                      *  tst.b   (Super_Sonic_flag).w
                                                      *  bne.w   SuperSonic_Balance2
                                                      *  cmpi.b  #3,next_tilt(a0)
                                                      *  bne.s   Sonic_BalanceLeft
                                                      *  btst    #0,status(a0)
                                                      *  bne.s   +
                                                      *  move.b  #AniIDSonAni_Balance,anim(a0)
                                                      *  move.w  x_pos(a0),d3
                                                      *  subq.w  #6,d3
                                                      *  jsr (ChkFloorEdge_Part2).l
                                                      *  cmpi.w  #$C,d1
                                                      *  blt.w   Obj01_ResetScr
                                                      *  move.b  #AniIDSonAni_Balance2,anim(a0)
                                                      *  bra.w   Obj01_ResetScr
                                                      *  ; on right edge but facing left:
                                                      *+ move.b  #AniIDSonAni_Balance3,anim(a0)
                                                      *  move.w  x_pos(a0),d3
                                                      *  subq.w  #6,d3
                                                      *  jsr (ChkFloorEdge_Part2).l
                                                      *  cmpi.w  #$C,d1
                                                      *  blt.w   Obj01_ResetScr
                                                      *  move.b  #AniIDSonAni_Balance4,anim(a0)
                                                      *  bclr    #0,status(a0)
                                                      *  bra.w   Obj01_ResetScr
                                                      *; ---------------------------------------------------------------------------
Sonic_BalanceLeft                                     *Sonic_BalanceLeft:
                                                      *  cmpi.b  #3,tilt(a0)
                                                      *  bne.s   Sonic_Lookup
                                                      *  btst    #0,status(a0)
                                                      *  beq.s   +
                                                      *  move.b  #AniIDSonAni_Balance,anim(a0)
                                                      *  move.w  x_pos(a0),d3
                                                      *  addq.w  #6,d3
                                                      *  jsr (ChkFloorEdge_Part2).l
                                                      *  cmpi.w  #$C,d1
                                                      *  blt.w   Obj01_ResetScr
                                                      *  move.b  #AniIDSonAni_Balance2,anim(a0)
                                                      *  bra.w   Obj01_ResetScr
                                                      *  ; on left edge but facing right:
                                                      *+ move.b  #AniIDSonAni_Balance3,anim(a0)
                                                      *  move.w  x_pos(a0),d3
                                                      *  addq.w  #6,d3
                                                      *  jsr (ChkFloorEdge_Part2).l
                                                      *  cmpi.w  #$C,d1
                                                      *  blt.w   Obj01_ResetScr
                                                      *  move.b  #AniIDSonAni_Balance4,anim(a0)
                                                      *  bset    #0,status(a0)
                                                      *  bra.w   Obj01_ResetScr
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A55E:
SuperSonic_Balance2                                   *SuperSonic_Balance2:
                                                      *  cmpi.b  #3,next_tilt(a0)
                                                      *  bne.s   loc_1A56E
                                                      *
                                                      *; loc_1A566:
SuperSonic_BalanceOnObjRight                          *SuperSonic_BalanceOnObjRight:
                                                      *  bclr    #0,status(a0)
                                                      *  bra.s   loc_1A57C
                                                      *; ---------------------------------------------------------------------------
loc_1A56E                                             *loc_1A56E:
                                                      *  cmpi.b  #3,tilt(a0)
                                                      *  bne.s   Sonic_Lookup
                                                      *
                                                      *; loc_1A576:
SuperSonic_BalanceOnObjLeft                           *SuperSonic_BalanceOnObjLeft:
                                                      *  bset    #0,status(a0)
                                                      *
loc_1A57C                                             *loc_1A57C:
                                                      *  move.b  #AniIDSonAni_Balance,anim(a0)
                                                      *  bra.s   Obj01_ResetScr
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A584:
Sonic_Lookup                                          *Sonic_Lookup:
        lda   Ctrl_1_Held_Logical
        anda  #button_up_mask                         *  btst    #button_up,(Ctrl_1_Held_Logical).w  ; is up being pressed?
        beq   Sonic_Duck                              *  beq.s   Sonic_Duck          ; if not, branch
        ldd   #SonAni_LookUp                          *  move.b  #AniIDSonAni_LookUp,anim(a0)            ; use "looking up" animation
        std   anim,u
        lda   Sonic_Look_delay_counter
        adda  Vint_Main_runcount                      *  addq.w  #1,(Sonic_Look_delay_counter).w
        inca
        sta   Sonic_Look_delay_counter
        cmpa  #$78                                    *  cmpi.w  #$78,(Sonic_Look_delay_counter).w
        blo   Obj01_ResetScr_Part2                    *  blo.s   Obj01_ResetScr_Part2
        lda   #$78
        sta   Sonic_Look_delay_counter                *  move.w  #$78,(Sonic_Look_delay_counter).w
        ldd   Camera_Y_pos_bias
        cmpd  #176                                    *  cmpi.w  #$C8,(Camera_Y_pos_bias).w
        bhs   Obj01_UpdateSpeedOnGround               *  beq.s   Obj01_UpdateSpeedOnGround
        addd  #4
        std   Camera_Y_pos_bias                       *  addq.w  #2,(Camera_Y_pos_bias).w
        bra   Obj01_UpdateSpeedOnGround               *  bra.s   Obj01_UpdateSpeedOnGround
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A5B2:
Sonic_Duck                                            *Sonic_Duck:
        lda   Ctrl_1_Held_Logical
        anda  #button_down_mask                       *  btst    #button_down,(Ctrl_1_Held_Logical).w    ; is down being pressed?
        beq   Obj01_ResetScr                          *  beq.s   Obj01_ResetScr          ; if not, branch
        ldd   #SonAni_Duck                            *  move.b  #AniIDSonAni_Duck,anim(a0)          ; use "ducking" animation
        std   anim,u
        lda   Sonic_Look_delay_counter
        adda  Vint_Main_runcount                      *  addq.w  #1,(Sonic_Look_delay_counter).w
        inca
        sta   Sonic_Look_delay_counter
        cmpa  #$78                                    *  cmpi.w  #$78,(Sonic_Look_delay_counter).w
        blo   Obj01_ResetScr_Part2                    *  blo.s   Obj01_ResetScr_Part2
        lda   #$78
        sta   Sonic_Look_delay_counter                *  move.w  #$78,(Sonic_Look_delay_counter).w
        ldd   Camera_Y_pos_bias
        cmpd  #72                                     *  cmpi.w  #8,(Camera_Y_pos_bias).w
        bls   Obj01_UpdateSpeedOnGround               *  beq.s   Obj01_UpdateSpeedOnGround
        subd  #4
        std   Camera_Y_pos_bias                       *  subq.w  #2,(Camera_Y_pos_bias).w
        bra   Obj01_UpdateSpeedOnGround               *  bra.s   Obj01_UpdateSpeedOnGround
                                                      *
                                                      *; ===========================================================================
                                                      *; moves the screen back to its normal position after looking up or down
                                                      *; loc_1A5E0:
Obj01_ResetScr                                        *Obj01_ResetScr:
        lda   #0
        sta   Sonic_Look_delay_counter                *  move.w  #0,(Sonic_Look_delay_counter).w
                                                      *; loc_1A5E6:
Obj01_ResetScr_Part2                                  *Obj01_ResetScr_Part2:
        ldd   Camera_Y_pos_bias
        cmpd  #camera_Y_pos_bias_default              *  cmpi.w  #(224/2)-16,(Camera_Y_pos_bias).w   ; is screen in its default position?
        beq   Obj01_UpdateSpeedOnGround               *  beq.s   Obj01_UpdateSpeedOnGround   ; if yes, branch.
        bhs   >                                       *  bhs.s   +               ; depending on the sign of the difference,
        addd  #4                                      *  addq.w  #4,(Camera_Y_pos_bias).w    ; either add 2
        cmpd  #camera_Y_pos_bias_default
        bls   @exit
        ldd   #camera_Y_pos_bias_default ; cap value
        bra   @exit
!       subd  #4                                      *+ subq.w  #2,(Camera_Y_pos_bias).w    ; or subtract 2
        cmpd  #camera_Y_pos_bias_default
        bhs   @exit
        ldd   #camera_Y_pos_bias_default ; cap value
@exit   std   Camera_Y_pos_bias
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; updates Sonic's speed on the ground
                                                      *; ---------------------------------------------------------------------------
                                                      *; sub_1A5F8:
Obj01_UpdateSpeedOnGround                             *Obj01_UpdateSpeedOnGround:
                                                      *  tst.b   (Super_Sonic_flag).w
                                                      *  beq.w   +
                                                      *  move.w  #$C,d5
                                                      *+
        lda   Ctrl_1_Held_Logical                     *  move.b  (Ctrl_1_Held_Logical).w,d0
        anda  #button_left_mask|button_right_mask     *  andi.b  #button_left_mask|button_right_mask,d0 ; is left/right pressed?
        bne   Obj01_Traction                          *  bne.s   Obj01_Traction  ; if yes, branch
        ldd   inertia,u                               *  move.w  inertia(a0),d0
        beq   Obj01_Traction                          *  beq.s   Obj01_Traction
        bmi   Obj01_SettleLeft                        *  bmi.s   Obj01_SettleLeft
                                                      *
                                                      *; slow down when facing right and not pressing a direction
                                                      *; Obj01_SettleRight:
        subd  Sonic_acceleration_tmp                  *  sub.w   d5,d0
        bcc   >                                       *  bcc.s   +
        ldd   #0                                      *  move.w  #0,d0
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
        bra   Obj01_Traction                          *  bra.s   Obj01_Traction
                                                      *; ---------------------------------------------------------------------------
                                                      *; slow down when facing left and not pressing a direction
                                                      *; loc_1A624:
Obj01_SettleLeft                                      *Obj01_SettleLeft:
        addd  Sonic_acceleration_tmp                  *  add.w   d5,d0
        bcc   >                                       *  bcc.s   +
        ldd   #0                                      *  move.w  #0,d0
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
                                                      *
                                                      *; increase or decrease speed on the ground
                                                      *; loc_1A630:
Obj01_Traction                                        *Obj01_Traction:
        lda   angle,u                                 *  move.b  angle(a0),d0
        ;jsr  CalcSine                                *  jsr (CalcSine).l
        ;                                             *  muls.w  inertia(a0),d1
        ;                                             *  asr.l   #8,d1
        ldd   inertia,u
        ldx   Vint_Main_runcount_w
        beq   @end
@loop
        addd  inertia,u
        leax  -1,x
        bne   @loop 
@end    std   x_vel,u                                  *  move.w  d1,x_vel(a0)
        ;                                              *  muls.w  inertia(a0),d0
        ;                                              *  asr.l   #8,d0
        ;                                              *  move.w  d0,y_vel(a0)
                                                      *
                                                      *; stops Sonic from running through walls that meet the ground
                                                      *; loc_1A64E:
Obj01_CheckWallsOnGround                              *Obj01_CheckWallsOnGround:
                                                      *  move.b  angle(a0),d0
                                                      *  addi.b  #$40,d0
                                                      *  bmi.s   return_1A6BE
                                                      *  move.b  #$40,d1         ; Rotate 90 degrees clockwise
                                                      *  tst.w   inertia(a0)     ; Check inertia
                                                      *  beq.s   return_1A6BE    ; If not moving, don't do anything
                                                      *  bmi.s   +               ; If negative, branch
                                                      *  neg.w   d1              ; Otherwise, we want to rotate counterclockwise
                                                      *+
                                                      *  move.b  angle(a0),d0
                                                      *  add.b   d1,d0
                                                      *  move.w  d0,-(sp)
                                                      *  bsr.w   CalcRoomInFront
                                                      *  move.w  (sp)+,d0
                                                      *  tst.w   d1
                                                      *  bpl.s   return_1A6BE
                                                      *  asl.w   #8,d1
                                                      *  addi.b  #$20,d0
                                                      *  andi.b  #$C0,d0
                                                      *  beq.s   loc_1A6BA
                                                      *  cmpi.b  #$40,d0
                                                      *  beq.s   loc_1A6A8
                                                      *  cmpi.b  #$80,d0
                                                      *  beq.s   loc_1A6A2
                                                      *  add.w   d1,x_vel(a0)
                                                      *  bset    #5,status(a0)
                                                      *  move.w  #0,inertia(a0)
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
loc_1A6A2                                             *loc_1A6A2:
                                                      *  sub.w   d1,y_vel(a0)
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
loc_1A6A8                                             *loc_1A6A8:
                                                      *  sub.w   d1,x_vel(a0)
                                                      *  bset    #5,status(a0)
                                                      *  move.w  #0,inertia(a0)
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
loc_1A6BA                                             *loc_1A6BA:
                                                      *  add.w   d1,y_vel(a0)
                                                      *
return_1A6BE                                          *return_1A6BE:
        rts                                           *  rts
                                                      *; End of subroutine Sonic_Move
                                                      *
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A6C0:
Sonic_MoveLeft                                        *Sonic_MoveLeft:
        ldd   inertia,u                               *  move.w  inertia(a0),d0
        beq   >                                       *  beq.s   +
        bpl   Sonic_TurnLeft                          *  bpl.s   Sonic_TurnLeft ; if Sonic is already moving to the right, branch
!                                                     *+
        ldb   status,u
        bitb  #status_x_orientation
        bne   >
        orb   #status_x_orientation                   *  bset    #0,status(a0)
                                                      *  bne.s   +
        andb  #^status_pushing 
        stb   status,u                                *  bclr    #5,status(a0)
        ldd   #SonAni_Run
        std   prev_anim,u                             *  move.b  #AniIDSonAni_Run,prev_anim(a0)  ; force walking animation to restart if it's already in-progress
!                                                     *+
        ldd   Sonic_top_speed_tmp
        _negd
        std   @top_s
        ldd   inertia,u
        subd  Sonic_acceleration_tmp                  *  sub.w   d5,d0   ; add acceleration to the left
        ; moved                                       *  move.w  d6,d1
        ; moved                                       *  neg.w   d1
        cmpd  #0
@top_s  equ   *-2                                     *  cmp.w   d1,d0   ; compare new speed with top speed
        bgt   >                                       *  bgt.s   +   ; if new speed is less than the maximum, branch
        addd  Sonic_acceleration_tmp                  *  add.w   d5,d0   ; remove this frame's acceleration change
        cmpd  @top_s                                  *  cmp.w   d1,d0   ; compare speed with top speed
        ble   >                                       *  ble.s   +   ; if speed was already greater than the maximum, branch
        ldd   @top_s                                  *  move.w  d1,d0   ; limit speed on ground going left
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
        ldd   #SonAni_Walk
        std   anim,u                                  *  move.b  #AniIDSonAni_Walk,anim(a0)  ; use walking animation
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A6FA:
Sonic_TurnLeft                                        *Sonic_TurnLeft:
        subd  Sonic_deceleration_tmp                  *  sub.w   d4,d0
        bcc   >                                       *  bcc.s   +
        ldd   #-$80                                   *  move.w  #-$80,d0
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
        ldb   angle,u                                 *  move.b  angle(a0),d0
        addb  #$20                                    *  addi.b  #$20,d0
        andb  #$C0                                    *  andi.b  #$C0,d0
        bne   return_1A744                            *  bne.s   return_1A744
        ldd   inertia,u
        addd  Sonic_deceleration_tmp
        subd  Sonic_deceleration
        cmpd  #$400                                   *  cmpi.w  #$400,d0
        blt   return_1A744                            *  blt.s   return_1A744
        ldd   #SonAni_Stop
        std   anim,u                                  *  move.b  #AniIDSonAni_Stop,anim(a0)  ; use "stopping" animation
        ldb   status,u
        andb  #^status_x_orientation
        stb   status,u                                *  bclr    #0,status(a0)
        lda   #SndID_Skidding                         *  move.w  #SndID_Skidding,d0
        sta   Smps.SFXToPlay                          *  jsr (PlaySound).l
        lda   air_left,u                              *  cmpi.b  #$C,air_left(a0)
        cmpa  #$C
        blo   return_1A744                            *  blo.s   return_1A744    ; if he's drowning, branch to not make dust
        ;ldx   #Sonic_Dust
        ;lda   #6
        ;sta   routine,x                               *  move.b  #6,(Sonic_Dust+routine).w
        ;ldd   #Imgxxx
        ;std   image_set,x                            *  move.b  #$15,(Sonic_Dust+mapping_frame).w
                                                      *
return_1A744                                          *return_1A744:
        rts                                           *  rts
                                                      *; End of subroutine Sonic_MoveLeft
                                                      *
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A746:
Sonic_MoveRight                                       *Sonic_MoveRight:
        ldd   inertia,u                               *  move.w  inertia(a0),d0
        bmi   Sonic_TurnRight                         *  bmi.s   Sonic_TurnRight ; if Sonic is already moving to the left, branch
        ldb   status,u
        bitb  #status_x_orientation
        beq   >
        andb  #^(status_x_orientation|status_pushing)  *  bclr    #0,status(a0)
                                                      *  beq.s   +
        stb   status,u                                *  bclr    #5,status(a0)
        ldd   #SonAni_Run
        std   prev_anim,u                             *  move.b  #AniIDSonAni_Run,prev_anim(a0)  ; force walking animation to restart if it's already in-progress
!                                                     *+
        ldd   inertia,u
        addd  Sonic_acceleration_tmp                  *  add.w   d5,d0   ; add acceleration to the right
        cmpd  Sonic_top_speed_tmp                     *  cmp.w   d6,d0   ; compare new speed with top speed
        blt   >                                       *  blt.s   +   ; if new speed is less than the maximum, branch
        subd  Sonic_acceleration_tmp                  *  sub.w   d5,d0   ; remove this frame's acceleration change
        cmpd  Sonic_top_speed_tmp                     *  cmp.w   d6,d0   ; compare speed with top speed
        bge   >                                       *  bge.s   +   ; if speed was already greater than the maximum, branch
        ldd   Sonic_top_speed_tmp                     *  move.w  d6,d0   ; limit speed on ground going right
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
        ldd   #SonAni_Walk
        std   anim,u                                  *  move.b  #AniIDSonAni_Walk,anim(a0)  ; use walking animation
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A77A:
Sonic_TurnRight                                       *Sonic_TurnRight:
        addd  Sonic_deceleration_tmp                  *  add.w   d4,d0
        bcc   >                                       *  bcc.s   +
        ldd   #$80                                    *  move.w  #$80,d0
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
        ldb   angle,u                                 *  move.b  angle(a0),d0
        addb  #$20                                    *  addi.b  #$20,d0
        andb  #$C0                                    *  andi.b  #$C0,d0
        bne   return_1A7C4                            *  bne.s   return_1A7C4
        ldd   inertia,u
        subd  Sonic_deceleration_tmp
        addd  Sonic_deceleration
        cmpd  #-$400                                  *  cmpi.w  #-$400,d0
        bgt   return_1A7C4                            *  bgt.s   return_1A7C4
        ldd   #SonAni_Stop
        std   anim,u                                  *  move.b  #AniIDSonAni_Stop,anim(a0)  ; use "stopping" animation
        ldb   status,u
        orb   #status_x_orientation
        stb   status,u                                *  bset    #0,status(a0)
        lda   #SndID_Skidding                         *  move.w  #SndID_Skidding,d0
        sta   Smps.SFXToPlay                          *  jsr (PlaySound).l
        lda   air_left,u                              *  cmpi.b  #$C,air_left(a0)
        cmpa  #$C
        blo   return_1A7C4                            *  blo.s   return_1A7C4    ; if he's drowning, branch to not make dust
        ;ldx   #Sonic_Dust
        ;lda   #6
        ;sta   routine,x                               *  move.b  #6,(Sonic_Dust+routine).w
        ;ldd   #Imgxxx
        ;std   image_set,x                            *  move.b  #$15,(Sonic_Dust+mapping_frame).w
                                                      *
return_1A7C4                                          *return_1A7C4:
        rts                                           *  rts
                                                      *; End of subroutine Sonic_MoveRight
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to change Sonic's speed as he rolls
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A7C6:
Sonic_RollSpeed                                       *Sonic_RollSpeed:
        ldd   Sonic_top_speed                         *  move.w  (Sonic_top_speed).w,d6
        _asld                                         *  asl.w   #1,d6
        std   Sonic_top_speed_tmp                     
        lda   Vint_Main_runcount
        bne   >
        lda   #1
!       ldb   Sonic_acceleration+1                    *  move.w  (Sonic_acceleration).w,d5
        mul
        _asrd                                         *  asr.w   #1,d5   ; natural roll deceleration = 1/2 normal acceleration
        std   Sonic_acceleration_tmp                  
        lda   Vint_Main_runcount
        bne   >
        lda   #1
!       ldb   #$20
        mul
        std   Sonic_deceleration_tmp                  *  move.w  #$20,d4 ; controlled roll deceleration... interestingly,
                                                      *          ; this should be Sonic_deceleration/4 according to Tails_RollSpeed,
                                                      *          ; which means Sonic is much better than Tails at slowing down his rolling when he's underwater
                                                      *    if status_sec_isSliding = 7
        tst   status_secondary,u                      *  tst.b   status_secondary(a0)
        bmi   Obj01_Roll_ResetScr                     *  bmi.w   Obj01_Roll_ResetScr
        ;                                              *    else
        ;                                              *  btst    #status_sec_isSliding,status_secondary(a0)
        ;                                              *  bne.w   Obj01_Roll_ResetScr
        ;                                              *    endif
        tst   move_lock,u                             *  tst.w   move_lock(a0)
        bne   Sonic_ApplyRollSpeed                    *  bne.s   Sonic_ApplyRollSpeed
        lda   Ctrl_1_Held_Logical
        anda  #button_left_mask                       *  btst    #button_left,(Ctrl_1_Held_Logical).w    ; is left being pressed?
        beq   >                                       *  beq.s   +               ; if not, branch
        jsr   Sonic_RollLeft                          *  bsr.w   Sonic_RollLeft
!                                                     *+
        lda   Ctrl_1_Held_Logical                     
        anda  #button_right_mask                      *  btst    #button_right,(Ctrl_1_Held_Logical).w   ; is right being pressed?
        beq   Sonic_ApplyRollSpeed                    *  beq.s   Sonic_ApplyRollSpeed        ; if not, branch
        jsr   Sonic_RollRight                         *  bsr.w   Sonic_RollRight
                                                      *
                                                      *; loc_1A7FC:
Sonic_ApplyRollSpeed                                  *Sonic_ApplyRollSpeed:
        ldd   inertia,u                               *  move.w  inertia(a0),d0
        beq   Sonic_CheckRollStop                     *  beq.s   Sonic_CheckRollStop
        bmi   Sonic_ApplyRollSpeedLeft                *  bmi.s   Sonic_ApplyRollSpeedLeft
                                                      *
Sonic_ApplyRollSpeedRight                             *; Sonic_ApplyRollSpeedRight:
        subd  Sonic_acceleration_tmp                  *  sub.w   d5,d0
        bcc   >                                       *  bcc.s   +
        ldd   #0                                      *  move.w  #0,d0
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
        bra   Sonic_CheckRollStop                     *  bra.s   Sonic_CheckRollStop
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A812:
Sonic_ApplyRollSpeedLeft                              *Sonic_ApplyRollSpeedLeft:
        addd  Sonic_acceleration_tmp                  *  add.w   d5,d0
        bcc   >                                       *  bcc.s   +
        ldd   #0                                      *  move.w  #0,d0
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
                                                      *
                                                      *; loc_1A81E:
Sonic_CheckRollStop                                   *Sonic_CheckRollStop:
        ;                                             *  tst.w   inertia(a0)
        bne   Obj01_Roll_ResetScr                     *  bne.s   Obj01_Roll_ResetScr
        tst   pinball_mode,u                          *  tst.b   pinball_mode(a0) ; note: the spindash flag has a different meaning when Sonic's already rolling -- it's used to mean he's not allowed to stop rolling
        bne   Sonic_KeepRolling                       *  bne.s   Sonic_KeepRolling
        lda   status,u
        anda  #^status_jumporroll                     *  bclr    #2,status(a0)
        sta   status,u
        ldd   #$1309                                  *  move.b  #$13,y_radius(a0)
        std   y_radius,u                              *  move.b  #9,x_radius(a0)
        ldd   #SonAni_Wait 
        std   anim,u                                  *  move.b  #AniIDSonAni_Wait,anim(a0)
        ldd   y_pos,u
        subd  #5
        std   y_pos,u                                 *  subq.w  #5,y_pos(a0)
        bra   Obj01_Roll_ResetScr                     *  bra.s   Obj01_Roll_ResetScr
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; magically gives Sonic an extra push if he's going to stop rolling where it's not allowed
                                                      *; (such as in an S-curve in HTZ or a stopper chamber in CNZ)
                                                      *; loc_1A848:
Sonic_KeepRolling                                     *Sonic_KeepRolling:
        ldd   #$400
        std   inertia,u                               *  move.w  #$400,inertia(a0)
        lda   status,u                                *  btst    #0,status(a0)
        anda  #status_x_orientation
        beq   Obj01_Roll_ResetScr                     *  beq.s   Obj01_Roll_ResetScr
        ldd   inertia,u
        _negd                                         *  neg.w   inertia(a0)
        std   inertia,u                               *
                                                      *; resets the screen to normal while rolling, like Obj01_ResetScr
                                                      *; loc_1A85A:
Obj01_Roll_ResetScr                                   *Obj01_Roll_ResetScr:
        ldd   Camera_Y_pos_bias
        cmpd  #camera_Y_pos_bias_default              *  cmpi.w  #(224/2)-16,(Camera_Y_pos_bias).w   ; is screen in its default position?
        beq   Sonic_SetRollSpeeds                     *  beq.s   Sonic_SetRollSpeeds    ; if yes, branch
        bhs   >                                       *  bhs.s   +               ; depending on the sign of the difference,
        addd  #4                                      *  addq.w  #4,(Camera_Y_pos_bias).w    ; either add 2
!       subd  #2                                      *+ subq.w  #2,(Camera_Y_pos_bias).w    ; or subtract 2
        std   Camera_Y_pos_bias
                                                      *

                                                      *; loc_1A86C:
Sonic_SetRollSpeeds                                   *Sonic_SetRollSpeeds:
        lda   angle,u                                 *  move.b  angle(a0),d0
                                                      *  jsr (CalcSine).l
                                                      *  muls.w  inertia(a0),d0
                                                      *  asr.l   #8,d0
                                                      *  move.w  d0,y_vel(a0)    ; set y velocity based on $14 and angle
        ldd   inertia,u                               *  muls.w  inertia(a0),d1
                                                      *  asr.l   #8,d1
        cmpd  #$1000                                  *  cmpi.w  #$1000,d1
        ble   >                                       *  ble.s   +
        ldd   #$1000                                  *  move.w  #$1000,d1   ; limit Sonic's speed rolling right
!                                                     *+
        cmpd  #-$1000                                 *  cmpi.w  #-$1000,d1
        bge   >                                       *  bge.s   +
        ldd   #-$1000                                 *  move.w  #-$1000,d1  ; limit Sonic's speed rolling left
!                                                     *+
        ldx   Vint_Main_runcount_w
        beq   @end
@loop
        addd  inertia,u
        leax  -1,x
        bne   @loop 
@end    std   x_vel,u                                 *  move.w  d1,x_vel(a0)    ; set x velocity based on $14 and angle
        jmp   Obj01_CheckWallsOnGround                *  bra.w   Obj01_CheckWallsOnGround
                                                      *; End of function Sonic_RollSpeed
                                                      *
                                                      *

                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *
                                                      *; loc_1A8A2:
Sonic_RollLeft                                        *Sonic_RollLeft:
        ldd   inertia,u                               *  move.w  inertia(a0),d0
        beq   >                                       *  beq.s   +
        bpl   Sonic_BrakeRollingRight                 *  bpl.s   Sonic_BrakeRollingRight
!                                                     *+
        lda   status,u
        ora   #status_x_orientation                   *  bset    #0,status(a0)
        sta   status,u
        ldd   #SonAni_Roll
        std   anim,u                                  *  move.b  #AniIDSonAni_Roll,anim(a0)  ; use "rolling" animation
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A8B8:
Sonic_BrakeRollingRight                               *Sonic_BrakeRollingRight:
        subd  Sonic_deceleration_tmp                  *  sub.w   d4,d0   ; reduce rightward rolling speed
        bcc   >                                       *  bcc.s   +
        ldd   #-$80                                   *  move.w  #-$80,d0
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
        rts                                           *  rts
                                                      *; End of function Sonic_RollLeft
                                                      *
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *
                                                      *; loc_1A8C6:
Sonic_RollRight                                       *Sonic_RollRight:
        ldd   inertia,u                               *  move.w  inertia(a0),d0
        bmi   Sonic_BrakeRollingLeft                  *  bmi.s   Sonic_BrakeRollingLeft
        lda   status,u
        anda  #^status_x_orientation                  *  bclr    #0,status(a0)
        sta   status,u
        ldd   #SonAni_Roll                            *  move.b  #AniIDSonAni_Roll,anim(a0)  ; use "rolling" animation
        std   anim,u
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A8DA:
Sonic_BrakeRollingLeft                                *Sonic_BrakeRollingLeft:
        addd  Sonic_deceleration_tmp                  *  add.w   d4,d0   ; reduce leftward rolling speed
        bcc   >                                       *  bcc.s   +
        ldd   #$80                                    *  move.w  #$80,d0
!                                                     *+
        std   inertia,u                               *  move.w  d0,inertia(a0)
        rts                                           *  rts
                                                      *; End of subroutine Sonic_RollRight
                                                      *
                                                      *

                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine for moving Sonic left or right when he's in the air
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A8E8:
Sonic_ChgJumpDir                                      *Sonic_ChgJumpDir:
        ldd   Sonic_top_speed
        std   Sonic_top_speed_tmp                     *  move.w  (Sonic_top_speed).w,d6
        lda   Vint_Main_runcount
        bne   >
        lda   #1
!       ldb   Sonic_acceleration+1                    *  move.w  (Sonic_acceleration).w,d5
        mul
        _asld                                         *  asl.w   #1,d5
        std   Sonic_acceleration_tmp                  
        lda   status,u
        anda  #status_jumpingafterrolling             *  btst    #4,status(a0)       ; did Sonic jump from rolling?
        bne   Obj01_Jump_ResetScr                     *  bne.s   Obj01_Jump_ResetScr ; if yes, branch to skip midair control
        ldx   x_vel,u                                 *  move.w  x_vel(a0),d0
        lda   Ctrl_1_Held_Logical
        anda  #button_left_mask                       *  btst    #button_left,(Ctrl_1_Held_Logical).w
        beq   >                                       *  beq.s   +   ; if not holding left, branch
                                                      *
        lda   status,u
        ora   #status_x_orientation                   
        sta   status,u                                *  bset    #0,status(a0)
        ldd   Sonic_acceleration_tmp
        _negd
        leax  d,x                                     *  sub.w   d5,d0   ; add acceleration to the left
        ldd   Sonic_top_speed_tmp                     *  move.w  d6,d1
        _negd                                         *  neg.w   d1
        std   @d1
        cmpx  #0                                      *  cmp.w   d1,d0   ; compare new speed with top speed
@d1     equ   *-2
        bgt   >                                       *  bgt.s   +   ; if new speed is less than the maximum, branch
        ldx   @d1                                     *  move.w  d1,d0   ; limit speed in air going left, even if Sonic was already going faster (speed limit/cap)
!                                                     *+
        lda   Ctrl_1_Held_Logical
        anda  #button_right_mask                      *  btst    #button_right,(Ctrl_1_Held_Logical).w
        beq   >                                       *  beq.s   +   ; if not holding right, branch
                                                      *
        lda   status,u
        anda  #^status_x_orientation                   
        sta   status,u                                *  bclr    #0,status(a0)
        ldd   Sonic_acceleration_tmp
        leax  d,x                                     *  add.w   d5,d0   ; accelerate right in the air
        cmpx  Sonic_top_speed_tmp                     *  cmp.w   d6,d0   ; compare new speed with top speed
        blt   >                                       *  blt.s   +   ; if new speed is less than the maximum, branch
        ldx   Sonic_top_speed_tmp                     *  move.w  d6,d0   ; limit speed in air going right, even if Sonic was already going faster (speed limit/cap)
                                                      *; Obj01_JumpMove:
!       stx   x_vel,u                                 *+ move.w  d0,x_vel(a0)
                                                      *
                                                      *; loc_1A932: Obj01_ResetScr2:
Obj01_Jump_ResetScr                                   *Obj01_Jump_ResetScr:
        ldd   Camera_Y_pos_bias
        cmpd  #camera_Y_pos_bias_default              *  cmpi.w  #(224/2)-16,(Camera_Y_pos_bias).w   ; is screen in its default position?
        beq   Sonic_JumpPeakDecelerate                *  beq.s   Sonic_JumpPeakDecelerate    ; if yes, branch
        bhs   >                                       *  bhs.s   +               ; depending on the sign of the difference,
        addd  #4                                      *  addq.w  #4,(Camera_Y_pos_bias).w    ; either add 2
!       subd  #2                                      *+ subq.w  #2,(Camera_Y_pos_bias).w    ; or subtract 2
        std   Camera_Y_pos_bias

                                                      *
                                                      *; loc_1A944:
Sonic_JumpPeakDecelerate                              *Sonic_JumpPeakDecelerate:
        ldd   y_vel,u
        cmpd  #-$400                                  *  cmpi.w  #-$400,y_vel(a0)    ; is Sonic moving faster than -$400 upwards?
        blo   return_1A972                            *  blo.s   return_1A972        ; if yes, return
        ldd   x_vel,u                                 *  move.w  x_vel(a0),d0
        ;                                             *  move.w  d0,d1
        _asrd
        _asrd
        _asrd
        _asrd
        _asrd                                         *  asr.w   #5,d1       ; d1 = x_velocity / 32
        std   @d1
        beq   return_1A972                            *  beq.s   return_1A972    ; return if d1 is 0
        bmi   Sonic_JumpPeakDecelerateLeft            *  bmi.s   Sonic_JumpPeakDecelerateLeft    ; branch if moving left
                                                      *
                                                      *; Sonic_JumpPeakDecelerateRight:
        ldd   x_vel,u
        subd  #0                                      *  sub.w   d1,d0   ; reduce x velocity by d1
@d1     equ   *-2
        bcc   >                                       *  bcc.s   +
        ldd   #0                                      *  move.w  #0,d0
!                                                     *+
        std   x_vel,u                                 *  move.w  d0,x_vel(a0)
        rts                                           *  rts
                                                      *;-------------------------------------------------------------
                                                      *; loc_1A966:
Sonic_JumpPeakDecelerateLeft                          *Sonic_JumpPeakDecelerateLeft:
        ldd   x_vel,u
        subd  @d1                                     *  sub.w   d1,d0   ; reduce x velocity by d1
        bcs   >                                       *  bcs.s   +
        ldd   #0                                      *  move.w  #0,d0
!                                                     *+
        std   x_vel,u                                 *  move.w  d0,x_vel(a0)
                                                      *
return_1A972                                          *return_1A972:
        rts                                           *  rts
                                                      *; End of subroutine Sonic_ChgJumpDir
                                                      *; ===========================================================================

                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to prevent Sonic from leaving the boundaries of a level
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A974:
Sonic_LevelBound                                      *Sonic_LevelBound:
                                                      *  move.l  x_pos(a0),d1
                                                      *  move.w  x_vel(a0),d0
                                                      *  ext.l   d0
                                                      *  asl.l   #8,d0
                                                      *  add.l   d0,d1
                                                      *  swap    d1
                                                      *  move.w  (Camera_Min_X_pos).w,d0
                                                      *  addi.w  #$10,d0
                                                      *  cmp.w   d1,d0           ; has Sonic touched the left boundary?
                                                      *  bhi.s   Sonic_Boundary_Sides    ; if yes, branch
                                                      *  move.w  (Camera_Max_X_pos).w,d0
                                                      *  addi.w  #320-24,d0      ; screen width - Sonic's width_pixels
                                                      *  tst.b   (Current_Boss_ID).w
                                                      *  bne.s   +
                                                      *  addi.w  #$40,d0
                                                      *+
                                                      *  cmp.w   d1,d0           ; has Sonic touched the right boundary?
                                                      *  bls.s   Sonic_Boundary_Sides    ; if yes, branch
                                                      *
                                                      *; loc_1A9A6:
Sonic_Boundary_CheckBottom                            *Sonic_Boundary_CheckBottom:
                                                      *  move.w  (Camera_Max_Y_pos_now).w,d0
                                                      *  addi.w  #$E0,d0
                                                      *  cmp.w   y_pos(a0),d0        ; has Sonic touched the bottom boundary?
                                                      *  blt.s   Sonic_Boundary_Bottom   ; if yes, branch
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
Sonic_Boundary_Bottom                                 *Sonic_Boundary_Bottom: ;;
        jmp   KillCharacter                           *  jmpto   (KillCharacter).l, JmpTo_KillCharacter
                                                      *; ===========================================================================
                                                      *
                                                      *; loc_1A9BA:
Sonic_Boundary_Sides                                  *Sonic_Boundary_Sides:
                                                      *  move.w  d0,x_pos(a0)
                                                      *  move.w  #0,2+x_pos(a0) ; subpixel x
                                                      *  move.w  #0,x_vel(a0)
                                                      *  move.w  #0,inertia(a0)
        bra   Sonic_Boundary_CheckBottom              *  bra.s   Sonic_Boundary_CheckBottom
                                                      *; ===========================================================================
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine allowing Sonic to start rolling when he's moving
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1A9D2:
Sonic_Roll                                            *Sonic_Roll:
                                                      *    if status_sec_isSliding = 7
        tst   status_secondary,u                      *  tst.b   status_secondary(a0)
        bmi   Obj01_NoRoll                            *  bmi.s   Obj01_NoRoll
                                                      *    else
                                                      *  btst    #status_sec_isSliding,status_secondary(a0)
                                                      *  bne.s   Obj01_NoRoll
                                                      *    endif
        ldd   inertia,u                               *  mvabs.w inertia(a0),d0
        bpl   >
        _negd
!                                              
        cmpd  #$80                                    *  cmpi.w  #$80,d0     ; is Sonic moving at $80 speed or faster?
        blo   Obj01_NoRoll                            *  blo.s   Obj01_NoRoll    ; if not, branch
        lda   Ctrl_1_Held_Logical                     *  move.b  (Ctrl_1_Held_Logical).w,d0
        bita  #button_left_mask|button_right_mask     *  andi.b  #button_left_mask|button_right_mask,d0 ; is left/right being pressed?
        bne   Obj01_NoRoll                            *  bne.s   Obj01_NoRoll    ; if yes, branch
        anda  #button_down_mask                       *  btst    #button_down,(Ctrl_1_Held_Logical).w ; is down being pressed?
        bne   Obj01_ChkRoll                           *  bne.s   Obj01_ChkRoll           ; if yes, branch
                                                      *; return_1A9F8:
Obj01_NoRoll                                          *Obj01_NoRoll:
        rts                                           *  rts
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1A9FA:
Obj01_ChkRoll                                         *Obj01_ChkRoll:
        lda   status,u                           
        bita  #status_jumporroll                      *  btst    #2,status(a0)   ; is Sonic already rolling?
        beq   Obj01_DoRoll                            *  beq.s   Obj01_DoRoll    ; if not, branch
        rts                                           *  rts
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1AA04:
Obj01_DoRoll                                          *Obj01_DoRoll:
        ora   #status_jumporroll                       
        sta   status,u                                *  bset    #2,status(a0)
        ldd   #$0E07                                  *  move.b  #$E,y_radius(a0)
        std   y_radius,u ; and x_radius               *  move.b  #7,x_radius(a0)
        ldd   #SonAni_Roll                            *  move.b  #AniIDSonAni_Roll,anim(a0)  ; use "rolling" animation
        std   anim,u                                   
        ldd   y_pos,u                                    
        addd  #5                                       
        std   y_pos,u                                 *  addq.w  #5,y_pos(a0)
        lda   #SndID_Roll                             *  move.w  #SndID_Roll,d0
        sta   Smps.SFXToPlay                          *  jsr (PlaySound).l   ; play rolling sound
        ldd   inertia,u                               *  tst.w   inertia(a0)
        bne   return_1AA36                            *  bne.s   return_1AA36
        ldd   #$200                                   *  move.w  #$200,inertia(a0)
        std   inertia,u                                
                                                      *
return_1AA36                                          *return_1AA36:
        rts                                           *  rts
                                                      *; End of function Sonic_Roll
                                                      *
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine allowing Sonic to jump
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AA38:
Sonic_Jump                                            *Sonic_Jump:
        lda   Ctrl_1_Press_Logical                    *  move.b  (Ctrl_1_Press_Logical).w,d0
        anda  #button_B_mask|button_A_mask            *  andi.b  #button_B_mask|button_C_mask|button_A_mask,d0 ; is A, B or C pressed?
        beq   return_1AAE6                            *  beq.w   return_1AAE6    ; if not, return
        ;lda   #0                                      *  moveq   #0,d0
        ;ldb   angle,u                                 *  move.b  angle(a0),d0
        ;addb  #$80                                    *  addi.b  #$80,d0
        ;bsr   CalcRoomOverHead                        *  bsr.w   CalcRoomOverHead
        ;cmpd  #6                                      *  cmpi.w  #6,d1           ; does Sonic have enough room to jump?
        ;blt   return_1AAE6                            *  blt.w   return_1AAE6        ; if not, branch
        ldx   #$680                                   *  move.w  #$680,d2
        ; unimplemented                               *  tst.b   (Super_Sonic_flag).w
        ;                                             *  beq.s   +
        ;                                              *  move.w  #$800,d2    ; set higher jump speed if super
                                                      *+
        lda   status,u                          *  btst    #6,status(a0)   ; Test if underwater
        bita  #status_underwater                      
        beq   >                                       *  beq.s   +       ; if not, branch
        ldx   #$380                                   *  move.w  #$380,d2    ; set lower jump speed if under
!                                                     *+
        ;lda   #0                                      *  moveq   #0,d0
        ;ldb   angle,u                                 *  move.b  angle(a0),d0
        ;subb  #$40                                    *  subi.b  #$40,d0
        ;jsr   CalcSine                                *  jsr (CalcSine).l
        ;                                              *  muls.w  d2,d1
        ;                                              *  asr.l   #8,d1
        ;                                             *  add.w   d1,x_vel(a0)    ; make Sonic jump (in X... this adds nothing on level ground)
        ;                                              *  muls.w  d2,d0
        ;                                              *  asr.l   #8,d0
        ldd   inertia,u
        std   x_vel,u

        tfr   x,d
        _negd
        addd  y_vel,u
        std   y_vel,u                                 *  add.w   d0,y_vel(a0)    ; make Sonic jump (in Y)
        ldb   status,u
        orb   #status_inair                           *  bset    #1,status(a0)
        andb  #^status_pushing 
        stb   status,u                                *  bclr    #5,status(a0)
        leas  2,s ; skip end of caller routine        *  addq.l  #4,sp
        lda   #1
        sta   jumping,u                               *  move.b  #1,jumping(a0)
        clr   stick_to_convex,u                       *  clr.b   stick_to_convex(a0)
        lda   #SndID_Jump                             *  move.w  #SndID_Jump,d0
        sta   Smps.SFXToPlay                          *  jsr (PlaySound).l   ; play jumping sound
        ldd   #$1309                                  *  move.b  #$13,y_radius(a0)
        std   y_radius,u ; and x_radius               *  move.b  #9,x_radius(a0)
        lda   status,u
        bita  #status_jumporroll                      *  btst    #2,status(a0)
        bne   Sonic_RollJump                          *  bne.s   Sonic_RollJump
        ldd   #$0E07                                  *  move.b  #$E,y_radius(a0)
        std   y_radius,u ; and x_radius               *  move.b  #7,x_radius(a0)
        ldd   #SonAni_Roll                            *  move.b  #AniIDSonAni_Roll,anim(a0)  ; use "jumping" animation
        std   anim,u
        lda   status,u
        ora   #status_jumporroll
        sta   status,u                                *  bset    #2,status(a0)
        ldd   y_pos,u 
        subd  #5
        std   y_pos,u                                 *  addq.w  #5,y_pos(a0)
                                                      *
return_1AAE6                                          *return_1AAE6:
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1AAE8:
Sonic_RollJump                                        *Sonic_RollJump:
        ora   #status_jumpingafterrolling             *  bset    #4,status(a0)   ; set the rolling+jumping flag
        sta   status,u                           
        rts                                           *  rts
                                                      *; End of function Sonic_Jump
                                                      *
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine letting Sonic control the height of the jump
                                                      *; when the jump button is released
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; ===========================================================================
                                                      *; loc_1AAF0:
Sonic_JumpHeight                                      *Sonic_JumpHeight:
        tst   jumping,u                               *  tst.b   jumping(a0) ; is Sonic jumping?
        beq   Sonic_UpVelCap                          *  beq.s   Sonic_UpVelCap  ; if not, branch
                                                      *
        ldx   #-$400                                  *  move.w  #-$400,d1
        lda   status,u                          *  btst    #6,status(a0)   ; is Sonic underwater?
        bita  #status_underwater                      
        beq   >                                       *  beq.s   +       ; if not, branch
        ldx   #-$200                                  *  move.w  #-$200,d1
!                                                     *+
                                                       
        cmpx  y_vel,u                                 *  cmp.w   y_vel(a0),d1    ; is Sonic going up faster than d1?
        ble   @a                                      *  ble.s   +       ; if not, branch
        ldb   Ctrl_1_Held_Logical                     *  move.b  (Ctrl_1_Held_Logical).w,d0
        bitb  #button_B_mask|button_A_mask            *  andi.b  #button_B_mask|button_C_mask|button_A_mask,d0 ; is a jump button pressed?
        bne   @a                                      *  bne.s   +       ; if yes, branch
        stx   y_vel,u                                 *  move.w  d1,y_vel(a0)    ; immediately reduce Sonic's upward speed to d1
@a                                                    *+
                                                       
        ;ldd   y_vel,u                                *  tst.b   y_vel(a0)       ; is Sonic exactly at the height of his jump?
        ;beq   Sonic_CheckGoSuper                     *  beq.s   Sonic_CheckGoSuper  ; if yes, test for turning into Super Sonic
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1AB22:
Sonic_UpVelCap                                        *Sonic_UpVelCap:
        tst   pinball_mode,u                          *  tst.b   pinball_mode(a0)    ; is Sonic charging a spindash or in a rolling-only area?
        bne   return_1AB36                            *  bne.s   return_1AB36        ; if yes, return
        ldx   #-$FC0                                   
        cmpx  y_vel,u                                 *  cmpi.w  #-$FC0,y_vel(a0)    ; is Sonic moving up really fast?
        bge   return_1AB36                            *  bge.s   return_1AB36        ; if not, return
        stx   y_vel,u                                 *  move.w  #-$FC0,y_vel(a0)    ; cap upward speed
                                                      *
return_1AB36                                          *return_1AB36:
        rts                                           *  rts
                                                      *; End of subroutine Sonic_JumpHeight
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine called at the peak of a jump that transforms Sonic into Super Sonic
                                                      *; if he has enough rings and emeralds
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AB38: test_set_SS:
Sonic_CheckGoSuper                                    *Sonic_CheckGoSuper:
                                                      *  tst.b   (Super_Sonic_flag).w    ; is Sonic already Super?
                                                      *  bne.s   return_1ABA4        ; if yes, branch
                                                      *  cmpi.b  #7,(Emerald_count).w    ; does Sonic have exactly 7 emeralds?
                                                      *  bne.s   return_1ABA4        ; if not, branch
                                                      *  cmpi.w  #50,(Ring_count).w  ; does Sonic have at least 50 rings?
                                                      *  blo.s   return_1ABA4        ; if not, branch
                                                      *    if gameRevision=2
                                                      *  ; fixes a bug where the player can get stuck if transforming at the end of a level
                                                      *  tst.b   (Update_HUD_timer).w    ; has Sonic reached the end of the act?
                                                      *  beq.s   return_1ABA4        ; if yes, branch
                                                      *    endif
                                                      *
                                                      *  move.b  #1,(Super_Sonic_palette).w
                                                      *  move.b  #$F,(Palette_timer).w
                                                      *  move.b  #1,(Super_Sonic_flag).w
                                                      *  move.b  #$81,obj_control(a0)
                                                      *  move.b  #AniIDSupSonAni_Transform,anim(a0)          ; use transformation animation
                                                      *  move.b  #ObjID_SuperSonicStars,(SuperSonicStars+id).w ; load Obj7E (super sonic stars object) at $FFFFD040
                                                      *  move.w  #$A00,(Sonic_top_speed).w
                                                      *  move.w  #$30,(Sonic_acceleration).w
                                                      *  move.w  #$100,(Sonic_deceleration).w
                                                      *  move.w  #0,invincibility_time(a0)
                                                      *  bset    #status_sec_isInvincible,status_secondary(a0)   ; make Sonic invincible
                                                      *  move.w  #SndID_SuperTransform,d0
                                                      *  jsr (PlaySound).l   ; Play transformation sound effect.
                                                      *  move.w  #MusID_SuperSonic,d0
                                                      *  jmp (PlayMusic).l   ; load the Super Sonic song and return
                                                      *
                                                      *; ---------------------------------------------------------------------------
return_1ABA4                                          *return_1ABA4:
        ;rts                                           *  rts
                                                      *; End of subroutine Sonic_CheckGoSuper
                                                      *
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine doing the extra logic for Super Sonic
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1ABA6:
Sonic_Super                                           *Sonic_Super:
                                                      *  tst.b   (Super_Sonic_flag).w    ; Ignore all this code if not Super Sonic
                                                      *  beq.w   return_1AC3C
                                                      *  tst.b   (Update_HUD_timer).w
                                                      *  beq.s   Sonic_RevertToNormal ; ?
                                                      *  subq.w  #1,(Super_Sonic_frame_count).w
                                                      *  bpl.w   return_1AC3C
                                                      *  move.w  #60,(Super_Sonic_frame_count).w ; Reset frame counter to 60
                                                      *  tst.w   (Ring_count).w
                                                      *  beq.s   Sonic_RevertToNormal
                                                      *  ori.b   #1,(Update_HUD_rings).w
                                                      *  cmpi.w  #1,(Ring_count).w
                                                      *  beq.s   +
                                                      *  cmpi.w  #10,(Ring_count).w
                                                      *  beq.s   +
                                                      *  cmpi.w  #100,(Ring_count).w
                                                      *  bne.s   ++
                                                      *+
                                                      *  ori.b   #$80,(Update_HUD_rings).w
                                                      *+
                                                      *  subq.w  #1,(Ring_count).w
                                                      *  bne.s   return_1AC3C
                                                      *; loc_1ABF2:
                                                      *Sonic_RevertToNormal:
                                                      *  move.b  #2,(Super_Sonic_palette).w  ; Remove rotating palette
                                                      *  move.w  #$28,(Palette_frame).w
                                                      *  move.b  #0,(Super_Sonic_flag).w
                                                      *  move.b  #AniIDSonAni_Run,prev_anim(a0)  ; Force Sonic's animation to restart
                                                      *  move.w  #1,invincibility_time(a0)   ; Remove invincibility
                                                      *  move.w  #$600,(Sonic_top_speed).w
                                                      *  move.w  #$C,(Sonic_acceleration).w
                                                      *  move.w  #$80,(Sonic_deceleration).w
        ;lda   status,u                          *  btst    #6,status(a0)   ; Check if underwater, return if not
        ;bita  #status_underwater                       
        ;beq   return_1AC3C                            *  beq.s   +       ; if not, branch
        ;ldd   #-$200                                  *  beq.s   return_1AC3C
@a                                                    *+
                                                       
                                                      *  move.w  #$300,(Sonic_top_speed).w
                                                      *  move.w  #6,(Sonic_acceleration).w
                                                      *  move.w  #$40,(Sonic_deceleration).w
                                                      *
return_1AC3C                                          *return_1AC3C:
        ;rts                                           *  rts
                                                      *; End of subroutine Sonic_Super
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to check for starting to charge a spindash
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AC3E:
Sonic_CheckSpindash                                   *Sonic_CheckSpindash:
        tst   spindash_flag,u                         *  tst.b   spindash_flag(a0)
        bne   Sonic_UpdateSpindash                    *  bne.s   Sonic_UpdateSpindash
        ldd   anim,u
        cmpd  #SonAni_Duck                            *  cmpi.b  #AniIDSonAni_Duck,anim(a0)
        bne   return_1AC8C                            *  bne.s   return_1AC8C
        lda   Ctrl_1_Press_Logical                    *  move.b  (Ctrl_1_Press_Logical).w,d0
        anda  #button_B_mask|button_A_mask            *  andi.b  #button_B_mask|button_C_mask|button_A_mask,d0
        beq   return_1AC8C                            *  beq.w   return_1AC8C
        ldd   #SonAni_Spindash                        *  move.b  #AniIDSonAni_Spindash,anim(a0)
        std   anim,u                                  
        lda   #SndID_SpindashRev                      *  move.w  #SndID_SpindashRev,d0
        sta   Smps.SFXToPlay                          *  jsr (PlaySound).l
        leas  2,s                                     *  addq.l  #4,sp
        lda   #1
        sta   spindash_flag,u                         *  move.b  #1,spindash_flag(a0)
        ldd   #0
        std   spindash_counter,u                      *  move.w  #0,spindash_counter(a0)
        lda   air_left,u
        cmpa  #$C                                     *  cmpi.b  #$C,air_left(a0)    ; if he's drowning, branch to not make dust
        blo   >                                       *  blo.s   +
        ;                                             *  move.b  #2,(Sonic_Dust+anim).w
!                                                     *+
        jsr   Sonic_LevelBound                        *  bsr.w   Sonic_LevelBound
        jsr   AnglePos                                *  bsr.w   AnglePos
                                                      *
return_1AC8C                                          *return_1AC8C:
        rts                                           *  rts
                                                      *; End of subroutine Sonic_CheckSpindash
                                                      *
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subrouting to update an already-charging spindash
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AC8E:
Sonic_UpdateSpindash                                  *Sonic_UpdateSpindash:
        lda   Ctrl_1_Held_Logical                     *  move.b  (Ctrl_1_Held_Logical).w,d0
        anda  #button_down_mask                       *  btst    #button_down,d0
        bne   Sonic_ChargingSpindash                  *  bne.w   Sonic_ChargingSpindash
                                                      *
                                                      *  ; unleash the charged spindash and start rolling quickly:
        ldd   #$0E07                                  *  move.b  #$E,y_radius(a0)
        std   y_radius,u                              *  move.b  #7,x_radius(a0)
        ldd   #SonAni_Roll    
        std   anim,u                                  *  move.b  #AniIDSonAni_Roll,anim(a0)
        ldd   y_pos,u
        addd  #5
        std   y_pos,u                                 *  addq.w  #5,y_pos(a0)    ; add the difference between Sonic's rolling and standing heights
        lda   #0
        sta   spindash_flag,u                         *  move.b  #0,spindash_flag(a0)
                                                      *  moveq   #0,d0
        ldb   spindash_counter,u                      *  move.b  spindash_counter(a0),d0
        aslb                                          *  add.w   d0,d0
        ldx   #SpindashSpeeds     
        ldd   b,x                                     *  move.w  SpindashSpeeds(pc,d0.w),inertia(a0)
        std   inertia,u
        ;                                              *  tst.b   (Super_Sonic_flag).w
        ;                                              *  beq.s   +
        ;                                              *  move.w  SpindashSpeedsSuper(pc,d0.w),inertia(a0)
        ;                                              *+
                                                      *  move.w  inertia(a0),d0
        subd   #$800                                  *  subi.w  #$800,d0
        _asld                                         *  add.w   d0,d0
        anda   #$1F                                   *  andi.w  #$1F00,d0
        andb   #$00
        _negd                                         *  neg.w   d0
        addd  #$2000                                  *  addi.w  #$2000,d0
        std   Horiz_scroll_delay_val                  *  move.w  d0,(Horiz_scroll_delay_val).w
        lda   status,u                                *  btst    #0,status(a0)
        anda  #status_x_orientation
        beq   >                                       *  beq.s   +
        ldd   inertia,u
        _negd                                         *  neg.w   inertia(a0)
        std   inertia,u
!                                                     *+
        lda   status,u
        ora   #status_jumporroll
        sta   status,u                                *  bset    #2,status(a0)
        ;                                             *  move.b  #0,(Sonic_Dust+anim).w
        ldb   #SndID_SpindashRelease                  *  move.w  #SndID_SpindashRelease,d0   ; spindash zoom sound
        stb   Smps.SFXToPlay                          *  jsr (PlaySound).l
        bra   Obj01_Spindash_ResetScr                 *  bra.s   Obj01_Spindash_ResetScr
                                                      *; ===========================================================================
                                                      *; word_1AD0C:
SpindashSpeeds                                        *SpindashSpeeds:
        fdb   $800                                    *  dc.w  $800  ; 0
        fdb   $880                                    *  dc.w  $880  ; 1
        fdb   $900                                    *  dc.w  $900  ; 2
        fdb   $980                                    *  dc.w  $980  ; 3
        fdb   $A00                                    *  dc.w  $A00  ; 4
        fdb   $A80                                    *  dc.w  $A80  ; 5
        fdb   $B00                                    *  dc.w  $B00  ; 6
        fdb   $B80                                    *  dc.w  $B80  ; 7
        fdb   $C00                                    *  dc.w  $C00  ; 8
                                                      *; word_1AD1E:
                                                      *SpindashSpeedsSuper:
                                                      *  dc.w  $B00  ; 0
                                                      *  dc.w  $B80  ; 1
                                                      *  dc.w  $C00  ; 2
                                                      *  dc.w  $C80  ; 3
                                                      *  dc.w  $D00  ; 4
                                                      *  dc.w  $D80  ; 5
                                                      *  dc.w  $E00  ; 6
                                                      *  dc.w  $E80  ; 7
                                                      *  dc.w  $F00  ; 8

                                                      *; ===========================================================================
                                                      *; loc_1AD30:
Sonic_ChargingSpindash                                *Sonic_ChargingSpindash:           ; If still charging the dash...
        ldd   spindash_counter,u                      *  tst.w   spindash_counter(a0)
        beq   >                                       *  beq.s   +
                                                      *  move.w  spindash_counter(a0),d0
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd                                         *  lsr.w   #5,d0
        std   @dec
        ldx   Vint_Main_runcount_w
        beq   @skip
!       addd  @dec
        leax  -1,x
        bne   < 
        std   @dec
@skip   ldd   spindash_counter,u
        subd  #0                                      *  sub.w   d0,spindash_counter(a0)
@dec    equ   *-2
        bcc   >                                       *  bcc.s   +
        ldd   #0                                      *  move.w  #0,spindash_counter(a0)
!       std   spindash_counter,u                      *+
        lda   Ctrl_1_Press_Logical                    *  move.b  (Ctrl_1_Press_Logical).w,d0
        anda  #button_B_mask|button_A_mask            *  andi.b  #button_B_mask|button_C_mask|button_A_mask,d0
        beq   Obj01_Spindash_ResetScr                 *  beq.w   Obj01_Spindash_ResetScr
        ldd   #SonAni_Spindash
        std   anim,u                                  *  move.w  #(AniIDSonAni_Spindash<<8),anim(a0)
        lda   #SndID_SpindashRev                      *  move.w  #SndID_SpindashRev,d0
        sta   Smps.SFXToPlay                          *  jsr (PlaySound).l
        ldd   spindash_counter,u
        addd  #$200
        std   spindash_counter,u                      *  addi.w  #$200,spindash_counter(a0)
        cmpd  #$800                                   *  cmpi.w  #$800,spindash_counter(a0)
        blo   Obj01_Spindash_ResetScr                 *  blo.s   Obj01_Spindash_ResetScr
        ldd   #$800
        std   spindash_counter,u                      *  move.w  #$800,spindash_counter(a0)
                                                      *

                                                      *; loc_1AD78:
Obj01_Spindash_ResetScr                               *Obj01_Spindash_ResetScr:
        leas  2,s                                     *  addq.l  #4,sp
        ldd   Camera_Y_pos_bias
        cmpd  #camera_Y_pos_bias_default              *  cmpi.w  #(224/2)-16,(Camera_Y_pos_bias).w
        beq   loc_1AD8C                               *  beq.s   loc_1AD8C
        bhs   >                                       *  bhs.s   +
        addd  #4                                      *  addq.w  #4,(Camera_Y_pos_bias).w
!       subd  #2                                      *+ subq.w  #2,(Camera_Y_pos_bias).w
        std   Camera_Y_pos_bias                       *
loc_1AD8C                                             *loc_1AD8C:
        jsr   Sonic_LevelBound                        *  bsr.w   Sonic_LevelBound
        jsr   AnglePos                                *  bsr.w   AnglePos
        rts                                           *  rts
                                                      *; End of subroutine Sonic_UpdateSpindash
                                                      *
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to slow Sonic walking up a slope
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AD96:
Sonic_SlopeResist                                     *Sonic_SlopeResist:
                                                      *  move.b  angle(a0),d0
                                                      *  addi.b  #$60,d0
                                                      *  cmpi.b  #$C0,d0
                                                      *  bhs.s   return_1ADCA
                                                      *  move.b  angle(a0),d0
                                                      *  jsr (CalcSine).l
                                                      *  muls.w  #$20,d0
                                                      *  asr.l   #8,d0
                                                      *  tst.w   inertia(a0)
                                                      *  beq.s   return_1ADCA
                                                      *  bmi.s   loc_1ADC6
                                                      *  tst.w   d0
                                                      *  beq.s   +
                                                      *  add.w   d0,inertia(a0)  ; change Sonic's $14
                                                      *+
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *
loc_1ADC6                                             *loc_1ADC6:
                                                      *  add.w   d0,inertia(a0)
                                                      *
return_1ADCA                                          *return_1ADCA:
        rts                                           *  rts
                                                      *; End of subroutine Sonic_SlopeResist
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to push Sonic down a slope while he's rolling
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1ADCC:
Sonic_RollRepel                                       *Sonic_RollRepel:
                                                      *  move.b  angle(a0),d0
                                                      *  addi.b  #$60,d0
                                                      *  cmpi.b  #$C0,d0
                                                      *  bhs.s   return_1AE06
                                                      *  move.b  angle(a0),d0
                                                      *  jsr (CalcSine).l
                                                      *  muls.w  #$50,d0
                                                      *  asr.l   #8,d0
                                                      *  tst.w   inertia(a0)
                                                      *  bmi.s   loc_1ADFC
                                                      *  tst.w   d0
                                                      *  bpl.s   loc_1ADF6
                                                      *  asr.l   #2,d0
                                                      *
loc_1ADF6                                             *loc_1ADF6:
                                                      *  add.w   d0,inertia(a0)
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *
loc_1ADFC                                             *loc_1ADFC:
                                                      *  tst.w   d0
                                                      *  bmi.s   loc_1AE02
                                                      *  asr.l   #2,d0
                                                      *
loc_1AE02                                             *loc_1AE02:
                                                      *  add.w   d0,inertia(a0)
                                                      *
return_1AE06                                          *return_1AE06:
        rts                                           *  rts
                                                      *; End of function Sonic_RollRepel
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to push Sonic down a slope
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AE08:
Sonic_SlopeRepel                                      *Sonic_SlopeRepel:
                                                      *  nop
                                                      *  tst.b   stick_to_convex(a0)
                                                      *  bne.s   return_1AE42
                                                      *  tst.w   move_lock(a0)
                                                      *  bne.s   loc_1AE44
                                                      *  move.b  angle(a0),d0
                                                      *  addi.b  #$20,d0
                                                      *  andi.b  #$C0,d0
                                                      *  beq.s   return_1AE42
                                                      *  mvabs.w inertia(a0),d0
                                                      *  cmpi.w  #$280,d0
                                                      *  bhs.s   return_1AE42
                                                      *  clr.w   inertia(a0)
                                                      *  bset    #1,status(a0)
                                                      *  move.w  #$1E,move_lock(a0)
                                                      *
return_1AE42                                          *return_1AE42:
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *
loc_1AE44                                             *loc_1AE44:
                                                      *  subq.w  #1,move_lock(a0)
        rts                                           *  rts
                                                      *; End of function Sonic_SlopeRepel
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to return Sonic's angle to 0 as he jumps
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AE4A:
Sonic_JumpAngle                                       *Sonic_JumpAngle:
        lda   angle,u                                 *  move.b  angle(a0),d0    ; get Sonic's angle
        beq   Sonic_JumpFlip                          *  beq.s   Sonic_JumpFlip  ; if already 0, branch
        bpl   loc_1AE5A                               *  bpl.s   loc_1AE5A   ; if higher than 0, branch
                                                      *
        adda  #2                                      *  addq.b  #2,d0       ; increase angle
        bcc   BranchTo_Sonic_JumpAngleSet             *  bcc.s   BranchTo_Sonic_JumpAngleSet
        lda   #0                                      *  moveq   #0,d0
                                                      *
BranchTo_Sonic_JumpAngleSet                           *BranchTo_Sonic_JumpAngleSet ; BranchTo
        bra   Sonic_JumpAngleSet                      *  bra.s   Sonic_JumpAngleSet
                                                      *; ===========================================================================
                                                      *
loc_1AE5A                                             *loc_1AE5A:
        suba  #2                                      *  subq.b  #2,d0       ; decrease angle
        bcc   Sonic_JumpAngleSet                      *  bcc.s   Sonic_JumpAngleSet
        lda   #0                                      *  moveq   #0,d0
                                                      *
                                                      *; loc_1AE60:
Sonic_JumpAngleSet                                    *Sonic_JumpAngleSet:
        sta   angle,u                                 *  move.b  d0,angle(a0)
                                                      *; End of function Sonic_JumpAngle
                                                      *  ; continue straight to Sonic_JumpFlip
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Updates Sonic's secondary angle if he's tumbling
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AE64:
Sonic_JumpFlip                                        *Sonic_JumpFlip:
        lda   flip_angle,u                            *  move.b  flip_angle(a0),d0
        beq   return_1AEA8                            *  beq.s   return_1AEA8
        tst   inertia,u                               *  tst.w   inertia(a0)
        bmi   Sonic_JumpLeftFlip                      *  bmi.s   Sonic_JumpLeftFlip
                                                      *; loc_1AE70:
Sonic_JumpRightFlip                                   *Sonic_JumpRightFlip:
        ;                                             *  move.b  flip_speed(a0),d1
        adda  flip_speed,u                            *  add.b   d1,d0
        bcc   BranchTo_Sonic_JumpFlipSet              *  bcc.s   BranchTo_Sonic_JumpFlipSet
        ldb   flips_remaining,u                        
        decb                                          *  subq.b  #1,flips_remaining(a0)
        stb   flips_remaining,u                        
        bcc   BranchTo_Sonic_JumpFlipSet              *  bcc.s   BranchTo_Sonic_JumpFlipSet
        anda  #0                                      
        sta   flips_remaining,u                       *  move.b  #0,flips_remaining(a0) 
        ;                                             *  moveq   #0,d0
                                                      *
BranchTo_Sonic_JumpFlipSet                            *BranchTo_Sonic_JumpFlipSet ; BranchTo
        bra   Sonic_JumpFlipSet                       *  bra.s   Sonic_JumpFlipSet
                                                      *; ===========================================================================
                                                      *; loc_1AE88:
Sonic_JumpLeftFlip                                    *Sonic_JumpLeftFlip:
        tst   flip_turned,u                           *  tst.b   flip_turned(a0)
        bne   Sonic_JumpRightFlip                     *  bne.s   Sonic_JumpRightFlip
        ;                                             *  move.b  flip_speed(a0),d1
        suba  flip_speed,u                            *  sub.b   d1,d0
        bcc   Sonic_JumpFlipSet                       *  bcc.s   Sonic_JumpFlipSet
        ldb   flips_remaining,u                        
        decb                                          *  subq.b  #1,flips_remaining(a0)
        stb   flips_remaining,u 
        bcc   Sonic_JumpFlipSet                       *  bcc.s   Sonic_JumpFlipSet
        anda   #0
        stb   flips_remaining,u                       *  move.b  #0,flips_remaining(a0)
        ;                                             *  moveq   #0,d0
                                                      *; loc_1AEA4:
Sonic_JumpFlipSet                                     *Sonic_JumpFlipSet:
        sta   flip_angle,u                            *  move.b  d0,flip_angle(a0)
                                                      *
return_1AEA8                                          *return_1AEA8:
        rts                                           *  rts
                                                      *; End of function Sonic_JumpFlip
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine for Sonic to interact with the floor and walls when he's in the air
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1AEAA: Sonic_Floor:
Sonic_DoLevelCollision                                *Sonic_DoLevelCollision:
                                                      *  move.l  #Primary_Collision,(Collision_addr).w
                                                      *  cmpi.b  #$C,top_solid_bit(a0)
                                                      *  beq.s   +
                                                      *  move.l  #Secondary_Collision,(Collision_addr).w
                                                      *+
                                                      *  move.b  lrb_solid_bit(a0),d5
                                                      *  move.w  x_vel(a0),d1
                                                      *  move.w  y_vel(a0),d2
                                                      *  jsr (CalcAngle).l
                                                      *  subi.b  #$20,d0
                                                      *  andi.b  #$C0,d0
                                                      *  cmpi.b  #$40,d0
                                                      *  beq.w   Sonic_HitLeftWall
                                                      *  cmpi.b  #$80,d0
                                                      *  beq.w   Sonic_HitCeilingAndWalls
                                                      *  cmpi.b  #$C0,d0
                                                      *  beq.w   Sonic_HitRightWall
                                                      *  bsr.w   CheckLeftWallDist
                                                      *  tst.w   d1
                                                      *  bpl.s   +
                                                      *  sub.w   d1,x_pos(a0)
                                                      *  move.w  #0,x_vel(a0) ; stop Sonic since he hit a wall
                                                      *+
                                                      *  bsr.w   CheckRightWallDist
                                                      *  tst.w   d1
                                                      *  bpl.s   +
                                                      *  add.w   d1,x_pos(a0)
                                                      *  move.w  #0,x_vel(a0) ; stop Sonic since he hit a wall
                                                      *+
                                                      *  bsr.w   Sonic_CheckFloor
                                                      *  tst.w   d1
                                                      *  bpl.s   return_1AF8A
                                                      *  move.b  y_vel(a0),d2
                                                      *  addq.b  #8,d2
                                                      *  neg.b   d2
        ldd   y_pos,u
        cmpd  #screen_top+20+$028F+5                  *  cmp.b   d2,d1
        bge   >                                       *  bge.s   +
                                                      *  cmp.b   d2,d0
        rts                                           *  blt.s   return_1AF8A
!                                                     *+
        ldd   #screen_top+20+$028F+5
        std   y_pos,u
                                                      *  add.w   d1,y_pos(a0)
                                                      *  move.b  d3,angle(a0)
        jsr   Sonic_ResetOnFloor                      *  bsr.w   Sonic_ResetOnFloor
                                                      *  move.b  d3,d0
                                                      *  addi.b  #$20,d0
                                                      *  andi.b  #$40,d0
                                                      *  bne.s   loc_1AF68
                                                      *  move.b  d3,d0
                                                      *  addi.b  #$10,d0
                                                      *  andi.b  #$20,d0
                                                      *  beq.s   loc_1AF5A
                                                      *  asr y_vel(a0)
        ;bra   loc_1AF7C                               *  bra.s   loc_1AF7C
                                                      *; ===========================================================================
                                                      *
loc_1AF5A                                             *loc_1AF5A:
        ldd   #0
        std   y_vel,u                                 *  move.w  #0,y_vel(a0)
        ldd   x_vel,u
        std   inertia,u                               *  move.w  x_vel(a0),inertia(a0)
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *
loc_1AF68                                             *loc_1AF68:
                                                      *  move.w  #0,x_vel(a0) ; stop Sonic since he hit a wall
                                                      *  cmpi.w  #$FC0,y_vel(a0)
                                                      *  ble.s   loc_1AF7C
                                                      *  move.w  #$FC0,y_vel(a0)
                                                      *
loc_1AF7C                                             *loc_1AF7C:
                                                      *  move.w  y_vel(a0),inertia(a0)
                                                      *  tst.b   d3
                                                      *  bpl.s   return_1AF8A
                                                      *  neg.w   inertia(a0)
                                                      *
return_1AF8A                                          *return_1AF8A:
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; loc_1AF8C:
Sonic_HitLeftWall                                     *Sonic_HitLeftWall:
                                                      *  bsr.w   CheckLeftWallDist
                                                      *  tst.w   d1
                                                      *  bpl.s   Sonic_HitCeiling ; branch if distance is positive (not inside wall)
                                                      *  sub.w   d1,x_pos(a0)
                                                      *  move.w  #0,x_vel(a0) ; stop Sonic since he hit a wall
                                                      *  move.w  y_vel(a0),inertia(a0)
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; loc_1AFA6:
Sonic_HitCeiling                                      *Sonic_HitCeiling:
                                                      *  bsr.w   Sonic_CheckCeiling
                                                      *  tst.w   d1
                                                      *  bpl.s   Sonic_HitFloor ; branch if distance is positive (not inside ceiling)
                                                      *  sub.w   d1,y_pos(a0)
                                                      *  tst.w   y_vel(a0)
                                                      *  bpl.s   return_1AFBE
                                                      *  move.w  #0,y_vel(a0) ; stop Sonic in y since he hit a ceiling
                                                      *
return_1AFBE                                          *return_1AFBE:
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; loc_1AFC0:
Sonic_HitFloor                                        *Sonic_HitFloor:
                                                      *  tst.w   y_vel(a0)
                                                      *  bmi.s   return_1AFE6
                                                      *  bsr.w   Sonic_CheckFloor
                                                      *  tst.w   d1
                                                      *  bpl.s   return_1AFE6
                                                      *  add.w   d1,y_pos(a0)
                                                      *  move.b  d3,angle(a0)
                                                      *  bsr.w   Sonic_ResetOnFloor
                                                      *  move.w  #0,y_vel(a0)
                                                      *  move.w  x_vel(a0),inertia(a0)
                                                      *
return_1AFE6                                          *return_1AFE6:
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; loc_1AFE8:
Sonic_HitCeilingAndWalls                              *Sonic_HitCeilingAndWalls:
                                                      *  bsr.w   CheckLeftWallDist
                                                      *  tst.w   d1
                                                      *  bpl.s   +
                                                      *  sub.w   d1,x_pos(a0)
                                                      *  move.w  #0,x_vel(a0)    ; stop Sonic since he hit a wall
                                                      *+
                                                      *  bsr.w   CheckRightWallDist
                                                      *  tst.w   d1
                                                      *  bpl.s   +
                                                      *  add.w   d1,x_pos(a0)
                                                      *  move.w  #0,x_vel(a0)    ; stop Sonic since he hit a wall
                                                      *+
                                                      *  bsr.w   Sonic_CheckCeiling
                                                      *  tst.w   d1
                                                      *  bpl.s   return_1B042
                                                      *  sub.w   d1,y_pos(a0)
                                                      *  move.b  d3,d0
                                                      *  addi.b  #$20,d0
                                                      *  andi.b  #$40,d0
                                                      *  bne.s   loc_1B02C
                                                      *  move.w  #0,y_vel(a0) ; stop Sonic in y since he hit a ceiling
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *
loc_1B02C                                             *loc_1B02C:
                                                      *  move.b  d3,angle(a0)
                                                      *  bsr.w   Sonic_ResetOnFloor
                                                      *  move.w  y_vel(a0),inertia(a0)
                                                      *  tst.b   d3
                                                      *  bpl.s   return_1B042
                                                      *  neg.w   inertia(a0)
                                                      *
return_1B042                                          *return_1B042:
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; loc_1B044:
Sonic_HitRightWall                                    *Sonic_HitRightWall:
                                                      *  bsr.w   CheckRightWallDist
                                                      *  tst.w   d1
                                                      *  bpl.s   Sonic_HitCeiling2
                                                      *  add.w   d1,x_pos(a0)
                                                      *  move.w  #0,x_vel(a0) ; stop Sonic since he hit a wall
                                                      *  move.w  y_vel(a0),inertia(a0)
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; identical to Sonic_HitCeiling...
                                                      *; loc_1B05E:
Sonic_HitCeiling2                                     *Sonic_HitCeiling2:
                                                      *  bsr.w   Sonic_CheckCeiling
                                                      *  tst.w   d1
                                                      *  bpl.s   Sonic_HitFloor2
                                                      *  sub.w   d1,y_pos(a0)
                                                      *  tst.w   y_vel(a0)
                                                      *  bpl.s   return_1B076
                                                      *  move.w  #0,y_vel(a0) ; stop Sonic in y since he hit a ceiling
                                                      *
return_1B076                                          *return_1B076:
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; identical to Sonic_HitFloor...
                                                      *; loc_1B078:
Sonic_HitFloor2                                       *Sonic_HitFloor2:
                                                      *  tst.w   y_vel(a0)
                                                      *  bmi.s   return_1B09E
                                                      *  bsr.w   Sonic_CheckFloor
                                                      *  tst.w   d1
                                                      *  bpl.s   return_1B09E
                                                      *  add.w   d1,y_pos(a0)
                                                      *  move.b  d3,angle(a0)
                                                      *  bsr.w   Sonic_ResetOnFloor
                                                      *  move.w  #0,y_vel(a0)
                                                      *  move.w  x_vel(a0),inertia(a0)
                                                      *
return_1B09E                                          *return_1B09E:
        rts                                           *  rts
                                                      *; End of function Sonic_DoLevelCollision
                                                      *
                                                      *
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to reset Sonic's mode when he lands on the floor
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1B0A0:
Sonic_ResetOnFloor                                    *Sonic_ResetOnFloor:
        tst   pinball_mode,u                          *  tst.b   pinball_mode(a0)
        bne   Sonic_ResetOnFloor_Part3                *  bne.s   Sonic_ResetOnFloor_Part3
        ldd   #SonAni_Walk
        std   anim,u                                  *  move.b  #AniIDSonAni_Walk,anim(a0)
                                                      *; loc_1B0AC:
Sonic_ResetOnFloor_Part2                              *Sonic_ResetOnFloor_Part2:
                                                      *  ; some routines outside of Tails' code can call Sonic_ResetOnFloor_Part2
                                                      *  ; when they mean to call Tails_ResetOnFloor_Part2, so fix that here
                                                      *  _cmpi.b #ObjID_Sonic,id(a0) ; is this object ID Sonic (obj01)?
                                                      *  bne.w   Tails_ResetOnFloor_Part2    ; if not, branch to the Tails version of this code
                                                      *
        lda   status,u
        anda  #status_jumporroll                      *  btst    #2,status(a0)
        beq   Sonic_ResetOnFloor_Part3                *  beq.s   Sonic_ResetOnFloor_Part3
        lda   status,u
        anda  #^status_jumporroll
        sta   status,u                                *  bclr    #2,status(a0)
        ldd   #$1309                                  *  move.b  #$13,y_radius(a0) ; this increases Sonic's collision height to standing
        std   y_radius,u ; and x_radius               *  move.b  #9,x_radius(a0)
        ldd   #SonAni_Walk
        std   anim,u                                  *  move.b  #AniIDSonAni_Walk,anim(a0)  ; use running/walking/standing animation
        ldd   y_pos,u
        subd  #5
        std   y_pos,u                                 *  subq.w  #5,y_pos(a0)    ; move Sonic up 5 pixels so the increased height doesn't push him into the ground
                                                      *; loc_1B0DA:
Sonic_ResetOnFloor_Part3                              *Sonic_ResetOnFloor_Part3:
        ldb   status,u
        andb  #^(status_inair|status_jumpingafterrolling|status_pushing) *  bclr    #1,status(a0)
        stb   status,u                                *  bclr    #5,status(a0)
                                                      *  bclr    #4,status(a0)
        ldd   #0
        sta   jumping,u                               *  move.b  #0,jumping(a0)
        std   Chain_Bonus_counter                     *  move.w  #0,(Chain_Bonus_counter).w
        sta   flip_angle,u                            *  move.b  #0,flip_angle(a0)
        sta   flip_turned,u                           *  move.b  #0,flip_turned(a0)
        sta   flips_remaining,u                       *  move.b  #0,flips_remaining(a0)
        std   Sonic_Look_delay_counter                *  move.w  #0,(Sonic_Look_delay_counter).w
        ;ldd   anim,u       
        ;cmpd  #SonAni_Hang2                          *  cmpi.b  #AniIDSonAni_Hang2,anim(a0)
        ;bne   return_1B11E                           *  bne.s   return_1B11E
        ;ldd   #SonAni_Walk
        ;std   anim,u                                 *  move.b  #AniIDSonAni_Walk,anim(a0)
                                                      *
return_1B11E                                          *return_1B11E:
        rts                                           *  rts
                                                      *
                                                      *; ===========================================================================
                                                      *; ---------------------------------------------------------------------------
                                                      *; Sonic when he gets hurt
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1B120: Obj_01_Sub_4:
Obj01_Hurt                                            *  Obj01_Hurt:
                                                      *  tst.w   (Debug_mode_flag).w
                                                      *  beq.s   Obj01_Hurt_Normal
                                                      *  btst    #button_B,(Ctrl_1_Press).w
                                                      *  beq.s   Obj01_Hurt_Normal
                                                      *  move.w  #1,(Debug_placement_mode).w
                                                      *  clr.b   (Control_Locked).w
        rts                                           *  rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1B13A:
Obj01_Hurt_Normal                                     *Obj01_Hurt_Normal:
                                                      *  tst.b   routine_secondary(a0)
                                                      *  bmi.w   Sonic_HurtInstantRecover
                                                      *  jsr (ObjectMove).l
                                                      *  addi.w  #$30,y_vel(a0)
        lda   status,u                                *  btst    #6,status(a0)
        bita  #status_underwater                       
        beq   @a                                      *  beq.s   +
        ldd   y_vel,u                                 *  subi.w  #$20,y_vel(a0)
        subd  #$20                                     
        std   y_vel,u                                  
@a                                                    *+
                                                       
                                                      *  cmpi.w  #-$100,(Camera_Min_Y_pos).w
                                                      *  bne.s   +
                                                      *  andi.w  #$7FF,y_pos(a0)
                                                      *+
                                                      *  bsr.w   Sonic_HurtStop
        jsr   Sonic_LevelBound                        *  bsr.w   Sonic_LevelBound
        ;jsr   Sonic_RecordPos                        *  bsr.w   Sonic_RecordPos
        jsr   Sonic_Animate                           *  bsr.w   Sonic_Animate
                                                      *  bsr.w   LoadSonicDynPLC
        jmp   DisplaySprite                           *  jmp (DisplaySprite).l
                                                      *; ===========================================================================
                                                      *; loc_1B184:
Sonic_HurtStop                                        *Sonic_HurtStop:
                                                      *  move.w  (Camera_Max_Y_pos_now).w,d0
                                                      *  addi.w  #$E0,d0
                                                      *  cmp.w   y_pos(a0),d0
                                                      *  blt.w   JmpTo_KillCharacter
                                                      *  bsr.w   Sonic_DoLevelCollision
                                                      *  btst    #1,status(a0)
                                                      *  bne.s   return_1B1C8
                                                      *  moveq   #0,d0
                                                      *  move.w  d0,y_vel(a0)
                                                      *  move.w  d0,x_vel(a0)
                                                      *  move.w  d0,inertia(a0)
                                                      *  move.b  d0,obj_control(a0)
                                                      *  move.b  #AniIDSonAni_Walk,anim(a0)
                                                      *  subq.b  #2,routine(a0)  ; => Obj01_Control
                                                      *  move.w  #$78,invulnerable_time(a0)
                                                      *  move.b  #0,spindash_flag(a0)
                                                      *
return_1B1C8                                          *return_1B1C8:
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; makes Sonic recover control after being hurt before landing
                                                      *; seems to be unused
                                                      *; loc_1B1CA:
Sonic_HurtInstantRecover                              *Sonic_HurtInstantRecover:
                                                      *  subq.b  #2,routine(a0)  ; => Obj01_Control
                                                      *  move.b  #0,routine_secondary(a0)
        ;jsr   Sonic_RecordPos                        *  bsr.w   Sonic_RecordPos
        jsr   Sonic_Animate                           *  bsr.w   Sonic_Animate
                                                      *  bsr.w   LoadSonicDynPLC
        jmp   DisplaySprite                           *  jmp (DisplaySprite).l
                                                      *; ===========================================================================
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Sonic when he dies
                                                      *; ...poor Sonic
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; loc_1B1E6: Obj_01_Sub_6:
Obj01_Dead                                            *  Obj01_Dead:
                                                      *  tst.w   (Debug_mode_flag).w
                                                      *  beq.s   +
                                                      *  btst    #button_B,(Ctrl_1_Press).w
                                                      *  beq.s   +
                                                      *  move.w  #1,(Debug_placement_mode).w
                                                      *  clr.b   (Control_Locked).w
        rts                                           *  rts
                                                      *+
        jsr   CheckGameOver                           *  bsr.w   CheckGameOver
        jsr   ObjectMoveAndFall                       *  jsr (ObjectMoveAndFall).l
        ;jsr   Sonic_RecordPos                        *  bsr.w   Sonic_RecordPos
        jsr   Sonic_Animate                           *  bsr.w   Sonic_Animate
                                                      *  bsr.w   LoadSonicDynPLC
        jmp   DisplaySprite                           *  jmp (DisplaySprite).l
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1B21C:
CheckGameOver                                         *CheckGameOver:
                                                      *  move.b  #1,(Scroll_lock).w
                                                      *  move.b  #0,spindash_flag(a0)
                                                      *  move.w  (Camera_Max_Y_pos_now).w,d0
                                                      *  addi.w  #$100,d0
                                                      *  cmp.w   y_pos(a0),d0
                                                      *  bge.w   return_1B31A
                                                      *  move.b  #8,routine(a0)  ; => Obj01_Gone
                                                      *  move.w  #60,restart_countdown(a0)
                                                      *  addq.b  #1,(Update_HUD_lives).w ; update lives counter
                                                      *  subq.b  #1,(Life_count).w   ; subtract 1 from number of lives
                                                      *  bne.s   Obj01_ResetLevel    ; if it's not a game over, branch
                                                      *  move.w  #0,restart_countdown(a0)
                                                      *  move.b  #ObjID_GameOver,(GameOver_GameText+id).w ; load Obj39 (game over text)
                                                      *  move.b  #ObjID_GameOver,(GameOver_OverText+id).w ; load Obj39 (game over text)
                                                      *  move.b  #1,(GameOver_OverText+mapping_frame).w
                                                      *  move.w  a0,(GameOver_GameText+parent).w
                                                      *  clr.b   (Time_Over_flag).w
                                                      *; loc_1B26E:
Obj01_Finished                                        *Obj01_Finished:
                                                      *  clr.b   (Update_HUD_timer).w
                                                      *  clr.b   (Update_HUD_timer_2P).w
                                                      *  move.b  #8,routine(a0)  ; => Obj01_Gone
                                                      *  move.w  #MusID_GameOver,d0
                                                      *  jsr (PlayMusic).l
                                                      *  moveq   #PLCID_GameOver,d0
        rts                                           *  jmp (LoadPLC).l
                                                      *; End of function CheckGameOver
                                                      *
                                                      *; ===========================================================================
                                                      *; ---------------------------------------------------------------------------
                                                      *; Sonic when the level is restarted
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1B28E:
Obj01_ResetLevel                                      *Obj01_ResetLevel:
                                                      *  tst.b   (Time_Over_flag).w
                                                      *  beq.s   Obj01_ResetLevel_Part2
                                                      *  move.w  #0,restart_countdown(a0)
                                                      *  move.b  #ObjID_TimeOver,(TimeOver_TimeText+id).w ; load Obj39
                                                      *  move.b  #ObjID_TimeOver,(TimeOver_OverText+id).w ; load Obj39
                                                      *  move.b  #2,(TimeOver_TimeText+mapping_frame).w
                                                      *  move.b  #3,(TimeOver_OverText+mapping_frame).w
                                                      *  move.w  a0,(TimeOver_TimeText+parent).w
        bra   Obj01_Finished                          *  bra.s   Obj01_Finished
                                                      *; ---------------------------------------------------------------------------
Obj01_ResetLevel_Part2                                *Obj01_ResetLevel_Part2:
                                                      *  tst.w   (Two_player_mode).w
                                                      *  beq.s   return_1B31A
                                                      *  move.b  #0,(Scroll_lock).w
                                                      *  move.b  #$A,routine(a0) ; => Obj01_Respawning
                                                      *  move.w  (Saved_x_pos).w,x_pos(a0)
                                                      *  move.w  (Saved_y_pos).w,y_pos(a0)
                                                      *  move.w  (Saved_art_tile).w,art_tile(a0)
                                                      *  move.w  (Saved_Solid_bits).w,top_solid_bit(a0)
                                                      *  clr.w   (Ring_count).w
                                                      *  clr.b   (Extra_life_flags).w
                                                      *  move.b  #0,obj_control(a0)
                                                      *  move.b  #5,anim(a0)
                                                      *  move.w  #0,x_vel(a0)
                                                      *  move.w  #0,y_vel(a0)
                                                      *  move.w  #0,inertia(a0)
                                                      *  move.b  #2,status(a0)
                                                      *  move.w  #0,move_lock(a0)
                                                      *  move.w  #0,restart_countdown(a0)
                                                      *
return_1B31A                                          *return_1B31A:
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; ---------------------------------------------------------------------------
                                                      *; Sonic when he's offscreen and waiting for the level to restart
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1B31C: Obj_01_Sub_8:
Obj01_Gone                                            *  Obj01_Gone:
                                                      *  tst.w   restart_countdown(a0)
                                                      *  beq.s   +
                                                      *  subq.w  #1,restart_countdown(a0)
                                                      *  bne.s   +
                                                      *  move.w  #1,(Level_Inactive_flag).w
                                                      *+
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; ---------------------------------------------------------------------------
                                                      *; Sonic when he's waiting for the camera to scroll back to where he respawned
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1B330: Obj_01_Sub_A:
Obj01_Respawning                                      *  Obj01_Respawning:
                                                      *  tst.w   (Camera_X_pos_diff).w
                                                      *  bne.s   +
                                                      *  tst.w   (Camera_Y_pos_diff).w
                                                      *  bne.s   +
                                                      *  move.b  #2,routine(a0)  ; => Obj01_Control
                                                      *+
        jsr   Sonic_Animate                           *  bsr.w   Sonic_Animate
                                                      *  bsr.w   LoadSonicDynPLC
        jmp   DisplaySprite                           *  jmp (DisplaySprite).l
                                                      *; ===========================================================================
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Sonic pattern loading subroutine
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1B848:
                                                      *LoadSonicDynPLC:
                                                      *
                                                      *  moveq   #0,d0
                                                      *  move.b  mapping_frame(a0),d0    ; load frame number
                                                      *; loc_1B84E:
                                                      *LoadSonicDynPLC_Part2:
                                                      *  cmp.b   (Sonic_LastLoadedDPLC).w,d0
                                                      *  beq.s   return_1B89A
                                                      *  move.b  d0,(Sonic_LastLoadedDPLC).w
                                                      *  lea (MapRUnc_Sonic).l,a2
                                                      *  add.w   d0,d0
                                                      *  adda.w  (a2,d0.w),a2
                                                      *  move.w  (a2)+,d5
                                                      *  subq.w  #1,d5
                                                      *  bmi.s   return_1B89A
                                                      *  move.w  #tiles_to_bytes(ArtTile_ArtUnc_Sonic),d4
                                                      *; loc_1B86E:
                                                      *SPLC_ReadEntry:
                                                      *  moveq   #0,d1
                                                      *  move.w  (a2)+,d1
                                                      *  move.w  d1,d3
                                                      *  lsr.w   #8,d3
                                                      *  andi.w  #$F0,d3
                                                      *  addi.w  #$10,d3
                                                      *  andi.w  #$FFF,d1
                                                      *  lsl.l   #5,d1
                                                      *  addi.l  #ArtUnc_Sonic,d1
                                                      *  move.w  d4,d2
                                                      *  add.w   d3,d4
                                                      *  add.w   d3,d4
                                                      *  jsr (QueueDMATransfer).l
                                                      *  dbf d5,SPLC_ReadEntry   ; repeat for number of entries
                                                      *
                                                      *return_1B89A:
                                                      *  rts
                                                      *; ===========================================================================
                                                      *
                                                      *JmpTo_KillCharacter ; JmpTo
                                                      *  jmp (KillCharacter).l
                                                      *
                                                      *    if ~~removeJmpTos
                                                      *  align 4
                                                      *    endif
                                                       
; ***************************************************************************************************************************************************

                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to change Sonic's angle & position as he walks along the floor
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1E234: Sonic_AnglePos:
AnglePos                                              * AnglePos:
                                                      *         move.l  #Primary_Collision,(Collision_addr).w
                                                      *         cmpi.b  #$C,top_solid_bit(a0)
                                                      *         beq.s   +
                                                      *         move.l  #Secondary_Collision,(Collision_addr).w
                                                      * +
                                                      *         move.b  top_solid_bit(a0),d5
                                                      *         btst    #3,status(a0)
                                                      *         beq.s   +
                                                      *         moveq   #0,d0
                                                      *         move.b  d0,(Primary_Angle).w
                                                      *         move.b  d0,(Secondary_Angle).w
        rts                                           *         rts
                                                      * ; ---------------------------------------------------------------------------
                                                      * +       moveq   #3,d0
                                                      *         move.b  d0,(Primary_Angle).w
                                                      *         move.b  d0,(Secondary_Angle).w
                                                      *         move.b  angle(a0),d0
                                                      *         addi.b  #$20,d0
                                                      *         bpl.s   loc_1E286
                                                      *         move.b  angle(a0),d0
                                                      *         bpl.s   +
                                                      *         subq.b  #1,d0
                                                      * +
                                                      *         addi.b  #$20,d0
                                                      *         bra.s   loc_1E292
                                                      * ; ---------------------------------------------------------------------------
                                                      * loc_1E286:
                                                      *         move.b  angle(a0),d0
                                                      *         bpl.s   loc_1E28E
                                                      *         addq.b  #1,d0
                                                      * 
                                                      * loc_1E28E:
                                                      *         addi.b  #$1F,d0
                                                      * 
                                                      * loc_1E292:
                                                      *         andi.b  #$C0,d0
                                                      *         cmpi.b  #$40,d0
                                                      *         beq.w   Sonic_WalkVertL
                                                      *         cmpi.b  #$80,d0
                                                      *         beq.w   Sonic_WalkCeiling
                                                      *         cmpi.b  #$C0,d0
                                                      *         beq.w   Sonic_WalkVertR
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.w  d1,-(sp)
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         neg.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Secondary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.w  (sp)+,d0
                                                      *         bsr.w   Sonic_Angle
                                                      *         tst.w   d1
                                                      *         beq.s   return_1E31C
                                                      *         bpl.s   loc_1E31E
                                                      *         cmpi.w  #-$E,d1
                                                      *         blt.s   return_1E31C
                                                      *         add.w   d1,y_pos(a0)
                                                      * 
                                                      * return_1E31C:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E31E:
                                                      *         mvabs.b x_vel(a0),d0
                                                      *         addq.b  #4,d0
                                                      *         cmpi.b  #$E,d0
                                                      *         blo.s   +
                                                      *         move.b  #$E,d0
                                                      * +
                                                      *         cmp.b   d0,d1
                                                      *         bgt.s   loc_1E33C
                                                      * 
                                                      * loc_1E336:
                                                      *         add.w   d1,y_pos(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E33C:
                                                      *         tst.b   stick_to_convex(a0)
                                                      *         bne.s   loc_1E336
                                                      *         bset    #1,status(a0)
                                                      *         bclr    #5,status(a0)
                                                      *         move.b  #AniIDSonAni_Run,prev_anim(a0)  ; Force character's animation to restart
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to change Sonic's angle as he walks along the floor
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1E356:
                                                      * Sonic_Angle:
                                                      *         move.b  (Secondary_Angle).w,d2
                                                      *         cmp.w   d0,d1
                                                      *         ble.s   +
                                                      *         move.b  (Primary_Angle).w,d2
                                                      *         move.w  d0,d1
                                                      * +
                                                      *         btst    #0,d2
                                                      *         bne.s   loc_1E380
                                                      *         move.b  d2,d0
                                                      *         sub.b   angle(a0),d0
                                                      *         bpl.s   +
                                                      *         neg.b   d0
                                                      * +
                                                      *         cmpi.b  #$20,d0
                                                      *         bhs.s   loc_1E380
                                                      *         move.b  d2,angle(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E380:
                                                      *         move.b  angle(a0),d2
                                                      *         addi.b  #$20,d2
                                                      *         andi.b  #$C0,d2
                                                      *         move.b  d2,angle(a0)
                                                      *         rts
                                                      * ; End of function Sonic_Angle
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine allowing Sonic to walk up a vertical slope/wall to his right
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1E392:
                                                      * Sonic_WalkVertR:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         neg.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindWall
                                                      *         move.w  d1,-(sp)
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Secondary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindWall
                                                      *         move.w  (sp)+,d0
                                                      *         bsr.w   Sonic_Angle
                                                      *         tst.w   d1
                                                      *         beq.s   return_1E400
                                                      *         bpl.s   loc_1E402
                                                      *         cmpi.w  #-$E,d1
                                                      *         blt.s   return_1E400
                                                      *         add.w   d1,x_pos(a0)
                                                      * 
                                                      * return_1E400:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E402:
                                                      *         mvabs.b y_vel(a0),d0
                                                      *         addq.b  #4,d0
                                                      *         cmpi.b  #$E,d0
                                                      *         blo.s   +
                                                      *         move.b  #$E,d0
                                                      * +
                                                      *         cmp.b   d0,d1
                                                      *         bgt.s   loc_1E420
                                                      * 
                                                      * loc_1E41A:
                                                      *         add.w   d1,x_pos(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E420:
                                                      *         tst.b   stick_to_convex(a0)
                                                      *         bne.s   loc_1E41A
                                                      *         bset    #1,status(a0)
                                                      *         bclr    #5,status(a0)
                                                      *         move.b  #AniIDSonAni_Run,prev_anim(a0)  ; Force character's animation to restart
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_1E43A
                                                      * Sonic_WalkCeiling:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d2
                                                      *         eori.w  #$F,d2
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$800,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.w  d1,-(sp)
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d2
                                                      *         eori.w  #$F,d2
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d3
                                                      *         lea     (Secondary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$800,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.w  (sp)+,d0
                                                      *         bsr.w   Sonic_Angle
                                                      *         tst.w   d1
                                                      *         beq.s   return_1E4AE
                                                      *         bpl.s   loc_1E4B0
                                                      *         cmpi.w  #-$E,d1
                                                      *         blt.s   return_1E4AE
                                                      *         sub.w   d1,y_pos(a0)
                                                      * 
                                                      * return_1E4AE:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E4B0:
                                                      *         mvabs.b x_vel(a0),d0
                                                      *         addq.b  #4,d0
                                                      *         cmpi.b  #$E,d0
                                                      *         blo.s   +
                                                      *         move.b  #$E,d0
                                                      * +
                                                      *         cmp.b   d0,d1
                                                      *         bgt.s   loc_1E4CE
                                                      * 
                                                      * loc_1E4C8:
                                                      *         sub.w   d1,y_pos(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E4CE:
                                                      *         tst.b   stick_to_convex(a0)
                                                      *         bne.s   loc_1E4C8
                                                      *         bset    #1,status(a0)
                                                      *         bclr    #5,status(a0)
                                                      *         move.b  #AniIDSonAni_Run,prev_anim(a0)  ; Force character's animation to restart
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_1E4E8
                                                      * Sonic_WalkVertL:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d3
                                                      *         eori.w  #$F,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$400,d6
                                                      *         bsr.w   FindWall
                                                      *         move.w  d1,-(sp)
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d3
                                                      *         eori.w  #$F,d3
                                                      *         lea     (Secondary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$400,d6
                                                      *         bsr.w   FindWall
                                                      *         move.w  (sp)+,d0
                                                      *         bsr.w   Sonic_Angle
                                                      *         tst.w   d1
                                                      *         beq.s   return_1E55C
                                                      *         bpl.s   loc_1E55E
                                                      *         cmpi.w  #-$E,d1
                                                      *         blt.s   return_1E55C
                                                      *         sub.w   d1,x_pos(a0)
                                                      * 
                                                      * return_1E55C:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E55E:
                                                      *         mvabs.b y_vel(a0),d0
                                                      *         addq.b  #4,d0
                                                      *         cmpi.b  #$E,d0
                                                      *         blo.s   +
                                                      *         move.b  #$E,d0
                                                      * +
                                                      *         cmp.b   d0,d1
                                                      *         bgt.s   loc_1E57C
                                                      * 
                                                      * loc_1E576:
                                                      *         sub.w   d1,x_pos(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E57C:
                                                      *         tst.b   stick_to_convex(a0)
                                                      *         bne.s   loc_1E576
                                                      *         bset    #1,status(a0)
                                                      *         bclr    #5,status(a0)
                                                      *         move.b  #AniIDSonAni_Run,prev_anim(a0)  ; Force character's animation to restart
                                                      *         rts
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
                                                      * ; loc_1E596: Floor_ChkTile:
                                                      * Find_Tile:
                                                      *         move.w  d2,d0   ; y_pos
                                                      *         add.w   d0,d0
                                                      *         andi.w  #$F00,d0        ; rounded 2*y_pos
                                                      *         move.w  d3,d1   ; x_pos
                                                      *         lsr.w   #3,d1
                                                      *         move.w  d1,d4
                                                      *         lsr.w   #4,d1   ; x_pos/128 = x_of_chunk
                                                      *         andi.w  #$7F,d1
                                                      *         add.w   d1,d0   ; d0 is relevant chunk ID now
                                                      *         moveq   #-1,d1
                                                      *         clr.w   d1              ; d1 is now $FFFF0000 = Chunk_Table
                                                      *         lea     (Level_Layout).w,a1
                                                      *         move.b  (a1,d0.w),d1    ; move 128*128 chunk ID to d1
                                                      *         add.w   d1,d1
                                                      *         move.w  word_1E5D0(pc,d1.w),d1
                                                      *         move.w  d2,d0   ; y_pos
                                                      *         andi.w  #$70,d0
                                                      *         add.w   d0,d1
                                                      *         andi.w  #$E,d4  ; x_pos/8
                                                      *         add.w   d4,d1
                                                      *         movea.l d1,a1   ; address of block ID
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; precalculated values for Find_Tile
                                                      * ; (Sonic 1 calculated it every time instead of using a table)
                                                      * word_1E5D0:
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
                                                      *         bsr.w   Find_Tile
                                                      *         move.w  (a1),d0
                                                      *         move.w  d0,d4
                                                      *         andi.w  #$3FF,d0
                                                      *         beq.s   loc_1E7E2
                                                      *         btst    d5,d4
                                                      *         bne.s   loc_1E7F0
                                                      * 
loc_1E7E2                                             * loc_1E7E2:
                                                      *         add.w   a3,d2
                                                      *         bsr.w   FindFloor2
                                                      *         sub.w   a3,d2
                                                      *         addi.w  #$10,d1
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1E7F0                                             * loc_1E7F0:      ; block has some solidity
                                                      *         movea.l (Collision_addr).w,a2   ; pointer to collision data, i.e. blockID -> collisionID array
                                                      *         move.b  (a2,d0.w),d0    ; get collisionID
                                                      *         andi.w  #$FF,d0
                                                      *         beq.s   loc_1E7E2
                                                      *         lea     (ColCurveMap).l,a2
                                                      *         move.b  (a2,d0.w),(a4)  ; get angle from AngleMap --> (a4)
                                                      *         lsl.w   #4,d0
                                                      *         move.w  d3,d1   ; x_pos
                                                      *         btst    #$A,d4  ; adv.blockID in d4 - X flipping
                                                      *         beq.s   +
                                                      *         not.w   d1
                                                      *         neg.b   (a4)
                                                      * +
                                                      *         btst    #$B,d4  ; Y flipping
                                                      *         beq.s   +
                                                      *         addi.b  #$40,(a4)
                                                      *         neg.b   (a4)
                                                      *         subi.b  #$40,(a4)
                                                      * +
                                                      *         andi.w  #$F,d1  ; x_pos (mod 16)
                                                      *         add.w   d0,d1   ; d0 = 16*blockID -> offset in ColArray to look up
                                                      *         lea     (ColArray).l,a2
                                                      *         move.b  (a2,d1.w),d0    ; heigth from ColArray
                                                      *         ext.w   d0
                                                      *         eor.w   d6,d4
                                                      *         btst    #$B,d4  ; Y flipping
                                                      *         beq.s   +
                                                      *         neg.w   d0
                                                      * +
                                                      *         tst.w   d0
                                                      *         beq.s   loc_1E7E2       ; no collision
                                                      *         bmi.s   loc_1E85E
                                                      *         cmpi.b  #$10,d0
                                                      *         beq.s   loc_1E86A
                                                      *         move.w  d2,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         move.w  #$F,d1
                                                      *         sub.w   d0,d1
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1E85E                                             * loc_1E85E:
                                                      *         move.w  d2,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         bpl.w   loc_1E7E2
                                                      * 
loc_1E86A                                             * loc_1E86A:
                                                      *         sub.w   a3,d2
                                                      *         bsr.w   FindFloor2
                                                      *         add.w   a3,d2
                                                      *         subi.w  #$10,d1
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
                                                      * FindFloor2:
                                                      *         bsr.w   Find_Tile
                                                      *         move.w  (a1),d0
                                                      *         move.w  d0,d4
                                                      *         andi.w  #$3FF,d0
                                                      *         beq.s   loc_1E88A
                                                      *         btst    d5,d4
                                                      *         bne.s   loc_1E898
                                                      * 
                                                      * loc_1E88A:
                                                      *         move.w  #$F,d1
                                                      *         move.w  d2,d0
                                                      *         andi.w  #$F,d0
                                                      *         sub.w   d0,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E898:
                                                      *         movea.l (Collision_addr).w,a2
                                                      *         move.b  (a2,d0.w),d0
                                                      *         andi.w  #$FF,d0
                                                      *         beq.s   loc_1E88A
                                                      *         lea     (ColCurveMap).l,a2
                                                      *         move.b  (a2,d0.w),(a4)
                                                      *         lsl.w   #4,d0
                                                      *         move.w  d3,d1
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
                                                      *         beq.s   loc_1E88A
                                                      *         bmi.s   loc_1E900
                                                      *         move.w  d2,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         move.w  #$F,d1
                                                      *         sub.w   d0,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E900:
                                                      *         move.w  d2,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         bpl.w   loc_1E88A
                                                      *         not.w   d1
                                                      *         rts
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
                                                      * Ring_FindFloor:
                                                      *         bsr.w   Find_Tile
                                                      *         move.w  (a1),d0
                                                      *         move.w  d0,d4
                                                      *         andi.w  #$3FF,d0
                                                      *         beq.s   loc_1E922
                                                      *         btst    d5,d4
                                                      *         bne.s   loc_1E928
                                                      * 
                                                      * loc_1E922:
                                                      *         move.w  #$10,d1
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
                                                      *         move.w  d3,d1
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
                                                      *         move.w  d2,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         move.w  #$F,d1
                                                      *         sub.w   d0,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E996:
                                                      *         move.w  d2,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         bpl.w   loc_1E922
                                                      * 
                                                      * loc_1E9A2:
                                                      *         sub.w   a3,d2
                                                      *         bsr.w   FindFloor2
                                                      *         add.w   a3,d2
                                                      *         subi.w  #$10,d1
                                                      *         rts
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
                                                      * FindWall:
                                                      *         bsr.w   Find_Tile
                                                      *         move.w  (a1),d0
                                                      *         move.w  d0,d4
                                                      *         andi.w  #$3FF,d0        ; plain blockID
                                                      *         beq.s   loc_1E9C2       ; no collision
                                                      *         btst    d5,d4
                                                      *         bne.s   loc_1E9D0
                                                      * 
                                                      * loc_1E9C2:
                                                      *         add.w   a3,d3
                                                      *         bsr.w   FindWall2
                                                      *         sub.w   a3,d3
                                                      *         addi.w  #$10,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1E9D0:
                                                      *         movea.l (Collision_addr).w,a2
                                                      *         move.b  (a2,d0.w),d0
                                                      *         andi.w  #$FF,d0 ; relevant collisionArrayEntry
                                                      *         beq.s   loc_1E9C2
                                                      *         lea     (ColCurveMap).l,a2
                                                      *         move.b  (a2,d0.w),(a4)
                                                      *         lsl.w   #4,d0   ; offset in collision array
                                                      *         move.w  d2,d1   ; y
                                                      *         btst    #$B,d4  ; y-mirror?
                                                      *         beq.s   +
                                                      *         not.w   d1
                                                      *         addi.b  #$40,(a4)
                                                      *         neg.b   (a4)
                                                      *         subi.b  #$40,(a4)
                                                      * +
                                                      *         btst    #$A,d4  ; x-mirror?
                                                      *         beq.s   +
                                                      *         neg.b   (a4)
                                                      * +
                                                      *         andi.w  #$F,d1  ; y
                                                      *         add.w   d0,d1   ; line to look up
                                                      *         lea     (ColArray2).l,a2        ; rotated collision array
                                                      *         move.b  (a2,d1.w),d0    ; collision value
                                                      *         ext.w   d0
                                                      *         eor.w   d6,d4   ; set x-flip flag if from the right
                                                      *         btst    #$A,d4  ; x-mirror?
                                                      *         beq.s   +
                                                      *         neg.w   d0
                                                      * +
                                                      *         tst.w   d0
                                                      *         beq.s   loc_1E9C2
                                                      *         bmi.s   loc_1EA3E
                                                      *         cmpi.b  #$10,d0
                                                      *         beq.s   loc_1EA4A
                                                      *         move.w  d3,d1   ; x
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         move.w  #$F,d1
                                                      *         sub.w   d0,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1EA3E:
                                                      *         move.w  d3,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         bpl.w   loc_1E9C2       ; no collision
                                                      * 
                                                      * loc_1EA4A:
                                                      *         sub.w   a3,d3
                                                      *         bsr.w   FindWall2
                                                      *         add.w   a3,d3
                                                      *         subi.w  #$10,d1
                                                      *         rts
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
                                                      * FindWall2:
                                                      *         bsr.w   Find_Tile
                                                      *         move.w  (a1),d0
                                                      *         move.w  d0,d4
                                                      *         andi.w  #$3FF,d0
                                                      *         beq.s   loc_1EA6A
                                                      *         btst    d5,d4
                                                      *         bne.s   loc_1EA78
                                                      * 
                                                      * loc_1EA6A:
                                                      *         move.w  #$F,d1
                                                      *         move.w  d3,d0
                                                      *         andi.w  #$F,d0
                                                      *         sub.w   d0,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1EA78:
                                                      *         movea.l (Collision_addr).w,a2
                                                      *         move.b  (a2,d0.w),d0
                                                      *         andi.w  #$FF,d0
                                                      *         beq.s   loc_1EA6A
                                                      *         lea     (ColCurveMap).l,a2
                                                      *         move.b  (a2,d0.w),(a4)
                                                      *         lsl.w   #4,d0
                                                      *         move.w  d2,d1
                                                      *         btst    #$B,d4
                                                      *         beq.s   +
                                                      *         not.w   d1
                                                      *         addi.b  #$40,(a4)
                                                      *         neg.b   (a4)
                                                      *         subi.b  #$40,(a4)
                                                      * +
                                                      *         btst    #$A,d4
                                                      *         beq.s   +
                                                      *         neg.b   (a4)
                                                      * +
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d0,d1
                                                      *         lea     (ColArray2).l,a2
                                                      *         move.b  (a2,d1.w),d0
                                                      *         ext.w   d0
                                                      *         eor.w   d6,d4
                                                      *         btst    #$A,d4
                                                      *         beq.s   +
                                                      *         neg.w   d0
                                                      * +
                                                      *         tst.w   d0
                                                      *         beq.s   loc_1EA6A
                                                      *         bmi.s   loc_1EAE0
                                                      *         move.w  d3,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         move.w  #$F,d1
                                                      *         sub.w   d0,d1
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_1EAE0:
                                                      *         move.w  d3,d1
                                                      *         andi.w  #$F,d1
                                                      *         add.w   d1,d0
                                                      *         bpl.w   loc_1EA6A
                                                      *         not.w   d1
                                                      *         rts
                                                      * ; End of function FindWall2
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; The subroutine appears to convert the collision array from an unknown
                                                      * ; 'raw' format to its current format, and write it to ROM, overwritting
                                                      * ; the original. This doesn't work on standard read-only cartridges, and
                                                      * ; would instead require a special dev cartridge.
                                                      * ; This subroutine exists in Sonic 1 as well, but was oddly changed in
                                                      * ; the S2 Nick Arcade prototype to just handle loading GHZ's collision
                                                      * ; instead (though it too is dummied out, hence collision being broken).
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; return_1EAF0: FloorLog_Unk:
                                                      * ConvertCollisionArray:
                                                      *         rts
                                                      * ; ---------------------------------------------------------------------------
                                                      *         lea     (ColArray).l,a1 ; Source location of 'raw' collision array
                                                      *         lea     (ColArray).l,a2 ; Destinatation of converted collision array (overwrites the original)
                                                      * 
                                                      *         move.w  #$100-1,d3      ; Number of blocks in collision array
                                                      * .blockLoop:
                                                      *         moveq   #16,d5          ; Start on the 16th bit (the leftmost pixel)
                                                      * 
                                                      *         move.w  #16-1,d2        ; Width of a block in pixels
                                                      * .columnLoop:
                                                      *         moveq   #0,d4
                                                      * 
                                                      *         ; It seems the 'raw' format stored the collision of each pixel in rows.
                                                      *         ; This block of code changes it from rows to columns, so each word contains
                                                      *         ; a bit for each pixel in a column.
                                                      *         move.w  #16-1,d1        ; Height of a block in pixels
                                                      * .rowLoop:
                                                      *         move.w  (a1)+,d0        ; Get row of collision bits
                                                      *         lsr.l   d5,d0           ; Push the selected bit of this row into the 'eXtend' flag
                                                      *         addx.w  d4,d4           ; Shift d4 to the left, and insert the selected bit into bit 0
                                                      *         dbf     d1,.rowLoop     ; Loop for each row of pixels in a block
                                                      * 
                                                      *         move.w  d4,(a2)+        ; Store column of collision bits
                                                      *         suba.w  #2*16,a1        ; Back to the start of the block
                                                      *         subq.w  #1,d5           ; Get next bit in the row
                                                      *         dbf     d2,.columnLoop  ; Loop for each column of pixels in a block
                                                      * 
                                                      *         adda.w  #2*16,a1        ; Next block
                                                      *         dbf     d3,.blockLoop   ; Loop for each block in the collision array
                                                      * 
                                                      *         lea     (ColArray).l,a1
                                                      *         lea     (ColArray2).l,a2        ; Write converted collision array to location of rotated collison array
                                                      *         bsr.s   .convertArrayToStandardFormat
                                                      *         lea     (ColArray).l,a1
                                                      *         lea     (ColArray).l,a2         ; Write converted collision array to location of normal collison array
                                                      * 
                                                      * ; loc_1EB46: FloorLog_Unk2:
                                                      * .convertArrayToStandardFormat:
                                                      *         move.w  #$1000-1,d3     ; Size of the collision array
                                                      * 
                                                      * .processCollisionArrayLoop:
                                                      *         moveq   #0,d2
                                                      *         move.w  #$F,d1
                                                      *         move.w  (a1)+,d0        ; Get current column of collision pixels
                                                      *         beq.s   .noCollision    ; Branch if there's no collision in this column
                                                      *         bmi.s   .topPixelSolid  ; Branch if top pixel of collision is solid
                                                      * 
                                                      *         ; Here we count, starting from the bottom, how many pixels tall
                                                      *         ; the collision in this column is.
                                                      * .processColumnLoop1:
                                                      *         lsr.w   #1,d0
                                                      *         bcc.s   .pixelNotSolid1
                                                      *         addq.b  #1,d2
                                                      * .pixelNotSolid1:
                                                      *         dbf     d1,.processColumnLoop1
                                                      * 
                                                      *         bra.s   .columnProcessed
                                                      * ; ===========================================================================
                                                      * .topPixelSolid:
                                                      *         cmpi.w  #$FFFF,d0               ; Is entire column solid?
                                                      *         beq.s   .entireColumnSolid      ; Branch if so
                                                      * 
                                                      *         ; Here we count, starting from the top, how many pixels tall
                                                      *         ; the collision in this column is (the resulting number is negative).
                                                      * .processColumnLoop2:
                                                      *         lsl.w   #1,d0
                                                      *         bcc.s   .pixelNotSolid2
                                                      *         subq.b  #1,d2
                                                      * .pixelNotSolid2:
                                                      *         dbf     d1,.processColumnLoop2
                                                      * 
                                                      *         bra.s   .columnProcessed
                                                      * ; ===========================================================================
                                                      * .entireColumnSolid:
                                                      *         move.w  #16,d0
                                                      * 
                                                      * ; loc_1EB78:
                                                      * .noCollision:
                                                      *         move.w  d0,d2
                                                      * 
                                                      * ; loc_1EB7A:
                                                      * .columnProcessed:
                                                      *         move.b  d2,(a2)+        ; Store column collision height to ROM
                                                      *         dbf     d3,.processCollisionArrayLoop
                                                      * 
                                                      *         rts
                                                      * 
                                                      * ; End of function ConvertCollisionArray
                                                      * 
                                                      *     if gameRevision<2
                                                      *         nop
                                                      *     endif
                                                      * 
                                                      * 
                                                      * 
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to calculate how much space is in front of Sonic or Tails on the ground
                                                      * ; d0 = some input angle
                                                      * ; d1 = output about how many pixels (up to some high enough amount)
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EB84: Sonic_WalkSpeed:
                                                      * CalcRoomInFront:
                                                      *         move.l  #Primary_Collision,(Collision_addr).w
                                                      *         cmpi.b  #$C,top_solid_bit(a0)
                                                      *         beq.s   +
                                                      *         move.l  #Secondary_Collision,(Collision_addr).w
                                                      * +
                                                      *         move.b  lrb_solid_bit(a0),d5                    ; Want walls or ceilings
                                                      *         move.l  x_pos(a0),d3
                                                      *         move.l  y_pos(a0),d2
                                                      *         move.w  x_vel(a0),d1
                                                      *         ext.l   d1
                                                      *         asl.l   #8,d1
                                                      *         add.l   d1,d3
                                                      *         move.w  y_vel(a0),d1
                                                      *         ext.l   d1
                                                      *         asl.l   #8,d1
                                                      *         add.l   d1,d2
                                                      *         swap    d2
                                                      *         swap    d3
                                                      *         move.b  d0,(Primary_Angle).w
                                                      *         move.b  d0,(Secondary_Angle).w
                                                      *         move.b  d0,d1
                                                      *         addi.b  #$20,d0
                                                      *         bpl.s   loc_1EBDC
                                                      * 
                                                      *         move.b  d1,d0
                                                      *         bpl.s   +
                                                      *         subq.b  #1,d0
                                                      * +
                                                      *         addi.b  #$20,d0
                                                      *         bra.s   loc_1EBE6
                                                      * ; ---------------------------------------------------------------------------
                                                      * loc_1EBDC:
                                                      *         move.b  d1,d0
                                                      *         bpl.s   +
                                                      *         addq.b  #1,d0
                                                      * +
                                                      *         addi.b  #$1F,d0
                                                      * 
                                                      * loc_1EBE6:
                                                      *         andi.b  #$C0,d0
                                                      *         beq.w   CheckFloorDist_Part2            ; Player is going mostly down
                                                      *         cmpi.b  #$80,d0
                                                      *         beq.w   CheckCeilingDist_Part2          ; Player is going mostly up
                                                      *         andi.b  #$38,d1
                                                      *         bne.s   +
                                                      *         addq.w  #8,d2
                                                      * +
                                                      *         cmpi.b  #$40,d0
                                                      *         beq.w   CheckLeftWallDist_Part2         ; Player is going mostly left
                                                      *         bra.w   CheckRightWallDist_Part2        ; Player is going mostly right
                                                      * 
                                                      * ; End of function CalcRoomInFront
                                                      * 
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to calculate how much space is empty above Sonic's/Tails' head
                                                      * ; d0 = input angle perpendicular to the spine
                                                      * ; d1 = output about how many pixels are overhead (up to some high enough amount)
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; sub_1EC0A:
CalcRoomOverHead                                      * CalcRoomOverHead:
                                                      *         move.l  #Primary_Collision,(Collision_addr).w
                                                      *         cmpi.b  #$C,top_solid_bit(a0)
                                                      *         beq.s   +
                                                      *         move.l  #Secondary_Collision,(Collision_addr).w
                                                      * +
                                                      *         move.b  lrb_solid_bit(a0),d5
                                                      *         move.b  d0,(Primary_Angle).w
                                                      *         move.b  d0,(Secondary_Angle).w
                                                      *         addi.b  #$20,d0
                                                      *         andi.b  #$C0,d0
                                                      *         cmpi.b  #$40,d0
                                                      *         beq.w   CheckLeftCeilingDist
                                                      *         cmpi.b  #$80,d0
                                                      *         beq.w   Sonic_CheckCeiling
                                                      *         cmpi.b  #$C0,d0
                                                      *         beq.w   CheckRightCeilingDist
                                                      * 
                                                      * ; End of function CalcRoomOverHead
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to check if Sonic/Tails is near the floor
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EC4E: Sonic_HitFloor:
Sonic_CheckFloor                                      * Sonic_CheckFloor:
                                                      *         move.l  #Primary_Collision,(Collision_addr).w
                                                      *         cmpi.b  #$C,top_solid_bit(a0)
                                                      *         beq.s   +
                                                      *         move.l  #Secondary_Collision,(Collision_addr).w
                                                      * +
                                                      *         move.b  top_solid_bit(a0),d5
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.w  d1,-(sp)
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d3
                                                      *         lea     (Secondary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.w  (sp)+,d0
                                                      *         move.b  #0,d2
                                                      * 
loc_1ECC6                                             * loc_1ECC6:
                                                      *         move.b  (Secondary_Angle).w,d3
                                                      *         cmp.w   d0,d1
                                                      *         ble.s   loc_1ECD4
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         exg     d0,d1
                                                      * 
loc_1ECD4                                             * loc_1ECD4:
                                                      *         btst    #0,d3
                                                      *         beq.s   +
                                                      *         move.b  d2,d3
                                                      * +
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      *         ; a bit of unused/dead code here
                                                      * ;CheckFloorDist:
                                                      *         move.w  y_pos(a0),d2 ; a0=character
                                                      *         move.w  x_pos(a0),d3
                                                      * 
                                                      * ; Checks a 16x16 block to find solid ground. May check an additional
                                                      * ; 16x16 block up for ceilings.
                                                      * ; d2 = y_pos
                                                      * ; d3 = x_pos
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance in d1
                                                      * ; returns angle in d3, or zero if angle was odd
                                                      * ;loc_1ECE6:
CheckFloorDist_Part2                                  * CheckFloorDist_Part2:
                                                      *         addi.w  #$A,d2
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.b  #0,d2
                                                      * 
                                                      * ; d2 what to use as angle if (Primary_Angle).w is odd
                                                      * ; returns angle in d3, or value in d2 if angle was odd
loc_1ECFE                                             * loc_1ECFE:
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         btst    #0,d3
                                                      *         beq.s   +
                                                      *         move.b  d2,d3
                                                      * +
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      *         ; Unused collision checking subroutine
                                                      * 
                                                      *         move.w  x_pos(a0),d3 ; a0=character
                                                      *         move.w  y_pos(a0),d2
                                                      *         subq.w  #4,d2
                                                      *         move.l  #Primary_Collision,(Collision_addr).w
                                                      *         cmpi.b  #$D,lrb_solid_bit(a0)
                                                      *         beq.s   +
                                                      *         move.l  #Secondary_Collision,(Collision_addr).w
                                                      * +
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         move.b  #0,(a4)
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         move.b  lrb_solid_bit(a0),d5
                                                      *         bsr.w   FindFloor
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         btst    #0,d3
                                                      *         beq.s   +
                                                      *         move.b  #0,d3
                                                      * +
                                                      *         rts
                                                      * 
                                                      * ; ===========================================================================
                                                      * ; loc_1ED56:
ChkFloorEdge                                          * ChkFloorEdge:
                                                      *         move.w  x_pos(a0),d3
                                                      * ; loc_1ED5A:
ChkFloorEdge_Part2                                    * ChkFloorEdge_Part2:
                                                      *         move.w  y_pos(a0),d2
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.l  #Primary_Collision,(Collision_addr).w
                                                      *         cmpi.b  #$C,top_solid_bit(a0)
                                                      *         beq.s   +
                                                      *         move.l  #Secondary_Collision,(Collision_addr).w
                                                      * +
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         move.b  #0,(a4)
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         move.b  top_solid_bit(a0),d5
                                                      *         bsr.w   FindFloor
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         btst    #0,d3
                                                      *         beq.s   +
                                                      *         move.b  #0,d3
                                                      * +
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ; Identical to ChkFloorEdge except that this uses a1 instead of a0
                                                      * ;loc_1EDA8:
ChkFloorEdge2                                         * ChkFloorEdge2:
                                                      *         move.w  x_pos(a1),d3
                                                      *         move.w  y_pos(a1),d2
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a1),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.l  #Primary_Collision,(Collision_addr).w
                                                      *         cmpi.b  #$C,top_solid_bit(a1)
                                                      *         beq.s   +
                                                      *         move.l  #Secondary_Collision,(Collision_addr).w
                                                      * +
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         move.b  #0,(a4)
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         move.b  top_solid_bit(a1),d5
                                                      *         bsr.w   FindFloor
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         btst    #0,d3
                                                      *         beq.s   return_1EDF8
                                                      *         move.b  #0,d3
                                                      * 
return_1EDF8                                          * return_1EDF8:
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine checking if an object should interact with the floor
                                                      * ; (objects such as a monitor Sonic bumps from underneath)
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EDFA: ObjHitFloor:
ObjCheckFloorDist                                     * ObjCheckFloorDist:
                                                      *         move.w  x_pos(a0),d3
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         move.b  #0,(a4)
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         moveq   #$C,d5
                                                      *         bsr.w   FindFloor
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         btst    #0,d3
                                                      *         beq.s   +
                                                      *         move.b  #0,d3
                                                      * +
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Collision check used to let the HTZ boss fire attack to hit the ground
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EE30:
                                                      * FireCheckFloorDist:
                                                      *         move.w  x_pos(a1),d3
                                                      *         move.w  y_pos(a1),d2
                                                      *         move.b  y_radius(a1),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         move.b  #0,(a4)
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         moveq   #$C,d5
                                                      *         bra.w   FindFloor
                                                      * ; End of function FireCheckFloorDist
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Collision check used to let scattered rings bounce on the ground
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EE56:
                                                      * RingCheckFloorDist:
                                                      *         move.w  x_pos(a0),d3
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         move.b  #0,(a4)
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         moveq   #$C,d5
                                                      *         bra.w   Ring_FindFloor
                                                      * ; End of function RingCheckFloorDist
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Stores a distance to the nearest wall above Sonic/Tails,
                                                      * ; where "above" = right, into d1
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EE7C:
CheckRightCeilingDist                                 * CheckRightCeilingDist:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindWall
                                                      *         move.w  d1,-(sp)
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Secondary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindWall
                                                      *         move.w  (sp)+,d0
                                                      *         move.b  #-$40,d2
                                                      *         bra.w   loc_1ECC6
                                                      * ; End of function CheckRightCeilingDist
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Stores a distance to the nearest wall on the right of Sonic/Tails into d1
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; Checks a 16x16 block to find solid walls. May check an additional
                                                      * ; 16x16 block up for walls.
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance in d1
                                                      * ; returns angle in d3, or zero if angle was odd
                                                      * ; sub_1EEDC:
                                                      * CheckRightWallDist:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      * ; loc_1EEE4:
                                                      * CheckRightWallDist_Part2:
                                                      *         addi.w  #$A,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         bsr.w   FindWall
                                                      *         move.b  #$C0,d2
                                                      *         bra.w   loc_1ECFE
                                                      * ; End of function CheckRightWallDist
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EF00: ObjCheckLeftWallDist:
                                                      * ObjCheckRightWallDist:
                                                      *         add.w   x_pos(a0),d3
                                                      *         move.w  y_pos(a0),d2
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         move.b  #0,(a4)
                                                      *         movea.w #$10,a3
                                                      *         move.w  #0,d6
                                                      *         moveq   #$D,d5
                                                      *         bsr.w   FindWall
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         btst    #0,d3
                                                      *         beq.s   +
                                                      *         move.b  #-$40,d3
                                                      * +
                                                      *         rts
                                                      * ; End of function ObjCheckRightWallDist
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Stores a distance from Sonic/Tails to the nearest ceiling into d1
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EF2E: Sonic_DontRunOnWalls: CheckCeilingDist:
Sonic_CheckCeiling                                    * Sonic_CheckCeiling:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d2
                                                      *         eori.w  #$F,d2 ; flip position upside-down within the current 16x16 block?
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$800,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.w  d1,-(sp)
                                                      * 
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d2
                                                      *         eori.w  #$F,d2
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d3
                                                      *         lea     (Secondary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$800,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.w  (sp)+,d0
                                                      * 
                                                      *         move.b  #$80,d2
                                                      *         bra.w   loc_1ECC6
                                                      * ; End of function Sonic_CheckCeiling
                                                      * 
                                                      * ; ===========================================================================
                                                      *         ; a bit of unused/dead code here
                                                      * ;CheckCeilingDist:
                                                      *         move.w  y_pos(a0),d2 ; a0=character
                                                      *         move.w  x_pos(a0),d3
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; Checks a 16x16 block to find solid ceiling. May check an additional
                                                      * ; 16x16 block up for ceilings.
                                                      * ; d2 = y_pos
                                                      * ; d3 = x_pos
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance in d1
                                                      * ; returns angle in d3, or zero if angle was odd
                                                      * ; loc_1EF9E: CheckSlopeDist:
                                                      * CheckCeilingDist_Part2:
                                                      *         subi.w  #$A,d2
                                                      *         eori.w  #$F,d2
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$800,d6
                                                      *         bsr.w   FindFloor
                                                      *         move.b  #$80,d2
                                                      *         bra.w   loc_1ECFE
                                                      * ; End of function CheckCeilingDist
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Stores a distance to the nearest wall above the object into d1
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EFBE: ObjHitCeiling:
                                                      * ObjCheckCeilingDist:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d2
                                                      *         eori.w  #$F,d2
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$800,d6
                                                      *         moveq   #$D,d5
                                                      *         bsr.w   FindFloor
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         btst    #0,d3
                                                      *         beq.s   +
                                                      *         move.b  #$80,d3
                                                      * +
                                                      *         rts
                                                      * ; End of function ObjCheckCeilingDist
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Stores a distance to the nearest wall above Sonic/Tails,
                                                      * ; where "above" = left, into d1
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1EFF6:
CheckLeftCeilingDist:                                 * CheckLeftCeilingDist:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d3
                                                      *         eori.w  #$F,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$400,d6
                                                      *         bsr.w   FindWall
                                                      *         move.w  d1,-(sp)
                                                      * 
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      *         moveq   #0,d0
                                                      *         move.b  x_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         add.w   d0,d2
                                                      *         move.b  y_radius(a0),d0
                                                      *         ext.w   d0
                                                      *         sub.w   d0,d3
                                                      *         eori.w  #$F,d3
                                                      *         lea     (Secondary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$400,d6
                                                      *         bsr.w   FindWall
                                                      *         move.w  (sp)+,d0
                                                      *         move.b  #$40,d2
                                                      *         bra.w   loc_1ECC6
                                                      * ; End of function CheckLeftCeilingDist
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Stores a distance to the nearest wall on the left of Sonic/Tails into d1
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; Checks a 16x16 block to find solid walls. May check an additional
                                                      * ; 16x16 block up for walls.
                                                      * ; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
                                                      * ; returns relevant block ID in (a1)
                                                      * ; returns distance in d1
                                                      * ; returns angle in d3, or zero if angle was odd
                                                      * ; loc_1F05E: Sonic_HitWall:
                                                      * CheckLeftWallDist:
                                                      *         move.w  y_pos(a0),d2
                                                      *         move.w  x_pos(a0),d3
                                                      * ; loc_1F066:
                                                      * CheckLeftWallDist_Part2:
                                                      *         subi.w  #$A,d3
                                                      *         eori.w  #$F,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$400,d6
                                                      *         bsr.w   FindWall
                                                      *         move.b  #$40,d2
                                                      *         bra.w   loc_1ECFE
                                                      * ; End of function CheckLeftWallDist
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_1F086: ObjCheckRightWallDist:
                                                      * ObjCheckLeftWallDist:
                                                      *         add.w   x_pos(a0),d3
                                                      *         move.w  y_pos(a0),d2
                                                      *         ; Engine bug: colliding with left walls is erratic with this function.
                                                      *         ; The cause is this: a missing instruction to flip collision on the found
                                                      *         ; 16x16 block; this one:
                                                      *         ;eori.w #$F,d3
                                                      *         lea     (Primary_Angle).w,a4
                                                      *         move.b  #0,(a4)
                                                      *         movea.w #-$10,a3
                                                      *         move.w  #$400,d6
                                                      *         moveq   #$D,d5
                                                      *         bsr.w   FindWall
                                                      *         move.b  (Primary_Angle).w,d3
                                                      *         btst    #0,d3
                                                      *         beq.s   +
                                                      *         move.b  #$40,d3
                                                      * +
                                                      *         rts

; ***************************************************************************************************************************************************

                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Object touch response subroutine - $20(a0) in the object RAM
                                                      * ; collides Sonic with most objects (enemies, rings, monitors...) in the level
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_3F554:
                                                      * TouchResponse:
                                                      *         nop
                                                      *         jsrto   (Touch_Rings).l, JmpTo_Touch_Rings
                                                      *         ; Bumpers in CNZ
                                                      *         cmpi.b  #casino_night_zone,(Current_Zone).w
                                                      *         bne.s   +
                                                      *         jsrto   (Check_CNZ_bumpers).l, JmpTo_Check_CNZ_bumpers
                                                      * +
                                                      *         tst.b   (Current_Boss_ID).w
                                                      *         bne.w   Touch_Boss
                                                      *         move.w  x_pos(a0),d2 ; load Sonic's position into d2,d3
                                                      *         move.w  y_pos(a0),d3
                                                      *         subi_.w #8,d2
                                                      *         moveq   #0,d5
                                                      *         move.b  y_radius(a0),d5
                                                      *         subq.b  #3,d5
                                                      *         sub.w   d5,d3
                                                      *         cmpi.b  #$4D,mapping_frame(a0)  ; is Sonic ducking?
                                                      *         bne.s   Touch_NoDuck            ; if not, branch
                                                      *         addi.w  #$C,d3
                                                      *         moveq   #$A,d5
                                                      * ; loc_3F592:
                                                      * Touch_NoDuck:
                                                      *         move.w  #$10,d4
                                                      *         add.w   d5,d5
                                                      *         lea     (Dynamic_Object_RAM).w,a1
                                                      *         move.w  #(Dynamic_Object_RAM_End-Dynamic_Object_RAM)/object_size-1,d6
                                                      * ; loc_3F5A0:
                                                      * Touch_Loop:
                                                      *         move.b  collision_flags(a1),d0
                                                      *         bne.w   Touch_Width
                                                      * ; loc_3F5A8:
                                                      * Touch_NextObj:
                                                      *         lea     next_object(a1),a1 ; load obj address ; goto next object
                                                      *         dbf     d6,Touch_Loop ; repeat 6F more times
                                                      * 
                                                      *         moveq   #0,d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_3F5B4: Touch_Height:
                                                      * Touch_Width:
                                                      *         andi.w  #$3F,d0
                                                      *         add.w   d0,d0
                                                      *         lea     Touch_Sizes(pc,d0.w),a2
                                                      *         moveq   #0,d1
                                                      *         move.b  (a2)+,d1
                                                      *         move.w  x_pos(a1),d0
                                                      *         sub.w   d1,d0
                                                      *         sub.w   d2,d0
                                                      *         bcc.s   loc_3F5D6
                                                      *         add.w   d1,d1
                                                      *         add.w   d1,d0
                                                      *         bcs.s   Touch_Height
                                                      *         bra.w   Touch_NextObj
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F5D6:
                                                      *         cmp.w   d4,d0
                                                      *         bhi.w   Touch_NextObj
                                                      * ; loc_3F5DC: Touch_Width:
                                                      * Touch_Height:
                                                      *         moveq   #0,d1
                                                      *         move.b  (a2)+,d1
                                                      *         move.w  y_pos(a1),d0
                                                      *         sub.w   d1,d0
                                                      *         sub.w   d3,d0
                                                      *         bcc.s   loc_3F5F6
                                                      *         add.w   d1,d1
                                                      *         add.w   d1,d0
                                                      *         bcs.w   Touch_ChkValue
                                                      *         bra.w   Touch_NextObj
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F5F6:
                                                      *         cmp.w   d5,d0
                                                      *         bhi.w   Touch_NextObj
                                                      *         bra.w   Touch_ChkValue
                                                      * ; ===========================================================================
                                                      * ; collision sizes (width,height)
                                                      * ; byte_3F600:
                                                      * Touch_Sizes:
                                                      *         dc.b   4,  4    ;   0
                                                      *         dc.b $14,$14    ;   1
                                                      *         dc.b  $C,$14    ;   2
                                                      *         dc.b $14, $C    ;   3
                                                      *         dc.b   4,$10    ;   4
                                                      *         dc.b  $C,$12    ;   5
                                                      *         dc.b $10,$10    ;   6 - monitors
                                                      *         dc.b   6,  6    ;   7 - rings
                                                      *         dc.b $18, $C    ;   8
                                                      *         dc.b  $C,$10    ;   9
                                                      *         dc.b $10,  8    ;  $A
                                                      *         dc.b   8,  8    ;  $B
                                                      *         dc.b $14,$10    ;  $C
                                                      *         dc.b $14,  8    ;  $D
                                                      *         dc.b  $E, $E    ;  $E
                                                      *         dc.b $18,$18    ;  $F
                                                      *         dc.b $28,$10    ; $10
                                                      *         dc.b $10,$18    ; $11
                                                      *         dc.b   8,$10    ; $12
                                                      *         dc.b $20,$70    ; $13
                                                      *         dc.b $40,$20    ; $14
                                                      *         dc.b $80,$20    ; $15
                                                      *         dc.b $20,$20    ; $16
                                                      *         dc.b   8,  8    ; $17
                                                      *         dc.b   4,  4    ; $18
                                                      *         dc.b $20,  8    ; $19
                                                      *         dc.b  $C, $C    ; $1A
                                                      *         dc.b   8,  4    ; $1B
                                                      *         dc.b $18,  4    ; $1C
                                                      *         dc.b $28,  4    ; $1D
                                                      *         dc.b   4,  8    ; $1E
                                                      *         dc.b   4,$18    ; $1F
                                                      *         dc.b   4,$28    ; $20
                                                      *         dc.b   4,$10    ; $21
                                                      *         dc.b $18,$18    ; $22
                                                      *         dc.b  $C,$18    ; $23
                                                      *         dc.b $48,  8    ; $24
                                                      *         dc.b $18,$28    ; $25
                                                      *         dc.b $10,  4    ; $26
                                                      *         dc.b $20,  2    ; $27
                                                      *         dc.b   4,$40    ; $28
                                                      *         dc.b $18,$80    ; $29
                                                      *         dc.b $20,$10    ; $2A
                                                      *         dc.b $10,$20    ; $2B
                                                      *         dc.b $10,$30    ; $2C
                                                      *         dc.b $10,$40    ; $2D
                                                      *         dc.b $10,$50    ; $2E
                                                      *         dc.b $10,  2    ; $2F
                                                      *         dc.b $10,  1    ; $30
                                                      *         dc.b   2,  8    ; $31
                                                      *         dc.b $20,$1C    ; $32
                                                      * ; ===========================================================================
                                                      * ; loc_3F666:
                                                      * Touch_Boss:
                                                      *         lea     Touch_Sizes(pc),a3
                                                      *         move.w  x_pos(a0),d2
                                                      *         move.w  y_pos(a0),d3
                                                      *         subi_.w #8,d2
                                                      *         moveq   #0,d5
                                                      *         move.b  y_radius(a0),d5
                                                      *         subq.b  #3,d5
                                                      *         sub.w   d5,d3
                                                      *         cmpi.b  #$4D,mapping_frame(a0)
                                                      *         bne.s   +
                                                      *         addi.w  #$C,d3
                                                      *         moveq   #$A,d5
                                                      * +
                                                      *         move.w  #$10,d4
                                                      *         add.w   d5,d5
                                                      *         lea     (Dynamic_Object_RAM).w,a1
                                                      *         move.w  #(Dynamic_Object_RAM_End-Dynamic_Object_RAM)/object_size-1,d6
                                                      * 
                                                      * loc_3F69C:
                                                      *         move.b  collision_flags(a1),d0
                                                      *         bne.s   loc_3F6AE
                                                      * 
                                                      * loc_3F6A2:
                                                      *         lea     next_object(a1),a1 ; a1=object
                                                      *         dbf     d6,loc_3F69C
                                                      * 
                                                      *         moveq   #0,d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F6AE:
                                                      *         bsr.w   BossSpecificCollision
                                                      *         andi.w  #$3F,d0
                                                      *         beq.s   loc_3F6A2
                                                      *         add.w   d0,d0
                                                      *         lea     (a3,d0.w),a2
                                                      *         moveq   #0,d1
                                                      *         move.b  (a2)+,d1
                                                      *         move.w  x_pos(a1),d0
                                                      *         sub.w   d1,d0
                                                      *         sub.w   d2,d0
                                                      *         bcc.s   loc_3F6D4
                                                      *         add.w   d1,d1
                                                      *         add.w   d1,d0
                                                      *         bcs.s   loc_3F6D8
                                                      *         bra.s   loc_3F6A2
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F6D4:
                                                      *         cmp.w   d4,d0
                                                      *         bhi.s   loc_3F6A2
                                                      * 
                                                      * loc_3F6D8:
                                                      *         moveq   #0,d1
                                                      *         move.b  (a2)+,d1
                                                      *         move.w  y_pos(a1),d0
                                                      *         sub.w   d1,d0
                                                      *         sub.w   d3,d0
                                                      *         bcc.s   loc_3F6EE
                                                      *         add.w   d1,d1
                                                      *         add.w   d1,d0
                                                      *         bcs.s   Touch_ChkValue
                                                      *         bra.s   loc_3F6A2
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F6EE:
                                                      *         cmp.w   d5,d0
                                                      *         bhi.s   loc_3F6A2
                                                      * ; loc_3F6F2:
                                                      * Touch_ChkValue:
                                                      *         move.b  collision_flags(a1),d1  ; load touch response number
                                                      *         andi.b  #$C0,d1                 ; is touch response $40 or higher?
                                                      *         beq.w   Touch_Enemy             ; if not, branch
                                                      *         cmpi.b  #$C0,d1                 ; is touch response $C0 or higher?
                                                      *         beq.w   Touch_Special           ; if yes, branch
                                                      *         tst.b   d1                      ; is touch response $80-$BF ?
                                                      *         bmi.w   Touch_ChkHurt           ; if yes, branch
                                                      *         ; touch response is $40-$7F
                                                      *         move.b  collision_flags(a1),d0
                                                      *         andi.b  #$3F,d0
                                                      *         cmpi.b  #6,d0                   ; is touch response $46 ?
                                                      *         beq.s   Touch_Monitor           ; if yes, branch
                                                      *         move.w  (MainCharacter+invulnerable_time).w,d0
                                                      *         tst.w   (Two_player_mode).w
                                                      *         beq.s   +
                                                      *         move.w  invulnerable_time(a0),d0
                                                      * +
                                                      *         cmpi.w  #90,d0
                                                      *         bhs.w   +
                                                      *         move.b  #4,routine(a1)  ; set the object's routine counter
                                                      *         move.w  a0,parent(a1)
                                                      * +
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_3F73C:
                                                      * Touch_Monitor:
                                                      *         tst.w   y_vel(a0)       ; is Sonic moving upwards?
                                                      *         bpl.s   loc_3F768       ; if not, branch
                                                      *         move.w  y_pos(a0),d0
                                                      *         subi.w  #$10,d0
                                                      *         cmp.w   y_pos(a1),d0
                                                      *         blo.s   return_3F78A
                                                      *         neg.w   y_vel(a0)       ; reverse Sonic's y-motion
                                                      *         move.w  #-$180,y_vel(a1)
                                                      *         tst.b   routine_secondary(a1)
                                                      *         bne.s   return_3F78A
                                                      *         move.b  #4,routine_secondary(a1) ; set the monitor's routine counter
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F768:
                                                      *         cmpa.w  #MainCharacter,a0
                                                      *         beq.s   +
                                                      *         tst.w   (Two_player_mode).w
                                                      *         beq.s   return_3F78A
                                                      * +
                                                      *         cmpi.b  #AniIDSonAni_Roll,anim(a0)
                                                      *         bne.s   return_3F78A
                                                      *         neg.w   y_vel(a0)       ; reverse Sonic's y-motion
                                                      *         move.b  #4,routine(a1)
                                                      *         move.w  a0,parent(a1)
                                                      * 
                                                      * return_3F78A:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_3F78C:
                                                      * Touch_Enemy:
                                                      *         btst    #status_sec_isInvincible,status_secondary(a0)   ; is Sonic invincible?
                                                      *         bne.s   +                       ; if yes, branch
                                                      *         cmpi.b  #AniIDSonAni_Spindash,anim(a0)
                                                      *         beq.s   +
                                                      *         cmpi.b  #AniIDSonAni_Roll,anim(a0)              ; is Sonic rolling?
                                                      *         bne.w   Touch_ChkHurt           ; if not, branch
                                                      * +
                                                      *         btst    #6,render_flags(a1)
                                                      *         beq.s   Touch_Enemy_Part2
                                                      *         tst.b   boss_hitcount2(a1)
                                                      *         beq.s   return_3F7C6
                                                      *         neg.w   x_vel(a0)
                                                      *         neg.w   y_vel(a0)
                                                      *         move.b  #0,collision_flags(a1)
                                                      *         subq.b  #1,boss_hitcount2(a1)
                                                      * 
                                                      * return_3F7C6:
                                                      *         rts
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; loc_3F7C8:
                                                      * Touch_Enemy_Part2:
                                                      *         tst.b   collision_property(a1)
                                                      *         beq.s   Touch_KillEnemy
                                                      *         neg.w   x_vel(a0)
                                                      *         neg.w   y_vel(a0)
                                                      *         move.b  #0,collision_flags(a1)
                                                      *         subq.b  #1,collision_property(a1)
                                                      *         bne.s   return_3F7E8
                                                      *         bset    #7,status(a1)
                                                      * 
                                                      * return_3F7E8:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_3F7EA:
                                                      * Touch_KillEnemy:
                                                      *         bset    #7,status(a1)
                                                      *         moveq   #0,d0
                                                      *         move.w  (Chain_Bonus_counter).w,d0
                                                      *         addq.w  #2,(Chain_Bonus_counter).w      ; add 2 to chain bonus counter
                                                      *         cmpi.w  #6,d0
                                                      *         blo.s   loc_3F802
                                                      *         moveq   #6,d0
                                                      * 
                                                      * loc_3F802:
                                                      *         move.w  d0,objoff_3E(a1)
                                                      *         move.w  Enemy_Points(pc,d0.w),d0
                                                      *         cmpi.w  #$20,(Chain_Bonus_counter).w    ; have 16 enemies been destroyed?
                                                      *         blo.s   loc_3F81C                       ; if not, branch
                                                      *         move.w  #1000,d0                        ; fix bonus to 10000 points
                                                      *         move.w  #$A,objoff_3E(a1)
                                                      * 
                                                      * loc_3F81C:
                                                      *         movea.w a0,a3
                                                      *         bsr.w   AddPoints2
                                                      *         _move.b #ObjID_Explosion,id(a1) ; load obj
                                                      *         move.b  #0,routine(a1)
                                                      *         tst.w   y_vel(a0)
                                                      *         bmi.s   loc_3F844
                                                      *         move.w  y_pos(a0),d0
                                                      *         cmp.w   y_pos(a1),d0
                                                      *         bhs.s   loc_3F84C
                                                      *         neg.w   y_vel(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F844:
                                                      *         addi.w  #$100,y_vel(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F84C:
                                                      *         subi.w  #$100,y_vel(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; byte_3F854:
                                                      * Enemy_Points:   dc.w 10, 20, 50, 100
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F85C:
                                                      *         bset    #7,status(a1)
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine for checking if Sonic/Tails should be hurt and hurting them if so
                                                      * ; note: sonic or tails must be at a0
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_3F862:
                                                      * Touch_ChkHurt:
                                                      *         btst    #status_sec_isInvincible,status_secondary(a0)   ; is Sonic invincible?
                                                      *         beq.s   Touch_Hurt              ; if not, branch
                                                      * ; loc_3F86A:
                                                      * Touch_NoHurt:
                                                      *         moveq   #-1,d0
                                                      *         rts
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; loc_3F86E:
                                                      * Touch_Hurt:
                                                      *         nop
                                                      *         tst.w   invulnerable_time(a0)
                                                      *         bne.s   Touch_NoHurt
                                                      *         movea.l a1,a2
                                                      * 
                                                      * ; End of function TouchResponse
                                                      * ; continue straight to HurtCharacter
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Hurting Sonic/Tails subroutine
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_3F878: HurtSonic:
                                                      * HurtCharacter:
                                                      *         move.w  (Ring_count).w,d0
                                                      *         cmpa.w  #MainCharacter,a0
                                                      *         beq.s   loc_3F88C
                                                      *         tst.w   (Two_player_mode).w
                                                      *         beq.s   Hurt_Sidekick
                                                      *         move.w  (Ring_count_2P).w,d0
                                                      * 
                                                      * loc_3F88C:
                                                      *         btst    #status_sec_hasShield,status_secondary(a0)
                                                      *         bne.s   Hurt_Shield
                                                      *         tst.w   d0
                                                      *         beq.w   KillCharacter
                                                      *         jsr     (SingleObjLoad).l
                                                      *         bne.s   Hurt_Shield
                                                      *         _move.b #ObjID_LostRings,id(a1) ; load obj
                                                      *         move.w  x_pos(a0),x_pos(a1)
                                                      *         move.w  y_pos(a0),y_pos(a1)
                                                      *         move.w  a0,parent(a1)
                                                      * 
                                                      * ; loc_3F8B8:
                                                      * Hurt_Shield:
                                                      *         bclr    #status_sec_hasShield,status_secondary(a0) ; remove shield
                                                      * 
                                                      * ; loc_3F8BE:
                                                      * Hurt_Sidekick:
                                                      *         move.b  #4,routine(a0)
                                                      *         jsrto   (Sonic_ResetOnFloor_Part2).l, JmpTo_Sonic_ResetOnFloor_Part2
                                                      *         bset    #1,status(a0)
                                                      *         move.w  #-$400,y_vel(a0) ; make Sonic bounce away from the object
                                                      *         move.w  #-$200,x_vel(a0)
                                                      *         btst    #6,status(a0)   ; underwater?
                                                      *         beq.s   Hurt_Reverse    ; if not, branch
                                                      *         move.w  #-$200,y_vel(a0) ; bounce slower
                                                      *         move.w  #-$100,x_vel(a0)
                                                      * 
                                                      * ; loc_3F8EE:
                                                      * Hurt_Reverse:
                                                      *         move.w  x_pos(a0),d0
                                                      *         cmp.w   x_pos(a2),d0
                                                      *         blo.s   Hurt_ChkSpikes  ; if Sonic is left of the object, branch
                                                      *         neg.w   x_vel(a0)       ; if Sonic is right of the object, reverse
                                                      * 
                                                      * ; loc_3F8FC:
                                                      * Hurt_ChkSpikes:
                                                      *         move.w  #0,inertia(a0)
                                                      *         move.b  #AniIDSonAni_Hurt2,anim(a0)
                                                      *         move.w  #$78,invulnerable_time(a0)
                                                      *         move.w  #SndID_Hurt,d0  ; load normal damage sound
                                                      *         cmpi.b  #ObjID_Spikes,(a2)      ; was damage caused by spikes?
                                                      *         bne.s   Hurt_Sound      ; if not, branch
                                                      *         move.w  #SndID_HurtBySpikes,d0  ; load spikes damage sound
                                                      * 
                                                      * ; loc_3F91C:
                                                      * Hurt_Sound:
                                                      *         jsr     (PlaySound).l
                                                      *         moveq   #-1,d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to kill Sonic or Tails
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; loc_3F926: KillSonic:
KillCharacter                                         * KillCharacter:
                                                      *         tst.w   (Debug_placement_mode).w
                                                      *         bne.s   ++
                                                      *         clr.b   status_secondary(a0)
                                                      *         move.b  #6,routine(a0)
                                                      *         jsrto   (Sonic_ResetOnFloor_Part2).l, JmpTo_Sonic_ResetOnFloor_Part2
                                                      *         bset    #1,status(a0)
                                                      *         move.w  #-$700,y_vel(a0)
                                                      *         move.w  #0,x_vel(a0)
                                                      *         move.w  #0,inertia(a0)
                                                      *         move.b  #AniIDSonAni_Death,anim(a0)
                                                      *         bset    #high_priority_bit,art_tile(a0)
                                                      *         move.w  #SndID_Hurt,d0
                                                      *         cmpi.b  #ObjID_Spikes,id(a2)
                                                      *         bne.s   +
                                                      *         move.w  #SndID_HurtBySpikes,d0
                                                      * +
                                                      *         jsr     (PlaySound).l
                                                      * +
                                                      *         moveq   #-1,d0
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_3F976:
                                                      * Touch_Special:
                                                      *         move.b  collision_flags(a1),d1
                                                      *         andi.b  #$3F,d1
                                                      *         cmpi.b  #6,d1
                                                      *         beq.s   loc_3FA00
                                                      *         cmpi.b  #7,d1
                                                      *         beq.w   loc_3FA18
                                                      *         cmpi.b  #$B,d1
                                                      *         beq.s   BranchTo_loc_3F85C
                                                      *         cmpi.b  #$A,d1
                                                      *         beq.s   loc_3FA00
                                                      *         cmpi.b  #$C,d1
                                                      *         beq.s   loc_3F9CE
                                                      *         cmpi.b  #$14,d1
                                                      *         beq.s   loc_3FA00
                                                      *         cmpi.b  #$15,d1
                                                      *         beq.s   loc_3FA00
                                                      *         cmpi.b  #$16,d1
                                                      *         beq.s   loc_3FA00
                                                      *         cmpi.b  #$17,d1
                                                      *         beq.s   loc_3FA00
                                                      *         cmpi.b  #$18,d1
                                                      *         beq.s   loc_3FA00
                                                      *         cmpi.b  #$1A,d1
                                                      *         beq.s   loc_3FA22
                                                      *         cmpi.b  #$21,d1
                                                      *         beq.s   loc_3FA12
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * BranchTo_loc_3F85C ; BranchTo
                                                      *         bra.w   loc_3F85C
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F9CE:
                                                      *         sub.w   d0,d5
                                                      *         cmpi.w  #8,d5
                                                      *         bhs.s   BranchTo_Touch_Enemy
                                                      *         move.w  x_pos(a1),d0
                                                      *         subq.w  #4,d0
                                                      *         btst    #0,status(a1)
                                                      *         beq.s   loc_3F9E8
                                                      *         subi.w  #$10,d0
                                                      * 
                                                      * loc_3F9E8:
                                                      *         sub.w   d2,d0
                                                      *         bcc.s   loc_3F9F4
                                                      *         addi.w  #$18,d0
                                                      *         bcs.s   BranchTo_Touch_ChkHurt
                                                      *         bra.s   BranchTo_Touch_Enemy
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3F9F4:
                                                      *         cmp.w   d4,d0
                                                      *         bhi.s   BranchTo_Touch_Enemy
                                                      * 
                                                      * BranchTo_Touch_ChkHurt ; BranchTo
                                                      *         bra.w   Touch_ChkHurt
                                                      * ; ===========================================================================
                                                      * 
                                                      * BranchTo_Touch_Enemy ; BranchTo
                                                      *         bra.w   Touch_Enemy
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FA00:
                                                      *         move.w  a0,d1
                                                      *         subi.w  #MainCharacter,d1
                                                      *         beq.s   +
                                                      *         addq.b  #1,collision_property(a1)
                                                      * +
                                                      *         addq.b  #1,collision_property(a1)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FA12:
                                                      *         addq.b  #1,collision_property(a1)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FA18:
                                                      *         move.b  #2,collision_property(a1)
                                                      *         bra.w   Touch_Enemy
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FA22:
                                                      *         move.b  #-1,collision_property(a1)
                                                      *         bra.w   Touch_Enemy
                                                      * ; ===========================================================================
                                                      * ; loc_3FA2C:
                                                      * BossSpecificCollision:
                                                      *         cmpi.b  #$F,d0
                                                      *         bne.s   +       ; rts
                                                      *         moveq   #0,d0
                                                      *         move.b  (Current_Boss_ID).w,d0
                                                      *         beq.s   +       ; rts
                                                      *         subq.w  #1,d0
                                                      *         add.w   d0,d0
                                                      *         move.w  BossCollision_Index(pc,d0.w),d0
                                                      *         jmp     BossCollision_Index(pc,d0.w)
                                                      * ; ===========================================================================
                                                      * +       rts
                                                      * ; ===========================================================================
                                                      * ; off_3FA48:
                                                      * BossCollision_Index:offsetTable ; jump depending on boss ID
                                                      *         offsetTableEntry.w BossCollision_EHZ_CPZ
                                                      *         offsetTableEntry.w BossCollision_EHZ_CPZ
                                                      *         offsetTableEntry.w BossCollision_HTZ
                                                      *         offsetTableEntry.w BossCollision_ARZ
                                                      *         offsetTableEntry.w BossCollision_MCZ
                                                      *         offsetTableEntry.w BossCollision_CNZ
                                                      *         offsetTableEntry.w BossCollision_MTZ
                                                      *         offsetTableEntry.w BossCollision_OOZ
                                                      *         offsetTableEntry.w return_3FA5E
                                                      * ; ===========================================================================
                                                      * ;loc_3FA5A:
                                                      * BossCollision_EHZ_CPZ:
                                                      *         move.b  collision_flags(a1),d0
                                                      * 
                                                      * return_3FA5E:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_3FA60:
                                                      * BossCollision_HTZ:
                                                      *         tst.b   (Boss_CollisionRoutine).w
                                                      *         bne.s   +
                                                      *         rts
                                                      * ; ---------------------------------------------------------------------------
                                                      * +
                                                      *         move.w  d7,-(sp)
                                                      *         moveq   #0,d1
                                                      *         move.b  objoff_15(a1),d1
                                                      *         subq.b  #2,d1
                                                      *         cmpi.b  #7,d1
                                                      *         bgt.s   loc_3FAA8
                                                      *         move.w  d1,d7
                                                      *         add.w   d7,d7
                                                      *         move.w  x_pos(a1),d0
                                                      *         btst    #0,render_flags(a1)
                                                      *         beq.s   loc_3FA8E
                                                      *         add.w   word_3FAB0(pc,d7.w),d0
                                                      *         bra.s   loc_3FA92
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FA8E:
                                                      *         sub.w   word_3FAB0(pc,d7.w),d0
                                                      * 
                                                      * loc_3FA92:
                                                      *         move.b  byte_3FAC0(pc,d1.w),d1
                                                      *         ori.l   #$40000,d1
                                                      *         move.w  y_pos(a1),d7
                                                      *         subi.w  #$1C,d7
                                                      *         bsr.w   Boss_DoCollision
                                                      * 
                                                      * loc_3FAA8:
                                                      *         move.w  (sp)+,d7
                                                      *         move.b  collision_flags(a1),d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * word_3FAB0:
                                                      *         dc.w   $1C
                                                      *         dc.w   $20      ; 1
                                                      *         dc.w   $28      ; 2
                                                      *         dc.w   $34      ; 3
                                                      *         dc.w   $3C      ; 4
                                                      *         dc.w   $44      ; 5
                                                      *         dc.w   $60      ; 6
                                                      *         dc.w   $70      ; 7
                                                      * byte_3FAC0:
                                                      *         dc.b   4
                                                      *         dc.b   4        ; 1
                                                      *         dc.b   8        ; 2
                                                      *         dc.b  $C        ; 3
                                                      *         dc.b $14        ; 4
                                                      *         dc.b $1C        ; 5
                                                      *         dc.b $24        ; 6
                                                      *         dc.b   8        ; 7
                                                      * ; ===========================================================================
                                                      * ;loc_3FAC8:
                                                      * BossCollision_ARZ:
                                                      *         move.w  d7,-(sp)
                                                      *         move.w  x_pos(a1),d0
                                                      *         move.w  y_pos(a1),d7
                                                      *         tst.b   (Boss_CollisionRoutine).w
                                                      *         beq.s   ++
                                                      *         addi_.w #4,d7
                                                      *         subi.w  #$50,d0
                                                      *         btst    #0,render_flags(a1)
                                                      *         beq.s   +
                                                      *         addi.w  #$A0,d0
                                                      * +
                                                      *         move.l  #$140010,d1
                                                      *         bsr.w   Boss_DoCollision
                                                      * +
                                                      *         move.w  (sp)+,d7
                                                      *         move.b  collision_flags(a1),d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_3FAFE:
                                                      * BossCollision_MCZ:
                                                      *         sf      boss_hurt_sonic(a1)
                                                      *         cmpi.b  #1,(Boss_CollisionRoutine).w
                                                      *         blt.s   BossCollision_MCZ2
                                                      * ; Boss_CollisionRoutine = 1, i.e. diggers pointing to the side
                                                      *         move.w  d7,-(sp)
                                                      *         move.w  x_pos(a1),d0
                                                      *         move.w  y_pos(a1),d7
                                                      *         addi_.w #4,d7
                                                      *         subi.w  #$30,d0
                                                      *         btst    #0,render_flags(a1)     ; left or right?
                                                      *         beq.s   +
                                                      *         addi.w  #$60,d0                 ; x+$30, otherwise x-$30
                                                      * +
                                                      *         move.l  #$40004,d1              ; heigth 4, width 4
                                                      *         bsr.w   Boss_DoCollision
                                                      *         move.w  (sp)+,d7
                                                      *         move.b  collision_flags(a1),d0
                                                      *         cmpi.w  #$78,invulnerable_time(a0)
                                                      *         bne.s   +       ; rts
                                                      *         st      boss_hurt_sonic(a1)     ; sonic has just been hurt flag
                                                      * +
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; Boss_CollisionRoutine = 0, i.e. diggers pointing towards top
                                                      * ;loc_3FB46:
                                                      * BossCollision_MCZ2:
                                                      *         move.w  d7,-(sp)
                                                      *         movea.w #$14,a5
                                                      *         movea.w #0,a4
                                                      * 
                                                      * -       move.w  x_pos(a1),d0
                                                      *         move.w  y_pos(a1),d7
                                                      *         subi.w  #$20,d7
                                                      *         add.w   a5,d0                   ; first check x+$14, second x-$14
                                                      *         move.l  #$100004,d1             ; heigth $10, width 4
                                                      *         bsr.w   Boss_DoCollision
                                                      *         movea.w #-$14,a5
                                                      *         adda_.w #1,a4
                                                      *         cmpa.w  #1,a4
                                                      *         beq.s   -                       ; jump back once for second check
                                                      *         move.w  (sp)+,d7
                                                      *         move.b  collision_flags(a1),d0
                                                      *         cmpi.w  #$78,invulnerable_time(a0)
                                                      *         bne.s   +       ; rts
                                                      *         st      boss_hurt_sonic(a1)     ; sonic has just been hurt flag
                                                      * +
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_3FB8A:
                                                      * BossCollision_CNZ:
                                                      *         tst.b   (Boss_CollisionRoutine).w
                                                      *         beq.s   ++
                                                      *         move.w  d7,-(sp)
                                                      *         move.w  x_pos(a1),d0
                                                      *         move.w  y_pos(a1),d7
                                                      *         addi.w  #$28,d7
                                                      *         move.l  #$80010,d1
                                                      *         cmpi.b  #1,(Boss_CollisionRoutine).w
                                                      *         beq.s   +
                                                      *         move.w  #$20,d1
                                                      *         subi_.w #8,d7
                                                      *         addi_.w #4,d0
                                                      * +
                                                      *         bsr.w   Boss_DoCollision
                                                      *         move.w  (sp)+,d7
                                                      * +
                                                      *         move.b  collision_flags(a1),d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_3FBC4:
                                                      * BossCollision_MTZ:
                                                      *         move.b  collision_flags(a1),d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_3FBCA:
                                                      * BossCollision_OOZ:
                                                      *         cmpi.b  #1,(Boss_CollisionRoutine).w
                                                      *         blt.s   loc_3FC46
                                                      *         beq.s   loc_3FC1C
                                                      *         move.w  d7,-(sp)
                                                      *         move.w  x_pos(a1),d0
                                                      *         move.w  y_pos(a1),d7
                                                      *         moveq   #0,d1
                                                      *         move.b  mainspr_mapframe(a1),d1
                                                      *         subq.b  #2,d1
                                                      *         add.w   d1,d1
                                                      *         btst    #0,render_flags(a1)
                                                      *         beq.s   loc_3FBF6
                                                      *         add.w   word_3FC10(pc,d1.w),d0
                                                      *         bra.s   loc_3FBFA
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FBF6:
                                                      *         sub.w   word_3FC10(pc,d1.w),d0
                                                      * 
                                                      * loc_3FBFA:
                                                      *         sub.w   word_3FC10+2(pc,d1.w),d7
                                                      *         move.l  #$60008,d1
                                                      *         bsr.w   Boss_DoCollision
                                                      *         move.w  (sp)+,d7
                                                      *         move.w  #0,d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * word_3FC10:
                                                      *         dc.w   $14,    0
                                                      *         dc.w   $10,  $10
                                                      *         dc.w   $10, -$10
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FC1C:
                                                      *         move.w  d7,-(sp)
                                                      *         move.w  x_pos(a1),d0
                                                      *         move.w  y_pos(a1),d7
                                                      *         moveq   #$10,d1
                                                      *         btst    #0,render_flags(a1)
                                                      *         beq.s   +
                                                      *         neg.w   d1
                                                      * +
                                                      *         sub.w   d1,d0
                                                      *         move.l  #$8000C,d1
                                                      *         bsr.w   loc_3FC7A
                                                      *         move.w  (sp)+,d7
                                                      *         move.b  #0,d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FC46:
                                                      *         move.b  collision_flags(a1),d0
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;loc_3FC4C:
                                                      *         ; d7 = y_boss, d3 = y_sonic, d1 (high word) = heigth
                                                      *         ; d0 = x_boss, d2 = x_sonic, d1 (low word)  = width
                                                      * Boss_DoCollision:
                                                      *         sub.w   d1,d0
                                                      *         sub.w   d2,d0
                                                      *         bcc.s   loc_3FC5A
                                                      *         add.w   d1,d1
                                                      *         add.w   d1,d0
                                                      *         bcs.s   loc_3FC5E
                                                      * 
                                                      * return_3FC58:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FC5A:
                                                      *         cmp.w   d4,d0
                                                      *         bhi.s   return_3FC58
                                                      * 
                                                      * loc_3FC5E:
                                                      *         swap    d1
                                                      *         sub.w   d1,d7
                                                      *         sub.w   d3,d7
                                                      *         bcc.s   loc_3FC70
                                                      *         add.w   d1,d1
                                                      *         add.w   d1,d7
                                                      *         bcs.w   Touch_ChkHurt
                                                      *         bra.s   return_3FC58
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FC70:
                                                      *         cmp.w   d5,d7
                                                      *         bhi.w   return_3FC58
                                                      *         bra.w   Touch_ChkHurt
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FC7A:
                                                      *         sub.w   d1,d0
                                                      *         sub.w   d2,d0
                                                      *         bcc.s   loc_3FC88
                                                      *         add.w   d1,d1
                                                      *         add.w   d1,d0
                                                      *         bcs.s   loc_3FC8C
                                                      * 
                                                      * return_3FC86:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FC88:
                                                      *         cmp.w   d4,d0
                                                      *         bhi.s   return_3FC86
                                                      * 
                                                      * loc_3FC8C:
                                                      *         swap    d1
                                                      *         sub.w   d1,d7
                                                      *         sub.w   d3,d7
                                                      *         bcc.s   loc_3FC9E
                                                      *         add.w   d1,d1
                                                      *         add.w   d1,d7
                                                      *         bcs.w   loc_3FCA4
                                                      *         bra.s   return_3FC86
                                                      * ; ===========================================================================
                                                      * 
                                                      * loc_3FC9E:
                                                      *         cmp.w   d5,d7
                                                      *         bhi.w   return_3FC86
                                                      * 
                                                      * loc_3FCA4:
                                                      *         neg.w   x_vel(a0)
                                                      *         neg.w   y_vel(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      *     if gameRevision<2
                                                      *         nop
                                                      *     endif
                                                      * 
                                                      *     if ~~removeJmpTos
                                                      * JmpTo_Sonic_ResetOnFloor_Part2 ; JmpTo
                                                      *         jmp     (Sonic_ResetOnFloor_Part2).l
                                                      * JmpTo_Check_CNZ_bumpers
                                                      *         jmp     (Check_CNZ_bumpers).l
                                                      * JmpTo_Touch_Rings ; JmpTo
                                                      *         jmp     (Touch_Rings).l
                                                      * 
                                                      *         align 4
                                                      *     endif
                                                      * 
                                                      * 
                                                      * 
                                                      * 
                                                      * ; ===========================================================================
                                                      * ;loc_3FCC4:
                                                      * AniArt_Load:
                                                      *         moveq   #0,d0
                                                      *         move.b  (Current_Zone).w,d0
                                                      *         add.w   d0,d0
                                                      *         add.w   d0,d0
                                                      *         move.w  PLC_DYNANM+2(pc,d0.w),d1
                                                      *         lea     PLC_DYNANM(pc,d1.w),a2
                                                      *         move.w  PLC_DYNANM(pc,d0.w),d0
                                                      *         jmp     PLC_DYNANM(pc,d0.w)
                                                      * ; ===========================================================================
                                                      *         rts
                                                      * ; ===========================================================================

Sonic_Animate
        jsr   Sonic_Animate_Do
        tstb
        bmi   SAnim_WalkRun
        rts
                                                      *; ===========================================================================
                                                      *; loc_1B3F4:
SAnim_WalkRun                                         *SAnim_WalkRun:
        incb                                          *  addq.b  #1,d0       ; is the start flag = $FF ?
        lbne  SAnim_Roll                              *  bne.w   SAnim_Roll  ; if not, branch
                                                      *  moveq   #0,d0       ; is animation walking/running?
        lda   flip_angle,u                            *  move.b  flip_angle(a0),d0   ; if not, branch
        lbne  SAnim_Tumble                            *  bne.w   SAnim_Tumble
        lda   #0
        sta   @d1                                     *  moveq   #0,d1
        ldb   angle,u                                 *  move.b  angle(a0),d0    ; get Sonic's angle
        bmi   >                                       *  bmi.s   +
        beq   >                                       *  beq.s   +
        decb                                          *  subq.b  #1,d0
!                                                     *+
        lda   status,u                                *  move.b  status(a0),d2
        anda  #status_x_orientation                   *  andi.b  #1,d2       ; is Sonic mirrored horizontally?
        bne   >                                       *  bne.s   +       ; if yes, branch
        negb                                          *  not.b   d0      ; reverse angle
!                                                     *+
        addb  #$10                                    *  addi.b  #$10,d0     ; add $10 to angle
        stb   @d0
        bpl   >                                       *  bpl.s   +       ; if angle is $0-$7F, branch
        ldb   #3
        stb   @d1                                     *  moveq   #3,d1
!                                                     *+
                                                      *  andi.b  #$FC,render_flags(a0)
        ldb   render_flags,u
        andb  #^(render_xmirror_mask|render_ymirror_mask) 
        eora  #0                                      *  eor.b   d1,d2
@d1     equ   *-1
        sta   @d2
        orb   @d2                                     *  or.b    d2,render_flags(a0)
        stb   render_flags,u
        lda   status,u
        bita  #status_pushing                         *  btst    #5,status(a0)
        lbne  SAnim_Push                              *  bne.w   SAnim_Push
        ; moved                                       *  lsr.b   #4,d0       ; divide angle by 16
        ; moved                                       *  andi.b  #6,d0       ; angle must be 0, 2, 4 or 6
        ldd   inertia,u                               *  mvabs.w inertia(a0),d2  ; get Sonic's "speed" for animation purposes
        bpl   >
        _negd
!
        ;                                             *    if status_sec_isSliding = 7
        tst   status_secondary,u                      *  tst.b   status_secondary(a0)
        bpl   >                                       *  bpl.w   +
        ;                                             *    else
        ;                                             *  btst    #status_sec_isSliding,status_secondary(a0)
        ;                                             *  beq.w   +
        ;                                             *    endif
        _lsld                                         *  add.w   d2,d2
!                                                     *+
        ; unimplemented                               *  tst.b   (Super_Sonic_flag).w
        ; unimplemented                               *  bne.s   SAnim_Super
        ldx   #Lkp_SonAni_Run                         *  lea (SonAni_Run).l,a1   ; use running animation
        cmpd  #$600                                   *  cmpi.w  #$600,d2        ; is Sonic at running speed?
        bhs   >                                       *  bhs.s   +               ; use running animation
        ldx   #Lkp_SonAni_Walk                        *  lea (SonAni_Walk).l,a1  ; if yes, branch
                                                      *  add.b   d0,d0
!                                                     *+
                                                      *  add.b   d0,d0
                                                      *  move.b  d0,d3
        std   @d2
        ldb   #0
@d0     equ   *-1
        lsrb
        lsrb
        lsrb
        lsrb
        andb  #6
        ldx   b,x
        stx   anim,u                                  *  add.b   d3,mapping_frame(a0)
        jsr   SAnim_WalkRun_Sub
        ldb   anim_frame_duration,u
        subb  Vint_Main_runcount
        stb   anim_frame_duration,u                   *  subq.b  #1,anim_frame_duration(a0)
        bpl   return_1B4AC                            *  bpl.s   return_1B4AC
        ldd   #0
@d2     equ   *-2
        _negd                                         *  neg.w   d2
        addd  #$800                                   *  addi.w  #$800,d2
        bpl   >                                       *  bpl.s   +
        ldd   #0                                      *  moveq   #0,d2
!                                                     *+
        ;                                             *  lsr.w   #8,d2
        sta   anim_frame_duration,u                   *  move.b  d2,anim_frame_duration(a0)  ; modify frame duration
        inc   anim_frame,u                            *  addq.b  #1,anim_frame(a0)       ; modify frame number
                                                      *
return_1B4AC                                          *return_1B4AC:
        rts                                           *  rts

Lkp_SonAni_Walk
        fdb   SonAni_Walk
        fdb   SonAni_Walk_1
        fdb   SonAni_Walk_2
        fdb   SonAni_Walk_3
Lkp_SonAni_Run
        fdb   SonAni_Run
        fdb   SonAni_Run_1
        fdb   SonAni_Run_2
        fdb   SonAni_Run_3

                                                      *; ===========================================================================
                                                      *; loc_1B4AE:
                                                      *SAnim_Super:
                                                      *  lea (SupSonAni_Run).l,a1    ; use fast animation
                                                      *  cmpi.w  #$800,d2        ; is Sonic moving fast?
                                                      *  bhs.s   SAnim_SuperRun      ; if yes, branch
                                                      *  lea (SupSonAni_Walk).l,a1   ; use slower animation
                                                      *  add.b   d0,d0
                                                      *  add.b   d0,d0
                                                      *  bra.s   SAnim_SuperWalk
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_1B4C6:
                                                      *SAnim_SuperRun:
                                                      *  lsr.b   #1,d0
                                                      *; loc_1B4C8:
                                                      *SAnim_SuperWalk:
                                                      *  move.b  d0,d3
                                                      *  moveq   #0,d1
                                                      *  move.b  anim_frame(a0),d1
                                                      *  move.b  1(a1,d1.w),d0
                                                      *  cmpi.b  #-1,d0
                                                      *  bne.s   +
                                                      *  move.b  #0,anim_frame(a0)
                                                      *  move.b  1(a1),d0
                                                      *+
                                                      *  move.b  d0,mapping_frame(a0)
                                                      *  add.b   d3,mapping_frame(a0)
                                                      *  move.b  (Timer_frames+1).w,d1
                                                      *  andi.b  #3,d1
                                                      *  bne.s   +
                                                      *  cmpi.b  #$B5,mapping_frame(a0)
                                                      *  bhs.s   +
                                                      *  addi.b  #$20,mapping_frame(a0)
                                                      *+
                                                      *  subq.b  #1,anim_frame_duration(a0)
                                                      *  bpl.s   return_1B51E
                                                      *  neg.w   d2
                                                      *  addi.w  #$800,d2
                                                      *  bpl.s   +
                                                      *  moveq   #0,d2
                                                      *+
                                                      *  lsr.w   #8,d2
                                                      *  move.b  d2,anim_frame_duration(a0)
                                                      *  addq.b  #1,anim_frame(a0)
                                                      *
                                                      *return_1B51E:
                                                      *  rts
                                                      *; ===========================================================================
                                                      *; loc_1B520:
SAnim_Tumble                                          *SAnim_Tumble:
                                                      *  move.b  flip_angle(a0),d0
                                                      *  moveq   #0,d1
                                                      *  move.b  status(a0),d2
                                                      *  andi.b  #1,d2
                                                      *  bne.s   SAnim_Tumble_Left
                                                      *
                                                      *  andi.b  #$FC,render_flags(a0)
                                                      *  addi.b  #$B,d0
                                                      *  divu.w  #$16,d0
                                                      *  addi.b  #$5F,d0
                                                      *  move.b  d0,mapping_frame(a0)
                                                      *  move.b  #0,anim_frame_duration(a0)
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; loc_1B54E:
SAnim_Tumble_Left                                     *SAnim_Tumble_Left:
                                                      *  andi.b  #$FC,render_flags(a0)
                                                      *  tst.b   flip_turned(a0)
                                                      *  beq.s   loc_1B566
                                                      *  ori.b   #1,render_flags(a0)
                                                      *  addi.b  #$B,d0
        bra   loc_1B572                               *  bra.s   loc_1B572
                                                      *; ===========================================================================
                                                      *
loc_1B566                                             *loc_1B566:
                                                      *  ori.b   #3,render_flags(a0)
                                                      *  neg.b   d0
                                                      *  addi.b  #$8F,d0
                                                      *
loc_1B572                                             *loc_1B572:
                                                      *  divu.w  #$16,d0
                                                      *  addi.b  #$5F,d0
                                                      *  move.b  d0,mapping_frame(a0)
                                                      *  move.b  #0,anim_frame_duration(a0)
        rts                                           *  rts
                                                      *; ===========================================================================
                                                      *; loc_1B586:
SAnim_Roll                                            *SAnim_Roll:
        lda   anim_frame_duration,u
        suba  Vint_Main_runcount
        sta   anim_frame_duration,u                   *  subq.b  #1,anim_frame_duration(a0)  ; subtract 1 from frame duration
        bmi   >                                       *  bpl.w   SAnim_Delay         ; if time remains, branch
        rts
!       incb                                          *  addq.b  #1,d0       ; is the start flag = $FE ?
        bne   SAnim_Push                              *  bne.s   SAnim_Push  ; if not, branch
        ldd   inertia,u                               *  mvabs.w inertia(a0),d2
        bpl   >
        _negd
!       ldx   #SonAni_Roll2                           *  lea (SonAni_Roll2).l,a1
        cmpd  #$600                                   *  cmpi.w  #$600,d2
        bhs   >                                       *  bhs.s   +
        ldx   #SonAni_Roll                            *  lea (SonAni_Roll).l,a1
!                                                     *+
        _negd                                         *  neg.w   d2
        addd  #$400                                   *  addi.w  #$400,d2
        bpl   >                                       *  bpl.s   +
        ldd   #0                                      *  moveq   #0,d2
!                                                     *+
        ;                                             *  lsr.w   #8,d2
        sta   anim_frame_duration,u                   *  move.b  d2,anim_frame_duration(a0)
        lda   status,u                                *  move.b  status(a0),d1
        anda  #status_x_orientation                   *  andi.b  #1,d1
        sta   @a
        ldb   render_flags,u
        andb  #^(render_xmirror_mask|render_ymirror_mask) *  andi.b  #$FC,render_flags(a0)
        orb   #0                                      *  or.b    d1,render_flags(a0)
@a      equ   *-1
        stb   render_flags,u
        jmp   Call_SAnim_Do2                          *  bra.w   SAnim_Do2
                                                      *; ===========================================================================
                                                      *

SAnim_Push                                            *SAnim_Push:
        lda   anim_frame_duration,u
        suba  Vint_Main_runcount
        sta   anim_frame_duration,u                   *  subq.b  #1,anim_frame_duration(a0)  ; subtract 1 from frame duration
        bmi   >                                       *  bpl.w   SAnim_Delay         ; if time remains, branch
        rts
!       ldd   inertia,u                               *  move.w  inertia(a0),d2
        bmi   >                                       *  bmi.s   +
        _negd                                         *  neg.w   d2
!                                                     *+
        addd  #$800                                   *  addi.w  #$800,d2
        bpl   >                                       *  bpl.s   +
        ldd   #0                                      *  moveq   #0,d2
!                                                     *+
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd                                         *  lsr.w   #6,d2
        std   anim_frame_duration,u                   *  move.b  d2,anim_frame_duration(a0)
        ldd   #SonAni_Push                            *  lea (SonAni_Push).l,a1
        ; unimplemented                               *  tst.b   (Super_Sonic_flag).w
        ;                                             *  beq.s   +
        ;                                             *  lea (SupSonAni_Push).l,a1
        ;                                             *+
        lda   status,u                                *  move.b  status(a0),d1
        anda  #status_x_orientation                   *  andi.b  #1,d1
        sta   @a
        ldb   render_flags,u
        andb  #^(render_xmirror_mask|render_ymirror_mask) *  andi.b  #$FC,render_flags(a0)
        orb   #0                                      *  or.b    d1,render_flags(a0)
@a      equ   *-1
        stb   render_flags,u
        jmp   Call_SAnim_Do2                          *  bra.w   SAnim_Do2

                                                      *; ===========================================================================
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Animation script - Sonic
                                                      *; ---------------------------------------------------------------------------
                                                      *; off_1B618:
                                                      *SonicAniData:         offsetTable
                                                      *SonAni_Walk_ptr:      offsetTableEntry.w SonAni_Walk      ;  0 ;   0
                                                      *SonAni_Run_ptr:           offsetTableEntry.w SonAni_Run       ;  1 ;   1
                                                      *SonAni_Roll_ptr:      offsetTableEntry.w SonAni_Roll      ;  2 ;   2
                                                      *SonAni_Roll2_ptr:     offsetTableEntry.w SonAni_Roll2     ;  3 ;   3
                                                      *SonAni_Push_ptr:      offsetTableEntry.w SonAni_Push      ;  4 ;   4
                                                      *SonAni_Wait_ptr:      offsetTableEntry.w SonAni_Wait      ;  5 ;   5
                                                      *SonAni_Balance_ptr:       offsetTableEntry.w SonAni_Balance   ;  6 ;   6
                                                      *SonAni_LookUp_ptr:        offsetTableEntry.w SonAni_LookUp    ;  7 ;   7
                                                      *SonAni_Duck_ptr:      offsetTableEntry.w SonAni_Duck      ;  8 ;   8
                                                      *SonAni_Spindash_ptr:      offsetTableEntry.w SonAni_Spindash  ;  9 ;   9
                                                      *SonAni_Blink_ptr:     offsetTableEntry.w SonAni_Blink     ; 10 ;  $A
                                                      *SonAni_GetUp_ptr:     offsetTableEntry.w SonAni_GetUp     ; 11 ;  $B
                                                      *SonAni_Balance2_ptr:      offsetTableEntry.w SonAni_Balance2  ; 12 ;  $C
                                                      *SonAni_Stop_ptr:      offsetTableEntry.w SonAni_Stop      ; 13 ;  $D
                                                      *SonAni_Float_ptr:     offsetTableEntry.w SonAni_Float     ; 14 ;  $E
                                                      *SonAni_Float2_ptr:        offsetTableEntry.w SonAni_Float2    ; 15 ;  $F
                                                      *SonAni_Spring_ptr:        offsetTableEntry.w SonAni_Spring    ; 16 ; $10
                                                      *SonAni_Hang_ptr:      offsetTableEntry.w SonAni_Hang      ; 17 ; $11
                                                      *SonAni_Dash2_ptr:     offsetTableEntry.w SonAni_Dash2     ; 18 ; $12
                                                      *SonAni_Dash3_ptr:     offsetTableEntry.w SonAni_Dash3     ; 19 ; $13
                                                      *SonAni_Hang2_ptr:     offsetTableEntry.w SonAni_Hang2     ; 20 ; $14
                                                      *SonAni_Bubble_ptr:        offsetTableEntry.w SonAni_Bubble    ; 21 ; $15
                                                      *SonAni_DeathBW_ptr:       offsetTableEntry.w SonAni_DeathBW   ; 22 ; $16
                                                      *SonAni_Drown_ptr:     offsetTableEntry.w SonAni_Drown     ; 23 ; $17
                                                      *SonAni_Death_ptr:     offsetTableEntry.w SonAni_Death     ; 24 ; $18
                                                      *SonAni_Hurt_ptr:      offsetTableEntry.w SonAni_Hurt      ; 25 ; $19
                                                      *SonAni_Hurt2_ptr:     offsetTableEntry.w SonAni_Hurt      ; 26 ; $1A
                                                      *SonAni_Slide_ptr:     offsetTableEntry.w SonAni_Slide     ; 27 ; $1B
                                                      *SonAni_Blank_ptr:     offsetTableEntry.w SonAni_Blank     ; 28 ; $1C
                                                      *SonAni_Balance3_ptr:      offsetTableEntry.w SonAni_Balance3  ; 29 ; $1D
                                                      *SonAni_Balance4_ptr:      offsetTableEntry.w SonAni_Balance4  ; 30 ; $1E
                                                      *SupSonAni_Transform_ptr:  offsetTableEntry.w SupSonAni_Transform  ; 31 ; $1F
                                                      *SonAni_Lying_ptr:     offsetTableEntry.w SonAni_Lying     ; 32 ; $20
                                                      *SonAni_LieDown_ptr:       offsetTableEntry.w SonAni_LieDown   ; 33 ; $21
                                                      *
                                                      *SonAni_Walk:  dc.b $FF, $F,$10,$11,$12,$13,$14, $D, $E,$FF
                                                      *  rev02even
                                                      *SonAni_Run:   dc.b $FF,$2D,$2E,$2F,$30,$FF,$FF,$FF,$FF,$FF
                                                      *  rev02even
                                                      *SonAni_Roll:  dc.b $FE,$3D,$41,$3E,$41,$3F,$41,$40,$41,$FF
                                                      *  rev02even
                                                      *SonAni_Roll2: dc.b $FE,$3D,$41,$3E,$41,$3F,$41,$40,$41,$FF
                                                      *  rev02even
                                                      *SonAni_Push:  dc.b $FD,$48,$49,$4A,$4B,$FF,$FF,$FF,$FF,$FF
                                                      *  rev02even
                                                      *SonAni_Wait:
                                                      *  dc.b   5,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
                                                      *  dc.b   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2
                                                      *  dc.b   3,  3,  3,  3,  3,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5
                                                      *  dc.b   5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  6,  6,  6
                                                      *  dc.b   6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5,  5,  4,  4,  4
                                                      *  dc.b   5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  6
                                                      *  dc.b   6,  6,  6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5,  5,  4
                                                      *  dc.b   4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5
                                                      *  dc.b   5,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  4,  4,  4,  5,  5
                                                      *  dc.b   5,  4,  4,  4,  5,  5,  5,  4,  4,  4,  5,  5,  5,  4,  4,  4
                                                      *  dc.b   5,  5,  5,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  7,  8,  8
                                                      *  dc.b   8,  9,  9,  9,$FE,  6
                                                      *  rev02even
                                                      *SonAni_Balance:   dc.b   9,$CC,$CD,$CE,$CD,$FF
                                                      *  rev02even
                                                      *SonAni_LookUp:    dc.b   5, $B, $C,$FE,  1
                                                      *  rev02even
                                                      *SonAni_Duck:  dc.b   5,$4C,$4D,$FE,  1
                                                      *  rev02even
                                                      *SonAni_Spindash:dc.b   0,$42,$43,$42,$44,$42,$45,$42,$46,$42,$47,$FF
                                                      *  rev02even
                                                      *SonAni_Blink: dc.b   1,  2,$FD,  0
                                                      *  rev02even
                                                      *SonAni_GetUp: dc.b   3, $A,$FD,  0
                                                      *  rev02even
                                                      *SonAni_Balance2:dc.b   3,$C8,$C9,$CA,$CB,$FF
                                                      *  rev02even
                                                      *SonAni_Stop:  dc.b   5,$D2,$D3,$D4,$D5,$FD,  0 ; halt/skidding animation
                                                      *  rev02even
                                                      *SonAni_Float: dc.b   7,$54,$59,$FF
                                                      *  rev02even
                                                      *SonAni_Float2:    dc.b   7,$54,$55,$56,$57,$58,$FF
                                                      *  rev02even
                                                      *SonAni_Spring:    dc.b $2F,$5B,$FD,  0
                                                      *  rev02even
                                                      *SonAni_Hang:  dc.b   1,$50,$51,$FF
                                                      *  rev02even
                                                      *SonAni_Dash2: dc.b  $F,$43,$43,$43,$FE,  1
                                                      *  rev02even
                                                      *SonAni_Dash3: dc.b  $F,$43,$44,$FE,  1
                                                      *  rev02even
                                                      *SonAni_Hang2: dc.b $13,$6B,$6C,$FF
                                                      *  rev02even
                                                      *SonAni_Bubble:    dc.b  $B,$5A,$5A,$11,$12,$FD,  0 ; breathe
                                                      *  rev02even
                                                      *SonAni_DeathBW:   dc.b $20,$5E,$FF
                                                      *  rev02even
                                                      *SonAni_Drown: dc.b $20,$5D,$FF
                                                      *  rev02even
                                                      *SonAni_Death: dc.b $20,$5C,$FF
                                                      *  rev02even
                                                      *SonAni_Hurt:  dc.b $40,$4E,$FF
                                                      *  rev02even
                                                      *SonAni_Slide: dc.b   9,$4E,$4F,$FF
                                                      *  rev02even
                                                      *SonAni_Blank: dc.b $77,  0,$FD,  0
                                                      *  rev02even
                                                      *SonAni_Balance3:dc.b $13,$D0,$D1,$FF
                                                      *  rev02even
                                                      *SonAni_Balance4:dc.b   3,$CF,$C8,$C9,$CA,$CB,$FE,  4
                                                      *  rev02even
                                                      *SonAni_Lying: dc.b   9,  8,  9,$FF
                                                      *  rev02even
                                                      *SonAni_LieDown:   dc.b   3,  7,$FD,  0
                                                      *  even
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Animation script - Super Sonic
                                                      *; (many of these point to the data above this)
                                                      *; ---------------------------------------------------------------------------
                                                      *SuperSonicAniData: offsetTable
                                                      *  offsetTableEntry.w SupSonAni_Walk   ;  0 ;   0
                                                      *  offsetTableEntry.w SupSonAni_Run    ;  1 ;   1
                                                      *  offsetTableEntry.w SonAni_Roll      ;  2 ;   2
                                                      *  offsetTableEntry.w SonAni_Roll2     ;  3 ;   3
                                                      *  offsetTableEntry.w SupSonAni_Push   ;  4 ;   4
                                                      *  offsetTableEntry.w SupSonAni_Stand  ;  5 ;   5
                                                      *  offsetTableEntry.w SupSonAni_Balance    ;  6 ;   6
                                                      *  offsetTableEntry.w SonAni_LookUp    ;  7 ;   7
                                                      *  offsetTableEntry.w SupSonAni_Duck   ;  8 ;   8
                                                      *  offsetTableEntry.w SonAni_Spindash  ;  9 ;   9
                                                      *  offsetTableEntry.w SonAni_Blink     ; 10 ;  $A
                                                      *  offsetTableEntry.w SonAni_GetUp     ; 11 ;  $B
                                                      *  offsetTableEntry.w SonAni_Balance2  ; 12 ;  $C
                                                      *  offsetTableEntry.w SonAni_Stop      ; 13 ;  $D
                                                      *  offsetTableEntry.w SonAni_Float     ; 14 ;  $E
                                                      *  offsetTableEntry.w SonAni_Float2    ; 15 ;  $F
                                                      *  offsetTableEntry.w SonAni_Spring    ; 16 ; $10
                                                      *  offsetTableEntry.w SonAni_Hang      ; 17 ; $11
                                                      *  offsetTableEntry.w SonAni_Dash2     ; 18 ; $12
                                                      *  offsetTableEntry.w SonAni_Dash3     ; 19 ; $13
                                                      *  offsetTableEntry.w SonAni_Hang2     ; 20 ; $14
                                                      *  offsetTableEntry.w SonAni_Bubble    ; 21 ; $15
                                                      *  offsetTableEntry.w SonAni_DeathBW   ; 22 ; $16
                                                      *  offsetTableEntry.w SonAni_Drown     ; 23 ; $17
                                                      *  offsetTableEntry.w SonAni_Death     ; 24 ; $18
                                                      *  offsetTableEntry.w SonAni_Hurt      ; 25 ; $19
                                                      *  offsetTableEntry.w SonAni_Hurt      ; 26 ; $1A
                                                      *  offsetTableEntry.w SonAni_Slide     ; 27 ; $1B
                                                      *  offsetTableEntry.w SonAni_Blank     ; 28 ; $1C
                                                      *  offsetTableEntry.w SonAni_Balance3  ; 29 ; $1D
                                                      *  offsetTableEntry.w SonAni_Balance4  ; 30 ; $1E
                                                      *  offsetTableEntry.w SupSonAni_Transform  ; 31 ; $1F
                                                      *
                                                      *SupSonAni_Walk:       dc.b $FF,$77,$78,$79,$7A,$7B,$7C,$75,$76,$FF
                                                      *  rev02even
                                                      *SupSonAni_Run:        dc.b $FF,$B5,$B9,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                                                      *  rev02even
                                                      *SupSonAni_Push:       dc.b $FD,$BD,$BE,$BF,$C0,$FF,$FF,$FF,$FF,$FF
                                                      *  rev02even
                                                      *SupSonAni_Stand:  dc.b   7,$72,$73,$74,$73,$FF
                                                      *  rev02even
                                                      *SupSonAni_Balance:    dc.b   9,$C2,$C3,$C4,$C3,$C5,$C6,$C7,$C6,$FF
                                                      *  rev02even
                                                      *SupSonAni_Duck:       dc.b   5,$C1,$FF
                                                      *  rev02even
                                                      *SupSonAni_Transform:  dc.b   2,$6D,$6D,$6E,$6E,$6F,$70,$71,$70,$71,$70,$71,$70,$71,$FD,  0
                                                      *  even
                                                      *
        rts

Sonic_top_speed                 fdb   0
Sonic_acceleration              fdb   0
Sonic_deceleration              fdb   0
;Sonic_Pos_Record_Index         fdb   0 ; into Sonic_Pos_Record_Buf and Sonic_Stat_Record_Buf

Primary_Angle                   fcb   0
Secondary_Angle                 fcb   0
Water_flag                      fcb   0

Last_star_pole_hit              fcb   0 ; 1 byte -- max activated starpole ID in this act
Saved_Last_star_pole_hit        fcb   0
Saved_x_pos                     fdb   0
Saved_y_pos                     fdb   0
Saved_Solid_bits                fdb   0

Control_Locked                  fcb   0

Chain_Bonus_counter             fcb   0
Sonic_Look_delay_counter        fcb   0
