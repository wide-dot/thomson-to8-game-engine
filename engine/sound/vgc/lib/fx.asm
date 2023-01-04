
INCBIN "testvgm/main.vgc"
;INCBIN "testvgm/outruneu.vgc" ; no huffman
INCBIN "testvgm/nd-ui.vgc"      ; Huffman
;INCBIN "testvgm/androids.vgc"  ; No Huffman
;INCBIN "testvgm/syner5.vgc"
;INCBIN "testvgm/darkside1.vgc"
;INCBIN "testvgm/bbcapple.vgc"
;INCBIN "testvgm/mongolia.vgc"
;INCBIN "testvgm/things.vgc"
;INCBIN "testvgm/lethal7.vgc"
;INCBIN "testvgm/CPCTL10A.vgc"
;INCBIN "testvgm/bestpart.vgc"
;INCBIN "testvgm/tale7.vgc"
.fx_temp SKIP 2
.fx_temp1 SKIP 1
.fxspectrum SKIP 256
.fxspectrumbars SKIP 32
.fxcopy SKIP 11
.fxdiff SKIP 11
    lda #22
    jsr &ffee
    lda #7
    jsr &ffee

.fx_channels SKIP 4

.fx_volume_table
    equb &ff, &ee, &dd, &cc, &bb, &aa, &99, &88, &77, &66, &55, &44, &33, &22, &11, &00

.update_fx
{
 
    ldx #0
    lda #0
.clearscreen
    sta &7c00,x
    sta &7d00,x
    sta &7e00,x
    sta &7f00,x
    dex
    bne clearscreen


    ldx #10
.copy_loop
    lda vgm_fx, x
    tay
    eor fxcopy,x
    sta fxdiff,x ; NZ if changed
    tya
    sta fxcopy,X
    dex
    bpl copy_loop

    ; do channel triggers
.do_channel0
    lda fxdiff+VGM_FX_TONE0_LO
    ora fxdiff+VGM_FX_TONE0_HI
    beq do_channel1
    ldx vgm_fx+VGM_FX_VOL0
    lda fx_volume_table,x
    cmp fx_channels+0
    bcc do_channel1
    sta fx_channels+0

.do_channel1
    lda fxdiff+VGM_FX_TONE1_LO
    ora fxdiff+VGM_FX_TONE1_HI
    beq do_channel2
    ldx vgm_fx+VGM_FX_VOL1
    lda fx_volume_table,x
    cmp fx_channels+1
    bcc do_channel2
    sta fx_channels+1

.do_channel2
    lda fxdiff+VGM_FX_TONE2_LO
    ora fxdiff+VGM_FX_TONE2_HI
    beq do_channel3
    ldx vgm_fx+VGM_FX_VOL2
    lda fx_volume_table,x
    cmp fx_channels+2
    bcc do_channel3
    sta fx_channels+2

.do_channel3
    lda fxdiff+VGM_FX_TONE3_LO
    beq done_channels
    ldx vgm_fx+VGM_FX_VOL3
    lda fx_volume_table,x
    cmp fx_channels+3
    bcc done_channels
    sta fx_channels+3


.done_channels

; spectrum

MACRO SPECTRUM channel
    lda vgm_fx+VGM_FX_VOL0+channel
    tay
    lda vgm_fx+VGM_FX_TONE0_HI+channel
    asl a:asl a:sta fx_temp
    lda vgm_fx+VGM_FX_TONE0_LO+channel:lsr a:lsr a:ora fx_temp:tax
    lda #15
    sec
    sbc vgm_fx+VGM_FX_VOL0+channel
    lda #15
    sta fxspectrum,x
ENDMACRO

    SPECTRUM 0
    SPECTRUM 1
    SPECTRUM 2

    ; resample to render 256 -> 32 = 8:1 (8x16 = 128 so no overflow)
    ldx #0
    ldy #0
.specloop
    clc
    lda fxspectrum+0,x
    adc fxspectrum+1,x
    adc fxspectrum+2,x
    adc fxspectrum+3,x
    adc fxspectrum+4,x
    adc fxspectrum+5,x
    adc fxspectrum+6,x
    adc fxspectrum+7,x
    lsr a:lsr a:lsr a  ; /8
    sta fxspectrumbars,y
    inx:inx:inx:inx
    inx:inx:inx:inx
    iny
    cpy #32
    bne specloop    


; draw spectrum

    SPECTRUM_Y = 10
    SPECTRUM_H = 8

MACRO PLOTCHAR c,x,y
    lda #c:sta &7c00+y*40+x
ENDMACRO

FOR y,SPECTRUM_Y, SPECTRUM_Y+SPECTRUM_H
    PLOTCHAR 145, 0, y
NEXT



MACRO DRAWSPECT bar,xc,yc
    lda fxspectrumbars+bar
    lda #15
    lsr a
    sta fx_temp1
    lda #255
    ldx #xc
    ldy #yc+SPECTRUM_H
.loop
    jsr drawchar
    dey
    lda fx_temp1
    beq finito
    dec fx_temp1
    bpl loop
.finito
ENDMACRO

FOR sx,0,31
    DRAWSPECT sx,1+sx,SPECTRUM_Y
NEXT

; render



    lda vgm_fx+VGM_FX_TONE0_HI:ldx #0:ldy #0:jsr drawnum
    lda vgm_fx+VGM_FX_TONE0_LO:ldx #2:ldy #0:jsr drawnum

    lda vgm_fx+VGM_FX_TONE1_HI:ldx #5:ldy #0:jsr drawnum
    lda vgm_fx+VGM_FX_TONE1_LO:ldx #7:ldy #0:jsr drawnum

    lda vgm_fx+VGM_FX_TONE2_HI:ldx #10:ldy #0:jsr drawnum
    lda vgm_fx+VGM_FX_TONE2_LO:ldx #12:ldy #0:jsr drawnum

    lda vgm_fx+VGM_FX_TONE3_LO:ldx #15:ldy #0:jsr drawnum


    lda vgm_fx+VGM_FX_VOL0:ldx #2:ldy #1:jsr drawnum
    lda vgm_fx+VGM_FX_VOL1:ldx #7:ldy #1:jsr drawnum
    lda vgm_fx+VGM_FX_VOL2:ldx #12:ldy #1:jsr drawnum
    lda vgm_fx+VGM_FX_VOL3:ldx #15:ldy #1:jsr drawnum

    lda fx_channels+0:ldx #2:ldy #2:jsr drawnum
    lda fx_channels+1:ldx #7:ldy #2:jsr drawnum
    lda fx_channels+2:ldx #12:ldy #2:jsr drawnum
    lda fx_channels+3:ldx #15:ldy #2:jsr drawnum

    ; bars
    BAR_Y = 4


MACRO DRAWBAR channel, ycoord
    lda #0
    ldx #39
.clearloop
    sta &7c00+ycoord*40,x
    dex
    bpl clearloop
    ; draw bars
    lda fx_channels+channel
    lsr a
    lsr a
    lsr a
    tax
    ldy #32
    lda #255
.draw1
    sta &7c00+40*ycoord,X
    dey
    dex
    bpl draw1
ENDMACRO

    DRAWBAR 0, BAR_Y+0
    DRAWBAR 1, BAR_Y+1
    DRAWBAR 2, BAR_Y+2
    DRAWBAR 3, BAR_Y+3


    PLOTCHAR 146,0,BAR_Y+0
    PLOTCHAR 147,0,BAR_Y+1
    PLOTCHAR 148,0,BAR_Y+2
    PLOTCHAR 149,0,BAR_Y+3

    ; decay

    ldx #3
.fade_loop
    lda fx_channels,x
    sec
    sbc #8
    bcs ok1
    lda #0
.ok1
    sta fx_channels,x
    dex
    bpl fade_loop
    rts
}



.hex equs "0123456789ABCDEF"
; X/Y address to draw
.ytable_lo
FOR y,0,25
equb lo(&7c00+y*40)
NEXT
.ytable_hi
FOR y,0,25
equb hi(&7c00+y*40)
NEXT

; X/Y are coords
.drawnum
{
    pha
    stx xadd+1

    lda ytable_lo,y
    clc
.xadd
    adc #0 ; **SM**
    sta fx_temp+0
    lda ytable_hi,y
    adc #0
    sta fx_temp+1
    pla
    pha
    and #&f0
    lsr a:lsr a:lsr a:lsr a
    tax
    lda hex, X
    ldy #0
    sta (fx_temp),y
    pla
    and #&0f
    tax
    lda hex, X
    iny
    sta (fx_temp),y

    rts
}


; X/Y are coords, XY preserved
.drawchar
{
    pha
    stx xadd+1
    lda ytable_lo,y
    clc
.xadd
    adc #0 ; **SM**
    sta fx_temp+0
    lda ytable_hi,y
    adc #0
    sta fx_temp+1
    pla
    sty restoreY+1
    ldy #0
    sta (fx_temp),y
.restoreY
    ldy #0 ;**SM**
    rts
}