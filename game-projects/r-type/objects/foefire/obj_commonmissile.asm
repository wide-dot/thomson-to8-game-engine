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

AABB_0                  equ ext_variables   ; AABB struct (9 bytes)

; **** TABROK MISSILE VARIABLES ****

tabrokmissile_0x24      equ ext_variables+10 ; 1 byte - reference value for run mode change frames
tabrokmissile_0x16      equ ext_variables+11 ; 1 bytes - current image index
tabrokmissile_0x20      equ ext_variables+12 ; 1 byte - run mode change frames
tabrokmissile_0x22      equ ext_variables+13 ; 2 bytes - period of tracking (set at $800 - after that, no tracking anymore)
tabrokmissile_b         equ ext_variables+15 ; 1 byte - temporary B register
missile_flame           equ ext_variables+16 ; 2 bytes

; **** PSTAFF ROCKET VARIABLES ****



Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
; Tabrok Missiles routines 
        fdb   Init                                              ; 0
        fdb   FUN_0000_xxxx_RunTabrokMissileRunMode0            ; 1
        fdb   AlreadyDeleted                                    ; 2
        fdb   FUN_0000_6c7d_RunTabrokMissileRunMode1            ; 3
; Pstaff Rockets routines
        fdb   FUN_0000_7c0e_CreateAndRunPstaffRocketMode1       ; 4
        fdb   FUN_0000_7c91_RunPstaffRocketMode2                ; 5


Init
        lda   subtype,u
        lbne  Init2

;   **************************************************************
;   *                   TABROK MISSILES                          *
;   **************************************************************

        jsr   LoadObject_x
        beq   >
        lda   #ObjID_tabrokmissileflame
        sta   id,x
        stx   missile_flame,u
!
	ldx   #TabrokMissileImagesIndex
        lda   tabrokmissile_0x16,u
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

        lda   tabrokmissile_0x20,u
        suba  gfxlock.frameDrop.count
        ble   LAB_0000_6c4c
	
        sta   tabrokmissile_0x20,u


	jsr   ObjectMoveSync
        ldy   missile_flame,u
        beq   >
        ldx   #missileflame_1x2d14
        lda   tabrokmissile_0x16,u
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
        sta   tabrokmissile_0x20,u
        ldd   #$800
        std   tabrokmissile_0x22,u
        lda   #3  ; FUN_0000_6c7d_RunTabrokMissileRunMode1
        sta   routine,u
	jsr   ObjectMoveSync
        ldy   missile_flame,u
        beq   >
        ldx   #missileflame_1x2d14
        lda   tabrokmissile_0x16,u
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

        ldd  tabrokmissile_0x22,u
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
        ldx   tabrokmissile_0x22,u
        lda   gfxlock.frameDrop.count
        nega
        leax  a,x
        stx   tabrokmissile_0x22,u
        lda   tabrokmissile_0x20,u
        suba  gfxlock.frameDrop.count
        sta   tabrokmissile_0x20,u
        bpl   LAB_0000_6cee

        ldx   #player1
        jsr   setDirectionTo
        tfr   y,d
        clra
        asrb
        asrb
        stb   tabrokmissile_b,u

        cmpb  tabrokmissile_0x16,u
        bmi   LAB_0000_6cae
        subb  #$8
        bmi   LAB_0000_6cb6
        subb  tabrokmissile_0x16,u
        bmi   LAB_0000_6cb6
        jmp   LAB_0000_6cbc

LAB_0000_6cae
        lda   tabrokmissile_0x16,u
        suba  #$8
        bmi   LAB_0000_6cbc
        suba  tabrokmissile_b,u
        bmi   LAB_0000_6cbc
LAB_0000_6cb6
        inc   tabrokmissile_0x16,u
        jmp   LAB_0000_6cbf
LAB_0000_6cbc
        dec   tabrokmissile_0x16,u
LAB_0000_6cbf
        lda   tabrokmissile_0x16,u
        anda  #$f
        sta   tabrokmissile_0x16,u
        ldb   globals.difficulty
        ldx   #tabrokmissile_1x2c8c
        lda   b,x
        ldx   #missile_1x8f90
        leax  a,x
        ldb   tabrokmissile_0x16,u
        aslb
        aslb
        leax  b,x
        ldd   ,x
        std   x_vel,u
        ldd   2,x
        std   y_vel,u
        lda   tabrokmissile_0x24,u
        sta   tabrokmissile_0x20,u
LAB_0000_6cee

        ldx   #TabrokMissileImagesIndex
        lda   tabrokmissile_0x16,u
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
        lda   tabrokmissile_0x16,u
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
        beq   DestroyNoFlame
        lda   #1
        sta   ext_variables,x
DestroyNoFlame
        jsr   LoadObject_x
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


;   **************************************************************
;   *                   Pstaff Rocket Init                       *
;   **************************************************************

Init2
        ;cmpa  #1
        ;lbne  Init3

	ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_foefire
        
        leax  AABB_0,u
        lda   #1                                        ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  3,4                                       ; set hitbox xy radius
        std   AABB.rx,x


        lda   #4        ; FUN_0000_7c0e_CreateAndRunPstaffRocketMode1
        sta   routine,u

        ldx   #Pstaff_0x343a
        ldd   y_vel,u
        cmpd  #$FE50            ; original value $240
        bcs   Init21
        ldx   #Pstaff_0x343a+4
        cmpd  #$FEE0            ; original value $180
        bcs   Init21
        ldx   #Pstaff_0x343a+8
        cmpd  #$FF40             ; original value $100
        bcs   Init21
        ldx   #Pstaff_0x343a+12
Init21
        lda   x_vel,u
        bmi   Init22
        leax  2,x
Init22
        ldd   ,x
        std   image_set,u
        jmp   DisplaySprite


FUN_0000_7c0e_CreateAndRunPstaffRocketMode1

        ; check if bullet is outside the viewport
        ; x axis
        ldd   x_pos,u                                   ; set visibility range
        cmpd  glb_camera_x_pos                          ; destroy if out of range
        lble  Delete
        ldd   y_pos,u
        lble  Delete

        ldx   #Pstaff_0x343a
        ldd   y_vel,u
        cmpd  #$FE50            ; original value $240
        bcs   LAB_0000_7c3b
        ldx   #Pstaff_0x343a+4
        cmpd  #$FEE0            ; original value $180
        bcs   LAB_0000_7c3b
        ldx   #Pstaff_0x343a+8
        cmpd  #$FF40             ; original value $100
        bcs   LAB_0000_7c3b
        ldx   #Pstaff_0x343a+12
LAB_0000_7c3b
        lda   x_vel,u
        bmi   LAB_0000_7c45
        leax  2,x
LAB_0000_7c45
        ldd   ,x
        std   image_set,u
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        lbne  DestroyNoFlame
        lda   globals.backgroundSolid
        beq   >
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        lbne  DestroyNoFlame
!
        ; collision
        leax  AABB_0,u
        lda   AABB.p,x
        lbeq  DestroyNoFlame

        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x

        ldb   #$c               ; original value $10
        lda   gfxlock.frameDrop.count
        mul
        addd  y_vel,u
        bpl   LAB_0000_7c86
        std   y_vel,u
	jsr   ObjectMoveSync
        jmp   DisplaySprite

LAB_0000_7c86

        ldd   #$0
        std   y_vel,u
        lda   #5        ; FUN_0000_7c91_RunPstaffRocketMode2
        sta   routine,u
        jmp   DisplaySprite

;   **************************************************************
;   *                   FUNCTION                                 *
;   **************************************************************
FUN_0000_7c91_RunPstaffRocketMode2

        ; check if bullet is outside the viewport
        ; x axis
        ldd   x_pos,u                                   ; set visibility range
        cmpd  glb_camera_x_pos                          ; destroy if out of range
        lble  Delete
        ldd   y_pos,u
        cmpd  #180
        lbhi  Delete

        ldx   #Pstaff_0x346a
        ldd   y_vel,u
        cmpd  #$1b0             ; original value $fdc0
        bcc   LAB_0000_7ccb
        ldx   #Pstaff_0x346a+4
        cmpd  #$120             ; original value $fe80
        bcc   LAB_0000_7ccb
        ldx   #Pstaff_0x346a+8
        cmpd  #$12              ; original value $ff00
        bcc   LAB_0000_7ccb
        ldx   #Pstaff_0x346a+12
LAB_0000_7ccb
        lda   x_vel,u
        bmi   LAB_0000_7cd5
        leax  2,x
LAB_0000_7cd5
        ldd   ,x
        std   image_set,u
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        lbne  DestroyNoFlame
        lda   globals.backgroundSolid
        beq   >
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #0 ; background
        jsr   terrainCollision.do
        tstb
        lbne  DestroyNoFlame
!
        ; collision
        leax  AABB_0,u
        lda   AABB.p,x
        lbeq  DestroyNoFlame

        ; update hitbox position
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x

        ldb   #$c               ; original value $10
        lda   gfxlock.frameDrop.count
        mul
        addd  y_vel,u
        std   y_vel,u

        jsr   ObjectMoveSync
        jmp   DisplaySprite



missile_1x8f90
        INCLUDE "./global/preset/18f90_preset-fireVelocity.asm"


tabrokmissile_1x2c8c
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

TabrokMissileImagesIndex
        fdb   Img_missile_0
        fdb   Img_missile_1
        fdb   Img_missile_2
        fdb   Img_missile_3
        fdb   Img_missile_4
        fdb   Img_missile_5
        fdb   Img_missile_6
        fdb   Img_missile_7
        fdb   Img_missile_8
        fdb   Img_missile_9
        fdb   Img_missile_10
        fdb   Img_missile_11
        fdb   Img_missile_12
        fdb   Img_missile_13
        fdb   Img_missile_14
        fdb   Img_missile_15

Pstaff_0x343a
        fdb   Img_missile_15
        fdb   Img_missile_1
        fdb   Img_missile_14
        fdb   Img_missile_2
        fdb   Img_missile_13
        fdb   Img_missile_3
        fdb   Img_missile_12
        fdb   Img_missile_4
Pstaff_0x346a
        fdb   Img_missile_8
        fdb   Img_missile_8
        fdb   Img_missile_9
        fdb   Img_missile_7
        fdb   Img_missile_10
        fdb   Img_missile_6
        fdb   Img_missile_11
        fdb   Img_missile_5



