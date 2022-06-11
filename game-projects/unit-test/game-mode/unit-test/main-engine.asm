        opt   c,ct

********************************************************************************
* Game Engine (TO8 Thomson) - Benoit Rousseau 2020-2021
* ------------------------------------------------------------------------------
*
*
********************************************************************************

        INCLUDE "./Engine/Constants.asm"
        INCLUDE "./Engine/Macros.asm"        	
        org   $6100
        SETDP $9F

CalcAngleUnitTest
        ldu   #CalcAngleUnitTestData ; read test data
        ldy   #CalcAngleUnitTestData ; write debug 
@a      pulu  d,x
        jsr   CalcAngle
        sta   ,y+                    ; write angle
        cmpu  #CalcAngleUnitTestData+1024+32+4
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

Mul9x16UnitTestData
        fdb   $0031,$FFDC ; $FFF9
        fdb   $FF23,$00AB ; $FF6C
        fdb   $0031,$0ADC ; $0214
        fdb   $FF23,$FFDC ; $001F
        fdb   $FF00,$FFDC ; $0024
        fdb   $0100,$FFDC ; $FFDC
        fdb   $FF00,$DEDC ; $2124
        fdb   $0100,$DEDC ; $DEDC

        INCLUDE "./Engine/Math/CalcAngle.asm"
        INCLUDE "./Engine/Math/Mul9x16.asm"