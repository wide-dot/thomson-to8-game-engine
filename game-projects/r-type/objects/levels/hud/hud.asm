; *****************************************************************************
; Render HUD on screen
; --------------------
;
; - nb of lives
; - beam indicator
; - score
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

        ; display lives
        ldu   #$DE97
        jsr   DisplayLife

        ; display score
        ldu   #$DE7D
        ldx   score
        beq   >
        ldb   #5                       ; nb of char
        jsr   DisplayDigit
        ; display the last two 0
	jsr   DRAW_Img_hud_0
	leau  1,u
 	jmp   DRAW_Img_hud_0

!       ; special case when score is 0
        ldb   #6                       ; nb of black char
!	jsr   DRAW_Img_hud_b
	leau  1,u
	decb
	bne   <	
	jmp   DRAW_Img_hud_0

DisplayLife
        ldb   lives
	subb  #7
	bpl   @drawlife ; cap when higher lives count than displayable
!	jsr   DRAW_Img_hud_b
	leau  1,u
	incb
	beq   @drawlife
	bra   <
@drawlife	
	ldb   lives
	beq   @rts
	cmpb  #7
	bls   >
	ldb   #7 ; cap when higher lives count than displayable
!	jsr   DRAW_Img_hud_life	
	leau  1,u
	decb
	beq   @rts
	bra   <
@rts	rts

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

Beam_mask
        fcb $ff,$ff,$ff,$f0 ; (7) RAMB: XH, XL RAMA: XH, XL
        fcb $ff,$ff,$ff,$00 : (6)
        fcb $ff,$f0,$ff,$00 : (5)
        fcb $ff,$00,$ff,$00 : (4)
        fcb $ff,$00,$f0,$00 : (3)
        fcb $ff,$00,$00,$00 : (2)
        fcb $f0,$00,$00,$00 : (1)
