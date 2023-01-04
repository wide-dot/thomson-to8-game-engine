* ---------------------------------------------------------------------------
* SMPS 6809 - Sample Music Playback System for 6809 (LWASM)
* Handle both YM2413 and SN76489 or Midi ouput (EF5860)
* ---------------------------------------------------------------------------
* by Bentoc Dec 2022, based on :
* Sonic the Hedgehog 2 (SEGA) disassembled Z80 sound driver
* Disassembled by Xenowhirl for AS
* Additional disassembly work by RAS Oct 2008
* RAS' work merged into SVN by Flamewing
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

* ---------------------------------------------------------------------------
* MIDI constants
* ---------------------------------------------------------------------------

MIDI.CTRL                    equ    $E7F2
MIDI.TX                      equ    $E7F3
MIDI.TXIRQON                 equ    %00110101 ; 8bits, no parity check, stop 1, tx interrupt
MIDI.TXIRQOFF                equ    %00010101 ; 8bits, no parity check, stop 1, no interrupt

FIRQ.ROUTINE                 equ    $6023

midi_gm                      equ 0
midi_mt                      equ 1
midi_gs                      equ 2
midi_xg                      equ 3

* ---------------------------------------------------------------------------
* MIDI variables
* ---------------------------------------------------------------------------

midiOnFmSynth  fcb 0 ; 0 : FMSynth | >0 : Midi
midiOnFmDrums  fcb 0 ; 0 : FMDrums | >0 : Midi
midiOnPsg      fcb 0 ; 0 : PSG     | >0 : Midi

MidiStd        fcb midi_mt
MidiDrums      fdb MidiVoices_MT_Drums_Mode0

MidiVoices_Drums_Mode0
        fdb   MidiVoices_GM_Drums
        fdb   MidiVoices_MT_Drums_Mode0
        fdb   MidiVoices_GS_Drums
        fdb   MidiVoices_XG_Drums

MidiVoices_Drums_Mode1
        fdb   MidiVoices_GM_Drums
        fdb   MidiVoices_MT_Drums_Mode1
        fdb   MidiVoices_GS_Drums
        fdb   MidiVoices_XG_Drums

MidiVoices_GM_Drums ; NoteOn|Channel,Note
        fcb    $99,36 ; $81 - CH10 - Drum - Kick (Acou BD)
        fcb    $99,38 ; $82 - CH10 - Drum - Snare (Acou SD)
        fcb    $99,39 ; $83 - CH10 - Drum - Clap (Hand Clap)
        fcb    $99,72 ; $84 - CH10 - Drum - Scratch (Smba Whis L) approx.
        fcb    $90,50 ; $85 - CH01 - Program 48 - Timpani (D3)
        fcb    $99,48 ; $86 - CH10 - Drum - Hi Tom (Acou Hi Tom)
        fcb    $99,64 ; $87 - CH10 - Drum - Bongo (Low Conga)
        fcb    $90,53 ; $88 - CH01 - Program 48 - Hi Timpani (F3)
        fcb    $90,52 ; $89 - CH01 - Program 48 - Mid Timpani (E3)
        fcb    $90,49 ; $8A - CH01 - Program 48 - Mid Low Timpani (Db3)
        fcb    $90,48 ; $8B - CH01 - Program 48 - Low Timpani (C3)
        fcb    $99,45 ; $8C - CH10 - Drum - Mid Tom (Acou Mid Tom)
        fcb    $99,43 ; $8D - CH10 - Drum - Low Tom (Acou Low Tom)
        fcb    $99,41 ; $8E - CH10 - Drum - Floor Tom (Acou Low Tom)
        fcb    $99,60 ; $8F - CH10 - Drum - Hi Bongo (High Bongo)
        fcb    $99,61 ; $90 - CH10 - Drum - Mid Bongo (Low Bongo)
        fcb    $99,63 ; $91 - CH10 - Drum - Low Bongo (High Conga)

MidiVoices_MT_Drums_Mode0 ; NoteOn|Channel,Note
        fcb    $99,36 ; $81 - CH10 - Drum - Kick (Acou BD)
        fcb    $99,38 ; $82 - CH10 - Drum - Snare (Acou SD)
        fcb    $99,39 ; $83 - CH10 - Drum - Clap (Hand Clap)
        fcb    $99,72 ; $84 - CH10 - Drum - Scratch (Smba Whis L)
        fcb    $99,66 ; $85 - CH10 - Drum - Timpani (Low Timbale)
        fcb    $99,48 ; $86 - CH10 - Drum - Hi Tom (Acou Hi Tom)
        fcb    $99,64 ; $87 - CH10 - Drum - Bongo (Low Conga)
        fcb    $99,65 ; $88 - CH10 - Drum - Hi Timpani (High Timbale)
        fcb    $99,65 ; $89 - CH10 - Drum - Mid Timpani (High Timbale)
        fcb    $99,66 ; $8A - CH10 - Drum - Mid Low Timpani (Low Timbale)
        fcb    $99,66 ; $8B - CH10 - Drum - Low Timpani (Low Timbale)
        fcb    $99,45 ; $8C - CH10 - Drum - Mid Tom (Acou Mid Tom)
        fcb    $99,43 ; $8D - CH10 - Drum - Low Tom (Acou Low Tom)
        fcb    $99,41 ; $8E - CH10 - Drum - Floor Tom (Acou Low Tom)
        fcb    $99,60 ; $8F - CH10 - Drum - Hi Bongo (High Bongo)
        fcb    $99,61 ; $90 - CH10 - Drum - Mid Bongo (Low Bongo)
        fcb    $99,63 ; $91 - CH10 - Drum - Low Bongo (High Conga)

MidiVoices_MT_Drums_Mode1  ; NoteOn|Channel,Note - this mode use Timpani on CH09 instead of PSG3 (use this when Noise mode is ON)
        fcb    $99,36 ; $81 - CH10 - Drum - Kick (Acou BD)
        fcb    $99,38 ; $82 - CH10 - Drum - Snare (Acou SD)
        fcb    $99,39 ; $83 - CH10 - Drum - Clap (Hand Clap)
        fcb    $99,72 ; $84 - CH10 - Drum - Scratch (Smba Whis L) approx.
        fcb    $98,50 ; $85 - CH09 - Program 48 - Timpani (D3)
        fcb    $99,48 ; $86 - CH10 - Drum - Hi Tom (Acou Hi Tom)
        fcb    $99,64 ; $87 - CH10 - Drum - Bongo (Low Conga)
        fcb    $98,53 ; $88 - CH09 - Program 48 - Hi Timpani (F3)
        fcb    $98,52 ; $89 - CH09 - Program 48 - Mid Timpani (E3)
        fcb    $98,49 ; $8A - CH09 - Program 48 - Mid Low Timpani (Db3)
        fcb    $98,48 ; $8B - CH09 - Program 48 - Low Timpani (C3)
        fcb    $99,45 ; $8C - CH10 - Drum - Mid Tom (Acou Mid Tom)
        fcb    $99,43 ; $8D - CH10 - Drum - Low Tom (Acou Low Tom)
        fcb    $99,41 ; $8E - CH10 - Drum - Floor Tom (Acou Low Tom)
        fcb    $99,60 ; $8F - CH10 - Drum - Hi Bongo (High Bongo)
        fcb    $99,61 ; $90 - CH10 - Drum - Mid Bongo (Low Bongo)
        fcb    $99,63 ; $91 - CH10 - Drum - Low Bongo (High Conga)

MidiVoices_GS_Drums ; NoteOn|Channel,Note
        fcb    $99,36 ; $81 - CH10 - Drum - Kick (Acou BD)
        fcb    $99,38 ; $82 - CH10 - Drum - Snare (Acou SD)
        fcb    $99,39 ; $83 - CH10 - Drum - Clap (Hand Clap)
        fcb    $99,30 ; $84 - CH10 - Drum - Scratch (Scratch Pull) better do PullPushPull
        fcb    $90,50 ; $85 - CH01 - Program 48 - Timpani (D3)
        fcb    $99,48 ; $86 - CH10 - Drum - Hi Tom (Acou Hi Tom)
        fcb    $99,64 ; $87 - CH10 - Drum - Bongo (Low Conga)
        fcb    $90,53 ; $88 - CH01 - Program 48 - Hi Timpani (F3)
        fcb    $90,52 ; $89 - CH01 - Program 48 - Mid Timpani (E3)
        fcb    $90,49 ; $8A - CH01 - Program 48 - Mid Low Timpani (Db3)
        fcb    $90,48 ; $8B - CH01 - Program 48 - Low Timpani (C3)
        fcb    $99,45 ; $8C - CH10 - Drum - Mid Tom (Acou Mid Tom)
        fcb    $99,43 ; $8D - CH10 - Drum - Low Tom (Acou Low Tom)
        fcb    $99,41 ; $8E - CH10 - Drum - Floor Tom (Acou Low Tom)
        fcb    $99,60 ; $8F - CH10 - Drum - Hi Bongo (High Bongo)
        fcb    $99,61 ; $90 - CH10 - Drum - Mid Bongo (Low Bongo)
        fcb    $99,63 ; $91 - CH10 - Drum - Low Bongo (High Conga)

MidiVoices_XG_Drums ; NoteOn|Channel,Note
        fcb    $99,36 ; $81 - CH10 - Drum - Kick (Acou BD)
        fcb    $99,38 ; $82 - CH10 - Drum - Snare (Acou SD)
        fcb    $99,39 ; $83 - CH10 - Drum - Clap (Hand Clap)
        fcb    $99,18 ; $84 - CH10 - Drum - Scratch (Low Scratch)
        fcb    $90,50 ; $85 - CH01 - Program 48 - Timpani (D3)
        fcb    $99,48 ; $86 - CH10 - Drum - Hi Tom (Acou Hi Tom)
        fcb    $99,64 ; $87 - CH10 - Drum - Bongo (Low Conga)
        fcb    $90,53 ; $88 - CH01 - Program 48 - Hi Timpani (F3)
        fcb    $90,52 ; $89 - CH01 - Program 48 - Mid Timpani (E3)
        fcb    $90,49 ; $8A - CH01 - Program 48 - Mid Low Timpani (Db3)
        fcb    $90,48 ; $8B - CH01 - Program 48 - Low Timpani (C3)
        fcb    $99,45 ; $8C - CH10 - Drum - Mid Tom (Acou Mid Tom)
        fcb    $99,43 ; $8D - CH10 - Drum - Low Tom (Acou Low Tom)
        fcb    $99,41 ; $8E - CH10 - Drum - Floor Tom (Acou Low Tom)
        fcb    $99,60 ; $8F - CH10 - Drum - Hi Bongo (High Bongo)
        fcb    $99,61 ; $90 - CH10 - Drum - Mid Bongo (Low Bongo)
        fcb    $99,63 ; $91 - CH10 - Drum - Low Bongo (High Conga)

* ---------------------------------------------------------------------------
* MIDI routines
* ---------------------------------------------------------------------------

 ; reset midi controller
 ; ---------------------

ResetMidiCtrl
        pshs  a
        lda   #$03
        sta   MIDI.CTRL
        lda   #MIDI.TXIRQOFF
        sta   MIDI.CTRL
        puls  a,pc

 ; init midi driver
 ; ----------------

InitMidiDrv
        sta   CircularBufferEnd+1      ; init buffer index to 0
        sta   CircularBufferPos+2      ; init buffer index to 0
        ldd   #SampleFIRQ              ; set the FIRQ routine that will be called when the EF5860 tx buffer is empty
        std   FIRQ.ROUTINE
        andcc #$BF                     ; activate FIRQ
        rts


 ; sends a sample to the midi interface (FIRQ)
 ; -------------------------------------------

SampleFIRQ
        sta   @a+1                     ; backup register A
        lda   CircularBufferPos+2      ; read current offset in buffer
CircularBufferEnd
        cmpa  #0                       ; (dynamic) end offset in buffer (set by IRQ routine when buffer is written)
        beq   DisableFIRQ              ; branch if no more data to read (todo shutdown midi interface interupt until next buffer write ?)
CircularBufferPos       
        lda   CircularBuffer           ; (dynamic) read the buffer at the current index
        sta   MIDI.TX                  ; send byte to the midi interface           
        inc   CircularBufferPos+2      ; increment the offset in buffer
@a      lda   #0                       ; (dynamic) restore register A
        rti
DisableFIRQ
        lda   #MIDI.TXIRQOFF
        sta   MIDI.CTRL
        bra   @a

        align 256
        fill  0,128
CircularBuffer
        fill  0,128

_enableFIRQ MACRO
        lda   #MIDI.TXIRQON
        sta   MIDI.CTRL
 ENDM 

 ; sends a message (3 bytes) to midi interface
 ; -------------------------------------------

midiWrite
        pshs  y
        ldb   CircularBufferEnd+1      ; load next free position in circular buffer
        addb  #$80                     ; adjust offset because write is made with 8 bit offset (-128,+127)
        ldy   #CircularBuffer          ; and reading buffer is made by direct address (lda   CircularBuffer)
        lda   #0
midi_d1 equ *-1
        sta   b,y                      ; write byte to the buffer
        incb
        lda   #0
midi_d2 equ *-1
        sta   b,y                      ; write byte to the buffer
        incb
        lda   #0
midi_d3 equ *-1
        sta   b,y                      ; write byte to the buffer
        incb
        addb  #$80
        stb   CircularBufferEnd+1
        addb  #$80
        _enableFIRQ
        puls  y,pc

 ; sends a short message (2 bytes) to midi interface
 ; -------------------------------------------------

midiWriteShort
        pshs  y
        ldb   CircularBufferEnd+1      ; load next free position in circular buffer
        addb  #$80                     ; adjust offset because write is made with 8 bit offset (-128,+127)
        ldy   #CircularBuffer          ; and reading buffer is made by direct address (lda   CircularBuffer)
        lda   #0
midi_sd1 equ *-1
        sta   b,y                      ; write byte to the buffer
        incb
        lda   #0
midi_sd2 equ *-1
        sta   b,y                      ; write byte to the buffer
        incb
        addb  #$80
        stb   CircularBufferEnd+1
        addb  #$80
        _enableFIRQ
        puls  y,pc

 ; write a sysex message to midi interface
 ; ---------------------------------------

midiWriteSysEx
        std   @xend
        ldb   CircularBufferEnd+1      ; load next free position in circular buffer
        addb  #$80                     ; adjust offset because write is made with 8 bit offset (-128,+127)
        ldy   #CircularBuffer          ; and reading buffer is made by direct address (lda   CircularBuffer)
!       lda   ,x+
        sta   b,y                      ; write byte to the buffer
        incb
        cmpx  #0
@xend   equ   *-2
        bne   <
        addb  #$80
        stb   CircularBufferEnd+1
        addb  #$80
        _enableFIRQ
        rts

* ---------------------------------------------------------------------------
* MIDI macros
* ---------------------------------------------------------------------------

_midiWriteSysEx MACRO
        pshs  x,y
        ldx   #\1
        ldd   #\2
        jsr   midiWriteSysEx
        puls  x,y
 ENDM

_midiWrite MACRO
        lda   #\1
        sta   midi_d1
        lda   #\2
        sta   midi_d2
        lda   #\3
        sta   midi_d3
        jsr   midiWrite
 ENDM

_midiWriteShort MACRO
        lda   #\1
        sta   midi_sd1
        lda   #\2
        sta   midi_sd2
        jsr   midiWriteShort
 ENDM

_midiWriteNoteA MACRO
        sta   midi_d2
        lda   #\1
        sta   midi_d1
        lda   #\2
        sta   midi_d3
        jsr   midiWrite
 ENDM

_midiWriteNoteD MACRO
        sta   midi_d1
        stb   midi_d2
        lda   #\1
        sta   midi_d3
        jsr   midiWrite
 ENDM

_midiWriteNote MACRO
        sta   midi_d1
        stb   midi_d2
        lda   #$0F
        suba  Volume,y
        asla
        asla
        asla
        sta   midi_d3
        jsr   midiWrite
 ENDM

* ---------------------------------------------------------------------------

Track STRUCT
                                                      ;         "playback control"; bits 
                                                      ;         1 (02h)  seems to be "track is at rest"
                                                      ;         2 (04h)  SFX is overriding this track
                                                      ;         3 (08h)  modulation on
                                                      ;         4 (10h)  do not attack next note
                                                      ;         7 (80h)  track is playing
PlaybackControl                rmb   1
                                                      ;         "voice control"; bits 
                                                      ;         0-3 FM Channel number
                                                      ;         5-7 PSG Track
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
NoteControl                    rmb   1                ;
MidiNoteControl                rmb   2                ; Note on|Channel|Note (Used to be able to send a Note Off)
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
PSGNoise                       rmb   1                ; PSG noise setting (11100xxx), where xxx means :
                                                      ; (Periodic noise: ($E0) 000 high pitch, ($E1) 001 mid pitch, ($E2) 010 low pitch, ($E3) 011 tone 3 frequency)
                                                      ; (White noise   : ($E4) 100 high pitch, ($E5) 101 mid pitch, ($E6) 110 low pitch, ($E7) 111 tone 3 frequency)
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
MidiNoteControl              equ   3
TempoDivider                 equ   5
DataPointer                  equ   6
TranspAndVolume              equ   8
Transpose                    equ   8
Volume                       equ   9
VoiceIndex                   equ   10
VolFlutter                   equ   11
StackPointer                 equ   12
DurationTimeout              equ   13
SavedDuration                equ   14
NextData                     equ   15
NoteFillTimeout              equ   17
NoteFillMaster               equ   18
ModulationPtr                equ   19
ModulationWait               equ   21
ModulationSpeed              equ   22
ModulationDelta              equ   23
ModulationSteps              equ   24
ModulationVal                equ   25
Detune                       equ   27
VolTLMask                    equ   28
PSGNoise                     equ   29
TLPtr                        equ   30
InstrTranspose               equ   32 
InstrAndVolume               equ   33 
LoopCounters                 equ   34   
GoSubStack                   equ   44

******************************************************************************

SmpsVar STRUCT
SFXPriorityVal                 rmb   1        
TempoTimeout                   rmb   1        
CurrentTempo                   rmb   1                ; Stores current tempo value here
StopMusic                      rmb   1                ; Set to 7Fh to pause music, set to 80h to unpause. Otherwise 00h
FadeOutCounter                 rmb   1        
FadeOutDelay                   rmb   1        
QueueToPlay                    rmb   1                ; if NOT set to 80h, means new index was requested by 68K
SFXToPlay                      rmb   2                ; When Genesis wants to play "normal" sound, it writes it here
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

SFXPriorityVal                 equ   0
TempoTimeout                   equ   1        
CurrentTempo                   equ   2
StopMusic                      equ   3
FadeOutCounter                 equ   4        
FadeOutDelay                   equ   5        
QueueToPlay                    equ   6
SFXToPlay                      equ   7
VoiceTblPtr                    equ   9
SFXVoiceTblPtr                 equ   11
FadeInFlag                     equ   13       
FadeInDelay                    equ   14        
FadeInCounter                  equ   15        
_1upPlaying                    equ   16        
TempoMod                       equ   17        
TempoTurbo                     equ   18
SpeedUpFlag                    equ   19        
DACEnabled                     equ   20                
_60HzData                      equ   21

******************************************************************************

StructStart
Smps          SmpsVar
        org   Smps                
        fill  0,sizeof{SmpsVar}

tracksStart                     ; This is the beginning of all BGM track memory
SongDACFMStart
SongDAC       Track             ; DAC / FM Drum / Midi Drum
        org   SongDAC     
        fdb   $0006             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFMStart
SongFM1       Track             ; FM 1 / Midi 1
        org   SongFM1     
        fdb   $0000             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFM2       Track             ; FM 2 / Midi 2
        org   SongFM2     
        fdb   $0001             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFM3       Track             ; FM 3 / Midi 3
        org   SongFM3     
        fdb   $0002             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFM4       Track             ; FM 4 / Midi 4
        org   SongFM4     
        fdb   $0003             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFM5       Track             ; FM 5 / Midi 5
        org   SongFM5     
        fdb   $0004             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFM6       Track             ; FM 6
        org   SongFM6     
        fdb   $0005             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFM7       Track             ; FM 7 / FM Drum mode
        org   SongFM7     
        fdb   $0006             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFM8       Track             ; FM 8 / FM Drum mode
        org   SongFM8     
        fdb   $0007             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFM9       Track             ; FM 9 / FM Drum mode
        org   SongFM9     
        fdb   $0008             ; VoiceControl
        fill  0,sizeof{Track}-2
SongFMEnd
SongDACFMEnd
SongPSGStart
SongPSG1      Track              ; PSG 1 / Midi 6
        org   SongPSG1     
        fdb   $0080             ; VoiceControl
        fill  0,sizeof{Track}-2
SongPSG2      Track             ; PSG 2 / Midi 7
        org   SongPSG2     
        fdb   $00A0             ; VoiceControl
        fill  0,sizeof{Track}-2
SongPSG3      Track             ; PSG 3 / Midi 8
        org   SongPSG3     
        fdb   $00C0             ; VoiceControl
        fill  0,sizeof{Track}-2
SongPSGEnd
tracksEnd

tracksSFXStart
SFXFMStart
SFXFM3        Track
        org   SFXFM3     
        fdb   $0002             ; VoiceControl
        fill  0,sizeof{Track}-2
SFXFM4        Track
        org   SFXFM4     
        fdb   $0004             ; VoiceControl
        fill  0,sizeof{Track}-2
SFXFM5        Track
        org   SFXFM5     
        fdb   $0005             ; VoiceControl
        fill  0,sizeof{Track}-2
SFXFMEnd
SFXPSGStart
SFXPSG1       Track
        org   SFXPSG1     
        fdb   $0080             ; VoiceControl
        fill  0,sizeof{Track}-2
SFXPSG2       Track
        org   SFXPSG2     
        fdb   $00A0             ; VoiceControl
        fill  0,sizeof{Track}-2
SFXPSG3       Track
        org   SFXPSG3     
        fdb   $00C0             ; VoiceControl
        fill  0,sizeof{Track}-2
SFXPSGEnd
tracksSFXEnd
StructEnd
                
******************************************************************************

PALUpdTick      fcb   0     ; this counts from 0 to 5 to periodically "double update" for PAL systems (basically every 6 frames you need to update twice to keep up)
DoSFXFlag       fcb   0     ; flag to indicate we're updating SFX (and thus use custom voice table); set to FFh while doing SFX, 0 when not.
Paused          fcb   0     ; 0 = normal, -1 = pause all sound and music
SongDelay       fcb   0     ; song header delay

MusicPage       fcb   0     ; memory page of music data
SoundPage       fcb   0     ; memory page of sound data
MusicData       fdb   0     ; address of song data
SoundData       fdb   0     ; address of sound data


MUSIC_TRACK_COUNT = (tracksEnd-tracksStart)/sizeof{Track}
MUSIC_DAC_FM_TRACK_COUNT = (SongDACFMEnd-SongDACFMStart)/sizeof{Track}
MUSIC_FM_TRACK_COUNT = (SongFMEnd-SongFMStart)/sizeof{Track}
MUSIC_PSG_TRACK_COUNT = (SongPSGEnd-SongPSGStart)/sizeof{Track}

SFX_TRACK_COUNT = (tracksSFXEnd-tracksSFXStart)/sizeof{Track}
SFXFM_TRACK_COUNT = (SFXFMEnd-SFXFMStart)/sizeof{Track}
SFXPSG_TRACK_COUNT = (SFXPSGEnd-SFXPSGStart)/sizeof{Track}

FMVoices_Drums
        fcb   $30 ; $81 - Kick  (BD+TOM)
        fcb   $28 ; $82 - Snare (SNARE noise+TOM)
        fcb   $21 ; $83 - Clap
        fcb   $22 ; $84 - Scratch
        fcb   $24 ; $85 - Timpani
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
        jsr   MidiSilenceAll

        ldu   #SongDAC+sizeof{Track}
        jsr   ClearTrack
        ldu   #SongFM1+sizeof{Track}
        jsr   ClearTrack
        ldu   #SongFM2+sizeof{Track}
        jsr   ClearTrack  
        ldu   #SongFM3+sizeof{Track}
        jsr   ClearTrack  
        ldu   #SongFM4+sizeof{Track}
        jsr   ClearTrack  
        ldu   #SongFM5+sizeof{Track}
        jsr   ClearTrack

        ldu   #SongPSG1+sizeof{Track}
        jsr   ClearTrack 
        ldu   #SongPSG2+sizeof{Track}
        jsr   ClearTrack 
        ldu   #SongPSG3+sizeof{Track}
        jsr   ClearTrack 

        ldu   #SFXFM3+sizeof{Track}
        jsr   ClearTrack 
        ldu   #SFXFM4+sizeof{Track}
        jsr   ClearTrack 
        ldu   #SFXFM5+sizeof{Track}
        jsr   ClearTrack 

        ldu   #SFXPSG1+sizeof{Track}
        jsr   ClearTrack 
        ldu   #SFXPSG2+sizeof{Track}
        jsr   ClearTrack 
        ldu   #SFXPSG3+sizeof{Track}
        jsr   ClearTrack 
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
* MidiSilenceAll
* destroys A
******************************************************************************
        
MidiSilenceAll
        _midiWrite $B1,$7B,0 ; send all note off on channel 2  (FM equiv 5x)
        _midiWrite $B2,$7B,0 ; send all note off on channel 3
        _midiWrite $B3,$7B,0 ; send all note off on channel 4
        _midiWrite $B4,$7B,0 ; send all note off on channel 5
        _midiWrite $B5,$7B,0 ; send all note off on channel 6
        _midiWrite $B6,$7B,0 ; send all note off on channel 7  (PSG equiv 3x)
        _midiWrite $B7,$7B,0 ; send all note off on channel 8
        _midiWrite $B8,$7B,0 ; send all note off on channel 9
        _midiWrite $B9,$7B,0 ; send all note off on channel 10 (Drums)
        rts   

******************************************************************************
* PlayMusic - Load a new music and init all tracks
*
* receives in X the address of the song
* destroys X
******************************************************************************

PlayMusic
BGMLoad
        pshs  d,y,u
        _GetCartPageA
        sta   BGMLoad_page              ; backup data page
                
        lda   ,x                       ; get memory page that contains track data
        sta   MusicPage
        ldx   1,x                      ; get ptr to track data
        stx   MusicData
        _SetCartPageA

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
        lda   MidiStd                  ; reset midi settings based on current midi std
        asla
        ldx   #MidiVoices_Drums_Mode0
        ldd   a,x
        std   MidiDrums
        jsr   ResetMidiPrograms        ; apply midi programs based on current midi std and Mode
        lda   #0                       ; (dynamic) set back data page
BGMLoad_page equ *-1
        _SetCartPageA
        puls  d,y,u,pc

InitTrackFM
        lda   SongDelay        
        sta   TempoDivider,y
        lda   PlaybackControl,y
        ora   #$82
        sta   PlaybackControl,y
        ldb   #$01
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

ResetMidiPrograms
        lda   MidiStd
        cmpa  #midi_mt
        beq   @mt
        ; GM/GS/XG
        _midiWriteShort $C0,48         ; set midi program to Timpani for CH01
        _midiWriteShort $C6,81         ; set midi program to Square Wave for CH07
        _midiWriteShort $C7,81         ; set midi program to Square Wave for CH08
        _midiWriteShort $C8,81         ; set midi program to Square Wave for CH09
        bra   @rts
@mt     ; MT-32
        _midiWriteSysEx MT_ReverbOff,MT_ReverbOff_end
        _midiWriteShort $C6,48         ; set midi program to Square Wave for CH07
        _midiWriteShort $C7,48         ; set midi program to Square Wave for CH08
        _midiWriteShort $C8,48         ; set midi program to Square Wave for CH09
        lda   SongPSG3.VoiceControl
        cmpa  #$E0
        bne   @rts
        lda   MidiStd                  ; reset midi settings based on current midi std
        asla
        ldx   #MidiVoices_Drums_Mode1  ; select Mode1 to allow the use of Timpani on CH09 for MT-32 instead of psg3 emul
        std   MidiDrums
        _midiWriteShort $C8,113         ; set midi program to Timpani for CH09
        puls  a,x
@rts    rts

MT_ReverbOff
        fcb   $F0,$41,$10,$16,$12 ; sysex header and command
        fcb   $10,$00,$03         ; parameter to alter (system area|reverb level)
        fcb   $00                 ; param value
        fcb   128-($10+$00+$03+$00) ; checksum
        fcb   $F7                 ; end of sysex
MT_ReverbOff_end

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
        ldx   Smps.SFXToPlay           ; get last requested sound effect to play
        beq   @a                       ; 0 means no sound effect to play
        jsr   PlaySound
        ldd   #0                       ; reset to be able to play another effect from now
        std   Smps.SFXToPlay
@a       
        lda   MusicPage                ; page switch to the music
        lbeq  UpdateSound              ; no music to play
        _SetCartPageA
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
        jmp   UpdateSound

@rts    rts
UpdateMusic
        * jsr   TempoWait              ; optim : do not call TempoWait, instead skip update
        lda   Smps.CurrentTempo        ; tempo value
        adda  Smps.TempoTimeout        ; Adds previous value to
        sta   Smps.TempoTimeout        ; Store this as new
        bcc   @rts                     ; skip update if tempo need more waits
        lda   midiOnFmDrums
        beq   @FMSample
@MidiSample
        _UpdateTrack SongDAC,MidiSampleUpdateTrack
        bra   @FMTracks
@FMSample
        _UpdateTrack SongDAC,FMSampleUpdateTrack
@FMTracks
        _UpdateTrack SongFM1,FMUpdateTrack
        _UpdateTrack SongFM2,FMUpdateTrack
        _UpdateTrack SongFM3,FMUpdateTrack
        _UpdateTrack SongFM4,FMUpdateTrack
        _UpdateTrack SongFM5,FMUpdateTrack     
        _UpdateTrack SongPSG1,PSGUpdateTrack
        _UpdateTrack SongPSG2,PSGUpdateTrack        
        _UpdateTrack SongPSG3,PSGUpdateTrack
        rts

UpdateSound        
        lda   SoundPage                ; page switch to the sound
        bne   @a
        rts
@a      _SetCartPageA
        lda   #$80
        sta   DoSFXFlag                ; Set zDoSFXFlag = 80h (updating sound effects)
        _UpdateTrack SFXFM3,FMUpdateTrack
        _UpdateTrack SFXFM4,FMUpdateTrack
        _UpdateTrack SFXFM5,FMUpdateTrack
        _UpdateTrack SFXPSG1,PSGUpdateTrack
        _UpdateTrack SFXPSG2,PSGUpdateTrack        
        _UpdateTrack SFXPSG3,PSGUpdateTrack
@rts    rts

******************************************************************************
* FMSampleUpdateTrack
* input Y (ptr to SONGDAC, is used by CoordFlag)
* destroys A,B,X
******************************************************************************

FMSampleUpdateTrack        
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
        ldx   #FMVoices_Drums
        subb  #$81                     ; transform note into an index...      
        lda   #$0E
        sta   <YM2413_A0
        ldb   b,x
        stb   <YM2413_D0      
        rts

******************************************************************************
* MidiSampleUpdateTrack
* input Y (ptr to SONGDAC, is used by CoordFlag)
* destroys A,B,X
******************************************************************************

MidiSampleUpdateTrack        
        dec   SongDAC.DurationTimeout
        beq   >
        rts
!
        ldd   SongDAC.MidiNoteControl  ; remember last played channel/note on this track
        _midiWriteNoteD 0              ; note off
        ldx   SongDAC.DataPointer
!       ldb   ,x+                      ; read DAC song data
        cmpb  #$E0
        blo   >                        ; test for >= E0h, which is a coordination flag
        jsr   CoordFlag
        bra   <                        ; read all consecutive coordination flags 
!       
        bpl   MidiSetDuration              ; test for 80h not set, which is a note duration
        stb   SongDAC.NextData         ; This is a note; store it here
        ldb   ,x
        bpl   MidiSetDurationAndForward    ; test for 80h not set, which is a note duration
        ldb   SongDAC.SavedDuration
        bra   MidiDACAfterDur

MidiSetDurationAndForward
        leax  1,x
MidiSetDuration
        lda   SongDAC.TempoDivider
        mul
        stb   SongDAC.SavedDuration
MidiDACAfterDur
        stb   SongDAC.DurationTimeout
        stx   SongDAC.DataPointer
        ldb   SongDAC.NextData
        cmpb  #$80
        bne   >
        rts                            ; if a rest, quit
!
        ldx   MidiDrums
        subb  #$81                     ; transform note into an index...      
        aslb
        ldd   b,x                      ; get the note by mapping based on current midi std
        std   SongDAC.MidiNoteControl  ; backup for note off
        _midiWriteNoteD 127            ; note on full velocity
        rts

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
        bita  #$04                     ; is SFX overriding set?
        bne   @skip                    ; if true skip note off, sfx is playing               
        lda   midiOnPsg
        beq   @psg                     ; if midi is off do psg
        ldd   MidiNoteControl,y        ; remember last played channel/note on this track
        _midiWriteNoteD 0              ; note off
        bra   @skip
@psg    orb   #$1F                     ; Volume Off
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
@a      addb  #$03                     ; Add Frequencies offet for C3 Note, access lower notes with transpose
        addb  Transpose,y              ; Add current channel transpose (coord flag E9)
        cmpb  #70                      ; array bound check
        blo   @c
        ldb   #69
@c      tst   midiOnPsg
        beq   >
        addb  #45                      ; lowest PSG note is A2 witch is Midi note 45
        std   NextData,y               ; Store note
        bra   @b
!       aslb                           ; Transform note into an index...
        ldu   #PSGFrequencies
        lda   #0    
        ldd   d,u
        std   NextData,y               ; Store Frequency
@b      ldb   ,x                       ; Get next byte
        bpl   PSGSetDurationAndForward ; Test for 80h not set, which is a note duration
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
        bita  #$06                     ; if either bit 1 ("track in rest") and 2 ("SFX overriding this track"), quit!
        bne   @rts
        ldb   midiOnPsg
        beq   PSGUpdateFreq            ; if midi is off do psg
        lda   VoiceControl,y
        cmpa  #$E0
        bne   >                        ; branch if PSG channel is 0,1,2 or 3 is a square wave channel
        ldd   #$992A                   ; Play Hi-Hat (note on|CH10, note 42)
        std   MidiNoteControl,y        ; backup for note off
        _midiWriteNote
        bra   PSGDoVolFX
!       lsla                           ; transform $80,$A0,$C0 in 0,1,2
        rola
        rola
        adda  #$96                     ; note on ($90) + square wave start at Midi CH07
        ldb   NextData,y               ; Play square wave midi note
        std   MidiNoteControl,y        ; backup for note off
        _midiWriteNote
        bra   PSGDoVolFX
@rts    rts

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
        stb   <PSG                     ; update volume
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

PlaySound
        pshs  d,y,u

        _GetCartPageA
        sta   PlaySound_end+1          ; backup data page
        lda   ,x                       ; get memory page that contains track data
        sta   SoundPage
        ldx   1,x                      ; get ptr to track data
        stx   SoundData
        _SetCartPageA
        
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
        std   TranspAndVolume,u        
        leax  SMPS_SFX_TRK_HDR_LEN,x
        dec   PS_cnt    
        lbne  @a  

PlaySound_end
        lda   #0
        _SetCartPageA          
        puls  d,y,u,pc

PS_cnt  fcb   0
        
******************************************************************************
* Midi Conversion
******************************************************************************
FreqMod2PitchBend MACRO
        addd  #$2000                   ; pitch adj is signed 14 bit
        bmi   >
        andb  #$7F
        stb   midi_d2
        anda  #$3F
        asla
        inca
        sta   midi_d3
        bra   @write
!       andb  #$7F
        stb   midi_d2
        anda  #$3F
        asla
        sta   midi_d3
@write  jsr   midiWrite
 ENDM

FM_FreqMod2PitchBend MACRO
        andb  #$9F
        lsrb
        lsrb
        lsrb
        lsrb
        lsrb
        addb  #6
        orb   #$E0                     ; midi pitch bender | channel
        stb   midi_d1
        ldb   #93
        mul
        FreqMod2PitchBend
 ENDM
     
PSG_FreqMod2PitchBend MACRO
        orb   #$E0                     ; midi pitch bender | channel
        stb   midi_d1
        ldb   #0
        nega
        _asld
        FreqMod2PitchBend
 ENDM


                                       ; 
                                       ; Private Function DB2MidiVol(ByVal DB As Single) As Byte
                                       ; 
                                       ;     Dim TempSng As Single
                                       ;     
                                       ;     TempSng = 10! ^ (DB / 40!)
                                       ;     If TempSng > 1! Then TempSng = 1!
                                       ;     DB2MidiVol = TempSng * &H7F
                                       ; 
                                       ; End Function
                                       ; 
                                       ; Private Function OPN_Vol2DB(ByVal TL As Byte, ByVal PanVal As Byte, ByVal ChnType As Byte) _
                                       ;                             As Single
                                       ; 
                                       ;     Dim DBVol As Single
                                       ;     
                                       ;     ' the YM2612 is twice as loud as the PSG,
                                       ;     ' so I either need to add 6 db here, or subtract 6 db from the PSG
                                       ;     DBVol = -TL * 3 / 4!
                                       ;     If PanVal <> 0 Then
                                       ;         DBVol = DBVol + PAN_DB
                                       ;     End If
                                       ;     'If Opt_BoostYM And ChnType = CHNTYPE_FM Then
                                       ;     If Opt_BoostYM Then
                                       ;         DBVol = DBVol + 6!
                                       ;     End If
                                       ;     OPN_Vol2DB = DBVol
                                       ; 
                                       ; End Function
                                       ; 
                                       ; Private Function PSG_Vol2DB(ByVal TL As Byte, ByVal PanVal As Byte) As Single
                                       ; 
                                       ;     Dim DBVol As Single
                                       ;     
                                       ;     If TL < &HF Then
                                       ;         DBVol = -TL * 2
                                       ;         If PanVal <> 0 Then
                                       ;             DBVol = DBVol + PAN_DB
                                       ;         End If
                                       ;         If Opt_BoostYM = 0 And SmpsHead.SMPSVer <> SMPSVER_SMS Then
                                       ;             DBVol = DBVol - 6!
                                       ;         End If
                                       ;         PSG_Vol2DB = DBVol
                                       ;     Else
                                       ;         PSG_Vol2DB = -400   ' results in volume 0
                                       ;     End If
                                       ; 
                                       ; End Function

******************************************************************************
* CoordFlag
******************************************************************************

CoordFlag
        subb  #$E0
        aslb
        ldu   #CoordFlagLookup
        jmp   [b,u] 

CoordFlagLookup
        fdb   cfPan                 ; E0 -- panning (midi only)
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

cfPan
                                       ; TempSht = PanVal
                                       ; Select Case TempByt And &HC0
                                       ; Case &H0, &HC0
                                       ;     TempByt = &H40  ' Center
                                       ;     PanVal = &H0
                                       ; Case &H80
                                       ;     TempByt = &H0   ' Left
                                       ;     PanVal = &H1
                                       ; Case &H40
                                       ;     TempByt = &H7F  ' Right
                                       ;     PanVal = &H1
                                       ; End Select
                                       ; Call WriteEvent(&HB0 Or MidChn, &HA, TempByt, MidPos)
                                       ; 
                                       ; ' If the next command is NOT a volume change ...
                                       ; If SmpsData(SmpsPos + &H2) = &HE6 Or SmpsData(SmpsPos + &H2) = &HEC Then
                                       ;     TempSht = PanVal
                                       ; End If
                                       ; If TempSht <> PanVal Then
                                       ;     If ChnType = CHNTYPE_FM Or ChnType = CHNTYPE_DAC Then
                                       ;         ' recalculate and rewrite volume
                                       ;         MidiVol = DB2MidiVol(OPN_Vol2DB(VolVal And &H7F, PanVal, ChnType))
                                       ;         If Opt_NoteVel = &H0 Then
                                       ;             Call WriteEvent(&HB0 Or MidChn, &H7, MidiVol, MidPos)
                                       ;         End If
                                       ;     End If
                                       ; End If
                                       ; End If  ' Sonic 2/3K only END
        rts

; (via Saxman's doc): Alter note values by xx
; More or less a pitch bend; this is applied to the frequency as a signed value
;              
cfDetune
        lda   ,x+
        ldb   VoiceControl,y           ; read channel nb
        bmi   >                        ; Is voice control bit 7 (80h) a PSG track set?     
 ; YM2413 - Midi
        FM_FreqMod2PitchBend
 ; YM2413
        lda   -1,x
        asra                           ; ratio freq btw YM2612 and YM2413 is 3.73, so tame a bit (/3)
        sta   @dyna+1
        asra        
        sta   @dynb+1
@dyna   lda   #0           
@dynb   suba  #0         
        sta   Detune,y
        rts    
 ; SN76489
!       sta   Detune,y
 ; SN76489 - Midi
        PSG_FreqMod2PitchBend
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
        sta   SongPSG1.TempoDivider
        sta   SongPSG2.TempoDivider
        sta   SongPSG3.TempoDivider
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

; ; Midi modulation
;        ldb   VoiceControl,y           ; read channel nb
;        orb   #$B0                     ; midi modulation | channel
;        stb   midi_d1
;        ldd   -2,x                     ; multiply modulation value by steps
;        bpl   >                        ; make modulation value absolute
;        coma
;!       mul                            ; get frequency
;        cmpd  #64 ; valeur a revoir
;        bls   >
;        lda   #1 ; may cap to 8 instead of 1
;        bra   @continue
;!       cmpd  #6096 ; valeur a revoir
;        bhs   >
;        lda   #127
;        bra   @end
;
; ; FM  frq = (frq * 4096 / 44) / 48
; ; approx. = (frq * 3 * 170) / 255
;
; ; PSG frq = (frq * 128) / 48
; ; approx. = (frq * 4 * 170) / 255
;
;        tst   VoiceControl,y           ; read channel nb
;        bmi   >                        ; Is voice control bit 7 (80h) a PSG track set?
; ; YM2413 - Midi
;
; ; SN76489 - Midi
;!
;
;!       _lsrd ; div by 48, simplified version : frequency = ((frequency / 32) * 170) / 255
;        _lsrd ; PSG only 2 _lsrd

;        lda   #170
;        mul
;@end    sta   xxx ; Call WriteEvent(&HB0 Or MidChn, &H1, ModVal, MidPos)
;        ; do common stuff
;        rts

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
        lda   MusicPage
        _SetCartPageA        
        ldx   Smps.VoiceTblPtr       ; Restore Voice to music channel (x can be erased because we are stopping track read)        
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
        lda   SoundPage
        _SetCartPageA  
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
cfSetPSGNoise
        lda   #$E0
        sta   VoiceControl,y
        lda   ,x+
        sta   PSGNoise,y

        ldb   midiOnPsg
        beq   @psg
        pshs  a,x
        lda   MidiStd                  ; reset midi settings based on current midi std
        asla
        ldx   #MidiVoices_Drums_Mode1  ; select Mode1 to allow the use of Timpani on CH09 for MT-32 instead of psg3 emul
        ldd   a,x
        std   MidiDrums
        _midiWriteShort $C8,113        ; set midi program to Timpani for CH09
        puls  a,x,pc                   ; rts
        ;
@psg    ldb   PlaybackControl,y
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

ClearTrack
        pshs  d,x,y
        ldd   #$0000        ; init regs to zero
        ldx   #$0000
        leay  ,x

        fill $36,((sizeof{Track}-2)/6)*2 ; generate object_size/6 assembly instructions $3636 (pshu  d,x,y) 

        IFEQ (sizeof{Track}-2)%6-5
        pshu  a,x,y
        ENDC

        IFEQ (sizeof{Track}-2)%6-4
        pshu  d,x
        ENDC

        IFEQ (sizeof{Track}-2)%6-3
        pshu  a,x
        ENDC

        IFEQ (sizeof{Track}-2)%6-2
        pshu  d
        ENDC

        IFEQ (sizeof{Track}-2)%6-1
        pshu  a
        ENDC

        puls  d,x,y,pc

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

