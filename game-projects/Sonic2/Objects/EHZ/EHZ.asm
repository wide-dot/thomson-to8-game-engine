; ---------------------------------------------------------------------------
; Object - Tilemap Load and Data
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
        fdb   TileMapRegister

TileMapRegister
	; register map to engine
        ldx   #EHZ_map
        stx   glb_map_adr

        _GetCartPageA
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
	fdb   Chunk_EHZ_1         ; layer_chunk1        - index to chunk definition (subset of 8x8 tiles) id 128-255
        fdb   Tls_EHZ             ; layer_tiles         - location of tiles index (page and adress for each tiles)
	fdb   EHZ_width*0         ; layer_mul_ref       - table of precalculated values for y position in map
        fdb   EHZ_width*1
        fdb   EHZ_width*2
        fdb   EHZ_width*3
        fdb   EHZ_width*4
        fdb   EHZ_width*5
        fdb   EHZ_width*6
        fdb   EHZ_width*7
        fdb   EHZ_width*8
        fdb   EHZ_width*9
        fdb   EHZ_width*10
        fdb   EHZ_width*11
        fdb   EHZ_width*12
        fdb   EHZ_width*13
        fdb   EHZ_width*14
        fdb   EHZ_width*15
        fdb   EHZ_width*16
        fdb   EHZ_width*17
        fdb   EHZ_width*18
        fdb   EHZ_width*19
        fdb   EHZ_width*20
        fdb   EHZ_width*21
        fdb   EHZ_width*22
        fdb   EHZ_width*23
        fdb   EHZ_width*24
        fdb   EHZ_width*25
        fdb   EHZ_width*26
        fdb   EHZ_width*27
        fdb   EHZ_width*28
        fdb   EHZ_width*29
        fdb   EHZ_width*30
        fdb   EHZ_width*31
        fdb   EHZ_width*32
        fdb   EHZ_width*33
        fdb   EHZ_width*34
        fdb   EHZ_width*35
        fdb   EHZ_width*36
        fdb   EHZ_width*37
        fdb   EHZ_width*38
        fdb   EHZ_width*39
        fdb   EHZ_width*40
        fdb   EHZ_width*41
        fdb   EHZ_width*42
        fdb   EHZ_width*43
        fdb   EHZ_width*44
        fdb   EHZ_width*45
        fdb   EHZ_width*46
        fdb   EHZ_width*47
        fdb   EHZ_width*48
        fdb   EHZ_width*49
        fdb   EHZ_width*50
        fdb   EHZ_width*51
        fdb   EHZ_width*52
        fdb   EHZ_width*53
        fdb   EHZ_width*54
        fdb   EHZ_width*55
        fdb   EHZ_width*56
        fdb   EHZ_width*57
        fdb   EHZ_width*58
        fdb   EHZ_width*59
        fdb   EHZ_width*60
        fdb   EHZ_width*61
        fdb   EHZ_width*62
        fdb   EHZ_width*63
        
Tls_EHZ  
        INCLUDEGEN Tls_EHZ index
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile]
        ; endmark (byte) value $00
