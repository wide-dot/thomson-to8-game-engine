    INCLUDE "./engine/InitGlobals.asm"
    INCLUDE "./engine/ram/BankSwitch.asm"
    INCLUDE "./engine/palette/PalUpdateNow.asm"
    INCLUDE "./engine/palette/color/Pal_black.asm"
    INCLUDE "./engine/ram/ClearDataMemory.asm"
; Required by the GENERATED LoadAct, which blits act.default.backgroundImage
; (the nebula) into both video pages -- see generated-code/starfield/
; BuilderMainGenCode.asm. Nothing in this project calls it directly. LoadAct
; runs inside _gameMode.init, i.e. before _IRQ.init, which is what this routine
; needs: it drives S as a roving write pointer and an IRQ firing mid-copy would
; push its return address into the pixels ahead of S.
    INCLUDE "./engine/graphics/draw/DrawFullscreenImage.asm"
; NOT WaitVBL: this mode double-buffers with gfxlock (included from the game
; mode's main.asm). The two are mutually exclusive — they declare the same
; globals — and WaitVBL's $E7E7 beam poll stalls once the music IRQ is live.

; Text: kept in the resident main engine ($6xxx) so the banked objects can call
; it. Each font variant hard-codes its palette index in its compiled glyphs:
;   fnt_4x6_shd     -> colour 3 (title)
;   fnt_4x6_shd_dis -> colour 1 (by FX, faded)
; NOTE: DrawText and the fonts are NOT here. A font is ~96 compiled glyphs
; (~5.7Kb); two of them blew the main engine past its 16Kb limit. Each text
; object carries its own DrawText + font in its own banked 16Kb page instead
; (same as sms-player's text object).

; Music players (SN76489 via vgc, YM2413 via YVGM). Kept resident; ticked once
; per frame from UserIRQ (see game-mode/00/main.asm), i.e. at a steady 50Hz.
    INCLUDE "./engine/sound/vgc/lib/vgcplayer.h.asm"
    INCLUDE "./engine/sound/vgc/lib/vgcplayer.asm"
    INCLUDE "./engine/sound/YM2413vgm.asm"

; vgm decode buffers (8 x 256 = 2Kb). fill, not rmb: this is a raw binary.
        ALIGN 256
vgc_stream_buffers
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
        fill 0,256
    INCLUDE "./engine/object-management/RunObjects.asm"
    INCLUDE "./engine/level-management/LoadGameMode.asm"
    INCLUDE "./engine/math/RandomNumber.asm"
    INCLUDE "./engine/irq/Irq.asm"
