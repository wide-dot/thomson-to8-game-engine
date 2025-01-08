
 

; -----------------------------------------------------------------------------
; vscroll.tiles.draw
; Add a sprite (based on tile mapping) to a drawing queue.
; With video double buffering, we need to maintain two arrays.
; -----------------------------------------------------------------------------
; input  REG : [b] x absolute coordinate in pixels
;              [x] y absolute coordinate in pixels
;              [y] ptr to sprite tile mapping data
; -----------------------------------------------------------------------------

; temporary variables
; -------------------
vscroll.tileset.remainingLines          equ dp_extreg+13 ; BYTE
vscroll.tiles.updateList.remainingBytes equ dp_extreg+14 ; WORD
vscroll.tiles.tilemap.cursor            equ dp_extreg+16 ; WORD
vscroll.tiles.tilegroup.wh              equ dp_extreg+18 ; WORD (alias to w and h)
vscroll.tiles.tilegroup.w               equ dp_extreg+18 ; BYTE
vscroll.tiles.tilegroup.h               equ dp_extreg+19 ; BYTE
vscroll.tiles.tilegroup.x               equ dp_extreg+20 ; BYTE
vscroll.tiles.tilegroup.y               equ dp_extreg+21 ; WORD
vscroll.tiles.backBuffer                equ dp_extreg+23 ; BYTE
vscroll.tiles.currentBuffer             equ dp_extreg+24 ; BYTE
; last available byte in dp is at dp_extreg+27

; constants
; -------------------
 IFNDEF vscroll.tiles.nbMaxUpdates
vscroll.tiles.nbMaxUpdates equ 16 ; by default 16 sprites can be added to tile update list
 ENDC
vscroll.tiles.updateListElementSize equ 5

vscroll.tiles.buffer.positions
        fdb   0*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   0*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   0*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   0*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   0*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   1*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   1*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   1*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   1*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   1*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   2*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   2*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   2*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   2*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   2*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   3*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   3*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   3*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   3*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   3*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   4*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   4*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   4*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   4*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   4*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   5*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   5*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   5*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   5*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   5*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   6*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   6*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   6*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   6*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   6*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   7*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   7*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   7*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   7*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   7*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   8*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   8*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   8*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   8*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   8*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   9*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   9*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   9*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   9*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   9*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   10*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   10*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   10*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   10*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   10*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   11*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   11*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   11*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   11*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   11*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE
        fdb   12*vscroll.LINE_SIZE*16+4*vscroll.CHUNCK_SIZE
        fdb   12*vscroll.LINE_SIZE*16+3*vscroll.CHUNCK_SIZE
        fdb   12*vscroll.LINE_SIZE*16+2*vscroll.CHUNCK_SIZE
        fdb   12*vscroll.LINE_SIZE*16+1*vscroll.CHUNCK_SIZE
        fdb   12*vscroll.LINE_SIZE*16+0*vscroll.CHUNCK_SIZE

; variables
; -------------------
vscroll.camera.tile.y.start fdb   0      ; camera start position in map (in tiles)
vscroll.camera.tile.y.end   fdb   0      ; camera end position in map (in tiles)
vscroll.tiles.updateList    fill  0,(vscroll.tiles.nbMaxUpdates*vscroll.tiles.updateListElementSize+2)
vscroll.tiles.state         fill  0,5*13 ; 5 group of 4 tiles for each of the 13 tile lines, only a nibble used for each byte.
                            fcb   -1     ; end state array flag
vscroll.tiles.updateFlag    fcb   -1

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
        ldx   #vscroll.tiles.updateList
        ldd   ,x
        addd  #vscroll.tiles.updateListElementSize
        cmpd  #vscroll.tiles.nbMaxUpdates*vscroll.tiles.updateListElementSize
        bls   >
        orcc  #%00000001 ; return KO
        rts              ; array is full
!       std   ,x         ; update size of array
        subd  #vscroll.tiles.updateListElementSize-2  ; skip header (size data)
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

; -----------------------------------------------------------------------------
; vscroll.tiles.Update
;
; -----------------------------------------------------------------------------
; input  REG : none
; -----------------------------------------------------------------------------

vscroll.tiles.update

; Part1 ---------------------------------
; update tilemap, map.cache with new tile ids
; set state bitfield for part2

        ;
        ; compare the tile of vscroll.tiles.updateList with the one in tilemap
        ; --------------------------------------------------------------------
        ldd   vscroll.tiles.updateList
        bne   >
        rts
!
        std   <vscroll.tiles.updateList.remainingBytes
        lda   #1
        sta   vscroll.tiles.updateFlag

        ldd   vscroll.camera.currentY   ; compute camera start and end position in tilemap (visible range)
        _lsrd                           ; a tile is 16px high
        _lsrd
        _lsrd
        _lsrd
        std   vscroll.camera.tile.y.start

        ldd   vscroll.camera.currentY   ; compute camera start and end position in tilemap (visible range)
        addd  vscroll.viewport.height.w ; add viewport height to get end of visible range
        _lsrd                           ; a tile is 16px high
        _lsrd
        _lsrd
        _lsrd
        std   vscroll.camera.tile.y.end

        lda   vscroll.obj.map.page
        _SetCartPageA                  ; mount page that contain map data
        ldy   vscroll.obj.map.address  ; handle up to 512 lines in map
        ldx   #vscroll.tiles.updateList+2
@loopUpdateList
        ;
        ; load tile group data
        ; --------------------
        ldu   3,x                      ; tile group address
        ldd   ,u++                     ; 8bits: nb lines, 8bits: nb columns
        std   <vscroll.tiles.tilegroup.wh
        sta   @width
        ; process line
        ; ------------
        ldd   1,x                      ; read tile line number in map
        std   <vscroll.tiles.tilegroup.y
        _lsrd                          ; max line number is 511, cannot use mult as is. Divide line in map by two
        bcc   >                        ; branch if line/2 is even
        leay  30,y                     ; if line/2 is odd, offset position in map by 30 bytes (12bits id * 20 tiles)
!       lda   #60                      ; 2 lines of 30 bytes (12bits id * 20 tiles)
        mul                            ; mult by line/2
        leay  d,y                      ; y point to desired data map line
        sty   <vscroll.tiles.tilemap.cursor
        ; process column
        ; --------------
        ldb   ,x                       ; read tile column number in map
        stb   <vscroll.tiles.tilegroup.x
@loopTileGroup
        lsrb                           ; unpacking tile id
        bcs   >                        ; from 12bit to 16bit
        ; read even tile
        ; --------------
        addb  ,x                       ; b is now mult. by 1.5x
        incb
        leay  b,y
        ldd   ,y                       ; get the first packed word
        andb  #$0F
        stb   @b
        _lsrd   
        _lsrd
        _lsrd
        _lsrd
        bra   @endif
!       ; read odd tile
        ; -------------
        addb  ,x                       ; b is now mult. by 1.5x
        leay  b,y
        ldd   ,y
        anda  #$F0
        sta   @a
        lda   ,y
        anda  #$0F
@endif
        cmpd  ,u++                     ; tile id (tilemap) is now in d, compare to the one in update list
        beq   @continue                ; branch if no update needed
        clr   vscroll.tiles.updateFlag ; set update flag
        ;
        ; update tilemap (tile is different)
        ; ----------------------------------
        ldb   <vscroll.tiles.tilegroup.x
        lsrb                           ; unpacking tile id
        bcs   >                        ; from 12bit to 16bit
        ; write even tile
        ; ---------------
        ldd   -2,u
        _lsld
        _lsld
        _lsld
        _lsld
        eorb  #0
@b      equ   *-1
        std   ,y
        bra   @endif2
!       ; write odd tile
        ; --------------
        ldd   -2,u
        eora  #0
@a      equ   *-1
        std   ,y
@endif2
        ;
        ; check if tile line is in visible range
        ; --------------------------------------
        ldd   <vscroll.tiles.tilegroup.y                   ; actual tile line position in map
        cmpd  vscroll.camera.tile.y.end
        bhi   @continue
        subd  vscroll.camera.tile.y.start
        bcs   @continue
        ;
        ; apply changes to vscroll.map.cache
        ; ----------------------------------
        pshs  x
        stb   @line
        ldb   vscroll.map.cache.line
        subb  #0
@line   equ   *-1
        bpl   >
        addb  #vscroll.map.cache.NB_LINES                  ; cycling cache
!
        stb   @cursor                                      ; tile line in cycling state/cache
        lda   #vscroll.map.cache.LINE_SIZE
        mul
        ldx   #vscroll.map.cache
        leax  d,x
        ldb   <vscroll.tiles.tilegroup.x
        lslb                                               ; two bytes for each tileid in cache
        ldy   -2,u                                         ; reload tile_id
        sty   b,x                                          ; store new tile_id in cache
        ;
        ; set the corresponding bit in vscroll.tiles.state
        ; ------------------------------------------------
        ; one byte store a bitfield for 4 consecutive tiles
        ; there are 4 usefull state bits in a byte
        ; 0000 1000 : tile 0
        ; 0000 0100 : tile 1
        ; 0000 0010 : tile 2
        ; 0000 0001 : tile 3
        lda   #5                                           ; there are 5 bytes per row in state array
        ldb   #0
@cursor equ   *-1
        mul
        ldx   #vscroll.tiles.state
        abx
        lda   #8
        ldb   <vscroll.tiles.tilegroup.x
        lsrb
        bcc   >
        lsra                                               ; tranform value 0-3 to a bitfield
!       lsrb
        bcc   >
        lsra
        lsra
!       abx
        eora  ,x
        sta   ,x
        puls  x
        ;
@continue
        ldy   <vscroll.tiles.tilemap.cursor
        inc   <vscroll.tiles.tilegroup.x
        ldb   <vscroll.tiles.tilegroup.x
        dec   <vscroll.tiles.tilegroup.w
        lbne  @loopTileGroup        
        dec   <vscroll.tiles.tilegroup.h
        beq   @nextUpdateList
        leay  30,y                                         ; move to next line in tilemap
        sty   <vscroll.tiles.tilemap.cursor
        lda   #0                                           ; reload width
@width  equ *-1
        sta   <vscroll.tiles.tilegroup.w
        ldb   ,x                                           ; reload start position for x in tilemap
        stb   <vscroll.tiles.tilegroup.x
        inc   <vscroll.tiles.tilegroup.y+1                 ; move for next line position in tilemap
        bcc   >
        inc   <vscroll.tiles.tilegroup.y
!       jmp   @loopTileGroup
@nextUpdateList
        ldd   <vscroll.tiles.updateList.remainingBytes
        subd  #vscroll.tiles.updateListElementSize
        std   <vscroll.tiles.updateList.remainingBytes
        beq   @clearUpdateList
        leax  5,x                                          ; move to next element in update list
        jmp   @loopUpdateList
@clearUpdateList
        ldd   #0
        std   vscroll.tiles.updateList                     ; clear the array

; Part2 ---------------------------------
; draw in code buffer

        ; Check if at least one element has changed
        tst   vscroll.tiles.updateFlag
        beq   >
        rts
!
        ldb   map.CF74021.DATA
        stb   <vscroll.tiles.backBuffer      ; backup back video buffer

        ; One Run for buffer A
        clr   <vscroll.tiles.currentBuffer
        lda   vscroll.obj.bufferA.page
        _SetCartPageA                        ; mount scroll buffer in cartridge space
        ldu   vscroll.obj.bufferA.address
        ldd   #vscroll.obj.tile.pages
        std   vscroll.tiles.tilePages        
        jsr   vscroll.tiles.updateTilesForOneBuffer

        ; One Run for buffer B
        inc   <vscroll.tiles.currentBuffer
        lda   vscroll.obj.bufferB.page
        _SetCartPageA                        ; mount scroll buffer in cartridge space
        ldu   vscroll.obj.bufferB.address
        ldd   #vscroll.obj.tile.pages
        addd  #1                             ; add offset specific to B buffer
        std   vscroll.tiles.tilePages
        jsr   vscroll.tiles.updateTilesForOneBuffer

        ldb   <vscroll.tiles.backBuffer      ; restore video buffer
        stb   map.CF74021.DATA
        rts

vscroll.tiles.updateTilesForOneBuffer
        ldx   #vscroll.tiles.state
@loop
        ldd   ,x++ ; quick browse
        beq   @loop
;
        tsta
        beq   @tstb
;
        sta   vscroll.tiles.routineId
        tst   <vscroll.tiles.currentBuffer ; clear current state bytes only with buffer B
        beq   >
        clr   -2,x
!       pshs  x,b ; save second state byte
        ldu   #vscroll.tiles.buffer.positions
        tfr   x,d
        subd  #vscroll.tiles.state+2 ; +2 is because x have been ++
        aslb
        ldu   d,u ; u is a ptr to write position in buffer, use d instead of b (leau b, is signed)
        lda   #8/2 ; b is already mult by 2
        mul
        ldy   #vscroll.map.cache
        leay  d,y ; y is a ptr to read position in tile cache (4 tiles of 2 bytes = 8 bytes)
        jsr   vscroll.tiles.updateTilesForOneGroup
        puls  x,b
@tstb
        tstb
        beq   @loop
        cmpb  #-1 ; test for end flag
        bne   >
        rts
!       stb   vscroll.tiles.routineId
        tst   <vscroll.tiles.currentBuffer ; clear current state bytes only with buffer B
        beq   >
        clr   -1,x
!       pshs  x
        ldu   #vscroll.tiles.buffer.positions
        tfr   x,d        
        subd  #vscroll.tiles.state+1 ; +1 is because x have been +
        aslb
        ldu   d,u ; u is a ptr to write position in buffer, use d instead of b (leau b, is signed)
        lda   #8/2 ; b is already mult by 2
        mul
        ldy   #vscroll.map.cache
        leay  d,y ; y is a ptr to read position in tile cache (4 tiles of 2 bytes = 8 bytes)
        jsr   vscroll.tiles.updateTilesForOneGroup
        puls  x
        bra   @loop

vscroll.tiles.updateTilesForOneGroup
        ldx   #vscroll.tiles.copyRoutines                  ; compute dynamic routine for this group
        ldb   #0
vscroll.tiles.routineId equ *-1
        aslb
        ldd   b,x
        std   vscroll.tiles.copyRoutine
        ldb   #15*2
        stb   <vscroll.tileset.line
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
        rts
vscroll.tiles.dyncall
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
        ldb   a,x
        stb   map.CF74021.DATA               ; mount in data space
        ldx   #vscroll.obj.tile.adresses     ; load A tileset addr
        ldx   a,x
        jmp   >*                             ; copy bitmap for buffer A
vscroll.tiles.copyRoutine equ *-2

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
!       ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.0001 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.0001 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.0010
!       ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.0010 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.0010 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.0011
!       ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.0011 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.0011 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.0100
!       ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.0100 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.0100 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.0101
!       ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX
        
        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.0101 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.0101 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.0110
!       ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.0110 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.0110 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.0111
!       ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.0111 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.0111 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.1000
!       ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.1000 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.1000 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.1001
!       ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.1001 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.1001 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.1010
!       ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.1010 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.1010 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.1011
!       ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.1011 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.1011 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.1100
!        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.1100 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.1100 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.1101
!       ldd   6,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   11,u                     ; fill the LDU

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.1101 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.1101 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.1110
!       ldd   4,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   8,u                      ; fill the LDY

        ldd   2,y                      ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   4,u                      ; fill the LDX

        ldd   ,y                       ; load tile id
        ldd   d,x                      ; load 4 pixels of this tile line
        std   1,u                      ; fill the LDD

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.1110 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.1110 equ *-1
        sta   <vscroll.tileset.line
        rts

vscroll.tiles.copyBitmap.1111
!       ldd   6,y                      ; load tile id
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

        leau  vscroll.LINE_SIZE,u      ; go to next screen line in code buffer
        leax  -1234,x
vscroll.tiles.nb.neg.x2.1111 equ *-2
        dec   <vscroll.tileset.remainingLines
        bne   <
        lda   <vscroll.tileset.line
        suba  #0
vscroll.tiles.nbLinesByPage.x2.1111 equ *-1
        sta   <vscroll.tileset.line
        rts
