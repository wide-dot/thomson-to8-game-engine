        INCLUDE "./engine/macros.asm"

LevelInit

        ; register map location to main
        ldd   #Tls_lvl05_s
        std   scroll_map_odd
        _GetCartPageA
        sta   scroll_map_page_odd
        rts

Tls_lvl05_s
        INCLUDEGEN Tls_lvl05_s buffer
        ; pre-rendered tilemap buffer
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile in the map]
