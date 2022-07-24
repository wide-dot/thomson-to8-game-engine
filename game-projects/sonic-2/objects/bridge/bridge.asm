                                                      * ; ===========================================================================
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; Object 11 - Bridge in Emerald Hill Zone and Hidden Palace Zone
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; OST Variables:
Obj11_child1   equ ext_variables_obj   ; word         * Obj11_child1            = objoff_30     ; pointer to first set of bridge segments
Obj11_child2   equ ext_variables_obj+2 ; word         * Obj11_child2            = objoff_34     ; pointer to second set of bridge segments, if applicable
Obj11_baseYPos equ ext_variables_obj+4 ; word
                                                      * 
                                                      * ; Sprite_F66C:
Obj11                                                 * Obj11:
        lda   render_flags,u                          *         btst    #6,render_flags(a0)     ; is this a child sprite object?
        anda  #render_subobjects_mask
        bne   >                                       *         bne.w   +                       ; if yes, branch
                                                      *         moveq   #0,d0
        lda   routine,u                               *         move.b  routine(a0),d0
        asla
        ldx   #Obj11_Index                            *         move.w  Obj11_Index(pc,d0.w),d1
        jsr   [a,x]                                   *         jmp     Obj11_Index(pc,d1.w)
                                                      * ; ===========================================================================
!                                                     * +       ; child sprite objects only need to be drawn
        lda   #3                                      *         move.w  #$180,d0
        jmp   DisplaySprite                           *         bra.w   DisplaySprite3
                                                      * ; ===========================================================================
                                                      * ; off_F68C:
Obj11_Index                                           * Obj11_Index:    offsetTable
        fdb   Obj11_Init                              *                 offsetTableEntry.w Obj11_Init           ; 0
        fdb   Obj11_EHZ                               *                 offsetTableEntry.w Obj11_EHZ            ; 2
        fdb   DisplaySprite                           *                 offsetTableEntry.w Obj11_Display        ; 4
        fdb   Obj11_HPZ                               *                 offsetTableEntry.w Obj11_HPZ            ; 6
                                                      * ; ===========================================================================
                                                      * ; loc_F694: Obj11_Main:
Obj11_Init                                            * Obj11_Init:
        inc   routine,u                               *         addq.b  #2,routine(a0)
        ldd   #Img_EHZ_bridge_0   
        std   image_set,u                             *         move.l  #Obj11_MapUnc_FC70,mappings(a0)
                                                      *         move.w  #make_art_tile(ArtTile_ArtNem_EHZ_Bridge,2,0),art_tile(a0)
        lda   #3
        sta   priority,u                              *         move.b  #3,priority(a0)
        lda   Current_Zone
        cmpa  #hidden_palace_zone                     *         cmpi.b  #hidden_palace_zone,(Current_Zone).w    ; is this an HPZ bridge?
        bne   >                                       *         bne.s   +                       ; if not, branch
        lda   routine,u
        adda  #2
        sta   routine,u                               *         addq.b  #4,routine(a0)
        ldd   #Img_HPZ_bridge_0   
        std   image_set,u                             *         move.l  #Obj11_MapUnc_FC28,mappings(a0)
                                                      *         move.w  #make_art_tile(ArtTile_ArtNem_HPZ_Bridge,3,0),art_tile(a0)
!                                                     * +
        ;                                             *         bsr.w   Adjust2PArtPointer
        lda   #render_playfieldcoord_mask
        sta   render_flags,u                          *         move.b  #4,render_flags(a0)
        lda   #$40 ; wide-dot factor
        sta   width_pixels,u                          *         move.b  #$80,width_pixels(a0)
        ldd   y_pos,u
        std   glb_d2                                  *         move.w  y_pos(a0),d2
        std   Obj11_baseYPos,u                        *         move.w  d2,objoff_3C(a0)
        ;
        ;                                             *         move.w  x_pos(a0),d3
        ;                                             *         lea     subtype(a0),a2  ; copy bridge subtype to a2
        ;                                             *         moveq   #0,d1
        ldb   subtype,u ; subtype hold number of logs
        ;                                             *         move.b  (a2),d1         ; d1 = subtype
        ;                                             *         move.w  d1,d0
        lsrb                                          *         lsr.w   #1,d0
        lslb
        lslb
        lslb  ; wide-dot factor                       *         lsl.w   #4,d0   ; (d0 div 2) * 16
        negb
        sex
        addd  x_pos,u                                 *         sub.w   d0,d3   ; x position of left half
        std   glb_d3
        ;                                             *         swap    d1      ; store subtype in high word for later
        ldb   #8 ; make 8 logs                        *         move.w  #8,d1
        jsr   Obj11_MakeBdgSegment                    *         bsr.s   Obj11_MakeBdgSegment
        ldd   sub6_x_pos,x                            *         move.w  sub6_x_pos(a1),d0
        subd  #4 ; wide-dot factor                    *         subq.w  #8,d0
        std   x_pos,x                                 *         move.w  d0,x_pos(a1)            ; center of first subsprite object
        stx   Obj11_child1,u                          *         move.l  a1,Obj11_child1(a0)     ; pointer to first subsprite object
        lda   subtype,u                               *         swap    d1      ; retrieve subtype
        suba  #8                                      *         subq.w  #8,d1
        bls   >                                       *         bls.s   +       ; branch, if subtype <= 8 (bridge has no more than 8 logs)
                                                      *         ; else, create a second subsprite object for the rest of the bridge
        sta   glb_d4_b                                *         move.w  d1,d4
        jsr   Obj11_MakeBdgSegment                    *         bsr.s   Obj11_MakeBdgSegment
        stx   Obj11_child2,u                          *         move.l  a1,Obj11_child2(a0)     ; pointer to second subsprite object
        ldb   glb_d4_b                                *         move.w  d4,d0
        aslb                                          *         add.w   d0,d0
        addb  glb_d4_b                                *         add.w   d4,d0   ; d0*3
        aslb
        addb  sub2_x_pos
        ldd   b,x ; load x_pos of center log          *         move.w  sub2_x_pos(a1,d0.w),d0
        subd  #4  ; wide-dot factor                   *         subq.w  #8,d0
        std   x_pos,x                                 *         move.w  d0,x_pos(a1)            ; center of second subsprite object
!                                                     * +
        bra   Obj11_EHZ                               *         bra.s   Obj11_EHZ
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * ; sub_F728:
Obj11_MakeBdgSegment                                  * Obj11_MakeBdgSegment:
        jsr   SingleObjLoad2                          *         jsrto   (SingleObjLoad2).l, JmpTo_SingleObjLoad2
        bne   >                                       *         bne.s   +       ; rts
        lda   id,u
        sta   id,x                                    *         _move.b id(a0),id(a1) ; load obj11
        ldd   x_pos,u
        std   x_pos,x                                 *         move.w  x_pos(a0),x_pos(a1)
        ldd   y_pos,u
        std   y_pos,x                                 *         move.w  y_pos(a0),y_pos(a1)
        ldd   image_set,u
        std   image_set,x                             *         move.l  mappings(a0),mappings(a1)
        ;                                             *         move.w  art_tile(a0),art_tile(a1)
        lda   render_flags,u                          *         move.b  render_flags(a0),render_flags(a1)
        anda  #render_subobjects_mask                      *         bset    #6,render_flags(a1)
        sta   render_flags,x
        lda   #$20 ; wide-dot factor
        sta   mainspr_width,x                         *         move.b  #$40,mainspr_width(a1)
        ldb   subtype,u ; subtype hold number of logs
        stb   mainspr_childsprites,x                  *         move.b  d1,mainspr_childsprites(a1)
        decb
        stb   glb_d1_b                                *         subq.b  #1,d1
        leay  sub2_x_pos,x                            *         lea     sub2_x_pos(a1),a2 ; starting address for subsprite data
                                                      * 
@a      ldd   glb_d3
        std   ,y++                                    * -       move.w  d3,(a2)+        ; sub?_x_pos
        addd  #8 ; wide-dot factor
        std   glb_d3
        ldd   glb_d2
        std   ,y++                                    *         move.w  d2,(a2)+        ; sub?_y_pos
        ldd   #0
        std   ,y++                                    *         move.w  #0,(a2)+        ; sub?_mapframe
        ; moved                                       *         addi.w  #$10,d3         ; width of a log, x_pos for next log
        dec   glb_d1_b
        bne   @a                                      *         dbf     d1,-    ; repeat for d1 logs
!                                                     * +
        rts                                           *         rts
                                                      * ; End of function Obj11_MakeBdgSegment
                                                      * 
                                                      * ; ===========================================================================
                                                      * ; loc_F77A: Obj11_Action:
Obj11_EHZ                                             * Obj11_EHZ:
                                                      *         move.b  status(a0),d0
                                                      *         andi.b  #standing_mask,d0
                                                      *         bne.s   +
                                                      *         tst.b   objoff_3E(a0)
                                                      *         beq.s   loc_F7BC
                                                      *         subq.b  #4,objoff_3E(a0)
                                                      *         bra.s   loc_F7B8
!                                                     * +
                                                      *         andi.b  #p2_standing,d0
                                                      *         beq.s   ++
                                                      *         move.b  objoff_3F(a0),d0
                                                      *         sub.b   objoff_3B(a0),d0
                                                      *         beq.s   ++
                                                      *         bcc.s   +
                                                      *         addq.b  #1,objoff_3F(a0)
                                                      *         bra.s   ++
                                                      * ; ---------------------------------------------------------------------------
!                                                     * +
                                                      *         subq.b  #1,objoff_3F(a0)
!                                                     * +
                                                      *         cmpi.b  #$40,objoff_3E(a0)
                                                      *         beq.s   loc_F7B8
                                                      *         addq.b  #4,objoff_3E(a0)
                                                      * 
loc_F7B8                                              * loc_F7B8:
                                                      *         bsr.w   Obj11_Depress
                                                      * 
loc_F7BC                                              * loc_F7BC:
                                                      *         moveq   #0,d1
                                                      *         move.b  subtype(a0),d1
                                                      *         lsl.w   #3,d1
                                                      *         move.w  d1,d2
                                                      *         addq.w  #8,d1
                                                      *         add.w   d2,d2
                                                      *         moveq   #8,d3
                                                      *         move.w  x_pos(a0),d4
                                                      *         bsr.w   sub_F872
                                                      * 
                                                      * ; loc_F7D4:
Obj11_Unload                                          * Obj11_Unload:
                                                      *         ; this is essentially MarkObjGone, except we need to delete our subsprite objects as well
                                                      *         tst.w   (Two_player_mode).w     ; is it two player mode?
                                                      *         beq.s   +                       ; if not, branch
                                                      *         rts
                                                      * ; ---------------------------------------------------------------------------
!                                                     * +
        ldd   x_pos,u                                 *         move.w  x_pos(a0),d0
        andb  #$C0 ; wide-dot factor                  *         andi.w  #$FF80,d0
        subd  glb_camera_X_pos_coarse                 *         sub.w   (Camera_X_pos_coarse).w,d0
        cmpd  #$280                                   *         cmpi.w  #$280,d0
        bhi   >                                       *         bhi.s   +
        rts                                           *         rts
                                                      * ; ---------------------------------------------------------------------------
!                                                     * +       ; delete first subsprite object
        ldx   Obj11_child1,u                          *         movea.l Obj11_child1(a0),a1 ; a1=object
        bsr   DeleteObject2                           *         bsr.w   DeleteObject2
        ldb   subtype,u
        cmpb  #8                                      *         cmpi.b  #8,subtype(a0)
        bls   >                                       *         bls.s   +       ; if bridge has more than 8 logs, delete second subsprite object
        ldx   Obj11_child2,u                          *         movea.l Obj11_child2(a0),a1 ; a1=object
        bsr   DeleteObject2                           *         bsr.w   DeleteObject2
!                                                     * +
        bra   DeleteObject                            *         bra.w   DeleteObject
                                                      * ; ===========================================================================
                                                      * ; loc_F80C: BranchTo_DisplaySprite:
Obj11_Display                                         * Obj11_Display:
        ; moved to offset table                       *         bra.w   DisplaySprite
                                                      * ; ===========================================================================
                                                      * ; loc_F810: Obj11_Action_HPZ:
Obj11_HPZ                                             * Obj11_HPZ:
                                                      *         move.b  status(a0),d0
                                                      *         andi.b  #standing_mask,d0
                                                      *         bne.s   +
                                                      *         tst.b   objoff_3E(a0)
                                                      *         beq.s   loc_F852
                                                      *         subq.b  #4,objoff_3E(a0)
                                                      *         bra.s   loc_F84E
                                                      * ; ===========================================================================
!                                                     * +
                                                      *         andi.b  #p2_standing,d0
                                                      *         beq.s   ++
                                                      *         move.b  objoff_3F(a0),d0
                                                      *         sub.b   objoff_3B(a0),d0
                                                      *         beq.s   ++
                                                      *         bcc.s   +
                                                      *         addq.b  #1,objoff_3F(a0)
                                                      *         bra.s   ++
                                                      * ; ===========================================================================
!                                                     * +
                                                      *         subq.b  #1,objoff_3F(a0)
!                                                     * +
                                                      *         cmpi.b  #$40,objoff_3E(a0)
                                                      *         beq.s   loc_F84E
                                                      *         addq.b  #4,objoff_3E(a0)
                                                      * 
loc_F84E                                              * loc_F84E:
        jsr   Obj11_Depress                           *         bsr.w   Obj11_Depress
                                                      * 
loc_F852                                              * loc_F852:
                                                      *         moveq   #0,d1
                                                      *         move.b  subtype(a0),d1
                                                      *         lsl.w   #3,d1
                                                      *         move.w  d1,d2
                                                      *         addq.w  #8,d1
                                                      *         add.w   d2,d2
                                                      *         moveq   #8,d3
                                                      *         move.w  x_pos(a0),d4
                                                      *         bsr.w   sub_F872
                                                      *         bsr.w   sub_F912
                                                      *         bra.w   Obj11_Unload
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * 
sub_F872                                              * sub_F872:
                                                      *         lea     (Sidekick).w,a1 ; a1=character
                                                      *         moveq   #p2_standing_bit,d6
                                                      *         moveq   #objoff_3B,d5
                                                      *         movem.l d1-d4,-(sp)
                                                      *         bsr.s   +
                                                      *         movem.l (sp)+,d1-d4
                                                      *         lea     (MainCharacter).w,a1 ; a1=character
                                                      *         subq.b  #1,d6
                                                      *         moveq   #objoff_3F,d5
!                                                     * +
                                                      *         btst    d6,status(a0)
                                                      *         beq.s   loc_F8F0
                                                      *         btst    #1,status(a1)
                                                      *         bne.s   +
                                                      *         moveq   #0,d0
                                                      *         move.w  x_pos(a1),d0
                                                      *         sub.w   x_pos(a0),d0
                                                      *         add.w   d1,d0
                                                      *         bmi.s   +
                                                      *         cmp.w   d2,d0
                                                      *         blo.s   ++
!                                                     * +
                                                      *         bclr    #3,status(a1)
                                                      *         bclr    d6,status(a0)
                                                      *         moveq   #0,d4
        rts                                           *         rts
                                                      * ; ===========================================================================
!                                                     * +
                                                      *         lsr.w   #4,d0
                                                      *         move.b  d0,(a0,d5.w)
                                                      *         movea.l Obj11_child1(a0),a2
                                                      *         cmpi.w  #8,d0
                                                      *         blo.s   +
                                                      *         movea.l Obj11_child2(a0),a2 ; a2=object
                                                      *         subi_.w #8,d0
!                                                     * +
                                                      *         add.w   d0,d0
                                                      *         move.w  d0,d1
                                                      *         add.w   d0,d0
                                                      *         add.w   d1,d0
                                                      *         move.w  sub2_y_pos(a2,d0.w),d0
                                                      *         subq.w  #8,d0
                                                      *         moveq   #0,d1
                                                      *         move.b  y_radius(a1),d1
                                                      *         sub.w   d1,d0
                                                      *         move.w  d0,y_pos(a1)
                                                      *         moveq   #0,d4
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
loc_F8F0                                              * loc_F8F0:
                                                      *         move.w  d1,-(sp)
        jsr     PlatformObject11_cont                 *         jsrto   (PlatformObject11_cont).l, JmpTo_PlatformObject11_cont
                                                      *         move.w  (sp)+,d1
                                                      *         btst    d6,status(a0)
                                                      *         beq.s   +       ; rts
                                                      *         moveq   #0,d0
                                                      *         move.w  x_pos(a1),d0
                                                      *         sub.w   x_pos(a0),d0
                                                      *         add.w   d1,d0
                                                      *         lsr.w   #4,d0
                                                      *         move.b  d0,(a0,d5.w)
!                                                     * +
        rts                                           *         rts
                                                      * ; End of function sub_F872
                                                      * 
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * 
sub_F912                                              * sub_F912:
                                                      *         moveq   #0,d0
                                                      *         tst.w   (MainCharacter+x_vel).w
                                                      *         bne.s   +
                                                      *         move.b  (Vint_runcount+3).w,d0
                                                      *         andi.w  #$1C,d0
                                                      *         lsr.w   #1,d0
!                                                     * +
                                                      *         moveq   #0,d2
                                                      *         move.b  byte_F950+1(pc,d0.w),d2
                                                      *         swap    d2
                                                      *         move.b  byte_F950(pc,d0.w),d2
                                                      *         moveq   #0,d0
                                                      *         tst.w   (Sidekick+x_vel).w
                                                      *         bne.s   +
                                                      *         move.b  (Vint_runcount+3).w,d0
                                                      *         andi.w  #$1C,d0
                                                      *         lsr.w   #1,d0
!                                                     * +
                                                      *         moveq   #0,d6
                                                      *         move.b  byte_F950+1(pc,d0.w),d6
                                                      *         swap    d6
                                                      *         move.b  byte_F950(pc,d0.w),d6
        bra   >                                       *         bra.s   +
                                                      * ; ===========================================================================
byte_F950                                             * byte_F950:
        fcb   1,2                                     *         dc.b   1,  2
        fcb   1,2                                     *         dc.b   1,  2    ; 2
        fcb   1,2                                     *         dc.b   1,  2    ; 4
        fcb   1,2                                     *         dc.b   1,  2    ; 6
        fcb   0,1                                     *         dc.b   0,  1    ; 8
        fcb   0,0                                     *         dc.b   0,  0    ; 10
        fcb   0,0                                     *         dc.b   0,  0    ; 12
        fcb   0,1                                     *         dc.b   0,  1    ; 14
                                                      * ; ===========================================================================
!                                                     * +
                                                      *         moveq   #-2,d3
                                                      *         moveq   #-2,d4
                                                      *         move.b  status(a0),d0
                                                      *         andi.b  #p1_standing,d0
                                                      *         beq.s   +
                                                      *         move.b  objoff_3F(a0),d3
!                                                     * +
                                                      *         move.b  status(a0),d0
                                                      *         andi.b  #p2_standing,d0
                                                      *         beq.s   +
                                                      *         move.b  objoff_3B(a0),d4
!                                                     * +
                                                      *         movea.l Obj11_child1(a0),a1
                                                      *         lea     sub9_mapframe+next_subspr(a1),a2
                                                      *         lea     sub2_mapframe(a1),a1
                                                      *         moveq   #0,d1
                                                      *         move.b  subtype(a0),d1
                                                      *         subq.b  #1,d1
                                                      *         moveq   #0,d5
                                                      * 
@                                                     * -       moveq   #0,d0
                                                      *         subq.w  #1,d3
                                                      *         cmp.b   d3,d5
                                                      *         bne.s   +
                                                      *         move.w  d2,d0
!                                                     * +
                                                      *         addq.w  #2,d3
                                                      *         cmp.b   d3,d5
                                                      *         bne.s   +
                                                      *         move.w  d2,d0
!                                                     * +
                                                      *         subq.w  #1,d3
                                                      *         subq.w  #1,d4
                                                      *         cmp.b   d4,d5
                                                      *         bne.s   +
                                                      *         move.w  d6,d0
!                                                     * +
                                                      *         addq.w  #2,d4
                                                      *         cmp.b   d4,d5
                                                      *         bne.s   +
                                                      *         move.w  d6,d0
!                                                     * +
                                                      *         subq.w  #1,d4
                                                      *         cmp.b   d3,d5
                                                      *         bne.s   +
                                                      *         swap    d2
                                                      *         move.w  d2,d0
                                                      *         swap    d2
!                                                     * +
                                                      *         cmp.b   d4,d5
                                                      *         bne.s   +
                                                      *         swap    d6
                                                      *         move.w  d6,d0
                                                      *         swap    d6
!                                                     * +
                                                      *         move.b  d0,(a1)
                                                      *         addq.w  #1,d5
                                                      *         addq.w  #6,a1
                                                      *         cmpa.w  a2,a1
                                                      *         bne.s   +
                                                      *         movea.l Obj11_child2(a0),a1 ; a1=object
                                                      *         lea     sub2_mapframe(a1),a1
!                                                     * +       dbf     d1,-
                                                      * 
        rts                                           *         rts
                                                      * ; End of function sub_F912
                                                      * 
                                                      * ; ===========================================================================
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * ; subroutine to make the bridge push down where Sonic or Tails walks over
                                                      * ; loc_F9E8:
Obj11_Depress                                         * Obj11_Depress:
                                                      *         move.b  objoff_3E(a0),d0
        jsr   CalcSine                                *         jsrto   (CalcSine).l, JmpTo_CalcSine
                                                      *         move.w  d0,d4
                                                      *         lea     (byte_FB28).l,a4
                                                      *         moveq   #0,d0
                                                      *         move.b  subtype(a0),d0
                                                      *         lsl.w   #4,d0
                                                      *         moveq   #0,d3
                                                      *         move.b  objoff_3F(a0),d3
                                                      *         move.w  d3,d2
                                                      *         add.w   d0,d3
                                                      *         moveq   #0,d5
                                                      *         lea     (Obj11_DepressionOffsets-$80).l,a5
                                                      *         move.b  (a5,d3.w),d5
                                                      *         andi.w  #$F,d3
                                                      *         lsl.w   #4,d3
                                                      *         lea     (a4,d3.w),a3
                                                      *         movea.l Obj11_child1(a0),a1
                                                      *         lea     sub9_y_pos+next_subspr(a1),a2
                                                      *         lea     sub2_y_pos(a1),a1
                                                      * 
@                                                     * -       moveq   #0,d0
                                                      *         move.b  (a3)+,d0
                                                      *         addq.w  #1,d0
                                                      *         mulu.w  d5,d0
                                                      *         mulu.w  d4,d0
                                                      *         swap    d0
        Obj11_baseYPos,y                              *         add.w   objoff_3C(a0),d0
                                                      *         move.w  d0,(a1)
                                                      *         addq.w  #6,a1
                                                      *         cmpa.w  a2,a1
        bne   >                                       *         bne.s   +
                                                      *         movea.l Obj11_child2(a0),a1 ; a1=object
                                                      *         lea     sub2_y_pos(a1),a1
!                                                     * +       dbf     d2,-
                                                      * 
                                                      *         moveq   #0,d0
                                                      *         move.b  subtype(a0),d0
                                                      *         moveq   #0,d3
                                                      *         move.b  objoff_3F(a0),d3
                                                      *         addq.b  #1,d3
                                                      *         sub.b   d0,d3
                                                      *         neg.b   d3
        bmi   >                                       *         bmi.s   ++      ; rts
                                                      *         move.w  d3,d2
                                                      *         lsl.w   #4,d3
                                                      *         lea     (a4,d3.w),a3
                                                      *         adda.w  d2,a3
                                                      *         subq.w  #1,d2
        bcs   >                                       *         bcs.s   ++      ; rts
                                                      * 
@                                                     * -       moveq   #0,d0
                                                      *         move.b  -(a3),d0
                                                      *         addq.w  #1,d0
                                                      *         mulu.w  d5,d0
                                                      *         mulu.w  d4,d0
                                                      *         swap    d0
        Obj11_baseYPos,u                              *         add.w   objoff_3C(a0),d0
                                                      *         move.w  d0,(a1)
                                                      *         addq.w  #6,a1
                                                      *         cmpa.w  a2,a1
        bne   @z                                      *         bne.s   +
                                                      *         movea.l Obj11_child2(a0),a1 ; a1=object
                                                      *         lea     sub2_y_pos(a1),a1
@z                                                    * +       dbf     d2,-
!                                                     * +
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ; seems to be bridge piece vertical position offset data
Obj11_DepressionOffsets                               * Obj11_DepressionOffsets: ; byte_FA98:
        fcb 2,4,6,8,8,6,4,2,0,0,0,0,0,0,0,0           *         dc.b   2,  4,  6,  8,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0; 16
        fcb 2,4,6,8,$A,8,6,4,2,0,0,0,0,0,0,0          *         dc.b   2,  4,  6,  8, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0,  0; 32
        fcb 2,4,6,8,$A,$A,8,6,4,2,0,0,0,0,0,0         *         dc.b   2,  4,  6,  8, $A, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0,  0; 48
        fcb 2,4,6,8,$A,$C,$A,8,6,4,2,0,0,0,0,0        *         dc.b   2,  4,  6,  8, $A, $C, $A,  8,  6,  4,  2,  0,  0,  0,  0,  0; 64
        fcb 2,4,6,8,$A,$C,$C,$A,8,6,4,2,0,0,0,0       *         dc.b   2,  4,  6,  8, $A, $C, $C, $A,  8,  6,  4,  2,  0,  0,  0,  0; 80
        fcb 2,4,6,8,$A,$C,$E,$C,$A,8,6,4,2,0,0,0      *         dc.b   2,  4,  6,  8, $A, $C, $E, $C, $A,  8,  6,  4,  2,  0,  0,  0; 96
        fcb 2,4,6,8,$A,$C,$E,$E,$C,$A,8,6,4,2,0,0     *         dc.b   2,  4,  6,  8, $A, $C, $E, $E, $C, $A,  8,  6,  4,  2,  0,  0; 112
        fcb 2,4,6,8,$A,$C,$E,$10,$E,$C,$A,8,6,4,2,0   *         dc.b   2,  4,  6,  8, $A, $C, $E,$10, $E, $C, $A,  8,  6,  4,  2,  0; 128
        fcb 2,4,6,8,$A,$C,$E,$10,$10,$E,$C,$A,8,6,4,2 *         dc.b   2,  4,  6,  8, $A, $C, $E,$10,$10, $E, $C, $A,  8,  6,  4,  2; 144
                                                      * 
                                                      * ; something else important for bridge depression to work (phase? bridge size adjustment?)
byte_FB28                                             * byte_FB28:
        fcb $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0                               *         dc.b $FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 16
        fcb $B5,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0                             *         dc.b $B5,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 32
        fcb $7E,$DB,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0                           *         dc.b $7E,$DB,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 48
        fcb $61,$B5,$EC,$FF,0,0,0,0,0,0,0,0,0,0,0,0                         *         dc.b $61,$B5,$EC,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 64
        fcb $4A,$93,$CD,$F3,$FF,0,0,0,0,0,0,0,0,0,0,0                       *         dc.b $4A,$93,$CD,$F3,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 80
        fcb $3E,$7E,$B0,$DB,$F6,$FF,0,0,0,0,0,0,0,0,0,0                     *         dc.b $3E,$7E,$B0,$DB,$F6,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 96
        fcb $38,$6D,$9D,$C5,$E4,$F8,$FF,0,0,0,0,0,0,0,0,0                   *         dc.b $38,$6D,$9D,$C5,$E4,$F8,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0; 112
        fcb $31,$61,$8E,$B5,$D4,$EC,$FB,$FF,0,0,0,0,0,0,0,0                 *         dc.b $31,$61,$8E,$B5,$D4,$EC,$FB,$FF,  0,  0,  0,  0,  0,  0,  0,  0; 128
        fcb $2B,$56,$7E,$A2,$C1,$DB,$EE,$FB,$FF,0,0,0,0,0,0,0               *         dc.b $2B,$56,$7E,$A2,$C1,$DB,$EE,$FB,$FF,  0,  0,  0,  0,  0,  0,  0; 144
        fcb $25,$4A,$73,$93,$B0,$CD,$E1,$F3,$FC,$FF,0,0,0,0,0,0             *         dc.b $25,$4A,$73,$93,$B0,$CD,$E1,$F3,$FC,$FF,  0,  0,  0,  0,  0,  0; 160
        fcb $1F,$44,$67,$88,$A7,$BD,$D4,$E7,$F4,$FD,$FF,0,0,0,0,0           *         dc.b $1F,$44,$67,$88,$A7,$BD,$D4,$E7,$F4,$FD,$FF,  0,  0,  0,  0,  0; 176
        fcb $1F,$3E,$5C,$7E,$98,$B0,$C9,$DB,$EA,$F6,$FD,$FF,0,0,0,0         *         dc.b $1F,$3E,$5C,$7E,$98,$B0,$C9,$DB,$EA,$F6,$FD,$FF,  0,  0,  0,  0; 192
        fcb $19,$38,$56,$73,$8E,$A7,$BD,$D1,$E1,$EE,$F8,$FE,$FF,0,0,0       *         dc.b $19,$38,$56,$73,$8E,$A7,$BD,$D1,$E1,$EE,$F8,$FE,$FF,  0,  0,  0; 208
        fcb $19,$38,$50,$6D,$83,$9D,$B0,$C5,$D8,$E4,$F1,$F8,$FE,$FF,0,0     *         dc.b $19,$38,$50,$6D,$83,$9D,$B0,$C5,$D8,$E4,$F1,$F8,$FE,$FF,  0,  0; 224
        fcb $19,$31,$4A,$67,$7E,$93,$A7,$BD,$CD,$DB,$E7,$F3,$F9,$FE,$FF,0   *         dc.b $19,$31,$4A,$67,$7E,$93,$A7,$BD,$CD,$DB,$E7,$F3,$F9,$FE,$FF,  0; 240
        fcb $19,$31,$4A,$61,$78,$8E,$A2,$B5,$C5,$D4,$E1,$EC,$F4,$FB,$FE,$FF *         dc.b $19,$31,$4A,$61,$78,$8E,$A2,$B5,$C5,$D4,$E1,$EC,$F4,$FB,$FE,$FF; 256
                                                      * ; -------------------------------------------------------------------------------
                                                      * ; sprite mappings
                                                      * ; -------------------------------------------------------------------------------
                                                      * Obj11_MapUnc_FC28:      BINCLUDE "mappings/sprite/obj11_a.bin"
                                                      * 
                                                      * ; -------------------------------------------------------------------------------
                                                      * ; sprite mappings
                                                      * ; -------------------------------------------------------------------------------
                                                      * Obj11_MapUnc_FC70:      BINCLUDE "mappings/sprite/obj11_b.bin"
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      *     if ~~removeJmpTos
                                                      * ; sub_FC88:
                                                      * JmpTo_SingleObjLoad2 ; JmpTo
                                                      *         jmp     (SingleObjLoad2).l
                                                      * JmpTo_PlatformObject11_cont ; JmpTo
                                                      *         jmp     (PlatformObject11_cont).l
                                                      * ; sub_FC94:
                                                      * JmpTo_CalcSine ; JmpTo
                                                      *         jmp     (CalcSine).l
                                                      * 
                                                      *         align 4
                                                      *     endif

                                                      *; ===========================================================================
                                                      *; Used only by EHZ/HPZ log bridges. Very similar to PlatformObject_cont, but
                                                      *; d2 already has the full width of the log.
                                                      *;loc_19D9C:
PlatformObject11_cont                                 *PlatformObject11_cont:
                                                      *        tst.w   y_vel(a1)
                                                      *        bmi.w   return_19E8E
                                                      *        move.w  x_pos(a1),d0
                                                      *        sub.w   x_pos(a0),d0
                                                      *        add.w   d1,d0
                                                      *        bmi.w   return_19E8E
                                                      *        cmp.w   d2,d0
                                                      *        bhs.w   return_19E8E
        bra   loc_19DD8                               *        bra.s   loc_19DD8
                                                      *; ===========================================================================
                                                      *;loc_19DBA:
PlatformObject_cont                                   *PlatformObject_cont:
                                                      *        tst.w   y_vel(a1)
                                                      *        bmi.w   return_19E8E
                                                      *        move.w  x_pos(a1),d0
                                                      *        sub.w   x_pos(a0),d0
                                                      *        add.w   d1,d0
                                                      *        bmi.w   return_19E8E
                                                      *        add.w   d1,d1
                                                      *        cmp.w   d1,d0
                                                      *        bhs.w   return_19E8E
                                                      *
loc_19DD8                                             *loc_19DD8:
                                                      *        move.w  y_pos(a0),d0
                                                      *        sub.w   d3,d0
                                                      *;loc_19DDE:
PlatformObject_ChkYRange                              *PlatformObject_ChkYRange:
                                                      *        move.w  y_pos(a1),d2
                                                      *        move.b  y_radius(a1),d1
                                                      *        ext.w   d1
                                                      *        add.w   d2,d1
                                                      *        addq.w  #4,d1
                                                      *        sub.w   d1,d0
                                                      *        bhi.w   return_19E8E
                                                      *        cmpi.w  #-$10,d0
                                                      *        blo.w   return_19E8E
                                                      *        tst.b   obj_control(a1)
                                                      *        bmi.w   return_19E8E
                                                      *        cmpi.b  #6,routine(a1)
                                                      *        bhs.w   return_19E8E
                                                      *        add.w   d0,d2
                                                      *        addq.w  #3,d2
                                                      *        move.w  d2,y_pos(a1)
                                                      *;loc_19E14:
RideObject_SetRide                                    *RideObject_SetRide:
                                                      *        btst    #3,status(a1)
                                                      *        beq.s   loc_19E30
                                                      *        moveq   #0,d0
                                                      *        move.b  interact(a1),d0
                                                      *    if object_size=$40
                                                      *        lsl.w   #6,d0
                                                      *    else
                                                      *        mulu.w  #object_size,d0
                                                      *    endif
                                                      *        addi.l  #Object_RAM,d0
                                                      *        movea.l d0,a3   ; a3=object
                                                      *        bclr    d6,status(a3)
                                                      *
loc_19E30                                             *loc_19E30:
                                                      *        move.w  a0,d0
                                                      *        subi.w  #Object_RAM,d0
                                                      *    if object_size=$40
                                                      *        lsr.w   #6,d0
                                                      *    else
                                                      *        divu.w  #object_size,d0
                                                      *    endif
                                                      *        andi.w  #$7F,d0
                                                      *        move.b  d0,interact(a1)
                                                      *        move.b  #0,angle(a1)
                                                      *        move.w  #0,y_vel(a1)
                                                      *        move.w  x_vel(a1),inertia(a1)
                                                      *        btst    #1,status(a1)
                                                      *        beq.s   loc_19E7E
                                                      *        move.l  a0,-(sp)
                                                      *        movea.l a1,a0
                                                      *        move.w  a0,d1
                                                      *        subi.w  #Object_RAM,d1
                                                      *        bne.s   loc_19E76
                                                      *        cmpi.w  #2,(Player_mode).w
                                                      *        beq.s   loc_19E76
                                                      *        jsr     (Sonic_ResetOnFloor_Part2).l
                                                      *        bra.s   loc_19E7C
                                                      *; ===========================================================================
                                                      *
loc_19E76                                             *loc_19E76:
                                                      *        jsr     (Tails_ResetOnFloor_Part2).l
                                                      *
loc_19E7C                                             *loc_19E7C:
                                                      *        movea.l (sp)+,a0 ; a0=character
                                                      *
loc_19E7E                                             *loc_19E7E:
                                                      *        bset    #3,status(a1)
                                                      *        bclr    #1,status(a1)
                                                      *        bset    d6,status(a0)
                                                      *
return_19E8E                                          *return_19E8E:
        rts                                           *        rts