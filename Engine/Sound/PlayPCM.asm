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

        ldd   #$fb3f  ! Mute by CRA to   ;
        anda  $e7cf   ! avoid sound when ; clear bit2 on CRB
        sta   $e7cf   ! $e7cd written    ; Data Direction Register selected
        stb   $e7cd   ! Full sound line  ; set DAC bits to output (%00111111)
        ora   #$04    ! Disable mute by  ; set bit2 on CRB
        sta   $e7cf   ! CRA and sound    ; Output Register selected
        
PlayPCM_ReadChunk
        lda   sound_page,y                    ; load memory page
        beq   PlayPCM_End
        _SetCartPageA                
        ldx   sound_start_addr,y              ; Chunk start addr
       
PlayPCM_Loop      
        lda   ,x+
        sta   $e7cd                         ; send byte to DAC
        cmpx  sound_end_addr,y
        beq   PlayPCM_NextChunk        
        mul                                 ; tempo for 16hHz
        mul
        mul
        tfr   a,b
        bra   PlayPCM_Loop                  ; loop is 63 cycles instead of 62,5
         
PlayPCM_NextChunk
        leay  sound_meta_size,y
        mul                                 ; tempo for 16kHz
        nop
        bra   PlayPCM_ReadChunk
        
PlayPCM_End
        lda   #$00
        sta   $e7cd
                
        ldd   #$fbfc  ! Mute by CRA to
        anda  $e7cf   ! avoid sound when ; clear bit2 on CRB
        sta   $e7cf   ! $e7cd is written ; Data Direction Register selected
        andb  $e7cd   ! Activate         ; clear bit 0 and bit1
        stb   $e7cd   ! joystick port    ; ???
        ora   #$04    ! Disable mute by  ; set bit2 on CRB
        sta   $e7cf   ! CRA + joystick   ; Output Register selected

PlayPCM_RestorePage        
        lda   #$00
        _SetCartPageA
        
        rts   
