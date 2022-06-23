; ---------------------------------------------------------------------------
; Object - black side mask for tiles
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"

        ; select image
        ldx   #Images
        ldx   b,x

        ; set display position
        ldd   #$DF40-3980-40
	std   <glb_screen_location_2
        ldd   #$BF40-3980-40
	std   <glb_screen_location_1

	; set image metadata page
	ldu   #Img_Page_Index
	lda   #ObjID_Mask
	lda   a,u
	rts

Images
	fdb   Img_Mask_Sprite
        fdb   Img_Mask_Frame