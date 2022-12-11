;******************************************************************
; 6502 BBC Micro Compressed VGM (VGC) Music Player
; By Simon Morris
; https://github.com/simondotm/vgm-player-bbc
; https://github.com/simondotm/vgm-packer
;******************************************************************


;-------------------------------
; workspace/zeropage vars
;-------------------------------

; Declare where VGM player should locate its zero page vars
; VGM player uses:
;  6 zero page vars without huffman
VGM_ZP fill 0,4 ; must be in zero page 

; declare zero page registers used for each compressed stream (they are context switched)
lz_zp equ VGM_ZP+0
zp_literal_cnt  equ lz_zp+0    ; literal count, 7 references
zp_match_cnt    equ lz_zp+2    ; match count, 10 references

VGM_MUSIC_BPM equ 125
VGM_BEATS_PER_PATTERN equ 8

VGM_FRAMES_PER_BEAT equ (50*60)/VGM_MUSIC_BPM
VGM_FRAMES_PER_PATTERN equ VGM_FRAMES_PER_BEAT*VGM_BEATS_PER_PATTERN