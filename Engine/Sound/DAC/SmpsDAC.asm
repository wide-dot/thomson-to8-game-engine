* ---------------------------------------------------------------------------
* SMPS 6809 - Sample Music Playback System for 6809 (LWASM)
* ---------------------------------------------------------------------------
* by Bentoc June 2021, based on
* Sonic the Hedgehog 2 disassembled Z80 sound driver
* Disassembled by Xenowhirl for AS
* Additional disassembly work by RAS Oct 2008
* RAS' work merged into SVN by Flamewing
*
* ---------------------------------------------------------------------------
*
*
*
*                             !!! not finished !!!
* DO NOT USE DO NOT USE DO NOT USE DO NOT USE DO NOT USE DO NOT USE DO NOT USE
*
*
* ---------------------------------------------------------------------------
*
* just a try to play PCM thru 3 FM channels
* IRQ must be set so quick, it makes no sense
* Call with:
*        jsr   InitYM2413DAC                                                       
*        jsr   IrqSet50Hz   
*        ldx   #Smps_MCZ
*        jmp   PlayMusic
*
* ---------------------------------------------------------------------------

; SMPS Header
SMPS_VOICE                   equ   0
SMPS_NB_FM                   equ   2
SMPS_NB_PSG                  equ   3
SMPS_TEMPO                   equ   4
SMPS_TEMPO_DELAY             equ   4
SMPS_DELAY                   equ   5
SMPS_TRK_HEADER              equ   6
SMPS_DAC_FLAG                equ   8

; SMPS Header each track relative
SMPS_TRK_DATA_PTR            equ   0 
SMPS_TRK_TR_VOL_PTR          equ   2
SMPS_TRK_ENV_PTR             equ   5
SMPS_TRK_FM_HDR_LEN          equ   4
SMPS_TRK_PSG_HDR_LEN         equ   6

; Track STRUCT Constants
PlaybackControl              equ   0
TempoDivider                 equ   2
DataPointer                  equ   3
TransposeAndVolume           equ   5
VoiceIndex                   equ   8
DurationTimeout              equ   11

; Hardware Addresses
YM2413_A0                    equ   $E7B1 
YM2413_D0                    equ   $E7B2
PSG                          equ   $E7B0

******************************************************************************

Track STRUCT
                                                      ;         "playback control"; bits 
                                                      ;         1 (02h)  seems to be "track is at rest"
                                                      ;         2 (04h)  SFX is overriding this track
                                                      ;         3 (08h)  modulation on
                                                      ;         4 (10h)  do not attack next note
                                                      ;         7 (80h)  track is playing
PlaybackControl                rmb   1
                                                      ;         "voice control"; bits 
                                                      ;         2 (04h)  If set, bound for part II, otherwise 0 (see zWriteFMIorII)
                                                      ;                 -- bit 2 has to do with sending key on/off, which uses this differentiation bit directly
                                                      ;         7 (80h)  PSG Track
VoiceControl                   rmb   1
TempoDivider                   rmb   1                ; timing divisor; 1 = Normal, 2 = Half, 3 = Third...
DataPointer                    rmb   2                ; Track's position
Transpose                      rmb   1                ; Transpose (from coord flag E9)
Volume                         rmb   1                ; (Dependency) Should follow Transpose - channel volume (only applied at voice changes)
AMSFMSPan                      rmb   1                ; Panning / AMS / FMS settings
VoiceIndex                     rmb   1                ; Current voice in use OR current PSG tone
VolFlutter                     rmb   1                ; PSG flutter (dynamically effects PSG volume for decay effects)
StackPointer                   rmb   1                ; "Gosub" stack position offset (starts at 2Ah, i.e. end of track, and each jump decrements by 2)
DurationTimeout                rmb   1                ; current duration timeout; counting down to zero
SavedDuration                  rmb   1                ; last set duration (if a note follows a note, this is reapplied to 0Bh)
                                                      ; 0Dh / 0Eh change a little depending on track -- essentially they hold data relevant to the next note to play
NextData                       rmb   2                ; DAC  Next drum to play
                                                      ; FM/PSG  frequency low byte
                                                      ; FM/PSG  frequency high byte
NoteFillTimeout                rmb   1                ; Currently set note fill; counts down to zero and then cuts off note
NoteFillMaster                 rmb   1                ; Reset value for current note fill
ModulationPtrLow               rmb   1                ; low byte of address of current modulation setting
ModulationPtrHigh              rmb   1                ; high byte of address of current modulation setting
ModulationWait                 rmb   1                ; Wait for ww period of time before modulation starts
ModulationSpeed                rmb   1                ; Modulation Speed
ModulationDelta                rmb   1                ; Modulation change per Mod. Step
ModulationSteps                rmb   1                ; Number of steps in modulation (divided by 2)
ModulationValLow               rmb   1                ; Current modulation value low byte
ModulationValHigh              rmb   1                ; Current modulation value high byte
Detune                         rmb   1                ; Set by detune coord flag E1; used to add directly to FM/PSG frequency
VolTLMask                      rmb   1                ; zVolTLMaskTbl value set during voice setting (value based on algorithm indexing zGain table)
PSGNoise                       rmb   1                ; PSG noise setting
VoicePtrLow                    rmb   1                ; low byte of custom voice table (for SFX)
VoicePtrHigh                   rmb   1                ; high byte of custom voice table (for SFX)
TLPtrLow                       rmb   1                ; low byte of where TL bytes of current voice begin (set during voice setting)
TLPtrHigh                      rmb   1                ; high byte of where TL bytes of current voice begin (set during voice setting)
LoopCounters                   rmb   $A               ; Loop counter index 0
                                                      ;   ... open ...
GoSubStack                                            ; start of next track, every two bytes below this is a coord flag "gosub" (F8h) return stack
                                                      ;
                                                      ;        The bytes between +20h and +29h are "open"; starting at +20h and going up are possible loop counters
                                                      ;        (for coord flag F7) while +2Ah going down (never AT 2Ah though) are stacked return addresses going
                                                      ;        down after calling coord flag F8h.  Of course, this does mean collisions are possible with either
                                                      ;        or other track memory if you're not careful with these!  No range checking is performed!
                                                      ;
                                                      ;        All tracks are 2Ah bytes long
 ENDSTRUCT
 
******************************************************************************

Var STRUCT
SFXPriorityVal                 rmb   1        
TempoTimeout                   rmb   1        
CurrentTempo                   rmb   1                ; Stores current tempo value here
StopMusic                      rmb   1                ; Set to 7Fh to pause music, set to 80h to unpause. Otherwise 00h
FadeOutCounter                 rmb   1        
FadeOutDelay                   rmb   1        
Communication                  rmb   1                ; Unused byte used to synchronise gameplay events with music
QueueToPlay                    rmb   1                ; if NOT set to 80h, means new index was requested by 68K
SFXToPlay                      rmb   1                ; When Genesis wants to play "normal" sound, it writes it here
SFXStereoToPlay                rmb   1                ; When Genesis wants to play alternating stereo sound, it writes it here
SFXUnknown                     rmb   1                ; Unknown type of sound queue, but it's in Genesis code like it was once used
VoiceTblPtr                    rmb   2                ; address of the voices
FadeInFlag                     rmb   1        
FadeInDelay                    rmb   1        
FadeInCounter                  rmb   1        
1upPlaying                     rmb   1        
TempoMod                       rmb   1        
TempoTurbo                     rmb   1                ; Stores the tempo if speed shoes are acquired (or 7Bh is played anywho)
SpeedUpFlag                    rmb   1        
DACEnabled                     rmb   1        
MusicBankNumber                rmb   1        
IsPalFlag                      rmb   1        
 ENDSTRUCT

******************************************************************************

StructStart
AbsVar          Var

tracksStart                ; This is the beginning of all BGM track memory
SongDACFMStart
SongDAC         Track
SongFMStart
SongFM0         Track
SongFM1         Track
SongFM2         Track
SongFM3         Track
SongFM4         Track
SongFM5         Track
SongFM6         Track
SongFM7         Track
SongFM8         Track
SongFMEnd
SongDACFMEnd
SongPSGStart
SongPSG1        Track
SongPSG2        Track
SongPSG3        Track
SongPSGEnd
tracksEnd

;tracksSFXStart
;SFX_FMStart
;SFX_FM3         Track
;SFX_FM4         Track
;SFX_FM5         Track
;SFX_FMEnd
;SFX_PSGStart
;SFX_PSG1        Track
;SFX_PSG2        Track
;SFX_PSG3        Track
;SFX_PSGEnd
;tracksSFXEnd
StructEnd

        org   StructStart
        fill  0,(StructEnd-StructStart)     ; I want struct data to be in binary please ...
        
******************************************************************************

PALUpdTick      fcb   0     ; this counts from 0 to 5 to periodically "double update" for PAL systems (basically every 6 frames you need to update twice to keep up)
CurDAC          fcb   0     ; indicate DAC sample playing status
;CurSong        fcb   0     ; currently playing song index
DoSFXFlag       fcb   0     ; flag to indicate we're updating SFX (and thus use custom voice table); set to FFh while doing SFX, 0 when not.
Paused          fcb   0     ; 0 = normal, -1 = pause all sound and music

SongPage        fcb   0     ; memory page of song data
SongDelay       fcb   0     ; song header delay
MusicData       fdb   0     ; address of song data
Sample_index    fdb   0
Sample_page     fcb   0
Sample_data     fdb   0
Sample_data_end fdb   0
Sample_rate     fcb   0
Sample_value    fdb   0     ; MSB always to 0 for 16 bit add
DACFMSample     fdb   0
DACSampleParity fcb   0     ; 0:hi nibble 1:lo nibble

MUSIC_TRACK_COUNT = (tracksEnd-tracksStart)/sizeof{Track}
MUSIC_DAC_FM_TRACK_COUNT = (SongDACFMEnd-SongDACFMStart)/sizeof{Track}
MUSIC_FM_TRACK_COUNT = (SongFMEnd-SongFMStart)/sizeof{Track}
MUSIC_PSG_TRACK_COUNT = (SongPSGEnd-SongPSGStart)/sizeof{Track}

;SFX_TRACK_COUNT = (tracksSFXEnd-tracksSFXStart)/sizeof{Track}
;SFX_FM_TRACK_COUNT = (SFX_FMEnd-SFX_FMStart)/sizeof{Track}
;SFX_PSG_TRACK_COUNT = (SFX_PSGEnd-SFX_PSGStart)/sizeof{Track}

* ************************************************************************************
* writes to YM2413 (address val A to dest U, data val B to dest X) with required waits
*

_WriteYM MACRO
        stb   ,u
        nop
        nop
        sta   ,x
 ENDM  
 
_YMBusyWait MACRO
        jsr   YMBusyWait
 ENDM
 
_YMBusyWait2 MACRO
        jsr   YMBusyWait2
 ENDM
 
_YMBusyWait3 MACRO
        exg   a,b
        exg   a,b
        nop
        nop
        nop
        nop
 ENDM
 
YMBusyWait
        nop
YMBusyWait2
        tst   $0000
        puls  pc

* ************************************************************************************
* Setup YM2413 for DAC emulation
* destroys A, B, U, X

InitYM2413DAC 

        ldu   #YM2413_A0
        ldx   #YM2413_D0 
  
        ldd   #$000E
        _WriteYM                       ; disable rhyhtm mode    
        ldb   #$28
        _YMBusyWait2
        _WriteYM                       ; make sure channel 8 is key-off            
        ldb   #$27
        _YMBusyWait2
        _WriteYM                       ; make sure channel 7 is key-off            
        ldb   #$26
        _YMBusyWait2
        _WriteYM                       ; make sure channel 6 is key-off            
        ldd   #$1F38
        _YMBusyWait3
        _WriteYM                       ; select violin tone (modulator AR is 15)            
        ldb   #$37
        _YMBusyWait2
        _WriteYM                       ; select violin tone (modulator AR is 15)            
        ldb   #$36
        _YMBusyWait2
        _WriteYM                       ; select violin tone (modulator AR is 15)  
        ldd   #$2018
        _YMBusyWait3
        _WriteYM                       ; set frequency            
        ldb   #$17
        _YMBusyWait2
        _WriteYM                       ; set frequency            
        ldb   #$16
        _YMBusyWait2
        _WriteYM                       ; set frequency  
        ldd   #$1028
        _YMBusyWait3
        _WriteYM                       ; start phase generator            
        ldb   #$27
        _YMBusyWait2
        _WriteYM                       ; start phase generator            
        ldb   #$26
        _YMBusyWait2
        _WriteYM                       ; start phase generator  
        
        ; wait until 1/4 cycle of phase generator (freq $20)
        ; 6809 cycles: ((1.0 / (($20 * 3579545) / 72 / 524288)) / 4)*1000000 = 82388

        ldd   #$0CDF                   ; 3 cy
WaitPhase        
        exg   a,b                      ; 8 cy |
        exg   a,b                      ; 8 cy |
        subd  1                        ; 6 cy |
        bne   WaitPhase                ; 3 cy | : total loop = 25 cy * $CDF
        exg   a,b                      ; 8 cy
        ldb   #$18                     ; 2 cy - D: $0018 now
                                       ; total wait time : 82388 cycles        
        
        _WriteYM                       ; stop phase generator            
        ldb   #$17
        _YMBusyWait2
        _WriteYM                       ; stop phase generator            
        ldb   #$16
        _YMBusyWait2
        _WriteYM                       ; stop phase generator         
        rts

* ************************************************************************************
* receives in X the address of the song
* destroys A

_InitTrackFM MACRO
        ldx   #\1
        lda   SongDelay        
        sta   TempoDivider,x
        ldd   #$8201
        sta   PlaybackControl,x
        stb   DurationTimeout,x
        ldd   SMPS_TRK_DATA_PTR,u
        addd  MusicData
        std   DataPointer,x
        ldd   SMPS_TRK_TR_VOL_PTR,u
        std   TransposeAndVolume,x
        leau  SMPS_TRK_FM_HDR_LEN,u       
 ENDM

_InitTrackPSG MACRO
        ldx   #\1
        lda   AbsVar.CurrentTempo        
        sta   TempoDivider,x
        ldd   #$8201
        sta   PlaybackControl,x
        stb   DurationTimeout,x
        ldd   SMPS_TRK_DATA_PTR,u
        addd  MusicData
        std   DataPointer,x
        ldd   SMPS_TRK_TR_VOL_PTR,u
        std   TransposeAndVolume,x
        lda   SMPS_TRK_ENV_PTR,u
        sta   VoiceIndex,x
        leau  SMPS_TRK_PSG_HDR_LEN,u
 ENDM

PlayMusic
BGMLoad
        lda   ,x                       ; get memory page that contains track data
        sta   SongPage
        ldx   1,x                      ; get ptr to track data
        stx   MusicData
        _SetCartPageA
        
        ldd   SMPS_VOICE,x   
        std   AbsVar.VoiceTblPtr
        
        ldd   SMPS_TEMPO_DELAY,x
        sta   SongDelay
        stb   AbsVar.TempoMod
        stb   AbsVar.CurrentTempo
        stb   AbsVar.TempoTimeout
        
        lda   #$05
        sta   PALUpdTick
        
        ; TODO
        ; silence tracks that are not in use !
        
        lda   SMPS_NB_FM,x
        sta   @dyn+1
        leau  SMPS_TRK_HEADER,x
        ldy   SMPS_DAC_FLAG,x
        bne   @a
        _InitTrackFM SongDAC
@dyn    lda   #$00                                    ; (dynamic)      
        deca
@a      asla
        ldy   #ifmjmp
        jmp   [a,y]    
ifmjmp        
        fdb   ifm
        fdb   ifm0        
        fdb   ifm1        
        fdb   ifm2
        fdb   ifm3
        fdb   ifm4
        fdb   ifm5
        fdb   ifm6
        fdb   ifm7
        fdb   ifm8

ifm8    _InitTrackFM SongFM8
ifm7    _InitTrackFM SongFM7
ifm6    _InitTrackFM SongFM6
ifm5    _InitTrackFM SongFM5
ifm4    _InitTrackFM SongFM4
ifm3    _InitTrackFM SongFM3
ifm2    _InitTrackFM SongFM2
ifm1    _InitTrackFM SongFM1
ifm0    _InitTrackFM SongFM0
ifm
        ldx   MusicData
        lda   SMPS_NB_PSG,x
@a      asla
        ldy   #ipsgjmp
        jmp   [a,y]    
ipsgjmp    
        fdb   ipsg0
        fdb   ipsg1
        fdb   ipsg2
        fdb   ipsg3

ipsg3   _InitTrackPSG SongPSG3
ipsg2   _InitTrackPSG SongPSG2  
ipsg1   _InitTrackPSG SongPSG1
ipsg0
        rts
        
        
* ************************************************************************************
* processes a music frame (VInt)
*
* SMPS Song Data
* --------------
* value in range [$00, $7F] : Duration value
* value in range [$80]      : Rest (counts as a note value)
* value in range [$81, $DF] : Note value
* value in range [$E0, $FF] : Coordination flag
*
* destroys A,B,X
        
@a      rts        
MusicFrame 
        lda   SongPage                 ; page switch to the music
        beq   @a                       ; no music to play
        _SetCartPageA
        ;clr   DoSFXFlag
        lda   AbsVar.StopMusic
        beq   UpdateEverything
        jsr   PauseMusic
        bra   UpdateDAC

DACClearNote        
        clr   CurDAC
        ldd   #$8038                        ; mute DAC
        ldu   #YM2413_A0
        ldx   #YM2413_D0        
        _WriteYM
        decb
        _YMBusyWait2
        _WriteYM         
        decb
        _YMBusyWait2
        _WriteYM
        rts

UpdateEverything        
        lda   AbsVar.IsPalFlag
        beq   @a
        dec   PALUpdTick
        bne   @a
        lda   #5
        sta   PALUpdTick
        jsr   UpdateMusic              ; play 2 frames in one to keep original speed
@a      jsr   UpdateMusic        
        
UpdateDAC   
        lda   CurDAC                   ; Get currently playing DAC sound
        bmi   @a                       ; If one is queued (80h+), go to it!
        rts
@a      lda   Sample_page
        _SetCartPageA                  ; Bankswitch to the DAC data
                
        ldx   Sample_data
        cmpx  Sample_data_end
        beq   DACClearNote
WriteToDAC
        tst   DACSampleParity
        bne   @a
        lda   ,x                       ; read sample and unpack value
        lsra
        lsra
        lsra
        lsra
        inc   DACSampleParity
        bra   @b
@a        
        lda   ,x+                      ; read sample and unpack value
        stx   Sample_data        
        anda  #$0F
        dec   DACSampleParity
@b      

        ldu   #DACDecodeTbl
        ldb   a,u
        addb  Sample_value+1
        stb   Sample_value+1 
        cmpb  #$1D                     ; convert sample value to 3 YM2413 FM instruments
        bhi   @a  
        ldd   #$0000                   ; ($00-$1D) mapped to $0000 
        bra   @c      
@a      cmpb  #$DF
        blo   @b  
        ldd   #$0EEE                   ; ($DF-$FF) mapped to $0EEE 
        bra   @c    
@b      lda   #0
        lsrb
        addd  Sample_value             ; data is 3 nibbles long so x1.5
        bitb  #1
        bne   @odd
        ldx   #DACTable                ; read three nibbles xx x_
        ldd   d,x
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb
        lsra
        rorb                           ; changed nibbles to _x xx
        bra   @c            
@odd    ldx   #DACTable                ; read three nibbles _x xx
        ldd   d,x   
@c      anda  #$0F
        ora   #$80
        std   DACFMSample      
        ldb   #$38
        ldu   #YM2413_A0
        ldx   #YM2413_D0        
        _WriteYM
        ldd   DACFMSample        
        lslb
        rola
        lslb
        rola
        lslb
        rola
        lslb
        rola                        
        anda  #$0F
        ora   #$80
        std   DACFMSample        
        ldb   #$37      
        _WriteYM         
        ldd   DACFMSample
        lslb
        rola
        lslb
        rola
        lslb
        rola
        lslb
        rola                        
        anda  #$0F
        ora   #$80
        ldb   #$36
        _WriteYM                
        rts

* ************************************************************************************
* 

_UpdateTrack MACRO
        ldx   #\1
        lda   PlaybackControl,x        ; Is bit 7 (80h) set on playback control byte? (means "is playing")
        bpl   a@                       
        jsr   \2                       ; If so, UpdateTrack
a@      equ   *        
 ENDM

UpdateMusic
        jsr   TempoWait
        _UpdateTrack SongDAC,DACUpdateTrack
        _UpdateTrack SongFM0,FMUpdateTrack        
        _UpdateTrack SongFM1,FMUpdateTrack
        _UpdateTrack SongFM2,FMUpdateTrack
        _UpdateTrack SongFM3,FMUpdateTrack
        _UpdateTrack SongFM4,FMUpdateTrack
        _UpdateTrack SongFM5,FMUpdateTrack
        _UpdateTrack SongFM6,FMUpdateTrack
        _UpdateTrack SongFM7,FMUpdateTrack
        _UpdateTrack SongFM8,FMUpdateTrack                
        _UpdateTrack SongPSG1,PSGUpdateTrack
        _UpdateTrack SongPSG2,PSGUpdateTrack
        _UpdateTrack SongPSG3,PSGUpdateTrack        
        rts
        
* ************************************************************************************
* 
TempoWait
        ; Tempo works as divisions of the 60Hz clock (there is a fix supplied for
        ; PAL that "kind of" keeps it on track.)  Every time the internal music clock
        ; overflows, it will update.  So a tempo of 80h will update every other
        ; frame, or 30 times a second.

        lda   AbsVar.CurrentTempo  ; tempo value
        adda  AbsVar.TempoTimeout  ; Adds previous value to
        sta   AbsVar.TempoTimeout  ; Store this as new
        bcc   @a
        rts                     ; If addition overflowed (answer greater than FFh), return
@a
        ; So if adding tempo value did NOT overflow, then we add 1 to all durations
        inc   SongDAC.DurationTimeout
        inc   SongFM0.DurationTimeout        
        inc   SongFM1.DurationTimeout
        inc   SongFM2.DurationTimeout
        inc   SongFM3.DurationTimeout
        inc   SongFM4.DurationTimeout
        inc   SongFM5.DurationTimeout
        inc   SongFM6.DurationTimeout
        inc   SongFM7.DurationTimeout
        inc   SongFM8.DurationTimeout                
        inc   SongPSG1.DurationTimeout
        inc   SongPSG2.DurationTimeout
        inc   SongPSG3.DurationTimeout
        rts

* ************************************************************************************
* 

DACUpdateTrack        
        dec   SongDAC.DurationTimeout
        beq   @a
        rts
@a       
        ldx   SongDAC.DataPointer
        
@b      lda   ,x+                      ; read DAC song data
        cmpa  #$E0
        blo   @a                       ; test for >= E0h, which is a coordination flag
        jsr   CoordFlag
        bra   @b                       ; read all consecutive coordination flags 
@a        
        bpl   SetDuration              ; test for 80h not set, which is a note duration
        sta   SongDAC.NextData               ; This is a note; store it here
        lda   ,x
        bpl   SetDurationAndForward    ; test for 80h not set, which is a note duration
        lda   SongDAC.SavedDuration
        sta   SongDAC.DurationTimeout
        bra   DACAfterDur

SetDurationAndForward
        leax  1,x
SetDuration
        ldb   SongDAC.TempoDivider
        mul
        stb   SongDAC.SavedDuration
        stb   SongDAC.DurationTimeout
DACAfterDur
        stx   SongDAC.DataPointer
        ; TODO SFX
        lda   SongDAC.NextData
        cmpa  #$80
        bne   @a
        rts                            ; if a rest, quit
@a      sta   CurDAC
        suba  #$81                     ; Otherwise, transform note into an index...
        ldx   #zDACMasterRate
        ldb   a,x
        stb   Sample_rate
        asla
        ldx   #DACMasterPlaylist
        ldu   a,x
        stu   Sample_index
        lda   ,u
        sta   Sample_page
        ldd   3,u
        std   Sample_data_end
        ldd   1,u
        std   Sample_data
        lda   #$80
        sta   Sample_value+1        
        rts
        
DACMasterPlaylist
        fdb   DAC_Sample1 ; $81 - Kick
        fdb   DAC_Sample2 ; $82 - Snare
        fdb   DAC_Sample3 ; $83 - Clap
        fdb   DAC_Sample4 ; $84 - Scratch
        fdb   DAC_Sample5 ; $85 - Timpani
        fdb   DAC_Sample6 ; $86 - Hi Tom
        fdb   DAC_Sample7 ; $87 - Bongo
        fdb   DAC_Sample5 ; $88 - Hi Timpani
        fdb   DAC_Sample5 ; $89 - Mid Timpani
        fdb   DAC_Sample5 ; $8A - Mid Low Timpani
        fdb   DAC_Sample5 ; $8B - Low Timpani
        fdb   DAC_Sample6 ; $8C - Mid Tom
        fdb   DAC_Sample6 ; $8D - Low Tom
        fdb   DAC_Sample6 ; $8E - Floor Tom
        fdb   DAC_Sample7 ; $8F - Hi Bongo
        fdb   DAC_Sample7 ; $90 - Mid Bongo
        fdb   DAC_Sample7 ; $91 - Low Bongo
         
zDACMasterRate
        fcb   $17 ; $81 - Kick
        fcb   $01 ; $82 - Snare
        fcb   $06 ; $83 - Clap
        fcb   $08 ; $84 - Scratch
        fcb   $1B ; $85 - Timpani
        fcb   $0A ; $86 - Hi Tom
        fcb   $1B ; $87 - Bongo
        fcb   $12 ; $88 - Hi Timpani
        fcb   $15 ; $89 - Mid Timpani
        fcb   $1C ; $8A - Mid Low Timpani
        fcb   $1D ; $8B - Low Timpani
        fcb   $02 ; $8C - Mid Tom
        fcb   $05 ; $8D - Low Tom
        fcb   $08 ; $8E - Floor Tom
        fcb   $08 ; $8F - Hi Bongo
        fcb   $0B ; $90 - Mid Bongo
        fcb   $12 ; $91 - Low Bongo
        
DACDecodeTbl
        fcb   0,1,2,4,8,$10,$20,$40
        fcb   $80,$FF,$FE,$FC,$F8,$F0,$E0,$C0

DACTable        
        fcb   $00,$02,$00
        fcb   $20,$02,$00
        fcb   $20,$02,$00
        fcb   $20,$02,$00
        fcb   $20,$02,$00
        fcb   $20,$02,$00
        fcb   $20,$02,$00
        fcb   $20,$02,$00
        fcb   $20,$04,$00
        fcb   $40,$04,$00
        fcb   $40,$04,$00
        fcb   $40,$04,$00
        fcb   $40,$06,$00
        fcb   $60,$06,$00
        fcb   $60,$08,$00
        fcb   $80,$0A,$00
        fcb   $A0,$02,$20
        fcb   $22,$02,$20
        fcb   $22,$02,$20
        fcb   $22,$02,$20
        fcb   $22,$02,$20
        fcb   $22,$02,$20
        fcb   $22,$02,$20
        fcb   $22,$02,$20
        fcb   $22,$04,$20
        fcb   $42,$04,$20
        fcb   $42,$04,$20
        fcb   $42,$04,$20
        fcb   $42,$06,$20
        fcb   $62,$06,$20
        fcb   $62,$08,$20
        fcb   $82,$0A,$20
        fcb   $A2,$04,$40
        fcb   $44,$04,$40
        fcb   $44,$04,$40
        fcb   $44,$04,$40
        fcb   $44,$06,$40
        fcb   $64,$06,$40
        fcb   $64,$08,$40
        fcb   $84,$0A,$40
        fcb   $A4,$06,$60
        fcb   $66,$06,$60
        fcb   $66,$08,$60
        fcb   $86,$0A,$60
        fcb   $A6,$08,$80
        fcb   $88,$0A,$80
        fcb   $A8,$0A,$A0
        fcb   $AA,$0C,$C0
        fcb   $CC,$04,$42
        fcb   $44,$24,$42
        fcb   $44,$24,$42
        fcb   $44,$24,$42
        fcb   $44,$26,$42
        fcb   $64,$26,$42
        fcb   $64,$28,$42
        fcb   $84,$2A,$42
        fcb   $A4,$26,$62
        fcb   $66,$26,$62
        fcb   $66,$28,$62
        fcb   $86,$2A,$62
        fcb   $A6,$28,$82
        fcb   $88,$2A,$82
        fcb   $A8,$2A,$A2
        fcb   $AA,$2C,$C2
        fcb   $CC,$26,$64
        fcb   $66,$46,$64
        fcb   $66,$48,$64
        fcb   $86,$4A,$64
        fcb   $A6,$48,$84
        fcb   $88,$4A,$84
        fcb   $A8,$4A,$A4
        fcb   $AA,$4C,$C4
        fcb   $CC,$48,$86
        fcb   $88,$6A,$86
        fcb   $A8,$6A,$A6
        fcb   $AA,$6C,$C6
        fcb   $CC,$6A,$A8
        fcb   $AA,$8C,$C8
        fcb   $CC,$8C,$CA
        fcb   $CC,$AE,$EC
        fcb   $EE,$CE,$EE        

* ************************************************************************************
* 
        
FMUpdateTrack
        dec   DurationTimeout,x
        rts
  
* ************************************************************************************
*   
        
PSGUpdateTrack
        dec   DurationTimeout,x
        rts        
  
* ************************************************************************************
*   
        
PauseMusic
        rts        

* ************************************************************************************
* 

CoordFlag
        suba  #$E0
        asla
        ldx   #CoordFlagLookup
        jmp   [a,x] 

CoordFlagLookup
        fdb   cfPanningAMSFMS       ; E0
        fdb   cfDetune              ; E1
        fdb   cfSetCommunication    ; E2
        fdb   cfJumpReturn          ; E3
        fdb   cfFadeInToPrevious    ; E4
        fdb   cfSetTempoDivider     ; E5
        fdb   cfChangeFMVolume      ; E6
        fdb   cfPreventAttack       ; E7
        fdb   cfNoteFill            ; E8
        fdb   cfChangeTransposition ; E9
        fdb   cfSetTempo            ; EA
        fdb   cfSetTempoMod         ; EB
        fdb   cfChangePSGVolume     ; EC
        fdb   cfClearPush           ; ED
        fdb   cfStopSpecialFM4      ; EE
        fdb   cfSetVoice            ; EF
        fdb   cfModulation          ; F0
        fdb   cfEnableModulation    ; F1
        fdb   cfStopTrack           ; F2
        fdb   cfSetPSGNoise         ; F3
        fdb   cfDisableModulation   ; F4
        fdb   cfSetPSGTone          ; F5
        fdb   cfJumpTo              ; F6
        fdb   cfRepeatAtPos         ; F7
        fdb   cfJumpToGosub         ; F8
        fdb   cfOpF9                ; F9
        fdb   cfNop                 ; FA
        fdb   cfNop                 ; FB
        fdb   cfNop                 ; FC
        fdb   cfNop                 ; FD
        fdb   cfNop                 ; FE
        fdb   cfNop                 ; FF

cfPanningAMSFMS
        rts
              
cfDetune
        rts         
            
cfSetCommunication
        rts   
        
cfJumpReturn
        rts         
        
cfFadeInToPrevious
        rts   
        
cfSetTempoDivider
        rts    
        
cfChangeFMVolume
        rts     

cfPreventAttack
        rts      

cfNoteFill 
        rts          

cfChangeTransposition
        rts

cfSetTempo 
        rts          

cfSetTempoMod
        rts        

cfChangePSGVolume
        rts    

cfClearPush
        rts          

cfStopSpecialFM4
        rts     

cfSetVoice
        rts

cfModulation
        rts         

cfEnableModulation
        rts   

cfStopTrack
        rts

cfSetPSGNoise
        rts        

cfDisableModulation
        rts  

cfSetPSGTone
        rts         

cfJumpTo
        rts             

cfRepeatAtPos
        rts        

cfJumpToGosub
        rts        

cfOpF9     
        rts          

cfNop 
        rts                                                 
                   