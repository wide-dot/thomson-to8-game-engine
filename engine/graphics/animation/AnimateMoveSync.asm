* ---------------------------------------------------------------------------
* AnimateMoveSync
* ---------------
* Read x,y velocity and animation frame from sub-scripts
*
* ---------------------------------------------------------------------------

anim_entry equ routine_tertiary ; and routine_quaternary ; reference to first animation entry

; register animation data location to routine
; help to save some cycles in main loop
; B : object_id that contains animation data
AnimateMoveSyncRegister
        ldx   #Obj_Index_Page
        abx
        lda   ,x  
        sta   animateMoveSync.anim.page.1
        sta   animateMoveSync.anim.page.2
        sta   animateMoveSync.anim.page.3
        aslb                  
        ldx   #Obj_Index_Address
        abx
        ldd   ,x
        std   animateMoveSync.anim.addr
        rts

; init object animation
; X : index to object entry (use anim-data.equ)
; B : index in animation list (0 if only one animation, 2 for the second anim, ...)
AnimateMoveSyncInit
        _GetCartPageA
        sta   @page
        lda   #0                       ; set object anim data
animateMoveSync.anim.page.1 equ *-1
        _SetCartPageA
        leax  $1234,x                  ; add base address of object anim data
animateMoveSync.anim.addr equ *-2
        ldx   ,x                       ; load animation list ptr
        abx                            ; add index in animations list
        ldx   ,x                       ; load animation
        stx   anim,u
        stx   anim_entry,u             ; save for animation loop
        ldd   ,x                       ; load anim segment
        std   sub_anim,u
        ldx   #0                       ; ignore previous velocity
        stx   x_vel,u
        stx   y_vel,u
        lda   #0
@page   equ   *-1
        _SetCartPageA
        rts

;
; process animation script for current object
;
AnimateMoveSync
        ldb   gfxlock.frameDrop.count
AnimateMoveSteps
        _GetCartPageA
        sta   @page
        lda   #0
animateMoveSync.anim.page.2 equ *-1
        _SetCartPageA
        ldy   sub_anim,u
        beq   @rts
;
        ldx   #0
        stx   x_vel,u
        stx   y_vel,u
;
        stb   glb_d0_b
        beq   >                        ; do a loop when 0
@loop   dec   glb_d0_b
!       bmi   @end
;
        ldb   ,y+                      ; read frame bitfield
@frame
        lslb
        bcc   @xvel
        lda   ,y+
        sta   anim_frame,u
@xvel        
        lslb
        bcc   @yvel
        stb   @b0
        ldd   ,y++
        addd  x_vel,u
        std   x_vel,u
        ldb   #0
@b0     equ   *-1
@yvel
        lslb
        bcc   @anim
        stb   @b1
        ldd   ,y++
        addd  y_vel,u
        std   y_vel,u
        ldb   #0
@b1     equ   *-1
@anim
        lslb
        bcc   @loop
        ldx   anim,u
        leax  2,x
        stx   anim,u
        ldy   ,x
        bne   @loop
@end    sty   sub_anim,u
@rts    lda   #0
@page   equ   *-1
        _SetCartPageA
        rts

;
; process animation script for current object
;
AnimateMoveSyncCallback
        ldb   gfxlock.frameDrop.count
AnimateMoveStepsCallback
        _GetCartPageA
        sta   @page
        lda   #0
animateMoveSync.anim.page.3 equ *-1
        _SetCartPageA
        clr   animateMoveSync.anim.end
        ldy   sub_anim,u
;
        stb   glb_d0_b
        beq   >                        ; do a loop when 0
@loop   dec   glb_d0_b
!       bmi   @end
;
        ldb   ,y+                      ; read frame bitfield
@frame
        lslb
        bcc   @xvel
        lda   ,y+
        sta   anim_frame,u
@xvel        
        lslb
        bcc   @yvel
        stb   @b0
        ldd   ,y++
        addd  x_vel,u
        std   x_vel,u
        ldb   #0
@b0     equ   *-1
@yvel
        lslb
        bcc   @anim
        stb   @b1
        ldd   ,y++
        addd  y_vel,u
        std   y_vel,u
        pshs  x,y
        lda   @page
        _SetCartPageA
        jsr   ObjectMove
        ldx   #0
        stx   x_vel,u
        stx   y_vel,u
        ldx   animateMoveSync.callback
        jsr   ,x
        lda   animateMoveSync.anim.page.3
        _SetCartPageA
        puls  x,y
        ldb   #0
@b1     equ   *-1
@anim
        lslb
        bcc   @loop
        ldx   anim,u
        leax  2,x
        stx   anim,u
        ldy   ,x
        bne   @loop
        ldx   anim_entry,u
        stx   anim,u
        ldy   ,x        
        inc   animateMoveSync.anim.end
@end    sty   sub_anim,u
@rts    lda   #0
@page   equ   *-1
        _SetCartPageA
        rts

animateMoveSync.callback fdb 0
animateMoveSync.anim.end fdb 0