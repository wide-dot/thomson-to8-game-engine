* Generated Code

* structure: rom src page, rom src end addr. hb, rom src end addr. lb, ram dest page, ram dest end addr. hb, ram dest end addr. lb
        fdb   RL_RAM_index+31
gm_scrollscreen
        fcb   $00,$04,$1A,$F1,$E0,$00
        fcb   $00,$04,$17,$22,$B9,$C2
        fcb   $00,$05,$12,$88,$E0,$00
        fcb   $00,$05,$0E,$A5,$B8,$43
        fcb   $00,$01,$0A,$65,$BC,$36
        fcb   $FF
Gm_Index
        fdb   gm_scrollscreen