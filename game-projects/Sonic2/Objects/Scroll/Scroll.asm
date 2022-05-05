        jsr   ScrollHoriz
        jmp   ScrollVerti
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
                                                      *         move.w  (a5),d1         ; should scrolling be delayed?
                                                      *         beq.s   .scrollNotDelayed       ; if not, branch
                                                      *         subi.w  #$100,d1        ; reduce delay value
                                                      *         move.w  d1,(a5)
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
                                                      * .scrollNotDelayed:
                                                      *         move.w  x_pos(a0),d0
                                                      * ; loc_D732:
                                                      * .checkIfShouldScroll:
        ldd   x_pos,u                                 *         sub.w   (a1),d0
        subd  glb_camera_x_pos
        cmpd  #$80-8                                  *         subi.w  #(320/2)-16,d0          ; is the player less than 144 pixels from the screen edge?
        blt   @scrollLeft                             *         blt.s   .scrollLeft     ; if he is, scroll left
        cmpd  #$80                                    *         subi.w  #16,d0          ; is the player more than 159 pixels from the screen edge?
        bge   @scrollRight                            *         bge.s   .scrollRight    ; if he is, scroll right
                                                      *         clr.w   (a4)            ; otherwise, don't scroll
                                                      * ; return_D742:
                                                      * .return:
        rts                                           *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_D744:
@scrollLeft                                           * .scrollLeft:
        ldd   x_pos,u
        subd  glb_camera_x_pos
        subd  #$80-8
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
        ldd   x_pos,u
        subd  glb_camera_x_pos
        subd  #$80
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
        rts                                           *         rts
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
                                                      *         move.w  y_pos(a0),d0
                                                      *         sub.w   (a1),d0         ; subtract camera Y pos
                                                      *         cmpi.w  #-$100,(Camera_Min_Y_pos).w ; does the level wrap vertically?
                                                      *         bne.s   .noWrap         ; if not, branch
                                                      *         andi.w  #$7FF,d0
                                                      * ; loc_D78E:
                                                      * .noWrap:
                                                      *         btst    #2,status(a0)   ; is the player rolling?
                                                      *         beq.s   .notRolling     ; if not, branch
                                                      *         subq.w  #5,d0           ; subtract difference between standing and rolling heights
                                                      * ; loc_D798:
                                                      * .notRolling:
                                                      *         btst    #1,status(a0)                   ; is the player in the air?
                                                      *         beq.s   .checkBoundaryCrossed_onGround  ; if not, branch
                                                      * ;.checkBoundaryCrossed_inAir:
                                                      *         ; If Sonic's in the air, he has $20 pixels above and below him to move without disturbing the camera.
                                                      *         ; The camera movement is also only capped at $10 pixels.
                                                      *         addi.w  #$20,d0
                                                      *         sub.w   d3,d0
                                                      *         bcs.s   .doScroll_fast  ; If Sonic is above the boundary, scroll to catch up to him
                                                      *         subi.w  #$40,d0
                                                      *         bcc.s   .doScroll_fast  ; If Sonic is below the boundary, scroll to catch up to him
                                                      *         tst.b   (Camera_Max_Y_Pos_Changing).w   ; is the max Y pos changing?
                                                      *         bne.s   .scrollUpOrDown_maxYPosChanging ; if it is, branch
                                                      *         bra.s   .doNotScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D7B6:
                                                      * .checkBoundaryCrossed_onGround:
                                                      *         ; On the ground, the camera follows Sonic very strictly.
                                                      *         sub.w   d3,d0                           ; subtract camera bias
                                                      *         bne.s   .decideScrollType               ; If Sonic has moved, scroll to catch up to him
                                                      *         tst.b   (Camera_Max_Y_Pos_Changing).w   ; is the max Y pos changing?
                                                      *         bne.s   .scrollUpOrDown_maxYPosChanging ; if it is, branch
                                                      * ; loc_D7C0:
                                                      * .doNotScroll:
                                                      *         clr.w   (a4)            ; clear Y position difference (Camera_Y_pos_bias)
                                                      *         rts
                                                      * ; ===========================================================================
                                                      * ; loc_D7C4:
                                                      * .decideScrollType:
                                                      *         cmpi.w  #(224/2)-16,d3          ; is the camera bias normal?
                                                      *         bne.s   .doScroll_slow  ; if not, branch
                                                      *         mvabs.w inertia(a0),d1  ; get player ground velocity, force it to be positive
                                                      *         cmpi.w  #$800,d1        ; is the player travelling very fast?
                                                      *         bhs.s   .doScroll_fast  ; if he is, branch
                                                      * ;.doScroll_medium:
                                                      *         move.w  #6<<8,d1        ; If player is going too fast, cap camera movement to 6 pixels per frame
                                                      *         cmpi.w  #6,d0           ; is player going down too fast?
                                                      *         bgt.s   .scrollDown_max ; if so, move camera at capped speed
                                                      *         cmpi.w  #-6,d0          ; is player going up too fast?
                                                      *         blt.s   .scrollUp_max   ; if so, move camera at capped speed
                                                      *         bra.s   .scrollUpOrDown ; otherwise, move camera at player's speed
                                                      * ; ===========================================================================
                                                      * ; loc_D7EA:
                                                      * .doScroll_slow:
                                                      *         move.w  #2<<8,d1        ; If player is going too fast, cap camera movement to 2 pixels per frame
                                                      *         cmpi.w  #2,d0           ; is player going down too fast?
                                                      *         bgt.s   .scrollDown_max ; if so, move camera at capped speed
                                                      *         cmpi.w  #-2,d0          ; is player going up too fast?
                                                      *         blt.s   .scrollUp_max   ; if so, move camera at capped speed
                                                      *         bra.s   .scrollUpOrDown ; otherwise, move camera at player's speed
                                                      * ; ===========================================================================
                                                      * ; loc_D7FC:
                                                      * .doScroll_fast:
                                                      *         ; related code appears in ScrollBG
                                                      *         ; S3K uses 24 instead of 16
                                                      *         move.w  #16<<8,d1       ; If player is going too fast, cap camera movement to $10 pixels per frame
                                                      *         cmpi.w  #16,d0          ; is player going down too fast?
                                                      *         bgt.s   .scrollDown_max ; if so, move camera at capped speed
                                                      *         cmpi.w  #-16,d0         ; is player going up too fast?
                                                      *         blt.s   .scrollUp_max   ; if so, move camera at capped speed
                                                      *         bra.s   .scrollUpOrDown ; otherwise, move camera at player's speed
                                                      * ; ===========================================================================
                                                      * ; loc_D80E:
                                                      * .scrollUpOrDown_maxYPosChanging:
                                                      *         moveq   #0,d0           ; Distance for camera to move = 0
                                                      *         move.b  d0,(Camera_Max_Y_Pos_Changing).w        ; clear camera max Y pos changing flag
                                                      * ; loc_D814:
                                                      * .scrollUpOrDown:
                                                      *         moveq   #0,d1
                                                      *         move.w  d0,d1           ; get position difference
                                                      *         add.w   (a1),d1         ; add old camera Y position
                                                      *         tst.w   d0              ; is the camera to scroll down?
                                                      *         bpl.w   .scrollDown     ; if it is, branch
                                                      *         bra.w   .scrollUp
                                                      * ; ===========================================================================
                                                      * ; loc_D824:
                                                      * .scrollUp_max:
                                                      *         neg.w   d1      ; make the value negative (since we're going backwards)
                                                      *         ext.l   d1
                                                      *         asl.l   #8,d1   ; move this into the upper word, so it lines up with the actual y_pos value in Camera_Y_pos
                                                      *         add.l   (a1),d1 ; add the two, getting the new Camera_Y_pos value
                                                      *         swap    d1      ; actual Y-coordinate is now the low word
                                                      * ; loc_D82E:
                                                      * .scrollUp:
                                                      *         cmp.w   Camera_Min_Y_pos-Camera_Min_X_pos(a2),d1        ; is the new position less than the minimum Y pos?
                                                      *         bgt.s   .doScroll       ; if not, branch
                                                      *         cmpi.w  #-$100,d1
                                                      *         bgt.s   .minYPosReached
                                                      *         andi.w  #$7FF,d1
                                                      *         andi.w  #$7FF,(a1)
                                                      *         bra.s   .doScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D844:
                                                      * .minYPosReached:
                                                      *         move.w  Camera_Min_Y_pos-Camera_Min_X_pos(a2),d1        ; prevent camera from going any further up
                                                      *         bra.s   .doScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D84A:
                                                      * .scrollDown_max:
                                                      *         ext.l   d1
                                                      *         asl.l   #8,d1           ; move this into the upper word, so it lines up with the actual y_pos value in Camera_Y_pos
                                                      *         add.l   (a1),d1         ; add the two, getting the new Camera_Y_pos value
                                                      *         swap    d1              ; actual Y-coordinate is now the low word
                                                      * ; loc_D852:
                                                      * .scrollDown:
                                                      *         cmp.w   Camera_Max_Y_pos_now-Camera_Min_X_pos(a2),d1    ; is the new position greater than the maximum Y pos?
                                                      *         blt.s   .doScroll       ; if not, branch
                                                      *         subi.w  #$800,d1
                                                      *         bcs.s   .maxYPosReached
                                                      *         subi.w  #$800,(a1)
                                                      *         bra.s   .doScroll
                                                      * ; ===========================================================================
                                                      * ; loc_D864:
                                                      * .maxYPosReached:
                                                      *         move.w  Camera_Max_Y_pos_now-Camera_Min_X_pos(a2),d1    ; prevent camera from going any further down
                                                      * ; loc_D868:
                                                      * .doScroll:
                                                      *         move.w  (a1),d4         ; get old pos (used by SetVertiScrollFlags)
                                                      *         swap    d1              ; actual Y-coordinate is now the high word, as Camera_Y_pos expects it
                                                      *         move.l  d1,d3
                                                      *         sub.l   (a1),d3
                                                      *         ror.l   #8,d3
                                                      *         move.w  d3,(a4)         ; set difference between old and new positions
                                                      *         move.l  d1,(a1)         ; set new camera Y pos
        rts                                           *         rts
                                                      * ; End of function ScrollVerti
