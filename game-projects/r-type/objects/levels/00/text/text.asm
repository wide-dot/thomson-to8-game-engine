
; ---------------------------------------------------------------------------
; Object - Logo_R
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"


Object
	nop                ; DO NOT MODIFY THIS LINE OR ADD ANY LINE BEFORE
			   ; THERE IS A DEPENDENCY THAT WILL BE REWRTTENT
			   ; INTO A RTS WHEN THIS OBJECT IS DONE DOING ITS JOB

        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
	fdb   InitSlow
        fdb   LiveSlow
	fdb   InitFast
	fdb   LiveFast
	fdb   InitScoresRAMA
	fdb   InitScoresRAMB
	fdb   LiveScoresInit
	fdb   LiveScores

Init
	lda   subtype,u
	inca
	asla
	deca
	sta   routine,u
	bra   Object
;
; --------------------------------------------------
; TYPE WRITER STYLE TO DISPLAY THE TITLE SCREEN TEXT
; --------------------------------------------------
;
InitSlow
	lda   #0
	sta   @Initslowloopcounter
	inc   routine,u
LiveSlow
        ldy   #allstrings
        ldu   ,y++
        ldx   #letter_addr
        lda   #0
@Initslowloopcounter equ *-1
        inca
        sta   @Initslowloopcounter
        sta   @Liveslowloopcounter
LiveSlowLoop
        lda   #0
@Liveslowloopcounter equ *-1
        beq   LiveSlowEnd
        deca
        sta   @Liveslowloopcounter
WasNotTheSlowEnd
        lda   ,y+
        beq   IsThisTheSlowEnd
        suba  #32
        asla
        jsr   [a,x]
        leau  1,u
        jmp   LiveSlowLoop
IsThisTheSlowEnd
        ldu   ,y++
        bne   WasNotTheSlowEnd
	lda   #$39			; Op-code for RTS
	sta   Object
LiveSlowEnd
	rts
;
; ----------------------------------------------------
; INSTANTANEOUS STYLE TO DISPLAY THE TITLE SCREEN TEXT
; ----------------------------------------------------
;
InitFast
	lda   #2			; Set run counter to 2 in fast mode (to update both RAMs)
	sta   @livefastbuffer
	inc   routine,u
LiveFast
	lda   #2
@livefastbuffer equ *-1
	beq   ThisWasTheFastEnd
	deca  
	sta   @livefastbuffer
        ldy   #allstrings
        ldu   ,y++
        ldx   #letter_addr
LiveFastLoop
        lda   ,y+
        beq   IsThisTheFastEnd
        suba  #32
        asla
        jsr   [a,x]
        leau  1,u
        jmp   LiveFastLoop
IsThisTheFastEnd
	ldu   ,y++
        bne   LiveFastLoop
	rts
ThisWasTheFastEnd
	lda   #$39			; Op-code for RTS
	sta   Object
	rts
;
; ----------------------------------------------------
; DISPLAY THE RANKINGS
; ----------------------------------------------------
;
InitScoresRAMA
	inc   routine,u
	ldy   #scorestring
	ldx   #letter_addr
	ldu   #$C0FE
InitScoreLoopRAMA
	lda   ,y+
	beq   >
	suba  #32
        asla
        jsr   [a,x]
	leau  1,u
	bra   InitScoreLoopRAMA
!
	rts
InitScoresRAMB
	inc   routine,u
	ldy   #scorestring
	ldx   #letter_addr
	ldu   #$C0FE
InitScoreLoopRAMB
	lda   ,y+
	beq   >
	suba  #32
        asla
        jsr   [a,x]
	leau  1,u
	bra   InitScoreLoopRAMB
!
	rts
LiveScoresInit
	inc   routine,u
	stu   @savedu
	lda   #0
	sta   @livescoresmainreportloop
LiveScores
	lda   #0
	sta   @livescoresmainloop
LiveScoresContinue
	lda   #0
@livescoresmainloop equ *-1
	ldu   #0
@savedu equ *-2 
	ldx   x_vel,u			; Unhide score number image
	asla
	ldx   a,x
	asra
	sta   subtype,x
	ldy   #allscores
	ldb   #9
	mul
	leay  b,y
	lda   @livescoresmainloop
	asla
	asla
	ldb   #140
	mul
	ldu   #$C0F0+17+40*30
	leau  d,u
	stu   @nextsavedu
	ldx   ,y++
	ldb   #4
	sty   @savedy
	jsr   DisplayDigit
	jsr   DRAW_text_0
	leau  1,u
	jsr   DRAW_text_0
	ldy   #0
@savedy equ *-2
@nextsavedu equ *-2
	leau  4,u
	lda   #7
	sta   @scorenameloop
	ldx   #letter_addr
!
	lda   ,y+
	suba  #32
	asla
	jsr   [a,x]
	leau  1,u
	lda   #0
@scorenameloop equ *-1
	deca
	beq   >
	sta   @scorenameloop
	bra   <
!
	lda   #0
@livescoresmainreportloop equ *-1
        cmpa  @livescoresmainloop
	beq   >
	lda   @livescoresmainloop
	inca
	sta   @livescoresmainloop
	bra   LiveScoresContinue
!
	inca 
	cmpa  #10
	bne   >
	ldb   #$39			; Op-code for RTS
	;stb   Object
	rts
!
	sta   @livescoresmainreportloop
	rts

counter_cur_digit equ dp_engine
counter_hdr_flag  equ dp_engine+1

DisplayDigit
        clr   counter_hdr_flag         ; flag used to skip left 0 at display
        bra   >
DisplayDigitPad
        lda   #1
        sta   counter_hdr_flag
!
        stx   @d1
        decb
        aslb
        ldx   #Hud_1
        abx
        ldd   #0
@d1     equ   *-2
        ldy   #numbers_addr
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
        jsr   DRAW_text_space          ; black background
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
Hud_100000      fdb   100000

allstrings 
        fdb $C0F0+15+(40*8*1)
        fcc 'BLAST OFF AND STRIKE'
        fcb $00
        fdb $C0F0+15+(40*8*3)
        fcc 'THE EVIL BYDO EMPIRE!'
        fcb $00
        fdb $C0F0+15+(40*8*7)+5
        fcc 'PUSH FIRE BUTTON'
        fcb $00

        fdb $C0F0+15+(40*8*10)+10
        fcc 'FREE  PLAY'
        fcb $00

        fdb $C0F0+15+(40*8*22)+1
        fcc "[ 1987 BY IREM CORP."
        fcb $00

        fdb $0000  * end of all strings

scorestring     fcc 'R A N K I N G'
		fcb $00

allscores
	fdb 1745
        fcc 'ABIKO..'

	fdb 1686
	fcc 'SUMITA '
	
	fdb 1597
	fcc 'AKIO.O '

	fdb 1179
	fcc 'SHINJI.'

	fdb 1005
	fcc 'MISAKO!'

	fdb 989
	fcc 'MASATO '

	fdb 920
	fcc 'HAMA...'

	fdb 800
	fcc 'KENT.K '

	fdb 760
	fcc 'JIJEE..'

	fdb 750
	fcc 'IREM . '

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
	LDA #$f8
	STA 80,U
	LDA #$f1
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
	LDA #$f9
	STA -80,U
	LDA #$ff
	STA -120,U
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA -80,U
	LDA #$8f
	STA 80,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_3
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LDA #$f9
	STA -40,U
	LDA #$ff
	STA -80,U
	STA -120,U
	LDA #$88
	STA 80,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_o
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$4f
	STA -120,U
	LEAU -40,U

	LDA #$f4
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_w
        pshs u
	LEAU 40,U

	LDA #$99
	STA ,U
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$8f
	STA 80,U
	LDA #$88
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_b
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$f0
	STA -40,U
	LDA #$10
	STA -120,U
	LDA #$90
	STA ,U
	STA -80,U
	LDA #$80
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
	LDA #$f8
	STA 80,U
	STA 40,U
	LDA #$f9
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$f1
	STA -120,U
	LEAU -40,U

	LDA #$f4
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
	LDA #$88
	STA 80,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	STA -80,U
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_d
        pshs u
	LEAU 40,U

	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_q
        pshs u
	LEAU 40,U

	LDA #$98
	STA ,U
	LDA #$9f
	STA -40,U
	STA -80,U
	LDA #$88
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$f9
	STA 80,U
	LDA #$4f
	STA -120,U
	LEAU -40,U

	LDA #$f4
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
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
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$4f
	STA -120,U
	LEAU -40,U

	LDA #$f4
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
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
	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_n
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$1f
	STA -120,U
	LDA #$98
	STA ,U
	LDA #$99
	STA -40,U
	STA -80,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_v
        pshs u
	LEAU 40,U

	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 80,U
	LDA #$88
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_exclam
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 80,U
	LDA #$ff
	STA 120,U
	STA 40,U
	LDA #$f9
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA -120,U
	LEAU -40,U

	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$90
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	LDA #$10
	STA -120,U
	LEAU -40,U

	LDA #$40
	STA -120,U
	puls u,pc

DRAW_text_c
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$4f
	STA -120,U
	LEAU -40,U

	LDA #$f4
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$1f
	STA -120,U
	LDA #$8f
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
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_4
        pshs u
	LEAU 40,U

	LDA #$1f
	STA -120,U
	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_e
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f0
	STA 120,U
	STA 40,U
	STA -80,U
	STA -120,U
	LDA #$80
	STA 80,U
	LDA #$00
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$10
	STA -120,U
	puls u,pc

DRAW_text_9
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LDA #$88
	STA 80,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_p
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_m
        pshs u
	LEAU 40,U

	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$99
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_x
        pshs u
	LEAU 40,U

	LDA #$1f
	STA -120,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$99
	STA -80,U
	LDA #$ff
	STA 120,U
	LDA #$f9
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_1
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 80,U
	STA 40,U
	LDA #$f9
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$f1
	STA -120,U
	LEAU -40,U

	LDA #$f4
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
	LDA #$f8
	STA 80,U
	LDA #$4f
	STA -120,U
	LDA #$98
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 40,U
	LEAU -40,U

	LDA #$f4
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 40,U
	LDA #$f9
	STA -40,U
	LDA #$f1
	STA -120,U
	LDA #$99
	STA ,U
	STA -80,U
	LDA #$8f
	STA 80,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_u
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LEAU -40,U

	LDA #$1f
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

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_k
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9f
	STA -40,U
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	STA ,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_s
        pshs u
	LEAU 40,U

	LDA #$41
	STA -120,U
	LDA #$88
	STA 80,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 40,U
	STA ,U
	LEAU -40,U

	LDA #$f4
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA -40,U
	STA -80,U
	STA -120,U
	LDA #$9f
	STA ,U
	LDA #$8f
	STA 40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_f
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$41
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

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_l
        pshs u
	LEAU 40,U

	LDA #$1f
	STA -120,U
	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	LEAU -40,U

	LDA #$4f
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
	LDA #$8f
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
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$4f
	STA -120,U
	LEAU -40,U

	LDA #$f4
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$1f
	STA -120,U
	LDA #$8f
	STA 40,U
	LDA #$9f
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

DRAW_text_y
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 80,U
	STA 40,U
	LDA #$f9
	STA ,U
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$4f
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -120,U
	LDA #$9f
	STA -80,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_a
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	LDA #$f4
	STA -120,U
	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f0
	STA 120,U
	LDA #$80
	STA 80,U
	STA 40,U
	LDA #$90
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$10
	STA -120,U
	LEAU -40,U

	LDA #$40
	STA -120,U
	puls u,pc

DRAW_text_t
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 80,U
	STA 40,U
	LDA #$f9
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$f1
	STA -120,U
	LEAU -40,U

	LDA #$41
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

	LDA #$1f
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
	LDA #$88
	STA 80,U
	LDA #$8f
	STA 40,U
	LDA #$9f
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA -80,U
	STA -120,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

DRAW_text_j
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 80,U
	LDA #$ff
	STA -40,U
	STA -80,U
	STA -120,U
	LDA #$9f
	STA ,U
	LDA #$88
	STA 40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$1f
	STA -120,U
	LDA #$8f
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	STA 80,U
	LEAU -40,U

	LDA #$4f
	STA -120,U
	puls u,pc

DRAW_text_r
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -120,U
	LDA #$99
	STA ,U
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LEAU -40,U

	LDA #$41
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA ,U
	STA -40,U
	LDA #$9f
	STA -80,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_g
        pshs u
	LEAU 40,U

	LDA #$4f
	STA -120,U
	LDA #$8f
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$ff
	STA 120,U
	LDA #$f8
	STA 80,U
	LEAU -40,U

	LDA #$f4
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$8f
	STA 80,U
	STA 40,U
	LDA #$ff
	STA 120,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$1f
	STA -120,U
	puls u,pc

