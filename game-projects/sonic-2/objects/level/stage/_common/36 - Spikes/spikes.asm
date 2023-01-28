        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256
                                                      * ; ===========================================================================
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; Object 36 - Spikes
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; OST Variables:
spikes_base_x_pos equ ext_variables_obj               * spikes_base_x_pos       = objoff_30     ; original x-position
spikes_base_y_pos equ ext_variables_obj+2             * spikes_base_y_pos       = objoff_32     ; original y-position
                                                      * spikes_retract_offset   = objoff_34     ; actual position relative to base position
                                                      * spikes_retract_state    = objoff_36     ; 0 = positive offset, 1 = original position
                                                      * spikes_retract_timer    = objoff_38     ; delay, before spikes move again
                                                      * ; Sprite_15900:
Obj36                                                 * Obj36:
                                                      *         moveq   #0,d0
        lda   routine,u                               *         move.b  routine(a0),d0
        asla
        ldx   #Obj36_Index                            *         move.w  Obj36_Index(pc,d0.w),d1
        jmp   [a,x]                                   *         jmp     Obj36_Index(pc,d1.w)
                                                      * ; ===========================================================================
                                                      * ; off_1590E:
Obj36_Index                                           * Obj36_Index:    offsetTable
        fdb   Obj36_Init                              *                 offsetTableEntry.w Obj36_Init           ; 0
        fdb   Obj36_Upright                           *                 offsetTableEntry.w Obj36_Upright        ; 2
        fdb   Obj36_Sideways                          *                 offsetTableEntry.w Obj36_Sideways       ; 4
        fdb   Obj36_Upsidedown                        *                 offsetTableEntry.w Obj36_Upsidedown     ; 6
                                                      * ; ===========================================================================
                                                      * ; byte_15916:
Obj36_InitData                                        * Obj36_InitData:
                                                      *         ;    width_pixels
                                                      *         ;        y_radius
        fcb   $10/2,$10                               *         dc.b $10,$10    ; 0     - Upright or ceiling spikes
        fcb   $20/2,$10                               *         dc.b $20,$10    ; 2
        fcb   $30/2,$10                               *         dc.b $30,$10    ; 4
        fcb   $40/2,$10                               *         dc.b $40,$10    ; 6
        fcb   $10/2,$10                               *         dc.b $10,$10    ; 8     - Sideways spikes
        fcb   $10/2,$20                               *         dc.b $10,$20    ; 10
        fcb   $10/2,$30                               *         dc.b $10,$30    ; 12
        fcb   $10/2,$40                               *         dc.b $10,$40    ; 14
                                                      * ; ===========================================================================
                                                      * ; loc_15926:
Obj36_Init                                            * Obj36_Init:
        rts ; desactivate this object
        inc   routine,u                               *         addq.b  #2,routine(a0)  ; => Obj36_Upright
 ifdef halfline
        ldd   y_pos,u
        addd  #1
        std   y_pos,u ; fix for interlace alignment
 endc
        ldd   #Img_spikes_v
        std   image_set,u                             *         move.l  #Obj36_MapUnc_15B68,mappings(a0)
        ;                                             *         move.w  #make_art_tile(ArtTile_ArtNem_Spikes,1,0),art_tile(a0)
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u                          *         ori.b   #4,render_flags(a0)
        ldb   #4
        stb   priority,u                              *         move.b  #4,priority(a0)
        lda   subtype,u                               *         move.b  subtype(a0),d0
        tfr   a,b
        anda  #$0F
        sta   subtype,u                               *         andi.b  #$F,subtype(a0)         ; lower 4 bits determine behavior, upper bits need to be removed
        andb  #$F0                                    *         andi.w  #$F0,d0
        ldx   #Obj36_InitData                         *         lea_    Obj36_InitData,a1       ; upper 4 bits determine size and orientation
        lsrb 
        lsrb
        lsrb                                          *         lsr.w   #3,d0                   ; use upper 4 bits * 2 as offset
        lda   b,x                                     *         adda.w  d0,a1
        sta   width_pixels,u                          *         move.b  (a1)+,width_pixels(a0)
        incb
        lda   b,x
        sta   y_radius,u                              *         move.b  (a1)+,y_radius(a0)
        lsrb                                          *         lsr.w   #1,d0                   ; use upper 4 bits to determine mappings frame
                                                      *         move.b  d0,mapping_frame(a0)
        cmpb   #4                                     *         cmpi.b  #4,d0                   ; do spikes face sideways?
        blo   >                                       *         blo.s   +                       ; if not, branch
        inc   routine,u                               *         addq.b  #2,routine(a0)  ; => Obj36_Sideways
        ldd   #Img_spikes_h
        std   image_set,u                             *         move.w  #make_art_tile(ArtTile_ArtNem_HorizSpike,1,0),art_tile(a0)
!                                                     * +
        lda   status_flags,u
        anda  #status_yflip_mask                      *         btst    #1,status(a0)           ; are spikes upsiede-down?
        beq   >                                       *         beq.s   +                       ; if not, branch
        ldb   #3
        stb   routine,u                               *         move.b  #6,routine(a0)  ; => Obj36_Upsidedown
!                                                     * +
        ldd   x_pos,u
        std   spikes_base_x_pos,u                     *         move.w  x_pos(a0),spikes_base_x_pos(a0)
        ldd   y_pos,u
        std   spikes_base_y_pos,u                     *         move.w  y_pos(a0),spikes_base_y_pos(a0)
        rts                                           *         bra.w   Adjust2PArtPointer
                                                      * ; ===========================================================================
                                                      * ; loc_15996:
Obj36_Upright                                         * Obj36_Upright:
                                                      *         bsr.w   MoveSpikes
                                                      *         moveq   #0,d1
                                                      *         move.b  width_pixels(a0),d1
                                                      *         addi.w  #$B,d1
                                                      *         moveq   #0,d2
                                                      *         move.b  y_radius(a0),d2
                                                      *         move.w  d2,d3
                                                      *         addq.w  #1,d3
                                                      *         move.w  x_pos(a0),d4
                                                      *         bsr.w   SolidObject
                                                      *         move.b  status(a0),d6
                                                      *         andi.b  #standing_mask,d6       ; are Sonic or Tails standing on the object?
                                                      *         beq.s   Obj36_UprightEnd        ; if not, branch
                                                      *         move.b  d6,d0
                                                      *         andi.b  #p1_standing,d0         ; is Sonic standing on the object?
                                                      *         beq.s   +                       ; if not, branch
                                                      *         lea     (MainCharacter).w,a1 ; a1=character
                                                      *         bsr.w   Touch_ChkHurt2
                                                      * +
                                                      *         andi.b  #p2_standing,d6         ; is Tails standing on the object?
                                                      *         beq.s   Obj36_UprightEnd        ; if not, branch
                                                      *         lea     (Sidekick).w,a1 ; a1=character
                                                      *         bsr.w   Touch_ChkHurt2
                                                      * 
                                                      * ; loc_159DE:
Obj36_UprightEnd                                      * Obj36_UprightEnd:
        ldd   spikes_base_x_pos,u                     *         move.w  spikes_base_x_pos(a0),d0
        jmp   MarkObjGone2                            *         bra.w   MarkObjGone2
                                                      * ; ===========================================================================
                                                      * ; loc_159E6:
Obj36_Sideways                                        * Obj36_Sideways:
                                                      *         move.w  x_pos(a0),-(sp)
                                                      *         bsr.w   MoveSpikes
                                                      *         moveq   #0,d1
                                                      *         move.b  width_pixels(a0),d1
                                                      *         addi.w  #$B,d1
                                                      *         moveq   #0,d2
                                                      *         move.b  y_radius(a0),d2
                                                      *         move.w  d2,d3
                                                      *         addq.w  #1,d3
                                                      *         move.w  (sp)+,d4
                                                      *         bsr.w   SolidObject
                                                      *         swap    d6
                                                      *         andi.w  #touch_side_mask,d6     ; are Sonic or Tails pushing against the side?
                                                      *         beq.s   Obj36_SidewaysEnd       ; if not, branch
                                                      *         move.b  d6,d0
                                                      *         andi.b  #p1_touch_side,d0       ; is Sonic pushing against the side?
                                                      *         beq.s   +                       ; if not, branch
                                                      *         lea     (MainCharacter).w,a1 ; a1=character
                                                      *         bsr.w   Touch_ChkHurt2
                                                      *         bclr    #p1_pushing_bit,status(a0)
                                                      * +
                                                      *         andi.b  #p2_touch_side,d6       ; is Tails pushing against the side?
                                                      *         beq.s   Obj36_SidewaysEnd       ; if not, branch
                                                      *         lea     (Sidekick).w,a1 ; a1=character
                                                      *         bsr.w   Touch_ChkHurt2
                                                      *         bclr    #p2_pushing_bit,status(a0)
                                                      * 
                                                      * ; loc_15A3A:
Obj36_SidewaysEnd                                     * Obj36_SidewaysEnd:
        ldd   spikes_base_x_pos,u                     *         move.w  spikes_base_x_pos(a0),d0
        jmp   MarkObjGone2                            *         bra.w   MarkObjGone2
                                                      * ; ===========================================================================
                                                      * ; loc_15A42:
Obj36_Upsidedown                                      * Obj36_Upsidedown:
                                                      *         bsr.w   MoveSpikes
                                                      *         moveq   #0,d1
                                                      *         move.b  width_pixels(a0),d1
                                                      *         addi.w  #$B,d1
                                                      *         moveq   #0,d2
                                                      *         move.b  y_radius(a0),d2
                                                      *         move.w  d2,d3
                                                      *         addq.w  #1,d3
                                                      *         move.w  x_pos(a0),d4
                                                      *         bsr.w   SolidObject
                                                      *         swap    d6
                                                      *         andi.w  #touch_bottom_mask,d6   ; are Sonic or Tails touching the bottom?
                                                      *         beq.s   Obj36_UpsidedownEnd     ; if not, branch
                                                      *         move.b  d6,d0
                                                      *         andi.b  #p1_touch_bottom,d0     ; is Sonic touching the bottom?
                                                      *         beq.s   +                       ; if not, branch
                                                      *         lea     (MainCharacter).w,a1 ; a1=character
                                                      *         bsr.w   Touch_ChkHurt2
                                                      * +
                                                      *         andi.b  #p2_touch_bottom,d6     ; is Tails touching the bottom?
                                                      *         beq.s   Obj36_UpsidedownEnd     ; if not, branch
                                                      *         lea     (Sidekick).w,a1 ; a1=character
                                                      *         bsr.w   Touch_ChkHurt2
                                                      * 
                                                      * ; loc_15A88:
Obj36_UpsidedownEnd                                   * Obj36_UpsidedownEnd:
        ldd   spikes_base_x_pos,u                     *         move.w  spikes_base_x_pos(a0),d0
        jmp   MarkObjGone2                            *         bra.w   MarkObjGone2
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine for checking if Sonic/Tails should be hurt and hurting them if so
                                                      * ; unlike Touch_ChkHurt, the character is at a1 instead of a0
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * Touch_ChkHurt2:
                                                      *         btst    #status_sec_isInvincible,status_secondary(a1)   ; is character invincible?
                                                      *         bne.s   +       ; rts           ; if yes, branch
                                                      *         tst.w   invulnerable_time(a1)   ; is character invulnerable?
                                                      *         bne.s   +       ; rts           ; if yes, branch
                                                      *         cmpi.b  #4,routine(a1)          ; is the character hurt, dieing, etc. ?
                                                      *         bhs.s   +       ; rts           ; if yes, branch
                                                      *         move.l  y_pos(a1),d3
                                                      *         move.w  y_vel(a1),d0
                                                      *         ext.l   d0
                                                      *         asl.l   #8,d0
                                                      *         sub.l   d0,d3
                                                      *         move.l  d3,y_pos(a1)
                                                      *         movea.l a0,a2
                                                      *         movea.l a1,a0
                                                      *         jsr     (HurtCharacter).l
                                                      *         movea.l a2,a0
                                                      * +
                                                      *         rts
                                                      * ; End of function Touch_ChkHurt2
                                                      * 
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * ; handles direction, timing and movement of moving spikes
                                                      * 
                                                      * ; sub_15AC6:
                                                      * MoveSpikes:
                                                      *         moveq   #0,d0
                                                      *         move.b  subtype(a0),d0
                                                      *         add.w   d0,d0
                                                      *         move.w  MoveSpikes_Behaviors(pc,d0.w),d1
                                                      *         jmp     MoveSpikes_Behaviors(pc,d1.w)
                                                      * ; End of function MoveSpikes
                                                      * 
                                                      * ; ===========================================================================
                                                      * ; off_15AD6:
                                                      * MoveSpikes_Behaviors:   offsetTable
                                                      *                 offsetTableEntry.w MoveSpikes_Still             ; 0
                                                      *                 offsetTableEntry.w MoveSpikes_Vertical          ; 1
                                                      *                 offsetTableEntry.w MoveSpikes_Horizontal        ; 2
                                                      * ; ===========================================================================
                                                      * ; return_15ADC:
                                                      * MoveSpikes_Still:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_15ADE:
                                                      * MoveSpikes_Vertical:
                                                      *         bsr.w   MoveSpikes_Delay
                                                      *         moveq   #0,d0
                                                      *         move.b  spikes_retract_offset(a0),d0
                                                      *         add.w   spikes_base_y_pos(a0),d0        ; apply offset to y-position
                                                      *         move.w  d0,y_pos(a0)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_15AF2:
                                                      * MoveSpikes_Horizontal:
                                                      *         bsr.w   MoveSpikes_Delay
                                                      *         moveq   #0,d0
                                                      *         move.b  spikes_retract_offset(a0),d0
                                                      *         add.w   spikes_base_x_pos(a0),d0        ; apply offset to x-position
                                                      *         move.w  d0,x_pos(a0)
                                                      *         rts
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; sub_15B06:
                                                      * MoveSpikes_Delay:
                                                      *         tst.w   spikes_retract_timer(a0)        ; is it time for spikes to move again?
                                                      *         beq.s   MoveSpikes_ChkDir               ; if yes, branch
                                                      *         subq.w  #1,spikes_retract_timer(a0)     ; else, decrement timer
                                                      *         bne.s   +       ; rts                   ; branch, if timer didn't reach 0
                                                      *         tst.b   render_flags(a0)                ; are spikes on screen?
                                                      *         bpl.s   +       ; rts                   ; if not, branch
                                                      *         move.w  #SndID_SpikesMove,d0            ; play spike movement sount
                                                      *         jsr     (PlaySound).l
                                                      *         bra.s   +       ; rts
                                                      * ; ===========================================================================
                                                      * ; loc_15B24:
                                                      * MoveSpikes_ChkDir:
                                                      *         tst.w   spikes_retract_state(a0)        ; do spikes need to move away from initial position?
                                                      *         beq.s   MoveSpikes_Retract              ; if yes, branch
                                                      *         subi.w  #$800,spikes_retract_offset(a0) ; subtract 8 pixels from offset
                                                      *         bhs.s   +       ; rts                   ; branch, if offset is not yet 0
                                                      *         move.w  #0,spikes_retract_offset(a0)
                                                      *         move.w  #0,spikes_retract_state(a0)     ; switch state
                                                      *         move.w  #$3C,spikes_retract_timer(a0)   ; reset timer
                                                      *         bra.s   +       ; rts
                                                      * ; ===========================================================================
                                                      * ; loc_15B46:
                                                      * MoveSpikes_Retract:
                                                      *         addi.w  #$800,spikes_retract_offset(a0)         ; add 8 pixels to offset
                                                      *         cmpi.w  #$2000,spikes_retract_offset(a0)        ; is offset the width of one spike block (32 pixels)?
                                                      *         blo.s   +       ; rts                           ; if not, branch
                                                      *         move.w  #$2000,spikes_retract_offset(a0)
                                                      *         move.w  #1,spikes_retract_state(a0)     ; switch state
                                                      *         move.w  #$3C,spikes_retract_timer(a0)   ; reset timer
                                                      * +
                                                      *         rts
                                                      * ; End of function MoveSpikes_Delay
                                                      * 
                                                      * ; ===========================================================================
                                                      * ; -------------------------------------------------------------------------------
                                                      * ; sprite mappings
                                                      * ; -------------------------------------------------------------------------------
                                                      * Obj36_MapUnc_15B68:     BINCLUDE "mappings/sprite/obj36.bin"

