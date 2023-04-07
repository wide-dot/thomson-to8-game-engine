; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Blaster subtype :
;       
;       Bit 0 : 0 => Facing down, 1 => Facing up
;       All bits : Shooting timing (which includes bit 0)
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/enemies_properties.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0                equ ext_variables   ; AABB struct (9 bytes)
shoottiming           equ ext_variables+9
shootdirection        equ ext_variables+11

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

        ldd   glb_camera_x_pos
        addd  #144+12
        std   x_pos,u
        clra
        ldb   subtype,u
        std   y_pos,u
        ldb   subtype+1,u
        stb   subtype,u

        ldb   #6
        stb   priority,u

        lda   #render_playfieldcoord_mask
        sta   render_flags,u

        _Collision_AddAABB AABB_0,AABB_list_ennemy
        
        lda   #blaster_hitdamage
        sta   AABB_0+AABB.p,u
        _ldd  blaster_hitbox_x,blaster_hitbox_y
        std   AABB_0+AABB.rx,u

        ldd   y_pos,u
        subd  glb_camera_y_pos
        stb   AABB_0+AABB.cy,u

        inc   routine,u
        ldb   subtype,u
        clra
        std   shoottiming,u


Live
        jsr   BlasterGetDirection
        sta   shootdirection,u
        asla
        ldx   #BlasterSpriteTable+10
        ldb   subtype,u
        bitb  #$01
        beq   >
        ldx   #BlasterSpriteTable
!
        ldx   a,x
        stx   image_set,u

        ldd   shoottiming,u                     ; Is it time to shoot ?
        subd  gfxlock.frameDrop.count_w
        std   shoottiming,u
        bpl   CheckEOL
        ldb   subtype,u                         ; It's time to shoot !
        clra
        std   shoottiming,u
        jsr   LoadObject_x                
        beq   CheckEOL      
        lda   #ObjID_foefire
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   shootdirection,u
        asla
        asla
        ldb   subtype,u
        ldy   #BlasterShootingTable+20
        bitb  #$01
        beq   >
        ldy   #BlasterShootingTable
!
        leay  a,y
        ldd   ,y
        std   x_vel,x
        ldd   2,y
        std   y_vel,x

CheckEOL
        lda   AABB_0+AABB.p,u
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #4                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        jmp   DisplaySprite
@destroy
        ldd   score
        addd  #blaster_score
        std   score 
        jsr   LoadObject_x
        beq   @delete
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        clr   x_vel,x
        clr   y_vel,x
@delete 
        inc   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts


BlasterGetDirection

        ldd   player1+y_pos  
        subd  #10          
        cmpd  y_pos,u
        bgt   BlasterGetDirectionNotHorizontal
        addd  #20
        cmpd  y_pos,u
        blt   BlasterGetDirectionNotHorizontal
        clra
        ldx   player1+x_pos            
        cmpx  x_pos,u
        blt   >
        lda   #4
!
        rts
BlasterGetDirectionNotHorizontal

        ldd   player1+x_pos
        subd  #15          
        cmpd  x_pos,u
        bgt   BlasterGetDirectionNotVertical
        addd  #30
        cmpd  x_pos,u
        blt   BlasterGetDirectionNotVertical
        lda   #2
        rts

BlasterGetDirectionNotVertical
        lda   #1
        ldx   player1+x_pos            
        cmpx  x_pos,u
        blt   >
        lda   #3
!
        rts


BlasterSpriteTable

        fdb   Img_blaster_0
        fdb   Img_blaster_1
        fdb   Img_blaster_2
        fdb   Img_blaster_3
        fdb   Img_blaster_4
        fdb   Img_blaster_5
        fdb   Img_blaster_6
        fdb   Img_blaster_7
        fdb   Img_blaster_8
        fdb   Img_blaster_9

BlasterShootingTable
        fdb   -$80,$00
        fdb   -$80,-$80
        fdb   $00,-$120
        fdb   $80,-$80
        fdb   $80,$00
        fdb   -$80,$00
        fdb   -$80,$80
        fdb   $00,$120
        fdb   $80,$80
        fdb   $80,$00