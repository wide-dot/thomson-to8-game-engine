; ------ level-loading.asm ------
; From: r-type game engine
; Example: How to load and initialize a level
;
; Dependencies: level-management subsystem

; Load a level by ID
; Input: A = level ID (0-based)
load-level:
    jsr level-management:load-level
    ; Load tilemap, spawn initial enemies, set camera position
    rts

; Scroll background by offset
; Input: X = X offset, Y = Y offset
scroll-level:
    jsr level-management:scroll-background
    rts

; See full context: game-projects/r-type/level-management module
