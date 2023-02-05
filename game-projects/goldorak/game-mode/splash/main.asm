    INCLUDE "./global/global-preambule-includes.asm"

    ORG   $6100
    
* ============================================================================== 
* Init
* ============================================================================== 
    _GameModeInit
    _MusicInit_SN76489 #Vgc_intro,#vgc_stream_buffers,#MUSIC_LOOP   ; initialize the SN76489 vgm player with a vgc data stream
    _MusicInit_YM2413 #Vgc_introYM,#MUSIC_LOOP                      ; initialize the YM2413 player 
    _MusicInit_IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame         ; Setting IRQ for music
    _NewManagedObject_U #ObjID_Splash

* ============================================================================== *
* MainLoop
* ==============================================================================
MainLoop
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

* ============================================================================== 
* INCLUDES
* ==============================================================================  
    INCLUDE "./game-mode/splash/ram-data.asm"
    INCLUDE "./global/global-trailer-includes.asm"
    

