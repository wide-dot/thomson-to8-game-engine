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
        stu   @d1
        decb
        aslb
        ldx   #Hud_1
        abx
        ldd   #0
@d1     equ   *-2
        ldy   #Img_Num
        clr   counter_hdr_flag  ; flag used to skip left 0 at display
@loop   clr   counter_cur_digit ; single digit counter
!       subd  ,x
        bcs   >
        inc   counter_cur_digit ; inc digit counter
        bra   <
!       addd  ,x
        tst   counter_cur_digit
        beq   >
        inc   counter_hdr_flag
!       tst   counter_hdr_flag
        beq   >                 ; skip display because all left digits are 0
        std   @d2
        ldu   glb_screen_location_2
        ldb   counter_cur_digit
        aslb
        jsr   [b,y]
        ldd   #0
@d2     equ   *-2
!       ldu   glb_screen_location_1 ; move coordinates to 6px right
        leau  1,u
        stu   @u
        ldu   glb_screen_location_2
        leau  2,u
        stu   glb_screen_location_1
        ldu   #0
@u      equ   *-2
        stu   glb_screen_location_2 ; deal with interlace ...
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
        fdb   DRAW_Img_num
        fdb   DRAW_Img_num_1
        fdb   DRAW_Img_num_2
        fdb   DRAW_Img_num_3
        fdb   DRAW_Img_num_4
        fdb   DRAW_Img_num_5
        fdb   DRAW_Img_num_6
        fdb   DRAW_Img_num_7
        fdb   DRAW_Img_num_8
        fdb   DRAW_Img_num_9

DRAW_Img_num
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	LDA #$fd
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$ff
	STD 39,U
	LDA #$df
	STD 79,U
	LDD #$effd
	STD -121,U
	LEAU -220,U

	LDA #$df
	STD 59,U
	STD 19,U
	STD -21,U
	LDD #$dddd
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$dd
	STA 120,U
	LDA #$df
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$de
	STA -120,U
	LDA #$fd
	STA 80,U
	LDA #$ff
	STA 40,U
	LEAU -220,U

	LDA #$dd
	STA 60,U
	STA 20,U
	LDA #$ff
	STA -20,U
	STA -60,U
	RTS

DRAW_Img_num_1
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -220,U

	STD 59,U
	STD 19,U
	STD -21,U
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$fd
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA #$ef
	STA -120,U
	LEAU -220,U

	LDA #$ff
	STA -20,U
	LDA #$df
	STA 60,U
	STA 20,U
	STA -60,U
	RTS

DRAW_Img_num_2
	LEAU 81,U

	LDD #$ffdd
	STD 79,U
	STD 39,U
	STD -1,U
	LDA #$dd
	STD 119,U
	LDA #$ef
	STD -41,U
	LDA #$de
	STD -81,U
	LDD #$ddfd
	STD -121,U
	LEAU -220,U

	LDB #$dd
	STD -61,U
	LDD #$dffd
	STD 19,U
	STD -21,U
	LDA #$dd
	STD 59,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$dd
	STA 120,U
	STA ,U
	LDA #$df
	STA -120,U
	LDA #$ff
	STA 80,U
	STA 40,U
	LDA #$fd
	STA -40,U
	LDA #$ff
	STA -80,U
	LEAU -220,U

	LDA #$df
	STA 60,U
	LDA #$dd
	STA 20,U
	LDA #$ff
	STA -20,U
	STA -60,U
	RTS

DRAW_Img_num_3
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$df
	STD 79,U
	LDA #$ff
	STD 39,U
	LDA #$fd
	STD -1,U
	LEAU -220,U

	LDD #$dffd
	STD 19,U
	STD -21,U
	LDA #$dd
	STD 59,U
	LDB #$dd
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$dd
	STA 120,U
	LDA #$df
	STA 40,U
	STA ,U
	STA -40,U
	STA -120,U
	LDA #$fd
	STA 80,U
	STA -80,U
	LEAU -220,U

	LDA #$dd
	STA 60,U
	STA 20,U
	LDA #$ff
	STA -20,U
	STA -60,U
	RTS

DRAW_Img_num_4
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$fffd
	STD -1,U
	STD -41,U
	LDA #$df
	STD -121,U
	LDD #$efdd
	STD -81,U
	LEAU -220,U

	LDD #$ddfd
	STD 59,U
	STD 19,U
	STD -21,U
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$ff
	STA ,U
	STA -40,U
	LDA #$fd
	STA -120,U
	LDA #$dd
	STA 120,U
	LDA #$df
	STA 80,U
	STA 40,U
	STA -80,U
	LEAU -220,U

	LDA #$ff
	STA 60,U
	LDA #$df
	STA -20,U
	LDA #$dd
	STA -60,U
	LDA #$ef
	STA 20,U
	RTS

DRAW_Img_num_5
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	STD -41,U
	LDA #$df
	STD 79,U
	LDA #$ff
	STD 39,U
	STD -81,U
	LDA #$fd
	STD -1,U
	LDA #$ef
	STD -121,U
	LEAU -220,U

	LDA #$df
	STD 59,U
	STD 19,U
	LDB #$fd
	STD -21,U
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$fd
	STA 80,U
	LDA #$ff
	STA 40,U
	STA -80,U
	LDA #$fe
	STA -120,U
	LDA #$dd
	STA 120,U
	LDA #$df
	STA ,U
	STA -40,U
	LEAU -220,U

	LDA #$ff
	STA -20,U
	STA -60,U
	LDA #$dd
	STA 60,U
	STA 20,U
	RTS

DRAW_Img_num_6
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	LDA #$ff
	STD 39,U
	STD -81,U
	LDA #$df
	STD 79,U
	LDA #$fd
	STD -1,U
	STD -41,U
	LDA #$ef
	STD -121,U
	LEAU -220,U

	LDD #$dffd
	STD 19,U
	STD -21,U
	LDB #$dd
	STD 59,U
	LDA #$dd
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$dd
	STA 120,U
	LDA #$df
	STA ,U
	STA -40,U
	LDA #$fd
	STA 80,U
	LDA #$ff
	STA 40,U
	LDA #$fe
	STA -80,U
	STA -120,U
	LEAU -220,U

	LDA #$ff
	STA -20,U
	STA -60,U
	LDA #$dd
	STA 60,U
	STA 20,U
	RTS

DRAW_Img_num_7
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	STD -81,U
	STD -121,U
	LDA #$ff
	STD 39,U
	LDA #$fe
	STD 79,U
	LDA #$df
	STD -1,U
	STD -41,U
	LEAU -220,U

	LDD #$ddfd
	STD 59,U
	STD 19,U
	LDA #$ff
	STD -21,U
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$dd
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	LDA #$fd
	STA -40,U
	LDA #$ff
	STA -80,U
	LDA #$ef
	STA -120,U
	LEAU -220,U

	LDA #$de
	STA 60,U
	LDA #$dd
	STA 20,U
	LDA #$ff
	STA -20,U
	STA -60,U
	RTS

DRAW_Img_num_8
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	STD -121,U
	LDA #$df
	STD 79,U
	STD -81,U
	LDA #$ff
	STD 39,U
	LDA #$fd
	STD -1,U
	STD -41,U
	LEAU -220,U

	LDD #$dffd
	STD 59,U
	STD 19,U
	STD -21,U
	LDD #$dddd
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$dd
	STA 120,U
	LDA #$df
	STA ,U
	STA -40,U
	LDA #$fd
	STA 80,U
	LDA #$ff
	STA 40,U
	LDA #$fd
	STA -80,U
	LDA #$ff
	STA -120,U
	LEAU -220,U

	LDA #$dd
	STA 60,U
	STA 20,U
	LDA #$ff
	STA -20,U
	STA -60,U
	RTS

DRAW_Img_num_9
	LEAU 81,U

	LDD #$dddd
	STD 119,U
	STD -41,U
	LDD #$dffd
	STD -121,U
	LDD #$ffdd
	STD 39,U
	LDA #$fd
	STD -1,U
	LDD #$deed
	STD -81,U
	LDD #$dfdd
	STD 79,U
	LEAU -220,U

	LDB #$fd
	STD 59,U
	STD 19,U
	STD -21,U
	LDD #$dddd
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$dd
	STA 120,U
	LDA #$df
	STA ,U
	STA -40,U
	LDA #$fd
	STA 80,U
	LDA #$ff
	STA 40,U
	STA -80,U
	STA -120,U
	LEAU -220,U

	STA -20,U
	STA -60,U
	LDA #$dd
	STA 60,U
	STA 20,U
	RTS
