; ---------------------------------------------------------------------------
; Object - Masher
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

                                                      *; ===========================================================================
                                                      *; ----------------------------------------------------------------------------
                                                      *; Object 5C - Masher (jumping piranha fish badnik) from EHZ
                                                      *; ----------------------------------------------------------------------------
                                                      *; OST Variables:
Obj5C_initial_y_pos equ ext_variables_obj             *Obj5C_initial_y_pos = objoff_30 ; word
                                                      *
                                                      *; Sprite_2D394:
Obj5C                                                 *Obj5C:
                                                      *    moveq   #0,d0
        lda   routine,u                               *    move.b  routine(a0),d0
        asla
        ldx   #Obj5C_Index                            *    move.w  Obj5C_Index(pc,d0.w),d1
        jsr   [a,x]                                   *    jsr Obj5C_Index(pc,d1.w)
        jmp   MarkObjGone                             *    jmpto   (MarkObjGone).l, JmpTo34_MarkObjGone
                                                      *; ===========================================================================
                                                      *; off_2D3A6:
Obj5C_Index                                           *Obj5C_Index:    offsetTable
        fdb   Obj5C_Init                              *        offsetTableEntry.w Obj5C_Init   ; 0
        fdb   Obj5C_Main                              *        offsetTableEntry.w Obj5C_Main   ; 2
                                                      *; ===========================================================================
                                                      *; loc_2D3AA:
Obj5C_Init                                            *Obj5C_Init:
        inc   routine,u                               *    addq.b  #2,routine(a0)
                                                      *    move.l  #Obj5C_MapUnc_2D442,mappings(a0)
                                                      *    move.w  #make_art_tile(ArtTile_ArtNem_Masher,0,0),art_tile(a0)
                                                      *    jsrto   (Adjust2PArtPointer).l, JmpTo58_Adjust2PArtPointer
        lda   #render_playfieldcoord_mask
        sta   render_flags,u                          *    move.b  #4,render_flags(a0)
        ldb   #4
        stb   priority,u                              *    move.b  #4,priority(a0)
        ldd   #$0910
        sta   collision_flags,u                       *    move.b  #9,collision_flags(a0)
        stb   width_pixels,u                          *    move.b  #$10,width_pixels(a0)
        ldd   #-$400
        std   y_vel,u                                 *    move.w  #-$400,y_vel(a0)
        ldd   y_pos,u
        std   Obj5C_initial_y_pos,u                   *    move.w  y_pos(a0),Obj5C_initial_y_pos(a0)   ; set initial (and lowest) y position
        ldd   #MasAni_SlowBite
        std   anim,u ; default anim is 0
                                                      *; loc_2D3E4:
Obj5C_Main                                            *Obj5C_Main:
        ; moved to init                               *    lea (Ani_obj5C).l,a1
        jsr   AnimateSpriteSync                       *    jsrto   (AnimateSprite).l, JmpTo16_AnimateSprite
        jsr   ObjectMoveSync                          *    jsrto   (ObjectMove).l, JmpTo22_ObjectMove
        ldd   y_vel,u
        ldx   Vint_Main_runcount_w
!       addd  #$18
        leax  -1,x
        bne   <
        addd  #$0C
        std   y_vel,u                                 *    addi.w  #$18,y_vel(a0)  ; apply gravity
        ldx   Obj5C_initial_y_pos,u                   *    move.w  Obj5C_initial_y_pos(a0),d0
        cmpx  y_pos,u                                 *    cmp.w   y_pos(a0),d0    ; has object reached its initial y position?
        bhs   >                                       *    bhs.s   +       ; if not, branch
        stx   y_pos,u                                 *    move.w  d0,y_pos(a0)
        ldd   #-$500
        std   y_vel,u                                 *    move.w  #-$500,y_vel(a0)    ; jump
!                                                     *+
        ldd   #MasAni_FastBite
        std   anim,u                                  *    move.b  #1,anim(a0)
        leax  -$C0,x                                  *    subi.w  #$C0,d0
        cmpx  y_pos,u                                 *    cmp.w   y_pos(a0),d0
        bhs   >                                       *    bhs.s   +   ; rts
        ldd   #MasAni_SlowBite
        std   anim,u                                  *    move.b  #0,anim(a0)
        tst   y_vel,u                                 *    tst.w   y_vel(a0)   ; is object falling?
        bmi   >                                       *    bmi.s   +   ; rts   ; if not, branch
        ldd   #MasAni_ClosedJaw
        std   anim,u                                  *    move.b  #2,anim(a0) ; use closed mouth animation
!                                                     *+
        rts                                           *    rts
                                                      *; ===========================================================================
                                                      *; animation script
                                                      *; off_2D430:
        ; there is no jump table in current engine    *Ani_obj5C:  offsetTable
        ; direct use of anim adress                   *        offsetTableEntry.w byte_2D436   ; 0
                                                      *        offsetTableEntry.w byte_2D43A   ; 1
                                                      *        offsetTableEntry.w byte_2D43E   ; 2
                                                      *byte_2D436: dc.b   7,  0,  1,$FF
                                                      *byte_2D43A: dc.b   3,  0,  1,$FF
                                                      *byte_2D43E: dc.b   7,  0,$FF
                                                      *    even
                                                      *; ----------------------------------------------------------------------------
                                                      *; sprite mappings
                                                      *; ----------------------------------------------------------------------------
                                                      *Obj5C_MapUnc_2D442: BINCLUDE "mappings/sprite/obj5C.bin"
                                                      *
                                                      *    if ~~removeJmpTos
                                                      *    align 4
                                                      *    endif
                                                      *; ===========================================================================
                                                      *
                                                      *    if ~~removeJmpTos
                                                      *JmpTo34_MarkObjGone ; JmpTo
                                                      *    jmp (MarkObjGone).l
                                                      *JmpTo16_AnimateSprite ; JmpTo
                                                      *    jmp (AnimateSprite).l
                                                      *JmpTo58_Adjust2PArtPointer ; JmpTo
                                                      *    jmp (Adjust2PArtPointer).l
                                                      *; loc_2D48E:
                                                      *JmpTo22_ObjectMove ; JmpTo
                                                      *    jmp (ObjectMove).l
                                                      *
                                                      *    align 4
                                                      *    endif