* ---------------------------------------------------------------------------
* YM2413VGM 6809 - YM2413 VGM playback system for 6809
* ---------------------------------------------------------------------------
* by Bentoc December 2022
* ---------------------------------------------------------------------------

        opt   c,ct

YVGM_MusicPage       fcb   0                ; memory page of music data
YVGM_MusicData       fdb   0                ; address of song data
YVGM_MusicDataPos    fdb   0                ; current playing position in Music Data
YVGM_MusicStatus     fcb   0                ; 0 : stop playing, 1-255 : play music
YVGM_WaitFrame       fcb   0                ; number of frames to wait before next play
YVGM_loop            fcb   0                ; 0=no loop

******************************************************************************
* PlayMusic - Load a new music and init all tracks
*
* receives in X the address of the song
* destroys X,A
******************************************************************************

YVGM_PlayMusic
        lda   #0
        rora                           ; move carry into A
        sta   YVGM_loop
        _GetCartPageA
        sta   @a
        lda   ,x                       ; get memory page that contains track data
        sta   YVGM_MusicPage
        sta   YVGM_MusicStatus
        _SetCartPageA
        lda   #1
        sta   YVGM_WaitFrame
        ldx   1,x                      ; get ptr to track data
        stx   YVGM_MusicData
        ldu   #YM2413_buffer
        stu   YVGM_MusicDataPos
        jsr   ym2413zx0_decompress
        lda   #0
@a      equ   *-1
        _SetCartPageA
        rts      

******************************************************************************
* MusicFrame - processes a music frame (VInt)
*
* format:
* -------
* x00-x38 xnn           : (2 bytes) YM2413 registers
* x39                   : (1 byte) end of stream
* x40                   : (1 byte) wait 1 frames
* ...
* xFF                   ; (1 byte) wait 198 frames
*
******************************************************************************
        
YVGM_MusicFrame 
        lda   YVGM_MusicStatus
        bne   @a
        rts    
@a      lda   YVGM_WaitFrame
        deca
        sta   YVGM_WaitFrame
        beq   @UpdateMusic
        rts
@UpdateMusic
        lda   YVGM_MusicPage
        bne   @b
        rts                            ; no music to play
@b      _SetCartPageA
        ldx   YVGM_MusicDataPos
@UpdateLoop
        lda   ,x+
        cmpx  #YM2413_buffer_end
        bne >
        ldx   #YM2413_buffer
!       cmpa  #$39
        blo   @YM2413
@YVGM_DoWait
        suba  #$39
        beq   @DoStopTrack
        sta   YVGM_WaitFrame
        stx   YVGM_MusicDataPos
        jmp   ym2413zx0_resume         ; read next frame data
@DoStopTrack
        lda   vgc_loop
        beq   @no_looping
        lda   #3 ; fix for battlesquadron files should be 1
        sta   YVGM_WaitFrame
        ldx   YVGM_MusicData
        ldu   #YM2413_buffer
        stu   YVGM_MusicDataPos
        jsr   ym2413zx0_decompress    
        jmp   YVGM_MusicFrame  
@no_looping
        lda   #0
        sta   YVGM_MusicStatus
        jsr   YVGM_SilenceAll
        rts
@YM2413
        sta   <YM2413.A
        ldb   ,x+
        cmpx  #YM2413_buffer_end
        bne >
        ldx   #YM2413_buffer
!       stb   <YM2413.D
        nop
        nop                            ; tempo (should be 24 cycles between two register writes)
        bra   @UpdateLoop
******************************************************************************
* FMSilenceAll
* destroys A, B, Y
******************************************************************************
YVGM_SilenceAll
        ldd   #$200E
        stb   YM2413.A
        nop                            ; (wait of 2 cycles)
        ldb   #0                       ; (wait of 2 cycles)
        sta   YM2413.D                ; note off for all drums     
        lda   #$20                     ; (wait of 2 cycles)
        brn   *                        ; (wait of 3 cycles)
@c      exg   a,b                      ; (wait of 8 cycles)                                      
        exg   a,b                      ; (wait of 8 cycles)                                      
        sta   YM2413.A
        nop
        inca
        stb   YM2413.D
        cmpa  #$29                     ; (wait of 2 cycles)
        bne   @c                       ; (wait of 3 cycles)
        rts        

; @zx0_6809_mega.asm - ZX0 decompressor for M6809 - 189 bytes
; Written for the LWTOOLS assembler, http://www.lwtools.ca/.
;
; Copyright (c) 2021 Doug Masten
; ZX0 compression (c) 2021 Einar Saukas, https://github.com/einar-saukas/ZX0
;
; This software is provided 'as-is', without any express or implied
; warranty. In no event will the authors be held liable for any damages
; arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.
;
; ************************************************************************
; ALTERED SOURCE TO BE ABLE TO UNCOMPRESS ON THE FLY WITH A CYCLING BUFFER
; ************************************************************************
;------------------------------------------------------------------------------
; Function    : zx0_decompress
; Entry       : Reg X = start of compressed data
;             : Reg U = start of decompression buffer
; Exit        : Reg X = end of compressed data + 1
;             : Reg U = end of decompression buffer + 1
; Destroys    : Regs D, Y
; Description : Decompress ZX0 data (version 1)
;------------------------------------------------------------------------------
ym2413zx0_decompress
; initialize variables
                   sts @saveS1
                   lds #@stackContext
                   ldd #$80ff
                   sta @zx0_bit         ; init bit stream
                   sex                  ; reg A = $FF
                   std @zx0_offset      ; init offset = -1
; 0 - literal (copy next N bytes from compressed data)
@ym2413zx0_literals bsr @zx0_elias       ; obtain length
                   tfr d,y              ;  "      "
                   bsr @zx0_copy_bytes  ; copy literals
                   bcs @zx0_new_offset  ; branch if next block is new-offset
; 0 - copy from last offset (repeat N bytes from last offset)
                   bsr @zx0_elias       ; obtain length
@zx0_copy          equ *
                   stx @saveX           ; save reg X
                   tfr d,y              ; setup length
@zx0_offset        equ *+2
                   leax >$ffff,u        ; calculate offset address
                   cmpx #YM2413_buffer
                   bhs >
                   leax YM2413_buffer_end-YM2413_buffer,x ; cycle buffer
!                  bsr @zx0_copy_bytes  ; copy match
                   ldx #0               ; restore reg X
@saveX             equ *-2
                   bcc @ym2413zx0_literals ; branch if next block is literals
; 1 - copy from new offset (repeat N bytes from new offset)
@zx0_new_offset    bsr @zx0_elias       ; obtain offset MSB
                   negb                 ; adjust for negative offset (set carry for RORA below)
                   beq @zx0_eof         ; eof? (length = 256) if so exit
                   tfr b,a              ; transfer to MSB position
                   ldb ,x+              ; obtain LSB offset
                   cmpx #YM2413_buffer_end
                   blo >
                   ldx  #YM2413_buffer  ; cycle buffer
!                  rora                 ; last offset bit becomes first length bit
                   rorb                 ;  "     "     "    "      "     "      "
                   std @zx0_offset      ; preserve new offset
                   ldd #1               ; set elias = 1
                   bsr @zx0_elias_bt    ; get length but skip first bit
                   incb                 ; Tiny change to save a couple of CPU cycles
                   bne @zx0_copy        
                   inca
                   bra @zx0_copy        ; copy new offset match
; interlaced elias gamma coding
@zx0_elias         ldd #1               ; set elias = 1
                   bra @zx0_elias_start ; goto start of elias gamma coding
@zx0_elias_loop    lsl @zx0_bit         ; get next bit
                   rolb                 ; rotate elias value
                   rola                 ;   "     "     "
@zx0_elias_start   lsl @zx0_bit         ; get next bit
                   bne @zx0_elias_bt    ; branch if bit stream is not empty
                   sta @saveA           ; save reg A
                   lda ,x+              ; load another 8-bits
                   cmpx #YM2413_buffer_end
                   blo >
                   ldx  #YM2413_buffer  ; cycle buffer
!                  rola                 ; get next bit
                   sta @zx0_bit         ; save bit stream
                   lda #0               ; restore reg A
@saveA             equ *-1
                   endc
@zx0_elias_bt      bcc @zx0_elias_loop  ; loop until done
@zx0_eof           rts                  ; return
; copy Y bytes from X to U and get next bit
@zx0_copy_bytes    ldb ,x+              ; copy byte
                   cmpx #YM2413_buffer_end
                   blo >
                   ldx  #YM2413_buffer  ; cycle buffer
!                  stb ,u+              ;  "    "
                   cmpu #YM2413_buffer_end
                   bne >
                   ldu #YM2413_buffer
; loop until a wait byte is found, this will unpack a whole sound frame
!                  tst @flip            ; handle 2 bytes cmd length
                   bne @nextByte
                   cmpb #$39
                   blo @nextByte        ; continue if a ym2413 cmd byte
; save context for next byte ... and exit
                   pshs d,x,y,u
                   sts @stackContextPos
                   lds #0
@saveS1            equ *-2
                   rts
; next call will resume here ...
ym2413zx0_resume   com @flip
                   sts @saveS1
                   lds @stackContextPos
                   puls d,x,y,u
@nextByte          com @flip
                   leay -1,y            ; decrement loop counter
                   bne @zx0_copy_bytes  ; loop until done
                   lsl @zx0_bit         ; get next bit
                   rts
@zx0_bit  fcb $80
@flip     fcb 0
@stackContextPos fdb 0
          fill 0,32
@stackContext equ *

YM2413_buffer
          fill 0,512
YM2413_buffer_end
