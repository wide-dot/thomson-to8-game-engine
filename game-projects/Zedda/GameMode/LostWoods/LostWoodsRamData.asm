; RAM variables

* ===========================================================================
* Object Constants
* ===========================================================================

* ---------------------------------------------------------------------------
* Object Status Table - OST
* ---------------------------------------------------------------------------

Object_RAM 
                              fcb   ObjID_Triangle
                              fill  0,object_size-1

                              fcb   ObjID_Nindendo
                              fill  0,object_size-1

                              fcb   ObjID_Title
                              fill  0,object_size-1

Obj_PaletteFade               fill  0,object_size

                              fcb   ObjID_Sword
                              fill  0,object_size-1

                              fcb   ObjID_Castle
                              fill  0,object_size-1

LinkData                      fill  0,object_size

Reserved_Object_RAM
;                             fill  0,nb_reserved_objects*object_size
Reserved_Object_RAM_End

Dynamic_Object_RAM
                              fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End

LevelOnly_Object_RAM
;                             fill  0,nb_level_objects*object_size
LevelOnly_Object_RAM_End
Object_RAM_End

glb_current_submap   fcb   0