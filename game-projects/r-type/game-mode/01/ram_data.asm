
; ext_variables_size is for dynamic objects
ext_variables_size           equ 20

* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 64
nb_graphical_objects         equ 64 * max 64 total
nb_stars                     equ 30
* ===========================================================================
* Object Status Table - OST
* ===========================================================================
MainCharacter                equ dp

Dynamic_Object_RAM           fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End

StarField_RAM                fill  0,(nb_stars) * 3  ;  for every star X, Y, Speed
StarField_RAM_End
