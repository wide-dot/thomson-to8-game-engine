********************************************************************************
* Clear memory in data area (16Ko), but only in video RAMA or RAMB range
* INPUT :
* [A] : =0 RAMA !=0 RAMB
* [X] : word that will be copied in the whole page
********************************************************************************

RAMA equ 1
RAMB equ 0

ClearDataMemRAMx
        pshs  u,y,x,dp,b,a
        tsta
        beq   @rama
@ramb
        lda   #$DF
        sta   @start
        lda   #$C0
        sta   @end
        bra   @run
@rama
        lda   #$BF
        sta   @start
        lda   #$A0
        sta   @end
@run
        sts   @s
        lds   #$BF40
@start  equ   *-2
        leau  ,x
        leay  ,x
        tfr   x,d
        tfr   a,dp
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y
@loop
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x,dp,b,a
        pshs  u,y,x
        cmps  #$A010
@end    equ   *-2                        
        bne   @loop
        leau  ,s        
        lds   #$0000        ; start of memory should not be written with S as an index because of IRQ        
@s      equ   *-2
        pshu  d,x,y         ; saving 12 bytes + (2 bytes * _sr calls) inside IRQ routine
        pshu  d,x,y         ; DEPENDENCY on nb of _sr calls inside IRQ routine (here 16 bytes of margin)
        pshu  d,x
        puls  a,b,dp,x,y,u,pc
