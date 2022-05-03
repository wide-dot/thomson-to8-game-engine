

; UNUSED CODE, replaced by AnimateSpriteSync
; and some complementary code
                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to animate Sonic's sprites
                                                      *; See also: AnimateSprite
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_1B350:
Sonic_Animate_Do                                      *Sonic_Animate:
                                                      *  lea (SonicAniData).l,a1
                                                      *  tst.b   (Super_Sonic_flag).w
                                                      *  beq.s   +
                                                      *  lea (SuperSonicAniData).l,a1
                                                      *+
                                                      *  moveq   #0,d0
        _GetCartPageA
        sta   @page                    ; backup cart page     
        ldx   #Ani_Page_Index
        ldb   id,u
        abx
        lda   ,x
        _SetCartPageA
;
        ldx   anim,u                                  *  move.b  anim(a0),d0
!       cmpx  prev_anim,u                             *  cmp.b   prev_anim(a0),d0    ; has animation changed?
        beq   SAnim_Do                                *  beq.s   SAnim_Do        ; if not, branch
        stx   prev_anim,u                             *  move.b  d0,prev_anim(a0)    ; set previous animation
        ldb   #0                            
        stb   anim_frame,u                            *  move.b  #0,anim_frame(a0)   ; reset animation frame
        stb   anim_frame_duration,u                   *  move.b  #0,anim_frame_duration(a0)  ; reset frame duration
        ldb   status,u
        andb  #^status_pushing 
        stb   status,u                                *  bclr    #5,status(a0)
                                                      *; loc_1B384:
SAnim_Do                                              *SAnim_Do:
        ; no offset table                             *  add.w   d0,d0
        ; anim is the address of anim                 *  adda.w  (a1,d0.w),a1    ; calculate address of appropriate animation script
        ldb   -1,x                            
        stb   @a                                      *  move.b  (a1),d0
        bmi   Go_SAnim_WalkRun                        *  bmi.s   SAnim_WalkRun   ; if animation is walk/run/roll/jump, branch
        ldb   status,u                                *  move.b  status(a0),d1
        andb  #status_x_orientation                   *  andi.b  #1,d1
        stb   @b
        ldb   render_flags,u
        andb  #^(render_xmirror_mask|render_ymirror_mask) *  andi.b  #$FC,render_flags(a0)
        orb   #0                                      *  or.b    d1,render_flags(a0)
@b      equ   *-1
        stb   render_flags,u
        ldb   anim_frame_duration,u
        subb  Vint_Main_runcount
        stb   anim_frame_duration,u                   *  subq.b  #1,anim_frame_duration(a0)  ; subtract 1 from frame duration
        bpl   SAnim_Delay                             *  bpl.s   SAnim_Delay         ; if time remains, branch
        ldb   #0
@a      equ   *-1
        stb   anim_frame_duration,u                   *  move.b  d0,anim_frame_duration(a0)  ; load frame duration
                                                      *; loc_1B3AA:
SAnim_Do2                                             *SAnim_Do2:
                                                      *  moveq   #0,d1
        ldb   anim_frame,u                            *  move.b  anim_frame(a0),d1   ; load current frame number
        lda   #0
        _asld
        leay  d,x
        ldd   ,y                                      *  move.b  1(a1,d1.w),d0       ; read sprite number from script
        cmpa  #$F0                                    *  cmpi.b  #$F0,d0
        bhs   SAnim_End_FF                            *  bhs.s   SAnim_End_FF        ; if animation is complete, branch
                                                      *; loc_1B3BA:
SAnim_Next                                            *SAnim_Next:
        std   image_set,u                             *  move.b  d0,mapping_frame(a0)    ; load sprite number
        inc   anim_frame,u                            *  addq.b  #1,anim_frame(a0)   ; go to next frame
                                                      *; return_1B3C2:
SAnim_Delay                                           *SAnim_Delay:
        ldd   #$00 ; page in a and 0 in b
@page   equ   *-2
        _SetCartPageA
        rts                                           *  rts
        ;
Call_SAnim_Do2
        _GetCartPageA
        sta   @page                    ; backup cart page     
        ldx   #Ani_Page_Index
        ldb   id,u
        abx
        lda   ,x
        _SetCartPageA
        ldx   anim,u
        bra   SAnim_Do2
        ;
Go_SAnim_WalkRun
        lda   @page
        _SetCartPageA
        rts
                                                      *; ===========================================================================
                                                      *; loc_1B3C4:
SAnim_End_FF                                          *SAnim_End_FF:
        inca                                          *  addq.b  #1,d0       ; is the end flag = $FF ?
        bne   SAnim_End_FE                            *  bne.s   SAnim_End_FE    ; if not, branch
        ldb   #0      
        stb   anim_frame,u                            *  move.b  #0,anim_frame(a0)   ; restart the animation
        ldd   ,x                                      *  move.b  1(a1),d0    ; read sprite number
        bra   SAnim_Next                              *  bra.s   SAnim_Next
                                                      *; ===========================================================================
                                                      *; loc_1B3D4:
SAnim_End_FE                                          *SAnim_End_FE:
        inca                                          *  addq.b  #1,d0       ; is the end flag = $FE ?
        bne   SAnim_End_FD                            *  bne.s   SAnim_End_FD    ; if not, branch
        lda   anim_frame,u                  
        stb   @c                                      *  move.b  2(a1,d1.w),d0   ; read the next byte in the script
        suba  #0
@c      equ   *-1        
        sta   anim_frame,u                            *  sub.b   d0,anim_frame(a0)   ; jump back d0 bytes in the script
                                                      *  sub.b   d0,d1
        ldb   #2
        mul                                             
        ldd   d,x                                     *  move.b  1(a1,d1.w),d0   ; read sprite number
        bra   SAnim_Next                              *  bra.s   SAnim_Next
                                                      *; ===========================================================================
                                                      *; loc_1B3E8:
SAnim_End_FD                                          *SAnim_End_FD:
        inca                                          *  addq.b  #1,d0           ; is the end flag = $FD ?
        bne   SAnim_End                               *  bne.s   SAnim_End       ; if not, branch
        ldd   1,y
        std   anim,u                                  *  move.b  2(a1,d1.w),anim(a0) ; read next byte, run that animation
                                                      *; return_1B3F2:
SAnim_End                                             *SAnim_End:
        ldd   @page ; and set b to 0
        _SetCartPageA
        rts                                           *  rts

