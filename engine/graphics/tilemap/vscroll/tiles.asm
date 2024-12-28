
 

; -----------------------------------------------------------------------------
; vscroll.tiles.draw
; Add a sprite (based on tile mapping) to a drawing queue.
; With video double buffering, we need to maintain two arrays.
; -----------------------------------------------------------------------------
; input  REG : [b] x absolute coordinate in pixels
;              [x] y absolute coordinate in pixels
;              [y] ptr to sprite tile mapping data
; -----------------------------------------------------------------------------

 IFNDEF vscroll.tiles.nbMaxUpdates
vscroll.tiles.nbMaxUpdates equ 16 ; by default 16 sprites can be added to tile update list
 ENDC

vscroll.tiles.bufferElementSize equ 5

vscroll.tiles.buffer
        fdb   vscroll.tiles.bufferA
        fdb   vscroll.tiles.bufferB

vscroll.tiles.bufferA
        fill  0,(vscroll.tiles.nbMaxUpdates*vscroll.tiles.bufferElementSize+2)

vscroll.tiles.bufferB
        fill  0,(vscroll.tiles.nbMaxUpdates*vscroll.tiles.bufferElementSize+2)

vscroll.tiles.state
        fill  0,5*13 ; 5 group of 4 tiles for each of the 13 tile lines, only a nibble used for each byte.
vscroll.tiles.state.end

vscroll.tiles.draw
        ; transform sprite position in tile position
        lsrb
        lsrb
        lsrb
        stb   @x
        tfr   x,d
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        std   @y
        ; adjust position based on image size
        ldb   ,y ; load width in tiles
        decb
        lsrb
        negb
        addb  @x
        stb   @x
        clra
        ldb   1,y ; load height in tiles
        decb
        lsrb
        _negd
        addd  @y
        std   @y
        ; copy data to draw list
        ldb   gfxlock.backBuffer.id ; alternate buffer based on in/active double buffering RAM
        aslb
        ldx   #vscroll.tiles.buffer
        abx
        ldx   ,x
        ; update size of array
        ldd   ,x
        addd  #vscroll.tiles.bufferElementSize
        cmpd  #vscroll.tiles.nbMaxUpdates*vscroll.tiles.bufferElementSize
        bls   >
        orcc  #%00000001 ; return KO
        rts              ; array is full
!       std   ,x
        subd  #vscroll.tiles.bufferElementSize-2  ; skip header (size data)
        leax  d,x ; go to first free element of the array
        ldb   #0
@x      equ   *-1
        stb   ,x  ; add x coordinates to array
        ldd   #0
@y      equ    *-2
        std   1,x ; add y coordinates to array
        sty   3,x ; add ptr (sprite tile mapping data) to array
        andcc #%11111110
        rts       ; return OK

vscroll.tiles.resetFrame
        ldb   gfxlock.backBuffer.id ; alternate buffer based on in/active double buffering RAM
        aslb
        ldx   #vscroll.tiles.buffer
        abx
        ldx   ,x
        ldd   #0                    ; clear the array
        std   ,x
        rts


; copy the tile bitmap to the code buffer
; by reading tiles in reverse order (from right to left)
; ---------------------------------------

vscroll.tiles.state.start      equ dp_extreg+12 ; WORD
vscroll.buffer.wAddress        equ dp_extreg+14 ; WORD
vscroll.buffer.currentPosition equ dp_extreg+16 ; WORD
vscroll.tileset.remainingLines equ dp_extreg+18 ; BYTE

vscroll.tiles.updateTiles

        ; One Run for buffer A
        lda   vscroll.obj.bufferA.page
        _SetCartPageA                        ; mount scroll buffer in cartridge space
        ldu   vscroll.obj.bufferA.address
        ldd   #vscroll.obj.tile.pages
        std   vscroll.tiles.tilePages        
        ldy   #vscroll.tiles.bufferA
        jsr   vscroll.tiles.updateTilesForOneBuffer

        ; One Run for buffer B
        lda   vscroll.obj.bufferB.page
        _SetCartPageA                        ; mount scroll buffer in cartridge space
        ldu   vscroll.obj.bufferB.address
        ldd   #vscroll.obj.tile.pages
        addd  #1                             ; add offset specific to B buffer
        std   vscroll.tiles.tilePages
        ldy   #vscroll.tiles.bufferB

vscroll.tiles.updateTilesForOneBuffer
        stu   <vscroll.buffer.currentPosition
        stu   <vscroll.buffer.wAddress
        ldx   #vscroll.tiles.state

@loop
        ldb   ,x+
        beq   >
        jsr   vscroll.tiles.updateTilesForOneGroup
!       leay  16,y                                      ; TODO: check fastest way, change for the same as ldu leau in this loop ?
        ldb   ,x+
        beq   >
        ldu   <vscroll.buffer.currentPosition
        leau  1*vscroll.CHUNCK_SIZE,u
        jsr   vscroll.tiles.updateTilesForOneGroup
!       leay  16,y
        ldb   ,x+
        beq   >
        ldu   <vscroll.buffer.currentPosition
        leau  2*vscroll.CHUNCK_SIZE,u
        jsr   vscroll.tiles.updateTilesForOneGroup
!       leay  16,y
        ldb   ,x+
        beq   >
        ldu   <vscroll.buffer.currentPosition
        leau  3*vscroll.CHUNCK_SIZE,u
        jsr   vscroll.tiles.updateTilesForOneGroup
!       leay  16,y
        ldb   ,x+
        beq   >
        ldu   <vscroll.buffer.currentPosition
        leau  4*vscroll.CHUNCK_SIZE,u
        jsr   vscroll.tiles.updateTilesForOneGroup
!      
        cmpx  #vscroll.tiles.state.end
        beq   @exit
        leau  vscroll.LINE_SIZE,u
        stu   <vscroll.buffer.currentPosition
        leay  16,y
        bra   @loop
@exit   rts

vscroll.tiles.updateTilesForOneGroup
        pshs  x
        ldx   #vscroll.tiles.copyRoutines               ; compute dynamic routine for this group
        aslb
        ldd   b,x
        std   vscroll.tiles.copyRoutine
        clr   <vscroll.tileset.line
        jmp   >*
vscroll.tiles.updateTilesForNLines.address equ *-2
@dyncall4
        jsr   vscroll.tiles.updateTilesForNLines
        jsr   vscroll.tiles.updateTilesForNLines
@dyncall2
        jsr   vscroll.tiles.updateTilesForNLines
@dyncall1
        jsr   vscroll.tiles.updateTilesForNLines
@dyncall0
        puls  x,pc
@dyncall
        fdb   @dyncall0 ; unused
        fdb   @dyncall4
        fdb   @dyncall2
        fdb   @dyncall0 ; unused
        fdb   @dyncall1

vscroll.tiles.updateTilesForNLines
        ldb   #0
vscroll.tiles.nbLinesByPage equ *-1
        stb   <vscroll.tileset.remainingLines
        lda   <vscroll.tileset.line
        ldx   #0                             ; load tileset page
vscroll.tiles.tilePages equ *-2
        lda   a,x
        sta   map.CF74021.DATA               ; mount in data space
!
        ldx   #vscroll.obj.tile.adresses     ; load tileset addr
        ldx   a,x
        jsr   >*                             ; copy bitmap for buffer A
vscroll.tiles.copyRoutine equ *-2
        leau  vscroll.LINE_SIZE,u            ; go to next screen line in code buffer
        lda   <vscroll.tileset.line
        adda  #2
        sta   <vscroll.tileset.line
        dec   <vscroll.tileset.remainingLines
        bne   <
        rts

vscroll.tiles.copyRoutines
        fdb   0
        fdb   vscroll.tiles.copyBitmap.0001
        fdb   vscroll.tiles.copyBitmap.0010
        fdb   vscroll.tiles.copyBitmap.0011
        fdb   vscroll.tiles.copyBitmap.0100
        fdb   vscroll.tiles.copyBitmap.0101
        fdb   vscroll.tiles.copyBitmap.0110
        fdb   vscroll.tiles.copyBitmap.0111
        fdb   vscroll.tiles.copyBitmap.1000
        fdb   vscroll.tiles.copyBitmap.1001
        fdb   vscroll.tiles.copyBitmap.1010
        fdb   vscroll.tiles.copyBitmap.1011
        fdb   vscroll.tiles.copyBitmap.1100
        fdb   vscroll.tiles.copyBitmap.1101
        fdb   vscroll.tiles.copyBitmap.1110
        fdb   vscroll.tiles.copyBitmap.1111

vscroll.tiles.copyBitmap.0001
        ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU
        rts

vscroll.tiles.copyBitmap.0010
        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY
        rts

vscroll.tiles.copyBitmap.0011
        ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY
        rts

vscroll.tiles.copyBitmap.0100
        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX
        rts

vscroll.tiles.copyBitmap.0101
        ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX
        rts

vscroll.tiles.copyBitmap.0110
        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX
        rts

vscroll.tiles.copyBitmap.0111
        ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX
        rts

vscroll.tiles.copyBitmap.1000
        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD
        rts

vscroll.tiles.copyBitmap.1001
        ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD
        rts

vscroll.tiles.copyBitmap.1010
        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD
        rts

vscroll.tiles.copyBitmap.1011
        ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD
        rts

vscroll.tiles.copyBitmap.1100
        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD
        rts

vscroll.tiles.copyBitmap.1101
        ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD
        rts

vscroll.tiles.copyBitmap.1110
        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD
        rts

vscroll.tiles.copyBitmap.1111
        ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD
        rts
