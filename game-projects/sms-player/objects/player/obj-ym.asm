
SoundTest
        pshs  u
        ldb   snd_tst_new_song
        cmpb  snd_tst_cur_song
        beq   @rts
        jsr   IrqUnpause
        stb   snd_tst_cur_song
        ldx   #MusicList
        aslb
        abx
        ldx   ,x
        ldb   #3 ; play intro x1 and theme x2
        ldy   #CallbackRoutine
        jsr   YVGM_PlayMusic 
@rts    puls  u,pc

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
        fdb   Snd_YM19
        fdb   Snd_YM20
        fdb   Snd_YM21
        fdb   Snd_YM22
        fdb   Snd_YM23
        fdb   Snd_YM24
        fdb   Snd_YM25
        fdb   Snd_YM26
        fdb   Snd_YM27
        fdb   Snd_YM28
        fdb   Snd_YM29
        fdb   Snd_YM30
        fdb   Snd_YM31
        fdb   Snd_YM32

