* ---------------------------------------------------------------------------
* Constants
*
* Naming convention
* -----------------
* - lower case
* - underscore-separated names
*
* ---------------------------------------------------------------------------

 ifndef CONSTANTS_ASM
CONSTANTS_ASM equ 1

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

; WARNING - BuildSprite allow to cross $A000 limit by glb_camera_x_offset/4
; Graphics routines using S to write may cross by 12 bytes
; be sure to compile with enough margin here
glb_ram_end                   equ $A000-12

; compilated sprite
glb_register_s                equ glb_ram_end-2             ; reverved space to store S from ROM routines

; DrawSprites
glb_screen_location_1         equ glb_register_s-2          ; start address for rendering of current sprite Part1     
glb_screen_location_2         equ glb_screen_location_1-2   ; start address for rendering of current sprite Part2 (DEPENDENCY Must follow Part1)

glb_camera_height             equ glb_screen_location_2-2
glb_camera_width              equ glb_camera_height-2
glb_camera_x_pos_coarse       equ glb_camera_width-2        ; ((glb_camera_x_pos - 64) / 64) * 64
glb_camera_x_pos              equ glb_camera_x_pos_coarse-2 ; 16.8 camera x position in palyfield coordinates
glb_camera_x_sub              equ glb_camera_x_pos-1        ; 
glb_camera_y_pos              equ glb_camera_x_pos-2        ; 16.8 camera y position in palyfield coordinates
glb_camera_y_sub              equ glb_camera_y_pos-1        ;
glb_camera_x_min_pos          equ glb_camera_y_pos-2
glb_camera_y_min_pos          equ glb_camera_x_min_pos-2
glb_camera_x_max_pos          equ glb_camera_y_min_pos-2
glb_camera_y_max_pos          equ glb_camera_x_max_pos-2
glb_camera_x_offset           equ glb_camera_y_max_pos-2
glb_camera_y_offset           equ glb_camera_x_offset-2
glb_force_sprite_refresh      equ glb_camera_y_offset-1
glb_camera_move               equ glb_force_sprite_refresh-1
glb_alphaTiles                equ glb_camera_move-1
glb_timer_second              equ glb_alphaTiles-1
glb_timer_minute              equ glb_timer_second-1
glb_timer                     equ glb_timer_minute
glb_timer_frame               equ glb_timer-1

; BankSwitch
glb_Page                      equ glb_timer_frame-1
dp_engine                     equ glb_Page-30  ; engine routines tmp var space
dp_extreg                     equ dp_engine-28 ; extra register space (user and engine common)
dp                            equ $9F00        ; user space (149 bytes max)
glb_system_stack              equ dp

; generic direct page extra registers
; -----------------------------------
glb_d0   equ   dp_extreg
glb_d0_b equ   dp_extreg+1
; must be a free byte here for 24bits computation
glb_d1   equ   dp_extreg+3
glb_d1_b equ   dp_extreg+4
; must be a free byte here for 24bits computation
glb_d2   equ   dp_extreg+6
glb_d2_b equ   dp_extreg+7
; must be a free byte here for 24bits computation
glb_d3   equ   dp_extreg+9
glb_d3_b equ   dp_extreg+10
; must be a free byte here for 24bits computation
glb_d4   equ   dp_extreg+12
glb_d4_b equ   dp_extreg+13
glb_d5   equ   dp_extreg+14
glb_d5_b equ   dp_extreg+15
glb_d6   equ   dp_extreg+16
glb_d6_b equ   dp_extreg+17
glb_a0   equ   dp_extreg+18
glb_a0_b equ   dp_extreg+19
glb_a1   equ   dp_extreg+20
glb_a1_b equ   dp_extreg+21
glb_a2   equ   dp_extreg+22
glb_a2_b equ   dp_extreg+23
glb_a3   equ   dp_extreg+24
glb_a3_b equ   dp_extreg+25
glb_a4   equ   dp_extreg+26
glb_a4_b equ   dp_extreg+27

* ===========================================================================
* Display Constants
* ===========================================================================

screen_width                  equ 160             ; in pixel
screen_height                 equ 200             ; in pixel
screen_top                    equ (256-200)/2     ; in pixel
screen_bottom                 equ screen_top+199  ; in pixel
screen_left                   equ (256-160)/2     ; in pixel
screen_right                  equ screen_left+159 ; in pixel
nb_priority_levels            equ 8               ; number of priority levels (need code change if modified)

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

; ext_variables_size should be declared in game source code

object_base_size              equ 38  ; the size of an object without rsvd and ext_vars
 ifndef OverlayMode
object_rsvd_size              equ 59
 else
object_rsvd_size              equ 5
 endc

object_rsvd                   equ object_base_size+ext_variables_size
object_size                   equ object_base_size+ext_variables_size+object_rsvd_size ; the size of a dynamic object
next_object                   equ object_size
ext_variables                 equ object_base_size ; start of reserved space for additionnal variables

id                            equ 0   ; reference to object model id (ObjID_) (0: free slot)
subtype                       equ 1   ; reference to object subtype (Sub_) DEPENDENCY subtype must follow id
render_flags                  equ 2
run_object_prev               equ 3   ; previous object to update when deleting current object
run_object_next               equ 5   ; next object to run by RunObjects

 ifndef OverlayMode
* --- render_flags bitfield variables --- background erase pack
render_xmirror_mask           equ $01 ; (bit 0) DEPENDENCY should be bit 0 - tell display engine to mirror sprite on horizontal axis
render_ymirror_mask           equ $02 ; (bit 1) DEPENDENCY should be bit 1 - tell display engine to mirror sprite on vertical axis
render_overlay_mask           equ $04 ; (bit 2) DEPENDENCY should be bit 2 - compilated sprite with no background save
render_playfieldcoord_mask    equ $08 ; (bit 3) tell display engine to use playfield (1) or screen (0) coordinates
render_xloop_mask             equ $10 ; (bit 4) (in screen coordinate) tell display engine to hide sprite when x is out of screen (0) or to display (1)  
render_todelete_mask          equ $20 ; (bit 5) tell display engine to delete sprite and clear OST for this object
render_subobjects_mask        equ $40 ; (bit 6) tell display engine to render subobjects for this object
render_hide_mask              equ $80 ; (bit 7) tell display engine to hide sprite (keep priority and mapping_frame)
 else
; --- render_flags bitfield variables --- overlay pack
render_xmirror_mask           equ $01 ; (bit 0) DEPENDENCY should be bit 0 - tell display engine to mirror sprite on horizontal axis
render_ymirror_mask           equ $02 ; (bit 1) DEPENDENCY should be bit 1 - tell display engine to mirror sprite on vertical axis

render_playfieldcoord_mask    equ $08 ; (bit 3) tell display engine to use playfield (1) or screen (0) coordinates
render_xloop_mask             equ $10 ; (bit 4) (in screen coordinate) tell display engine to hide sprite when x is out of screen (0) or to display (1)  
render_no_range_ctrl_mask     equ $20 ; (bit 5) tell display engine to skip out of range controls (this may lead to memory corruption BEWARE)
render_subobjects_mask        equ $40 ; (bit 6) tell display engine to render subobjects for this object
render_hide_mask              equ $80 ; (bit 7) tell display engine to hide sprite (keep priority and mapping_frame)
 endc

priority                      equ 7           ; display priority (0: nothing to display, 1:front, ..., 8:back)
anim                          equ 8  ; and 9  ; reference to current animation (Ani_)
prev_anim                     equ 10 ; and 11 ; reference to previous animation (Ani_)
sub_anim                      equ 10 ; and 11 ; reference to sub animation
anim_frame                    equ 12          ; index of current frame in animation
anim_frame_duration           equ 13          ; number of frames for each image in animation, range: 00-7F (0-127), 0 means display only during one frame
anim_flags                    equ 14          ; byte offset to reference an anim_flags LUT (adv) / store a link flag (non adv)

* --- anim_flags bitfield variables ---
anim_link_mask                equ $01 ; (bit 0) if set, allow the load of a new animation without reseting anim_frame and anim_frame_duration

status_flags                  equ 14          ; orientation of sprite, is applied to animation xmirror flag during AnimateSprite

* --- status_flags bitfield variables ---
status_xflip_mask             equ $01 ; (bit 0) X Flip
status_yflip_mask             equ $02 ; (bit 1) Y Flip

image_set                     equ 16 ; and 17 ; reference to current image (Img_) (0000 if no image)
x_pos                         equ 18 ; and 19 ; x playfield coordinate
x_sub                         equ 20          ; x subpixel (1/256 of a pixel), must follow x_pos in data structure
y_pos                         equ 21 ; and 22 ; y playfield coordinate
y_sub                         equ 23          ; y subpixel (1/256 of a pixel), must follow y_pos in data structure
xy_pixel                      equ 24          ; x and y screen coordinate
x_pixel                       equ 24          ; x screen coordinate
y_pixel                       equ 25          ; y screen coordinate, must follow x_pixel
x_vel                         equ 26 ; and 27 ; s8.8 horizontal velocity
y_vel                         equ 28 ; and 29 ; s8.8 vertical velocity
x_acl                         equ 30 ; and 31 ; s8.8 horizontal gravity
y_acl                         equ 32 ; and 33 ; s8.8 vertical gravity
routine                       equ 34          ; index of current object routine
routine_secondary             equ 35          ; index of current secondary routine
routine_tertiary              equ 36          ; index of current tertiary routine
routine_quaternary            equ 37          ; index of current quaternary routine

 ifndef OverlayMode
* ---------------------------------------------------------------------------
* reserved variables (read/write by engine)

rsv_render_flags              equ object_rsvd

* --- rsv_render_flags bitfield variables ---
rsv_render_checkrefresh_mask  equ $01 ; (bit 0) if erasesprite and display sprite flag are processed for this frame
rsv_render_erasesprite_mask   equ $02 ; (bit 1) if a sprite need to be cleared on screen
rsv_render_displaysprite_mask equ $04 ; (bit 2) if a sprite need to be rendered on screen
rsv_render_outofrange_mask    equ $08 ; (bit 3) if a sprite is out of range for full rendering in screen
rsv_render_onscreen_mask      equ $80 ; (bit 7) DEPENDENCY should be bit 7 - has been rendered on last screen buffer (may be 0 or 1)

rsv_prev_anim                 equ object_rsvd+1 ; and +2 ; reference to previous animation (Ani_) w * UTILE ?
rsv_image_center_offset       equ object_rsvd+3 ; 0 or 1 offset that indicate if image center is even or odd (DRS_XYToAddress)
rsv_image_subset              equ object_rsvd+4 ; and +5 ; reference to current image regarding mirror flags w
rsv_mapping_frame             equ object_rsvd+6 ; and +7 ; reference to current image regarding mirror flags, overlay flag and x precision w
rsv_erase_nb_cell             equ object_rsvd+8 ; b 
rsv_page_draw_routine         equ object_rsvd+9 ; b
rsv_draw_routine              equ object_rsvd+10 ; and +11 ; w
rsv_page_erase_routine        equ object_rsvd+12 ; b
rsv_erase_routine             equ object_rsvd+13 ; and +14 ; w 
rsv_xy1_pixel                 equ object_rsvd+15 ;
rsv_x1_pixel                  equ object_rsvd+15 ; x+x_offset-(x_size/2) screen coordinate
rsv_y1_pixel                  equ object_rsvd+16 ; y+y_offset-(y_size/2) screen coordinate, must follow rsv_x1_pixel
rsv_xy2_pixel                 equ object_rsvd+17 ;
rsv_x2_pixel                  equ object_rsvd+17 ; x+x_offset+(x_size/2) screen coordinate
rsv_y2_pixel                  equ object_rsvd+18 ; y+y_offset+(y_size/2) screen coordinate, must follow rsv_x2_pixel

* ---------------------------------------------------------------------------
* reserved variables (engine) - buffer specific

rsv_buffer_0                  equ object_rsvd+19 ; Start index of buffer 0 variables
rsv_priority_0                equ object_rsvd+19 ; internal value that hold priority in video buffer 0
rsv_priority_prev_obj_0       equ object_rsvd+20 ; and +21 ; previous object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_priority_next_obj_0       equ object_rsvd+22 ; and +23 ; next object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_prev_mapping_frame_0      equ object_rsvd+24 ; and +25 ; reference to previous image in video buffer 0 w
rsv_prev_erase_nb_cell_0      equ object_rsvd+26 : b
rsv_prev_page_erase_routine_0 equ object_rsvd+27 ; b
rsv_prev_erase_routine_0      equ object_rsvd+28 ; and +29 ; w
rsv_bgdata_0                  equ object_rsvd+30 ; and +31 ; address of background data in screen 0 w
rsv_prev_xy_pixel_0           equ object_rsvd+32 ;
rsv_prev_x_pixel_0            equ object_rsvd+32 ; previous x screen coordinate b
rsv_prev_y_pixel_0            equ object_rsvd+33 ; previous y screen coordinate b, must follow x_pixel
rsv_prev_xy1_pixel_0          equ object_rsvd+34 ;
rsv_prev_x1_pixel_0           equ object_rsvd+34 ; previous x+x_offset-(x_size/2) screen coordinate b
rsv_prev_y1_pixel_0           equ object_rsvd+35 ; previous y+y_offset-(y_size/2) screen coordinate b, must follow x1_pixel
rsv_prev_xy2_pixel_0          equ object_rsvd+36 ;
rsv_prev_x2_pixel_0           equ object_rsvd+36 ; previous x+x_offset+(x_size/2) screen coordinate b
rsv_prev_y2_pixel_0           equ object_rsvd+37 ; previous y+y_offset+(y_size/2) screen coordinate b, must follow x2_pixel
rsv_prev_render_flags_0       equ object_rsvd+38 ;
* --- rsv_prev_render_flags_0 bitfield variables ---
rsv_prev_render_overlay_mask  equ $01 ; (bit 0) if a sprite has been rendered with compilated sprite and no background save on screen buffer 0/1
rsv_prev_render_onscreen_mask equ $80 ; (bit 7) DEPENDENCY should be bit 7 - has been rendered on screen buffer 0/1

rsv_buffer_1                  equ object_rsvd+39 ; Start index of buffer 1 variables
rsv_priority_1                equ object_rsvd+39 ; internal value that hold priority in video buffer 1
rsv_priority_prev_obj_1       equ object_rsvd+40 ; and +41 ; previous object (OST address) in display priority list for video buffer 1 (0000 if none) w
rsv_priority_next_obj_1       equ object_rsvd+42 ; and +43 ; next object (OST address) in display priority list for video buffer 1 (0000 if none) w
rsv_prev_mapping_frame_1      equ object_rsvd+44 ; and +45 ; reference to previous image in video buffer 1 w
rsv_prev_erase_nb_cell_1      equ object_rsvd+46 ; b
rsv_prev_page_erase_routine_1 equ object_rsvd+47 ; b
rsv_prev_erase_routine_1      equ object_rsvd+48 ; and +49 ; w
rsv_bgdata_1                  equ object_rsvd+50 ; and +51 ; address of background data in screen 1 w
rsv_prev_xy_pixel_1           equ object_rsvd+52 ;
rsv_prev_x_pixel_1            equ object_rsvd+52 ; previous x screen coordinate b
rsv_prev_y_pixel_1            equ object_rsvd+53 ; previous y screen coordinate b, must follow x_pixel
rsv_prev_xy1_pixel_1          equ object_rsvd+54 ;
rsv_prev_x1_pixel_1           equ object_rsvd+54 ; previous x+x_size screen coordinate b
rsv_prev_y1_pixel_1           equ object_rsvd+55 ; previous y+y_size screen coordinate b, must follow x_pixel
rsv_prev_xy2_pixel_1          equ object_rsvd+56 ;
rsv_prev_x2_pixel_1           equ object_rsvd+56 ; previous x+x_size screen coordinate b
rsv_prev_y2_pixel_1           equ object_rsvd+57 ; previous y+y_size screen coordinate b, must follow x_pixel
rsv_prev_render_flags_1       equ object_rsvd+58 ;

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
 else
* ---------------------------------------------------------------------------
* reserved variables (engine) - buffer specific - overlay pack

rsv_priority                  equ object_rsvd   ; internal value that hold priority in video buffer 0
rsv_priority_prev_obj         equ object_rsvd+1 ; and +2 ; previous object (OST address) in display priority list for video buffer 0 (0000 if none) w
rsv_priority_next_obj         equ object_rsvd+3 ; and +4 ; next object (OST address) in display priority list for video buffer 0 (0000 if none) w

; ---------------------------------------------------------------------------
; when childsprites are activated (i.e. bit #6 of render_flags set)
; object_base_size+ext_variables_size should cover at least 7+56 bytes 
; subtype is recovered
mainspr_childsprites    equ   subtype         ; amount of child sprites
mainspr_width           equ   run_object_next+2
mainspr_height          equ   run_object_next+3
mainspr_x_pos           equ   mainspr_height+1
mainspr_y_pos           equ   mainspr_height+3
mainspr_mapframe        equ   mainspr_height+5
sub2_x_pos              equ   mainspr_x_pos+6
sub2_y_pos              equ   mainspr_y_pos+6
sub2_mapframe           equ   mainspr_mapframe+6
sub3_x_pos              equ   sub2_x_pos+6
sub3_y_pos              equ   sub2_y_pos+6
sub3_mapframe           equ   sub2_mapframe+6
sub4_x_pos              equ   sub3_x_pos+6
sub4_y_pos              equ   sub3_y_pos+6
sub4_mapframe           equ   sub3_mapframe+6
sub5_x_pos              equ   sub4_x_pos+6
sub5_y_pos              equ   sub4_y_pos+6
sub5_mapframe           equ   sub4_mapframe+6
sub6_x_pos              equ   sub5_x_pos+6
sub6_y_pos              equ   sub5_y_pos+6
sub6_mapframe           equ   sub5_mapframe+6
sub7_x_pos              equ   sub6_x_pos+6
sub7_y_pos              equ   sub6_y_pos+6
sub7_mapframe           equ   sub6_mapframe+6
sub8_x_pos              equ   sub7_x_pos+6
sub8_y_pos              equ   sub7_y_pos+6
sub8_mapframe           equ   sub7_mapframe+6
sub9_x_pos              equ   sub8_x_pos+6
sub9_y_pos              equ   sub8_y_pos+6
sub9_mapframe           equ   sub8_mapframe+6
next_subspr             equ   6 ; size of a subsprite data
 endc
 endc