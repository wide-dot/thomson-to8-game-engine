        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256
tile_xy equ   glb_d1
tile_x  equ   glb_d1
tile_y  equ   glb_d1_b

LevelSelect
        lda   routine,u
        asla
        ldx   #LevelSelect_Routines
        pshs  u
        jsr   [a,x]
        puls  u
        jmp   DisplaySprite

LevelSelect_Routines
        fdb   LevelSelect_Wings
        fdb   LevelSelect_Up
        fdb   LevelSelect_Down
        fdb   LevelSelect_UpWait
        fdb   LevelSelect_DownWait

LevelSelect_Wings    
        ldd   #Img_Wings
        std   image_set,u
        ldd   #$807F
        std   xy_pixel,u
        ldb   #1
        stb   priority,u  
        inc   routine,u
        bra   LevelSelect_Up

LevelSelect_UpWaitInit
        lda   #3
        sta   routine,u
LevelSelect_UpWait
        lda   routine_secondary,u
        ldb   routine_tertiary,u
        incb
        stb   routine_tertiary,u
        cmpb  #26
        bne   LevelSelect_Main
        andb  #0
        stb   routine_tertiary,u
        incb
        stb   routine,u
LevelSelect_Up
        lda   routine_secondary,u
        cmpa  #3
        beq   LevelSelect_DownWaitInit
        inc   routine_secondary,u
        bra   LevelSelect_Main

LevelSelect_DownWaitInit
        ldb   #4
        stb   routine,u
LevelSelect_DownWait
        lda   routine_secondary,u
        ldb   routine_tertiary,u
        incb
        stb   routine_tertiary,u
        cmpb  #26
        bne   LevelSelect_Main
        andb  #0
        stb   routine_tertiary,u
        ldb   #2
        stb   routine,u
LevelSelect_Down
        lda   routine_secondary,u
        cmpa  #0
        beq   LevelSelect_UpWaitInit
        dec   routine_secondary,u

LevelSelect_Main
        asla
        ldb   #250
        mul ; x500
        ldy   #map_ls ; load position on map (4 frames of 250 tiles id)
        leay  d,y
        _ldd  20,25
        std   tile_xy ; store x and y cpt in dp
        ldu   #$A000  ; set position at top left screen
        stu   glb_screen_location_1
        ldu   #$C000
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
        addd  #2
        std   glb_screen_location_1
        ldd   glb_screen_location_2
        addd  #2
        std   glb_screen_location_2
        dec   tile_x
        bne   @loop
        ldd   glb_screen_location_1 ; move position one line to the bottom
        addd  #7*40
        std   glb_screen_location_1
        ldd   glb_screen_location_2
        addd  #7*40
        std   glb_screen_location_2
        lda   #20
        sta   tile_x
        dec   tile_y
        bne   @loop
        rts

map_ls
        INCLUDEBIN "./objects/level/level-select/level-select/map/ls_back.bin"

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
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00025_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00026_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00027_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00028_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00029_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00030_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00031_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00032_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00033_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00034_DN0.asm"
        INCLUDE "./objects/level/level-select/level-select/tiles/asm/img_ls00035_DN0.asm"

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
        fdb adr_img_ls00025_DN0
        fdb adr_img_ls00026_DN0
        fdb adr_img_ls00027_DN0
        fdb adr_img_ls00028_DN0
        fdb adr_img_ls00029_DN0
        fdb adr_img_ls00030_DN0
        fdb adr_img_ls00031_DN0
        fdb adr_img_ls00032_DN0
        fdb adr_img_ls00033_DN0
        fdb adr_img_ls00034_DN0
        fdb adr_img_ls00035_DN0
