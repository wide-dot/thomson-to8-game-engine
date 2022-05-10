; ---------------------------------------------------------------------------
; Object - Smps Sound player
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Sound/SmpsObj.asm"

Song_Index
        fdb   Song_EHZ

Song_EHZ
        INCLUDEBIN "./Objects/Smps/music/songs/2-01 Emerald Hill Zone.smp"
        ;INCLUDEBIN "./Objects/Smps/music/songs/2-1B Hidden Palace Zone.smp"

Sound_Index
        fdb   0