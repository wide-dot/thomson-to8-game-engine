; RAM variables

* ===========================================================================
* Object Constants
* ===========================================================================

; ext_variables_size is for dynamic objects
ext_variables_size                equ 0
nb_dynamic_objects                equ 3
nb_graphical_objects              equ 3 * max 64 total

Object_RAM
SS_Object_RAM
Dynamic_Object_RAM                fcb   ObjID_Back
                                  fill  0,object_size-1
                                  fcb   ObjID_Back2
                                  fill  0,object_size-1
                                  fcb   ObjID_Player
                                  fill  0,object_size-1
Dynamic_Object_RAM_End
SS_Object_RAM_End
Object_RAM_End
