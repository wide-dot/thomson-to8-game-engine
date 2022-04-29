CheckCameraMove
	; check if camera has moved
	; and if tiles need an update
	lda   #0
	sta   glb_camera_move
        tst   glb_Cur_Wrk_Screen_Id
        bne   @b1
@b0     ldx   <glb_camera_x_pos
	cmpx  glb_old_camera_x_pos0
	bne   @endx0
	ldd   <glb_camera_y_pos
	cmpd  glb_old_camera_y_pos0
	bne   @endy0
        rts
@b1     ldx   <glb_camera_x_pos
	cmpx  glb_old_camera_x_pos1
	bne   @endx1
	ldd   <glb_camera_y_pos
	cmpd  glb_old_camera_y_pos1
	bne   @endy1
        rts
@endx0 	ldd   <glb_camera_y_pos
@endy0	std   glb_old_camera_y_pos0
	stx   glb_old_camera_x_pos0
	bra   @end
@endx1 	ldd   <glb_camera_y_pos
@endy1	std   glb_old_camera_y_pos1
	stx   glb_old_camera_x_pos1
@end

	; Force sprite to be refreshed when background changes
	; ----------------------------------------------------
	lda   #1
	sta   <glb_force_sprite_refresh
	sta   glb_camera_move
	rts

glb_old_camera_x_pos0 fdb   -1
glb_old_camera_x_pos1 fdb   -1
glb_old_camera_y_pos0 fdb   -1
glb_old_camera_y_pos1 fdb   -1