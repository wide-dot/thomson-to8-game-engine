; ------ spawning.asm ------
; From: r-type game engine
; Example: How to spawn a new game object
;
; Usage:
;   1. Define object template (sprite, hitbox, behavior functions)
;   2. Call object-management:spawn-object with type and position
;   3. Object management tracks it in global object list
;   4. Main loop calls update-all-objects once per frame
;   5. Objects are automatically rendered and collision-checked
;
; Dependencies: object-management subsystem

; Spawn a new enemy at screen position (X, Y)
; Input: X = screen X position, Y = screen Y position
spawn-enemy:
    lda #obj-type-enemy  ; Object type ID

    ; Load enemy template (sprite, hitbox, logic functions)
    leax [enemy-template]
    ldy #0               ; Y reserved for data pointer

    ; Call object-management to spawn
    jsr object-management:spawn-object

    ; object-management returns object ID in A (store if needed later)
    rts

; Update all spawned objects (called once per frame in main loop)
update-all-objects:
    jsr object-management:for-each-object
    ; For each object, calls its update function
    rts

; Destroy an object by ID
; Input: A = object ID
destroy-object:
    jsr object-management:destroy-object
    rts

; See full context: game-projects/r-type/object-management module
