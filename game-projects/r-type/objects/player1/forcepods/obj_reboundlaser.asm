
; ---------------------------------------------------------------------------
; Object - Weapon1
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
is_child      equ ext_variables+13 ; byte
old_posx      equ ext_variables+14 ; word
old_posy      equ ext_variables+16 ; word
old_imgset    equ ext_variables+18 ; word
speedxp equ $2
speedxm equ $-1
speedyp equ $4
speedym equ $-4
Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   InitNextFrame
        fdb   Live
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
        
        leax  AABB_0,u
        lda   #1                       ; set damage potential for this hitbox
        sta   AABB.p,x
        _ldd  3,7                      ; set hitbox xy radius
        std   AABB.rx,x

        inc   routine,u
        lda   is_child,u
        bne   Live
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
        bra   Live

InitNextFrame
        inc   routine,u
        ldb   subtype,u
        andb  #%11000000
        stb   @flagsubtype
        ldb   subtype,u
        andb  #%00111111
        beq   Live                      ; It was the last laser to spawn
        decb
        orb   #00
@flagsubtype equ *-1
        jsr   LoadObject_x
        beq   Live
        _breakpoint
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
Live
        lda   is_child,u
        lbne  LiveAsChild
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
        leax  AABB_0,u        
        lda   AABB.p,x
        lbeq  @delete                 ; delete weapon if something was hit  
        lda   is_child,u
        bne   >
        lda   currentspeedx,u
        ldb   Vint_Main_runcount
        mul
        addd  x_pos,u
        std   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        cmpd  #0
        blt   @delete
        cmpd  #144
        bgt   @delete
        ldb   Vint_Main_runcount
        lda   currentspeedy,u
        mul
        sex
        addd  y_pos,u
        std   y_pos,u
        stb   AABB.cy,x
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
        lda   #3
        sta   routine,u
        ldx   childaddr,u
        clr   is_child,x
        jmp   DeleteObject

LiveAsChild       
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
        leax  AABB_0,u 
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB.cx,x
        ldb   y_pos+1,u
        stb   AABB.cy,x
        jmp   DisplaySprite


AlreadyDeleted
        rts


spritetable   fdb Img_reboundlaser_0
              fdb Img_reboundlaser_1
              fdb Img_reboundlaser_1
              fdb Img_reboundlaser_0