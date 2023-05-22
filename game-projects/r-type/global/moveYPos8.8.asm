moveYPos8.8
	bita  #$80
	bne   LAB_0000_0a97
	addd  y_pos+1,u
	bcc   LAB_0000_0a96
	inc   y_pos,u
LAB_0000_0a96
	std   y_pos+1,u
	rts
LAB_0000_0a97
	addd  y_pos+1,u
	bcs   LAB_0000_0a96
	dec   y_pos,u
	std   y_pos+1,u
	rts