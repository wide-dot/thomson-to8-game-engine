
; ---------------------------------------------------------------------------
; Object - Weapon
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;       subtype : bit 6 => 0=going right, 1=going left
;                 bit 7 => 0=going up,   1=going down
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0  equ ext_variables ; AABB struct (9 bytes)
currentspeedx equ ext_variables+9 ; byte
currentspeedy equ ext_variables+10 ; byte
childaddr     equ ext_variables+11 ; word
is_child      equ ext_variables+13 ; byte (0=head, other value = child)
old_posx      equ ext_variables+14 ; word
old_posy      equ ext_variables+16 ; word
old_imgset    equ ext_variables+18 ; word
speedxp equ $2
speedxm equ $-1
speedyp equ $4
speedym equ $-4
maxvintcount equ 4

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   InitNextFrame
        fdb   LiveAsParent
        fdb   LiveAsChild
        fdb   AlreadyDeleted

Init
        ldd   x_pos,u
        addd  #6
        std   x_pos,u
        ldd   y_pos,u
        addd  #2
        std   y_pos,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_friend
        
        lda   #255                     ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  3,7                      ; set hitbox xy radius
        std   AABB_0+AABB.rx,u

        inc   routine,u                ; Set routine to InitNextFrame
        lda   is_child,u
        lbne  LiveAsChild
        lda   #1 
        sta   AABB_0+AABB.p,u
        ldb   subtype,u
        lda   #speedxp
        bitb  #%01000000
        beq   >
        lda   #speedxm
!
        sta   currentspeedx,u
        ldx   #Img_reboundlaser_0
        lda   #speedym
        bitb  #%10000000
        beq   >
        ldx   #Img_reboundlaser_1
        lda   #speedyp
!
        sta   currentspeedy,u
        stx   image_set,u
        bra   Object

InitNextFrame
        inc   routine,u                   ; Set routine to LiveAsParent
        lda   is_child,u
        beq   >
        inc   routine,u                   ; Set routine to LiveAsChild
!
        ldb   subtype,u
        andb  #%11000000
        stb   @flagsubtype
        ldb   subtype,u
        andb  #%00111111
        lbeq  Object                      ; It was the last laser to spawn
        decb
        orb   #00
@flagsubtype equ *-1
        jsr   LoadObject_x
        lbeq  Object
        stx   childaddr,u
        stb   subtype,x                   
        lda   #ObjID_forcepod_reboundlaser  
        sta   id,x
        sta   is_child,x
        ldd   x_pos,u
        std   old_posx,x
        ldd   y_pos,u
        std   old_posy,x
        ldd   image_set,u
        std   old_imgset,x
        ldd   currentspeedx,u
        std   currentspeedx,x
        lbra  Object
LiveAsParent
        ldx   childaddr,u
        beq   >
        ldd   x_pos,u
        std   old_posx,x
        ldd   y_pos,u
        std   old_posy,x
        ldd   image_set,u
        std   old_imgset,x
        ldd   currentspeedx,u
        std   currentspeedx,x
!
        ldb   gfxlock.frameDrop.count
        cmpb  #maxvintcount+1
        blt   >
        ldb   #maxvintcount
!
        stb   @count       
        lda   AABB_0+AABB.p,u
        lbeq  @delete                 ; delete weapon if something was hit  
        lda   is_child,u
        bne   >
        lda   currentspeedx,u
        ldb   #1
@count equ *-1
        mul
        addd  x_pos,u
        std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        cmpd  #0
        blt   @delete
        cmpd  #144
        bgt   @delete
        ldb   @count
        lda   currentspeedy,u
        mul
        sex
        addd  y_pos,u
        std   y_pos,u
        stb   AABB_0+AABB.cy,u
        cmpd  #191                 
        bge   @delete
        cmpd  #5
        blt   @delete
                                       ; First, let's check the rebound Y
                                       ; (That will be simulated by pos Y)
                                       ; Let's then check if it is still inside the window
        ldd   y_pos,u
        cmpd  #22
        blt   @reboundy
        cmpd  #179
        bgt   @reboundy
        clrb
        lda   currentspeedy,u
        bmi   >
        ldb   #$04
!
        lda   currentspeedx,u
        bpl   >
        andb  #$02
!
        ldx   #spritetable
        ldd   b,x
        std   image_set,u
        jmp   DisplaySprite
@reboundy
        ldx   #Img_reboundlaser_2
        lda   #speedyp
        ldb   currentspeedy,u
        bmi   >
        ldx   #Img_reboundlaser_3
        lda   #speedym
!
        sta   currentspeedy,u
        stx   image_set,u
        jmp   DisplaySprite
@delete 
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        lda   #4
        sta   routine,u
        ldx   childaddr,u
        beq   >                  ; no child, skip
        clr   is_child,x         ; Clear is_child ( = head)
        lda   #2                 ; Set child object's routine to LiveAsParent
        sta   routine,x
        deca                     ; Set damage to 1
        sta   AABB_0+AABB.p,x
!
        jmp   DeleteObject

LiveAsChild      
        lda   routine,u
        cmpa  #3
        beq   >
        _breakpoint
!
        ldx   childaddr,u
        beq   >
        ldd   x_pos,u
        std   old_posx,x
        ldd   y_pos,u
        std   old_posy,x
        ldd   image_set,u
        std   old_imgset,x
        ldd   currentspeedx,u
        std   currentspeedx,x
!
        ldd   old_posx,u
        std   x_pos,u
        ldd   old_posy,u
        std   y_pos,u
        ldd   old_imgset,u
        std   image_set,u
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        jmp   DisplaySprite


AlreadyDeleted
        rts


spritetable   fdb Img_reboundlaser_0
              fdb Img_reboundlaser_1
              fdb Img_reboundlaser_1
              fdb Img_reboundlaser_0