
* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 1
nb_graphical_objects         equ 64 * max 64 total
ext_variables_size           equ 20

* ===========================================================================
* Object Status Table - OST
* ===========================================================================

Dynamic_Object_RAM           fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End
