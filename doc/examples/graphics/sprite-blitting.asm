; ------ sprite-blitting.asm ------
; From: r-type game engine
; Example: How to render a sprite using the graphics subsystem
;
; Usage:
;   1. Load sprite data into memory (e.g., player sprite starts at $2000)
;   2. Set sprite position (X, Y coordinates)
;   3. Call graphics:blit-sprite with address and coordinates
;   4. Graphics subsystem handles blitting to video memory
;
; Dependencies: graphics subsystem, ram

; Blit a 16x16 sprite to screen
; Input: D = sprite data address, X = screen X, Y = screen Y
; Output: Sprite rendered to video memory
blit-sprite:
    pshs D,X,Y           ; Save registers

    ; Calculate video memory address from X, Y
    ; Y * 80 + X = video address (80 bytes per scanline on Thomson TO8)
    leay D,Y             ; Y coordinate
    ldb #80              ; bytes per scanline
    mul                  ; D = Y * 80

    leax D,X             ; Add X coordinate
    lda #$40             ; Video base address high byte
    sta ,X               ; Add video base address

    ; Copy sprite data from source to video memory
    ; [See full r-type source for complete blitting loop]

    puls D,X,Y           ; Restore registers
    rts

; See full context: game-projects/r-type/objects/*/[sprite-render.asm]
