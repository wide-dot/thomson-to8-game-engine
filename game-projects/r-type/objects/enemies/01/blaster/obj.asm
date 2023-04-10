; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Blaster subtype :
;       
;       Bit 0, 1, 2, 3 => Y pos (29, 41, 53, 147, 159, 171)
;       Bit 4, 5, 6, 7 => Shoot timing (0 = no shoot, 1 = every 2s, 2 = every 1.5s, 3 = every 1s)
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/enemies_properties.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"

AABB_0                equ ext_variables   ; AABB struct (9 bytes)
shoottiming           equ ext_variables+9
shoottimingset        equ ext_variables+11
shootdirection        equ ext_variables+13

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
        addd  #144+10
        std   x_pos,u
        lda   subtype+1,u
        sta   subtype,u

        anda  #$0F
        ldx   #BlasterYTable
        ldb   a,x
        clra
        std   y_pos,u

        lda   subtype,u
        asra
        asra
        asra
        ldb   #3
        mul
        ldx   #BlasterShootingTiming+2
        ldd   b,x
        std   shoottimingset,u
        std   shoottiming,u

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

Live
        jsr   BlasterGetDirection
        sta   shootdirection,u
        asla
        ldx   #BlasterSpriteTable+10
        ldb   subtype,u
        andb  #$0F
        cmpb  #3
        blt   >
        ldx   #BlasterSpriteTable
!
        ldx   a,x
        stx   image_set,u

        ldd   shoottimingset,u
        beq   CheckEOL
        ldd   shoottiming,u                     ; Is it time to shoot ?
        subd  gfxlock.frameDrop.count_w
        std   shoottiming,u
        bpl   CheckEOL
        addd  shoottimingset,u
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
        ldy   #BlasterShootingTable+20
        ldb   subtype,u
        andb  #$0F
        cmpb  #3
        blt   >
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


BlasterYTable
        fcb   29
        fcb   41
        fcb   53
        fcb   147
        fcb   159
        fcb   171

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

BlasterShootingTiming
        fdb   $0000,$0000,$0000
        fdb   $00C0,$0140,$8FD0
        fdb   $0080,$0100,$9010
        fdb   $0080,$00C0,$9010
        fdb   $0040,$0080,$9050
        fdb   $0040,$0060,$9050
        fdb   $0030,$0050,$9090
        fdb   $0018,$0030,$90D0
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90
        fdb   $0040,$0140,$8F90