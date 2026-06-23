 IFNDEF GLOBAL_VARIABLES

GLOBAL_VARIABLES         equ $9E80   ; first free byte after resident code ($9EBC)
globals.nextGameMode     equ GLOBAL_VARIABLES+0 ; 1 byte
globals.score            equ GLOBAL_VARIABLES+1 ; 2 bytes
globals.lives            equ GLOBAL_VARIABLES+3 ; 1 bytes
globals.backgroundSolid  equ GLOBAL_VARIABLES+4 ; 1 byte
globals.difficulty       equ GLOBAL_VARIABLES+5 ; 1 byte
globals.lifeUpIdx        equ GLOBAL_VARIABLES+6 ; 1 byte (extra-life thresholds crossed so far)
globals.bossDefeated     equ GLOBAL_VARIABLES+7 ; 1 byte (0 if boss not defeated, !=0 if boss defeated)
globals.stageScoreBase   equ GLOBAL_VARIABLES+8 ; 2 bytes (score at stage start; stageScore = score - base)
; --- arme missile joueur : STATUT D'ARME persistant (doit survivre au changement de stage) ---
globals.missileUnlocked  equ GLOBAL_VARIABLES+10 ; 1 byte (1 = missile débloqué par le bonus)
; NB : missilePairCount / missileTgtTop / missileTgtBot = état TRANSITOIRE in-stage
;      -> déclarés dans game-mode/<n>/ram_data.asm (fcb/fdb), PAS ici.

 ENDC
