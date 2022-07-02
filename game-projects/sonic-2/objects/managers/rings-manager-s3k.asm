; ---------------------------------------------------------------------------
; Load_Rings
;
; This is the Ring manager for Sonic 3
; 
; ---------------------------------------------------------------------------

Rings_camera_lbound   equ 4
Rings_camera_rbound   equ 136+4

Rings_manager_routine fcb 0
Ring_start_addr_ROM   fdb 0 ; address in the ring layout of the first ring whose X position is >= camera X position - 8
Ring_end_addr_ROM     fdb 0 ; address in the ring layout of the first ring whose X position is >= camera X position + 328
Ring_start_addr_RAM   fdb 0 ; address in the ring status table of the first ring whose X position is >= camera X position - 8

Load_Rings                                            *Load_Rings:
                                                      *                moveq   #0,d0
        lda   Rings_manager_routine                   *                move.b  (Rings_manager_routine).w,d0
        ldx   #Rings_Routines                         *                move.w  off_E8B8(pc,d0.w),d0
        jmp   [a,x]                                   *                jmp     off_E8B8(pc,d0.w)
                                                      *; End of function Load_Rings
                                                      *
                                                      *; ---------------------------------------------------------------------------
Rings_Routines                                        *off_E8B8:       dc.w loc_E8BE-off_E8B8
        fdb   Rings_Init                              *                dc.w loc_E942-off_E8B8
        fdb   Rings_Main                              *                dc.w loc_E9CA-off_E8B8
        fdb   loc_E8BE                                *; ---------------------------------------------------------------------------
                                                      *
Rings_Init                                            *loc_E8BE:
        lda   #2
        sta   Rings_manager_routine                   *                addq.b  #2,(Rings_manager_routine).w
        jsr   sub_EB1A                                *                bsr.w   sub_EB1A
                                                      *                cmpi.b  #$14,(Current_zone).w
                                                      *                beq.s   loc_E904
        ldx   Ring_start_addr_ROM                     *                movea.l (Ring_start_addr_ROM).w,a1
        ldu   #Ring_status_table                      *                lea     (Ring_status_table).w,a2
        ldd   Camera_X_pos                            *                move.w  (Camera_X_pos).w,d4
        subd  #Rings_camera_lbound                    *                subq.w  #8,d4
        bhi   >                                       *                bhi.s   loc_E8E6
        ldd   #1                                      *                moveq   #1,d4
        bra   >                                       *                bra.s   loc_E8E6
                                                      *; ---------------------------------------------------------------------------
                                                      *
@a                                                    *loc_E8E2:
        leax  4,x                                     *                addq.w  #4,a1
        leau  2,u                                     *                addq.w  #2,a2
                                                      *
!                                                     *loc_E8E6:
        cmpd  ,x                                      *                cmp.w   (a1),d4
        bra   @a                                      *                bhi.s   loc_E8E2
        stx   Ring_start_addr_ROM                     *                move.l  a1,(Ring_start_addr_ROM).w
        stu   Ring_start_addr_RAM                     *                move.w  a2,(Ring_start_addr_RAM).w
        addd  #$150                                   *                addi.w  #$150,d4
        bra   >                                       *                bra.s   loc_E8FA
                                                      *; ---------------------------------------------------------------------------
                                                      *
@b                                                      *loc_E8F8:
                                                      *                addq.w  #4,a1
                                                      *
!                                                     *loc_E8FA:
        cmpd  ,x                                      *                cmp.w   (a1),d4
        bhi   @b                                      *                bhi.s   loc_E8F8
        stx   Ring_end_addr_ROM                       *                move.l  a1,(Ring_end_addr_ROM).w
        rts                                           *                rts
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E904:
                                                      *                addq.b  #2,(Rings_manager_routine).w
                                                      *                movea.l (Ring_start_addr_ROM).w,a1
                                                      *                lea     (Ring_status_table_2).w,a2
                                                      *                move.w  (Camera_Y_pos).w,d4
                                                      *                subq.w  #8,d4
                                                      *                bhi.s   loc_E920
                                                      *                moveq   #1,d4
                                                      *                bra.s   loc_E920
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E91C:
                                                      *                addq.w  #4,a1
                                                      *                addq.w  #2,a2
                                                      *
                                                      *loc_E920:
                                                      *                cmp.w   2(a1),d4
                                                      *                bhi.s   loc_E91C
                                                      *                move.l  a1,(Ring_start_addr_ROM).w
                                                      *                move.w  a2,(Ring_start_addr_RAM).w
                                                      *                addi.w  #$F0,d4
                                                      *                bra.s   loc_E936
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E934:
                                                      *                addq.w  #4,a1
                                                      *
                                                      *loc_E936:
                                                      *                cmp.w   2(a1),d4
                                                      *                bhi.s   loc_E934
                                                      *                move.l  a1,(Ring_end_addr_ROM).w
                                                      *                rts
                                                      *; ---------------------------------------------------------------------------
                                                      *
Rings_Main                                            *loc_E942:
                                                      *                bsr.s   sub_E994
                                                      *                movea.l (Ring_start_addr_ROM).w,a1
                                                      *                movea.w (Ring_start_addr_RAM).w,a2
                                                      *                move.w  (Camera_X_pos).w,d4
                                                      *                subq.w  #8,d4
                                                      *                bhi.s   loc_E95C
                                                      *                moveq   #1,d4
                                                      *                bra.s   loc_E95C
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E958:
                                                      *                addq.w  #4,a1
                                                      *                addq.w  #2,a2
                                                      *
                                                      *loc_E95C:
                                                      *                cmp.w   (a1),d4
                                                      *                bhi.s   loc_E958
                                                      *                bra.s   loc_E966
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E962:
                                                      *                subq.w  #4,a1
                                                      *                subq.w  #2,a2
                                                      *
                                                      *loc_E966:
                                                      *                cmp.w   -4(a1),d4
                                                      *                bls.s   loc_E962
                                                      *                move.l  a1,(Ring_start_addr_ROM).w
                                                      *                move.w  a2,(Ring_start_addr_RAM).w
                                                      *                movea.l (Ring_end_addr_ROM).w,a2
                                                      *                addi.w  #$150,d4
                                                      *                bra.s   loc_E980
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E97E:
                                                      *                addq.w  #4,a2
                                                      *
                                                      *loc_E980:
                                                      *                cmp.w   (a2),d4
                                                      *                bhi.s   loc_E97E
                                                      *                bra.s   loc_E988
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E986:
                                                      *                subq.w  #4,a2
                                                      *
                                                      *loc_E988:
                                                      *                cmp.w   -4(a2),d4
                                                      *                bls.s   loc_E986
                                                      *                move.l  a2,(Ring_end_addr_ROM).w
        rts                                           *                rts
                                                      *
                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *
                                                      *sub_E994:
                                                      *                lea     (Ring_consumption_table).w,a2
                                                      *                move.w  (a2)+,d1
                                                      *                subq.w  #1,d1
                                                      *                bcs.s   locret_E9C8
                                                      *
                                                      *loc_E99E:
                                                      *                move.w  (a2)+,d0
                                                      *                beq.s   loc_E99E
                                                      *                movea.w d0,a1
                                                      *                subq.b  #1,(a1)
                                                      *                bne.s   loc_E9C4
                                                      *                move.b  #6,(a1)
                                                      *                addq.b  #1,1(a1)
                                                      *                cmpi.b  #8,1(a1)
                                                      *                bne.s   loc_E9C4
                                                      *                move.w  #-1,(a1)
                                                      *                clr.w   -2(a2)
                                                      *                subq.w  #1,(Ring_consumption_table).w
                                                      *
                                                      *loc_E9C4:
                                                      *                dbf     d1,loc_E99E
                                                      *
                                                      *locret_E9C8:
                                                      *                rts
                                                      *; End of function sub_E994
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E9CA:
                                                      *                bsr.s   sub_E994
                                                      *                movea.l (Ring_start_addr_ROM).w,a1
                                                      *                movea.w (Ring_start_addr_RAM).w,a2
                                                      *                move.w  (Camera_Y_pos).w,d4
                                                      *                subq.w  #8,d4
                                                      *                bhi.s   loc_E9E4
                                                      *                moveq   #1,d4
                                                      *                bra.s   loc_E9E4
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E9E0:
                                                      *                addq.w  #4,a1
                                                      *                addq.w  #2,a2
                                                      *
                                                      *loc_E9E4:
                                                      *                cmp.w   2(a1),d4
                                                      *                bhi.s   loc_E9E0
                                                      *                bra.s   loc_E9F0
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_E9EC:
                                                      *                subq.w  #4,a1
                                                      *                subq.w  #2,a2
                                                      *
                                                      *loc_E9F0:
                                                      *                cmp.w   -2(a1),d4
                                                      *                bls.s   loc_E9EC
                                                      *                move.l  a1,(Ring_start_addr_ROM).w
                                                      *                move.w  a2,(Ring_start_addr_RAM).w
                                                      *                movea.l (Ring_end_addr_ROM).w,a2
                                                      *                addi.w  #$F0,d4
                                                      *                bra.s   loc_EA0A
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_EA08:
                                                      *                addq.w  #4,a2
                                                      *
                                                      *loc_EA0A:
                                                      *                cmp.w   2(a2),d4
                                                      *                bhi.s   loc_EA08
                                                      *                bra.s   loc_EA14
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_EA12:
                                                      *                subq.w  #4,a2
                                                      *
                                                      *loc_EA14:
                                                      *                cmp.w   -2(a2),d4
                                                      *                bls.s   loc_EA12
                                                      *                move.l  a2,(Ring_end_addr_ROM).w
                                                      *                rts
                                                      *
                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *
                                                      *Test_Ring_Collisions:
                                                      *                cmpi.b  #$5A,$34(a0)
                                                      *                bhs.w   locret_EAE4
                                                      *                movea.l (Ring_start_addr_ROM).w,a1
                                                      *                movea.l (Ring_end_addr_ROM).w,a2
                                                      *                cmpa.l  a1,a2
                                                      *                beq.w   locret_EAE4
                                                      *                movea.w (Ring_start_addr_RAM).w,a4
                                                      *                btst    #Status_LtngShield,status_secondary(a0) ; does Sonic have a Lightning Shield?
                                                      *                beq.s   Test_Ring_Collisions_NoAttraction
                                                      *                move.w  $10(a0),d2
                                                      *                move.w  $14(a0),d3
                                                      *                subi.w  #$40,d2
                                                      *                subi.w  #$40,d3
                                                      *                move.w  #6,d1
                                                      *                move.w  #$C,d6
                                                      *                move.w  #$80,d4
                                                      *                move.w  #$80,d5
                                                      *                bra.s   Test_Ring_Collisions_NextRing
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *Test_Ring_Collisions_NoAttraction:
                                                      *                move.w  $10(a0),d2
                                                      *                move.w  $14(a0),d3
                                                      *                subi.w  #8,d2
                                                      *                moveq   #0,d5
                                                      *                move.b  $1E(a0),d5
                                                      *                subq.b  #3,d5
                                                      *                sub.w   d5,d3
                                                      *                move.w  #6,d1
                                                      *                move.w  #$C,d6
                                                      *                move.w  #$10,d4
                                                      *                add.w   d5,d5
                                                      *
                                                      *Test_Ring_Collisions_NextRing:
                                                      *                tst.w   (a4)
                                                      *                bne.w   loc_EADA
                                                      *                move.w  (a1),d0
                                                      *                sub.w   d1,d0
                                                      *                sub.w   d2,d0
                                                      *                bcc.s   loc_EAA0
                                                      *                add.w   d6,d0
                                                      *                bcs.s   loc_EAA6
                                                      *                bra.w   loc_EADA
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_EAA0:
                                                      *                cmp.w   d4,d0
                                                      *                bhi.w   loc_EADA
                                                      *
                                                      *loc_EAA6:
                                                      *                move.w  2(a1),d0
                                                      *                sub.w   d1,d0
                                                      *                sub.w   d3,d0
                                                      *                bcc.s   loc_EAB8
                                                      *                add.w   d6,d0
                                                      *                bcs.s   loc_EABE
                                                      *                bra.w   loc_EADA
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_EAB8:
                                                      *                cmp.w   d5,d0
                                                      *                bhi.w   loc_EADA
                                                      *
                                                      *loc_EABE:
                                                      *                btst    #Status_LtngShield,status_secondary(a0) ; does Sonic have a Lightning Shield?
                                                      *                bne.s   Test_Ring_Collisions_AttractRing
                                                      *
                                                      *loc_EAC6:
                                                      *                move.w  #$604,(a4)
                                                      *                bsr.s   sub_EAE6
                                                      *                lea     (Ring_consumption_list).w,a3
                                                      *
                                                      *loc_EAD0:
                                                      *                tst.w   (a3)+
                                                      *                bne.s   loc_EAD0
                                                      *                move.w  a4,-(a3)
                                                      *                addq.w  #1,(Ring_consumption_table).w
                                                      *
                                                      *loc_EADA:
                                                      *                addq.w  #4,a1
                                                      *                addq.w  #2,a4
                                                      *                cmpa.l  a1,a2
                                                      *                bne.w   Test_Ring_Collisions_NextRing
                                                      *
                                                      *locret_EAE4:
                                                      *                rts
                                                      *; End of function Test_Ring_Collisions
                                                      *
                                                      *
                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *
                                                      *sub_EAE6:
                                                      *                subq.w  #1,(Perfect_rings_left).w
                                                      *                jmp     (GiveRing).l
                                                      *; End of function sub_EAE6
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *Test_Ring_Collisions_AttractRing:
                                                      *                movea.l a1,a3
                                                      *                jsr     (Create_New_Sprite).l
                                                      *                bne.w   loc_EB16
                                                      *                move.l  #Obj_Attracted_Ring,(a1)
                                                      *                move.w  (a3),x_pos(a1)
                                                      *                move.w  2(a3),y_pos(a1)
                                                      *                move.w  a4,$30(a1)
                                                      *                move.w  #-1,(a4)
                                                      *                rts
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_EB16:
                                                      *                movea.l a3,a1
                                                      *                bra.s   loc_EAC6
                                                      *
                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *
                                                      *sub_EB1A:
                                                      *                moveq   #0,d0
                                                      *                tst.b   (Respawn_table_keep).w
                                                      *                bne.s   loc_EB30
                                                      *                lea     (Ring_status_table).w,a1
                                                      *                move.w  #$FF,d1
                                                      *
                                                      *loc_EB2A:
                                                      *                move.l  d0,(a1)+
                                                      *                dbf     d1,loc_EB2A
                                                      *
                                                      *loc_EB30:
                                                      *                lea     (Ring_consumption_table).w,a1
                                                      *                moveq   #$1F,d1
                                                      *
                                                      *loc_EB36:
                                                      *                move.l  d0,(a1)+
                                                      *                dbf     d1,loc_EB36
                                                      *                cmpi.b  #$14,(Current_zone).w
                                                      *                bne.s   loc_EB52
                                                      *                lea     (Ring_status_table_2).w,a1
                                                      *                move.w  #$FF,d1
                                                      *
                                                      *loc_EB4C:
                                                      *                move.l  d0,(a1)+
                                                      *                dbf     d1,loc_EB4C
                                                      *
                                                      *loc_EB52:
                                                      *                move.w  (Current_zone_and_act).w,d0
                                                      *                ror.b   #1,d0
                                                      *                lsr.w   #5,d0
                                                      *                lea     (RingLocPtrs).l,a1
                                                      *                movea.l (a1,d0.w),a1
                                                      *                move.l  a1,(Ring_start_addr_ROM).w
                                                      *                addq.w  #4,a1
                                                      *                moveq   #0,d5
                                                      *                move.w  #$1FE,d0
                                                      *
                                                      *loc_EB70:
                                                      *                tst.l   (a1)+
                                                      *                bmi.s   loc_EB7A
                                                      *                addq.w  #1,d5
                                                      *                dbf     d0,loc_EB70
                                                      *
                                                      *loc_EB7A:
                                                      *                move.w  d5,(Perfect_rings_left).w
                                                      *                move.w  #0,(_unkFF06).w
                                                      *                rts
                                                      *; End of function sub_EB1A
                                                      *
                                                      *
                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *
                                                      *Render_Rings:
                                                      *                movea.l (Ring_start_addr_ROM).w,a0
                                                      *                move.l  (Ring_end_addr_ROM).w,d2
                                                      *                sub.l   a0,d2
                                                      *                beq.s   locret_EBEC
                                                      *                movea.w (Ring_start_addr_RAM).w,a4
                                                      *                lea     CMap_Ring(pc),a1
                                                      *                move.w  4(a3),d4
                                                      *                move.w  #$F0,d5
                                                      *                move.w  (Screen_Y_wrap_value).w,d3
                                                      *
                                                      *loc_EBA6:
                                                      *                tst.w   (a4)+
                                                      *                bmi.s   loc_EBE6
                                                      *                move.w  2(a0),d1
                                                      *                sub.w   d4,d1
                                                      *                addq.w  #8,d1
                                                      *                and.w   d3,d1
                                                      *                cmp.w   d5,d1
                                                      *                bhs.s   loc_EBE6
                                                      *                addi.w  #$78,d1
                                                      *                move.w  (a0),d0
                                                      *                sub.w   (a3),d0
                                                      *                addi.w  #$80,d0
                                                      *                move.b  -1(a4),d6
                                                      *                bne.s   loc_EBCE
                                                      *                move.b  (Rings_frame).w,d6
                                                      *
                                                      *loc_EBCE:
                                                      *                lsl.w   #3,d6
                                                      *                lea     (a1,d6.w),a2
                                                      *                add.w   (a2)+,d1
                                                      *                move.w  d1,(a6)+
                                                      *                move.w  (a2)+,d6
                                                      *                move.b  d6,(a6)
                                                      *                addq.w  #2,a6
                                                      *                move.w  (a2)+,(a6)+
                                                      *                add.w   (a2)+,d0
                                                      *                move.w  d0,(a6)+
                                                      *                subq.w  #1,d7
                                                      *
                                                      *loc_EBE6:
                                                      *                addq.w  #4,a0
                                                      *                subq.w  #4,d2
                                                      *                bne.s   loc_EBA6
                                                      *
                                                      *locret_EBEC:
                                                      *                rts
                                                      *; End of function Render_Rings
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *; Custom mappings format. Compare to Map_Ring.
                                                      *
                                                      *; Differences include...
                                                      *;  No offset table (each sprite assumed to be 8 bytes)
                                                      *;  No 'sprite pieces per frame' value (hardcoded to 1)
                                                      *;  Sign-extended Y-pos value
                                                      *;  Sign-extended sprite size value
                                                      *
                                                      *CMap_Ring:
                                                      *;frame1:
                                                      *                dc.w $FFF8
                                                      *                dc.w $0005
                                                      *                dc.w $0000+make_art_tile(ArtTile_Ring,1,0)
                                                      *                dc.w $FFF8
                                                      *
                                                      *;frame2:
                                                      *                dc.w $FFF8
                                                      *                dc.w $0005
                                                      *                dc.w $0004+make_art_tile(ArtTile_Ring,1,0)
                                                      *                dc.w $FFF8
                                                      *
                                                      *;frame3:
                                                      *                dc.w $FFF8
                                                      *                dc.w $0001
                                                      *                dc.w $0008+make_art_tile(ArtTile_Ring,1,0)
                                                      *                dc.w $FFFC
                                                      *
                                                      *;frame4:
                                                      *                dc.w $FFF8
                                                      *                dc.w $0005
                                                      *                dc.w $0804+make_art_tile(ArtTile_Ring,1,0)
                                                      *                dc.w $FFF8
                                                      *
                                                      *;frame5:
                                                      *                dc.w $FFF8
                                                      *                dc.w $0005
                                                      *                dc.w $000A+make_art_tile(ArtTile_Ring,1,0)
                                                      *                dc.w $FFF8
                                                      *
                                                      *;frame6:
                                                      *                dc.w $FFF8
                                                      *                dc.w $0005
                                                      *                dc.w $180A+make_art_tile(ArtTile_Ring,1,0)
                                                      *                dc.w $FFF8
                                                      *
                                                      *;frame7:
                                                      *                dc.w $FFF8
                                                      *                dc.w $0005
                                                      *                dc.w $080A+make_art_tile(ArtTile_Ring,1,0)
                                                      *                dc.w $FFF8
                                                      *
                                                      *;frame8:
                                                      *                dc.w $FFF8
                                                      *                dc.w $0005
                                                      *                dc.w $100A+make_art_tile(ArtTile_Ring,1,0)
                                                      *                dc.w $FFF8