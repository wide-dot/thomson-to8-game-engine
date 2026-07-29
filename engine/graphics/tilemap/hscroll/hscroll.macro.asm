; -----------------------------------------------------------------------------
; _hscroll.setBuffer
; -----------------------------------------------------------------------------
; input : object id of hscroll code buffer A (plane 0, RAMA data)
; input : object id of hscroll code buffer B (plane 1, RAMB data)
; -----------------------------------------------------------------------------
_hscroll.setBuffer MACRO
        ldx   #Obj_Index_Page
        ldy   #Obj_Index_Address
        ldb   \1
        lda   b,x
        sta   hscroll.obj.bufferA.page
        aslb
        ldu   b,y
        stu   hscroll.obj.bufferA.address
        ldb   \2
        lda   b,x
        sta   hscroll.obj.bufferB.page
        aslb
        ldu   b,y
        stu   hscroll.obj.bufferB.address
 ENDM

; -----------------------------------------------------------------------------
; _hscroll.setExitOffset
; -----------------------------------------------------------------------------
; input : offset of the guard line in the code buffer
;         (hscroll.band.EXIT_OFFSET from the generated .hscroll.equ file)
; -----------------------------------------------------------------------------
_hscroll.setExitOffset MACRO
        ldd   \1
        addd  #10*hscroll.ENTRY_CHUNK_SIZE
        std   hscroll.patch.offset     ; jmp pad location (fixed, end of buffer)
 ENDM

; -----------------------------------------------------------------------------
; _hscroll.setGuardColor
; -----------------------------------------------------------------------------
; input : guard color word (hscroll.band.GUARD from the generated .equ file)
; -----------------------------------------------------------------------------
_hscroll.setGuardColor MACRO
        ldd   \1
        std   hscroll.guard
 ENDM

; -----------------------------------------------------------------------------
; _hscroll.setViewport
; -----------------------------------------------------------------------------
; input : band line start from top of screen (in pixel)
; input : band height (in pixel)
; -----------------------------------------------------------------------------
_hscroll.setViewport MACRO
        lda   \1
        adda  \2
        ldb   #40                      ; nb of bytes in a line
        mul
        addd  #$A000                   ; video ram start location
        std   hscroll.dest.zoneB
        adda  #$20
        std   hscroll.dest.zoneA
 ENDM

; -----------------------------------------------------------------------------
; _hscroll.setCameraPos
; -----------------------------------------------------------------------------
; input : band shift in px (8.8 fixed point, int part 0-159)
; -----------------------------------------------------------------------------
_hscroll.setCameraPos MACRO
        ldd   \1
        std   hscroll.camera.x
 ENDM

; -----------------------------------------------------------------------------
; _hscroll.setCameraSpeed
; -----------------------------------------------------------------------------
; input : band speed (signed 8.8 fixed point) nb of pixels/50hz
; -----------------------------------------------------------------------------
_hscroll.setCameraSpeed MACRO
        ldd   \1
        std   hscroll.camera.speed
 ENDM
