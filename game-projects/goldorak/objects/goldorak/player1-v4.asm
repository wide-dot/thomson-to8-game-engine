; ---------------------------------------------------------------------------
; Object - Player
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Player
        lda   routine,u
        asla
        ldx   #Player_Routines
        jmp   [a,x]

Player_Routines
        fdb   Init
        fdb   Live

Init
        ldd   #Ani_Player1
        std   anim,u
        ldb   #$04
        stb   priority,u
        ldd   #$0050
        std   x_pos,u
        ldd   #$0063
        std   y_pos,u

******** set object to use camera coord
            *ldd   #80
            *std   x_pos,u
            *ldd   #100
            *std   y_pos,u

            *ldd   #0  *-$400
            *std   y_vel,u
            *ldd   y_pos,u

            ldd   #48
            std   glb_camera_x_offset
            ldd   #28
            std   glb_camera_y_offset

            lda   render_flags,u
            ora   #render_playfieldcoord_mask
            sta   render_flags,u
            inc   routine,u

        rts

Live
    ldd  x_pos,u
    cmpd #0+10
    BLE limiteLeft
    bra >
limiteLeft
    ldd   #0+10+1
    std   x_pos,u
    bra XV0
!
    ldd  x_pos,u
    cmpd #159-10
    BGE limiteRight
    bra >
limiteRight
    ldd   #159-10-1
    std   x_pos,u
    bra XV0
!
    ldd  y_pos,u
    cmpd #0+20
    BLE limiteTop
    bra >
limiteTop
    ldd   #0+20+1
    std   y_pos,u
    bra YV0
!
    ldd  y_pos,u
    cmpd #199-20
    BGE limiteBottom
    bra >
limiteBottom
    ldd   #199-20-1
    std   y_pos,u
    bra YV0
!


live_s
    lda ddJoy
    cmpa #0
    beq set0
    cmpa #1
    beq setL
    cmpa #2
    beq setR
    cmpa #3
    beq setT
    cmpa #4
    beq setB
    bra   startVelX
set0
    ldd   #Ani_Player1
    std   anim,u
    bra   startVelX
setL
    ldd   #Ani_Player1_left
    std   anim,u
    bra   startVelX
setR
    ldd   #Ani_Player1_right
    std   anim,u
    bra   startVelX
setT

    bra   startVelX
setB

    *bra   startVelX

startVelX *********************
    ldd velocityX
    BPL incXVel
    BMI decXVel
XV0 ldd   #0
    STD velocityX
    bra startVelY
incXVel
    ldd velocityX
    SUBD decspeed
    STD velocityX
        ldd velocityX
        cmpd #0
        BLT XV0
    bra startVelY
decXVel
    ldd velocityX
    ADDD decspeed
    STD velocityX
        ldd velocityX
        cmpd #0
        BGT XV0
    *bra   startVelY

startVelY *********************
    ldd velocityY
    BPL incYVel
    BMI decYVel
YV0 ldd   #0
    STD velocityY
    bra applyVel
incYVel
    ldd velocityY
    SUBD decspeed
    STD velocityY
        ldd velocityY
        cmpd #0
        BLT YV0
    bra applyVel
decYVel
    ldd velocityY
    ADDD decspeed
    STD velocityY
        ldd velocityY
        cmpd #0
        BGT YV0
    *bra applyVel

applyVel *********************
    ldd velocityX
    std   x_vel,u
    ldd velocityY
    std   y_vel,u

testJoy
    lda #0
    sta ddJoy

        **** weapon fire
        ldb   Fire_Press
        bitb  #c1_button_A_mask
        beq   TestLeft
*            ldd   #159/2
*            std   x_pos,u
*            ldd   #199/2
*            std   y_pos,u
            jsr   LoadObject_u
            lda   #ObjID_Weapon10
            sta   id,u
*            jsr   LoadObject_x
*            lda   #ObjID_Weapon10
*            sta   id,x

        ****


TestLeft
        lda   Dpad_Held
        bita  #c1_button_left_mask
        beq   TestRight
                lda #1
                sta ddJoy
                jsr decVelX
        bra   TestUp
TestRight
        lda   Dpad_Held
        bita  #c1_button_right_mask
        beq   TestUp
                lda #2
                sta ddJoy
                jsr incVelX
TestUp
        lda   Dpad_Held
        bita  #c1_button_up_mask
        beq   TestDown
                lda #3
                sta ddJoy
                jsr decVelY
        bra   Anim
TestDown
        lda   Dpad_Held
        bita  #c1_button_down_mask
        beq   Anim
                lda #4
                sta ddJoy
                jsr incVelY
Anim
        jsr   AnimateSprite
        jsr   ObjectMove
        jmp   DisplaySprite

*************
* sub routines
*************
incVelX
    ldd velocityX
    ADDD speed
    STD velocityX
    RTS
decVelX
    ldd velocityX
    SUBD speed
    STD velocityX
    RTS
incVelY
    ldd velocityY
    ADDD speed
    STD velocityY
    RTS
decVelY
    ldd velocityY
    SUBD speed
    STD velocityY
    RTS

weapons
    jsr   LoadObject_u
    lda   #ObjID_Weapon10
    sta   id,u
    bra TestLeft
*    RTS


*************
* variables
*************
ddJoy   fcb 0
velocityX fdb 0
velocityY fdb 0

*************
* static params
*************
speed fdb 50
decspeed fdb 30
