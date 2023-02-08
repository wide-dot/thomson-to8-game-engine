; Display a n digit number on screen (mode 160x200x16)
;
; INPUT
; -----
; register B : number of digits
; register U : value to display
; set glb_screen_location_1, glb_screen_location_2 with video memory location
; ----------------------------------------------------

; variables
counter_cur_digit equ dp_engine
counter_hdr_flag  equ dp_engine+1

DisplayDigit
        clr   counter_hdr_flag  ; flag used to skip left 0 at display
        bra   >
DisplayDigitPad
        lda   #1
        sta   counter_hdr_flag
!
        stu   @d1
        decb
        aslb
        ldx   #Hud_1
        abx
        ldd   #0
@d1     equ   *-2
        ldy   #Img_Num
@loop   clr   counter_cur_digit ; single digit counter
!       subd  ,x
        bcs   >
        inc   counter_cur_digit ; inc digit counter
        bra   <
!       addd  ,x
        std   @d2
        tst   counter_cur_digit
        beq   >
        inc   counter_hdr_flag
!       tst   counter_hdr_flag
        beq   >                 ; skip display because all left digits are 0
        ldu   glb_screen_location_2
        ldb   counter_cur_digit
        aslb
        jsr   [b,y]
!       ldd   glb_screen_location_1 ; move coordinates to 4px right
        addd  #1
        std   glb_screen_location_1
        ldd   glb_screen_location_2
        addd  #1
        std   glb_screen_location_2
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
; Diplay routines for numbers
; ---------------------------------------------------------------------------

Img_Num
        fdb   DRAW_Img_num_0
        fdb   DRAW_Img_num_1
        fdb   DRAW_Img_num_2
        fdb   DRAW_Img_num_3
        fdb   DRAW_Img_num_4
        fdb   DRAW_Img_num_5
        fdb   DRAW_Img_num_6
        fdb   DRAW_Img_num_7
        fdb   DRAW_Img_num_8
        fdb   DRAW_Img_num_9

DRAW_Img_num_0
	LEAU 80,U

	LDA #$fd
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$0f
	STA 80,U
	LEAU -200,U

	LDA #$fd
	STA 40,U
	LDA ,U
	ANDA #$0F
	ORA #$f0
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$0f
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 120,U
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$0d
	STA 80,U
	LDA #$fd
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -80,U

	STA -80,U
	LDA -120,U
	ANDA #$0F
	ORA #$f0
	STA -120,U
	RTS

DRAW_Img_num_1
	LEAU 40,U

	LDA 120,U
	ANDA #$F0
	ORA #$0f
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$0f
	STA 80,U
	LDA 40,U
	ANDA #$F0
	ORA #$0f
	STA 40,U
	LDA ,U
	ANDA #$F0
	ORA #$0f
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$0f
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$0f
	STA -80,U
	LDA -120,U
	ANDA #$F0
	ORA #$0f
	STA -120,U
	LEAU -180,U

	LDA -20,U
	ANDA #$F0
	ORA #$0f
	STA -20,U
	LDA #$ff
	STA 20,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 120,U
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDA 80,U
	ANDA #$0F
	ORA #$d0
	STA 80,U
	LDA 40,U
	ANDA #$0F
	ORA #$d0
	STA 40,U
	LDA ,U
	ANDA #$0F
	ORA #$d0
	STA ,U
	LDA -40,U
	ANDA #$0F
	ORA #$d0
	STA -40,U
	LDA -80,U
	ANDA #$0F
	ORA #$d0
	STA -80,U
	LDA -120,U
	ANDA #$0F
	ORA #$d0
	STA -120,U
	LEAU -80,U

	LDA -80,U
	ANDA #$0F
	ORA #$d0
	STA -80,U
	LDA -120,U
	ANDA #$0F
	ORA #$d0
	STA -120,U
	RTS

DRAW_Img_num_2
	LEAU 80,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA -40,U
	ANDA #$0F
	ORA #$f0
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$0f
	STA -80,U
	LDA -120,U
	ANDA #$F0
	ORA #$0f
	STA -120,U
	LDA #$ff
	STA 80,U
	LDA #$fd
	STA 40,U
	STA ,U
	LEAU -220,U

	LDA 20,U
	ANDA #$F0
	ORA #$0d
	STA 20,U
	LDA #$ff
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 80,U
	ANDA #$0F
	ORA #$f0
	STA 80,U
	LDA -40,U
	ANDA #$0F
	ORA #$d0
	STA -40,U
	LDA -80,U
	ANDA #$0F
	ORA #$d0
	STA -80,U
	LDA -120,U
	ANDA #$F0
	ORA #$0d
	STA -120,U
	LDA #$dd
	STA 120,U
	LEAU -80,U

	LDA #$fd
	STA -80,U
	LDA -120,U
	ANDA #$0F
	ORA #$f0
	STA -120,U
	RTS

DRAW_Img_num_3
	LEAU 80,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA -120,U
	ANDA #$F0
	ORA #$0f
	STA -120,U
	LDA #$ff
	STA 80,U
	LEAU -220,U

	LDA 20,U
	ANDA #$F0
	ORA #$0d
	STA 20,U
	LDA #$ff
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$fd
	STA 40,U
	STA ,U
	STA -40,U
	LDA 120,U
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$0d
	STA 80,U
	LDA -80,U
	ANDA #$0F
	ORA #$f0
	STA -80,U
	LDA -120,U
	ANDA #$F0
	ORA #$0d
	STA -120,U
	LEAU -80,U

	LDA -120,U
	ANDA #$0F
	ORA #$f0
	STA -120,U
	LDA #$fd
	STA -80,U
	RTS

DRAW_Img_num_4
	LEAU -80,U

	LDA #$fd
	STA 40,U
	STA ,U
	STA -40,U
	LDA 80,U
	ANDA #$F0
	ORA #$0f
	STA 80,U
	LDA -80,U
	ANDA #$0F
	ORA #$f0
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA #$fd
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -80,U

	LDA -80,U
	ANDA #$0F
	ORA #$f0
	STA -80,U
	RTS

DRAW_Img_num_5
	LEAU 40,U

	LDA 120,U
	ANDA #$F0
	ORA #$0f
	STA 120,U
	LDA 80,U
	ANDA #$0F
	ORA #$f0
	STA 80,U
	LDA -40,U
	ANDA #$F0
	ORA #$0d
	STA -40,U
	LDA #$ff
	STA -80,U
	LDA #$fd
	STA -120,U
	LEAU -180,U

	STA 20,U
	LDA #$ff
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 100,U

	LDA #$fd
	STA 20,U
	STA -20,U
	STA -60,U
	LDA 100,U
	ANDA #$0F
	ORA #$d0
	STA 100,U
	LDA 60,U
	ANDA #$F0
	ORA #$0d
	STA 60,U
	LDA -100,U
	ANDA #$0F
	ORA #$f0
	STA -100,U
	LEAU -240,U

	LDA -20,U
	ANDA #$0F
	ORA #$f0
	STA -20,U
	LDA #$dd
	STA 20,U
	RTS

DRAW_Img_num_6
	LEAU 40,U

	LDA 120,U
	ANDA #$F0
	ORA #$0f
	STA 120,U
	LDA #$fd
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$ff
	STA -80,U
	LDA #$fd
	STA -120,U
	LEAU -180,U

	LDA 20,U
	ANDA #$0F
	ORA #$f0
	STA 20,U
	LDA -20,U
	ANDA #$F0
	ORA #$0f
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 100,U

	LDA 100,U
	ANDA #$0F
	ORA #$d0
	STA 100,U
	LDA 60,U
	ANDA #$F0
	ORA #$0d
	STA 60,U
	LDA -100,U
	ANDA #$0F
	ORA #$f0
	STA -100,U
	LDA #$fd
	STA 20,U
	STA -20,U
	STA -60,U
	LEAU -240,U

	LDA -20,U
	ANDA #$0F
	ORA #$f0
	STA -20,U
	LDA #$dd
	STA 20,U
	RTS

DRAW_Img_num_7
	LEAU 60,U

	LDA 100,U
	ANDA #$F0
	ORA #$0f
	STA 100,U
	LDA 60,U
	ANDA #$F0
	ORA #$0f
	STA 60,U
	LDA 20,U
	ANDA #$F0
	ORA #$0f
	STA 20,U
	LDA -20,U
	ANDA #$F0
	ORA #$0f
	STA -20,U
	LDA -60,U
	ANDA #$F0
	ORA #$0f
	STA -60,U
	LDA -100,U
	ANDA #$F0
	ORA #$0f
	STA -100,U
	LEAU -200,U

	LDA 20,U
	ANDA #$F0
	ORA #$0d
	STA 20,U
	LDA #$ff
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 120,U
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDA 80,U
	ANDA #$0F
	ORA #$d0
	STA 80,U
	LDA 40,U
	ANDA #$0F
	ORA #$d0
	STA 40,U
	LDA ,U
	ANDA #$0F
	ORA #$d0
	STA ,U
	LDA -40,U
	ANDA #$0F
	ORA #$d0
	STA -40,U
	LDA -80,U
	ANDA #$0F
	ORA #$d0
	STA -80,U
	LDA -120,U
	ANDA #$F0
	ORA #$0d
	STA -120,U
	LEAU -200,U

	LDA -40,U
	ANDA #$0F
	ORA #$f0
	STA -40,U
	LDA #$fd
	STA 40,U
	STA ,U
	RTS

DRAW_Img_num_8
	LEAU 40,U

	LDA #$fd
	STA 80,U
	STA 40,U
	STA ,U
	STA -120,U
	LDA 120,U
	ANDA #$F0
	ORA #$0f
	STA 120,U
	LDA -40,U
	ANDA #$0F
	ORA #$f0
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$0f
	STA -80,U
	LEAU -180,U

	LDA 20,U
	ANDA #$0F
	ORA #$f0
	STA 20,U
	LDA -20,U
	ANDA #$F0
	ORA #$0f
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 120,U
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$0d
	STA 80,U
	LDA -80,U
	ANDA #$0F
	ORA #$f0
	STA -80,U
	LDA -120,U
	ANDA #$F0
	ORA #$0d
	STA -120,U
	LDA #$fd
	STA 40,U
	STA ,U
	STA -40,U
	LEAU -80,U

	LDA -120,U
	ANDA #$0F
	ORA #$f0
	STA -120,U
	LDA #$fd
	STA -80,U
	RTS

DRAW_Img_num_9
	LEAU 40,U

	LDA #$fd
	STA -80,U
	STA -120,U
	LDA 120,U
	ANDA #$F0
	ORA #$0f
	STA 120,U
	LDA 80,U
	ANDA #$0F
	ORA #$f0
	STA 80,U
	LDA -40,U
	ANDA #$F0
	ORA #$0f
	STA -40,U
	LEAU -180,U

	LDA 20,U
	ANDA #$0F
	ORA #$f0
	STA 20,U
	LDA -20,U
	ANDA #$F0
	ORA #$0f
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 120,U
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$0d
	STA 80,U
	LDA #$fd
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -80,U

	STA -80,U
	LDA -120,U
	ANDA #$0F
	ORA #$f0
	STA -120,U
	RTS