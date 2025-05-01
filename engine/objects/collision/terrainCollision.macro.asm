_terrainCollision.init MACRO
        lda   Obj_Index_Page+\1
        sta   terrainCollision.main.page 
        sta   terrainCollision.main.xAxis.page
        ldd   Obj_Index_Address+2*\1
        std   terrainCollision.main.address
        addd  #3
        std   terrainCollision.main.xAxis.address
 ENDM    
