;******************************************************************
; 6502 BBC Micro Compressed VGM (VGC) Music Player
; By Simon Morris
; https://github.com/simondotm/vgm-player-bbc
; https://github.com/simondotm/vgm-packer
;
; 6809 version
; By Benoit Rousseau
;******************************************************************

;---------------------------------------------------------------
; VGM Player Library code
;---------------------------------------------------------------

;--------------------------------------------------
; user callable routines:
;  vgc_init
;  vgc_update
;  sn_reset
;  sn_write
;--------------------------------------------------

;-------------------------------------------
; vgc_play
;-------------------------------------------
; Initialise playback routine
;  B=1 for looped playback, 0 for no loop
;  X point to the VGC data stream to be played
;-------------------------------------------
vgc_init
        lda   #vgc_stream_buffers/256  ; HI byte of a page aligned 2Kb RAM buffer address
        sta   vgc_buffers              ; stash the 2kb buffer address
        stb   vgc_loop
        sty   vgc_callback
        lda   ,x                       ; get memory page that contains track data
        sta   vgc_source_page
        _GetCartPageB
        stb   @a
        _SetCartPageA
        ldx   1,x                      ; get ptr to track data
        stx   vgc_source               ; stash the data source addr for looping
        jsr   vgc_stream_mount         ; Prepare the data for streaming (passed in X)
        lda   #0
@a      equ   *-1
        _SetCartPageA
        rts

;-------------------------------------------
; vgc_update
;-------------------------------------------
;  call every 50Hz to play music
;  vgc_init must be called prior to this
; On entry A is non-zero if the music should be looped
;  returns non-zero when VGC is finished.
;-------------------------------------------
vgc_update
        lda   vgc_finished
        bne   @exit        
        lda   vgc_source_page
        bne   @a
        rts                            ; no music to play
@a      _SetCartPageA
        ; SN76489 data register format is %1cctdddd where cc=channel, t=0=tone, t=1=volume, dddd=data
        ; The data is run length encoded.
        ; Get Channel 3 tone first because that contains the EOF marker        
        ; Update Tone3
vgc_do_update
        lda   #3
        jsr   vgc_update_register1  ; on exit C set if data changed, B is last value
        bcc   @more_updates
        ;
        ldb   skip_tone3+1
        cmpb  #$08     ; EOF marker? (0x08 is an invalid tone 3 value)
        beq   @finished
        ; 
@more_updates
        lda   #7
        jsr   vgc_update_register1  ; Volume3
        lda   #0
        jsr   vgc_update_register2  ; Tone0
        lda   #4
        jsr   vgc_update_register1  ; Volume0
        lda   #1
        jsr   vgc_update_register2  ; Tone1
        lda   #5
        jsr   vgc_update_register1  ; Volume1
        lda   #2
        jsr   vgc_update_register2  ; Tone2
        lda   #6
        jsr   vgc_update_register1  ; Volume2
@exit
        rts
        ;
@finished
        ; end of tune reached
        ldx   vgc_callback             ; check callback routine
        beq   >
        jmp   ,x
!       lda   vgc_loop
        beq   @no_looping
        ; restart if looping
        ldx   vgc_source
        lda   vgc_loop
        asla ; -> C
        lda   vgc_buffers
        jsr   vgc_stream_mount
        jmp   vgc_update
@no_looping 
        ; no looping so set flag $ stop PSG
        stb   vgc_finished    ; any NZ value is fine, in this case 0x08
        jmp   sn_reset ; also returns non-zero in A

;-------------------------------------------
; Sound chip routines
;-------------------------------------------

; Reset SN76489 sound chip to a default (silent) state
sn_reset
        lda   #$9F
        sta   SN76489.D
        lda   #$BF
        sta   SN76489.D       
        lda   #$DF
        sta   SN76489.D
        lda   #$FF
        sta   SN76489.D  
	rts

;-------------------------------------------
; VGC internal routines
; Not user callable.
;-------------------------------------------

;-------------------------------------------
; local vgc workspace
;-------------------------------------------

VGC_STREAM_CONTEXT_SIZE equ 8 ; number of bytes total workspace for a stream
VGC_STREAMS equ 8

vgc_streams ; decoder contexts - 8 bytes per stream, 8 streams (64 bytes)
        fill 0,VGC_STREAMS*VGC_STREAM_CONTEXT_SIZE
        ; 0 zp_stream_src     ; stream data ptr HI/LO
        ; 2 vgc_literal_cnt    ; literal count HI/LO
        ; 4 vgc_match_cnt      ; match count HI/LO
        ; 6 lz_window_src     ; window read ptr - index LO
        ; 7 lz_window_dst     ; window write ptr - index LO

vgc_buffers     fcb 0    ; the HI byte of the address where the buffers are stored
vgc_finished    fcb 0    ; a flag to indicate player has reached the end of the vgc stream
vgc_loop        fcb 0    ; non zero if tune is to be looped
vgc_source      fdb 0    ; vgc data address
vgc_source_page fdb 0    ; vgc data address
vgc_callback    fdb 0    ; 0=no calback routine

; 8 counters for VGC register update counters (RLE)
vgc_register_counts
        fill 0,8

; Table of SN76489 flags for the 8 LATCH/DATA registers
; %1cctdddd 
vgc_register_headers
        fcb $80+%00000000   ; Tone 0
        fcb $80+%00100000   ; Tone 1
        fcb $80+%01000000   ; Tone 2
        fcb $80+%01100000   ; Tone 3
        fcb $90+%00000000   ; Volume 0
        fcb $90+%00100000   ; Volume 1
        fcb $90+%01000000   ; Volume 2
        fcb $90+%01100000   ; Volume 3

; VGC file parsing - Initialise the system for the provided in-memory VGC data stream.
; On entry X point to address of the vgc data
vgc_stream_mount
        ; parse data stream
        ; VGC broadly uses LZ4 frame $ block formats for convenience
        ; however there are assumptions for format:
        ;  Magic number[4], Flags[1], MaxBlockSize[1], Header checksum[1]
        ;  Contains 8 blocks
        ; Obviously since this is an 8-bit CPU no files or blocks can be > 64Kb in size        
        ; VGC streams have a different magic number to LZ4
        ; [56 47 43 XX]
        ; where XX:
        ; bit 6 - LZ 8 bit (0) or 16 bit (1)
        ; bit 7 - Huffman (1) or no huffman (0)
        ; -- 6809 version -- only support : 8 bit / no huffman
        leau  7,x ; Skip frame header, and move to first block
        ; init first block position
        ldx   #0
        ldy   #vgc_register_counts
        ; clear vgc finished flag
        clr   vgc_finished
@block_loop
        ; get start address of encoded data for vgc_stream[x] (block ptr+4)
        leau  4,u  ; skip block header
        stu   vgc_streams+VGC_STREAMS*0,x  ; zp_stream_src
        ldd   #0
        std   vgc_streams+VGC_STREAMS*2,x  ; literal cnt 
        std   vgc_streams+VGC_STREAMS*4,x  ; match cnt 
        std   vgc_streams+VGC_STREAMS*6,x  ; window src dst ptr 
        ; setup RLE tables
        inca
        sta   ,y+
        ;
        ldb   -4,u                     ; read 16-bit block size
        lda   -3,u                     ; read 16-bit block size
        leau  d,u                      ; move to next block
        ;
        ; for all 8 blocks
        leax  2,x
        cmpx  #16
        bne   @block_loop
        rts

;----------------------------------------------------------------------
; fetch register data byte from register stream selected in A
; This byte will be LZ4 encoded
;  A is register id (0-7)
;  clobbers X,U
vgc_get_register_data
        ; set the LZ4 decoder stream workspace buffer (initialised by vgc_stream_mount)
        ldx   #0
        leax  a,x
        leax  a,x
        adda  vgc_buffers ; hi byte of the base address of the 2Kb (8x256) vgc stream buffers
        ; store hi byte of where the 256 byte vgc stream buffer for this stream is located
        sta   lz_window_src ; **SELFMOD** HI
        sta   lz_window_dst ; **SELFMOD** HI
        ; calculate the stream buffer context
        stx   @loadX ; Stash X for later *** SELF MODIFYING SEE BELOW ***
        ;
        ; since we have 8 separately compressed register streams
        ; we have to load the required decoder context to ZP
        ldu   vgc_streams+VGC_STREAMS*0,x
        ldd   vgc_streams+VGC_STREAMS*2,x
        std   vgc_literal_cnt
        ldd   vgc_streams+VGC_STREAMS*4,x
        std   vgc_match_cnt
        ldd   vgc_streams+VGC_STREAMS*6,x
        sta   lz_window_src+1   ; **SELF MODIFY** LO
        stb   lz_window_dst+1   ; **SELF MODIFY** LO
        ; then fetch a decompressed byte
        jsr   lz_decode_byte
        stb   @loadB ; Stash B for later - ** SMOD ** [4](2) faster than pha/pla 
        ; then we save the decoder context from ZP back to main ram
        ldx   #0  ; *** SELF MODIFIED - See above ***
@loadX  equ *-2
        stu   vgc_streams+VGC_STREAMS*0,x
        ldd   vgc_literal_cnt
        std   vgc_streams+VGC_STREAMS*2,x
        ldd   vgc_match_cnt
        std   vgc_streams+VGC_STREAMS*4,x
        lda   lz_window_src+1 ; LO
        ldb   lz_window_dst+1 ; LO
        std   vgc_streams+VGC_STREAMS*6,x
        ldb   #0 ;[2](2) - ***SELF MODIFIED - See above ***
@loadB  equ *-1
        rts

; Fetch 1 register data byte from the encoded stream and send to sound chip (volumes $ tone3)
; A is register to update
; on exit:
;    C is set if an update happened and B contains last register value
;    C is clear if no updated happened and B is preserved

vgc_update_register1
        ldx   #vgc_register_counts
        andcc #$fe ; clear cc
        dec   a,x ; no effect on C
        bne   skip_register_update

        ; decode a byte $ send to psg
        sta   @LoadA
        jsr   vgc_get_register_data
        stb   @LoadB
        andb  #$0f
        ldx   #vgc_register_headers
        lda   #0
@LoadA  equ   *-1
        orb   a,x
        ; check if it's a tone3 skip command ($ef) before we play it
        ; - this prevents the LFSR being reset unnecessarily
        cmpb  #$ef
        beq   skip_tone3
        stb   <SN76489.D
skip_tone3
        ; get run length (top 4-bits+1)
        ldb   #0
@LoadB  equ *-1
        lsrb
        lsrb
        lsrb
        lsrb
        incb
        ldx   #vgc_register_counts
        stb   a,x
        orcc  #1 ; set cc
skip_register_update
        rts

; Fetch 2 register bytes (LATCH+DATA) from the encoded stream and send to sound chip (tone0, tone1, tone2)
; Same parameters as vgc_update_register1
vgc_update_register2
        sta   @LoadA                  ; saves stream id
        jsr   vgc_update_register1    ; returns stream in X if updated, and C=0 if no update needed
        bcc   skip_register_update
        ;
        ; decode 2nd byte and send to psg as (DATA)
        lda   #0                      ; load stream id
@LoadA  equ   *-1
        jsr   vgc_get_register_data 
	stb   <SN76489.D
        rts

;-------------------------------
; lz4 decoder
;-------------------------------

; push byte into decode buffer
; clobbers Y, preserves A
lz_store_buffer    ; called twice - 4 byte overhead, 6 byte function. Cheaper to inline.
        stb   $1234   ; *** SELF MODIFIED ***
        inc   lz_store_buffer+2
        rts                 ; [6] (1)

; provide these vars as cleaner addresses for the code address to be self modified
lz_window_src equ lz_fetch_buffer+1 ; window read ptr HI (2 bytes) - index, 3 references
lz_window_dst equ lz_store_buffer+1 ; window write ptr HI (2 bytes) - index, 3 references

; Calculate a multi-byte lz4 style length into zp_temp
; On entry A contains the initial counter value (LO)
; Returns 16-bit length in X
lz_fetch_count
        lda   #0
        tfr   d,x
        cmpb  #15                      ; >=15 signals byte extend
        bne   lz_fetch_count_done
fetch
fetchByte1
        ldb   ,u+
        abx
        cmpb  #255                     ; 255 signals byte extend       
        beq   fetch
lz_fetch_count_done
        rts

; decode a byte from the currently selected register stream
; unlike typical lz style unpackers we are using a state machine
; because it is necessary for us to be able to decode a byte at a time from 8 separate streams
lz_decode_byte
    ; decoder state is:
    ;  empty - fetch new token $ prepare
    ;  literal - decode new literal
    ;  match - decode new match

    ; lz4 block format:
    ;  [TOKEN][LITERAL LENGTH][LITERALS][...][MATCH OFFSET][MATCH LENGTH]

; try fetching a literal byte from the stream
try_literal
        lda   vgc_literal_cnt+1
        bne   is_literal
        lda   vgc_literal_cnt
        beq   try_match

is_literal
fetchByte2
        ; fetch a literal $ stash in decode buffer
        ; plain LZ4 byte fetch
        ldb   ,u+
        jsr   lz_store_buffer
        stb   stashB+1                 ; **SELF MODIFICATION**

        ; using inverted counter
        inc vgc_literal_cnt+1
        bne >
        inc vgc_literal_cnt
!       bne end_literal

begin_matches
        ; literals run completed
        ; now fetch match offset $ length

fetchByte3
        ; get match offset LO
        ; plain LZ4 byte fetch
        ldb   ,u+

        ; set buffer read ptr
        stb   stashS+1 ; **SELF MODIFICATION**
        lda   lz_window_dst+1 ; *** SELF MODIFYING CODE ***
        ;orcc  #1
stashS
        suba  #0 ; **SELFMODIFIED**
        ;inca
        sta   lz_window_src+1 ; *** SELF MODIFYING CODE ***

        ; fetch match length
        ldb   vgc_match_cnt+1
        jsr   lz_fetch_count
        ; match length is always+4 (0=4)
        ; cant do this before because we need to detect 15
        leax  4,x
        stx   vgc_match_cnt

end_literal
stashB
        ldb   #0 ;**SELFMODIFIED - See above**
        rts

; try fetching a matched byte from the stream
try_match
        lda   vgc_match_cnt
        bne   is_match
        lda   vgc_match_cnt+1
        ; all matches done, so get a new token.
        beq   try_token

is_match
; fetch a byte from the current decode buffer at the current read ptr offset
; returns byte in B
lz_fetch_buffer
        ldb   $1234 ; *** SELF MODIFIED ***
        inc   lz_fetch_buffer+2
        jsr   lz_store_buffer    ; stash in decode buffer

        ; for all matches
        ; we know match cnt is at least 1
        lda   vgc_match_cnt+1
        bne   skiphi
        dec   vgc_match_cnt
skiphi
        dec   vgc_match_cnt+1

end_match
        rts

; then token parser
try_token
fetchByte5
        ; fetch a token
        ; plain LZ4 byte fetch 
        ldb   ,u+

        ; unpack match length from token (bottom 4 bits)
        lda   #0
        andb  #$0f
        std   vgc_match_cnt

        ; unpack literal length from token (top 4 bits)
        ldb   -1,u
        lsrb
        lsrb
        lsrb
        lsrb

        ; fetch literal extended length, passing in B
        jsr   lz_fetch_count
        stx   vgc_literal_cnt
        
        ; if no literals, begin the match sequence
        ; and fetch one match byte
        ; literal count can be 2 bytes, check both for zero
        bne   has_literals

        jsr   begin_matches
        jmp   try_match

has_literals
        ; negate the literals counter so we can increment it rather than decrement it
        ldd   vgc_literal_cnt
        nega
        negb
        sbca  #0
        std   vgc_literal_cnt

        ; ok now go back to literal parser so we can return a byte
        ; if no literals, logic will fall through to matches
        jmp   try_literal
