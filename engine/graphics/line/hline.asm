; -----------------------------------------------------------------------------
; hline.draw
; -----------------------------------------------------------------------------
; input  REG : [A] line number to draw (0-199)
; input  REG : [X] 4bit color repeated 4 times (ex: $FFFF for color 15)
; -----------------------------------------------------------------------------
; draw a line in video memory
; -----------------------------------------------------------------------------
hline.draw
        ; setup position
        pshs  dp,a
        inca
        ldb   #40 ; byte per line
        mul
        ldu   #$A000
        leau  d,u

        ; setup color
        leay  ,x
        tfr   x,d
        tfr   a,dp

        pshu  y,x,dp,b,a
        pshu  y,x,dp,b,a
        pshu  y,x,dp,b,a
        pshu  y,x,dp,b,a
        pshu  y,x,dp,b,a
        pshu  y,x,dp
        leau  $2028,u
        pshu  y,x,dp,b,a
        pshu  y,x,dp,b,a
        pshu  y,x,dp,b,a
        pshu  y,x,dp,b,a
        pshu  y,x,dp,b,a
        pshu  y,x,dp
        puls  a,dp,pc
