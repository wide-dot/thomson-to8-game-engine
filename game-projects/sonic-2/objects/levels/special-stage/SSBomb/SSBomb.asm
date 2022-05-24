; ---------------------------------------------------------------------------
; Object - Bombs and Rings from Special Stage
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./objects/levels/special-stage/SSBomb/Constants.asm"

SSObject
        clr   is_out_of_screen
        lda   subtype,u
        asla           
        ldx   #SSObject_Routines
        jmp   [a,x]

SSObject_Routines
        fdb   SSBomb
        fdb   SSRing

                                                                          *; ===========================================================================
                                                                          *; ----------------------------------------------------------------------------
                                                                          *; Object 61 - Bombs from Special Stage
                                                                          *; ----------------------------------------------------------------------------
                                                                          *; Sprite_34EB0:
SSBomb                                                                    *Obj61:
        lda   routine,u                                                   *    moveq   #0,d0
        asla                                                              *    move.b  routine(a0),d0
        ldx   #SSB_Routines                                               *    move.w  Obj61_Index(pc,d0.w),d1
        jmp   [a,x]                                                       *    jmp Obj61_Index(pc,d1.w)
                                                                          *; ===========================================================================
                                                                          *; off_34EBE:
SSB_Routines                                                              *Obj61_Index:    offsetTable
        fdb   SSB_Init                                                    *        offsetTableEntry.w Obj61_Init   ; 0
        fdb   SSB_Bomb                                                    *        offsetTableEntry.w loc_34F06    ; 2
        fdb   SSB_Shadow                                                  *        offsetTableEntry.w loc_3533A    ; 4
        fdb   SSB_Explode                                                 *        offsetTableEntry.w loc_34F6A    ; 6
                                                                          *; ===========================================================================
																		  
                                                                          *; loc_34EC6:
SSB_Init                                                                  *Obj61_Init:
        inc   routine,u                                                   *        addq.b  #2,routine(a0)
        ldd   #$0000                                                      *        move.w  #$7F,x_pos(a0)
        std   xy_pixel,u                                                  *        move.w  #$58,y_pos(a0)
                                                                          *        move.l  #Obj61_MapUnc_36508,mappings(a0)
                                                                          *        move.w  #make_art_tile(ArtTile_ArtNem_SpecialBomb,1,0),art_tile(a0)
        ; coordinate system                                               *        move.b  #4,render_flags(a0)
        ldd   #$0402                                                      
        sta   priority,u                                                  *        move.b  #3,priority(a0)
        stb   collision_flags,u                                           *        move.b  #2,collision_flags(a0)
                                                                          *        move.b  #-1,(SS_unk_DB4D).w
        tst   angle,u                                                     *        tst.b   angle(a0)
        bmi   SSB_Bomb                                                    *        bmi.s   loc_34F06
        jsr   SSB_InitShadow                                              *        bsr.w   loc_3529C
                                                                          *
SSB_Bomb                                                                  *loc_34F06:

        ; TODO optim
        ; keep a variable with max zz_pos for visible obj on the curr img
        ; test it here instead of SSB_ComputeCoordinates
        ; simplify SSB_ComputeCoordinates (remove the test)
        ; decrease zz_pos here and return
        ; same when zz_pos=0 this case should be processed here 
        ; otherwise call the following code

        jsr   SSB_ScaleAnim                                               *        bsr.w   loc_3512A
        jsr   SSB_ComputeCoordinates                                      *        bsr.w   loc_351A0
                                                                          *        lea     (Ani_obj61).l,a1
        jsr   AnimateSprite                                               *        bsr.w   loc_3539E
        jsr   GetImgIdA
        sta   mapping_frame,u        
        tst   is_out_of_screen
        bne   SSB_Init_hide_and_return
        ; tst   rsv_render_flags,u                                        *        tst.b   render_flags(a0)
        ; bpl   SSB_Init_return        ; not on screen last frame         *        bpl.s   return_34F26
        ; jsr   SSB_CheckCollision     ; so no collision test             *        bsr.w   loc_34F28
        jmp   DisplaySprite                                               *        bra.w   JmpTo44_DisplaySprite
                                                                          *
SSB_Init_hide_and_return
        lda   render_flags,u
        ora   #render_hide_mask        ; set hide flag
        sta   render_flags,u
SSB_Init_return                                                           *return_34F26:
        rts                                                               *        rts
		
                                                                          *; ===========================================================================
                                                                          *

SSB_CheckCollision                                                        *loc_34F28:
        ; collision width, now hardcoded in collision routine             *        move.w  #8,d6
        jsr   CheckCollision                                              *        bsr.w   loc_350A0
        bcc   return_34F68                                                *        bcc.s   return_34F68
        lda   #1
        sta   collision_property,x                                        *        move.b  #1,collision_property(a1)
                                                                          *        move.w  #SndID_SlowSmash,d0
                                                                          *        jsr     (PlaySoundStereo).l
        ldd   #$0300                                                          
        sta   routine,u                ; explode                          *        move.b  #6,routine(a0)
        stb   anim_frame,u                                                *        move.b  #0,anim_frame(a0)
        stb   anim_frame_duration,u                                       *        move.b  #0,anim_frame_duration(a0)
        ldx   ss_parent,u                                                 *        move.l  objoff_34(a0),d0
        beq   return_34F68             ; no shadow for this Bomb          *        beq.s   return_34F68
        ldd   #0
        std   ss_parent,u                                                 *        move.l  #0,objoff_34(a0)
                                                                          *        movea.l d0,a1 ; a1=object
        tst   id,x
        beq   return_34F68                                                                          
        com   ss_self_delete,x         ; tell shadow to self delete       *        st      objoff_2A(a1)
                                                                          *
return_34F68                                                              *return_34F68:
        rts                                                               *        rts

                                                                          *; ===========================================================================
                                                                          *

SSB_Explode                                                               *loc_34F6A:
        ldd   #Ani_SSBomb_explode                                         *        move.b  #$A,anim(a0)
        std   anim,u                                                      
                                                                          *        move.w  #make_art_tile(ArtTile_ArtNem_SpecialExplosion,2,0),art_tile(a0)
        jsr   SSB_CheckIfForeground                                       *        bsr.w   loc_34F90
        jsr   SSB_ScaleAnim                                               *        bsr.w   loc_3512A
        jsr   SSB_ComputeCoordinates                                      *        bsr.w   loc_351A0
                                                                          *        lea     (Ani_obj61).l,a1
        jsr   AnimateSprite                                               *        jsrto   (AnimateSprite).l, JmpTo24_AnimateSprite
        jsr   GetImgIdA
        sta   mapping_frame,u
        tst   is_out_of_screen
        bne   SSB_Explode_hide_and_return                
        jmp   DisplaySprite                                               *        bra.w   JmpTo44_DisplaySprite
SSB_Explode_hide_and_return
        lda   render_flags,u
        ora   #render_hide_mask        ; set hide flag
        sta   render_flags,u
        rts  
		
                                                                          *; ===========================================================================

SSB_CheckIfForeground                                                     *loc_34F90:
        ldd   ss_z_pos,u                                                  
        cmpd  #4                                                          *        cmpi.w  #4,objoff_30(a0)
        bhs   @a                                                          *        bhs.s   return_34F9E
        lda   #2                                                          
        sta   priority,u                                                  *        move.b  #1,priority(a0)
                                                                          *
@a                                                                        *return_34F9E:
        rts                                                               *        rts

                                                                          *; ===========================================================================
                                                                          *; ----------------------------------------------------------------------------
                                                                          *; Object 60 - Rings from Special Stage
                                                                          *; ----------------------------------------------------------------------------
                                                                          *; Sprite_34FA0:
SSRing                                                                    *Obj60:
        lda   routine,u                                                   *    moveq   #0,d0
        asla                                                              *    move.b  routine(a0),d0
        ldx   #SSR_Routines                                               *    move.w  Obj60_Index(pc,d0.w),d1
        jmp   [a,x]                                                       *    jmp Obj60_Index(pc,d1.w)
                                                                          *; ===========================================================================
                                                                          *; off_34FAE:
SSR_Routines                                                              *Obj60_Index:    offsetTable
        fdb   SSR_Init                                                    *        offsetTableEntry.w Obj60_Init   ; 0
        fdb   SSR_Ring                                                    *        offsetTableEntry.w loc_34FF0    ; 1
        fdb   SSB_Shadow                                                  *        offsetTableEntry.w loc_3533A    ; 2
        fdb   SSR_Stars                                                   *        offsetTableEntry.w loc_35010    ; 3
                                                                          *; ===========================================================================
																		  
                                                                          *; loc_34FB6:
SSR_Init                                                                  *Obj60_Init:
        inc   routine,u                                                   *    addq.b  #2,routine(a0)
        ldd   #$0000                                                      *    move.w  #$7F,x_pos(a0)
        std   xy_pixel,u                                                  *    move.w  #$58,y_pos(a0)
                                                                          *    move.l  #Obj5A_Obj5B_Obj60_MapUnc_3632A,mappings(a0)
                                                                          *    move.w  #make_art_tile(ArtTile_ArtNem_SpecialRings,3,0),art_tile(a0)
                                                                          *    move.b  #4,render_flags(a0)
        ldd   #$0401
        sta   priority,u                                                  *    move.b  #3,priority(a0)
        stb   collision_flags,u                                           *    move.b  #1,collision_flags(a0)
		
        lda   anim_flags,u
        ora   #anim_link_mask
        sta   anim_flags,u
		
        tst   angle,u                                                     *    tst.b   angle(a0)
        bmi   SSR_Ring                                                    *    bmi.s   loc_34FF0
        jsr   SSB_InitShadow                                              *    bsr.w   loc_3529C
                                                                          *
SSR_Ring                                                                  *loc_34FF0:

        ; TODO optim
        ; keep a variable with max zz_pos for visible obj on the curr img
        ; test it here instead of SSB_ComputeCoordinates
        ; simplify SSB_ComputeCoordinates (remove the test)
        ; decrease zz_pos here and return
        ; same when zz_pos=0 this case should be processed here 
        ; otherwise call the following code

        jsr   SSR_ScaleAnim                                               *    bsr.w   loc_3512A
        jsr   SSB_ComputeCoordinates                                      *    bsr.w   loc_351A0
        jsr   SSR_RingCounter                                             *    bsr.w   loc_35036
                                                                          *    lea (Ani_obj5B_obj60).l,a1
        jsr   AnimateSprite                                               *    bsr.w   loc_3539E
        jsr   GetImgIdA
        sta   mapping_frame,u        
        tst   is_out_of_screen
        bne   SSR_Init_hide_and_return		
                                                                          *    tst.b   render_flags(a0)
        jmp   DisplaySprite                                               *    bmi.w   JmpTo44_DisplaySprite
           
SSR_Init_hide_and_return
        lda   render_flags,u
        ora   #render_hide_mask        ; set hide flag
        sta   render_flags,u
SSR_Init_return
        rts                                                               *    rts
																		  
                                                                          *; ===========================================================================
                                                                          *
																		  
SSR_Stars                                                                 *loc_35010:
        ldd   #Ani_SSRing_stars                                           *    move.b  #$A,anim(a0)
        std   anim,u
                                                                          *    move.w  #make_art_tile(ArtTile_ArtNem_SpecialStars,2,0),art_tile(a0)
        jsr   SSB_CheckIfForeground                                       *    bsr.w   loc_34F90
        jsr   SSB_ScaleAnim                                               *    bsr.w   loc_3512A
        jsr   SSB_ComputeCoordinates                                      *    bsr.w   loc_351A0
                                                                          *    lea (Ani_obj5B_obj60).l,a1
        jsr   AnimateSprite                                               *    jsrto   (AnimateSprite).l, JmpTo24_AnimateSprite
        jsr   GetImgIdA
        sta   mapping_frame,u
        tst   is_out_of_screen
        bne   SSR_Stars_hide_and_return		
        jmp   DisplaySprite                                               *    bra.w   JmpTo44_DisplaySprite
SSR_Stars_hide_and_return
        lda   render_flags,u
        ora   #render_hide_mask        ; set hide flag
        sta   render_flags,u
        rts 
																		  
                                                                          *; ===========================================================================
                                                                          *
SSR_RingCounter                                                           *loc_35036:
                                                                          *    move.w  #$A,d6
                                                                          *    bsr.w   loc_350A0
                                                                          *    bcc.s   return_3509E
                                                                          *    cmpa.l  #MainCharacter,a1
                                                                          *    bne.s   loc_3504E
                                                                          *    addq.w  #1,(Ring_count).w
                                                                          *    bra.s   loc_35052
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_3504E:
                                                                          *    addq.w  #1,(Ring_count_2P).w
                                                                          *
                                                                          *loc_35052:
                                                                          *    addq.b  #1,ss_rings_units(a1)
                                                                          *    cmpi.b  #$A,ss_rings_units(a1)
                                                                          *    blt.s   loc_3507A
                                                                          *    addq.b  #1,ss_rings_tens(a1)
                                                                          *    move.b  #0,ss_rings_units(a1)
                                                                          *    cmpi.b  #$A,ss_rings_tens(a1)
                                                                          *    blt.s   loc_3507A
                                                                          *    addq.b  #1,ss_rings_hundreds(a1)
                                                                          *    move.b  #0,ss_rings_tens(a1)
                                                                          *
                                                                          *loc_3507A:
                                                                          *    move.b  #6,routine(a0)
                                                                          *    move.l  objoff_34(a0),d0
                                                                          *    beq.s   loc_35094
                                                                          *    move.l  #0,objoff_34(a0)
                                                                          *    movea.l d0,a1 ; a1=object
                                                                          *    st  objoff_2A(a1)
                                                                          *
                                                                          *loc_35094:
                                                                          *    move.w  #SndID_Ring,d0
                                                                          *    jsr (PlaySoundStereo).l
                                                                          *
                                                                          *return_3509E:
        rts                                                               *    rts
                                                                          *; ===========================================================================

CheckCollision                                                            *loc_350A0:
        ldd   anim,u                                                      
        cmpd  #Ani_SSBomb_8                                               *    cmpi.b  #8,anim(a0)
        bne   @a                                                          *    bne.s   loc_350DC
        tst   collision_flags,u                                           *    tst.b   collision_flags(a0)
        beq   @a                                                          *    beq.s   loc_350DC
        ldx   #MainCharacter                                              *    lea (MainCharacter).w,a2 ; a2=object (special stage sonic)
                                                                          *    lea (Sidekick).w,a3 ; a3=object (special stage tails)
                                                                          *    move.w  objoff_34(a2),d0
                                                                          *    cmp.w   objoff_34(a3),d0
                                                                          *    blo.s   loc_350CE
                                                                          *    movea.l a3,a1
                                                                          *    bsr.w   loc_350E2
                                                                          *    bcs.s   return_350E0
                                                                          *    movea.l a2,a1
        bra   @b                                                          *    bra.w   loc_350E2
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_350CE:
                                                                          *    movea.l a2,a1
                                                                          *    bsr.w   loc_350E2
                                                                          *    bcs.s   return_350E0
                                                                          *    movea.l a3,a1
                                                                          *    bra.w   loc_350E2
                                                                          *; ===========================================================================
                                                                          *
@a                                                                        *loc_350DC:
        andcc #$FE                                                        *    move    #0,ccr
                                                                          *
@c                                                                        *return_350E0:
        rts                                                               *    rts
                                                                          *; ===========================================================================
@b                                                                        *loc_350E2:
                                                                          *    tst.b   id(a1)
                                                                          *    beq.s   loc_3511A
        lda   routine,x
        cmpa  #$1                      ; sonic is in MdNormal             *    cmpi.b  #2,routine(a1)
        bne   @d                                                          *    bne.s   loc_3511A
        tst   routine_secondary,x                                         *    tst.b   routine_secondary(a1)
        bne   @d                       ; branch if sonic in hurt state    *    bne.s   loc_3511A
                                                                          *    move.b  angle(a1),d0
        lda   angle,u                  ; bomb angle                       *    move.b  angle(a0),d1
        ldb   angle,u                                                                          
                                                                          *    move.b  d1,d2
        adda  #8                                                          *    add.b   d6,d1
        bcs   @e                                                          *    bcs.s   loc_35110
        subb  #8                                                          *    sub.b   d6,d2
        bcs   @f                                                          *    bcs.s   loc_35112
        cmpa  angle,x                                                     *    cmp.b   d1,d0
        blo   @d                                                          *    bhs.s   loc_3511A
        cmpb  angle,x                                                     *    cmp.b   d2,d0
        blo   @g                                                          *    bhs.s   loc_35120
        bra   @d                                                          *    bra.s   loc_3511A
                                                                          *; ===========================================================================
                                                                          *
@e                                                                        *loc_35110:
        subb  #8                                                          *    sub.b   d6,d2
                                                                          *
@f                                                                        *loc_35112:
        cmpa  angle,x                                                     *    cmp.b   d1,d0
        bhs   @g                                                          *    blo.s   loc_35120
        cmpb  angle,x                                                     *    cmp.b   d2,d0
        bhs   @g                                                          *    bhs.s   loc_35120
                                                                          *
@d                                                                        *loc_3511A:
        andcc #$FE                                                        *    move    #0,ccr
        rts                                                               *    rts
                                                                          *; ===========================================================================
                                                                          *
@g                                                                        *loc_35120:
        clr   collision_flags,u                                           *    clr.b   collision_flags(a0)
        orcc  #$01                                                        *    move    #1,ccr
        rts                                                               *    rts

                                                                          *; ===========================================================================
                                                                          *
SSB_ScaleAnim                                                             *loc_3512A:
                                                                          *    btst    #7,status(a0)
                                                                          *    bne.s   loc_3516C
                                                                          *    cmpi.b  #4,(SSTrack_drawing_index).w
                                                                          *    bne.s   loc_35146
        lda   SSTrack_drawing_index
        bne   @a                  
        ldd   ss_z_pos_img_start,u
        subd  #HalfPipe_Img_z_depth
        ble   SSB_DeleteObject
        std   ss_z_pos_img_start,u
        stb   ss_z_pos+1,u
        sta   ss_z_pos+2,u                  ; ss_z_pos is always 0
        bra   @b
@a      ldd   ss_z_pos+1,u                                                                          
        subd  HalfPipe_z_step                                             *    subi.l  #$CCCC,objoff_30(a0)
        ble   SSB_DeleteObject                                            *    ble.s   loc_3516C
        std   ss_z_pos+1,u        
@b                                                                        *    bra.s   loc_35150
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_35146:
                                                                          *    subi.l  #$CCCD,objoff_30(a0)
                                                                          *    ble.s   loc_3516C
                                                                          *
																		  
                                                                          *loc_35150:
        ldx   anim,u                                                      *    cmpi.b  #$A,anim(a0)
        cmpx  #Ani_SSBomb_explode                                         
        beq   SSB_ScaleAnim_return                                        *    beq.s   return_3516A
        ldb   ss_z_pos+1,u                                                *    move.w  objoff_30(a0),d0
        cmpb  #$1D                                                        *    cmpi.w  #$1D,d0
        ble   SSB_ScaleAnim_LoadAnim                                      *    ble.s   loc_35164
        ldb   #$1E                                                        *    moveq   #$1E,d0
                                                                          *
SSB_ScaleAnim_LoadAnim                                                    *loc_35164:
        ldx   #Ani_SSBomb                                                 *    move.b  byte_35180(pc,d0.w),anim(a0)
        aslb
        ldd   b,x
        std   anim,u
                                                                          *  
SSB_ScaleAnim_return                                                      *return_3516A:
        rts                                                               *    rts
		
SSR_ScaleAnim
        lda   SSTrack_drawing_index
        bne   @a                  
        ldd   ss_z_pos_img_start,u
        subd  #HalfPipe_Img_z_depth
        ble   SSB_DeleteObject
        std   ss_z_pos_img_start,u
        stb   ss_z_pos+1,u
        sta   ss_z_pos+2,u                  ; ss_z_pos is always 0
        bra   @b
@a      ldd   ss_z_pos+1,u                                                                          
        subd  HalfPipe_z_step
        ble   SSB_DeleteObject
        std   ss_z_pos+1,u        
@b
        ldx   anim,u
        cmpx  #Ani_SSRing_stars                                         
        beq   SSR_ScaleAnim_return

        ldb   ss_z_pos+1,u
        cmpb  #$1D
        ble   SSR_ScaleAnim_LoadAnim
        ldb   #$1E

SSR_ScaleAnim_LoadAnim
        ldx   #Ani_SSRing
        aslb
        ldd   b,x
        std   anim,u
                                                                          
SSR_ScaleAnim_return
        rts    		

SSB_DeleteObject
        ldx   ss_parent,u
        beq   SSB_DeleteObject_End     ; no shadow for this Bomb
        tst   id,x
        beq   SSB_DeleteObject_End
        com   ss_self_delete,x         ; tell shadow to self delete
SSB_DeleteObject_End                     
        jmp   DeleteObject		
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_3516C:
                                                                          *    move.l  (sp)+,d0
                                                                          *    move.l  objoff_34(a0),d0
                                                                          *    beq.w   JmpTo63_DeleteObject
                                                                          *    movea.l d0,a1 ; a1=object
                                                                          *    st  objoff_2A(a1)
                                                                          *
                                                                          *    if removeJmpTos
                                                                          *JmpTo63_DeleteObject ; JmpTo
                                                                          *    endif
                                                                          *
                                                                          *    jmpto   (DeleteObject).l, JmpTo63_DeleteObject
                                                                          *; ===========================================================================
                                                                          *byte_35180:
                                                                          *    dc.b   9,  9,  9,  8,  8,  7,  7,  6,  6,  5,  5,  4,  4,  3,  3,  3
                                                                          *    dc.b   2,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0; 16
                                                                          *; ===========================================================================
Ani_SSBomb
        fdb   Ani_SSBomb_9 ; 0         ; ajdusted some values here
        fdb   Ani_SSBomb_9 ; 2         ; however in-game sprite does not
        fdb   Ani_SSBomb_9 ; 4         ; match this table, because of
        fdb   Ani_SSBomb_8 ; 6         ; animate method that forces
        fdb   Ani_SSBomb_8 ; 8         ; to end an animation before
        fdb   Ani_SSBomb_7 ; $A        ; setting the new one
        fdb   Ani_SSBomb_7 ; $C
        fdb   Ani_SSBomb_6 ; $E
        fdb   Ani_SSBomb_6 ; $10
        fdb   Ani_SSBomb_5 ; $12
        fdb   Ani_SSBomb_5 ; $14
        fdb   Ani_SSBomb_4 ; $16
        fdb   Ani_SSBomb_4 ; $18                                                
        fdb   Ani_SSBomb_3 ; $1A
        fdb   Ani_SSBomb_3 ; $1C
        fdb   Ani_SSBomb_3 ; $1E
        fdb   Ani_SSBomb_2 ; $20                               
		fdb   Ani_SSBomb_2 ; $22
        fdb   Ani_SSBomb_2 ; $24
        fdb   Ani_SSBomb_1 ; $26
        fdb   Ani_SSBomb_1 ; $28
        fdb   Ani_SSBomb_1 ; $2A
        fdb   Ani_SSBomb_1 ; $2C
        fdb   Ani_SSBomb_1 ; $2E
        fdb   Ani_SSBomb_1 ; $30
        fdb   Ani_SSBomb_1 ; $32
        fdb   Ani_SSBomb_1 ; $34
        fdb   Ani_SSBomb_1 ; $36
        fdb   Ani_SSBomb_1 ; $38
        fdb   Ani_SSBomb_1 ; $3A
        fdb   Ani_SSBomb_0 ; $3C	 	
       
        
Ani_SSRing
        fdb   Ani_SSRing_9 ; 0
        fdb   Ani_SSRing_9 ; 2
        fdb   Ani_SSRing_9 ; 4
        fdb   Ani_SSRing_8 ; 6
        fdb   Ani_SSRing_8 ; 8
        fdb   Ani_SSRing_7 ; $A
        fdb   Ani_SSRing_7 ; $C
        fdb   Ani_SSRing_6 ; $E
        fdb   Ani_SSRing_6 ; $10
        fdb   Ani_SSRing_5 ; $12
        fdb   Ani_SSRing_5 ; $14
        fdb   Ani_SSRing_4 ; $16
        fdb   Ani_SSRing_4 ; $18                                                
        fdb   Ani_SSRing_3 ; $1A
        fdb   Ani_SSRing_3 ; $1C
        fdb   Ani_SSRing_3 ; $1E
        fdb   Ani_SSRing_2 ; $20                               
		fdb   Ani_SSRing_2 ; $22
        fdb   Ani_SSRing_2 ; $24
        fdb   Ani_SSRing_1 ; $26
        fdb   Ani_SSRing_1 ; $28
        fdb   Ani_SSRing_1 ; $2A
        fdb   Ani_SSRing_1 ; $2C
        fdb   Ani_SSRing_1 ; $2E
        fdb   Ani_SSRing_1 ; $30
        fdb   Ani_SSRing_1 ; $32
        fdb   Ani_SSRing_1 ; $34
        fdb   Ani_SSRing_1 ; $36
        fdb   Ani_SSRing_1 ; $38
        fdb   Ani_SSRing_1 ; $3A
        fdb   Ani_SSRing_0 ; $3C
										
SSB_CC_OutOfScreen             
        lda   #$01
        sta   is_out_of_screen
SSB_CC_Return_1        
        rts
										
SSB_ComputeCoordinates                                                    *loc_351A0:
                                                                          *    move.w  d7,-(sp)
                                                                          *    moveq   #0,d2
                                                                          *    moveq   #0,d3
                                                                          *    moveq   #0,d4
                                                                          *    moveq   #0,d5
                                                                          *    moveq   #0,d6
                                                                          *    moveq   #0,d7
                                                                          
        ; this call was initially from loc_4F64
        ; has been moved because of SpecialPerspective data location
        
                                                                          *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                                          *;sub_5514
                                                                          *SSLoadCurrentPerspective:
                                                                          *    cmpi.b  #4,(SSTrack_drawing_index).w
                                                                          *    bne.s   +   ; rts
        ldx   #SpecialPerspective                                         *    movea.l #SSRAM_MiscKoz_SpecialPerspective,a0
                                                                          *    moveq   #0,d0
        lda   SSTrack_mapping_frame                                       *    move.b  (SSTrack_mapping_frame).w,d0
        asla                                                              *    add.w   d0,d0
        ldd   a,x                                                         *    adda.w  (a0,d0.w),a0
        leax  d,x                                                         
                                                                          *    move.l  a0,(SS_CurrentPerspective).w
                                                                          *+   rts
                                                                          *; End of function SSLoadCurrentPerspective
                                                                          *
                                                                          *                                                                          
                                                                          
                                                                          *    movea.l (SS_CurrentPerspective).w,a1
        ldd   ss_z_pos,u               ; load sprite z position           *    move.w  objoff_30(a0),d0
        beq   SSB_CC_OutOfScreen       ; if z=0 sprite is behind camera   *    beq.w   loc_35258
        cmpd  ,x++                     ; read nb of ellipses for this img *    cmp.w   (a1)+,d0
        bgt   SSB_CC_Return_1          ; sprite is too far, no ellipse    *    bgt.w   loc_35258
        subd  #1                       ; each perspective data for an img *    subq.w  #1,d0
        aslb                           ; is stored in groups of 6 bytes
        rola                           ; one group defines an ellipse     *    add.w   d0,d0
        std   d1+1                     ; for a specific distance from     *    move.w  d0,d1
        aslb                           ; camera, first group is
        rola                           ; for ss_z_pos = 1                 *    add.w   d0,d0
d1      addd  #$0000                   ; (dynamic) d = (ss_z_pos-1)*6     *    add.w   d1,d0
        leax  d,x
        tst   SSTrack_Orientation                                         *    tst.b   (SSTrack_Orientation).w
        lbne  SSB_CC_Flipped           ; branch if image is h flipped     *    bne.w   loc_35260
        ldd   4,x                                                         *    move.b  4(a1,d0.w),d6
        sta   d6+1                                                        *    move.b  5(a1,d0.w),d7
        stb   d7+1                     ; branch if angle min
        beq   SSB_CC_VisibleArea       ; of visible area is 0             *    beq.s   loc_351E8
        lda   angle,u                  ; load sprite angle                *    move.b  angle(a0),d1
d6      cmpa  #$00                     ; (dynamic) angle max (incl.)      *    cmp.b   d6,d1
        blo   SSB_CC_VisibleArea       ; of visible area                  *    blo.s   loc_351E8
d7      cmpa  #$00                     ; (dynamic) angle min (excl.)      *    cmp.b   d7,d1
        blo   SSB_CC_OutOfScreen       ; of visible area                  *    blo.s   loc_35258
                                                                          *
SSB_CC_VisibleArea                                                        *loc_351E8:
        clra
        ldb   ,x                                                          *    move.b  (a1,d0.w),d2
        std   xCenter+1
        std   sxCenter+1
                                                                          *    move.b  2(a1,d0.w),d4
                                                                          *    move.b  3(a1,d0.w),d5
                                                                          *    move.b  1(a1,d0.w),d3
                                                                          *
SSB_CC_ProcessYCenter                                                     *loc_351F8:
        clra
        ldb   1,x
        tstb
        bpl   @a                                                          *    bpl.s   loc_35202
        cmpb  #$48                                                        *    cmpi.b  #$48,d3
        blo   @a                                                          *    blo.s   loc_35202
        sex                                                               *    ext.w   d3
@a      std   yCenter+1
        std   syCenter+1
                                                                          *
                                                                          *loc_35202:
        ldb   angle,u                                                     *    move.b  angle(a0),d0

        ldy   #Sine_Data                                                  *CalcSine:
        lda   #$00                                                        *    andi.w  #$FF,d0
        aslb                                                              *    add.w   d0,d0
	    rola
	    leay  d,y
	    ldd   ,y
	    std   ysin+1
        leay  $80,y                                                       *    addi.w  #$80,d0
	    ldd   ,y                                                          *    move.w  Sine_Data(pc,d0.w),d1 ; cos
                                                                          *    subi.w  #$80,d0
                                                                          *    move.w  Sine_Data(pc,d0.w),d0 ; sin
                                                                          *; CalcSineEnd
                                                                          
                                                                          *    muls.w  d4,d1
                                                                          *    muls.w  d5,d0
                                                                          *    asr.l   #8,d0
                                                                          *    asr.l   #8,d1
                                                                          *    add.w   d2,d1
                                                                          *    add.w   d3,d0
                                                                          *    move.w  d1,x_pos(a0)
                                                                          *    move.w  d0,y_pos(a0)
        ; Compute X coordinate
        ; --------------------                                                                                                                                            
        ; signed mul of a value (range FF00-0100) with an non null unsigned byte (01-FF)
        ; next the value is divided by 256
        
        tsta
        beq   xpos  ; cas $0000 <= d <= $00FF
        bpl   xp256 ; cas d = $0100
        tstb
        bne   xneg  ; cas $FF01 >= d >= $FFFF    

xn256   ldb   2,x  ; cas d = $FF00
        negb
        bra   xEnd

xp256   clra
        ldb   2,x
        bra   xEnd

xpos    lda   2,x 
        mul
        tfr   a,b
        clra
        bra   xEnd

xneg    lda   2,x    
        negb
        mul
        nega
        negb
        sbca  #0
        tfr   a,b
        lda   #$FF
        
xEnd    std   sx+1
xCenter addd  #$0000                   ; (dynamic) add x center of ellipse
        ;std   x_pos,u
        
        lsra                           ; megadrive coordinates conversion
        rorb    
        addd  #$40
        stb   x_pixel,u
        tsta
        beq   ysin
        sta   is_out_of_screen
          
        ; Compute Y coordinate
        ; --------------------          
        ; signed mul of a value (range FF00-0100) with an non null unsigned byte (01-FF)
        ; next the value is divided by 256
        
ysin    ldd   #$0000                   ; (dynamic) get sin
        tsta
        beq   ypos  ; cas $0000 <= d <= $00FF
        bpl   yp256 ; cas d = $0100
        tstb
        bne   yneg  ; cas $FF01 >= d >= $FFFF    

yn256   ldb   3,x  ; cas d = $FF00
        negb
        bra   yEnd

yp256   clra
        ldb   3,x
        bra   yEnd

ypos    lda   3,x 
        mul
        tfr   a,b
        clra
        bra   yEnd

yneg    lda   3,x    
        negb
        mul
        nega
        negb
        sbca  #0
        tfr   a,b
        lda   #$FF
        
yEnd    std   sy+1
yCenter addd  #$0000                   ; (dynamic) add y center of ellipse
        ;std   y_pos,u
        addd  #$10
        stb   y_pixel,u
        tsta
        beq   scoord
        sta   is_out_of_screen        

        ; Process shadow coordinates
        ; --------------------------

scoord  ldy   ss_parent,u                                                 *    move.l  objoff_34(a0),d0
        beq   SSB_CC_Return_2                                             *    beq.s   loc_3524E
        tst   id,y
        beq   SSB_CC_Return_2
                                                                          *    movea.l d0,a1 ; a1=object
                                                                          *    move.b  angle(a0),d0
                                                                          *
                                                                          *CalcSine:
                                                                          *    andi.w  #$FF,d0
                                                                          *    add.w   d0,d0
																          
																          
																          
																          
                                                                          *    addi.w  #$80,d0
	                                                                      *    move.w  Sine_Data(pc,d0.w),d1 ; cos
                                                                          *    subi.w  #$80,d0
                                                                          *    move.w  Sine_Data(pc,d0.w),d0 ; sin
                                                                          *; CalcSineEnd
        ; we will appy 1,25 factor on already calculated ellipse          *
        ; instead of process muls one more time                                                                  
sx      ldd   #$0000                   ; (dynamic)
        ldx   >*-2
        asra
        rorb
        asra
        rorb        
        leax  d,x

         
sxCenter
        ldd   #$0000                   ; (dynamic) add x center of ellipse
        leax  d,x        
        ;stx   x_pos,y 
        
        tfr   x,d        
        lsra                           ; megadrive coordinates conversion
        rorb    
        addd  #$40
        stb   x_pixel,y
        tsta
        beq   sy
        sta   is_out_of_screen            
                                                                          *    move.w  d4,d7
                                                                          *    lsr.w   #2,d7
                                                                          *    add.w   d7,d4
                                                                          *    muls.w  d4,d1
        ; we will appy 1,25 factor on already calculated ellipse          *
        ; instead of process muls one more time                                                                  
sy      ldd   #$0000                   ; (dynamic)
        ldx   >*-2
        asra
        rorb
        asra
        rorb        
        leax  d,x

         
syCenter
        ldd   #$0000                   ; (dynamic) add y center of ellipse
        leax  d,x        
        ;stx   y_pos,y  
        
        tfr   x,d
        addd  #$10
        stb   y_pixel,y
        tsta
        beq   SSB_CC_Return_2
        sta   is_out_of_screen          
                                                                          *    move.w  d5,d7
                                                                          *    asr.w   #2,d7
                                                                          *    add.w   d7,d5
                                                                          *    muls.w  d5,d0
                                                                          *    asr.l   #8,d0
                                                                          *    asr.l   #8,d1
                                                                          *    add.w   d2,d1
                                                                          *    move.w  d1,x_pos(a1)                                                                                                                            
                                                                          *    add.w   d3,d0
                                                                          *    move.w  d0,y_pos(a1)
                                                                          *
SSB_CC_Return_2                                                           *loc_3524E:
                                                                          *    ori.b   #$80,render_flags(a0)
                                                                          *
                                                                          *loc_35254:
                                                                          *    move.w  (sp)+,d7
        rts                                                               *    rts                                                      
                                                                          *; ===========================================================================
                                                                          *loc_35258:
                                                                          *    andi.b  #$7F,render_flags(a0)
                                                                          *    bra.s   loc_35254
                                                                          *; ===========================================================================  
SSB_CC_Flipped                                                            *loc_35260:
                                                                          *    move.b  #$80,d1
                                                                          *    move.b  4(a1,d0.w),d6
        ldb   5,x                      ; branch if angle min              *    move.b  5(a1,d0.w),d7
        beq   SSB_CC_FVisibleArea      ; of visible area is 0             *    beq.s   loc_35282
        clra
        subd  #$0080
        negb
        stb   fd7+1
        clra
        ldb   4,x
        subd  #$0080
        negb
        stb   fd6+1        
                                                                          *    sub.w   d1,d6
                                                                          *    sub.w   d1,d7
                                                                          *    neg.w   d6
                                                                          *    neg.w   d7
        lda   angle,u                  ; load sprite angle                *    move.b  angle(a0),d1
fd7     cmpa  #$00                     ; (dynamic) angle min (excl.)      *    cmp.b   d7,d1
        blo   SSB_CC_FVisibleArea                                         *    blo.s   loc_35282
fd6     cmpa  #$00                     ; (dynamic) angle max (incl.)      *    cmp.b   d6,d1
        blo   SSB_CC_Return_2                                             *    blo.s   loc_35258
                                                                          *
SSB_CC_FVisibleArea                                                       *loc_35282:
        clra
        ldb   ,x                                                          *    move.b  (a1,d0.w),d2
                                                                          *    move.b  2(a1,d0.w),d4
                                                                          *    move.b  3(a1,d0.w),d5
        subd  #$100                                                       *    subi.w  #$100,d2
        nega                                                              *    neg.w   d2
        negb
        sbca  #0
        std   xCenter+1
        std   sxCenter+1
                                                                          *    move.b  1(a1,d0.w),d3
        jmp   SSB_CC_ProcessYCenter                                       *    bra.w   loc_351F8
                                                                          																		  
                                                                          *; ===========================================================================
                                                                          *
																		  
SSB_InitShadow                                                            *loc_3529C:
        rts
        jsr   SSSingleObjLoad2                                            *    jsrto   (SSSingleObjLoad2).l, JmpTo_SSSingleObjLoad2
        bne   SSB_InitShadow_return                                       *    bne.w   return_3532C
        stu   ss_parent,x                                                 *    move.l  a0,objoff_34(a1)
        stx   ss_parent,u                                                 
        lda   id,u                                                        
        sta   id,x                                                        *    move.b  id(a0),id(a1)
        ldd   #$0205                                                      
        sta   routine,x                                                   *    move.b  #4,routine(a1)
                                                                          *    move.l  #Obj63_MapUnc_34492,mappings(a1)
                                                                          *    move.w  #make_art_tile(ArtTile_ArtNem_SpecialFlatShadow,3,0),art_tile(a1)
                                                                          *    move.b  #4,render_flags(a1)
        stb   priority,x                                                  *    move.b  #5,priority(a1)
        lda   angle,u                                                     *    move.b  angle(a0),d0
        cmpa  #$10                                                        *    cmpi.b  #$10,d0
        bgt   loc_352E6                                                   *    bgt.s   loc_352E6
        lda   render_flags,x                                              
        ora   #render_xmirror_mask                                        *    bset    #0,render_flags(a1)
        sta   render_flags,x
        lda   #2                                                          
        sta   ss_shadow_tilt,x                                            *    move.b  #2,objoff_2B(a1)
                                                                          *    move.l  a1,objoff_34(a0)
SSB_InitShadow_return
        rts                                                               *    rts
                                                                          *; ===========================================================================
                                                                          *
loc_352E6                                                                 *loc_352E6:
        cmpa  #$30                                                        *    cmpi.b  #$30,d0
        bgt   loc_352FE                                                   *    bgt.s   loc_352FE
        lda   render_flags,x                                              
        ora   #render_xmirror_mask                                        *    bset    #0,render_flags(a1)
        sta   render_flags,x
        lda   #1                                                          
        sta   ss_shadow_tilt,x                                            *    move.b  #1,objoff_2B(a1)
                                                                          *    move.l  a1,objoff_34(a0)
        rts                                                               *    rts
                                                                          *; ===========================================================================
                                                                          *
loc_352FE                                                                 *loc_352FE:
        cmpa  #$50                                                        *    cmpi.b  #$50,d0
        bgt   loc_35310                                                   *    bgt.s   loc_35310
        lda   #0                                                          
        sta   ss_shadow_tilt,x                                            *    move.b  #0,objoff_2B(a1)
                                                                          *    move.l  a1,objoff_34(a0)
        rts                                                               *    rts
                                                                          *; ===========================================================================
                                                                          *
loc_35310                                                                 *loc_35310:
        cmpa  #$70                                                        *    cmpi.b  #$70,d0
        bgt   loc_35322                                                   *    bgt.s   loc_35322
        lda   #1                                                          
        sta   ss_shadow_tilt,x                                            *    move.b  #1,objoff_2B(a1)
                                                                          *    move.l  a1,objoff_34(a0)
        rts                                                               *    rts
                                                                          *; ===========================================================================
                                                                          *
loc_35322                                                                 *loc_35322:
        lda   #2                                                          
        sta   ss_shadow_tilt,x                                            *    move.b  #2,objoff_2B(a1)
                                                                          *    move.l  a1,objoff_34(a0)
                                                                          *
                                                                          *return_3532C:
        rts                                                               *    rts
		
                                                                          *; ===========================================================================
                                                                          *    dc.b   0
                                                                          *    dc.b   0    ; 1
                                                                          *    dc.b   0    ; 2
                                                                          *    dc.b $18    ; 3
                                                                          *    dc.b   0    ; 4
                                                                          *    dc.b $14    ; 5
                                                                          *    dc.b   0    ; 6
                                                                          *    dc.b $14    ; 7
                                                                          *    dc.b   0    ; 8
                                                                          *    dc.b $14    ; 9
                                                                          *    dc.b   0    ; 10
                                                                          *    dc.b   0    ; 11
                                                                          *; ===========================================================================
                                                                          *
																		  
SSB_Shadow                                                                *loc_3533A:
        tst   ss_self_delete,u                                            *    tst.b   objoff_2A(a0)
        bne   SSB_DeleteShadow                                            *    bne.w   BranchTo_JmpTo63_DeleteObject
        ldx   ss_parent,u                                                 *    movea.l objoff_34(a0),a1 ; a1=object
        beq   SSB_DeleteShadow
        tst   id,x
        beq   SSB_DeleteShadow
        tst   rsv_render_flags,x       ; only render shadow if parent     *    tst.b   render_flags(a1)
        bmi   @a                       ; is on screen                     *    bmi.s   loc_3534E
        rts                                                               *    rts
                                                                          *; ===========================================================================
                                                                          *
@a                                                                        *loc_3534E:
                                                                          *    moveq   #9,d0
                                                                          *    sub.b   anim(a1),d0
                                                                          *    addi_.b #1,d0
                                                                          *    cmpi.b  #$A,d0
                                                                          *    bne.s   loc_35362
                                                                          *    move.w  #9,d0
                                                                          *
                                                                          *loc_35362:
                                                                          *    move.w  d0,d1
                                                                          *    add.w   d0,d0
                                                                          *    add.w   d1,d0
                                                                          *    moveq   #0,d1
        lda   ss_shadow_tilt,u                                            *    move.b  objoff_2B(a0),d1
        beq   loc_3538A                                                   *    beq.s   loc_3538A
        cmpa  #1                                                          *    cmpi.b  #1,d1
        beq   loc_35380                                                   *    beq.s   loc_35380
                                                                          *    add.w   d1,d0
                                                                          *    move.w  #make_art_tile(ArtTile_ArtNem_SpecialSideShadow,3,0),art_tile(a0)
        lda   mapping_frame,x
        ldx   #Tbl_SSShadow_Side
        ldd   a,x
        std   image_set,u
        jmp   DisplaySprite                                                                               
                                                                          *    bra.s   loc_35392
                                                                          *; ===========================================================================
                                                                          *
loc_35380                                                                 *loc_35380:
                                                                          *    add.w   d1,d0
                                                                          *    move.w  #make_art_tile(ArtTile_ArtNem_SpecialDiagShadow,3,0),art_tile(a0)
        lda   mapping_frame,x
        ldx   #Tbl_SSShadow_Diag
        ldd   a,x
        std   image_set,u
        jmp   DisplaySprite                                                                                          
                                                                          *    bra.s   loc_35392
                                                                          *; ===========================================================================
                                                                          *
loc_3538A                                                                 *loc_3538A:
                                                                          *    add.w   d1,d0
                                                                          *    move.w  #make_art_tile(ArtTile_ArtNem_SpecialFlatShadow,3,0),art_tile(a0)
        lda   mapping_frame,x
        ldx   #Tbl_SSShadow_Flat
        ldd   a,x
        std   image_set,u  
        jmp   DisplaySprite                                                                                        
                                                                          *
                                                                          *loc_35392:
                                                                          *    move.b  d0,mapping_frame(a0)
                                                                          *    bra.w   JmpTo44_DisplaySprite
                                                                          *
                                                                          *BranchTo_JmpTo63_DeleteObject ; BranchTo
SSB_DeleteShadow
        jmp   DeleteObject                                                *    jmpto   (DeleteObject).l, JmpTo63_DeleteObject
		
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_3539E:
                                                                          *    subq.b  #1,anim_frame_duration(a0)
                                                                          *    bpl.s   return_353E8
                                                                          *    moveq   #0,d0
                                                                          *    move.b  anim(a0),d0
                                                                          *    add.w   d0,d0
                                                                          *    adda.w  (a1,d0.w),a1
                                                                          *    move.b  (a1),anim_frame_duration(a0)
                                                                          *    moveq   #0,d1
                                                                          *    move.b  anim_frame(a0),d1
                                                                          *    move.b  1(a1,d1.w),d0
                                                                          *    bpl.s   loc_353CA
                                                                          *    move.b  #0,anim_frame(a0)
                                                                          *    move.b  1(a1),d0
                                                                          *
                                                                          *loc_353CA:
                                                                          *    andi.b  #$7F,d0
                                                                          *    move.b  d0,mapping_frame(a0)
                                                                          *    move.b  status(a0),d1
                                                                          *    andi.b  #3,d1
                                                                          *    andi.b  #$FC,render_flags(a0)
                                                                          *    or.b    d1,render_flags(a0)
                                                                          *    addq.b  #1,anim_frame(a0)
                                                                          *
                                                                          *return_353E8:
                                                                          *    rts
                                                                          *; ===========================================================================
                                                                          *byte_353EA:
                                                                          *    dc.b $38
                                                                          *    dc.b $48    ; 1
                                                                          *    dc.b $2A    ; 2
                                                                          *    dc.b $56    ; 3
                                                                          *    dc.b $1C    ; 4
                                                                          *    dc.b $64    ; 5
                                                                          *    dc.b  $E    ; 6
                                                                          *    dc.b $72    ; 7
                                                                          *    dc.b   0    ; 8
                                                                          *    dc.b $80    ; 9
                                                                          *byte_353F4:
                                                                          *    dc.b $40
                                                                          *    dc.b $30    ; 1
                                                                          *    dc.b $50    ; 2
                                                                          *    dc.b $20    ; 3
                                                                          *    dc.b $60    ; 4
                                                                          *    dc.b $10    ; 5
                                                                          *    dc.b $70    ; 6
                                                                          *    dc.b   0    ; 7
                                                                          *    dc.b $80    ; 8
                                                                          *    dc.b   0    ; 9
													                      
is_out_of_screen
        fcb   $00
        
Tbl_SSShadow_Flat
        fdb   Img_SSShadow_000
        fdb   Img_SSShadow_003
        fdb   Img_SSShadow_006
        fdb   Img_SSShadow_009
        fdb   Img_SSShadow_012
        fdb   Img_SSShadow_015
        fdb   Img_SSShadow_018
        fdb   Img_SSShadow_021
        fdb   Img_SSShadow_024
        fdb   Img_SSShadow_027

Tbl_SSShadow_Diag
        fdb   Img_SSShadow_001
        fdb   Img_SSShadow_004
        fdb   Img_SSShadow_007
        fdb   Img_SSShadow_010
        fdb   Img_SSShadow_013
        fdb   Img_SSShadow_016
        fdb   Img_SSShadow_019
        fdb   Img_SSShadow_022
        fdb   Img_SSShadow_025
        fdb   Img_SSShadow_028

Tbl_SSShadow_Side
        fdb   Img_SSShadow_002
        fdb   Img_SSShadow_005
        fdb   Img_SSShadow_008
        fdb   Img_SSShadow_011
        fdb   Img_SSShadow_014
        fdb   Img_SSShadow_017
        fdb   Img_SSShadow_020
        fdb   Img_SSShadow_023
        fdb   Img_SSShadow_026
        fdb   Img_SSShadow_029 																		  
																		  
Sine_Data                                                                 *Sine_Data:      BINCLUDE        "misc/sinewave.bin"
        INCLUDEBIN "./Engine/Math/sinewave.bin"                                 

        ; -------------------------------------------------------------------------------------------------------------        
        ; Sinus/Cosinus
        ; -------------------------------------------------------------------------------------------------------------             
        ;
        ; 0000 0006 000c ... 00ff 0100 00ff ... 0006 0000 fffa ... ff01 ff00 ff01 ... fffa 0000 0006 ... 00ff
        ; |______________________________________________________________________________|
        ;  sin values from index $0000 to index $01ff, value range: $ff00 (-256) to $0100 (256) 
        ;                         |_________________________________________________________________________|
        ;                          cos values from index $0080 to index $027f, value range: $ff00 (-256) to $0100 (256)
        ;
        ; -------------------------------------------------------------------------------------------------------------
        
SpecialPerspective
        INCLUDEBIN "./game-mode/special-stage/Special stage object perspective data.bin" 

        ; -------------------------------------------------------------------------------------------------------------
        ; Perspective data
        ; -------------------------------------------------------------------------------------------------------------
        ;        
        ; Index (words)
        ; -----
        ; Offset to each halfpipe image perspective data (56 word offsets for the 56 images)
        ;
        ; Image perspective data
        ; ----------------------      
        ;  1 word : n number of z_pos defined for this frame from 1 (camera front) to n (far away)
        ;  n groups of 6 bytes : 7b dd b8 e6 00 00   that defines an elipse arc
        ;                        |  |  |  |  |  |___ angle min (excl.) of visible area (0: no invisible area)
        ;                        |  |  |  |  |______ angle max (incl.) of visible area
        ;                        |  |  |  |_________ y radius
        ;                        |  |  |____________ x radius
        ;                        |  |_______________ y origin
        ;                        |__________________ x origin
        ;
        ; -------------------------------------------------------------------------------------------------------------
        
        INCLUDE "./Engine/ObjectManagement/SSSingleObjLoad.asm"            																		  