; ---------------------------------------------------------------------------
; Get Orientation To Player
; Returns the horizontal and vertical distances of the closest player object.
;
; input REG : [u] pointeur sur l'objet
; output    : Gotp_Closest_Player    (ptr objet de MainCharacter ou Sidekick)
;             Gotp_Player_Is_Left    (0: player left from object, 2: right)
;             Gotp_Player_Is_Above   (0: player above object, 2: below)
;             Gotp_Player_H_Distance (closest character's h distance to obj)
;             Gotp_Player_V_Distance (closest character's v distance to obj)

glb_Closest_Player            fill  0,$2  ; ptr objet de MainCharacter ou Sidekick
glb_Player_Is_Left            fill  0,$1  ; 0: player left from object, 2: right
glb_Player_Is_Above           fill  0,$1  ; 0: player above object, 2: below
glb_Player_H_Distance         fill  0,$2  ; closest character's h distance to obj
glb_Player_V_Distance         fill  0,$2  ; closest character's v distance to obj 
glb_Abs_H_Distance_Mainc      fill  0,$2  ; absolute horizontal distance to main character
glb_H_Distance_Sidek          fill  0,$2  ; horizontal distance to sidekick

Gotp_Closest_Player          fdb   $0000     * ptr objet de MainCharacter ou Sidekick
Gotp_Player_Is_Left          fcb   $00       * 0: player left from object, 2: right
Gotp_Player_Is_Above         fcb   $00       * 0: player above object, 2: below
Gotp_Player_H_Distance       fdb   $0000     * closest character's h distance to obj
Gotp_Player_V_Distance       fdb   $0000     * closest character's v distance to obj 
Gotp_Abs_H_Distance_Mainc    fdb   $0000     * absolute horizontal distance to main character
Gotp_H_Distance_Sidek        fdb   $0000     * horizontal distance to sidekick
									   
                                       *; ---------------------------------------------------------------------------
                                       *; Get Orientation To Player
                                       *; Returns the horizontal and vertical distances of the closest player object.
                                       *;
                                       *; input variables:
                                       *;  a0 = object
                                       *;
                                       *; returns:
                                       *;  a1 = address of closest player character
                                       *;  d0 = 0 if player is left from object, 2 if right
                                       *;  d1 = 0 if player is above object, 2 if below
                                       *;  d2 = closest character's horizontal distance to object
                                       *;  d3 = closest character's vertical distance to object
                                       *;
                                       *; writes:
                                       *;  d0, d1, d2, d3, d4, d5
                                       *;  a1
                                       *;  a2 = sidekick
                                       *; ---------------------------------------------------------------------------
                                       *;loc_366D6:
Obj_GetOrientationToPlayer             *Obj_GetOrientationToPlayer:
        pshs  d,x
        lda   #$00
        sta   Gotp_Player_Is_Left      *    moveq   #0,d0
        sta   Gotp_Player_Is_Above     *    moveq   #0,d1
        ldx   MainCharacter            *    lea (MainCharacter).w,a1 ; a1=character
        ldd   x_pos,u                  *    move.w  x_pos(a0),d2
        subd  x_pos,x                  *    sub.w   x_pos(a1),d2
                                       *    mvabs.w d2,d4   ; absolute horizontal distance to main character
        std   Gotp_Player_H_Distance
        bpl   gotp_skip1
        coma
        comb
        addd  #$0001
gotp_skip1
        std   Gotp_Abs_H_Distance_Mainc
        ldx   Sidekick                 *    lea (Sidekick).w,a1 ; a1=character
        ldd   x_pos,u                  *    move.w  x_pos(a0),d3
        subd  x_pos,x                  *    sub.w   x_pos(a2),d3
        std   Gotp_H_Distance_Sidek
                                       *    mvabs.w d3,d5   ; absolute horizontal distance to sidekick
        bpl   gotp_skip2
        coma
        comb
        addd  #$0001
gotp_skip2
        cmpd  Gotp_Abs_H_Distance_Mainc
                                       *    cmp.w   d5,d4   ; get shorter distance
        bhi   MainCharacterIsCloser    *    bls.s   +   ; branch, if main character is closer
                                       *    ; if sidekick is closer
        stx   Gotp_Closest_Player      *    movea.l a2,a1
        ldd   Gotp_H_Distance_Sidek
        std   Gotp_Player_H_Distance   *    move.w  d3,d2
MainCharacterIsCloser                  *+
        lda   Gotp_Player_H_Distance
        bita  #$80                     *    tst.w   d2  ; is player to enemy's left?
        beq   PlayerToEnemysLeft       *    bpl.s   +   ; if not, branch
        lda   #$02
        sta   Gotp_Player_Is_Left      *    addq.w  #2,d0
PlayerToEnemysLeft                     *+
        ldd   y_pos,u                  *    move.w  y_pos(a0),d3
        subd  y_pos,x                  *    sub.w   y_pos(a1),d3    ; vertical distance to closest character
        std   Gotp_Player_V_Distance
        bhs   PlayerToEnemysAbove      *    bhs.s   +   ; branch, if enemy is under
        lda   #$02
        sta   Gotp_Player_Is_Above     *    addq.w  #2,d1
PlayerToEnemysAbove                    *+
        puls  d,x,pc
                                       *    rts