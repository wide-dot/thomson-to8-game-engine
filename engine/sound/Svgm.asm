* ---------------------------------------------------------------------------
* SVGM 6809 - Small VGM playback system for 6809
* ---------------------------------------------------------------------------
* by Bentoc October 2021
* ---------------------------------------------------------------------------

        opt   c,ct

MusicPage       fcb   0                ; memory page of music data
MusicData       fdb   0                ; address of song data
MusicDataPos    fdb   0                ; current playing position in Music Data
MusicStatus     fcb   0                ; 0 : stop playing, 1-255 : play music
WaitFrame       fcb   0                ; number of frames to wait before next play

******************************************************************************
* PlayMusic - Load a new music and init all tracks
*
* receives in X the address of the song
* destroys X
******************************************************************************

PlayMusic
        pshs  d
        lda   ,x                       ; get memory page that contains track data
        sta   MusicPage
        sta   MusicStatus
        lda   #1
        sta   WaitFrame
        ldx   1,x                      ; get ptr to track data
        stx   MusicData
        stx   MusicDataPos
        puls  d,pc        

******************************************************************************
* MusicFrame - processes a music frame (VInt)
*
* format:
* -------
* x00-x38 xnn           : (2 bytes) YM2413
* x40-xff               : (1 byte)  SN76489
* x39     xnn           : (2 bytes) command code xnn (x00-xff)
*   |____ x00           : (2 bytes) stop track
*   |____ xnn           : (2 bytes) wait xnn frames (x01-x7f)
*
* For future use (not yet available) :
*   |____ x80 xnnnn     : (4 bytes) jump to xnnnn 
*   |____ x81 xnnnn xnn : (5 bytes) replay at xnnnn (unsigned offset to start) xnn bytes and return
*
* replay offset is 16bits, it can address 4 pages of 16Ko
*
* destroys A,B,X,Y
******************************************************************************
        
MusicFrame 
        lda   MusicStatus
        bne   @a
        rts    
@a      lda   WaitFrame
        deca
        sta   WaitFrame
        beq   UpdateMusic
        rts

UpdateMusic
        lda   MusicPage
        bne   @a
        rts                            ; no music to play
@a      _SetCartPageA
        ldx   MusicDataPos

UpdateLoop
        lda   ,x+
        cmpa  #$39
        beq   DoCommand
        blo   YM2413

SN76489        
        sta   <SN76489.D
        bra   UpdateLoop

DoCommand
        lda   ,x+
        beq   DoStopTrack
        bmi   DoSpecialCommand
        
DoWait
        sta   WaitFrame
        stx   MusicDataPos

DoSpecialCommand
        rts        

DoStopTrack
        lda   #0
        sta   MusicStatus
        lda   #1
        sta   WaitFrame
        ldx   MusicData
        stx   MusicDataPos        
        jsr   PSGSilenceAll
        jsr   FMSilenceAll
        rts
               
YM2413
        sta   <YM2413.A
        ldb   ,x+
        stb   <YM2413.D
        nop
        nop                            ; tempo (should be 24 cycles between two register writes)
        bra   UpdateLoop

******************************************************************************
* PSGSilenceAll
* destroys A
******************************************************************************
        
PSGSilenceAll
        lda   #$9F
        sta   SN76489.D
        lda   #$BF
        sta   SN76489.D       
        lda   #$DF
        sta   SN76489.D
        lda   #$FF
        sta   SN76489.D                               
        rts  

******************************************************************************
* FMSilenceAll
* destroys A, B, Y
******************************************************************************

FMSilenceAll
        ldd   #$200E
        stb   YM2413.A
        nop                            ; (wait of 2 cycles)
        ldb   #0                       ; (wait of 2 cycles)
        sta   YM2413.D                ; note off for all drums     

        lda   #$20                     ; (wait of 2 cycles)
        brn   *                        ; (wait of 3 cycles)
@a      exg   a,b                      ; (wait of 8 cycles)                                      
        exg   a,b                      ; (wait of 8 cycles)                                      
        sta   YM2413.A
        nop
        inca
        stb   YM2413.D
        cmpa  #$29                     ; (wait of 2 cycles)
        bne   @a                       ; (wait of 3 cycles)
        rts        