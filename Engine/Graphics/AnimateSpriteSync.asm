* ---------------------------------------------------------------------------
* Subroutine to animate a sprite using an animation script
* Use VBL to keep a constant animation rate
*
* input REG : [u] pointeur sur l'objet
*
* ---------------------------------------------------------------------------

                                            *; ---------------------------------------------------------------------------
                                            *; Subroutine to animate a sprite using an animation script
                                            *; ---------------------------------------------------------------------------
                                            *
                                            *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                            *
                                            *; sub_16544:
AnimateSpriteSync                           *AnimateSprite:
                                            *    moveq   #0,d0
        _GetCartPageA
        sta   Anim_Rts+1                    ; backup cart page     
        ldx   #Ani_Page_Index
        ldb   id,u
        abx
        lda   ,x
        _SetCartPageA
;
        ldx   anim,u                        *    move.b  anim(a0),d0      ; move animation number to d0
        bpl   @a                       ; branch if anim is an address of anim
        ldx   #Ani_Asd_Index           ; negative means anim,u is a signed 8 bit offset for a LUT
        ; ldb   id,u                   ; already loaded
        aslb
        abx
        ldx   [,x]                     ; load Anim LUT (first entry in Asd LUT)
        ldb   anim+1,u                 ; load offset
        abx                            ; apply offset
        ldx   ,x                       ; load target anim address
@a      cmpx  prev_anim,u                   *    cmp.b   prev_anim(a0),d0 ; is animation set to change?
        beq   Anim_Run                      *    beq.s   Anim_Run         ; if not, branch
        stx   prev_anim,u                   *    move.b  d0,prev_anim(a0) ; set prev anim to current animation
        
        lda   anim_flags,u
        anda  #anim_link_mask               ; if animation link, when changing animation
        bne   Anim_Reload                   ; will skip frame and duration reinit
        
        ldb   #0                            
        stb   anim_frame,u                  *    move.b  #0,anim_frame(a0)          ; reset animation
        stb   anim_frame_duration,u         *    move.b  #0,anim_frame_duration(a0) ; reset frame duration
                                            *; loc_16560:
Anim_Run                                    *Anim_Run:
        ldb   anim_frame_duration,u
        subb  Vint_Main_runcount
        stb   anim_frame_duration,u
                                            *    subq.b  #1,anim_frame_duration(a0)   ; subtract 1 from frame duration
        bpl   Anim_Rts                      *    bpl.s   Anim_Wait                    ; if time remains, branch
        * no offset table                   *    add.w   d0,d0
        * anim is the address of anim       *    adda.w  (a1,d0.w),a1                 ; calculate address of appropriate animation script
        ldb   -1,x                            
        stb   anim_frame_duration,u         *    move.b  (a1),anim_frame_duration(a0) ; load frame duration
Anim_Reload                                 *    moveq   #0,d1
        ldb   anim_frame,u                  *    move.b  anim_frame(a0),d1 ; load current frame number
        lda   #0
        _asld
        leay  d,x
        ldd   ,y                            *    move.b  1(a1,d1.w),d0 ; read sprite number from script
        * bmi   Anim_End_FF                 *    bmi.s   Anim_End_FF   ; if animation is complete, branch MJ: Delete this line
        cmpa  #$FA                          *    cmp.b   #$FA,d0       ; MJ: is it a flag from FA to FF?
        bhs   Anim_End_FF                   *    bhs     Anim_End_FF   ; MJ: if so, branch to flag routines
                                            *; loc_1657C:
Anim_Next                                   *Anim_Next:
                                            *    andi.b  #$7F,d0               ; clear sign bit
        std   image_set,u                   *    move.b  d0,mapping_frame(a0)  ; load sprite number
        lda   status_flags,u
        anda  #status_xflip_mask|status_yflip_mask
        sta   @dyn+1
        lda   render_flags,u
        anda  #^render_xmirror_mask
@dyn    ora   #0
        sta   render_flags,u
                                            *    move.b  status(a0),d1         ; match the orientaion dictated by the object
                                            *    andi.b  #3,d1                 ; with the orientation used by the object engine
                                            *    andi.b  #$FC,render_flags(a0)
                                            *    or.b    d1,render_flags(a0)
        inc   anim_frame,u                  *    addq.b  #1,anim_frame(a0)     ; next frame number
                                            *; return_1659A:
Anim_Rts                                    *Anim_Wait:
        lda   #$00                          ; (dynamic)
        _SetCartPageA                       ; restore data page
        rts                                 *    rts 
                                            *; ===========================================================================
                                            *; loc_1659C:
Anim_End_FF                                 *Anim_End_FF:
        inca                                *    addq.b  #1,d0       ; is the end flag = $FF ?
        bne   Anim_End_FE                   *    bne.s   Anim_End_FE ; if not, branch
        ldb   #0                            
        stb   anim_frame,u                  *    move.b  #0,anim_frame(a0) ; restart the animation
        ldd   ,x                            *    move.b  1(a1),d0          ; read sprite number
        bra   Anim_Next                     *    bra.s   Anim_Next
                                            *; ===========================================================================
                                            *; loc_165AC:
Anim_End_FE                                 *Anim_End_FE:
        inca                                *    addq.b  #1,d0             ; is the end flag = $FE ?
        bne   Anim_End_FD                   *    bne.s   Anim_End_FD       ; if not, branch
        lda   anim_frame,u                  
        stb   Anim_End_FE_dyn+1             *    move.b  2(a1,d1.w),d0     ; read the next byte in the script
Anim_End_FE_dyn
        suba  #$00                          ; (dynamic)                          
        sta   anim_frame,u                  *    sub.b   d0,anim_frame(a0) ; jump back d0 bytes in the script
                                            *    sub.b   d0,d1
        ldb   #2
        mul                                             
        ldd   d,x                           *    move.b  1(a1,d1.w),d0     ; read sprite number
        bra   Anim_Next                     *    bra.s   Anim_Next
                                            *; ===========================================================================
                                            *; loc_165C0:
Anim_End_FD                                 *Anim_End_FD:
        inca                                *    addq.b  #1,d0               ; is the end flag = $FD ?
        bne   Anim_End_FC                   *    bne.s   Anim_End_FC         ; if not, branch
        ldd   1,y                           ; read word after FD
        std   anim,u                        *    move.b  2(a1,d1.w),anim(a0) ; read next byte, run that animation
        bra   Anim_Rts                      *    rts
                                            *; ===========================================================================
                                            *; loc_165CC:
Anim_End_FC                                 *Anim_End_FC:
        inca                                *    addq.b  #1,d0          ; is the end flag = $FC ?
        bne   Anim_End_FB                   *    bne.s   Anim_End_FB    ; if not, branch
        inc   routine,u                     *    addq.b  #2,routine(a0) ; jump to next routine
        lda   #0                            
        sta   anim_frame_duration,u         *    move.b  #0,anim_frame_duration(a0)
        inc   anim_frame,u                  *    addq.b  #1,anim_frame(a0)
        bra   Anim_Rts                      *    rts
                                            *; ===========================================================================
                                            *; loc_165E0:
Anim_End_FB                                 *Anim_End_FB:
        inca                                *    addq.b  #1,d0                 ; is the end flag = $FB ?
        bne   Anim_End_FA                   *    bne.s   Anim_End_FA           ; if not, branch
        lda   #0                            
        sta   anim_frame,u                  *    move.b  #0,anim_frame(a0)     ; reset animation
        sta   routine_secondary,u           *    clr.b   routine_secondary(a0) ; reset 2nd routine counter
        bra   Anim_Rts                      *    rts
                                            *; ===========================================================================
                                            *; loc_165F0:
Anim_End_FA                                 *Anim_End_FA:
        inca                                *    addq.b  #1,d0                    ; is the end flag = $FA ?
        bne   Anim_End                      *    bne.s   Anim_End_F9              ; if not, branch
        inc   routine_secondary,u           *    addq.b  #2,routine_secondary(a0) ; jump to next routine    
Anim_End               
        bra   Anim_Rts                      *    rts
                                            *; ===========================================================================
                                            *; loc_165FA:
                                            *Anim_End_F9:
                                            *    addq.b  #1,d0            ; is the end flag = $F9 ?
                                            *    bne.s   Anim_End         ; if not, branch
                                            *    addq.b  #2,objoff_2A(a0) ; Actually obj89_arrow_routine
                                            *; return_16602:
                                            *Anim_End:
                                            *    rts
                                            *; End of function AnimateSprite