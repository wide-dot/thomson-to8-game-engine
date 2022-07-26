; ---------------------------------------------------------------------------
; Object - Shadow from Special Stage
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

rts
                                                                          *; ===========================================================================
                                                                          *; ----------------------------------------------------------------------------
                                                                          *; Object 63 - Character shadow from Special Stage
                                                                          *; ----------------------------------------------------------------------------
                                                                          *; Sprite_340A4:
                                                                          *Obj63:
                                                                          *        movea.l ss_parent(a0),a1 ; a1=object
                                                                          *        cmpa.l  #MainCharacter,a1
                                                                          *        bne.s   loc_340BC
                                                                          *        movea.l #MainCharacter,a1 ; a1=character
                                                                          *        bsr.s   loc_340CC
                                                                          *        jmpto   (DisplaySprite).l, JmpTo42_DisplaySprite
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_340BC:
                                                                          *        movea.l #Sidekick,a1 ; a1=object
                                                                          *        bsr.s   loc_340CC
                                                                          *        bsr.w   loc_341BA
                                                                          *        jmpto   (DisplaySprite).l, JmpTo42_DisplaySprite
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_340CC:
                                                                          *        cmpi.b  #2,routine(a1)
                                                                          *        beq.w   loc_34108
                                                                          *        bsr.w   loc_33D02
                                                                          *        move.b  angle(a0),d0
                                                                          *        jsr     (CalcSine).l
                                                                          *        muls.w  ss_z_pos(a1),d1
                                                                          *        muls.w  #$CC,d1
                                                                          *        swap    d1
                                                                          *        add.w   (SS_Offset_X).w,d1
                                                                          *        move.w  d1,x_pos(a0)
                                                                          *        muls.w  ss_z_pos(a1),d0
                                                                          *        asr.l   #8,d0
                                                                          *        add.w   (SS_Offset_Y).w,d0
                                                                          *        move.w  d0,y_pos(a0)
                                                                          *        bra.w   loc_3411A
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_34108:
                                                                          *        move.w  x_pos(a1),x_pos(a0)
                                                                          *        move.w  y_pos(a1),y_pos(a0)
                                                                          *        move.b  angle(a1),angle(a0)
                                                                          *
                                                                          *loc_3411A:
                                                                          *        moveq   #0,d0
                                                                          *        move.b  angle(a0),d0
                                                                          *        subi.b  #$10,d0
                                                                          *        lsr.b   #5,d0
                                                                          *        move.b  d0,d1
                                                                          *        lsl.w   #3,d0
                                                                          *        lea     word_3417A(pc),a2
                                                                          *        adda.w  d0,a2
                                                                          *        move.w  (a2)+,art_tile(a0)
                                                                          *        move.w  (a2)+,d0
                                                                          *        add.w   d0,x_pos(a0)
                                                                          *        move.w  (a2)+,d0
                                                                          *        add.w   d0,y_pos(a0)
                                                                          *        move.b  (a2)+,mapping_frame(a0)
                                                                          *        move.b  render_flags(a0),d0
                                                                          *        andi.b  #$FC,d0
                                                                          *        or.b    (a2)+,d0
                                                                          *        move.b  d0,render_flags(a0)
                                                                          *        tst.b   angle(a0)
                                                                          *        bpl.s   return_34178
                                                                          *        cmpi.b  #3,d1
                                                                          *        beq.s   loc_34164
                                                                          *        cmpi.b  #7,d1
                                                                          *        bne.s   loc_3416A
                                                                          *
                                                                          *loc_34164:
                                                                          *        addi_.b #3,mapping_frame(a0)
                                                                          *
                                                                          *loc_3416A:
                                                                          *        move.w  (SS_Offset_Y).w,d1
                                                                          *        sub.w   y_pos(a0),d1
                                                                          *        add.w   d1,d1
                                                                          *        add.w   d1,y_pos(a0)
                                                                          *
                                                                          *return_34178:
                                                                          *        rts
                                                                          *; ===========================================================================
                                                                          *word_3417A:
                                                                          *        dc.w make_art_tile(ArtTile_ArtNem_SpecialDiagShadow,3,0),  $14,  $14,   $101
                                                                          *        dc.w make_art_tile(ArtTile_ArtNem_SpecialFlatShadow,3,0),    0,  $18,      0; 4
                                                                          *        dc.w make_art_tile(ArtTile_ArtNem_SpecialDiagShadow,3,0),$FFEC,  $14,   $100; 8
                                                                          *        dc.w make_art_tile(ArtTile_ArtNem_SpecialSideShadow,3,0),$FFEC,    0,   $200; 12
                                                                          *        dc.w make_art_tile(ArtTile_ArtNem_SpecialDiagShadow,3,0),$FFEC,$FFEC,   $700; 16
                                                                          *        dc.w make_art_tile(ArtTile_ArtNem_SpecialFlatShadow,3,0),    0,$FFE8,   $900; 20
                                                                          *        dc.w make_art_tile(ArtTile_ArtNem_SpecialDiagShadow,3,0),  $14,$FFEC,   $701; 24
                                                                          *        dc.w make_art_tile(ArtTile_ArtNem_SpecialSideShadow,3,0),  $14,    0,   $201; 28
                                                                          *; ===========================================================================
                                                                          *
                                                                          *loc_341BA:
                                                                          *        cmpi.b  #1,anim(a1)
                                                                          *        bne.s   return_341E0
                                                                          *        move.b  status(a1),d1
                                                                          *        andi.w  #3,d1
                                                                          *        cmpi.b  #2,d1
                                                                          *        bhs.s   return_341E0
                                                                          *        move.b  byte_341E2(pc,d1.w),d0
                                                                          *        ext.w   d0
                                                                          *        add.w   d0,x_pos(a0)
                                                                          *        subi_.w #4,y_pos(a0)
                                                                          *
                                                                          *return_341E0:
                                                                          *        rts
                                                                          *; ===========================================================================
                                                                          *; animation script
                                                                          *byte_341E2:     dc.b  4, -4
                                                                          *off_341E4:      offsetTable
                                                                          *                offsetTableEntry.w byte_341EE   ; 0
                                                                          *                offsetTableEntry.w byte_341F4   ; 1
                                                                          *                offsetTableEntry.w byte_341FE   ; 2
                                                                          *                offsetTableEntry.w byte_34204   ; 3
                                                                          *                offsetTableEntry.w byte_34208   ; 4
                                                                          *byte_341EE:
                                                                          *        dc.b   3,  0,  1,  2,  3,$FF
                                                                          *byte_341F4:
                                                                          *        dc.b   3,  4,  5,  6,  7,  8,  9, $A, $B,$FF
                                                                          *byte_341FE:
                                                                          *        dc.b   3, $C, $D, $E, $F,$FF
                                                                          *byte_34204:
                                                                          *        dc.b   1,$10,$11,$FF
                                                                          *byte_34208:
                                                                          *        dc.b   3,  0,  4, $C,  4,  0,  4, $C,  4,$FF
                                                                          *        even
                                                                          *       