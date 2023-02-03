
; ext_variables_size is for dynamic objects
ext_variables_size                equ 0

* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 10
nb_graphical_objects         equ 1 * max 64 total
* ===========================================================================
* Object Status Table - OST
* ===========================================================================
MainCharacter                 equ dp

Dynamic_Object_RAM            fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End

var_flag_displayText fcb 0
var_intro_slides_num fcb 0
var_count16Tx        fdb 0
