* Generated Code

* structure: sector, nb sector, drive (bit 7) track (bit 6-0), end offset, ram dest page, ram dest end addr. hb, ram dest end addr. lb
        fdb   RL_RAM_index+36
gm_game
        fcb   $03,$13,$00,$A8,$04,$E0,$00
        fcb   $06,$18,$01,$B4,$04,$BC,$35
        fcb   $0E,$0C,$02,$AC,$05,$E0,$00
        fcb   $0A,$12,$03,$73,$05,$B7,$70
        fcb   $0C,$08,$04,$93,$01,$B9,$81
        fcb   $FF
Gm_Index
        fdb   gm_game