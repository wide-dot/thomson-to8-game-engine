
SoundTest
        lda   Current_Selection
        cmpa  #24
        bne   @rts
        lda   Ctrl_1_Press
        ldb   Sound_test_sound
        bita  #button_left_mask
        beq   >
        decb
        bpl   >
        ldb   #26
!       bita  #button_right_mask
        beq   >
        incb
        cmpb  #27
        blo   >
        andb  #0
!       stb   Sound_test_sound
        bita  #button_A_mask|button_B_mask
        beq   @rts
        ldy   #MusicList
        aslb
        ldx   b,y
        jmp   PlayMusic
@rts    rts

MusicList
        fdb   Smps_209
        fdb   Smps_100
        fdb   Smps_200
        fdb   Smps_201
        fdb   Smps_202
        fdb   Smps_203
        fdb   Smps_204
        fdb   Smps_205
        fdb   Smps_206
        fdb   Smps_207
        fdb   Smps_208
        fdb   Smps_20A
        fdb   Smps_20B
        fdb   Smps_20C
        fdb   Smps_20D
        fdb   Smps_20E
        fdb   Smps_20F
        fdb   Smps_210
        fdb   Smps_211
        fdb   Smps_212
        fdb   Smps_213
        fdb   Smps_214
        fdb   Smps_216
        fdb   Smps_217
        fdb   Smps_219
        fdb   Smps_21B
        fdb   Smps_21C