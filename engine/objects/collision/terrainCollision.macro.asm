_terrainCollision.init MACRO
        lda   Obj_Index_Page+\1
        sta   terrainCollision.main.page 
        sta   terrainCollision.main.xAxis.doRight.page
        sta   terrainCollision.main.xAxis.doLeft.page
        sta   terrainCollision.main.update.page
        ldd   Obj_Index_Address+2*\1
        std   terrainCollision.main.address
        addd  #3
        std   terrainCollision.main.xAxis.doRight.address
        addd  #3
        std   terrainCollision.main.xAxis.doLeft.address
        addd  #3
        std   terrainCollision.main.update.address
 ENDM    
