* ---------------------------------------------------------------------------
; Draw an horizontal line for 320x200x16 mode
; -------------------------------------------
;
; !!! UNIFINISHED !!!
;
; p0: x MSB
; p1: x LSB
; p2: y
; p3: nb of pixels to draw MSB
; p4: nb of pixels to draw LSB
; p5: color 0 (s0000bvr)
; p6: color 1 (0sbvr000)
* ---------------------------------------------------------------------------

p0          equ   dp_engine
p1          equ   dp_engine+1
p2          equ   dp_engine+2
p3          equ   dp_engine+3
p4          equ   dp_engine+4
p5          equ   dp_engine+5
p6          equ   dp_engine+6
dhl_routine equ   dp_engine+7

DrawHLine
        ldb   p2                       ; load y pos
        lda   #40
        mul
        addd  #$A000                   ; set u at RAMA line (pixel def)
        tfr   d,u

        ldd   p0                       ; load x pos / 8
        _asrd
        _asrd
        _asrd
        leau  d,u                      ; u point to first byte to write in RAMB (color)

        anda  #0
        sta   DHL_lnl
        ldb   p1
        andb  #%00000111               ; get offset in 8px chunk
        beq   DHL_Center

DHL_Left
        stb   @b
        lda   #8
        suba  #0                       ; a contains max len in chunk
@b      equ   *-1
        sta   DHL_lnl
        ldx   p3
        cmpx  #0
DHL_lnl equ   *-1
        bls   DHL_Left_Only
        ldx   #left_px
        asla
        ldx   a,x                      ; load table for a len of px
        lda   b,x                      ; load pixel pattern from pos
        sta   $2000,u                  ; update pixels on screen

        ldb   ,u
        andb  #%10000111               ; clear color 1
        orb   p6                       ; apply color 1
        stb   ,u+        

DHL_Center
        ldd   p3
        subd  DHL_lnl-1                ; compute nb of remaining pixels to draw
        _asrd
        asrb
        asrb                           ; number of 8px groups
        beq   DHL_Right
        cmpb  #1
        bne   @fast
        lda   #0
        ldb   p5
        sta   $2000,u                  ; draw one plain chunk
        stb   ,u+
        bra   DHL_Right
@fast   leau  b,u
        stu   @u
        leau  $2000,u
        aslb
        ldx   #DHL_pshu
        ldx   b,x                      ; load compiled draw routine
        stx   dhl_routine
        ldd   #0
        ldx   #0
        leay  ,x
        jsr   [dhl_routine]
        ldu   #0
@u      equ   *-2
        lda   p5
        ldb   p5
        tfr   d,x
        leay  ,x
        jsr   [dhl_routine]
        ldu   @u

        ; draw right chunk
DHL_Right
        ldb   p4
        subb  DHL_lnl
        andb  #%00000111
        beq   @end
        ;
        ldx   #right_px
        lda   b,x                      ; load pixel pattern from len
        sta   $2000,u                  ; update pixels on screen
        ;
        ldb   ,u
        andb  #%10000111               ; clear color 1
        orb   p6                       ; apply color 1
        stb   ,u        
@end    rts
       
DHL_Left_Only
        lda   p4                       ; need to draw only one Chunk
        asla
        ldx   #left_px
        ldx   a,x                      ; load table for a len of px
        lda   b,x                      ; load pixel pattern from pos
        sta   $2000,u                  ; update pixels on screen
        ;
        ldb   ,u
        andb  #%10000111               ; clear color 1
        orb   p6                       ; apply color 1
        stb   ,u        
        rts
        
left_px
        fdb   0                        ; unused
        fdb   left_px_1
        fdb   left_px_2
        fdb   left_px_3
        fdb   left_px_4
        fdb   left_px_5
        fdb   left_px_6
        fdb   left_px_7

left_px_1
        fcb   %10000000
        fcb   %01000000
        fcb   %00100000
        fcb   %00010000
        fcb   %00001000
        fcb   %00000100
        fcb   %00000010
        fcb   %00000001
        
left_px_2
        fcb   %11000000
        fcb   %01100000
        fcb   %00110000
        fcb   %00011000
        fcb   %00001100
        fcb   %00000110
        fcb   %00000011

left_px_3
        fcb   %11100000
        fcb   %01110000
        fcb   %00111000
        fcb   %00011100
        fcb   %00001110
        fcb   %00000111

left_px_4
        fcb   %11110000
        fcb   %01111000
        fcb   %00111100
        fcb   %00011110
        fcb   %00001111

left_px_5
        fcb   %11111000
        fcb   %01111100
        fcb   %00111110
        fcb   %00011111

left_px_6
        fcb   %11111100
        fcb   %01111110
        fcb   %00111111

left_px_7
        fcb   %11111110
        fcb   %01111111

right_px
        fcb   %00000000                ; unused
        fcb   %10000000
        fcb   %11000000
        fcb   %11100000
        fcb   %11110000
        fcb   %11111000
        fcb   %11111100
        fcb   %11111110

DHL_pshu
        fdb   0                        ; unused
        fdb   @l1
        fdb   @l2
        fdb   @l3
        fdb   @l4
        fdb   @l5
        fdb   @l6
        fdb   @l7
        fdb   @l8
        fdb   @l9
        fdb   @l10
        fdb   @l11
        fdb   @l12
        fdb   @l13
        fdb   @l14
        fdb   @l15
        fdb   @l16
        fdb   @l17
        fdb   @l18
        fdb   @l19
        fdb   @l20
        fdb   @l21
        fdb   @l22
        fdb   @l23
        fdb   @l24
        fdb   @l25
        fdb   @l26
        fdb   @l27
        fdb   @l28
        fdb   @l29
        fdb   @l30
        fdb   @l31
        fdb   @l32
        fdb   @l33
        fdb   @l34
        fdb   @l35
        fdb   @l36
        fdb   @l37
        fdb   @l38
        fdb   @l39
        fdb   @l40
@l35    pshu  d,x,y
@l29    pshu  d,x,y
@l23    pshu  d,x,y
@l17    pshu  d,x,y
@l11    pshu  d,x,y
@l5     pshu  a,x,y
        rts
@l36    pshu  d,x,y
@l30    pshu  d,x,y
@l24    pshu  d,x,y
@l18    pshu  d,x,y
@l12    pshu  d,x,y
@l6     pshu  d,x,y
        rts
@l37    pshu  d,x,y
@l31    pshu  d,x,y
@l25    pshu  d,x,y
@l19    pshu  d,x,y
@l13    pshu  d,x,y
@l7     pshu  d,x,y
@l1     pshu  a
        rts
@l38    pshu  d,x,y
@l32    pshu  d,x,y
@l26    pshu  d,x,y
@l20    pshu  d,x,y
@l14    pshu  d,x,y
@l8     pshu  d,x,y
@l2     pshu  d
        rts
@l39    pshu  d,x,y
@l33    pshu  d,x,y
@l27    pshu  d,x,y
@l21    pshu  d,x,y
@l15    pshu  d,x,y
@l9     pshu  d,x,y
@l3     pshu  a,x  
        rts
@l40    pshu  d,x,y
@l34    pshu  d,x,y
@l28    pshu  d,x,y
@l22    pshu  d,x,y
@l16    pshu  d,x,y
@l10    pshu  d,x,y
@l4     pshu  d,x  
        rts