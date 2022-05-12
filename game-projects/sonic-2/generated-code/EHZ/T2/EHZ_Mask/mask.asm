	opt   c,ct
	INCLUDE "./generated-code/EHZ/T2/main-engine.glb"
	INCLUDE "./generated-code/EHZ/T2/EHZ_Mask/EHZ_Mask_ImageSet.glb"
	org   $3BFB
	setdp $FF

; ---------------------------------------------------------------------------
; Object - 
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"
        ldd   #$DF40-3980-40
	std   <glb_screen_location_2
        ldd   #$BF40-3980-40
	std   <glb_screen_location_1

	; set image metadata page
	ldu   #Img_Page_Index
	lda   #ObjID_EHZ_Mask
	lda   a,u
	ldx   #Img_EHZ_Mask
	rts
