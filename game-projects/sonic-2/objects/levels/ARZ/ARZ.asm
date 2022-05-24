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
        ldx   #ARZ_map
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
	;ldu   layer_chunk1,x
	;lda   ,u
	;sta   glb_map_defchunk1_pge
	;ldd   1,u
	;std   glb_map_defchunk1_adr

        lda   layer_map_width,x
	sta   glb_map_width

        ldd   #Primary_Collision
        std   glb_primary_collision
        ldd   #Secondary_Collision
        std   glb_secondary_collision

        ldd   submap_camera_x_min,x
        std   glb_camera_x_min_pos
        ldd   submap_camera_x_max,x
        std   glb_camera_x_max_pos
        ldd   submap_camera_y_min,x
        std   glb_camera_y_min_pos
        ldd   submap_camera_y_max,x
        std   glb_camera_y_max_pos

        rts  

ARZ_map
        fdb   0                   ; submap_camera_x_min - camera position limit
        fdb   0                   ; submap_camera_y_min - camera position limit
        fdb   5480+16             ; submap_camera_x_max - camera position limit
        fdb   848+16              ; submap_camera_y_max - camera position limit   
ARZ_width equ 128
        fcb   ARZ_width           ; layer_map_width     - Width (byte) nb of chunks in this layer map rows
        fcb   8                   ; layer_map_height    - Height (byte) nb of chunks in this layer map columns 
        fdb   Map_ARZ             ; layer_map           - map made of 64x128 chunks
        fdb   Chunk_ARZ_0         ; layer_chunk0        - index to chunk definition (subset of 8x16 tiles) id 0-127
	fdb   0                   ; layer_chunk1        - index to chunk definition (subset of 8x16 tiles) id 128-255
        fdb   Tls_ARZ             ; layer_tiles         - location of tiles index (page and adress for each tiles)
	fdb   ARZ_width*0         ; layer_mul_ref       - table of precalculated values for y position in map
        fdb   ARZ_width*1
        fdb   ARZ_width*2
        fdb   ARZ_width*3
        fdb   ARZ_width*4
        fdb   ARZ_width*5
        fdb   ARZ_width*6
        fdb   ARZ_width*7
	; only 8 lines of chunks in map, no need to go further
        
Tls_ARZ  
        INCLUDEGEN Tls_ARZ index
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile]

Primary_Collision
        INCLUDEBIN "./objects/levels/ARZ/map/primary-collision.bin"

Secondary_Collision
        INCLUDEBIN "./objects/levels/ARZ/map/secondary-collision.bin"

        ; Animated tileset
TlsAni_ARZ
	fcb   $61
        fdb   TlsAni_ARZ_pulseball1
	fcb   $61
        fdb   TlsAni_ARZ_pulseball2
	fcb   $61
        fdb   TlsAni_ARZ_pulseball3
	fcb   $61
        fdb   TlsAni_ARZ_flower1
	fcb   $61
        fdb   TlsAni_ARZ_flower2
	fcb   $61
        fdb   TlsAni_ARZ_flower3
	fcb   $61
        fdb   TlsAni_ARZ_flower4
