; ------ music-init.asm ------
; From: r-type game engine
; Example: How to load and play background music
;
; Usage:
;   1. Define music data in config (Java generator embeds it)
;   2. Call sound:init-sound at game start
;   3. Call sound:play-music to start playback
;   4. Sound subsystem plays music each frame
;
; Dependencies: sound subsystem

; Initialize sound subsystem and load game music
init-music:
    lda #1               ; Music volume (1-7, 1=quiet, 7=loud)
    jsr sound:set-volume

    ldd #music-data      ; Load address of music data (from config)
    jsr sound:load-music ; Load music into sound buffer

    jsr sound:play-music ; Start playback
    rts

; Trigger a sound effect (e.g., player fires)
play-sfx:
    lda #sfx-laser       ; Sound effect ID (defined in config)
    jsr sound:play-sfx   ; Play sound immediately
    rts

; Stop music
stop-music:
    jsr sound:stop-music
    rts

; See full context: game-projects/r-type/sound module
