; RAM variables

* ===========================================================================
* Object Constants
* ===========================================================================

; ext_variables_size is for dynamic objects
ext_variables_size                equ 0
nb_dynamic_objects                equ 2
nb_graphical_objects              equ 2 * max 64 total

Dynamic_Object_RAM                
                                fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End
