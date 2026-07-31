 opt c

; ---------------------------------------------------------------------------
; GAME MODE fadetest - banc de mesure du fondu pixel (engine/graphics/fade)
; ---------------------------------------------------------------------------
; But : determiner si l'algorithme de fondu, seul, efface 100 % des DEUX pages
; video, ou s'il lui manque un "step". Isole du code R-Type : meme double
; buffering (gfxlock + IRQ 50 Hz), meme cadence d'un FadeOut par tour de boucle,
; mais RIEN d'autre ne dessine (pas de sprite, pas de tilemap, pas de restauration
; de fond). Si du residu subsiste ici, le defaut est dans le fondu lui-meme ;
; s'il n'y en a pas, il vient de l'integration dans R-Type.
;
; Protocole, repete pour extraStep = 1 puis 0 :
;   1. remplir les DEUX pages video de $FF (tous les demi-octets a la couleur 15)
;   2. armer FadeCnt = FadeLen*2 + extraStep
;   3. boucler : gfxlock.on / FadeOut / gfxlock.off / gfxlock.loop
;   4. quand FadeCnt == 0, balayer les deux pages et compter les octets non nuls
;
; Resultats laisses en RAM (voir bloc test.* ci-dessous), lisibles depuis toje.
; test.done passe a $A5 quand les deux passes sont finies.
; ---------------------------------------------------------------------------

        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/system/to8/map.const.asm"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./global/macro.asm"
        INCLUDE "./global/variables.asm"

viewport_width  equ 144
viewport_height equ 180

SCREEN_BYTES    equ 8000       ; 40 octets x 200 lignes, par plan
FILL_VALUE      equ $FF        ; tous les demi-octets a la couleur 15

        org   $6100

Start
        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct

        lda   #GmID_fadetest
        sta   glb_Cur_Game_Mode

        ; --- IRQ + double buffering, exactement comme le game-mode 01 ---
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; sync hors affichage (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init
        clr   gfxlock.frameDrop.max    ; pas de plafond : on ne veut rien masquer
        jsr   IrqOn

        ; ===== passe 1 : extraStep = 1 (comportement R-Type actuel) =====
        lda   #1
        sta   test.extraStep
        ldx   #test.run1
        stx   test.out
        bsr   RunOnePass

        ; ===== passe 2 : extraStep = 0 =====
        lda   #0
        sta   test.extraStep
        ldx   #test.run2
        stx   test.out
        bsr   RunOnePass

        lda   #$A5
        sta   test.done
        jsr   IrqOff
Halt    bra   Halt

; ---------------------------------------------------------------------------
; RunOnePass - remplit, fond, compte. test.out pointe le bloc resultat (8 o) :
;   +0 steps (word)  +2 remain (word)  +4 firstAddr (word)  +6 firstPage / firstVal
; ---------------------------------------------------------------------------
RunOnePass
        bsr   FillBothPages

        bsr   CountBothPages           ; TEMOIN : sans lui, un remplissage rate
        ldd   test.remain              ;   donnerait remain=0 et un faux "tout efface"
        std   test.filled

        ldb   #FadeLen*2               ; armer le compteur du fondu
        addb  test.extraStep
        stb   FadeCnt
        ldd   #0
        std   test.steps

@loop
        jsr   gfxlockOn
        lda   FadeCnt
        beq   @tail                    ; fondu termine : on ne compte pas ce tour
        jsr   FadeOut
        ldd   test.steps
        addd  #1
        std   test.steps
@tail
        jsr   gfxlockOff
        jsr   gfxlockLoop
        lda   FadeCnt
        bne   @loop

        bsr   CountBothPages

        ldx   test.out                 ; publier le resultat
        ldd   test.steps
        std   ,x
        ldd   test.remain
        std   2,x
        ldd   test.firstAddr
        std   4,x
        lda   test.firstPage
        sta   6,x
        lda   test.firstVal
        sta   7,x
        ldd   test.filled
        std   8,x
        rts

; ---------------------------------------------------------------------------
; FillBothPages - $FF sur les 2 plans des 2 pages video (hors verrou graphique)
; ---------------------------------------------------------------------------
FillBothPages
        ldb   #2
        bsr   @onePage
        ldb   #3
@onePage
        stb   map.CF74021.DATA
        ldx   #$A000
        bsr   @fill
        ldx   #$C000
@fill
        ldd   #SCREEN_BYTES
        std   test.cnt
        lda   #FILL_VALUE
@l      sta   ,x+
        ldd   test.cnt
        subd  #1
        std   test.cnt
        bne   @l
        rts

; ---------------------------------------------------------------------------
; CountBothPages - compte les octets non nuls, memorise le premier rencontre
; ---------------------------------------------------------------------------
CountBothPages
        ldd   #0
        std   test.remain
        std   test.firstAddr
        clr   test.firstSet
        clr   test.firstVal
        clr   test.firstPage

        ldb   #2
        bsr   @onePage
        ldb   #3
@onePage
        stb   map.CF74021.DATA
        stb   test.curPage
        ldx   #$A000
        bsr   @scan
        ldx   #$C000
@scan
        ldd   #SCREEN_BYTES
        std   test.cnt
@l      lda   ,x+
        beq   @next
        pshs  a
        ldd   test.remain              ; un demi-octet au moins n'a pas ete efface
        addd  #1
        std   test.remain
        tst   test.firstSet
        bne   @seen
        inc   test.firstSet
        leax  -1,x                     ; memoriser l'adresse exacte
        stx   test.firstAddr
        leax  1,x
        lda   ,s
        sta   test.firstVal
        lda   test.curPage
        sta   test.firstPage
@seen   puls  a
@next
        ldd   test.cnt
        subd  #1
        std   test.cnt
        bne   @l
        rts

; ---------------------------------------------------------------------------
; Enveloppes gfxlock (les macros ne sont pas appelables directement)
; ---------------------------------------------------------------------------
gfxlockOn
        _gfxlock.on
        rts
gfxlockOff
        _gfxlock.off
        rts
gfxlockLoop
        _gfxlock.loop
        rts

* ---------------------------------------------------------------------------
* MAIN IRQ
* ---------------------------------------------------------------------------
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jmp   PalUpdateNow

* ---------------------------------------------------------------------------
* Resultats du banc - a lire depuis toje
* ---------------------------------------------------------------------------
test.done       fcb 0   ; $A5 quand les deux passes sont terminees
test.extraStep  fcb 0
test.out        fdb 0
test.steps      fdb 0
test.remain     fdb 0
test.firstAddr  fdb 0
test.firstVal   fcb 0
test.firstPage  fcb 0
test.firstSet   fcb 0
test.curPage    fcb 0
test.filled     fdb 0   ; temoin : octets non nuls juste apres le remplissage
test.cnt        fdb 0

test.run1       fill 0,10  ; extraStep=1 : steps, remain, firstAddr, page, val, filled
test.run2       fill 0,10  ; extraStep=0 : idem

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        INCLUDE "./game-mode/fadetest/ram_data.asm"

* ---------------------------------------------------------------------------
* ENGINE routines
* ---------------------------------------------------------------------------
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/irq/Irq.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"

        ; le fondu teste, tel quel
        INCLUDE "./engine/graphics/fade/pixel-fade.asm"

        ; should be at the end of includes (ifdef dependencies)
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"
