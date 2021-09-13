* ---------------------------------------------------------------------------
* PlayPCM
* ------------
* Subroutine to play a PCM sample at 16kHz
* This will freeze anything running
* DAC Init from Mission: Liftoff (merci Prehisto ;-))
*
* input REG : [y] Pcm_ index to play
* reset REG : [d] [x] [y]
* ---------------------------------------------------------------------------

PlayPCM 

        _GetCartPageA
        sta   PlayPCM_RestorePage+1

        ldd   #$fb3f  ! Mute by CRA to 
        anda  $e7cf   ! avoid sound when 
        sta   $e7cf   ! $e7cd written
        stb   $e7cd   ! Full sound line
        ora   #$04    ! Disable mute by
        sta   $e7cf   ! CRA and sound
        
PlayPCM_ReadChunk
        lda   pcm_page,y                    ; load memory page
        beq   PlayPCM_End
        _SetCartPageA                
        ldx   pcm_start_addr,y              ; Chunk start addr
       
PlayPCM_Loop      
        lda   ,x+
        sta   $e7cd                         ; send byte to DAC
        cmpx  pcm_end_addr,y
        beq   PlayPCM_NextChunk        
        mul                                 ; tempo for 16hHz
        mul
        mul
        tfr   a,b
        bra   PlayPCM_Loop                  ; loop is 63 cycles instead of 62,5
         
PlayPCM_NextChunk
        leay  pcm_meta_size,y
        mul                                 ; tempo for 16kHz
        nop
        bra   PlayPCM_ReadChunk
        
PlayPCM_End
        lda   #$00
        sta   $e7cd
                
        ldd   #$fbfc  ! Mute by CRA to
        anda  $e7cf   ! avoid sound when
        sta   $e7cf   ! $e7cd is written
        andb  $e7cd   ! Activate
        stb   $e7cd   ! joystick port
        ora   #$04    ! Disable mute by
        sta   $e7cf   ! CRA + joystick

PlayPCM_RestorePage        
        lda   #$00
        _SetCartPageA
        
        rts   
