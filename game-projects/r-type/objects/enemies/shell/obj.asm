; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------


        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0          equ  ext_variables     ; AABB struct (9 bytes)
angle           equ  ext_variables+9   ; 8.8
child_ptr       equ  ext_variables+11  ; 16
son_ptr         equ  ext_variables+13
dad_ptr         equ  ext_variables+15
is_destroyed    equ  ext_variables+17
kill_my_nok     equ  ext_variables+18
current_p       equ  ext_variables+19
angle_step equ 16
center_of_circle equ 882

; child offsets

parent         equ  ext_variables
old_pos_0      equ  ext_variables+2
old_pos_1      equ  ext_variables+4

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   CreateChilds
        fdb   Init
        fdb   Live
        fdb   LiveEye
        fdb   Destroyed
        fdb   AlreadyDeleted

CreateChilds
        stu   @u
        lda   #14
        sta   childs
        lda   #angle_step*-8
        sta   cur_angle
        ldy   #0
        sty   @dad
@loop   jsr   LoadObject_u             ; create background object
        beq   @nomore                  ; branch if no more available object slot
        lda   #ObjID_shellmask         ; must set the id before calling next loadobject routine
        sta   id,u
        lda   #7
        sta   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
        jsr   LoadObject_x             ; create shell object
        ; background object
        beq   @nomore
        stx   parent,u
        stu   child_ptr,x
        ldy   #0
@dad    equ   *-2
        sty   dad_ptr,x                ; Child declares its parent
        beq   >                        ; Child has no parent, no need to declare itself
        stx   son_ptr,y                ; Child declares itself to its parent
!
        stx   @dad                     ; Save current pointer for next child to declare its parent
        ; shell object
        lda   #ObjID_shell
        sta   id,x
        _ldd  angle_step*-8,0 ; start pos
cur_angle equ *-2
        std   angle,x
        adda  #angle_step
        sta   cur_angle
        lda   #1
        sta   routine,x
        lda   childs
        cmpa  #11
        bne   >
        ldb   #1
        stb   subtype,x
!       deca
        sta   childs
        bne   @loop
@nomore
        ldu   #0
@u      equ   *-2
        jmp   DeleteObject
 
childs fcb 0

LiveEye
        ldx   #ImagesEye
        bra   LiveContinue

Init
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask|render_overlay_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        leax  AABB_0,u
        lda   #1                       ; set damage potential for this hitbox
        ldb   subtype,u
        beq   >
        lda   #2
!
        sta   AABB.p,x
        sta   current_p,u
        _ldd  7,17                     ; set hitbox xy radius
        std   AABB.rx,x


        lda   subtype,u
        beq   >
        lda   #3
        sta   routine,u
        bra   LiveEye
!       inc   routine,u

Live
        ldx   #Images
LiveContinue
        lda   gfxlock.frameDrop.count
        ldb   #$60
        mul
        addd  angle,u
        std   angle,u
        adda  #-angle_step/2
        lsra
        lsra
        lsra
        ldb   render_flags,u
        bita  #%00010000
        beq   >
        orb   #render_xmirror_mask|render_ymirror_mask
        bra   @else
!       andb  #^(render_xmirror_mask|render_ymirror_mask)
@else   stb   render_flags,u
        anda  #%00011110
        ldx   a,x
        stx   image_set,u
        sta   @a
; do the maths
;        ldb   angle,u
;        jsr   CalcSine
;        stx   @x
;        ldx   #40           ; circle radius
;        jsr   Mul9x16
;        addd  #916          ; x center of circle
;        std   x_pos,u
;        addd  #40*2+14/2
;        cmpd  glb_camera_x_pos
;        ble   >
;        ldd   #0
;@x      equ *-2
;        ldx   #56           ; circle radius
;        jsr   Mul9x16
;        addd  #82           ; y center of circle
;        std   y_pos,u
; or precalc positions
        ldx   #XPositions
        ldb   angle,u
        ldb   b,x
        sex
        addd  #center_of_circle ; x center of circle
        std   x_pos,u
        leax  AABB_0,u
        addd  #55+8             ; circle 2*x_radius + max sprite radius in any positions
        cmpd  glb_camera_x_pos
        lble  Delete
        subd  glb_camera_x_pos
        subd  #55+8
        stb   AABB.cx,x
        ldy   #YPositions
        ldb   angle,u
        ldb   b,y
        sex
        addd  #101               ; y center of circle
        std   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        lda   AABB.p,x
        beq   @destroy          ; was killed
        cmpa  #255
        beq   >
        sta   current_p,u
!
        lda   kill_my_nok,u
        bita  #$03
        bne   @destroy
        asra
        asra
        sta   kill_my_nok,u
        ldb   current_p,u
        ldy   player1+x_pos     ; Starts testing if shell is vulnerable
        lda   subtype,u
        lda   #0                ; Contains current image number
@a      equ   *-1
        cmpa  #14
        bgt   @facingleft
        cmpy  x_pos,u           ; Canons facing right
        bgt   >
        ldb   #255
!
        stb   AABB.p,x
        jmp   DisplaySprite
@facingleft
        cmpy  x_pos,u           ; Canons facing left
        blt   >
        ldb   #255
!
        stb   AABB.p,x
        jmp   DisplaySprite
@destroy
        ldb   #255
        stb   AABB.p,x
        lda   #4
        sta   routine,u
        ldx   #Img_shellbroken
        stx   image_set,u
        jsr   LoadObject_x
        beq   >
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
!
        lda   subtype,u
        beq   >
        ldx   dad_ptr,u         ; The eye sends the order to destroy his direct son and dad
        ldb   #4                ; =4 => Next of kin to kill is dad
        stb   kill_my_nok,x
        ldx   son_ptr,u
        aslb                    ; =8 => Next of kin to kill is son
        stb   kill_my_nok,x
        jmp   DisplaySprite
!
        lda   kill_my_nok,u     ; Not the eye, is there an order to self destroy ?
        bita  #$03
        bne   >
        jmp   DisplaySprite
!
        ldx   dad_ptr,u         ; Order to self destroy has been received
        lbeq  DisplaySprite     ; No dad (so sad)
        cmpa  #2
        bne   >
        ldx   son_ptr,u         ; Son to be destroyed, not dad
        lbeq  DisplaySprite     ; No son (not so sad, tons of time available)
!
        asla                    ; Set the order back to initial value ... 
        asla
        sta   kill_my_nok,x     ; ... and assign it to next of kin
        clr   kill_my_nok,u     ; Cancel order for self, this is taken care now 
        jmp   DisplaySprite
Delete
        lda   #5
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        ldx   child_ptr,u
        jsr   DeleteObject_x    ; destroy child object
        jmp   DeleteObject
AlreadyDeleted
        rts
Destroyed
        lda   gfxlock.frameDrop.count
        ldb   #$60
        mul
        addd  angle,u
        std   angle,u
        ldx   #XPositions
        ldb   angle,u
        ldb   b,x
        sex
        addd  #center_of_circle ; x center of circle
        std   x_pos,u
        leax  AABB_0,u
        addd  #55+8             ; circle 2*x_radius + max sprite radius in any positions
        cmpd  glb_camera_x_pos
        ble   Delete
        subd  glb_camera_x_pos
        subd  #55+8
        stb   AABB.cx,x
        ldy   #YPositions
        ldb   angle,u
        ldb   b,y
        sex
        addd  #101               ; y center of circle
        std   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        lda   kill_my_nok,u
        bne   >
        jmp   DisplaySprite
!
        bita  #$03
        bne   >
        asra
        asra
        sta   kill_my_nok,u
        jmp   DisplaySprite
!
        ldx   dad_ptr,u         ; I'm already destroyed, but I need to destroy my next of kin, is it dad ?
        lbeq  DisplaySprite     ; No dad (so sad)
        cmpa  #2
        bne   >
        ldx   son_ptr,u         ; Son to be destroyed, not dad
        lbeq  DisplaySprite     ; No son (not so sad, tons of time available)
!
        asla                    ; Set the order back to initial value ... 
        asla
        sta   kill_my_nok,x     ; ... and assign it to next of kin
        clr   kill_my_nok,u     ; Cancel order for self, this is taken care of now 
        jmp   DisplaySprite


Images
        fdb   Img_shell_7
        fdb   Img_shell_6
        fdb   Img_shell_5
        fdb   Img_shell_4
        fdb   Img_shell_3
        fdb   Img_shell_2
        fdb   Img_shell_1
        fdb   Img_shell_0
        fdb   Img_shell_7
        fdb   Img_shell_6
        fdb   Img_shell_5
        fdb   Img_shell_4
        fdb   Img_shell_3
        fdb   Img_shell_2
        fdb   Img_shell_1
        fdb   Img_shell_0

ImagesEye
        fdb   Img_shelleye_7
        fdb   Img_shelleye_6
        fdb   Img_shelleye_5
        fdb   Img_shelleye_4
        fdb   Img_shelleye_3
        fdb   Img_shelleye_2
        fdb   Img_shelleye_1
        fdb   Img_shelleye_0
        fdb   Img_shelleye_7
        fdb   Img_shelleye_6
        fdb   Img_shelleye_5
        fdb   Img_shelleye_4
        fdb   Img_shelleye_3
        fdb   Img_shelleye_2
        fdb   Img_shelleye_1
        fdb   Img_shelleye_0

XPositions equ *+128 ; signed offset
        fcb   $00
        fcb   $00
        fcb   $01
        fcb   $02
        fcb   $03
        fcb   $04
        fcb   $05
        fcb   $06
        fcb   $07
        fcb   $07
        fcb   $08
        fcb   $09
        fcb   $0A
        fcb   $0B
        fcb   $0C
        fcb   $0C
        fcb   $0D
        fcb   $0E
        fcb   $0F
        fcb   $10
        fcb   $10
        fcb   $11
        fcb   $12
        fcb   $13
        fcb   $14
        fcb   $14
        fcb   $15
        fcb   $16
        fcb   $16
        fcb   $17
        fcb   $18
        fcb   $18
        fcb   $19
        fcb   $1A
        fcb   $1A
        fcb   $1B
        fcb   $1B
        fcb   $1C
        fcb   $1C
        fcb   $1D
        fcb   $1D
        fcb   $1E
        fcb   $1E
        fcb   $1F
        fcb   $1F
        fcb   $20
        fcb   $20
        fcb   $20
        fcb   $21
        fcb   $21
        fcb   $21
        fcb   $22
        fcb   $22
        fcb   $22
        fcb   $22
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $24
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $23
        fcb   $22
        fcb   $22
        fcb   $22
        fcb   $22
        fcb   $21
        fcb   $21
        fcb   $21
        fcb   $20
        fcb   $20
        fcb   $20
        fcb   $1F
        fcb   $1F
        fcb   $1E
        fcb   $1E
        fcb   $1D
        fcb   $1D
        fcb   $1C
        fcb   $1C
        fcb   $1B
        fcb   $1B
        fcb   $1A
        fcb   $1A
        fcb   $19
        fcb   $18
        fcb   $18
        fcb   $17
        fcb   $16
        fcb   $16
        fcb   $15
        fcb   $14
        fcb   $14
        fcb   $13
        fcb   $12
        fcb   $11
        fcb   $10
        fcb   $10
        fcb   $0F
        fcb   $0E
        fcb   $0D
        fcb   $0C
        fcb   $0C
        fcb   $0B
        fcb   $0A
        fcb   $09
        fcb   $08
        fcb   $07
        fcb   $07
        fcb   $06
        fcb   $05
        fcb   $04
        fcb   $03
        fcb   $02
        fcb   $01
        fcb   $00
        fcb   $00
        fcb   $00
        fcb   $FF
        fcb   $FE
        fcb   $FD
        fcb   $FC
        fcb   $FB
        fcb   $FA
        fcb   $F9
        fcb   $F9
        fcb   $F8
        fcb   $F7
        fcb   $F6
        fcb   $F5
        fcb   $F4
        fcb   $F4
        fcb   $F3
        fcb   $F2
        fcb   $F1
        fcb   $F0
        fcb   $F0
        fcb   $EF
        fcb   $EE
        fcb   $ED
        fcb   $EC
        fcb   $EC
        fcb   $EB
        fcb   $EA
        fcb   $EA
        fcb   $E9
        fcb   $E8
        fcb   $E8
        fcb   $E7
        fcb   $E6
        fcb   $E6
        fcb   $E5
        fcb   $E5
        fcb   $E4
        fcb   $E4
        fcb   $E3
        fcb   $E3
        fcb   $E2
        fcb   $E2
        fcb   $E1
        fcb   $E1
        fcb   $E0
        fcb   $E0
        fcb   $E0
        fcb   $DF
        fcb   $DF
        fcb   $DF
        fcb   $DE
        fcb   $DE
        fcb   $DE
        fcb   $DE
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DC
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DD
        fcb   $DE
        fcb   $DE
        fcb   $DE
        fcb   $DE
        fcb   $DF
        fcb   $DF
        fcb   $DF
        fcb   $E0
        fcb   $E0
        fcb   $E0
        fcb   $E1
        fcb   $E1
        fcb   $E2
        fcb   $E2
        fcb   $E3
        fcb   $E3
        fcb   $E4
        fcb   $E4
        fcb   $E5
        fcb   $E5
        fcb   $E6
        fcb   $E6
        fcb   $E7
        fcb   $E8
        fcb   $E8
        fcb   $E9
        fcb   $EA
        fcb   $EA
        fcb   $EB
        fcb   $EC
        fcb   $EC
        fcb   $ED
        fcb   $EE
        fcb   $EF
        fcb   $F0
        fcb   $F0
        fcb   $F1
        fcb   $F2
        fcb   $F3
        fcb   $F4
        fcb   $F4
        fcb   $F5
        fcb   $F6
        fcb   $F7
        fcb   $F8
        fcb   $F9
        fcb   $F9
        fcb   $FA
        fcb   $FB
        fcb   $FC
        fcb   $FD
        fcb   $FE
        fcb   $FF
        fcb   $00

YPositions equ *+128 ; signed offset
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $40
        fcb   $40
        fcb   $40
        fcb   $3F
        fcb   $3F
        fcb   $3E
        fcb   $3E
        fcb   $3D
        fcb   $3C
        fcb   $3C
        fcb   $3B
        fcb   $3A
        fcb   $3A
        fcb   $39
        fcb   $38
        fcb   $37
        fcb   $36
        fcb   $35
        fcb   $35
        fcb   $34
        fcb   $33
        fcb   $31
        fcb   $30
        fcb   $2F
        fcb   $2E
        fcb   $2D
        fcb   $2C
        fcb   $2B
        fcb   $29
        fcb   $28
        fcb   $27
        fcb   $26
        fcb   $24
        fcb   $23
        fcb   $21
        fcb   $20
        fcb   $1F
        fcb   $1D
        fcb   $1C
        fcb   $1A
        fcb   $19
        fcb   $17
        fcb   $16
        fcb   $14
        fcb   $13
        fcb   $11
        fcb   $10
        fcb   $0E
        fcb   $0C
        fcb   $0B
        fcb   $09
        fcb   $08
        fcb   $06
        fcb   $04
        fcb   $03
        fcb   $01
        fcb   $00
        fcb   $FF
        fcb   $FD
        fcb   $FC
        fcb   $FA
        fcb   $F8
        fcb   $F7
        fcb   $F5
        fcb   $F4
        fcb   $F2
        fcb   $F0
        fcb   $EF
        fcb   $ED
        fcb   $EC
        fcb   $EA
        fcb   $E9
        fcb   $E7
        fcb   $E6
        fcb   $E4
        fcb   $E3
        fcb   $E1
        fcb   $E0
        fcb   $DF
        fcb   $DD
        fcb   $DC
        fcb   $DA
        fcb   $D9
        fcb   $D8
        fcb   $D7
        fcb   $D5
        fcb   $D4
        fcb   $D3
        fcb   $D2
        fcb   $D1
        fcb   $D0
        fcb   $CF
        fcb   $CD
        fcb   $CC
        fcb   $CB
        fcb   $CB
        fcb   $CA
        fcb   $C9
        fcb   $C8
        fcb   $C7
        fcb   $C6
        fcb   $C6
        fcb   $C5
        fcb   $C4
        fcb   $C4
        fcb   $C3
        fcb   $C2
        fcb   $C2
        fcb   $C1
        fcb   $C1
        fcb   $C0
        fcb   $C0
        fcb   $C0
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BE
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $BF
        fcb   $C0
        fcb   $C0
        fcb   $C0
        fcb   $C1
        fcb   $C1
        fcb   $C2
        fcb   $C2
        fcb   $C3
        fcb   $C4
        fcb   $C4
        fcb   $C5
        fcb   $C6
        fcb   $C6
        fcb   $C7
        fcb   $C8
        fcb   $C9
        fcb   $CA
        fcb   $CB
        fcb   $CB
        fcb   $CC
        fcb   $CD
        fcb   $CF
        fcb   $D0
        fcb   $D1
        fcb   $D2
        fcb   $D3
        fcb   $D4
        fcb   $D5
        fcb   $D7
        fcb   $D8
        fcb   $D9
        fcb   $DA
        fcb   $DC
        fcb   $DD
        fcb   $DF
        fcb   $E0
        fcb   $E1
        fcb   $E3
        fcb   $E4
        fcb   $E6
        fcb   $E7
        fcb   $E9
        fcb   $EA
        fcb   $EC
        fcb   $ED
        fcb   $EF
        fcb   $F0
        fcb   $F2
        fcb   $F4
        fcb   $F5
        fcb   $F7
        fcb   $F8
        fcb   $FA
        fcb   $FC
        fcb   $FD
        fcb   $FF
        fcb   $00
        fcb   $01
        fcb   $03
        fcb   $04
        fcb   $06
        fcb   $08
        fcb   $09
        fcb   $0B
        fcb   $0C
        fcb   $0E
        fcb   $10
        fcb   $11
        fcb   $13
        fcb   $14
        fcb   $16
        fcb   $17
        fcb   $19
        fcb   $1A
        fcb   $1C
        fcb   $1D
        fcb   $1F
        fcb   $20
        fcb   $21
        fcb   $23
        fcb   $24
        fcb   $26
        fcb   $27
        fcb   $28
        fcb   $29
        fcb   $2B
        fcb   $2C
        fcb   $2D
        fcb   $2E
        fcb   $2F
        fcb   $30
        fcb   $31
        fcb   $33
        fcb   $34
        fcb   $35
        fcb   $35
        fcb   $36
        fcb   $37
        fcb   $38
        fcb   $39
        fcb   $3A
        fcb   $3A
        fcb   $3B
        fcb   $3C
        fcb   $3C
        fcb   $3D
        fcb   $3E
        fcb   $3E
        fcb   $3F
        fcb   $3F
        fcb   $40
        fcb   $40
        fcb   $40
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41
        fcb   $41