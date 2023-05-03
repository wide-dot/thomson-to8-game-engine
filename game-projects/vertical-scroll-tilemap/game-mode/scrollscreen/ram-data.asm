
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

TILE_WIDTH EQU 32
TILE_HEIGHT EQU 32

TILE_SIZE EQU (TILE_WIDTH/2)*TILE_HEIGHT

Tile_Set_Data
Tile_01 FILL $11,TILE_SIZE
Tile_02 FILL $22,TILE_SIZE
Tile_03 FILL $33,TILE_SIZE
Tile_04 FILL $44,TILE_SIZE
Tile_05 FILL $55,TILE_SIZE

Tile_map_start
   FDB Tile_01,Tile_02,Tile_03,Tile_04,Tile_05
   FDB Tile_02,Tile_03,Tile_04,Tile_05,Tile_01
   FDB Tile_03,Tile_04,Tile_05,Tile_01,Tile_02
   FDB Tile_04,Tile_05,Tile_01,Tile_02,Tile_03
   FDB Tile_05,Tile_01,Tile_02,Tile_03,Tile_04
Tile_map_end


