Math_CalculateAtan2
                            ; Y = quadrant identifier (&1 = bottom, &2 = right)
                            ; $00 = absolute X (xdiff)
                            ; $01 = absolute Y (ydiff)
                            ; Only the most significant 3 bits of each coordinate are considered.
                            ; Result = A = angle (00..3F)
                            ;     When Y=0: A = (0x00 + ArctanTable[xdiff/32*8 + ydiff/32])
                            ;     When Y=1: A = (0x10 + ArctanTable[ydiff/32*8 + xdiff/32])
                            ;     When Y=2: A = (0x30 + ArctanTable[ydiff/32*8 + xdiff/32]) & 0x3F
                            ;     When Y=3: A = (0x20 + ArctanTable[xdiff/32*8 + ydiff/32])
	$8D76  98:          tya 
	$8D77  38:          sec 
	$8D78  E9 01:       sbc #$01
	$8D7A  C9 02:       cmp #$02
	$8D7C  B0 0C:       bcs +		; $8D8A
	$8D7E  A5 00:       lda $00
	$8D80  85 02:       sta $02
	$8D82  A5 01:       lda $01
	$8D84  85 00:       sta $00
	$8D86  A5 02:       lda $02
	$8D88  85 01:       sta $01
+	$8D8A  B9 EA 8D:    lda Math_Atan2Offsets,y
	$8D8D  85 02:       sta $02
	$8D8F  A5 00:       lda $00
	$8D91  20 73 E3:    jsr Math_divAby16
	$8D94  4A:          lsr a
	$8D95  85 00:       sta $00
	$8D97  A5 01:       lda $01
	$8D99  4A:          lsr a
	$8D9A  4A:          lsr a
	$8D9B  29 F8:       and #$F8
	$8D9D  18:          clc 
	$8D9E  65 00:       adc $00
	$8DA0  A8:          tay 
	$8DA1  B9 AA 8D:    lda Math_ArctanTable,y
	$8DA4  18:          clc 
	$8DA5  65 02:       adc $02
	$8DA7  29 3F:       and #$3F
_loc_4DA9
	$8DA9  60:          rts 
;------------------------------------------
Math_ArctanTable
                            ; Perfectly matches round(0x20/pi * atan(((a>>3) + 0.11)
                            ;                                       / ((a&7) + 0.11))) where a=0..63
                            ;  or equivalently: round(0x20/pi * atan2((a>>3) + 0.11, (a&7) + 0.11))
	$8DAA               .byte $08,$01,$01,$00,$00,$00,$00,$00, $0F,$08,$05,$03,$03,$02,$02,$02
	$8DBA               .byte $0F,$0B,$08,$06,$05,$04,$03,$03, $10,$0D,$0A,$08,$07,$06,$05,$04
	$8DCA               .byte $10,$0D,$0B,$09,$08,$07,$06,$05, $10,$0E,$0C,$0A,$09,$08,$07,$06
	$8DDA               .byte $10,$0E,$0D,$0B,$0A,$09,$08,$07, $10,$0E,$0D,$0C,$0B,$0A,$09,$08
;------------------------------------------
Math_Atan2Offsets
	$8DEA               .byte $00,$10,$30,$20
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
	$8D32  A8:          tay 
	$8D33  29 0F:       and #$0F
	$8D35  85 00:       sta $00
	$8D37  98:          tya 
	$8D38  20 73 E3:    jsr Math_divAby16
	$8D3B  85 07:       sta $07
	$8D3D  29 01:       and #$01
	$8D3F  D0 05:       bne +		; $8D46
	$8D41  A5 00:       lda $00
	$8D43  4C 4B 8D:    jmp ++		; $8D4B

+	$8D46  A9 10:       lda #$10
	$8D48  38:          sec 
	$8D49  E5 00:       sbc $00
++	$8D4B  A8:          tay 
	$8D4C  B9 65 8D:    lda Math_CosineTable,y
	$8D4F  85 00:       sta $00
	$8D51  A9 00:       lda #$00
	$8D53  85 01:       sta $01
	$8D55  A5 02:       lda $02
	$8D57  20 EE 8D:    jsr Math_MultiplyOrDivideDependingOnA
	$8D5A  A5 07:       lda $07
	$8D5C  F0 4B:       beq _loc_4DA9		; $8DA9 -> rts
	$8D5E  C9 03:       cmp #$03
	$8D60  F0 47:       beq _loc_4DA9		; $8DA9 -> rts
	$8D62  4C 66 E0:    jmp Math_Negate16bitWordAt00
;------------------------------------------
Math_CosineTable
                            ; Perfectly matches round(0xFF*cos(a*pi/0x20)) with a = 0..16
	$8D65               .byte $FF,$FE,$FA,$F4,$EC,$E1,$D4,$C5,$B4,$A2,$8E,$78,$62,$4A,$32,$19
	$8D75               .byte $00
;------------------------------------------
Math_MultiplyOrDivideDependingOnA
	$8DEE  0A:          asl a
	$8DEF  A8:          tay 
	$8DF0  B9 FD 8D:    lda _JumpPointerTable_4DFD,y
	$8DF3  85 08:       sta $08
	$8DF5  B9 FE 8D:    lda _JumpPointerTable_4DFD+1,y
	$8DF8  85 09:       sta $09
	$8DFA  6C 08 00:    jmp ($08)
_JumpPointerTable_4DFD
	$8DFD  0D 8E:       .word (Math_ShiftNothing		; $8E0D -> rts) ;8E0D (4E0D) ()
	$8DFF  09 8E:       .word (Math_div00by4) ;8E09 (4E09) ()
	$8E01  0B 8E:       .word (Math_div00by2) ;8E0B (4E0B) ()
	$8E03  0E 8E:       .word (Math_0001mulby1p5_RoundUp) ;8E0E (4E0E) ()
	$8E05  1C 8E:       .word (Math_0001mulby2) ;8E1C (4E1C) ()
	$8E07  18 8E:       .word (Math_0001mulby4) ;8E18 (4E18) ()
Math_div00by4
	$8E09  46 00:       lsr $00
Math_div00by2
	$8E0B  46 00:       lsr $00
Math_ShiftNothing
	$8E0D  60:          rts 
;------------------------------------------
Math_0001mulby1p5_RoundUp
	$8E0E  A5 00:       lda $00
	$8E10  4A:          lsr a
	$8E11  65 00:       adc $00
	$8E13  85 00:       sta $00
	$8E15  26 01:       rol $01
	$8E17  60:          rts 
;------------------------------------------
Math_0001mulby4
	$8E18  06 00:       asl $00
	$8E1A  26 01:       rol $01
Math_0001mulby2
	$8E1C  06 00:       asl $00
	$8E1E  26 01:       rol $01
	$8E20  60:          rts 

Math_Negate16bitWordAt00
	$E066  A5 00:       lda $00
	$E068  20 B7 DE:    jsr Math_NegateA
	$E06B  85 00:       sta $00
	$E06D  A5 01:       lda $01
	$E06F  49 FF:       eor #$FF
	$E071  69 00:       adc #$00
	$E073  85 01:       sta $01
	$E075  60:          rts 

Math_divAby16
	$E373  4A:          lsr a
	$E374  4A:          lsr a
	$E375  4A:          lsr a
	$E376  4A:          lsr a
	$E377  60:          rts 

Math_NegateA
	$DEB7  49 FF:       eor #$FF
	$DEB9  18:          clc 
	$DEBA  69 01:       adc #$01
	$DEBC  60:          rts 