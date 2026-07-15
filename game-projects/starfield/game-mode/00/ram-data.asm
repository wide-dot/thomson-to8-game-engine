; ext_variables_size is for dynamic objects
ext_variables_size           equ 20
nb_dynamic_objects           equ 8
nb_graphical_objects         equ 8

MainCharacter                equ dp

Dynamic_Object_RAM           fill 0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End
