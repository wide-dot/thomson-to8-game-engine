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

glb_system_stack              equ $9FFA
glb_screen_location_1         equ $9FFA  ; start address for rendering of current sprite Part1     
glb_screen_location_2         equ $9FFC  ; start address for rendering of current sprite Part2 (Must follow Part1)
glb_register_s                equ $9FFE  ; reverved space to store S from ROM routines

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

object_size                   equ 114 ; the size of an object - DEPENDENCY ClearObj routine
next_object                   equ object_size

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
anim_link                     equ 10          ; allow animation swap without reseting anim_frame and duration
image_set                     equ 11 ; and 12 ; reference to current image (Img_) (0000 if no image)
x_pos                         equ 13 ; and 14 ; x playfield coordinate
x_sub                         equ 15          ; x subpixel (1/256 of a pixel), must follow x_pos in data structure
y_pos                         equ 16 ; and 17 ; y playfield coordinate
y_sub                         equ 18          ; y subpixel (1/256 of a pixel), must follow y_pos in data structure
xy_pixel                      equ 19          ; x and y screen coordinate
x_pixel                       equ 19          ; x screen coordinate
y_pixel                       equ 20          ; y screen coordinate, must follow x_pixel
x_vel                         equ 21 ; and 22 ; horizontal velocity
y_vel                         equ 23 ; and 24 ; vertical velocity
routine                       equ 25          ; index of current object routine
routine_secondary             equ 26          ; index of current secondary routine
routine_tertiary              equ 27          ; index of current tertiary routine
routine_quaternary            equ 28          ; index of current quaternary routine

ext_variables                 equ 88 ; to 113 ; reserved space for additionnal variables (25 bytes)

* ---------------------------------------------------------------------------
* reserved variables (engine)

rsv_render_flags              equ 29

* --- rsv_render_flags bitfield variables ---
rsv_render_checkrefresh_mask  equ $01 ; (bit 0) if erasesprite and display sprite flag are processed for this frame
rsv_render_erasesprite_mask   equ $02 ; (bit 1) if a sprite need to be cleared on screen
rsv_render_displaysprite_mask equ $04 ; (bit 2) if a sprite need to be rendered on screen
rsv_render_outofrange_mask    equ $08 ; (bit 3) if a sprite is out of range for full rendering in screen
rsv_render_onscreen_mask      equ $80 ; (bit 7) DEPENDENCY should be bit 7 - has been rendered on last screen buffer (may be 0 or 1)

rsv_prev_anim                 equ 30 ; and 31 ; reference to previous animation (Ani_) w * UTILE ?
rsv_image_center_offset       equ 32 ; 0 or 1 offset that indicate if image center is even or odd (DRS_XYToAddress)
rsv_image_subset              equ 33 ; and 34 ; reference to current image regarding mirror flags w
rsv_mapping_frame             equ 35 ; and 36 ; reference to current image regarding mirror flags, overlay flag and x precision w
rsv_erase_nb_cell             equ 37 ; b 
rsv_page_draw_routine         equ 38 ; b
rsv_draw_routine              equ 39 ; and 40 ; w
rsv_page_erase_routine        equ 41 ; b
rsv_erase_routine             equ 42 ; and 43 ; w 
rsv_xy1_pixel                 equ 44 ;
rsv_x1_pixel                  equ 44 ; x+x_offset-(x_size/2) screen coordinate
rsv_y1_pixel                  equ 45 ; y+y_offset-(y_size/2) screen coordinate, must follow rsv_x1_pixel
rsv_xy2_pixel                 equ 46 ;
rsv_x2_pixel                  equ 46 ; x+x_offset+(x_size/2) screen coordinate
rsv_y2_pixel                  equ 47 ; y+y_offset+(y_size/2) screen coordinate, must follow rsv_x2_pixel

* ---------------------------------------------------------------------------
* reserved variables (engine) - buffer specific

rsv_buffer_0                  equ 48 ; Start index of buffer 0 variables
rsv_priority_0                equ 48 ; internal value that hold priority in video buffer 0
rsv_priority_prev_obj_0       equ 49 ; and 50 ; previous object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_priority_next_obj_0       equ 51 ; and 52 ; next object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_prev_mapping_frame_0      equ 53 ; and 54 ; reference to previous image in video buffer 0 w
rsv_prev_erase_nb_cell_0      equ 55 : b
rsv_prev_page_erase_routine_0 equ 56 ; b
rsv_prev_erase_routine_0      equ 57 ; and 58 ; w
rsv_bgdata_0                  equ 59 ; and 60 ; address of background data in screen 0 w
rsv_prev_xy_pixel_0           equ 61 ;
rsv_prev_x_pixel_0            equ 61 ; previous x screen coordinate b
rsv_prev_y_pixel_0            equ 62 ; previous y screen coordinate b, must follow x_pixel
rsv_prev_xy1_pixel_0          equ 63 ;
rsv_prev_x1_pixel_0           equ 63 ; previous x+x_offset-(x_size/2) screen coordinate b
rsv_prev_y1_pixel_0           equ 64 ; previous y+y_offset-(y_size/2) screen coordinate b, must follow x1_pixel
rsv_prev_xy2_pixel_0          equ 65 ;
rsv_prev_x2_pixel_0           equ 65 ; previous x+x_offset+(x_size/2) screen coordinate b
rsv_prev_y2_pixel_0           equ 66 ; previous y+y_offset+(y_size/2) screen coordinate b, must follow x2_pixel
rsv_prev_render_flags_0       equ 67 ;
* --- rsv_prev_render_flags_0 bitfield variables ---
rsv_prev_render_overlay_mask  equ $01 ; (bit 0) if a sprite has been rendered with compilated sprite and no background save on screen buffer 0/1
rsv_prev_render_onscreen_mask equ $80 ; (bit 7) DEPENDENCY should be bit 7 - has been rendered on screen buffer 0/1

rsv_buffer_1                  equ 68 ; Start index of buffer 1 variables
rsv_priority_1                equ 68 ; internal value that hold priority in video buffer 1
rsv_priority_prev_obj_1       equ 69 ; and 70 ; previous object (OST address) in display priority list for video buffer 1 (0000 if none) w
rsv_priority_next_obj_1       equ 71 ; and 72 ; next object (OST address) in display priority list for video buffer 1 (0000 if none) w
rsv_prev_mapping_frame_1      equ 73 ; and 74 ; reference to previous image in video buffer 1 w
rsv_prev_erase_nb_cell_1      equ 75 ; b
rsv_prev_page_erase_routine_1 equ 76 ; b
rsv_prev_erase_routine_1      equ 77 ; and 78 ; w
rsv_bgdata_1                  equ 79 ; and 80 ; address of background data in screen 1 w
rsv_prev_xy_pixel_1           equ 81 ;
rsv_prev_x_pixel_1            equ 81 ; previous x screen coordinate b
rsv_prev_y_pixel_1            equ 82 ; previous y screen coordinate b, must follow x_pixel
rsv_prev_xy1_pixel_1          equ 83 ;
rsv_prev_x1_pixel_1           equ 83 ; previous x+x_size screen coordinate b
rsv_prev_y1_pixel_1           equ 84 ; previous y+y_size screen coordinate b, must follow x_pixel
rsv_prev_xy2_pixel_1          equ 85 ;
rsv_prev_x2_pixel_1           equ 85 ; previous x+x_size screen coordinate b
rsv_prev_y2_pixel_1           equ 86 ; previous y+y_size screen coordinate b, must follow x_pixel
rsv_prev_render_flags_1       equ 87 ;

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
