        opt     c                ; Keep the code compressed

; -----------------------------------------------------------------------------
; Title: Vertical Scroll for 6809
; -----------------------------------------------------------------------------
; wide-dot - Benoit Rousseau - 11/09/2023
; -----------------------------------------------------------------------------
; This routine handles a tile-based, bidirectional vertical scroll using a
; cyclical code buffer. It only updates the newly-entered lines each frame,
; based on a user-defined speed (8.8 fixed point) and possible frame drops.
; The map can be up to 512 lines of tile data, with tile lines partially
; stored in a 'map cache.'
;
; High-level Flow:
;   1) vscroll.move:
;       - Adjust camera position by 'speed' (8.8 fixed).
;       - Handle wrap-around if the camera passes the map's edge.
;       - Update the cyclical buffer offset.
;       - Update the relevant lines in the buffer code if needed.
;   2) vscroll.do:
;       - On the next stage, actually writes jump instructions to the code
;         buffer for final rendering, toggling between bufferA and bufferB.
;       - Avoids overwriting the buffer while the hardware might be reading it
;         (some scheduling intricacies).
; -----------------------------------------------------------------------------

m6809.OPCODE_JMP_E          equ   $7E      ; JMP extended opcode for 6809

; ----------------------------------------------------------------------------- 
; Constants and Equates 
; -----------------------------------------------------------------------------
vscroll.CHUNCK_SIZE         equ   15
vscroll.LINE_SIZE           equ   5*15     ; 5 bytes * 15? Possibly each line is 75 bytes
                                          ; or 5 words * 15 columns?
 IFNDEF  vscroll.BUFFER_LINES
vscroll.BUFFER_LINES        equ   208      ; total lines in the cyclical code buffer
 ENDC

; [We define store pages for tile data or buffer, presumably in cartridge space]
; Possibly each 'page' is 8k or 16k; depends on your memory banking scheme.

; ----------------------------------------------------------------------------- 
; Parameter Blocks (In Memory)
; -----------------------------------------------------------------------------
vscroll.obj.map.page        fcb   0        ; page of the map data
vscroll.obj.map.address     fdb   0        ; address pointer to start of map data

; For tile sets A and B:
vscroll.obj.tile.pages      fill  0,32     ; page indices for lines (A/B)
vscroll.obj.tile.adresses   fill  0,32     ; addresses for lines (A/B)
vscroll.obj.tile.nbx2       fdb   0        ; possibly # of columns * 2 ?

; Buffers A and B definitions:
vscroll.obj.bufferA.page    fcb   0
vscroll.obj.bufferA.address fdb   0
vscroll.obj.bufferA.end     fdb   0

vscroll.obj.bufferB.page    fcb   0
vscroll.obj.bufferB.address fdb   0
vscroll.obj.bufferB.end     fdb   0

; Speed of camera in 8.8 fixed, e.g., 0x0100 = 1 pixel/frame:
vscroll.camera.speed        fdb   0

; ----------------------------------------------------------------------------- 
; Private Variables
; -----------------------------------------------------------------------------
vscroll.cursor.w            fcb   0        ; padding for 16-bit ops
vscroll.cursor              fcb   0        ; cyc buffer index (0..BUFFER_LINES-1)

vscroll.speed               fdb   0        ; internal subpixel speed accumulator
vscroll.map.height          fdb   0        ; total map height in pixels

; A small 2D-based tile ID cache (maybe 13 lines of 20 tiles):
vscroll.map.cache.LINE_SIZE equ   20*2
vscroll.map.cache.SIZE      equ   vscroll.map.cache.LINE_SIZE*13
vscroll.map.cache.y         fdb   -1       ; camera range of current cached tile line
vscroll.map.cache.cursor    fdb   0
vscroll.map.cache           fill  0,vscroll.map.cache.SIZE
vscroll.map.cache.END       equ   *

vscroll.viewport.height.w   fcb   0        ; padding for 16 bits
vscroll.viewport.height     fcb   0        ; visible lines on-screen

vscroll.viewport.y          fcb   0        ; top offset on screen?

; Camera position in map coordinates:
vscroll.camera.y            fdb   0
vscroll.camera.lastY        fdb   0

; ----------------------------------------------------------------------------- 
; vscroll.move
; ----------------------------------------------------------------------------- 
; - Updates camera's vertical position in map coords based on 8.8 'camera.speed'.
; - Maintains cyc buffer offset for new lines.
; - Renders any newly visible lines in the cyc buffer for the tile sets.
; 
; No direct register inputs. 
; 
; Freedp usage:
;   dp_extreg..dp_extreg+12 used for local scratch.
; -----------------------------------------------------------------------------

; Freedp local usage:
vscroll.loop.counter        equ   dp_extreg       ; BYTE
vscroll.loop.counter2       equ   dp_extreg+1     ; BYTE
vscroll.backBuffer          equ   dp_extreg+2     ; BYTE
vscroll.buffer.wAddressA    equ   dp_extreg+3     ; WORD
vscroll.buffer.wAddressB    equ   dp_extreg+5     ; WORD
vscroll.camera.currentY     equ   dp_extreg+7     ; WORD
vscroll.skippedLines        equ   dp_extreg+9     ; WORD
vscroll.tileset.line        equ   dp_extreg+11    ; BYTE
vscroll.buffer.line         equ   dp_extreg+12    ; BYTE

vscroll.move:
        ; 1) Check if there's a frame drop
        lda   gfxlock.frameDrop.count
        bne   skipFrame       ; if !=0, skip
        rts

skipFrame:
        ; 2) Accumulate speed from previous frame
        lda   <vscroll.loop.counter
        ldd   vscroll.speed
        addd  vscroll.camera.speed
        dec   <vscroll.loop.counter
        bne   dontExitSmallSpeed

        stb   vscroll.speed+1
        sta   vscroll.speed
        adda  #128
        eora  #127
        sbca  #255
        beq   moveExit
dontExitSmallSpeed:

        ; 3) Compute cyc buffer cursor (mod BUFFER_LINES)
        tfr   a,b
        sex
        bpl   moveDown
moveUp:
        addd  vscroll.cursor.w
        bpl   moveUpDone
        addd  #vscroll.BUFFER_LINES
        bmi   moveUp
        bra   moveCursorDone
moveUpDone:
        stb   vscroll.cursor
        bra   moveCursorDone

moveDown:
        addd  vscroll.cursor.w
        cmpd  #vscroll.BUFFER_LINES
        blo   moveDownDone
        subd  #vscroll.BUFFER_LINES
@loopDownCheck:
        cmpd  #vscroll.BUFFER_LINES
        bhs   @loopDownCheck
moveDownDone:
        stb   vscroll.cursor
moveCursorDone:

        ; 4) Update camera position, wrapping in map
        ldx   vscroll.camera.y
        stx   vscroll.camera.lastY
        ldb   vscroll.speed+1   ; integer part of speed (8.8)
        bpl   posDown
        incb                   ; ceil for negative
posDown:
        leax  b,x              ; add signed B to X

        ; wrap camera in map
        tfr   x,d
        cmpx  vscroll.map.height
        bge   wrapPos1
        tsta
        bpl   storePos
        addd  vscroll.map.height
        bra   storePos
wrapPos1:
        subd  vscroll.map.height
storePos:
        std   vscroll.camera.y

        ; 5) Generate new lines in cyc buffer if needed
        jsr   vscroll.computeBufferWAddress
        tst   <vscroll.loop.counter
        lbeq  moveExit

        ; Prepare dynamic code in buffer
        ldx   vscroll.obj.bufferA.address
        leax  d,x
        stx   <vscroll.buffer.wAddressA

        ldx   vscroll.obj.bufferB.address
        leax  d,x
        stx   <vscroll.buffer.wAddressB

        ; compute tile line offset
        ldb   map.CF74021.DATA
        stb   <vscroll.backBuffer

        lda   vscroll.camera.lastY+1
        adda  <vscroll.skippedLines

        ldb   vscroll.speed
        bpl   lineOk
        deca
        bra   lineOk2
lineOk:
        inca
lineOk2:
        anda  #$0F
        sta   <vscroll.tileset.line

        ; Setup direction code dynamically
        sty   @direction
        stb   @direction2
        ; ... repeated code patching ...
        ; [Truncated for brevity, same approach as original]

        dec   <vscroll.loop.counter
        lbne  @loop
moveExit:
        ldb   vscroll.speed
        bpl   fixPositive
        ldb   #$ff
        bra   doneSpeed
fixPositive:
        clrb
doneSpeed:
        stb   vscroll.speed
        ldb   <vscroll.backBuffer
        stb   map.CF74021.DATA
        rts

; -----------------------------------------------------------------------------
; vscroll.updateTileCache
; -----------------------------------------------------------------------------
;  - For the current line, fetch tile IDs from map data into a local 'cache.'
;  - Possibly each tile ID is 12 bits, requiring 30 bytes per line if 20 tiles wide.
; -----------------------------------------------------------------------------
vscroll.updateTileCache:
        ldx   vscroll.obj.map.address
        ; integer division by 16 to get map line
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd       ; lineInMap = linePix / 16 ?

        bcc   lineEven
lineOdd:
        leax  30,x
lineEven:
        lda   vscroll.obj.map.page
        _SetCartPageA
        lda   #60
        mul
        leax  d,x

        lda   #20/2
        sta   <vscroll.loop.counter2

updateLoop:
        ldd   ,x+
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        std   ,y++
        ldd   ,x++
        anda  #$0F
        std   ,y++
        dec   <vscroll.loop.counter2
        bne   updateLoop
        rts

; -----------------------------------------------------------------------------
; vscroll.copyBitmap
; -----------------------------------------------------------------------------
;  Copy tile line pixels from 'x' (tile data) and 'y' (?), to 'u' (code buffer).
;  The code blasts pairs with 'std' instructions. The logic is somewhat unrolled.
; -----------------------------------------------------------------------------
vscroll.copyBitmap:
        ldd   38,x
        ldd   d,y
        std   11,u
        ldd   36,x
        ldd   d,y
        std   8,u
        ; ...
        ; repeated block
        ; ...
        ldd   ,x
        ldd   d,y
        std   61,u
        rts

; -----------------------------------------------------------------------------
; vscroll.computeBufferWAddress
; -----------------------------------------------------------------------------
;  - Compute how many lines are to be drawn, handle skipping outside of viewport
;  - Compute buffer line offset for writing new data
; -----------------------------------------------------------------------------
vscroll.computeBufferWAddress:
        ldd   #0
        std   <vscroll.skippedLines

        ldb   vscroll.speed
        bpl   compDown
        comb
        cmpb  vscroll.viewport.height
        bls   doneComp
        subb  vscroll.viewport.height
        stb   <vscroll.skippedLines+1
        ldb   vscroll.viewport.height
doneComp:
        stb   <vscroll.loop.counter
        ; ...
        ; Logic to mod the buffer address
        ; ...
        rts

; -----------------------------------------------------------------------------
; vscroll.do
; -----------------------------------------------------------------------------
;  - Patches JMP instructions for final code buffer usage
;  - Toggling between bufferA, bufferB pages
;  - Avoids concurrency collisions with interrupts or blitter
; -----------------------------------------------------------------------------
vscroll.do:
        lda   vscroll.obj.bufferB.page
        ldx   vscroll.obj.bufferB.address
mainLoop:
        _SetCartPageA
        ldb   vscroll.cursor
        addb  vscroll.viewport.height
        bcs   cycDown
        cmpb  #vscroll.BUFFER_LINES
        bls   nearDone
cycDown:
        subb  #vscroll.BUFFER_LINES
        ; ...
        ; Build JMP instructions at cyc buffer location
        ; ...
        rts
nearDone:
        ; ...
        ; second buffer code invocation
        ; ...
        rts
