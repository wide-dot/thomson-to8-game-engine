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

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   LevelInitPhase0
        fdb   LevelInitPhase0Live
        fdb   LevelInitPhase1Live
        fdb   LevelInitPhase2Live
        fdb   LevelInitPhase3Live
        fdb   AlreadyDeleted

* ---------------------------------------------------------------------------
* PLAYER 1 LEVEL 1 INIT
* ---------------------------------------------------------------------------

LevelInitPhase0
        inc   routine,u
        lda   #50
        sta   LevelInitPhase0_a
        lda   #$FF
        sta   player1+subtype  
LevelInitPhase0Live
        lda   #0
LevelInitPhase0_a equ *-1
        beq   LevelInitPhase1
        deca
        sta   LevelInitPhase0_a
        rts

LevelInitPhase1
        inc   routine,u
        lda   #$01
        sta   player1+subtype  

        ; Load engine flames
        jsr   LoadObject_x
        stx   engineflames
        lda   #ObjID_engineflames
        sta   id,x    
        ldd   #280
        std   player1+x_vel


LevelInitPhase1Live

        ldd   player1+x_pos
        cmpd  #140
        bgt   LevelInitPhase2
        rts

LevelInitPhase2
        inc   routine,u

        ldx   #0
engineflames equ *-2
        lda   #2
        sta   routine,x
        ldd   #150
        std   player1+x_vel
LevelInitPhase2Live
        ldd   player1+x_pos
        cmpd  #160
        bgt   LevelInitPhase3
        rts

LevelInitPhase3
        inc   routine,u
        ldd   #-180
        std   player1+x_vel
LevelInitPhase3Live
        ldd   player1+x_pos
        cmpd  #110
        blt   LetsStart
        rts              

LetsStart

        clr   player1+subtype
        inc   routine,u     
        jmp   DeleteObject
AlreadyDeleted
        rts