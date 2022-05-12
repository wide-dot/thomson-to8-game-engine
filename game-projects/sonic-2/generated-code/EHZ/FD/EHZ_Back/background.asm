	opt   c,ct
	INCLUDE "./generated-code/EHZ/FD/main-engine.glb"
	INCLUDE "./generated-code/EHZ/FD/EHZ_Back/EHZ_Back_ImageSet.glb"
	org   $039E
	setdp $FF

; ---------------------------------------------------------------------------
; Object - 
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"
        ldd   #$DF40-3859-161
	std   <glb_screen_location_2
        ldd   #$BF40-3859-161
	std   <glb_screen_location_1

	; set image metadata page
	ldu   #Img_Page_Index
	lda   #ObjID_EHZ_Back
	lda   a,u
	ldx   #Img_EHZ_Back
	rts
