; ---------------------------------------------------------------------------
; Object - Title : draws "WIDE-DOT STARFIELD" in colour 3 (yellow).
;
; input REG : [u] pointer to Object Status Table (OST)
;
; Position lives in the OST (x_pos/y_pos), so this can be moved later just by
; writing those fields. x is in pixels but the font advances one byte = 4 px,
; so x is rounded down to a multiple of 4 by the x>>2 byte-column maths.
;
; Redrawn every frame on purpose: the mode double-buffers and the starfield
; erases its own pixels everywhere, so a once-drawn text would flicker and get
; holes punched in it by passing stars.
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Object
        nop                        ; DO NOT MODIFY / DO NOT ADD A LINE BEFORE:
                                   ; rewritten into an rts when the object is done
        pshs  u                    ; RunObjects does "ldu run_object_next,u" after
                                   ; the dispatch: U must come back intact
        lda   routine,u
        asla
        ldx   #Routines
        jsr   [a,x]
        puls  u,pc

Routines
        fdb   Init
        fdb   Live

Init
        lda   #1
        sta   routine,u            ; next frame -> Live
        rts

Live
        lda   y_pos+1,u            ; A = y (0..199)
        ldb   #40
        mul                        ; D = y*40
        tfr   d,x
        leax  $C000,x              ; RAM A plane: glyphs reach RAM B via -$2000
        ldb   x_pos+1,u            ; B = x (0..159)
        lsrb
        lsrb                       ; B = x>>2 = byte column (4 px per glyph)
        abx
        tfr   x,d
        std   DrawText_pos
        ldx   #fnt_4x6_shd         ; colour 3 = yellow
        ldy   #txt_title
        jsr   DrawText

; --- the scenario's caption, if any ----------------------------------------
; This object draws it rather than an object of its own, because fnt_4x6_shd
; hard-codes palette index 3 -- the title's colour, already lit by the time any
; caption shows. A separate caption object would have to carry its own copy of
; DrawText and the ~5.7Kb font in its own banked page (a font does not fit twice
; in one 16Kb page), to render the same glyphs in the same colour.
;
; The caption's position is fixed, so it is not read from the OST: band_msg in
; global/band.asm repaints exactly these rows and the two must agree.
        ldd   sc_msg
        beq   @nomsg
        tfr   d,y                  ; Y = caption text (DrawText reads it here)
; Centre it. One glyph advances exactly one byte column (4 px), so the first
; column is (40 - length) / 2. Measured from the string rather than stored per
; caption: a new caption is then centred by writing it and nothing else, and
; there is no second place to forget to update.
        tfr   d,x
        clrb
@len    tst   ,x+
        beq   @gotlen
        incb
        bra   @len
@gotlen
        negb
        addb  #40                  ; B = 40 - length, in byte columns
        lsrb                       ; B = first byte column
        clra
        addd  #$C000+MSG_ROW*40
        std   DrawText_pos
        ldx   #fnt_4x6_shd
        jsr   DrawText
@nomsg
        rts

* KEEP IN SYNC with the band_msg descriptor (global/band.asm), which repaints
* the nebula under this line: it covers rows 140..146, byte columns 2..37. A
* CENTRED caption of length L occupies columns (40-L)/2 .. (40+L)/2-1, so the
* band covers every caption up to 36 glyphs — which is exactly the longest one.
MSG_ROW equ 140

txt_title
        fcc   "WIDE-DOT STARFIELD"
        fcb   0

; DrawText + the font live in THIS object's own banked 16Kb page: a font is ~96
; compiled glyphs (~5.7Kb) and two of them do not fit in the main engine's 16Kb.
        INCLUDE "./engine/graphics/font/DrawText/DrawText.asm"
        INCLUDE "./engine/graphics/font/DrawText/3x5_shaded/asm/font_upper.asm"
