
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

string1 fcc 'BLAST OFF AND STRIKE'
        fcb $00


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
                fdb DRAW_text_space                * 46
                fdb DRAW_text_space                * 47
                fdb DRAW_text_space                * 48 = 0                
                fdb DRAW_text_1                    * 49 = 1
                fdb DRAW_text_2                    * 50 = 2
                fdb DRAW_text_space                * 51
                fdb DRAW_text_space                * 52
                fdb DRAW_text_space                * 53
                fdb DRAW_text_space                * 54
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
                fdb DRAW_text_z                    * 90S






DRAW_text_z
        pshs u
	LEAU 40,U

	LDA #$f9
	STA 40,U
	LDA #$ff
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$88
	STA 120,U
	LDA #$8f
	STA 80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$ff
	STA 80,U
	STA 40,U
	LDA #$f1
	STA -80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_o
        pshs u
	LEAU 40,U

	LDA #$f8
	STA 120,U
	LDA #$f1
	STA -120,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA -120,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$8f
	STA 80,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_w
        pshs u
	LEAU 40,U

	LDA #$1f
	STA -80,U
	STA -120,U
	LDA #$99
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$8f
	STA 120,U
	LDA #$88
	STA 80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f8
	STA 120,U
	STA 80,U
	LDA #$f9
	STA 40,U
	LDA #$f1
	STA -80,U
	STA -120,U
	LDA #$99
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_b
        pshs u
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	LDA #$1f
	STA -80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f8
	STA 80,U
	LDA #$f9
	STA 40,U
	STA -40,U
	LDA #$f1
	STA -80,U
	LDA #$8f
	STA 120,U
	LDA #$9f
	STA ,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_i
        pshs u
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$11
	STA -120,U
	LDA #$f8
	STA 80,U
	LDA #$f9
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$f1
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$8f
	STA 120,U
	LDA #$ff
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_d
        pshs u
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$8f
	STA 80,U
	LDA #$ff
	STA 120,U
	STA -120,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_q
        pshs u
	LEAU 40,U

	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$88
	STA 80,U
	LDA #$f8
	STA 120,U
	LDA #$f1
	STA -120,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	LDA #$ff
	STA -120,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_8
        pshs u
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$80
	STA 80,U
	LDA #$90
	STA 40,U
	LDA #$99
	STA ,U
	LDA #$90
	STA -40,U
	LDA #$10
	STA -80,U
	LDA #$01
	STA -120,U
	LEAU -40,U

	LDA #$00
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$80
	STA 120,U
	STA 80,U
	LDA #$90
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$10
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$00
	STA -120,U
	puls u,pc

DRAW_text_2
        pshs u
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$8f
	STA 80,U
	LDA #$11
	STA -120,U
	LDA #$ff
	STA -40,U
	STA -80,U
	LDA #$9f
	STA 40,U
	LDA #$99
	STA ,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$8f
	STA 120,U
	LDA #$ff
	STA 80,U
	STA 40,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_n
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$9f
	STA 40,U
	STA ,U
	LDA #$99
	STA -40,U
	LDA #$11
	STA -80,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$99
	STA 40,U
	STA ,U
	LDA #$f8
	STA 120,U
	STA 80,U
	LDA #$f9
	STA -40,U
	LDA #$f1
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_v
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 120,U
	LDA #$88
	STA 80,U
	LDA #$99
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	LDA #$f1
	STA -80,U
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_exclam
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 120,U
	LDA #$ff
	STA 80,U
	LDA #$f9
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$ff
	STA -80,U
	STA -120,U
	LEAU -40,U

	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$1f
	STA -80,U
	STA -120,U
	LDA #$9f
	STA -40,U
	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_c
        pshs u
	LEAU 40,U

	LDA #$1f
	STA -80,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$f8
	STA 120,U
	LDA #$f1
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA ,U
	STA -40,U
	STA -120,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_h
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$9f
	STA 40,U
	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_e
        pshs u
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$80
	STA 80,U
	LDA #$90
	STA 40,U
	LDA #$99
	STA ,U
	LDA #$90
	STA -40,U
	LDA #$10
	STA -80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$80
	STA 120,U
	LDA #$ff
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
	LDA #$10
	STA -120,U
	LDA #$0f
	STA ,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_9
        pshs u
	LEAU 40,U

	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	LDA #$ff
	STA 80,U
	STA 40,U
	LDA #$88
	STA 120,U
	LDA #$1f
	STA -80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$1f
	STA -80,U
	STA -120,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$8f
	STA 120,U
	STA 80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_p
        pshs u
	LEAU 40,U

	LDA #$99
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$1f
	STA -80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_m
        pshs u
	LEAU 40,U

	LDA #$9f
	STA 40,U
	LDA #$99
	STA ,U
	STA -40,U
	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f8
	STA 120,U
	STA 80,U
	LDA #$f9
	STA 40,U
	STA -40,U
	LDA #$f1
	STA -80,U
	STA -120,U
	LDA #$99
	STA ,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_x
        pshs u
	LEAU 40,U

	LDA #$f9
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$f8
	STA 120,U
	STA 80,U
	LDA #$f1
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_1
        pshs u
	LEAU 40,U

	LDA #$f8
	STA 120,U
	STA 80,U
	LDA #$f9
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$f1
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
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

DRAW_text_copy
        pshs u
	LEAU 40,U

	LDD #$ff88
	STD 119,U
	LDD #$f1ff
	STD -121,U
	LDD #$9f9f
	STD 39,U
	STD -81,U
	LDB #$ff
	STD -1,U
	STD -41,U
	LDA #$f8
	STD 79,U
	LEAU -40,U

	LDD #$ff11
	STD -121,U

	LEAU -$2000,U
	LEAU 40,U

	LDD #$88ff
	STD 119,U
	LDD #$ff8f
	STD 79,U
	LDD #$f9f9
	STD 39,U
	STD -81,U
	LDA #$9f
	STD -1,U
	STD -41,U
	LDD #$ff1f
	STD -121,U
	LEAU -40,U

	LDD #$11ff
	STD -121,U
	puls u,pc

DRAW_text_u
        pshs u
	LEAU 40,U

	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$8f
	STA 80,U
	LDA #$f8
	STA 120,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_7
        pshs u
	LEAU 40,U

	LDA #$11
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

	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_k
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$99
	STA 40,U
	STA ,U
	LDA #$9f
	STA -40,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9f
	STA 40,U
	STA -40,U
	LDA #$8f
	STA 80,U
	LDA #$f8
	STA 120,U
	LDA #$ff
	STA ,U
	LDA #$f1
	STA -120,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_s
        pshs u
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$8f
	STA 80,U
	LDA #$ff
	STA 40,U
	LDA #$f1
	STA -120,U
	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f8
	STA 80,U
	LDA #$f9
	STA 40,U
	LDA #$ff
	STA -40,U
	LDA #$f1
	STA -80,U
	LDA #$8f
	STA 120,U
	LDA #$9f
	STA ,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_f
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$9f
	STA 40,U
	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	LDA #$1f
	STA -80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
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
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_l
        pshs u
	LEAU 40,U

	LDA #$88
	STA 120,U
	LDA #$8f
	STA 80,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LDA #$8f
	STA 120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_y
        pshs u
	LEAU 40,U

	LDA #$f8
	STA 120,U
	STA 80,U
	LDA #$f9
	STA 40,U
	LDA #$99
	STA ,U
	LDA #$9f
	STA -40,U
	LDA #$1f
	STA -80,U
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$1f
	STA -80,U
	STA -120,U
	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$ff
	STA 120,U
	STA 80,U
	STA 40,U
	LEAU -40,U

	STA -120,U
	puls u,pc

DRAW_text_a
        pshs u
	LEAU 40,U

	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$f1
	STA -80,U
	LDA #$ff
	STA -120,U
	LDA #$99
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$f8
	STA 120,U
	STA 80,U
	LDA #$f9
	STA ,U
	STA -40,U
	LDA #$f1
	STA -80,U
	LDA #$99
	STA 40,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_t
        pshs u
	LEAU 40,U

	LDA #$f8
	STA 120,U
	STA 80,U
	LDA #$f9
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$f1
	STA -80,U
	LDA #$11
	STA -120,U
	LEAU -40,U

	LDA #$ff
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
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
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

DRAW_text_j
        pshs u
	LEAU 40,U

	LDA #$f8
	STA 120,U
	LDA #$ff
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$f1
	STA -120,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$ff
	STA 120,U
	LDA #$1f
	STA -80,U
	LDA #$11
	STA -120,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$8f
	STA 80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_r
        pshs u
	LEAU 40,U

	LDA #$1f
	STA -80,U
	LDA #$11
	STA -120,U
	LDA #$99
	STA 40,U
	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$8f
	STA 120,U
	STA 80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9f
	STA ,U
	STA -40,U
	LDA #$ff
	STA 40,U
	STA -120,U
	LDA #$8f
	STA 120,U
	STA 80,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

DRAW_text_g
        pshs u
	LEAU 40,U

	LDA #$f8
	STA 120,U
	LDA #$f1
	STA -120,U
	LDA #$8f
	STA 80,U
	LDA #$9f
	STA 40,U
	STA ,U
	STA -40,U
	LDA #$1f
	STA -80,U
	LEAU -40,U

	LDA #$ff
	STA -120,U

	LEAU -$2000,U
	LEAU 40,U

	LDA #$9f
	STA ,U
	LDA #$f8
	STA 80,U
	LDA #$f9
	STA 40,U
	LDA #$ff
	STA -40,U
	LDA #$f1
	STA -80,U
	LDA #$8f
	STA 120,U
	LDA #$1f
	STA -120,U
	LEAU -40,U

	LDA #$ff
	STA -120,U
	puls u,pc

