;******************************************************************
; 6502 BBC Micro Compressed VGM (VGC) Music Player
; By Simon Morris
; https://github.com/simondotm/vgm-player-bbc
; https://github.com/simondotm/vgm-packer
;******************************************************************

;  vars without huffman
VGM_VARS fill 0,4

; registers used for each compressed stream (they are context switched)
lz_vars equ VGM_VARS+0
vgc_literal_cnt  equ lz_vars+0
vgc_match_cnt    equ lz_vars+2

VGM_MUSIC_BPM equ 125
VGM_BEATS_PER_PATTERN equ 8

VGM_FRAMES_PER_BEAT equ (50*60)/VGM_MUSIC_BPM
VGM_FRAMES_PER_PATTERN equ VGM_FRAMES_PER_BEAT*VGM_BEATS_PER_PATTERN