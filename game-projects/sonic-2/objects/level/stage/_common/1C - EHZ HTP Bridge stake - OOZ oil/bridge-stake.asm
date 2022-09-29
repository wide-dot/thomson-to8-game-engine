                                                      *; ===========================================================================
                                                      *; ----------------------------------------------------------------------------
                                                      *; Object 1C - Bridge stake in Emerald Hill Zone and Hill Top Zone, falling oil in Oil Ocean Zone
                                                      *; ----------------------------------------------------------------------------
                                                      *; Sprite_111D4:
Obj1C                                                 *Obj1C:
        ;                                             *        moveq   #0,d0
        lda   routine,u                               *        move.b  routine(a0),d0
        asla
        ldx   #Obj1C_Index                            *        move.w  Obj1C_Index(pc,d0.w),d1
        jmp   [a,x]                                   *        jmp     Obj1C_Index(pc,d1.w)
                                                      *; ===========================================================================
                                                      *; off_111E2:
Obj1C_Index                                           *Obj1C_Index:    offsetTable
        fdb   Obj1C_Init                              *                offsetTableEntry.w Obj1C_Init           ; 0
        fdb   MarkObjGone                             *                offsetTableEntry.w BranchTo_MarkObjGone ; 2
                                                      *; ===========================================================================
                                                      *
                                                      *objsubdecl macro frame, mapaddr,artaddr,width,priority
                                                      *        dc.l frame<<24|mapaddr
                                                      *        dc.w artaddr
                                                      *        dc.b width, priority
                                                      *    endm
                                                      *
                                                      *; dword_111E6:
                                                      *Obj1C_InitData:
                                                      *        objsubdecl 0, Obj1C_MapUnc_11552, make_art_tile(ArtTile_ArtNem_BoltEnd_Rope,2,0), 4, 6
                                                      *        objsubdecl 1, Obj1C_MapUnc_11552, make_art_tile(ArtTile_ArtNem_BoltEnd_Rope,2,0), 4, 6
                                                      *        objsubdecl 1, Obj11_MapUnc_FC70,  make_art_tile(ArtTile_ArtNem_EHZ_Bridge,2,0), 4, 1
                                                      *        objsubdecl 2, Obj1C_MapUnc_11552, make_art_tile(ArtTile_ArtNem_BoltEnd_Rope,1,0), $10, 6
                                                      *        objsubdecl 3, Obj16_MapUnc_21F14, make_art_tile(ArtTile_ArtNem_HtzZipline,2,0), 8, 4
                                                      *        objsubdecl 4, Obj16_MapUnc_21F14, make_art_tile(ArtTile_ArtNem_HtzZipline,2,0), 8, 4
                                                      *        objsubdecl 1, Obj16_MapUnc_21F14, make_art_tile(ArtTile_ArtNem_HtzZipline,2,0), $20, 1
                                                      *        objsubdecl 0, Obj1C_MapUnc_113D6, make_art_tile(ArtTile_ArtKos_LevelArt,2,0), 8, 1
                                                      *        objsubdecl 1, Obj1C_MapUnc_113D6, make_art_tile(ArtTile_ArtKos_LevelArt,2,0), 8, 1
                                                      *        objsubdecl 0, Obj1C_MapUnc_113EE, make_art_tile(ArtTile_ArtUnc_Waterfall3,2,0), 4, 4
                                                      *        objsubdecl 0, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4
                                                      *        objsubdecl 1, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4
                                                      *        objsubdecl 2, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4
                                                      *        objsubdecl 3, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4
                                                      *        objsubdecl 4, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4
                                                      *        objsubdecl 5, Obj1C_MapUnc_11406, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 4, 4
                                                      *        objsubdecl 0, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), $18, 4
                                                      *        objsubdecl 1, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), $18, 4
                                                      *        objsubdecl 2, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 8, 4
                                                      *        objsubdecl 3, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 8, 4
                                                      *        objsubdecl 4, Obj1C_MapUnc_114AE, make_art_tile(ArtTile_ArtNem_Oilfall2,2,0), 8, 4
                                                      *; byte_1128E:
                                                      *Obj1C_Radii:
                                                      *        dc.b   0
                                                      *        dc.b   0        ; 1
                                                      *        dc.b   0        ; 2
                                                      *        dc.b   0        ; 3
                                                      *        dc.b   0        ; 4
                                                      *        dc.b   0        ; 5
                                                      *        dc.b   0        ; 6
                                                      *        dc.b   0        ; 7
                                                      *        dc.b   0        ; 8
                                                      *        dc.b   0        ; 9
                                                      *        dc.b   0        ; 10
                                                      *        dc.b   0        ; 11
                                                      *        dc.b   0        ; 12
                                                      *        dc.b $30        ; 13
                                                      *        dc.b $40        ; 14
                                                      *        dc.b $60        ; 15
                                                      *        dc.b   0        ; 16
                                                      *        dc.b   0        ; 17
                                                      *        dc.b $30        ; 18
                                                      *        dc.b $40        ; 19
                                                      *        dc.b $50        ; 20
                                                      *        dc.b   0        ; 21
                                                      *; ===========================================================================
                                                      *; loc_112A4:
Obj1C_Init                                            *Obj1C_Init:
        inc   routine,u                               *        addq.b  #2,routine(a0)
                                                      *        moveq   #0,d0
                                                      *        move.b  subtype(a0),d0
                                                      *        move.w  d0,d1
                                                      *        lsl.w   #3,d0
                                                      *        lea     Obj1C_InitData(pc),a1
                                                      *        lea     (a1,d0.w),a1
                                                      *        move.b  (a1),mapping_frame(a0)
                                                      *        move.l  (a1)+,mappings(a0)
                                                      *        move.w  (a1)+,art_tile(a0)
        ldd   #Img_EHZ_bridge_stake
        std   image_set,u
                                                      *        bsr.w   Adjust2PArtPointer
        lda   #render_playfieldcoord_mask
        sta   render_flags,u                          *        ori.b   #4,render_flags(a0)
        ldd   #$0201 ; wide-dot factor on a
        sta   width_pixels,u                          *        move.b  (a1)+,width_pixels(a0)
        stb   priority,u                              *        move.b  (a1)+,priority(a0)
                                                      *        lea     Obj1C_Radii(pc),a1
                                                      *        move.b  (a1,d1.w),d1
                                                      *        beq.s   BranchTo_MarkObjGone    ; if the radius is zero, branch
                                                      *        move.b  d1,y_radius(a0)
                                                      *        bset    #4,render_flags(a0)
 ifdef halfline
        ldd   y_pos,u
        addd  #1
        std   y_pos,u ; fix for interlace alignment
 endc
                                                      *
                                                      *BranchTo_MarkObjGone ; BranchTo
        jmp   MarkObjGone                             *        bra.w   MarkObjGone