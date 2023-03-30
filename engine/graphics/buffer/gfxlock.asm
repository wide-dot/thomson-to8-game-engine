********************************************************************************
* double buffering gfx write lock
* ------------------------------------------------------------------------------
*
* Page affichee par l'automate Video
* ----------------------------------
*   $E7DD determine la page affichee a l'ecran
*   bit7=0 bit6=0 bit5=0 bit4=0 (#$0_) : page 0
*   bit7=0 bit6=1 bit5=0 bit4=0 (#$4_) : page 1
*   bit7=1 bit6=0 bit5=0 bit4=0 (#$8_) : page 2
*   bit7=1 bit6=1 bit5=0 bit4=0 (#$C_) : page 3
*   bit3 bit2 bit1 bit0  (#$_0 a #$_F) : couleur du cadre
*   Remarque : bit5 et bit4 utilisable uniquement en mode MO
*
* Page en espace cartouche
* ------------------------
*   $E7E6 determine la page visible dans l'espace cartouche (0000 a 3FFF)
*   bit7 toujours a 0
*   bit6=1 : ecriture autorisee
*   bit5=1 : espace cartouche recouvert par de la RAM
*   bit4=0 : CAS1N valide : banques 0-15 / 1 = CAS2N valide : banques 16-31
*   bit5=1 bit4=0 bit3=0 bit2=0 bit1=0 bit0=0 (#$60) : page 0
*   ...
*   bit5=1 bit4=0 bit3=1 bit2=1 bit1=1 bit0=1 (#$6F) : page 15
*   bit5=1 bit4=1 bit3=0 bit2=0 bit1=0 bit0=0 (#$70) : page 16
*   ...
*   bit5=1 bit4=1 bit3=1 bit2=1 bit1=1 bit0=1 (#$7F) : page 31
*
* Demi-Page 0 en espace ecran (4000 a 5FFF)
* -----------------------------------------
*   $E7C3 determine la demi-page de la page 0 visible dans l'espace ecran
*   bit0=0 : 8Ko RAMA
*   bit0=1 : 8ko RAMB
*
* Page en espace donnees
* ----------------------
* lda   #$04
* sta   $E7E5                    * selection de la page 04 en RAM Donnees (A000-DFFF)
*
********************************************************************************

* ===========================================================================
* macros
* ===========================================================================

_gfxlock.init MACRO
        lda   #-1
        sta   gfxlock.status
 ENDM

_gfxlock.set MACRO
        lda   gfxlock.status
        bne   >
        jsr   gfxlock.wait
        ; ... switch buffer and set flags here
        ; ...
!       lda   #1
        sta   gfxlock.status
 ENDM

_gfxlock.unset MACRO
        clr   gfxlock.status
 ENDM

* ===========================================================================
* variables
* ===========================================================================

gfxlock.status         fcb   0 ; user must set this lock during gfx writes to video buffer
gfxlock.irq.status     fcb   0
gfxlock.wait.status    fcb   0

buffer.swapcount       fdb   0 ; buffer swap counter
buffer.back            fcb   0 ; back buffer set to write operations (0 or 1)

frame.duration_w       fcb   0 ; zero pad
frame.duration         fcb   0 ; elapsed 50Hz frames since last main game loop
frame.runcount         fdb   0 ; incremented in 50Hz IRQ
frame.lastruncount     fdb   0 ; used to compute duration

* ===========================================================================
* routines
* ===========================================================================

gfxlock.irq
        lda   gfxlock.irq.status
        bne   @irqlock
        lda   gfxlock.status
        bne   >
        jsr   gfxlock.swapbuffer
        _gfxlock.init
!       rts
@irqlock        
        clr   gfxlock.irq.status
        rts


gfxlock.swapbuffer
        ldb   @flip
        andb  #%01000000               ; set bit 6 based on flip/flop
        orb   #%10000000               ; set bit 7=1, bit 0-3=frame color
screen.bordercolor equ *-1
        stb   CF74021.SYS2             ; set visible video buffer (2 or 3)
        com   @flip
        ldb   #$00
@flip   equ   *-1
        andb  #%00000001               ; set bit 0 based on flip/flop
        stb   buffer.back              ; video back buffer is 0 or 1
        orb   #%00000010               ; set bit 1=1
        stb   CF74021.DATA             ; mount working video buffer in visible RAM
        ldb   MC6846.PRC
        eorb  #%00000001               ; swap half-page in $4000 $5FFF
        stb   MC6846.PRC
        
        inc   buffer.swapcount+1
        bne   >
        inc   buffer.swapcount  
!
        ldd   frame.runcount
        subd  frame.lastruncount
        stb   frame.duration           ; store the number of elapsed 50Hz frames since last main game loop

        ldd   frame.runcount
        std   frame.lastruncount
        rts

gfxlock.wait
        lda   #1
        sta   gfxlock.wait.status
!       tst   CF74021.SYS1             ; beam is not visible
        bpl   <                        ; loop until visible
!       tst   CF74021.SYS1             ; beam is visible
        bmi   <                        ; loop until not visible
        clr   gfxlock.wait.status
        rts

