\ ******************************************************************
\\ VGM Player
\\ Code module
\ ******************************************************************

VGM_ENABLE_AUDIO = TRUE				; enables output to sound chip (disable for silent testing/demo loop)
VGM_HAS_HEADER = FALSE				; set this to TRUE if the VGM bin file contains a metadata header (only useful for sound tracker type demos where you want to have the song info)  
VGM_FX = FALSE						; set this to TRUE to parse the music into vu-meter type buffers for effect purposes

.vgm_player_start


\ ******************************************************************
\ *	Define global constants
\ ******************************************************************



\ ******************************************************************
\ *	Declare FX variables
\ ******************************************************************

IF VGM_FX
VGM_FX_num_freqs = 32				; number of VU bars - can be 16 or 32
VGM_FX_num_channels = 4				; number of beat bars (one per channel)

\\ Frequency array for vu-meter effect, plus beat bars for 4 channels
\\ These two must be contiguous in memory
.vgm_freq_array				SKIP VGM_FX_num_freqs
.vgm_chan_array				SKIP VGM_FX_num_channels
.vgm_player_reg_vals		SKIP 8		; data values passed to each channel during audio playback (4x channels x pitch + volume)

\\ Copied out of the RAW VGM header
.vgm_player_packet_count	SKIP 2		; number of packets
.vgm_player_duration_mins	SKIP 1		; song duration (mins)
.vgm_player_duration_secs	SKIP 1		; song duration (secs)

.vgm_player_packet_offset	SKIP 1		; offset from start of file to beginning of packet data

.vgm_player_last_reg		SKIP 1		; last channel (register) refered to by the VGM sound data
.vgm_player_reg_bits		SKIP 1		; bits 0 - 7 set if SN register 0 - 7 updated this frame, cleared at start of player poll

ENDIF ; VGM_FX

\\ Player vars
.vgm_player_ended			SKIP 1		; non-zero when player has reached end of tune
.vgm_player_data			SKIP 1		; temporary variable when decoding sound data - must be separate as player running on events
.vgm_player_counter			SKIP 2		; increments by 1 every poll (20ms) - used as our tracker line no. & to sync fx with audio update

.vgm_player_counter_tmp     SKIP 1


\ ******************************************************************
\ *	VGM music player data area
\ ******************************************************************
IF VGM_HAS_HEADER
\\ Player
VGM_PLAYER_string_max = 42			; size of our meta data strings (title and author)
VGM_PLAYER_sample_rate = 50			; locked to 50Hz


.vgm_player_song_title_len	SKIP 1
.vgm_player_song_title		SKIP VGM_PLAYER_string_max
.vgm_player_song_author_len	SKIP 1
.vgm_player_song_author		SKIP VGM_PLAYER_string_max

.tmp_msg_idx SKIP 1

ENDIF


.tmp_var SKIP 1




.num_to_bit				; look up bit N
EQUB &01, &02, &04, &08, &10, &20, &40, &80

\ ******************************************************************
\ *	VGM music player routines
\ * Plays a RAW format VGM music stream from an Exomiser compressed data stream
\ ******************************************************************

\\ Initialise the VGM player with an Exomizer compressed data stream
\\ X - lo byte of data stream to be played
\\ Y - hi byte of data stream to be played
.vgm_init_stream
{
	\\ Initialise exomizer - must have some data ready to decrunch
	JSR exo_init_decruncher

	\\ Initialise music player - parses header
	JSR	vgm_init_player

	RTS
}


.vgm_init_player				; return non-zero if error
{
IF VGM_HAS_HEADER
\\ <header section>
\\  [byte] - header size - indicates number of bytes in header section

	LDA #1
	STA vgm_player_packet_offset

	jsr exo_get_decrunched_byte
	STA tmp_var
	CMP #5
	BCS parse_header			; we need at least 5 bytes to parse!
	JMP error

	.parse_header
	CLC
	ADC vgm_player_packet_offset
	STA vgm_player_packet_offset

\\  [byte] - indicates the required playback rate in Hz eg. 50/60/100

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	CMP #VGM_PLAYER_sample_rate		; we only support 50Hz files
	BEQ is_50HZ					; return non-zero to indicate error
	JMP error
	.is_50HZ
	DEC tmp_var

\\  [byte] - packet count lsb

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	STA vgm_player_packet_count
	DEC tmp_var

\\  [byte] - packet count msb

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	STA vgm_player_packet_count+1
	DEC tmp_var

\\  [byte] - duration minutes

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	STA vgm_player_duration_mins
	DEC tmp_var

\\  [byte] - duration seconds

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	STA vgm_player_duration_secs

	.header_loop
	DEC tmp_var
	BEQ done_header

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	\\ don't know what this byte is so ignore it
	JMP header_loop

	.done_header

\\ <title section>
\\  [byte] - title string size

	INC vgm_player_packet_offset

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	STA tmp_var

	CLC
	ADC vgm_player_packet_offset
	STA vgm_player_packet_offset

\\  [dd] ... - ZT title string

	LDX #0
	.title_loop
	STX tmp_msg_idx
	LDA tmp_var
	BEQ done_title				; make sure we consume all the title string
	DEC tmp_var

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	LDX tmp_msg_idx
	CPX #VGM_PLAYER_string_max
	BCS title_loop				; don't write if buffer full
	STA vgm_player_song_title,X
	INX
	JMP title_loop

	\\ Where title string is smaller than our buffer
	.done_title
	STX vgm_player_song_title_len
	LDA #' '
	.title_pad_loop
	CPX #VGM_PLAYER_string_max
	BCS done_title_padding
	STA vgm_player_song_title,X
	INX
	JMP title_pad_loop
	.done_title_padding

\\ <author section>
\\  [byte] - author string size

	INC vgm_player_packet_offset

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	STA tmp_var

	CLC
	ADC vgm_player_packet_offset
	STA vgm_player_packet_offset

\\  [dd] ... - ZT author string

	LDX #0
	.author_loop
	STX tmp_msg_idx
	LDA tmp_var
	BEQ done_author				; make sure we consume all the author string
	DEC tmp_var

	jsr exo_get_decrunched_byte		; should really check carry status for EOF
	LDX tmp_msg_idx
	CPX #VGM_PLAYER_string_max
	BCS author_loop
	STA vgm_player_song_author,X	; don't write if buffer full
	INX
	JMP author_loop

	\\ Where author string is smaller than our buffer
	.done_author
	STX vgm_player_song_author_len
	LDA #' '
	.author_pad_loop
	CPX #VGM_PLAYER_string_max
	BCS done_author_padding
	STA vgm_player_song_author,X
	INX
	JMP author_pad_loop
	.done_author_padding
ENDIF ;VGM_HAS_HEADER

	\\ Initialise vars
	LDA #&FF
	STA vgm_player_counter
	STA vgm_player_counter+1

	LDA #0
	STA vgm_player_ended
IF VGM_FX
	STA vgm_player_last_reg
	STA vgm_player_reg_bits
ENDIF
	\\ Return zero 
	RTS

	\\ Return error
	.error
	LDA #&FF
	RTS
}

.vgm_deinit_player
{
	\\ Zero volume on all channels
	LDA #&9F: JSR psg_strobe
	LDA #&BF: JSR psg_strobe
	LDA #&DF: JSR psg_strobe
	LDA #&FF: JSR psg_strobe
	
	.return
	RTS
}

.vgm_poll_player
{
	\\ Assume this is called every 20ms..
IF VGM_FX
	LDA #0
	STA vgm_player_reg_bits
ENDIF

	LDA vgm_player_ended
	BNE _sample_end

\\ <packets section>
\\  [byte] - indicating number of data writes within the current packet (max 11)
\\  [dd] ... - data
\\  [byte] - number of data writes within the next packet
\\  [dd] ... - data
\\  ...`
\\ <eof section>
\\  [0xff] - eof

	\\ Get next byte from the stream
	jsr exo_get_decrunched_byte
	bcs _sample_end

	cmp #&ff
	beq _player_end

	\\ Byte is #data bytes to send to sound chip:
	TAY
	.sound_data_loop
	BEQ wait_20_ms
	TYA:PHA
	jsr exo_get_decrunched_byte
	bcc not_sample_end
	PLA
	JMP _sample_end

	.not_sample_end
IF VGM_FX
	JSR psg_decode
ENDIF
	JSR psg_strobe
	PLA:TAY:DEY
	JMP sound_data_loop
	
	.wait_20_ms
	INC vgm_player_counter				; indicate we have completed another frame of audio
	BNE no_carry
	INC vgm_player_counter+1
	.no_carry

	CLC
	RTS

	._player_end
	STA vgm_player_ended

	\\ Silence sound chip
	JSR vgm_deinit_player

	INC vgm_player_counter				; indicate we have completed one last frame of audio
	BNE _sample_end
	INC vgm_player_counter+1

	._sample_end
	SEC
	RTS
}

.psg_strobe
{

IF VGM_ENABLE_AUDIO

	ldy #255
	sty $fe43
	
	sta $fe4f
	lda #0
	sta $fe40
	nop
	nop
	nop
	nop
	nop
	nop
	lda #$08
	sta $fe40

ENDIF ; VGM_ENABLE_AUDIO

	rts
}

IF VGM_FX

.psg_decode
{
	STA vgm_player_data
	AND #&80	; bit 7 is a LATCH command if 1, DATA if 0
	BEQ second_byte

	\\ First byte

	\\ Obtain register fields
	
	\\ Get register from bits 7,6,5
	LDA vgm_player_data
	AND #&70 ; bits 6,5,4 are the register number
	LSR A:LSR A:LSR A:LSR A
	STA vgm_player_last_reg

	\\ Y is our register number
	TAY

	\\ Set bit field for each register used this frame
	LDA num_to_bit,Y				; look up bit for reg number
	ORA vgm_player_reg_bits				; mask in bit
	STA vgm_player_reg_bits

	\\ Is this tone or volume register?
	TYA
	AND #&01
	BEQ process_tone_data

	\\ Volume data
	LDA vgm_player_data
	AND #&0F ; volume is bottom 4 bits
	STA vgm_player_reg_vals,Y

	\\ Invert volume (0 = max 15 = off)
	SEC
	LDA #&0F ; max volume
	SBC vgm_player_reg_vals,Y
	STA vgm_player_reg_vals,Y
	JMP return

	\\ Frequency / tone data
	.process_tone_data
	CPY #&40 ; SN_REG_NOISE_CTRL				; Y already register number
	BNE tone_channel

	\\ Noise channel
	LDA vgm_player_data
	AND #&07 ;  (SN_NF_MASK OR SN_FB_MASK)		; store noise freq data
	STA vgm_player_reg_vals,Y

	JMP trigger_beat

	.tone_channel
	LDA vgm_player_data
	AND #&0f ; SN_FREQ_FIRST_BYTE_MASK		; F3 - F0
	LSR A: LSR A						; lose bottom 2 bits
	STA vgm_player_reg_vals,Y

	.trigger_beat
	\\ trigger the beat effect for this channel
	TYA:LSR A:TAY						; channel is register / 2
	LDA #9
	STA vgm_chan_array, Y

	JMP return

	.second_byte
	LDA vgm_player_data
	AND #&3F; SN_FREQ_SECOND_BYTE_MASK		; F9 - F4
	STA tmp_var
	ASL A: ASL A						; put 6 bits to top of byte
	LDY vgm_player_last_reg
	ORA vgm_player_reg_vals,Y				; combine with bottom 2 bits
	STA vgm_player_reg_vals,Y

	\\ trigger the beat effect for this channel
; technically correct, but better visuals without this.
;	TYA:LSR A:TAY						; channel is register / 2
;	LDA #9
;	STA vgm_chan_array, Y

	LDA tmp_var
IF VGM_FX_num_freqs == 16
	\\ 16 frequency bars, so use top 4 bits
	LSR A : LSR A
ELSE
	\\ 32 frequency bars, so use top 5 bits
	LSR A
ENDIF
	
	\\ clamp final frequency to array range and invert 
	AND #VGM_FX_num_freqs-1
	STA tmp_var
	LDA #VGM_FX_num_freqs-1
	SEC
	SBC tmp_var
	TAX
	LDA #15
	STA vgm_freq_array,X

	.return
	LDA vgm_player_data
	RTS
}

ENDIF ; VGM_FX

.vgm_player_end

