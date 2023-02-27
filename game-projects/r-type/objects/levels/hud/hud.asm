        ldb   #1
        ldx   lives
        ldu   #$DEA4
        jsr   DisplayDigit

        ldx   score
        beq   >
        ldb   #4                       ; nb of char
        ldu   #$DEC0
        jsr   DisplayDigit
        ldx   #0                       ; display the last two 0
        ldb   #2                       ; nb of char
        ldu   #$DEC4
        jmp   DisplayDigitPad

!       ldx   #0                       ; special case when score is 0
        ldb   #6                       ; nb of char
        ldu   #$DEC0
        jmp   DisplayDigit

; Display a n digit number on screen (mode 160x200x16)
;
; INPUT
; -----
; register B : number of digits
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
Hud_100000      fdb   100000

; ---------------------------------------------------------------------------
; Diplay routines for numbers
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
        pshs u
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
        puls  u,pc

DRAW_Img_hud_0
        pshs u
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$00
	STA -120,U

        LEAU -$2000,U
	LDA #$04
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$44
	STA 120,U
	STA -120,U
        puls  u,pc

DRAW_Img_hud_1
        pshs u
	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$44
	STA -120,U
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
        puls  u,pc

DRAW_Img_hud_2
        pshs u
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	LDA #$00
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$04
	STA -120,U

        LEAU -$2000,U
	LDA #$44
	STA 120,U
	LDA #$40
	STA ,U
	STA -120,U
	LDA #$00
	STA 80,U
	STA 40,U
	LDA #$04
	STA -40,U
	STA -80,U
        puls  u,pc

DRAW_Img_hud_3
        pshs u
	LDA #$04
	STA 120,U
	LDA #$00
	STA 80,U
	STA 40,U
	LDA #$04
	STA ,U
	LDA #$00
	STA -40,U
	STA -80,U
	LDA #$04
	STA -120,U

        LEAU -$2000,U
	LDA #$04
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
	LDA #$44
	STA 120,U
	STA ,U
	STA -120,U
        puls  u,pc

DRAW_Img_hud_4
        pshs u
	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	LDA #$04
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$44
	STA ,U
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
	STA -120,U
        puls  u,pc

DRAW_Img_hud_5
        pshs u
	LDA #$04
	STA 120,U
	LDA #$00
	STA 80,U
	STA 40,U
	LDA #$04
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

        LEAU -$2000,U
	LDA #$40
	STA 120,U
	LDA #$44
	STA ,U
	STA -120,U
	LDA #$04
	STA 80,U
	STA 40,U
	LDA #$00
	STA -40,U
	STA -80,U
        puls  u,pc

DRAW_Img_hud_6
        pshs u
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$00
	STA -120,U

        LEAU -$2000,U
	LDA #$44
	STA 120,U
	STA ,U
	STA -120,U
	LDA #$04
	STA 80,U
	STA 40,U
	LDA #$00
	STA -40,U
	STA -80,U
        puls  u,pc

DRAW_Img_hud_7
        pshs u
	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$04
	STA -120,U

        LEAU -$2000,U
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$44
	STA -120,U
        puls  u,pc

DRAW_Img_hud_8
        pshs u
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$00
	STA -120,U

        LEAU -$2000,U
	LDA #$44
	STA 120,U
	STA ,U
	STA -120,U
	LDA #$04
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
        puls  u,pc

DRAW_Img_hud_9
        pshs u
	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	LDA #$04
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$00
	STA -120,U

        LEAU -$2000,U
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
	LDA #$44
	STA ,U
	STA -120,U
        puls  u,pc

