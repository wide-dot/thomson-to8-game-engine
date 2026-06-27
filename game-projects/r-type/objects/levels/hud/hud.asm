; *****************************************************************************
; Render HUD on screen
; --------------------
;
; - nb of globals.lives
; - beam indicator
; - globals.score
;
; *****************************************************************************

        INCLUDE "./objects/player1/player1.equ"

_beam_seg_extA MACRO                   ; outer lines of 8px
	std   $2001,u
	std   $2001+4*40,u
 ENDM

_beam_seg_extB MACRO                   ; outer lines of 8px
	std   ,u
	std   4*40,u
 ENDM

_beam_seg_midA MACRO                   ; middle lines of 8px
	std   $2001+1*40,u
	std   $2001+3*40,u
 ENDM

_beam_seg_midB MACRO                   ; middle lines of 8px
	std   1*40,u
	std   3*40,u
 ENDM

_beam_seg_intA MACRO                   ; inner line of 8px
	std   $2001+2*40,u
 ENDM

_beam_seg_intB MACRO                   ; inner line of 8px
	std   2*40,u
        leau  beam_m_size,u            ; move to next segment position
 ENDM

beam_m_start equ $BE3B                 ; beam render starting point
beam_m_size  equ 2                     ; number of byte for a segment

; ---------------------------------------------------------------------------
; HUD render entry point
; ---------------------------------------------------------------------------
; Draws the beam indicator (5 segments), then updates globals.lives (granting any
; extra life triggered by a globals.score threshold), then draws the current globals.score.
; Each segment of the beam is 8px; values in-between are rendered using
; Beam_mask to mask off the dark pixels of the last partial segment.
; ---------------------------------------------------------------------------

        ; ObjID_hud entry - dispatch on B (hud.NORMAL = bottom HUD, hud.READOUT = score readout)
        cmpb  #hud.READOUT
        lbeq  hud.scoreReadout

        ; display beam in 5 segments
        ldu   #beam_m_start

        ldb   player1+beam_value
	stb   @cnt
@loop_full_beam
        ldb   #0
@cnt    equ   *-1
        lbeq  @loop_black
        subb  #8
        bmi   @do_partial_beam
	stb   @cnt	
	ldd   #$5555
        _beam_seg_extA
        _beam_seg_extB
	ldd   #$6666
        _beam_seg_midA
        _beam_seg_midB
	ldd   #$dddd
        _beam_seg_intA
        _beam_seg_intB
        cmpu  #beam_m_start+beam_m_size*5
        lbeq  @beam_end
        bra   @loop_full_beam
;
@do_partial_beam
        ldy   #Beam_mask
        lda   #4
        negb
        decb
        mul
        leay  d,y
        ldd   2,y
        anda  #$55
        andb  #$55
        _beam_seg_extA
        ldd   ,y
        anda  #$55
        andb  #$55
        _beam_seg_extB
        ldd   2,y
        anda  #$66
        andb  #$66
        _beam_seg_midA
        ldd   ,y
        anda  #$66
        andb  #$66
        _beam_seg_midB
        ldd   2,y
        anda  #$dd
        andb  #$dd
        _beam_seg_intA
        ldd   ,y
        anda  #$dd
        andb  #$dd
        _beam_seg_intB
        cmpu  #beam_m_start+beam_m_size*5
        beq   @beam_end
;
@loop_black
        ; complete the bar with black segments
	ldd   #$0000
        _beam_seg_extA
        _beam_seg_extB	
        _beam_seg_midA
        _beam_seg_midB
        _beam_seg_intA
        _beam_seg_intB
        cmpu  #beam_m_start+beam_m_size*5
        bne   @loop_black
@beam_end

        ; grant extra globals.lives on globals.score thresholds
        jsr   hud.checkExtraLife

        ; display globals.lives
        ldu   #$DE97
        jsr   DisplayLife

        ; display globals.score : 5 significant digits (score in hundreds) + "00"
        ldu   #$DE7D
        lda   globals.score              ; score == 0 ? (all 3 bytes)
        bne   @scoreShow
        ldd   globals.score+1
        bne   @scoreShow
        ldb   #6                          ; score==0 : 6 black tiles + "0"
@scoreZ jsr   DRAW_Img_hud_b
        leau  1,u
        decb
        bne   @scoreZ
        jmp   DRAW_Img_hud_0
@scoreShow
        lda   globals.score              ; scoreWork = globals.score
        sta   hud.scoreWork
        ldd   globals.score+1
        std   hud.scoreWork+1
        ldy   #hud.scoreDigits
        jsr   ScoreToDigits
        clr   counter_hdr_flag            ; significance flag (0 = still leading zeros)
        clr   hud.scoreDigPos
@scoreLoop
        ldx   #hud.scoreDigits
        ldb   hud.scoreDigPos
        lda   b,x                         ; A = current digit
        sta   hud.curDigit
        bne   @scoreSig
        tst   counter_hdr_flag
        bne   @scoreDraw                  ; already significant -> draw the 0
        jsr   DRAW_Img_hud_b              ; leading zero -> blank tile
        bra   @scoreAdv
@scoreSig
        inc   counter_hdr_flag
@scoreDraw
        lda   hud.curDigit
        asla
        ldx   #Img_Num
        jsr   [a,x]                       ; draw glyph for this digit
@scoreAdv
        leau  1,u
        inc   hud.scoreDigPos
        lda   hud.scoreDigPos
        cmpa  #5
        blo   @scoreLoop
        jsr   DRAW_Img_hud_0              ; trailing "00"
        leau  1,u
        jmp   DRAW_Img_hud_0

; ----------------------------------------------------
; hud.checkExtraLife
; ----------------------------------------------------
; Grants +1 life when the globals.score crosses one of the
; following displayed thresholds:
;   100000, 200000, 350000, 500000, 700000
; The on-screen globals.score is globals.score*100, so the values compared
; against the 'globals.score' variable are divided by 100:
;   1000, 2000, 3500, 5000, 7000
;
; State is tracked in globals.lifeUpIdx (0..5).
; It is auto-reset when globals.score is 0 (new game / restart),
; so no per-game-mode initialization is required.
;
; At most one threshold can be crossed per call (globals.score
; increments are always small enough in-game).
; ----------------------------------------------------
hud.checkExtraLife
        lda   globals.score              ; score == 0 ? (3 bytes)
        bne   @doCheck
        ldd   globals.score+1
        bne   @doCheck
        clr   globals.lifeUpIdx          ; new game: reset tracking
        rts
@doCheck
        ldb   globals.lifeUpIdx
        cmpb  #hud.nbExtraLifeThresholds
        bhs   @rts
        aslb
        ldx   #hud.extraLifeThresholds
        abx
        lda   globals.score              ; MSB != 0 -> score >= 65536 > any threshold
        bne   @grant
        ldd   globals.score+1
        cmpd  ,x
        blo   @rts
@grant  inc   globals.lives
        inc   globals.lifeUpIdx
@rts    rts

hud.nbExtraLifeThresholds equ 5
hud.extraLifeThresholds
        fdb   1000                     ; 100000
        fdb   2000                     ; 200000
        fdb   3500                     ; 350000
        fdb   5000                     ; 500000
        fdb   7000                     ; 700000

; ----------------------------------------------------
; Display the number of globals.lives on screen (mode 160x200x16)
;
; Draws 7 columns total: padding black tiles on the left
; followed by one life icon per remaining life. When
; 'globals.lives' is >= 7, the display is capped to 7 icons.
;
; INPUT
; -----
; register U : screen location in ram A ($C000-$DFFF)
;              (leftmost column of the globals.lives area)
; global     : globals.lives (1 byte)
; ----------------------------------------------------
DisplayLife
        ldb   globals.lives
	subb  #7
	bmi   >
	ldb   #7
	bra   @drawLifeFull ; cap when higher globals.lives count than displayable
!
	jsr   DRAW_Img_hud_b
	leau  1,u
	incb
	beq   @drawLife
	bra   <
@drawLife	
	ldb   globals.lives
!
	beq   @rts
@drawLifeFull
 	jsr   DRAW_Img_hud_life	
	leau  1,u
	decb
	bra   <
@rts	rts

; ----------------------------------------------------
; Draw a single "life" icon (4px wide) on screen
; (mode 160x200x16)
;
; INPUT
; -----
; register U : screen location in ram A ($C000-$DFFF)
; ----------------------------------------------------
DRAW_Img_hud_life
	LDA #$08
	STA 120,U
	STA 80,U
	LDA #$04
	STA 40,U
	STA ,U
	LDA #$05
	STA -40,U
	STA -80,U
	LDA #$00
	STA -120,U

        LEAU -$2000,U
	LDA #$18
	STA 80,U
	LDA #$14
	STA 40,U
	STA ,U
	LDA #$08
	STA 120,U
	LDA #$d5
	STA -40,U
	STA -80,U
	LDA #$50
	STA -120,U
        LEAU $2000,U
	rts

; ----------------------------------------------------
; Display a n digit number on screen (mode 160x200x16)
;
; INPUT
; -----
; register B : number of digits (1-5)
; register X : value to display
; register U : screen location in ram A ($C000-$DFFF)
;
; display in 4px steps
; ----------------------------------------------------

; variables
counter_cur_digit equ dp_engine
counter_hdr_flag  equ dp_engine+1

DisplayDigit
        clr   counter_hdr_flag         ; flag used to skip left 0 at display
        stx   @d1
        decb
        aslb
        ldx   #Hud_1
        abx
        ldd   #0
@d1     equ   *-2
        ldy   #Img_Num
@loop   clr   counter_cur_digit        ; single digit counter
!       subd  ,x
        bcs   >
        inc   counter_cur_digit        ; inc digit counter
        bra   <
!       addd  ,x
        std   @d2
        tst   counter_cur_digit
        beq   >
        inc   counter_hdr_flag
!       tst   counter_hdr_flag
        bne   @digits                  ; branch if significant digit to display
        jsr   DRAW_Img_hud_b           ; black background
        bra   >
@digits ldb   counter_cur_digit
        aslb
        jsr   [b,y]
!       leau  1,u                      ; move coordinates to 4px right
        ldd   #0
@d2     equ   *-2
        leax  -2,x
        cmpx  #Hud_1
        bne   >
        inc   counter_hdr_flag
!       cmpx  #Hud_1-2
        bne   @loop
        rts

; ---------------------------------------------------------------------------
; for HUD counter
; ---------------------------------------------------------------------------

Hud_1           fdb   1				
Hud_10          fdb   10
Hud_100         fdb   100
Hud_1000        fdb   1000
Hud_10000       fdb   10000

; ---------------------------------------------------------------------------
; Diplay routines
; ---------------------------------------------------------------------------

Img_Num
        fdb   DRAW_Img_hud_0
        fdb   DRAW_Img_hud_1
        fdb   DRAW_Img_hud_2
        fdb   DRAW_Img_hud_3
        fdb   DRAW_Img_hud_4
        fdb   DRAW_Img_hud_5
        fdb   DRAW_Img_hud_6
        fdb   DRAW_Img_hud_7
        fdb   DRAW_Img_hud_8
        fdb   DRAW_Img_hud_9

; ----------------------------------------------------
; Draw a single blank (black) 4px-wide tile on screen
; (mode 160x200x16). Used both as background eraser and
; as padding by DisplayLife / DisplayDigit.
;
; INPUT
; -----
; register U : screen location in ram A ($C000-$DFFF)
; ----------------------------------------------------
DRAW_Img_hud_b

	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
        LEAU $2000,U
	rts

DRAW_Img_hud_0

	LDA #$01
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$01
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$11
	STA 120,U
	STA -120,U

        LEAU $2000,U
	rts

DRAW_Img_hud_1

	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$01
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
        LEAU $2000,U
	rts

DRAW_Img_hud_2

	LDA #$01
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	LDA #$00
	STA -40,U
	STA -80,U
	LDA #$01
	STA -120,U

        LEAU -$2000,U
	LDA #$00
	STA 80,U
	STA 40,U
	LDA #$01
	STA -40,U
	STA -80,U
	LDA #$11
	STA 120,U
	STA ,U
	STA -120,U
        LEAU $2000,U
	rts

DRAW_Img_hud_3

	LDA #$01
	STA 120,U
	LDA #$00
	STA 80,U
	STA 40,U
	LDA #$01
	STA ,U
	LDA #$00
	STA -40,U
	STA -80,U
	LDA #$01
	STA -120,U

        LEAU -$2000,U
	LDA #$01
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
	LDA #$11
	STA 120,U
	STA ,U
	STA -120,U
        LEAU $2000,U
	rts

DRAW_Img_hud_4

	LDA #$00
	STA 120,U
	STA 80,U
	LDA #$01
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$01
	STA 120,U
	STA 80,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LDA #$11
	STA 40,U
        LEAU $2000,U
	rts

DRAW_Img_hud_5

	LDA #$01
	STA 120,U
	LDA #$00
	STA 80,U
	STA 40,U
	LDA #$01
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$01
	STA 80,U
	STA 40,U
	LDA #$00
	STA -40,U
	STA -80,U
	LDA #$11
	STA 120,U
	STA ,U
	STA -120,U
        LEAU $2000,U
	rts

DRAW_Img_hud_6

	LDA #$01
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$01
	STA 80,U
	STA 40,U
	LDA #$00
	STA -40,U
	STA -80,U
	LDA #$11
	STA 120,U
	STA ,U
	STA -120,U
        LEAU $2000,U
	rts

DRAW_Img_hud_7

	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$01
	STA -120,U

        LEAU -$2000,U
	LDA #$11
	STA -120,U
	LDA #$01
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
        LEAU $2000,U
	rts

DRAW_Img_hud_8

	LDA #$01
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$11
	STA 120,U
	STA ,U
	STA -120,U
	LDA #$01
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
        LEAU $2000,U
	rts

DRAW_Img_hud_9

	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	LDA #$01
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$01
	STA 120,U
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
	LDA #$11
	STA ,U
	STA -120,U
        LEAU $2000,U
	rts

; ---------------------------------------------------------------------------
; Beam partial-segment masks
; ---------------------------------------------------------------------------
; Bit masks used when the beam value is not a multiple of 8, to render the
; last (partially filled) segment of the beam bar. Each row describes the 4
; bytes of a segment:
;   RAMB: XH, XL   RAMA: XH, XL
; The parenthesized number indicates how many pixels of the segment are lit
; (from 7 down to 1). The selected row is later ANDed with the full-segment
; colour bytes: one byte stores two pixels (one nibble each), so $55 encodes
; two pixels of colour 5, $66 two pixels of colour 6 and $dd two pixels of
; colour $d. The mask zeroes out the pixels that must stay dark.
; ---------------------------------------------------------------------------

Beam_mask
        fcb $ff,$ff,$ff,$f0 ; (7) RAMB: XH, XL RAMA: XH, XL
        fcb $ff,$ff,$ff,$00 : (6)
        fcb $ff,$f0,$ff,$00 : (5)
        fcb $ff,$00,$ff,$00 : (4)
        fcb $ff,$00,$f0,$00 : (3)
        fcb $ff,$00,$00,$00 : (2)
        fcb $f0,$00,$00,$00 : (1)

; ===========================================================================
; STAGE SCORE READOUT (hud.READOUT) - arcade "score rollover" port
; ---------------------------------------------------------------------------
; Driven by main each frame during endstage phase 4 (double buffer). The 7 score
; digits spin through random glyphs and settle one by one as a master countdown
; crosses per-digit thresholds, like the arcade tick_score_rollover_dispatcher.
; Drawn centered, reusing the HUD digit glyphs (Img_Num / DRAW_Img_hud_*). Seeded
; from the stage score (globals.score - globals.stageScoreBase) the first frame
; after main.endstage.scoreArmed is set; raises main.endstage.scoreDone at 0.
; The bottom HUD is left untouched (preserved by the capped fade).
; ===========================================================================

READOUT_FRAMES equ 224          ; spin/settle master countdown (arcade 0xE0)
READOUT_HOLD   equ 150          ; final-score hold after settle, in frames (~3 s @ 50 Hz)
READOUT_BLANK  equ 10           ; settled-digit sentinel for a blanked leading zero
; on-screen layout (RAMA, 40 cells/line, 1 cell = one 4px glyph). Centered; tune later.
hud.line1U   equ $C000+56*40+5  ; "S T A G E   1   C L E A R E D" (29 cells), scanline 56, centered col 5
hud.line2U   equ $C000+96*40+10 ; "STAGE SCORE " label (12 chars) - scanline 96, col 10
hud.readoutU equ hud.line2U+12  ; the 7 score digits, right after the "STAGE SCORE " label

hud.scoreReadout
        lda   main.endstage.scoreArmed
        beq   @run
        clr   main.endstage.scoreArmed       ; first readout frame: seed digits + countdown
        clr   main.endstage.scoreDone
        jsr   hud.readout.seed
        lda   #READOUT_FRAMES
        sta   hud.readout.timer
@run
        ldb   hud.readout.timer               ; spin/settle countdown, frame-drop compensated
        beq   @holdPhase                      ; spin/settle done -> hold the final score
        subb  gfxlock.frameDrop.count
        bhi   @storeTimer                     ; still spinning (> 0, no underflow)
        clrb                                   ; spin/settle reached 0 this frame
        lda   #READOUT_HOLD                    ; arm the final-score hold (main loop keeps running)
        sta   hud.readout.holdTimer
@storeTimer
        stb   hud.readout.timer
        bra   @draw
@holdPhase
        ; spin/settle done: hold the settled score for READOUT_HOLD frames. The main loop keeps
        ; running (pod animates, ship pipeline) - we only set scoreDone when the hold expires.
        ldb   hud.readout.holdTimer
        beq   @draw                           ; hold already finished (scoreDone set) -> just draw
        subb  gfxlock.frameDrop.count
        bhi   @storeHold                      ; still holding
        clrb
        lda   #1
        sta   main.endstage.scoreDone          ; hold done -> the Tick may leave the level
@storeHold
        stb   hud.readout.holdTimer
@draw
        ldu   #hud.line1U                     ; "STAGE n CLEARED" (static; redrawn each frame so
        ldy   #hud.str.cleared                ;   both video buffers carry it)
        jsr   hud.drawStr
        ldu   #hud.line2U                     ; "STAGE SCORE " label
        ldy   #hud.str.score
        jsr   hud.drawStr
        clr   hud.readout.spun                ; "did any digit actually spin this frame" (arcade DI)
        ldu   #hud.readoutU                   ; leftmost score digit (RAMA)
        ldx   #0                              ; digit index 0..6
@digitLoop
        ldb   hud.readout.digits,x            ; settled value for this position
        cmpb  #10
        bhs   @blank                           ; blanked leading zero -> never spins, stays blank
        lda   hud.readout.timer               ; significant digit: spin while timer > threshold[i]
        cmpa  hud.readout.thresholds,x
        bls   @realDigit                       ; timer <= threshold -> settled (B = digits[x])
        inc   hud.readout.spun                  ; this digit spins this frame
        jsr   RandomNumber                      ; random glyph 0..9
        andb  #15
        cmpb  #10
        blo   @realDigit
        andb  #7                                ; clamp 10..15 -> 2..7 (arcade)
@realDigit
        aslb
        ldy   #numbers_addr                     ; title font digits (raccord avec les lettres)
        jsr   [b,y]                             ; DRAW_text_<digit> at U
        bra   @nextDigit
@blank
        jsr   DRAW_text_space
@nextDigit
        leau  1,u
        leax  1,x
        cmpx  #7
        blo   @digitLoop
        ; chime every 4th frame while at least one significant digit actually spun (arcade DI)
        lda   hud.readout.spun
        beq   @done
        ldb   gfxlock.frame.count+1
        andb  #3
        bne   @done
        ldd   #$0201                           ; soundFX queue: id 2 (BonusSound) << 8 | priority 1
        std   soundFX.newSound                 ; (inline - no soundFX macro include in this object)
@done   rts

; ---------------------------------------------------------------------------
; hud.drawStr - draw a 0-terminated uppercase string at U (RAMA) with the
; duplicated title font. Y = string ptr, U = screen dest. Each DRAW_text_X
; restores U (pshs/puls), so we advance leau 1,u per character.
; Trashes A,X,Y,U.
; ---------------------------------------------------------------------------
hud.drawStr
        ldx   #letter_addr
@l      lda   ,y+
        beq   @r
        suba  #32
        asla
        jsr   [a,x]
        leau  1,u
        bra   @l
@r      rts

hud.str.cleared fcc 'S T A G E   1   C L E A R E D'
                fcb 0
hud.str.score   fcc 'STAGE SCORE '
                fcb 0

; ---------------------------------------------------------------------------
; seed: stageScore = globals.score - globals.stageScoreBase, expand to 7 digits
; (5 significant MSB-first + the x100 trailing "00"), blank leading zeros.
; ---------------------------------------------------------------------------
hud.readout.seed
        ldd   globals.score+1            ; stageScore = score - base (24-bit)
        subd  globals.stageScoreBase+1
        std   hud.scoreWork+1
        lda   globals.score
        sbca  globals.stageScoreBase
        sta   hud.scoreWork
        bcc   >
        clr   hud.scoreWork              ; base > score -> clamp to 0
        clr   hud.scoreWork+1
        clr   hud.scoreWork+2
!       ldy   #hud.readout.digits
        jsr   ScoreToDigits              ; digits[0..4] = 5 significant digits
        ldx   #hud.readout.digits+5
        clr   ,x+                        ; digits[5] = 0 (x100 trailing zero)
        clr   ,x                         ; digits[6] = 0
        ldx   #hud.readout.digits        ; blank leading zeros (keep real digits[6])
        ldb   #6
@blank  lda   ,x
        bne   @blankDone
        lda   #READOUT_BLANK
        sta   ,x+
        decb
        bne   @blank
@blankDone
        rts

hud.readout.timer      fcb 0
hud.readout.holdTimer  fcb 0                  ; final-score hold countdown (after settle)
hud.readout.seedDigit  fcb 0
hud.readout.spun       fcb 0                  ; per-frame count of digits that spun (arcade DI)
hud.readout.digits     fcb 0,0,0,0,0,0,0      ; 7 settled digit values (0-9 or READOUT_BLANK)
hud.readout.thresholds fcb $10,$20,$30,$50,$70,$90,$A0
hud.readout.powers     fdb 10000,1000,100,10,1

; ScoreToDigits - expand 3-byte hud.scoreWork (hundreds, 0..99999) into 5 decimal
;                 digits (0..9) MSB-first at the buffer pointed by Y (Y += 5).
; INPUT : hud.scoreWork (3 bytes, MSB first), Y = output buffer
; CLOBBERS: A,B,X,Y,D,CC
ScoreToDigits
        ldx   #hud.readout.powers
@digit  clr   ,y
@sub    ldd   hud.scoreWork+1
        subd  ,x
        std   hud.scoreWork+1
        lda   hud.scoreWork
        sbca  #0
        sta   hud.scoreWork
        bcs   @subDone               ; borrow out of MSB -> value went negative
        inc   ,y
        bra   @sub
@subDone
        ldd   hud.scoreWork+1        ; undo last subtract (+= power)
        addd  ,x
        std   hud.scoreWork+1
        lda   hud.scoreWork
        adca  #0
        sta   hud.scoreWork
        leax  2,x
        leay  1,y
        cmpx  #hud.readout.powers+10
        blo   @digit
        rts

hud.scoreWork    fcb 0,0,0
hud.scoreDigits  fcb 0,0,0,0,0
hud.curDigit     fcb 0
hud.scoreDigPos  fcb 0

; ===========================================================================
; STAGE-CLEARED FONT  (duplicated verbatim from objects/levels/00/text/text.asm)
; ---------------------------------------------------------------------------
; Full title-screen glyph set, copied here so the phase-4 STAGE CLEARED / STAGE
; SCORE text draws letters without depending on the title objects bank.
; letter_addr is indexed by (ASCII-32)*2; each DRAW_text_X draws one 4px-wide x
; ~8px-tall glyph at U (RAMA $C000-$DFFF), both banks via LEAU -$2000, the caller
; advancing leau 1,u per char. Same 4px scale as the HUD digits (DRAW_Img_hud_*).
; Object-local labels -> the title copy and this one do not clash at link.
; ===========================================================================
letter_addr     fdb DRAW_text_space                * 32 = space
                fdb DRAW_text_exclam               * 33 = !
                fdb DRAW_text_space                * 34
                fdb DRAW_text_space                * 35
                fdb DRAW_text_space                * 36
                fdb DRAW_text_space                * 37
                fdb DRAW_text_space                * 38
                fdb DRAW_text_space                * 39
                fdb DRAW_text_space                * 40
                fdb DRAW_text_space                * 41
                fdb DRAW_text_space                * 42
                fdb DRAW_text_space                * 43
                fdb DRAW_text_space                * 44
                fdb DRAW_text_space                * 45
                fdb DRAW_text_dot                  * 46
                fdb DRAW_text_space                * 47
numbers_addr    fdb DRAW_text_0                    * 48 = 0                
                fdb DRAW_text_1                    * 49 = 1
                fdb DRAW_text_2                    * 50 = 2
                fdb DRAW_text_3                    * 51
                fdb DRAW_text_4                    * 52
                fdb DRAW_text_5                    * 53
                fdb DRAW_text_6                    * 54
                fdb DRAW_text_7                    * 55 = 7
                fdb DRAW_text_8                    * 56 = 8
                fdb DRAW_text_9                    * 57 = 9
                fdb DRAW_text_space                * 58
                fdb DRAW_text_space                * 59
                fdb DRAW_text_space                * 60
                fdb DRAW_text_space                * 61
                fdb DRAW_text_space                * 62
                fdb DRAW_text_space                * 63
                fdb DRAW_text_space                * 64
                fdb DRAW_text_a                    * 65 = A
                fdb DRAW_text_b                    * 66
                fdb DRAW_text_c                    * 67
                fdb DRAW_text_d                    * 68
                fdb DRAW_text_e                    * 69
                fdb DRAW_text_f                    * 70
                fdb DRAW_text_g                    * 71
                fdb DRAW_text_h                    * 72
                fdb DRAW_text_i                    * 73
                fdb DRAW_text_j                    * 74
                fdb DRAW_text_k                    * 75
                fdb DRAW_text_l                    * 76
                fdb DRAW_text_m                    * 77
                fdb DRAW_text_n                    * 78
                fdb DRAW_text_o                    * 79
                fdb DRAW_text_p                    * 80
                fdb DRAW_text_q                    * 81
                fdb DRAW_text_r                    * 82
                fdb DRAW_text_s                    * 83
                fdb DRAW_text_t                    * 84
                fdb DRAW_text_u                    * 85
                fdb DRAW_text_v                    * 86
                fdb DRAW_text_w                    * 87
                fdb DRAW_text_x                    * 88
                fdb DRAW_text_y                    * 89
                fdb DRAW_text_z                    * 90
                fdb DRAW_text_copy                 * 91 = [ (but used for (c) )

DRAW_text_dot
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	LDA #$fd
	STA 40,U
	LDA #$ff
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc
DRAW_text_z
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f6
	STA -80,U
	LDA #$ff
	STA -120,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA -80,U
	LDA #$5f
	STA 80,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_3
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LDA #$f6
	STA -40,U
	LDA #$ff
	STA -80,U
	STA -120,U
	LDA #$55
	STA 80,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_o
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_w
        pshs u
	LEAU 40,U

	LDA #$66
	STA ,U
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$5f
	STA 80,U
	LDA #$55
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_b
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$f0
	STA -40,U
	LDA #$d0
	STA -120,U
	LDA #$60
	STA ,U
	STA -80,U
	LDA #$50
	STA 40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_i
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	STA 40,U
	LDA #$f6
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$fd
	STA -120,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f0
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_5
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LDA #$55
	STA 80,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	STA -80,U
	STA -120,U
	LDA #$6f
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_d
        pshs u
	LEAU 40,U

	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_q
        pshs u
	LEAU 40,U

	LDA #$65
	STA ,U
	LDA #$6f
	STA -40,U
	STA -80,U
	LDA #$55
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$f6
	STA 80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_8
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_2
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA -80,U
	STA -120,U
	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LDA #$5f
	STA 80,U
	LDA #$6f
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_n
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$df
	STA -120,U
	LDA #$65
	STA ,U
	LDA #$66
	STA -40,U
	STA -80,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_v
        pshs u
	LEAU 40,U

	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 80,U
	LDA #$55
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_exclam
        pshs u
	LEAU 40,U

	LDA #$5f
	STA 80,U
	LDA #$ff
	STA 120,U
	STA 40,U
	LDA #$f6
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA -120,U
	LEAU -40,U

	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$60
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	LDA #$d0
	STA -120,U
	LEAU -40,U

	LDA #$10
	STA -120,U
	puls u,pc

DRAW_text_c
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$df
	STA -120,U
	LDA #$5f
	STA 40,U
	LDA #$0f
	STA ,U
	LDA #$ff
	STA 120,U
	STA 80,U
	STA -40,U
	STA -80,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_h
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_4
        pshs u
	LEAU 40,U

	LDA #$df
	STA -120,U
	LDA #$66
	STA ,U
	LDA #$6f
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_e
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f0
	STA 120,U
	STA 40,U
	STA -80,U
	STA -120,U
	LDA #$50
	STA 80,U
	LDA #$00
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$d0
	STA -120,U
	puls u,pc

DRAW_text_9
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LDA #$55
	STA 80,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_p
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_m
        pshs u
	LEAU 40,U

	LDA #$6f
	STA ,U
	STA -40,U
	LDA #$66
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$dd
	STA -120,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_x
        pshs u
	LEAU 40,U

	LDA #$df
	STA -120,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$66
	STA -80,U
	LDA #$ff
	STA 120,U
	LDA #$f6
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_1
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	STA 40,U
	LDA #$f6
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$fd
	STA -120,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f0
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_copy
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	LDA #$1f
	STA -120,U
	LDA #$65
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 40,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 40,U
	LDA #$f6
	STA -40,U
	LDA #$fd
	STA -120,U
	LDA #$66
	STA ,U
	STA -80,U
	LDA #$5f
	STA 80,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_u
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_7
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_k
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$66
	STA ,U
	LDA #$6f
	STA -40,U
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$6f
	STA -40,U
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	STA ,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_s
        pshs u
	LEAU 40,U

	LDA #$1d
	STA -120,U
	LDA #$55
	STA 80,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA -40,U
	STA -80,U
	STA -120,U
	LDA #$6f
	STA ,U
	LDA #$5f
	STA 40,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_f
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_l
        pshs u
	LEAU 40,U

	LDA #$df
	STA -120,U
	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LDA #$5f
	STA 80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_0
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$df
	STA -120,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 80,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_y
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	STA 40,U
	LDA #$f6
	STA ,U
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$df
	STA -120,U
	LDA #$6f
	STA -80,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_a
        pshs u
	LEAU 40,U

	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$f1
	STA -120,U
	LDA #$66
	STA ,U
	LDA #$6f
	STA -40,U
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f0
	STA 120,U
	LDA #$50
	STA 80,U
	STA 40,U
	LDA #$60
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$d0
	STA -120,U
	LEAU -40,U

	LDA #$10
	STA -120,U
	puls u,pc

DRAW_text_t
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	STA 40,U
	LDA #$f6
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$fd
	STA -120,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_space
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_6
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$55
	STA 80,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	LDA #$66
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA -80,U
	STA -120,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc

DRAW_text_j
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	LDA #$ff
	STA -40,U
	STA -80,U
	STA -120,U
	LDA #$6f
	STA ,U
	LDA #$55
	STA 40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$df
	STA -120,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 80,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_r
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$df
	STA -120,U
	LDA #$66
	STA ,U
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$1d
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA ,U
	STA -40,U
	LDA #$6f
	STA -80,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$df
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_g
        pshs u
	LEAU 40,U

	LDA #$1f
	STA -120,U
	LDA #$5f
	STA 40,U
	LDA #$6f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	LDA #$f5
	STA 80,U
	LEAU -40,U

	LDA #$f1
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$6f
	STA ,U
	STA -40,U
	LDA #$5f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$df
	STA -120,U
	puls u,pc
