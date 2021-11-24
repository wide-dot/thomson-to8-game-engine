* ---------------------------------------------------------------------------
* PlayDPCM16kHz
* -------------
* Subroutine to play a Delta PCM sample at 16kHz
* 8 bit sample value is encoded as a 4bit lookup value in a delta table
* then it is downsampled to 6bits and send to the DAC
* 62,5 cycles between 2 DAC samples (alternation of 62 and 63 cycles)
*
* This will freeze anything running ;-)
* DAC Init from Mission: Liftoff (merci Prehisto ;-))
*
* input REG : [y] Pcm_ index to play
* reset REG : none
*
* Pcm_ index point to a data structure that store location of sample data:
* page[b], start address[w], end address[w]
* page[b], start address[w], end address[w]
* ...
* $00
*
* ---------------------------------------------------------------------------

PlayDPCM16kHz 
        pshs  d,x,y,u
        _GetCartPageA
        sta   @RestorePage+1
        ldd   #$fb3f  ! Mute by CRA to 
        anda  $e7cf   ! avoid sound when 
        sta   $e7cf   ! $e7cd written
        stb   $e7cd   ! Full sound line
        ora   #$04    ! Disable mute by
        sta   $e7cf   ! CRA and sound
	ldu   #@DACDecodeTbl
	lda   #$80                     ; init delta value
	sta   @smplh+1
	sta   @smpll+1
@ReadChunk
        lda   sound_page,y             ; [4] load memory page
        beq   @End                     ; [3]
        _SetCartPageA                  ; for each page switch there is a lag, data in RAM: 7 cycles late, data in ROM: 77 cycles late in stream
        ldx   sound_start_addr,y       ; [6] Chunk start addr
@Loop      
        lda   ,x                       ; [4] load data byte
        lsra                           ; [2]
        lsra                           ; [2]
        lsra                           ; [2]
        lsra                           ; [2]
        ldb   a,u                      ; [5] read high nibble sample
@smplh  addb  #00                      ; [2]
        stb   @smpll+1                 ; [5]
	lsrb                           ; [2]
	lsrb                           ; [2]
	stb   $e7cd                    ; [5] send byte to DAC
        lda   ,x+                      ; [6] reload data byte
        anda  #$0F                     ; [2]
        ldb   a,u                      ; [5] read low nibble sample
@smpll  addb  #00                      ; [2]
        stb   @smplh+1                 ; [5]
        exg   a,b                      ; [34] wait
        exg   a,b                      ; ...				       
        exg   a,b                      ; ...				       
        exg   a,b                      ; ...				       
        nop                            ; ...
	lsrb                           ; [2]
	lsrb                           ; [2]					
	stb   $e7cd                    ; [5] send byte to DAC
        cmpx  sound_end_addr,y         ; [7]
        beq   @NextChunk               ; [3]
        exg   a,b                      ; [16] wait	
        exg   a,b                      ; ...
        bra   @Loop                    ; [3]
@NextChunk
        leay  sound_meta_size,y        ; [5]
        bra   @ReadChunk               ; [3]
@End
        lda   #$00
        sta   $e7cd
        ldd   #$fbfc  ! Mute by CRA to
        anda  $e7cf   ! avoid sound when
        sta   $e7cf   ! $e7cd is written
        andb  $e7cd   ! Activate
        stb   $e7cd   ! joystick port
        ora   #$04    ! Disable mute by
        sta   $e7cf   ! CRA + joystick
@RestorePage        
        lda   #$00
        _SetCartPageA
        puls  d,x,y,u,pc
@DACDecodeTbl
        fcb   0,4,8,16,32,48,64,96,-128,-4,-8,-16,-32,-48,-64,-96	