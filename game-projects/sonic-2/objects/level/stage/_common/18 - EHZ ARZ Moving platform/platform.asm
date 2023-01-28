        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256

Obj18_child        equ ext_variables_obj
objoff_2C          equ ext_variables_obj+2
objoff_32          equ ext_variables_obj+4
objoff_34          equ ext_variables_obj+6

                                                      * ; ----------------------------------------------------------------------------
                                                      * ; Object 18 - Stationary floating platform from ARZ, EHZ and HTZ
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; Sprite_104AC:
Obj18                                                 * Obj18:
        lda   render_flags,u ; is this a child sprite object?
        anda  #render_subobjects_mask
        bne   >              ; if yes, branch
                                                      *         moveq   #0,d0
        lda   routine,u                               *         move.b  routine(a0),d0
        asla
        ldx   #Obj18_Index                            *         move.w  Obj18_Index(pc,d0.w),d1
        jmp   [a,x]                                   *         jmp     Obj18_Index(pc,d1.w)
!
        lda   #3 ; child sprite objects only need to be drawn
        jmp   DisplaySprite3
                                                      * ; ===========================================================================
                                                      * ; off_104BA:
Obj18_Index                                           * Obj18_Index:    offsetTable
        fdb   Obj18_Init                              *                 offsetTableEntry.w Obj18_Init                   ; 0
        fdb   loc_1056A                               *                 offsetTableEntry.w loc_1056A                    ; 2
        fdb   BranchTo3_DeleteObject                  *                 offsetTableEntry.w BranchTo3_DeleteObject       ; 4
        fdb   loc_105A8                               *                 offsetTableEntry.w loc_105A8                    ; 6
        fdb   loc_105D4                               *                 offsetTableEntry.w loc_105D4                    ; 8
                                                      * ; ===========================================================================
                                                      * ;word_104C4:
Obj18_InitData                                        * Obj18_InitData:
                                                      *         ;    width_pixels
                                                      *         ;        frame
        ;fcb   $20,0                                   *         dc.b $20, 0
        ;fcb   $20,1                                   *         dc.b $20, 1
        ;fcb   $20,2                                   *         dc.b $20, 2
        ;fcb   $40,3                                   *         dc.b $40, 3
        ;fcb   $30,4                                   *         dc.b $30, 4
                                                      * ; ===========================================================================
                                                      * ; loc_104CE:
Obj18_Init                                            * Obj18_Init:
        rts ; desactivate this object
        inc   routine,u                               *         addq.b  #2,routine(a0)

 ifdef halfline
        ldd   y_pos,u
        addd  #1
        std   y_pos,u ; fix for interlace alignment
 endc

                                                       *         moveq   #0,d0
        ;lda   subtype,u                               *         move.b  subtype(a0),d0
        ;lsra
        ;lsra
        ;lsra                                          *         lsr.w   #3,d0
        ;anda  #$E                                     *         andi.w  #$E,d0
        ;ldx   #Obj18_InitData  
        ;ldb   a,x
        ldb   #$10 ; wide-dot factor ; only one type for EHZ
        stb   width_pixels,u                          *         move.b  (a2)+,width_pixels(a0)
        ;                                             *         move.b  (a2)+,mapping_frame(a0)
        ;                                             *         move.l  #Obj18_MapUnc_107F6,mappings(a0)
        ;                                             *         move.w  #make_art_tile(ArtTile_ArtKos_LevelArt,2,0),art_tile(a0)
        ;                                             *         cmpi.b  #aquatic_ruin_zone,(Current_Zone).w
        ;                                             *         bne.s   +
        ;                                             *         move.l  #Obj18_MapUnc_1084E,mappings(a0)
        ;                                             *         move.w  #make_art_tile(ArtTile_ArtKos_LevelArt,2,0),art_tile(a0)
        ;                                             * +
        ;                                             *         bsr.w   Adjust2PArtPointer

        _ldd  render_playfieldcoord_mask,4
        sta   render_flags,u                          *         move.b  #4,render_flags(a0)
        stb   priority,u                              *         move.b  #4,priority(a0)

        ; build platform as a multisprite
        jsr   LoadObject_x
        beq   >
        stx   Obj18_child,u
        lda   id,u
        sta   id,x
;
        lda   render_flags,u
        ora   #render_subobjects_mask
        sta   render_flags,x
;
        ldb   #8                       ; number of tiles
        stb   mainspr_childsprites,x
;
        lda   #$20                     ; wide-dot factor
        sta   mainspr_width,x
        sta   mainspr_height,x
;
        ldd   x_pos,u
        subd  #12                      ; set position to the left (platform 64x32 px is assumed)
        std   sub2_x_pos,x
        std   glb_d5
        addd  #8
        std   glb_d3
;
        ldd   y_pos,u
        subd  #8                       ; set position to the top (platform 64x32 px is assumed)
        std   sub2_y_pos,x
        std   glb_d2
;
        ldy   #Obj18_Images
        ldd   ,y++
        std   sub2_mapframe,x       ; set image
;
        leax  sub3_x_pos,x
        lda   #3
        sta   glb_d1_b
;
        clr   glb_d1                   ; init first line
@a      ldd   glb_d3                   ; x loop
        std   ,x++                     ; x pos
        addd  #8
        std   glb_d3
;
        ldd   glb_d2
        std   ,x++                     ; y pos
;
        ldd   ,y++
        std   ,x++                     ; image tile
;
        dec   glb_d1_b
        bne   @a
!
        tst   glb_d1                   ; first line ?
        bne   >                        ; no quit
        ldd   glb_d5
        std   glb_d3
        ldd   glb_d2                   ; move to second line
        addd  #16
        std   glb_d2
        ldd   #$0104
        std   glb_d1                   ; flag as second line and set 4 tiles
        bra   @a                       ; do x loop for second line

!       ldd   y_pos,u
        std   objoff_2C,u                             *         move.w  y_pos(a0),objoff_2C(a0)
        std   objoff_34,u                             *         move.w  y_pos(a0),objoff_34(a0)
        ldd   x_pos,u
        std   objoff_32,u                             *         move.w  x_pos(a0),objoff_32(a0)
        lda   #$80
        sta   angle,u                                 *         move.w  #$80,angle(a0)
        lda   subtype,u                               *         tst.b   subtype(a0)
        bpl   @a                                      *         bpl.s   ++
        ldb   routine,u
        addb  #3
        stb   routine,u                               *         addq.b  #6,routine(a0)
        anda  #$0F
        sta   subtype,u                               *         andi.b  #$F,subtype(a0)
        ;                                             *         move.b  #$30,y_radius(a0)
        ;                                             *         cmpi.b  #aquatic_ruin_zone,(Current_Zone).w
        ;                                             *         bne.s   +
        lda   #$28
        sta   y_radius,u                              *         move.b  #$28,y_radius(a0)
                                                      * +
        ; height flag (ignored)                       *         bset    #4,render_flags(a0)
        bra   loc_105D4                               *         bra.w   loc_105D4
                                                      * ; ===========================================================================
@a                                                    * +
        anda  #$0F
        sta   subtype,u                               *         andi.b  #$F,subtype(a0)
                                                      * 
loc_1056A                                             * loc_1056A:
                                                      *         move.b  status(a0),d0
                                                      *         andi.b  #standing_mask,d0
                                                      *         bne.s   +
                                                      *         tst.b   objoff_38(a0)
                                                      *         beq.s   ++
                                                      *         subq.b  #4,objoff_38(a0)
                                                      *         bra.s   ++
                                                      * ; ===========================================================================
                                                      * +
                                                      *         cmpi.b  #$40,objoff_38(a0)
                                                      *         beq.s   +
                                                      *         addq.b  #4,objoff_38(a0)
                                                      * +
                                                      *         move.w  x_pos(a0),-(sp)
                                                      *         bsr.w   sub_10638
                                                      *         bsr.w   sub_1061E
                                                      *         moveq   #0,d1
                                                      *         move.b  width_pixels(a0),d1
                                                      *         moveq   #8,d3
                                                      *         move.w  (sp)+,d4
                                                      *         jsrto   (PlatformObject).l, JmpTo_PlatformObject
                                                      *         bra.s   loc_105B0
                                                      * ; ===========================================================================
                                                      * 
loc_105A8                                             * loc_105A8:
                                                      *         bsr.w   sub_10638
                                                      *         bsr.w   sub_1061E
                                                      * 
loc_105B0                                             * loc_105B0:
        ;                                             *         tst.w   (Two_player_mode).w
        ;                                             *         beq.s   +
        ;                                             *         bra.w   DisplaySprite
                                                      * ; ===========================================================================
                                                      * +
        ldd   x_pos,u                                 *         move.w  objoff_32(a0),d0
        andb  #$C0 ; wide-dot factor                  *         andi.w  #$FF80,d0
        subd  glb_camera_x_pos_coarse                 *         sub.w   (Camera_X_pos_coarse).w,d0
        cmpd  #$40+160+$20+$40  ; wide-dot factor     *         cmpi.w  #$280,d0
        bhi   BranchTo3_DeleteObject                  *         bhi.s   BranchTo3_DeleteObject
        rts ; no display for parent sprite            *         bra.w   DisplaySprite
                                                      * ; ===========================================================================
                                                      * 
BranchTo3_DeleteObject                                * BranchTo3_DeleteObject
        ldx   Obj18_child,u
        jsr   DeleteObject2 
        jmp   DeleteObject                            *         bra.w   DeleteObject
                                                      * ; ===========================================================================
                                                      * 
loc_105D4                                             * loc_105D4:
                                                      *         move.b  status(a0),d0
                                                      *         andi.b  #standing_mask,d0
                                                      *         bne.s   +
                                                      *         tst.b   objoff_38(a0)
                                                      *         beq.s   ++
                                                      *         subq.b  #4,objoff_38(a0)
                                                      *         bra.s   ++
                                                      * ; ===========================================================================
                                                      * +
                                                      *         cmpi.b  #$40,objoff_38(a0)
                                                      *         beq.s   +
                                                      *         addq.b  #4,objoff_38(a0)
                                                      * +
                                                      *         move.w  x_pos(a0),-(sp)
                                                      *         bsr.w   sub_10638
                                                      *         bsr.w   sub_1061E
                                                      *         moveq   #0,d1
                                                      *         move.b  width_pixels(a0),d1
                                                      *         addi.w  #$B,d1
                                                      *         moveq   #0,d2
                                                      *         move.b  y_radius(a0),d2
                                                      *         move.w  d2,d3
                                                      *         addq.w  #1,d3
                                                      *         move.w  (sp)+,d4
                                                      *         jsrto   (SolidObject).l, JmpTo_SolidObject
                                                      *         bra.s   loc_105B0
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * 
                                                      * sub_1061E:
                                                      *         move.b  objoff_38(a0),d0
        jsr   CalcSine                                *         jsrto   (CalcSine).l, JmpTo3_CalcSine
                                                      *         move.w  #$400,d1
                                                      *         muls.w  d1,d0
                                                      *         swap    d0
                                                      *         add.w   objoff_2C(a0),d0
                                                      *         move.w  d0,y_pos(a0)
        rts                                           *         rts
                                                      * ; End of function sub_1061E
                                                      * 
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * 
sub_10638                                             * sub_10638:
                                                      *         moveq   #0,d0
                                                      *         move.b  subtype(a0),d0
                                                      *         andi.w  #$F,d0
                                                      *         add.w   d0,d0
                                                      *         move.w  Obj18_Behaviours(pc,d0.w),d1
                                                      *         jmp     Obj18_Behaviours(pc,d1.w)
                                                      * ; End of function sub_10638
                                                      * 
                                                      * ; ===========================================================================
                                                      * ; off_1064C:
Obj18_Behaviours                                      * Obj18_Behaviours: offsetTable
        fdb   return_10668                            *         offsetTableEntry.w return_10668 ;  0
        fdb   loc_1067A                               *         offsetTableEntry.w loc_1067A    ;  1
        fdb   loc_106C0                               *         offsetTableEntry.w loc_106C0    ;  2
        fdb   loc_106D8                               *         offsetTableEntry.w loc_106D8    ;  3
        fdb   loc_10702                               *         offsetTableEntry.w loc_10702    ;  4
        fdb   loc_1066A                               *         offsetTableEntry.w loc_1066A    ;  5
        fdb   loc_106B0                               *         offsetTableEntry.w loc_106B0    ;  6
        fdb   loc_10778                               *         offsetTableEntry.w loc_10778    ;  7
        fdb   loc_107A4                               *         offsetTableEntry.w loc_107A4    ;  8
        fdb   return_10668                            *         offsetTableEntry.w return_10668 ;  9
        fdb   loc_107BC                               *         offsetTableEntry.w loc_107BC    ; $A
        fdb   loc_107D6                               *         offsetTableEntry.w loc_107D6    ; $B
        fdb   loc_106A2                               *         offsetTableEntry.w loc_106A2    ; $C
                                                      * ; ===========================================================================
                                                      * 
return_10668                                          * return_10668:
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_1066A                                             * loc_1066A:
                                                      *         move.w  objoff_32(a0),d0
                                                      *         move.b  angle(a0),d1
                                                      *         neg.b   d1
                                                      *         addi.b  #$40,d1
                                                      *         bra.s   loc_10686
                                                      * ; ===========================================================================
                                                      * 
loc_1067A                                             * loc_1067A:
                                                      *         move.w  objoff_32(a0),d0
                                                      *         move.b  angle(a0),d1
                                                      *         subi.b  #$40,d1
                                                      * 
loc_10686                                             * loc_10686:
                                                      *         ext.w   d1
                                                      *         add.w   d1,d0
                                                      *         move.w  d0,x_pos(a0)
                                                      *         bra.w   loc_107EE
                                                      * ; ===========================================================================
                                                      * 
loc_10692                                             * loc_10692:
                                                      *         move.w  objoff_34(a0),d0
                                                      *         move.b  (Oscillating_Data+$C).w,d1
                                                      *         neg.b   d1
                                                      *         addi.b  #$30,d1
                                                      *         bra.s   loc_106CC
                                                      * ; ===========================================================================
                                                      * 
loc_106A2                                             * loc_106A2:
                                                      *         move.w  objoff_34(a0),d0
                                                      *         move.b  (Oscillating_Data+$C).w,d1
                                                      *         subi.b  #$30,d1
                                                      *         bra.s   loc_106CC
                                                      * ; ===========================================================================
                                                      * 
loc_106B0                                             * loc_106B0:
                                                      *         move.w  objoff_34(a0),d0
                                                      *         move.b  angle(a0),d1
                                                      *         neg.b   d1
                                                      *         addi.b  #$40,d1
                                                      *         bra.s   loc_106CC
                                                      * ; ===========================================================================
                                                      * 
loc_106C0                                             * loc_106C0:
                                                      *         move.w  objoff_34(a0),d0
                                                      *         move.b  angle(a0),d1
                                                      *         subi.b  #$40,d1
                                                      * 
loc_106CC                                             * loc_106CC:
                                                      *         ext.w   d1
                                                      *         add.w   d1,d0
                                                      *         move.w  d0,objoff_2C(a0)
                                                      *         bra.w   loc_107EE
                                                      * ; ===========================================================================
                                                      * 
loc_106D8                                             * loc_106D8:
                                                      *         tst.w   objoff_3A(a0)
                                                      *         bne.s   loc_106F0
                                                      *         move.b  status(a0),d0
                                                      *         andi.b  #standing_mask,d0
                                                      *         beq.s   +       ; rts
                                                      *         move.w  #$1E,objoff_3A(a0)
                                                      * /
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_106F0                                             * loc_106F0:
                                                      *         subq.w  #1,objoff_3A(a0)
                                                      *         bne.s   -       ; rts
                                                      *         move.w  #$20,objoff_3A(a0)
                                                      *         addq.b  #1,subtype(a0)
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_10702                                             * loc_10702:
                                                      *         tst.w   objoff_3A(a0)
                                                      *         beq.s   loc_10730
                                                      *         subq.w  #1,objoff_3A(a0)
                                                      *         bne.s   loc_10730
                                                      *         bclr    #p1_standing_bit,status(a0)
                                                      *         beq.s   +
                                                      *         lea     (MainCharacter).w,a1 ; a1=character
                                                      *         bsr.s   sub_1075E
                                                      * +
                                                      *         bclr    #p2_standing_bit,status(a0)
                                                      *         beq.s   +
                                                      *         lea     (Sidekick).w,a1 ; a1=character
                                                      *         bsr.s   sub_1075E
                                                      * +
                                                      *         move.b  #6,routine(a0)
                                                      * 
loc_10730                                             * loc_10730:
                                                      *         move.l  objoff_2C(a0),d3
                                                      *         move.w  y_vel(a0),d0
                                                      *         ext.l   d0
                                                      *         asl.l   #8,d0
                                                      *         add.l   d0,d3
                                                      *         move.l  d3,objoff_2C(a0)
                                                      *         addi.w  #$38,y_vel(a0)
                                                      *         move.w  (Camera_Max_Y_pos_now).w,d0
                                                      *         addi.w  #$120,d0
                                                      *         cmp.w   objoff_2C(a0),d0
                                                      *         bhs.s   +       ; rts
                                                      *         move.b  #4,routine(a0)
                                                      * +
        rts                                           *         rts
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * 
sub_1075E                                             * sub_1075E:
                                                      *         bset    #1,status(a1)
                                                      *         bclr    #3,status(a1)
                                                      *         move.b  #2,routine(a1)
                                                      *         move.w  y_vel(a0),y_vel(a1)
        rts                                           *         rts
                                                      * ; End of function sub_1075E
                                                      * 
                                                      * ; ===========================================================================
                                                      * 
loc_10778                                             * loc_10778:
                                                      *         tst.w   objoff_3A(a0)
                                                      *         bne.s   loc_10798
                                                      *         lea     (ButtonVine_Trigger).w,a2
                                                      *         moveq   #0,d0
                                                      *         move.b  subtype(a0),d0
                                                      *         lsr.w   #4,d0
                                                      *         tst.b   (a2,d0.w)
                                                      *         beq.s   +       ; rts
                                                      *         move.w  #$3C,objoff_3A(a0)
                                                      * /
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_10798                                             * loc_10798:
                                                      *         subq.w  #1,objoff_3A(a0)
                                                      *         bne.s   -       ; rts
                                                      *         addq.b  #1,subtype(a0)
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_107A4                                             * loc_107A4:
                                                      *         subq.w  #2,objoff_2C(a0)
                                                      *         move.w  objoff_34(a0),d0
                                                      *         subi.w  #$200,d0
                                                      *         cmp.w   objoff_2C(a0),d0
                                                      *         bne.s   +       ; rts
                                                      *         clr.b   subtype(a0)
                                                      * +
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_107BC                                             * loc_107BC:
                                                      *         move.w  objoff_34(a0),d0
                                                      *         move.b  angle(a0),d1
                                                      *         subi.b  #$40,d1
                                                      *         ext.w   d1
                                                      *         asr.w   #1,d1
                                                      *         add.w   d1,d0
                                                      *         move.w  d0,objoff_2C(a0)
                                                      *         bra.w   loc_107EE
                                                      * ; ===========================================================================
                                                      * 
loc_107D6                                             * loc_107D6:
                                                      *         move.w  objoff_34(a0),d0
                                                      *         move.b  angle(a0),d1
                                                      *         neg.b   d1
                                                      *         addi.b  #$40,d1
                                                      *         ext.w   d1
                                                      *         asr.w   #1,d1
                                                      *         add.w   d1,d0
                                                      *         move.w  d0,objoff_2C(a0)
                                                      * 
loc_107EE                                             * loc_107EE:
                                                      *         move.b  (Oscillating_Data+$18).w,angle(a0)
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ; -------------------------------------------------------------------------------
                                                      * ; sprite mappings
                                                      * ; -------------------------------------------------------------------------------
                                                      * Obj18_MapUnc_107F6:     BINCLUDE "mappings/sprite/obj18_a.bin"
                                                      * ; -------------------------------------------------------------------------------
                                                      * ; sprite mappings
                                                      * ; -------------------------------------------------------------------------------
                                                      * Obj18_MapUnc_1084E:     BINCLUDE "mappings/sprite/obj18_b.bin"
                                                      * ; ===========================================================================
                                                      * 
                                                      *     if gameRevision<2
                                                      *         nop
                                                      *     endif
                                                      * 
                                                      *     if ~~removeJmpTos
                                                      * JmpTo3_CalcSine ; JmpTo
                                                      *         jmp     (CalcSine).l
                                                      * JmpTo_PlatformObject ; JmpTo
                                                      *         jmp     (PlatformObject).l
                                                      * JmpTo_SolidObject ; JmpTo
                                                      *         jmp     (SolidObject).l
                                                      * 
                                                      *         align 4
                                                      *     endif

Obj18_Images
        fdb   Img_platform_0
        fdb   Img_platform_1
        fdb   Img_platform_2
        fdb   Img_platform_3
        fdb   Img_platform_4
        fdb   Img_platform_5
        fdb   Img_platform_6
        fdb   Img_platform_7