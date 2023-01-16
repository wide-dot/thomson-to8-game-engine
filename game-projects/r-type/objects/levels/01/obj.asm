        INCLUDE "./engine/macros.asm"

Level
        lda   routine,u
        asla
        ldx   #Level_Routines
        jmp   [a,x]

Level_Routines
        fdb   Level_Init_0
        fdb   Level_Init_1
        fdb   Level_End

Level_Init_0
        ldd   #Img_lvl01_init
        std   image_set,u
	ldd   #$806F
        std   xy_pixel,u
	ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

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
        _ldd  10,12
        sta   scroll_vp_h_tiles
        stb   scroll_vp_v_tiles
        _ldd  10,14
        sta   scroll_vp_x_pos
        stb   scroll_tile_width
        _ldd  14,120
        sta   scroll_tile_height
        stb   scroll_map_width
        clr   scroll_map_x_pos

Level_Init_1
	inc   routine,u
        jmp   DisplaySprite	

Level_End
        jmp   DeleteObject

        align 256
Tls_lvl01
        INCLUDEGEN Tls_lvl01 buffer
        ; pre-rendered tilemap buffer
        ; free    (byte) reserved for future use - can be used for layer information
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile in the map]

        align 256
Tls_lvl01_s
        INCLUDEGEN Tls_lvl01_s buffer
        ; pre-rendered tilemap buffer
        ; free    (byte) reserved for future use - can be used for layer information
        ; page    (byte) page number of compilated tile routine
        ; address (word) absolute address of compilated tile routine
        ; [repeated for each tile in the map]