    INCLUDE "./global/global-preambule-includes.asm"

    ORG   $6100
    
* ============================================================================== 
* Init
* ============================================================================== 
    _gameMode.init #GmID_splash
    _music.init.SN76489 #Vgc_introSN,#MUSIC_LOOP,#0                  ; initialize the SN76489 player
    _music.init.YM2413 #Vgc_introYM,#MUSIC_LOOP,#0                   ; initialize the YM2413 player 
    _music.init.IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame         ; Setting IRQ for music
    _objectManager.new.u #ObjID_Splash  
    _palette.set #Pal_black
    _palette.show
    _palette.fade #Pal_black,#Palette_splash,PALETTE_FADER,#$60,#NO_CALLBACK,#$FF ; FF = UNLOAD !

    ; passage en mode 60 Hz, pour le FUN
    ; LDA $6081
    ; ORA #$20
    ; STA $6081
    ; STA $E7E7

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
    
    

