; ---------------------------------------------------------------------------
; Object - Tilemap Load and Data for South America Level
;
;   This code can be split in several parts (objects) if needed
;   Data will be stored in objects and accessed with Object index
;
; input REG : [A] routine
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm" 

TilemapMain
        asla
        ldx   #TilemapRoutines
        jmp   [a,x]

TilemapRoutines
        fdb   TilemapInit
        fdb   Tilemap01
        fdb   Tilemap02
        ;fdb   Tilemap03
        ;fdb   Tilemap04
        ;fdb   Tilemap05
        ;fdb   Tilemap06
        ;fdb   Tilemap07
        ;fdb   Tilemap08
        ;fdb   Tilemap09

TilemapInit
        ldd   #$0000
        std   <glb_camera_x_pos
        std   glb_camera_y_pos
        inc   glb_current_submap        
        ldx   #SouthAmerica_submap001                 ; default submap at startup
        bra   TilemapLoad
TilemapReturn
        rts

Tilemap01
        ldx   #RickData
        ldd   x_pos,x
        cmpd  #24+120
        blo   TilemapReturn
        cmpd  #24+128
        bhi   TilemapReturn
        ldd   y_pos,x
        cmpd  #8+320
        blo   TilemapReturn
        cmpd  #8+352
        bhi   TilemapReturn
        inc   glb_current_submap
        ldd   #128
        std   <glb_camera_x_pos
        ldd   #256
        std   <glb_camera_y_pos
        ldd   #28+128  
        std   x_pos,x
        ldx   #SouthAmerica_submap002
        bra   TilemapLoad  ; exit position 120,320 128,352
      
Tilemap02      
        rts
        
TilemapLoad
        stx   glb_submap
        lda   $E7E6
        sta   glb_submap_page

        ; set camera limits
        ldd   submap_camera_y_min,x 
        std   glb_camera_y_min
        
        ldd   submap_camera_y_max,x
        std   glb_camera_y_max

        ; this will force the refresh of the screen buffers        
        ldd   #glb_submap_index_inactive
        std   glb_submap_index_buf0
        std   glb_submap_index_buf1
        rts  

; TODO add page location to Layers index in submap definition to break the 16K limit and put layers on dedicated objects (no need here)
SouthAmerica_submap001
        fdb   0                               ; submap_x_pos          - position of submap in the global map including camera border (x_pixel coordinates system)
        fdb   0                               ; submap_y_pos          - position of submap in the global map including camera border (x_pixel coordinates system)
        fdb   0                               ; submap_camera_x_min   - camera position limit
        fdb   0                               ; submap_camera_y_min   - camera position limit
        fdb   0                               ; submap_camera_x_max   - camera position limit
        fdb   256                             ; submap_camera_y_max   - camera position limit   
        fdb   SouthAmerica_submap001_layer001 ; submap_layers         - table of layer addresses
        fcb   $00                             ;                       - end flag of layers index
        
SouthAmerica_submap001_layer001
        fcb   $FF              ; layer_parallax_X          - for one camera pixel move tell how much this layer will move in 8 bit decimal value (n/256)
        fcb   $FF              ; layer_parallax_Y          - ex: $FF is one pixel move, $00 is not moving, $80 is moving half a pixel ...
        fdb   $0144            ; layer_vp_offset           - viewport offset from top of the screen (in linear memory bytes) col: 4 px = 1 byte + row: 1 px = 40 bytes
        fcb   $08-1            ; layer_vp_tiles_x          - nb of tiles in viewport rows
        fcb   $18-1            ; layer_vp_tiles_y          - nb of tiles in viewport columns
        fdb   $0080            ; layer_vp_x_size           - viewport x size in pixel 
        fdb   $00C0            ; layer_vp_y_size           - viewport y size in pixel 
        fcb   $04              ; layer_mem_step_x          - nb of linear memory bytes between two tiles in a column
        fdb   $0124            ; layer_mem_step_y          - nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
        fcb   $04              ; layer_tile_size_bitmask_x - bitmask used in sub tile position representation (tile x size : 4px=2, 8px=3, 16px=4, 32px=5, ... 256px=8)
        fcb   $03              ; layer_tile_size_bitmask_y - bitmask used in sub tile position representation (tile y size : 4px=2, 8px=3, 16px=4, 32px=5, ... 256px=8)
        fcb   $08              ; layer_tile_size_divider_x - number of byte to branch over in the division routine (tile x size : 4px=0C, 8px=0A, 16px=08, 32px=06, ... 256px=0)
        fcb   $0A              ; layer_tile_size_divider_y - number of byte to branch over in the division routine (tile y size : 4px=0C, 8px=0A, 16px=08, 32px=06, ... 256px=0)
        fdb   Tls_SouthAmerica ; layer_tiles_location      - location of tiles index (page and adress for each tiles)
        
        fcb   8  ; TODO move this Width to layer bin
        fcb   56 ; TODO move this Height to layer bin
        INCLUDEBIN "./objects/SouthAmerica/Tilemap/tilemap/SouthAmerica.submap001_layer001.bin"
        ; TODO Width   (byte) nb of tiles in this layer map rows
        ; TODO Height  (byte) nb of tiles in this layer map columns                
        ; TileMap (byte) index of a tile [repeated width*height times]

SouthAmerica_submap002
        fdb   128                             ; submap_x_pos          - position of submap in the global map including camera border (x_pixel coordinates system)
        fdb   256                             ; submap_y_pos          - position of submap in the global map including camera border (x_pixel coordinates system)
        fdb   128                             ; submap_camera_x_min   - camera position limit
        fdb   256                             ; submap_camera_y_min   - camera position limit
        fdb   128                             ; submap_camera_x_max   - camera position limit
        fdb   896                             ; submap_camera_y_max   - camera position limit   
        fdb   SouthAmerica_submap002_layer001 ; submap_layers         - table of layer addresses
        fcb   $00                             ;                       - end flag of layers index
        
SouthAmerica_submap002_layer001
        fcb   $FF              ; layer_parallax_X          - for one camera pixel move tell how much this layer will move in 8 bit decimal value (n/256)
        fcb   $FF              ; layer_parallax_Y          - ex: $FF is one pixel move, $00 is not moving, $80 is moving half a pixel ...
        fdb   $0144            ; layer_vp_offset           - viewport offset from top of the screen (in linear memory bytes) col: 4 px = 1 byte + row: 1 px = 40 bytes
        fcb   $08-1            ; layer_vp_tiles_x          - nb of tiles in viewport rows
        fcb   $18-1            ; layer_vp_tiles_y          - nb of tiles in viewport columns
        fdb   $0080            ; layer_vp_x_size           - viewport x size in pixel 
        fdb   $00C0            ; layer_vp_y_size           - viewport y size in pixel 
        fcb   $04              ; layer_mem_step_x          - nb of linear memory bytes between two tiles in a column
        fdb   $0124            ; layer_mem_step_y          - nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
        fcb   $04              ; layer_tile_size_bitmask_x - bitmask used in sub tile position representation (tile x size : 4px=2, 8px=3, 16px=4, 32px=5, ... 256px=8)
        fcb   $03              ; layer_tile_size_bitmask_y - bitmask used in sub tile position representation (tile y size : 4px=2, 8px=3, 16px=4, 32px=5, ... 256px=8)
        fcb   $08              ; layer_tile_size_divider_x - number of byte to branch over in the division routine (tile x size : 4px=14, 8px=12, 16px=10, 32px=8, ... 256px=2)
        fcb   $0A              ; layer_tile_size_divider_y - number of byte to branch over in the division routine (tile y size : 4px=14, 8px=12, 16px=10, 32px=8, ... 256px=2)
        fdb   Tls_SouthAmerica ; layer_tiles_location      - location of tiles index (page and adress for each tiles)
        
        fcb   8   ; TODO move this Width to layer bin
        fcb   104 ; TODO move this Height to layer bin
        INCLUDEBIN "./objects/SouthAmerica/Tilemap/tilemap/SouthAmerica.submap002_layer001.bin"
        ; TODO Width   (byte) nb of tiles in this layer map rows
        ; TODO Height  (byte) nb of tiles in this layer map columns                
        ; TileMap (byte) index of a tile [repeated width*height times]

Tls_SouthAmerica   
        INCLUDEGEN Tls_SouthAmerica index
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile]
        ; endmark (byte) value $00