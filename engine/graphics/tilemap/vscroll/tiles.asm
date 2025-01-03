
 

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
vscroll.buffer.wAddress                 equ dp_extreg+13 ; WORD
vscroll.buffer.currentPosition          equ dp_extreg+15 ; WORD
vscroll.tileset.remainingLines          equ dp_extreg+17 ; BYTE
vscroll.tiles.updateList.remainingBytes equ dp_extreg+18 ; WORD
vscroll.tiles.tilemap.cursor            equ dp_extreg+20 ; WORD
vscroll.tiles.tilegroup.wh              equ dp_extreg+22 ; WORD (alias to w and h)
vscroll.tiles.tilegroup.w               equ dp_extreg+22 ; BYTE
vscroll.tiles.tilegroup.h               equ dp_extreg+23 ; BYTE
vscroll.tiles.tilegroup.x               equ dp_extreg+24 ; BYTE
vscroll.tiles.tilegroup.y               equ dp_extreg+25 ; WORD
vscroll.tiles.updateFlag                equ dp_extreg+27 ; BYTE
; last available byte in dp is at dp_extreg+27

; constants
; -------------------
 IFNDEF vscroll.tiles.nbMaxUpdates
vscroll.tiles.nbMaxUpdates equ 16 ; by default 16 sprites can be added to tile update list
 ENDC
vscroll.tiles.updateListElementSize equ 5

; variables
; -------------------
vscroll.camera.tile.y.start fdb   0      ; camera start position in map (in tiles)
vscroll.camera.tile.y.end   fdb   0      ; camera end position in map (in tiles)
vscroll.tiles.updateList    fill  0,(vscroll.tiles.nbMaxUpdates*vscroll.tiles.updateListElementSize+2)
vscroll.tiles.state         fill  0,5*13 ; 5 group of 4 tiles for each of the 13 tile lines, only a nibble used for each byte.
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
; vscroll.tiles.updateTiles
;
; -----------------------------------------------------------------------------
; input  REG : none
; -----------------------------------------------------------------------------

vscroll.tiles.updateTiles

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
        lda   #-1
        sta   <vscroll.tiles.updateFlag ; this flag will skip part 2 if all tiles are already updated

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
        clr   <vscroll.tiles.updateFlag ; set update flag
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
        addb  vscroll.map.cache.line                       ; b already loaded with tile line from camera start
        cmpb  #vscroll.map.cache.NB_LINES
        blo   >
        subb  #vscroll.map.cache.NB_LINES                  ; cycling cache
!
        stb   @cursor                                      ; tile line in cycling state/cache
        lda   #vscroll.map.cache.LINE_SIZE
        mul
        ldx   #vscroll.map.cache
        leax  d,x
        ldb   <vscroll.tiles.tilegroup.x
        aslb                                               ; two bytes for each tileid in cache
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
        tst   <vscroll.tiles.updateFlag
        beq   >
        rts
!

        ; One Run for buffer A
        clr   vscroll.tiles.currentBuffer
        lda   vscroll.obj.bufferA.page
        _SetCartPageA                        ; mount scroll buffer in cartridge space
        ldu   vscroll.obj.bufferA.address
        leau  vscroll.BUFFER_LINES*vscroll.LINE_SIZE,u
        ldd   #vscroll.obj.tile.pages
        std   vscroll.tiles.tilePages        
        ldy   #vscroll.map.cache
        jsr   vscroll.tiles.updateTilesForOneBuffer

        ; One Run for buffer B
        inc   vscroll.tiles.currentBuffer
        lda   vscroll.obj.bufferB.page
        _SetCartPageA                        ; mount scroll buffer in cartridge space
        ldu   vscroll.obj.bufferB.address
        leau  vscroll.BUFFER_LINES*vscroll.LINE_SIZE,u
        ldd   #vscroll.obj.tile.pages
        addd  #1                             ; add offset specific to B buffer
        std   vscroll.tiles.tilePages
        ldy   #vscroll.map.cache

vscroll.tiles.updateTilesForOneBuffer
        stu   <vscroll.buffer.currentPosition
        stu   <vscroll.buffer.wAddress
        ldx   #vscroll.tiles.state

@loop
        leau  -vscroll.CHUNCK_SIZE,u
        ldb   ,x+
        beq   >
        jsr   vscroll.tiles.updateTilesForOneGroup
!       leay  8,y
        leau  -vscroll.CHUNCK_SIZE,u
        ldb   ,x+
        beq   >
        jsr   vscroll.tiles.updateTilesForOneGroup
!       leay  8,y
        leau  -vscroll.CHUNCK_SIZE,u
        ldb   ,x+
        beq   >
        jsr   vscroll.tiles.updateTilesForOneGroup
!       leay  8,y
        leau  -vscroll.CHUNCK_SIZE,u
        ldb   ,x+
        beq   >
        jsr   vscroll.tiles.updateTilesForOneGroup
!       leay  8,y
        leau  -vscroll.CHUNCK_SIZE,u
        ldb   ,x+
        beq   >
        jsr   vscroll.tiles.updateTilesForOneGroup
!       cmpx  #vscroll.tiles.state.end
        beq   @exit
        leay  8,y
        leau  -vscroll.LINE_SIZE*15,u
        bra   @loop
@exit   rts

vscroll.tiles.updateTilesForOneGroup
        lda   #0
vscroll.tiles.currentBuffer equ *-1
        beq   >
        clr   -1,x                                         ; clear current state byte only with buffer B
!       pshs  x,y
        ldx   #vscroll.tiles.copyRoutines                  ; compute dynamic routine for this group
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
        puls  x,y,pc
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
!       ldx   #vscroll.obj.tile.adresses     ; load A tileset addr
        ldx   a,x
        jsr   >*                             ; copy bitmap for buffer A
vscroll.tiles.copyRoutine equ *-2
        leau  -vscroll.LINE_SIZE,u           ; go to next screen line in code buffer
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
