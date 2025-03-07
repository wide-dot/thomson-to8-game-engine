
; ext_variables_size is for dynamic objects
ext_variables_size                equ 20

* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 20
nb_graphical_objects         equ 20 * max 64 total
* ===========================================================================
* Object Status Table - OST
* ===========================================================================
MainCharacter                 equ dp

Dynamic_Object_RAM            fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End

RAM_A_COCKPIT
        INCLUDEBIN "./game-mode/gamescreen/image/goldorak-cockpit.1.0.bin"
RAM_B_COCKPIT
        INCLUDEBIN "./game-mode/gamescreen/image/goldorak-cockpit.0.0.bin"



