; ---------------------------------------------------------------------------
; Object - SEGA
;
; Play SEGA Intro
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"   

SegaScr_This            equ Object_RAM
Obj_SEGA                equ SegaScr_This
Obj_Trails1             equ SegaScr_This+(object_size*1)
Obj_Trails2             equ SegaScr_This+(object_size*2)
Obj_Trails3             equ SegaScr_This+(object_size*3)
Obj_Trails4             equ SegaScr_This+(object_size*4)
Obj_Sonic1              equ SegaScr_This+(object_size*5)
Obj_Sonic2              equ SegaScr_This+(object_size*6)
Obj_Sonic3              equ SegaScr_This+(object_size*7)
Obj_PaletteFade         equ SegaScr_This+(object_size*8)

* ---------------------------------------------------------------------------
* Object Status Table offsets
* - two variables can share same space if used by two different subtypes
* - take care of words and bytes and space them accordingly
* ---------------------------------------------------------------------------
b_nbFrames              equ ext_variables

* ---------------------------------------------------------------------------
* Subtypes
* ---------------------------------------------------------------------------
Sub_Init        equ 0
Sub_SEGA        equ 1
Sub_Trails      equ 2
Sub_Sonic       equ 3

SEGA_Main
        lda   routine,u
        asla
        ldx   #SEGA_Routines
        jmp   [a,x]

SEGA_Routines
        fdb   SEGA_MainInit
        fdb   SEGA
        fdb   Trails
        fdb   Sonic

SEGA_MainInit
        lda   #2
        sta   priority,u
        lda   subtype,u
        sta   routine,u
        bra   SEGA_Main

Trails
        jmp   DisplaySprite

Sonic
        jsr   AnimateSprite
        jmp   DisplaySprite

SEGA
        lda   routine_secondary,u
        asla
        ldx   #SEGA_SubRoutines
        jmp   [a,x]

SEGA_SubRoutines
        fdb   SEGA_Init
        fdb   SEGA_RunLeft
        fdb   SEGA_MidWipe
        fdb   SEGA_MidWipeWaitPal
        fdb   SEGA_RunRight
        fdb   SEGA_EndWipe
        fdb   SEGA_EndWipeWaitPal
        fdb   SEGA_Wait
        fdb   SEGA_End
        fdb   SEGA_Rts      
        
SEGA_Rts   
        rts

SEGA_Init

        lda   #$E
        sta   b_nbFrames,u

        * Init SEGA logo position
        ldd   #$807F
        std   xy_pixel,u

        * Disable background save
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        * Init all sub objects
        stu   SEGA_Init_01+1
        _ldd  ObjID_SEGA,Sub_Trails
        ldy   #$F080

        ldx   #Obj_Trails1
        std   ,x
        sty   xy_pixel,x
        ldu   #Img_SegaTrails_1
        stu   image_set,x

        ldx   #Obj_Trails2
        std   ,x
        sty   xy_pixel,x
        ldu   #Img_SegaTrails_2
        stu   image_set,x

        ldx   #Obj_Trails3
        std   ,x
        sty   xy_pixel,x
        ldu   #Img_SegaTrails_5
        stu   image_set,x

        ldx   #Obj_Trails4
        std   ,x
        sty   xy_pixel,x
        ldu   #Img_SegaTrails_6
        stu   image_set,x

        _ldd  ObjID_SEGA,Sub_Sonic
        ldy   #$F87B

        ldx   #Obj_Sonic1
        std   ,x
        sty   xy_pixel,x
        ldu   #Ani_SegaSonic_1
        stu   anim,x

        ldx   #Obj_Sonic2
        std   ,x
        sty   xy_pixel,x
        ldu   #Ani_SegaSonic_2
        stu   anim,x

        ldx   #Obj_Sonic3
        std   ,x
        sty   xy_pixel,x
        ldu   #Ani_SegaSonic_3
        stu   anim,x

SEGA_Init_01
        ldu   #$0000

        * Disable backround save on Trails and set x mirror
        ldx   #Obj_Trails1
        lda   render_flags,x
        ora   #render_overlay_mask|render_xmirror_mask
        sta   render_flags,x
        ldb   #3
        stb   priority,x

        ldx   #Obj_Trails2
        sta   render_flags,x
        stb   priority,x

        ldx   #Obj_Trails3
        sta   render_flags,x
        stb   priority,x

        ldx   #Obj_Trails4
        sta   render_flags,x
        stb   priority,x

        * Set x mirror on Sonic
        ldx   #Obj_Sonic1
        lda   status_flags,x
        ora   #status_xflip_mask
        sta   status_flags,x
        ldb   #1
        stb   priority,x

        ldx   #Obj_Sonic2
        sta   status_flags,x
        stb   priority,x

        ldx   #Obj_Sonic3
        sta   status_flags,x
        stb   priority,x

        inc   routine_secondary,u
        rts

SEGA_RunLeft

        dec   b_nbFrames,u
        bmi   SEGA_RunLeft_continue

        ldx   #Obj_Trails1
        lda   x_pixel,x
        suba  #$10
        sta   x_pixel,x
        ldx   #Obj_Trails2
        sta   x_pixel,x
        ldx   #Obj_Trails3
        sta   x_pixel,x
        ldx   #Obj_Trails4
        sta   x_pixel,x

        ldx   #Obj_Sonic1
        lda   x_pixel,x
        suba  #$10
        sta   x_pixel,x
        ldx   #Obj_Sonic2
        sta   x_pixel,x
        ldx   #Obj_Sonic3
        sta   x_pixel,x
        rts

SEGA_RunLeft_continue
        inc   routine_secondary,u

        lda   #$E
        sta   b_nbFrames,u
        rts

SEGA_MidWipe

        * Unset x mirror on Trails
        ldx   #Obj_Trails1
        lda   render_flags,x
        anda   #^render_xmirror_mask
        sta   render_flags,x
        ldb   y_pixel,x
        decb
        stb   y_pixel,x

        ldx   #Obj_Trails2
        sta   render_flags,x
        stb   y_pixel,x

        ldx   #Obj_Trails3
        sta   render_flags,x
        stb   y_pixel,x
        ldy   #Img_SegaTrails_3
        sty   image_set,x

        ldx   #Obj_Trails4
        sta   render_flags,x
        stb   y_pixel,x
        ldy   #Img_SegaTrails_4
        sty   image_set,x

        * Unset x mirror on Sonic
        ldx   #Obj_Sonic1
        lda   status_flags,x
        anda   #^status_xflip_mask
        sta   status_flags,x
        ldb   x_pixel,x
        subb  #$10
        stb   x_pixel,x

        ldx   #Obj_Sonic2
        sta   status_flags,x
        stb   x_pixel,x

        ldx   #Obj_Sonic3
        sta   status_flags,x
        stb   x_pixel,x

        * Set Sega Logo
        ldd   #Img_SegaLogo_1
        std   image_set,u

        * Fade out Trails
        ldx   #Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x
        ldd   #Pal_SEGA
        std   ext_variables,x
        ldd   #Pal_SEGAMid
        std   ext_variables+2,x
        inc   routine_secondary,u

        jmp   DisplaySprite

SEGA_MidWipeWaitPal
        ldx   #Obj_PaletteFade
        tst   ,x
        beq   SEGA_MidWipeWaitPal_continue
        jmp   DisplaySprite

SEGA_MidWipeWaitPal_continue
        inc   routine_secondary,u
        rts

SEGA_RunRight
        dec   b_nbFrames,u
        bmi   SEGA_RunRight_continue

        ldx   #Obj_Trails1
        lda   x_pixel,x
        adda  #$10
        sta   x_pixel,x
        ldx   #Obj_Trails2
        sta   x_pixel,x
        ldx   #Obj_Trails3
        sta   x_pixel,x
        ldx   #Obj_Trails4
        sta   x_pixel,x

        ldx   #Obj_Sonic1
        lda   x_pixel,x
        adda  #$10
        sta   x_pixel,x
        ldx   #Obj_Sonic2
        sta   x_pixel,x
        ldx   #Obj_Sonic3
        sta   x_pixel,x
        rts

SEGA_RunRight_continue
        inc   routine_secondary,u
        rts

SEGA_EndWipe

        * Set Sega Logo
        ldd   #Img_SegaLogo_2
        std   image_set,u

        * Delete Trails and Sonic Sprites
        ldx   #Obj_Trails1
        jsr   DeleteObject_x
        ldx   #Obj_Trails2
        jsr   DeleteObject_x
        ldx   #Obj_Trails3
        jsr   DeleteObject_x
        ldx   #Obj_Trails4
        jsr   DeleteObject_x
        ldx   #Obj_Sonic1
        jsr   DeleteObject_x
        ldx   #Obj_Sonic2
        jsr   DeleteObject_x
        ldx   #Obj_Sonic3
        jsr   DeleteObject_x

        * Fade out Trails
        ldx   #Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x
        ldd   Cur_palette
        std   ext_variables,x
        ldd   #Pal_SEGAEnd
        std   ext_variables+2,x
        
        inc   routine_secondary,u

        jmp   DisplaySprite

SEGA_EndWipeWaitPal
        ldx   #Obj_PaletteFade
        tst   ,x
        beq   SEGA_PlaySample
        jmp   DisplaySprite

SEGA_PlaySample
        inc   routine_secondary,u

        ldy   #Pcm_SEGA
        jsr   PlayDPCM16kHz

        ldd   #$0000
        std   glb_Main_runcount
        rts

SEGA_Wait
        ldd   glb_Main_runcount
        cmpd  #3*50 ; 3 seconds
        beq   SEGA_fadeOut
        rts

SEGA_fadeOut
        ldx   #Obj_PaletteFade
        lda   #ObjID_PaletteFade
        sta   id,x
        ldd   Cur_palette
        std   ext_variables,x
        ldd   #Black_palette
        std   ext_variables+2,x
        inc   routine_secondary,u
        rts

SEGA_End
        ldx   #Obj_PaletteFade
        tst   ,x
        beq   SEGA_return
        rts

SEGA_return
        jsr   DeleteObject  
        _ldd  ObjID_SonicAndTailsIn,$00         ; Replace this object with Title Screen Object subtype 3
        std   ,u

        ldu   #Obj_PaletteFade
        jsr   ClearObj
        rts
