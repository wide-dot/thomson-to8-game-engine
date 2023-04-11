        INCLUDE "./engine/macros.asm"

LevelInit

        ; register map location to main
        ldd   #Tls_lvl03
        std   scroll_map_even
        _GetCartPageA
        sta   scroll_map_page_even

        ; set scroll parameters
        _ldd  12,15
        sta   scroll_vp_h_tiles
        stb   scroll_vp_v_tiles
        _ldd  8,11
        sta   scroll_vp_x_pos
        stb   scroll_vp_y_pos
        _ldd  12,12
        sta   scroll_tile_width
        stb   scroll_tile_height
        ldd   #$0030 ; 8.8 scroll speed, r-type arcade scroll is 0,5px / frame so here (256*0.5)/(384/144)
        std   scroll_vel
        rts

Tls_lvl03
        INCLUDEGEN Tls_lvl03 buffer
        ; pre-rendered tilemap buffer
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile in the map]
