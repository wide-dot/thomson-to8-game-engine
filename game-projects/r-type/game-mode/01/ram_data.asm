
; ext_variables_size is for dynamic objects
ext_variables_size           equ 20

* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 64
nb_graphical_objects         equ 64 * max 64 total
* ===========================================================================
* Object Status Table - OST
* ===========================================================================
player1                      equ dp

Dynamic_Object_RAM           fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End
