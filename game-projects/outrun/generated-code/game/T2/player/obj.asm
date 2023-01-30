	opt   c,ct
	INCLUDE "./generated-code/game/T2/main.glb"
	org   $16C8
	setdp $FF


SoundTest
        ;lda   Current_Selection
        ;cmpa  #24
        ;bne   @rts
        lda   Ctrl_1_Press
        ldb   Sound_test_sound
        bita  #button_left_mask
        beq   >
        decb
        bpl   >
        ldb   #3
!       bita  #button_right_mask
        beq   >
        incb
        cmpb  #4
        blo   >
        andb  #0
!       stb   Sound_test_sound
        bita  #button_A_mask|button_B_mask
        beq   @rts
        ldy   #MusicList
        aslb
        ldx   b,y
        ldd   #vgc_stream_buffers
        * andcc #$fe ; clear carry (no loop)
        orcc  #1 ; set carry (loop)
        jmp   vgc_init
@rts    rts

MusicList
        fdb   Snd_01
        fdb   Snd_02
        fdb   Snd_03
        fdb   Snd_04
