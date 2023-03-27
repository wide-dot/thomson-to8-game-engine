
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


Tile_Data_RAM_A_Start
   FDB $1111,$1111,$1111,$1111  ; 32 px x 8 px 
   FDB $2222,$2222,$2222,$2222  ; 
   FDB $3333,$3333,$3333,$3333  ; 
   FDB $4444,$4444,$4444,$4444  ; 
   FDB $5555,$5555,$5555,$5555  ;
   FDB $6666,$6666,$6666,$6666  ;
   FDB $7777,$7777,$7777,$7777  ;
   FDB $8888,$8888,$8888,$8888  ;
Tile_Data_RAM_A_End

Tile_Data_RAM_B_Start
   FDB $1111,$1111,$1111,$1111  ; 
   FDB $2222,$2222,$2222,$2222  ; 
   FDB $3333,$3333,$3333,$3333  ; 
   FDB $4444,$4444,$4444,$4444  ; 
   FDB $5555,$5555,$5555,$5555  ;
   FDB $6666,$6666,$6666,$6666  ;
   FDB $7777,$7777,$7777,$7777  ;
   FDB $8888,$8888,$8888,$8888  ;
Tile_Data_RAM_B_End


Obj_PaletteFade FDB $0000

RAM_A_COCKPIT_START
        INCLUDEBIN "./game-mode/gamescreen/image/goldorak-cockpit.1.0.bin"
RAM_A_COCKPIT_END
RAM_B_COCKPIT_START
        INCLUDEBIN "./game-mode/gamescreen/image/goldorak-cockpit.0.0.bin"
RAM_B_COCKPIT_END


