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
gfxlock.backBuffer.id      fcb   0 ; back buffer set to write operations (0 or 1)

gfxlock.frameDrop.count_w  fcb   0 ; zero pad
gfxlock.frameDrop.count    fcb   0 ; elapsed 50Hz frames since last main game loop
gfxlock.frame.count        fdb   0 ; elapsed 50Hz frames since init
gfxlock.frame.lastCount    fdb   0 ; elapsed 50Hz frames at last main game loop

* =============================================================================
* macros
* =============================================================================

_gfxlock.init MACRO
        lda   #-1
        sta   gfxlock.gfx.status
 ENDM

_gfxlock.on MACRO
        lda   gfxlock.gfx.status
        bne   >
        jsr   gfxlock.wait             ; wait if second gfx frame is reached
!       lda   #1
        sta   gfxlock.gfx.status
 ENDM

_gfxlock.off MACRO
        clr   gfxlock.gfx.status
 ENDM

_gfxlock.backProcess.on MACRO
        ; param 1 : routine address
        ldd   #\1
        std   gfxlock.backProcess
        lda   #1
        sta   gfxlock.backProcess.status
 ENDM

_gfxlock.backProcess.off MACRO
        clr   gfxlock.backProcess.status
 ENDM

* =============================================================================
* routines
* =============================================================================

gfxlock.bufferSwap.check
        lda   gfxlock.status
        bne   >
        jsr   gfxlock.bufferSwap.do    ; swap only when gfx was redered
        _gfxlock.init
!       rts

gfxlock.bufferSwap.do
        ldb   @flip
        andb  #%01000000               ; set bit 6 based on flip/flop
        orb   #%10000000               ; set bit 7=1, bit 0-3=frame color
gfxlock.screenBorder.color equ *-1
        stb   map.CF74021.SYS2         ; set visible video buffer (2 or 3)
        com   @flip
        ldb   #$00
@flip   equ   *-1
        andb  #%00000001               ; set bit 0 based on flip/flop
        stb   gfxlock.backBuffer.id              ; video back buffer is 0 or 1
        orb   #%00000010               ; set bit 1=1
        stb   map.CF74021.DATA         ; mount working video buffer in visible RAM
        ldb   map.MC6846.PRC
        eorb  #%00000001               ; swap half-page in $4000 $5FFF
        stb   map.MC6846.PRC
        
        inc   gfxlock.bufferSwap.count+1
        bne   >
        inc   gfxlock.bufferSwap.count
!
        ldd   gfxlock.frame.count
        subd  gfxlock.frame.lastCount
        stb   gfxlock.frameDrop.count  ; store the number of elapsed 50Hz frames since last main game loop

        ldd   gfxlock.frame.count
        std   gfxlock.frame.lastCount
        com   gfxlock.swap.status
        rts

gfxlock.bufferSwap.wait
        clr   gfxlock.swap.status
@loop   tst   gfxlock.backProcess.status
        bne   >
        jsr   #$1234                    ; do some back processing
gfxlock.backProcess.routine equ *-2
!       tst   gfxlock.swap.status
        beq   @loop                     ; loop until irq make a swap
        rts
