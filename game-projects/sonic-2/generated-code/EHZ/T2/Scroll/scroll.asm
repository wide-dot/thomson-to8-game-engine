	opt   c,ct
	INCLUDE "./generated-code/EHZ/T2/main-engine.glb"
	org   $351D
	setdp $FF

        INCLUDE "./Engine/Macros.asm"  

                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * ; sub_C3D0:
                                                      * DeformBgLayer:
                                                      *         tst.b   (Deform_lock).w
                                                      *         beq.s   +
                                                      *         rts
                                                      * ; ---------------------------------------------------------------------------
                                                      * +
                                                      *         clr.w   (Scroll_flags).w
                                                      *         clr.w   (Scroll_flags_BG).w
                                                      *         clr.w   (Scroll_flags_BG2).w
                                                      *         clr.w   (Scroll_flags_BG3).w
                                                      *         clr.w   (Scroll_flags_P2).w
                                                      *         clr.w   (Scroll_flags_BG_P2).w
                                                      *         clr.w   (Scroll_flags_BG2_P2).w
                                                      *         clr.w   (Scroll_flags_BG3_P2).w
                                                      *         clr.w   (Camera_X_pos_diff).w
                                                      *         clr.w   (Camera_Y_pos_diff).w
                                                      *         clr.w   (Camera_X_pos_diff_P2).w
                                                      *         clr.w   (Camera_Y_pos_diff_P2).w
                                                      *         cmpi.b  #sky_chase_zone,(Current_Zone).w
                                                      *         bne.w   +
                                                      *         tst.w   (Debug_placement_mode).w
                                                      *         beq.w   loc_C4D0        ; skip normal scrolling for SCZ
                                                      * +
                                                      *         tst.b   (Scroll_lock).w
                                                      *         bne.s   DeformBgLayerAfterScrollVert
                                                      *         lea     (MainCharacter).w,a0 ; a0=character
                                                      *         lea     (Camera_X_pos).w,a1
                                                      *         lea     (Camera_Min_X_pos).w,a2
                                                      *         lea     (Scroll_flags).w,a3
                                                      *         lea     (Camera_X_pos_diff).w,a4
                                                      *         lea     (Horiz_scroll_delay_val).w,a5
                                                      *         lea     (Sonic_Pos_Record_Buf).w,a6
                                                      *         cmpi.w  #2,(Player_mode).w
                                                      *         bne.s   +
                                                      *         lea     (Horiz_scroll_delay_val_P2).w,a5
                                                      *         lea     (Tails_Pos_Record_Buf).w,a6
                                                      * +
                                                      *         bsr.w   ScrollHoriz
                                                      *         lea     (Horiz_block_crossed_flag).w,a2
                                                      *         bsr.w   SetHorizScrollFlags
                                                      *         lea     (Camera_Y_pos).w,a1
                                                      *         lea     (Camera_Min_X_pos).w,a2
                                                      *         lea     (Camera_Y_pos_diff).w,a4
                                                      *         move.w  (Camera_Y_pos_bias).w,d3
                                                      *         cmpi.w  #2,(Player_mode).w
                                                      *         bne.s   +
                                                      *         move.w  (Camera_Y_pos_bias_P2).w,d3
                                                      * +
                                                      *         bsr.w   ScrollVerti
                                                      *         lea     (Verti_block_crossed_flag).w,a2
                                                      *         bsr.w   SetVertiScrollFlags
                                                      * 
                                                      * DeformBgLayerAfterScrollVert:
                                                      *         tst.w   (Two_player_mode).w
                                                      *         beq.s   loc_C4D0
                                                      *         tst.b   (Scroll_lock_P2).w
                                                      *         bne.s   loc_C4D0
                                                      *         lea     (Sidekick).w,a0 ; a0=character
                                                      *         lea     (Camera_X_pos_P2).w,a1
                                                      *         lea     (Tails_Min_X_pos).w,a2
                                                      *         lea     (Scroll_flags_P2).w,a3
                                                      *         lea     (Camera_X_pos_diff_P2).w,a4
                                                      *         lea     (Horiz_scroll_delay_val_P2).w,a5
                                                      *         lea     (Tails_Pos_Record_Buf).w,a6
                                                      *         bsr.w   ScrollHoriz
                                                      *         lea     (Horiz_block_crossed_flag_P2).w,a2
                                                      *         bsr.w   SetHorizScrollFlags
                                                      *         lea     (Camera_Y_pos_P2).w,a1
                                                      *         lea     (Tails_Min_X_pos).w,a2
                                                      *         lea     (Camera_Y_pos_diff_P2).w,a4
                                                      *         move.w  (Camera_Y_pos_bias_P2).w,d3
                                                      *         bsr.w   ScrollVerti
                                                      *         lea     (Verti_block_crossed_flag_P2).w,a2
                                                      *         bsr.w   SetVertiScrollFlags
                                                      * 
                                                      * loc_C4D0:
                                                      *         bsr.w   RunDynamicLevelEvents
                                                      *         move.w  (Camera_Y_pos).w,(Vscroll_Factor_FG).w
                                                      *         move.w  (Camera_BG_Y_pos).w,(Vscroll_Factor_BG).w
                                                      *         move.l  (Camera_X_pos).w,(Camera_X_pos_copy).w
                                                      *         move.l  (Camera_Y_pos).w,(Camera_Y_pos_copy).w
                                                      *         moveq   #0,d0
                                                      *         move.b  (Current_Zone).w,d0
                                                      *         add.w   d0,d0
                                                      *         move.w  SwScrl_Index(pc,d0.w),d0
                                                      *         jmp     SwScrl_Index(pc,d0.w)
                                                      * ; End of function DeformBgLayer

                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to scroll the camera horizontally
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ;sub_D704:
ScrollHoriz                                           * ScrollHoriz:
                                                      *         move.w  (a1),d4         ; get camera X pos
                                                      *         tst.b   (Teleport_flag).w
                                                      *         bne.s   .return         ; if a teleport is in progress, return
        ldd   Horiz_scroll_delay_val                  *         move.w  (a5),d1         ; should scrolling be delayed?
        beq   @scrollNotDelayed                       *         beq.s   .scrollNotDelayed       ; if not, branch
        ;subd  #$100                                   *         subi.w  #$100,d1        ; reduce delay value
        ;todo ...                                         *         move.w  d1,(a5)
                                                      *         moveq   #0,d1
                                                      *         move.b  (a5),d1         ; get delay value
                                                      *         lsl.b   #2,d1           ; multiply by 4, the size of a position buffer entry
                                                      *         addq.b  #4,d1
                                                      *         move.w  2(a5),d0        ; get current position buffer index
                                                      *         sub.b   d1,d0
                                                      *         move.w  (a6,d0.w),d0    ; get Sonic's position a certain number of frames ago
                                                      *         andi.w  #$3FFF,d0
                                                      *         bra.s   .checkIfShouldScroll    ; use that value for scrolling
                                                      * ; ===========================================================================
                                                      * ; loc_D72E:
@scrollNotDelayed                                     * .scrollNotDelayed:
        ldd   x_pos,u                                 *         move.w  x_pos(a0),d0
                                                      * ; loc_D732:
@checkIfShouldScroll                                  * .checkIfShouldScroll:
        subd  glb_camera_x_pos                        *         sub.w   (a1),d0
        subd  #$80-8                                  *         subi.w  #(320/2)-16,d0          ; is the player less than 144 pixels from the screen edge?
        blt   @scrollLeft                             *         blt.s   .scrollLeft     ; if he is, scroll left
        subd  #$8                                     *         subi.w  #16,d0          ; is the player more than 159 pixels from the screen edge?
        bge   @scrollRight                            *         bge.s   .scrollRight    ; if he is, scroll right
        ;                                             *         clr.w   (a4)            ; otherwise, don't scroll
                                                      * ; return_D742:
                                                      * .return:
        bra   ScrollVerti                             *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_D744:
@scrollLeft                                           * .scrollLeft:
        cmpd  #-8*5                                   *         cmpi.w  #-16,d0
        bgt   @maxNotReached                          *         bgt.s   .maxNotReached
        ldd   #-8*5                                   *         move.w  #-16,d0         ; limit scrolling to 16 pixels per frame
                                                      * ; loc_D74E:
@maxNotReached                                        * .maxNotReached:
        addd  glb_camera_x_pos                        *         add.w   (a1),d0         ; get new camera position
        cmpd  glb_camera_x_min_pos                    *         cmp.w   (a2),d0         ; is it greater than the minimum position?
        bgt   @doScroll                               *         bgt.s   .doScroll               ; if it is, branch
        ldd   glb_camera_x_min_pos                    *         move.w  (a2),d0         ; prevent camera from going any further back
        bra   @doScroll                               *         bra.s   .doScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D758:
@scrollRight                                          * .scrollRight:
        cmpd  #8*5                                    *         cmpi.w  #16,d0
        blo   @maxNotReached2                         *         blo.s   .maxNotReached2
        ldd   #8*5                                    *         move.w  #16,d0
                                                      * ; loc_D762:
@maxNotReached2                                       * .maxNotReached2:
        addd  glb_camera_x_pos                        *         add.w   (a1),d0         ; get new camera position
        cmpd  glb_camera_x_max_pos                    *         cmp.w   Camera_Max_X_pos-Camera_Min_X_pos(a2),d0        ; is it less than the max position?
        blt   @doScroll                               *         blt.s   .doScroll       ; if it is, branch
        ldd   glb_camera_x_max_pos                    *         move.w  Camera_Max_X_pos-Camera_Min_X_pos(a2),d0        ; prevent camera from going any further forward
                                                      * ; loc_D76E:
@doScroll                                             * .doScroll:
                                                      *         move.w  d0,d1
                                                      *         sub.w   (a1),d1         ; subtract old camera position
        andb  #$FE                                    *         asl.w   #8,d1           ; shift up by a byte
        std   glb_camera_x_pos                        *         move.w  d0,(a1)         ; set new camera position
                                                      *         move.w  d1,(a4)         ; set difference between old and new positions
                                                      *         rts
                                                      * ; End of function ScrollHoriz
                                                      * 

                                                      * ; ---------------------------------------------------------------------------
                                                      * ; Subroutine to scroll the camera vertically
                                                      * ; ---------------------------------------------------------------------------
                                                      * 
                                                      * ; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      * 
                                                      * ; The upper 16 bits of Camera_Y_pos is the actual Y-pos, the lower ones seem
                                                      * ; unused, yet this code goes to a strange extent to manage them.
                                                      * ;sub_D77A:
ScrollVerti                                           * ScrollVerti:
                                                      *         moveq   #0,d1
        ldd   y_pos,u                                 *         move.w  y_pos(a0),d0
        subd  glb_camera_y_pos                        *         sub.w   (a1),d0         ; subtract camera Y pos
        ;ldx   glb_camera_y_min_pos                    *         cmpi.w  #-$100,(Camera_Min_Y_pos).w ; does the level wrap vertically?
        ;cmpx  #-$100
        ;bne   @noWrap                                 *         bne.s   .noWrap         ; if not, branch
        ;anda  #$07 
        ;andb  #$FF                                    *         andi.w  #$7FF,d0
                                                      * ; loc_D78E:
@noWrap                                               * .noWrap:
        std   @d
        lda   status,u                                *         btst    #2,status(a0)   ; is the player rolling?
        anda  #status_jumporroll
        beq   @notRolling                             *         beq.s   .notRolling     ; if not, branch
        ldd   @d
        subd  #5                                      *         subq.w  #5,d0           ; subtract difference between standing and rolling heights
        std   @d
                                                      * ; loc_D798:
@notRolling                                           * .notRolling:
        lda   status,u
        anda  #status_inair                           *         btst    #1,status(a0)                   ; is the player in the air?
        beq   @checkBoundaryCrossed_onGround          *         beq.s   .checkBoundaryCrossed_onGround  ; if not, branch
@checkBoundaryCrossed_inAir                           * ;.checkBoundaryCrossed_inAir:
                                                      *         ; If Sonic's in the air, he has $20 pixels above and below him to move without disturbing the camera.
                                                      *         ; The camera movement is also only capped at $10 pixels.
        ldd   @d
        addd  #$20                                    *         addi.w  #$20,d0
        subd  Camera_Y_pos_bias                       *         sub.w   d3,d0
        bcs   @doScroll_fast                          *         bcs.s   .doScroll_fast  ; If Sonic is above the boundary, scroll to catch up to him
        subd  #$40                                    *         subi.w  #$40,d0
        bcc   @doScroll_fast                          *         bcc.s   .doScroll_fast  ; If Sonic is below the boundary, scroll to catch up to him
        tst   Camera_Max_Y_Pos_Changing               *         tst.b   (Camera_Max_Y_Pos_Changing).w   ; is the max Y pos changing?
        bne   @scrollUpOrDown_maxYPosChanging         *         bne.s   .scrollUpOrDown_maxYPosChanging ; if it is, branch
        bra   @doNotScroll                            *         bra.s   .doNotScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D7B6:
@checkBoundaryCrossed_onGround                        * .checkBoundaryCrossed_onGround:
                                                      *         ; On the ground, the camera follows Sonic very strictly.
        ldd   @d
        subd  Camera_Y_pos_bias                       *         sub.w   d3,d0                           ; subtract camera bias
        std   @d
        bne   @decideScrollType                       *         bne.s   .decideScrollType               ; If Sonic has moved, scroll to catch up to him
        tst   Camera_Max_Y_Pos_Changing               *         tst.b   (Camera_Max_Y_Pos_Changing).w   ; is the max Y pos changing?
        bne   @scrollUpOrDown_maxYPosChanging         *         bne.s   .scrollUpOrDown_maxYPosChanging ; if it is, branch
                                                      * ; loc_D7C0:
@doNotScroll                                          * .doNotScroll:
        ;                                             *         clr.w   (a4)            ; clear Y position difference (Camera_Y_pos_bias)
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_D7C4:
@decideScrollType                                     * .decideScrollType:
        ldx   Camera_Y_pos_bias
        cmpx  #camera_Y_pos_bias_default              *         cmpi.w  #(224/2)-16,d3          ; is the camera bias normal?
        bne   @doScroll_slow                          *         bne.s   .doScroll_slow  ; if not, branch
        ldd   inertia,u                               *         mvabs.w inertia(a0),d1  ; get player ground velocity, force it to be positive
        bpl   >
        _negd              
!       tfr   d,x
        ldd   #0
@d      equ   *-2
        cmpx  #$800                                   *         cmpi.w  #$800,d1        ; is the player travelling very fast?
        bhs   @doScroll_fast                          *         bhs.s   .doScroll_fast  ; if he is, branch
@doScroll_medium                                      * ;.doScroll_medium:
        ldx   #12                                      *         move.w  #6<<8,d1        ; If player is going too fast, cap camera movement to 6 pixels per frame
        cmpd  #12                                      *         cmpi.w  #6,d0           ; is player going down too fast?
        lbgt   @scrollDown_max                         *         bgt.s   .scrollDown_max ; if so, move camera at capped speed
        cmpd  #-12                                     *         cmpi.w  #-6,d0          ; is player going up too fast?
        blt   @scrollUp_max                           *         blt.s   .scrollUp_max   ; if so, move camera at capped speed
        bra   @scrollUpOrDown                         *         bra.s   .scrollUpOrDown ; otherwise, move camera at player's speed
                                                      * ; ===========================================================================
                                                      * ; loc_D7EA:
@doScroll_slow                                        * .doScroll_slow:
        ldd   @d
        ldx   #4                                      *         move.w  #2<<8,d1        ; If player is going too fast, cap camera movement to 2 pixels per frame
        cmpd  #4                                      *         cmpi.w  #2,d0           ; is player going down too fast?
        bgt   @scrollDown_max                         *         bgt.s   .scrollDown_max ; if so, move camera at capped speed
        cmpd  #-4                                     *         cmpi.w  #-2,d0          ; is player going up too fast?
        blt   @scrollUp_max                           *         blt.s   .scrollUp_max   ; if so, move camera at capped speed
        bra   @scrollUpOrDown                         *         bra.s   .scrollUpOrDown ; otherwise, move camera at player's speed
                                                      * ; ===========================================================================
                                                      * ; loc_D7FC:
@doScroll_fast                                        * .doScroll_fast:
                                                      *         ; related code appears in ScrollBG
                                                      *         ; S3K uses 24 instead of 16
        ldx   #32                                     *         move.w  #16<<8,d1       ; If player is going too fast, cap camera movement to $10 pixels per frame
        cmpd  #32                                     *         cmpi.w  #16,d0          ; is player going down too fast?
        bgt   @scrollDown_max                         *         bgt.s   .scrollDown_max ; if so, move camera at capped speed
        cmpd  #-32                                    *         cmpi.w  #-16,d0         ; is player going up too fast?
        blt   @scrollUp_max                           *         blt.s   .scrollUp_max   ; if so, move camera at capped speed
        bra   @scrollUpOrDown                         *         bra.s   .scrollUpOrDown ; otherwise, move camera at player's speed
                                                      * ; ===========================================================================
                                                      * ; loc_D80E:
@scrollUpOrDown_maxYPosChanging                       * .scrollUpOrDown_maxYPosChanging:
        ldd   #0                                      *         moveq   #0,d0           ; Distance for camera to move = 0
        sta   Camera_Max_Y_Pos_Changing               *         move.b  d0,(Camera_Max_Y_Pos_Changing).w        ; clear camera max Y pos changing flag
                                                      * ; loc_D814:
@scrollUpOrDown                                       * .scrollUpOrDown:
        ;                                             *         moveq   #0,d1
        std   @d0
        tfr   d,x                                     *         move.w  d0,d1           ; get position difference
        ldd   glb_camera_y_pos
        leax  d,x                                     *         add.w   (a1),d1         ; add old camera Y position
        stx   @scval
        ldd   #0
@d0     equ   *-2                                     *         tst.w   d0              ; is the camera to scroll down?
        bpl   @scrollDown                             *         bpl.w   .scrollDown     ; if it is, branch
        bra   @scrollUp                               *         bra.w   .scrollUp
                                                      * ; ===========================================================================
                                                      * ; loc_D824:
@scrollUp_max                                         * .scrollUp_max:
        std   @d0
        tfr   x,d
        _negd                                         *         neg.w   d1      ; make the value negative (since we're going backwards)
        tfr   d,x
        ldd   glb_camera_y_pos
        ;                                             *         ext.l   d1
        ;                                             *         asl.l   #8,d1   ; move this into the upper word, so it lines up with the actual y_pos value in Camera_Y_pos
        leax   d,x                                    *         add.l   (a1),d1 ; add the two, getting the new Camera_Y_pos value
        stx   @scval
        ;                                             *         swap    d1      ; actual Y-coordinate is now the low word
                                                      * ; loc_D82E:
@scrollUp                                             * .scrollUp:
        cmpx  glb_camera_y_min_pos                    *         cmp.w   Camera_Min_Y_pos-Camera_Min_X_pos(a2),d1        ; is the new position less than the minimum Y pos?
        bgt   @doScroll                               *         bgt.s   .doScroll       ; if not, branch
        cmpx  #-$100                                  *         cmpi.w  #-$100,d1
        bgt   @minYPosReached                         *         bgt.s   .minYPosReached
        tfr   x,d
        anda  #$07                                    *         andi.w  #$7FF,d1
        andb  #$FF
        std   @scval
        ldd   glb_camera_y_pos
        anda  #$07 
        andb  #$FF
        std   glb_camera_y_pos                        *         andi.w  #$7FF,(a1)
        bra   @doScroll                               *         bra.s   .doScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D844:
@minYPosReached                                       * .minYPosReached:
        ldd   glb_camera_y_min_pos                    *         move.w  Camera_Min_Y_pos-Camera_Min_X_pos(a2),d1        ; prevent camera from going any further up
        std   @scval
        bra   @doScroll                               *         bra.s   .doScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D84A:
@scrollDown_max                                       * .scrollDown_max:
        std   @d0
        ldd   glb_camera_y_pos
        ;                                             *         ext.l   d1
        ;                                             *         asl.l   #8,d1           ; move this into the upper word, so it lines up with the actual y_pos value in Camera_Y_pos
        leax  d,x                                     *         add.l   (a1),d1         ; add the two, getting the new Camera_Y_pos value
        stx   @scval
        ;                                             *         swap    d1              ; actual Y-coordinate is now the low word
                                                      * ; loc_D852:
@scrollDown                                           * .scrollDown:
        cmpx  glb_camera_y_max_pos                    *         cmp.w   Camera_Max_Y_pos_now-Camera_Min_X_pos(a2),d1    ; is the new position greater than the maximum Y pos?
        blt   @doScroll                               *         blt.s   .doScroll       ; if not, branch
        tfr   x,d
        subd  #$800                                   *         subi.w  #$800,d1
        std   @scval
        bcs   @maxYPosReached                         *         bcs.s   .maxYPosReached
        ldd   glb_camera_y_pos
        subd  #$800                                   *         subi.w  #$800,(a1)
        std   glb_camera_y_pos
        bra   @doScroll                               *         bra.s   .doScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D864:
@maxYPosReached                                       * .maxYPosReached:
        ldd   glb_camera_y_max_pos                    *         move.w  Camera_Max_Y_pos_now-Camera_Min_X_pos(a2),d1    ; prevent camera from going any further down
        std   @scval
                                                      * ; loc_D868:
@doScroll                                             * .doScroll:
                                                      *         move.w  (a1),d4         ; get old pos (used by SetVertiScrollFlags)
                                                      *         swap    d1              ; actual Y-coordinate is now the high word, as Camera_Y_pos expects it
                                                      *         move.l  d1,d3
                                                      *         sub.l   (a1),d3
                                                      *         ror.l   #8,d3
                                                      *         move.w  d3,(a4)         ; set difference between old and new positions
        ldd   #0
@scval  equ   *-2
        andb  #$FE
        std   glb_camera_y_pos                        *         move.l  d1,(a1)         ; set new camera Y pos
        rts                                           *         rts
                                                      * ; End of function ScrollVerti
