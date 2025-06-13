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
        INCLUDE "./objects/explosion/explosion.const.asm"

AABB_0          equ ext_variables   ; AABB struct (9 bytes)
missile_0x24	equ ext_variables+10 ; 1 byte - reference value for run mode change frames
missile_0x16    equ ext_variables+11 ; 1 bytes - current image index
missile_0x20    equ ext_variables+12 ; 1 byte - run mode change frames
missile_0x22    equ ext_variables+13 ; 2 bytes - period of tracking (set at $800 - after that, no tracking anymore)
missile_b       equ ext_variables+15 ; 1 byte - temporary B register
missile_flame   equ ext_variables+16 ; 2 bytes

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init                                      ; 0
        fdb   FUN_0000_xxxx_RunTabrokMissileRunMode0    ; 1
        fdb   AlreadyDeleted                            ; 2
        fdb   FUN_0000_6c7d_RunTabrokMissileRunMode1    ; 3

Init

        jsr   LoadObject_x
        beq   >
        lda   #ObjID_tabrokmissileflame
        sta   id,x
        stx   missile_flame,u
!
	ldx   #ImagesIndex
        lda   missile_0x16,u
        asla
        ldx   a,x
	stx   image_set,u
	ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
	inc   routine,u

        _Collision_AddAABB AABB_0,AABB_list_foefire
        
        leax  AABB_0,u
        lda   #1                                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  3,4                                       ; set hitbox xy radius
        std   AABB.rx,x

        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined FUN_0000_xxxx_RunTabrokMissileRunMode0()

FUN_0000_xxxx_RunTabrokMissileRunMode0

        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        lbne  Destroy
        lda   globals.backgroundSolid
        beq   >
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        lbne  Destroy
!
        ; check if bullet is outside the viewport
        ; x axis
        ldd   x_pos,u                                   ; set visibility range
        cmpd  glb_camera_x_pos                          ; destroy if out of range
        lble  Delete
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        lbge  Delete

        ; collision
        leax  AABB_0,u
        lda   AABB.p,x
        lbeq  Destroy

        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x

        lda   missile_0x20,u
        suba  gfxlock.frameDrop.count
        ble   LAB_0000_6c4c
	
        sta   missile_0x20,u


	jsr   ObjectMoveSync
        ldy   missile_flame,u
        beq   >
        ldx   #missileflame_1x2d14
        lda   missile_0x16,u
        asla
        asla
        leax  a,x
        ldd   ,x
        addd  x_pos,u
        std   x_pos,y
        ldd   2,x
        addd  y_pos,u
        std   y_pos,y
!

	jmp   DisplaySprite

LAB_0000_6c4c
        lda   #1
        sta   missile_0x20,u
        ldd   #$800
        std   missile_0x22,u
        lda   #3  ; FUN_0000_6c7d_RunTabrokMissileRunMode1
        sta   routine,u
	jsr   ObjectMoveSync
        ldy   missile_flame,u
        beq   >
        ldx   #missileflame_1x2d14
        lda   missile_0x16,u
        asla
        asla
        leax  a,x
        ldd   ,x
        addd  x_pos,u
        std   x_pos,y
        ldd   2,x
        addd  y_pos,u
        std   y_pos,y
!
	jmp   DisplaySprite        

        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined FUN_0000_6c7d_RunTabrokMissileRunMode1()

FUN_0000_6c7d_RunTabrokMissileRunMode1

        ldd  missile_0x22,u
        bpl  LAB_0000_6c8a
        ; check if bullet is outside the viewport
        ; x axis
        ldd   x_pos,u                                   ; set visibility range
        cmpd  glb_camera_x_pos                          ; destroy if out of range
        lble  Delete
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        lbge  Delete
        jmp   LAB_0000_6cee


LAB_0000_6c8a
        ldx   missile_0x22,u
        lda   gfxlock.frameDrop.count
        nega
        leax  a,x
        stx   missile_0x22,u
        lda   missile_0x20,u
        suba  gfxlock.frameDrop.count
        sta   missile_0x20,u
        bpl   LAB_0000_6cee

        ldx   #player1
        jsr   setDirectionTo
        tfr   y,d
        clra
        asrb
        asrb
        stb   missile_b,u

        cmpb  missile_0x16,u
        bmi   LAB_0000_6cae
        subb  #$8
        bmi   LAB_0000_6cb6
        subb  missile_0x16,u
        bmi   LAB_0000_6cb6
        jmp   LAB_0000_6cbc

LAB_0000_6cae
        lda   missile_0x16,u
        suba  #$8
        bmi   LAB_0000_6cbc
        suba  missile_b,u
        bmi   LAB_0000_6cbc
LAB_0000_6cb6
        inc   missile_0x16,u
        jmp   LAB_0000_6cbf
LAB_0000_6cbc
        dec   missile_0x16,u
LAB_0000_6cbf
        lda   missile_0x16,u
        anda  #$f
        sta   missile_0x16,u
        ldb   globals.difficulty
        ldx   #missile_1x2c8c
        lda   b,x
        ldx   #missile_1x8f90
        leax  a,x
        ldb   missile_0x16,u
        aslb
        aslb
        leax  b,x
        ldd   ,x
        std   x_vel,u
        ldd   2,x
        std   y_vel,u
        lda   missile_0x24,u
        sta   missile_0x20,u
LAB_0000_6cee

        ldx   #ImagesIndex
        lda   missile_0x16,u
        asla
        ldx   a,x
	stx   image_set,u

        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   Destroy
        lda   globals.backgroundSolid
        beq   >
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        bne   Destroy
!
        ; check if bullet is outside the viewport
        ; x axis
        ldd   x_pos,u                                   ; set visibility range
        cmpd  glb_camera_x_pos                          ; destroy if out of range
        ble   Delete
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        bge   Delete

        ; collision
        leax  AABB_0,u
        lda   AABB.p,x
        beq   Destroy

        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x

	jsr   ObjectMoveSync

        ldy   missile_flame,u
        beq   >
        ldx   #missileflame_1x2d14
        lda   missile_0x16,u
        asla
        asla
        leax  a,x
        ldd   ,x
        addd  x_pos,u
        std   x_pos,y
        ldd   2,x
        addd  y_pos,u
        std   y_pos,y
!	jmp   DisplaySprite




Destroy
        ldx   missile_flame,u    ; kill flame sprite
        beq   >
        lda   #1
        sta   ext_variables,x
!
        jsr   LoadObject_x ; make then die early ... to be removed
        beq   Delete
        _ldd  ObjID_explosion,explosion.subtype.fwk
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
Delete
        lda   #2    ; AlreadyDeleted
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_foefire
        jmp   DeleteObject

AlreadyDeleted
	rts



missile_1x8f90
        INCLUDE "./global/preset/18f90_preset-fireVelocity.asm"


missile_1x2c8c
        fdb $00
        fdb $40
        fdb $80
        fdb $c0

missileflame_1x2d14
	fdb $0000,$0009 ; $0000,$fff4
	fdb $fffd,$0008 ; $fff8,$fff5
	fdb $fffd,$0006 ; $fff6,$fff7
	fdb $fffc,$0002 ; $fff4,$fffd

	fdb $fffb,$0000 ; $fff1,$0000
	fdb $fffc,$fffe ; $fff4,$0003
	fdb $fffd,$fffa ; $fff6,$0009
	fdb $fffd,$fff8 ; $fff8,$000b

	fdb $0000,$fff7 ; $0000,$000c
	fdb $0001,$fff8 ; $0003,$000b
	fdb $0003,$fffa ; $000a,$0009
	fdb $0004,$fffe ; $000c,$0003

	fdb $0005,$0000 ; $000f,$0000
	fdb $0004,$0002 ; $000c,$fffd
	fdb $0003,$0006 ; $000a,$fff7
	fdb $0001,$0008 ; $0003,$fff5

ImagesIndex
        fdb   Img_tabrokmissile_0
        fdb   Img_tabrokmissile_1
        fdb   Img_tabrokmissile_2
        fdb   Img_tabrokmissile_3
        fdb   Img_tabrokmissile_4
        fdb   Img_tabrokmissile_5
        fdb   Img_tabrokmissile_6
        fdb   Img_tabrokmissile_7
        fdb   Img_tabrokmissile_8
        fdb   Img_tabrokmissile_9
        fdb   Img_tabrokmissile_10
        fdb   Img_tabrokmissile_11
        fdb   Img_tabrokmissile_12
        fdb   Img_tabrokmissile_13
        fdb   Img_tabrokmissile_14
        fdb   Img_tabrokmissile_15
