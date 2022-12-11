;******************************************************************
; 6502 BBC Micro Compressed VGM (VGC) Music Player
; By Simon Morris
; https://github.com/simondotm/vgm-player-bbc
; https://github.com/simondotm/vgm-packer
;
; 6809 version
; By Benoit Rousseau
;******************************************************************

PSG equ $E7FF

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
; vgc_init
;-------------------------------------------
; Initialise playback routine
;  A points to HI byte of a page aligned 2Kb RAM buffer address
;  X point to the VGC data stream to be played
;  C=1 for looped playback
;-------------------------------------------
vgc_play
        sta   vgc_buffers              ; stash the 2kb buffer address
        lda   #0
        rora                           ; move carry into A
        sta   vgc_loop
        lda   ,x                       ; get memory page that contains track data
        sta   vgc_source_page
        ldx   1,x                      ; get ptr to track data
        stx   vgc_source               ; stash the data source addr for looping
        jmp   vgc_stream_mount         ; Prepare the data for streaming (passed in X)

;-------------------------------------------
; vgc_update
;-------------------------------------------
;  call every 50Hz to play music
;  vgc_init must be called prior to this
; On entry A is non-zero if the music should be looped
;  returns non-zero when VGC is finished.
;-------------------------------------------
vgc_update
        lda vgc_finished
        bne exit        
        ; SN76489 data register format is %1cctdddd where cc=channel, t=0=tone, t=1=volume, dddd=data
        ; The data is run length encoded.
        ; Get Channel 3 tone first because that contains the EOF marker        
        ; Update Tone3
        lda   #3
        jsr   vgc_update_register1  ; on exit C set if data changed, Y is last value
        bcc   @more_updates
        ;
        cmpa  #$08     ; EOF marker? (0x08 is an invalid tone 3 value)
        beq   @finished
        ; 
@more_updates
        lda   #7
        jsr   vgc_update_register1  ; Volume3
        lda   #1
        jsr   vgc_update_register2  ; Tone1
        lda   #2
        jsr   vgc_update_register2  ; Tone2
        lda   #4
        jsr   vgc_update_register1  ; Volume0
        lda   #5
        jsr   vgc_update_register1  ; Volume1
        lda   #6
        jsr   vgc_update_register1  ; Volume2
        ; do tone0 last so we can use B output as the Zero return flag
        lda   #0
        jsr   vgc_update_register2  ; Tone0, returns 0 in X
        tstb ; return Z=0=still playing
@exit
        rts
        ;
@finished
        ; end of tune reached
        lda   vgc_loop
        beq   @no_looping
        ; restart if looping
        ldx   vgc_source
        lda   vgc_loop
        asla ; -> C
        lda   vgc_buffers
        jsr   vgc_init ; TODO rechargement par les données dejà enregistrées (pas l'id sound)
        jmp   vgc_update
@no_looping 
        ; no looping so set flag $ stop PSG
        sta   vgc_finished    ; any NZ value is fine, in this case 0x08
        jmp   sn_reset ; also returns non-zero in A

;-------------------------------------------
; Sound chip routines
;-------------------------------------------

; Reset SN76489 sound chip to a default (silent) state
sn_reset
        lda   #$9F
        sta   PSG
        lda   #$BF
        sta   PSG       
        lda   #$DF
        sta   PSG
        lda   #$FF
        sta   PSG  
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
        ; 2 zp_literal_cnt    ; literal count HI/LO
        ; 4 zp_match_cnt      ; match count HI/LO
        ; 6 lz_window_src     ; window read ptr - index LO
        ; 7 lz_window_dst     ; window write ptr - index LO

vgc_buffers     fcb 0    ; the HI byte of the address where the buffers are stored
vgc_finished    fcb 0    ; a flag to indicate player has reached the end of the vgc stream
vgc_temp        fcb 0    ; used by vgc_update_register1()
vgc_loop        fcb 0    ; non zero if tune is to be looped
vgc_source      fdb 0    ; vgc data address
vgc_source_page fdb 0    ; vgc data address

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
        leax  7,x ; Skip frame header, and move to first block
        leau  ,x  ; init first block position
no_block_hi
        ; read the block headers (size)
        ldx   #0
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
        sta   vgc_register_counts,x

        ldd   ,u                       ; read 16-bit block size
        addd  #4                       ; +4 to compensate for block header
        leau  d,u                      ; move to next block

        ; for all 8 blocks
        leax  1,x
        cpmx  #8
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
        std   zp_literal_cnt
        ldd   vgc_streams+VGC_STREAMS*4,x
        std   zp_match_cnt
        ldd   vgc_streams+VGC_STREAMS*6,x
        sta   lz_window_src+1   ; **SELF MODIFY** LO
        stb   lz_window_dst+1   ; **SELF MODIFY** LO
        ; then fetch a decompressed byte
        jsr   lz_decode_byte
        sta   @loadA ; Stash A for later - ** SMOD ** [4](2) faster than pha/pla 
        ; then we save the decoder context from ZP back to main ram
        ldx   #0  ; *** SELF MODIFIED - See above ***
@loadX equ *-2
        stu   vgc_streams+VGC_STREAMS*0,x
        ldd   zp_literal_cnt
        std   vgc_streams+VGC_STREAMS*2,x
        ldd   zp_match_cnt
        std   vgc_streams+VGC_STREAMS*4,x
        lda   lz_window_src+1 ; LO
        ldb   lz_window_dst+1 ; LO
        std   vgc_streams+VGC_STREAMS*6,x
        lda   #0 ;[2](2) - ***SELF MODIFIED - See above ***
@loadA equ *-1
        rts

; Fetch 1 register data byte from the encoded stream and send to sound chip (volumes $ tone3)
; A is register to update
; on exit:
;    C is set if an update happened and Y contains last register value
;    C is clear if no updated happened and Y is preserved
;    X contains register provided in A on entry (0-7)

vgc_update_register1
        ldx   #vgc_register_counts
        dec   a,x ; no effect on C
        bne   skip_register_update

        ; decode a byte $ send to psg
        sta   vgc_temp
        jsr   vgc_get_register_data
        sta   @LoadA
        anda  #$0f
        ldx   #0
        ldb   vgc_temp
        leax  b,x
        ora   vgc_register_headers,x
        ; check if it's a tone3 skip command ($ef) before we play it
        ; - this prevents the LFSR being reset unnecessarily
        cmpa  #$ef
        beq   skip_tone3
        sta   <PSG
skip_tone3
        ; get run length (top 4-bits+1)
        lda   #0
@LoadA equ *-1
        lsra
        lsra
        lsra
        lsra
        inca
        sta   vgc_register_counts,x
        orcc  #1
skip_register_update
        rts

; Fetch 2 register bytes (LATCH+DATA) from the encoded stream and send to sound chip (tone0, tone1, tone2)
; Same parameters as vgc_update_register1
vgc_update_register2
        jsr   vgc_update_register1    ; returns stream in X if updated, and C=0 if no update needed
        bcc   skip_register_update

        ; decode 2nd byte and send to psg as (DATA)
        tfr   b,a
        jsr   vgc_get_register_data 
	sta   <PSG
        rts

;-------------------------------
; lz4 decoder
;-------------------------------

; fetch a byte from the current decode buffer at the current read ptr offset
; returns byte in A, clobbers Y
lz_fetch_buffer
        ldb   $ffff ; *** SELF MODIFIED ***
        inc   lz_fetch_buffer+2
        rts

; push byte into decode buffer
; clobbers Y, preserves A
lz_store_buffer    ; called twice - 4 byte overhead, 6 byte function. Cheaper to inline.
        stb   $ffff   ; *** SELF MODIFIED ***
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
        cmpb  #15                      ; >=15 signals byte extend
        bne   lz_fetch_count_done
        tfr   d,x
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
        lda   zp_literal_cnt+1
        bne   is_literal
        lda   zp_literal_cnt
        beq   try_match

is_literal
fetchByte2
        ; fetch a literal $ stash in decode buffer
        ; plain LZ4 byte fetch
        ldb   ,u+
        jsr   lz_store_buffer
        stb   stashB+1                 ; **SELF MODIFICATION**

        ; using inverted counter
        inc zp_literal_cnt+1
        bne >
        inc zp_literal_cnt
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
        ldb   lz_window_dst+1 ; *** SELF MODIFYING CODE ***
        orcc  #1
stashS
        sbcb  #0 ; **SELFMODIFIED**
        sta   lz_window_src+1 ; *** SELF MODIFYING CODE ***

        ; fetch match length
        ldb   zp_match_cnt+1
        jsr   lz_fetch_count
        ; match length is always+4 (0=4)
        ; cant do this before because we need to detect 15
        leax  4,x
        stx   zp_match_cnt

end_literal
stashB
        ldb   #0 ;**SELFMODIFIED - See above**
        rts

; try fetching a matched byte from the stream
try_match
        lda   zp_match_cnt
        bne   is_match
        lda   zp_match_cnt+1
        ; all matches done, so get a new token.
        beq   try_token

is_match
        jsr   lz_fetch_buffer    ; fetch matched byte from decode buffer
        jsr   lz_store_buffer    ; stash in decode buffer

        ; for all matches
        ; we know match cnt is at least 1
        lda   zp_match_cnt+1
        bne   skiphi
        dec   zp_match_cnt
skiphi
        dec   zp_match_cnt+1

end_match
        rts

; then token parser
try_token
fetchByte5
        ; fetch a token
        ; plain LZ4 byte fetch
        ldb   ,u+

        ; unpack match length from token (bottom 4 bits)
        andb  #$0f
        stb   zp_match_cnt+1
        clr   zp_match_cnt

        ; unpack literal length from token (top 4 bits)
        ldb   -1,u
        lsrb
        lsrb
        lsrb
        lsrb

        ; fetch literal extended length, passing in B
        jsr   lz_fetch_count
        stx   zp_literal_cnt
        
        ; if no literals, begin the match sequence
        ; and fetch one match byte
        ; literal count can be 2 bytes, check both for zero
        bne   has_literals

        jsr   begin_matches
        jmp   try_match

has_literals
        ; negate the literals counter so we can increment it rather than decrement it
        ldd   zp_literal_cnt
        nega
        negb
        sbca  #0
        std   zp_literal_cnt

        ; ok now go back to literal parser so we can return a byte
        ; if no literals, logic will fall through to matches
        jmp   try_literal