; ---------------------------------------------------------------------------
; Terrain Collision
; -----------------
; input : U ptr to object
;         B map id
; 
; return zero (no collision) or not zero (collision) in B
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

        ldx   #terrainCollision.maps
        aslb
        ldy   b,x                      ; set ptr to map in x

        ldx   #terrainCollision.yOffset
        ldd   terrainCollision.sensor.y
        _asld
        ldd   d,x                      ; load precomputed y position in map
        leay  d,y                      ; apply

        ldx   #terrainCollision.xOffset
        ldd   terrainCollision.sensor.x
        subd  glb_camera_x_pos
        addb  scroll_tile_pos_offset24
        abx
        lda   ,x                       ; load precomputed x position in map
        adda  scroll_tile_pos          ; get already scrolled x collision tiles

        ldx   #terrainCollision.xMask
        abx
        ldb   ,x                       ; read precomputed mask
        andb  a,y                      ; read collision data and apply against precomputed mask
        rts



terrainCollision.yOffset equ *-22 ; minus vertical viewport position * 2
        fdb   00*lvlMapWidth,00*lvlMapWidth,00*lvlMapWidth,00*lvlMapWidth,00*lvlMapWidth,00*lvlMapWidth
        fdb   01*lvlMapWidth,01*lvlMapWidth,01*lvlMapWidth,01*lvlMapWidth,01*lvlMapWidth,01*lvlMapWidth
        fdb   02*lvlMapWidth,02*lvlMapWidth,02*lvlMapWidth,02*lvlMapWidth,02*lvlMapWidth,02*lvlMapWidth
        fdb   03*lvlMapWidth,03*lvlMapWidth,03*lvlMapWidth,03*lvlMapWidth,03*lvlMapWidth,03*lvlMapWidth
        fdb   04*lvlMapWidth,04*lvlMapWidth,04*lvlMapWidth,04*lvlMapWidth,04*lvlMapWidth,04*lvlMapWidth
        fdb   05*lvlMapWidth,05*lvlMapWidth,05*lvlMapWidth,05*lvlMapWidth,05*lvlMapWidth,05*lvlMapWidth
        fdb   06*lvlMapWidth,06*lvlMapWidth,06*lvlMapWidth,06*lvlMapWidth,06*lvlMapWidth,06*lvlMapWidth
        fdb   07*lvlMapWidth,07*lvlMapWidth,07*lvlMapWidth,07*lvlMapWidth,07*lvlMapWidth,07*lvlMapWidth
        fdb   08*lvlMapWidth,08*lvlMapWidth,08*lvlMapWidth,08*lvlMapWidth,08*lvlMapWidth,08*lvlMapWidth
        fdb   09*lvlMapWidth,09*lvlMapWidth,09*lvlMapWidth,09*lvlMapWidth,09*lvlMapWidth,09*lvlMapWidth
        fdb   10*lvlMapWidth,10*lvlMapWidth,10*lvlMapWidth,10*lvlMapWidth,10*lvlMapWidth,10*lvlMapWidth
        fdb   11*lvlMapWidth,11*lvlMapWidth,11*lvlMapWidth,11*lvlMapWidth,11*lvlMapWidth,11*lvlMapWidth
        fdb   12*lvlMapWidth,12*lvlMapWidth,12*lvlMapWidth,12*lvlMapWidth,12*lvlMapWidth,12*lvlMapWidth
        fdb   13*lvlMapWidth,13*lvlMapWidth,13*lvlMapWidth,13*lvlMapWidth,13*lvlMapWidth,13*lvlMapWidth
        fdb   14*lvlMapWidth,14*lvlMapWidth,14*lvlMapWidth,14*lvlMapWidth,14*lvlMapWidth,14*lvlMapWidth
        fdb   15*lvlMapWidth,15*lvlMapWidth,15*lvlMapWidth,15*lvlMapWidth,15*lvlMapWidth,15*lvlMapWidth
        fdb   16*lvlMapWidth,16*lvlMapWidth,16*lvlMapWidth,16*lvlMapWidth,16*lvlMapWidth,16*lvlMapWidth
        fdb   17*lvlMapWidth,17*lvlMapWidth,17*lvlMapWidth,17*lvlMapWidth,17*lvlMapWidth,17*lvlMapWidth
        fdb   18*lvlMapWidth,18*lvlMapWidth,18*lvlMapWidth,18*lvlMapWidth,18*lvlMapWidth,18*lvlMapWidth
        fdb   19*lvlMapWidth,19*lvlMapWidth,19*lvlMapWidth,19*lvlMapWidth,19*lvlMapWidth,19*lvlMapWidth
        fdb   20*lvlMapWidth,20*lvlMapWidth,20*lvlMapWidth,20*lvlMapWidth,20*lvlMapWidth,20*lvlMapWidth
        fdb   21*lvlMapWidth,21*lvlMapWidth,21*lvlMapWidth,21*lvlMapWidth,21*lvlMapWidth,21*lvlMapWidth
        fdb   22*lvlMapWidth,22*lvlMapWidth,22*lvlMapWidth,22*lvlMapWidth,22*lvlMapWidth,22*lvlMapWidth
        fdb   23*lvlMapWidth,23*lvlMapWidth,23*lvlMapWidth,23*lvlMapWidth,23*lvlMapWidth,23*lvlMapWidth
        fdb   24*lvlMapWidth,24*lvlMapWidth,24*lvlMapWidth,24*lvlMapWidth,24*lvlMapWidth,24*lvlMapWidth
        fdb   25*lvlMapWidth,25*lvlMapWidth,25*lvlMapWidth,25*lvlMapWidth,25*lvlMapWidth,25*lvlMapWidth
        fdb   26*lvlMapWidth,26*lvlMapWidth,26*lvlMapWidth,26*lvlMapWidth,26*lvlMapWidth,26*lvlMapWidth
        fdb   27*lvlMapWidth,27*lvlMapWidth,27*lvlMapWidth,27*lvlMapWidth,27*lvlMapWidth,27*lvlMapWidth
        fdb   28*lvlMapWidth,28*lvlMapWidth,28*lvlMapWidth,28*lvlMapWidth,28*lvlMapWidth,28*lvlMapWidth
        fdb   29*lvlMapWidth,29*lvlMapWidth,29*lvlMapWidth,29*lvlMapWidth,29*lvlMapWidth,29*lvlMapWidth
        
terrainCollision.xOffset equ *-8 ; minus horizontal viewport position
        fcb   0,0,0 ; x_pos 0
        fcb   0,0,0
        fcb   0,0,0
        fcb   0,0,0
        fcb   0,0,0
        fcb   0,0,0
        fcb   0,0,0
        fcb   0,0,0
        fcb   1,1,1 ; x_pos 24
        fcb   1,1,1
        fcb   1,1,1
        fcb   1,1,1
        fcb   1,1,1
        fcb   1,1,1
        fcb   1,1,1
        fcb   1,1,1
        fcb   2,2,2 ; x_pos 48
        fcb   2,2,2
        fcb   2,2,2
        fcb   2,2,2
        fcb   2,2,2
        fcb   2,2,2
        fcb   2,2,2
        fcb   2,2,2
        fcb   3,3,3 ; x_pos 72
        fcb   3,3,3
        fcb   3,3,3
        fcb   3,3,3
        fcb   3,3,3
        fcb   3,3,3
        fcb   3,3,3
        fcb   3,3,3
        fcb   4,4,4 ; x_pos 96
        fcb   4,4,4
        fcb   4,4,4
        fcb   4,4,4
        fcb   4,4,4
        fcb   4,4,4
        fcb   4,4,4
        fcb   4,4,4
        fcb   5,5,5 ; x_pos 120
        fcb   5,5,5
        fcb   5,5,5
        fcb   5,5,5
        fcb   5,5,5
        fcb   5,5,5
        fcb   5,5,5
        fcb   5,5,5
        fcb   6,6,6 ; x_pos 144
        fcb   6,6,6
        fcb   6,6,6
        fcb   6,6,6
        fcb   6,6,6
        fcb   6,6,6
        fcb   6,6,6
        fcb   6,6,6

terrainCollision.xMask equ *-8 ; minus horizontal viewport position
        fcb   $80,$80,$80 ; x_pos 0
        fcb   $40,$40,$40
        fcb   $20,$20,$20
        fcb   $10,$10,$10
        fcb   $08,$08,$08
        fcb   $04,$04,$04
        fcb   $02,$02,$02
        fcb   $01,$01,$01
        fcb   $80,$80,$80 ; x_pos 24
        fcb   $40,$40,$40
        fcb   $20,$20,$20
        fcb   $10,$10,$10
        fcb   $08,$08,$08
        fcb   $04,$04,$04
        fcb   $02,$02,$02
        fcb   $01,$01,$01
        fcb   $80,$80,$80 ; x_pos 48
        fcb   $40,$40,$40
        fcb   $20,$20,$20
        fcb   $10,$10,$10
        fcb   $08,$08,$08
        fcb   $04,$04,$04
        fcb   $02,$02,$02
        fcb   $01,$01,$01
        fcb   $80,$80,$80 ; x_pos 72
        fcb   $40,$40,$40
        fcb   $20,$20,$20
        fcb   $10,$10,$10
        fcb   $08,$08,$08
        fcb   $04,$04,$04
        fcb   $02,$02,$02
        fcb   $01,$01,$01
        fcb   $80,$80,$80 ; x_pos 96
        fcb   $40,$40,$40
        fcb   $20,$20,$20
        fcb   $10,$10,$10
        fcb   $08,$08,$08
        fcb   $04,$04,$04
        fcb   $02,$02,$02
        fcb   $01,$01,$01
        fcb   $80,$80,$80 ; x_pos 120
        fcb   $40,$40,$40
        fcb   $20,$20,$20
        fcb   $10,$10,$10
        fcb   $08,$08,$08
        fcb   $04,$04,$04
        fcb   $02,$02,$02
        fcb   $01,$01,$01
        fcb   $80,$80,$80 ; x_pos 144
        fcb   $40,$40,$40
        fcb   $20,$20,$20
        fcb   $10,$10,$10
        fcb   $08,$08,$08
        fcb   $04,$04,$04
        fcb   $02,$02,$02
        fcb   $01,$01,$01
