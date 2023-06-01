 IFNDEF GLOBAL_VARIABLES

GLOBAL_VARIABLES         equ $9E00
NEXT_GAME_MODE           equ GLOBAL_VARIABLES+0 ; 1 byte
score                    equ GLOBAL_VARIABLES+1 ; 2 bytes
lives                    equ GLOBAL_VARIABLES+3 ; 2 bytes
globals.backgroundSolid  equ GLOBAL_VARIABLES+5 ; 1 byte
globals.difficulty       equ GLOBAL_VARIABLES+6 ; 1 byte

 ENDC
