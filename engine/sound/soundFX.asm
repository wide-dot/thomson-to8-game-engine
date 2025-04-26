; <YM2413 Sound FX Driver
; 6809 @ 1MHz, <YM2413 @ 3.57954MHz
; 50Hz IRQ-driven playback
; ----------------------------------------

                jmp     soundFX.playIRQ

soundFX.NO_SOUND      equ     $FF00    ; No sound

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
soundFX.soundStat    fcb     0          ; Sound status (0=idle, 1=playing)
soundFX.soundPtr     fdb     0          ; Current sound data pointer
soundFX.cmdCount     fcb     0          ; Command count
soundFX.delayCnt     fcb     0          ; Delay counter (in IRQ ticks)
soundFX.currChan     fcb     0          ; Current channel number
soundFX.currSound    fcb     0          ; Current sound ID being played

soundFX.play
            lda     soundFX.soundStat  ; Check if already playing
            beq     @NotPlaying
            ;
            ; Sound is already playing, send note off to current channel
            lda     soundFX.currChan   ; Get current channel
            adda    #YM_FREQ_MSB_BASE ; Add channel base address
            sta     <YM2413.A   ; Set address (4 cycles)
            nop                 ; (2 cycles)
            clra                ; Clear sustain, key-on, freq msb bits (2 cycles)
            sta     <YM2413.D   ; Write data (4 cycles)
            ;
@NotPlaying
            ; Validate sound ID
            ldb     soundFX.newSound
            stb     soundFX.currSound
            ;
            ; Get sound data address
            aslb                ; Multiply by 2 for word offset
            ldx     #soundFX.soundTable ; Point to sound table
            abx                 ; Add offset (128 values, otherwise 64 if you use b,x for reading)
            ldx     ,x          ; Get sound data address
            ;
            ; Get command count and channel from sound data
            ldd     ,x++        ; Get command count
            sta     soundFX.cmdCount
            beq     @Exit       ; If no command count, keep soundStat = 0
            stb     soundFX.currChan   ; Store channel number
            ;
            ; Initialize playback
            stx     soundFX.soundPtr   ; Save pointer
            ldd     #1
            sta     soundFX.delayCnt
            stb     soundFX.soundStat  ; Set playing flag
            ;
@Exit
            rts

; Sound effect IRQ handler
; Call every 1/50 second (20ms)
; Preserves all registers
; Takes max 100 cycles (100µs @ 1MHz)
soundFX.playIRQ
            pshs    d,x,y,u     ; Save registers
            ;
            ; Check for new sound to play
            ldd     soundFX.newSound
            cmpd    #soundFX.NO_SOUND
            beq     @playCurSound
            andb    #$7f
            stb     @newPri
            ;
            lda     soundFX.curSound+1
            anda    #$7f
            cmpa    #0
@newPri     equ     *-1
            blo     @playNewSound
            bhi     @playCurSound
            ; if same sound priority and current sound is locked, skip playing the new sound
            lda     soundFX.curSound+1
            bita    #$80
            bne     @playCurSound
@playNewSound
            ; Play the new sound
            jsr     soundFX.play ; Play the sound
            ldd     soundFX.newSound
            std     soundFX.curSound ; Update current sound
            ldd     #soundFX.NO_SOUND
            std     soundFX.newSound ; Reset new sound ID
            ;
@playCurSound
            lda     soundFX.soundStat ; Check if playing
            beq     @Exit
            lda     soundFX.delayCnt ; Check delay counter
            beq     @Process
            deca
            sta     soundFX.delayCnt
@Exit       puls    d,x,y,u,pc
            ;
@Process
            ldx     soundFX.soundPtr
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
            ldb     soundFX.currChan   ; Get channel number
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
            adda    soundFX.currChan   ; Apply channel number
!           sta     <YM2413.A   ; Set address (4 cycles)
            lda     1,x         ; Get data (5 cycles)
            sta     <YM2413.D   ; Write data (4 cycles)
            ;
@EndCommand
            ; Update command pointer
            leax    3,x         ; Point to next command
            dec     soundFX.cmdCount
            beq     @StopSound  ; If zero, stop
            ;
            ; Check if delay is 0, and if so, process the next command
            lda     -1,x        ; Get delay of last command
            beq     @ProcessLoop
            deca                ; Decrement counter
            sta     soundFX.delayCnt
            stx     soundFX.soundPtr
            puls    d,x,y,u,pc
            ;
@StopSound
            ; Clear key-on
            lda     soundFX.currChan   ; Get current channel
            adda    #YM_FREQ_MSB_BASE ; Add channel base address
            sta     <YM2413.A   ; Set address (4 cycles)
            nop                 ; (2 cycles)
            clra                ; (2 cycles)
            sta     <YM2413.D   ; Clear sustain, key-on, freq msb bits (2 cycles)
            ;            
            sta     soundFX.soundStat  ; Clear playing flag
            ldd     #soundFX.NO_SOUND
            std     soundFX.curSound ; Update current sound
            ;
            puls    d,x,y,u,pc

; After including the soundFX.data.asm file, user should define soundFX.soundTable

; Sound data lookup table
; ------------------------
;soundFX.soundTable
;            fdb     soundFX.FireSound
;            fdb     soundFX.ExplosionSound
;            fdb     soundFX.BonusSound
;            fdb     soundFX.PodAttachSound

; soundFX.FireSound
; ...

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