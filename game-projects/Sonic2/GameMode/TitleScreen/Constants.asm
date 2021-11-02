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

dk_drive                    equ $6049
dk_track                      equ $604A
dk_track_lsb                     equ $604B
dk_sector                    equ $604C
dk_write_location                equ $604F

* ===========================================================================
* Display Constants
* ===========================================================================

screen_width                  equ 160 ; screen width in pixel
screen_top                    equ 28 ; in pixel
screen_bottom                 equ 28+199 ; in pixel
screen_left                   equ 48 ; in pixel
screen_right                  equ 48+159 ; in pixel
nb_priority_levels            equ 8   ; number of priority levels (need code change if modified)
glb_system_stack               equ $9FFA 
glb_screen_location_1   equ $9FFA  ; start address for rendering of current sprite Part1     
glb_screen_location_2   equ $9FFC  ; start address for rendering of current sprite Part2 (Must follow Part1)
glb_register_s                     equ $9FFE  ; reverved space to store S from ROM routines

* ===========================================================================
* Physics Constants
* ===========================================================================

gravity                       equ $38 ; Gravite: 56 sub-pixels par frame

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

nb_reserved_objects           equ 2
nb_dynamic_objects            equ 38
nb_level_objects              equ 3
nb_graphical_objects                    equ 43 * max 64 total

* ---------------------------------------------------------------------------
* Object Status Table offsets
* ---------------------------------------------------------------------------

object_size                   equ 104 ; the size of an object - DEPENDENCY ClearObj routine
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
image_set                     equ 10 ; and 11 ;reference to current image (Img_) (0000 if no image)
x_pos                         equ 12 ; and 13 ; x playfield coordinate
x_sub                         equ 14          ; x subpixel (1/256 of a pixel), must follow x_pos in data structure
y_pos                         equ 15 ; and 16 ; y playfield coordinate
y_sub                         equ 17          ; y subpixel (1/256 of a pixel), must follow y_pos in data structure
xy_pixel                      equ 18          ; x and y screen coordinate
x_pixel                       equ 18          ; x screen coordinate
y_pixel                       equ 19          ; y screen coordinate, must follow x_pixel
x_vel                         equ 20 ; and 21 ; horizontal velocity
y_vel                         equ 22 ; and 23 ; vertical velocity
routine                       equ 24          ; index of current object routine
routine_secondary             equ 25          ; index of current secondary routine
status                        equ 26 

* --- status bitfield variables for objects ---
status_x_orientation          equ   $01 ; (bit 0) X Orientation. Clear is left and set is right
status_y_orientation          equ   $02 ; (bit 1) Y Orientation. Clear is right-side up, and set is upside-down
status_bit2                   equ   $04 ; (bit 2) Unused
status_mainchar_standing      equ   $08 ; (bit 3) Set if Main character is standing on this object
status_sidekick_standing      equ   $10 ; (bit 4) Set if Sidekick is standing on this object
status_mainchar_pushing       equ   $20 ; (bit 5) Set if Main character is pushing on this object
status_sidekick_pushing       equ   $40 ; (bit 6) Set if Sidekick is pushing on this object
status_bit7                   equ   $80 ; (bit 7) Unused

* --- status bitfield variables for Main characters ---
status_inair                  equ   $02 ; (bit 1) Set if in the air (jump counts)
status_jumporroll             equ   $04 ; (bit 2) Set if jumping or rolling
status_norgroundnorfall       equ   $08 ; (bit 3) Set if isn't on the ground but shouldn't fall. (Usually when he is on a object that should stop him falling, like a platform or a bridge.)
status_jumpingafterrolling    equ   $10 ; (bit 4) Set if jumping after rolling
status_pushing                equ   $20 ; (bit 5) Set if pushing something
status_underwater             equ   $40 ; (bit 6) Set if underwater

angle                         equ 102 ; angle about the z axis (360 degrees = 256)
collision_flags               equ 103 ; Collision response bitfield, tells what the object will do if hit by the character
* --- collision bitfield variables for objects ---
; format TTSS SSSS
; TT is the type of collision - 00 is enemy, 01 sets the routine counter to $4, 10 is harm, and 11 seems to be a special thing for the starpole.
; SSSSSS is the size, lifted from a lookup table in the collision response routine.

inertia                       equ 100 ; and 101 ; directionless representation of speed... not updated in the air
ext_variables                 equ 27  ; to 40   ; reserved space for additionnal variables

* ---------------------------------------------------------------------------
* reserved variables (engine)

rsv_render_flags              equ 41

* --- rsv_render_flags bitfield variables ---
rsv_render_checkrefresh_mask  equ $01 ; (bit 0) if erasesprite and display sprite flag are processed for this frame
rsv_render_erasesprite_mask   equ $02 ; (bit 1) if a sprite need to be cleared on screen
rsv_render_displaysprite_mask equ $04 ; (bit 2) if a sprite need to be rendered on screen
rsv_render_outofrange_mask    equ $08 ; (bit 3) if a sprite is out of range for full rendering in screen
rsv_render_onscreen_mask      equ $80 ; (bit 7) DEPENDENCY should be bit 7 - has been rendered on last screen buffer (may be 0 or 1)

rsv_prev_anim                 equ 42 ; and 43 ; reference to previous animation (Ani_) w * UTILE ?
rsv_image_center_offset       equ 44 ; 0 or 1 offset that indicate if image center is even or odd (DRS_XYToAddress)
rsv_image_subset              equ 45 ; and 46 ; reference to current image regarding mirror flags w
rsv_mapping_frame             equ 47 ; and 48 ; reference to current image regarding mirror flags, overlay flag and x precision w
rsv_erase_nb_cell             equ 49 ; b 
rsv_page_draw_routine         equ 50 ; b
rsv_draw_routine              equ 51 ; and 52 ; w
rsv_page_erase_routine        equ 97 ; b
rsv_erase_routine             equ 98 ; and 99 ; w 
rsv_xy1_pixel                 equ 53 ;
rsv_x1_pixel                  equ 53 ; x+x_offset-(x_size/2) screen coordinate
rsv_y1_pixel                  equ 54 ; y+y_offset-(y_size/2) screen coordinate, must follow rsv_x1_pixel
rsv_xy2_pixel                 equ 55 ;
rsv_x2_pixel                  equ 55 ; x+x_offset+(x_size/2) screen coordinate
rsv_y2_pixel                  equ 56 ; y+y_offset+(y_size/2) screen coordinate, must follow rsv_x2_pixel

* ---------------------------------------------------------------------------
* reserved variables (engine) - buffer specific

rsv_buffer_0                  equ 57 ; Start index of buffer 0 variables
rsv_priority_0                equ 57 ; internal value that hold priority in video buffer 0
rsv_priority_prev_obj_0       equ 58 ; and 59 ; previous object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_priority_next_obj_0       equ 60 ; and 61 ; next object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_prev_mapping_frame_0      equ 62 ; and 63 ; reference to previous image in video buffer 0 w
rsv_prev_erase_nb_cell_0      equ 64 : b
rsv_prev_page_erase_routine_0 equ 65 ; b
rsv_prev_erase_routine_0      equ 66 ; and 67 ; w
rsv_bgdata_0                  equ 68 ; and 69 ; address of background data in screen 0 w
rsv_prev_xy_pixel_0           equ 70 ;
rsv_prev_x_pixel_0            equ 70 ; previous x screen coordinate b
rsv_prev_y_pixel_0            equ 71 ; previous y screen coordinate b, must follow x_pixel
rsv_prev_xy1_pixel_0          equ 72 ;
rsv_prev_x1_pixel_0           equ 72 ; previous x+x_offset-(x_size/2) screen coordinate b
rsv_prev_y1_pixel_0           equ 73 ; previous y+y_offset-(y_size/2) screen coordinate b, must follow x1_pixel
rsv_prev_xy2_pixel_0          equ 74 ;
rsv_prev_x2_pixel_0           equ 74 ; previous x+x_offset+(x_size/2) screen coordinate b
rsv_prev_y2_pixel_0           equ 75 ; previous y+y_offset+(y_size/2) screen coordinate b, must follow x2_pixel
rsv_prev_render_flags_0       equ 76 ;
* --- rsv_prev_render_flags_0 bitfield variables ---
rsv_prev_render_overlay_mask  equ $01 ; (bit 0) if a sprite has been rendered with compilated sprite and no background save on screen buffer 0/1
rsv_prev_render_onscreen_mask equ $80 ; (bit 7) DEPENDENCY should be bit 7 - has been rendered on screen buffer 0/1

rsv_buffer_1                  equ 77 ; Start index of buffer 1 variables
rsv_priority_1                equ 77 ; internal value that hold priority in video buffer 1
rsv_priority_prev_obj_1       equ 78 ; and 79 ; previous object (OST address) in display priority list for video buffer 1 (0000 if none) w
rsv_priority_next_obj_1       equ 80 ; and 81 ; next object (OST address) in display priority list for video buffer 1 (0000 if none) w
rsv_prev_mapping_frame_1      equ 82 ; and 83 ; reference to previous image in video buffer 1 w
rsv_prev_erase_nb_cell_1      equ 84 ; b
rsv_prev_page_erase_routine_1 equ 85 ; b
rsv_prev_erase_routine_1      equ 86 ; and 87 ; w
rsv_bgdata_1                  equ 88 ; and 89 ; address of background data in screen 1 w
rsv_prev_xy_pixel_1           equ 90 ;
rsv_prev_x_pixel_1            equ 90 ; previous x screen coordinate b
rsv_prev_y_pixel_1            equ 91 ; previous y screen coordinate b, must follow x_pixel
rsv_prev_xy1_pixel_1          equ 92 ;
rsv_prev_x1_pixel_1           equ 92 ; previous x+x_size screen coordinate b
rsv_prev_y1_pixel_1           equ 93 ; previous y+y_size screen coordinate b, must follow x_pixel
rsv_prev_xy2_pixel_1          equ 94 ;
rsv_prev_x2_pixel_1           equ 94 ; previous x+x_size screen coordinate b
rsv_prev_y2_pixel_1           equ 95 ; previous y+y_size screen coordinate b, must follow x_pixel
rsv_prev_render_flags_1       equ 96 ;

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