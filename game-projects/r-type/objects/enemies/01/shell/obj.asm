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

AABB_0     equ  ext_variables     ; AABB struct (9 bytes)
angle      equ  ext_variables+9   ; 8.8
child_ptr  equ  ext_variables+11  ; 16
son_ptr    equ  ext_variables+13
dad_ptr    equ  ext_variables+15
angle_step equ 16

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

CreateChilds
        stu   @u
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
        _ldd  -angle_step*0,0 ; start pos
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
        ldu   #0
@u      equ   *-2
@nomore jmp   DeleteObject
        rts

childs fcb 14

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
        lda   #255                     ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  6,16                     ; set hitbox xy radius
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
        lda   Vint_Main_runcount
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
        addd  #190   ; #1032         ; x center of circle
        std   x_pos,u

        leax  AABB_0,u
        addd  #55+8         ; circle 2*x_radius + max sprite radius in any positions
        cmpd  glb_camera_x_pos
        ble   Delete
        subd  glb_camera_x_pos
        subd  #55+8
        stb   AABB.cx,x

        ldy   #YPositions
        ldb   angle,u
        ldb   b,y
        sex
        addd  #84           ; y center of circle
        std   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x



        jmp   DisplaySprite

Delete
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        ldx   child_ptr,u
        jsr   DeleteObject_x ; destroy child object
        jmp   DeleteObject

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
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $39
        fcb   $39
        fcb   $39
        fcb   $38
        fcb   $38
        fcb   $38
        fcb   $37
        fcb   $37
        fcb   $36
        fcb   $35
        fcb   $35
        fcb   $34
        fcb   $34
        fcb   $33
        fcb   $32
        fcb   $31
        fcb   $31
        fcb   $30
        fcb   $2F
        fcb   $2E
        fcb   $2D
        fcb   $2C
        fcb   $2B
        fcb   $2A
        fcb   $29
        fcb   $28
        fcb   $27
        fcb   $26
        fcb   $25
        fcb   $24
        fcb   $23
        fcb   $21
        fcb   $20
        fcb   $1F
        fcb   $1E
        fcb   $1D
        fcb   $1B
        fcb   $1A
        fcb   $19
        fcb   $17
        fcb   $16
        fcb   $15
        fcb   $13
        fcb   $12
        fcb   $11
        fcb   $0F
        fcb   $0E
        fcb   $0C
        fcb   $0B
        fcb   $0A
        fcb   $08
        fcb   $07
        fcb   $05
        fcb   $04
        fcb   $02
        fcb   $01
        fcb   $00
        fcb   $FF
        fcb   $FE
        fcb   $FC
        fcb   $FB
        fcb   $F9
        fcb   $F8
        fcb   $F6
        fcb   $F5
        fcb   $F4
        fcb   $F2
        fcb   $F1
        fcb   $EF
        fcb   $EE
        fcb   $ED
        fcb   $EB
        fcb   $EA
        fcb   $E9
        fcb   $E7
        fcb   $E6
        fcb   $E5
        fcb   $E3
        fcb   $E2
        fcb   $E1
        fcb   $E0
        fcb   $DF
        fcb   $DD
        fcb   $DC
        fcb   $DB
        fcb   $DA
        fcb   $D9
        fcb   $D8
        fcb   $D7
        fcb   $D6
        fcb   $D5
        fcb   $D4
        fcb   $D3
        fcb   $D2
        fcb   $D1
        fcb   $D0
        fcb   $CF
        fcb   $CF
        fcb   $CE
        fcb   $CD
        fcb   $CC
        fcb   $CC
        fcb   $CB
        fcb   $CB
        fcb   $CA
        fcb   $C9
        fcb   $C9
        fcb   $C8
        fcb   $C8
        fcb   $C8
        fcb   $C7
        fcb   $C7
        fcb   $C7
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C5
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C6
        fcb   $C7
        fcb   $C7
        fcb   $C7
        fcb   $C8
        fcb   $C8
        fcb   $C8
        fcb   $C9
        fcb   $C9
        fcb   $CA
        fcb   $CB
        fcb   $CB
        fcb   $CC
        fcb   $CC
        fcb   $CD
        fcb   $CE
        fcb   $CF
        fcb   $CF
        fcb   $D0
        fcb   $D1
        fcb   $D2
        fcb   $D3
        fcb   $D4
        fcb   $D5
        fcb   $D6
        fcb   $D7
        fcb   $D8
        fcb   $D9
        fcb   $DA
        fcb   $DB
        fcb   $DC
        fcb   $DD
        fcb   $DF
        fcb   $E0
        fcb   $E1
        fcb   $E2
        fcb   $E3
        fcb   $E5
        fcb   $E6
        fcb   $E7
        fcb   $E9
        fcb   $EA
        fcb   $EB
        fcb   $ED
        fcb   $EE
        fcb   $EF
        fcb   $F1
        fcb   $F2
        fcb   $F4
        fcb   $F5
        fcb   $F6
        fcb   $F8
        fcb   $F9
        fcb   $FB
        fcb   $FC
        fcb   $FE
        fcb   $FF
        fcb   $00
        fcb   $01
        fcb   $02
        fcb   $04
        fcb   $05
        fcb   $07
        fcb   $08
        fcb   $0A
        fcb   $0B
        fcb   $0C
        fcb   $0E
        fcb   $0F
        fcb   $11
        fcb   $12
        fcb   $13
        fcb   $15
        fcb   $16
        fcb   $17
        fcb   $19
        fcb   $1A
        fcb   $1B
        fcb   $1D
        fcb   $1E
        fcb   $1F
        fcb   $20
        fcb   $21
        fcb   $23
        fcb   $24
        fcb   $25
        fcb   $26
        fcb   $27
        fcb   $28
        fcb   $29
        fcb   $2A
        fcb   $2B
        fcb   $2C
        fcb   $2D
        fcb   $2E
        fcb   $2F
        fcb   $30
        fcb   $31
        fcb   $31
        fcb   $32
        fcb   $33
        fcb   $34
        fcb   $34
        fcb   $35
        fcb   $35
        fcb   $36
        fcb   $37
        fcb   $37
        fcb   $38
        fcb   $38
        fcb   $38
        fcb   $39
        fcb   $39
        fcb   $39
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3A
        fcb   $3B
