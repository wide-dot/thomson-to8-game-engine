 ; TODO line 725 : a quick fix was made for frame rate adjustment


        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256
                                                      * ; ===========================================================================
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; Object 11 - Bridge in Emerald Hill Zone and Hidden Palace Zone
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; OST Variables:
Obj11_child1       equ ext_variables_obj    ; word    * Obj11_child1            = objoff_30     ; pointer to first set of bridge segments
Obj11_child2       equ ext_variables_obj+2  ; word    * Obj11_child2            = objoff_34     ; pointer to second set of bridge segments, if applicable
Obj11_p2_log_pos   equ ext_variables_obj+4  ; byte = objoff_3B
Obj11_baseYPos     equ ext_variables_obj+5  ; word = objoff_3C
Obj11_depressTimer equ ext_variables_obj+7  ; byte = objoff_3E
Obj11_p1_log_pos   equ ext_variables_obj+8  ; byte = objoff_3F

framerate_adjust   equ 4 ; for code specific adjustment, search "framerate adjust" comment
max_press          equ 64 ; dont change this value, it's an angle (90°) must be a multiple of framerate_adjust
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
        jmp   [a,x]                                   *         jmp     Obj11_Index(pc,d1.w)
                                                      * ; ===========================================================================
!                                                     * +       ; child sprite objects only need to be drawn
        lda   #3                                      *         move.w  #$180,d0
        jmp   DisplaySprite3                          *         bra.w   DisplaySprite3
                                                      * ; ===========================================================================
                                                      * ; off_F68C:
Obj11_Index                                           * Obj11_Index:    offsetTable
        fdb   Obj11_Init                              *                 offsetTableEntry.w Obj11_Init           ; 0
        fdb   Obj11_EHZ                               *                 offsetTableEntry.w Obj11_EHZ            ; 2
        fdb   DisplaySprite ; unused                  *                 offsetTableEntry.w Obj11_Display        ; 4
        fdb   Obj11_HPZ                               *                 offsetTableEntry.w Obj11_HPZ            ; 6
                                                      * ; ===========================================================================
                                                      * ; loc_F694: Obj11_Main:
Obj11_Init                                            * Obj11_Init:
        inc   routine,u                               *         addq.b  #2,routine(a0)
        ldd   #Img_bridge_log   
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
        ldd   #Img_bridge_log   
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
        lslb  ; wide-dot factor                       *         lsl.w   #4,d0   ; (d0/2) * 16
        negb
        sex
        addd  x_pos,u                                 *         sub.w   d0,d3   ; x position of left half
        std   glb_d3
        ;                                             *         swap    d1      ; store subtype in high word for later
        ldb   #8 ; make 8 logs                        *         move.w  #8,d1
        stb   glb_d1_b
        jsr   Obj11_MakeBdgSegment                    *         bsr.s   Obj11_MakeBdgSegment
        ldd   sub6_x_pos,x                            *         move.w  sub6_x_pos(a1),d0
        subd  #4 ; wide-dot factor                    *         subq.w  #8,d0
        std   mainspr_x_pos,x                         *         move.w  d0,x_pos(a1)            ; center of first subsprite object
        stx   Obj11_child1,u                          *         move.l  a1,Obj11_child1(a0)     ; pointer to first subsprite object
        lda   subtype,u                               *         swap    d1      ; retrieve subtype
        suba  #8                                      *         subq.w  #8,d1
        sta   glb_d1_b
        bls   >                                       *         bls.s   +       ; branch, if subtype <= 8 (bridge has no more than 8 logs)
                                                      *         ; else, create a second subsprite object for the rest of the bridge
        sta   glb_d4_b                                *         move.w  d1,d4
        jsr   Obj11_MakeBdgSegment                    *         bsr.s   Obj11_MakeBdgSegment
        stx   Obj11_child2,u                          *         move.l  a1,Obj11_child2(a0)     ; pointer to second subsprite object
        ldb   glb_d4_b                                *         move.w  d4,d0
        lslb                                          *         add.w   d0,d0
        addb  glb_d4_b
        lslb  ; *6                                    *         add.w   d4,d0   ; d0*3
        addb  #sub2_x_pos
        ldd   b,x ; load x_pos of center log          *         move.w  sub2_x_pos(a1,d0.w),d0
        subd  #4  ; wide-dot factor                   *         subq.w  #8,d0
        std   mainspr_x_pos,x                         *         move.w  d0,x_pos(a1)            ; center of second subsprite object
!                                                     * +
        bra   Obj11_EHZ                               *         bra.s   Obj11_EHZ
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * ; sub_F728:
Obj11_MakeBdgSegment                                  * Obj11_MakeBdgSegment:
        jsr   LoadObject_x                            *         jsrto   (SingleObjLoad2).l, JmpTo_SingleObjLoad2
        beq   >                                       *         bne.s   +       ; rts
        lda   id,u
        sta   id,x                                    *         _move.b id(a0),id(a1) ; load obj11
        ; useless will beoverwritten later            *         move.w  x_pos(a0),x_pos(a1)
        ldd   y_pos,u
        std   mainspr_y_pos,x                         *         move.w  y_pos(a0),y_pos(a1)
        ldd   image_set,u
        std   mainspr_mapframe,x                      *         move.l  mappings(a0),mappings(a1)
        ;                                             *         move.w  art_tile(a0),art_tile(a1)
        lda   render_flags,u                          *         move.b  render_flags(a0),render_flags(a1)
        ora   #render_subobjects_mask                 *         bset    #6,render_flags(a1)
        sta   render_flags,x
        lda   #$20 ; wide-dot factor
        sta   mainspr_width,x                         *         move.b  #$40,mainspr_width(a1)
        ldb   glb_d1_b ; hold number of logs to process
        stb   mainspr_childsprites,x                  *         move.b  d1,mainspr_childsprites(a1)
        ;                                             *         subq.b  #1,d1
        leay  sub2_x_pos,x                            *         lea     sub2_x_pos(a1),a2 ; starting address for subsprite data
                                                      * 
@a      ldd   glb_d3
        std   ,y++                                    * -       move.w  d3,(a2)+        ; sub?_x_pos
        addd  #8 ; wide-dot factor
        std   glb_d3
        ldd   glb_d2
        std   ,y++                                    *         move.w  d2,(a2)+        ; sub?_y_pos
        ldd   #Img_bridge_log
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
        lda   status,u                                *         move.b  status(a0),d0
        anda  #standing_mask                          *         andi.b  #standing_mask,d0
        bne   >          ; player standing on bridge  *         bne.s   +
        ldb   Obj11_depressTimer,u                    *         tst.b   objoff_3E(a0)
        beq   loc_F7BC   ; branch if timeout          *         beq.s   loc_F7BC
        subb  #4*framerate_adjust ; decrease press timer
        stb   Obj11_depressTimer,u                    *         subq.b  #4,objoff_3E(a0)
        bra   loc_F7B8   ; refresh depress            *         bra.s   loc_F7B8
                                                      * +
                                                      *         andi.b  #p2_standing,d0
                                                      *         beq.s   ++
                                                      *         move.b  objoff_3F(a0),d0
                                                      *         sub.b   objoff_3B(a0),d0
                                                      *         beq.s   ++
                                                      *         bcc.s   +
                                                      *         addq.b  #1,objoff_3F(a0)
                                                      *         bra.s   ++
                                                      * ; ---------------------------------------------------------------------------
                                                      * +
                                                      *         subq.b  #1,objoff_3F(a0)
!                                                     * +
        ldb   Obj11_depressTimer,u 
        cmpb  #max_press ; check max press value      *         cmpi.b  #$40,objoff_3E(a0)
        beq   loc_F7B8                                *         beq.s   loc_F7B8
        addb  #4*framerate_adjust
        stb   Obj11_depressTimer,u                    *         addq.b  #4,objoff_3E(a0)
                                                      * 
loc_F7B8                                              * loc_F7B8:
        jsr   Obj11_Depress                           *         bsr.w   Obj11_Depress
                                                      * 
loc_F7BC                                              * loc_F7BC:
        ;                                             *         moveq   #0,d1
        lda   subtype,u                               *         move.b  subtype(a0),d1
        lsla
        lsla           ; wide-dot factor              *         lsl.w   #3,d1
        tfr   a,b                                     *         move.w  d1,d2
        adda  #4       ; wide-dot factor              *         addq.w  #8,d1
        sta   glb_d1_b
        anda  #0
        sta   glb_d1   ; store half seg. len. (8+nblogs*8)/2
        lslb                                          *         add.w   d2,d2
        std   glb_d2   ; store half seg. len. (8+nblogs*8)
        ldb   #8       
        std   glb_d3   ; hard coded obj y radius      *         moveq   #8,d3
        ldd   x_pos,u                                 *         move.w  x_pos(a0),d4
        std   glb_d4
        jsr   sub_F872                                *         bsr.w   sub_F872
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
        subd  glb_camera_x_pos_coarse                 *         sub.w   (Camera_X_pos_coarse).w,d0
        cmpd  #$40+160+$20+$40  ; wide-dot factor     *         cmpi.w  #$280,d0
        bhi   >                                       *         bhi.s   +
        rts                                           *         rts
                                                      * ; ---------------------------------------------------------------------------
!                                                     * +       ; delete first subsprite object
        ldx   Obj11_child1,u                          *         movea.l Obj11_child1(a0),a1 ; a1=object
        jsr   DeleteObject2                           *         bsr.w   DeleteObject2
        ldb   subtype,u
        cmpb  #8                                      *         cmpi.b  #8,subtype(a0)
        bls   >                                       *         bls.s   +       ; if bridge has more than 8 logs, delete second subsprite object
        ldx   Obj11_child2,u                          *         movea.l Obj11_child2(a0),a1 ; a1=object
        jsr   DeleteObject2                           *         bsr.w   DeleteObject2
!                                                     * +
        jmp   DeleteObject                            *         bra.w   DeleteObject
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
                                                      * +
                                                      *         andi.b  #p2_standing,d0
                                                      *         beq.s   ++
                                                      *         move.b  objoff_3F(a0),d0
                                                      *         sub.b   objoff_3B(a0),d0
                                                      *         beq.s   ++
                                                      *         bcc.s   +
                                                      *         addq.b  #1,objoff_3F(a0)
                                                      *         bra.s   ++
                                                      * ; ===========================================================================
                                                      * +
                                                      *         subq.b  #1,objoff_3F(a0)
                                                      * +
                                                      *         cmpi.b  #$40,objoff_3E(a0)
                                                      *         beq.s   loc_F84E
                                                      *         addq.b  #4,objoff_3E(a0)
                                                      * 
                                                      * loc_F84E:
                                                      *         bsr.w   Obj11_Depress
                                                      * 
                                                      * loc_F852:
                                                      *         moveq   #0,d1
                                                      *         move.b  subtype(a0),d1
                                                      *         lsl.w   #3,d1
                                                      *         move.w  d1,d2
                                                      *         addq.w  #8,d1
                                                      *         add.w   d2,d2
                                                      *         moveq   #8,d3
                                                      *         move.w  x_pos(a0),d4
                                                      *         bsr.w   sub_F872
        ; bridge log lights                           *         bsr.w   sub_F912
                                                      *         bra.w   Obj11_Unload
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * 
        ; for each of the two players
        ; process position on the bridge
sub_F872                                              * sub_F872:
                                                      *         lea     (Sidekick).w,a1 ; a1=character
                                                      *         moveq   #p2_standing_bit,d6
                                                      *         moveq   #objoff_3B,d5
                                                      *         movem.l d1-d4,-(sp)
                                                      *         bsr.s   +
                                                      *         movem.l (sp)+,d1-d4
        ;                                             *         lea     (MainCharacter).w,a1 ; a1=character
        ;                                             *         subq.b  #1,d6
        ;
        ;                                             *         moveq   #objoff_3F,d5
                                                      * +
        lda   status,u
        anda  #status_mainchar_standing               *         btst    d6,status(a0)
        beq   loc_F8F0                                *         beq.s   loc_F8F0
        lda   dp+status
        anda  #status_inair                           *         btst    #1,status(a1)
        bne   PlyNotOnBridge ; ply is in air          *         bne.s   +
        ;                                             *         moveq   #0,d0
        ldd   dp+x_pos                                *         move.w  x_pos(a1),d0
        subd  x_pos,u ; dist ply vs bridge segment    *         sub.w   x_pos(a0),d0
        addd  glb_d1  ; half seg. len. (8+nblogs*8)/2 *         add.w   d1,d0
        std   glb_d0
        bmi   PlyNotOnBridge ; ply is before bridge   *         bmi.s   +
        cmpd  glb_d2 ; bridge seg. px size (nblogs*8) *         cmp.w   d2,d0
        blo   PlyOnBridge                             *         blo.s   ++
        ; continue if ply is after the bridge
PlyNotOnBridge                                        * +
        lda   dp+status
        anda  #^status_norgroundnorfall               *         bclr    #3,status(a1)
        sta   dp+status
        lda   status,u
        anda  #^status_mainchar_standing              *         bclr    d6,status(a0)
        sta   status,u
        ldd   #0
        std   glb_d4                                  *         moveq   #0,d4
        rts                                           *         rts
                                                      * ; ===========================================================================
PlyOnBridge                                           * +
        ldb   glb_d0_b
        lsrb
        lsrb
        lsrb  ; wide-dot factor                       *         lsr.w   #4,d0
        stb   Obj11_p1_log_pos,u                      *         move.b  d0,(a0,d5.w)
        ldx   Obj11_child1,u                          *         movea.l Obj11_child1(a0),a2
        cmpb  #8                                      *         cmpi.w  #8,d0
        blo   >                                       *         blo.s   +
        ldx   Obj11_child2,u                          *         movea.l Obj11_child2(a0),a2 ; a2=object
        subb  #8                                      *         subi_.w #8,d0
!                                                     * +
        lslb                                          *         add.w   d0,d0
        stb   @dx6                                    *         move.w  d0,d1
        lslb                                          *         add.w   d0,d0
        addb  #0 ; x6                                 *         add.w   d1,d0
@dx6    equ   *-1
        abx
        ldd   sub2_y_pos,x ; get log y_pos            *         move.w  sub2_y_pos(a2,d0.w),d0
        subd  #8           ; get log floor value      *         subq.w  #8,d0
        std   glb_d0
        anda  #0                                      *         moveq   #0,d1
        ldb   dp+y_radius  ; get player floor value   *         move.b  y_radius(a1),d1
        std   glb_d1
        ldd   glb_d0
        subd  glb_d1                                  *         sub.w   d1,d0
        std   dp+y_pos     ; stick player to object   *         move.w  d0,y_pos(a1)
        ldd   #0
        std   glb_d4                                  *         moveq   #0,d4
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 

loc_F8F0                                              * loc_F8F0:
        ldd   glb_d1
        std   @d1                                     *         move.w  d1,-(sp)
        jsr   PlatformObject11_cont                   *         jsrto   (PlatformObject11_cont).l, JmpTo_PlatformObject11_cont
        ldd   #0
@d1     equ     *-2                                   *         move.w  (sp)+,d1
        std   glb_d1
        lda   status,u
        anda  #status_mainchar_standing               *         btst    d6,status(a0)
        beq   >                                       *         beq.s   +       ; rts
        ;                                             *         moveq   #0,d0
        ldd   dp+x_pos                                *         move.w  x_pos(a1),d0
        subd  x_pos,u                                 *         sub.w   x_pos(a0),d0
        addd  glb_d1                                  *         add.w   d1,d0
        _lsrd
        _lsrd
        _lsrd ; wide-dot factor                       *         lsr.w   #4,d0
        stb   Obj11_p1_log_pos,u                      *         move.b  d0,(a0,d5.w)
!                                                     * +
        rts                                           *         rts
                                                      * ; End of function sub_F872
                                                      * 
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
 ; subroutine to make the bridge light on where Sonic or Tails walks over
sub_F912                                              * sub_F912:
                                                      *         moveq   #0,d0
        ldd   dp+x_vel                                *         tst.w   (MainCharacter+x_vel).w
        bne   >                                       *         bne.s   +
        ldb   gfxlock.frame.count+1 ; vint as anim timer    *         move.b  (Vint_runcount+3).w,d0
        andb  #$1C                                    *         andi.w  #$1C,d0
        lsrb                 ; val 0,2,4,6,8,10,12,14 *         lsr.w   #1,d0
!       ;                                             * +
        ldx   #byte_F950                              *         moveq   #0,d2
        ldd   b,x ; load word in one op               *         move.b  byte_F950+1(pc,d0.w),d2
        std   glb_d2                                  *         swap    d2
        ;                                             *         move.b  byte_F950(pc,d0.w),d2
        ;                                             *         moveq   #0,d0
        ;                                             *         tst.w   (Sidekick+x_vel).w
        ;                                             *         bne.s   +
        ;                                             *         move.b  (Vint_runcount+3).w,d0
        ;                                             *         andi.w  #$1C,d0
        ;                                             *         lsr.w   #1,d0
!       ;                                             * +
        ;                                             *         moveq   #0,d6
        ;                                             *         move.b  byte_F950+1(pc,d0.w),d6
        ;                                             *         swap    d6
        ;                                             *         move.b  byte_F950(pc,d0.w),d6
        bra   >                                       *         bra.s   +
                                                      * ; ===========================================================================
 ; this table reference bridge log map frames for glowing effect
 ; right value is for player active log
 ; left value is for active side logs
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
        ldb   #-2                                     *         moveq   #-2,d3           ; init value if p1 is not standing on bridge, will result in all logs set to frame 0
        ;                                             *         moveq   #-2,d4
        lda   status,u                                *         move.b  status(a0),d0
        anda  #p1_standing                            *         andi.b  #p1_standing,d0
        beq   >                                       *         beq.s   +
        ldb   Obj11_p1_log_pos,u                      *         move.b  objoff_3F(a0),d3
!                                                     * +
        ;                                             *         move.b  status(a0),d0
        ;                                             *         andi.b  #p2_standing,d0
        ;                                             *         beq.s   +
        ;                                             *         move.b  objoff_3B(a0),d4
!                                                     * +
        ldx   Obj11_child1,u                          *         movea.l Obj11_child1(a0),a1
        leay  sub9_mapframe+next_subspr,x             *         lea     sub9_mapframe+next_subspr(a1),a2
        sty   glb_a2 ; ptr to end of bridge logs mapframe
        leax  sub2_mapframe,x                         *         lea     sub2_mapframe(a1),a1
        stx   glb_a1 ; ptr to start of bridge logs mapframe
                                                      *         moveq   #0,d1
        lda   subtype,u                               *         move.b  subtype(a0),d1 ; set number of bridge logs to process
        ; dec is for dbf                              *         subq.b  #1,d1
        sta   glb_d1_b
        lda   #0
        sta   glb_d5_b                                *         moveq   #0,d5          ; init current log index in loop to 0
                                                      * 
 ; this loop set all bridge log mapframes
 ; --------------------------------------
@loop   lda   #0                                      * -       moveq   #0,d0     ; default mapframe is 0 (light off)
        decb                                          *         subq.w  #1,d3
        cmpb  glb_d5_b                                *         cmp.b   d3,d5     ; test if current processed log is the one at p1 left side
        bne   >                                       *         bne.s   +         ; branch if not
        lda   glb_d2                                  *         move.w  d2,d0     ; else set mapframe with current glowing value for side log
!                                                     * +
        addb  #2                                      *         addq.w  #2,d3
        cmpb  glb_d5_b                                *         cmp.b   d3,d5     ; test if current processed log is the one at p1 right side     
        bne   >                                       *         bne.s   +         ; branch if not
        lda   glb_d2                                  *         move.w  d2,d0     ; else set mapframe with current glowing value for side log
!                                                     * +
        decb                                          *         subq.w  #1,d3     ; reset p1 log position
        ;                                             *         subq.w  #1,d4     ; do the same with p2 log pos
        ;                                             *         cmp.b   d4,d5
        ;                                             *         bne.s   +
        ;                                             *         move.w  d6,d0
!                                                     * +
        ;                                             *         addq.w  #2,d4
        ;                                             *         cmp.b   d4,d5
        ;                                             *         bne.s   +
        ;                                             *         move.w  d6,d0
!                                                     * +
        ;                                             *         subq.w  #1,d4
        cmpb  glb_d5_b                                *         cmp.b   d3,d5     ; test if current processed log is the one at p1 pos
        bne   >                                       *         bne.s   +         ; branch if not
        ;                                             *         swap    d2
        lda   glb_d2+1                                *         move.w  d2,d0     ; else set mapframe with current glowing value for active log
        ;                                             *         swap    d2
!                                                     * +
        ;                                             *         cmp.b   d4,d5     ; same for p2
        ;                                             *         bne.s   +
        ;                                             *         swap    d6
        ;                                             *         move.w  d6,d0
        ;                                             *         swap    d6
!                                                     * +
        sta   ,x                                      *         move.b  d0,(a1)   ; apply mapframe to log subsprite
        inc   glb_d5_b                                *         addq.w  #1,d5     ; move to next bridge log
        leax  next_subspr,x                           *         addq.w  #6,a1
        cmpx  glb_a2                                  *         cmpa.w  a2,a1     ; test the end of current subsprite
        bne   >                                       *         bne.s   +         ; branch if not
        ldx   Obj11_child2,u                          *         movea.l Obj11_child2(a0),a1 ; a1=object ; move to next subsprite
        leax  sub2_mapframe,x                         *         lea     sub2_mapframe(a1),a1
!       dec   glb_d1_b                                * +       dbf     d1,-      ; loop until all bridge logs are processed
        bne   @loop                                   * 
        rts                                           *         rts
                                                      * ; End of function sub_F912
                                                      * 
                                                      * ; ===========================================================================
                                                      * 

                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * ; subroutine to make the bridge push down where Sonic or Tails walks over
                                                      * ; loc_F9E8:
Obj11_Depress                                         * Obj11_Depress:
        ldb   Obj11_depressTimer,u ; get timer value  *         move.b  objoff_3E(a0),d0
        jsr   CalcSine             ; apply sin        *         jsrto   (CalcSine).l, JmpTo_CalcSine ; apply sine function to depress timer
        std   glb_d4                                  *         move.w  d0,d4
        ldx   #byte_FB28                              *         lea     (byte_FB28).l,a4
        anda  #0                                      *         moveq   #0,d0
        ldb   subtype,u ; get bridge length           *         move.b  subtype(a0),d0
        _lsld
        _lsld
        _lsld
        _lsld ; bridge length *16                     *         lsl.w   #4,d0
        std   glb_d0
        anda  #0                                      *         moveq   #0,d3
        ldb   Obj11_p1_log_pos,u                      *         move.b  objoff_3F(a0),d3
        stb   glb_d2_b                                *         move.w  d3,d2
        addd  glb_d0
        std   glb_d3                                  *         add.w   d0,d3
                                                      *         moveq   #0,d5
        ldy   #Obj11_DepressionOffsets-$80            *         lea     (Obj11_DepressionOffsets-$80).l,a5 ; table begin at length 8 so apply an offset of 8x16 bytes
        lda   d,y ; TODO read overflow d=$0AC4        *         move.b  (a5,d3.w),d5
        sta   glb_d5_b
        anda  #0
        ldb   glb_d2_b ; faster to get value in d2    *         andi.w  #$F,d3
        _lsld
        _lsld
        _lsld
        _lsld ;ply log pos*16                         *         lsl.w   #4,d3
        leax  d,x                                     *         lea     (a4,d3.w),a3
        ldy   Obj11_child1,u                          *         movea.l Obj11_child1(a0),a1
        sty   glb_a1
        leay  sub9_y_pos+next_subspr,y                *         lea     sub9_y_pos+next_subspr(a1),a2
        sty   glb_a2 ; set end loop position
        ldy   glb_a1
        leay  sub2_y_pos,y                            *         lea     sub2_y_pos(a1),a1
 ; process logs on player's left                      * 
@loop   anda  #0                                      * -       moveq   #0,d0
        ldb   ,x+                                     *         move.b  (a3)+,d0   ; load factor based on player position
        addd  #1                                      *         addq.w  #1,d0      ; add one to factor ($FF gives $100)
        tsta
        bne   >
        lda   glb_d5_b
        mul      ; depression offset * bend factor    *         mulu.w  d5,d0
        bra   @skip
!       lda   glb_d5_b ; multiply by $100
        andb  #0
@skip   stx   @x
        tfr   d,x    ; depression offset * bend factor (9bits)
        ldd   glb_d4 ; sin of timer value (9bits)
        jsr   Mul9x16                                 *         mulu.w  d4,d0
        ldx   #0
@x      equ   *-2
        tfr   a,b                                     *         swap    d0
        anda  #0
        addd  Obj11_baseYPos,u                        *         add.w   objoff_3C(a0),d0
        std   ,y ; set y_pos                          *         move.w  d0,(a1)
        leay  next_subspr,y                           *         addq.w  #6,a1
        sty   glb_a1
        cmpy  glb_a2 ; end of first sub object ?      *         cmpa.w  a2,a1
        bne   >                                       *         bne.s   +
        ldy   Obj11_child2,u ; yes load 2nd sub obj   *         movea.l Obj11_child2(a0),a1 ; a1=object
        leay  sub2_y_pos,y                            *         lea     sub2_y_pos(a1),a1
!       dec   glb_d2_b       ; dec nb of log          * +       dbf     d2,-
        bpl   @loop

                                                      * 
        ;                                             *         moveq   #0,d0
        ;                                             *         move.b  subtype(a0),d0
        anda  #0                                      *         moveq   #0,d3
        ldb   Obj11_p1_log_pos,u ; we are processing  *         move.b  objoff_3F(a0),d3
        incb  ; from the first log on player's right  *         addq.b  #1,d3
        subb  subtype,u                               *         sub.b   d0,d3
        negb                                          *         neg.b   d3
        bmi   @rts      ; p1 is on last bridge log    *         bmi.s   ++      ; rts
        std   glb_d2    ; store nb of log to process  *         move.w  d3,d2
        _lsld
        _lsld
        _lsld
        _lsld           ; *16 to get the desired line in factor table
        std   glb_d3                                  *         lsl.w   #4,d3
        ldx   #byte_FB28
        leax  d,x       ; select the line             *         lea     (a4,d3.w),a3
        ldd   glb_d2
        leax  d,x       ; add remaining nb logs, point on $FF value       *         adda.w  d2,a3
        dec   glb_d2_b  ; decrement nb of log to process                              *         subq.w  #1,d2
        bmi   @rts                                    *         bcs.s   ++      ; rts
; process logs on player's right                      * 
@loop   anda  #0                                      * -       moveq   #0,d0
        ldb   ,-x  ; decrement and load, get the value on the left of $FF                                   *         move.b  -(a3),d0
        addd  #1                                      *         addq.w  #1,d0
        tsta
        bne   >
        lda   glb_d5_b
        mul                                           *         mulu.w  d5,d0
        bra   @skip
!       lda   glb_d5_b ; multiply by $100    
        andb  #0
@skip   stx   @x
        tfr   d,x
        ldd   glb_d4 ; sin of timer value
        jsr   Mul9x16                                 *         mulu.w  d4,d0
        ldx   #0
@x      equ   *-2
        tfr   a,b                                     *         swap    d0
        anda  #0
        addd  Obj11_baseYPos,u                        *         add.w   objoff_3C(a0),d0
        std   ,y ; set y_pos                          *         move.w  d0,(a1)
        leay  next_subspr,y                           *         addq.w  #6,a1
        cmpy  glb_a2                                  *         cmpa.w  a2,a1
        bne   >                                       *         bne.s   +
        ldy   Obj11_child2,u                          *         movea.l Obj11_child2(a0),a1 ; a1=object
        leay  sub2_y_pos,y                            *         lea     sub2_y_pos(a1),a1
!       dec   glb_d2_b                                * +       dbf     d2,-
        bpl   @loop
@rts                                                  * +
        rts                                           *         rts

                                                      * ; ===========================================================================
                                                      * ; seems to be bridge piece vertical position offset data
 ; maximum vertical position offset for each log of each bridge size
 ; (vertical depth of the bridge according to its length)
 ; the value read is the one that match player position
 ; this max value is applied to all logs
 ; first line is for bridge of length 8 and so on
 
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
 ; bridge curve for left or right log segment from player position
 ; factor = (table value+1)*(1/256)
 ; factor is applied on the depression offset of a log
 ; left log segment: select table line that matches segment length (bridge start to player pos), read values from left to right 
 ; right log segment: select table line that matches remaining logs (player pos to bridge end), select column=nb remaining log , read values from right to left

byte_FB28                                                                   * byte_FB28:
        fcb $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0                               *         dc.b $FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 16  ; segment length 1
        fcb $B5,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0                             *         dc.b $B5,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 32  ; segment length 2
        fcb $7E,$DB,$FF,0,0,0,0,0,0,0,0,0,0,0,0,0                           *         dc.b $7E,$DB,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 48  ; segment length 3
        fcb $61,$B5,$EC,$FF,0,0,0,0,0,0,0,0,0,0,0,0                         *         dc.b $61,$B5,$EC,$FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0; 64  ; ...
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
        fcb $19,$31,$4A,$67,$7E,$93,$A7,$BD,$CD,$DB,$E7,$F3,$F9,$FE,$FF,0   *         dc.b $19,$31,$4A,$67,$7E,$93,$A7,$BD,$CD,$DB,$E7,$F3,$F9,$FE,$FF,  0; 240 ; ...
        fcb $19,$31,$4A,$61,$78,$8E,$A2,$B5,$C5,$D4,$E1,$EC,$F4,$FB,$FE,$FF *         dc.b $19,$31,$4A,$61,$78,$8E,$A2,$B5,$C5,$D4,$E1,$EC,$F4,$FB,$FE,$FF; 256 ; segment length 16
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

@rts
	rts
                                                      *; ===========================================================================
                                                      *; Used only by EHZ/HPZ log bridges. Very similar to PlatformObject_cont, but
                                                      *; d2 already has the full width of the log.
                                                      *;loc_19D9C:
PlatformObject11_cont                                 *PlatformObject11_cont:
        tst   dp+y_vel                                *        tst.w   y_vel(a1)
        bmi   @rts ; exit if ply is moving up         *        bmi.w   return_19E8E
        ldd   dp+x_pos                                *        move.w  x_pos(a1),d0
        subd  x_pos,u                                 *        sub.w   x_pos(a0),d0
        addd  glb_d1 ; half seg. len. (8+nblogs*8)/2  *        add.w   d1,d0
        bmi   @rts ; ply is before bridge             *        bmi.w   return_19E8E
        cmpd  glb_d2 ; bridge seg. px size (nblogs*8) *        cmp.w   d2,d0
        bhs   @rts ; ply is on the bridge             *        bhs.w   return_19E8E
        bra   loc_19DD8 ; ply is after bridge         *        bra.s   loc_19DD8
                                                      *; ===========================================================================
                                                      *;loc_19DBA:
PlatformObject_cont                                   *PlatformObject_cont:
        tst   dp+y_vel                                *        tst.w   y_vel(a1)
        bmi   @rts                                    *        bmi.w   return_19E8E
        ldd   glb_d1
        addd  glb_d1
        std   @d1x2
        ldd   dp+x_pos                                *        move.w  x_pos(a1),d0
        subd  x_pos,u                                 *        sub.w   x_pos(a0),d0
        addd  glb_d1                                  *        add.w   d1,d0
        bmi   @rts                                    *        bmi.w   return_19E8E
        ;                                             *        add.w   d1,d1
        cmpd  #0                                      *        cmp.w   d1,d0
@d1x2   equ   *-2
        bhs   @rts                                    *        bhs.w   return_19E8E
                                                      *
loc_19DD8                                             *loc_19DD8:
        ldd   y_pos,u                                 *        move.w  y_pos(a0),d0
        subd  glb_d3                                  *        sub.w   d3,d0
        std   glb_d0
                                                      *;loc_19DDE:
PlatformObject_ChkYRange                              *PlatformObject_ChkYRange:
        ldd   dp+y_pos                                *        move.w  y_pos(a1),d2
	std   glb_d2
        ldb   dp+y_radius                             *        move.b  y_radius(a1),d1
        sex                                           *        ext.w   d1
        addd  glb_d2                                  *        add.w   d2,d1
        addd  #4                                      *        addq.w  #4,d1
        std   glb_d1
        ldd   glb_d0
        subd  glb_d1                                  *        sub.w   d1,d0
        bhi   return_19E8E                            *        bhi.w   return_19E8E
        std   glb_d0
        cmpd  glb_col_y_range_neg ; framerate adjust  *        cmpi.w  #-$10,d0
        blo   return_19E8E                            *        blo.w   return_19E8E
        tst   dp+obj_control                          *        tst.b   obj_control(a1)
        bmi   return_19E8E                            *        bmi.w   return_19E8E
        ldb   dp+routine
        cmpb  #3 ; dead, gone or respawning           *        cmpi.b  #6,routine(a1)
        bhs   return_19E8E                            *        bhs.w   return_19E8E
        ldd   glb_d2
        addd  glb_d0                                  *        add.w   d0,d2
        addd  #3                                      *        addq.w  #3,d2
        std   dp+y_pos                                *        move.w  d2,y_pos(a1)
                                                      *;loc_19E14:
RideObject_SetRide                                    *RideObject_SetRide:
        ldb   dp+status
        andb  #status_norgroundnorfall                *        btst    #3,status(a1)
        beq   loc_19E30                               *        beq.s   loc_19E30
                                                      *        moveq   #0,d0
        ldx   dp+interact                             *        move.b  interact(a1),d0
        ; in this version interact store the address  *    if object_size=$40
        ;                                             *        lsl.w   #6,d0
                                                      *    else
        ;                                             *        mulu.w  #object_size,d0
                                                      *    endif
        ;                                             *        addi.l  #Object_RAM,d0
        ;                                             *        movea.l d0,a3   ; a3=object
        ldb   status,x
        andb  #^status_mainchar_standing
        stb   status,x                                *        bclr    d6,status(a3)
                                                      *
loc_19E30                                             *loc_19E30:
        ; in this version interact store the address  *        move.w  a0,d0
        ;                                             *        subi.w  #Object_RAM,d0
                                                      *    if object_size=$40
        ;                                             *        lsr.w   #6,d0
                                                      *    else
        ;                                             *        divu.w  #object_size,d0
                                                      *    endif
        ;                                             *        andi.w  #$7F,d0
        stu   dp+interact                             *        move.b  d0,interact(a1)
        ldd   #0
        stb   dp+angle                                *        move.b  #0,angle(a1)
        std   dp+y_vel                                *        move.w  #0,y_vel(a1)
        ldd   dp+x_vel
        std   dp+inertia                              *        move.w  x_vel(a1),inertia(a1)
        lda   dp+status
        anda  #status_inair                           *        btst    #1,status(a1)
        beq   loc_19E7E                               *        beq.s   loc_19E7E
        ;                                             *        move.l  a0,-(sp)
        ;                                             *        movea.l a1,a0
        ;                                             *        move.w  a0,d1
        ;                                             *        subi.w  #Object_RAM,d1
        ;                                             *        bne.s   loc_19E76
        ;                                             *        cmpi.w  #2,(Player_mode).w
        ;                                             *        beq.s   loc_19E76
        jsr   Sonic_ResetOnFloor_Part2                *        jsr     (Sonic_ResetOnFloor_Part2).l
                                                      *        bra.s   loc_19E7C
                                                      *; ===========================================================================
                                                      *
loc_19E76                                             *loc_19E76:
        ;                                             *        jsr     (Tails_ResetOnFloor_Part2).l
                                                      *
loc_19E7C                                             *loc_19E7C:
        ;                                             *        movea.l (sp)+,a0 ; a0=character
                                                      *
loc_19E7E                                             *loc_19E7E:
        ldb   dp+status
        orb   #status_norgroundnorfall                *        bset    #3,status(a1)
        andb  #^status_inair                          *        bclr    #1,status(a1)
        stb   dp+status
        ldb   status,u
        orb   #status_mainchar_standing
        stb   status,u                                *        bset    d6,status(a0)
                                                      *
return_19E8E                                          *return_19E8E:
        rts                                           *        rts

Sonic_ResetOnFloor_Part2
        rts