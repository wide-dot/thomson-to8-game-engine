        INCLUDE "./engine/macros.asm"

LevelInit

        ; register map location to main
        ldx   #scroll_map
        ldd   #Tls_lvl01
        std   -2,x
        ldd   #Tls_lvl01_s
        std   ,x
        ldx   #scroll_map_page
        _GetCartPageA
        sta   -1,x
        sta   ,x

        ; set scroll parameters
        lda   #4
        sta   scroll_wait_frames
        _ldd  10,12
        sta   scroll_vp_h_tiles
        stb   scroll_vp_v_tiles
        _ldd  10,14
        sta   scroll_vp_x_pos
        stb   scroll_tile_width
        _ldd  14,128                   ; ! MAP WIDTH !
        sta   scroll_tile_height
        stb   scroll_map_width
        clr   scroll_map_x_pos

        ; register object wave
        ldd   #Level_data
        std   object_wave_data
        std   object_wave_data_start
        _GetCartPageA
        sta   object_wave_data_page
        rts

Tls_lvl01
        INCLUDEGEN Tls_lvl01 buffer
        ; pre-rendered tilemap buffer
        ; free    (byte) reserved for future use - can be used for layer information
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile in the map]

Tls_lvl01_s
        INCLUDEGEN Tls_lvl01_s buffer
        ; pre-rendered tilemap buffer
        ; free    (byte) reserved for future use - can be used for layer information
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile in the map]

Level_data
        INCLUDE "./objects/levels/01/object-wave/object-wave.asm"