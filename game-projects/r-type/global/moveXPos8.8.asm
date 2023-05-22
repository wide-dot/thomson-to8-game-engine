moveXPos8.8
	bita  #$80
	bne   LAB_0000_0a80
	addd  x_pos+1,u
	bcc   LAB_0000_0a7f
	inc   x_pos,u
LAB_0000_0a7f
	std   x_pos+1,u
	rts
LAB_0000_0a80
	addd  x_pos+1,u
	bcs   LAB_0000_0a7f
	dec   x_pos,u
	std   x_pos+1,u
	rts


