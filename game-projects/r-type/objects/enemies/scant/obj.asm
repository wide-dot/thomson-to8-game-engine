; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/enemies_properties.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/explosion/explosion.const.asm"

AABB_0                  equ ext_variables   ; AABB struct (9 bytes)

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   FUN_0000_84e3_CreateScant         ; 0
        fdb   AlreadyDeleted                    ; 1
        fdb   FUN_0000_8538_RunScantMode1       ; 2


FUN_0000_84e3_CreateScant


        ldb   subtype_w+1,u            ; load x and y pos based on wave parameter
        andb  #$0F
        aslb
        ldx   #PresetXYIndex
        abx
        clra
        ldb   1,x
        std   y_pos,u
        ldb   ,x
        addd  glb_camera_x_pos
        std   x_pos,u

        ; set subtype based on preset

        ldb   subtype+1,u
        stb   subtype,u

        ldb   #6    
        stb   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        leax  AABB_0,u
        lda   #$1e                     ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  12,25                    ; set hitbox xy radius
        std   AABB.rx,x

        ldd   #$1c0
        std   scant_0x26
        jsr   RandomNumber
        andb  scant_0x14    
        lda   #$1f
        sta   scant_0x16    
        ldd   player1+x_pos
        addd  #$5a              ; original value $f0
        std   scant_0x24
        std   scant_0x30
        ldd   player1+y_pos
        std   scant_0x28
        std   scant_0x32

        lda   #2        ; FUN_0000_8538_RunScantMode1
        sta   routine,u
        rts

;   			  *******************************************************
;                         *                      FUNCTION                       *
;                         *******************************************************


FUN_0000_8538_RunScantMode1
        lda   scant_0x16
        adda  gfxlock.frameDrop.count
        sta   scant_0x16
        cmpa  #$1f
        blo   LAB_0000_8582
        clr   scant_0x16

        ldd   scant_0x30
        std   scant_0x24
        ldd   scant_0x32
        std   scant_0x28

        ldd   player1+x_pos
        addd  #$3c      ; original value $a0
        std   scant_0x30
        ldd   player1+y_pos
        std   scant_0x32
        ldx   #scant_0x24-18
        jsr   setDirectionTo
        tfr   y,d
        ldx   #scant_0x3966
        abx   
        ldd   ,x
        std   x_vel,u
        ldd   2,x
        std   y_vel,u
        ldd   scant_0x26
        cmpd  #$ffff
        bne   LAB_0000_8582
        ldd   #$ffac            ; original value $ff00
        std   x_vel,u
LAB_0000_8582
	ldd   x_pos,u
	addd  #($30*scale.XP1PX)/256
	std   terrainCollision.sensor.x
	lda   x_vel,u
	anda  #$80
	beq   LAB_0000_858e
	ldd   x_pos,u
	subd  #($30*scale.XP1PX)/256
	std   terrainCollision.sensor.x
LAB_0000_858e
	ldd   y_pos,u
	std   terrainCollision.sensor.y
	ldb   #1 ; foreground
	jsr   terrainCollision.do        
	tstb   
	beq   LAB_0000_858e_bis
        ldd   #$0
        std   x_vel,u
        jmp   LAB_0000_85b9
LAB_0000_858e_bis
        
        ldd   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #$fc      ; original value $2a0
        bcs   LAB_0000_85b3
        lda   x_vel,u
        bmi   LAB_0000_85b3
        ldd   #$20      ; original value $00
        std   x_vel,u
LAB_0000_85b3
LAB_0000_85b9

	ldd   y_pos,u
	addd  #($30*scale.YP1PX)/256
	std   terrainCollision.sensor.y
	lda   y_vel,u
	anda  #$80
	beq   LAB_0000_85c5
	ldd   y_pos,u
	subd  #($30*scale.YP1PX)/256
	std   terrainCollision.sensor.y
LAB_0000_85c5
	ldd   x_pos,u
	std   terrainCollision.sensor.x
	ldb   #1 ; foreground
	jsr   terrainCollision.do        
	tstb   
	beq   LAB_0000_85c5_bis
        ldd   #$0
        std   y_vel,u
        jmp   LAB_0000_85e2
LAB_0000_85c5_bis
        
        ldd   x_pos,u
        cmpd  #$53      ; original value $dfc
        bcc   LAB_0000_85e2
        cmpd  #$2e      ; original value $7d0
        bcc   LAB_0000_85e2
        lda   x_vel,u
        cmpa  #$80
        bne   LAB_0000_85e2
        ldd   #$20      ; original value $00
        std   x_vel,u
LAB_0000_85e2

        jsr   ObjectMoveSync

        ldd   player1+x_pos
        cmpd  x_pos,u
        bcs   LAB_0000_8603
        ldx   #scant_0x3876
        lda   x_vel,u
        bpl   LAB_0000_861c
        lda   scant_0x38
        cmpa  #$3e
        bcc   LAB_0000_85fd
        adda  gfxlock.frameDrop.count
        sta   scant_0x38
LAB_0000_85fd
        ldx   #scant_0x387e
        jmp   LAB_0000_8621
LAB_0000_8603
        ldx   #scant_0x3866
        lda   x_vel,u
        bpl   LAB_0000_861c
        lda   scant_0x38
        cmpa  #$3e
        bcc   LAB_0000_8616
        adda  gfxlock.frameDrop.count
        sta   scant_0x38
LAB_0000_8616
        ldx   #scant_0x386e
        jmp   LAB_0000_8621
LAB_0000_861c
        clr   scant_0x38
LAB_0000_8621
        lda   scant_0x38
        anda  #$30
        asra
        asra
        asra
        ldd   a,x
        ;jsr   FUN_0000_8809_ScantChoosePalette
        std   image_set,u

        ldd   player1+y_pos
        subd  #($18*scale.YP1PX)/256
        cmpd  y_pos,u
        bcs   LAB_0000_8668
        addd  #($30*scale.YP1PX)/256
        cmpd  y_pos,u
        bcc   LAB_0000_8668
        lda   scant_0x14
        suba  gfxlock.frameDrop.count
        sta   scant_0x14
        bpl   LAB_0000_8668
        ldb   globals.difficulty
        ldx   #scant_3856
        lda   b,x
        sta   scant_0x14
        lda   #$1f
        sta   scant_0x3a
        ;lda   #3    ; FUN_0000_86d6
        ;sta   routine,u
        ;ldd   #1234
        ;std   score
LAB_0000_8668
        lda   AABB_0+AABB.p,u
        beq   LAB_0000_86a0_DestroyScant        ; was killed  










        jmp   DisplaySprite

LAB_0000_86a0_DestroyScant                     
        ldd   score
        addd  #tabrok_score
        std   score
        jsr   LoadObject_x ; make then die early ... to be removed
        beq   FUN_0000_6a07_DeleteScant
        _ldd  ObjID_explosion,explosion.subtype.big
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
FUN_0000_6a07_DeleteScant
        lda   #1        ; Already deleted
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject


AlreadyDeleted
        rts

scant_0x16      fcb $0
scant_0x24      fdb $0
scant_0x14      fcb $0
scant_0x28      fdb $0
scant_0x26      fdb $0
scant_0x30      fdb $0
scant_0x32      fdb $0
scant_0x38      fcb $0
scant_0x3a      fdb $0

scant_3856
                fcb $20
                fcb $18
                fcb $10
                fcb $08

                fdb $fc00
                fdb $fb00
                fdb $f900
                fdb $f700

scant_0x3866    
        fdb Img_scant_0
        fdb Img_scant_0
        fdb Img_scant_0
        fdb Img_scant_0
scant_0x386e    
        fdb Img_scant_1
        fdb Img_scant_1
        fdb Img_scant_1
        fdb Img_scant_1
scant_0x3876    
        fdb Img_scant_3
        fdb Img_scant_3
        fdb Img_scant_3
        fdb Img_scant_3
scant_0x387e    
        fdb Img_scant_4
        fdb Img_scant_4
        fdb Img_scant_4
        fdb Img_scant_4
scant_0x3886    
        fdb Img_scant_0
        fdb Img_scant_0
        fdb Img_scant_0
        fdb Img_scant_2
scant_0x388e  
        fdb Img_scant_3
        fdb Img_scant_3
        fdb Img_scant_3
        fdb Img_scant_5


; Pour X :
;   Choisir la valeur positive, retirer $20, faire conversion avec .375
;   Mettre la valeur trouvee en neg, appliquer a la direction opposee ($4 et $38 sont opposes)



scant_0x3966    fdb $0020       ; $0    $0000
                fdb $fee0       ;       $0180
                fdb $0036       ; $4    $00b0
                fdb $fef8       ;       $0160
                fdb $006c       ; $8    $0140
                fdb $ff28       ;       $0120
                fdb $0090       ; $c    $01a0
                fdb $ff88       ;       $00a0
                fdb $00a8       ; $10   $01c0
                fdb $0000
                fdb $0090       ; $14   $01a0
                fdb $0078       ;       $ff60
                fdb $006c       ; $18   $0140
                fdb $00d8       ;       $fee0
                fdb $0036       ; $1c   $00b0
                fdb $0108       ;       $fea0
                fdb $0020       ; $20   $0000
                fdb $0120       ;       $fe80
                fdb $ffca       ; $24   $ff50
                fdb $0108       ;       $fea0
                fdb $ff94       ; $28   $fec0
                fdb $00d8       ;       $fee0
                fdb $ff70       ; $2c   $fe60
                fdb $0078       ;       $ff60
                fdb $ff58       ; $30   $fe40
                fdb $0000
                fdb $ff70       ; $34   $fe60
                fdb $ff88       ;       $00a0
                fdb $ff94       ; $38   $fec0
                fdb $ff28       ;       $0120
                fdb $ffc0       ; $3c   $ff50
                fdb $fef8       ;       $0160



PresetXYIndex
        INCLUDE "./global/preset/18dd0_preset-xy.asm"