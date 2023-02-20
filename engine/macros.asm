_ldd MACRO
        ldd   #((\1)*256)+\2
 ENDM
 
_ldx MACRO
        ldx   #((\1)*256)+\2
 ENDM
 
_ldy MACRO
        ldy   #((\1)*256)+\2
 ENDM
 
_ldu MACRO
        ldu   #((\1)*256)+\2
 ENDM  
 
_lds MACRO
        lds   #((\1)*256)+\2
 ENDM   
 
_SetCartPageA MACRO
 IFDEF T2
        jsr   SetCartPageA
 ELSE
        sta   $E7E6                    ; selection de la page RAM en zone cartouche
 ENDC
 ENDM      
 
_GetCartPageA MACRO
 IFDEF T2
        jsr   GetCartPageA
 ELSE
        lda   $E7E6
 ENDC
 ENDM

_SetCartPageB MACRO
 IFDEF T2
        jsr   SetCartPageB
 ELSE
        stb   $E7E6                    ; selection de la page RAM en zone cartouche
 ENDC
 ENDM      
 
_GetCartPageB MACRO
 IFDEF T2
        jsr   GetCartPageB
 ELSE
        ldb   $E7E6
 ENDC
 ENDM     

_RunObjectSwap MACRO
        ; param 1 : ObjID_
        ; param 2 : Object data RAM address
        ; manual launch of an object from a different dynamic memory page and not from the resident page 1
        lda   Obj_Index_Page+\1
        sta   PSR_Page   
        ldd   Obj_Index_Address+2*\1
        std   PSR_Address       
        ldu   \2             
        jsr   RunPgSubRoutine
 ENDM    

_RunObjectSwapRoutine MACRO
        ; param 1 : ObjID_
        ; param 2 : Object routine
        ; manual launch of an object from a different dynamic memory page and not from the resident page 1
        lda   Obj_Index_Page+\1   
        sta   PSR_Page   
        ldd   Obj_Index_Address+2*\1
        std   PSR_Address       
        ldb   \2        
        jsr   RunPgSubRoutine
 ENDM 
 
_MountObject MACRO 
        ; param 1 : ObjID_
        ; manual mount of an object from the resident page 1
        lda   Obj_Index_Page+\1
        _SetCartPageA
        ldx   Obj_Index_Address+2*\1
 ENDM

_RunObject MACRO 
        ; param 1 : ObjID_
        ; param 2 : Object data RAM address
        ; manual launch of an object from the resident page 1
        _MountObject \1
        ldu   \2        
        jsr   ,x
 ENDM

_RunObjectRoutineA MACRO 
        ; param 1 : ObjID_
        ; param 2 : Object routine
        ; manual launch of an object from the resident page 1
	; this object does not need or have a data structure for this routine
        _MountObject \1
        lda   \2        
        jsr   ,x
 ENDM

_RunObjectRoutineB MACRO 
        ; param 1 : ObjID_
        ; param 2 : Object routine
        ; manual launch of an object from the resident page 1
	; this object does not need or have a data structure for this routine
        _MountObject \1
        ldb   \2        
        jsr   ,x
 ENDM

_SwitchScreenBuffer MACRO
        ldb   $E7E5
        eorb  #1                       ; switch btw page 2 and 3
        orb   #$02
        stb   $E7E5
 ENDM

_asld MACRO
        aslb
        rola
 ENDM        
 
_asrd MACRO
        asra
        rorb
 ENDM      
 
_lsld MACRO
        lslb
        rola
 ENDM        
 
_lsrd MACRO
        lsra
        rorb
 ENDM
 
_rold MACRO
        rolb
        rola
 ENDM    
 
_rord MACRO
        rora
        rorb
 ENDM

_negd MACRO
        nega
        negb
        sbca  #0
 ENDM

_cba MACRO
        pshs  b
        cmpa  ,s+
 ENDM

_aba MACRO
        pshs  b
        adda  ,s+
 ENDM

_sba MACRO
        pshs  b
        suba  ,s+
 ENDM

_cab MACRO
        pshs  a
        cmpb  ,s+
 ENDM

_aab MACRO
        pshs  a
        addb  ,s+
 ENDM

_sab MACRO
        pshs  a
        subb  ,s+
 ENDM

_breakpoint MACRO
 IFDEF DEBUG
        pshs  CC
        sta   >$ffff
        puls  CC
 ENDC
 ENDM