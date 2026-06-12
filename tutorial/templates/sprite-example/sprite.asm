; Minimal sprite blitting example for Thomson TO8
; This code shows how to:
; 1. Define a simple 16x16 sprite in memory
; 2. Blit it to the screen at different positions
; 3. Use the graphics subsystem to render

; ==================== CONSTANTS ====================

SPRITE_WIDTH    equ 16          ; pixels (2 bytes per line)
SPRITE_HEIGHT   equ 16          ; pixels

; Thomson TO8 graphics memory
SCREEN_BASE     equ $A000       ; Video RAM base
SCREEN_WIDTH    equ 320         ; pixels (40 bytes per line in 16-color mode)
BYTES_PER_LINE  equ 40

; ==================== SPRITE DATA ====================

; CHANGE THIS: Replace with your own 16x16 sprite
; Format: 2 bytes per line (16 pixels in 16-color mode = 8 pixels per byte)
; This example is a simple 16x16 square

SpriteData:
    fcb $FF, $FF    ; Line 1: all pixels set
    fcb $FF, $FF    ; Line 2
    fcb $F0, $0F    ; Line 3: outer pixels (F) and inner pixels (0)
    fcb $F0, $0F    ; Line 4
    fcb $F0, $0F    ; Line 5
    fcb $F0, $0F    ; Line 6
    fcb $F0, $0F    ; Line 7
    fcb $F0, $0F    ; Line 8
    fcb $F0, $0F    ; Line 9
    fcb $F0, $0F    ; Line 10
    fcb $F0, $0F    ; Line 11
    fcb $F0, $0F    ; Line 12
    fcb $F0, $0F    ; Line 13
    fcb $F0, $0F    ; Line 14
    fcb $FF, $FF    ; Line 15: all pixels set
    fcb $FF, $FF    ; Line 16

SpriteDataEnd:

; ==================== MAIN CODE ====================

    org $2000

Start:
    ; CHANGE THIS: Set up your sprite positions
    ; This example blits one sprite at (10, 10) and another at (100, 50)
    
    ; Blit sprite at x=10, y=10
    lda #10         ; x position
    ldx #10         ; y position
    jsr BlitSprite
    
    ; Blit sprite at x=100, y=50
    lda #100
    ldx #50
    jsr BlitSprite
    
    ; Wait forever (or loop to animate)
    bra Start

; ==================== SPRITE BLIT SUBROUTINE ====================
; Input:
;   A = X position (0-319)
;   X = Y position (0-199)
; Output:
;   Sprite blitted to screen
; Clobbers: A, B, X, Y, U

BlitSprite:
    pshs a,x        ; Save position on stack
    
    ; Calculate screen offset
    ; offset = (y * BYTES_PER_LINE) + (x / 2)
    
    ldb #BYTES_PER_LINE
    mul             ; D = Y * BYTES_PER_LINE
    ldu d           ; U = offset base
    
    puls x          ; Restore X position (x coordinate)
    tfr x, d        ; D = X position
    lsr d           ; D = X / 2 (convert pixels to bytes)
    leau d, u       ; U = screen_base + offset
    
    ; Now blit the sprite
    ; CHANGE THIS: Add actual blitting code
    ; For now, this is a stub that shows the structure
    
    puls a          ; Restore A (original X position)
    rts

; ==================== END OF FILE ====================
