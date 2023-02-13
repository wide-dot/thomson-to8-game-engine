
; ext_variables_size is for dynamic objects
ext_variables_size           equ 20

* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 54
nb_graphical_objects         equ 54 * max 64 total

* ===========================================================================
* Object Status Table - OST
* ===========================================================================
player1                      equ   dp
palettefade                  fcb   ObjID_fade
                             fill  0,object_size-1

Dynamic_Object_RAM           fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End

* ===========================================================================
* Collision lists
* ===========================================================================
AABB_list_friend             fdb   0,0
AABB_list_ennemy             fdb   0,0
AABB_list_player             fdb   0,0
AABB_list_bonus              fdb   0,0