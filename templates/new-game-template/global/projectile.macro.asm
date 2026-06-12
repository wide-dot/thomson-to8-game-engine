_loadFirePreset MACRO
        lda   Obj_Index_Page+ObjID_loadFirePreset
        sta   PSR_Page   
        ldx   Obj_Index_Address+2*ObjID_loadFirePreset
        stx   PSR_Address   
        lda   #0                       
        sta   PSR_Param
        jsr   RunPgSubRoutine
 ENDM    

_loadFirePresetBug MACRO
        lda   Obj_Index_Page+ObjID_loadFirePreset
        sta   PSR_Page   
        ldy   Obj_Index_Address+2*ObjID_loadFirePreset
        sty   PSR_Address                  
        lda   #2              
        sta   PSR_Param
        jsr   RunPgSubRoutine
 ENDM    
