; ---------------------------------------------------------------------------
; Object - return image index and position for full frame img
;
; input  image id in a
; return image page in a
;        image address in x
; ---------------------------------------------------------------------------

        asla
        sta   @imgnum
        ldd   #$DF40-3859-161
	std   <glb_screen_location_2
        ldd   #$BF40-3859-161
	std   <glb_screen_location_1
	; set image metadata page
	ldu   #Img_Page_Index
	lda   #ObjID_Frame
	lda   a,u
        ldb   #0
@imgnum equ   *-1
        ldx   #ImageIndex
        ldx   b,x
	rts

ImageIndex
        fdb   Img_Back
        fdb   Img_Frame
        fdb   Img_FrameBack