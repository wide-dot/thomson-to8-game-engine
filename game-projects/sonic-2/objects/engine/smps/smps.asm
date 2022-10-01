; ---------------------------------------------------------------------------	fdb   
; Object - Smps Sound player
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/sound/SmpsObj.asm"

Song_Index
        fdb   0
        fdb   Song_EHZ

Song_EHZ
        ;INCLUDEBIN "./objects/engine/smps/songs/1-00 Continue.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-00 Casino Night Zone (2P).smp"
        INCLUDEBIN "./objects/engine/smps/songs/2-01 Emerald Hill Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-02 Metropolis Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-03 Casino Night Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-04 Mystic Cave Zone.1380.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-05 Mystic Cave Zone (2P).1380.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-06 Aquatic Ruin Zone.1380.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-07 Death Egg Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-08 Special Stage.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-09 Option Screen.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-0A Sweet Sweet Sweet (Ending).smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-0B Final Boss.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-0C Chemical Plant Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-0D Boss.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-0E Sky Chase Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-0F Oil Ocean Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-10 Wing Fortress Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-11 Emerald Hill Zone (2P).smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-12 2P Results Screen.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-13 Super Sonic.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-14 Hill Top Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-16 Title Screen.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-17 Act Clear.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-19 Invincibility.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-1B Hidden Palace Zone.smp"
        ;INCLUDEBIN "./objects/engine/smps/songs/2-1C Drowning.smp"

Sound_Index
                        fdb   0
SndPtr_Jump             fdb   Sound20 ; jumping sound
SndPtr_Checkpoint       fdb   Sound21 ; checkpoint ding-dong sound
SndPtr_SpikeSwitch      fdb   Sound22 ; spike switch sound
SndPtr_Hurt             fdb   Sound23 ; hurt sound
SndPtr_Skidding         fdb   Sound24 ; skidding sound
SndPtr_BlockPush        fdb   Sound25 ; block push sound
SndPtr_HurtBySpikes     fdb   Sound26 ; spiky impalement sound
SndPtr_Sparkle          fdb   Sound27 ; sparkling sound
SndPtr_Beep             fdb   Sound28 ; short beep
SndPtr_Bwoop            fdb   Sound29 ; bwoop (unused)
SndPtr_Splash           fdb   Sound2A ; splash sound
SndPtr_Swish            fdb   Sound2B ; swish
SndPtr_BossHit          fdb   Sound2C ; boss hit
SndPtr_InhalingBubble   fdb   Sound2D ; inhaling a bubble
SndPtr_ArrowFiring 
SndPtr_LavaBall         fdb   Sound2E ; arrow firing
SndPtr_Shield           fdb   Sound2F ; shield sound
SndPtr_LaserBeam        fdb   Sound30 ; laser beam
SndPtr_Zap              fdb   Sound31 ; zap (unused)
SndPtr_Drown            fdb   Sound32 ; drownage
SndPtr_FireBurn         fdb   Sound33 ; fire + burn
SndPtr_Bumper           fdb   Sound34 ; bumper bing
SndPtr_Ring 
SndPtr_RingRight        fdb   Sound35 ; ring sound
SndPtr_SpikesMove       fdb   Sound36
SndPtr_Rumbling         fdb   Sound37 ; rumbling
                        fdb   Sound38 ; (unused)
SndPtr_Smash            fdb   Sound39 ; smash/breaking
                        fdb   Sound3A ; nondescript ding (unused)
SndPtr_DoorSlam         fdb   Sound3B ; door slamming shut
SndPtr_SpindashRelease  fdb   Sound3C ; spindash unleashed
SndPtr_Hammer           fdb   Sound3D ; slide-thunk
SndPtr_Roll             fdb   Sound3E ; rolling sound
SndPtr_ContinueJingle   fdb   Sound3F ; got continue
SndPtr_CasinoBonus      fdb   Sound40 ; short bonus ding
SndPtr_Explosion        fdb   Sound41 ; badnik bust
SndPtr_WaterWarning     fdb   Sound42 ; warning ding-ding
SndPtr_EnterGiantRing   fdb   Sound43 ; special stage ring flash (mostly unused)
SndPtr_BossExplosion    fdb   Sound44 ; thunk
SndPtr_TallyEnd         fdb   Sound45 ; cha-ching
SndPtr_RingSpill        fdb   Sound46 ; losing rings
                        fdb   Sound47 ; chain pull chink-chink (unused)
SndPtr_Flamethrower     fdb   Sound48 ; flamethrower
SndPtr_Bonus            fdb   Sound49 ; bonus pwoieeew (mostly unused)
SndPtr_SpecStageEntry   fdb   Sound4A ; special stage entry
SndPtr_SlowSmash        fdb   Sound4B ; slower smash/crumble
SndPtr_Spring           fdb   Sound4C ; spring boing
SndPtr_Blip             fdb   Sound4D ; selection blip
SndPtr_RingLeft         fdb   Sound4E ; another ring sound (only plays in the left speaker?)
SndPtr_Signpost         fdb   Sound4F ; signpost spin sound
SndPtr_CNZBossZap       fdb   Sound50 ; mosquito zapper
                        fdb   Sound51 ; (unused)
                        fdb   Sound52 ; (unused)
SndPtr_Signpost2P       fdb   Sound53
SndPtr_OOZLidPop        fdb   Sound54 ; OOZ lid pop sound
SndPtr_SlidingSpike     fdb   Sound55
SndPtr_CNZElevator      fdb   Sound56
SndPtr_PlatformKnock    fdb   Sound57
SndPtr_BonusBumper      fdb   Sound58 ; CNZ bonusy bumper sound
SndPtr_LargeBumper      fdb   Sound59 ; CNZ baaang bumper sound
SndPtr_Gloop            fdb   Sound5A ; CNZ gloop / water droplet sound
SndPtr_PreArrowFiring   fdb   Sound5B
SndPtr_Fire             fdb   Sound5C
SndPtr_ArrowStick       fdb   Sound5D ; chain clink
SndPtr_Helicopter 
SndPtr_WingFortress     fdb   Sound5E ; helicopter
SndPtr_SuperTransform   fdb   Sound5F
SndPtr_SpindashRev      fdb   Sound60 ; spindash charge
SndPtr_Rumbling2        fdb   Sound61 ; rumbling
SndPtr_CNZLaunch        fdb   Sound62
SndPtr_Flipper          fdb   Sound63 ; CNZ blooing bumper
SndPtr_HTZLiftClick     fdb   Sound64 ; HTZ track click sound
SndPtr_Leaves           fdb   Sound65 ; kicking up leaves sound
SndPtr_MegaMackDrop     fdb   Sound66 ; leaf splash?
SndPtr_DrawbridgeMove   fdb   Sound67
SndPtr_QuickDoorSlam    fdb   Sound68 ; door slamming quickly (unused)
SndPtr_DrawbridgeDown   fdb   Sound69
SndPtr_LaserBurst       fdb   Sound6A ; robotic laser burst
SndPtr_Scatter 
SndPtr_LaserFloor       fdb   Sound6B ; scatter
SndPtr_Teleport         fdb   Sound6C
SndPtr_Error            fdb   Sound6D ; error sound
SndPtr_MechaSonicBuzz   fdb   Sound6E ; silver sonic buzz saw
SndPtr_LargeLaser       fdb   Sound6F
SndPtr_OilSlide         fdb   Sound70

; jumping sound
Sound20         fdb   $0000,$0101
                fdb   $8080,@a-Sound20,$F400
@a              fcb   $F5,$00,$9E,$05,$F0,$02,$01,$F8,$65,$A3,$15,$F2

; checkpoint ding-dong sound
Sound21         fdb   ssamp21-Sound21,$0101
                fdb   $8005,@a-Sound21,$0001
ssamp21         fcb   $3C,$05,$0A,$01,$01,$56,$5C,$5C,$5C,$0E,$11,$11
                fcb   $11,$09,$06,$0A,$0A,$4F,$3F,$3F,$3F,$17,$20,$80,$80
@a              fcb   $EF,$00,$BD,$06,$BA,$16,$F2

; spike switch sound
Sound22         fdb   $0000,$0101
                fdb   $80C0,@a-Sound22,$0000
@a              fcb   $F0,$01,$01,$F0,$08,$F3,$E7,$C0,$04,$CA,$04
@b              fcb   $C0,$01,$EC
                fdb   $01F7,$0006
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2

; hurt sound
Sound23         fdb   ssamp23-Sound23,$0101
                fdb   $8005,@a-Sound23,$F400
@a              fcb   $EF,$00,$B0,$07,$E7,$AD
@b              fcb   $01,$E6
                fdb   $01F7,$002F,@b-Sound23
                fcb   $F2
ssamp23         fcb   $30,$30,$30,$30,$30,$9E,$DC,$D8,$DC,$0E,$04,$0A
                fcb   $05,$08,$08,$08,$08,$BF,$BF,$BF,$BF,$14,$14,$3C,$80

; skidding sound
Sound24         fdb   $0000,$0102 ; sound header... no sample and 2 script entries
                fdb   $80A0,@a-Sound24,$F400 ; entry 1 header
                fdb   $80C0,@b-Sound24,$F400 ; entry 2 header
@a              fcb   $F5,$00,$AF,$01,$80,$AF,$80,$03 ; script entry 1
@c              fcb   $AF,$01,$80
                fdb   $01F7,$000B
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2 ; script 1 end
@b              fcb   $F5,$00,$80,$01,$AD,$80,$AD,$80,$03 ; script entry 2
@d              fcb   $AD,$01,$80
                fdb   $01F7,$000B
@lb2            fdb   @d-@lb2 ; loopback
                fcb   $F2 ; script 2 end

; block push sound
Sound25         fdb   ssamp25-Sound25,$0101
                fdb   $8005,@a-Sound25,$0000
@a              fcb   $EF,$00,$80,$01,$8B,$0A,$80,$02,$F2
ssamp25         fcb   $FA,$21,$10,$30,$32,$2F,$2F,$1F,$2F,$05,$09,$08
                fcb   $02,$06,$06,$0F,$02,$1F,$4F,$2F,$2F,$0F,$0E,$1A,$80

; spiky impalement sound
Sound26         fdb   ssamp26-ssamp26,$0101
                fdb   $8005,@a-Sound26,$F200
@a              fcb   $EF,$00,$F0,$01,$01,$10,$FF,$CF,$05,$D7,$25,$F2
ssamp26         fcb   $3B,$3C,$30,$39,$31,$DF,$1F,$1F,$DF,$04,$04,$05
                fcb   $01,$04,$04,$04,$02,$FF,$1F,$0F,$AF,$29,$0F,$20,$80

; sparkling sound
Sound27         fdb   ssamp27-Sound27,$0101
                fdb   $8004,@a-Sound27,$0C1C
@a              fcb   $EF,$00,$C1,$05,$C4,$05,$C9,$2B,$F2
ssamp27         fcb   $E1,$00
;ssamp27         fcb   $07,$73,$33,$33,$73,$0F,$19,$14,$1A,$0A,$0A,$0A
;                fcb   $0A,$0A,$0A,$0A,$0A,$57,$57,$57,$57,$00,$00,$00,$00

; short beep
Sound28         fdb   $0000,$0101
                fdb   $8080,@a-Sound28,$E803
@a              fcb   $F5,$04,$CB,$04,$F2

; bwoop (unused)
Sound29         fdb   $0000,$0101
                fdb   $80A0,@a-Sound29,$0000
@a              fcb   $F0,$01,$01,$E6,$35,$8E,$06,$F2

; splash sound
Sound2A         fdb   ssamp2A-Sound2A,$0102
                fdb   $80C0,@a-Sound2A,$0000
                fdb   $8005,@b-Sound2A,$0003
@a              fcb   $F5,$00,$F3,$E7,$C2,$05,$C6,$05,$E7
@c              fcb   $07,$EC,$01
                fdb   $E7F7,$000F
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2
@b              fcb   $EF,$00,$A6,$14,$F2
ssamp2A         fcb   $00,$00,$02,$03,$00,$D9,$1F,$DF,$1F,$12,$14,$11
                fcb   $0F,$0A,$0A,$00,$0D,$FF,$FF,$FF,$FF,$22,$27,$07,$80

; swish
Sound2B         fdb   $0000,$0101
                fdb   $80C0,@a-Sound2B,$0000
@a              fcb   $F5,$00,$F3,$E7,$C6,$03,$80,$03,$C6,$01,$E7
@b              fcb   $01,$EC,$01
                fdb   $E7F7,$0015
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2

; boss hit
Sound2C         fdb   smashsamp-Sound2C,$0101
                fdb   $8005,@a-Sound2C,$0000
@a              fcb   $EF,$00,$F0,$01,$01,$0C,$01
@b              fcb   $81,$0A,$E6
                fdb   $10F7,$0004
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2
smashsamp       fcb   $F9,$21,$10,$30,$32,$1F,$1F,$1F,$1F,$05,$09,$18
                fcb   $02,$0B,$10,$1F,$05,$1F,$4F,$2F,$2F,$0E,$04,$07,$80

; inhaling a bubble
Sound2D         fdb   ssamp2D-Sound2D,$0101
                fdb   $8005,@a-Sound2D,$0E00
@a              fcb   $EF,$00,$F0,$01,$01,$21,$6E,$A6,$07
                fcb   $80,$06,$F0,$01,$01,$44,$1E,$AD,$08,$F2
ssamp2D         fcb   $35,$05,$08,$09,$07,$1E,$0D,$0D,$0E,$0C,$03,$15
                fcb   $06,$16,$09,$0E,$10,$2F,$1F,$2F,$1F,$15,$12,$12,$80

; arrow firing
Sound2E         fdb   ssamp2E-Sound2E,$0102
                fdb   $8005,@a-Sound2E,$0000
                fdb   $80C0,@b-Sound2E,$0000
@a              fcb   $EF,$00,$80,$01,$F0,$01,$01,$40,$48,$83,$06,$85,$02,$F2
@b              fcb   $F5,$00,$80,$0B,$F3,$E7,$C6,$01,$E7
@c              fcb   $02,$EC,$01
                fdb   $E7F7,$0010
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2
ssamp2E         fcb   $FA,$02,$00,$03,$05,$12,$0F,$11,$13,$05,$09,$18
                fcb   $02,$06,$06,$0F,$02,$1F,$4F,$2F,$2F,$2F,$0E,$1A,$80

; shield sound
Sound2F         fdb   ssamp2F-Sound2F,$0101
                fdb   $8005,@a-Sound2F,$0C00
@a              fcb   $EF,$00,$80,$01,$A3,$05,$E7,$A4,$26,$F2
ssamp2F         fcb   $30,$30,$30,$30,$30,$9E,$AC,$A8,$DC,$0E,$04,$0A
                fcb   $05,$08,$08,$08,$08,$BF,$BF,$BF,$BF,$04,$14,$2C,$80

; laser beam
Sound30         fdb   ssamp30-Sound30,$0101 ; sound header... a voice and 1 script entry
                fdb   $8005,@a-Sound30,$FB05 ; script entry header
@a              fcb   $EF,$00,$DF,$7F ; script start
@b              fcb   $DF,$02,$E6 ; script continued
                fdb   $01F7,$001B
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2 ; script end
ssamp30         fcb   $83,$1F,$1F,$15,$1F,$1F,$1F,$1F,$1F,$00,$00,$00 ; voice
                fcb   $00,$02,$02,$02,$02,$2F,$FF,$2F,$3F,$0B,$01,$16,$82 ; (fixed length)

; zap (unused)
Sound31         fdb   ssamp31-Sound31,$0101
                fdb   $8005,@a-Sound31,$FB02
@a              fcb   $EF,$00,$B3,$05,$80,$01,$B3,$09,$F2
ssamp31         fcb   $83,$12,$13,$10,$1E,$1F,$1F,$1F,$1F,$00,$00,$00
                fcb   $00,$02,$02,$02,$02,$2F,$FF,$2F,$3F,$05,$34,$10,$87

; drownage
Sound32         fdb   ssamp32-Sound32,$0102
                fdb   $8004,@b-Sound32,$0C04
                fdb   $8005,@a-Sound32,$0E02
@a              fcb   $EF,$00,$F0,$01,$01,$83,$0C
@c              fcb   $8A,$05,$05,$E6
                fdb   $03F7,$000A
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2
@b              fcb   $80,$06,$EF,$00,$F0,$01,$01,$6F,$0E
@d              fcb   $8D,$04,$05,$E6
                fdb   $03F7,$000A
@lb2            fdb   @d-@lb2 ; loopback
                fcb   $F2
ssamp32         fcb   $35,$14,$04,$1A,$09,$0E,$11,$10,$0E,$0C,$03,$15
                fcb   $06,$16,$09,$0E,$10,$2F,$4F,$2F,$4F,$2F,$12,$12,$80

; fire @aburn
Sound33         fdb   ssamp2E-Sound33,$0102
                fdb   $8005,@a-Sound33,$0000
                fdb   $80C0,@b-Sound33,$0000
@a              fcb   $EF,$00,$80,$01,$F0,$01,$01,$40,$48,$83,$06,$85,$02,$F2
@b              fcb   $F5,$00,$80,$0B,$F3,$E7,$A7,$25,$E7
@c              fcb   $02,$EC,$01
                fdb   $E7F7,$0010
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2

; bumper bing
Sound34         fdb   ssamp34-Sound34,$0103
                fdb   $8005,@a-Sound34,$0000
                fdb   $8004,@b-Sound34,$0000
                fdb   $8002,@c-Sound34,$0002
@a              fcb   $EF,$00,$F6
@jp1            fdb   Sound34_3-@jp1
@b              fcb   $EF,$00,$E1,$07,$80,$01
Sound34_3 
                fcb   $BA,$20,$F2
@c              fcb   $EF,$01,$9A,$03,$F2
ssamp34         fcb   $3C,$05,$0A,$01,$01,$56,$5C,$5C,$5C,$0E,$11,$11
                fcb   $11,$09,$06,$0A,$0A,$4F,$3F,$3F,$3F,$1F,$2B,$80,$80
                fcb   $05,$00,$00,$00,$00,$1F,$1F,$1F,$1F,$12,$0C,$0C
                fcb   $0C,$12,$08,$08,$08,$1F,$5F,$5F,$5F,$07,$80,$80,$80

; ring sound
Sound35         fdb   ringsamp-Sound35,$0101
                fdb   $8005,@a-Sound35,$0005
@a              fcb   $EF,$00,$E0,$40,$C1,$05,$C4,$05,$C9,$1B,$F2


Sound36         fdb   $0000,$0101
                fdb   $80C0,@a-Sound36,$0000
@a              fcb   $F0,$01,$01,$F0,$08,$F3,$E7,$C1,$07
@b              fcb   $D0,$01,$EC
                fdb   $01F7,$000C
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2

; rumbling
Sound37         fdb   ssamp37-Sound37,$0101
                fdb   $8005,@a-Sound37,$0000
@a              fcb   $EF,$00,$F0,$01,$01,$20,$08
@b              fcb   $8B
                fdb   $0AF7,$0008
@lb1            fdb   @b-@lb1 ; loopback
@c              fcb   $8B,$10,$E6
                fdb   $03F7,$0009
@lb2            fdb   @c-@lb2 ; loopback
                fcb   $F2
ssamp37         fcb   $FA,$21,$10,$30,$32,$1F,$1F,$1F,$1F,$05,$09,$18
                fcb   $02,$06,$06,$0F,$02,$1F,$4F,$2F,$2F,$0F,$0E,$1A,$80

; (unused)
Sound38         fdb   $0000,$0101
                fdb   $80C0,@a-Sound38,$0000
@a              fcb   $F0,$01,$01,$F0,$08,$F3,$E7,$B4,$08
@b              fcb   $B0,$02,$EC
                fdb   $01F7,$0003
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2

; smash/breaking
Sound39         fdb   smashsamp-Sound39,$0104
                fdb   $8002,@a-Sound39,$1000
                fdb   $8004,@c-Sound39,$0000
                fdb   $8005,@b-Sound39,$1000
                fdb   $80C0,s39s4-Sound39,$0000
@a              fcb   $E0,$40,$80,$02,$F6
@jp1            fdb   @c-@jp1
@b              fcb   $E0,$80,$80,$01
@c              fcb   $EF,$00,$F0,$03,$01,$20,$04
@d              fcb   $81,$18,$E6
                fdb   $0AF7,$0006
@lb1            fdb   @d-@lb1 ; loopback
                fcb   $F2
s39s4           fcb   $F0,$01,$01,$0F,$05,$F3,$E7
@e              fcb   $B0,$18,$E7,$EC
                fdb   $03F7,$0005
@lb2            fdb   @e-@lb2 ; loopback
                fcb   $F2

; nondescript ding (unused)
Sound3A         fdb   ssamp3A-Sound3A,$0101
                fdb   $8005,@a-Sound3A,$0007
@a              fcb   $EF,$00,$AE,$08,$F2
ssamp3A         fcb   $1C,$2E,$0F,$02,$02,$1F,$1F,$1F,$1F,$18,$14,$0F
                fcb   $0E,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$20,$1B,$80,$80

; door slamming shut
Sound3B         fdb   ssamp3B-Sound3B,$0101
                fdb   $8005,@a-Sound3B,$F400
@a              fcb   $EF,$00,$9B,$04,$80,$A0,$06,$F2
ssamp3B         fcb   $3C,$00,$00,$00,$00,$1F,$1F,$1F,$1F,$00,$0F,$16
                fcb   $0F,$00,$00,$00,$00,$0F,$FF,$AF,$FF,$00,$0A,$80,$80

; spindash unleashed
Sound3C         fdb   ssamp3C-Sound3C,$0102
                fdb   $8005,@a-Sound3C,$9000
                fdb   $80C0,@b-Sound3C,$0000
@a              fcb   $EF,$00,$F0,$01,$01,$C5,$1A,$CD,$07,$F2
@b              fcb   $F5,$07,$80,$07,$F0,$01,$02,$05,$FF,$F3,$E7,$BB,$4F,$F2
ssamp3C         fcb   $C2,$00
;ssamp3C         fcb   $FD,$09,$00,$03,$00,$1F,$1F,$1F,$1F,$10,$0C,$0C
;                fcb   $0C,$0B,$10,$1F,$05,$1F,$4F,$2F,$2F,$09,$92,$84,$8E

; slide-thunk
Sound3D         fdb   ssamp3D-Sound3D,$0102
                fdb   $8005,@a-Sound3D,$100A
                fdb   $8004,@b-Sound3D,$0000
@a              fcb   $EF,$00,$F0,$01,$01,$60,$01,$A7,$08,$F2
@b              fcb   $80,$08,$EF,$01,$84,$22,$F2
ssamp3D         fcb   $FA,$21,$19,$3A,$30,$1F,$1F,$1F,$1F,$05,$09,$18
                fcb   $02,$0B,$10,$1F,$05,$1F,$4F,$2F,$2F,$0E,$04,$07,$80
                fcb   $FA,$31,$10,$30,$32,$1F,$1F,$1F,$1F,$05,$05,$18
                fcb   $10,$0B,$10,$1F,$10,$1F,$1F,$2F,$2F,$0D,$01,$00,$80

; rolling sound
Sound3E         fdb   ssamp3E-Sound3E,$0101
                fdb   $8004,@a-Sound3E,$0C05
@a              fcb   $EF,$00,$80,$01,$F0,$03,$01,$09,$FF,$CA,$25,$F4
@b              fcb   $E7,$E6,$01,$D0
                fdb   $02F7,$002A
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2
ssamp3E         fcb   $10,$0C
;ssamp3E         fcb   $3C,$00,$02,$44,$02,$1F,$1F,$1F,$15,$00,$00,$1F
;                fcb   $00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$0D,$28,$00,$00

; got continue
Sound3F         fdb   ssamp3F-Sound3F,$0103
                fdb   $8002,@a-Sound3F,$F406
                fdb   $8004,@b-Sound3F,$F406
                fdb   $8005,@c-Sound3F,$F406
@a              fcb   $EF,$00,$C9,$07,$CD,$D0,$CB,$CE,$D2,$CD,$D0,$D4,$CE,$D2,$D5
@d              fcb   $D0,$07,$D4,$D7,$E6
                fdb   $05F7,$0008
@lb1            fdb   @d-@lb1 ; loopback
                fcb   $F2
@b              fcb   $EF,$00,$E1,$01,$80,$07,$CD,$15,$CE,$D0,$D2
@e              fcb   $D4,$15,$E6
                fdb   $05F7,$0008
@lb2            fdb   @e-@lb2 ; loopback
                fcb   $F2
@c              fcb   $EF,$00,$E1,$01,$C9,$15,$CB,$CD,$CE
@f              fcb   $D0,$15,$E6
                fdb   $05F7,$0008
@lb3            fdb   @f-@lb3 ; loopback
                fcb   $F2
ssamp3F         fcb   $14,$25,$36,$33,$11,$1F,$1F,$1F,$1F,$15,$1C,$18
                fcb   $13,$0B,$0D,$08,$09,$0F,$8F,$9F,$0F,$24,$0A,$05,$80

; short bonus ding
Sound40         fdb   ssamp3F-Sound40,$0102
                fdb   $8005,@b-Sound40,$0008
                fdb   $8004,@a-Sound40,$0008
@a              fcb   $E1,$03,$80,$02
@b              fcb   $EF,$00,$C4,$16,$F2

; badnik bust
Sound41         fdb   ssamp41-Sound41,$0102
                fdb   $8005,@a-Sound41,$0000
                fdb   $80C0,@b-Sound41,$0002
@a              fcb   $F0,$03,$01,$72,$0B,$EF,$00,$BA,$16,$F2
@b              fcb   $F5,$01,$F3,$E7,$B0,$1B,$F2
ssamp41         fcb   $3C,$0F,$03,$01,$01,$1F,$1F,$1F,$1F,$19,$19,$12
                fcb   $0E,$05,$00,$12,$0F,$0F,$FF,$7F,$FF,$00,$00,$80,$80

; warning ding-ding
Sound42         fdb   ssamp3F-Sound42,$0101
                fdb   $8005,@a-Sound42,$0C08
@a              fcb   $EF,$00,$BA,$08,$BA,$25,$F2

; special stage ring flash (mostly unused)
Sound43         fdb   ssamp43-Sound43,$0102
                fdb   $8004,@a-Sound43,$0C00
                fdb   $8005,@b-Sound43,$0013
@a              fcb   $EF,$01,$80,$01,$A2,$08,$EF,$00,$E7,$AD,$26,$F2
@b              fcb   $EF,$02,$F0,$06,$01,$03,$FF,$80,$0A
@c              fcb   $C3
                fdb   $06F7,$0005
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $C3,$17,$F2
ssamp43         fcb   $30,$30,$34,$5C,$30,$9E,$AC,$A8,$DC,$0E,$04,$0A
                fcb   $05,$08,$08,$08,$08,$BF,$BF,$BF,$BF,$24,$04,$1C,$80
                fcb   $30,$30,$34,$5C,$30,$9E,$AC,$A8,$DC,$0E,$04,$0A
                fcb   $05,$08,$08,$08,$08,$BF,$BF,$BF,$BF,$24,$04,$2C,$80
                fcb   $04,$37,$77,$72,$49,$1F,$1F,$1F,$1F,$07,$07,$0A
                fcb   $0D,$00,$00,$0B,$0B,$1F,$1F,$0F,$0F,$13,$13,$81,$88

; thunk
Sound44         fdb   ssamp44-Sound44,$0101
                fdb   $8005,@a-Sound44,$0000
@a              fcb   $EF,$00,$8A,$22,$F2
ssamp44         fcb   $FA,$21,$10,$30,$32,$1F,$1F,$1F,$1F,$05,$05,$18
                fcb   $10,$0B,$10,$1F,$10,$1F,$4F,$2F,$2F,$0D,$04,$07,$80

; cha-ching
Sound45         fdb   ssamp45-Sound45,$0103
                fdb   $8005,@a-Sound45,$0000
                fdb   $8004,@b-Sound45,$0000
                fdb   $80C0,@c-Sound45,$0000
@a              fcb   $EF,$00,$8A,$08,$80,$02,$8A,$08,$F2
@b              fcb   $EF,$01,$80,$12,$C6,$55,$F2
@c              fcb   $F5,$02,$F3,$E7,$80,$02,$C2,$05,$C4,$04,$C2,$05,$C4,$04,$F2
ssamp45         fcb   $3B,$03,$02,$02,$06,$18,$1A,$1A,$96,$17,$0A,$0E
                fcb   $10,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$00,$39,$28,$80
ringsamp        fcb   $31,$0E ; instrument (0-F) / attenuation (0-F) , transpose
;               fcb   $04,$37,$77,$72,$49,$1F,$1F,$1F,$1F,$07,$07,$0A
;               fcb   $0D,$00,$00,$0B,$0B,$1F,$1F,$0F,$0F,$23,$23,$80,$80

; losing rings (scatter)
Sound46         fdb   ringsamp-Sound46,$0102
                fdb   $8004,@a-Sound46,$0005
                fdb   $8005,@b-Sound46,$0008
@a              fcb   $EF,$00,$C6,$02,$05,$05,$05,$05,$05,$05,$3A,$F2
@b              fcb   $EF,$00,$80,$02,$C4,$02,$05,$15,$02,$05,$32,$F2

; chain pull chink-chink (unused)
Sound47         fdb   ssamp47-Sound47,$0101
                fdb   $8005,@a-Sound47,$0000
@a              fcb   $EF,$00,$BE,$05,$80,$04,$BE,$04,$80,$04,$F2
ssamp47         fcb   $28,$2F,$37,$5F,$2B,$1F,$1F,$1F,$1F,$15,$15,$15
                fcb   $13,$13,$0D,$0C,$10,$2F,$3F,$2F,$2F,$00,$1F,$10,$80

; flamethrower
Sound48         fdb   $0000,$0101
                fdb   $80C0,@a-Sound48,$0000
@a              fcb   $F5,$00,$F3,$E7,$A7,$25,$F2

; bonus pwoieeew (mostly unused)
Sound49         fdb   ssamp49-Sound49,$0101
                fdb   $8005,@a-Sound49,$0E00
@a              fcb   $EF,$00,$F0,$01,$01,$33,$18,$B9,$1A,$F2
ssamp49         fcb   $3B,$0A,$05,$31,$02,$5F,$5F,$5F,$5F,$04,$16,$14
                fcb   $0C,$00,$00,$04,$00,$1F,$D8,$6F,$FF,$03,$00,$25,$80

; special stage entry
Sound4A         fdb   ssamp4A-Sound4A,$0101
                fdb   $8005,@a-Sound4A,$0002
@a              fcb   $EF,$00,$F0,$01,$01,$5B,$02,$CC,$65,$F2
ssamp4A         fcb   $20,$36,$30,$35,$31,$41,$3B,$49,$4B,$09,$09,$06
                fcb   $08,$01,$02,$03,$A9,$0F,$0F,$0F,$0F,$29,$23,$27,$80

; slower smash/crumble
Sound4B         fdb   smashsamp-Sound4B,$0102
                fdb   $8005,@a-Sound4B,$0000
                fdb   $80C0,@b-Sound4B,$0000
@a              fcb   $EF,$00,$F0,$03,$01,$20,$04
@c              fcb   $81,$18,$E6
                fdb   $0AF7,$0006
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2
@b              fcb   $F0,$01,$01,$0F,$05,$F3,$E7
@d              fcb   $B0,$18,$E7,$EC
                fdb   $03F7,$0005
@lb2            fdb   @d-@lb2 ; loopback
                fcb   $F2

; spring boing
Sound4C         fdb   ssamp4C-Sound4C,$0101
                fdb   $8004,@a-Sound4C,$0002
@a              fcb   $EF,$00,$80,$01,$F0,$03,$01,$5D,$0F,$B0,$0C,$F4
@b              fcb   $E7,$E6,$02,$BD
                fdb   $02F7,$0019
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2
ssamp4C         fcb   $20,$36,$30,$35,$31,$DF,$9F,$DF,$9F,$07,$09,$06
                fcb   $06,$07,$06,$06,$08,$2F,$1F,$1F,$FF,$16,$13,$30,$80

; selection blip
Sound4D         fdb   $0000,$0101
                fdb   $80C0,@a-Sound4D,$0000
@a              fcb   $BB,$02,$F2

; another ring sound (only plays in the left speaker?)
Sound4E         fdb   ringsamp-Sound4E,$0101
                fdb   $8004,@a-Sound4E,$0005
@a              fcb   $EF,$00,$E0,$80,$C1,$04,$C4,$05,$C9,$1B,$F2

; signpost spin sound
Sound4F         fdb   ssamp4F-Sound4F,$0102
                fdb   $8004,@a-Sound4F,$2703
                fdb   $8005,@b-Sound4F,$2700
@a              fcb   $80,$04
@b              fcb   $EF,$00
@c              fcb   $B4,$05,$E6
                fdb   $02F7,$0015
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2
ssamp4F         fcb   $F4,$06,$0F,$04,$0E,$1F,$1F,$1F,$1F,$00,$0B,$00
                fcb   $0B,$00,$05,$00,$08,$0F,$FF,$0F,$FF,$0C,$03,$8B,$80

; mosquito zapper
Sound50         fdb   ssamp50-Sound50,$0101
                fdb   $8005,@a-Sound50,$F400
@a              fcb   $EF,$00,$B3,$04,$80,$01
@b              fcb   $B4,$04,$80
                fdb   $01F7,$0004
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2
ssamp50         fcb   $83,$12,$13,$10,$1E,$1F,$1F,$1F,$1F,$00,$00,$00
                fcb   $00,$02,$02,$02,$02,$2F,$FF,$2F,$3F,$06,$34,$10,$87

; (unused)
Sound51         fdb   ssamp51-Sound51,$0102
                fdb   $80C0,@a-Sound51,$0001
                fdb   $8005,@b-Sound51,$000B
@a              fcb   $F5,$02,$F3,$E4,$B0,$04,$85,$02,$F2
@b              fcb   $EF,$00,$E8,$04,$A5,$06,$F2
ssamp51         fcb   $3C,$02,$01,$00,$01,$1F,$1F,$1F,$1F,$00,$19,$0E
                fcb   $10,$00,$00,$0C,$0F,$0F,$FF,$EF,$FF,$05,$00,$80,$80

; (unused)
Sound52         fdb   ssamp52-Sound52,$0101
                fdb   $8005,@a-Sound52,$0002
@a              fcb   $F0,$01,$01,$2A,$07,$EF,$00
@b              fcb   $A5,$03
                fdb   $E7F7,$0013
@lb1            fdb   @b-@lb1 ; loopback
@c              fcb   $A5,$03,$E7,$E6
                fdb   $02F7,$0013
@lb2            fdb   @c-@lb2 ; loopback
                fcb   $F2
ssamp52         fcb   $28,$21,$21,$21,$30,$1F,$1F,$1F,$1F,$00,$00,$00
                fcb   $00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$29,$20,$29,$80


Sound53         fdb   ssamp53-Sound53,$0101
                fdb   $8005,@a-Sound53,$F503
@a              fcb   $EF,$00,$F0,$01,$01,$46,$09,$A7,$14,$E7,$14,$E7,$E6,$04
                fcb   $14,$E7,$E6,$04,$14,$E7,$E6,$04,$0A,$E7,$E6,$04,$0A,$F2
ssamp53         fcb   $07,$0A,$0C,$0C,$0C,$1F,$1F,$1F,$1F,$00,$00,$00
                fcb   $00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$2A,$0F,$0F,$80

; OOZ lid pop sound
Sound54         fdb   ssamp54-Sound54,$0102
                fdb   $8005,@a-Sound54,$0000
                fdb   $80C0,@b-Sound54,$0006
@a              fcb   $EF,$00,$B6,$15,$F2
@b              fcb   $F3,$E7,$F5,$04,$C6,$03,$E7,$C5,$E7
                fcb   $C4,$E7,$C3,$E7,$C2,$E7,$C1,$E7,$C0,$F2
ssamp54         fcb   $07,$03,$02,$03,$00,$FF,$6F,$6F,$3F,$12,$14,$11
                fcb   $0E,$1A,$0A,$03,$0D,$FF,$FF,$FF,$FF,$03,$07,$07,$80


Sound55         fdb   ssamp55-Sound55,$0101
                fdb   $8005,@a-Sound55,$0000
@a              fcb   $EF,$00,$AA,$07,$B6,$15,$F2
ssamp55         fcb   $42,$20,$0E,$0F,$0F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
                fcb   $1F,$0F,$0E,$0F,$0E,$0F,$0F,$0F,$0F,$2E,$80,$20,$80


Sound56         fdb   ssamp56-Sound56,$0101
                fdb   $8005,@a-Sound56,$100E
@a              fcb   $EF,$00,$F0,$01,$01,$1E,$FF,$8F,$1C,$F4
@b              fcb   $E7,$9A
                fdb   $05F7,$0009
@lb1            fdb   @b-@lb1 ; loopback
@c              fcb   $E7,$9A,$04,$E6,$02,$E7,$9A,$04,$E6
                fdb   $02F7,$0008
@lb2            fdb   @c-@lb2 ; loopback
                fcb   $F2
ssamp56         fcb   $0D,$06,$00,$00,$E5,$1F,$1F,$1F,$1F,$00,$00,$00
                fcb   $00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$27,$80,$80,$80


Sound57         fdb   ssamp57-Sound57,$0101
                fdb   $8005,@a-Sound57,$0000
@a              fcb   $EF,$00,$CA,$15,$F2
ssamp57         fcb   $04,$09,$70,$00,$30,$1C,$1F,$DF,$1F,$15,$12,$0B
                fcb   $0F,$0C,$0D,$00,$0D,$07,$2F,$FA,$FA,$00,$29,$00,$00

; CNZ bonusy bumper sound
Sound58         fdb   ssamp58-Sound58,$0101
                fdb   $8005,@a-Sound58,$0007
@a              fcb   $EF,$00,$B3,$06,$B3,$15,$F2
ssamp58         fcb   $3C,$05,$0A,$01,$01,$56,$5C,$5C,$5C,$0E,$11,$11
                fcb   $11,$09,$06,$0A,$0A,$4F,$3F,$3F,$3F,$17,$20,$80,$80

; CNZ baaang bumper sound
Sound59         fdb   ssamp59-Sound59,$0103
                fdb   $8004,@a-Sound59,$0000
                fdb   $8002,@b-Sound59,$0002
                fdb   $8005,@c-Sound59,$0000
@a              fcb   $EF,$00,$E1,$0C,$B5,$14,$F2
@b              fcb   $EF,$01,$9A,$03,$F2
@c              fcb   $EF,$00,$B6,$14,$F2
ssamp59         fcb   $32,$30,$30,$40,$70,$1F,$1F,$1F,$1F,$12,$0A,$01
                fcb   $0D,$00,$01,$01,$0C,$00,$23,$C3,$F6,$08,$07,$1C,$03
                fcb   $05,$00,$00,$00,$00,$1F,$1F,$1F,$1F,$12,$0C,$0C
                fcb   $0C,$12,$08,$08,$08,$1F,$5F,$5F,$5F,$07,$80,$80,$80

; CNZ gloop / water droplet sound
Sound5A         fdb   ssamp5A-Sound5A,$0101
                fdb   $8005,@a-Sound5A,$0000
@a              fcb   $EF,$00,$F0,$01,$01,$7F,$F1,$AA,$0A,$F2
ssamp5A         fcb   $47,$03,$02,$02,$04,$5F,$5F,$5F,$5F,$0E,$1A,$11
                fcb   $0A,$09,$0A,$0A,$0A,$4F,$3F,$3F,$3F,$7F,$80,$80,$A3


Sound5B         fdb   ssamp5B-Sound5B,$0101
                fdb   $8005,@a-Sound5B,$0000
@a              fcb   $EF,$00,$80,$02,$A5,$01,$E7
@b              fcb   $01,$E7,$E6
                fdb   $02F7,$0005
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2
ssamp5B         fcb   $38,$0F,$0F,$0F,$0F,$1F,$1F,$1F,$0E,$00,$00,$00
                fcb   $00,$00,$00,$00,$00,$0F,$0F,$0F,$1F,$00,$00,$00,$80


Sound5C         fdb   ssamp5C-Sound5C,$0102
                fdb   $8004,@a-Sound5C,$000E
                fdb   $80C0,@b-Sound5C,$0000
@a              fcb   $EF,$00,$85,$40
@c              fcb   $E7,$04,$E6
                fdb   $04F7,$000A
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2
@b              fcb   $F5,$00,$F3,$E7,$A7,$40
@d              fcb   $E7,$08,$E6
                fdb   $01F7,$0005
@lb2            fdb   @d-@lb2 ; loopback
                fcb   $F2
ssamp5C         fcb   $FA,$12,$01,$01,$01,$1F,$1F,$1F,$1F,$00,$00,$00
                fcb   $00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$81,$8E,$14,$80

; chain clink
Sound5D         fdb   ssamp5D-Sound5D,$0101
                fdb   $8005,@a-Sound5D,$0000
@a              fcb   $EF,$00,$C0,$04,$F2
ssamp5D         fcb   $28,$2F,$37,$5F,$2B,$1F,$1F,$1F,$1F,$15,$15,$15
                fcb   $13,$13,$0D,$0C,$10,$2F,$3F,$2F,$2F,$00,$1F,$10,$80

; helicopter
Sound5E         fdb   ssamp5E-Sound5E,$0101
                fdb   $8002,@a-Sound5E,$1405
@a              fcb   $EF,$00
@b              fcb   $95,$02,$95
                fdb   $01F7,$0013
@lb1            fdb   @b-@lb1 ; loopback
@c              fcb   $95,$02,$95,$01,$E6
                fdb   $01F7,$001B
@lb2            fdb   @c-@lb2 ; loopback
                fcb   $F2
ssamp5E         fcb   $35,$30,$44,$40,$51,$1F,$1F,$1F,$1F,$10,$00,$13
                fcb   $15,$1F,$00,$1F,$1A,$7F,$0F,$7F,$5F,$02,$A8,$80,$80


Sound5F         fdb   ssamp5F-Sound5F,$0103
                fdb   $8005,s5Fs1-Sound5F,$0000
                fdb   $80C0,s5Fs2-Sound5F,$0000
                fdb   $80A0,s5Fs3-Sound5F,$0000
s5Fs1           fcb   $EF,$00,$F0,$01,$01,$C5,$1A,$CD,$07,$E6,$0A,$80
                fcb   $06,$EF,$01,$F0,$01,$01,$11,$FF,$A2,$28
@a              fcb   $E7,$03,$E6
                fdb   $03F7,$0005
@lb1            fdb   @a-@lb1 ; loopback
                fcb   $F2
s5Fs2           fcb   $80,$07,$F0,$01,$02,$05,$FF,$F3,$E7,$BB,$1D
@b              fcb   $E7,$07,$EC
                fdb   $01F7,$0010
@lb2            fdb   @b-@lb2 ; loopback
                fcb   $F2
s5Fs3           fcb   $80,$16,$F5,$03
@c              fcb   $BF,$04,$C1,$C3,$EC,$01,$E9
                fdb   $FFF7,$0005
@lb3            fdb   @c-@lb3 ; loopback
@d              fcb   $BF,$04,$C1,$C3,$EC,$01,$E9
                fdb   $01F7,$0007
@lb4            fdb   @d-@lb4 ; loopback
                fcb   $F2
ssamp5F         fcb   $FD,$09,$00,$03,$00,$1F,$1F,$1F,$1F,$10,$0C,$0C
                fcb   $0C,$0B,$10,$1F,$05,$1F,$4F,$2F,$2F,$09,$92,$84,$8E
                fcb   $3A,$70,$30,$04,$01,$0F,$14,$19,$16,$08,$0A,$0B
                fcb   $05,$03,$03,$03,$05,$1F,$6F,$8F,$5F,$1F,$22,$1F,$80

; spindash charge
Sound60         fdb   ssamp60-Sound60,$0101 
                fdb   $8005,@a-Sound60,$FE00
@a              fcb   $EF,$00,$F0,$00,$01,$22,$F6,$C4,$16,$E7,$F4,$D0,$18,$E7
@b              fcb   $04,$E7,$E6
                fdb   $03F7,$0010
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2
ssamp60         fcb   $10,$0E
;ssamp60         fcb   $34,$00,$03,$0C,$09,$9F,$8C,$8F,$95,$00,$00,$00
;                fcb   $00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$00,$1D,$00,$00

; rumbling
Sound61         fdb   ssamp61-Sound61,$0101
                fdb   $8004,@a-Sound61,$0004
@a              fcb   $80,$01,$EF,$00,$F0,$00,$01,$70,$06,$82,$06,$85,$08,$83
                fcb   $01,$82,$05,$86,$06,$89,$03,$82,$08,$88,$04,$82,$06,$E6
                fcb   $02,$85,$08,$E6,$02,$83,$01,$E6,$02,$82,$05,$E6,$02,$86
                fcb   $06,$E6,$02,$89,$03,$E6,$02,$82,$08,$E6,$02,$88,$04,$E6,$02,$F2
ssamp61         fcb   $32,$30,$30,$50,$30,$1F,$0E,$19,$0E,$07,$12,$15
                fcb   $09,$0A,$09,$1D,$06,$E8,$03,$0A,$17,$07,$00,$00,$00


Sound62         fdb   ssamp62-Sound62,$0101
                fdb   $8005,@a-Sound62,$FF00
@a              fcb   $EF,$00,$A6,$05,$F0,$01,$01,$E7,$40
@b              fcb   $C4,$02,$E7,$E6
                fdb   $01F7,$0012
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2
ssamp62         fcb   $34,$0C,$10,$73,$0C,$AF,$AC,$FF,$D5,$06,$00,$02
                fcb   $01,$02,$0A,$04,$08,$BF,$BF,$BF,$BF,$00,$08,$80,$80

; CNZ blooing bumper
Sound63         fdb   ssamp63-Sound63,$0101
                fdb   $8005,@a-Sound63,$0907
@a              fcb   $EF,$00,$F0,$01,$01,$04,$56,$92,$03,$9A,$25,$F2
ssamp63         fcb   $3D,$12,$10,$77,$30,$5F,$5F,$5F,$5F,$0F,$0A,$00
                fcb   $01,$0A,$0A,$0D,$0D,$4F,$0F,$0F,$0F,$13,$80,$80,$80

; HTZ track click sound
Sound64         fdb   ssamp64-Sound64,$0101
                fdb   $8005,@a-Sound64,$1100
@a              fcb   $EF,$00,$C7,$02,$F2
ssamp64         fcb   $24,$2A,$02,$05,$01,$1A,$1F,$10,$1F,$0F,$1F,$1F
                fcb   $1F,$0C,$0D,$11,$11,$0C,$09,$09,$0F,$0E,$04,$80,$80

; kicking up leaves sound
Sound65         fdb   ssamp65-Sound65,$0101
                fdb   $80C0,@a-Sound65,$F800
@a              fcb   $F5,$03,$F3,$E7,$CE,$03,$F5,$06,$CE,$04,$EC
                fcb   $02,$CE,$02,$F5,$03,$EC,$FE,$CE,$08,$CE,$18,$F2
ssamp65         ; uhm... apparently they forgot to null out the pointer to here.
                ; luckily, sound 65 doesn't really use its sample

; leaf splash?
Sound66         fdb   ssamp66-Sound66,$0102
                fdb   $8005,@b-Sound66,$EE08
                fdb   $80C0,@a-Sound66,$0000
@a              fcb   $F3,$E7,$F5,$09,$C6,$36,$F2
@b              fcb   $EF,$00,$80,$01,$92,$02,$02,$02,$30,$F2
ssamp66         fcb   $32,$33,$17,$34,$13,$0F,$0D,$1B,$17,$00,$04,$02
                fcb   $0B,$08,$00,$08,$09,$6F,$5F,$4F,$6F,$05,$00,$00,$80


Sound67         fdb   ssamp67-Sound67,$0101
                fdb   $80C0,@a-Sound67,$0000
@a              fcb   $F5,$06,$F3,$E7,$90,$0A,$94,$0A,$98,$0A,$9C
                fcb   $0A,$A0,$0A,$A4,$08,$A8,$08,$AC,$08,$B0,$08,$F2
ssamp67         ; another not-really-used sample (like Sound65)

; door slamming quickly (unused)
Sound68         fdb   ssamp68-Sound68,$0101
                fdb   $8005,@a-ssamp67,$F400
@a              fcb   $EF,$00,$9B,$04,$A5,$06,$F2
ssamp68         fcb   $3C,$00,$00,$00,$00,$1F,$1F,$1F,$1F,$00,$0F,$16
                fcb   $0F,$00,$00,$00,$00,$0F,$FF,$AF,$FF,$00,$0A,$80,$80


Sound69         fdb   ssamp69-Sound69,$0102
                fdb   $8005,@a-Sound69,$F400
                fdb   $80C0,@b-Sound69,$0000
@a              fcb   $EF,$00,$9B,$03,$A8,$06,$9E,$08,$F2
@b              fcb   $F5,$04,$F3,$E7,$C6,$03,$C6,$06,$C6,$08,$F2
ssamp69         fcb   $3C,$00,$00,$00,$00,$1F,$1F,$1F,$1F,$00,$0F,$16
                fcb   $0F,$00,$00,$00,$00,$0F,$FF,$AF,$FF,$00,$0A,$80,$80

; robotic laser burst
Sound6A         fdb   ssamp6A-Sound6A,$0101
                fdb   $8005,@a-Sound6A,$0004
@a              fcb   $EF,$00,$DF,$14,$E6,$18,$06,$F2
ssamp6A         fcb   $3D,$09,$34,$34,$28,$1F,$16,$16,$16,$00,$00,$00
                fcb   $04,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$15,$02,$02,$00

; scatter
Sound6B         fdb   ssamp6B-Sound6B,$0101
                fdb   $8004,@a-Sound6B,$0002
@a              fcb   $EF,$00,$81,$04,$80,$0C,$F2
ssamp6B         fcb   $3A,$30,$30,$40,$70,$1F,$1F,$1F,$1F,$12,$0A,$01
                fcb   $07,$00,$01,$01,$03,$00,$23,$C3,$46,$08,$07,$1C,$03


Sound6C         fdb   ssamp6C-Sound6C,$0104
                fdb   $8005,@b-Sound6C,$0010
                fdb   $8004,@a-Sound6C,$0010
                fdb   $80C0,s5Fs2-Sound6C,$0000
                fdb   $80A0,s5Fs3-Sound6C,$0000
@a              fcb   $E1,$10
@b              fcb   $EF,$01,$F0,$01,$01,$EC,$56,$C0,$24,$F4,$EF,$00,$E6,$F0
@c              fcb   $BB,$02,$E7,$E6,$02,$E9
                fdb   $01F7,$0020
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2
ssamp6C         fcb   $00,$53,$30,$03,$30,$1F,$1F,$1F,$1F,$00,$00,$00
                fcb   $00,$00,$00,$00,$00,$00,$00,$00,$0F,$0F,$06,$23,$80
                fcb   $3C,$72,$32,$32,$72,$14,$14,$0F,$0F,$00,$00,$00
                fcb   $00,$00,$00,$00,$00,$02,$02,$08,$08,$35,$14,$00,$00

; error sound
Sound6D         fdb   ssamp6D-Sound6D,$0101
                fdb   $8005,@a-Sound6D,$0004
@a              fcb   $EF,$00,$B0,$06,$80,$06,$B0,$18,$F2
ssamp6D         fcb   $38,$00,$00,$00,$00,$1F,$1F,$1F,$1F,$00,$00,$00
                fcb   $00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$1F,$0C,$17,$00

; silver sonic buzz saw
Sound6E         fdb   ssamp6E-Sound6E,$0102
                fdb   $8005,@a-Sound6E,$0000
                fdb   $80C0,@b-Sound6E,$0000
@a              fcb   $EF,$00,$C6,$24,$E7
@c              fcb   $C6,$04,$E7,$E6
                fdb   $04F7,$0008
@lb1            fdb   @c-@lb1 ; loopback
                fcb   $F2
@b              fcb   $F3,$E7,$C7,$44,$F2
ssamp6E         fcb   $33,$00,$10,$00,$31,$1F,$1D,$1E,$0E,$00,$0C,$1D
                fcb   $00,$00,$00,$01,$00,$0F,$0F,$0F,$0F,$08,$06,$07,$80


Sound6F         fdb   ssamp6A-Sound6F,$0103
                fdb   $8005,@b-Sound6F,$000B
                fdb   $8004,@a-Sound6F,$0012
                fdb   $80C0,@c-Sound6F,$0000
@a              fcb   $E1,$02,$80,$02
@b              fcb   $EF,$00,$E6,$0C,$DF,$06,$E7,$E6,$F4,$06,$E7
                fcb   $E6,$F4,$12,$E7,$E6,$0C,$06,$E7,$E6,$0C,$06,$F2
@c              fcb   $F3,$E7,$C6,$04,$C0,$BA,$B4,$AE,$E6
                fcb   $01,$AE,$E6,$01,$AE,$E6,$01,$AE,$F2


Sound70         fdb   $0000,$0101
                fdb   $80C0,@a-Sound70,$0000
@a              fcb   $F3,$E7,$C6,$18
@b              fcb   $E7,$03,$E6
                fdb   $01F7,$0008
@lb1            fdb   @b-@lb1 ; loopback
                fcb   $F2

        