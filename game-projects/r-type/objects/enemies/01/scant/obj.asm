; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Scant_isshooting        equ ext_variables
Scant_backfire          equ $80
Scant_sensitivity       equ 5

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Scant_init
        fdb   Scant_live
        fdb   Scant_shoot
        fdb   Scant_stopshooting

Scant_init
        ldb   #6    
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

Scant_stopshooting
        clr   Scant_isshooting,u
        lda   #1
        sta   routine,u
        ldd   #Ani_scant
        std   anim,u   
        clr   anim_frame,u 
        ldd   #$-30
        std   x_vel,u

Scant_live
        jsr   Scant_whattodo
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

Scant_shoot 
        jsr   Scant_shooting
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite


!
        jmp   DeleteObject

Scant_whattodo

        ldd   player1+y_pos
        addd  #Scant_sensitivity
        cmpd  y_pos,u
        blt   Scant_keepup
        subd  #Scant_sensitivity*2
        cmpd  y_pos,U
        bgt   Scant_keepdown
        ldd   player1+x_pos
        cmpd  x_pos,u
        blt   >
        ldd   #00               ; past the r-rtype (on its left), don't shoot
        std   y_vel,u
        rts
!       
        ;lda   x_pixel,u
        ;cmpa  #160
        ;blt   >
        ;ldd   #00               ; too far on the right of the screen, don't shoot
        ;std   y_vel,u
        ;rts     
!                               ; time to initiate the shoot
        ldd   #00
        std   y_vel,u
        std   x_vel,u
        ldd   #Ani_scant_shoot
        std   anim,u
        inc   routine,u
        rts
Scant_keepdown
        ldd   #$30
        std   y_vel,u
        rts
Scant_keepup
        ldd   #$-30
        std   y_vel,u
        rts
Scant_shooting

        lda   anim_frame,u 
        cmpa  #5
        bgt   Scant_shootdown
        cmpa  #3
        bgt   Scant_initiateshoot
        rts
Scant_shootdown
        clr   x_vel,u
        rts
Scant_initiateshoot
        lda   Scant_isshooting,u
        beq   >
        cmpa  #1
        beq   @scantfireball
        rts
!
        ldd   player1+y_pos             ; Let's re-evaluate the shooting
        addd  #Scant_sensitivity
        cmpd  y_pos,u
        blt   Scant_keepup
        subd  #Scant_sensitivity*2
        cmpd  y_pos,U
        bgt   Scant_keepdown
        ldd   player1+x_pos
        cmpd  x_pos,u
        blt   >        
        clr   Scant_isshooting,u        ; No longer good to shoot, reset
        lda   #1
        sta   routine,u
        ldd   #Ani_scant
        std   anim,u   
        clr   anim_frame,u 
        ldd   #$-30
        std   x_vel,u
        rts                   
!
        jsr   LoadObject_x              ; Alright, this time, we're good ! Shoot !
        beq   >
        lda   #ObjID_scantfire
        sta   id,x
        ldd   x_pos,u
        subd  #16
        std   x_pos,x
        ldd   y_pos,u
        subd  #7
        std   y_pos,x
        ldd   #$-160
        std   x_vel,x
        ldd   #0
        std   y_vel,x
        ldd   #Scant_backfire
        std   x_vel,u
        lda   #1
        sta   Scant_isshooting,u
!
        rts
@scantfireball
        jsr   LoadObject_x ; Scant shoot
        beq   >
        lda   #ObjID_scantfireball
        sta   id,x
        ldd   x_pos,u
        subd  #16
        std   x_pos,x
        ldd   y_pos,u
        subd  #7
        std   y_pos,x
        ldd   #Scant_backfire
        std   x_vel,x
        ldd   #0
        std   y_vel,x
        lda   #2
        sta   Scant_isshooting,u
!
        rts

