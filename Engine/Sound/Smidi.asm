* ---------------------------------------------------------------------------
* SMIDI 6809 - Small Midi playback system for 6809
* ---------------------------------------------------------------------------
* by Bentoc October 2021
* with inputs from Fool-DupleX
* ---------------------------------------------------------------------------

    opt   c,ct

MIDI.CTRL       EQU    $E7F2
MIDI.STAT       EQU    MIDI.CTRL
MIDI.RX         EQU    $E7F3
MIDI.TX         EQU    MIDI.RX
MIDI.RXFULL     EQU    $01
MIDI.TXEMPTY    EQU    $02
MIDI.RXIRQ      EQU    $80

MusicLoop       fcb   0                ; 0 : do not loop music
MusicIndex      fdb   0                ; first index of all data chuncks (page, address)
MusicIndexPos   fdb   0                ; position in index
MusicPage       fcb   0                ; current memory page of music data
MusicDataPos    fdb   0                ; current playing position in Music Data
MusicStatus     fcb   0                ; 0 : stop playing, 1-255 : play music
WaitFrame       fcb   0                ; number of frames to wait before next play

******************************************************************************
* ResetMidi - Reset Midi Controller
*
******************************************************************************

ResetMidi
        pshs  a
        lda   #$03
        sta   MIDI.CTRL                ; reset midi controller
        lda   #$15               
        sta   MIDI.CTRL                ; no r/w interrupt
        puls  a,pc

******************************************************************************
* PlayMusic - Load a new music and init midi interface
*
* receives in X the address of the song
* destroys X
******************************************************************************

PlayMusicLoop
        pshs  a
        lda   #$ff
        sta   MusicLoop                ; set the loop flag on
        bra   @a
PlayMusic
        pshs  a
@a      stx   MusicIndex               ; store index for loop restart
        stx   MusicIndexPos            ; init data chunck index position
        lda   ,x                       ; get memory page that contains track data
        sta   MusicPage
        sta   MusicStatus              ; no data on page 0, page is used to init status to a non zero value
        lda   #1
        sta   WaitFrame                ; wait frame is only zero where reading commands, should be init to 1
        ldx   1,x                      ; get ptr to track data
        stx   MusicDataPos             ; init data location
        puls  a,pc

******************************************************************************
* MusicFrame - processes a music frame (VInt - DP $E7)
*
* format:
* -------
* xnn
*   |____ x00               : (1 byte) next page/adr or end of data
*   |____ x01-x7f           : (1 byte) wait xnn frames
*   |____ x80-xff xnn (xnn) : (2 or 3 bytes) command, data1, (data2)
*   |____ xf0 xnn ... xf7   : (x bytes) SysEx
*
* destroys A,B,X
******************************************************************************

MusicFrame 
        lda   MusicStatus              ; check if a music track is to play
        bne   @a
        rts    
@a      dec   WaitFrame
        beq   ReadCommand              ; no more frame to wait, play the next commands
        rts

IsMusicLoop
        lda   MusicLoop
        beq   StopMusic
        ldx   MusicIndex
	lda   ,x
        bra   LoopRestart
    
StopMusic
        sta   MusicStatus
        sta   MusicLoop
        rts

BankSwitch        
        ldx   MusicIndexPos            ; read byte was $00, this is end of data chunk or music track
        leax  5,x                      ; move to next index
        lda   ,x                       ; get memory page that contains track data
        beq   IsMusicLoop              ; this is an end of track
LoopRestart
        sta   MusicPage                ; store the new page
        stx   MusicIndexPos            ; this is an end of data chunck, save new index
        ldx   1,x                      ; get ptr to track data
	bra   @a
        ;
ReadCommand
        ldx   MusicDataPos             ; load current position in music track
        lda   MusicPage
@a      _SetCartPageA
    
CommandLoop
        lda   ,x+                      ; read data byte in new page
        bmi   DoCommand
        beq   BankSwitch

DoWait
        sta   WaitFrame
        stx   MusicDataPos
        rts

DoCommand
        cmpa  #$C0
        blo   TXRdyLoop0               ; skip 2 bytes (command 8n to Bn, 2 data byte)
        cmpa  #$E0                
        blo   TXRdyLoop1               ; skip 1 byte  (command Cn and Dn, 1 data byte)
        cmpa  #$f0
        beq   DoSysEx
                                       ; bne: skip 2 bytes (command En, 2 data byte)
TXRdyLoop0
        ldb   <MIDI.STAT               ; wait interface to be ready
        andb  #MIDI.TXEMPTY
        beq   TXRdyLoop0              
        sta   <MIDI.TX                 ; send byte to the midi interface
        lda   ,x+

TXRdyLoop1             
        ldb   <MIDI.STAT               ; wait interface to be ready
        andb  #MIDI.TXEMPTY
        beq   TXRdyLoop1             
        sta   <MIDI.TX                 ; send byte to the midi interface
        lda   ,x+

TXRdyLoop2             
        ldb   <MIDI.STAT               ; wait interface to be ready
        andb  #MIDI.TXEMPTY
        beq   TXRdyLoop2              
        sta   <MIDI.TX                 ; send byte to the midi interface
        bra  CommandLoop   

DoSysEx
        ldb   <MIDI.STAT               ; wait interface to be ready
        andb  #MIDI.TXEMPTY
        beq   DoSysEx              
        sta   <MIDI.TX                 ; send byte to the midi interface
        lda   ,x+
        cmpa  #$f7
        bne   DoSysEx
        sta   <MIDI.TX                 ; send byte to the midi interface           
        bra  CommandLoop