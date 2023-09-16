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
; _vscroll.setTileset
; -----------------------------------------------------------------------------
; input : object id of tileset A
; input : object id of tileset B
; -----------------------------------------------------------------------------
_vscroll.setTileset MACRO
        ldx   #Obj_Index_Page
        ldy   #Obj_Index_Address
        ldb   \1
        lda   b,x   
        sta   vscroll.obj.tileA.page
        aslb
        ldu   b,y
        leau  $A000,u
        stu   vscroll.obj.tileA.address
        ldb   \2
        lda   b,x   
        sta   vscroll.obj.tileB.page
        aslb
        ldu   b,y
        leau  $A000,u
        stu   vscroll.obj.tileB.address
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
        ldb   \2
        lda   b,x   
        sta   vscroll.obj.bufferB.page
        aslb
        ldu   b,y
        stu   vscroll.obj.bufferB.address
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