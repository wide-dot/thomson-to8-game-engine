
        ldd   #0

; compilated sprite
        std   glb_register_s

; DrawSprites
        std   glb_screen_location_1
        std   glb_screen_location_2

; CheckSpritesRefresh
        std   glb_cur_priority         
        std   glb_cur_ptr_sub_obj_erase
        std   glb_cur_ptr_sub_obj_draw 
        std   glb_camera_x_pos         
        std   glb_camera_y_pos         
	sta   glb_force_sprite_refresh
	sta   glb_camera_move