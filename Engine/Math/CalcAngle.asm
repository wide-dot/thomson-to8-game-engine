; arctangent of y/x
; -----------------
; Calculate the angle, in a 256-degree circle, between two points.
; The trick is to use logarithmic division to get the y/x ratio and
; integrate the power function into the atan table. Some branching is
; avoided by using a table to adjust for the octants.
; In otherwords nothing new or particularily clever but nevertheless
; quite useful.
;
; original 6502 code by Johan Forslof (doynax)

; computation is done on 9 bit signed values of x and y made by
; downscaling of 16 bit signed values
;
; input registers :
; D = y (16 bit signed value)
; X = x (16 bit signed value)
;
; output register :
; A = angle 0-255 (255 = 360 deg, 192 = 90 deg, 128 = 180 deg, 64 = 270 deg)
;     angle 0 start at (x=0, y>0), clockwise
;     special case (0,0) return $40

        SETDP   dp/256

tstd            equ dp_engine+25
x_h             equ dp_engine+27
y_h             equ dp_engine+28
x_l             equ dp_engine+29
y_l             equ dp_engine+30
octant          equ dp_engine+31

CalcAngle
        ; scale down 16 bit value to 9 bit
        sta   y_h
        stb   y_l
        tfr   x,d
        sta   x_h       ; a loaded with x high byte
        stb   x_l
        ldb   y_h       ; b loaded with y high byte
        bra   @test
@undoB  decb            ; undo incb
@undoA  deca            ; undo inca
        asrb            ; lower resolution
        ror    y_l      ; .
        asra            ; .
        ror    x_l      ; end of lower resolution
@test   inca            ; $00 => $01 or $ff => $00, every other value will have a bit set btw b7 and b1
        bita   #$fe     ; do not change A, check if a bit is set btw b7 and b1
        bne    @undoA   ; restore value and scale down
        incb
        bitb   #$fe
        bne    @undoB
        ldd    x_l      ; now values are computed to 8 bits and loaded in A:x ,B:y

        ; start of atan2
        ; --------------

        ; special cases
        bne   >
        ldx   x_h
        bne   >
        lda   #$40      ; x=0,y=0
        rts
!       tsta
        bne   @y0
        tst   y_h 
        bmi   >
        lda   #$00      ; x=0,y>0
        rts
!       lda   #$80      ; x=0,y<0
        rts
@y0     tstb
        bne   @run
        tst   x_h
        bmi   >
        lda   #$C0      ; x>0,y=0
        rts
!       lda   #$40      ; x<0,y=0
        rts         
@run
        ; set x
        lda   x_h       ; test sign of x using the 16 bit input value
        asra            ; cc=1 if x_h<0
        rol   octant    ; set octant b2 if x is negative
        eora  x_l

        ; set y
        ldb   y_h       ; test sign of y using the 16 bit input value
        asrb            ; cc=1 if y_h<0
        rol   octant    ; set octant b2 if y is negative
        eorb  y_l

        ; compute ratio
        orcc  #1
        ldx   #log2_tab
        lda   a,x
        sbca  b,x       ; compute y/x ratio
        bcs   >         ; branch if (x < y)
        nega
        andcc #$FE      ; clear carry (x > y)
!       

        ; retrieve the angle
        ldx   #atan_tab
        lda   a,x

        ; adjust octant
        ldx   #octant_adjust
        ldb   octant   
        rolb            ; set octant b0 if (x < y)
        andb  #%111     ; modulo to keep usefull values
        eora  b,x       ; apply octant to angle
        ldx   #octant_adjust2
        adda  b,x

        rts                  

octant_adjust
                fcb %11000000           ;; x+,y+,|x|>|y|
                fcb %11111111           ;; x+,y+,|x|<|y|
                fcb %10111111           ;; x+,y-,|x|>|y|
                fcb %10000000           ;; x+,y-,|x|<|y|
                fcb %00111111           ;; x-,y+,|x|>|y|
                fcb %00000000           ;; x-,y+,|x|<|y|
                fcb %01000000           ;; x-,y-,|x|>|y|
                fcb %01111111           ;; x-,y-,|x|<|y|

octant_adjust2
                fcb 0
                fcb 0
                fcb 1
                fcb 1
                fcb 1
                fcb 1
                fcb 0
                fcb 0

                ;;;;;;;; atan(2^(x/32))*128/pi ;;;;;;;;
                fcb $02,$02,$02,$02,$02,$02,$02,$02 ; 80
                fcb $03,$03,$03,$03,$03,$03,$03,$03
                fcb $03,$03,$03,$03,$03,$04,$04,$04 ; 90
                fcb $04,$04,$04,$04,$04,$04,$04,$04
                fcb $05,$05,$05,$05,$05,$05,$05,$05 ; A0
                fcb $06,$06,$06,$06,$06,$06,$06,$06
                fcb $07,$07,$07,$07,$07,$07,$08,$08 ; B0
                fcb $08,$08,$08,$08,$09,$09,$09,$09
                fcb $09,$0a,$0a,$0a,$0a,$0b,$0b,$0b ; C0
                fcb $0b,$0c,$0c,$0c,$0c,$0d,$0d,$0d
                fcb $0d,$0e,$0e,$0e,$0e,$0f,$0f,$0f ; D0
                fcb $10,$10,$10,$11,$11,$11,$12,$12
                fcb $12,$13,$13,$13,$14,$14,$15,$15 ; E0
                fcb $15,$16,$16,$17,$17,$17,$18,$18
                fcb $19,$19,$19,$1a,$1a,$1b,$1b,$1c ; F0
                fcb $1c,$1c,$1d,$1d,$1e,$1e,$1f,$1f
atan_tab        fcb $00,$00,$00,$00,$00,$00,$00,$00 ; 00
                fcb $00,$00,$00,$00,$00,$00,$00,$00
                fcb $00,$00,$00,$00,$00,$00,$00,$00 ; 10
                fcb $00,$00,$00,$00,$00,$00,$00,$00
                fcb $00,$00,$00,$00,$00,$00,$00,$00 ; 20
                fcb $00,$00,$00,$00,$00,$00,$00,$00
                fcb $00,$00,$00,$00,$00,$00,$00,$00 ; 30
                fcb $00,$00,$00,$00,$00,$00,$00,$00
                fcb $00,$00,$00,$00,$00,$00,$00,$00 ; 40
                fcb $00,$00,$00,$00,$00,$00,$00,$00
                fcb $00,$00,$00,$00,$00,$01,$01,$01 ; 50
                fcb $01,$01,$01,$01,$01,$01,$01,$01
                fcb $01,$01,$01,$01,$01,$01,$01,$01 ; 60
                fcb $01,$01,$01,$01,$01,$01,$01,$01
                fcb $01,$01,$01,$01,$01,$02,$02,$02 ; 70
                fcb $02,$02,$02,$02,$02,$02,$02,$02

                ;;;;;;;; log2(x)*32 ;;;;;;;;
                fcb $df,$e0,$e0,$e1,$e1,$e1,$e2,$e2 ; 80
                fcb $e2,$e3,$e3,$e3,$e4,$e4,$e4,$e5
                fcb $e5,$e5,$e6,$e6,$e6,$e7,$e7,$e7 ; 90
                fcb $e7,$e8,$e8,$e8,$e9,$e9,$e9,$ea
                fcb $ea,$ea,$ea,$eb,$eb,$eb,$ec,$ec ; A0
                fcb $ec,$ec,$ed,$ed,$ed,$ed,$ee,$ee
                fcb $ee,$ee,$ef,$ef,$ef,$ef,$f0,$f0 ; B0
                fcb $f0,$f1,$f1,$f1,$f1,$f1,$f2,$f2
                fcb $f2,$f2,$f3,$f3,$f3,$f3,$f4,$f4 ; C0
                fcb $f4,$f4,$f5,$f5,$f5,$f5,$f5,$f6
                fcb $f6,$f6,$f6,$f7,$f7,$f7,$f7,$f7 ; D0
                fcb $f8,$f8,$f8,$f8,$f9,$f9,$f9,$f9
                fcb $f9,$fa,$fa,$fa,$fa,$fa,$fb,$fb ; E0
                fcb $fb,$fb,$fb,$fc,$fc,$fc,$fc,$fc
                fcb $fd,$fd,$fd,$fd,$fd,$fd,$fe,$fe ; F0
                fcb $fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff
log2_tab        fcb $00,$00,$20,$32,$40,$4a,$52,$59 ; 00
                fcb $60,$65,$6a,$6e,$72,$76,$79,$7d
                fcb $80,$82,$85,$87,$8a,$8c,$8e,$90 ; 10
                fcb $92,$94,$96,$98,$99,$9b,$9d,$9e
                fcb $a0,$a1,$a2,$a4,$a5,$a6,$a7,$a9 ; 20
                fcb $aa,$ab,$ac,$ad,$ae,$af,$b0,$b1
                fcb $b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9 ; 30
                fcb $b9,$ba,$bb,$bc,$bd,$bd,$be,$bf
                fcb $c0,$c0,$c1,$c2,$c2,$c3,$c4,$c4 ; 40
                fcb $c5,$c6,$c6,$c7,$c7,$c8,$c9,$c9
                fcb $ca,$ca,$cb,$cc,$cc,$cd,$cd,$ce ; 50
                fcb $ce,$cf,$cf,$d0,$d0,$d1,$d1,$d2
                fcb $d2,$d3,$d3,$d4,$d4,$d5,$d5,$d5 ; 60
                fcb $d6,$d6,$d7,$d7,$d8,$d8,$d9,$d9
                fcb $d9,$da,$da,$db,$db,$db,$dc,$dc ; 70
                fcb $dd,$dd,$dd,$de,$de,$de,$df,$df
