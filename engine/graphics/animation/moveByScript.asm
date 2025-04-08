* ---------------------------------------------------------------------------
* moveByScript
* ---------------
* Read Script composed by segments :
* - position in script (anim,u)
* - position in segment (sub_anim,u)
*
* Segments defines :
* - moves (x_pos,u and y_pos,u)
* - images (anim_frame,u)
* - animation speed (anim_frame_duration,u)
*
* ---------------------------------------------------------------------------

; you must define equates in your code for each move :
; moveByScript.NEGXSTEP : negative x step 
; moveByScript.POSXSTEP : positive x step
; moveByScript.NEGYSTEP : negative y step
; moveByScript.POSYSTEP : positive y step

moveByScript.callback       equ glb_a0     ; object routine that must be called each move step
moveByScript.anim.speed     equ glb_d0     ; number of move steps by frame
moveByScript.anim.end       equ glb_d0_b   ; boolean to inform object that script is over
moveByScript.anim.loops     equ glb_d0_b+1 ; will run the routine n times to compensate frame drop

; register animation data location to routine
; help to save some cycles in main loop
; B : object_id that contains animation data
moveByScript.register
        ldx   #Obj_Index_Page
        abx
        lda   ,x  
        sta   moveByScript.anim.page.1
        sta   moveByScript.anim.page.2
        aslb                  
        ldx   #Obj_Index_Address
        abx
        ldd   ,x
        std   moveByScript.anim.addr
        rts

; X : index of script (use script.equ)
; no need for that in builder v2, will be able to use
; directly the script address equate
moveByScript.initialize
        _GetCartPageA
        sta   @page
        lda   #0                       ; set object anim data
moveByScript.anim.page.1 equ *-1
        _SetCartPageA
        ldx   $1234,x                  ; add base address of LUT to index and load script addr
moveByScript.anim.addr equ *-2
        stx   anim,u
        ldd   ,x                       ; load anim segment
        std   sub_anim,u
        lda   #0
@page   equ   *-1
        _SetCartPageA
        rts

;
; process animation script for current object
;
moveByScript.runByFrameDrop
        ldb   gfxlock.frameDrop.count
moveByScript.runByB
        tstb
        bne   >
        ldb   #1                                              ; prevent running 256 loops if 0 is passed in b
!       stb   moveByScript.anim.loops
        _GetCartPageA
        sta   @page
@loop   lda   #0
moveByScript.anim.page.2 equ *-1
        _SetCartPageA
        lda   anim_frame_duration,u                           ; load number of move commands to read in segment for each frame
        sta   moveByScript.anim.speed
LAB_0000_f9c6
        ldx   sub_anim,u                                      ; load address of current position in segment
        ldb   ,x+                                             ; read first byte of segment
        rolb                                                  ; read first bit as a boolean
        bcs   LAB_0000_fa03                                   ; if boolean is true, branch to change image
        rolb                                                  ; read next bit as a boolean
        bcs   LAB_0000_f9f1                                   ; if boolean is true : branch and decrement x
        rolb                                                  ; read next bit as boolean
        bcc   LAB_0000_f9db                                   ; if boolean is false : branch and increment y
        ldy   x_vel,u
        leay  moveByScript.POSXSTEP,y                         ; increment x position
        sty   x_vel,u
LAB_0000_f9db
        rolb             
        bcs   LAB_0000_f9fa
        rolb             
        bcc   LAB_0000_f9e6
        ldy   y_vel,u
        leay  moveByScript.NEGYSTEP,y                         ; decrement y position (axe is upside down compared to arcade)
        sty   y_vel,u
LAB_0000_f9e6
        rolb                                                  ; read next bit as a boolean
        bcs   LAB_0000_fa0e                                   ; branch if true
LAB_0000_f9ea
        stx   sub_anim,u                                      ; save new segment position
        dec   moveByScript.anim.speed
        bne   LAB_0000_f9c6                                   ; process nb of move commands (bytes) defined by +0x17 object variable
        clr   moveByScript.anim.end                           ; set end to 0, script is not over
        bra   @end
LAB_0000_f9f1
        rolb             
        bcc   LAB_0000_f9db
        ldy   x_vel,u
        leay  moveByScript.NEGXSTEP,y                         ; decrement x position
        sty   x_vel,u
        bra   LAB_0000_f9db
LAB_0000_f9fa
        rolb             
        bcc   LAB_0000_f9e6
        ldy   y_vel,u
        leay  moveByScript.POSYSTEP,y                         ; increment y position (axe is upside down compared to arcade)
        sty   y_vel,u
        bra   LAB_0000_f9e6
LAB_0000_fa03
        lsrb
        ;andb  #$1f
        stb   anim_frame,u                                    ; update current animation frame
        inc   moveByScript.anim.speed                         ; image command does not count as a move command
        bra   LAB_0000_f9ea
LAB_0000_fa0e
        ldx   anim,u
        leax  2,x
        ldd   ,x                                              ; read script command and move to next value in script (may be a segment, an end of script ...)
        beq   LAB_0000_fa2b                                   ; branch if script command is 0 (end of script or goto script)
        stx   anim,u
        cmpa  #$f0
        bne   LAB_0000_fa26                                   ; branch if high byte is not 0xF0
        stb   anim_frame_duration,u                           ; update nb of move command to read in each segment (speed)
        bra   LAB_0000_fa0e
LAB_0000_fa26
        std   sub_anim,u                                      ; store new segment position
        clr   moveByScript.anim.end                           ; set end to 0, script is not over
        bra   @end
LAB_0000_fa2b
        ldx   2,x                                             ; value following the 0 is the new script to jump to (will be used or not by caller routine)
        stx   anim,u                                          ; store new script
        ldd   ,x                                              ; load first segment
        std   sub_anim,u                                      ; store new segment
        lda   #1
        sta   moveByScript.anim.end                           ; set end to 1 to tell caller that script has ended
@end    
        ldb   x_vel,u
        sex                            ; velocity is positive or negative, take care of that
        sta   @a+1
        ldd   x_vel,u
        addd  x_pos+1,u                ; x_pos must be followed by x_sub in memory
        std   x_pos+1,u                ; update low byte of x_pos and x_sub byte
        lda   x_pos,u
@a
        adca  #$00                     ; parameter is modified by the result of sign extend
        sta   x_pos,u                  ; update high byte of x_pos
;
        ldb   y_vel,u
        sex                            ; velocity is positive or negative, take care of that
        sta   @b+1
        ldd   y_vel,u
        addd  y_pos+1,u                ; y_pos must be followed by y_sub in memory
        std   y_pos+1,u                ; update low byte of y_pos and y_sub byte
        lda   y_pos,u
@b
        adca  #$00                     ; parameter is modified by the result of sign extend
        sta   y_pos,u                  ; update high byte of y_pos
 ;
        ldx   #0                                              ; before each callback
        stx   x_vel,u
        stx   y_vel,u
        dec   moveByScript.anim.loops
        ldx   moveByScript.callback
        lda   @page
        _SetCartPageA
        jsr   ,x
        tst   moveByScript.anim.loops
        lbne  @loop
        lda   #0
@page   equ   *-1
        _SetCartPageA
        rts
