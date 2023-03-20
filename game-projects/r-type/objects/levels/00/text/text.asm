
; ---------------------------------------------------------------------------
; Object - Logo_R
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"


Object
        ldu   #$C0F0+20
        ldy   #string1
        ldx   #letter_addr
LiveLoop
        lda   ,y+
        beq   LiveEnd
        suba  #32
        asla
        jsr   [a,x]
        leau  1,u
        jmp   LiveLoop
LiveEnd
	rts

string1 fcc '! 12789127! 127! 127'
        fcb $00


letter_addr     fdb letter_space                * 32 = space
                fdb letter_exclam               * 33 = !
                fdb letter_space                * 34
                fdb letter_space                * 35
                fdb letter_space                * 36
                fdb letter_space                * 37
                fdb letter_space                * 38
                fdb letter_space                * 39
                fdb letter_space                * 40
                fdb letter_space                * 41
                fdb letter_space                * 42
                fdb letter_space                * 43
                fdb letter_space                * 44
                fdb letter_space                * 45
                fdb letter_space                * 46
                fdb letter_space                * 47
                fdb letter_space                * 48 = 0                
                fdb letter_1                    * 49 = 1
                fdb letter_2                    * 50 = 2
                fdb letter_space                * 51
                fdb letter_space                * 52
                fdb letter_space                * 53
                fdb letter_space                * 54
                fdb letter_7                    * 55 = 7
                fdb letter_8                    * 56 = 8
                fdb letter_9                    * 57 = 9




letter_space
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

letter_exclam
        pshs u

	LEAU 40,U

	LDA #$ff
	STA 80,U
	LDA #$f9
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$ff
	STA -80,U
	STA -120,U
	LDA #$9c
	STA 120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

        LEAU -$2000,U
	LEAU 40,U

	LDA #$cf
	STA 40,U
	STA ,U
	LDA #$ff
	STA 120,U
	STA 80,U
	LDA #$9c
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
        puls u,pc

letter_1
        pshs u
	LEAU 40,U

	LDA #$f9
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

        LEAU -$2000,U
	LEAU 40,U

	LDA #$cf
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
        puls u,pc

letter_2
        pshs u
	LEAU 40,U

	LDA #$99
	STA 120,U
	LDA #$9c
	STA 80,U
	STA 40,U
	LDA #$99
	STA ,U
	STA -120,U
	LDA #$ff
	STA -40,U
	STA -80,U
	LEAU -40,U

	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9c
	STA 120,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LDA #$ff
	STA 80,U
	STA 40,U
	LEAU -40,U

	STA -120,U
        puls u,pc

letter_7
        pshs u
	LEAU 40,U

	LDA #$99
	STA -120,U
	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LEAU -40,U

	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9c
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
        puls u,pc

letter_8
        pshs u
	LEAU 40,U

	LDA #$99
	STA 120,U
	LDA #$9c
	STA 80,U
	STA 40,U
	LDA #$99
	STA ,U
	LDA #$9c
	STA -40,U
	STA -80,U
	LDA #$f9
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9c
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

        puls u,pc

letter_9
        pshs u
	LEAU 40,U

	LDA #$ff
	STA 80,U
	STA 40,U
	LDA #$99
	STA 120,U
	STA ,U
	LDA #$9c
	STA -40,U
	STA -80,U
	LDA #$99
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9c
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
        puls u,pc