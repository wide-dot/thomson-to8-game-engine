; -----------------------------------------------------------------------------
; Vertical Scroll
; -----------------------------------------------------------------------------
; wide-dot - Benoit Rousseau - 11/09/2023
; ---------------------------------------
; - use a cycling code buffer to render a vertical scroll
; - buffer use stack blasting (pshs d,x,y,u)
; - buffer is only updated few lines per frame (only the new lines)
; - scroll is bi-directionnal
; - speed is a fixed point value and adjusted in regard of frame drop
; - handle up to 512 lines of tiles in a map
; -----------------------------------------------------------------------------

        opt c

; constants
; -----------------------------------------------------------------------------
m6809.OPCODE_JMP_E          equ   $7E

vscroll.CHUNCK_SIZE         equ   15
vscroll.LINE_SIZE           equ   5*15
 IFNDEF  vscroll.BUFFER_LINES
vscroll.BUFFER_LINES        equ   208  ; nb lines in buffer is 201 (0-200 to fit JMP return)
 ENDC

; parameters
; -----------------------------------------------------------------------------
; scroll data is split in 5 pages
vscroll.obj.map.page        fcb   0
vscroll.obj.map.address     fdb   0
vscroll.obj.tile.pages      fill  0,32 ; pages for every line tileset A and B
vscroll.obj.tile.adresses   fill  0,32 ; starting position for every line tileset (generic)
vscroll.obj.tile.nbx2       fdb   0
vscroll.obj.bufferA.page    fcb   0
vscroll.obj.bufferA.address fdb   0
vscroll.obj.bufferA.end     fdb   0
vscroll.obj.bufferB.page    fcb   0
vscroll.obj.bufferB.address fdb   0
vscroll.obj.bufferB.end     fdb   0
vscroll.camera.speed        fdb   0    ; (signed 8.8 fixed point) nb of pixels/50hz

; private variables
; -----------------------------------------------------------------------------
vscroll.cursor.w            fcb   0                                ; padding for 16 bit operations
vscroll.cursor              fcb   0
vscroll.speed               fdb   0                                ; (signed 8.8 fixed point) nb of line to scroll
vscroll.map.height          fdb   0                                ; map height in pixels
vscroll.map.cache.LINE_SIZE equ   20*2
vscroll.map.cache.NB_LINES  equ   13
vscroll.map.cache.SIZE      equ   vscroll.map.cache.LINE_SIZE*vscroll.map.cache.NB_LINES
vscroll.map.cache.y         fdb   -1                               ; camera range for the current cached tile line
vscroll.map.cache.cursor    fdb   0                                ; position in cache buffer (adress)
vscroll.map.cache.line      fcb   0                                ; position in cache buffer (in lines)
vscroll.map.cache           fill  0,vscroll.map.cache.SIZE         ; tile ids reflecting scroll buffer
vscroll.map.cache.END       equ   *
vscroll.viewport.height.w   fcb   0                                ; padding for 16 bit operations
vscroll.viewport.height     fcb   0
vscroll.viewport.y          fcb   0                                ; y position of viewport on screen
vscroll.camera.y            fdb   0                                ; camera position in map (in pixels)
vscroll.camera.lastY        fdb   0                                ; last camera position in map (in pixels)

; -----------------------------------------------------------------------------
; vscroll.move
; -----------------------------------------------------------------------------
; input  REG : none
; -----------------------------------------------------------------------------

; temporary variables in dp
vscroll.loop.counter        equ dp_extreg    ; BYTE
vscroll.loop.counter2       equ dp_extreg+1  ; BYTE
vscroll.backBuffer          equ dp_extreg+2  ; BYTE
vscroll.buffer.wAddressA    equ dp_extreg+3  ; WORD
vscroll.buffer.wAddressB    equ dp_extreg+5  ; WORD
vscroll.camera.currentY     equ dp_extreg+7  ; WORD
vscroll.skippedLines        equ dp_extreg+9  ; WORD
vscroll.tileset.line        equ dp_extreg+11 ; BYTE
vscroll.buffer.line         equ dp_extreg+12 ; BYTE

vscroll.move

; update position in map and buffer
; ---------------------------------

        ; check for elapsed frames
        lda   gfxlock.frameDrop.count
        bne   >
@exit   rts
;
        ; compute frame compensated speed
!       sta   <vscroll.loop.counter
        ldd   vscroll.speed                  ; load speed value of previous frame
!       addd  vscroll.camera.speed           ; mult speed by frame drop
        dec   <vscroll.loop.counter
        bne   <
;
        ; exit if speed is too small (subpixel)
        stb   vscroll.speed+1
        sta   vscroll.speed
        adda  #128 ; this cryptic code negate integer part of a 8.8 value
        eora  #127 ; and round by floor
        sbca  #255 ; cursor goes the opposite direction of y in buffer
        beq   @exit

        ; compute cursor in cycling buffer code (modulo)
        tfr   a,b
        sex
        bpl   @goUp
@goDown
        addd  vscroll.cursor.w
        bpl   @end
!       addd  #vscroll.BUFFER_LINES
        bmi   <
        bra   @end
@goUp
        addd  vscroll.cursor.w
        cmpd  #vscroll.BUFFER_LINES
        blo   @end
!       subd  #vscroll.BUFFER_LINES
        cmpd  #vscroll.BUFFER_LINES
        bhs   <
@end    stb   vscroll.cursor

        ; compute position in map
        ldx   vscroll.camera.y
        stx   vscroll.camera.lastY
        ldb   vscroll.speed                  ; get int part of 8.8
        bpl   >
        incb                                 ; by truncating, negative is floor and positive is ceil, so make it ceil also for negative
!       leax  b,x                            ; do not use abx, b is signed, speed is implicitly caped to a choppy 127px by frame

        ; wrap camera position in map (infinite level loop)
        tfr   x,d
        cmpx  vscroll.map.height
        bge   >
        tsta
        bpl   @end
        addd  vscroll.map.height
        bra   @end
!       subd  vscroll.map.height
@end    std   vscroll.camera.y

; update gfx in buffer code
; -------------------------
vscroll.updategfx
        jsr   vscroll.computeBufferWAddress
        tst   <vscroll.loop.counter          ; nb of lines to render
        lbeq  @exit                          ; when viewport shrink nothing to render
        ; setup vscroll buffers
        ldx   vscroll.obj.bufferA.address
        leax  d,x
        stx   <vscroll.buffer.wAddressA
        ldx   vscroll.obj.bufferB.address
        leax  d,x
        stx   <vscroll.buffer.wAddressB
        ; compute current line in tile
        ldb   map.CF74021.DATA
        stb   <vscroll.backBuffer            ; backup back video buffer
        lda   vscroll.camera.lastY+1         ; LSB only
        adda  <vscroll.skippedLines          ; nb skip lines (outside viewport)
        ldb   vscroll.speed
        bpl   >
        deca                                 ; next line in tile
        ldb   #$4A ; deca
        ldu   #0
        ldx   #vscroll.LINE_SIZE
        ldy   #-1
        bra   @mod
!       adda  vscroll.viewport.height
        inca                                 ; previous line in tile
        ldb   #$4C ; inca
        ldu   vscroll.viewport.height.w
        ldx   #-vscroll.LINE_SIZE
        ldy   #1
@mod
        anda  #$0f                           ; modulo to keep 0-15      
        sta   <vscroll.tileset.line
        ; setup dynamic code in main scroll loop
        sty   @direction
        stb   @direction2
        stu   @direction3
        stx   @direction4
        stx   @direction5
        eorb  #%00000110                     ; inverse deca/inca instruction
        stb   @direction6
        ldd   vscroll.camera.lastY
        addd  #0                             ; add viewport when going down
@direction3 equ *-2
@loop   
        addd  #0
@direction equ *-2
        cmpd  vscroll.map.height
        bge   >
        tsta
        bpl   @end1
        addd  vscroll.map.height
        bra   @end1
!       subd  vscroll.map.height
@end1   std   <vscroll.camera.currentY
;
; PROCESS BUFFER A
; ----------------
        andb  #$f0                           ; tile height is 16px, faster check here than _asrd*4
        cmpd  vscroll.map.cache.y
        beq  >
        std   vscroll.map.cache.y            ; load cache at a new position
;
        ldy   #vscroll.map.cache
        lda   <vscroll.buffer.line
        lsra
        lsra
        lsra
        lsra
        sta   vscroll.map.cache.line
        ldb   #vscroll.map.cache.LINE_SIZE
        mul
        leay  d,y
        sty   vscroll.map.cache.cursor
;
        ldd   <vscroll.camera.currentY
        jsr   vscroll.updateTileCache        ; check cache for this line number (in d)
!       lda   vscroll.obj.bufferA.page
        _SetCartPageA                        ; mount in cartridge space
        lda   <vscroll.tileset.line
        lsla
        ldx   #vscroll.obj.tile.adresses     ; load A tileset addr
        ldy   a,x
        ldx   #vscroll.obj.tile.pages        ; load A tileset page
        lda   a,x
        sta   map.CF74021.DATA               ; mount in data space
        ldu   <vscroll.buffer.wAddressA
        ldx   vscroll.map.cache.cursor
        jsr   vscroll.copyBitmap             ; copy bitmap for buffer A
        leau  1234,u
@direction4 equ *-2
        cmpu  vscroll.obj.bufferA.address
        bge   @tendA
        leau  vscroll.BUFFER_LINES*vscroll.LINE_SIZE,u
        bra   >
@tendA  cmpu  vscroll.obj.bufferA.end
        blt   >
        leau  -vscroll.BUFFER_LINES*vscroll.LINE_SIZE,u
!       stu   <vscroll.buffer.wAddressA
;
; PROCESS BUFFER B
; ----------------
        lda   vscroll.obj.bufferB.page
        _SetCartPageA                        ; mount in cartridge space
        lda   <vscroll.tileset.line
        lsla
        ldx   #vscroll.obj.tile.adresses     ; load B tileset addr
        ldy   a,x
        ldx   #vscroll.obj.tile.pages+1      ; load B tileset page
        lda   a,x
        sta   map.CF74021.DATA               ; mount in data space
        ldu   <vscroll.buffer.wAddressB
        ldx   vscroll.map.cache.cursor
        jsr   vscroll.copyBitmap             ; copy bitmap for buffer B
        lda   <vscroll.buffer.line
        inca
@direction6 equ *-1
        leau  1234,u
@direction5 equ *-2
        cmpu  vscroll.obj.bufferB.address
        bge   @tendB
        lda   #vscroll.BUFFER_LINES-1
        leau  vscroll.BUFFER_LINES*vscroll.LINE_SIZE,u
        bra   >
@tendB  cmpu  vscroll.obj.bufferB.end
        blt   >
        lda   #0
        leau  -vscroll.BUFFER_LINES*vscroll.LINE_SIZE,u
!       stu   <vscroll.buffer.wAddressB
;
        sta   <vscroll.buffer.line
        lda   <vscroll.tileset.line
        inca
@direction2 equ *-1
        anda  #$0f
        sta   <vscroll.tileset.line
;
        ldd   <vscroll.camera.currentY
        dec   <vscroll.loop.counter
        lbne  @loop                          ; loop until all lines are rendered
@exit
        ldb   vscroll.speed
        bpl   >
        ldb   #$ff
        bra   @end2
!       clrb
@end2   stb   vscroll.speed
        ldb   <vscroll.backBuffer            ; restore back video buffer
        stb   map.CF74021.DATA
        rts

; update the horizontal line of tile id in map cache
; --------------------------------------------------
vscroll.updateTileCache
        ldx   vscroll.obj.map.address  ; handle up to 512 lines in map
        _lsld                          ; divide by 16 to get 
        _lsld                          ; line number in map 
        lslb                                
        bpl >
        leax  30,x                     ; if line in map is odd, offset  position in map by 30 bytes (12bits id * 20 tiles)
!       rola              
        ldb   #60                      ; 2 lines of 30 bytes (12bits id * 20 tiles)
        mul                            ; mult by line/2
        leax  d,x                      ; x point to desired data map line
        lda   vscroll.obj.map.page
        _SetCartPageA                  ; mount page that contain map data
        lda   #20/2                    ; nb bytes to load/2
        sta   <vscroll.loop.counter2
@loop   ldd   ,x+                      ; load cache by unpacking tile id
        _lsrd                          ; from 12bit to 16bit
        _lsrd
        _lsrd
        _lsrd
        std   ,y++
        ldd   ,x++
        anda  #$0F
        std   ,y++
        dec   <vscroll.loop.counter2
        bne   @loop
        rts

; copy the tile bitmap to the code buffer
; read tiles in reverse order (from right to left)
; ---------------------------------------
vscroll.copyBitmap
        ldd   38,x                     ; [6] load tile id
        ldd   d,y                      ; [9] load 4 pixels of this tile line
        std   11,u                     ; [6] fill the LDU
        ldd   36,x                     ; [6] load tile id
        ldd   d,y                      ; [9] load 4 pixels of this tile line
        std   8,u                      ; [6] fill the LDY
        ldd   34,x                     ; [6] load tile id
        ldd   d,y                      ; [9] load 4 pixels of this tile line
        std   4,u                      ; [6] fill the LDX
        ldd   32,x                     ; [6] load tile id
        ldd   d,y                      ; [9] load 4 pixels of this tile line
        std   1,u                      ; [6] fill the LDD

        ldd   30,x
        ldd   d,y
        std   26,u
        ldd   28,x
        ldd   d,y
        std   23,u
        ldd   26,x
        ldd   d,y
        std   19,u
        ldd   24,x
        ldd   d,y
        std   16,u

        ldd   22,x
        ldd   d,y
        std   41,u
        ldd   20,x
        ldd   d,y
        std   38,u
        ldd   18,x
        ldd   d,y
        std   34,u
        ldd   16,x
        ldd   d,y
        std   31,u

        ldd   14,x
        ldd   d,y
        std   56,u
        ldd   12,x
        ldd   d,y
        std   53,u
        ldd   10,x
        ldd   d,y
        std   49,u
        ldd   8,x
        ldd   d,y
        std   46,u

        ldd   6,x
        ldd   d,y
        std   71,u
        ldd   4,x
        ldd   d,y
        std   68,u
        ldd   2,x
        ldd   d,y
        std   64,u
        ldd   ,x                       ; [5] load tile id
        ldd   d,y
        std   61,u
        rts

; compute write location in buffer
; --------------------------------
vscroll.computeBufferWAddress

        ; compute number of lines to render
        ldd   #0
        std   <vscroll.skippedLines        ; init tmp value
        ldb   vscroll.speed
        bpl   >
        comb                               ; by truncating, negative is floor and positive is ceil, so make it ceil also for negative
!       cmpb  vscroll.viewport.height      ; compare to viewport height
        bls   >
        subb  vscroll.viewport.height
        stb   <vscroll.skippedLines+1      ; number of skipped lines (outside of viewport)
        ldb   vscroll.viewport.height      ; keep lowest value
!       stb   <vscroll.loop.counter        ; setup nb of line to render

        ; compute relative write location in code buffer
        tst   vscroll.speed
        bmi   @goUp
@goDown
        addd  vscroll.cursor.w
        subd  #1
        subd  <vscroll.skippedLines        ; skip lines if needed
        bmi   @loop
        cmpd  #vscroll.BUFFER_LINES
        bhs   @loop2
        bra   >
@loop
        addd  #vscroll.BUFFER_LINES    ; cycling in buffer
        bmi   @loop
        bra   >
@goUp
        negb                           ; substract it to cursor + viewport height
        sex                            ; omg !
        addd  vscroll.cursor.w
        addd  vscroll.viewport.height.w
        addd  <vscroll.skippedLines
        cmpd  #vscroll.BUFFER_LINES
        blo   >
@loop2
        subd  #vscroll.BUFFER_LINES    ; cycling in buffer
        cmpd  #vscroll.BUFFER_LINES
        bhs   @loop2
!       stb   <vscroll.buffer.line
        lda   #vscroll.LINE_SIZE
        mul
        rts

; -----------------------------------------------------------------------------
; vscroll.do
; -----------------------------------------------------------------------------
; input  REG : none
; -----------------------------------------------------------------------------
; When the first screen line is part of the scroll, as S register is used
; to write in video buffer, you should expect that irq call will write 12 bytes
; in or just before video memory. If it occurs at the end of the buffer routine
; before S is retored, this can erase bytes at $9FF4-$9FFF, so leave this aera
; unsed
; -----------------------------------------------------------------------------
vscroll.do
        lda   vscroll.obj.bufferB.page
        ldx   vscroll.obj.bufferB.address
@loop   _SetCartPageA                  ; mount page that contain buffer code
        ldb   vscroll.cursor           ; screen start line (0-199)
        addb  vscroll.viewport.height  ; viewport size (1-200)
        bcs   @cycle
        cmpb  #vscroll.BUFFER_LINES
        bls   >
@cycle  subb  #vscroll.BUFFER_LINES    ; cycling in buffer
!       lda   #vscroll.LINE_SIZE
        mul
        leau  d,x                      ; set u where a jump should be placed for return to caller
        pulu  a,y                      ; save 3 bytes in buffer that will be erased by the jmp return
        stu   @save_u
        pshs  a,y
        lda   #m6809.OPCODE_JMP_E      ; build jmp instruction
        ldy   #@ret                    ; this works even at the end of table because there is 
        sta   -3,u                     ; already a jmp for looping into the buffer
        sty   -2,u                     ; no need to have some padding
        sts   @save_s
        lds   #$BF40
vscroll.viewport.ram equ *-2
        lda   vscroll.cursor
        ldb   #vscroll.LINE_SIZE
        mul
        leax  d,x                      ; set starting position in buffer code
        jmp   ,x
@ret    lds   #0
@save_s equ   *-2
        ldu   #0
@save_u equ   *-2
        puls  a,x
        pshu  a,x                      ; restore 3 bytes in buffer
        lda   vscroll.viewport.ram
        cmpa  #$C0
        bhs   >                        ; exit if second buffer code as been executed
        adda  #$20                     ; else execute second buffer code
        sta   vscroll.viewport.ram
        lda   vscroll.obj.bufferA.page
        ldx   vscroll.obj.bufferA.address
        bra   @loop
!       lda   vscroll.viewport.ram
        suba  #$20
        sta   vscroll.viewport.ram     ; restore to first buffer
        rts