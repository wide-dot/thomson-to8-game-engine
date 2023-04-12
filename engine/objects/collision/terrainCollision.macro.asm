_terrainCollision.init MACRO
        lda   Obj_Index_Page+\1
        sta   terrainCollision.main.page 
        ldd   Obj_Index_Address+2*\1
        std   terrainCollision.main.address
 ENDM    
