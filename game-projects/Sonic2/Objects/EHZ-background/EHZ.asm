; ---------------------------------------------------------------------------
; Object - Tilemap Load and Data
;
;   This code can be split in several parts (objects) if needed
;   Data will be stored in objects and accessed with Object index
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"

TileMapRegister
	; register map to engine
        ldx   #EHZ_map
        stx   glb_map_adr

        lda   $E7E6
        sta   glb_map_pge

	; register tiles
	sta   glb_map_tiles_pge
	ldd   layer_tiles,x
	std   glb_map_tiles_adr

	; load chunk map
	ldu   layer_map,x
	lda   ,u
	sta   glb_map_chunk_pge
	ldd   1,u
	std   glb_map_chunk_adr

	; load chunk definitions (part 0)
	ldu   layer_chunk0,x
	lda   ,u
	sta   glb_map_defchunk0_pge
	ldd   1,u
	std   glb_map_defchunk0_adr

	; load chunk definitions (part 1)
	ldu   layer_chunk1,x
	lda   ,u
	sta   glb_map_defchunk1_pge
	ldd   1,u
	std   glb_map_defchunk1_adr

	; load chunk definitions (part 1)
	ldu   layer_chunk1,x
	lda   ,u
	sta   glb_map_defchunk1_pge
	ldd   1,u
	std   glb_map_defchunk1_adr

        lda   layer_map_width,x
	sta   glb_map_width

	; init engine variables
        ldd   #glb_camera_init
        std   glb_old_camera_x_pos0
        std   glb_old_camera_x_pos1
        std   glb_old_camera_y_pos0
        std   glb_old_camera_y_pos1
        rts  

EHZ_map
        fdb   0                   ; submap_camera_x_min - camera position limit
        fdb   0                   ; submap_camera_y_min - camera position limit
        fdb   5480                ; submap_camera_x_max - camera position limit
        fdb   848                 ; submap_camera_y_max - camera position limit   
EHZ_width equ 88
        fcb   EHZ_width           ; layer_map_width     - Width (byte) nb of tiles in this layer map rows
        fcb   8                   ; layer_map_height    - Height  (byte) nb of tiles in this layer map columns 
        fdb   Map_EHZ             ; layer_map           - map made of 64x128 tiles
        fdb   Chunk_EHZ_0         ; layer_chunk0        - index to chunk definition (subset of 8x8 tiles) id 0-127
	fdb   0                   ; layer_chunk1        - index to chunk definition (subset of 8x8 tiles) id 128-255
        fdb   Tls_EHZ             ; layer_tiles         - location of tiles index (page and adress for each tiles)
	fdb   EHZ_width*0         ; layer_mul_ref       - table of precalculated values for y position in map
        fdb   EHZ_width*1
        fdb   EHZ_width*2
        fdb   EHZ_width*3
        fdb   EHZ_width*4
        fdb   EHZ_width*5
        fdb   EHZ_width*6
        fdb   EHZ_width*7
	; only 8 lines of chunks in map, no need to go further
        
Tls_EHZ  
        INCLUDEGEN Tls_EHZ index
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile]
        ; endmark (byte) value $00
