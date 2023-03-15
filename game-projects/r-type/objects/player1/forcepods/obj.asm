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
        INCLUDE "./objects/player1/player1.equ"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
currentlevel      equ ext_variables+9 ; Byte
hooked_status     equ ext_variables+10 ; Byte (0=Not hooked, 4=hooked front, 5=hooked back)
hookzoneignore    equ ext_variables+11 ; Byte
canshootweapon    equ ext_variables+12 ; Byte

canshootreboundlasertiming equ 20
canshootcounterairlasertiming equ 4

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveSetTrackSpot
        fdb   LiveSetTrackSpot
        fdb   LiveTrackPlayer1
        fdb   LiveHookedFront
        fdb   LiveHookedBack

Init
        ldd   #Ani_forcepod_2
        std   anim,u
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

        lda   #1
        sta   currentlevel,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        leax  AABB_0,u
        lda   #255                      ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  7,10                       ; set hitbox xy radius
        std   AABB.rx,x
        ldd   y_pos,u
        stb   AABB.cy,x

        ldd   #100
        std   y_pos,u
        std   @tsy
        ldd   glb_camera_x_pos
        subd  #10
        std   x_pos,u
LiveSetTrackSpot
        ldd   glb_camera_x_pos
        addd  #80
@stsx   equ   *-2                       ; Set X tracking position
        std   @tsx
LiveTrackspot
        jsr   Live
        ldx   #160
@tsvelxplus   equ   *-2
        ldd   #0
@tsx    equ   *-2                       ; Tracking spot X
        cmpd  x_pos,u
        bgt   @continuetsx
        ldx   #-100
@tsvelxmin   equ   *-2
@continuetsx
        stx   x_vel,u
        ldx   #160
        ldd   #0
@tsy    equ   *-2                       ; Tracking spot Y
        cmpd  y_pos,u
        bgt   @continuetsy
        ldx   #-160
        addd  #5
        cmpd  y_pos,u
        blt   @continuetsy
        ldd   @tsy
        std   y_pos,u
        ldx   #0
@continuetsy
        stx   y_vel,u
        jsr   ObjectMoveSync
	leax  AABB_0,u
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
LiveTrackPlayer1
        ldd   player1+y_pos
        addd  #6
        std   @tsy
        ldd   player1+x_pos
        addd  #6
        std   @tsx
        jmp   LiveTrackspot
Live
        lda   player1+forcepodlevel     ; Has forcepod been upgraded ?
        cmpa  currentlevel,u
        beq   @continueliveishooked     ; Nop, move along
        ldx   #Ani_forcepod_1
        cmpa  #2
        beq   >
        ldx   #Ani_forcepod_2
!
        stx   anim,u
        clr   anim_frame,u
        sta   currentlevel,u
@continueliveishooked
        lda   hooked_status,u
        beq   @continueliveisfree
                                        ; Forcepod is hooked
        ldb   Fire_Press
        andb  #c1_button_B_mask
        bne   @continueliveishookedcontinue     
        jsr   KTST
        bcc   >
        jsr   GETC
        cmpb  #$3E ; touche ">"     
        beq   @continueliveishookedcontinue
!       
        ldb   canshootweapon,u
        beq   >
        dec   canshootweapon,u
        rts
!
        ldb   Fire_Press
        andb  #c1_button_A_mask
        lbne  @counterairlaser
        rts                             
@continueliveishookedcontinue
        ldx   #10
        cmpa  #4
        bne   >                         ; Back hook               
        ldx   #140
!
        stx   @stsx
        ldx   #400
        stx   @tsvelxplus
        ldx   #-300
        stx   @tsvelxmin
        ldd   y_pos,u
        std   @tsy
        clr   hooked_status,u           ; Forcepod is free  
        lda   #1
        sta   routine,u
        lda   #5
        sta   hookzoneignore,u
        rts
@continueliveisfree
                                        ; Is forcepod close du player 1 (ie getting hooked)
        ldb   hookzoneignore,u
        beq   >
        decb
        stb   hookzoneignore,u
        rts
!
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        blt   @continuelivenothooked    ; Forcepod not on the screen yet
        lda   #4                        ; Sets A for routine 4 (LiveHookedFront)
        subb  player1+x_pos+1
        bpl   >
        negb
        inca                            ; Sets A to 5 (Same as lda #5 but saves a byte, plugging to routine LiveHookedBack)
!
        sta   @hookroutine
        cmpb  #10
        bgt   @continuelivenothooked    ; Not on X
        ldd   y_pos,u
        subd  player1+y_pos
        bpl   >
        negb
!
        cmpb  #10
        bgt   @continuelivenothooked    ; Not on Y either ... not hooked yet
        lda   #4                        ; Forcepod is Hooked
@hookroutine  equ   *-1
        sta   routine,u
        sta   hooked_status,u
        rts
@continuelivenothooked
        lda   Fire_Press
        anda  #c1_button_B_mask
        bne   @continuelivenothookedrecall
        jsr   KTST
        bcc   >
        jsr   GETC
        cmpb  #$3E ; touche ">"
        beq   @continuelivenothookedrecall
!
        lda   currentlevel,u
        cmpa  #1
        beq   > 
        lda   Fire_Press
        anda  #c1_button_A_mask
        beq   >
        jsr   LoadObject_x
        beq   >                             ; branch if no more available object slot
        lda   #ObjID_forcepod_straightup    ; fire straight up !
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        jsr   LoadObject_x
        beq   >                             ; branch if no more available object slot
        lda   #ObjID_forcepod_straightdown  ; fire straight up !
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
!
        rts
@continuelivenothookedrecall                                       ; Recalling forcepod
        lda   #3
        sta   routine,u
        ldx   #160
        stx   @tsvelxplus
        ldx   #-100
        stx   @tsvelxmin
        rts
@reboundlaser
        jsr   LoadObject_x
        lbeq  >                             
        lda   #ObjID_forcepod_reboundlaser  
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   #$05
        sta   subtype,x
        jsr   LoadObject_x
        lbeq  >                             
        lda   #ObjID_forcepod_reboundlaser  
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   #$85
        sta   subtype,x
!       
        ldb   #canshootreboundlasertiming
        stb   canshootweapon,u
        rts
@counterairlaser
        jsr   LoadObject_x
        lbeq  >                             
        lda   #ObjID_forcepod_counterairlaser
        sta   id,x
        lda   hooked_status,u
        sta   subtype,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
!       
        ldb   #canshootcounterairlasertiming
        stb   canshootweapon,u
        rts


LiveHookedFront

        jsr   Live
        leax  AABB_0,u
        ldd   player1+x_pos
	addd  #9
	std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   player1+y_pos
	std   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

LiveHookedBack

        jsr   Live
        leax  AABB_0,u
        ldd   player1+x_pos
	subd  #11
	std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
	ldd   player1+y_pos
	std   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB.cy,x
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
