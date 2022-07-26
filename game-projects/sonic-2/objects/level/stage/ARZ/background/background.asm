; ---------------------------------------------------------------------------
; Object - 
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        ldd   #$DF40-3859-161
	std   <glb_screen_location_2
        ldd   #$BF40-3859-161
	std   <glb_screen_location_1

	; set image metadata page
	ldu   #Img_Page_Index
	lda   #ObjID_ARZ_Back
	lda   a,u
	ldx   #Img_ARZ_Back
	rts