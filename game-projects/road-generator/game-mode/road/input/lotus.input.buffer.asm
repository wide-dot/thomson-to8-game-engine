********************************************************************************
* Lotus input buffer — adaptation de engine/joypad/joypad.buffer.asm
* (= ce que fait rtype) au format INPUT LOTUS (post-FUN_0007abbe).
*
* Pattern producteur-consommateur :
*  - IRQ writer (lotus_input.add) : appelé 1× par VBL (50 Hz) depuis UserIRQ.
*    Lit $E7CC (dpad) + $E7CD (fire), remappe les bits au format Lotus,
*    push dans buffer circulaire 16 entrées.
*  - Reader (lotus_input.get) : appelé en boucle depuis Player_Main.
*    Drain le buffer ; chaque entrée = 1 tick physique. Si frame drop,
*    plusieurs ticks rattrapés en 1 tour de boucle → simulation 50 Hz
*    garantie sans perte d'input.
*
* ── Format de l'octet stocké (= format Lotus) ─────────────────────────
*   bit 0 = LEFT
*   bit 1 = RIGHT
*   bit 2 = DOWN
*   bit 3 = UP
*   bit 4 = FIRE (= bouton A joypad TO8)
*   bits 5..7 = 0
*
* ── Mapping TO8 → Lotus (fait UNE fois à l'IRQ writer) ────────────────
*   TO8 $E7CC (dpad, après coma) :     Lotus :
*     bit 0 = UP                    →   bit 3
*     bit 1 = DOWN                  →   bit 2
*     bit 2 = LEFT                  →   bit 0
*     bit 3 = RIGHT                 →   bit 1
*   TO8 $E7CD (fire, après coma) :
*     bit 6 = btn A joypad 1         →   bit 4
********************************************************************************

* ─── Buffer circulaire (RAM) ──────────────────────────────────────────
lotus_input.buffer            fill  0,16
lotus_input.write.ptr         fcb   0
lotus_input.read.ptr          fcb   0

* ─── IRQ writer : push un état remappé Lotus ──────────────────────────
* Coût : ~30 cycles. Appelé 1× par UserIRQ.
* Uses : A, B, X, condition codes
lotus_input.add
        ldx   #lotus_input.buffer
        ldb   >lotus_input.write.ptr

        * --- Lecture dpad TO8 ($E7CC) ---
        lda   $E7CC                       ; raw, 0=pressed (inversé)
        coma                              ; → 1=pressed (TO8 convention)
        ; A = %XXXXRLDU (TO8 P1) avec X=joypad2

        * --- Remap TO8 → Lotus : UP↔bit3, DOWN↔bit2 (LEFT/RIGHT déjà OK) ---
        * Astuce : on swap les bits 0 (UP) et 1 (DOWN) ↔ 2/3, mais en fait
        * la transformation est :
        *   Lotus bit 0 = TO8 bit 2 (LEFT)
        *   Lotus bit 1 = TO8 bit 3 (RIGHT)
        *   Lotus bit 2 = TO8 bit 1 (DOWN)
        *   Lotus bit 3 = TO8 bit 0 (UP)
        * → on swap les 2 paires (bits 0↔3 et 1↔2) via XOR sur table.
        anda  #%00001111                  ; isole P1 dpad
        ; mapping inline via bit-tests successifs :
        clrb                              ; B = résultat Lotus
        bita  #%00000100                  ; TO8 bit 2 = LEFT ?
        beq   @noL
        orb   #%00000001                  ; → Lotus bit 0
@noL    bita  #%00001000                  ; TO8 bit 3 = RIGHT ?
        beq   @noR
        orb   #%00000010                  ; → Lotus bit 1
@noR    bita  #%00000010                  ; TO8 bit 1 = DOWN ?
        beq   @noD
        orb   #%00000100                  ; → Lotus bit 2
@noD    bita  #%00000001                  ; TO8 bit 0 = UP ?
        beq   @noU
        orb   #%00001000                  ; → Lotus bit 3
@noU
        * --- Fire bouton A ($E7CD bit 6 = c1_button_A_mask) ---
        lda   $E7CD
        coma                              ; 1=pressed
        bita  #%01000000                  ; TO8 c1_button_A_mask
        beq   @noFire
        orb   #%00010000                  ; → Lotus bit 4
@noFire

        * --- Push B dans buffer à write.ptr ---
        tfr   b,a                         ; A = octet Lotus à push
        ldb   >lotus_input.write.ptr      ; reload B = write index
        stx   ,--s                        ; save X
        ldx   #lotus_input.buffer
        sta   b,x                         ; buffer[write_ptr] = A
        leax  ,s++                        ; restore (et discard X)
        incb
        andb  #%00001111                  ; wrap 0..15
        stb   >lotus_input.write.ptr
        rts


* ─── Reader : pop un état Lotus (ou $FF si buffer vide) ───────────────
* Coût : ~20 cycles. Appelé en boucle dans Player_Main.
* Sortie : A = octet Lotus, OU $FF si plus rien
* Uses : A, B, X, condition codes
lotus_input.get
        ldb   >lotus_input.read.ptr
        cmpb  >lotus_input.write.ptr
        beq   @empty
        ldx   #lotus_input.buffer
        lda   b,x
        incb
        andb  #%00001111
        stb   >lotus_input.read.ptr
        rts
@empty
        lda   #$FF
        rts
