; RAM variables - Level Select

; ext_variables_size is for dynamic objects
ext_variables_size                equ 14

* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects                equ 20
nb_graphical_objects              equ 20 * max 64 total

* ---------------------------------------------------------------------------
* Object Status Table - OST
* ---------------------------------------------------------------------------
        
Dynamic_Object_RAM            fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End

menu_sel_chip fcb 0
menu_sel_port fcb 0

