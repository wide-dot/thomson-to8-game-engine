
_objectManager.new.u MACRO
    jsr   LoadObject_u
    lda   \1
    sta   id,u
    ENDM

_objectManager.new.x MACRO
    jsr   LoadObject_x
    lda   \1
    sta   id,x
    ENDM    

_object.routines.init MACRO
    lda   routine,u
    asla
    ldx   \1
    jmp   [a,x]  
    ENDM     

_object.routines.next MACRO
    inc routine,u
    ENDM      

_music.init.SN76489 MACRO
    ldx   \1
    ldb   \2
    ldy   \3
    jsr   vgc_init 
    ENDM

_music.init.YM2413 MACRO
    ldx   \1
    ldb   \2
    ldy   \3
    jsr   YVGM_PlayMusic 
    ENDM

_music.init.IRQ    MACRO
    jsr   IrqInit
    ldd   \1
    std   Irq_user_routine
    lda   \2                     
    ldx   \3
    jsr   IrqSync
    jsr   IrqOn  
    ENDM

_gameMode.init MACRO
    jsr   InitGlobals
    jsr   InitStack
    jsr   LoadAct
    jsr   InitJoypads
    lda   \1
    sta   glb_Cur_Game_Mode
    ENDM   



_image.set.u MACRO
        ldd   \1   
        std   image_set,u
        ldd   \2
        std   xy_pixel,u
        ldb   \3
        stb   priority,u
        lda   render_flags,u
        ora   \4
        sta   render_flags,u
        ENDM    

_image.update.u MACRO
        ldd   \1   
        std   image_set,u    
        ENDM            

_palette.set MACRO
        ldd   \1
        std   Pal_current
        ENDM   

_palette.show MACRO
        clr   PalRefresh
        jsr   PalUpdateNow
        ENDM     

_palette.fade MACRO                    
        jsr   LoadObject_x
        stx   \3
        lda   #ObjID_PaletteFade
        sta   id,x                 
        ldd   \1
        std   o_fade_src,x     ; _src
        ldd   \2
        std   o_fade_dst,x   ; _dest 
        ldd   \4
        std   o_fade_sleep,x   ; _sleep time before start
        ldd   \5
        std   o_fade_callback,x   ; _callback
        ldd   \6
        std   o_fade_unload,x   ; _unload

        ENDM

_joysticks.test MACRO
        ldb   \1
        bitb  \2
        ENDM        