        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256
tile_xy equ   glb_d1
tile_x  equ   glb_d1
tile_y  equ   glb_d1_b

LevelSelect
        lda   routine,u
        asla
        ldx   #LevelSelect_Routines
        jmp   [a,x]

LevelSelect_Routines
        fdb   LevelSelect_Init
        fdb   LevelSelect_Main

LevelSelect_Init
        ldd   #Ani_Wings
        std   anim,u
        ldd   #$7F7F
        std   xy_pixel,u
        ldb   #1
        stb   priority,u  
        inc   routine,u

LevelSelect_Main
        jsr   AnimateSprite
        jsr   GetImgIdA
        ldb   #120 ; a screen is 120 tiles
        mul
        ldy   #map_ls ; load position on map (4 frames of 250 tiles id)
        leay  d,y
        _ldd  10,12
        std   tile_xy ; store x and y cpt in dp
        pshs  u
        ldu   #$A000+(4*40)  ; set position at top left screen + line 4
        stu   glb_screen_location_1
        ldu   #$C000+(4*40)
        stu   glb_screen_location_2
        ldx   #tiles_ls
@loop   ldu   glb_screen_location_2
        ldb   ,y+
        aslb
        pshs  x,y
        abx
        jsr   [,x]
        puls  x,y
        ldd   glb_screen_location_1 ; move position one tile to the right
        addd  #4 ; tile width is 16px
        std   glb_screen_location_1
        addd  #$2000
        std   glb_screen_location_2
        dec   tile_x
        bne   @loop
        ldd   glb_screen_location_1 ; move position one line to the bottom
        addd  #15*40 ; tile heigth is 16px
        std   glb_screen_location_1
        addd  #$2000
        std   glb_screen_location_2
        lda   #10 ; nb of tiles in a row
        sta   tile_x
        dec   tile_y
        bne   @loop
        puls  u
        jmp   DisplaySprite

ls_last_frame fdb -1

map_ls
        INCLUDEBIN "./objects/level/level-select/level-select/map/map.bin"

        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00000_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00001_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00002_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00003_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00004_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00005_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00006_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00007_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00008_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00009_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00010_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00011_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00012_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00013_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00014_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00015_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00016_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00017_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00018_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00019_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00020_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00021_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00022_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00023_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00024_DN0.asm"

tiles_ls
        fdb adr_img_ls00000_DN0
        fdb adr_img_ls00001_DN0
        fdb adr_img_ls00002_DN0
        fdb adr_img_ls00003_DN0
        fdb adr_img_ls00004_DN0
        fdb adr_img_ls00005_DN0
        fdb adr_img_ls00006_DN0
        fdb adr_img_ls00007_DN0
        fdb adr_img_ls00008_DN0
        fdb adr_img_ls00009_DN0
        fdb adr_img_ls00010_DN0
        fdb adr_img_ls00011_DN0
        fdb adr_img_ls00012_DN0
        fdb adr_img_ls00013_DN0
        fdb adr_img_ls00014_DN0
        fdb adr_img_ls00015_DN0
        fdb adr_img_ls00016_DN0
        fdb adr_img_ls00017_DN0
        fdb adr_img_ls00018_DN0
        fdb adr_img_ls00019_DN0
        fdb adr_img_ls00020_DN0
        fdb adr_img_ls00021_DN0
        fdb adr_img_ls00022_DN0
        fdb adr_img_ls00023_DN0
        fdb adr_img_ls00024_DN0
