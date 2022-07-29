* ===========================================================================
* Object Constants
* ===========================================================================

nb_reserved_objects               equ 0
nb_dynamic_objects                equ 4
nb_level_objects                  equ 0
nb_graphical_objects              equ 4 * max 64 total (background erase only)

* ===========================================================================
* Object Status Table - OST
* ===========================================================================
MainCharacter                     equ dp 

Reserved_Object_RAM
Reserved_Object_RAM_End
Object_RAM
Dynamic_Object_RAM
                              fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End

LevelOnly_Object_RAM
LevelOnly_Object_RAM_End
Object_RAM_End

* ===========================================================================
* Common object structure
* ===========================================================================

; ext_variables_size is for dynamic objects
ext_variables_size            equ   26
