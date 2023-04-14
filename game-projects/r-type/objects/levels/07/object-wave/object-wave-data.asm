;$00,$00,ObjID_25,$00,$04
;$00,$00,ObjID_1,$00,$00
;$00,$C8,ObjID_13,$00,$0A
;$01,$90,ObjID_13,$00,$00
	;fcb   $02,$06,ObjID_pow,$00,$35 ; original data
        fcb   $02,$06,ObjID_pow,$00,$45 ; test (to remove)
        fcb   $02,$0A,ObjID_pow,$00,$45 ; test (to remove)
        fcb   $02,$0E,ObjID_pow,$00,$45 ; test (to remove)
;$02,$58,ObjID_13,$00,$01
;$03,$20,ObjID_13,$00,$07
;$03,$D4,ObjID_13,$00,$01
;$04,$4C,ObjID_13,$00,$02
;$04,$56,ObjID_13,$00,$00
;$04,$60,ObjID_13,$00,$0E
;$05,$3C,ObjID_13,$00,$07
;$05,$3C,ObjID_13,$00,$05
;$05,$C8,ObjID_13,$00,$02
;$06,$40,ObjID_13,$00,$01
;$06,$54,ObjID_15,$00,$00
;$06,$68,ObjID_13,$00,$03
;$06,$E0,ObjID_36,$00,$01
;$07,$08,ObjID_13,$00,$00
;$07,$DA,ObjID_13,$00,$03
;$07,$E4,ObjID_13,$00,$0C
	;fcb   $08,$20,ObjID_pow,$00,$14
;$08,$34,ObjID_13,$00,$03
;$08,$B4,ObjID_36,$00,$00
;$09,$10,ObjID_13,$00,$00
;$09,$4C,ObjID_13,$00,$02
;$0A,$3C,ObjID_13,$00,$01
;$0A,$50,ObjID_13,$00,$04
;$0A,$80,ObjID_0,$00,$05
;$0A,$BC,ObjID_13,$00,$07
;$0A,$F0,ObjID_13,$00,$01
;$0B,$98,ObjID_13,$00,$02
;$0C,$58,ObjID_13,$00,$02
;$0D,$48,ObjID_13,$00,$03
	;fcb   $0D,$B4,ObjID_pow,$00,$06
;$0E,$10,ObjID_13,$00,$02
;$0E,$10,ObjID_13,$00,$00
;$0E,$7C,ObjID_13,$00,$01
;$0E,$88,ObjID_29,$00,$04
	;fcb   $0F,$64,ObjID_pow,$00,$07
	fcb   $13,$60,ObjID_bossmusic,$00,$00
;$13,$60,ObjID_39,$00,$00
;$14,$80,ObjID_28,$00,$00
;$14,$FC,ObjID_40,$00,$00

	fdb   $FFFF
