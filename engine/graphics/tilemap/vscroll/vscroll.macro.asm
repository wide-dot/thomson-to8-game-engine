; -----------------------------------------------------------------------------
; _vscroll.setMap
; -----------------------------------------------------------------------------
; input : object id of map
; -----------------------------------------------------------------------------
_vscroll.setMap MACRO
        ldb   \1
        ldx   #Obj_Index_Page
        lda   b,x   
        sta   vscroll.obj.map.page
        aslb
        ldx   #Obj_Index_Address
        ldx   b,x
        stx   vscroll.obj.map.address
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setMapHeight
; -----------------------------------------------------------------------------
; input : map height in pixels
; -----------------------------------------------------------------------------
_vscroll.setMapHeight MACRO
        ldd   \1
        std   vscroll.map.height
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setTileset
; -----------------------------------------------------------------------------
; input : object id of tileset A
; input : object id of tileset B
; -----------------------------------------------------------------------------

_vscroll.setTileset_ MACRO
        lda   #4
        sta   <dp_extreg
        ldu   #@list
        ldx   #Obj_Index_Page
        ldy   #vscroll.obj.tile.pages
@loop   equ   *
        ldd   ,u++
        lda   a,x   
        ldb   b,x   
        sta   ,y+
        stb   ,y+
        sta   ,y+
        stb   ,y+
        sta   ,y+
        stb   ,y+
        sta   ,y+
        stb   ,y+
        dec   <dp_extreg
        bne   @loop
        bra   @list+8
@list   equ   *
 ENDM

_vscroll.setUpdateRoutine_ MACRO
        sta   vscroll.tiles.nbLinesByPage
        asra
        ldx   #vscroll.tiles.dyncall
        ldx   a,x
        stx   vscroll.tiles.updateTilesForNLines.address
        lda   vscroll.tiles.nbLinesByPage
        asla
        sta   vscroll.tiles.nbLinesByPage.x2.0001
        sta   vscroll.tiles.nbLinesByPage.x2.0010
        sta   vscroll.tiles.nbLinesByPage.x2.0011
        sta   vscroll.tiles.nbLinesByPage.x2.0100
        sta   vscroll.tiles.nbLinesByPage.x2.0101
        sta   vscroll.tiles.nbLinesByPage.x2.0110
        sta   vscroll.tiles.nbLinesByPage.x2.0111
        sta   vscroll.tiles.nbLinesByPage.x2.1000
        sta   vscroll.tiles.nbLinesByPage.x2.1001
        sta   vscroll.tiles.nbLinesByPage.x2.1010
        sta   vscroll.tiles.nbLinesByPage.x2.1011
        sta   vscroll.tiles.nbLinesByPage.x2.1100
        sta   vscroll.tiles.nbLinesByPage.x2.1101
        sta   vscroll.tiles.nbLinesByPage.x2.1110
        sta   vscroll.tiles.nbLinesByPage.x2.1111
 ENDM

_vscroll.setTileset256 MACRO
 IFDEF vscroll.tiles.DEFINED
        lda   #16
        _vscroll.setUpdateRoutine_
 ENDC
        _vscroll.setTileset_
        fcb   \1
        fcb   \2
        fcb   \1
        fcb   \2
        fcb   \1
        fcb   \2
        fcb   \1
        fcb   \2
 ENDM

_vscroll.setTileset512 MACRO
 IFDEF vscroll.tiles.DEFINED
        lda   #16
        _vscroll.setUpdateRoutine_
 ENDC
        _vscroll.setTileset256 \1,\2
 ENDM

_vscroll.setTileset1024 MACRO
 IFDEF vscroll.tiles.DEFINED
        lda   #8        
        _vscroll.setUpdateRoutine_
 ENDC
        _vscroll.setTileset_
        fcb   \1
        fcb   \2
        fcb   \1
        fcb   \2
        fcb   \3
        fcb   \4
        fcb   \3
        fcb   \4
 ENDM

_vscroll.setTileset2048 MACRO
 IFDEF vscroll.tiles.DEFINED
        lda   #4
        _vscroll.setUpdateRoutine_
 ENDC
        _vscroll.setTileset_
        fcb   \1
        fcb   \2
        fcb   \3
        fcb   \4
        fcb   \5
        fcb   \6
        fcb   \7
        fcb   \8
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setTileNb
; -----------------------------------------------------------------------------
; input : number of tiles : 256, 512, 1024 or 2048
; -----------------------------------------------------------------------------
_vscroll.setTileNb MACRO

        ldd   \1
        _asld
        std   vscroll.obj.tile.nbx2
        _negd
 IFDEF vscroll.tiles.DEFINED
        std vscroll.tiles.nb.neg.x2.0001
        std vscroll.tiles.nb.neg.x2.0010
        std vscroll.tiles.nb.neg.x2.0011
        std vscroll.tiles.nb.neg.x2.0100
        std vscroll.tiles.nb.neg.x2.0101
        std vscroll.tiles.nb.neg.x2.0110
        std vscroll.tiles.nb.neg.x2.0111
        std vscroll.tiles.nb.neg.x2.1000
        std vscroll.tiles.nb.neg.x2.1001
        std vscroll.tiles.nb.neg.x2.1010
        std vscroll.tiles.nb.neg.x2.1011
        std vscroll.tiles.nb.neg.x2.1100
        std vscroll.tiles.nb.neg.x2.1101
        std vscroll.tiles.nb.neg.x2.1110
        std vscroll.tiles.nb.neg.x2.1111
 ENDC
        addd  #$A000+$4000
        std   @test
        ; compute lut for each starting address of the 16 line tilesets
        lda   #16
        sta   <dp_extreg
        ldx   #vscroll.obj.tile.adresses
        ldd   #$A000
@loop   equ   *
        std   ,x++
        addd  vscroll.obj.tile.nbx2
        cmpd  #$A000+4000
@test   equ   *-2
        bls   >
        ldd   #$A000
!       dec   <dp_extreg
        bne   @loop

 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setBuffer
; -----------------------------------------------------------------------------
; input : object id of vscroll code buffer A
; input : object id of vscroll code buffer B
; -----------------------------------------------------------------------------
_vscroll.setBuffer MACRO
        ldx   #Obj_Index_Page
        ldy   #Obj_Index_Address
        ldb   \1
        lda   b,x   
        sta   vscroll.obj.bufferA.page
        aslb
        ldu   b,y
        stu   vscroll.obj.bufferA.address
        leau  vscroll.BUFFER_LINES*vscroll.LINE_SIZE,u
        stu   vscroll.obj.bufferA.end
        ldb   \2
        lda   b,x   
        sta   vscroll.obj.bufferB.page
        aslb
        ldu   b,y
        stu   vscroll.obj.bufferB.address
        leau  vscroll.BUFFER_LINES*vscroll.LINE_SIZE,u
        stu   vscroll.obj.bufferB.end
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setCameraPos
; -----------------------------------------------------------------------------
; input : camera position in map 0-8191 (map height of 512 tiles max)
; -----------------------------------------------------------------------------
_vscroll.setCameraPos MACRO
        ldd   \1
        std   vscroll.camera.y
        std   vscroll.camera.lastY
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setCameraSpeed
; -----------------------------------------------------------------------------
; input : camera speed (signed 8.8 fixed point) nb of pixels/50hz
; -----------------------------------------------------------------------------
_vscroll.setCameraSpeed MACRO
        ldd   \1
        std   vscroll.camera.speed
        eora  vscroll.speed            ; check direction change
        anda  #%10000000               ; by comparing sign bit
        beq   @end                     ; eor return 0 if both bit are identical
        ldd   #0                       ; if direction change, get rid of remainer
        std   vscroll.speed            ; otherwise it may gives an unwanted
@end    equ   *                        ; boost on first frame
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setViewport
; -----------------------------------------------------------------------------
; input : viewport line start from top of screen (in pixel)
; input : viewport height (in pixel)
; -----------------------------------------------------------------------------
_vscroll.setViewport MACRO
        lda   \2
        sta   vscroll.viewport.height
        lda   \1
        sta   vscroll.viewport.y
        adda  vscroll.viewport.height
        ldb   #40                            ; nb of bytes in a line
        mul
        addd  #$A000                         ; video ram start location
        std   vscroll.viewport.ram
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.buffer
; -----------------------------------------------------------------------------
; data structure for buffer code
; -----------------------------------------------------------------------------

_vscroll.buffer.chunk MACRO
        ldd   #0
        ldx   #0
        ldy   #0
        ldu   #0
        pshs  d,x,y,u
 ENDM

_vscroll.buffer.line MACRO
        _vscroll.buffer.chunk
        _vscroll.buffer.chunk
        _vscroll.buffer.chunk
        _vscroll.buffer.chunk
        _vscroll.buffer.chunk
 ENDM

_vscroll.buffer.linex8 MACRO
        _vscroll.buffer.line
        _vscroll.buffer.line
        _vscroll.buffer.line
        _vscroll.buffer.line
        _vscroll.buffer.line
        _vscroll.buffer.line
        _vscroll.buffer.line
        _vscroll.buffer.line
 ENDM
