
; ext_variables_size is for dynamic objects
ext_variables_size                equ 20 ;
nb_dynamic_objects                equ 10 ; dynamic allocation
nb_graphical_objects              equ 10 ; only count objects that will be rendered on screen (max 64 total)

#palettefade                  fcb   ObjID_fade
#                             fill  0,object_size-1

Dynamic_Object_RAM 
        fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End
             

