* ---------------------------------------------------------------------------
* Constants
*
* Naming convention
* -----------------
* - lower case
* - underscore-separated names
*
* ---------------------------------------------------------------------------

* ===========================================================================
* TO8 Registers
* ===========================================================================

; Disk routine registers (ROM)

dk_drive                      equ $6049
dk_track                      equ $604A
dk_track_lsb                  equ $604B
dk_sector                     equ $604C
dk_write_location             equ $604F

* ===========================================================================
* Globals
* ===========================================================================

glb_direct_page               equ $9F    ; direct page for globals

; compilated sprite
glb_register_s                equ $9FFE  ; reverved space to store S from ROM routines

; DrawSprites
glb_screen_location_1         equ $9FFC  ; start address for rendering of current sprite Part1     
glb_screen_location_2         equ $9FFA  ; start address for rendering of current sprite Part2 (Must follow Part1)

; CheckSpritesRefresh
glb_cur_priority              equ $9FF9
glb_cur_ptr_sub_obj_erase     equ $9FF7
glb_cur_ptr_sub_obj_draw      equ $9FF5
glb_camera_x_pos              equ $9FF3 ; camera x position in palyfield coordinates
glb_camera_y_pos              equ $9FF1 ; camera y position in palyfield coordinates
glb_force_sprite_refresh      equ $9FF0
glb_w_var_0                   equ $9FEE

glb_system_stack              equ $9FEE

* ===========================================================================
* Display Constants
* ===========================================================================

screen_width                  equ 160    ; in pixel
screen_top                    equ 28     ; in pixel
screen_bottom                 equ 28+199 ; in pixel
screen_left                   equ 48     ; in pixel
screen_right                  equ 48+159 ; in pixel
nb_priority_levels            equ 8      ; number of priority levels (need code change if modified)

* ===========================================================================
* Images Constants
* ===========================================================================

image_x_size                  equ 4
image_y_size                  equ 5
image_center_offset           equ 6

image_subset_x1_offset        equ 4
image_subset_y1_offset        equ 5

page_draw_routine             equ 0
draw_routine                  equ 1
page_erase_routine            equ 3
erase_routine                 equ 4
erase_nb_cell                 equ 6

* ===========================================================================
* Sound Constants
* ===========================================================================

sound_page        equ 0
sound_start_addr  equ 1
sound_end_addr    equ 3
sound_meta_size   equ 5

* ===========================================================================
* Object Constants
* ===========================================================================

object_core_size              equ 93  ; the size of an object without ext_vars - DEPENDENCY ClearObj routine
object_size                   equ object_core_size+ext_variables_size ; the size of a dynamic object
next_object                   equ object_size
ext_variables                 equ object_core_size ; start of reserved space for additionnal variables

id                            equ 0           ; reference to object model id (ObjID_) (0: free slot)
subtype                       equ 1           ; reference to object subtype (Sub_)
render_flags                  equ 2

* --- render_flags bitfield variables ---
render_xmirror_mask           equ $01 ; (bit 0) DEPENDENCY should be bit 0 - tell display engine to mirror sprite on horizontal axis
render_ymirror_mask           equ $02 ; (bit 1) DEPENDENCY should be bit 1 - tell display engine to mirror sprite on vertical axis
render_overlay_mask           equ $04 ; (bit 2) DEPENDENCY should be bit 2 - compilated sprite with no background save
render_motionless_mask        equ $08 ; (bit 3) tell display engine to compute sub image and position check only once until the flag is removed  
render_playfieldcoord_mask    equ $10 ; (bit 4) tell display engine to use playfield (1) or screen (0) coordinates
render_hide_mask              equ $20 ; (bit 5) tell display engine to hide sprite (keep priority and mapping_frame)
render_todelete_mask          equ $40 ; (bit 6) tell display engine to delete sprite and clear OST for this object
render_xloop_mask             equ $80 ; (bit 7) (screen coordinate) tell display engine to hide sprite when x is out of screen (0) or to display (1)  
 
priority                      equ 3           ; display priority (0: nothing to display, 1:front, ..., 8:back)
anim                          equ 4  ; and 5  ; reference to current animation (Ani_)
prev_anim                     equ 6  ; and 7  ; reference to previous animation (Ani_)
anim_frame                    equ 8           ; index of current frame in animation
anim_frame_duration           equ 9           ; number of frames for each image in animation, range: 00-7F (0-127), 0 means display only during one frame
anim_flags                    equ 10          ; byte offset to reference an anim_flags LUT (adv) / store a link flag (non adv)

* --- anim_flags bitfield variables ---
anim_link_mask                equ $01 ; (bit 0) if set, allow the load of a new animation without reseting anim_frame and anim_frame_duration

status_flags                  equ 11          ; orientation of sprite, is applied to animation xmirror flag during AnimateSprite

* --- status_flags bitfield variables ---
status_xflip_mask             equ $01 ; (bit 0) X Flip
status_yflip_mask             equ $02 ; (bit 1) Y Flip

image_set                     equ 12 ; and 13 ; reference to current image (Img_) (0000 if no image)
x_pos                         equ 14 ; and 15 ; x playfield coordinate
x_sub                         equ 16          ; x subpixel (1/256 of a pixel), must follow x_pos in data structure
y_pos                         equ 17 ; and 18 ; y playfield coordinate
y_sub                         equ 19          ; y subpixel (1/256 of a pixel), must follow y_pos in data structure
xy_pixel                      equ 20          ; x and y screen coordinate
x_pixel                       equ 20          ; x screen coordinate
y_pixel                       equ 21          ; y screen coordinate, must follow x_pixel
;x_offset                      equ 93          ; x screen coordinate offset that is applied at rendering
;y_offset                      equ 94          ; x screen coordinate offset that is applied at rendering
x_vel                         equ 22 ; and 23 ; horizontal velocity
y_vel                         equ 24 ; and 25 ; vertical velocity
x_acl                         equ 26 ; and 27 ; horizontal gravity
y_acl                         equ 28 ; and 29 ; vertical gravity
routine                       equ 30          ; index of current object routine
routine_secondary             equ 31          ; index of current secondary routine
routine_tertiary              equ 32          ; index of current tertiary routine
routine_quaternary            equ 33          ; index of current quaternary routine

* ---------------------------------------------------------------------------
* reserved variables (update by engine)

rsv_render_flags              equ 34

* --- rsv_render_flags bitfield variables ---
rsv_render_checkrefresh_mask  equ $01 ; (bit 0) if erasesprite and display sprite flag are processed for this frame
rsv_render_erasesprite_mask   equ $02 ; (bit 1) if a sprite need to be cleared on screen
rsv_render_displaysprite_mask equ $04 ; (bit 2) if a sprite need to be rendered on screen
rsv_render_outofrange_mask    equ $08 ; (bit 3) if a sprite is out of range for full rendering in screen
rsv_render_onscreen_mask      equ $80 ; (bit 7) DEPENDENCY should be bit 7 - has been rendered on last screen buffer (may be 0 or 1)

rsv_prev_anim                 equ 35 ; and 36 ; reference to previous animation (Ani_) w * UTILE ?
rsv_image_center_offset       equ 37 ; 0 or 1 offset that indicate if image center is even or odd (DRS_XYToAddress)
rsv_image_subset              equ 38 ; and 39 ; reference to current image regarding mirror flags w
rsv_mapping_frame             equ 40 ; and 41 ; reference to current image regarding mirror flags, overlay flag and x precision w
rsv_erase_nb_cell             equ 42 ; b 
rsv_page_draw_routine         equ 43 ; b
rsv_draw_routine              equ 44 ; and 45 ; w
rsv_page_erase_routine        equ 46 ; b
rsv_erase_routine             equ 47 ; and 48 ; w 
rsv_xy1_pixel                 equ 49 ;
rsv_x1_pixel                  equ 49 ; x+x_offset-(x_size/2) screen coordinate
rsv_y1_pixel                  equ 50 ; y+y_offset-(y_size/2) screen coordinate, must follow rsv_x1_pixel
rsv_xy2_pixel                 equ 51 ;
rsv_x2_pixel                  equ 51 ; x+x_offset+(x_size/2) screen coordinate
rsv_y2_pixel                  equ 52 ; y+y_offset+(y_size/2) screen coordinate, must follow rsv_x2_pixel

* ---------------------------------------------------------------------------
* reserved variables (engine) - buffer specific

rsv_buffer_0                  equ 53 ; Start index of buffer 0 variables
rsv_priority_0                equ 53 ; internal value that hold priority in video buffer 0
rsv_priority_prev_obj_0       equ 54 ; and 55 ; previous object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_priority_next_obj_0       equ 56 ; and 57 ; next object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_prev_mapping_frame_0      equ 58 ; and 59 ; reference to previous image in video buffer 0 w
rsv_prev_erase_nb_cell_0      equ 60 : b
rsv_prev_page_erase_routine_0 equ 61 ; b
rsv_prev_erase_routine_0      equ 62 ; and 63 ; w
rsv_bgdata_0                  equ 64 ; and 65 ; address of background data in screen 0 w
rsv_prev_xy_pixel_0           equ 66 ;
rsv_prev_x_pixel_0            equ 66 ; previous x screen coordinate b
rsv_prev_y_pixel_0            equ 67 ; previous y screen coordinate b, must follow x_pixel
rsv_prev_xy1_pixel_0          equ 68 ;
rsv_prev_x1_pixel_0           equ 68 ; previous x+x_offset-(x_size/2) screen coordinate b
rsv_prev_y1_pixel_0           equ 69 ; previous y+y_offset-(y_size/2) screen coordinate b, must follow x1_pixel
rsv_prev_xy2_pixel_0          equ 70 ;
rsv_prev_x2_pixel_0           equ 70 ; previous x+x_offset+(x_size/2) screen coordinate b
rsv_prev_y2_pixel_0           equ 71 ; previous y+y_offset+(y_size/2) screen coordinate b, must follow x2_pixel
rsv_prev_render_flags_0       equ 72 ;
* --- rsv_prev_render_flags_0 bitfield variables ---
rsv_prev_render_overlay_mask  equ $01 ; (bit 0) if a sprite has been rendered with compilated sprite and no background save on screen buffer 0/1
rsv_prev_render_onscreen_mask equ $80 ; (bit 7) DEPENDENCY should be bit 7 - has been rendered on screen buffer 0/1

rsv_buffer_1                  equ 73 ; Start index of buffer 1 variables
rsv_priority_1                equ 73 ; internal value that hold priority in video buffer 1
rsv_priority_prev_obj_1       equ 74 ; and 75 ; previous object (OST address) in display priority list for video buffer 1 (0000 if none) w
rsv_priority_next_obj_1       equ 76 ; and 77 ; next object (OST address) in display priority list for video buffer 1 (0000 if none) w
rsv_prev_mapping_frame_1      equ 78 ; and 79 ; reference to previous image in video buffer 1 w
rsv_prev_erase_nb_cell_1      equ 80 ; b
rsv_prev_page_erase_routine_1 equ 81 ; b
rsv_prev_erase_routine_1      equ 82 ; and 83 ; w
rsv_bgdata_1                  equ 84 ; and 85 ; address of background data in screen 1 w
rsv_prev_xy_pixel_1           equ 86 ;
rsv_prev_x_pixel_1            equ 86 ; previous x screen coordinate b
rsv_prev_y_pixel_1            equ 87 ; previous y screen coordinate b, must follow x_pixel
rsv_prev_xy1_pixel_1          equ 88 ;
rsv_prev_x1_pixel_1           equ 88 ; previous x+x_size screen coordinate b
rsv_prev_y1_pixel_1           equ 89 ; previous y+y_size screen coordinate b, must follow x_pixel
rsv_prev_xy2_pixel_1          equ 90 ;
rsv_prev_x2_pixel_1           equ 90 ; previous x+x_size screen coordinate b
rsv_prev_y2_pixel_1           equ 91 ; previous y+y_size screen coordinate b, must follow x_pixel
rsv_prev_render_flags_1       equ 92 ;

buf_priority                  equ 0  ; offset for each rsv_buffer variables
buf_priority_prev_obj         equ 1  ;
buf_priority_next_obj         equ 3  ;
buf_prev_mapping_frame        equ 5  ;
buf_erase_nb_cell             equ 7  ;
buf_page_erase_routine        equ 8 ;
buf_erase_routine             equ 9 ;
buf_bgdata                    equ 11 ;
buf_prev_xy_pixel             equ 13 ;
buf_prev_x_pixel              equ 13 ;
buf_prev_y_pixel              equ 14 ;
buf_prev_xy1_pixel            equ 15 ;
buf_prev_x1_pixel             equ 15 ;
buf_prev_y1_pixel             equ 16 ;
buf_prev_xy2_pixel            equ 17 ;
buf_prev_x2_pixel             equ 17 ;
buf_prev_y2_pixel             equ 18 ;
buf_prev_render_flags         equ 19 ;
