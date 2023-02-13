Math_CalculateAtan2

; ported from 6502 : http://bisqwit.iki.fi/kala/atan2_cv2.txt
; Y = quadrant identifier (&1 = bottom, &2 = right)
; $00 = absolute X (xdiff)
; $01 = absolute Y (ydiff)
; Only the most significant 3 bits of each coordinate are considered.
; Result = A = angle (00..3F)
;     When Y=0: A = (0x00 + ArctanTable[xdiff/32*8 + ydiff/32])
;     When Y=1: A = (0x10 + ArctanTable[ydiff/32*8 + xdiff/32])
;     When Y=2: A = (0x30 + ArctanTable[ydiff/32*8 + xdiff/32]) & 0x3F
;     When Y=3: A = (0x20 + ArctanTable[xdiff/32*8 + ydiff/32])

        tya 
        sec 
        sbc   #$01
        cmp   #$02
        bcs   >
        lda   $00
        sta   $02
        lda   $01
        sta   $00
        lda   $02
        sta   $01
!       lda   Math_Atan2Offsets,y
        sta   $02
        lda   $00
        jsr   Math_divAby16
        lsr   a
        sta   $00
        lda   $01
        lsr   a
        lsr   a
        and   #$F8
        clc   
        adc   $00
        tay   
        lda   Math_ArctanTable,y
        clc   
        adc   $02
        and   #$3F
        rts 

;------------------------------------------

Math_ArctanTable
; Perfectly matches round(0x20/pi * atan(((a>>3) + 0.11)
;                                       / ((a&7) + 0.11))) where a=0..63
;  or equivalently: round(0x20/pi * atan2((a>>3) + 0.11, (a&7) + 0.11))
        fcb   $08,$01,$01,$00,$00,$00,$00,$00,$0F,$08,$05,$03,$03,$02,$02,$02
        fcb   $0F,$0B,$08,$06,$05,$04,$03,$03,$10,$0D,$0A,$08,$07,$06,$05,$04
        fcb   $10,$0D,$0B,$09,$08,$07,$06,$05,$10,$0E,$0C,$0A,$09,$08,$07,$06
        fcb   $10,$0E,$0D,$0B,$0A,$09,$08,$07,$10,$0E,$0D,$0C,$0B,$0A,$09,$08

;------------------------------------------

Math_Atan2Offsets
        fcb   $00,$10,$30,$20

;------------------------------------------

Math_CalculateCosine_Scale

; Return value is 16-bit value in $00:
;      round(0xFF * cos(A * 2pi / 0x40))
; Valid range for A: 00..3F. 0x40 = 360 degrees
; $02 scales the result:
;      0 = scale by 1 (that is, no scaling)
;      1 = scale by 0.25 (round towards zero)
;      2 = scale by 0.5 (round towards zero)
;      3 = scale by 1.5 (round away from zero)
;      4 = scale by 2
;      5 = scale by 4

        tay 
        and   #$0F
        sta   $00
        tya 
        jsr   Math_divAby16
        sta   $07
        and   #$01
        bne   +
        lda   $00
        jmp   ++

+	lda   #$10
	sec 
	sbc   $00
++	tay 
	lda   Math_CosineTable,y
	sta   $00
	lda   #$00
	sta   $01
	;lda   $02
	;jsr   Math_MultiplyOrDivideDependingOnA
	lda   $07
	beq   @rts
	cmp   #$03
	beq   @rts
	jmp   Math_Negate16bitWordAt00
@rts    rts

;------------------------------------------

Math_CosineTable

; Perfectly matches round(0xFF*cos(a*pi/0x20)) with a = 0..16

	fcb   $FF,$FE,$FA,$F4,$EC,$E1,$D4,$C5,$B4,$A2,$8E,$78,$62,$4A,$32,$19
	fcb   $00
;------------------------------------------

_Object_SetObjectTowardsPlayer MACRO

; param 1 = speed
; U = ptr to player's data
; X = ptr to projectile's data

        ldd   x_pos,x
        subd  x_pos,u
        _asld
        tfr   d,y
        ldd   y_pos,x
        subd  y_pos,u
        pshs  x,u
	jsr   Math_CalculateAtan2

                            ; A = Angle (00..3F)
                            ; Y = Speed (0,1,2,3,4 mean 1, 0.25, 0.5, 1.5, 2, 4 respectively)
                            ; Xvelocity = cos(angle) * speed
                            ; Yvelocity = -sin(angle) * speed

	jsr Math_CalculateCosine_Scale
        lda   #\1
        mul
        std   y_vel,x

	pla 
	sec 
	sbc #$10
	and #$3F
	jsr Math_CalculateCosine_Scale
	ldy TempPtr00_lo
	lda TempPtr00_hi
	jmp Object_SetYVelocity16bit_from_AY

        lda   #\1
        mul
        std   x_vel,x

        puls  x,u
 ENDM


