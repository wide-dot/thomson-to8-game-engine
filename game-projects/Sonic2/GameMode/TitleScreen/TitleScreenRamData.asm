; RAM variables - Special stage
; TODO : split entre variables qui doivent etre globales (restent ici)
; et celles specifiques a l'objet (vont avec le code objet)

; ext_variables_size is for dynamic objects
ext_variables_size                equ 14

* ===========================================================================
* Object Constants
* ===========================================================================

nb_reserved_objects               equ 2
nb_dynamic_objects                equ 38
nb_level_objects                  equ 3
nb_graphical_objects              equ 43 * max 64 total

* ---------------------------------------------------------------------------
* Object Status Table - OST
* ---------------------------------------------------------------------------
        
Object_RAM 
Reserved_Object_RAM
MainCharacter                 fcb   ObjID_SEGA
                              fcb   $01
                              fill  0,object_size-2
Sidekick                      fill  0,object_size
Reserved_Object_RAM_End

Dynamic_Object_RAM            fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End

LevelOnly_Object_RAM                              * faire comme pour Dynamic_Object_RAM
Obj_TailsTails                fill  0,object_size * Positionnement et nommage a mettre dans objet Tails
Obj_SonicDust                 fill  0,object_size * Positionnement et nommage a mettre dans objet Tails
Obj_TailsDust                 fill  0,object_size * Positionnement et nommage a mettre dans objet Tails
LevelOnly_Object_RAM_End
Object_RAM_End
