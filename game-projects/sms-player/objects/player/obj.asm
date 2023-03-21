
SoundTest
        ldb   snd_tst_new_song
        cmpb  snd_tst_cur_song
        beq   @rts
        jsr   IrqUnpause
        stb   snd_tst_cur_song
        ldy   #MusicList
        aslb
        ldx   b,y
        ldb   #1 ; 0=no loop 1=loop
        ldy   #0 ; pas de callback
        jsr   vgc_init
@rts    rts

MusicList
        fdb   Snd_01
        fdb   Snd_02
        fdb   Snd_03
        fdb   Snd_04
        fdb   Snd_05
        fdb   Snd_06
        fdb   Snd_07
        fdb   Snd_08
        fdb   Snd_09
        fdb   Snd_10
        fdb   Snd_11
        fdb   Snd_12
        fdb   Snd_13
        fdb   Snd_14
        fdb   Snd_15
        fdb   Snd_16
        fdb   Snd_17
        fdb   Snd_18
        fdb   Snd_19
        fdb   Snd_20
        fdb   Snd_21
        fdb   Snd_22
        fdb   Snd_23
        fdb   Snd_24
        fdb   Snd_25
        fdb   Snd_26
        fdb   Snd_27
        fdb   Snd_28
        fdb   Snd_29
        fdb   Snd_30
        fdb   Snd_31
        fdb   Snd_32
        fdb   Snd_33
        fdb   Snd_34
        fdb   Snd_35
        fdb   Snd_36
        fdb   Snd_37
        fdb   Snd_38
        fdb   Snd_39
        fdb   Snd_40
        fdb   Snd_41
        fdb   Snd_42
        fdb   Snd_43
        fdb   Snd_44
        fdb   Snd_45
        fdb   Snd_46
        fdb   Snd_47
        fdb   Snd_48
        fdb   Snd_49
        fdb   Snd_50
        fdb   Snd_51
        fdb   Snd_52
        fdb   Snd_53
        fdb   Snd_54
        fdb   Snd_55
        fdb   Snd_56
        fdb   Snd_57
        fdb   Snd_58
        fdb   Snd_59
        fdb   Snd_60