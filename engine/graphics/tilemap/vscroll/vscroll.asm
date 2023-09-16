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
; - handle up to 512 lines in map
; -----------------------------------------------------------------------------

; constants
; -----------------------------------------------------------------------------
m6809.OPCODE_JMP_E          equ   $7E

vscroll.LINE_SIZE           equ   75
 IFNDEF  vscroll.BUFFER_LINES
vscroll.BUFFER_LINES        equ   201  ; nb lines in buffer is 201 (0-200 to fit JMP return)
 ENDC

; parameters
; -----------------------------------------------------------------------------
; scroll data is split in 5 pages
vscroll.obj.map.page        fcb   0
vscroll.obj.map.address     fdb   0
vscroll.obj.tileA.page      fcb   0
vscroll.obj.tileA.address   fdb   0
vscroll.obj.tileB.page      fcb   0
vscroll.obj.tileB.address   fdb   0
vscroll.obj.bufferA.page    fcb   0
vscroll.obj.bufferA.address fdb   0
vscroll.obj.bufferB.page    fcb   0
vscroll.obj.bufferB.address fdb   0
vscroll.camera.speed        fdb   0    ; (signed 8.8 fixed point) nb of pixels/50hz

; private variables
; -----------------------------------------------------------------------------
vscroll.speed               fdb   0    ; (signed 8.8 fixed point) nb of line to scroll
vscroll.map.cache.y         fdb   -1   ; current cached map line
vscroll.map.cache           fill  0,40 ; a full unpacked map line with 20x tile ids
vscroll.map.cache.end       equ   *
vscroll.viewport.y          fcb   0    ; y position of viewport on screen
vscroll.camera.y            fdb   0    ; camera position in map
vscroll.camera.lastY        fdb   0    ; last camera position in map

; -----------------------------------------------------------------------------
; vscroll.move
; -----------------------------------------------------------------------------
; input  REG : none
; -----------------------------------------------------------------------------

; temporary variables in dp
vscroll.loop_cnt            equ dp_extreg    ; BYTE
vscroll.backBuffer          equ dp_extreg+1  ; BYTE
vscroll.buffer.wAddressA    equ dp_extreg+2  ; WORD
vscroll.buffer.wAddressB    equ dp_extreg+4  ; WORD
vscroll.tileset.cursor      equ dp_extreg+6  ; WORD
vscroll.loop.counter        equ dp_extreg+8  ; BYTE
vscroll.camera.currentY     equ dp_extreg+9  ; WORD
vscroll.tmp                 equ dp_extreg+11 ; BYTE

vscroll.move

; update position in map and buffer
; ---------------------------------
        lda   gfxlock.frameDrop.count
        bne   >
        rts
!       sta   <vscroll.loop_cnt
        ldd   vscroll.speed                  ; load speed value of previous frame
        clra                                 ; clear integer part (nb line moved in last frame), and keep only remainer
@loop   addd  vscroll.camera.speed           ; mult speed by frame drop
        dec   <vscroll.loop_cnt
        bne   @loop
        std   vscroll.speed
        negb                                 ; cursor goes the opposite direction
        nega                                 ; of y in buffer
        bmi   @neg
        adda  vscroll.cursor              
        cmpa  #vscroll.BUFFER_LINES
        bls   @exit                          ; branch if in buffer range
        suba  #vscroll.BUFFER_LINES          ; cycling in buffer
        bra   @exit
@neg    adda  vscroll.cursor              
        cmpa  #vscroll.BUFFER_LINES
        bls   @exit                          ; branch if in buffer range
        adda  #vscroll.BUFFER_LINES          ; cycling in buffer
@exit   sta   vscroll.cursor
        ldx   vscroll.camera.y               ; update camera position in map
        stx   vscroll.camera.lastY
        ldb   vscroll.speed                  ; get int part of 8.8
        leax  b,x                            ; do not use abx, b is signed
        stx   vscroll.camera.y

; update gfx in buffer code
; -------------------------
vscroll.updategfx
        ldx   vscroll.obj.bufferA.address
        jsr   vscroll.computeBufferWAddress
        stx   vscroll.buffer.wAddressA
        ldx   vscroll.obj.bufferB.address
        jsr   vscroll.computeBufferWAddress
        stx   vscroll.buffer.wAddressB

        ldb   map.CF74021.DATA
        stb   <vscroll.backBuffer            ; backup back video buffer
        lda   vscroll.camera.lastY+1         ; LSB only
        deca                                 ; prev line TODO DIRECTION
        anda  #$0f                           ; modulo to keep 0-15
        asla
        asla
        clrb                                 ; tileset for each line are 512*2 bytes long
        std   <vscroll.tileset.cursor
        ldd   vscroll.camera.lastY
@loop   
        subd  #1                             ; TODO DIRECTION
        std   <vscroll.camera.currentY       ; TODO make the map infinite by looping
        jsr   vscroll.updateTileCache        ; check cache for this line number (in d)
        lda   vscroll.obj.bufferA.page
        _SetCartPageA                        ; mount in cartridge space
        lda   vscroll.obj.tileA.page
        sta   map.CF74021.DATA               ; mount in data space
        ldu   vscroll.buffer.wAddressA
        ldy   vscroll.obj.tileA.address
        ldd   <vscroll.tileset.cursor
        leay  d,y                            ; move y to start of tileset for this line
        jsr   vscroll.copyBitmap             ; copy bitmap for buffer A
        stu   vscroll.buffer.wAddressA
;
        lda   vscroll.obj.bufferB.page
        _SetCartPageA                        ; mount in cartridge space
        lda   vscroll.obj.tileB.page
        sta   map.CF74021.DATA               ; mount in data space
        ldu   vscroll.buffer.wAddressB
        ldy   vscroll.obj.tileB.address
        ldd   <vscroll.tileset.cursor
        leay  d,y                            ; move y to start of tileset for this line
        jsr   vscroll.copyBitmap             ; copy bitmap for buffer B
        stu   vscroll.buffer.wAddressB
;
        ldd   <vscroll.tileset.cursor        ; increment cursor in tiles
        subd  #$400                          ; TODO !!! direction
        anda  #$3f                           ; modulo on tileset
        andb  #$ff
        std   <vscroll.tileset.cursor
;
        ldd   <vscroll.camera.currentY
        dec   <vscroll.loop.counter
        bne   @loop

        ldb   <vscroll.backBuffer            ; restore back video buffer
        stb   map.CF74021.DATA
        rts

; update the horizontal line of tile id in map cache
; --------------------------------------------------
vscroll.updateTileCache
        andb  #$f0                     ; tile height is 16px, faster check here than _asrd*4
        cmpd  vscroll.map.cache.y
        bne   >
        rts                            ; return, cache is already up to date
!       std   vscroll.map.cache.y      ; load cache at a new position
        lda   vscroll.obj.map.page
        _SetCartPageA                  ; mount page that contain map data
        ldx   vscroll.obj.map.address
        lda   vscroll.map.cache.y      ; handle up to 512 lines in map, b already loaded
        _asrd
        _asrd
        _asrd
        _asrd
        sta   <vscroll.tmp             ; keep bit 8
        lda   #30                      ; multiply map vertical pos (first 8 bits: 0-7)
        mul                            ; by 30 bytes (12bits id * 20 tiles)
        tst   <vscroll.tmp
        beq   >
        addd  #256*30                  ; complete the mult with bit8 value
!       leax  d,x                      ; x point to desired map line
        ldy   #vscroll.map.cache
        lda   #20/2                    ; nb byte to load/2
        sta   <vscroll.loop_cnt
@loop   ldd   ,x+                      ; load cache by unpacking tile id
        _lsrd                          ; from 12bit to 16bit
        _lsrd
        _lsrd
        _lsrd
        std   ,y++
        ldd   ,x++
        anda  #$0F
        std   ,y++
        dec   <vscroll.loop_cnt
        bne   @loop
        rts

; copy the tile bitmap to the code buffer
; ---------------------------------------
vscroll.copyBitmap
        ldx   #vscroll.map.cache.end   ; read tiles in reverse order (from right to left)
@loop
        leax  -8,x                     ; move to next tile id in cache (to the left)
        ldd   6,x                      ; load tile id
        ldd   d,y                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDD
        ldd   4,x                      ; load tile id
        ldd   d,y                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDX
        ldd   2,x                      ; load tile id
        ldd   d,y                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDY
        ldd   ,x                       ; load tile id
        ldd   d,y                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDU
        leau  15,u                     ; move to next dest block in code buffer
        cmpx  #vscroll.map.cache
        bne   @loop
        rts

; compute write location in buffer
; --------------------------------
vscroll.computeBufferWAddress
        ldb   vscroll.speed
        bpl   >
        negb                           ; absolute value
!       cmpb  vscroll.viewport.height  ; compare to viewport height
        bls   >
        ldb   vscroll.viewport.height
!       stb   <vscroll.loop.counter    ; setup nb of line to render
        negb                           ; keep lowest value and substract it to cursor + viewport height
        addb  vscroll.cursor
        addb  vscroll.viewport.height
        bcs   @cycle
        cmpb  #vscroll.BUFFER_LINES
        blo   >
@cycle  subb  #vscroll.BUFFER_LINES    ; cycling in buffer
!       lda   #vscroll.LINE_SIZE
        mul
        leax  d,x                      ; x is write location in buffer
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
        addb  #200                     ; viewport size (1-200)
vscroll.viewport.height equ *-1
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
        lda   #0
vscroll.cursor equ *-1
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