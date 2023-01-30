* ---------------------------------------------------------------------------
* PSGlib
* ------------
* Converted to 6809 from:
* PSGlib - Programmable Sound Generator audio library - by sverx
*          https://github.com/sverx/PSGlib
*
* Typical workflow:
* 1) You (or a friend of yours) track one or more module(s) and SFX(s) using either Mod2PSG2 or DefleMask (or whatever you prefer as long as it supports exporting in VGM format).
* 2) Optional, but warmly suggested: optimize your VGM(s) using Maxim's VGMTool
* 3) Convert the VGM to PSG file(s) using the vgm2psg tool.
* 4) Optional, suggested: compress the PSG file(s) using the psgcomp tool. The psgdecomp tool can be used to verify that the compression was right.
* 5) include the library and 'incbin' the PSG file(s) to your Z80 ASM source.
* 6) call PSGInit once somewhere near the beginning of your code.
* 7) Set up a steady interrupt (vertical blanking for instance) so to call PSGFrame and PSGSFXFrame at a constant pace (very important!). The two calls are separated so you can eventually switch banks when done processing background music and need to process SFX.
* 8) Start/stop tunes when needed using PSGPlay and PSGStop calls, start/stop SFXs when needed using PSGSFXPlay and PSGSFXStop calls.
* - Looping SFXs are supported too: fire them using a PSGSFXPlayLoop call, cancel their loop using a PSGSFXCancelLoop call.
* - Tunes can be set to run just once instead of endlessly using PSGPlayNoRepeat call, or set a playing tune to have no more loops using PSGCancelLoop call at any time.
* - To check if a tune is still playing use PSGGetStatus call, to check if a SFX is still playing use PSGSFXGetStatus call.
*
* PSGlib functions reference
* ==========================
* 
* engine initializer function
* ---------------------------
* 
* **PSGInit**: initializes the PSG engine
* - no required parameters
* - no return values
* - destroys A
* 
* functions for music
* -------------------
* 
* **PSGFrame**: processes a music frame
* - no required parameters
* - no return values
* - destroys A,B,X
* 
* **PSGPlay** / **PSGPlayNoRepeat**: starts a tune (playing it repeatedly or only once)
* - *needs* the address of the PSG to start playing in X
* - no return values
* - destroys A
* 
* **PSGStop**: stops (pauses) the music (leaving the SFX on, if one is playing)
* - no required parameters
* - no return values
* - destroys A
* 
* **PSGResume**: resume the previously stopped music
* - no required parameters
* - no return values
* - destroys A
* 
* **PSGCancelLoop**: sets the currently looping music to no more loops after the current
* - no required parameters
* - no return values
* - destroys A
* 
* **PSGGetStatus**: gets the current status of music into register A
* - no required parameters
* - *returns* `PSG_PLAYING` in register A the engine is playing music, `PSG_STOPPED` otherwise.
* 
* functions for SFX
* -----------------
* 
* **PSGSFXFrame**: processes a SFX frame
* - no required parameters
* - no return values
* - destroys A,B,Y
* 
* **PSGSFXPlay** / **PSGSFXPlayLoop**: starts a SFX (playing it once or repeatedly)
* - *needs* the address of the SFX to start playing in X
* - *needs* a mask indicating which channels to be used by the SFX in B. The only possible values are `SFX_CHANNEL2`,`SFX_CHANNEL3` and `SFX_CHANNELS2AND3`.
* - destroys A
* 
* **PSGSFXStop**: stops the SFX (leaving the music on, if music is playing)
* - no required parameters
* - no return values
* - destroys A
* 
* **PSGSFXCancelLoop**: sets the currently looping SFX to no more loops after the current
* - no required parameters
* - no return values
* - destroys A
* 
* **PSGSFXGetStatus**: gets the current status of SFX into register A
* - no required parameters
* - *returns* `PSG_PLAYING` in register A if the engine is playing a SFX, `PSG_STOPPED` otherwise.
* 
* functions for music volume and hardware channels handling
* ---------------------------------------------------------
* 
* **PSGSetMusicVolumeAttenuation**: sets the volume attenuation for the music
* - *needs* the volume attenuation value in A (valid value are 0-15 where 0 means no attenuation and 15 is complete silence)
* - no return values
* - destroys A
* 
* **PSGSilenceChannels**: sets all hardware channels to volume ZERO (useful if you need to pause all audio)
* - no required parameters
* - no return values
* - destroys A
* 
* **PSGRestoreVolumes**: resets silenced hardware channels to previous volume
* - no required parameters
* - no return values
* - destroys A
*
* ---------------------------------------------------------------------------

PSG_STOPPED         equ 0
PSG_PLAYING         equ 1

PSGLatch            equ $80
PSGData             equ $40

PSGChannel0         equ $00
PSGChannel1         equ $20
PSGChannel2         equ $40
PSGChannel3         equ $60
PSGVolumeData       equ $10

PSGWait             equ $38
PSGSubString        equ $08
PSGLoop             equ $01
PSGEnd              equ $00

SFX_CHANNEL2        equ $01 
SFX_CHANNEL3        equ $02 
SFX_CHANNELS2AND3   equ SFX_CHANNEL2|SFX_CHANNEL3 

* ************************************************************************************
* initializes the PSG 'engine'
* destroys A

PSGInit 
        lda   #PSG_STOPPED                            ; ld a,PSG_STOPPED
        sta   PSGMusicStatus                          ; set music status to PSG_STOPPED
        sta   PSGSFXStatus                            ; set SFX status to PSG_STOPPED
        sta   PSGChannel2SFX                          ; set channel 2 SFX to PSG_STOPPED
        sta   PSGChannel3SFX                          ; set channel 3 SFX to PSG_STOPPED
        sta   PSGMusicVolumeAttenuation               ; volume attenuation = none
        rts

* ************************************************************************************
* receives in X the address of the PSG to start playing
* destroys A

PSGPlayNoRepeat 
        lda   #0                                      ; We don't want the song to loop
        bra   PSGPlay1
PSGPlay 
        lda   #1                                      ; the song can loop when finished
PSGPlay1
        sta   PSGLoopFlag
        bsr   PSGStop                                 ; if there's a tune already playing, we should stop it!
        
        lda   ,x   
        sta   PSGMusicPage
        ldx   1,x
        stx   PSGMusicStart                           ; store the begin point of music
        stx   PSGMusicPointer                         ; set music pointer to begin of music
        stx   PSGMusicLoopPoint                       ; looppointer points to begin too
        lda   #0
        sta   PSGMusicSkipFrames                      ; reset the skip frames
        sta   PSGMusicSubstringLen                    ; reset the substring len (for compression)
        lda   #PSGLatch|PSGChannel0|PSGVolumeData|$0F ; latch channel 0, volume=0xF (silent)
        sta   PSGMusicLastLatch                       ; reset last latch to chn 0 volume 0
        lda   #PSG_PLAYING
        sta   PSGMusicStatus                          ; set status to PSG_PLAYING
        rts

* ************************************************************************************
* stops the music (leaving the SFX on, if it's playing)
* destroys A

PSGStop 
        lda   PSGMusicStatus                          ; if it's already stopped, leave
        beq   PSGStop_end
        lda   #PSGLatch|PSGChannel0|PSGVolumeData|$0F ; latch channel 0, volume=0xF (silent)
        sta   SN76489.D
        lda   #PSGLatch|PSGChannel1|PSGVolumeData|$0F ; latch channel 1, volume=0xF (silent)
        sta   SN76489.D
        lda   PSGChannel2SFX
        bne   PSGStop2
        lda   #PSGLatch|PSGChannel2|PSGVolumeData|$0F ; latch channel 2, volume=0xF (silent)
        sta   SN76489.D
PSGStop2
        lda   PSGChannel3SFX
        bne   PSGStop3
        lda   #PSGLatch|PSGChannel3|PSGVolumeData|$0F ; latch channel 3, volume=0xF (silent)
        sta   SN76489.D
PSGStop3
        lda   #PSG_STOPPED                            ; ld a,PSG_STOPPED
        sta   PSGMusicStatus                          ; set status to PSG_STOPPED
PSGStop_end
  rts


* ************************************************************************************
* resume a previously stopped music
* destroys A

PSGResume 
        lda   PSGMusicStatus                          ; if it's already playing, leave
        bne   PSGResume_end
        lda   PSGChan0Volume                          ; restore channel 0 volume
        ora   #PSGLatch|PSGChannel0|PSGVolumeData
        sta   SN76489.D
        lda   PSGChan1Volume                          ; restore channel 1 volume
        ora   #PSGLatch|PSGChannel1|PSGVolumeData
        sta   SN76489.D
        lda   PSGChannel2SFX
        bne   PSGResume1
        lda   PSGChan2LowTone                         ; restore channel 2 frequency
        ora   #PSGLatch|PSGChannel2
        sta   SN76489.D
        lda   PSGChan2HighTone
        sta   SN76489.D
        lda   PSGChan2Volume                          ; restore channel 2 volume
        ora   #PSGLatch|PSGChannel2|PSGVolumeData
        sta   SN76489.D
PSGResume1
        lda   PSGChannel3SFX
        bne   PSGResume2
        lda   PSGChan3LowTone                         ; restore channel 3 frequency
        ora   #PSGLatch|PSGChannel3
        sta   SN76489.D
        lda   PSGChan3Volume                          ; restore channel 3 volume
        ora   #PSGLatch|PSGChannel2|PSGVolumeData
        sta   SN76489.D
PSGResume2
        lda   #PSG_PLAYING
        sta   PSGMusicStatus                          ; set status to PSG_PLAYING
PSGResume_end        
        rts

* ************************************************************************************
* sets the currently looping music to no more loops after the current
* destroys A

PSGCancelLoop 
          clr   PSGLoopFlag
          rts

* ************************************************************************************
* gets the current status of music into register A

PSGGetStatus 
        lda   PSGMusicStatus
        rts

* ************************************************************************************
* receives in A the volume attenuation for the music (0-15)
* destroys A

PSGSetMusicVolumeAttenuation 
        sta   PSGMusicVolumeAttenuation
        lda   PSGMusicStatus                          ; if tune is not playing, leave
        beq   PSGSetMusicVolumeAttenuation_end

        lda   PSGChan0Volume
        anda  #$0F
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGSetMusicVolumeAttenuation1           ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
PSGSetMusicVolumeAttenuation1
        ora   #PSGLatch|PSGChannel0|PSGVolumeData
        sta   SN76489.D                             ; output the byte
        
        lda   PSGChan1Volume
        anda  #$0F
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGSetMusicVolumeAttenuation2           ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
PSGSetMusicVolumeAttenuation2
        ora   #PSGLatch|PSGChannel1|PSGVolumeData
        sta   SN76489.D                             ; output the byte        
  

        lda   PSGChannel2SFX                          ; channel 2 busy with SFX?
        bne   _restore_channel3                       ; if so, skip channel 2

        lda   PSGChan2Volume
        anda  #$0F
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGSetMusicVolumeAttenuation3           ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
PSGSetMusicVolumeAttenuation3
        ora   #PSGLatch|PSGChannel2|PSGVolumeData
        sta   SN76489.D 

_restore_channel3
        lda   PSGChannel3SFX                          ; channel 3 busy with SFX?
        bne   PSGSetMusicVolumeAttenuation_end        ; if so, we're done

        lda   PSGChan3Volume
        anda  #$0F
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGSetMusicVolumeAttenuation4           ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
PSGSetMusicVolumeAttenuation4
        ora   #PSGLatch|PSGChannel3|PSGVolumeData
        sta   SN76489.D 
        
PSGSetMusicVolumeAttenuation_end
        rts

* ************************************************************************************
* sets all PSG channels to volume ZERO (useful if you need to pause music)
* destroys A

PSGSilenceChannels 
        lda   #PSGLatch|PSGChannel0|PSGVolumeData|$0F ; latch channel 0, volume=0xF (silent)
        sta   SN76489.D
        lda   #PSGLatch|PSGChannel1|PSGVolumeData|$0F ; latch channel 1, volume=0xF (silent)
        sta   SN76489.D
        lda   #PSGLatch|PSGChannel2|PSGVolumeData|$0F ; latch channel 2, volume=0xF (silent)
        sta   SN76489.D
        lda   #PSGLatch|PSGChannel3|PSGVolumeData|$0F ; latch channel 3, volume=0xF (silent)
        sta   SN76489.D
        rts

* ************************************************************************************
* resets all PSG channels to previous volume
* destroys A

PSGRestoreVolumes 
        lda   PSGMusicStatus                          ; check if tune is playing
        beq   _chkchn2                                ; if not, skip chn0 and chn1

        lda   PSGChan0Volume
        anda  #$0F
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGRestoreVolumes1                      ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
PSGRestoreVolumes1
        ora   #PSGLatch|PSGChannel0|PSGVolumeData
        sta   SN76489.D                             ; output the byte

        lda   PSGChan1Volume
        anda  #$0F
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGRestoreVolumes2                      ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
PSGRestoreVolumes2
        ora   #PSGLatch|PSGChannel1|PSGVolumeData
        sta   SN76489.D                             ; output the byte
  
_chkchn2
        lda   PSGChannel2SFX                          ; channel 2 busy with SFX?
        bne   _restoreSFX2
  
        lda   PSGMusicStatus                          ; check if tune is playing
        beq   _chkchn3                                ; if not, skip chn2

        lda   PSGChan2Volume
        anda  #$0F
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGRestoreVolumes3                      ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
        bra   PSGRestoreVolumes3

_restoreSFX2
        lda   PSGSFXChan2Volume
        anda  $0F
PSGRestoreVolumes3
        ora   #PSGLatch|PSGChannel2|PSGVolumeData
        sta   SN76489.D                             ; output the byte

_chkchn3
        lda   PSGChannel3SFX                          ; channel 3 busy with SFX?
        bne   _restoreSFX3
  
        lda   PSGMusicStatus                          ; check if tune is playing
        beq   _restoreSFX2_end                        ; if not, we've done

        lda   PSGChan3Volume
        anda  #$0F
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGRestoreVolumes4                      ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
        bra   PSGRestoreVolumes4

_restoreSFX3
        lda   PSGSFXChan3Volume
        anda  #$0F
PSGRestoreVolumes4
        ora   #PSGLatch|PSGChannel3|PSGVolumeData
        sta   SN76489.D                             ; output the byte
_restoreSFX2_end
        rts


* ************************************************************************************
* receives in X the address of the SFX PSG to start
* receives in B the mask that indicates which channel(s) the SFX will use
* destroys A

PSGSFXPlayLoop 
        lda   #1                                      ; SFX _IS_ a looping one
        bra   PSGSFXPlay1
PSGSFXPlay 
        lda   #0                                      ; SFX is _NOT_ a looping one
PSGSFXPlay1
        sta   PSGSFXLoopFlag
        bsr   PSGSFXStop                              ; if there's a SFX already playing, we should stop it!

        lda   ,x   
        sta   PSGSFXPage
        ldx   1,x        
        stx   PSGSFXStart                             ; store begin of SFX
        stx   PSGSFXPointer                           ; set the pointer to begin of SFX
        stx   PSGSFXLoopPoint                         ; looppointer points to begin too
        lda   #0
        sta   PSGSFXSkipFrames                        ; reset the skip frames
        sta   PSGSFXSubstringLen                      ; reset the substring len
        bitb  #SFX_CHANNEL2                           ; channel 2 needed?
        beq   PSGSFXPlay2
        lda   #PSG_PLAYING
        sta   PSGChannel2SFX
PSGSFXPlay2
        bitb  #SFX_CHANNEL3                           ; channel 3 needed?
        beq   PSGSFXPlay3
        lda   #PSG_PLAYING
        sta   PSGChannel3SFX
PSGSFXPlay3
        sta   PSGSFXStatus                            ; set status to PSG_PLAYING
        lda   PSGChan3LowTone                         ; test if channel 3 uses the frequency of channel 2
        anda  #SFX_CHANNELS2AND3
        cmpa  #SFX_CHANNELS2AND3
        bne   PSGSFXPlayLoop_end                      ; if channel 3 doesn't use the frequency of channel 2 we're done
        lda   #PSG_PLAYING
        sta   PSGChannel3SFX                          ; otherwise mark channel 3 as occupied by the SFX
        lda   #PSGLatch|PSGChannel3|PSGVolumeData|$0F ; and silence channel 3
        sta   SN76489.D
PSGSFXPlayLoop_end        
        rts


* ************************************************************************************
* stops the SFX (leaving the music on, if it's playing)
* destroys A

PSGSFXStop 
        lda   PSGSFXStatus                            ; check status
        beq   PSGSFXStop_end                          ; no SFX playing, leave
        lda   PSGChannel2SFX                          ; channel 2 playing?
        beq   PSGSFXStop1
        lda   #PSGLatch|PSGChannel2|PSGVolumeData|$0F ; latch channel 2, volume=0xF (silent)
        sta   SN76489.D
PSGSFXStop1
        lda   PSGChannel3SFX                          ; channel 3 playing?
        beq   PSGSFXStop2
        lda   #PSGLatch|PSGChannel3|PSGVolumeData|$0F ; latch channel 3, volume=0xf (silent)
        sta   SN76489.D
PSGSFXStop2
        lda   PSGMusicStatus                          ; check if a tune is playing
        beq   _skipRestore                            ; if it's not playing, skip restoring PSG values
        lda   PSGChannel2SFX                          ; channel 2 playing?
        beq   _skip_chn2
        lda   PSGChan2LowTone
        anda  #$0F                                    ; use only low 4 bits of byte
        ora   #PSGLatch|PSGChannel2                   ; latch channel 2, low part of tone
        sta   SN76489.D
        lda   PSGChan2HighTone                        ; high part of tone (latched channel 2, tone)
        anda  #$3F                                    ; use only low 6 bits of byte
        sta   SN76489.D
        lda   PSGChan2Volume                          ; restore music' channel 2 volume
        anda  #$0F                                    ; use only low 4 bits of byte
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGSFXStop3                             ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
PSGSFXStop3
        ora   #PSGLatch|PSGChannel2|PSGVolumeData
        sta   SN76489.D                             ; output the byte
_skip_chn2
        lda   PSGChannel3SFX                          ; channel 3 playing?
        beq   _skip_chn3
        lda   PSGChan3LowTone
        anda  $07                                     ; use only low 3 bits of byte
        ora   #PSGLatch|PSGChannel3                   ; latch channel 3, low part of tone (no high part)
        sta   SN76489.D
        lda   PSGChan3Volume                          ; restore music' channel 3 volume
        anda  #$0F                                    ; use only low 4 bits of byte
        adda  PSGMusicVolumeAttenuation
        cmpa  #$10                                    ; check overflow
        bcs   PSGSFXStop4                             ; if it's <=15 then ok
        lda   #$0F                                    ; else, reset to 15
PSGSFXStop4
        ora   #PSGLatch|PSGChannel3|PSGVolumeData
        sta   SN76489.D                             ; output the byte

_skip_chn3
        lda   #PSG_STOPPED                            ; ld a,PSG_STOPPED
_skipRestore
        sta   PSGChannel2SFX
        sta   PSGChannel3SFX
        sta   PSGSFXStatus                            ; set status to PSG_STOPPED
PSGSFXStop_end  
        rts

* ************************************************************************************
* sets the currently looping SFX to no more loops after the current
* destroys A

PSGSFXCancelLoop 
        clr   PSGSFXLoopFlag
        rts


* ************************************************************************************
* gets the current SFX status into register A

PSGSFXGetStatus 
        lda   PSGSFXStatus
        rts


* ************************************************************************************
* processes a music frame
* destroys A,B,X
        
PSGFrame 
        lda   PSGMusicStatus                          ; check if we have got to play a tune
        bne   PSGFrame_continue
        rts

PSGFrame_continue
        lda   PSGMusicPage
        _SetCartPageA        
        lda   PSGMusicSkipFrames                      ; check if we havve got to skip frames
        bne   _skipFrame
        ldx   PSGMusicPointer                         ; read current address

_intLoop
        ldb   ,x+                                     ; load PSG byte (in B)
        lda   PSGMusicSubstringLen                    ; read substring len
        beq   _continue                               ; check if it is 0 (we are not in a substring)
        deca                                          ; decrease len
        sta   PSGMusicSubstringLen                    ; save len
        bne   _continue
        ldx   PSGMusicSubstringRetAddr                ; substring is over, retrieve return address

_continue
        cmpb  #PSGLatch                               ; is it a latch?
        bcs   _noLatch                                ; if < $80 then it is NOT a latch
        stb   PSGMusicLastLatch                       ; it is a latch - save it in "LastLatch"
  
        bitb  #4                                      ; test if it is a volume
        bne   _latch_Volume                           ; jump if volume data
        bitb  #6                                      ; test if the latch it is for channels 0-1 or for 2-3
        beq   _send2PSG                               ; send data to PSG if it is for channels 0-1

        bitb  #5                                      ; test if tone it is for channel 2 or 3
        beq   _ifchn2                                 ; jump if channel 2
        stb   PSGChan3LowTone                         ; save tone LOW data
        lda   PSGChannel3SFX                          ; channel 3 free?
        bne   _intLoop
        lda   PSGChan3LowTone
        anda  #3                                      ; test if channel 3 is set to use the frequency of channel 2
        cmpa  #3
        bne   _send2PSG                               ; if channel 3 does not use frequency of channel 2 jump
        lda   PSGSFXStatus                            ; test if an SFX is playing
        beq   _send2PSG                               ; if no SFX is playing jump
        sta   PSGChannel3SFX                          ; otherwise mark channel 3 as occupied
        lda   #PSGLatch|PSGChannel3|PSGVolumeData|$0F ; and silence channel 3
        sta   SN76489.D
        bra   _intLoop

_ifchn2
        stb   PSGChan2LowTone                         ; save tone LOW data
        lda   PSGChannel2SFX                          ; channel 2 free?
        beq   _send2PSG
        bra   _intLoop
  
_latch_Volume
        bitb  #6                                      ; test if the latch it is for channels 0-1 or for 2-3
        bne   _latch_Volume_23                        ; volume is for channel 2 or 3
        bitb  #5                                      ; test if volume it is for channel 0 or 1
        beq   _ifchn0                                 ; jump for channel 0
        stb   PSGChan1Volume                          ; save volume data
        bra   _sendVolume2PSG
        
_ifchn0
        stb   PSGChan0Volume                          ; save volume data
        bra   _sendVolume2PSG

_latch_Volume_23
        bitb  #5                                      ; test if volume it is for channel 2 or 3
        beq   _chn2                                   ; jump for channel 2
        stb   PSGChan3Volume                          ; save volume data
        lda   PSGChannel3SFX                          ; channel 3 free?
        beq   _sendVolume2PSG
        bra   _intLoop

_chn2
        stb   PSGChan2Volume                          ; save volume data
        lda   PSGChannel2SFX                          ; channel 2 free?
        beq   _sendVolume2PSG
        bra   _intLoop
        
_send2PSG
        stb   SN76489.D                             ; output the byte
        bra   _intLoop            
  
_skipFrame
        deca
        sta   PSGMusicSkipFrames
        rts

_noLatch
        cmpb  #PSGData
        bcs   _command                                ; if < $40 then it is a command
                                                      * it's a data
        lda   PSGMusicLastLatch                       ; retrieve last latch
        bra   _output_NoLatch

_command
        cmpb  #PSGWait
        beq   _done                                   ; no additional frames
        bcs   _otherCommands                          ; other commands?
        andb  #$07                                    ; take only the last 3 bits for skip frames
        stb   PSGMusicSkipFrames                      ; we got additional frames
  
_done
        stx   PSGMusicPointer                         ; save current address
        rts                                           ; frame done

_otherCommands
        cmpb  #PSGSubString
        bcc   _substring
        cmpb  #PSGEnd
        beq   _musicLoop
        cmpb  #PSGLoop
        beq   _setLoopPoint

  * ***************************************************************************
  * we should never get here!
  * if we do, it means the PSG file is probably corrupted, so we just RET
  * ***************************************************************************

        rts  

_sendVolume2PSG 
        stb   _sendVolume2PSG1+1                      ; save the PSG command byte
        andb  #$0F                                    ; keep lower nibble
        addb  PSGMusicVolumeAttenuation               ; add volume attenuation
        cmpb  #$10                                    ; check overflow
        bcs   _sendVolume2PSG1                        ; if it is <=15 then ok
        ldb   #$0F                                    ; else, reset to 15
_sendVolume2PSG1  
        lda   #0                                      ; retrieve PSG command
        stb   _sendVolume2PSG2+1   
        anda  #$F0                                    ; keep upper nibble
_sendVolume2PSG2        
        ora   #0                                      ; set attenuated volume
        sta   SN76489.D                             ; output the byte
        jmp   _intLoop

_output_NoLatch
  * we got the last latch in A and the PSG data in B
  * and we have to check if the value should pass to PSG or not
  * note that non-latch commands can be only contain frequencies (no volumes)
  * for channels 0,1,2 only (no noise)
        bita  #6                                      ; test if the latch it is for channels 0-1 or for chn 2
        bne   _high_part_Tone                         ;  it is tone data for channel 2
        bra   _send2PSG                               ; otherwise, it is for chn 0 or 1 so we have done!

_setLoopPoint
        stx   PSGMusicLoopPoint
        jmp   _intLoop

_musicLoop
        lda   PSGLoopFlag                             ; looping requested?
        lbeq   PSGStop                                ; No:stop it! (tail call optimization)
        ldx   PSGMusicLoopPoint
        jmp   _intLoop

_substring
        subb  #PSGSubString-4                         ; len is value - $08 + 4
        stb   PSGMusicSubstringLen                    ; save len
        ldb   ,x+                                     ; load substring address (offset) little-endian
        lda   ,x+                                     ; load substring address (offset) little-endian
        stx   PSGMusicSubstringRetAddr                ; save return address
        ldx   PSGMusicStart
        leax  d,x                                     ; make substring current
        jmp   _intLoop

_high_part_Tone
        stb   PSGChan2HighTone                        ; save channel 2 tone HIGH data
        lda   PSGChannel2SFX                          ; channel 2 free?
        lbeq  _send2PSG
        jmp   _intLoop


* ************************************************************************************
* processes a SFX frame
* destroys A,B,X

PSGSFXFrame 

        lda   PSGSFXPage
        _SetCartPageA
        
        lda   PSGSFXStatus                            ; check if we have got to play SFX
        beq   PSGSFXFrame_end

        lda   PSGSFXSkipFrames                        ; check if we have got to skip frames
        bne   _skipSFXFrame
  
        ldx   PSGSFXPointer                           ; read current SFX address

_intSFXLoop
        ldb   ,x+                                     ; load a byte in B
        lda   PSGSFXSubstringLen                      ; read substring len
        beq   _SFXcontinue                            ; check if it is 0 (we are not in a substring)
        deca                                          ; decrease len
        sta   PSGSFXSubstringLen                      ; save len
        bne   _SFXcontinue
        ldx   PSGSFXSubstringRetAddr                  ; substring over, retrieve return address

_SFXcontinue
        cmpb   #PSGData
        bcs    _SFXcommand                            ; if less than $40 then it is a command
        bitb   #4                                     ; check if it is a volume byte
        beq    _SFXoutbyte                            ; if not, output it
        bitb   #5                                     ; check if it is volume for channel 2 or channel 3
        bne    _SFXvolumechn3
        stb    PSGSFXChan2Volume
        bra   _SFXoutbyte

_SFXvolumechn3
        stb   PSGSFXChan3Volume

_SFXoutbyte
        stb   SN76489.D                             ; output the byte
        bra   _intSFXLoop
  
_skipSFXFrame
        deca
        sta   PSGSFXSkipFrames
PSGSFXFrame_end  
        rts

_SFXcommand
        cmpb   #PSGWait
        beq    _SFXdone                               ; no additional frames
        bcs    _SFXotherCommands                      ; other commands?
        andb   #$07                                   ; take only the last 3 bits for skip frames
        stb    PSGSFXSkipFrames                       ; we got additional frames to skip
_SFXdone
        stx    PSGSFXPointer                          ; save current address
        rts                                           ; frame done

_SFXotherCommands
        cmpb   #PSGSubString
        bcc    _SFXsubstring
        cmpb   #PSGEnd
        beq    _sfxLoop
        cmpb   #PSGLoop
        beq    _SFXsetLoopPoint
  
  * ***************************************************************************
  * we should never get here!
  * if we do, it means the PSG SFX file is probably corrupted, so we just RET
  * ***************************************************************************

        rts

_SFXsetLoopPoint 
        stx   PSGSFXLoopPoint
        bra   _intSFXLoop
  
_sfxLoop
        lda   PSGSFXLoopFlag                          ; is it a looping SFX?
        lbeq   PSGSFXStop                             ; No:stop it! (tail call optimization)
        ldx   PSGSFXLoopPoint
        stx   PSGSFXPointer
        bra   _intSFXLoop

_SFXsubstring
        subb  #PSGSubString-4                         ; len is value - $08 + 4
        stb   PSGSFXSubstringLen                      ; save len
        ldb   ,x+                                     ; load substring address (offset) little-endian
        lda   ,x+                                     ; load substring address (offset) little-endian
        stx   PSGSFXSubstringRetAddr                  ; save return address
        ldx   PSGSFXStart
        leax  d,x                                     ; make substring current
        bra   _intSFXLoop

  * fundamental vars
PSGMusicStatus             fcb   $00 ; are we playing a background music?
PSGMusicPage               fcb   $00 ; Memory Page of Music Data
PSGMusicStart              fdb   $0000 ; the pointer to the beginning of music
PSGMusicPointer            fdb   $0000 ; the pointer to the current
PSGMusicLoopPoint          fdb   $0000 ; the pointer to the loop begin
PSGMusicSkipFrames         fcb   $00 ; the frames we need to skip
PSGLoopFlag                fcb   $00 ; the tune should loop or not (flag)
PSGMusicLastLatch          fcb   $00 ; the last PSG music latch

  * decompression vars
PSGMusicSubstringLen       fcb   $00 ; length of the substring we are playing
PSGMusicSubstringRetAddr   fdb   $0000 ; return to this address when substring is over

  * command buffers
PSGChan0Volume             fcb   $00 ; the volume for channel 0
PSGChan1Volume             fcb   $00 ; the volume for channel 1
PSGChan2Volume             fcb   $00 ; the volume for channel 2
PSGChan3Volume             fcb   $00 ; the volume for channel 3
PSGChan2LowTone            fcb   $00 ; the low tone bits for channels 2
PSGChan3LowTone            fcb   $00 ; the low tone bits for channels 3
PSGChan2HighTone           fcb   $00 ; the high tone bits for channel 2

PSGMusicVolumeAttenuation  fcb   $00 ; the volume attenuation applied to the tune (0-15)

  * ******* SFX *************

  * flags for channels 2-3 access
PSGChannel2SFX             fcb   $00 ; !0 means channel 2 is allocated to SFX
PSGChannel3SFX             fcb   $00 ; !0 means channel 3 is allocated to SFX

  * command buffers for SFX
PSGSFXChan2Volume          fcb   $00 ; the volume for channel 2
PSGSFXChan3Volume          fcb   $00 ; the volume for channel 3

  * fundamental vars for SFX
PSGSFXStatus               fcb   $00 ; are we playing a SFX?
PSGSFXPage                 fcb   $00 ; Memory Page of SFX Data
PSGSFXStart                fdb   $0000 ; the pointer to the beginning of SFX
PSGSFXPointer              fdb   $0000 ; the pointer to the current address
PSGSFXLoopPoint            fdb   $0000 ; the pointer to the loop begin
PSGSFXSkipFrames           fcb   $00 ; the frames we need to skip
PSGSFXLoopFlag             fcb   $00 ; the SFX should loop or not (flag)

  * decompression vars for SFX
PSGSFXSubstringLen         fcb   $00 ; length of the substring we are playing
PSGSFXSubstringRetAddr     fdb   $0000 ; return to this address when substring is over

