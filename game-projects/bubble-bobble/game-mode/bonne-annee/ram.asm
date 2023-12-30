; RAM variables

* ===========================================================================
* Object Constants
* ===========================================================================

; ext_variables_size is for dynamic objects
ext_variables_size                equ 9
nb_dynamic_objects                equ 22
nb_graphical_objects              equ 12 ; max 64 total

Dynamic_Object_RAM                
                                fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End

* ===========================================================================
* Collision lists
* ===========================================================================
AABB_lists.nb                equ   (AABB_endLists-AABB_lists)/2
AABB_lists
AABB_list_player             fdb   0,0
AABB_list_bubble             fdb   0,0
AABB_endLists