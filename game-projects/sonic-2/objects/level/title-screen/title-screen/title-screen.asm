; ---------------------------------------------------------------------------
; Object - TitleScreen
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Sonic 2 - Notes
; ---------------
;
; Palettes
; --------
; 4x pal of 16 colors (first is transparent)
; init state:
;    Pal1 - LargeStar, Tails
;    Pal0,2,3 - Black
;
; sequence of TitleScreen :
;    Pal3 - fade in - Emblem
;    Pal0 - set - Sonic
;    Pal2 - set - White
;    Pal2 - fade in - Background
;
; Colors
; ------
; Genesis/Megadrive: 8 values for each component (BGR) 0, 2, 4, 6, 8, A, C, E
; RGB space values: 0, 0x24, 0x49, 0x6D, 0x92, 0xB6, 0xDB, 0xFF
;
; Display position
; ----------------
; Horizontal
; - the sprite H position is between 0 and 511 but the display area is from 128 to 383 in H32 mode and 128 to 447 in H40 mode
; Vertical Non-interlace
; - the sprite V position is between 0 and 511 but the display area is from 128 to 351 in V28 mode and 128 to 367 in V30 mode
;
; conversion :
; x=((x-128)/2)+48
; y=y-140+28-1
;
; center : #$807F
; top left : #$301C
; bottom right : #$CFE3
;
; Display priority (VDP)
; ----------------------
; Background
;  |  backdrop color => Blue
;  |  low priority plane B tiles => Island
;  |  low priority plane A tiles
;  |  low priority sprites  => from top to bottom : center of Emblem Top, Sky piece (4x 8x32) link 8, 9, 10, 11 xpos 4,0,4,0 ypos 240,240,272,272
;  |  high priority plane B tiles
;  |  high priority plane A tiles => Emblem
; \./ high priority sprites => from top to bottom: left and right of Emblem Top, Sonic, Tails
; Foreground
;
; TitleScreen_Loop (s2.asm) set "horizontal position" alternatively to 0 and 4
; on all VDP sprites that have : priority = 0, hflip = 0, vflip = 0 and tileart < $80
;
; One VDP funtion is that when a sprite is x = 0, all horizontal lines that are occupied by this sprite
; are no more refreshed with the content of lower priority sprites (Sprite_Table).
; This is used to mask Sonic and Tails behind the emblem.
; Another sprite is used to mask the upper part of the emblem (non linear shape.
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/engine/sfx/raster-fade/raster-fade.idx"
        INCLUDE "./objects/engine/sfx/palette-fade/palette-fade.idx"



* ---------------------------------------------------------------------------
* Object Status Table offsets
* - two variables can share same space if used by two different subtypes
* - take care of words and bytes and space them accordingly
* ---------------------------------------------------------------------------
w_TitleScr_time_frame_count     equ ext_variables
w_TitleScr_time_frame_countdown equ ext_variables+2
w_TitleScr_move_frame_count     equ ext_variables+2
w_TitleScr_xy_data_index        equ ext_variables+4
b_TitleScr_final_state          equ ext_variables+6
b_TitleScr_music_is_playing     equ ext_variables+7
b_TitleScr_ripple_index         equ ext_variables
b_TitleScr_water_index          equ ext_variables+1
b_TitleScr_time_frame_count     equ ext_variables+2
b_TitleScr_pressed              equ ext_variables+2

* ---------------------------------------------------------------------------
* Subtypes
* ---------------------------------------------------------------------------
Sub_Init        equ 0
Sub_Sonic       equ 1
Sub_Tails       equ 2
Sub_EmblemFront equ 3
Sub_EmblemBack  equ 4
Sub_LargeStar   equ 5
Sub_SonicHand   equ 6
Sub_SmallStar   equ 7
Sub_TailsHand   equ 8
Sub_Island      equ 9
Sub_IslandWater equ 10
Sub_IslandMask  equ 11
Sub_PressStart  equ 12

* ***************************************************************************
* TitleScreen
* ***************************************************************************

                                                 *; ----------------------------------------------------------------------------
                                                 *; Object 0E - Flashing stars from intro
                                                 *; ----------------------------------------------------------------------------
                                                 *; Sprite_12E18:
TitleScreen                                      *Obj0E:
                                                 *        moveq   #0,d0
        lda   routine,u                          *        move.b  routine(a0),d0
        asla
        ldx   #TitleScreen_Routines              *        move.w  Obj0E_Index(pc,d0.w),d1
        jmp   [a,x]                              *        jmp     Obj0E_Index(pc,d1.w)
                                                 *; ===========================================================================
                                                 *; off_12E26: Obj0E_States:
TitleScreen_Routines                             *Obj0E_Index:    offsetTable
        fdb   Init                               *                offsetTableEntry.w Obj0E_Init   ;   0
        fdb   Sonic                              *                offsetTableEntry.w Obj0E_Sonic  ;   2
        fdb   Tails                              *                offsetTableEntry.w Obj0E_Tails  ;   4
        fdb   EmblemFront                        *                offsetTableEntry.w Obj0E_LogoTop        ;   6
        fdb   EmblemBack
        fdb   LargeStar                          *                offsetTableEntry.w Obj0E_LargeStar      ;   8
        fdb   SonicHand                          *                offsetTableEntry.w Obj0E_SonicHand      ;  $A
        fdb   SmallStar                          *                offsetTableEntry.w Obj0E_SmallStar      ;  $C
                                                 *                offsetTableEntry.w Obj0E_SkyPiece       ;  $E
        fdb   TailsHand                          *                offsetTableEntry.w Obj0E_TailsHand      ; $10
        fdb   Island
        fdb   IslandWater
        fdb   IslandMask
        fdb   PressStart
                                                 *; ===========================================================================
                                                 *; loc_12E38:
Init                                             *Obj0E_Init:
        * vdp unused                             *        addq.b  #2,routine(a0)  ; useless, because it's overwritten with the subtype below
        * vdp unused                             *        move.l  #Obj0E_MapUnc_136A8,mappings(a0)
        * vdp unused                             *        move.w  #make_art_tile(ArtTile_ArtNem_TitleSprites,0,0),art_tile(a0)
        
        lda   #4                                 *        move.b  #4,priority(a0)
        sta   priority,u
        lda   subtype,u                          *        move.b  subtype(a0),routine(a0)
        sta   routine,u
        bra   TitleScreen                        *        bra.s   Obj0E
                                                 *; ===========================================================================

* ---------------------------------------------------------------------------
* Sonic
* ---------------------------------------------------------------------------

                                                 *
Sonic                                            *Obj0E_Sonic:
        ldd   w_TitleScr_time_frame_count,u
        addd  #1                                 *        addq.w  #1,objoff_34(a0)
        std   w_TitleScr_time_frame_count,u
        cmpd  #$120                              *        cmpi.w  #$120,objoff_34(a0)
        bhs   Sonic_NotFinalState                *        bhs.s   +
        *lbsr  TitleScreen_SetFinalState         *        bsr.w   TitleScreen_SetFinalState
Sonic_NotFinalState                              *+
                                                 *        moveq   #0,d0
        lda   routine_secondary,u                *        move.b  routine_secondary(a0),d0
        asla
        ldx   #Sonic_Routines                    *        move.w  off_12E76(pc,d0.w),d1
        jmp   [a,x]                              *        jmp     off_12E76(pc,d1.w)
                                                 *; ===========================================================================
Sonic_Routines                                   *off_12E76:      offsetTable
        fdb   Sonic_Init                         *                offsetTableEntry.w Obj0E_Sonic_Init     ;   0
        fdb   Sonic_PaletteFade                  *                offsetTableEntry.w loc_12EC2    ;   2
        fdb   Sonic_SetPal_TitleScreen           *                offsetTableEntry.w loc_12EE8    ;   4
        fdb   Sonic_Move                         *                offsetTableEntry.w loc_12F18    ;   6
        fdb   TitleScreen_Animate                *                offsetTableEntry.w loc_12F52    ;   8
        fdb   Sonic_CreateHand                   *                offsetTableEntry.w Obj0E_Sonic_LastFrame        ;  $A
        fdb   Sonic_CreateTails                  *                offsetTableEntry.w loc_12F7C    ;  $C
        fdb   Sonic_FadeInBackground             *                offsetTableEntry.w loc_12F9A    ;  $E
        fdb   Sonic_CreateSmallStar              *                offsetTableEntry.w loc_12FD6    ; $10
        fdb   Sonic_Display                      *                offsetTableEntry.w loc_13014    ; $12
                                                 *; ===========================================================================
                                                 *; spawn more stars
Sonic_Init                                       *Obj0E_Sonic_Init:

        ldd   #Pal_TitleScreen
        std   Pal_current
        clr   PalRefresh                         * will call refresh palette after next VBL

        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        ldd   #Img_sonic_1
        std   image_set,u                        *        move.b  #5,mapping_frame(a0)
        ldd   #Ani_sonic                         ; in original code, anim is an index in offset table (1 byte) that is implicitly initialized to 0
        std   anim,u                             ; so added init code to anim address here because it is not an index anymore
        * sonic est invisible a cette position mais depasse en bas on le positionne donc hors cadre
        ldd   #$0000
        std   xy_pixel,u                         *        move.w  #$110,x_pixel(a0)
                                                 *        move.w  #$E0,y_pixel(a0)
        jsr   LoadObject_x
        stx   Obj_LargeStar                     *        lea     (IntroLargeStar).w,a1
        lda   #ObjID_TitleScreen
        sta   id,x                               *        move.b  #ObjID_IntroStars,id(a1) ; load obj0E (flashing intro stars) at $FFFFB0C0
        ldb   #Sub_LargeStar
        stb   subtype,x                          *        move.b  #8,subtype(a1)                          ; large star

        * moved to Sonic_PaletteFadeAfterWait    *        lea     (IntroEmblemTop).w,a1
                                                 *        move.b  #ObjID_IntroStars,id(a1) ; load obj0E (flashing intro stars) at $FFFFD140
        ldd   #UserIRQ_Pal_Smps
        std   Irq_user_routine
                                                 *        move.b  #6,subtype(a1)                          ; logo top
        ldx   #Smps_Sparkle                      *        moveq   #SndID_Sparkle,d0
        stx   Smps.SFXToPlay        
        rts                                      *        jmpto   (PlaySound).l, JmpTo4_PlaySound
                                                 *; ===========================================================================
                                                 *
Sonic_PaletteFade                                *loc_12EC2:
        ldd   w_TitleScr_time_frame_count,u
        cmpd  #$38                               *        cmpi.w  #$38,objoff_34(a0)
        bhs   Sonic_PaletteFadeAfterWait         *        bhs.s   +
        rts                                      *        rts
                                                 *; ===========================================================================
Sonic_PaletteFadeAfterWait                       *+
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)

        * Create emblem tiles
        jsr   LoadObject_x
        stx   Obj_EmblemFront01
        lda   #ObjID_TitleScreen
        
        ldb   #Sub_EmblemFront
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemFront01
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemFront02
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemFront02
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemFront03
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemFront03
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemFront04
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemFront04
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemFront05
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemFront05
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemFront06
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemFront06
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemFront07
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemFront07
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemFront08
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemFront08
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack01
        ldb   #Sub_EmblemBack
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack01
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack02
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack02
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack03
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack03
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack04
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack04
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack05
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack05
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack06
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack06
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack07
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack07
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack08
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack08
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_EmblemBack09
        sta   id,x
        stb   subtype,x
        ldy   #Img_emblemBack09
        sty   image_set,x

        jsr   LoadObject_x
        stx   Obj_PaletteFade                   *        lea     (TitleScreenPaletteChanger3).w,a1
        lda   #ObjID_PaletteFade
        sta   id,x                               *        move.b  #ObjID_TtlScrPalChanger,id(a1) ; load objC9 (palette change)
        clr   subtype,x                          *        move.b  #0,subtype(a1)
        ldd   #Pal_black
        std   _src,x
        ldd   #Pal_TitleScreen
        std   _dst,x
        lda   #$FF
        sta   b_TitleScr_music_is_playing,u      *        st.b    objoff_30(a0)
        ldx   #Smps_TitleScreen                  *        moveq   #MusID_Title,d0 ; title music
        jmp   PlayMusic                          *        jmpto   (PlayMusic).l, JmpTo4_PlayMusic
                                                 *; ===========================================================================
                                                 *
Sonic_SetPal_TitleScreen                         *loc_12EE8:
        ldd   w_TitleScr_time_frame_count,u
        cmpd  #$70                               *        cmpi.w  #$80,objoff_34(a0)
        bhs   Sonic_SetPal_TitleScreenAfterWait  *        bhs.s   +
        rts                                      *        rts
                                                 *; ===========================================================================
Sonic_SetPal_TitleScreenAfterWait                *+
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)

        *ldd   #Pal_TitleScreen                  *        lea     (Pal_133EC).l,a1
        *std   Pal_current                       *        lea     (Normal_palette).w,a2
                                                 *
        * not implemented                        *        moveq   #$F,d6
        * switch pointer to                      *-       move.w  (a1)+,(a2)+
        * fixed palette instead of copying data  *        dbf     d6,-
                                                 *
                                                 *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                 *
                                                 *
        * not implemented                        *sub_12F08:
        * not implemented                        *        lea     (IntroSmallStar1).w,a1
        * not implemented
        * not implemented                        *        move.b  #ObjID_IntroStars,id(a1) ; load obj0E (flashing intro star) at $FFFFB180
        * not implemented
        * not implemented                        *        move.b  #$E,subtype(a1)                         ; piece of sky
        rts                                      *        rts
                                                 *; End of function sub_12F08
                                                 *
                                                 *; ===========================================================================
                                                 *
Sonic_Move                                       *loc_12F18:
        ldx   #Sonic_xy_data_end-Sonic_xy_data+2
        stx   dyn_01+2                           *        moveq   #word_13046_end-word_13046+4,d2
        ldx   #Sonic_xy_data-2                   *        lea     (word_13046).l,a1
                                                 *
TitleScreen_MoveObjects                          *loc_12F20:
        ldd   w_TitleScr_move_frame_count,u      *        move.w  objoff_2A(a0),d0
        addd  #1                                 *        addq.w  #1,d0
        std   w_TitleScr_move_frame_count,u      *        move.w  d0,objoff_2A(a0)
        *andb  #3 * means one frame on four       *        andi.w  #3,d0
        *bne   MoveObjects_KeepPosition           *        bne.s   +
        ldd   w_TitleScr_xy_data_index,u         *        move.w  objoff_2C(a0),d1
        addd  #2                                 *        addq.w  #4,d1
dyn_01
        cmpd  #$0000                             *        cmp.w   d2,d1
        lbhs  TitleScreen_NextSubRoutineAndDisplay
                                                 *        bhs.w   loc_1310A
        std   w_TitleScr_xy_data_index,u         *        move.w  d1,objoff_2C(a0)
        leax  d,x                                *        move.l  -4(a1,d1.w),d0
        ldd   ,x                                 *        move.w  d0,y_pixel(a0)
        std   xy_pixel,u
                                                 *        swap    d0
                                                 *        move.w  d0,x_pixel(a0)

MoveObjects_KeepPosition                         *+
        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *
TitleScreen_Animate                              *loc_12F52:
        * no more offset table                   *        lea     (Ani_obj0E).l,a1
        jsr   AnimateSprite                      *        bsr.w   AnimateSprite
        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *
Sonic_CreateHand                                 *Obj0E_Sonic_LastFrame:
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        ldd   #Img_sonic_5
        std   image_set,u                        *        move.b  #$12,mapping_frame(a0)
        jsr   LoadObject_x
        stx   Obj_SonicHand                     *        lea     (IntroSonicHand).w,a1
        lda   #ObjID_TitleScreen
        sta   id,x                               *        move.b  #ObjID_IntroStars,id(a1) ; load obj0E (flashing intro star) at $FFFFB1C0
        lda   #Sub_SonicHand
        sta   subtype,x                          *        move.b  #$A,subtype(a1)                         ; Sonic's hand

        * Change sprite to overlay
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *
Sonic_CreateTails                                *loc_12F7C:
        ldd   w_TitleScr_time_frame_count,u
        cmpd  #$90 ; was $C0                     *        cmpi.w  #$C0,objoff_34(a0)
        blo   Sonic_CreateTails_BeforeWait       *        blo.s   +
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        jsr   LoadObject_x
        stx   Obj_Tails                         *        lea     (IntroTails).w,a1
        lda   #ObjID_TitleScreen
        sta   id,x                               *        move.b  #ObjID_IntroStars,id(a1) ; load obj0E (flashing intro star) at $FFFFB080
        lda   #Sub_Tails
        sta   subtype,x                          *        move.b  #4,subtype(a1)                          ; Tails
Sonic_CreateTails_BeforeWait                     *+
        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *
Sonic_FadeInBackground                           *loc_12F9A:
        ldd   w_TitleScr_time_frame_count,u
        cmpd  #$C0 ; was $120                    *        cmpi.w  #$120,objoff_34(a0)
        blo   Sonic_FadeInBackground_NotYet      *        blo.s   +
        bhi   Sonic_FadeInBackground_Continue
                                                 *        addq.b  #2,routine_secondary(a0)
        ldd   #$0000
        std   w_TitleScr_xy_data_index,u         *        clr.w   objoff_2C(a0)
        ldd   #$FF
        std   b_TitleScr_final_state,u           *        st      objoff_2F(a0)

        jsr   LoadObject_x
        stx   Obj_RasterFade
        lda   #ObjID_RasterFade
        sta   id,x
        lda   #Sub_RasterFadeInColor
        sta   subtype,x
        lda   #PalID_TitleScreenRaster
        sta   raster_pal_dst,x
        ldd   #$0fff
        std   raster_color,x
        ldd   #$103a
        sta   raster_cycles,x
        stb   raster_nb_fade_colors,x            * 58 lines to fade
        ldd   #$0148
        sta   raster_inc,x
        sta   raster_frames,x
        stb   raster_nb_colors,x                 * 72 total lines
                                                 *        lea     (Normal_palette_line3).w,a1
                                                 *        move.w  #$EEE,d0
                                                 *
                                                 *        moveq   #$F,d6
                                                 *-       move.w  d0,(a1)+
                                                 *        dbf     d6,-
                                                 *
                                                 *        lea     (TitleScreenPaletteChanger2).w,a1
                                                 *        move.b  #ObjID_TtlScrPalChanger,id(a1) ; load objC9 (palette change handler) at $FFFFB240

                                                 *        move.b  #2,subtype(a1)
        * not implemented                        *        move.b  #ObjID_TitleMenu,(TitleScreenMenu+id).w ; load Obj0F (title screen menu) at $FFFFB400
Sonic_FadeInBackground_NotYet                    *+
        jmp   DisplaySprite                      *        bra.w   DisplaySprite

Sonic_FadeInBackground_Continue
        lda   #139                               ; screen line to sync
        ldx   #Irq_one_frame                     ; on every frame
        jsr   IrqSync
        ldd   #UserIRQ_Raster_Smps
        std   Irq_user_routine

        jsr   LoadObject_x
        stx   Obj_Island
        lda   #ObjID_TitleScreen
        sta   id,x
        lda   #Sub_Island
        sta   subtype,x
        inc   routine_secondary,u
        rts
                                                 *; ===========================================================================
                                                 *
Sonic_CreateSmallStar                            *loc_12FD6:
        * not implemented                        *        btst    #6,(Graphics_Flags).w ; is Megadrive PAL?
        * not implemented                        *        beq.s   + ; if not, branch
        ldd   w_TitleScr_time_frame_count,u
        cmpd  #$C8 ; was $190                    *        cmpi.w  #$190,objoff_34(a0)
        beq   Sonic_CreateSmallStar_AfterWait    *        beq.s   ++
        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *+
        * not implemented                        *        cmpi.w  #$1D0,objoff_34(a0)
        * not implemented                        *        beq.s   +
        * not implemented                        *        bra.w   DisplaySprite
                                                 *; ===========================================================================
Sonic_CreateSmallStar_AfterWait                  *+
        jsr   LoadObject_x
        stx   Obj_SmallStar                     *        lea     (IntroSmallStar2).w,a1
        lda   #ObjID_TitleScreen
        sta   id,x                               *        move.b  #ObjID_IntroStars,id(a1) ; load obj0E (flashing intro star) at $FFFFB440
        lda   #Sub_SmallStar
        sta   subtype,x                          *        move.b  #$C,subtype(a1)                         ; small star
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        * not implemented                        *        lea     (IntroSmallStar1).w,a1
        * not implemented                        *        bsr.w   DeleteObject2 ; delete object at $FFFFB180
Sonic_Display
        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *
        * cycling pal is in RasterFade           *loc_13014:
                                                 *        move.b  (Vint_runcount+3).w,d0
                                                 *        andi.b  #7,d0
                                                 *        bne.s   ++
                                                 *        move.w  objoff_2C(a0),d0
                                                 *        addq.w  #2,d0
                                                 *        cmpi.w  #CyclingPal_TitleStar_End-CyclingPal_TitleStar,d0
                                                 *        blo.s   +
                                                 *        moveq   #0,d0
                                                 *+
                                                 *        move.w  d0,objoff_2C(a0)
                                                 *        move.w  CyclingPal_TitleStar(pc,d0.w),(Normal_palette_line3+$A).w
                                                 *+
                                                 *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *; word_1303A:
                                                 *CyclingPal_TitleStar:
                                                 *        binclude "art/palettes/Title Star Cycle.bin"
                                                 * ;$0E64
                                                 * ;$0E86
                                                 * ;$0E64
                                                 * ;$0EA8
                                                 * ;$0E64
                                                 * ;$0ECA
                                                 *CyclingPal_TitleStar_End
                                                 *
Sonic_xy_data                                    *word_13046:
        fcb   $74,$5F                            *        dc.w  $108, $D0
        fcb   $70,$4F                            *        dc.w  $100, $C0 ; 2
        fcb   $6C,$3F                            *        dc.w   $F8, $B0 ; 4
        fcb   $6B,$35                            *        dc.w   $F6, $A6 ; 6
        fcb   $6D,$2D                            *        dc.w   $FA, $9E ; 8
        fcb   $70,$29                            *        dc.w  $100, $9A ; $A
        fcb   $72,$28                            *        dc.w  $104, $99 ; $C
        fcb   $74,$27                            *        dc.w  $108, $98 ; $E
Sonic_xy_data_end                                *word_13046_end
                                                 *; ===========================================================================

* ---------------------------------------------------------------------------
* Tails
* ---------------------------------------------------------------------------

                                                 *
Tails                                            *Obj0E_Tails:
                                                 *        moveq   #0,d0
        lda   routine_secondary,u                *        move.b  routine_secondary(a0),d0
        asla
        ldx   #Tails_Routines                    *        move.w  off_13074(pc,d0.w),d1
        jmp   [a,x]                              *        jmp     off_13074(pc,d1.w)
                                                 *; ===========================================================================
Tails_Routines                                   *off_13074:      offsetTable
        fdb   Tails_Init                         *                offsetTableEntry.w Obj0E_Tails_Init                     ; 0
        fdb   Tails_Move                         *                offsetTableEntry.w loc_13096                    ; 2
        fdb   TitleScreen_Animate                *                offsetTableEntry.w loc_12F52                    ; 4
        fdb   Tails_CreateHand                   *                offsetTableEntry.w loc_130A2                    ; 6
        fdb   Tails_DisplaySprite                *                offsetTableEntry.w BranchTo10_DisplaySprite     ; 8
                                                 *; ===========================================================================
                                                 *
Tails_Init                                       *Obj0E_Tails_Init:
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        ldd   #$5C67
        std   xy_pixel,u                         *        move.w  #$D8,x_pixel(a0)
                                                 *        move.w  #$D8,y_pixel(a0)
        ldb   #$05
        stb   priority,u
        ldd   #Ani_tails
        std   anim,u                             *        move.b  #1,anim(a0)
        ldd   #Img_tails_1                       ; in original code, mapping_frame is an index in offset table (1 byte) that is implicitly initialized to 0
        std   image_set,u                     ; so added init code to mapping_frame address here because it is not an index anymore
        rts                                      *        rts
                                                 *; ===========================================================================
                                                 *
Tails_Move                                       *loc_13096:
        ldx   #Tails_xy_data_end-Tails_xy_data+2
        stx   dyn_01+2                           *        moveq   #word_130B8_end-word_130B8+4,d2
        ldx   #Tails_xy_data-2                   *        lea     (word_130B8).l,a1
        jmp   TitleScreen_MoveObjects            *        bra.w   loc_12F20
                                                 *; ===========================================================================
                                                 *
Tails_CreateHand                                 *loc_130A2:
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        jsr   LoadObject_x
        stx   Obj_TailsHand                     *        lea     (IntroTailsHand).w,a1
        lda   #ObjID_TitleScreen                 *        move.b  #ObjID_IntroStars,id(a1) ; load obj0E (flashing intro star) at $FFFFB200
        sta   id,x
        lda   #Sub_TailsHand
        sta   subtype,x                          *        move.b  #$10,subtype(a1)                        ; Tails' hand

        * Change sprite to overlay
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

                                                 *
Tails_DisplaySprite                              *BranchTo10_DisplaySprite
        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
Tails_xy_data                                    *word_130B8:
        fcb   $5B,$57                            *        dc.w   $D7,$C8
        fcb   $59,$47                            *        dc.w   $D3,$B8  ; 2
        fcb   $57,$3B                            *        dc.w   $CE,$AC  ; 4
        fcb   $56,$35                            *        dc.w   $CC,$A6  ; 6
        fcb   $55,$31                            *        dc.w   $CA,$A2  ; 8
        fcb   $54,$30                            *        dc.w   $C9,$A1  ; $A
        fcb   $54,$2F                            *        dc.w   $C8,$A0  ; $C
Tails_xy_data_end                                *word_130B8_end
                                                 *; ===========================================================================

* ---------------------------------------------------------------------------
* EmblemFront
* ---------------------------------------------------------------------------

                                                 *
EmblemFront                                      *Obj0E_LogoTop:
                                                 *        moveq   #0,d0
        lda   routine_secondary,u                *        move.b  routine_secondary(a0),d0
        asla
        ldx   #EmblemFront_Routines              *        move.w  off_130E2(pc,d0.w),d1
        jmp   [a,x]                              *        jmp     off_130E2(pc,d1.w)
                                                 *; ===========================================================================
EmblemFront_Routines                             *off_130E2:      offsetTable
        fdb   EmblemFront_Init                   *                offsetTableEntry.w Obj0E_LogoTop_Init                   ; 0
        fdb   TitleScreen_NextSubRoutineAndDisplay
        fdb   EmblemFront_DisplaySprite          *                offsetTableEntry.w BranchTo11_DisplaySprite     ; 2
                                                 *; ===========================================================================
                                                 *
EmblemFront_Init                                 *Obj0E_LogoTop_Init:
        * not implemented                        *        move.b  #$B,mapping_frame(a0)
        * trademark logo for PAL                 *        tst.b   (Graphics_Flags).w
        * game version                           *        bmi.s   +
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        * initialized in object creation         *        move.b  #$A,mapping_frame(a0)
                                                 *+
        ldb   #$02
        stb   priority,u                         *        move.b  #2,priority(a0)
        ldd   #$807F
        std   xy_pixel,u                         *        move.w  #$120,x_pixel(a0)
                                                 *        move.w  #$E8,y_pixel(a0)
                                                 *
TitleScreen_NextSubRoutineAndDisplay             *loc_1310A:
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
                                                 *
                                                 *BranchTo11_DisplaySprite
        jmp   DisplaySprite                      *        bra.w   DisplaySprite

EmblemFront_DisplaySprite
        * Overlay sprite will never change priority, this code is faster than calling DisplaySprite
        * We just need to call DisplaySprite two times (one for each buffer)
        lda   render_flags,u
        anda  #^render_hide_mask
        sta   render_flags,u
        rts
                                                 *; ===========================================================================

* ---------------------------------------------------------------------------
* EmblemBack
* ---------------------------------------------------------------------------

EmblemBack
        lda   routine_secondary,u
        asla
        ldx   #EmblemBack_Routines
        jmp   [a,x]

EmblemBack_Routines
        fdb   EmblemBack_Init
        fdb   TitleScreen_NextSubRoutineAndDisplay
        fdb   EmblemFront_DisplaySprite

EmblemBack_Init
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        ldb   #$06
        stb   priority,u
        ldd   #$807F
        std   xy_pixel,u
        bra   TitleScreen_NextSubRoutineAndDisplay

* ---------------------------------------------------------------------------
* Sky Piece
* - use a VDP functionality that hide lines of lower priority
*   sprites, when a higher priority sprite is at x=0 position
* ---------------------------------------------------------------------------

                                                 *
        * not implemented                        *Obj0E_SkyPiece:
        * not implemented                        *        moveq   #0,d0
        * not implemented                        *        move.b  routine_secondary(a0),d0
        * not implemented                        *        move.w  off_13120(pc,d0.w),d1
        * not implemented                        *        jmp     off_13120(pc,d1.w)
        * not implemented                        *; ===========================================================================
        * not implemented                        *off_13120:      offsetTable
        * not implemented                        *                offsetTableEntry.w Obj0E_SkyPiece_Init                  ; 0
        * not implemented                        *                offsetTableEntry.w BranchTo12_DisplaySprite     ; 2
        * not implemented                        *; ===========================================================================
        * not implemented                        *
        * not implemented                        *Obj0E_SkyPiece_Init:
        * not implemented
        * not implemented                        *        addq.b  #2,routine_secondary(a0)
        * not implemented                        *        move.w  #make_art_tile(ArtTile_ArtKos_LevelArt,0,0),art_tile(a0)
        * not implemented
        * not implemented                        *        move.b  #$11,mapping_frame(a0)
        * not implemented                        *        move.b  #2,priority(a0)
        * not implemented                        *        move.w  #$100,x_pixel(a0)
        * not implemented                        *        move.w  #$F0,y_pixel(a0)
        * not implemented                        *
        * not implemented                        *BranchTo12_DisplaySprite
        * not implemented                        *        bra.w   DisplaySprite
        * not implemented                        *; ===========================================================================

* ---------------------------------------------------------------------------
* Large Star
* ---------------------------------------------------------------------------

                                                 *
LargeStar                                        *Obj0E_LargeStar:
                                                 *        moveq   #0,d0
        lda   routine_secondary,u                *        move.b  routine_secondary(a0),d0
        asla
        ldx   #LargeStar_Routines                *        move.w  off_13158(pc,d0.w),d1
        jmp   [a,x]                              *        jmp     off_13158(pc,d1.w)
                                                 *; ===========================================================================
LargeStar_Routines                               *off_13158:      offsetTable
        fdb   LargeStar_Init                     *                offsetTableEntry.w Obj0E_LargeStar_Init ; 0
        fdb   TitleScreen_Animate                *                offsetTableEntry.w loc_12F52    ; 2
        fdb   LargeStar_Wait                     *                offsetTableEntry.w loc_13190    ; 4
        fdb   LargeStar_Move                     *                offsetTableEntry.w loc_1319E    ; 6
                                                 *; ===========================================================================
                                                 *
LargeStar_Init                                   *Obj0E_LargeStar_Init:
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        ldd   #Img_star_2
        std   image_set,u                        *        move.b  #$C,mapping_frame(a0)
        * not implemented                        *        ori.w   #high_priority,art_tile(a0)
        ldd   #Ani_largeStar
        std   anim,u                             *        move.b  #2,anim(a0)
        ldb   #$01
        stb   priority,u                         *        move.b  #1,priority(a0)
        ldd   #$7037
        std   xy_pixel,u                         *        move.w  #$100,x_pixel(a0)
                                                 *        move.w  #$A8,y_pixel(a0)
        ldd   #4
        std   w_TitleScr_move_frame_count,u      *        move.w  #4,objoff_2A(a0)
        rts                                      *        rts
                                                 *; ===========================================================================
                                                 *
LargeStar_Wait                                   *loc_13190:
        ldd   w_TitleScr_move_frame_count,u
        subd  #1                                 *        subq.w  #1,objoff_2A(a0)
        std   w_TitleScr_move_frame_count,u
        bmi   LargeStar_AfterWait                *        bmi.s   +
        rts                                      *        rts
                                                 *; ===========================================================================
LargeStar_AfterWait                              *+
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        rts                                      *        rts
                                                 *; ===========================================================================
                                                 *
LargeStar_Move                                   *loc_1319E:
        ldd   #$0100
        sta   routine_secondary,u                *        move.b  #2,routine_secondary(a0)
        stb   anim_frame,u                       *        move.b  #0,anim_frame(a0)
        stb   anim_frame_duration,u              *        move.b  #0,anim_frame_duration(a0)
        ldd   #6
        std   w_TitleScr_move_frame_count,u      *        move.w  #6,objoff_2A(a0)
        ldd   w_TitleScr_xy_data_index,u         *        move.w  objoff_2C(a0),d0
        addd  #2                                 *        addq.w  #4,d0
        cmpd  #LargeStar_xy_data_end-LargeStar_xy_data
                                                 *        cmpi.w  #word_131DC_end-word_131DC+4,d0
        blo   LargeStar_MoveContinue
        jmp   DeleteObject                       *        bhs.w   DeleteObject
LargeStar_MoveContinue
        std   w_TitleScr_xy_data_index,u                    *        move.w  d0,objoff_2C(a0)
        ldx   #LargeStar_xy_data-2    
        leax  d,x                                *        move.l  word_131DC-4(pc,d0.w),d0
        ldd   ,x
        std   xy_pixel,u                         *        move.w  d0,y_pixel(a0)
                                                 *        swap    d0
                                                 *        move.w  d0,x_pixel(a0)
        ldx   #Smps_Sparkle                      *        moveq   #SndID_Sparkle,d0 ; play intro sparkle sound
        stx   Smps.SFXToPlay
        rts                                      *        jmpto   (PlaySound).l, JmpTo4_PlaySound
                                                 *; ===========================================================================
                                                 *; unknown
LargeStar_xy_data                                *word_131DC:
        fcb   $5D,$81                            *        dc.w   $DA, $F2
        fcb   $A8,$87                            *        dc.w  $170, $F8 ; 2
        fcb   $89,$C0                            *        dc.w  $132,$131 ; 4
        fcb   $BF,$31                            *        dc.w  $19E, $A2 ; 6
        fcb   $50,$72                            *        dc.w   $C0, $E3 ; 8
        fcb   $B0,$6F                            *        dc.w  $180, $E0 ; $A
        fcb   $76,$CA                            *        dc.w  $10D,$13B ; $C
        fcb   $50,$3A                            *        dc.w   $C0, $AB ; $E
        fcb   $A2,$96                            *        dc.w  $165, $107        ; $10
LargeStar_xy_data_end                            *word_131DC_end
                                                 *; ===========================================================================

* ---------------------------------------------------------------------------
* Sonic Hand
* ---------------------------------------------------------------------------

                                                 *
SonicHand                                        *Obj0E_SonicHand:
                                                 *        moveq   #0,d0
        lda   routine_secondary,u                *        move.b  routine_secondary(a0),d0
        asla
        ldx   #SonicHand_Routines                *        move.w  off_1320E(pc,d0.w),d1
        jmp   [a,x]                              *        jmp     off_1320E(pc,d1.w)
                                                 *; ===========================================================================
SonicHand_Routines                               *off_1320E:      offsetTable
        fdb   SonicHand_Init                     *                offsetTableEntry.w Obj0E_SonicHand_Init                 ; 0
        fdb   SonicHand_Move                     *                offsetTableEntry.w loc_13234                    ; 2
        fdb   SonicHand_DisplaySprite            *                offsetTableEntry.w BranchTo13_DisplaySprite     ; 4
                                                 *; ===========================================================================
                                                 *
SonicHand_Init                                   *Obj0E_SonicHand_Init:
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        ldd   #Img_sonicHand
        std   image_set,u                        *        move.b  #9,mapping_frame(a0)
        lda   #3
        sta   priority,u                         *        move.b  #3,priority(a0)
        ldd   #$924E
        std   xy_pixel,u                         *        move.w  #$145,x_pixel(a0)
                                                 *        move.w  #$BF,y_pixel(a0)
                                                 *
        jmp   DisplaySprite

SonicHand_DisplaySprite                          *BranchTo13_DisplaySprite
        * Change sprite to overlay
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *
SonicHand_Move                                   *loc_13234:
        ldx   #SonicHand_xy_data_end-SonicHand_xy_data+2
        stx   dyn_01+2                           *        moveq   #word_13240_end-word_13240+4,d2
        ldx   #SonicHand_xy_data-2               *        lea     (word_13240).l,a1
        jmp   TitleScreen_MoveObjects            *        bra.w   loc_12F20
                                                 *; ===========================================================================
SonicHand_xy_data                                *word_13240:
        fcb   $91,$50                            *        dc.w  $143, $C1
        fcb   $90,$51                            *        dc.w  $140, $C2 ; 2
        fcb   $90,$50                            *        dc.w  $141, $C1 ; 4
SonicHand_xy_data_end                            *word_13240_end
                                                 *; ===========================================================================

* ---------------------------------------------------------------------------
* Tails Hand
* ---------------------------------------------------------------------------

                                                 *
TailsHand                                        *Obj0E_TailsHand:
                                                 *        moveq   #0,d0
        lda   routine_secondary,u                *        move.b  routine_secondary(a0),d0
        asla
        ldx   #TailsHand_Routines                *        move.w  off_1325A(pc,d0.w),d1
        jmp   [a,x]                              *        jmp     off_1325A(pc,d1.w)
                                                 *; ===========================================================================
TailsHand_Routines                               *off_1325A:      offsetTable
        fdb   TailsHand_Init                     *                offsetTableEntry.w Obj0E_TailsHand_Init                 ; 0
        fdb   TailsHand_Move                     *                offsetTableEntry.w loc_13280                    ; 2
        fdb   TailsHand_DisplaySprite            *                offsetTableEntry.w BranchTo14_DisplaySprite     ; 4
                                                 *; ===========================================================================
                                                 *
TailsHand_Init                                   *Obj0E_TailsHand_Init:
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        ldd   #Img_tailsHand
        std   image_set,u                        *        move.b  #$13,mapping_frame(a0)
        lda   #3
        sta   priority,u                         *        move.b  #3,priority(a0)
        ldd   #$7764
        std   xy_pixel,u                         *        move.w  #$10F,x_pixel(a0)
                                                 *        move.w  #$D5,y_pixel(a0)
                                                 *
        jmp   DisplaySprite

TailsHand_DisplaySprite                          *BranchTo14_DisplaySprite
        * Change sprite to overlay
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *
TailsHand_Move                                   *loc_13280:
        ldx   #TailsHand_xy_data_end-TailsHand_xy_data+2
        stx   dyn_01+2                           *        moveq   #word_1328C_end-word_1328C+4,d2
        ldx   #TailsHand_xy_data-2               *        lea     (word_1328C).l,a1
        jmp   TitleScreen_MoveObjects            *        bra.w   loc_12F20
                                                 *; ===========================================================================
TailsHand_xy_data                                *word_1328C:
        fcb   $76,$5F                            *        dc.w  $10C, $D0
        fcb   $76,$60                            *        dc.w  $10D, $D1 ; 2
TailsHand_xy_data_end                            *word_1328C_end
                                                 *; ===========================================================================

* ---------------------------------------------------------------------------
* Small Star
* ---------------------------------------------------------------------------

                                                 *
SmallStar                                        *Obj0E_SmallStar:
                                                 *        moveq   #0,d0
        lda   routine_secondary,u                *        move.b  routine_secondary(a0),d0
        asla
        ldx   #SmallStar_Routines                *        move.w  off_132A2(pc,d0.w),d1
        jmp   [a,x]                              *        jmp     off_132A2(pc,d1.w)
                                                 *; ===========================================================================
SmallStar_Routines                               *off_132A2:      offsetTable
        fdb   SmallStar_Init                     *                offsetTableEntry.w Obj0E_SmallStar_Init ; 0
        fdb   SmallStar_Move                     *                offsetTableEntry.w loc_132D2    ; 2
                                                 *; ===========================================================================
                                                 *
SmallStar_Init                                   *Obj0E_SmallStar_Init:
        ldd   Vint_runcount
        std   w_TitleScr_time_frame_count,u
        inc   routine_secondary,u                *        addq.b  #2,routine_secondary(a0)
        ldd   #Img_star_2
        std   image_set,u                        *        move.b  #$C,mapping_frame(a0)
        lda   #7
        sta   priority,u                         *        move.b  #5,priority(a0)
        ldd   #$A80F
        std   xy_pixel,u                         *        move.w  #$170,x_pixel(a0)
                                                 *        move.w  #$80,y_pixel(a0)
        ldd   #Ani_smallStar
        std   anim,u                             *        move.b  #3,anim(a0)
        ldd   #$80
        std   w_TitleScr_time_frame_countdown,u  *        move.w  #$8C,objoff_2A(a0)
        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================
                                                 *
SmallStar_Move                                   *loc_132D2:
        lda   x_pixel,u
        cmpa  #$30                               *        subq.w  #1,objoff_2A(a0)
        bpl   SmallStar_MoveContinue
        jmp   DeleteObject                       *        bmi.w   DeleteObject
SmallStar_MoveContinue
        ldd   Vint_runcount
        subd  w_TitleScr_time_frame_count,u
        stb   SmallStar_MoveContinue_d1+1
        stb   SmallStar_MoveContinue_d2+1
        lda   x_pixel,u                          *        subq.w  #2,x_pixel(a0)
SmallStar_MoveContinue_d1
        suba  #$00
        sta   x_pixel,u
        lda   y_pixel,u                          *        addq.w  #1,y_pixel(a0)
SmallStar_MoveContinue_d2        
        adda  #$00     
        sta   y_pixel,u 
        
        ldd   Vint_runcount
        std   w_TitleScr_time_frame_count,u
        
        * no more offset table                   *        lea     (Ani_obj0E).l,a1
        jsr   AnimateSprite                      *        bsr.w   AnimateSprite
        jmp   DisplaySprite                      *        bra.w   DisplaySprite
                                                 *; ===========================================================================

* ---------------------------------------------------------------------------
* Island
* ---------------------------------------------------------------------------

Island
        lda   routine_secondary,u
        asla
        ldx   #Island_Routines
        jmp   [a,x]

Island_Routines
        fdb   Island_Init
        fdb   Island_Move
        fdb   Island_Move_Display

Island_Init
        inc   routine_secondary,u
        ldd   #Img_island
        std   image_set,u
        lda   #7
        sta   priority,u
        ldd   #$A3C0
        std   xy_pixel,u
        lda   render_flags,u
        ora   #render_xloop_mask|render_overlay_mask
        sta   render_flags,u

        jsr   LoadObject_x
        stx   Obj_IslandMask
        _ldd  ObjID_TitleScreen,Sub_IslandMask
        std   id,x                                    ; id and subtype

        jsr   LoadObject_x
        stx   Obj_IslandWater01
        _ldy  ObjID_TitleScreen,Sub_IslandWater
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater01
        std   image_set,x
        lda   #0
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater02
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater02
        std   image_set,x
        lda   #1
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater03
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater03
        std   image_set,x
        lda   #2
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater04
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater04
        std   image_set,x
        lda   #3
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater05
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater05
        std   image_set,x
        lda   #4
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater06
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater06
        std   image_set,x
        lda   #5
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater07
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater07
        std   image_set,x
        lda   #6
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater08
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater08
        std   image_set,x
        lda   #7
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater09
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater09
        std   image_set,x
        lda   #8
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater10
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater10
        std   image_set,x
        lda   #9
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater11
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater11
        std   image_set,x
        lda   #10
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater12
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater12
        std   image_set,x
        lda   #11
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater13
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater13
        std   image_set,x
        lda   #12
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater14
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater14
        std   image_set,x
        lda   #13
        sta   b_TitleScr_water_index,x

        jsr   LoadObject_x
        stx   Obj_IslandWater15
        sty   id,x                                    ; id and subtype
        ldd   #Img_islandWater15
        std   image_set,x
        lda   #14
        sta   b_TitleScr_water_index,x

        jmp   DisplaySprite

Island_Move
        lda   x_pixel,u
        deca
        cmpa  #screen_left+80
        bhs   Island_Move_InScreen
        inc   routine_secondary,u

        jsr   LoadObject_x
        stx   Obj_PressStart
        _ldd  ObjID_TitleScreen,Sub_PressStart
        std   id,x                                    ; id and subtype
        clr   b_TitleScr_pressed,x

        jmp   DisplaySprite
Island_Move_InScreen
        sta   x_pixel,u
Island_Move_Display
        jmp   DisplaySprite

* ---------------------------------------------------------------------------
* Island Water
* ---------------------------------------------------------------------------

IslandWater
        lda   routine_secondary,u
        asla
        ldx   #IslandWater_Routines
        jmp   [a,x]

IslandWater_Routines
        fdb   IslandWater_Init
        fdb   IslandWater_Ripple

IslandWater_Init
        inc   routine_secondary,u
        lda   #2
        sta   priority,u
        lda   render_flags,u
        ora   #render_xloop_mask|render_overlay_mask
        sta   render_flags,u
        ldx   Obj_Island
        lda   y_pixel,x
        sta   y_pixel,u
        lda   Vint_runcount+1
        sta   b_TitleScr_time_frame_count,u

IslandWater_Ripple
        ldx   Obj_Island

        ldb   b_TitleScr_ripple_index,u
        lda   Vint_runcount+1
        suba  b_TitleScr_time_frame_count,u
        cmpa  #8
        blo   IslandWater_continue1

        lda   Vint_runcount+1
        sta   b_TitleScr_time_frame_count,u
        
        incb
        cmpb  #65
        bls   IslandWater_continue1
        ldb   #0
IslandWater_continue1
        stb   b_TitleScr_ripple_index,u
        addb  b_TitleScr_water_index,u
        cmpb  #65
        bls   IslandWater_continue2
        subb  #66
IslandWater_continue2
        ldy   #SwScrl_RippleData
        lda   x_pixel,x
        adda  b,y
        sta   x_pixel,u
        jmp   DisplaySprite

SwScrl_RippleData
        fcb   1,2,1,2,1,2,2,1
        fcb   2,2,1,2,1,2,0,0 ; 16
        fcb   2,0,2,2,1,2,2,2
        fcb   1,2,0,0,1,0,1,2 ; 32
        fcb   1,2,1,2,1,2,2,1
        fcb   2,2,1,2,1,2,0,0 ; 48
        fcb   2,0,2,2,2,1,2,2
        fcb   1,2,0,0,1,0,1,2 ; 64
        fcb   1,2                 ; 66

      * original offsets
      * fcb   1,2,1,3,1,2,2,1
      * fcb   2,3,1,2,1,2,0,0 ; 16
      * fcb   2,0,3,2,2,3,2,2
      * fcb   1,3,0,0,1,0,1,3 ; 32
      * fcb   1,2,1,3,1,2,2,1
      * fcb   2,3,1,2,1,2,0,0 ; 48
      * fcb   2,0,3,2,2,3,2,2
      * fcb   1,3,0,0,1,0,1,3 ; 64
      * fcb   1,2                 ; 66

* ---------------------------------------------------------------------------
* Island Mask
* ---------------------------------------------------------------------------

IslandMask
        lda   routine_secondary,u
        asla
        ldx   #IslandMask_Routines
        jmp   [a,x]

IslandMask_Routines
        fdb   IslandMask_Init
        fdb   IslandMask1

IslandMask_Init
        inc   routine_secondary,u
        ldd   #Img_islandMask
        std   image_set,u
        lda   #1
        sta   priority,u
        ldd   #$BBC0
        std   xy_pixel,u
        lda   render_flags,u
        ora   #render_xloop_mask|render_overlay_mask
        sta   render_flags,u
        jmp   DisplaySprite

IslandMask1
        ldx   Obj_Island
        lda   x_pixel,x
        cmpa  #screen_left+80+12
        bhi   IslandMask_continue
        jmp   DeleteObject
IslandMask_continue
        jmp   DisplaySprite

* ---------------------------------------------------------------------------
* Press Start
* ---------------------------------------------------------------------------

PressStart
        ldb   Fire_Press
                bitb  #c1_button_A_mask
        beq   PressStart_NoPress

        lda   #$FF
        sta   b_TitleScr_pressed,u

        ldx   Obj_RasterFade
        lda   #Sub_RasterFadeOutColor
        sta   routine,x

        lda   #PalID_TitleScreenRasterBlack
        sta   raster_pal_dst,x
        ldd   #$1048
        sta   raster_cycles,x
        stb   raster_nb_fade_colors,x            * 58 lines to fade
        lda   #$01
        sta   raster_inc,x
        sta   raster_frames,x
        stb   raster_nb_colors,x                 * 72 total lines

PressStart_NoPress
        lda   b_TitleScr_pressed,u
        beq   PressStart_While

        ldx   Obj_RasterFade
        lda   routine,x
        cmpa  #Sub_RasterCycle
        bne   PressStart_While

        jsr   IrqOff
        lda   glb_Next_Game_Mode
        sta   GameMode
        lda   #$FF
        sta   ChangeGameMode       

PressStart_While
        lda   routine_secondary,u
        asla
        ldx   #PressStart_Routines
        jmp   [a,x]

PressStart_Routines
        fdb   PressStart_Init
        fdb   PressStart_display
        fdb   PressStart_hide

PressStart_Init
        inc   routine_secondary,u

        ldd   #Img_pressStart
        std   image_set,u
        lda   #1
        sta   priority,u
        ldd   #$80D8
        std   xy_pixel,u
        ldd   Vint_runcount
        std   w_TitleScr_time_frame_count,u
        jmp   DisplaySprite

PressStart_display
        ldd   Vint_runcount
        subd  w_TitleScr_time_frame_count,u
        cmpd  #35                                * 700ms
        lblo  DisplaySprite
        inc   routine_secondary,u
        ldd   Vint_runcount
        std   w_TitleScr_time_frame_count,u
        jmp   DisplaySprite

PressStart_hide
        ldd   Vint_runcount
        subd  w_TitleScr_time_frame_count,u
        cmpd  #35                                * 700ms
        blo   PressStart_hide1
        dec   routine_secondary,u
        ldd   Vint_runcount
        std   w_TitleScr_time_frame_count,u
PressStart_hide1
        rts

Obj_Tails               fdb 0
Obj_LargeStar           fdb 0
Obj_SmallStar           fdb 0
Obj_SonicHand           fdb 0
Obj_TailsHand           fdb 0
Obj_EmblemFront01       fdb 0
Obj_EmblemFront02       fdb 0
Obj_EmblemFront03       fdb 0
Obj_EmblemFront04       fdb 0
Obj_EmblemFront05       fdb 0
Obj_EmblemFront06       fdb 0
Obj_EmblemFront07       fdb 0
Obj_EmblemFront08       fdb 0
Obj_EmblemBack01        fdb 0
Obj_EmblemBack02        fdb 0
Obj_EmblemBack03        fdb 0
Obj_EmblemBack04        fdb 0
Obj_EmblemBack05        fdb 0
Obj_EmblemBack06        fdb 0
Obj_EmblemBack07        fdb 0
Obj_EmblemBack08        fdb 0
Obj_EmblemBack09        fdb 0
Obj_Island              fdb 0
Obj_IslandWater01       fdb 0
Obj_IslandWater02       fdb 0
Obj_IslandWater03       fdb 0
Obj_IslandWater04       fdb 0
Obj_IslandWater05       fdb 0
Obj_IslandWater06       fdb 0
Obj_IslandWater07       fdb 0
Obj_IslandWater08       fdb 0
Obj_IslandWater09       fdb 0
Obj_IslandWater10       fdb 0
Obj_IslandWater11       fdb 0
Obj_IslandWater12       fdb 0
Obj_IslandWater13       fdb 0
Obj_IslandWater14       fdb 0
Obj_IslandWater15       fdb 0
Obj_IslandMask          fdb 0
Obj_PaletteFade         fdb 0
Obj_RasterFade          fdb 0
Obj_PressStart          fdb 0