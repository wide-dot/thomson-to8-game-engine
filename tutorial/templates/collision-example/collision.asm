; Minimal AABB collision detection example for Thomson TO8
; This code shows how to:
; 1. Define object bounding boxes
; 2. Perform axis-aligned bounding box (AABB) collision tests
; 3. Handle collision responses

; ==================== CONSTANTS ====================

; Object structure
OBJECT_X        equ 0           ; X coordinate
OBJECT_Y        equ 1           ; Y coordinate
OBJECT_W        equ 2           ; Width
OBJECT_H        equ 3           ; Height
OBJECT_SIZE     equ 4

; ==================== DATA ====================

    org $2000

; Example objects
; CHANGE THIS: Replace with your game objects

Player:
    fcb 100         ; X = 100
    fcb 100         ; Y = 100
    fcb 16          ; Width = 16
    fcb 16          ; Height = 16

Enemy:
    fcb 120         ; X = 120
    fcb 110         ; Y = 110
    fcb 12          ; Width = 12
    fcb 12          ; Height = 12

; ==================== MAIN LOOP ====================

Start:
    ; Check collision between player and enemy
    ldu #Player
    ldx #Enemy
    jsr CheckCollision
    
    ; If collision detected (Z flag clear), handle it
    beq NoCollision
    
    jsr HandleCollision
    
NoCollision:
    ; Continue game loop
    bra Start

; ==================== AABB COLLISION CHECK ====================
; Input:
;   U = pointer to object 1 (player)
;   X = pointer to object 2 (enemy)
; Output:
;   Z flag = 1 if NO collision, 0 if collision detected
; Clobbers: A, B, D

CheckCollision:
    ; AABB collision test:
    ; obj1.x < obj2.x + obj2.w  AND
    ; obj1.x + obj1.w > obj2.x  AND
    ; obj1.y < obj2.y + obj2.h  AND
    ; obj1.y + obj1.h > obj2.y
    
    ; Get coordinates from objects
    lda u, x0       ; A = obj1.x (offset OBJECT_X = 0)
    ldb x, x0       ; B = obj2.x
    
    ; Check: obj1.x < obj2.x + obj2.w
    ldd u, x2       ; D = obj1.w
    addb u, x2      ; B = obj2.x + obj2.w (CHANGE THIS: should use obj2 width)
    cmpa b
    bge NoCollision ; If obj1.x >= obj2.x + obj2.w, no collision
    
    ; Check: obj1.x + obj1.w > obj2.x
    lda u, x0       ; A = obj1.x
    adda u, x2      ; A = obj1.x + obj1.w
    ldb x, x0       ; B = obj2.x
    cmpa b
    ble NoCollision ; If obj1.x + obj1.w <= obj2.x, no collision
    
    ; Check Y axis
    lda u, x1       ; A = obj1.y (offset OBJECT_Y = 1)
    ldb x, x1       ; B = obj2.y
    
    ; Check: obj1.y < obj2.y + obj2.h
    addb x, x3      ; B = obj2.y + obj2.h
    cmpa b
    bge NoCollision ; If obj1.y >= obj2.y + obj2.h, no collision
    
    ; Check: obj1.y + obj1.h > obj2.y
    lda u, x1       ; A = obj1.y
    adda u, x3      ; A = obj1.y + obj1.h
    ldb x, x1       ; B = obj2.y
    cmpa b
    ble NoCollision ; If obj1.y + obj1.h <= obj2.y, no collision
    
    ; All checks passed: collision detected
    clrz            ; Clear Z flag to indicate collision
    rts
    
NoCollision:
    testz           ; Set Z flag to indicate no collision
    rts

; ==================== COLLISION RESPONSE ====================
; Handle what happens when objects collide
; CHANGE THIS: Implement your collision response

HandleCollision:
    ; Example: Award points, remove enemy, etc.
    
    ; Bounce player back
    lda Player + OBJECT_X
    suba #5
    sta Player + OBJECT_X
    
    ; Decrease enemy health
    ; (Assume health is at offset 4 in object)
    dec Enemy + 4
    
    rts

; ==================== END OF FILE ====================
