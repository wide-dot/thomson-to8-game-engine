; RAM variables - Special stage
; TODO : split entre variables qui doivent etre globales (restent ici)
; et celles specifiques a l'objet (vont avec le code objet)

; ext_variables_size is for dynamic objects
ext_variables_size                equ 14

* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects                equ 43
nb_graphical_objects              equ 43 * max 64 total

* ---------------------------------------------------------------------------
* Object Status Table - OST
* ---------------------------------------------------------------------------
        
Dynamic_Object_RAM            fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End
