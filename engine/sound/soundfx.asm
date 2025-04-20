; <YM2413 Sound FX Driver
; 6809 @ 1MHz, <YM2413 @ 3.57954MHz
; 50Hz IRQ-driven playback
; ----------------------------------------

                jmp     SoundFxIRQ

; Sound IDs
SOUND_COUNT     equ     1       ; Total number of sounds
SOUND_NONE      equ     $FF     ; No sound to play

; <YM2413 register base addresses
YM_FREQ_LSB_BASE equ     $10     ; Base address for frequency LSB registers
YM_FREQ_MSB_BASE equ     $20     ; Base address for frequency MSB, note on/off registers
YM_INST_BASE     equ     $30     ; Base address for instrument/volume registers

; Sound command structure
CMD_REG       equ     0           ; Register offset
CMD_DATA      equ     1           ; Data offset
CMD_DELAY     equ     2           ; Delay offset
CMD_SIZE      equ     3           ; Size of each command

; Sound variables
sound_stat    fcb     0          ; Sound status (0=idle, 1=playing)
sound_ptr     fdb     0          ; Current sound data pointer
cmd_count     fcb     0          ; Command count
delay_cnt     fcb     0          ; Delay counter (in IRQ ticks)
curr_chan     fcb     0          ; Current channel number
curr_sound    fcb     0          ; Current sound ID being played

PlaySoundFx
            lda     sound_stat  ; Check if already playing
            beq     @NotPlaying
            ;
            ; Sound is already playing, send note off to current channel
            lda     curr_chan   ; Get current channel
            adda    #YM_FREQ_MSB_BASE ; Add channel base address
            sta     <YM2413.A   ; Set address (4 cycles)
            nop                 ; (2 cycles)
            clra                ; Clear sustain, key-on, freq msb bits (2 cycles)
            sta     <YM2413.D   ; Write data (4 cycles)
            ;
@NotPlaying
            ; Validate sound ID
            ldb     soundFxDriver.newSound
            cmpb    #SOUND_COUNT
            bhs     @Exit       ; Invalid ID, exit
            stb     curr_sound
            ;
            ; Get sound data address
            aslb                ; Multiply by 2 for word offset
            ldx     #SoundTable ; Point to sound table
            abx                 ; Add offset (128 values, otherwise 64 if you use b,x for reading)
            ldx     ,x          ; Get sound data address
            ;
            ; Get command count and channel from sound data
            ldd     ,x++        ; Get command count
            sta     cmd_count
            beq     @Exit       ; If no command count, keep sound_stat = 0
            stb     curr_chan   ; Store channel number
            ;
            ; Initialize playback
            stx     sound_ptr   ; Save pointer
            ldd     #1
            sta     delay_cnt
            stb     sound_stat  ; Set playing flag
            ;
@Exit
            rts

; Sound effect IRQ handler
; Call every 1/50 second (20ms)
; Preserves all registers
; Takes max 100 cycles (100µs @ 1MHz)
SoundFxIRQ
            pshs    d,x,y,u     ; Save registers
            ;
            ; Check for new sound to play
            lda     soundFxDriver.newSound   ; Get new sound ID
            cmpa    #SOUND_NONE ; Is there a new sound?
            beq     @CheckPlaying ; No, check if already playing
            ;
            ; Play the new sound
            jsr     PlaySoundFx ; Play the sound
            lda     #SOUND_NONE ; Reset new sound ID
            sta     soundFxDriver.newSound   ; to indicate no new sound
            ;
@CheckPlaying
            lda     sound_stat  ; Check if playing
            beq     @Exit
            lda     delay_cnt   ; Check delay counter
            beq     @Process
            deca                ; Decrement counter
            sta     delay_cnt
@Exit       puls    d,x,y,u,pc
            ;
@Process
            ldx     sound_ptr
            ;
@ProcessLoop   
            ; Process command
            lda     ,x          ; Get register
            cmpa    #$FF
            bne     @NotCustom
            ;
            ; Load custom instrument data
            ldu     1,x         ; Get instrument data address
            ldb     #7          ; Write registers backwards
            ;
@InstLoop
            stb     <YM2413.A   ; Set address (4 cycles)
            lda     b,u         ; Get data (5 cycles)
            sta     <YM2413.D   ; Write data (4 cycles)
            exg     a,b         ; (wait of 8 cycles)                                      
            exg     a,b         ; (wait of 8 cycles)  
            decb                ; Prev register (2 cycles)
            bpl     @InstLoop   ; Done ? if not, continue
            ;
            ; Select custom instrument
            ldb     curr_chan   ; Get channel number
            addb    #YM_INST_BASE ; Add instrument base address
            stb     <YM2413.A   ; Set instrument command for channel number
            nop
            clra
            sta     <YM2413.D   ; Set instrument with volume level at 0
            ;
            ; Update delay counter
            lda     #0          ; implicit delay counter value 0
            bra     @EndCommand
            ;
@NotCustom
            cmpa    #$0F
            bls     >
            adda    curr_chan   ; Apply channel number
!           sta     <YM2413.A   ; Set address (4 cycles)
            lda     1,x         ; Get data (5 cycles)
            sta     <YM2413.D   ; Write data (4 cycles)
            ;
            ; Update delay counter
            lda     2,x         ; Get delay
            ;
@EndCommand
            ; Update command pointer
            leax    3,x         ; Point to next command
            dec     cmd_count
            beq     @StopSound  ; If zero, stop
            ;
            ; Check if delay is 0, and if so, process the next command
            sta     delay_cnt
            beq     @ProcessLoop
            stx     sound_ptr
            puls    d,x,y,u,pc
            ;
@StopSound
            ; Clear key-on
            lda     curr_chan   ; Get current channel
            adda    #YM_FREQ_MSB_BASE ; Add channel base address
            sta     <YM2413.A   ; Set address (4 cycles)
            nop                 ; (2 cycles)
            clra                ; (2 cycles)
            sta     <YM2413.D   ; Clear sustain, key-on, freq msb bits (2 cycles)
            ;            
            sta     sound_stat  ; Clear playing flag
            ;
            puls    d,x,y,u,pc

; Sound data lookup table
SoundTable
            fdb     FireSound

; Sound data format:
; ------------------
;
; header
; ------
; Byte 0: Length of data (in commands)
; Byte 1: Channel number (0-8)
;
; commands (3 bytes each)
; -----------------------
; Byte 0: Register
; Byte 1: Data
; Byte 2: Delay (in 50Hz ticks)
;
; special command
; ---------------
; Byte 0: $FF, Bytes 1-2: Custom instrument data address

FireSound
            ; header
            fcb     11          ; Number of commands
            fcb     5           ; Channel number (5)

            ; Custom instrument settings
            fcb     $FF         ; special command
            fdb     FireInst    ; Custom instrument data address (0 if not needed)
            
            ; Initial pitch (F-Number = 407, Block = 4)
            fcb     $10,$97,0   ; F-Number LSB
            fcb     $20,$09,0   ; Block 4 + F-Number MSB
            
            ; Attack phase
            fcb     $30,$A0,0   ; Custom instrument, Full volume
            fcb     $20,$39,1   ; Key-on
            
            ; Pitch bend
            fcb     $10,$57,1   ; F-Number 343
            fcb     $10,$27,1   ; F-Number 295
            fcb     $10,$07,1   ; F-Number 263
            
            ; Volume decay
            fcb     $30,$A4,1   ; Custom instrument, Volume 12
            fcb     $30,$A8,1   ; Custom instrument, Volume 8
            fcb     $30,$AC,1   ; Custom instrument, Volume 4

; Instrument IDs
; 0 = Custom instrument (followed by 2 bytes with instrument data address)
; 1-15 = Standard <YM2413 instruments:
; 1 = Violin (smooth string sound)
; 2 = Guitar (sharp attack, plucked string)
; 3 = Piano (soft bell-like piano)
; 4 = Flute (gentle airy tone)
; 5 = Clarinet (reed-like, woody tone)
; 6 = Oboe (nasal wind instrument)
; 7 = Trumpet (bright, brassy tone)
; 8 = Organ (hollow sustained tone)
; 9 = Horn (mellow brass sound)
; 10 = Synthesizer (classic synthy feel)
; 11 = Harpsichord (metallic pluck)
; 12 = Vibraphone (soft metallic bell)
; 13 = Synth Bass (deep bassy synth)
; 14 = Wood Bass (acoustic upright bass)
; 15 = Electric Guitar (muted string pluck)

; Custom instrument definitions
FireInst
            ; Modulator
            fcb     $41
            fcb     $64
            fcb     $0B
            fcb     $18
            ; Carrier
            fcb     $85
            fcb     $F7
            fcb     $71
            fcb     $07
