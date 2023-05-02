* Generated Code

* structure: sector, nb sector, drive (bit 7) track (bit 6-0), end offset, ram dest page, ram dest end addr. hb, ram dest end addr. lb
        fdb   RL_RAM_index+36
gm_scrollscreen
        fcb   $03,$04,$00,$A6,$04,$E0,$00
        fcb   $07,$05,$00,$4F,$04,$BA,$28
        fcb   $0C,$04,$00,$32,$05,$E0,$00
        fcb   $10,$04,$00,$72,$05,$B8,$43
        fcb   $04,$04,$01,$93,$01,$AC,$32
        fcb   $FF
Gm_Index
        fdb   gm_scrollscreen