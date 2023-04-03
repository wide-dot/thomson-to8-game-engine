*******************************************************************************
* double buffering gfx write lock
* -----------------------------------------------------------------------------
*
* Swap buffers with a 50hz irq, when beam is near VBL.
* gfxlock.irq should be called by user irq routine.
*
* To tell engine when gfx rendering begins or ends, the user uses macros :
* _gfxlock.init : should be called before irq starts
* _gfxlock.on   : should be called before entering rendering routines
* _gfxlock.off : should be called as soon as rendering is over for a frame
*
* A wait routine will only runs if a second gfx rendering lock is set during
* a single screen frame. User can set a back process routine during wait.
*
* Irq must be in sync with VBL to avoid palette change artifacts.
*
*******************************************************************************

* =============================================================================
* variables
* =============================================================================

gfxlock.status             fcb   0 ; 1: gfx rendering is running
gfxlock.bufferSwap.status  fcb   0 ; -1: a swap buffer was made
gfxlock.backProcess.status fcb   0 ; 1: a back process is active during wait

gfxlock.bufferSwap.count   fdb   0 ; buffer swap counter
gfxlock.backBuffer.id      fcb   0 ; back buffer set to read operations (0 or 1)

gfxlock.frameDrop.count_w  fcb   0 ; zero pad
gfxlock.frameDrop.count    fcb   0 ; elapsed 50Hz frames since last main game loop
gfxlock.frame.count        fdb   0 ; elapsed 50Hz frames since init
gfxlock.frame.lastCount    fdb   0 ; elapsed 50Hz frames at last main game loop

* =============================================================================
* routines
* =============================================================================

gfxlock.bufferSwap.check
        lda   gfxlock.status
        bne   >
        jsr   gfxlock.bufferSwap.do    ; swap only when gfx was redered
        lda   #-1
        sta   gfxlock.status
!       rts

gfxlock.bufferSwap.do
        ldb   gfxlock.backBuffer.status
        andb  #%01000000               ; set bit 6 based on flip/flop
        orb   #%10000000               ; set bit 7=1, bit 0-3=frame color
gfxlock.screenBorder.color equ *-1
        stb   map.CF74021.SYS2         ; set visible video buffer (2 or 3)
        com   gfxlock.backBuffer.status
        ldb   #$00
gfxlock.backBuffer.status equ   *-1
        andb  #%00000001               ; set bit 0 based on flip/flop
        orb   #%00000010               ; set bit 1=1
        stb   map.CF74021.DATA         ; mount working video buffer in visible RAM
        ldb   map.MC6846.PRC
        eorb  #%00000001               ; swap half-page in $4000 $5FFF
        stb   map.MC6846.PRC
        
        inc   gfxlock.bufferSwap.count+1
        bne   >
        inc   gfxlock.bufferSwap.count
!
        com   gfxlock.bufferSwap.status
        rts

gfxlock.bufferSwap.wait
        clr   gfxlock.bufferSwap.status
@loop   tst   gfxlock.backProcess.status
        beq   >
        jsr   $1234                     ; do some back processing
gfxlock.backProcess.routine equ *-2
!       lda   gfxlock.status
        bne   >
        tst   gfxlock.bufferSwap.status
        beq   @loop                     ; loop until irq make a swap
!       rts
