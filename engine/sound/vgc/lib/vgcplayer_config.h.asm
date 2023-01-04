;******************************************************************
; 6502 BBC Micro Compressed VGM (VGC) Music Player
; By Simon Morris
; https://github.com/simondotm/vgm-player-bbc
; https://github.com/simondotm/vgm-packer
;******************************************************************

;-------------------------------
; config options
;-------------------------------

; VGM player supports VGC files that are plain LZ4 or Huffman LZ4 if ENABLE_HUFFMAN is TRUE
; Huffman decoding is variable speed and requires more Zero page, so...
; For optimal performance & memory usage you can disable huffman support.
; (just make sure you compile your VGC files without huffman of course) 
ENABLE_HUFFMAN equ FALSE

; Enable this to capture the SN chip register settings (for fx etc.)
ENABLE_VGM_FX equ FALSE
