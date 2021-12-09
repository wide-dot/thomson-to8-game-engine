* ---------------------------------------------------------------------------
* SMIDI 6809 - Small Midi playback system for 6809 and EF5860
* ---------------------------------------------------------------------------
* by Bentoc October 2021
* with inputs from Fool-DupleX
* ---------------------------------------------------------------------------

    opt   c,ct

MIDI.CTRL       equ    $E7F2
MIDI.STAT       equ    MIDI.CTRL
MIDI.RX         equ    $E7F3
MIDI.TX         equ    MIDI.RX
MIDI.RXFULL     equ    %00000001
MIDI.TXEMPTY    equ    %00000010
MIDI.RXIRQ      equ    %10000000
MIDI.TXIRQ      equ    %00100000

FIRQ.ROUTINE    equ    $6023

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
        pshs  d
        lda   #$ff
        sta   MusicLoop                ; set the loop flag on
        bra   @a
PlayMusic
        pshs  d
@a      stx   MusicIndex               ; store index for loop restart
        stx   MusicIndexPos            ; init data chunck index position
        lda   sound_page,x             ; get memory page that contains track data
        sta   MusicPage
        sta   MusicStatus              ; no data on page 0, page is used to init status to a non zero value
        ldd   #1
        stb   WaitFrame                ; wait frame is only zero where reading commands, should be init to 1
        ldx   sound_start_addr,x       ; get ptr to track data
        stx   MusicDataPos             ; init data location
	sta   CircularBufferEnd+1      ; init buffer index to 0
	sta   CircularBufferPos+2      ; init buffer index to 0
	ldd   #SampleFIRQ              ; set the FIRQ routine that will be called when the EF5860 tx buffer is empty
	std   FIRQ.ROUTINE
        puls  d,pc

******************************************************************************
* MusicFrame - processes a music frame (IRQ - DP $E7)
*
* format:
* -------
* xnn
*   |____ x00               : (1 byte) next page/adr or end of data
*   |____ x01-x7f           : (1 byte) wait xnn frames
*   |____ x80-xff xnn (xnn) : (2 or 3 bytes) command, data1, (data2)
*   |____ xf0 xnn ... xf7   : (x bytes) SysEx
*
* destroys A,B,X,Y
******************************************************************************
_enableFIRQ MACRO
	lda   MIDI.CTRL
	anda  #^MIDI.TXIRQ
        sta   MIDI.CTRL
 ENDM 

_writeBuffer MACRO
        sta   b,y                      ; send byte to the midi interface
	incb
	stb   CircularBufferEnd+1
        lda   ,x+
 ENDM 

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
        leax  sound_meta_size,x        ; move to next index
        lda   sound_page,x             ; get memory page that contains track data
        beq   IsMusicLoop              ; this is an end of track
LoopRestart
        sta   MusicPage                ; store the new page
        stx   MusicIndexPos            ; this is an end of data chunck, save new index
        ldx   sound_start_addr,x       ; get ptr to track data
	bra   @a
        ;
ReadCommand
        ldb   CircularBufferEnd+1      ; load next free position in circular buffer
	ldy   #CircularBuffer
        ldx   MusicDataPos             ; load current position in music track
        lda   MusicPage
@a      _SetCartPageA
        lda   ,x+                      ; read data byte in new page

CommandLoop
        bmi   DoCommand
        beq   BankSwitch

DoWait
        sta   WaitFrame
        stx   MusicDataPos
	_enableFIRQ
        rts

DoCommand
        cmpa  #$C0
        blo   TXRdy3b                  ; branch (command 8n to Bn, 2 data bytes)
        cmpa  #$E0                
        blo   TXRdy2b                  ; branch (command Cn and Dn, 1 data byte)
        cmpa  #$f0
        beq   DoSysEx                  ; branch (sysex)
                                       ; default (command En, 2 data byte)

TXRdy3b                             
        _writeBuffer

TXRdy2b
        _writeBuffer
        _writeBuffer
        bra   CommandLoop

DoSysEx
        _writeBuffer
        cmpa  #$f7
        bne   DoSysEx
        _writeBuffer
        bra   CommandLoop

******************************************************************************
* SampleFIRQ - send a sample to the midi interface (FIRQ)
*
******************************************************************************

SampleFIRQ
        sta   @a+1                     ; backup register A
	lda   CircularBufferPos+2      ; read current offset in buffer
CircularBufferEnd
	cmpa  #0                       ; (dynamic) end offset in buffer (set by IRQ routine when buffer is written)
	beq   DisableFIRQ             ; branch if no more data to read (todo shutdown midi interface interupt until next buffer write ?)
	inc   CircularBufferPos+2      ; increment the offset in buffer
CircularBufferPos	
        lda   CircularBuffer           ; (dynamic) read the buffer at the current index
        sta   MIDI.TX                  ; send byte to the midi interface           
@a      lda   #0                       ; (dynamic) restore register A
        rti
DisableFIRQ
	lda   MIDI.CTRL
	anda  #^MIDI.TXIRQ
        sta   MIDI.CTRL
        rti

        align 256
CircularBuffer
        fill  0,256

; todo IRQ routine must record the byte in buffer and then increment the last index, FIRQ is able to run simultaneously
; todo at encoding stage a frame is not allowed to hold more than 62 midi bytes, place a warning
