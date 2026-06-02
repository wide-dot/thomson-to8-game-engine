data_143AC
	fcb   $C5,$9F,$00 ; x offset, y offset, image
	fdb   data_148AA  ; animation script
	fcb   $C1,$9A,$00
	fdb   data_148E0
	fcb   $BE,$95,$00
	fdb   data_14916
	fcb   $B9,$90,$00
	fdb   data_1494C
	fcb   $B5,$8D,$00
	fdb   data_14982
	fcb   $B0,$8A,$00
	fdb   data_149B8
	fcb   $AC,$87,$00
	fdb   data_149EE
	fcb   $A7,$87,$02
	fdb   data_14A24
	fcb   $A3,$8A,$02
	fdb   data_14A5A
	fcb   $9F,$8B,$02
	fdb   data_14A90
	fcb   $9B,$8E,$02
	fdb   data_14AC6
	fcb   $97,$91,$02
	fdb   data_14AFC
	fcb   $93,$96,$02
	fdb   data_14B32
	fcb   $90,$99,$04
	fdb   data_14B68
	fcb   $8C,$9C,$04
	fdb   data_14B9E
	fcb   $88,$9E,$04
	fdb   data_14BD4
	fcb   $85,$9F,$04
	fdb   data_14C0A
	fcb   $81,$9C,$04
	fdb   data_14C40
        fcb   $7D,$99,$06 ; tail end
	fdb   data_14C76

data_148AA
	fdb   $0000,$FFF4 ; x vel 8.8, y vel 8.8, duration: x10 (constant)
	fdb   $FFFA,$0000
	fdb   $0000,$000C
	fdb   $0000,$FFF4
	fdb   $0000,$0000
	fdb   $FFFA,$000C
	fdb   $0006,$FFF4
	fdb   $FFFA,$000C
	fdb   $000C,$0000
	fcb   $80

data_148E0
	fdb   $0012,$FFE8
	fdb   $0000,$FFF4
	fdb   $FFE2,$0054
	fdb   $FFFA,$000C
	fdb   $FFFA,$000C
	fdb   $0006,$0030
	fdb   $0012,$FF88
	fdb   $FFEE,$0018
	fdb   $0012,$FFE8
	fcb   $80

data_14916
	fdb   $001E,$FFDC
	fdb   $0018,$FFF4
	fdb   $FFC4,$0060
	fdb   $FFE2,$0048
	fdb   $FFFA,$003C
	fdb   $0000,$0048
	fdb   $0012,$FF40
	fdb   $0000,$000C
	fdb   $0018,$FFB8
	fcb   $80

data_1494C
	fdb   $0042,$FFA0
	fdb   $0030,$FFDC
	fdb   $FFBE,$0078
	fdb   $FFBE,$0060
	fdb   $FFDC,$0084
	fdb   $0006,$0078
	fdb   $0012,$FF10
	fdb   $0000,$0000
	fdb   $001E,$FFA0
	fcb   $80

data_14982
	fdb   $0060,$FF7C
	fdb   $005A,$FFC4
	fdb   $FFB8,$0078
	fdb   $FF9A,$0060
	fdb   $FFBE,$00D8
	fdb   $FFFA,$00A8
	fdb   $0018,$FF10
	fdb   $0000,$FFD0
	fdb   $0024,$FF88
	fcb   $80

data_149B8
	fdb   $0072,$FF40
	fdb   $009C,$FFAC
	fdb   $FFBE,$006C
	fdb   $FF88,$0060
	fdb   $FF8E,$00FC
	fdb   $FFDC,$0120
	fdb   $0018,$FF1C
	fdb   $0000,$FFA0
	fdb   $002A,$FF70
	fcb   $80

data_149EE
	fdb   $007E,$FF28
	fdb   $00DE,$FF58
	fdb   $FFE2,$0084
	fdb   $FF82,$0060
	fdb   $FF52,$00F0
	fdb   $FFAC,$0198
	fdb   $001E,$FF58
	fdb   $0000,$FF64
	fdb   $0024,$FF58
	fcb   $80

data_14A24
	fdb   $0084,$FEF8
	fdb   $0120,$FF04
	fdb   $0006,$0084
	fdb   $FF82,$0078
	fdb   $FF3A,$00CC
	fdb   $FF5E,$0210
	fdb   $0018,$FF88
	fdb   $FFFA,$FF4C
	fdb   $002A,$FF58
	fcb   $80

data_14A5A
	fdb   $007E,$FEE0
	fdb   $015C,$FEA4
	fdb   $0030,$0084
	fdb   $FF8E,$0084
	fdb   $FF34,$00C0
	fdb   $FEF2,$0258
	fdb   $001E,$FFDC
	fdb   $FFFA,$FF34
	fdb   $002A,$FF4C
	fcb   $80

data_14A90
	fdb   $0078,$FEC8
	fdb   $017A,$FE20
	fdb   $006C,$0090
	fdb   $FFA6,$0090
	fdb   $FF34,$00C0
	fdb   $FE8C,$027C
	fdb   $001E,$0048
	fdb   $FFE8,$FF28
	fdb   $0036,$FF4C
	fcb   $80

data_14AC6
	fdb   $007E,$FEBC
	fdb   $0174,$FDD8
	fdb   $00BA,$003C
	fdb   $FFCA,$00A8
	fdb   $FF2E,$00CC
	fdb   $FE32,$0270
	fdb   $0000,$00B4
	fdb   $FFF4,$FF40
	fdb   $0036,$FF58
	fcb   $80

data_14AFC
	fdb   $0078,$FEBC
	fdb   $016E,$FD9C
	fdb   $0102,$FFD0
	fdb   $FFEE,$00B4
	fdb   $FF40,$00D8
	fdb   $FDF0,$0258
	fdb   $FFCA,$0114
	fdb   $FFEE,$FF58
	fdb   $0042,$FF88
	fcb   $80

data_14B32
	fdb   $007E,$FEC8
	fdb   $0162,$FD6C
	fdb   $0138,$FF34
	fdb   $0018,$00CC
	fdb   $FF58,$00E4
	fdb   $FDD8,$0240
	fdb   $FF88,$0120
	fdb   $FFD0,$FFD0
	fdb   $0048,$FFB8
	fcb   $80

data_14B68
	fdb   $007E,$FED4
	fdb   $015C,$FD54
	fdb   $014A,$FEB0
	fdb   $004E,$00A8
	fdb   $FF7C,$0114
	fdb   $FDD2,$0234
	fdb   $FF4C,$00FC
	fdb   $FFA0,$0054
	fdb   $0054,$FFE8
	fcb   $80

data_14B9E
	fdb   $0084,$FEE0
	fdb   $015C,$FD54
	fdb   $0144,$FE5C
	fdb   $0084,$0054
	fdb   $FFAC,$012C
	fdb   $FDDE,$0240
	fdb   $FF2E,$00E4
	fdb   $FF52,$0084
	fdb   $004E,$0048
	fcb   $80

data_14BD4
	fdb   $0090,$FEF8
	fdb   $0156,$FD54
	fdb   $0132,$FE2C
	fdb   $00C0,$FFDC
	fdb   $FFE2,$0144
	fdb   $FDE4,$0240
	fdb   $FF28,$00D8
	fdb   $FF10,$006C
	fdb   $002A,$00E4
	fcb   $80

data_14C0A
	fdb   $0096,$FF34
	fdb   $015C,$FD60
	fdb   $0120,$FDF0
	fdb   $00E4,$FF64
	fdb   $002A,$0150
	fdb   $FDF0,$0264
	fdb   $FF22,$00CC
	fdb   $FEE6,$0030
	fdb   $FFE8,$0168
	fcb   $80

data_14C40
	fdb   $0096,$FFA0
	fdb   $0162,$FD6C
	fdb   $011A,$FDC0
	fdb   $00EA,$FF10
	fdb   $0090,$0138
	fdb   $FDF0,$027C
	fdb   $FF28,$00C0
	fdb   $FEC8,$0018
	fdb   $FF94,$0198
	fcb   $80

data_14C76 ; tail end
	fdb   $0090,$000C
	fdb   $0174,$FD84
	fdb   $010E,$FDA8
	fdb   $00F0,$FEA4
	fdb   $00EA,$00FC
	fdb   $FE14,$02AC
	fdb   $FF1C,$00C0
	fdb   $FEB0,$FFF4
	fdb   $FF34,$01C8
	fcb   $80