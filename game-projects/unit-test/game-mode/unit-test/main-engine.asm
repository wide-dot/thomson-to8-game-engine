        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************

        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"        	
        org   $6100
        jsr   InitGlobals
        SETDP $9F

CalcAngleUnitTest
        ldu   #CalcAngleUnitTestData ; read test data
        ldy   #CalcAngleUnitTestData ; write debug 
@a      pulu  d,x
        jsr   CalcAngle
        sta   ,y+                    ; write angle
        cmpu  #CalcAngleUnitTestData+1024+32+4
        bne   @a

CalcAngleUnitTest2
        ldu   #CalcAngleUnitTestData2 ; read test data
        ldy   #CalcAngleUnitTestData2 ; write debug 
@a      pulu  d,x
        jsr   CalcAngle
        sta   ,y+                    ; write angle
        cmpu  #CalcAngleUnitTestData2+1024
        bne   @a

Mul9x16UnitTest
        ldu   #Mul9x16UnitTestData ; read test data
        ldy   #Mul9x16UnitTestData ; write debug 
@a      pulu  d,x
        jsr   Mul9x16
        std   ,y++                 ; write result
        cmpu  #Mul9x16UnitTestData+8*4
        bne   @a

InfiniteLoop
@b      bra   @b

CalcAngleUnitTestData

        ;     Y,X - Circle R=1
        fdb   $0001,$0000 ; 00
        fdb   $0001,$FFFF ; 20
        fdb   $0000,$FFFF ; 40
        fdb   $FFFF,$FFFF ; 60
        fdb   $FFFF,$0000 ; 80
        fdb   $FFFF,$0001 ; A0
        fdb   $0000,$0001 ; C0
        fdb   $0001,$0001 ; E0

        ;     Y,X - special case 0
        fdb   $0000,$0000 ; 40

        ;     Y,X - Circle R=255
        fdb   $00FE,$0006 ; FF
        fdb   $00FE,$000C ; FE
        fdb   $00FE,$0012 ; FD
        fdb   $00FD,$0018 ; ...
        fdb   $00FD,$001F
        fdb   $00FC,$0025
        fdb   $00FB,$002B
        fdb   $00FA,$0031
        fdb   $00F8,$0037
        fdb   $00F7,$003D
        fdb   $00F5,$0044
        fdb   $00F4,$004A
        fdb   $00F2,$004F
        fdb   $00F0,$0055
        fdb   $00ED,$005B
        fdb   $00EB,$0061
        fdb   $00E9,$0067
        fdb   $00E6,$006D
        fdb   $00E3,$0072
        fdb   $00E0,$0078
        fdb   $00DD,$007D
        fdb   $00DA,$0083
        fdb   $00D7,$0088
        fdb   $00D4,$008D
        fdb   $00D0,$0092
        fdb   $00CC,$0097
        fdb   $00C9,$009C
        fdb   $00C5,$00A1
        fdb   $00C1,$00A6
        fdb   $00BC,$00AB
        fdb   $00B8,$00AF
        fdb   $00B4,$00B4
        fdb   $00AF,$00B8
        fdb   $00AB,$00BC
        fdb   $00A6,$00C1
        fdb   $00A1,$00C5
        fdb   $009C,$00C9
        fdb   $0097,$00CC
        fdb   $0092,$00D0
        fdb   $008D,$00D4
        fdb   $0088,$00D7
        fdb   $0083,$00DA
        fdb   $007D,$00DD
        fdb   $0078,$00E0
        fdb   $0072,$00E3
        fdb   $006D,$00E6
        fdb   $0067,$00E9
        fdb   $0061,$00EB
        fdb   $005B,$00ED
        fdb   $0055,$00F0
        fdb   $004F,$00F2
        fdb   $004A,$00F4
        fdb   $0044,$00F5
        fdb   $003D,$00F7
        fdb   $0037,$00F8
        fdb   $0031,$00FA
        fdb   $002B,$00FB
        fdb   $0025,$00FC
        fdb   $001F,$00FD
        fdb   $0018,$00FD
        fdb   $0012,$00FE
        fdb   $000C,$00FE
        fdb   $0006,$00FE
        fdb   $0000,$00FF
        fdb   $FFFA,$00FE
        fdb   $FFF4,$00FE
        fdb   $FFEE,$00FE
        fdb   $FFE8,$00FD
        fdb   $FFE1,$00FD
        fdb   $FFDB,$00FC
        fdb   $FFD5,$00FB
        fdb   $FFCF,$00FA
        fdb   $FFC9,$00F8
        fdb   $FFC3,$00F7
        fdb   $FFBC,$00F5
        fdb   $FFB6,$00F4
        fdb   $FFB1,$00F2
        fdb   $FFAB,$00F0
        fdb   $FFA5,$00ED
        fdb   $FF9F,$00EB
        fdb   $FF99,$00E9
        fdb   $FF93,$00E6
        fdb   $FF8E,$00E3
        fdb   $FF88,$00E0
        fdb   $FF83,$00DD
        fdb   $FF7D,$00DA
        fdb   $FF78,$00D7
        fdb   $FF73,$00D4
        fdb   $FF6E,$00D0
        fdb   $FF69,$00CC
        fdb   $FF64,$00C9
        fdb   $FF5F,$00C5
        fdb   $FF5A,$00C1
        fdb   $FF55,$00BC
        fdb   $FF51,$00B8
        fdb   $FF4C,$00B4
        fdb   $FF48,$00AF
        fdb   $FF44,$00AB
        fdb   $FF3F,$00A6
        fdb   $FF3B,$00A1
        fdb   $FF37,$009C
        fdb   $FF34,$0097
        fdb   $FF30,$0092
        fdb   $FF2C,$008D
        fdb   $FF29,$0088
        fdb   $FF26,$0083
        fdb   $FF23,$007D
        fdb   $FF20,$0078
        fdb   $FF1D,$0072
        fdb   $FF1A,$006D
        fdb   $FF17,$0067
        fdb   $FF15,$0061
        fdb   $FF13,$005B
        fdb   $FF10,$0055
        fdb   $FF0E,$004F
        fdb   $FF0C,$004A
        fdb   $FF0B,$0044
        fdb   $FF09,$003D
        fdb   $FF08,$0037
        fdb   $FF06,$0031
        fdb   $FF05,$002B
        fdb   $FF04,$0025
        fdb   $FF03,$001F
        fdb   $FF03,$0018
        fdb   $FF02,$0012
        fdb   $FF02,$000C
        fdb   $FF02,$0006
        fdb   $FF01,$0000
        fdb   $FF02,$FFFA
        fdb   $FF02,$FFF4
        fdb   $FF02,$FFEE
        fdb   $FF03,$FFE8
        fdb   $FF03,$FFE1
        fdb   $FF04,$FFDB
        fdb   $FF05,$FFD5
        fdb   $FF06,$FFCF
        fdb   $FF08,$FFC9
        fdb   $FF09,$FFC3
        fdb   $FF0B,$FFBC
        fdb   $FF0C,$FFB6
        fdb   $FF0E,$FFB1
        fdb   $FF10,$FFAB
        fdb   $FF13,$FFA5
        fdb   $FF15,$FF9F
        fdb   $FF17,$FF99
        fdb   $FF1A,$FF93
        fdb   $FF1D,$FF8E
        fdb   $FF20,$FF88
        fdb   $FF23,$FF83
        fdb   $FF26,$FF7D
        fdb   $FF29,$FF78
        fdb   $FF2C,$FF73
        fdb   $FF30,$FF6E
        fdb   $FF34,$FF69
        fdb   $FF37,$FF64
        fdb   $FF3B,$FF5F
        fdb   $FF3F,$FF5A
        fdb   $FF44,$FF55
        fdb   $FF48,$FF51
        fdb   $FF4C,$FF4C
        fdb   $FF51,$FF48
        fdb   $FF55,$FF44
        fdb   $FF5A,$FF3F
        fdb   $FF5F,$FF3B
        fdb   $FF64,$FF37
        fdb   $FF69,$FF34
        fdb   $FF6E,$FF30
        fdb   $FF73,$FF2C
        fdb   $FF78,$FF29
        fdb   $FF7D,$FF26
        fdb   $FF83,$FF23
        fdb   $FF88,$FF20
        fdb   $FF8E,$FF1D
        fdb   $FF93,$FF1A
        fdb   $FF99,$FF17
        fdb   $FF9F,$FF15
        fdb   $FFA5,$FF13
        fdb   $FFAB,$FF10
        fdb   $FFB1,$FF0E
        fdb   $FFB6,$FF0C
        fdb   $FFBC,$FF0B
        fdb   $FFC3,$FF09
        fdb   $FFC9,$FF08
        fdb   $FFCF,$FF06
        fdb   $FFD5,$FF05
        fdb   $FFDB,$FF04
        fdb   $FFE1,$FF03
        fdb   $FFE8,$FF03
        fdb   $FFEE,$FF02
        fdb   $FFF4,$FF02
        fdb   $FFFA,$FF02
        fdb   $0000,$FF01
        fdb   $0006,$FF02
        fdb   $000C,$FF02
        fdb   $0012,$FF02
        fdb   $0018,$FF03
        fdb   $001F,$FF03
        fdb   $0025,$FF04
        fdb   $002B,$FF05
        fdb   $0031,$FF06
        fdb   $0037,$FF08
        fdb   $003D,$FF09
        fdb   $0044,$FF0B
        fdb   $004A,$FF0C
        fdb   $004F,$FF0E
        fdb   $0055,$FF10
        fdb   $005B,$FF13
        fdb   $0061,$FF15
        fdb   $0067,$FF17
        fdb   $006D,$FF1A
        fdb   $0072,$FF1D
        fdb   $0078,$FF20
        fdb   $007D,$FF23
        fdb   $0083,$FF26
        fdb   $0088,$FF29
        fdb   $008D,$FF2C
        fdb   $0092,$FF30
        fdb   $0097,$FF34
        fdb   $009C,$FF37
        fdb   $00A1,$FF3B
        fdb   $00A6,$FF3F
        fdb   $00AB,$FF44
        fdb   $00AF,$FF48
        fdb   $00B4,$FF4C
        fdb   $00B8,$FF51
        fdb   $00BC,$FF55
        fdb   $00C1,$FF5A
        fdb   $00C5,$FF5F
        fdb   $00C9,$FF64
        fdb   $00CC,$FF69
        fdb   $00D0,$FF6E
        fdb   $00D4,$FF73
        fdb   $00D7,$FF78
        fdb   $00DA,$FF7D
        fdb   $00DD,$FF83
        fdb   $00E0,$FF88
        fdb   $00E3,$FF8E
        fdb   $00E6,$FF93
        fdb   $00E9,$FF99
        fdb   $00EB,$FF9F
        fdb   $00ED,$FFA5
        fdb   $00F0,$FFAB
        fdb   $00F2,$FFB1
        fdb   $00F4,$FFB6
        fdb   $00F5,$FFBC
        fdb   $00F7,$FFC3
        fdb   $00F8,$FFC9
        fdb   $00FA,$FFCF
        fdb   $00FB,$FFD5
        fdb   $00FC,$FFDB
        fdb   $00FD,$FFE1
        fdb   $00FD,$FFE8
        fdb   $00FE,$FFEE ; ...
        fdb   $00FE,$FFF4 ; 2
        fdb   $00FE,$FFFA ; 1
        fdb   $00FF,$0000 ; 0

CalcAngleUnitTestData2
        FDB   $04FA,$001F
        FDB   $04F9,$003E
        FDB   $04F7,$005D
        FDB   $04F4,$007C
        FDB   $04F1,$009C
        FDB   $04ED,$00BB
        FDB   $04E8,$00D9
        FDB   $04E2,$00F8
        FDB   $04DC,$0117
        FDB   $04D4,$0135
        FDB   $04CC,$0154
        FDB   $04C4,$0172
        FDB   $04BA,$018F
        FDB   $04B0,$01AD
        FDB   $04A5,$01CA
        FDB   $0499,$01E7
        FDB   $048D,$0204
        FDB   $0480,$0221
        FDB   $0472,$023D
        FDB   $0464,$0259
        FDB   $0455,$0274
        FDB   $0445,$028F
        FDB   $0435,$02AA
        FDB   $0424,$02C4
        FDB   $0412,$02DE
        FDB   $0400,$02F7
        FDB   $03ED,$0310
        FDB   $03D9,$0328
        FDB   $03C5,$0340
        FDB   $03B0,$0358
        FDB   $039B,$036F
        FDB   $0385,$0385
        FDB   $036F,$039B
        FDB   $0358,$03B0
        FDB   $0340,$03C5
        FDB   $0328,$03D9
        FDB   $0310,$03ED
        FDB   $02F7,$0400
        FDB   $02DE,$0412
        FDB   $02C4,$0424
        FDB   $02AA,$0435
        FDB   $028F,$0445
        FDB   $0274,$0455
        FDB   $0259,$0464
        FDB   $023D,$0472
        FDB   $0221,$0480
        FDB   $0204,$048D
        FDB   $01E7,$0499
        FDB   $01CA,$04A5
        FDB   $01AD,$04B0
        FDB   $018F,$04BA
        FDB   $0172,$04C4
        FDB   $0154,$04CC
        FDB   $0135,$04D4
        FDB   $0117,$04DC
        FDB   $00F8,$04E2
        FDB   $00D9,$04E8
        FDB   $00BB,$04ED
        FDB   $009C,$04F1
        FDB   $007C,$04F4
        FDB   $005D,$04F7
        FDB   $003E,$04F9
        FDB   $001F,$04FA
        FDB   $0000,$04FB
        FDB   $FFE1,$04FA
        FDB   $FFC2,$04F9
        FDB   $FFA3,$04F7
        FDB   $FF84,$04F4
        FDB   $FF64,$04F1
        FDB   $FF45,$04ED
        FDB   $FF27,$04E8
        FDB   $FF08,$04E2
        FDB   $FEE9,$04DC
        FDB   $FECB,$04D4
        FDB   $FEAC,$04CC
        FDB   $FE8E,$04C4
        FDB   $FE71,$04BA
        FDB   $FE53,$04B0
        FDB   $FE36,$04A5
        FDB   $FE19,$0499
        FDB   $FDFC,$048D
        FDB   $FDDF,$0480
        FDB   $FDC3,$0472
        FDB   $FDA7,$0464
        FDB   $FD8C,$0455
        FDB   $FD71,$0445
        FDB   $FD56,$0435
        FDB   $FD3C,$0424
        FDB   $FD22,$0412
        FDB   $FD09,$0400
        FDB   $FCF0,$03ED
        FDB   $FCD8,$03D9
        FDB   $FCC0,$03C5
        FDB   $FCA8,$03B0
        FDB   $FC91,$039B
        FDB   $FC7B,$0385
        FDB   $FC65,$036F
        FDB   $FC50,$0358
        FDB   $FC3B,$0340
        FDB   $FC27,$0328
        FDB   $FC13,$0310
        FDB   $FC00,$02F7
        FDB   $FBEE,$02DE
        FDB   $FBDC,$02C4
        FDB   $FBCB,$02AA
        FDB   $FBBB,$028F
        FDB   $FBAB,$0274
        FDB   $FB9C,$0259
        FDB   $FB8E,$023D
        FDB   $FB80,$0221
        FDB   $FB73,$0204
        FDB   $FB67,$01E7
        FDB   $FB5B,$01CA
        FDB   $FB50,$01AD
        FDB   $FB46,$018F
        FDB   $FB3C,$0172
        FDB   $FB34,$0154
        FDB   $FB2C,$0135
        FDB   $FB24,$0117
        FDB   $FB1E,$00F8
        FDB   $FB18,$00D9
        FDB   $FB13,$00BB
        FDB   $FB0F,$009C
        FDB   $FB0C,$007C
        FDB   $FB09,$005D
        FDB   $FB07,$003E
        FDB   $FB06,$001F
        FDB   $FB05,$0000
        FDB   $FB06,$FFE1
        FDB   $FB07,$FFC2
        FDB   $FB09,$FFA3
        FDB   $FB0C,$FF84
        FDB   $FB0F,$FF64
        FDB   $FB13,$FF45
        FDB   $FB18,$FF27
        FDB   $FB1E,$FF08
        FDB   $FB24,$FEE9
        FDB   $FB2C,$FECB
        FDB   $FB34,$FEAC
        FDB   $FB3C,$FE8E
        FDB   $FB46,$FE71
        FDB   $FB50,$FE53
        FDB   $FB5B,$FE36
        FDB   $FB67,$FE19
        FDB   $FB73,$FDFC
        FDB   $FB80,$FDDF
        FDB   $FB8E,$FDC3
        FDB   $FB9C,$FDA7
        FDB   $FBAB,$FD8C
        FDB   $FBBB,$FD71
        FDB   $FBCB,$FD56
        FDB   $FBDC,$FD3C
        FDB   $FBEE,$FD22
        FDB   $FC00,$FD09
        FDB   $FC13,$FCF0
        FDB   $FC27,$FCD8
        FDB   $FC3B,$FCC0
        FDB   $FC50,$FCA8
        FDB   $FC65,$FC91
        FDB   $FC7B,$FC7B
        FDB   $FC91,$FC65
        FDB   $FCA8,$FC50
        FDB   $FCC0,$FC3B
        FDB   $FCD8,$FC27
        FDB   $FCF0,$FC13
        FDB   $FD09,$FC00
        FDB   $FD22,$FBEE
        FDB   $FD3C,$FBDC
        FDB   $FD56,$FBCB
        FDB   $FD71,$FBBB
        FDB   $FD8C,$FBAB
        FDB   $FDA7,$FB9C
        FDB   $FDC3,$FB8E
        FDB   $FDDF,$FB80
        FDB   $FDFC,$FB73
        FDB   $FE19,$FB67
        FDB   $FE36,$FB5B
        FDB   $FE53,$FB50
        FDB   $FE71,$FB46
        FDB   $FE8E,$FB3C
        FDB   $FEAC,$FB34
        FDB   $FECB,$FB2C
        FDB   $FEE9,$FB24
        FDB   $FF08,$FB1E
        FDB   $FF27,$FB18
        FDB   $FF45,$FB13
        FDB   $FF64,$FB0F
        FDB   $FF84,$FB0C
        FDB   $FFA3,$FB09
        FDB   $FFC2,$FB07
        FDB   $FFE1,$FB06
        FDB   $0000,$FB05
        FDB   $001F,$FB06
        FDB   $003E,$FB07
        FDB   $005D,$FB09
        FDB   $007C,$FB0C
        FDB   $009C,$FB0F
        FDB   $00BB,$FB13
        FDB   $00D9,$FB18
        FDB   $00F8,$FB1E
        FDB   $0117,$FB24
        FDB   $0135,$FB2C
        FDB   $0154,$FB34
        FDB   $0172,$FB3C
        FDB   $018F,$FB46
        FDB   $01AD,$FB50
        FDB   $01CA,$FB5B
        FDB   $01E7,$FB67
        FDB   $0204,$FB73
        FDB   $0221,$FB80
        FDB   $023D,$FB8E
        FDB   $0259,$FB9C
        FDB   $0274,$FBAB
        FDB   $028F,$FBBB
        FDB   $02AA,$FBCB
        FDB   $02C4,$FBDC
        FDB   $02DE,$FBEE
        FDB   $02F7,$FC00
        FDB   $0310,$FC13
        FDB   $0328,$FC27
        FDB   $0340,$FC3B
        FDB   $0358,$FC50
        FDB   $036F,$FC65
        FDB   $0385,$FC7B
        FDB   $039B,$FC91
        FDB   $03B0,$FCA8
        FDB   $03C5,$FCC0
        FDB   $03D9,$FCD8
        FDB   $03ED,$FCF0
        FDB   $0400,$FD09
        FDB   $0412,$FD22
        FDB   $0424,$FD3C
        FDB   $0435,$FD56
        FDB   $0445,$FD71
        FDB   $0455,$FD8C
        FDB   $0464,$FDA7
        FDB   $0472,$FDC3
        FDB   $0480,$FDDF
        FDB   $048D,$FDFC
        FDB   $0499,$FE19
        FDB   $04A5,$FE36
        FDB   $04B0,$FE53
        FDB   $04BA,$FE71
        FDB   $04C4,$FE8E
        FDB   $04CC,$FEAC
        FDB   $04D4,$FECB
        FDB   $04DC,$FEE9
        FDB   $04E2,$FF08
        FDB   $04E8,$FF27
        FDB   $04ED,$FF45
        FDB   $04F1,$FF64
        FDB   $04F4,$FF84
        FDB   $04F7,$FFA3
        FDB   $04F9,$FFC2
        FDB   $04FA,$FFE1
        FDB   $04FB,$0000

Mul9x16UnitTestData
        fdb   $0031,$FFDC ; $FFF9
        fdb   $FF23,$00AB ; $FF6C
        fdb   $0031,$0ADC ; $0214
        fdb   $FF23,$FFDC ; $001F
        fdb   $FF00,$FFDC ; $0024
        fdb   $0100,$FFDC ; $FFDC
        fdb   $FF00,$DEDC ; $2124
        fdb   $0100,$DEDC ; $DEDC

        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/math/CalcAngle.asm"
        INCLUDE "./engine/math/Mul9x16.asm"