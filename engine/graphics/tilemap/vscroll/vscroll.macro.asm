; -----------------------------------------------------------------------------
; _vscroll.setMap
; -----------------------------------------------------------------------------
; input : object id of map
; -----------------------------------------------------------------------------
_vscroll.setMap MACRO
        lda   \1
        sta   vscroll.obj.map
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setTileset
; -----------------------------------------------------------------------------
; input : object id of tileset A
; input : object id of tileset B
; -----------------------------------------------------------------------------
_vscroll.setTileset MACRO
        lda   \1
        sta   vscroll.obj.tileA
        lda   \2
        sta   vscroll.obj.tileB
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setBuffer
; -----------------------------------------------------------------------------
; input : object id of vscroll code buffer A
; input : object id of vscroll code buffer B
; -----------------------------------------------------------------------------
_vscroll.setBuffer MACRO
        lda   \1
        sta   vscroll.obj.bufferA
        lda   \2
        sta   vscroll.obj.bufferB
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
 ENDM

; -----------------------------------------------------------------------------
; _vscroll.setViewport
; -----------------------------------------------------------------------------
; input : viewport height (in pixel)
; input : viewport line start from top of screen (in pixel)
; -----------------------------------------------------------------------------
_vscroll.setViewport MACRO
        lda   \1
        ldb   \2
        stb   vscroll.viewport.height
        sta   vscroll.viewport.y
        adda  vscroll.viewport.height
        ldb   #40                            ; nb of bytes in a line
        mul
        addd  #$A000                         ; video ram start location
        std   vscroll.viewport.ram
 ENDM