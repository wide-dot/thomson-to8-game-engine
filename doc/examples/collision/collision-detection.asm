; ------ collision-detection.asm ------
; From: r-type game engine
; Example: How to detect collision between two objects (AABB - Axis-Aligned Bounding Box)
;
; Usage:
;   1. Define hitboxes for objects (x, y, width, height)
;   2. Call collision:check-rect-collision with two object addresses
;   3. Returns collision flag (0 = no collision, 1 = collision)
;   4. Handle collision response (damage, sound, effect)
;
; Dependencies: collision subsystem

; Check if two rectangles collide
; Input: X = object1 address, Y = object2 address
; Output: A = 1 if collision, 0 if no collision
check-rect-collision:
    ; Object structure: hitbox at offset +0 (x,y,w,h)

    ; Load object1 hitbox
    lda [X,0]            ; obj1.x
    ldb [Y,0]            ; obj2.x
    cba                  ; Compare X positions
    blt check-y          ; If obj1.x < obj2.x, check Y

    ; No collision on X axis
    lda #0
    rts

check-y:
    ; Similar check for Y axis
    ; [simplified - see full r-type source for complete logic]

    lda #1               ; Collision found
    rts

no-collision:
    lda #0               ; No collision
    rts

; See full context: game-projects/r-type/[collision module]
