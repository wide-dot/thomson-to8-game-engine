* Generated Code

* structure: rom src page, rom src end addr. hb, rom src end addr. lb, ram dest page, ram dest end addr. hb, ram dest end addr. lb
        fdb   RL_RAM_index+31
gm_scrollscreen
        fcb   $00,$04,$17,$47,$E0,$00
        fcb   $00,$04,$13,$78,$B9,$C2
        fcb   $00,$05,$0E,$DE,$E0,$00
        fcb   $00,$05,$0A,$FB,$B8,$43
        fcb   $00,$01,$06,$BB,$AC,$34
        fcb   $FF
Gm_Index
        fdb   gm_scrollscreen