* Generated Code

* structure: rom src page, rom src end addr. hb, rom src end addr. lb, ram dest page, ram dest end addr. hb, ram dest end addr. lb
        fdb   RL_RAM_index+13
gm_game
        fcb   $01,$04,$2F,$E6,$D7,$01
        fcb   $01,$01,$2A,$3A,$B9,$81
        fcb   $FF
Gm_Index
        fdb   gm_game