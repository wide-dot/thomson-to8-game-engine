        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************
        INCLUDE "./GameMode/LostWoods/LostWoodsRamData.equ"    
        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"        
        org   $6100

        jsr   LoadAct

        jsr   YM2413_DrumModeOn
        jsr   IrqSet50Hz
        ldx   #Smps_Zelda
        jsr   PlayMusic 

* ==============================================================================
* Intro
* ==============================================================================
IntroMainLoop
        jsr   WaitVBL   
        jsr   UpdatePalette
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

	ldd   #Black_palette
	std   Cur_palette
        clr   Refresh_palette
        jsr   WaitVBL   
        jsr   UpdatePalette		

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
@a	jsr   ClearObj
	leau  object_size,u
	cmpu  #Object_RAM_End
	bne   @a
        lda   #ObjID_Link	
	sta   LinkData
	ldu   #Tbl_Priority_First_Entry_0
        ldd   #0
@b	std   ,u++
	cmpu  #DPS_buffer_end
	bne   @b
	ldd   #Lst_Priority_Unset_0+2
	std   Lst_Priority_Unset_0
	ldd   #Lst_Priority_Unset_1+2
	std   Lst_Priority_Unset_1

	ldd   #Pal_LostWoods1
	std   Cur_palette
        clr   Refresh_palette	

        _RunObjectRoutine ObjID_Tilemap,glb_current_submap       

* ==============================================================================
* Main Loop
* ==============================================================================
LevelMainLoop
        jsr   WaitVBL   
        jsr   UpdatePalette
        jsr   ReadJoypads
        jsr   AutoScroll
        jsr   RunObjects
        _RunObjectRoutine ObjID_Tilemap,glb_current_submap
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawTilemap
        jsr   DrawSprites        
        bra   LevelMainLoop

* ==============================================================================
* Game Mode RAM variables
* ==============================================================================
        
        INCLUDE "./GameMode/LostWoods/LostWoodsRamData.asm"       

* ==============================================================================
* Routines
* ==============================================================================
        INCLUDE "./Engine/Ram/BankSwitch.asm"
        INCLUDE "./Engine/Graphics/WaitVBL.asm"
        INCLUDE "./Engine/Graphics/AnimateSprite.asm"	
        INCLUDE "./Engine/Graphics/DisplaySprite.asm"	
        INCLUDE "./Engine/Graphics/CheckSpritesRefresh.asm"
        INCLUDE "./Engine/Graphics/EraseSprites.asm"
        INCLUDE "./Engine/Graphics/UnsetDisplayPriority.asm"
        INCLUDE "./Engine/Graphics/DrawSpritesExtEnc.asm"
        INCLUDE "./Engine/Graphics/BgBufferAlloc.asm"	
        INCLUDE "./Engine/Joypad/ReadJoypads.asm"
        INCLUDE "./Engine/Irq/IrqSmpsJoypad.asm"        
        INCLUDE "./Engine/Sound/Smps.asm"
        INCLUDE "./Engine/ObjectManagement/RunObjects.asm"
        INCLUDE "./Engine/ObjectManagement/DeleteObject.asm"
        INCLUDE "./Engine/ObjectManagement/ClearObj.asm"
        INCLUDE "./Engine/ObjectManagement/RunPgSubRoutine.asm"
	INCLUDE "./Engine/ObjectManagement/SingleObjLoad.asm"
        INCLUDE "./Engine/Ram/ClearDataMemory.asm"
        INCLUDE "./Engine/Palette/UpdatePalette.asm"
        INCLUDE "./Engine/Graphics/Camera/AutoScroll.asm"
        INCLUDE "./Engine/Graphics/Tilemap/Tilemap.asm"
        INCLUDE "./Engine/Graphics/GetImgIdA.asm"
        INCLUDE "./Engine/Graphics/Codec/DecRLE00.asm"
zx0_decompress rts	
