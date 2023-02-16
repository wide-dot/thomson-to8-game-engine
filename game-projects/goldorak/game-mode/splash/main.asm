    INCLUDE "./global/global-preambule-includes.asm"

    ORG   $6100
    
* ============================================================================== 
* Init
* ============================================================================== 
    _GameModeInit #GmID_splash
    _MusicInit_SN76489 #Vgc_introSN,#vgc_stream_buffers,#MUSIC_LOOP ; initialize the SN76489 vgm player with a vgc data stream
    _MusicInit_YM2413 #Vgc_introYM,#MUSIC_LOOP                      ; initialize the YM2413 player 
    _MusicInit_IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame         ; Setting IRQ for music
    _NewManagedObject_U #ObjID_Splash
    
    _SetPalette #Pal_black
    _ShowPalette

    _PaletteFade #Pal_black,#Palette_splash,PALETTE_FADER,#$60,#NO_CALLBACK,#$FF ; FF = UNLOAD !

* ============================================================================== *
* MainLoop
* ==============================================================================
MainLoop
    jsr   ReadJoypads
    jsr   RunObjects
    jsr   CheckSpritesRefresh
    jsr   EraseSprites
    jsr   UnsetDisplayPriority
    jsr   DrawSprites
    jsr   WaitVBL
    bra   MainLoop

UserIRQ
    jsr   PalUpdateNow
    jsr   YVGM_MusicFrame
    jmp   vgc_update    

DoChangeGameMode
        jsr IrqOff
        jsr sn_reset
        jsr YVGM_SilenceAll 
        lda #GmID_gamescreen
        sta NEXT_GAME_MODE
        lda #GmID_loading
        sta GameMode
        jsr LoadGameModeNow 
        rts       

* ============================================================================== 
* INCLUDES
* ==============================================================================  
    INCLUDE "./game-mode/splash/ram-data.asm"

     ; bg images & sprites
    INCLUDE "./engine/graphics/codec/DecRLE00.asm"
    INCLUDE "./engine/graphics/codec/zx0_mega.asm" 
    INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"
    INCLUDE "./engine/palette/color/Pal_white.asm"
    INCLUDE "./engine/palette/color/Pal_black.asm"

    INCLUDE "./global/global-trailer-includes.asm"
    
    

