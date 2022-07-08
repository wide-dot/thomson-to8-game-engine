; ---------------------------------------------------------------------------
; Load_Rings
;
; This is the Ring manager for Sonic 3, with some changes to fit sonic 2
; 
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"    

; All sprites coordinates are image centered
Rings_width             equ 8
Rings_height            equ 16
Rings_view_width        equ 136
Rings_view_height       equ 160

nb_rings                equ dp_engine

Load_Rings                                            *Load_Rings:
                                                      *                moveq   #0,d0
        ; a is set by caller                          *                move.b  (Rings_manager_routine).w,d0
        ldx   #Rings_Routines                         *                move.w  off_E8B8(pc,d0.w),d0
        jmp   [b,x]                                   *                jmp     off_E8B8(pc,d0.w)
                                                      *; End of function Load_Rings
                                                      *
Rings_Routines                                        *; ---------------------------------------------------------------------------
        fdb   Rings_Init                              *off_E8B8:       dc.w loc_E8BE-off_E8B8
        fdb   Rings_Main                              *                dc.w loc_E942-off_E8B8
        fdb   Render_Rings ; used for external call
        fdb   Touch_Rings  ; used for external call
                                                      *                dc.w loc_E9CA-off_E8B8
                                                      *; ---------------------------------------------------------------------------
                                                      *
Rings_Init                                            *loc_E8BE:

        ; this routine init start and end pointers
        ; to rings position and consumption arrays
        ; based on camera x position

        ; a is set by caller                          *                addq.b  #2,(Rings_manager_routine).w
        jsr   Rings_Setup                             *                bsr.w   sub_EB1A
                                                      *                cmpi.b  #$14,(Current_zone).w
                                                      *                beq.s   loc_E904
        ldx   Ring_start_addr_layout                  *                movea.l (Ring_start_addr_ROM).w,a1
        ldu   #Ring_status_table                      *                lea     (Ring_status_table).w,a2
        ldd   glb_camera_x_pos                        *                move.w  (Camera_X_pos).w,d4
        subd  #Rings_width/2                          *                subq.w  #8,d4
        bhi   >                                       *                bhi.s   loc_E8E6
        ldd   #1 ; no negative values allowed         *                moveq   #1,d4
        bra   >                                       *                bra.s   loc_E8E6
                                                      *; ---------------------------------------------------------------------------
                                                      *
@a                                                    *loc_E8E2:
        leax  4,x ; load next ring                    *                addq.w  #4,a1
        leau  2,u                                     *                addq.w  #2,a2
                                                      *
!                                                     *loc_E8E6:
        cmpd  ,x ; ring X pos < camera X pos?         *                cmp.w   (a1),d4
        bhi   @a ; if yes move to next ring           *                bhi.s   loc_E8E2

        ; start position found, store index
        stx   Ring_start_addr_layout                  *                move.l  a1,(Ring_start_addr_ROM).w
        stu   Ring_start_addr_status                  *                move.w  a2,(Ring_start_addr_RAM).w
        ; advance by a screen
        addd  #(Rings_width/2)+Rings_view_width       *                addi.w  #$150,d4
        bra   >                                       *                bra.s   loc_E8FA
                                                      *; ---------------------------------------------------------------------------
                                                      *
@b                                                      *loc_E8F8:
        leax  4,x ; load next ring                    *                addq.w  #4,a1
                                                      *
!                                                     *loc_E8FA:
        cmpd  ,x ; ring X pos < camera X + screen?    *                cmp.w   (a1),d4
        bhi   @b                                      *                bhi.s   loc_E8F8
        ; end position found, store index
        stx   Ring_end_addr_layout                    *                move.l  a1,(Ring_end_addr_ROM).w
        rts                                           *                rts
                                                      *; ---------------------------------------------------------------------------
                                                      *
        ; special stage unimplemented                 *loc_E904:
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
        ; end of special stage specific               *                rts
                                                      *; ---------------------------------------------------------------------------
                                                      *

Rings_Main                                            *loc_E942:
        jsr   Rings_Consume                           *                bsr.s   sub_E994
        ldy   Ring_start_addr_layout                  *                movea.l (Ring_start_addr_ROM).w,a1
        ldu   Ring_start_addr_status                  *                movea.w (Ring_start_addr_RAM).w,a2
        ldx   glb_camera_x_pos                        *                move.w  (Camera_X_pos).w,d4
        leax  -(Rings_width/2),x                      *                subq.w  #8,d4
        cmpx  #1
        bge   >                                       *                bhi.s   loc_E95C
        ldx   #1 ; camera x pos capped to 1           *                moveq   #1,d4
        bra   >                                       *                bra.s   loc_E95C
                                                      *; ---------------------------------------------------------------------------
                                                      *
@a                                                    *loc_E958:
        leay  4,y                                     *                addq.w  #4,a1
        leau  2,u                                     *                addq.w  #2,a2
                                                      *
!                                                     *loc_E95C:
        cmpx  ,y                                      *                cmp.w   (a1),d4
        bhi   @a ; search first ring for this         *                bhi.s   loc_E958
        bra   >  ; camera x position moving forward   *                bra.s   loc_E966
                                                      *; ---------------------------------------------------------------------------
                                                      *
@b                                                    *loc_E962:
        leay  -4,y                                    *                subq.w  #4,a1
        leau  -2,u                                    *                subq.w  #2,a2
                                                      *
!                                                     *loc_E966:
        cmpx  -4,y ; search moving rearward           *                cmp.w   -4(a1),d4
        bls   @b                                      *                bls.s   loc_E962
        sty   Ring_start_addr_layout                  *                move.l  a1,(Ring_start_addr_ROM).w
        stu   Ring_start_addr_status                  *                move.w  a2,(Ring_start_addr_RAM).w
        ldu   Ring_end_addr_layout                    *                movea.l (Ring_end_addr_ROM).w,a2
        leax  (Rings_width/2)+Rings_view_width,x      *                addi.w  #$150,d4
        bra   >                                       *                bra.s   loc_E980
                                                      *; ---------------------------------------------------------------------------
                                                      *
@c                                                    *loc_E97E:
        leau  4,u                                     *                addq.w  #4,a2
                                                      *
!                                                     *loc_E980:
        cmpx  ,u ; search last ring for this          *                cmp.w   (a2),d4
        bhi   @c ; camera x position moving forward   *                bhi.s   loc_E97E
        bra   >                                       *                bra.s   loc_E988
                                                      *; ---------------------------------------------------------------------------
                                                      *
@d                                                    *loc_E986:
        leau  -4,u                                    *                subq.w  #4,a2
                                                      *
!                                                     *loc_E988:
        cmpx  -4,u ; search moving rearward           *                cmp.w   -4(a2),d4
        bls   @d                                      *                bls.s   loc_E986
        stu   Ring_end_addr_layout                    *                move.l  a2,(Ring_end_addr_ROM).w
        rts                                           *                rts
                                                      *

                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *

Rings_Consume                                         *sub_E994:
        ldx   #Ring_consumption_table                 *                lea     (Ring_consumption_table).w,a2
        ldy   ,x++ ; rings currently being consumed?  *                move.w  (a2)+,d1
        ;                                             *                subq.w  #1,d1
        beq   @end ; exit if no ring                  *                bcs.s   locret_E9C8
                                                      *
@loop                                                 *loc_E99E:
        ldu   ,x++  ; is there a ring in this slot?   *                move.w  (a2)+,d0
        beq   @loop ; branch if not                   *                beq.s   loc_E99E
        ;                                             *                movea.w d0,a1
        lda   ,u
        suba  Vint_Main_runcount
        sta   ,u    ; decrement timer                 *                subq.b  #1,(a1)
        bpl   @next ; branch if not ready             *                bne.s   loc_E9C4
        adda  #6                                      *                move.b  #6,(a1)
        sta   ,u    ; reset timer
        lda   1,u                                     *                addq.b  #1,1(a1)
        inca        ; increment frame (stars)
        sta   1,u
        cmpa  #8    ; is it destruction time yet ?    *                cmpi.b  #8,1(a1)
        bne   @next                                   *                bne.s   loc_E9C4
        ldd   #-1
        std   ,u    ; destroy ring                    *                move.w  #-1,(a1)
        ldd   #0
        std   -2,x  ; clear ring entry                *                clr.w   -2(a2)
        ldd   Ring_consumption_table                  *                subq.w  #1,(Ring_consumption_table).w
        subd  #1
        std   Ring_consumption_table ; subtract count
                                                      *
@next                                                 *loc_E9C4:
        leay  -1,y
        bne   @loop ; next ring, else exit            *                dbf     d1,loc_E99E
                                                      *
@end                                                  *locret_E9C8:
        rts                                           *                rts
                                                      *; End of function sub_E994
                                                      *
                                                      *; ---------------------------------------------------------------------------
                                                      *
        ; unused (special stage)                      *loc_E9CA:
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
 ; end of unsused code                                *                rts
                                                      *
                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *
Touch_Rings                                           *Test_Ring_Collisions:
        lda   invulnerable_time,u                     *                cmpi.b  #$5A,$34(a0)
        cmpa  #$5A
        bhs   @rts                                    *                bhs.w   locret_EAE4
        ;                                             *                movea.l (Ring_start_addr_ROM).w,a1
        ldx   Ring_start_addr_layout                  *                movea.l (Ring_end_addr_ROM).w,a2
        cmpx  Ring_end_addr_layout                    *                cmpa.l  a1,a2
        bne   >                                       *                beq.w   locret_EAE4 ; branch if no rings in this area
@rts    rts
!       ldy   Ring_start_addr_status                  *                movea.w (Ring_start_addr_RAM).w,a4
        ;                                             *                btst    #Status_LtngShield,status_secondary(a0) ; does Sonic have a Lightning Shield?
        ;                                             *                beq.s   Test_Ring_Collisions_NoAttraction
        ;ldd   x_pos,u                                *                move.w  $10(a0),d2
        ;subd  #$40
        ;std   glb_d2
        ;ldd   y_pos,u                                *                move.w  $14(a0),d3
        ;subd  #$40
        ;std   glb_d3
        ;                                             *                subi.w  #$40,d2
        ;                                             *                subi.w  #$40,d3
        ;                                             *                move.w  #6,d1
        ;                                             *                move.w  #$C,d6
        ;ldd   #$80
        ;std   glb_d4                                 *                move.w  #$80,d4
        ;std   glb_d5                                 *                move.w  #$80,d5
        ;bra   Test_Ring_Collisions_NextRing          *                bra.s   Test_Ring_Collisions_NextRing
                                                     *; ---------------------------------------------------------------------------
                                                      *
        ;                                             *Test_Ring_Collisions_NoAttraction:
        ldd   x_pos,u                                 *                move.w  $10(a0),d2
        ;                                             *                move.w  $14(a0),d3
        subd  #8                                                                         ; assume X radius to be 8
        std   glb_d2                                  *                subi.w  #8,d2
        anda  #0                                      *                moveq   #0,d5
        ldb   y_radius,u                              *                move.b  $1E(a0),d5
        subb  #3                                      *                subq.b  #3,d5
        std   glb_d5
        ldd   y_pos,u
        subd  glb_d5 
        std   glb_d3                                  *                sub.w   d5,d3     ; subtract (Y radius - 3) from Y pos
        ;                                             *                move.w  #6,d1     ; set ring radius
        ;                                             *                move.w  #$C,d6    ; set ring diameter
        ldd   #$10
        std   glb_d4                                  *                move.w  #$10,d4   ; set Sonic's X diameter
        ldd   glb_d5        
        addd  glb_d5
        std   glb_d5                                  *                add.w   d5,d5     ; set Y diameter
                                                      *
Test_Ring_Collisions_NextRing                         *Test_Ring_Collisions_NextRing:
        ldd   ,y                                      *                tst.w   (a4)      ; has this ring already been collided with?
        bne   Touch_NextRing                          *                bne.w   loc_EADA  ; if it has, branch
        ldd   ,x                                      *                move.w  (a1),d0   ; get ring X pos
        subd  #3                                      *                sub.w   d1,d0     ; get ring left edge X pos
        subd  glb_d2                                  *                sub.w   d2,d0     ; subtract Sonic's left edge X pos
        bcc   >                                       *                bcc.s   loc_EAA0  ; if Sonic's to the left of the ring, branch
        addd  #6                                      *                add.w   d6,d0     ; add ring diameter
        bcs   @a                                      *                bcs.s   loc_EAA6  ; if Sonic's colliding, branch
        bra   Touch_NextRing                          *                bra.w   loc_EADA  ; otherwise, test next ring
                                                      *; ---------------------------------------------------------------------------
                                                      *
!                                                     *loc_EAA0:
        cmpd  glb_d4                                  *                cmp.w   d4,d0     ; has Sonic crossed the ring?
        bhi   Touch_NextRing                          *                bhi.w   loc_EADA  ; if he has, branch
                                                      *
@a                                                    *loc_EAA6:
        ldd   2,x                                     *                move.w  2(a1),d0  ; get ring Y pos
        subd  #6                                      *                sub.w   d1,d0     ; get ring top edge pos
        subd  glb_d3                                  *                sub.w   d3,d0     ; subtract Sonic's top edge pos
        bcc   >                                       *                bcc.s   loc_EAB8  ; if Sonic's above the ring, branch
        addd  #12                                     *                add.w   d6,d0     ; add ring diameter
        bcs   @b                                      *                bcs.s   loc_EABE  ; if Sonic's colliding, branch
        bra   Touch_NextRing                          *                bra.w   loc_EADA  ; otherwise, test next ring
                                                      *; ---------------------------------------------------------------------------
                                                      *
!                                                     *loc_EAB8:
        cmpd  glb_d5                                  *                cmp.w   d5,d0     ; has Sonic crossed the ring?
        bhi   Touch_NextRing                          *                bhi.w   loc_EADA  ; if he has, branch
                                                      *
@b                                                    *loc_EABE:
        ;                                             *                btst    #Status_LtngShield,status_secondary(a0) ; does Sonic have a Lightning Shield?
        ;                                             *                bne.s   Test_Ring_Collisions_AttractRing
                                                      *
                                                      *loc_EAC6:
        ldd   #$604
        std   ,y                                      *                move.w  #$604,(a4) ; set frame and destruction timer
        jsr   Touch_ConsumeRing                      *                bsr.s   sub_EAE6
        stx   @x
        ldx   #Ring_consumption_list                  *                lea     (Ring_consumption_list).w,a3
                                                      *
!                                                     *loc_EAD0:
        ldd   ,x++                                    *                tst.w   (a3)+      ; is this slot free?
        bne   <                                       *                bne.s   loc_EAD0   ; if not, repeat until you find one
        sty   ,--x                                    *                move.w  a4,-(a3)   ; set ring address
        ldd   Ring_consumption_table
        addd  #1
        std   Ring_consumption_table                  *                addq.w  #1,(Ring_consumption_table).w ; increase count
        ldx   #0
@x      equ   *-2
                                                      *
Touch_NextRing                                        *loc_EADA:
        leax  4,x                                     *                addq.w  #4,a1
        leay  2,y                                     *                addq.w  #2,a4
        cmpx  Ring_end_addr_layout                    *                cmpa.l  a1,a2
        bne   Test_Ring_Collisions_NextRing           *                bne.w   Test_Ring_Collisions_NextRing
                                                      *
                                                      *locret_EAE4:
        rts                                           *                rts
                                                      *; End of function Test_Ring_Collisions

                                                      *
                                                      *
                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *
Touch_ConsumeRing                                     *sub_EAE6:
        ;                                             *                subq.w  #1,(Perfect_rings_left).w
        jmp   CollectRing_Sonic                       *                jmp     (GiveRing).l
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
Rings_Setup                                           *sub_EB1A:
        ldx   #0                                      *                moveq   #0,d0
        tst   Respawn_table_keep                      *                tst.b   (Respawn_table_keep).w
        bne   @keep                                   *                bne.s   loc_EB30
        ldy   #Ring_status_table                      *                lea     (Ring_status_table).w,a1
        lda   #$FF                                    *                move.w  #$FF,d1
                                                      *
                                                      *loc_EB2A:
!       stx   ,y++                                    *                move.l  d0,(a1)+
        stx   ,y++                                    *                dbf     d1,loc_EB2A
        deca                                          *
        bne   <
@keep                                                 *loc_EB30:
        ldy   #Ring_consumption_table                 *                lea     (Ring_consumption_table).w,a1
        lda   #$1F                                    *                moveq   #$1F,d1
                                                      *
                                                      *loc_EB36:
!       stx   ,y++                                    *                move.l  d0,(a1)+
        deca                                          *                dbf     d1,loc_EB36
        bne   <
        ; special stage specific                      *                cmpi.b  #$14,(Current_zone).w
        ; unimplemented                               *                bne.s   loc_EB52
        ;                                             *                lea     (Ring_status_table_2).w,a1
        ;                                             *                move.w  #$FF,d1
                                                      *
        ;                                             *loc_EB4C:
        ;                                             *                move.l  d0,(a1)+
        ;                                             *                dbf     d1,loc_EB4C
                                                      *
        ;                                             *loc_EB52:
        ldd   Current_zone_and_act                    *                move.w  (Current_zone_and_act).w,d0
        ;                                             *                ror.b   #1,d0
        ;                                             *                lsr.w   #5,d0
        ldx   #RingLocPtrs                            *                lea     (RingLocPtrs).l,a1
        ldd   d,x                                     *                movea.l (a1,d0.w),a1
        std   Ring_start_addr_layout                  *                move.l  a1,(Ring_start_addr_ROM).w
        ; perfect ring count                          *                addq.w  #4,a1
        ; unimplemeted                                *                moveq   #0,d5
        ;                                             *                move.w  #$1FE,d0
        ;                                             *
        ;                                             *loc_EB70:
        ;                                             *                tst.l   (a1)+
        ;                                             *                bmi.s   loc_EB7A
        ;                                             *                addq.w  #1,d5
        ;                                             *                dbf     d0,loc_EB70
        ;                                             *
        ;                                             *loc_EB7A:
        ;                                             *                move.w  d5,(Perfect_rings_left).w
        ;                                             *                move.w  #0,(_unkFF06).w
        rts                                           *                rts
                                                      *; End of function sub_EB1A
                                                      *
                                                      *
                                                      *; =============== S U B R O U T I N E =======================================
                                                      *
                                                      *

Render_Rings                                          *Render_Rings:
                                                      *                movea.l (Ring_start_addr_ROM).w,a0
        ldd   Ring_end_addr_layout                    *                move.l  (Ring_end_addr_ROM).w,d2
        subd  Ring_start_addr_layout                  *                sub.l   a0,d2
        beq   @rts ; branch if no rings to display    *                beq.s   locret_EBEC
        _asrd
        _asrd
        stb   nb_rings
        ldx   Ring_start_addr_layout
        ldu   Ring_start_addr_status                  *                movea.w (Ring_start_addr_RAM).w,a4
                                                      *                lea     CMap_Ring(pc),a1
                                                      *                move.w  4(a3),d4
                                                      *                move.w  #$F0,d5
                                                      *                move.w  (Screen_Y_wrap_value).w,d3
                                                      *
@loop                                                 *loc_EBA6:
        tst   ,u++                                    *                tst.w   (a4)+
        bmi   @next ; branch if ring is consumed      *                bmi.s   loc_EBE6
        ldd   2,x   ; get ring Y pos                  *                move.w  2(a0),d1
        subd  glb_camera_y_pos                        *                sub.w   d4,d1
        addd  #Rings_height/2                         *                addq.w  #8,d1
        anda  #$07
        andb  #$FF  ; level Y loop                    *                and.w   d3,d1
        cmpd  #Rings_view_height+Rings_height         *                cmp.w   d5,d1
        bhs   @next ; ring is out of y screen range   *                bhs.s   loc_EBE6
        addb  #20-(Rings_height/2) ; on screen pos    *                addi.w  #$78,d1
        lda   1,x   ; get ring X pos                  *                move.w  (a0),d0
        anda  #%11111110 ; scroll step is 2px
        inca             ; fix ring position
        suba  glb_camera_x_pos+1                      *                sub.w   (a3),d0
        adda  #12   ; on screen position of camera    *                addi.w  #$80,d0
        lsra                                ; x=x/2, sprites moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB interlace  
        bcs   @RAM2First                    ; Branch if write must begin in RAM2 first
@RAM1First
        sta   @dyn1
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$C000                        ; (dynamic)
@dyn1   equ   *-1        
        std   <glb_screen_location_2
        suba  #$20
        std   <glb_screen_location_1     
        bra   @end
@RAM2First
        sta   @dyn2
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$A000                        ; (dynamic)
@dyn2   equ   *-1        
        std   <glb_screen_location_2
        addd  #$2001
        std   <glb_screen_location_1
@end
        lda   -1,u  ; get ring frame                  *                move.b  -1(a4),d6
        bne   >     ; use specific frame (stars)      *                bne.s   loc_EBCE
        lda   Rings_anim_frame ; use global frame     *                move.b  (Rings_frame).w,d6
                                                      *
!                                                     *loc_EBCE:
        pshs  x,u
        ldu   glb_screen_location_2
        ldx   #Ring_Images
        asla
        jsr   [a,x]
        puls  x,u
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
@next                                                 *loc_EBE6:
        leax  4,x                                     *                addq.w  #4,a0
        dec   nb_rings                                *                subq.w  #4,d2
        bne   @loop                                   *                bne.s   loc_EBA6
                                                      *
@rts                                                  *locret_EBEC:
        rts                                           *                rts
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

                                                      ; Sonic 2 code here ...
CollectRing_Sonic                                     *CollectRing_Sonic:
        ldd   Ring_count
        cmpd  #999                                    *        cmpi.w  #999,(Rings_Collected).w ; did Sonic collect 999 or more rings?
        bhs   >                                       *        bhs.s   CollectRing_1P          ; if yes, branch
        addd  #1                                      *        addq.w  #1,(Rings_Collected).w  ; add 1 to the number of collected rings
        std   Ring_count                              *
!                                                     *CollectRing_1P:
                                                      *
                                                      *    if gameRevision=0
                                                      *        cmpi.w  #999,(Ring_count).w     ; does the player 1 have 999 or more rings?
                                                      *        bhs.s   +                       ; if yes, skip the increment
                                                      *        addq.w  #1,(Ring_count).w       ; add 1 to the ring count
                                                      *+
                                                      *        ori.b   #1,(Update_HUD_rings).w ; set flag to update the ring counter in the HUD
                                                      *        move.w  #SndID_Ring,d0          ; prepare to play the ring sound
                                                      *    else
                                                      *        move.w  #SndID_Ring,d0          ; prepare to play the ring sound
                                                      *        cmpi.w  #999,(Ring_count).w     ; does the player 1 have 999 or more rings?
                                                      *        bhs.s   JmpTo_PlaySoundStereo   ; if yes, play the ring sound
                                                      *        addq.w  #1,(Ring_count).w       ; add 1 to the ring count
                                                      *        ori.b   #1,(Update_HUD_rings).w ; set flag to update the ring counter in the HUD
                                                      *    endif
                                                      *
                                                      *        cmpi.w  #100,(Ring_count).w     ; does the player 1 have less than 100 rings?
                                                      *        blo.s   JmpTo_PlaySoundStereo   ; if yes, play the ring sound
                                                      *        bset    #1,(Extra_life_flags).w ; test and set the flag for the first extra life
                                                      *        beq.s   +                       ; if it was clear before, branch
                                                      *        cmpi.w  #200,(Ring_count).w     ; does the player 1 have less than 200 rings?
                                                      *        blo.s   JmpTo_PlaySoundStereo   ; if yes, play the ring sound
                                                      *        bset    #2,(Extra_life_flags).w ; test and set the flag for the second extra life
                                                      *        bne.s   JmpTo_PlaySoundStereo   ; if it was set before, play the ring sound
                                                      *+
                                                      *        addq.b  #1,(Life_count).w       ; add 1 to the life count
                                                      *        addq.b  #1,(Update_HUD_lives).w ; add 1 to the displayed life count
                                                      *        move.w  #MusID_ExtraLife,d0     ; prepare to play the extra life jingle
                                                      *
                                                      *JmpTo_PlaySoundStereo ; JmpTo
                                                      *        jmp     (PlaySoundStereo).l
                                                      *; ===========================================================================
        rts                                           *        rts
                                                      *; ===========================================================================

;--------------------------------------------------------------------------------------------------
Ring_start_addr_layout  fdb 0 ; address in the ring layout of the first ring whose X position is >= camera X position - 8
Ring_end_addr_layout    fdb 0 ; address in the ring layout of the first ring whose X position is >= camera X position + 328
Ring_start_addr_status  fdb 0 ; address in the ring status table of the first ring whose X position is >= camera X position - 8

Ring_status_table       fill 0,$400 ; 1 word per ring (512 rings max)
Ring_consumption_table             ; $80 bytes ; stores the addresses of all rings currently being consumed
Ring_consumption_count  fdb 0       ; the number of rings being consumed currently
Ring_consumption_list   fill 0,$7E  ; the remaining part of the ring consumption table

RingLocPtrs
        fdb   EHZ1_Rings
        fdb   EHZ2_Rings

EHZ1_Rings INCLUDEBIN ".\objects\managers\rings\EHZ_1_INDIVIDUAL.bin"
EHZ2_Rings INCLUDEBIN ".\objects\managers\rings\EHZ_2_INDIVIDUAL.bin"

Ring_Images
        fdb   draw_img_ring_1
        fdb   draw_img_ring_2
        fdb   draw_img_ring_3
        fdb   draw_img_ring_4
        fdb   draw_img_ring_sparkle_1
        fdb   draw_img_ring_sparkle_2
        fdb   draw_img_ring_sparkle_3
        fdb   draw_img_ring_sparkle_4

draw_img_ring_1

	leau  199,u

	lda   #$33
	sta   121,u
	lda   #$3f
	sta   -80,u
	sta   -120,u
	lda   #$54
	sta   81,u
	ldd   40,u
	anda  #$f0
	ora   #$03
	ldb   #$f5
	std   40,u
	ldd   ,u
	anda  #$f0
	andb  #$f0
	addd  #$0403
	std   ,u
	lda   -40,u
	anda  #$f0
	ora   #$05
	sta   -40,u
	leau  -280,u

	lda   #$3f
	sta   120,u
	sta   80,u
	lda   #$35
	sta   40,u
	sta   ,u
	ldd   -80,u
	anda  #$f0
	andb  #$f0
	addd  #$0503
	std   -80,u
	lda   -40,u
	anda  #$f0
	ora   #$05
	sta   -40,u
	ldd   -120,u
	anda  #$f0
	ora   #$04
	ldb   #$34
	std   -120,u
	leau  -179,u

	lda   #$55
	sta   20,u
	lda   #$ff
	sta   -20,u

	ldu    <glb_screen_location_1
	leau  199,u

	lda   120,u
	anda  #$f0
	ora   #$03
	sta   120,u
	lda   -119,u
	anda  #$f0
	ora   #$05
	sta   -119,u
	ldd   80,u
	lda   #$35
	andb  #$0f
	orb   #$30
	std   80,u
	ldd   40,u
	lda   #$5f
	andb  #$0f
	orb   #$40
	std   40,u
	ldd   ,u
	anda  #$0f
	ora   #$f0
	ldb   #$54
	std   ,u
	lda   #$35
	sta   -79,u
	lda   #$45
	sta   -39,u
	leau  -279,u

	lda   120,u
	anda  #$f0
	ora   #$05
	sta   120,u
	lda   80,u
	anda  #$f0
	ora   #$05
	sta   80,u
	lda   40,u
	anda  #$f0
	ora   #$05
	sta   40,u
	ldd   -81,u
	anda  #$0f
	ora   #$40
	ldb   #$4f
	std   -81,u
	lda   #$35
	sta   ,u
	lda   #$3f
	sta   -40,u
	ldd   -121,u
	lda   #$53
	andb  #$0f
	orb   #$50
	std   -121,u
	leau  -181,u

	ldd   20,u
	lda   #$55
	andb  #$0f
	orb   #$f0
	std   20,u
	lda   -20,u
	anda  #$f0
	ora   #$05
	sta   -20,u
        rts

draw_img_ring_2

	leau  200,u

	ldd   -81,u
	anda  #$f0
	andb  #$f0
	addd  #$0303
	std   -81,u
	ldd   -121,u
	anda  #$f0
	andb  #$f0
	addd  #$0303
	std   -121,u
	lda   #$53
	sta   80,u
	lda   #$45
	sta   40,u
	lda   120,u
	anda  #$0f
	ora   #$30
	sta   120,u
	lda   ,u
	anda  #$f0
	ora   #$05
	sta   ,u
	lda   -40,u
	anda  #$f0
	ora   #$04
	sta   -40,u
	leau  -280,u

	ldd   119,u
	anda  #$f0
	andb  #$f0
	addd  #$0303
	std   119,u
	ldd   79,u
	anda  #$f0
	andb  #$f0
	addd  #$0303
	std   79,u
	ldd   39,u
	anda  #$f0
	andb  #$f0
	addd  #$0303
	std   39,u
	ldd   -1,u
	anda  #$f0
	andb  #$f0
	addd  #$0303
	std   -1,u
	lda   -40,u
	anda  #$f0
	ora   #$04
	sta   -40,u
	lda   -80,u
	anda  #$f0
	ora   #$04
	sta   -80,u
	lda   #$35
	sta   -120,u
	leau  -180,u

	lda   #$5f
	sta   20,u
	lda   -20,u
	anda  #$0f
	ora   #$50
	sta   -20,u

	ldu    <glb_screen_location_1
	leau  199,u

	lda   120,u
	anda  #$f0
	ora   #$03
	sta   120,u
	lda   80,u
	anda  #$f0
	ora   #$04
	sta   80,u
	ldd   40,u
	lda   #$35
	andb  #$0f
	orb   #$30
	std   40,u
	ldd   ,u
	lda   #$54
	andb  #$0f
	orb   #$40
	std   ,u
	ldd   -40,u
	anda  #$0f
	andb  #$0f
	addd  #$5050
	std   -40,u
	ldd   -80,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   -80,u
	ldd   -120,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   -120,u
	leau  -279,u

	ldd   -81,u
	lda   #$53
	andb  #$0f
	orb   #$f0
	std   -81,u
	ldd   -121,u
	lda   #$45
	andb  #$0f
	orb   #$50
	std   -121,u
	ldd   119,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   119,u
	ldd   79,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   79,u
	ldd   39,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   39,u
	ldd   -1,u
	anda  #$0f
	andb  #$0f
	addd  #$40f0
	std   -1,u
	ldd   -41,u
	anda  #$0f
	andb  #$0f
	addd  #$50f0
	std   -41,u
	leau  -181,u

	lda   20,u
	anda  #$f0
	ora   #$05
	sta   20,u
	lda   -20,u
	anda  #$f0
	ora   #$04
	sta   -20,u
        rts

draw_img_ring_3

	leau  200,u

	lda   120,u
	anda  #$0f
	ora   #$30
	sta   120,u
	lda   #$53
	sta   -80,u
	sta   -120,u
	lda   #$43
	sta   80,u
	sta   40,u
	sta   ,u
	sta   -40,u
	leau  -280,u

	lda   #$53
	sta   120,u
	lda   #$54
	sta   80,u
	lda   #$f4
	sta   40,u
	sta   ,u
	sta   -40,u
	sta   -80,u
	lda   #$f5
	sta   -120,u
	leau  -180,u

	sta   20,u
	lda   -20,u
	anda  #$0f
	ora   #$50
	sta   -20,u

	ldu    <glb_screen_location_1
	leau  159,u

	lda   120,u
	anda  #$f0
	ora   #$03
	sta   120,u
	lda   80,u
	anda  #$f0
	ora   #$03
	sta   80,u
	lda   40,u
	anda  #$f0
	ora   #$03
	sta   40,u
	lda   ,u
	anda  #$f0
	ora   #$03
	sta   ,u
	lda   -40,u
	anda  #$f0
	ora   #$03
	sta   -40,u
	lda   -80,u
	anda  #$f0
	ora   #$03
	sta   -80,u
	lda   -120,u
	anda  #$f0
	ora   #$03
	sta   -120,u
	leau  -280,u

	lda   120,u
	anda  #$f0
	ora   #$04
	sta   120,u
	lda   80,u
	anda  #$f0
	ora   #$04
	sta   80,u
	lda   40,u
	anda  #$f0
	ora   #$04
	sta   40,u
	lda   ,u
	anda  #$f0
	ora   #$04
	sta   ,u
	lda   -40,u
	anda  #$f0
	ora   #$04
	sta   -40,u
	lda   -80,u
	anda  #$f0
	ora   #$05
	sta   -80,u
	lda   -120,u
	anda  #$f0
	ora   #$05
	sta   -120,u
        rts

draw_img_ring_4

	leau  199,u

	lda   121,u
	anda  #$0f
	ora   #$30
	sta   121,u
	lda   1,u
	anda  #$f0
	ora   #$04
	sta   1,u
	lda   -120,u
	anda  #$f0
	ora   #$0f
	sta   -120,u
	lda   #$45
	sta   41,u
	lda   #$53
	sta   81,u
	ldd   -40,u
	anda  #$f0
	andb  #$f0
	addd  #$0304
	std   -40,u
	ldd   -80,u
	anda  #$f0
	andb  #$f0
	addd  #$0403
	std   -80,u
	leau  -280,u

	lda   120,u
	anda  #$f0
	ora   #$0f
	sta   120,u
	lda   80,u
	anda  #$f0
	ora   #$0f
	sta   80,u
	lda   40,u
	anda  #$f0
	ora   #$0f
	sta   40,u
	lda   -79,u
	anda  #$f0
	ora   #$05
	sta   -79,u
	lda   #$35
	sta   -119,u
	ldd   ,u
	anda  #$f0
	andb  #$f0
	addd  #$0503
	std   ,u
	ldd   -40,u
	anda  #$f0
	andb  #$f0
	addd  #$0503
	std   -40,u
	leau  -179,u

	lda   #$54
	sta   20,u
	lda   -20,u
	anda  #$0f
	ora   #$40
	sta   -20,u

	ldu    <glb_screen_location_1
	leau  199,u

	lda   120,u
	anda  #$f0
	ora   #$03
	sta   120,u
	lda   #$54
	sta   40,u
	lda   #$35
	sta   80,u
	ldd   ,u
	lda   #$53
	andb  #$0f
	orb   #$30
	std   ,u
	ldd   -40,u
	anda  #$0f
	andb  #$0f
	addd  #$5030
	std   -40,u
	ldd   -80,u
	anda  #$0f
	andb  #$0f
	addd  #$5050
	std   -80,u
	ldd   -120,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   -120,u
	leau  -280,u

	ldd   -80,u
	lda   #$53
	andb  #$0f
	orb   #$40
	std   -80,u
	ldd   120,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   120,u
	ldd   80,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   80,u
	ldd   40,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   40,u
	ldd   ,u
	anda  #$0f
	andb  #$0f
	addd  #$4050
	std   ,u
	ldd   -40,u
	anda  #$0f
	andb  #$0f
	addd  #$5050
	std   -40,u
	lda   #$f4
	sta   -120,u
	leau  -180,u

	lda   #$55
	sta   20,u
	lda   -20,u
	anda  #$f0
	ora   #$05
	sta   -20,u
        rts

draw_img_ring_sparkle_1

	leau  79,u

	lda   120,u
	anda  #$f0
	ora   #$04
	sta   120,u
	lda   -120,u
	anda  #$f0
	ora   #$03
	sta   -120,u
	leau  -199,u

	lda   -1,u
	anda  #$f0
	ora   #$03
	sta   -1,u
	lda   -40,u
	anda  #$f0
	ora   #$04
	sta   -40,u
	ldd   39,u
	lda   #$35
	andb  #$0f
	orb   #$30
	std   39,u

	ldu    <glb_screen_location_1
	ldd   -41,u
	lda   #$f3
	andb  #$0f
	orb   #$30
	std   -41,u
	ldd   -81,u
	lda   #$f5
	andb  #$0f
	orb   #$40
	std   -81,u
	ldd   -121,u
	lda   #$f3
	andb  #$0f
	orb   #$50
	std   -121,u
	lda   79,u
	anda  #$0f
	ora   #$40
	sta   79,u
	lda   39,u
	anda  #$0f
	ora   #$50
	sta   39,u
	lda   -1,u
	anda  #$0f
	ora   #$f0
	sta   -1,u
	ldd   119,u
	anda  #$0f
	andb  #$0f
	addd  #$3030
	std   119,u
	leau  -220,u

	ldd   19,u
	anda  #$0f
	andb  #$0f
	addd  #$5050
	std   19,u
	ldd   -21,u
	anda  #$0f
	andb  #$0f
	addd  #$4040
	std   -21,u
	ldd   -61,u
	anda  #$0f
	andb  #$0f
	addd  #$3030
	std   -61,u
	ldd   59,u
	anda  #$0f
	ora   #$f0
	ldb   #$f4
	std   59,u
        rts

draw_img_ring_sparkle_2

	leau  179,u

	lda   #$35
	sta   20,u
	lda   60,u
	anda  #$f0
	ora   #$03
	sta   60,u
	lda   -20,u
	anda  #$f0
	ora   #$03
	sta   -20,u
	lda   -59,u
	anda  #$f0
	ora   #$04
	sta   -59,u

	ldu    <glb_screen_location_1
	leau  79,u

	lda   81,u
	anda  #$0f
	ora   #$40
	sta   81,u
	lda   1,u
	anda  #$0f
	ora   #$40
	sta   1,u
	lda   -39,u
	anda  #$0f
	ora   #$30
	sta   -39,u
	lda   -80,u
	anda  #$0f
	ora   #$30
	sta   -80,u
	lda   -120,u
	anda  #$0f
	ora   #$40
	sta   -120,u
	ldd   120,u
	anda  #$0f
	andb  #$0f
	addd  #$3030
	std   120,u
	lda   #$f4
	sta   41,u
	leau  -220,u

	ldd   20,u
	anda  #$0f
	andb  #$0f
	addd  #$4040
	std   20,u
	ldd   -20,u
	anda  #$0f
	andb  #$0f
	addd  #$3050
	std   -20,u
	lda   60,u
	anda  #$0f
	ora   #$50
	sta   60,u
	lda   -59,u
	anda  #$0f
	ora   #$40
	sta   -59,u
        rts

draw_img_ring_sparkle_3

	leau  139,u

	lda   61,u
	anda  #$f0
	ora   #$04
	sta   61,u
	lda   20,u
	anda  #$f0
	ora   #$03
	sta   20,u
	lda   -60,u
	anda  #$f0
	ora   #$03
	sta   -60,u
	ldd   -20,u
	lda   #$35
	andb  #$0f
	orb   #$30
	std   -20,u
	leau  -300,u

	lda   ,u
	anda  #$f0
	ora   #$04
	sta   ,u

	ldu    <glb_screen_location_1
	leau  200,u

	ldd   -1,u
	anda  #$0f
	ora   #$f0
	ldb   #$f4
	std   -1,u
	ldd   119,u
	anda  #$0f
	andb  #$0f
	addd  #$3030
	std   119,u
	ldd   79,u
	anda  #$0f
	andb  #$0f
	addd  #$4040
	std   79,u
	ldd   39,u
	anda  #$0f
	andb  #$0f
	addd  #$5050
	std   39,u
	ldd   -41,u
	lda   #$f3
	andb  #$0f
	orb   #$50
	std   -41,u
	ldd   -81,u
	lda   #$f5
	andb  #$0f
	orb   #$40
	std   -81,u
	ldd   -121,u
	lda   #$f3
	andb  #$0f
	orb   #$30
	std   -121,u
	leau  -200,u

	lda   39,u
	anda  #$0f
	ora   #$f0
	sta   39,u
	lda   -1,u
	anda  #$0f
	ora   #$50
	sta   -1,u
	lda   -41,u
	anda  #$0f
	ora   #$40
	sta   -41,u
	ldd   -81,u
	anda  #$0f
	andb  #$0f
	addd  #$3030
	std   -81,u
        rts

draw_img_ring_sparkle_4

	leau  -141,u

	lda   #$35
	sta   -20,u
	lda   61,u
	anda  #$f0
	ora   #$04
	sta   61,u
	lda   20,u
	anda  #$f0
	ora   #$03
	sta   20,u
	lda   -60,u
	anda  #$f0
	ora   #$03
	sta   -60,u

	ldu    <glb_screen_location_1
	leau  120,u

	ldd   79,u
	anda  #$0f
	andb  #$0f
	addd  #$3050
	std   79,u
	ldd   39,u
	anda  #$0f
	andb  #$0f
	addd  #$4040
	std   39,u
	lda   120,u
	anda  #$0f
	ora   #$40
	sta   120,u
	lda   -1,u
	anda  #$0f
	ora   #$50
	sta   -1,u
	lda   -41,u
	anda  #$0f
	ora   #$40
	sta   -41,u
	lda   -81,u
	anda  #$0f
	ora   #$30
	sta   -81,u
	lda   -120,u
	anda  #$0f
	ora   #$30
	sta   -120,u
	leau  -220,u

	ldd   -61,u
	anda  #$0f
	andb  #$0f
	addd  #$3030
	std   -61,u
	lda   #$f4
	sta   20,u
	lda   60,u
	anda  #$0f
	ora   #$40
	sta   60,u
	lda   -20,u
	anda  #$0f
	ora   #$40
	sta   -20,u
        rts

