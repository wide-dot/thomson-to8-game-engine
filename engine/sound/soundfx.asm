; <YM2413 Sound FX Driver
; 6809 @ 1MHz, <YM2413 @ 3.57954MHz
; 50Hz IRQ-driven playback
; ----------------------------------------

                jmp     SoundFxIRQ

; Sound IDs
SOUND_COUNT     equ     2       ; Total number of sounds
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
@EndCommand
            ; Update command pointer
            leax    3,x         ; Point to next command
            dec     cmd_count
            beq     @StopSound  ; If zero, stop
            ;
            ; Check if delay is 0, and if so, process the next command
            lda     -1,x        ; Get delay of last command
            beq     @ProcessLoop
            deca                ; Decrement counter
            sta     delay_cnt
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
            fdb     ExplosionSound

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
        fcb     25          ; Number of commands
        fcb     5           ; Channel number (5)

        ; Custom instrument settings
        ;fcb     $FF         ; special command
        ;fdb     FireInst    ; Custom instrument data address (0 if not needed)
            
        fcb     $30,$F2,0
        fcb     $20,$19,0
        fcb     $10,$01,1

        fcb     $20,$17,0
        fcb     $10,$81,1

        fcb     $20,$17,0
        fcb     $10,$20,1

        fcb     $20,$15,0
        fcb     $10,$E5,1

        fcb     $20,$1D,0
        fcb     $10,$01,1

        fcb     $20,$1B,0
        fcb     $10,$B0,1

        fcb     $20,$1B,0
        fcb     $10,$57,1

        fcb     $20,$1B,0
        fcb     $10,$43,1

        fcb     $20,$1B,0
        fcb     $10,$01,1

        fcb     $20,$19,0
        fcb     $10,$20,1

        fcb     $20,$17,0
        fcb     $10,$E5,1

        fcb     $20,$15,0
        fcb     $10,$20

ExplosionSound
    ; Header
    fcb    39                    ; Nombre de commandes augmenté
    fcb    3                     ; Channel number (5)

        fcb     $30,$24,0
        fcb     $20,$19,0
        fcb     $10,$10,1

        fcb     $20,$19,0
        fcb     $10,$6B,1

        fcb     $20,$19,0
        fcb     $10,$CA,1

        fcb     $20,$1F,0
        fcb     $10,$6B,1

        fcb     $20,$1F,0
        fcb     $10,$FC,1

        fcb     $20,$1D,0
        fcb     $10,$6B,1

        fcb     $20,$1D,0
        fcb     $10,$01,1

        fcb     $20,$1B,0
        fcb     $10,$57,1

        fcb     $20,$1D,0
        fcb     $10,$10,1

        fcb     $20,$1F,0
        fcb     $10,$31,1

        fcb     $20,$1F,0
        fcb     $10,$98,1

        fcb     $20,$1F,0
        fcb     $10,$CA,1

        fcb     $20,$1F,0
        fcb     $10,$31,1

        fcb     $20,$1D,0
        fcb     $10,$6B,1

        fcb     $20,$1D,0
        fcb     $10,$10,1

        fcb     $20,$1B,0
        fcb     $10,$98,1

        fcb     $20,$1D,0
        fcb     $10,$31,1

        fcb     $20,$1F,0
        fcb     $10,$01,1

        fcb     $20,$1F,0
        fcb     $10,$CA

; Custom instrument definitions
FireInst
            fcb     $2D,$13,$02,$15,$A2,$F4,$00,$F5

; YM2413 instruments settings
; 1 | 71 61 1E 17 D0 78 00 17 | Violin
; 2 | 13 41 1A 0D D8 F7 23 13 | Guitar
; 3 | 13 01 99 00 F2 C4 11 23 | Piano
; 4 | 31 61 0E 07 A8 64 70 27 | Flute
; 5 | 32 21 1E 06 E0 76 00 28 | Clarinet
; 6 | 31 22 16 05 E0 71 00 18 | Oboe
; 7 | 21 61 1D 07 82 81 10 07 | Trumpet
; 8 | 23 21 2D 14 A2 72 00 07 | Organ
; 9 | 61 61 1B 06 64 65 10 17 | Horn
; A | 41 61 0B 18 85 F7 71 07 | Synthesizer
; B | 13 01 83 11 FA E4 10 04 | Harpsichord
; C | 17 C1 24 07 F8 F8 22 12 | Vibraphone (same)
; D | 61 50 0C 05 C2 F5 20 42 | Synthesizer Bass
; E | 01 01 55 03 C9 95 03 02 | Acoustic Bass
; F | 61 41 89 03 F1 E4 40 13 | Electric Guitar