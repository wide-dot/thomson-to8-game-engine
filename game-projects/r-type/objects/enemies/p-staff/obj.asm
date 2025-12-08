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

 IFNDEF t2
Img_pstaff_3 equ Img_pstaff_0
Img_pstaff_4 equ Img_pstaff_1
Img_pstaff_5 equ Img_pstaff_2
Img_pstaff_7 equ Img_pstaff_8
Img_pstaff_13 equ Img_pstaff_10
Img_pstaff_14 equ Img_pstaff_11
Img_pstaff_15 equ Img_pstaff_12
Img_pstaff_17 equ Img_pstaff_18
 ENDC

AABB_0    		equ ext_variables   ; AABB struct (9 bytes)
pstaff_0x22		equ ext_variables+9 ; 1 byte
pstaff_0x24		equ ext_variables+10 ; 1 byte
pstaff_0x20		equ ext_variables+11 ; 1 byte
pstaff_0x30		equ ext_variables+12 ; 1 byte
pstaff_0x10     equ ext_variables+13 ; 2 bytes
pstaff_0x14     equ ext_variables+15 ; 2 bytes
pstaff_0x16     equ ext_variables+17 ; 2 bytes


Onject
	lda   routine,u
	asla
	ldx   #Routines
	jmp   [a,x]

Routines
	fdb   FUN_0000_78b4_CreatePStaff
	fdb   FUN_0000_7a07_RunPstaffPrepareWalkLeft
	fdb   AlreadyDeleted
	fdb   FUN_0000_7902_RunPstaffWalk
	fdb   FUN_0000_799f_RunPstaffWait
	fdb   FUN_0000_7a54_RunPstaffPrepareForShooting
	fdb   FUN_0000_7aac_RunPstaffShootingMode
	fdb   FUN_0000_7b19_RunPstaffReturnFromShooting

FUN_0000_78b4_CreatePStaff

	ldb   subtype_w+1,u
    	andb  #$0F
	aslb
	ldx   #PresetXYIndex
	abx
	clra
	ldb   1,x
	addd  #$3    ; original value $8
	std   y_pos,u
    	stb   AABB_0+AABB.cy,u
	ldb   ,x
	addd  glb_camera_x_pos
	std   x_pos,u

	ldb   subtype,u
	andb  #$01
	stb   subtype,u
	; set subtype based on preset
	ldb   #6
	stb   priority,u
	lda   #render_playfieldcoord_mask
	sta   render_flags,u

	_Collision_AddAABB AABB_0,AABB_list_ennemy
	
	leax  AABB_0,u
	lda   #$06                      ; set damage potential for this hitbox
	sta   AABB.p,x
	_ldd  6,13                      ; set hitbox xy radius
	std   AABB.rx,x

	ldb   globals.difficulty
	ldx   #pstaff_1x3346
	lda   b,x


	sta   pstaff_0x22,u
	sta   pstaff_0x24,u
	lda   #$20
	sta   pstaff_0x20,u
	lda   #$80
	sta   pstaff_0x30,u

	lda   #1   ; FUN_0000_7a07_RunPstaffPrepareWalkLeft
	sta   routine,u

	ldx   #Img_pstaff_15
	stx   image_set,u
	rts


; ##################################################


FUN_0000_7902_RunPstaffWalk

	lda   AABB_0+AABB.p,u
	lbeq  FUN_0000_7b7b_DestroyPstaff        ; was killed  

	ldx   #pstaff_0x334e
	lda   x_vel,u
	anda  #$80
	beq   LAB_0000_7915
	ldx   #pstaff_0x337e
LAB_0000_7915

	lda   pstaff_0x30,u
	anda  #$1c
	asra
	;jsr   FUN_0000_7b9e      ; Test if was hit and update the palette accordingly
	ldd   a,x
	std   image_set,u

	ldd   x_pos,u
	addd  #($10*scale.XP1PX)/256
	std   terrainCollision.sensor.x
	lda   x_vel,u
	anda  #$80
	beq   LAB_0000_794f
	ldd   x_pos,u
	subd  #($10*scale.XP1PX)/256
	std   terrainCollision.sensor.x
LAB_0000_794f
	ldd   y_pos,u
	addd  #11
	std   terrainCollision.sensor.y
	ldb   #1 ; foreground
	jsr   terrainCollision.do        
	tstb   
	lbne  FUN_0000_7a17

	jsr   ObjectMoveSync
	ldd   x_pos,u
	subd  glb_camera_x_pos
	stb   AABB_0+AABB.cx,u
	addd  #5                       ; add x radius
	lbmi  FUN_0000_7b68_DeletePstaff                  ; branch if out of screen's left

LAB_0000_797b
	lda   pstaff_0x30,u
	adda  gfxlock.frameDrop.count
	sta   pstaff_0x30,u
	lda   pstaff_0x22,u
	suba  gfxlock.frameDrop.count
	cmpa  pstaff_0x24,u
	lbcc  FUN_0000_7a2d
LAB_0000_798c
	sta   pstaff_0x22,u
	lda   pstaff_0x20,u
	suba  gfxlock.frameDrop.count
	ble   FUN_0000_79f5
	sta   pstaff_0x20,u
	jmp   DisplaySprite

; End of wait ... what to do now ?


FUN_0000_79f5

	ldd   player1+x_pos
	subd  x_pos,u
	bcc   FUN_0000_7a0f_RunPstaffPrepareWalkRight
	addd  #$27				; original value : $68
    bcs   FUN_0000_7a0f_RunPstaffPrepareWalkRight
	addd  #$7				; original value : $14
	bcs   FUN_0000_7a17

FUN_0000_7a07_RunPstaffPrepareWalkLeft

	ldd   #$ff70            ; original value $fe80
	std   x_vel,u
	lda   #3   ; FUN_0000_7902_RunPstaffWalk
	sta   routine,u
	lda   #8
	sta   pstaff_0x20,u
	lda   pstaff_0x22,u
	suba  gfxlock.frameDrop.count
	cmpa  pstaff_0x24,u
	lbcc  FUN_0000_7a2d
	sta   pstaff_0x22,u
	jmp   DisplaySprite

FUN_0000_7a0f_RunPstaffPrepareWalkRight
	ldd   #$0090			; original value $200
	std   x_vel,u
	lda   #3   ; FUN_0000_7902_RunPstaffWalk
	sta   routine,u
	lda   #8
	sta   pstaff_0x20,u
	lda   pstaff_0x22,u
	suba  gfxlock.frameDrop.count
	cmpa  pstaff_0x24,u
	lbcc  FUN_0000_7a2d
	sta   pstaff_0x22,u
	jmp   DisplaySprite

FUN_0000_7a17
	lda   #$8
	sta   pstaff_0x20,u
	lda   #4	; FUN_0000_799f_RunPstaffWait
	sta   routine,u
	lda   pstaff_0x22,u
	suba  gfxlock.frameDrop.count
	cmpa  pstaff_0x24,u
	lbcc  FUN_0000_7a2d
	sta   pstaff_0x22,u
	jmp   DisplaySprite



;##########################

FUN_0000_799f_RunPstaffWait
	ldd   x_pos,u
	subd  glb_camera_x_pos
	stb   AABB_0+AABB.cx,u
	addd  #5                       ; add x radius
	lbmi  FUN_0000_7b68_DeletePstaff                  ; branch if out of screen's left

	ldx   #Img_pstaff_15
	lda   x_vel,u
	anda  #$80
	beq   LAB_0000_79b2
	ldx   #Img_pstaff_5
LAB_0000_79b2
	stx   image_set,u
	lda   AABB_0+AABB.p,u
	lbeq  FUN_0000_7b7b_DestroyPstaff        ; was killed  
	lda   pstaff_0x30,u
	adda  gfxlock.frameDrop.count
	sta   pstaff_0x30,u
	lda   pstaff_0x22,u
	suba  gfxlock.frameDrop.count
	cmpa  pstaff_0x24,u
	bcc   FUN_0000_7a2d

LAB_0000_79e2
	lda   pstaff_0x20,u
	suba  gfxlock.frameDrop.count
	lble  FUN_0000_79f5
	sta   pstaff_0x20,u
	jmp   DisplaySprite

 


FUN_0000_7a2d
	lda   #$1f
	sta   pstaff_0x20,u
	lda   #5	; FUN_0000_7a54_RunPstaffPrepareForShooting
	sta   routine,u

	ldd   #pstaff_0x33ae
	std   pstaff_0x14,u
	ldd   #pstaff_0x33de
	std   pstaff_0x16,u
	ldd   player1+x_pos
	cmpd  x_pos,u
	bcs   LAB_0000_7a53
	ldd   #pstaff_0x33c6
	std   pstaff_0x14,u
	ldd   #pstaff_0x3402
	std   pstaff_0x16,u
LAB_0000_7a53
	jmp   DisplaySprite

;   					  *******************************************************
;                         *                      FUNCTION                       *
;                         *******************************************************

FUN_0000_7a54_RunPstaffPrepareForShooting
	lda   pstaff_0x20,u
	anda  #$18				
	asra
	asra
	ldx   pstaff_0x14,u
	ldd   a,x
	std   image_set,u

	lda   AABB_0+AABB.p,u
	lbeq  FUN_0000_7b7b_DestroyPstaff        ; was killed  
	ldd   x_pos,u
	subd  glb_camera_x_pos
	stb   AABB_0+AABB.cx,u
	addd  #5                       ; add x radius
	lbmi  FUN_0000_7b68_DeletePstaff                  ; branch if out of screen's left

	lda   pstaff_0x30,u
	adda  gfxlock.frameDrop.count
	sta   pstaff_0x30,u
	lda   pstaff_0x20,u
	suba  gfxlock.frameDrop.count
	ble   LAB_0000_7aa6
	sta   pstaff_0x20,u
	jmp   DisplaySprite
LAB_0000_7aa6
	lda   #$f				; using temporarily for frame count between rockets
	sta   pstaff_0x20,u
	lda   #8
	sta   pstaff_0x22,u		; using temporarily for rocket count
	lda   #6    ; FUN_0000_7aac_RunPstaffShootingMode_RunPstaffShootingMode
	sta   routine,u
	jmp   DisplaySprite

;   					  *******************************************************
;                         *                      FUNCTION                       *
;                         *******************************************************


FUN_0000_7aac_RunPstaffShootingMode

	ldx   pstaff_0x16,u
	lda   pstaff_0x20,u
FUN_0000_7aac_bis
	suba  gfxlock.frameDrop.count
	bpl   LAB_0000_7acf
	leax  2,x
	jsr   FUN_0000_7bc1_PstaffShootsRocket
	dec   pstaff_0x22,u
	lda   #$f
LAB_0000_7acf
	sta   pstaff_0x20,u
	ldd   ,x
	std   image_set,u
	lda   AABB_0+AABB.p,u
	lbeq  FUN_0000_7b7b_DestroyPstaff        ; was killed  
	ldd   x_pos,u
	subd  glb_camera_x_pos
	stb   AABB_0+AABB.cx,u
	addd  #5                       ; add x radius
	lbmi  FUN_0000_7b68_DeletePstaff                  ; branch if out of screen's left

	lda   pstaff_0x22,u
	beq   LAB_0000_7b05
	jmp   DisplaySprite


LAB_0000_7b05
	lda   pstaff_0x24,u
	sta   pstaff_0x22,u
	lda   #$1f
	sta   pstaff_0x20,u
	ldd   pstaff_0x16,u
	addd  #4
	std   pstaff_0x14,u
	lda   #7	; FUN_0000_7b19_RunPstaffReturnFromShooting
	sta   routine,u
	jmp   DisplaySprite

;   					  *******************************************************
;                         *                      FUNCTION                       *
;                         *******************************************************

FUN_0000_7b19_RunPstaffReturnFromShooting

	lda   pstaff_0x20,u
	anda  #$18				; original value $18
	asra
	asra
	ldx   pstaff_0x14,u
	ldd   a,x
	std   image_set,u

	lda   AABB_0+AABB.p,u
	lbeq  FUN_0000_7b7b_DestroyPstaff        ; was killed  
	ldd   x_pos,u
	subd  glb_camera_x_pos
	stb   AABB_0+AABB.cx,u
	addd  #5                       ; add x radius
	lbmi  FUN_0000_7b68_DeletePstaff                  ; branch if out of screen's left

	lda   pstaff_0x30,u
	adda  gfxlock.frameDrop.count
	sta   pstaff_0x30,u
	lda   pstaff_0x20,u
	suba  gfxlock.frameDrop.count
	ble   LAB_0000_7b5d
	sta   pstaff_0x20,u
	jmp   DisplaySprite
LAB_0000_7b5d
	jmp   FUN_0000_79f5




;   					  *******************************************************
;                         *                      FUNCTION                       *
;                         *******************************************************

FUN_0000_7bc1_PstaffShootsRocket
	pshs  x
	jsr   LoadObject_x ; make then die early ... to be removed
    beq   LAB_0000_7c0d
	lda   #ObjID_commonmissile
    sta   id,x
	lda   #1
	sta   subtype,x
	ldd   x_pos,u
	std   x_pos,x
	ldd   y_pos,u
	subd  #$c		; original value $10
	std   y_pos,x
	jsr   RandomNumber
	exg   a,b
	anda  #$1		; original value AND #$1ff
	andb  #$7f     
	addd  #$1e0		; original value $280
	_negd
	std   y_vel,x
	jsr   RandomNumber
	exg   a,b
	clra
	andb  #$5f      ; original value $ff
	addd  #$48		; original value $c0
	std   x_vel,x
	ldd   pstaff_0x16,u
	cmpd  #pstaff_0x33de
	bne   LAB_0000_7c05
	ldd   x_vel,x
	_negd
	std   x_vel,x
LAB_0000_7c05
LAB_0000_7c0d
	puls  x
	rts

FUN_0000_7b7b_DestroyPstaff 
	jsr   LoadObject_x ; make then die early ... to be removed
	beq   FUN_0000_7b68_DeletePstaff
	_ldd   ObjID_explosion,explosion.subtype.smallx3
	std   id,x
	ldd   x_pos,u
	std   x_pos,x
	ldd   y_pos,u
	std   y_pos,x
FUN_0000_7b68_DeletePstaff
	lda   #2     ; AlreadyDeleted
	sta   routine,u      
	_Collision_RemoveAABB AABB_0,AABB_list_ennemy
	jmp   DeleteObject
AlreadyDeleted
	rts


pstaff_1x3346
	fcb   $c0
	fcb   $a0
	fcb   $70
	fcb   $40

pstaff_0x334e
	fdb   Img_pstaff_15
	fdb   Img_pstaff_15
	fdb   Img_pstaff_14
	fdb   Img_pstaff_13
	fdb   Img_pstaff_12
	fdb   Img_pstaff_12
	fdb   Img_pstaff_11
	fdb   Img_pstaff_10
pstaff_0x337e
	fdb   Img_pstaff_5
	fdb   Img_pstaff_5
	fdb   Img_pstaff_4
	fdb   Img_pstaff_3
	fdb   Img_pstaff_2
	fdb   Img_pstaff_2
	fdb   Img_pstaff_1
	fdb   Img_pstaff_0

pstaff_0x33ae
	fdb   Img_pstaff_8
	fdb   Img_pstaff_9
	fdb   Img_pstaff_9
	fdb   Img_pstaff_5

pstaff_0x33c6
	fdb   Img_pstaff_18
	fdb   Img_pstaff_19
	fdb   Img_pstaff_19
	fdb   Img_pstaff_15

pstaff_0x33de
	fdb   Img_pstaff_7
	fdb   Img_pstaff_6

pstaff_0x33ea
	fdb   Img_pstaff_5
	fdb   Img_pstaff_9
	fdb   Img_pstaff_9
	fdb   Img_pstaff_8

pstaff_0x3402
	fdb   Img_pstaff_17
	fdb   Img_pstaff_16
pstaff_0x340e
	fdb   Img_pstaff_15
	fdb   Img_pstaff_19
	fdb   Img_pstaff_19
	fdb   Img_pstaff_18



PresetXYIndex
        INCLUDE "./global/preset/18dd0_preset-xy.asm"