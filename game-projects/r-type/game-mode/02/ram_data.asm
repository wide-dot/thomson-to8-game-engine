* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 48
nb_graphical_objects         equ 48 * max 64 total
ext_variables_size           equ 20 ; ext_variables_size is for dynamic objects

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
AABB_lists.nb                equ   (AABB_endLists-AABB_lists)/2
AABB_lists
AABB_list_friend             fdb   0,0
AABB_list_ennemy             fdb   0,0
AABB_list_ennemy_unkillable  fdb   0,0
AABB_list_player             fdb   0,0
AABB_list_bonus              fdb   0,0
AABB_list_foefire            fdb   0,0
AABB_list_forcepod           fdb   0,0
AABB_endLists