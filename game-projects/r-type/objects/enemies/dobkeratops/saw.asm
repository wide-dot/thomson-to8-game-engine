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
        INCLUDE "./objects/enemies_properties.asm"

x_pos_origin  equ ext_variables
y_pos_origin  equ ext_variables+2
frame         equ ext_variables+4
y_vel_step    equ ext_variables+5
parent        equ ext_variables+7
missed_frames equ ext_variables+9
child_frame   equ ext_variables+10
AABB_0        equ ext_variables+11   ; AABB struct (9 bytes)

XVEL          equ -$0180

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   InitMaster  ; 0
        fdb   RunMaster   ; 1
        fdb   RunCommon   ; 2
        fdb   InitCommon  ; 3
        fdb   RunSlave    ; 4

saw.instanceParity fcb 0

InitMaster
        ldd   x_pos,u
        std   x_pos_origin,u
        ldd   y_pos,u
        std   y_pos_origin,u
        ldb   #2
        stb   child_frame,u
InitCommon
        ldd   #$2040         ; counter variable x30 and x10 in original game
        std   anim_frame,u   ; using two different counters in anim_frame
        inc   routine,u
        ldb   #5
        stb   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #XVEL
        std   x_vel,u

        com   saw.instanceParity
        beq   >
        rts
!       _Collision_AddAABB AABB_0,AABB_list_ennemy_unkillable
        lda   #dobkeratops_saw_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  dobkeratops_saw_hitbox_x,dobkeratops_saw_hitbox_y
        std   AABB_0+AABB.rx,u
        jmp   UpdateHitBox        

RunMaster
        lda   gfxlock.frameDrop.count
@loop   dec   anim_frame+1,u
        ldb   anim_frame+1,u        
        andb  #3
        bne   >
        jsr   CreateSlave
!       jsr   SawMoveXLeft
        dec   anim_frame,u
        bne   >
        jsr   CheckPlayerOnePos
        jmp   RunMaster2
!       deca
        bne   @loop

!       jsr   UpdateFrame
        jsr   UpdateHitBox
        jmp   DisplaySprite

RunMaster2
@loop   jsr   SawMoveXLeft
        jsr   SawMoveY
        deca
        bne   @loop
        bra   <

CreateSlave
        pshs  d
        jsr   LoadObject_x
        beq   >
        _ldd  ObjID_dobkeratops_saw,3 ; InitCommon
        sta   id,x
        stb   routine,x
        ldd   x_pos_origin,u
        std   x_pos,x
        ldd   y_pos_origin,u
        std   y_pos,x
        lda   #$20
        sta   anim_frame,x
        stu   parent,x
        ldb   child_frame,u
        addb  #2
        ldb   child_frame,u
        stb   frame,x
        lda   ,s                       ; get remaining frame drops to process
        deca
        sta   missed_frames,x
!       puls  d,pc

SawMoveXLeft
        pshs  d
        ldd   #-$0180
        addd  x_pos+1,u             
        std   x_pos+1,u              
        bcs   >
        dec   x_pos,u
!       puls  d,pc

SawMoveY
        pshs  d
        ldx   y_vel_step,u
        ldd   y_vel,u
        leax  d,x
        bmi   @neg
        addd  y_pos+1,u                      
        bcc   >
        inc   y_pos,u
!       std   y_pos+1,u       
        stx   y_vel,u
        puls  d,pc
@neg    addd  y_pos+1,u                     
        bcs   <
        dec   y_pos,u
        std   y_pos+1,u         
        stx   y_vel,u
        puls  d,pc

CheckPlayerOnePos
; set a velocity value based on y position of player one
; on arcade velocity is $20, but added one frame on 2
; so after scale (*.75) and /2 (every frame, gives 12
        ldx <player1+y_pos
        cmpx #102
        bls @neg
        cmpx #115
        bls @zero
        ldx #12
        stx y_vel_step,u
        inc routine,u
        rts
@neg
        ldx #-12
        stx y_vel_step,u
        inc routine,u
        rts
@zero
        ldx #0
        stx y_vel_step,u
        inc routine,u
        rts

RunCommon
        jsr   SawMoveSync
        ldd   x_pos,u
        addd  #8
        cmpd  glb_camera_x_pos
        bhi   >
        lda   AABB_0+AABB.p,u
        beq   @del
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy_unkillable
@del    jmp   DeleteObject
!       jsr   UpdateFrame
        jsr   UpdateHitBox
        jmp   DisplaySprite

RunSlave
        lda   gfxlock.frameDrop.count
        adda  missed_frames,u
@loop   jsr   SawMoveXLeft
        jsr   SawMoveY
        dec   anim_frame,u
        bne   >
        jsr   GetParentVel
!       deca
        bne   @loop
        jsr   UpdateFrame
        jsr   UpdateHitBox
        clr   missed_frames,u
        jmp   DisplaySprite

GetParentVel
        pshs  d
        ldx   parent,u
        ldd   y_vel_step,x
        std   y_vel_step,u
        lda   #2 ; RunCommon
        sta   routine,u
        puls  d,pc

SawMoveSync
; apply XY velocity in sync with framerate
; ----------------------------------------
        ldb   gfxlock.frameDrop.count_w+1
        bne   >
        incb
!       stb   ,-s  

        * compteur boucle sur pile : même coût que x, mais le libère 
        ldb   y_vel_step+1,u
        stb   @a-1
        ldx   y_vel,u ; on garde y_vel dans un reg
@loop1
        ldd   x_pos+1,u
        addd  #XVEL
        bcs   >       ; bcc si x_vel>0
        dec   x_pos,u ; dec si x_vel>0
!       std   x_pos+1,u
        tfr   x,d
        leax  111,x
@a      tsta 
        bmi   @neg
        addd  y_pos+1,u
        std   y_pos+1,u
        bcc   >
        inc   y_pos,u
!       dec   ,s
        bne   @loop1
        stx   y_vel,u ; mis â jour
        puls  b,pc ; fix compteur + retour
@neg
        addd  y_pos+1,u
        std   y_pos+1,u
        bcs   >
        dec   y_pos,u
!       dec   ,s
        bne   @loop1
        stx   y_vel,u ; mis â jour
        puls  b,pc ; fix compteur + retour

UpdateFrame
        ldb   frame,u        ; original code use global counter
        addb  #2             ; to have a nice rotating effect
        andb  #6             ; here get continuous image transitions
        stb   frame,u
        ldx   #saw.images
        ldd   b,x
        std   image_set,u
        rts

saw.images
        fdb   Img_dobkeratops_saw_0
        fdb   Img_dobkeratops_saw_1
        fdb   Img_dobkeratops_saw_2
        fdb   Img_dobkeratops_saw_3

UpdateHitBox
        lda   AABB_0+AABB.p,u
        beq   >
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u
!       rts
