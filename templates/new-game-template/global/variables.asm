 IFNDEF GLOBAL_VARIABLES

GLOBAL_VARIABLES         equ $9E28
globals.nextGameMode     equ GLOBAL_VARIABLES+0 ; 1 byte
globals.score            equ GLOBAL_VARIABLES+1 ; 2 bytes
globals.lives            equ GLOBAL_VARIABLES+3 ; 1 bytes
globals.backgroundSolid  equ GLOBAL_VARIABLES+4 ; 1 byte
globals.difficulty       equ GLOBAL_VARIABLES+5 ; 1 byte
globals.lifeUpIdx        equ GLOBAL_VARIABLES+6 ; 1 byte (extra-life thresholds crossed so far)
globals.bossDefeated     equ GLOBAL_VARIABLES+7 ; 1 byte (0 if boss not defeated, !=0 if boss defeated)

 ENDC
