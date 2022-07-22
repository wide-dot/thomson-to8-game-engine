* ---------------------------------------------------------------------------
* SMPS 6809 - Sample Music Playback System for 6809 (LWASM)
* ---------------------------------------------------------------------------
* by Bentoc June 2021, based on
* Sonic the Hedgehog 2 disassembled Z80 sound driver
* Disassembled by Xenowhirl for AS
* Additional disassembly work by RAS Oct 2008
* RAS' work merged into SVN by Flamewing
*
* TODO
* - Test real hardware wait time and adjust the code
* ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"   

; SMPS Header
SMPS_VOICE                   equ   0
SMPS_NB_FM                   equ   2
SMPS_NB_PSG                  equ   3
SMPS_TEMPO                   equ   4
SMPS_TEMPO_DELAY             equ   4
SMPS_DELAY                   equ   5
SMPS_TRK_HEADER              equ   6
SMPS_DAC_FLAG                equ   8

; SMPS Header (each track)
SMPS_TRK_DATA_PTR            equ   0 
SMPS_TRK_TR_VOL_PTR          equ   2
SMPS_TRK_ENV_PTR             equ   5
SMPS_TRK_FM_HDR_LEN          equ   4
SMPS_TRK_PSG_HDR_LEN         equ   6

; SMPS SFX Header
SMPS_SFX_VOICE               equ   0
SMPS_SFX_TEMPO               equ   2
SMPS_SFX_TEMPO_NB_CH         equ   2
SMPS_SFX_NB_CH               equ   3
SMPS_SFX_HDR_LEN             equ   4

; SMPS SFX Header (each track)
SMPS_SFX_TRK_CH              equ   0
SMPS_SFX_TRK_DATA_PTR        equ   2 
SMPS_SFX_TRK_TR_VOL_PTR      equ   4
SMPS_SFX_TRK_HDR_LEN         equ   6

; Hardware Addresses
PSG                          equ   $E7FF
YM2413_A0                    equ   $E7FC
YM2413_D0                    equ   $E7FD

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
                                                      ;         0-3 (00h-0Fh) Channel number
                                                      ;         7   (80h) PSG Track
                                                      ;         PSG    Chn    |a| |00000|
                                                      ;         Voice1 0x80 = 100  00000
                                                      ;         Voice2 0xa0 = 101  00000
                                                      ;         Voice3 0xc0 = 110  00000                                                      
                                                      ;         Voice4 0xe0 = 111  00000                                                      
VoiceControl                   rmb   1
                                                      ;         "note control"; bits
                                                      ;         0-3 (00h-0Fh) Current Block(0-2) and FNum(8)
                                                      ;         4   (10h) Key On
                                                      ;         5   (20h) Sustain On
NoteControl                    rmb   1
TempoDivider                   rmb   1                ; timing divisor; 1 = Normal, 2 = Half, 3 = Third...
DataPointer                    rmb   2                ; Track's position
Transpose                      rmb   1                ; Transpose (from coord flag E9)
Volume                         rmb   1                ; Attenuation - (Dependency) Should follow Transpose
VoiceIndex                     rmb   1                ; Current voice in use OR current PSG tone
VolFlutter                     rmb   1                ; PSG flutter (dynamically effects PSG volume for decay effects)
StackPointer                   rmb   1                ; "Gosub" stack position offset (starts at 2Ah, i.e. end of track, and each jump decrements by 2)
DurationTimeout                rmb   1                ; current duration timeout; counting down to zero
SavedDuration                  rmb   1                ; last set duration (if a note follows a note, this is reapplied to 0Bh)
                                                      ; 0Dh / 0Eh change a little depending on track -- essentially they hold data relevant to the next note to play
NextData                       rmb   2                ; DAC Next drum to play - FM/PSG  frequency
NoteFillTimeout                rmb   1                ; Currently set note fill; counts down to zero and then cuts off note
NoteFillMaster                 rmb   1                ; Reset value for current note fill
ModulationPtr                  rmb   2                ; address of current modulation setting
ModulationWait                 rmb   1                ; Wait for ww period of time before modulation starts
ModulationSpeed                rmb   1                ; Modulation Speed
ModulationDelta                rmb   1                ; Modulation change per Mod. Step
ModulationSteps                rmb   1                ; Number of steps in modulation (divided by 2)
ModulationVal                  rmb   2                ; Current modulation value
Detune                         rmb   1                ; Set by detune coord flag E1; used to add directly to FM/PSG frequency
VolTLMask                      rmb   1                ; zVolTLMaskTbl value set during voice setting (value based on algorithm indexing zGain table)
PSGNoise                       rmb   1                ; PSG noise setting
TLPtr                          rmb   2                ; where TL bytes of current voice begin (set during voice setting)
InstrTranspose                 rmb   1                ; instrument transpose
                                                      ;         "InstrAndVolume"; bits
                                                      ;          FM Instr.  Attnenuation
                                                      ; FM       0000       xxxx
                                                      ; FM       0001       xxxx 
                                                      ; ...  
                                                      ; PSG      Chn    |a| |1Fh|
                                                      ; VOL1     0x90 = 100 1xxxx        vol 4b xxxx = attenuation value
                                                      ; VOL2     0xb0 = 101 1xxxx        vol 4b
                                                      ; VOL3     0xd0 = 110 1xxxx        vol 4b
                                                      ; VOL4     0xf0 = 111 1xxxx        vol 4b       
InstrAndVolume                 rmb   1                ; current instrument and volume
LoopCounters                   rmb   $A               ; Loop counter index 0
                                                      ;   ... open ...
                                                      ; start of next track, every two bytes below this is a coord flag "gosub" (F8h) return stack
                                                      ;
                                                      ;        The bytes between +20h and +29h are "open"; starting at +20h and going up are possible loop counters
                                                      ;        (for coord flag F7) while +2Ah going down (never AT 2Ah though) are stacked return addresses going
                                                      ;        down after calling coord flag F8h.  Of course, this does mean collisions are possible with either
                                                      ;        or other track memory if you're not careful with these!  No range checking is performed!
                                                      ;
                                                      ;        All tracks are 2Ah bytes long
 ENDSTRUCT

; Track STRUCT Constants
PlaybackControl              equ   0
VoiceControl                 equ   1
NoteControl                  equ   2
TempoDivider                 equ   3
DataPointer                  equ   4
TranspAndVolume              equ   6
Transpose                    equ   6
Volume                       equ   7
VoiceIndex                   equ   8
VolFlutter                   equ   9
StackPointer                 equ   10
DurationTimeout              equ   11
SavedDuration                equ   12
NextData                     equ   13
NoteFillTimeout              equ   15
NoteFillMaster               equ   16
ModulationPtr                equ   17
ModulationWait               equ   19
ModulationSpeed              equ   20
ModulationDelta              equ   21
ModulationSteps              equ   22
ModulationVal                equ   23
Detune                       equ   25
VolTLMask                    equ   26
PSGNoise                     equ   27
TLPtr                        equ   28
InstrTranspose               equ   30 
InstrAndVolume               equ   31 
LoopCounters                 equ   32   
GoSubStack                   equ   42

MUSIC_TRACK_COUNT = (tracksEnd-tracksStart)/sizeof{Track}
MUSIC_DAC_FM_TRACK_COUNT = (SongDACFMEnd-SongDACFMStart)/sizeof{Track}
MUSIC_FM_TRACK_COUNT = (SongFMEnd-SongFMStart)/sizeof{Track}
MUSIC_PSG_TRACK_COUNT = (SongPSGEnd-SongPSGStart)/sizeof{Track}

SFX_TRACK_COUNT = (tracksSFXEnd-tracksSFXStart)/sizeof{Track}
SFXFM_TRACK_COUNT = (SFXFMEnd-SFXFMStart)/sizeof{Track}
SFXPSG_TRACK_COUNT = (SFXPSGEnd-SFXPSGStart)/sizeof{Track}

******************************************************************************
* writes to YM2413 with required waits
******************************************************************************

_WriteYM MACRO
        sta   YM2413_A0
        nop
        nop
        stb   YM2413_D0
 ENDM  

_YMBusyWait5 MACRO
        nop                                        
        brn   *
 ENDM

_YMBusyWait9 MACRO
        nop
        nop
        nop
        brn   *
 ENDM
 
_YMBusyWait11 MACRO
        nop
        nop
        nop
        nop
        brn   *
 ENDM
 
_YMBusyWait19 MACRO
        exg   a,b
        exg   a,b
        brn   *
 ENDM

******************************************************************************
* Main Jump table
******************************************************************************

SmpsObj
        ldx   #SmpsObj_Routines
        jmp   [a,x]

SmpsObj_Routines
        fdb   YM2413_DrumModeOn
        fdb   PlayMusic
        fdb   MusicFrame
        fdb   PlaySound

******************************************************************************

PALUpdTick      fcb   0     ; this counts from 0 to 5 to periodically "double update" for PAL systems (basically every 6 frames you need to update twice to keep up)
DoSFXFlag       fcb   0     ; flag to indicate we're updating SFX (and thus use custom voice table); set to FFh while doing SFX, 0 when not.
Paused          fcb   0     ; 0 = normal, -1 = pause all sound and music
SongDelay       fcb   0     ; song header delay

MusicData       fdb   0     ; address of song data
SoundData       fdb   0     ; address of sound data

******************************************************************************
* Setup YM2413 for Drum Mode
* destroys A, B
******************************************************************************

YM2413_DrumModeOn
        pshs  d,x
        ldx   #@data
@a      ldd   ,x++
        bmi   @end
        _WriteYM
        _YMBusyWait5
        bra   @a
@end    lda   #$05                     ; saves values for FMSilenceAll routine
        sta   SongFM7.NoteControl 
        lda   #$05
        sta   SongFM8.NoteControl
        lda   #$01
        sta   SongFM9.NoteControl                
        puls  d,x,pc       
@data
        fdb   $0E20
        fdb   $1620
        fdb   $1750 ; recommended setting is $1750 and $2705 for snare but $1700 and $2700 gives better SD sound (noise), affects HH that will sound more like a cowbell 
        fdb   $18C0
        fdb   $2605 ; (dependency) if modified, change hardcoded value at DrumModeOn end label
        fdb   $2705 ; (dependency) if modified, change hardcoded value at DrumModeOn end label
        fdb   $2801 ; (dependency) if modified, change hardcoded value at DrumModeOn end label
        fdb   $36F2 ; drum at max vol        
        fdb   $3762 ; drum at max vol
        fdb   $3844 ; drum at max vol
        fcb   $FF
        
******************************************************************************
* InitMusicPlayback
* 
******************************************************************************

InitMusicPlayback
        jsr   FMSilenceAll
        jsr   PSGSilenceAll
        rts

******************************************************************************
* FMSilenceAll
* destroys A, B, Y
******************************************************************************

FMSilenceAll
        ldd   #$200E
        stb   YM2413_A0
        ldy   #SongFM1.NoteControl
        sta   YM2413_D0                ; note off for all drums     
        _YMBusyWait5
        _YMBusyWait5        
                
@a      _YMBusyWait5                   ; total wait btw two notes : 20 cycles
        ldb   ,y                       ; (wait of 4 cycles)
        sta   YM2413_A0
        andb  #$EF                     ; note off for each track
        inca
        stb   YM2413_D0
        leay  sizeof{Track},y          ; (wait of 5 cycles)        
        cmpa  #$29                     ; (wait of 2 cycles)
        bne   @a                       ; (wait of 3 cycles)
        rts

******************************************************************************
* PSGSilenceAll
* destroys A
******************************************************************************
        
PSGSilenceAll
        lda   #$9F
        sta   PSG
        lda   #$BF
        sta   PSG       
        lda   #$DF
        sta   PSG
        lda   #$FF
        sta   PSG                               
        rts        

******************************************************************************
* PlayMusic - Load a new music and init all tracks
*
* receives in X the address of the song
* destroys X
******************************************************************************

@rts    puls  d,y,u,pc
PlayMusic
BGMLoad
        pshs  d,y,u
        ldx   #Song_Index
        abx
        ldx   ,x
        stx   MusicData
        beq   @rts

        jsr   InitMusicPlayback
        ldd   SMPS_VOICE,x
        addd  MusicData   
        std   Smps.VoiceTblPtr
        
        ldd   SMPS_TEMPO_DELAY,x
        sta   SongDelay
        stb   Smps.TempoMod
        stb   Smps.CurrentTempo
        stb   Smps.TempoTimeout
        
        lda   #$05
        sta   PALUpdTick
        
        lda   SMPS_NB_FM,x
        sta   @fm+1
        leau  SMPS_TRK_HEADER,x
        ldd   SMPS_DAC_FLAG,x
        bne   @fm                      ; no DRUM track found (should be $0000 to be DRUM)
        ldy   #SongDAC
        jsr   InitTrackFM              ; DRUM mode use channel 6-8
        dec   @fm+1                    ; DAC track is part of FM nb channel count
@fm      
        lda   #$00                     ; (dynamic) nb of FM tracks to init
        ldy   #SongFM1                 ; Init all FM tracks
@fmlp   dec   @fm+1
        bmi   @psg     
        jsr   InitTrackFM
        bra   @fmlp
@psg    
        lda   #$C0                     ; set back Tone channel for PSG3 (can be switched to noise by cfSetPSGNoise)
        sta   SongPSG3.VoiceControl
        lda   SMPS_NB_PSG,x
        sta   @var                     ; nb of PSG tracks to init
        ldy   #SongPSG1                ; Init all PSG tracks
@psglp  dec   @var
        bmi   BGMLoad_end     
        jsr   InitTrackPSG
        bra   @psglp
@var    fcb   0

BGMLoad_end
        puls  d,y,u,pc

InitTrackFM
        lda   SongDelay        
        sta   TempoDivider,y
        ldd   #$8201
        sta   PlaybackControl,y
        stb   DurationTimeout,y
        ldb   #GoSubStack
        stb   StackPointer,y
        ldd   SMPS_TRK_DATA_PTR,u
        addd  MusicData
        std   DataPointer,y
        ldd   SMPS_TRK_TR_VOL_PTR,u
        std   TranspAndVolume,y
        leau  SMPS_TRK_FM_HDR_LEN,u
        leay  sizeof{Track},y
        rts       
 
InitTrackPSG
        lda   SongDelay        
        sta   TempoDivider,y
        ldd   #$8201
        sta   PlaybackControl,y
        stb   DurationTimeout,y
        ldb   #GoSubStack
        stb   StackPointer,y        
        ldd   SMPS_TRK_DATA_PTR,u
        addd  MusicData
        std   DataPointer,y
        ldd   SMPS_TRK_TR_VOL_PTR,u
        std   TranspAndVolume,y
        lda   SMPS_TRK_ENV_PTR,u
        sta   VoiceIndex,y
        leau  SMPS_TRK_PSG_HDR_LEN,u
        leay  sizeof{Track},y
        rts        
        
******************************************************************************
* MusicFrame - processes a music frame (VInt)
*
* SMPS Song Data
* --------------
* value in range [$00, $7F] : Duration value
* value in range [$80]      : Rest (counts as a note value)
* value in range [$81, $DF] : Note value
* value in range [$E0, $FF] : Coordination flag
*
* destroys A,B,X,Y
******************************************************************************

_UpdateTrack MACRO
        lda   \1.PlaybackControl       ; Is bit 7 (80h) set on playback control byte? (means "is playing")
        bpl   a@
        ldy   #\1                               
        jsr   \2                       ; If so, UpdateTrack
a@      equ   *        
 ENDM
        
MusicFrame 
        
        ; simple sound fx implementation with no priority
        ; TODO upgrade to a queue system like original code
        ldb   Smps.SFXToPlay           ; get last requested sound effect to play
        beq   @a                       ; 0 means no sound effect to play
        jsr   PlaySound
        ldb   #0                       ; reset to be able to play another effect from now
        stb   Smps.SFXToPlay
@a       
        ldd   MusicData
        lbeq  UpdateSound              ; no music to play
        clr   DoSFXFlag

UpdateEverything     
        lda   Smps.60HzData            ; TODO use SMPS relocate to convert timings
        beq   @a                       ; to play 60hz songs at 50hz at normal speed
        dec   PALUpdTick               ; this will allow to throw away this code
        bne   @a
        lda   #5
        sta   PALUpdTick
        jsr   UpdateMusic              ; play 2 frames in one to keep original speed
@a      jsr   UpdateMusic              ; play 2 frames in one to keep original speed
        bra   UpdateSound

UpdateMusic
        * jsr   TempoWait              ; optim : do not call TempoWait, instead skip update
        lda   Smps.CurrentTempo        ; tempo value
        adda  Smps.TempoTimeout        ; Adds previous value to
        sta   Smps.TempoTimeout        ; Store this as new
        bcc   @rts                     ; skip update if tempo need more waits
        _UpdateTrack SongDAC,DACUpdateTrack
        _UpdateTrack SongFM1,FMUpdateTrack
        _UpdateTrack SongFM2,FMUpdateTrack
        _UpdateTrack SongFM3,FMUpdateTrack
        _UpdateTrack SongFM4,FMUpdateTrack
        _UpdateTrack SongFM5,FMUpdateTrack
        ;_UpdateTrack SongFM6,FMUpdateTrack      ; uncomment to use this channel
        ;_UpdateTrack SongFM7,FMUpdateTrack      ; uncomment to use tone channel instead of drum kit
        ;_UpdateTrack SongFM8,FMUpdateTrack      ; uncomment to use tone channel instead of drum kit
        ;_UpdateTrack SongFM9,FMUpdateTrack      ; uncomment to use tone channel instead of drum kit        
        ;_UpdateTrack SongPSG4,PSGUpdateTrack    ; uncomment to use noise channel as an independent channel from tone 3
        _UpdateTrack SongPSG1,PSGUpdateTrack
        _UpdateTrack SongPSG2,PSGUpdateTrack        
        _UpdateTrack SongPSG3,PSGUpdateTrack
@rts    rts

UpdateSound        
        ldd   SoundData
        bne   @a
        rts
@a      
        ; Spindash update
        lda   zSpindashPlayingCounter
        beq   >                        ; if the spindash counter is already 0, branch
        deca                           ; decrease the spindash sound playing counter
        sta   zSpindashPlayingCounter
!
        lda   #$80
        sta   DoSFXFlag                ; Set zDoSFXFlag = 80h (updating sound effects)
        _UpdateTrack SFXFM3,FMUpdateTrack
        _UpdateTrack SFXFM4,FMUpdateTrack
        _UpdateTrack SFXFM5,FMUpdateTrack
        _UpdateTrack SFXPSG1,PSGUpdateTrack
        _UpdateTrack SFXPSG2,PSGUpdateTrack        
        _UpdateTrack SFXPSG3,PSGUpdateTrack
@rts    rts

* * ************************************************************************************
* * 
* TempoWait
*         ; Tempo works as divisions of the 60Hz clock (there is a fix supplied for
*         ; PAL that "kind of" keeps it on track.)  Every time the internal music clock
*         ; overflows, it will update.  So a tempo of 80h will update every other
*         ; frame, or 30 times a second.

*         lda   Smps.CurrentTempo  ; tempo value
*         adda  Smps.TempoTimeout  ; Adds previous value to
*         sta   Smps.TempoTimeout  ; Store this as new
*         bcc   @a
*         rts                     ; If addition overflowed (answer greater than FFh), return
* @a
*         ; So if adding tempo value did NOT overflow, then we add 1 to all durations
*         inc   SongDAC.DurationTimeout
*         inc   SongFM1.DurationTimeout
*         inc   SongFM2.DurationTimeout
*         inc   SongFM3.DurationTimeout
*         inc   SongFM4.DurationTimeout
*         inc   SongFM5.DurationTimeout
*         ;inc   SongFM6.DurationTimeout
*         ;inc   SongFM7.DurationTimeout
*         ;inc   SongFM8.DurationTimeout                
*         ;inc   SongFM9.DurationTimeout                        
*         ;inc   SongPSG4.DurationTimeout
*         inc   SongPSG1.DurationTimeout
*         inc   SongPSG2.DurationTimeout
*         inc   SongPSG3.DurationTimeout
*         rts

******************************************************************************
* DACUpdateTrack
* input Y (ptr to SONGDAC, is used by CoordFlag)
* destroys A,B,X
******************************************************************************

DACUpdateTrack        
        dec   SongDAC.DurationTimeout
        beq   @a
        rts
@a
        ldd   #$0E20                   ; note has ended, so note off
        sta   <YM2413_A0
        ldx   SongDAC.DataPointer
        stb   <YM2413_D0        
                 
@b      ldb   ,x+                      ; read DAC song data
        cmpb  #$E0
        blo   @a                       ; test for >= E0h, which is a coordination flag
        jsr   CoordFlag
        bra   @b                       ; read all consecutive coordination flags 
@a        
        bpl   SetDuration              ; test for 80h not set, which is a note duration
        stb   SongDAC.NextData               ; This is a note; store it here
        ldb   ,x
        bpl   SetDurationAndForward    ; test for 80h not set, which is a note duration
        ldb   SongDAC.SavedDuration
        bra   DACAfterDur

SetDurationAndForward
        leax  1,x
SetDuration
        lda   SongDAC.TempoDivider
        mul
        stb   SongDAC.SavedDuration
DACAfterDur
        stb   SongDAC.DurationTimeout
        stx   SongDAC.DataPointer
        ldb   SongDAC.NextData
        cmpb  #$80
        bne   @a
        rts                            ; if a rest, quit
@a
        ldx   #@data            
        subb  #$81                     ; transform note into an index...      
        lda   #$0E
        sta   <YM2413_A0
        ldb   b,x
        stb   <YM2413_D0      
        rts
@data
        fcb   $30 ; $81 - Kick  (BD+TOM) 34
        fcb   $28 ; $82 - Snare (SNARE noise+TOM) 2C
        fcb   $21 ; $83 - Clap 21
        fcb   $22 ; $84 - Scratch 22
        fcb   $24 ; $85 - Timpani 22
        fcb   $24 ; $86 - Hi Tom
        fcb   $24 ; $87 - Bongo
        fcb   $24 ; $88 - Hi Timpani
        fcb   $30 ; $89 - Mid Timpani
        fcb   $30 ; $8A - Mid Low Timpani
        fcb   $34 ; $8B - Low Timpani
        fcb   $28 ; $8C - Mid Tom
        fcb   $30 ; $8D - Low Tom
        fcb   $34 ; $8E - Floor Tom
        fcb   $24 ; $8F - Hi Bongo
        fcb   $28 ; $90 - Mid Bongo
        fcb   $30 ; $91 - Low Bongo

******************************************************************************
* FM Track Update
******************************************************************************

_FMNoteOff MACRO                       ; (dependency) should be preceded by A loaded with PlaybackControl,y and B with VoiceControl,y
        bita  #$04                     ; Is SFX overriding set?
        bne   @skip                    ; if true skip note off, sfx is playing        
        addb  #$20                     ; set Sus/Key/Block/FNum(MSB) Command
        stb   <YM2413_A0
        ldb   NoteControl,y            ; load current value (do not erase FNum MSB)
        andb  #$EF                     ; clear bit 4 (10h) Key Off
        stb   <YM2413_D0               ; send to YM
        stb   NoteControl,y               
@skip   equ   *        
 ENDM        

FMUpdateTrack
        dec   DurationTimeout,y        ; Decrement duration
        bne   NoteFillUpdate           ; If not time-out yet, go do updates only
        lda   PlaybackControl,y
        anda  #$EF
        sta   PlaybackControl,y        ; When duration over, clear "do not attack" bit 4 (0x10) of track's play control
        
FMDoNext
        ldx   DataPointer,y
        lda   PlaybackControl,y        ; Clear bit 1 (02h) "track is rest" from track
        anda  #$FD
        sta   PlaybackControl,y        
       
FMReadCoordFlag        
        ldb   ,x+                      ; Read song data
        stb   NoteDyn+1
        cmpb  #$E0
        blo   FMNoteOff                ; Test for >= E0h, which is a coordination flag
        jsr   CoordFlag
        bra   FMReadCoordFlag          ; Read all consecutive coordination flags

FMNoteOff
        lda   PlaybackControl,y
        anda  #$14                     ; Are bits 4 (no attack) or 2 (SFX overriding) set?
        bne   NoteDyn                  ; If they are, skip
        ldb   VoiceControl,y           ; Otherwise, send a Key Off
        _FMNoteOff                     ; (dependency) should be preceded by A loaded with PlaybackControl,y and B with VoiceControl,y
NoteDyn ldb   #0                       ; (dynamic) retore note value   
        bpl   FMSetDuration            ; Test for 80h not set, which is a note duration
        
FMSetFreq
        subb  #$80                     ; Test for a rest
        bne   @a
        lda   PlaybackControl,y        ; Set bit 1 (track is at rest)
        ora   #$02
        sta   PlaybackControl,y
        bra   @b        
@a      addb  #$0B                     ; Add FMFrequencies offet for C0 Note, access lower notes with transpose
        addb  Transpose,y              ; Add current channel transpose (coord flag E9)
        addb  InstrTranspose,y         ; Add Instrument (Voice) offset (coord flag EF)
        aslb                           ; Transform note into an index...
        ldu   #FMFrequencies
        lda   #0    
        ldd   d,u
        std   NextData,y               ; Store Frequency
@b      ldb   ,x                       ; Get next byte
        bpl   FMSetDurationAndForward  ; Test for 80h not set, which is a note duration
        ldb   SavedDuration,y        
        bra   FinishTrackUpdate
        
NoteFillUpdate
        lda   NoteFillTimeout,y        ; Get current note fill value
        lbeq  DoModulation             ; If zero, return!
        dec   NoteFillTimeout,y        ; Decrement note fill
        bne   DoModulation             ; If not zero, return
        
        lda   PlaybackControl,y
        ora   #$02                     ; Set bit 1 (track is at rest)
        sta   PlaybackControl,y        
        ldb   VoiceControl,y
        _FMNoteOff                     ; (dependency) should be preceded by A loaded with PlaybackControl,y and B with VoiceControl,y         
        rts         

FMSetDurationAndForward
        leax  1,x
        
FMSetDuration
        lda   TempoDivider,y
        mul
        stb   SavedDuration,y
        
FinishTrackUpdate
        stb   DurationTimeout,y        ; Last set duration ... put into ticker
        stx   DataPointer,y            ; Stores to the track pointer memory
        lda   PlaybackControl,y
        bita  #$10                     ; Is bit 4 (10h) "do not attack next note" set on playback?
        beq   @a                       
        bra   FMPrepareNote            ; If so, quit
@a      ldb   NoteFillMaster,y
        stb   NoteFillTimeout,y        ; Reset 0Fh "note fill" value to master
        bita  #$08                     ; Is bit 3 (08h) modulation turned on?
        bne   @b
        bra   FMPrepareNote            ; if not, quit
@b      ldx   ModulationPtr,y
        jsr   SetModulation            ; reload modulation settings for the new note
        
FMPrepareNote
        lda   PlaybackControl,y
        bita  #$04                     ; Is bit 2 (04h) Is SFX overriding this track?
        bne   DoModulation             ; If so skip freq update                                                 
        bita  #$02                     ; Is bit 1 (02h) "track is at rest" set on playback?
        beq   FMUpdateFreqAndNoteOn
        rts                            ; If so, quit
FMUpdateFreqAndNoteOn
        ldb   Detune,y
        sex
        addd  NextData,y               ; Apply detune but don't update stored frequency
        sta   @dyn+1
        lda   #$10                     ; set LSB Frequency Command
        adda  VoiceControl,y
        sta   <YM2413_A0
        adda  #$10                     ; set Sus/Key/Block/FNum(MSB) Command
        stb   <YM2413_D0
        _YMBusyWait9
        ldb   NoteControl,y            ; load current value (do not erase FNum MSB) (and used as 5 cycles tempo)
        orb   #$10                     ; Set bit 4 (10h) Key On
        andb  #$F0                     ; Clear FNum MSB (and used as 2 cycles tempo)
@dyn    addb  #0                       ; (dynamic) Set Fnum MSB (and used as 2 cycles tempo)                
        sta   <YM2413_A0
        stb   NoteControl,y
        stb   <YM2413_D0   
        
DoModulation  
        lda   PlaybackControl,y
        bita  #$02                     ; Is bit 1 (02h) "track is at rest" set on playback?
        beq   @a
        rts                            ; If so, quit        
@a      bita  #$08                     ; Is bit 3 (08h) "modulation on" set on playback?
        bne   @b
        rts                            ; If not, quit        
@b      lda   ModulationWait,y         ; 'ww' period of time before modulation starts
        beq   @c                       ; if zero, go to it!
        dec   ModulationWait,y         ; Otherwise, decrement timer
        rts                            ; return if decremented
@c      dec   ModulationSpeed,y        ; Decrement modulation speed counter
        beq   @d
        rts                            ; Return if not yet zero
@d      ldx   ModulationPtr,y
        lda   1,x
        sta   ModulationSpeed,y
        lda   ModulationSteps,y
        bne   @e
        lda   3,x
        sta   ModulationSteps,y     
        neg   ModulationDelta,y
        rts                
@e      dec   ModulationSteps,y
        ldb   ModulationDelta,y
        sex
        addd  ModulationVal,y
        std   ModulationVal,y        
              
FMUpdateFreq
        lda   PlaybackControl,y
        bita  #$04                     ; Is bit 2 (04h) Is SFX overriding this track?
        bne   @rts
        ldb   Detune,y
        sex
        std   @dyna+1
        ldd   ModulationVal,y          ; get modulation effect
        bmi   @a
        _asrd                          ; modulation is divided by four
        _asrd                          ; used for better precision of delta
        bra   @b
@a      _asrd                          ; modulation is divided by four
        _asrd                          ; used for better precision of delta        
        addd  #1                       ; negative value need +1 when div 
@b      addd  NextData,y               ; apply detune but don't update stored frequency
@dyna   addd  #0                       ; (dynamic) apply detune        
        anda  #$0F
        sta   @dynb+1
        lda   #$10                     ; set LSB Frequency Command
        adda  VoiceControl,y           ; get channel number
        sta   <YM2413_A0               ; send Fnum update Command
        adda  #$10                     ; set Sus/Key/Block/FNum(MSB) Command
        stb   <YM2413_D0               ; send FNum (b0-b7)
        _YMBusyWait11                  ; total wait 20 cycles
        ldb   NoteControl,y            ; load current value (do not erase FNum MSB) (and used as 5 cycles tempo)
        andb  #$F0                     ; clear FNum MSB (and used as 2 cycles tempo)
@dynb   addb  #0                       ; (dynamic) Set Fnum MSB (and used as 2 cycles tempo)        
        sta   <YM2413_A0               ; send command
        stb   NoteControl,y
        stb   <YM2413_D0               ; send FNum (b8) and Block (b0-b2)
@rts    rts        
 
; 95 notes (Note value $81=C0 $DF=A#7) with direct access
; Other notes can be accessed by transpose
FMFrequencies
        fdb   $0056,$005B,$0061,$0067,$006D,$0073,$007A,$0081,$0089,$0091,$009A,$00A2 ; C-1 - B-1
        fdb   $00AD,$00B7,$00C2,$00CD,$00DA,$00E6,$00F4,$0102,$0112,$0122,$0133,$0146 ; C0 - B0
        fdb   $0159,$016D,$0183,$019A,$01B3,$01CC,$01E8,$0302,$0312,$0322,$0333,$0346 ; C1 - B1
        fdb   $0359,$036D,$0383,$039A,$03B3,$03CC,$03E8,$0502,$0512,$0522,$0533,$0546 ; C2 - B2
        fdb   $0559,$056D,$0583,$059A,$05B3,$05CC,$05E8,$0702,$0712,$0722,$0733,$0746 ; C3 - B3
        fdb   $0759,$076D,$0783,$079A,$07B3,$07CC,$07E8,$0902,$0912,$0922,$0933,$0946 ; C4 - B4
        fdb   $0959,$096D,$0983,$099A,$09B3,$09CC,$09E8,$0B02,$0B12,$0B22,$0B33,$0B46 ; C5 - B5
        fdb   $0B59,$0B6D,$0B83,$0B9A,$0BB3,$0BCC,$0BE8,$0D02,$0D12,$0D22,$0D33,$0D46 ; C6 - B6
        fdb   $0D59,$0D6D,$0D83,$0D9A,$0DB3,$0DCC,$0DE8,$0F02,$0F12,$0F22,$0F33,$0F46 ; C7 - B7        
        fdb   $0F59,$0F6D,$0F83,$0F9A,$0FB3,$0FCC,$0FE8,$0FE8,$0FE8,$0FE8,$0FE8,$0FE8 ; C8 - F#8
        fdb   $0FE8,$0FE8,$0FE8,$0FE8,$0FE8,$0FE8,$0FE8,$0FE8                         ; F#8
        
******************************************************************************
* PSG Update Track
******************************************************************************

_PSGNoteOff MACRO                      ; (dependency) should be preceded by A loaded with PlaybackControl,y and B with VoiceControl,y
        bita  #$04                     ; Is SFX overriding set?
        bne   @skip                    ; if true skip note off, sfx is playing               
        orb   #$1F                     ; Volume Off
        stb   <PSG
@skip   equ   *        
 ENDM
 
PSGNoteFillUpdate
        lda   NoteFillTimeout,y        ; Get current note fill value
        lbeq  PSGUpdateVolFX           ; If zero, return!
        dec   NoteFillTimeout,y        ; Decrement note fill
        lbne  PSGUpdateVolFX           ; If not zero, return
        
        lda   PlaybackControl,y
        ora   #$02                     ; Set bit 1 (track is at rest)
        sta   PlaybackControl,y    
        ldb   VoiceControl,y           ; Get "voice control" byte (loads upper bits which specify attenuation setting)
        _PSGNoteOff                    ; (dependency) should be preceded by A loaded with PlaybackControl,y and B with VoiceControl,y
        rts 
 
PSGUpdateTrack
        dec   DurationTimeout,y        ; Decrement duration
        bne   PSGNoteFillUpdate        ; If not time-out yet, go do updates only
        lda   PlaybackControl,y
        anda  #$EF
        sta   PlaybackControl,y        ; When duration over, clear "do not attack" bit 4 (0x10) of track's play control
        
PSGDoNext
        ldx   DataPointer,y
        lda   PlaybackControl,y        ; Clear bit 1 (02h) "track is rest" from track
        anda  #$FD
        sta   PlaybackControl,y        
       
PSGReadCoordFlag        
        ldb   ,x+                      ; Read song data
        cmpb  #$E0
        blo   @a                       ; Test for >= E0h, which is a coordination flag
        jsr   CoordFlag
        bra   PSGReadCoordFlag         ; Read all consecutive coordination flags
@a      bpl   PSGSetDuration           ; Test for 80h not set, which is a note duration
        
PSGSetFreq
        subb  #$81                     ; Test for a rest
        bcc   @a                       ; If a note branch
        lda   PlaybackControl,y        ; If carry (only time that happens if 80h because of earlier logic) this is a rest!
        ora   #$02
        sta   PlaybackControl,y        ; Set bit 1 (track is at rest)
        ldb   VoiceControl,y           ; Get "voice control" byte (loads upper bits which specify attenuation setting)        
        _PSGNoteOff                    ; (dependency) should be preceded by A loaded with PlaybackControl,y and B with VoiceControl,y
        bra   @b
@a      addb  #$03                     ; Add Frequencies offet for C0 Note, access lower notes with transpose
        addb  Transpose,y              ; Add current channel transpose (coord flag E9)
        cmpb  #70                      ; array bound check
        blo   @c
        ldb   #69                      
@c      aslb                           ; Transform note into an index...
        ldu   #PSGFrequencies
        lda   #0    
        ldd   d,u
        std   NextData,y                ; Store Frequency
@b      ldb   ,x                        ; Get next byte
        bpl   PSGSetDurationAndForward  ; Test for 80h not set, which is a note duration
        ldb   SavedDuration,y        
        bra   PSGFinishTrackUpdate

PSGSetDurationAndForward
        leax  1,x
        
PSGSetDuration
        lda   TempoDivider,y
        mul
        stb   SavedDuration,y

PSGFinishTrackUpdate
        stb   DurationTimeout,y        ; Last set duration ... put into ticker
        stx   DataPointer,y            ; Stores to the track pointer memory
        lda   PlaybackControl,y
        bita  #$10                     ; Is bit 4 (10h) "do not attack next note" set on playback?
        beq   @a                       
        bra   PSGDoNoteOn              ; If so, quit
@a      ldb   NoteFillMaster,y
        stb   NoteFillTimeout,y        ; Reset 0Fh "note fill" value to master
        clr   VolFlutter,y             ; Reset PSG flutter byte
        bita  #$08                     ; Is bit 3 (08h) modulation turned on?
        bne   @b
        bra   PSGDoNoteOn              ; if not, quit
@b      ldx   ModulationPtr,y
        jsr   SetModulation            ; reload modulation settings for the new note
        
PSGDoNoteOn
        lda   PlaybackControl,y
        bita  #$06                     ; If either bit 1 ("track in rest") and 2 ("SFX overriding this track"), quit!
        beq   PSGUpdateFreq                       
        rts                            ; If so, quit
PSGUpdateFreq
        ldb   Detune,y
        sex
        addd  NextData,y               ; Apply detune but don't update stored frequency
        std   @dyn+1
        andb  #$0F                     ; Keep only lower four bits (first PSG reg write only applies d0-d3 of freq)
        lda   VoiceControl,y
        cmpa  #$E0
        bne   @a
        addb  #$C0
        bra   @b
@a      addb  VoiceControl,y           ; Get "voice control" byte...
@b      stb   <PSG
@dyn    ldd   #0
        _lsrd
        _lsrd
        _lsrd
        _lsrd              
        stb   <PSG
        bra   PSGDoVolFX
        
PSGUpdateVolFX
        lda   VoiceIndex,y
        beq   PSGDoModulation
        ldb   Volume,y
        stb   DynVol+1          
        bra   PSGFlutter

VolEnvHold
        lda   VolFlutter,y             ; This just decrements the flutter to keep it in place; no more volume changes in this list
        suba  #2                       ; Put index back (before final volume value)
        sta   VolFlutter,y             ; Loop back and update volume
        
PSGDoVolFX
        ldb   Volume,y
        stb   DynVol+1
        lda   VoiceIndex,y
        beq   PSGUpdateVol             ; If tone is zero, jump to PSGUpdateVol
                
PSGFlutter
        asla
        ldx   #PSG_FlutterTbl
        ldx   a,x
        lda   VolFlutter,y
        inc   VolFlutter,y        
        lda   a,x
        bpl   @a
        cmpa  #$80
        beq   VolEnvHold
@a      sta   @b
        addb  #0
@b      equ   *-1
        stb   DynVol+1
                
PSGUpdateVol                
        lda   PlaybackControl,y
        bita  #$06                     ; If either bit 1 ("track in rest") and 2 ("SFX overriding this track"), quit!
        bne   PSGDoModulation          ; If so, branch           
        bita  #$10                     ; Is bit 4 (10h) "do not attack next note" set on playback?
        bne   @b                       ; If so, branch
DynVol  ldb   #0                       ; (dynamic) volume
        cmpb  #$10
        blo   @a
        ldb   #$0F
@a      addb  VoiceControl,y
        orb   #$10
        stb   <PSG
        bra   PSGDoModulation        
@b      lda   NoteFillMaster,y         ; If you get here, then "do not attack next note" was set...
        beq   DynVol                   ; If it's zero, then just process normally
        lda   NoteFillTimeout,y        
        bne   DynVol                   ; If it's not zero, then just process normally
        
PSGDoModulation  
        lda   PlaybackControl,y
        bita  #$02                     ; Is bit 1 (02h) "track is at rest" set on playback?
        beq   @a
        rts                            ; If so, quit        
@a      bita  #$08                     ; Is bit 3 (08h) "modulation on" set on playback?
        bne   @b
        rts                            ; If not, quit        
@b      lda   ModulationWait,y         ; 'ww' period of time before modulation starts
        beq   @c                       ; if zero, go to it!
        dec   ModulationWait,y         ; Otherwise, decrement timer
        rts                            ; return if decremented
@c      dec   ModulationSpeed,y        ; Decrement modulation speed counter
        beq   @d
        rts                            ; Return if not yet zero
@d      ldx   ModulationPtr,y
        lda   1,x
        sta   ModulationSpeed,y
        lda   ModulationSteps,y
        bne   @e
        lda   3,x
        sta   ModulationSteps,y     
        neg   ModulationDelta,y
        rts                
@e      dec   ModulationSteps,y
        ldb   ModulationDelta,y
        sex
        addd  ModulationVal,y
        std   ModulationVal,y        
              
PSGUpdateFreq2
        ldb   Detune,y
        sex
        addd  NextData,y               ; apply detune but don't update stored frequency
        addd  ModulationVal,y          ; add modulation effect
        std   @dyn+1
        andb  #$0F                     ; Keep only lower four bits (first PSG reg write only applies d0-d3 of freq)
        lda   VoiceControl,y
        cmpa  #$E0
        bne   @a
        addb  #$C0
        bra   @b
@a      addb  VoiceControl,y           ; Get "voice control" byte...
@b      stb   <PSG
@dyn    ldd   #0
        _lsrd
        _lsrd
        _lsrd
        _lsrd              
        stb   <PSG
        rts        
 
; 70 notes (Note value $81=C3 $C7=G#8) with direct access
; (Note value $C8 is reserved for PSG3 to drive noise PSG4)
; Other notes can be accessed by transpose
PSGFrequencies
        fdb                                                         $03F8,$03C0,$0388 ; A2 - B2
        fdb   $0356,$0327,$02FA,$02CF,$02A5,$0281,$025C,$023B,$021A,$01FC,$01E0,$01C4 ; C3 - B3
        fdb   $01AB,$0193,$017D,$0167,$0152,$0140,$012E,$011D,$010D,$00FE,$00F0,$00E2 ; C4 - B4
        fdb   $00D5,$00C9,$00BE,$00B3,$00A9,$00A0,$0097,$008E,$0086,$007F,$0078,$0071 ; C5 - B5
        fdb   $006A,$0064,$005F,$0059,$0054,$0050,$004B,$0047,$0043,$0040,$003C,$0039 ; C6 - B6
        fdb   $0035,$0032,$002F,$002C,$002A,$0028,$0025,$0023,$0022,$0020,$001F,$001D ; C7 - B7
        fdb   $001A,$0019,$0017,$0016,$0015,$0014,$0012,$0011,$0010,$0001             ; C8 - G#8
        ; (Last 3 values are also used for channel 3 when driving noise channel. $0000 doesn't work for real SN76489 chip, so was replaced by $0001 value)

PSG_FlutterTbl
    ; Basically, for any tone 0-11, dynamic volume adjustments are applied to produce a pseudo-decay,
    ; or sometimes a ramp up for "soft" sounds, or really any other volume effect you might want!

    ; Remember on PSG that the higher the value, the quieter it gets (it's attenuation, not volume);
    ; 0 is thus loudest, and increasing values decay, until level $F (silent)
        fdb   0 ; saves a dec instruction in table lookup
        fdb   Flutter1,Flutter2,Flutter3,Flutter4
        fdb   Flutter5,Flutter6,Flutter7,Flutter8
        fdb   Flutter9,Flutter10,Flutter11,Flutter12
        fdb   Flutter13
Flutter1
        fcb   0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5
        fcb   5,5,6,6,6,7,$80
Flutter2
        fcb   0,2,4,6,8,$10,$80
Flutter3
        fcb   0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,$80
Flutter4
        fcb   0,0,2,3,4,4,5,5,5,6,$80
Flutter5
        fcb   3,3,3,2,2,2,2,1,1,1,0,0,0,0,$80
Flutter6
        fcb   0,0,0,0,0,0,0,0,0,0,1,1
        fcb   1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2
        fcb   2,2,2,2,3,3,3,3,3,3,3,3,4,$80
Flutter7
        fcb   0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,2
        fcb   3,3,3,4,4,4,5,5,5,6,7,$80
Flutter8
        fcb   0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,2
        fcb   3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,6
        fcb   6,6,6,6,7,7,7,$80
Flutter9
        fcb   0,1,2,3,4,5,6,7,8,9,$0A,$0B,$0C,$0D,$0E,$0F,$80
Flutter10
        fcb   0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
        fcb   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        fcb   1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2
        fcb   2,2,3,3,3,3,3,3,3,3,3,3,4,$80
Flutter11
        fcb   4,4,4,3,3,3,2,2,2,1,1,1,1,1,1,1
        fcb   2,2,2,2,2,3,3,3,3,3,4,$80
Flutter12
        fcb   4,4,3,3,2,2,1,1,1,1,1,1,1,1,1,1
        fcb   1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2
        fcb   2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3
        fcb   3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
        fcb   3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4
        fcb   4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5
        fcb   5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6
        fcb   6,6,6,6,6,6,6,6,6,6,6,6,6,6,7,$80
Flutter13
        fcb   $0E,$0D,$0C,$0B,$0A,9,8,7,6,5,4,3,2,1,0,$80

;   END of PSG_FlutterTbl ---------------------------                 
          
******************************************************************************
* PlaySound - Load and play a new sound effect
*
* receives in X the address of the sound
* destroys X
******************************************************************************          

SFXTrackOffs        
        fdb   SFXFM3                   ; identified by Track id 8002 in smps sfx file (for Sonic 2 compatibility)
        fdb   SFXFM3                   ; identified by Track id 8003 in smps sfx file        
        fdb   SFXFM4                   ; identified by Track id 8004 in smps sfx file        
        fdb   SFXFM5                   ; identified by Track id 8005 in smps sfx file
        fdb   SFXPSG1                  ; identified by Track id 8080 in smps sfx file
        fdb   SFXPSG2                  ; identified by Track id 80A0 in smps sfx file
        fdb   SFXPSG3                  ; identified by Track id 80C0 in smps sfx file
        fdb   SFXPSG3                  ; identified by Track id 80E0 in smps sfx file

MusicTrackOffs
        fdb   SongFM2
        fdb   SongFM3        
        fdb   SongFM4        
        fdb   SongFM5
        fdb   SongPSG1
        fdb   SongPSG2
        fdb   SongPSG3
        fdb   SongPSG3

@rts    puls  d,x,y,u,pc
PlaySound
        pshs  d,x,y,u
        ldx   #Sound_Index
        abx
        ldx   ,x
        stx   SoundData
        beq   @rts

        ; Check Spin Dash
        lda   #0
        sta   zSpindashActiveFlag
        cmpb  #SndID_SpindashRev ; is this the spindash rev sound playing?
        bne   PlaySound_main     ; if not, branch

        lda   zSpindashExtraFrequencyIndex
        tst   zSpindashPlayingCounter
        bne   >                  ; if the spindash sound is already playing, branch
        lda   #-1                ; reset the extra frequency (becomes 0 on the next line)
!
        inca                     ; increase the frequency
        cmpa  #$05
        bhs   >
        sta   zSpindashExtraFrequencyIndex
!
        lda   #$3C
        sta   zSpindashPlayingCounter
        lda   #-1
        sta   zSpindashActiveFlag

PlaySound_main
        ldd   SMPS_SFX_VOICE,x
        addd  SoundData   
        std   Smps.SFXVoiceTblPtr

        ldd   SMPS_SFX_TEMPO_NB_CH,x   ; init process for each track
        sta   @dyna+2        
        stb   PS_cnt
        leax  SMPS_SFX_HDR_LEN,x        
@a      ldu   #MusicTrackOffs
        ldd   SMPS_SFX_TRK_CH,x        ; read playbackcontrol and voice id
        std   @dynb+1
        tstb
        bmi   @psg
        subb  #2                       ; this is an fm track
        aslb                           ; transform track ref to an index: $02,$04,$05 => 0,4,6
        ldy   b,u    
        bra   @c
@psg    cmpb  #$C0
        bne   @b
        lda   #$DF                     ; set silence on PSG3
        sta   <PSG
        lda   #$FF
        sta   <PSG
@b      lsrb                           ; this is a psg track
        lsrb
        lsrb
        lsrb                           ; transform track ref to an index: $80,$A0,$C0,$E0 => 8,10,12,14
        ldy   b,u    
@c      lda   PlaybackControl,y        ; y (hl) ptr to Music Track
        ora   #$04                     ; Set "SFX is overriding this track!" bit
        sta   PlaybackControl,y
        ldu   #SFXTrackOffs
        ldu   b,u                      ; u (ix) ptr to SFX Track
        ldd   #0                       ; clear SFX Track
        std   ,u
        std   2,u
        std   4,u
        std   6,u
        std   8,u
        std   10,u
        std   12,u
        std   14,u
        std   16,u
        std   18,u
        std   20,u
        std   22,u
        std   24,u
        std   26,u
        std   28,u
        std   30,u
        std   32,u
        std   34,u
        std   36,u
        std   38,u
        std   40,u
@dyna   ldd   #$0100                   ; (dynamic) TempoDivider
        sta   DurationTimeout,u        ; current duration timeout to 1 (will expire immediately and thus update)
        stb   TempoDivider,u
@dynb   ldd   #0                       ; (dynamic)
        sta   PlaybackControl,u
        stb   VoiceControl,u
        ldb   #GoSubStack
        stb   StackPointer,u           ; Reset track "gosub" stack
        ldd   SMPS_SFX_TRK_DATA_PTR,x 
        addd  SoundData
        std   DataPointer,u
        ldd   SMPS_SFX_TRK_TR_VOL_PTR,x
        ; If spindash active, the following block updates its frequency specially:
        tst   zSpindashActiveFlag
        beq   >                                  ; If spindash not last sound played, skip this
        adda  zSpindashExtraFrequencyIndex       ; Add spindash key offset!
!       std   TranspAndVolume,u        
        leax  SMPS_SFX_TRK_HDR_LEN,x
        dec   PS_cnt    
        lbne  @a  

        puls  d,x,y,u,pc

PS_cnt  fcb   0
        
******************************************************************************
* CoordFlag
******************************************************************************

CoordFlag
        subb  #$E0
        aslb
        ldu   #CoordFlagLookup
        jmp   [b,u] 

CoordFlagLookup
        fdb   cfSkip1               ; E0 -- unsupported (panning)
        fdb   cfDetune              ; E1 -- done
        fdb   cfSkip1               ; E2 -- unsupported
        fdb   cfJumpReturn          ; E3 -- done
        fdb   cfFadeInToPrevious    ; E4 --todo
        fdb   cfSetTempoDivider     ; E5 -- done
        fdb   cfChangeFMVolume      ; E6 -- done
        fdb   cfPreventAttack       ; E7 -- done
        fdb   cfNoteFill            ; E8 -- done
        fdb   cfChangeTransposition ; E9 -- done
        fdb   cfSetTempo            ; EA -- done
        fdb   cfSetTempoMod         ; EB -- done
        fdb   cfChangePSGVolume     ; EC -- done
        fdb   cfNop                 ; ED -- unsupported
        fdb   cfNop                 ; EE -- unsupported
        fdb   cfSetVoice            ; EF -- done
        fdb   cfModulation          ; F0 -- done
        fdb   cfEnableModulation    ; F1 -- done
        fdb   cfStopTrack           ; F2 -- done
        fdb   cfSetPSGNoise         ; F3 -- done
        fdb   cfDisableModulation   ; F4 -- done
        fdb   cfSetPSGTone          ; F5 -- done
        fdb   cfJumpTo              ; F6 -- done
        fdb   cfRepeatAtPos         ; F7 -- done
        fdb   cfJumpToGosub         ; F8 -- done
        fdb   cfNop                 ; F9 -- unsupported
        fdb   cfNop                 ; FA -- free
        fdb   cfNop                 ; FB -- free
        fdb   cfNop                 ; FC -- free
        fdb   cfNop                 ; FD -- free
        fdb   cfNop                 ; FE -- free
        fdb   cfNop                 ; FF -- free

; (via Saxman's doc): Alter note values by xx
; More or less a pitch bend; this is applied to the frequency as a signed value
;              
cfDetune
        lda   ,x+
        ; this should be replaced by a conversion of the smps music file
        ; here to play sonic2 files only
        ldb   VoiceControl,y           ; read channel nb
        bmi   @a                       ; Is voice control bit 7 (80h) a PSG track set?        
        asra                           ; ratio freq btw YM2612 and YM2413 is 3.73, so tame a bit (/3)
        sta   @dyna+1
        asra        
        sta   @dynb+1
@dyna   lda   #0           
@dynb   suba  #0         
        ; end of tmp code
@a      sta   Detune,y
        rts           

; Return (Sonic 1 & 2)
;
cfJumpReturn
        lda   StackPointer,y           ; retrieve stack ptr
        ldx   a,y                      ; load return address
        adda  #2                       
        sta   StackPointer,y           ; free stack position
        rts         
        
cfFadeInToPrevious
        rts   

; Change tempo divider to xx
;        
cfSetTempoDivider
        lda   ,x+
        sta   TempoDivider,y
        rts    
        
; (via Saxman's doc): Change channel volume BY xx; xx is signed
;
cfChangeFMVolume
        lda   Volume,y                 ; apply volume attenuation change
        adda  ,x+
        sta   Volume,y
        ldb   PlaybackControl,y
        bitb  #$04                     ; Is bit 2 (04h) Is SFX overriding this track?
        bne   @rts        
        lsra                           ; volume attenuation is unsigned
        lsra
        lsra
        sta   @dyn1+1
        lda   #$30
        adda  VoiceControl,y
        sta   <YM2413_A0
        ldb   InstrAndVolume,y         
        tfr   b,a
        ora   #$0F                     ; set maximum attenuation for compare        
        sta   @dyn2+1
@dyn1   addb  #0                       ; (dynamic) add global volume attenuation to actual voice
@dyn2   cmpb  #0                       ; (dynamic) test if overflow of attenuation value
        blo   @write                   ; attenuation < F and no overflow
        tfr   a,b                      ; set maximum attenuation (F)
@write  stb   <YM2413_D0        
@rts    rts     

cfPreventAttack
        lda   PlaybackControl,y
        ora   #$10
        sta   PlaybackControl,y        ; Set bit 4 (10h) on playback control; do not attack next note
        rts      

; (via Saxman's doc): set note fill amount to xx
;
cfNoteFill 
        lda   ,x+
        sta   NoteFillTimeout,y
        sta   NoteFillMaster,y
        rts          

; (via Saxman's doc): add xx to channel key
;
cfChangeTransposition
        lda   Transpose,y
        adda  ,x+
        sta   Transpose,y
        rts

; (via Saxman's doc): set music tempo to xx
;
cfSetTempo 
        lda   ,x+
        sta   Smps.CurrentTempo
        rts          

; (via Saxman's doc): Change Tempo Modifier to xx for ALL channels
;
cfSetTempoMod
        lda   ,x+
        sta   SongDAC.TempoDivider
        sta   SongFM1.TempoDivider
        sta   SongFM2.TempoDivider
        sta   SongFM3.TempoDivider
        sta   SongFM4.TempoDivider
        sta   SongFM5.TempoDivider
        ;sta   SongFM6.TempoDivider
        ;sta   SongFM7.TempoDivider
        ;sta   SongFM8.TempoDivider
        ;sta   SongFM9.TempoDivider        
        sta   SongPSG1.TempoDivider
        sta   SongPSG2.TempoDivider
        sta   SongPSG3.TempoDivider
        ;sta   SongPSG4.TempoDivider        
        rts        

cfChangePSGVolume
        lda   Volume,y
        adda  ,x+
        sta   Volume,y
        rts    
        
; (via Saxman's doc): set voice selection to xx
;
cfSetVoice
        ldb   ,x+
        stb   VoiceIndex,y             ; save voice index to restore voice after sfx        
        lda   PlaybackControl,y
        bita  #$04                     ; Is bit 2 (04h) Is SFX overriding this track?
        bne   @rts                     ; yes skip YM command
        lda   DoSFXFlag
        bmi   @a
        ldu   Smps.VoiceTblPtr
        bra   @b
@a      ldu   Smps.SFXVoiceTblPtr
@b        
        lda   VoiceControl,y           ; read channel nb   
        adda  #$30
        sta   <YM2413_A0
        aslb
        ldd   b,u
        sta   InstrAndVolume,y        
        stb   InstrTranspose,y
        ldb   Volume,y                 ; apply current track attenuation to voice
        lsrb                           ; volume attenuation is unsigned
        lsrb
        lsrb
        stb   @dyn1+1
        ldb   #$30
        addb  VoiceControl,y
        stb   <YM2413_A0
        tfr   a,b
        orb   #$0F                     ; set maximum attenuation for compare        
        stb   @dyn2+1
@dyn1   adda  #0                       ; (dynamic) add global volume attenuation
@dyn2   cmpa  #0                       ; (dynamic) test if overflow of attenuation value
        blo   @write                   ; attenuation < F and no overflow
        tfr   b,a                      ; set maximum attenuation (F)
@write  sta   <YM2413_D0     
@rts    rts

; (via Saxman's doc): F0wwxxyyzz - modulation
; o        ww - Wait for ww period of time before modulation starts
; o        xx - Modulation Speed
; o        yy - Modulation change per Mod. Step
; o        zz - Number of steps in modulation
;
cfModulation
        lda   PlaybackControl,y
        ora   #$08
        sta   PlaybackControl,y        ; Set bit 3 (08h) of "playback control" byte (modulation on)
        stx   ModulationPtr,y          ; Back up modulation setting address
SetModulation
        ldd   ,x++                     ; also read ModulationSpeed
        std   ModulationWait,y         ; also write ModulationSpeed
        ldd   ,x++                     ; also read ModulationSteps
        sta   ModulationDelta,y        
        lsrb                           ; divide number of steps by 2
        stb   ModulationSteps,y
        lda   PlaybackControl,y
        bita  #$10                     ; Is bit 4 "do not attack next note" (10h) set?
        bne   @a                       ; If so, quit!
        ldd   #0
        std   ModulationVal,y          ; Clear modulation value
@a      rts         

; (via Saxman's doc): Turn on modulation
;
cfEnableModulation
        lda   PlaybackControl,y
        ora   #$08
        sta   PlaybackControl,y        ; Set bit 3 (08h) of "playback control" byte (modulation on)
        rts   

; (via Saxman's doc): stop the track
;
cfStopTrack
        lda   PlaybackControl,y
        anda  #$6F                     ; clear playback byte bit 7 (80h) -- currently playing (not anymore)
        sta   PlaybackControl,y        ; clear playback byte bit 4 (10h) -- do not attack
        
        ldb   VoiceControl,y           ; read channel nb
        bmi   @a                       ; Is voice control bit 7 (80h) a PSG track set?
        _FMNoteOff                     ; (dependency) should be preceded by A loaded with PlaybackControl,y and B with VoiceControl,y               
        bra   @b
@a      _PSGNoteOff                    ; (dependency) should be preceded by A loaded with PlaybackControl,y and B with VoiceControl,y
@b      lda   DoSFXFlag
        bmi   @d
@rts    puls  u                        ; removing return address from stack; will not return to coord flag loop
        rts
@d      lda   VoiceControl,y           ; this is SFX Track
        lbmi  @psgsfx
        ldu   #MusicTrackOffs          ; get back the overriden music track
        suba  #2
        asla                           ; transform track ref to an index: $02,$04,$05 => 0,4,6
        ldu   a,u                      ; U ptr to same FM track ID than SFX but for Music, Y still for FM SFX Track
        lda   PlaybackControl,u
        bita  #$04                     ; Is bit 2 (04h) Is SFX overriding this track?
        beq   @rts                     ; if not skip this part (i.e. if SFX was not overriding this track, then nothing to restore)
        anda  #$FB                     ; Clear SFX is overriding this track from playback control
        ora   #$02                     ; Set bit 1 (track is at rest)
        sta   PlaybackControl,u
        ldx   Smps.VoiceTblPtr         ; Restore Voice to music channel (x can be erased because we are stopping track read)        
        ldb   VoiceIndex,u
        lda   VoiceControl,u           ; read channel nb  
        adda  #$30
        sta   <YM2413_A0
        aslb
        ldd   b,x
        sta   InstrAndVolume,u        
        stb   InstrTranspose,u
        ldb   Volume,u                 ; apply current track attenuation to voice
        lsrb                           ; volume attenuation is unsigned
        lsrb
        lsrb
        stb   @dyn1+1
        tfr   a,b
        orb   #$0F                     ; set maximum attenuation for compare        
        stb   @dyn2+1
@dyn1   adda  #0                       ; (dynamic) add global volume attenuation
@dyn2   cmpa  #0                       ; (dynamic) test if overflow of attenuation value
        blo   @write                   ; attenuation < F and no overflow
        tfr   b,a                      ; set maximum attenuation (F)
@write  sta   <YM2413_D0   
        puls  u                        ; removing return address from stack; will not return to coord flag loop
        rts                   
@psgsfx ldu   #MusicTrackOffs
        lsra                           ; this is a psg fx track
        lsra
        lsra
        lsra                           ; transform track ref to an index: $80,$A0,$C0,$E0 => 8,10,12,14
        ldu   a,u                      ; U ptr to same FM track ID than SFX but for Music, Y still for FM SFX Track
        lda   PlaybackControl,u
        anda  #$FB                     ; Clear SFX is overriding this track from playback control
        ora   #$02                     ; Set bit 1 (track is at rest)
        sta   PlaybackControl,u
        lda   VoiceControl,u           ; read channel nb
        cmpa  #$E0                     ; Is this a PSG 3 noise (not tone) track?
        bne   @c                       ; If it isn't, don't do next part (non-PSG Noise doesn't restore)
        lda   PSGNoise,u               ; Get PSG noise setting
        sta   <PSG                     ; Write it to PSG
@c      puls  u                        ; removing return address from stack; will not return to coord flag loop                        
        rts

; (via Saxman's doc): Change current PSG noise to xx (For noise channel, E0-E7)
;
cfSetPSGNoise
        lda   #$E0
        sta   VoiceControl,y
        lda   ,x+
        sta   PSGNoise,y
        ldb   PlaybackControl,y
        bitb  #$04                     ; Is bit 2 (04h) Is SFX overriding this track?
        bne   @rts        
        sta   <PSG
@rts    rts        

cfDisableModulation
        lda   PlaybackControl,y
        anda  #$F7
        sta   PlaybackControl,y        ; Clear bit 3 (08h) of "playback control" byte (modulation off)        
        rts  

; (via Saxman's doc): Change current PSG tone to xx
;
cfSetPSGTone
        lda   ,x+
        sta   VoiceIndex,y
        rts         

; (via Saxman's doc):  $F6zzzz - jump to position
;    * zzzz - position to loop back to (negative offset)
;
cfJumpTo
        ldd   ,x
        leax  d,x
        rts             

; (via Saxman's doc): $F7xxyyzzzz - repeat section of music
;    * xx - loop index, for loops within loops without confusing the engine.
;          o EXAMPLE: Some notes, then a section that is looped twice, then some more notes, and finally the whole thing is looped three times.
;            The "inner" loop (the section that is looped twice) would have an xx of 01, looking something along the lines of F70102zzzz, whereas the "outside" loop (the whole thing loop) would have an xx of 00, looking something like F70003zzzz.
;    * yy - number of times to repeat
;          o NOTE: This includes the initial encounter of the F7 flag, not number of times to repeat AFTER hitting the flag.
;    * zzzz - position to loop back to (negative offset)
;
cfRepeatAtPos
        ldd   ,x++                     ; Loop index is in 'a'
        adda  #LoopCounters            ; Add to make loop index offset
        leau  a,y
        tst   ,u
        bne   @a
        stb   ,u                       ; Otherwise, set it to the new number of repeats  
@a      dec   ,u                       ; One less loop
        beq   @b                       ; If counted to zero, skip the rest of this (hence start loop count of 1 terminates the loop without ever looping)
        ldd   ,x
        leax  d,x                      ; loop back
        rts
@b      leax  2,x
        rts        

; (via Saxman's doc): jump to position yyyy (keep previous position in memory for returning)
cfJumpToGosub
        lda   StackPointer,y
        suba  #2
        sta   StackPointer,y           ; move stack backward
        leau  2,x                      ; move x to return address
        stu   a,y                      ; store return address to stack
        ldd   ,x                       ; read sub address
        leax  d,x                      ; gosub
        rts        

cfSkip1
        leax  1,x
cfNop 
        rts                                                 

tracksStart                ; This is the beginning of all BGM track memory
SongDACFMStart
SongDAC         Track
SongFMStart
SongFM1         Track
SongFM2         Track
SongFM3         Track
SongFM4         Track
SongFM5         Track
SongFM6         Track
SongFM7         Track
SongFM8         Track
SongFM9         Track
SongFMEnd
SongDACFMEnd
SongPSGStart
SongPSG1        Track
SongPSG2        Track
SongPSG3        Track
;SongPSG4        Track
SongPSGEnd
tracksEnd

tracksSFXStart
SFXFMStart
SFXFM3          Track
SFXFM4          Track
SFXFM5          Track
SFXFMEnd
SFXPSGStart
SFXPSG1         Track
SFXPSG2         Track
SFXPSG3         Track
SFXPSGEnd
tracksSFXEnd
StructEnd

        ; I want struct data to be in binary please ...
        ; VoiceControl is hardcoded
        
        org   tracksStart         
        fdb   $0006       
        fill  0,sizeof{Track}-2
        fdb   $0000
        fill  0,sizeof{Track}-2        
        fdb   $0001
        fill  0,sizeof{Track}-2
        fdb   $0002
        fill  0,sizeof{Track}-2
        fdb   $0003
        fill  0,sizeof{Track}-2
        fdb   $0004
        fill  0,sizeof{Track}-2
        fdb   $0005
        fill  0,sizeof{Track}-2
        fdb   $0006
        fill  0,sizeof{Track}-2
        fdb   $0007
        fill  0,sizeof{Track}-2
        fdb   $0008
        fill  0,sizeof{Track}-2
        fdb   $0080
        fill  0,sizeof{Track}-2
        fdb   $00A0
        fill  0,sizeof{Track}-2
        fdb   $00C0
        fill  0,sizeof{Track}-2
        ;fdb   $00E0
        ;fill  0,sizeof{Track}-2
        fdb   $0002
        fill  0,sizeof{Track}-2
        fdb   $0004
        fill  0,sizeof{Track}-2
        fdb   $0005
        fill  0,sizeof{Track}-2
        fdb   $0080
        fill  0,sizeof{Track}-2
        fdb   $00A0
        fill  0,sizeof{Track}-2
        fdb   $00C0
        fill  0,sizeof{Track}-2

zSpindashPlayingCounter      fcb 0
zSpindashExtraFrequencyIndex fcb 0
zSpindashActiveFlag          fcb 0 ; -1 if spindash charge was the last sound that played

* YM2413 Instrument presets
* -------------------------
*
* /* Order of array = { modulator, carrier } */
* typedef struct {
*     Bit8u tl;
*     Bit8u dc;
*     Bit8u dm;
*     Bit8u fb;
*     Bit8u am[2];
*     Bit8u vib[2];
*     Bit8u et[2];
*     Bit8u ksr[2];
*     Bit8u multi[2];
*     Bit8u ksl[2];
*     Bit8u ar[2];
*     Bit8u dr[2];
*     Bit8u sl[2];
*     Bit8u rr[2];
* } opll_patch_t;

* static const opll_patch_t patch_ds1001[opll_patch_max] = {
*     { 0x05, 0x00, 0x00, 0x06,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x01 },{ 0x00, 0x00 },{ 0x03, 0x01 },{ 0x00, 0x00 },{ 0x0e, 0x08 },{ 0x08, 0x01 },{ 0x04, 0x02 },{ 0x02, 0x07 } }, * 1 : Violin
*     { 0x14, 0x00, 0x01, 0x05,{ 0x00, 0x00 },{ 0x00, 0x01 },{ 0x00, 0x00 },{ 0x01, 0x00 },{ 0x03, 0x01 },{ 0x00, 0x00 },{ 0x0d, 0x0f },{ 0x08, 0x06 },{ 0x02, 0x01 },{ 0x03, 0x02 } }, * 2 : Guitar
*     { 0x08, 0x00, 0x01, 0x00,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x01, 0x01 },{ 0x01, 0x01 },{ 0x00, 0x00 },{ 0x0f, 0x0b },{ 0x0a, 0x02 },{ 0x02, 0x01 },{ 0x00, 0x02 } }, * 3 : Piano
*     { 0x0c, 0x00, 0x00, 0x07,{ 0x00, 0x00 },{ 0x00, 0x01 },{ 0x01, 0x01 },{ 0x01, 0x00 },{ 0x01, 0x01 },{ 0x00, 0x00 },{ 0x0a, 0x06 },{ 0x08, 0x04 },{ 0x06, 0x02 },{ 0x01, 0x07 } }, * 4 : Flute
*     { 0x1e, 0x00, 0x00, 0x06,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x01, 0x01 },{ 0x01, 0x00 },{ 0x02, 0x01 },{ 0x00, 0x00 },{ 0x0e, 0x07 },{ 0x01, 0x06 },{ 0x00, 0x02 },{ 0x01, 0x08 } }, * 5 : Clarinet
*     { 0x06, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x02, 0x01 },{ 0x00, 0x00 },{ 0x0a, 0x0e },{ 0x03, 0x02 },{ 0x0f, 0x0f },{ 0x04, 0x04 } }, * 6 : Oboe
*     { 0x1d, 0x00, 0x00, 0x07,{ 0x00, 0x00 },{ 0x00, 0x01 },{ 0x01, 0x01 },{ 0x00, 0x00 },{ 0x01, 0x01 },{ 0x00, 0x00 },{ 0x08, 0x08 },{ 0x02, 0x01 },{ 0x01, 0x00 },{ 0x01, 0x07 } }, * 7 : Trumpet
*     { 0x22, 0x01, 0x00, 0x07,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x01, 0x01 },{ 0x00, 0x00 },{ 0x03, 0x01 },{ 0x00, 0x00 },{ 0x0a, 0x07 },{ 0x02, 0x02 },{ 0x00, 0x01 },{ 0x01, 0x07 } }, * 8 : Organ
*     { 0x25, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x01, 0x00 },{ 0x01, 0x01 },{ 0x05, 0x01 },{ 0x00, 0x00 },{ 0x04, 0x07 },{ 0x00, 0x03 },{ 0x07, 0x00 },{ 0x02, 0x01 } }, * 9 : Horn
*     { 0x0f, 0x00, 0x01, 0x07,{ 0x01, 0x00 },{ 0x00, 0x00 },{ 0x01, 0x00 },{ 0x01, 0x00 },{ 0x05, 0x01 },{ 0x00, 0x00 },{ 0x0a, 0x0a },{ 0x08, 0x05 },{ 0x05, 0x00 },{ 0x01, 0x02 } }, * A : Synthesizer
*     { 0x24, 0x00, 0x00, 0x07,{ 0x00, 0x01 },{ 0x00, 0x01 },{ 0x00, 0x00 },{ 0x01, 0x00 },{ 0x07, 0x01 },{ 0x00, 0x00 },{ 0x0f, 0x0f },{ 0x08, 0x08 },{ 0x02, 0x01 },{ 0x02, 0x02 } }, * B : Harpsichord
*     { 0x11, 0x00, 0x00, 0x06,{ 0x00, 0x00 },{ 0x01, 0x00 },{ 0x01, 0x01 },{ 0x01, 0x00 },{ 0x01, 0x03 },{ 0x00, 0x00 },{ 0x06, 0x07 },{ 0x05, 0x04 },{ 0x01, 0x01 },{ 0x08, 0x06 } }, * C : Vibraphone
*     { 0x13, 0x00, 0x00, 0x05,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x01, 0x02 },{ 0x03, 0x00 },{ 0x0c, 0x09 },{ 0x09, 0x05 },{ 0x00, 0x00 },{ 0x03, 0x02 } }, * D : Synthesizer Bass
*     { 0x0c, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x01, 0x01 },{ 0x01, 0x01 },{ 0x00, 0x00 },{ 0x01, 0x03 },{ 0x00, 0x00 },{ 0x09, 0x0c },{ 0x04, 0x00 },{ 0x03, 0x0f },{ 0x03, 0x06 } }, * E : Acoustic Bass
*     { 0x0d, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x00, 0x01 },{ 0x01, 0x01 },{ 0x00, 0x01 },{ 0x01, 0x02 },{ 0x00, 0x00 },{ 0x0c, 0x0d },{ 0x01, 0x05 },{ 0x05, 0x00 },{ 0x06, 0x06 } }, * F : Electric Guitar
*     /* Rhythm Patches: rows 1 and 4 are bass drum, 2 and 5 are Snare Drum & Hi-Hat, 3 and 6 are Tom and Top Cymbal */
*     { 0x18, 0x00, 0x01, 0x07,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x01, 0x00 },{ 0x00, 0x00 },{ 0x0d, 0x00 },{ 0x0f, 0x00 },{ 0x06, 0x00 },{ 0x0a, 0x00 } },
*     { 0x00, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x01, 0x00 },{ 0x00, 0x00 },{ 0x0c, 0x00 },{ 0x08, 0x00 },{ 0x0a, 0x00 },{ 0x07, 0x00 } },
*     { 0x00, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x05, 0x00 },{ 0x00, 0x00 },{ 0x0f, 0x00 },{ 0x08, 0x00 },{ 0x05, 0x00 },{ 0x09, 0x00 } },
*     { 0x00, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x01 },{ 0x00, 0x00 },{ 0x00, 0x0f },{ 0x00, 0x08 },{ 0x00, 0x06 },{ 0x00, 0x0d } },
*     { 0x00, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x01 },{ 0x00, 0x00 },{ 0x00, 0x0d },{ 0x00, 0x08 },{ 0x00, 0x06 },{ 0x00, 0x08 } },
*     { 0x00, 0x00, 0x00, 0x00,{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x00 },{ 0x00, 0x01 },{ 0x00, 0x00 },{ 0x00, 0x0a },{ 0x00, 0x0a },{ 0x00, 0x05 },{ 0x00, 0x05 } }
* };             