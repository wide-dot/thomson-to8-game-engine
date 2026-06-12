; Minimal scrolling level example for Thomson TO8
; This code shows how to:
; 1. Define a tile-based level map
; 2. Implement camera/viewport scrolling
; 3. Render visible tiles

; ==================== CONSTANTS ====================

TILE_SIZE       equ 16          ; Pixels per tile (16x16)
MAP_WIDTH       equ 20          ; Level width in tiles
MAP_HEIGHT      equ 15          ; Level height in tiles
SCREEN_WIDTH    equ 320         ; Pixels
SCREEN_HEIGHT   equ 200         ; Pixels

; Viewport dimensions (in pixels)
VIEWPORT_WIDTH  equ 320
VIEWPORT_HEIGHT equ 200

; ==================== DATA ====================

    org $2000

; Camera/viewport position
CameraX:        fdb 0           ; Pixel X offset
CameraY:        fdb 0           ; Pixel Y offset

; Player position
PlayerX:        fdb 100
PlayerY:        fdb 100

; ==================== SIMPLE TILEMAP ====================
; 20 tiles wide x 15 tiles high
; Each byte = tile type (0 = empty, 1 = solid, etc.)
; CHANGE THIS: Replace with your level data

TileMap:
    ; Row 0
    fcb 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    ; Row 1
    fcb 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    ; Row 2
    fcb 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    ; Row 3
    fcb 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    ; ... (rest of map omitted for brevity)
    ; You would continue this for all 15 rows

TileMapEnd:

; ==================== MAIN LOOP ====================

Start:
    ; Update camera position based on player
    jsr UpdateCamera
    
    ; Render visible tiles
    jsr RenderLevel
    
    ; Handle input to move player
    jsr HandleInput
    
    ; Loop
    bra Start

; ==================== UPDATE CAMERA ====================
; Move camera to follow player
; CHANGE THIS: Adjust camera smoothing/lag if needed

UpdateCamera:
    ; Simple camera: center on player
    ; Camera X = Player X - (Screen Width / 2)
    
    ldd PlayerX
    subd #SCREEN_WIDTH / 2
    
    ; Clamp to level bounds
    ; Min: 0
    ; Max: (MAP_WIDTH * TILE_SIZE) - SCREEN_WIDTH
    
    cmpd #0
    bge CameraXNotMin
    ldd #0
    
CameraXNotMin:
    std CameraX
    
    ; Same for Y
    ldd PlayerY
    subd #SCREEN_HEIGHT / 2
    std CameraY
    
    rts

; ==================== RENDER LEVEL ====================
; Draw all visible tiles
; CHANGE THIS: Add actual tile rendering code

RenderLevel:
    ; Calculate which tile to start rendering
    ; StartTile X = CameraX / TILE_SIZE
    ; StartTile Y = CameraY / TILE_SIZE
    
    ldd CameraX
    ldy #TILE_SIZE
    ; D = StartTileX
    
    ; For each visible tile:
    ;   - Get tile type from TileMap
    ;   - Get tile graphics from tileset
    ;   - Render at screen position
    
    ; (Stub: actual rendering would go here)
    
    rts

; ==================== HANDLE INPUT ====================

HandleInput:
    jsr ReadJoypad
    
    ; CHANGE THIS: Move player based on joypad input
    ; Example: move right
    ldd PlayerX
    addd #2
    std PlayerX
    
    rts

; ==================== HELPER: GET TILE ====================
; Input:
;   A = tile X
;   B = tile Y
; Output:
;   A = tile type (0 = empty, 1 = solid, etc.)

GetTile:
    ; Calculate offset in TileMap
    ; offset = (Y * MAP_WIDTH) + X
    
    pshs x
    
    tfr b, x        ; X = Y
    ldb #MAP_WIDTH
    mul             ; D = Y * MAP_WIDTH
    exg a, b        ; Swap (D = low byte, A = high)
    adda b          ; A = Y * MAP_WIDTH + X
    
    ldb #TileMap
    addb a          ; B = address of tile
    ldx b
    lda x           ; A = tile value
    
    puls x
    rts

; ==================== END OF FILE ====================
