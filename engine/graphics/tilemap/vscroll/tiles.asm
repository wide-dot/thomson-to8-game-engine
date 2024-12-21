
 

; -----------------------------------------------------------------------------
; vscroll.tiles.draw
; Add a sprite (based on tile mapping) to a drawing queue.
; With video double buffering, we need to maintain two arrays.
; -----------------------------------------------------------------------------
; input  REG : [d] x,y coordinates of top left corner for sprite
;              [y] ptr to sprite tile mapping data
; -----------------------------------------------------------------------------

 IFNDEF vscroll.tiles.nbMaxUpdates
vscroll.tiles.nbMaxUpdates equ 16 ; by default 16 sprites can be added to tile update list
 ENDC

vscroll.tiles.bufferElementSize equ 4

vscroll.tiles.buffer
        fdb   vscroll.tiles.bufferA
        fdb   vscroll.tiles.bufferB

vscroll.tiles.bufferA
        fill  0,(vscroll.tiles.nbMaxUpdates*vscroll.tiles.bufferElementSize+2)

vscroll.tiles.bufferB
        fill  0,(vscroll.tiles.nbMaxUpdates*vscroll.tiles.bufferElementSize+2)


vscroll.tiles.draw
        std   @coordinates
        ldb   gfxlock.backBuffer.id ; alternate buffer based on in/active double buffering RAM
        aslb
        ldx   #vscroll.tiles.buffer
        abx
        ldx   ,x
        ; update size of array
        ldd   ,x
        addd  #4
        cmpd  #vscroll.tiles.nbMaxUpdates*vscroll.tiles.bufferElementSize
        bls   >
        orcc  #%00000001 ; return KO
        rts              ; array is full
!       std   ,x
        subd  #2  ; skip header (size data)
        leax  d,x ; go to first free element of the array
        ldd   #0
@coordinates equ *-2
        std   ,x  ; add coordinates to array
        sty   2,x ; add ptr (sprite tile mapping data) to array
        andcc #%11111110
        rts              ; return OK

vscroll.tiles.resetFrame
        ldb   gfxlock.backBuffer.id ; alternate buffer based on in/active double buffering RAM
        aslb
        ldx   #vscroll.tiles.buffer
        abx
        ldx   ,x
        ldd   #0                    ; clear the array
        std   ,x
        rts