* ---------------------------------------------------------------------------
* Subroutine to animate a sprite using an animation script
* - reload current frame or load a new animation frame
* - this routine does not play the animation
*
* input REG : [u] object data ptr
*
* ---------------------------------------------------------------------------

AnimateSpriteAdvLoad
        _GetCartPageA
        sta   @rts+1
        ldx   #Ani_Page_Index
        ldb   id,u
        abx
        lda   ,x
        _SetCartPageA
;
        ldx   anim,u
        bpl   @adr                     ; branch if anim is an address of anim
        ldx   #Ani_Asd_Index           ; negative means anim,u is a signed 8 bit offset for a LUT
        ; ldb   id,u                   ; already loaded
        aslb
        abx
        ldx   [,x]                     ; load Anim LUT (first entry in Asd LUT)
        ldb   anim+1,u                 ; load offset
        abx                            ; apply offset
        ldx   ,x                       ; load target anim address
@adr    cmpx  prev_anim,u
        beq   @a
        stx   prev_anim,u
        ldb   #0
        stb   anim_frame,u
	bra   @b
@a      ldb   anim_frame,u
	beq   @b                       ; frame 0 means just initialized skip dec compensation
	decb                           ; otherwise frame is in progress (remember AnimateSprite sets one frame ahead after each tick)
@b      lda   #4
        mul
        leax  d,x
        ldd   ,x
        std   image_set,u
        ldd   2,x
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
        leax  object_core_size,u
        jsr   [,x]
;
@rts
        lda   #$00
        _SetCartPageA
        rts