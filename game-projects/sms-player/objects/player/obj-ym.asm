
SoundTest
        ldb   snd_tst_new_song
        cmpb  snd_tst_cur_song
        beq   @rts
        stb   snd_tst_cur_song
        ldy   #MusicList
        aslb
        ldx   b,y
        ldb   #1 ; 0=no loop 1=loop
        ldy   #0 ; pas de callback
        jsr   YVGM_PlayMusic 
@rts    rts

MusicList
        fdb   Snd_YM01
        fdb   Snd_YM02
        fdb   Snd_YM03
        fdb   Snd_YM04
        fdb   Snd_YM05
        fdb   Snd_YM06
        fdb   Snd_YM07
        fdb   Snd_YM08
        fdb   Snd_YM09
        fdb   Snd_YM10
        fdb   Snd_YM11
        fdb   Snd_YM12
        fdb   Snd_YM13
        fdb   Snd_YM14
        fdb   Snd_YM15
        fdb   Snd_YM16
        fdb   Snd_YM17
        fdb   Snd_YM18