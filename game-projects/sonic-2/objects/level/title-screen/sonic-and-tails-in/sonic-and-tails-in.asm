; ---------------------------------------------------------------------------
; Object - SonicAndTailsIn
;
; Display Sonic And Tails In ... message
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------
        
        INCLUDE "./engine/macros.asm"      
        
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
        
        ldd   #$7F7F
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

        jsr   LoadObject_x
        stx   Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x                 
        ldd   Pal_current
        std   ext_variables,x
        ldd   #Pal_SonicAndTailsIn
        std   ext_variables+2,x    
        
        inc   routine,u

        ldd   #$0000
        std   gfxlock.bufferSwap.count           
              
        jmp   DisplaySprite    
                
SATI_fadeOut
        ldd   gfxlock.bufferSwap.count
        cmpd  #3*50 ; 3 seconds
        beq   SATI_fadeOut_continue
        rts

SATI_fadeOut_continue        
        jsr   LoadObject_x
        stx   Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x                 
        ldd   Pal_current
        std   ext_variables,x
        ldd   #Pal_black
        std   ext_variables+2,x  
          
        inc   routine,u    
        rts                
                
SATI_Wait
        ldx   Obj_PaletteFade
        lda   ,x
        cmpa  #ObjID_PaletteFade
        bne   SATI_clearScreen_end
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
        sta   gfxlock.screenBorder.color
                     
        inc   routine,u    
        rts            
                
SATI_End
        ldx   #$FFFF
        jsr   ClearDataMem  
        jsr   DeleteObject 
        jsr   LoadObject_u                   
        _ldd  ObjID_TitleScreen,$01                   ; Replace this object with Title Screen Object subtype 3
        std   ,u
        rts  
                        
Obj_PaletteFade      fdb   0