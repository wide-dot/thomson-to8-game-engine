; ---------------------------------------------------------------------------
; Object - Tilemap Load and Data for savage Level
;
;   This code can be split in several parts (objects) if needed
;   Data will be stored in objects and accessed with Object index
;
; input REG : [A] routine
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"

TilemapMain
        asla
        ldx   #TilemapRoutines
        jmp   [a,x]

TilemapRoutines
        fdb   TilemapInit
        fdb   Tilemap01

TilemapInit
        ldd   #$0000
        std   glb_camera_x_pos
        ldd   #$0000
        std   glb_camera_y_pos
        inc   glb_current_submap        
        ldx   #Savage_submap001                    ; default submap at startup
        jmp   TilemapLoad

Tilemap01
        rts

TilemapLoad
        stx   glb_submap
        _GetCartPageA
        sta   glb_submap_page

        ; set camera limits
        ldd   submap_camera_y_min,x 
        std   glb_camera_y_min
        addd  #screen_top+8+11
        std   glb_vp_y_min

        ldd   submap_camera_y_max,x
        std   glb_camera_y_max
        addd  #screen_top+8+192-11
        std   glb_vp_y_max        

        ldd   submap_camera_x_min,x 
        std   glb_camera_x_min
        addd  #screen_left+16+4
        std   glb_vp_x_min
        
        ldd   submap_camera_x_max,x
        std   glb_camera_x_max
        addd  #screen_left+16+128-5
        std   glb_vp_x_max        

        ; this will force the refresh of the screen buffers        
        ldd   #glb_submap_index_inactive
        std   glb_submap_index_buf0
        std   glb_submap_index_buf1
        rts  

; TODO add page location to Layers index in submap definition to break the 16K limit and put layers on dedicated objects (no need here)
Savage_submap001
        fdb   0                               ; submap_x_pos          - position of submap in the global map including camera border (x_pixel coordinates system)
        fdb   0                               ; submap_y_pos          - position of submap in the global map including camera border (x_pixel coordinates system)
        fdb   0                               ; submap_camera_x_min   - camera position limit
        fdb   0                               ; submap_camera_y_min   - camera position limit
        fdb   1984                            ; submap_camera_x_max   - camera position limit
        fdb   0                               ; submap_camera_y_max   - camera position limit   
        fdb   Savage_submap001_layer001       ; submap_layers         - table of layer addresses
        fcb   $00                             ;                       - end flag of layers index
        
Savage_submap001_layer001
        fcb   $FF              ; layer_parallax_X          - for one camera pixel move tell how much this layer will move in 8 bit decimal value (n/256)
        fcb   $FF              ; layer_parallax_Y          - ex: $FF is one pixel move, $00 is not moving, $80 is moving half a pixel ...
        fdb   $0144            ; layer_vp_offset           - viewport offset from top of the screen (in linear memory bytes) col: 4 px = 1 byte + row: 1 px = 40 bytes
        fcb   $10-1            ; layer_vp_tiles_x          - nb of tiles in viewport rows
        fcb   $08-1            ; layer_vp_tiles_y          - nb of tiles in viewport columns
        fdb   $0080            ; layer_vp_x_size           - viewport x size in pixel 
        fdb   $0080            ; layer_vp_y_size           - viewport y size in pixel 
        fcb   $02              ; layer_mem_step_x          - nb of linear memory bytes between two tiles in a column
        fdb   $0262            ; layer_mem_step_y          - nb of linear memory bytes to go from the last tile of a row to the first tile of the next row
        fcb   $03              ; layer_tile_size_bitmask_x - bitmask used in sub tile position representation (tile x size : 4px=2, 8px=3, 16px=4, 32px=5, ... 256px=8)
        fcb   $04              ; layer_tile_size_bitmask_y - bitmask used in sub tile position representation (tile y size : 4px=2, 8px=3, 16px=4, 32px=5, ... 256px=8)
        fcb   $0A              ; layer_tile_size_divider_x - number of byte to branch over in the division routine (tile x size : 4px=0C, 8px=0A, 16px=08, 32px=06, ... 256px=0)
        fcb   $08              ; layer_tile_size_divider_y - number of byte to branch over in the division routine (tile x size : 4px=0C, 8px=0A, 16px=08, 32px=06, ... 256px=0)
        fdb   Tls_savage       ; layer_tiles_location      - location of tiles index (page and adress for each tiles)
        
        fcb   128 ; TODO move this Width to layer bin
        fcb   8   ; TODO move this Height to layer bin
        INCLUDEBIN "./Objects/tilemap/tilemap/map.bin"
        ; TODO Width   (byte) nb of tiles in this layer map rows
        ; TODO Height  (byte) nb of tiles in this layer map columns                
        ; TileMap (byte) index of a tile [repeated width*height times]

Tls_savage   
        INCLUDEGEN Tls_savage index
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile]
        ; endmark (byte) value $00
          