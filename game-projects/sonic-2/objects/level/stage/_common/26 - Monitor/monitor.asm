        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256

Obj26_child        equ ext_variables_obj
                                                      * ; ===========================================================================
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; Object 26 - Monitor
                                                      * ;
                                                      * ; The power-ups themselves are handled by the next object. This just does the
                                                      * ; monitor collision and graphics.
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; Obj_Monitor:
Obj26                                                 * Obj26:
                                                      *         moveq   #0,d0
        lda   routine,u                               *         move.b  routine(a0),d0
        asla
        ldx   #Obj26_Index                            *         move.w  Obj26_Index(pc,d0.w),d1
        jmp   [a,x]                                   *         jmp     Obj26_Index(pc,d1.w)
                                                      * ; ===========================================================================
                                                      * ; obj_26_subtbl:
Obj26_Index                                           * Obj26_Index:    offsetTable
        fdb   Obj26_Init                              *                 offsetTableEntry.w Obj26_Init                   ; 0
        fdb   Obj26_Main                              *                 offsetTableEntry.w Obj26_Main                   ; 2
        fdb   Obj26_Break                             *                 offsetTableEntry.w Obj26_Break                  ; 4
        fdb   Obj26_Animate                           *                 offsetTableEntry.w Obj26_Animate                ; 6
        fdb   BranchTo2_MarkObjGone                   *                 offsetTableEntry.w BranchTo2_MarkObjGone        ; 8
                                                      * ; ===========================================================================
                                                      * ; obj_26_sub_0: Obj_26_Init:
Obj26_Init                                            * Obj26_Init:
        inc   routine,u                               *         addq.b  #2,routine(a0)
        ldd   #$0E07 ; wide-dot factor                *         move.b  #$E,y_radius(a0)
        std   y_radius,u ; and x_radius,u             *         move.b  #$E,x_radius(a0)
        ;                                             *         move.l  #Obj26_MapUnc_12D36,mappings(a0)
        ;                                             *         move.w  #make_art_tile(ArtTile_ArtNem_Powerups,0,0),art_tile(a0)
        ;                                             *         bsr.w   Adjust2PArtPointer
        _ldd  render_playfieldcoord_mask,3
        sta   render_flags,u                          *         move.b  #4,render_flags(a0)
        stb   priority,u                              *         move.b  #3,priority(a0)
        lda   #$0F/2
        sta   width_pixels,u ; wide-dot factor        *         move.b  #$F,width_pixels(a0)
                                                      * 
        ldx   #Object_Respawn_Table                   *         lea     (Object_Respawn_Table).w,a2
                                                      *         moveq   #0,d0
        ldb   respawn_index,u                         *         move.b  respawn_index(a0),d0
        addb  #2
        lda   b,x
        anda  #%01111111
        sta   b,x                                     *         bclr    #7,2(a2,d0.w)
        anda  #1                                      *         btst    #0,2(a2,d0.w)   ; if this bit is set it means the monitor is already broken
        beq   >                                       *         beq.s   +
        lda   #4                                      *         move.b  #8,routine(a0)  ; set monitor to 'broken' state
        sta   routine,u
        ldd   #Img_monitor_broken
        std   image_set,u                             *         move.b  #$B,mapping_frame(a0)
        rts                                           *         rts
                                                      * ; ---------------------------------------------------------------------------
!                                                     * +
        ldd   #Img_monitor
        std   image_set,u
        ; to save some memory, child is allocated before monitor break
        ; to show monitor's image independently or monitor sprite
        jsr   LoadObject_x
        beq   >
        stx   Obj26_child,u
        lda   #ObjID_MonitorContent
        sta   id,x
        lda   subtype,u
        sta   subtype,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        subd  #2
        std   y_pos,x
        stu   parent,x
!
        ; todo                                        *         move.b  #$46,collision_flags(a0)
                                                      *         move.b  subtype(a0),anim(a0)    ; subtype = icon to display
        ;                                             *         tst.w   (Two_player_mode).w     ; is it two player mode?
        ;                                             *         beq.s   Obj26_Main              ; if not, branch
        ;                                             *         move.b  #9,anim(a0)             ; use '?' icon
                                                      * ;obj_26_sub_2:
Obj26_Main                                            * Obj26_Main:
                                                      *         move.b  routine_secondary(a0),d0
                                                      *         beq.s   SolidObject_Monitor
                                                      *         ; only when secondary routine isn't 0
                                                      *         ; make monitor fall
                                                      *         bsr.w   ObjectMoveAndFall
                                                      *         jsr     (ObjCheckFloorDist).l
                                                      *         tst.w   d1                      ; is monitor in the ground?
                                                      *         bpl.w   SolidObject_Monitor     ; if not, branch
                                                      *         add.w   d1,y_pos(a0)            ; move monitor out of the ground
                                                      *         clr.w   y_vel(a0)
                                                      *         clr.b   routine_secondary(a0)   ; stop monitor from falling
                                                      * ; loc_1271C:
                                                      * SolidObject_Monitor:
                                                      *         move.w  #$1A,d1 ; monitor's width
                                                      *         move.w  #$F,d2
                                                      *         move.w  d2,d3
                                                      *         addq.w  #1,d3
                                                      *         move.w  x_pos(a0),d4
                                                      *         lea     (MainCharacter).w,a1 ; a1=character
                                                      *         moveq   #p1_standing_bit,d6
                                                      *         movem.l d1-d4,-(sp)
                                                      *         bsr.w   SolidObject_Monitor_Sonic
                                                      *         movem.l (sp)+,d1-d4
                                                      *         lea     (Sidekick).w,a1 ; a1=character
                                                      *         moveq   #p2_standing_bit,d6
                                                      *         bsr.w   SolidObject_Monitor_Tails
                                                      * 
Obj26_Animate                                         * Obj26_Animate:
        ;                                             *         lea     (Ani_obj26).l,a1
        ; animation is given to child obj             *         bsr.w   AnimateSprite
        jsr   DisplaySprite
                                                      * 
BranchTo2_MarkObjGone                                 * BranchTo2_MarkObjGone
        ldd   x_pos,u
        andb  #$C0 ; wide-dot factor 
        subd  glb_camera_x_pos_coarse
        cmpd  #$40+160+$20+$40  ; wide-dot factor
        bhi   >
        rts
!       ldx   Obj26_child,u
        beq   >
        jsr   DeleteObject2
!       jmp   MarkObjGone                             *         bra.w   MarkObjGone
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * ; sub_12756:
                                                      * SolidObject_Monitor_Sonic:
                                                      *         btst    d6,status(a0)                   ; is Sonic standing on the monitor?
                                                      *         bne.s   Obj26_ChkOverEdge               ; if yes, branch
                                                      *         cmpi.b  #AniIDSonAni_Roll,anim(a1)              ; is Sonic spinning?
                                                      *         bne.w   SolidObject_cont                ; if not, branch
                                                      *         rts
                                                      * ; End of function SolidObject_Monitor_Sonic
                                                      * 
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * ; sub_12768:
                                                      * SolidObject_Monitor_Tails:
                                                      *         btst    d6,status(a0)                   ; is Tails standing on the monitor?
                                                      *         bne.s   Obj26_ChkOverEdge               ; if yes, branch
                                                      *         tst.w   (Two_player_mode).w             ; is it two player mode?
                                                      *         beq.w   SolidObject_cont                ; if not, branch
                                                      *         ; in one player mode monitors always behave as solid for Tails
                                                      *         cmpi.b  #AniIDTailsAni_Roll,anim(a1)    ; is Tails spinning?
                                                      *         bne.w   SolidObject_cont                ; if not, branch
                                                      *         rts
                                                      * ; End of function SolidObject_Monitor_Tails
                                                      * 
                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Checks if the player has walked over the edge of the monitor.
                                                      * ; ---------------------------------------------------------------------------
                                                      * ;loc_12782:
                                                      * Obj26_ChkOverEdge:
                                                      *         move.w  d1,d2
                                                      *         add.w   d2,d2
                                                      *         btst    #1,status(a1)   ; is the character in the air?
                                                      *         bne.s   +               ; if yes, branch
                                                      *         ; check, if character is standing on
                                                      *         move.w  x_pos(a1),d0
                                                      *         sub.w   x_pos(a0),d0
                                                      *         add.w   d1,d0
                                                      *         bmi.s   +       ; branch, if character is behind the left edge of the monitor
                                                      *         cmp.w   d2,d0
                                                      *         blo.s   Obj26_CharStandOn       ; branch, if character is not beyond the right edge of the monitor
                                                      * +
                                                      *         ; if the character isn't standing on the monitor
                                                      *         bclr    #3,status(a1)   ; clear 'on object' bit
                                                      *         bset    #1,status(a1)   ; set 'in air' bit
                                                      *         bclr    d6,status(a0)   ; clear 'standing on' bit for the current character
                                                      *         moveq   #0,d4
                                                      *         rts
                                                      * ; ---------------------------------------------------------------------------
                                                      * ;loc_127B2:
                                                      * Obj26_CharStandOn:
                                                      *         move.w  d4,d2
                                                      *         bsr.w   MvSonicOnPtfm
                                                      *         moveq   #0,d4
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ;obj_26_sub_4:
Obj26_Break                                           * Obj26_Break:
                                                      *         move.b  status(a0),d0
                                                      *         andi.b  #standing_mask|pushing_mask,d0  ; is someone touching the monitor?
                                                      *         beq.s   Obj26_SpawnIcon ; if not, branch
                                                      *         move.b  d0,d1
                                                      *         andi.b  #p1_standing|p1_pushing,d1      ; is it the main character?
                                                      *         beq.s   +               ; if not, branch
                                                      *         andi.b  #$D7,(MainCharacter+status).w
                                                      *         ori.b   #2,(MainCharacter+status).w     ; prevent Sonic from walking in the air
                                                      * +
                                                      *         andi.b  #p2_standing|p2_pushing,d0      ; is it the sidekick?
                                                      *         beq.s   Obj26_SpawnIcon ; if not, branch
                                                      *         andi.b  #$D7,(Sidekick+status).w
                                                      *         ori.b   #2,(Sidekick+status).w  ; prevent Tails from walking in the air
                                                      * ;loc_127EC:
                                                      * Obj26_SpawnIcon:
                                                      *         clr.b   status(a0)
                                                      *         addq.b  #2,routine(a0)
                                                      *         move.b  #0,collision_flags(a0)
 ; obj is already allocated,
 ; instead inc routine of child to run                *         bsr.w   SingleObjLoad
 ;                                                    *         bne.s   Obj26_SpawnSmoke
 ; already done                                       *         _move.b #ObjID_MonitorContents,id(a1) ; load obj2E
 ;                                                    *         move.w  x_pos(a0),x_pos(a1)     ; set icon's position
 ;                                                    *         move.w  y_pos(a0),y_pos(a1)
 ;                                                    *         move.b  anim(a0),anim(a1)
 ;                                                    *         move.w  parent(a0),parent(a1)   ; parent gets the item
                                                      * ;loc_1281E:
                                                      * Obj26_SpawnSmoke:
                                                      *         bsr.w   SingleObjLoad
                                                      *         bne.s   +
                                                      *         _move.b #ObjID_Explosion,id(a1) ; load obj27
                                                      *         addq.b  #2,routine(a1)
                                                      *         move.w  x_pos(a0),x_pos(a1)
                                                      *         move.w  y_pos(a0),y_pos(a1)
                                                      * +
                                                      *         lea     (Object_Respawn_Table).w,a2
                                                      *         moveq   #0,d0
                                                      *         move.b  respawn_index(a0),d0
                                                      *         bset    #0,2(a2,d0.w)   ; mark monitor as destroyed
                                                      *         move.b  #$A,anim(a0)
        jmp   DisplaySprite                           *         bra.w   DisplaySprite