* ---------------------------------------------------------------------------
* Constants
*
* Naming convention
* -----------------
* - lower case
* - underscore-separated names
*
* ---------------------------------------------------------------------------

HalfPipe_Img_z_depth  equ 4 ; number of z pos increment into a single image 

* ===========================================================================
* Object Constants
* ===========================================================================

ss_z_pos                      equ ext_variables    ; and ext_variables+1 ; and ext_variables+2 ; first byte is always 0, distance from camera to half-pipe segment end (0: front)
ss_parent                     equ ext_variables+3  ; and ext_variables+4  ; object ptr to child or parent (0: front)
ss_shadow_tilt                equ ext_variables+5  ; 0:flat 1:diagonal 2:side
ss_self_delete                equ ext_variables+6  ; flag usually set by parent to tell to child to self delete
collision_property            equ ext_variables+7
mapping_frame                 equ ext_variables+8
ss_z_pos_img_start            equ ext_variables+9  ; and ext_variables+10  ; distance from camera to half-pipe segment end (0: front) at start of last image

;ss_dplc_timer = $23
;ss_x_pos = objoff_2A
;ss_x_sub = objoff_2C
;ss_y_pos = objoff_2E
;ss_y_sub = objoff_30
;ss_init_flip_timer = objoff_32
;ss_flip_timer = objoff_33
;ss_z_pos = objoff_34
;ss_hurt_timer = objoff_36
;ss_slide_timer = objoff_37
;ss_parent = objoff_38
;ss_rings_base = objoff_3C	; word
;ss_rings_hundreds = objoff_3C
;ss_rings_tens = objoff_3D
;ss_rings_units = objoff_3E
;ss_last_angle_index = objoff_3F