; ---------------------------------------------------------------------------
; Object - Splash and Dust
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

                                                      * ; ===========================================================================
                                                      * ; ----------------------------------------------------------------------------
                                                      * ; Object 08 - Water splash in Aquatic Ruin Zone, Spindash dust
                                                      * ; ----------------------------------------------------------------------------
                                                      * 
                                                      * obj08_previous_frame = objoff_30
obj08_dust_timer       equ ext_variables_obj          * obj08_dust_timer = objoff_32
obj08_skid_anim        equ ext_variables_obj+1        * obj08_belongs_to_tails = objoff_34
                                                      * obj08_vram_address = objoff_3C
                                                      * 
                                                      * ; Sprite_1DD20:
Obj08                                                 * Obj08:
        lda   routine,u                               *         moveq   #0,d0
        asla                                          *         move.b  routine(a0),d0
        ldx   #Obj08_Index                            *         move.w  Obj08_Index(pc,d0.w),d1
        jmp   [a,x]                                   *         jmp     Obj08_Index(pc,d1.w)
                                                      * ; ===========================================================================
                                                      * ; off_1DD2E:
Obj08_Index                                           * Obj08_Index:    offsetTable
        fdb   Obj08_Init                              *                 offsetTableEntry.w Obj08_Init                   ; 0
        fdb   Obj08_Main                              *                 offsetTableEntry.w Obj08_Main                   ; 2
        fdb   DeleteObject                            *                 offsetTableEntry.w BranchTo16_DeleteObject      ; 4
        fdb   Obj08_CheckSkid                         *                 offsetTableEntry.w Obj08_CheckSkid              ; 6
                                                      * ; ===========================================================================
                                                      * ; loc_1DD36:
Obj08_Init                                            * Obj08_Init:
        inc   routine,u                               *         addq.b  #2,routine(a0)
                                                      *         move.l  #Obj08_MapUnc_1DF5E,mappings(a0)
        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u                          *         ori.b   #4,render_flags(a0)
        ldd   #$0110
        sta   priority,u                              *         move.b  #1,priority(a0)
        stb   width_pixels,u                          *         move.b  #$10,width_pixels(a0)
                                                      *         move.w  #make_art_tile(ArtTile_ArtNem_SonicDust,0,0),art_tile(a0)
        ldd   #MainCharacter
        std   parent,u                                *         move.w  #MainCharacter,parent(a0)
                                                      *         move.w  #tiles_to_bytes(ArtTile_ArtNem_SonicDust),obj08_vram_address(a0)
                                                      *         cmpa.w  #Sonic_Dust,a0
                                                      *         beq.s   +
                                                      *         move.b  #1,obj08_belongs_to_tails(a0)
                                                      *         cmpi.w  #2,(Player_mode).w
                                                      *         beq.s   +
                                                      *         move.w  #make_art_tile(ArtTile_ArtNem_TailsDust,0,0),art_tile(a0)
                                                      *         move.w  #Sidekick,parent(a0)
                                                      *         move.w  #tiles_to_bytes(ArtTile_ArtNem_TailsDust),obj08_vram_address(a0)
                                                      * +
                                                      *         bsr.w   Adjust2PArtPointer
                                                      * 
                                                      * ; loc_1DD90:
Obj08_Main                                            * Obj08_Main:
        ldy   parent,u                                *         movea.w parent(a0),a2 ; a2=character
        lda   routine_secondary,u                     *         moveq   #0,d0
        asla                                          *         move.b  anim(a0),d0     ; use current animation as a secondary routine counter
        ldx   #Obj08_DisplayModes                     *         add.w   d0,d0
        jmp   [a,x]                                   *         move.w  Obj08_DisplayModes(pc,d0.w),d1
                                                      *         jmp     Obj08_DisplayModes(pc,d1.w)
                                                      * ; ===========================================================================
                                                      * ; off_1DDA4:
Obj08_DisplayModes                                    * Obj08_DisplayModes: offsetTable
        fdb   Obj08_Idle                              *         offsetTableEntry.w Obj08_Display        ; 0
        fdb   Obj08_MdSplash                          *         offsetTableEntry.w Obj08_MdSplash       ; 2
        fdb   Obj08_MdSpindashDust                    *         offsetTableEntry.w Obj08_MdSpindashDust ; 4
        fdb   Obj08_MdSkidDust                        *         offsetTableEntry.w Obj08_MdSkidDust     ; 6
                                                      * ; ===========================================================================
                                                      * ; loc_1DDAC:
Obj08_MdSplash                                        * Obj08_MdSplash:
        ldd   Water_Level_1
        std   y_pos,u                                 *         move.w  (Water_Level_1).w,y_pos(a0)
        ldd   prev_anim,u                             *         tst.b   prev_anim(a0)
        bne   Obj08_Display                           *         bne.s   Obj08_Display
        ldd   x_pos,y
        std   x_pos,u                                 *         move.w  x_pos(a2),x_pos(a0)
        lda   #0
        sta   status,u                                *         move.b  #0,status(a0)
                                                      *         andi.w  #drawing_mask,art_tile(a0)
        ldd   #Obj08Ani_Splash
        std   anim,u
        bra   Obj08_Display                           *         bra.s   Obj08_Display
                                                      * ; ===========================================================================
                                                      * ; loc_1DDCC:
Obj08_MdSpindashDust                                  * Obj08_MdSpindashDust:
        lda   air_left,y
        cmpa  #$C                                     *         cmpi.b  #$C,air_left(a2)
        blo   Obj08_ResetDisplayMode                  *         blo.s   Obj08_ResetDisplayMode
        lda   routine,y                               
        cmpa  #2                                      *         cmpi.b  #4,routine(a2)
        bhs   Obj08_ResetDisplayMode                  *         bhs.s   Obj08_ResetDisplayMode
        tst   spindash_flag,y                         *         tst.b   spindash_flag(a2)
        beq   Obj08_ResetDisplayMode                  *         beq.s   Obj08_ResetDisplayMode
        ldd   x_pos,y
        std   x_pos,u                                 *         move.w  x_pos(a2),x_pos(a0)
        ldd   y_pos,y
        std   y_pos,u                                 *         move.w  y_pos(a2),y_pos(a0)
        lda   status,y
        anda  #status_x_orientation
        sta   status,u                                *         move.b  status(a2),status(a0)
                                                      *         andi.b  #1,status(a0)
                                                      *         tst.b   obj08_belongs_to_tails(a0)
                                                      *         beq.s   +
                                                      *         subi_.w #4,y_pos(a0);   ; Tails is shorter than Sonic
                                                      * +
                                                      *         tst.b   prev_anim(a0)
                                                      *         bne.s   Obj08_Display
                                                      *         andi.w  #drawing_mask,art_tile(a0)
        ldd   #Obj08Ani_Dash                          
        std   anim,u
                                                      *         tst.w   art_tile(a2)
                                                      *         bpl.s   Obj08_Display
                                                      *         ori.w   #high_priority,art_tile(a0)
        bra   Obj08_Display                           *         bra.s   Obj08_Display
                                                      * ; ===========================================================================
                                                      * ; loc_1DE20:
Obj08_MdSkidDust                                      * Obj08_MdSkidDust:
        lda   air_left,y                              *         cmpi.b  #$C,air_left(a2)
        cmpa  #$C
        blo   Obj08_ResetDisplayMode                  *         blo.s   Obj08_ResetDisplayMode
                                                      * 
                                                      * ; loc_1DE28:
Obj08_Display                                         * Obj08_Display:
                                                      *         lea     (Ani_obj08).l,a1
        jsr   AnimateSpriteSync                       *         jsr     (AnimateSprite).l
                                                      *         bsr.w   Obj08_LoadDustOrSplashArt
        jmp   DisplaySprite                           *         jmp     (DisplaySprite).l

Obj08_Idle
        rts

                                                      * ; ===========================================================================
                                                      * ; loc_1DE3E:
Obj08_ResetDisplayMode                                * Obj08_ResetDisplayMode:
        lda   #0                                      *         move.b  #0,anim(a0)
        sta   routine_secondary,u
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * 
                                                      * BranchTo16_DeleteObject
                                                      *         bra.w   DeleteObject
                                                      * ; ===========================================================================
                                                      * ; loc_1DE4A:
Obj08_CheckSkid                                       * Obj08_CheckSkid:
        ldy   parent,u                                *         movea.w parent(a0),a2 ; a2=character
        ldd   anim,y
        cmpd  obj08_skid_anim,u                       *         cmpi.b  #AniIDSonAni_Stop,anim(a2)      ; SonAni_Stop
        beq   Obj08_SkidDust                          *         beq.s   Obj08_SkidDust
        ldd   #$0100
        sta   routine,u                               *         move.b  #2,routine(a0)
        stb   obj08_dust_timer,u                      *         move.b  #0,obj08_dust_timer(a0)
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_1DE64:
Obj08_SkidDust                                        * Obj08_SkidDust:
        dec   obj08_dust_timer,u                      *         subq.b  #1,obj08_dust_timer(a0)
        bpl   loc_1DEE0                               *         bpl.s   loc_1DEE0
        lda   #3
        suba  Vint_Main_runcount
        sta   obj08_dust_timer,u                      *         move.b  #3,obj08_dust_timer(a0)
        jsr   LoadObject_x                            *         bsr.w   SingleObjLoad
        beq   loc_1DEE0                               *         bne.s   loc_1DEE0
        lda   id,u
        sta   id,x                                    *         _move.b id(a0),id(a1) ; load obj08
        ldd   x_pos,y
        std   x_pos,x                                 *         move.w  x_pos(a2),x_pos(a1)
        ldd   y_pos,y
        addd  #$10
        std   y_pos,x                                 *         move.w  y_pos(a2),y_pos(a1)
                                                      *         addi.w  #$10,y_pos(a1)
                                                      *         tst.b   obj08_belongs_to_tails(a0)
                                                      *         beq.s   +
                                                      *         subi_.w #4,y_pos(a1)    ; Tails is shorter than Sonic
                                                      * +
        lda   #0
        sta   status,x                                *         move.b  #0,status(a1)
        ldd   #Obj08Ani_Skid
        std   anim,x
        lda   #3
        sta   routine_secondary,x                     *         move.b  #3,anim(a1)
        inc   routine,x                               *         addq.b  #2,routine(a1)
                                                      *         move.l  mappings(a0),mappings(a1)
        lda   render_flags,u
        sta   render_flags,x                          *         move.b  render_flags(a0),render_flags(a1)
        ldd   #$0104
        sta   priority,x                              *         move.b  #1,priority(a1)
        stb   width_pixels,x                          *         move.b  #4,width_pixels(a1)
                                                      *         move.w  art_tile(a0),art_tile(a1)
        ldd   parent,u
        std   parent,x                                *         move.w  parent(a0),parent(a1)
                                                      *         andi.w  #drawing_mask,art_tile(a1)
                                                      *         tst.w   art_tile(a2)
                                                      *         bpl.s   loc_1DEE0
                                                      *         ori.w   #high_priority,art_tile(a1)
                                                      * 
loc_1DEE0                                             * loc_1DEE0:
                                                      *         bsr.s   Obj08_LoadDustOrSplashArt
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_1DEE4:
                                                      * Obj08_LoadDustOrSplashArt:
                                                      *         moveq   #0,d0
                                                      *         move.b  mapping_frame(a0),d0
                                                      *         cmp.b   obj08_previous_frame(a0),d0
                                                      *         beq.s   return_1DF36
                                                      *         move.b  d0,obj08_previous_frame(a0)
                                                      *         lea     (Obj08_MapRUnc_1E074).l,a2
                                                      *         add.w   d0,d0
                                                      *         adda.w  (a2,d0.w),a2
                                                      *         move.w  (a2)+,d5
                                                      *         subq.w  #1,d5
                                                      *         bmi.s   return_1DF36
                                                      *         move.w  obj08_vram_address(a0),d4
                                                      * 
                                                      * -       moveq   #0,d1
                                                      *         move.w  (a2)+,d1
                                                      *         move.w  d1,d3
                                                      *         lsr.w   #8,d3
                                                      *         andi.w  #$F0,d3
                                                      *         addi.w  #$10,d3
                                                      *         andi.w  #$FFF,d1
                                                      *         lsl.l   #5,d1
                                                      *         addi.l  #ArtUnc_SplashAndDust,d1
                                                      *         move.w  d4,d2
                                                      *         add.w   d3,d4
                                                      *         add.w   d3,d4
                                                      *         jsr     (QueueDMATransfer).l
                                                      *         dbf     d5,-
                                                      * 
                                                      * return_1DF36:
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; animation script
                                                      * ; off_1DF38:
                                                      * Ani_obj08:      offsetTable
                                                      *                 offsetTableEntry.w Obj08Ani_Null        ; 0
                                                      *                 offsetTableEntry.w Obj08Ani_Splash      ; 1
                                                      *                 offsetTableEntry.w Obj08Ani_Dash        ; 2
                                                      *                 offsetTableEntry.w Obj08Ani_Skid        ; 3
                                                      * Obj08Ani_Null:  dc.b $1F,  0,$FF
                                                      *         rev02even
                                                      * Obj08Ani_Splash:dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,  9,$FD,  0
                                                      *         rev02even
                                                      * Obj08Ani_Dash:  dc.b   1, $A, $B, $C, $D, $E, $F,$10,$FF
                                                      *         rev02even
                                                      * Obj08Ani_Skid:  dc.b   3,$11,$12,$13,$14,$FC
                                                      *         even