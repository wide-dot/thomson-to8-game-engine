
 

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