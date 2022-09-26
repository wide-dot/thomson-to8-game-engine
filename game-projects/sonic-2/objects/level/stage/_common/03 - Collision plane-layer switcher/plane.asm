        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256

 ; http://info.sonicretro.org/Path_swapper
 ; subtype has the format HGFE DCBA:
 ; BA is the collision radius of the object (radius in pixels = $20 * 2^BA)
 ; C is the orientation - 0 means the swapper is vertical and operates from left to right and right to left, 1 means the swapper is horizontal and operates from up to down and down to up
 ; D is the operation when the player crosses from left to right or up to down - 0 means move to low plane, 1 means move to high plane
 ; E is the operation when the player crosses from right to left or down to up - 0 means move to low plane, 1 means move to high plane
 ; F indicates if the swapper should set the high priority bit of the player's art tile when the player is crossing from left to right or up to down - if this is 0, the priority bit is cleared, and if it is 1, the bit is set
 ; G indicates if the swapper should set the high priority bit of the player's art tile when the player is crossing from right to left or down to up - if this is 0, the priority bit is cleared, and if it is 1, the bit is set
 ; H is a flag which if set indicates that the swapper should only change the collision plane when the player is on the ground

 ; Megadrive layers priority
 ; -------------------------
 ; Background color
 ; Low priority plane B
 ; Low priority plane A
 ; Low priority sprites
 ; High priority plane B
 ; High priority plane A
 ; High priority sprites

subtype_radius      equ $03
subtype_orientation equ $04
subtype_op_RD       equ $08
subtype_op_LU       equ $10
subtype_hp_RD       equ $20
subtype_hp_LU       equ $40
subtype_on_ground   equ $80

collision_radius_x  equ ext_variables_obj    ; word = objoff_32
collision_radius_y  equ ext_variables_obj+2  ; word
ply1_position       equ ext_variables_obj+4  ; byte = objoff_34 (player position relative to collision obj: 0 at left or top, 1 at right or down)
ply2_position       equ ext_variables_obj+5  ; byte = objoff_35

                                                      *; ===========================================================================
                                                      *; ----------------------------------------------------------------------------
                                                      *; Object 03 - Collision plane/layer switcher
                                                      *; ----------------------------------------------------------------------------
                                                      *; Sprite_1FCDC:
Obj03                                                 *Obj03:
                                                      *        moveq   #0,d0
        lda   routine,u                               *        move.b  routine(a0),d0
        asla
        ldx   #Obj03_Index                            *        move.w  Obj03_Index(pc,d0.w),d1
        jsr   [a,x]                                   *        jsr     Obj03_Index(pc,d1.w)
        jmp   MarkObjGone3                            *        jmp     (MarkObjGone3).l
                                                      *; ===========================================================================
                                                      *; off_1FCF0:
Obj03_Index                                           *Obj03_Index:    offsetTable
        fdb   Obj03_Init                              *                offsetTableEntry.w Obj03_Init   ; 0
        fdb   Obj03_MainX                             *                offsetTableEntry.w Obj03_MainX  ; 2
        fdb   Obj03_MainY                             *                offsetTableEntry.w Obj03_MainY  ; 4
                                                      *; ===========================================================================
                                                      *; loc_1FCF6:
Obj03_Init                                            *Obj03_Init:
        inc   routine,u                               *        addq.b  #2,routine(a0) ; => Obj03_MainX
        ;                                             *        move.l  #Obj03_MapUnc_1FFB8,mappings(a0)
        ;                                             *        move.w  #make_art_tile(ArtTile_ArtNem_Ring,1,0),art_tile(a0)
        ;                                             *        jsrto   (Adjust2PArtPointer).l, JmpTo7_Adjust2PArtPointer
        sta   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u                          *        ori.b   #4,render_flags(a0)
        _ldd  $10,5
        sta   width_pixels,u                          *        move.b  #$10,width_pixels(a0)
        stb   priority,u                              *        move.b  #5,priority(a0)
        ldb   subtype,u                               *        move.b  subtype(a0),d0
        andb  #subtype_orientation                    *        btst    #2,d0
        beq   Obj03_Init_CheckX                       *        beq.s   Obj03_Init_CheckX
Obj03_Init_CheckY                                     *;Obj03_Init_CheckY:
        inc   routine,u                               *        addq.b  #2,routine(a0) ; => Obj03_MainY
        ;                                             *        andi.w  #7,d0
        ;                                             *        move.b  d0,mapping_frame(a0)
        andb  #3                                      *        andi.w  #3,d0
        aslb                                          *        add.w   d0,d0
        ldx   #Tbl_CollisionRadius
        ldd   b,x
        _asrd ; wide dot factor
        std   collision_radius_x,u                    *        move.w  word_1FD68(pc,d0.w),objoff_32(a0)
        ldd   y_pos,u                                 *        move.w  y_pos(a0),d1
        ; maincharacter is in dp                      *        lea     (MainCharacter).w,a1 ; a1=character
        cmpd  dp+y_pos                                *        cmp.w   y_pos(a1),d1
        bhs   >                                       *        bhs.s   +
        lda   #1
        sta   ply1_position,u                         *        move.b  #1,objoff_34(a0)
!                                                     *+
        ;                                             *        lea     (Sidekick).w,a1 ; a1=character
        ;                                             *        cmp.w   y_pos(a1),d1
        ;                                             *        bhs.s   +
        ;                                             *        move.b  #1,objoff_35(a0)
        ;                                             *+
        jmp   Obj03_MainY                             *        bra.w   Obj03_MainY
                                                      *; ===========================================================================
Tbl_CollisionRadius                                   *word_1FD68:
        fcb   $20                                     *        dc.w   $20
        fcb   $40                                     *        dc.w   $40      ; 1
        fcb   $80                                     *        dc.w   $80      ; 2
        fcb   $100                                    *        dc.w  $100      ; 3
                                                      *; ===========================================================================
                                                      *; loc_1FD70:
Obj03_Init_CheckX                                     *Obj03_Init_CheckX:
        andb  #3                                      *        andi.w  #3,d0
        ;                                             *        move.b  d0,mapping_frame(a0)
        aslb                                          *        add.w   d0,d0
        ldx   #Tbl_CollisionRadius
        ldd   b,x
        std   collision_radius_y,u                    *        move.w  word_1FD68(pc,d0.w),objoff_32(a0)
        ldd   x_pos,u                                 *        move.w  x_pos(a0),d1
        ; maincharacter is in dp                      *        lea     (MainCharacter).w,a1 ; a1=character
        cmpd  dp+x_pos                                *        cmp.w   x_pos(a1),d1
        bhs   >                                       *        bhs.s   +
        lda   #1
        sta   ply1_position,u                         *        move.b  #1,objoff_34(a0)
!                                                     *+
        ;                                             *        lea     (Sidekick).w,a1 ; a1=character
        ;                                             *        cmp.w   x_pos(a1),d1
        ;                                             *        bhs.s   +
        ;                                             *        move.b  #1,objoff_35(a0)
        ;                                             *+
                                                      *
                                                      *; loc_1FDA4:
Obj03_MainX                                           *Obj03_MainX:
        ;                                             *        tst.w   (Debug_placement_mode).w
        ;                                             *        bne.w   return_1FEAC
        ldd   x_pos,u                                 *        move.w  x_pos(a0),d1
        ;                                             *        lea     objoff_34(a0),a2
        ; maincharacter is in dp                      *        lea     (MainCharacter).w,a1 ; a1=character
        ;                                             *        bsr.s   +
        ;                                             *        lea     (Sidekick).w,a1 ; a1=character
                                                      *
!       tst   ply1_position,u                         *+       tst.b   (a2)+
        bne   Obj03_MainX_Alt                         *        bne.s   Obj03_MainX_Alt
        cmpd  dp+x_pos                                *        cmp.w   x_pos(a1),d1
        bhi   @rts                                    *        bhi.w   return_1FEAC
        lda   #1
        sta   ply1_position,u                         *        move.b  #1,-1(a2)
        ldd   y_pos,u
        ;                                             *        move.w  y_pos(a0),d2
        ;                                             *        move.w  d2,d3
        ;                                             *        move.w  objoff_32(a0),d4
        subd  collision_radius_y,u                    *        sub.w   d4,d2
        std   glb_d2
        ldd   y_pos,u
        addd  collision_radius_y,u                    *        add.w   d4,d3
        std   glb_d3
        ldd   dp+y_pos                                *        move.w  y_pos(a1),d4
        cmpd  glb_d2                                  *        cmp.w   d2,d4
        blt   @rts                                    *        blt.w   return_1FEAC
        cmpd  glb_d3                                  *        cmp.w   d3,d4
        bge   @rts                                    *        bge.w   return_1FEAC
        ldb   subtype,u                               *        move.b  subtype(a0),d0
        bpl   >                                       *        bpl.s   +
        lda   dp+status
        anda  #status_inair                           *        btst    #1,status(a1)
        bne   @rts          ; skip if in air          *        bne.w   return_1FEAC
!                                                     *+
        lda   render_flags,u
        anda  #1                                      *        btst    #0,render_flags(a0)
        bne   >                                       *        bne.s   +
        ldd   #$0810
        std   dp+top_solid_bit ; and lrb_solid_bit    *        move.b  #$C,top_solid_bit(a1)
        ;                                             *        move.b  #$D,lrb_solid_bit(a1)
        ldb   subtype,u
        andb  #subtype_op_RD                          *        btst    #3,d0
        beq   >                                       *        beq.s   +
        ldd   #$2040
        std   dp+top_solid_bit ; and lrb_solid_bit    *        move.b  #$E,top_solid_bit(a1)
        ;                                             *        move.b  #$F,lrb_solid_bit(a1)
!                                                     *+
        ; TODO clear high priority                    *        andi.w  #drawing_mask,art_tile(a1)
        ldb   subtype,u
        andb  #subtype_hp_RD                          *        btst    #5,d0
        beq   @rts                                    *        beq.s   return_1FEAC
        ; TODO set high priority                      *        ori.w   #high_priority,art_tile(a1)
@rts    rts                                           *        bra.s   return_1FEAC
                                                      *; ===========================================================================

                                                      *; loc_1FE38:
Obj03_MainX_Alt                                       *Obj03_MainX_Alt:
        cmpd  dp+x_pos                                *        cmp.w   x_pos(a1),d1
        bls   @rts                                    *        bls.w   return_1FEAC
        lda   #0
        sta   ply1_position,u                         *        move.b  #0,-1(a2)
        ldd   y_pos,u
        ;                                             *        move.w  y_pos(a0),d2
        ;                                             *        move.w  d2,d3
        ;                                             *        move.w  objoff_32(a0),d4
        subd  collision_radius_y,u                    *        sub.w   d4,d2
        std   glb_d2
        ldd   y_pos,u
        addd  collision_radius_y,u                    *        add.w   d4,d3
        std   glb_d3
        ldd   dp+y_pos                                *        move.w  y_pos(a1),d4
        cmpd  glb_d2                                  *        cmp.w   d2,d4
        blt   @rts                                    *        blt.w   return_1FEAC
        cmpd  glb_d3                                  *        cmp.w   d3,d4
        bge   @rts                                    *        bge.w   return_1FEAC
        ldb   subtype,u                               *        move.b  subtype(a0),d0
        bpl   >                                       *        bpl.s   +
        lda   dp+status
        anda  #status_inair                           *        btst    #1,status(a1)
        bne   @rts          ; skip if in air          *        bne.w   return_1FEAC
!                                                     *+
        lda   render_flags,u
        anda  #1                                      *        btst    #0,render_flags(a0)
        bne   >                                       *        bne.s   +
        ldd   #$0810
        std   dp+top_solid_bit ; and lrb_solid_bit    *        move.b  #$C,top_solid_bit(a1)
        ;                                             *        move.b  #$D,lrb_solid_bit(a1)
        ldb   subtype,u
        andb  #subtype_op_LU                          *        btst    #4,d0
        beq   >                                       *        beq.s   +
        ldd   #$2040
        std   dp+top_solid_bit ; and lrb_solid_bit    *        move.b  #$E,top_solid_bit(a1)
        ;                                             *        move.b  #$F,lrb_solid_bit(a1)
!                                                     *+
        ; TODO clear high priority                    *        andi.w  #drawing_mask,art_tile(a1)
        ldb   subtype,u
        andb  #subtype_hp_LU                          *        btst    #6,d0
        beq   @rts                                    *        beq.s   return_1FEAC
        ; TODO set high priority                      *        ori.w   #high_priority,art_tile(a1)
                                                      *
        ;                                             *return_1FEAC:
@rts    rts                                           *        rts

                                                      *; ===========================================================================
                                                      *
Obj03_MainY                                           *Obj03_MainY:
        ;                                             *        tst.w   (Debug_placement_mode).w
        ;                                             *        bne.w   return_1FFB6
        ldd   x_pos,u                                 *        move.w  y_pos(a0),d1
        ;                                             *        lea     objoff_34(a0),a2
        ; maincharacter is in dp                      *        lea     (MainCharacter).w,a1 ; a1=character
        ;                                             *        bsr.s   +
        ;                                             *        lea     (Sidekick).w,a1 ; a1=character
                                                      *
!       tst   ply1_position,u                         *+       tst.b   (a2)+
        bne   Obj03_MainY_Alt                         *        bne.s   Obj03_MainY_Alt
        cmpd  dp+y_pos                                *        cmp.w   y_pos(a1),d1
        bhi   @rts                                    *        bhi.w   return_1FFB6
        lda   #1
        sta   ply1_position,u                         *        move.b  #1,-1(a2)
        ldd   x_pos,u
        ;                                             *        move.w  x_pos(a0),d2
        ;                                             *        move.w  d2,d3
        ;                                             *        move.w  objoff_32(a0),d4
        subd  collision_radius_x,u                    *        sub.w   d4,d2
        std   glb_d2
        ldd   x_pos,u
        addd  collision_radius_x,u                    *        add.w   d4,d3
        std   glb_d3
        ldd   dp+x_pos                                *        move.w  x_pos(a1),d4
        cmpd  glb_d2                                  *        cmp.w   d2,d4
        blt   @rts                                    *        blt.w   return_1FFB6
        cmpd  glb_d3                                  *        cmp.w   d3,d4
        bge   @rts                                    *        bge.w   return_1FFB6
        ldb   subtype,u                               *        move.b  subtype(a0),d0
        bpl   >                                       *        bpl.s   +
        lda   dp+status
        anda  #status_inair                           *        btst    #1,status(a1)
        bne   @rts          ; skip if in air          *        bne.w   return_1FFB6
!                                                     *+
        lda   render_flags,u
        anda  #1                                      *        btst    #0,render_flags(a0)
        bne   >                                       *        bne.s   +
        ldd   #$0810
        std   dp+top_solid_bit ; and lrb_solid_bit    *        move.b  #$C,top_solid_bit(a1)
        ;                                             *        move.b  #$D,lrb_solid_bit(a1)
        ldb   subtype,u
        andb  #subtype_op_RD                          *        btst    #3,d0
        beq   >                                       *        beq.s   +
        ldd   #$2040
        std   dp+top_solid_bit ; and lrb_solid_bit    *        move.b  #$E,top_solid_bit(a1)
        ;                                             *        move.b  #$F,lrb_solid_bit(a1)
!                                                     *+
        ; TODO clear high priority                    *        andi.w  #drawing_mask,art_tile(a1)
        ldb   subtype,u
        andb  #subtype_hp_RD                          *        btst    #5,d0
        beq   @rts                                    *        beq.s   return_1FFB6
        ; TODO set high priority                      *        ori.w   #high_priority,art_tile(a1)
@rts    rts                                           *        bra.s   return_1FFB6

                                                      *; ===========================================================================
                                                      *; loc_1FF42:
Obj03_MainY_Alt                                       *Obj03_MainY_Alt:
        cmpd  dp+y_pos                                *        cmp.w   y_pos(a1),d1
        bls   @rts                                    *        bls.w   return_1FFB6
        lda   #0
        sta   ply1_position,u                         *        move.b  #0,-1(a2)
        ldd   x_pos,u
        ;                                             *        move.w  x_pos(a0),d2
        ;                                             *        move.w  d2,d3
        ;                                             *        move.w  objoff_32(a0),d4
        subd  collision_radius_x,u                    *        sub.w   d4,d2
        std   glb_d2
        ldd   x_pos,u
        addd  collision_radius_x,u                    *        add.w   d4,d3
        std   glb_d3
        ldd   dp+x_pos                                *        move.w  x_pos(a1),d4
        cmpd  glb_d2                                  *        cmp.w   d2,d4
        blt   @rts                                    *        blt.w   return_1FFB6
        cmpd  glb_d3                                  *        cmp.w   d3,d4
        bge   @rts                                    *        bge.w   return_1FFB6
        ldb   subtype,u                               *        move.b  subtype(a0),d0
        bpl   >                                       *        bpl.s   +
        lda   dp+status
        anda  #status_inair                           *        btst    #1,status(a1)
        bne   @rts          ; skip if in air          *        bne.w   return_1FFB6
!                                                     *+
        lda   render_flags,u
        anda  #1                                      *        btst    #0,render_flags(a0)
        bne   >                                       *        bne.s   +
        ldd   #$0810
        std   dp+top_solid_bit ; and lrb_solid_bit    *        move.b  #$C,top_solid_bit(a1)
        ;                                             *        move.b  #$D,lrb_solid_bit(a1)
        ldb   subtype,u
        andb  #subtype_op_LU                          *        btst    #4,d0
        beq   >                                       *        beq.s   +
        ldd   #$2040
        std   dp+top_solid_bit ; and lrb_solid_bit    *        move.b  #$E,top_solid_bit(a1)
        ;                                             *        move.b  #$F,lrb_solid_bit(a1)
!                                                     *+
        ; TODO clear high priority                    *        andi.w  #drawing_mask,art_tile(a1)
        ldb   subtype,u
        andb  #subtype_hp_LU                          *        btst    #6,d0
        beq   @rts                                    *        beq.s   return_1FFB6
        ; TODO set high priority                      *        ori.w   #high_priority,art_tile(a1)
                                                      *
        ;                                             *return_1FFB6:
@rts    rts                                           *        rts