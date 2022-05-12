	opt   c,ct
	INCLUDE "./generated-code/TitleScreen/FD/main-engine.glb"
	INCLUDE "./generated-code/TitleScreen/FD/SonicAndTailsIn/SonicAndTailsIn_ImageSet.glb"
	org   $3E58
	setdp $FF

; ---------------------------------------------------------------------------
; Object - SonicAndTailsIn
;
; Display Sonic And Tails In ... message
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------
        
        INCLUDE "./Engine/Macros.asm"      
        
Obj_PaletteFade      equ Object_RAM+(object_size*1)        
        
SonicAndTailsIn
        lda   routine,u
        asla
        ldx   #SATI_Routines
        jmp   [a,x]

SATI_Routines
        fdb   SATI_clearScreen
        fdb   SATI_fadeIn
        fdb   SATI_fadeOut        
        fdb   SATI_Wait
        fdb   SATI_End
 
SATI_clearScreen
        ldx   #$0000
        jsr   ClearDataMem        
        
        ldd   #Img_SonicAndTailsIn
        std   image_set,u
        
        ldd   #$807F
        std   xy_pixel,u
        
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u   
        
        ldb   #1
        stb   priority,u     
        
        inc   routine,u

        jmp   DisplaySprite

SATI_fadeIn
        ldx   #$0000
        jsr   ClearDataMem        

        ldx   #Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x                 
        ldd   Cur_palette
        std   ext_variables,x
        ldd   #Pal_SonicAndTailsIn
        std   ext_variables+2,x    
        
        inc   routine,u

        ldd   #$0000
        std   glb_Main_runcount           
              
        jmp   DisplaySprite    
                
SATI_fadeOut
        ldd   glb_Main_runcount
        cmpd  #3*50 ; 3 seconds
        beq   SATI_fadeOut_continue
        rts

SATI_fadeOut_continue        
        ldx   #Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x                 
        ldd   Cur_palette
        std   ext_variables,x
        ldd   #Black_palette
        std   ext_variables+2,x  
          
        inc   routine,u    
        rts                
                
SATI_Wait
        ldx   #Obj_PaletteFade
        tst   ,x
        beq   SATI_clearScreen_end
        rts
        
SATI_clearScreen_end
        ldx   #$FFFF
        jsr   ClearDataMem
        
        lda   $E7DD                    * set border color
        anda  #$F0
        adda  #$01                     ; color 1
        sta   $E7DD
        anda  #$01                     ; color 1
        adda  #$80
        sta   glb_screen_border_color+1    * maj WaitVBL
                     
        inc   routine,u    
        rts            
                
SATI_End
        ldx   #$FFFF
        jsr   ClearDataMem  
        jsr   DeleteObject                    
        _ldd  ObjID_TitleScreen,$01                   ; Replace this object with Title Screen Object subtype 3
        std   ,u
        ldu   #Obj_PaletteFade
        jsr   ClearObj        
        rts  
                        
