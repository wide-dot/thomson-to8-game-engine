; RAM variables

* ===========================================================================
* Object Constants
* ===========================================================================

* ---------------------------------------------------------------------------
* Object Status Table - OST
* ---------------------------------------------------------------------------

Object_RAM 

Reserved_Object_RAM
;                             fill  0,nb_reserved_objects*object_size
Reserved_Object_RAM_End

Dynamic_Object_RAM
                              fcb   ObjID_player
                              fill  0,object_size-1
Obj_Axe1                      fcb   ObjID_axe
                              fill  0,object_size-1
Obj_Axe2                      fcb   ObjID_axe
                              fill  0,object_size-1
Obj_Axe3                      fcb   ObjID_axe
                              fill  0,object_size-1
Obj_Axe4                      fcb   ObjID_axe
                              fill  0,object_size-1
Obj_Axe5                      fcb   ObjID_axe
                              fill  0,object_size-1
Obj_Bat1                      fcb   ObjID_bat
                              fill  0,object_size-1
Obj_Bat2                      fcb   ObjID_bat
                              fill  0,object_size-1
Obj_Bat3                      fcb   ObjID_bat
                              fill  0,object_size-1
Obj_Bat4                      fcb   ObjID_bat
                              fill  0,object_size-1
Obj_Bat5                      fcb   ObjID_bat
                              fill  0,object_size-1
Dynamic_Object_RAM_End

LevelOnly_Object_RAM
;                             fill  0,nb_level_objects*object_size
LevelOnly_Object_RAM_End
Object_RAM_End

glb_current_submap   fcb   0