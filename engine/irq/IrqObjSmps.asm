* ---------------------------------------------------------------------------
* IrqObjSmps
* ----------
* IRQ Subroutine to run smps driver as an object
*
* input REG : [none]
* reset REG : [a,x]
*
* feature request - whith the new builder architecture, it will be possible
* to make a direct call without the need of an address table
* it should also be possible to store and execute objects in ROM instead
* of RAM
*
* ---------------------------------------------------------------------------
        setdp $E7
IrqObjSmps
        lda   Obj_Index_Page+ObjID_Smps
        sta   <$E6                                    ; mount Smps page in RAM

        lda   #4                                      ; Smps MusicFrame routine id
        ldx   Obj_Index_Address+2*ObjID_Smps          ; load page and addr of sound routine
        jmp   ,x                                      ; Call Smps sound driver and return

SmpsVar STRUCT
SFXPriorityVal                 rmb   1        
TempoTimeout                   rmb   1        
CurrentTempo                   rmb   1                ; Stores current tempo value here
StopMusic                      rmb   1                ; Set to 7Fh to pause music, set to 80h to unpause. Otherwise 00h
FadeOutCounter                 rmb   1        
FadeOutDelay                   rmb   1        
QueueToPlay                    rmb   1                ; if NOT set to 80h, means new index was requested by 68K
SFXToPlay                      rmb   1                ; When Genesis wants to play "normal" sound, it writes it here
VoiceTblPtr                    rmb   2                ; address of the voices
SFXVoiceTblPtr                 rmb   2                ; address of the SFX voices
FadeInFlag                     rmb   1        
FadeInDelay                    rmb   1        
FadeInCounter                  rmb   1        
1upPlaying                     rmb   1        
TempoMod                       rmb   1        
TempoTurbo                     rmb   1                ; Stores the tempo if speed shoes are acquired (or 7Bh is played anywho)
SpeedUpFlag                    rmb   1        
DACEnabled                     rmb   1                
60HzData                       rmb   1                ; 1: play 60hz track at 50hz, 0: do not skip frames
 ENDSTRUCT

SmpsStructStart
Smps          SmpsVar
        org   SmpsStructStart                
        fill  0,sizeof{SmpsVar}

        setdp dp/256