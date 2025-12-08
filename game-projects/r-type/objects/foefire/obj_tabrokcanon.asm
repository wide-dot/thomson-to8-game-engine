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
canon_0x30	equ ext_variables+10 ; 2 bytes, canon velocity

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live
        fdb   AlreadyDeleted

Init
	ldx   #Img_tabrokcanon_left
	lda   subtype,u
	beq   >
	ldx   #Img_tabrokcanon_right
!
	stx   image_set,u
	ldb   #7
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

	ldd   canon_0x30,u
	std   x_vel,u

        ;0000:6ac8 8b 46 30        MOV        AX,word ptr [BP + 0x30]
        ;0000:6acb e8 a4 9f        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos
        ;0000:6ace bb 7e 2c        MOV        BX,0x2c7e
        ;0000:6ad1 f7 46 30        TEST       word ptr [BP + 0x30],0x8000
        ;         00 80
        ;0000:6ad6 74 03           JZ         LAB_0000_6adb
        ;0000:6ad8 bb 78 2c        MOV        BX,0x2c78
        ;                    LAB_0000_6adb                                   XREF[1]:     0000:6ad6(j)  
        ;0000:6adb e8 ee b4        CALL       FUN_0000_1fcc_Write1Sprite_A                     undefined FUN_0000_1fcc_Write1Sp
        ;0000:6ade bf 84 2c        MOV        DI,0x2c84
        ;0000:6ae1 e8 b0 8f        CALL       FUN_0000_fa94_DoCollisionWithPlayerAndWeapons_v1 undefined FUN_0000_fa94_DoCollis
        ;0000:6ae4 72 0e           JC         LAB_0000_6af4
        ;0000:6ae6 e8 83 b7        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
        ;0000:6ae9 3d fc 0d        CMP        AX,0xdfc
        ;0000:6aec 72 06           JC         LAB_0000_6af4
        ;0000:6aee e8 7a b6        CALL       FUN_0000_216b_IsVisibleRange                     undefined FUN_0000_216b_IsVisibl
        ;0000:6af1 72 15           JC         LAB_0000_6b08
        ;0000:6af3 c3              RET

Live
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
        ble   Destroy
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        bge   Destroy

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
	jmp   DisplaySprite

Destroy
        inc   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_foefire
        jsr   LoadObject_x ; make then die early ... to be removed
        beq   >
        _ldd  ObjID_explosion,explosion.subtype.fwk
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
!
        jmp   DeleteObject

AlreadyDeleted
	rts