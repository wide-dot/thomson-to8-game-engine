* ===========================================================================
* Object Constants
* ===========================================================================

nb_reserved_objects               equ 0
nb_dynamic_objects                equ 18
nb_level_objects                  equ 1
nb_graphical_objects              equ 20 * max 64 total

* ===========================================================================
* Object Status Table - OST
* ===========================================================================
MainCharacter                     equ dp 

Reserved_Object_RAM
Reserved_Object_RAM_End
Object_RAM
Dynamic_Object_RAM            fcb   0
                              fill  0,object_size-1
                              fill  0,(nb_dynamic_objects-1)*object_size
Dynamic_Object_RAM_End

LevelOnly_Object_RAM
Sonic_Dust                    fcb   ObjID_SplashDust
                              fill  0,object_size-1
LevelOnly_Object_RAM_End
Object_RAM_End

* ===========================================================================
* Common object structure
* ===========================================================================

; ext_variables_size is for dynamic objects
ext_variables_size            equ   14

status                        equ   status_flags   ; note  exact meaning depends on the object... for sonic/tails  bit 0  leftfacing. bit 1  inair. bit 2  spinning. bit 3  onobject. bit 4  rolljumping. bit 5  pushing. bit 6  underwater.
width_pixels                  equ   ext_variables
y_radius                      equ   ext_variables+1 ; collision height / 2
x_radius                      equ   ext_variables+2 ; collision width / 2
angle                         equ   ext_variables+3 ; angle about the z axis (360 degrees  equ  256)
collision_flags               equ   ext_variables+4
collision_property            equ   ext_variables+5
respawn_index                 equ   ext_variables+6
parent                        equ   ext_variables+7
ext_variables_obj             equ   object_core_size+9
ext_variables_main            equ   object_core_size+ext_variables_size

* ===========================================================================
* Main characters object structure
* ===========================================================================

main_ext_variables_size       equ   ext_variables_size+26
main_object_size              equ   object_core_size+main_ext_variables_size ; the size of a main character object
next_main_object              equ   main_object_size

inertia            equ   ext_variables_main    ; and +1 ; directionless representation of speed... not updated in the air
flip_angle         equ   ext_variables_main+2  ; angle about the x axis (360 degrees  equ  256) (twist/tumble)
air_left           equ   ext_variables_main+3
flip_turned        equ   ext_variables_main+4  ; 0 for normal, 1 to invert flipping (it's a 180 degree rotation about the axis of Sonic's spine, so he stays in the same position but looks turned around)
obj_control        equ   ext_variables_main+5  ; 0 for normal, 1 for hanging or for resting on a flipper, $81 for going through CNZ/OOZ/MTZ tubes or stopped in CNZ cages or stoppers or flying if Tails
status_secondary   equ   ext_variables_main+6
flips_remaining    equ   ext_variables_main+7  ; number of flip revolutions remaining
flip_speed         equ   ext_variables_main+8  ; number of flip revolutions per frame / 256
move_lock          equ   ext_variables_main+9  ; horizontal control lock, counts down to 0
invulnerable_time  equ   ext_variables_main+10 ; and +11 ; time remaining until you stop blinking
invincibility_time equ   ext_variables_main+12 ; and +13 ; remaining
speedshoes_time    equ   ext_variables_main+14 ; and +15 ; remaining
next_tilt          equ   ext_variables_main+16 ; angle on ground in front of sprite
tilt               equ   ext_variables_main+17 ; angle on ground
stick_to_convex    equ   ext_variables_main+18 ; 0 for normal, 1 to make Sonic stick to convex surfaces like the rotating discs in Sonic 1 and 3 (unused in Sonic 2 but fully functional)
spindash_flag      equ   ext_variables_main+19 ; 0 for normal, 1 for charging a spindash or forced rolling
pinball_mode       equ   spindash_flag
spindash_counter   equ   ext_variables_main+20 ; and +21
restart_countdown  equ   spindash_counter
jumping            equ   ext_variables_main+22
interact           equ   ext_variables_main+23 ; RAM address of the last object Sonic stood on, minus $FFFFB000 and divided by $40
top_solid_bit      equ   ext_variables_main+24 ; the bit to check for top solidity (either $C or $E)
lrb_solid_bit      equ   ext_variables_main+25 ; the bit to check for left/right/bottom solidity (either $D or $F)

; ---------------------------------------------------------------------------
; Bits 3-6 of an object's status after a SolidObject call is a
; bitfield with the following meaning 
p1_standing_bit    equ   3
p2_standing_bit    equ   p1_standing_bit + 1

p1_standing        equ   %00001000
p2_standing        equ   %00010000

pushing_bit_delta  equ   2
p1_pushing_bit     equ   p1_standing_bit+pushing_bit_delta
p2_pushing_bit     equ   p1_pushing_bit+1

p1_pushing         equ   %00100000
p2_pushing         equ   %01000000


standing_mask      equ   p1_standing|p2_standing
pushing_mask       equ   p1_pushing|p2_pushing

; ---------------------------------------------------------------------------
; The high word of d6 after a SolidObject call is a bitfield
; with the following meaning 
p1_touch_side_bit    equ   0
p2_touch_side_bit    equ   p1_touch_side_bit+1

p1_touch_side        equ   %00000001
p2_touch_side        equ   %00000010

touch_side_mask      equ   p1_touch_side|p2_touch_side

p1_touch_bottom_bit  equ   p1_touch_side_bit+pushing_bit_delta
p2_touch_bottom_bit  equ   p1_touch_bottom_bit+1

p1_touch_bottom      equ   %00000100
p2_touch_bottom      equ   %00001000

touch_bottom_mask    equ   p1_touch_bottom|p2_touch_bottom

p1_touch_top_bit     equ   p1_touch_bottom_bit+pushing_bit_delta
p2_touch_top_bit     equ   p1_touch_top_bit+1

p1_touch_top         equ   %00010000
p2_touch_top         equ   %00100000

touch_top_mask       equ   p1_touch_top|p2_touch_top

; ---------------------------------------------------------------------------
; status_secondary bitfield variables
;
; status_secondary variable bit numbers
status_sec_hasShield 		equ   0
status_sec_isInvincible 	equ   1
status_sec_hasSpeedShoes 	equ   2
status_sec_isSliding 		equ   7

status_sec_hasShield_mask 	equ   $01
status_sec_isInvincible_mask 	equ   $02
status_sec_hasSpeedShoes_mask 	equ   $04
status_sec_isSliding_mask 	equ   $80

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

* ===========================================================================
* Physics Constants
* ===========================================================================

gravity                       equ   $38 ; 56 sub-pixels par frame
camera_Y_pos_bias_default     equ   (200/2)-16 ; position of default camera center on screen

* ===========================================================================
* Game specific globals
* ===========================================================================

Camera_Y_pos_bias             fdb   0
Camera_Max_Y_Pos_Changing     fcb   0
Horiz_scroll_delay_val        fcb   0
Sonic_Pos_Record_Index        fcb   0 ; index in Sonic_Pos_Record_Buf and Sonic_Stat_Record_Buf
Sonic_Stat_Record_Buf         fill  0,$100
Sonic_Pos_Record_Buf          fill  0,$100
Current_zone_and_act          fdb   0

 INCLUDE ".\objects\managers\rings-manager-s3k-ram.asm"

* ---------------------------------------------------------------------------
* Level Globals
* ---------------------------------------------------------------------------
   
Water_Level_1                 fdb   0
ColData_page                  fcb   0
ColCurveMap                   fdb   0
ColArray                      fdb   0
ColArray2                     fdb   0
Respawn_table_keep            fdb   0

* ---------------------------------------------------------------------------
* HUD Globals
* ---------------------------------------------------------------------------

Ring_count                    fdb   0
