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
        tsta
        bpl   RAMPg@
        sta   glb_Page
        
        lda   $E7E6
        anda  #$DF                     ; passe le bit5 a 0 pour cartouche au lieu de 1 pour RAM
        sta   $E7E6
        
        lda   #$F0                     ; sortie du mode commande T.2
        sta   $0555                    ; dans le cas ou l'irq intervient en cours de changement de page
                
        lda   #$AA                     ; sequence pour commutation de page T.2
        sta   $0555
        lda   #$55
        sta   $02AA
        lda   #$C0
        sta   $0555
        lda   glb_Page
        anda  #$7F                     ; le bit 7 doit etre a 0        
        sta   $0555                    ; selection de la page T.2 en zone cartouche
        bra   End@
RAMPg@  sta   glb_Page                 ; selection de la page RAM en zone cartouche (bit 5 integre au numero de page)
        sta   $E7E6 
End@    equ   *
 ELSE
        sta   $E7E6                    ; selection de la page RAM en zone cartouche
 ENDC
 ENDM      
 
_GetCartPageA MACRO
 IFDEF T2
        lda   glb_Page
 ELSE
        lda   $E7E6
 ENDC
 ENDM

_SetCartPageB MACRO
 IFDEF T2
        tstb
        bpl   RAMPg@
        stb   glb_Page
        
        ldb   $E7E6
        andb  #$DF                     ; passe le bit5 a 0 pour cartouche au lieu de 1 pour RAM
        stb   $E7E6
        
        ldb   #$F0                     ; sortie du mode commande T.2
        stb   $0555                    ; dans le cas ou l'irq intervient en cours de changement de page
                
        ldb   #$AA                     ; sequence pour commutation de page T.2
        stb   $0555
        ldb   #$55
        stb   $02AA
        ldb   #$C0
        stb   $0555
        ldb   glb_Page
        andb  #$7F                     ; le bit 7 doit etre a 0
        stb   $0555                    ; selection de la page T.2 en zone cartouche
        bra   End@
RAMPg@  stb   glb_Page                 ; selection de la page RAM en zone cartouche (bit 5 integre au numero de page)
        stb   $E7E6 
End@    equ   *
 ELSE
        stb   $E7E6                    ; selection de la page RAM en zone cartouche
 ENDC
 ENDM      
 
_GetCartPageB MACRO
 IFDEF T2
        ldb   glb_Page
 ELSE
        ldb   $E7E6
 ENDC
 ENDM     

_RunPgSubRoutine MACRO
        ; param 1 : ObjID_
        ; param 2 : Object data RAM address
        ; manual launch of an object from a different dynamic memory page and not from the resident page 1
        
        ldx   #Obj_Index_Page
        ldb   #\1   
        abx
        lda   ,x                       ; memory page routine
        
        ldx   #Obj_Index_Address
        aslb
        abx        
        ldu   ,x                       ; address routine
        stu   glb_Address        
        
        ldu   #\2              
        jsr   RunPgSubRoutine
 ENDM           
 
_RunObject MACRO 
        ldx   #Obj_Index_Page
        ldb   #\1   
        abx
        lda   ,x                       ; memory page routine
        _SetCartPageA                  ; set data page for sub routine to call
                
        ldx   #Obj_Index_Address
        aslb
        abx
        ldu   #\2        
        jsr   [,x]
 ENDM

_RunObjectRoutine MACRO 
        ldx   #Obj_Index_Page
        ldb   #\1   
        abx
        lda   ,x                       ; memory page routine
        _SetCartPageA                  ; set data page for sub routine to call
                
        ldx   #Obj_Index_Address
        aslb
        abx
        lda   \2        
        jsr   [,x]
 ENDM

_MountObject MACRO 
        ldx   #Obj_Index_Page
        ldb   #\1   
        abx
        lda   ,x                       ; memory page routine
        _SetCartPageA                  ; set data page to access object data
                
        ldx   #Obj_Index_Address
        aslb
        abx
        ldx   ,x
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