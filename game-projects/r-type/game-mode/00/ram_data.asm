
* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 64
nb_graphical_objects         equ 64 * max 64 total
ext_variables_size           equ 20 ; ext_variables_size is for dynamic objects

* ===========================================================================
* Object Status Table - OST
* ===========================================================================
palettefade                  fcb   ObjID_fade
                             fill  0,10-1

Dynamic_Object_RAM           fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End
