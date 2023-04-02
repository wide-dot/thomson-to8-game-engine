* ---------------------------------------------------------------------------
* AnimateSpriteAdvSync
* --------------------
* Subroutine to animate a sprite using an animation script
* - use duration on each frame (instead of a global value)
* - associate a lookup value (with each frame) to a dataset
* - dynamic call of a routine with the lookup value, the address of the
*   routine is stored at the end of objet data table (before ext_var)
* - Sync means frames will be skipped when frame drop occurs
*
* input REG : [u] ptr to object data
*
* ---------------------------------------------------------------------------

AnimateSpriteAdvSync
        _GetCartPageA
        sta   @Anim_Rts+1
        ldx   #Ani_Page_Index
        ldb   id,u
        abx
        lda   ,x
        _SetCartPageA
;
        ldx   anim,u
        bpl   @a                       ; branch if anim is an address of anim
        ldx   #Ani_Asd_Index           ; negative means anim,u is a signed 8 bit offset for a LUT
        ; ldb   id,u                   ; already loaded
        aslb
        abx
        ldx   [,x]                     ; load Anim LUT (first entry in Asd LUT)
        ldb   anim+1,u                 ; load offset
        abx                            ; apply offset
        ldx   ,x                       ; load target anim address
@a      cmpx  prev_anim,u
        beq   @Anim_Run
        stx   prev_anim,u
        ldb   #0
        stb   anim_frame,u
        bra   @b
;
@Anim_Run
        ldb   anim_frame_duration,u
        subb  gfxlock.frameDrop.count
        stb   anim_frame_duration,u
        bpl   @Anim_Rts
@b      ldb   anim_frame,u
        lda   #4
        mul
        leay  d,x
        ldd   ,y
        cmpa  #$FA
        bhs   @Anim_End_FF
;
@Anim_Next
        std   image_set,u
        ldd   2,y
        sta   anim_frame_duration,u
        stb   anim_flags,u
        inc   anim_frame,u
;
; apply sprite status orientation
; -------------------------------
; notice that an orientation change will only take effect
; when a new animation step is loaded,
; unless animation frame duration is 1.
        lda   status_flags,u
        anda  #status_xflip_mask|status_yflip_mask
        sta   @dyn+1
        lda   render_flags,u
        anda  #^(render_xmirror_mask|render_ymirror_mask)
@dyn    ora   #0
        sta   render_flags,u
;
; run specific routine that apply to this animation frame
; -------------------------------------------------------
        leax  object_size,u
        jsr   [,x]
;
@Anim_Rts
        lda   #$00
        _SetCartPageA
        rts
;
@Anim_End_FF ;_resetAnim
        inca
        bne   @Anim_End_FE
        ldb   #0
        stb   anim_frame,u
        leay  ,x
        ldd   ,y
        bra   @Anim_Next
;
@Anim_End_FE ;_goBackNFrames
        inca
        bne   @Anim_End_FD
        lda   anim_frame,u
        _sba
        sta   anim_frame,u
        ldb   #4
        mul
        leay  d,x
        ldd   ,y
        bra   @Anim_Next
;
@Anim_End_FD ;_goToAnimation
        inca
        bne   @Anim_Rts
        ldd   1,y
        std   anim,u
        bra   @Anim_Rts