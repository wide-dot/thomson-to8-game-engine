        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256

Icon
        lda   routine,u
        asla
        ldx   #Icon_Routines
        jmp   [a,x]

Icon_Routines
        fdb   Icon_Init
        fdb   Icon_Main

Icon_Init    
        ldd   #$807F
        std   xy_pixel,u
        ldb   #1
        stb   priority,u  
        inc   routine,u
Icon_Main
        lda   Current_Zone
        asla
        ldx   #Icon_Img
        ldd   a,x
        std   image_set,u
        jmp   DisplaySprite

Icon_Img
        fdb   Img_IcoEHZ
        fdb   Img_IcoCPZ
        fdb   Img_IcoARZ
        fdb   Img_IcoCNZ
        fdb   Img_IcoHTZ
        fdb   Img_IcoMCZ
        fdb   Img_IcoHPZ
        fdb   Img_IcoOCZ
        fdb   Img_IcoMTZ
        fdb   Img_IcoMTZ
        fdb   Img_IcoSCZ
        fdb   Img_IcoWFZ
        fdb   Img_IcoDEZ
        fdb   Img_IcoSPECIAL
        fdb   Img_IcoSOUND
        fdb   Img_IcoSOUND
