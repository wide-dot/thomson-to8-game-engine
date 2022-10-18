        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
        INCLUDE "./game-mode/LostWoods/LostWoodsRamData.equ"    
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        
        org   $6100
        
        jsr   InitGlobals        
        jsr   LoadAct

        jsr   IrqInit
        ldd   #UserIRQ_Smps
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        jsr   YM2413_DrumModeOn
        ldx   #Smps_Zelda
        jsr   PlayMusic 

* ==============================================================================
* Intro
* ==============================================================================
IntroMainLoop
        jsr   WaitVBL   
        jsr   ReadJoypads
        ldb   Fire_Press
        bitb  #c1_button_A_mask
        bne   InitLevelMainLoop
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites        
        bra   IntroMainLoop

InitLevelMainLoop

        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
        jsr   WaitVBL        

        ldb   #$02                     * load page 2
        stb   $E7E5                    * in data space ($A000-$DFFF)
        ldx   #$EEEE                   * set Background solid color
        jsr   ClearDataMem
        lda   $E7DD                    * set border color
        anda  #$F0
        adda  #$0E                     * color ref
        sta   $E7DD
        anda  #$0F
        adda  #$80
        sta   glb_screen_border_color+1    * maj WaitVBL
        jsr   WaitVBL
        ldb   #$03                     * load page 3
        stb   $E7E5                    * data space ($A000-$DFFF)
        ldx   #$EEEE                   * set Background solid color
        jsr   ClearDataMem

        ; TODO put this as two routines in engine, one for cleaning all objects, another for cleaning Display priority data
        ldu   #Object_RAM
@a      jsr   ClearObj
        leau  object_size,u
        cmpu  #Object_RAM_End
        bne   @a
        lda   #ObjID_Link        
        sta   LinkData
        ldu   #Tbl_Priority_First_Entry_0
        ldd   #0
@b      std   ,u++
        cmpu  #DPS_buffer_end
        bne   @b
        ldd   #Lst_Priority_Unset_0+2
        std   Lst_Priority_Unset_0
        ldd   #Lst_Priority_Unset_1+2
        std   Lst_Priority_Unset_1

        ldd   #Pal_LostWoods1
        std   Pal_current
        clr   PalRefresh        

        _RunObjectRoutineA ObjID_Tilemap,glb_current_submap       

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL   
        jsr   ReadJoypads
        jsr   AutoScroll
        jsr   RunObjects
        _RunObjectRoutineA ObjID_Tilemap,glb_current_submap
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawTilemap
        jsr   DrawSprites        
        bra   LevelMainLoop

UserIRQ_Smps
        jsr   PalUpdateNow
        jmp   MusicFrame

* ==============================================================================
* Game Mode RAM variables
* ==============================================================================
        
        INCLUDE "./game-mode/LostWoods/LostWoodsRamData.asm"       

* ==============================================================================
* Routines
* ==============================================================================

        ; gfx rendering
        INCLUDE "./engine/graphics/Codec/DecRLE00.asm"
        INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"        
        
        ; basic object management
        INCLUDE "./engine/object-management/ClearObj.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/object-management/SingleObjLoad.asm"

        ; utilities
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/palette/color/Pal_Black.asm"
        INCLUDE "./engine/palette/color/Pal_white.asm"
        
        ; animation & image
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"            
        INCLUDE "./engine/graphics/image/GetImgIdA.asm"

        ; tilemap
        INCLUDE "./engine/graphics/Camera/AutoScroll.asm"
        INCLUDE "./engine/graphics/Tilemap/Tilemap.asm"

        ; sound
        INCLUDE "./engine/irq/Irq.asm"        
        INCLUDE "./engine/sound/Smps.asm"
