********************************************************************************
* lotus.input.buffer — buffer circulaire d'inputs en format TO8 natif.
*
* Pattern producteur-consommateur :
*  - IRQ writer (lotus_input.add) : appelé 1× par VBL (50 Hz) depuis UserIRQ.
*    Lit $E7CC (dpad) + $E7CD (fire), masque P1 uniquement,
*    push dans buffer circulaire 16 entrées.
*  - Reader (lotus_input.get) : appelé en boucle depuis Player_Main.
*    Drain le buffer ; chaque entrée = 1 tick physique. Si frame drop,
*    plusieurs ticks rattrapés en 1 tour de boucle → simulation 50 Hz
*    garantie sans perte d'input.
*
* ── Format de l'octet stocké (= TO8 natif, post-coma → 1=pressed) ─────
* Identique aux c1_*_mask de engine/joypad/ReadJoypads.asm :
*   bit 0 = UP            (%00000001)
*   bit 1 = DOWN          (%00000010)
*   bit 2 = LEFT          (%00000100)
*   bit 3 = RIGHT         (%00001000)
*   bit 6 = FIRE (btn A)  (%01000000)
*   bits 4,5,7 = 0 (P2 + btn B masqués → non utilisés ici)
*
* Le sentinel $FF (buffer vide) reste distinct du max possible $4F.
*
* Le consommateur (Lotus_PhysicsTick) teste avec les mêmes masques,
* aucun remap nécessaire.
********************************************************************************

* ─── Buffer circulaire (RAM) ──────────────────────────────────────────
lotus_input.buffer            fill  0,16
lotus_input.write.ptr         fcb   0
lotus_input.read.ptr          fcb   0

* ─── IRQ writer : push un état TO8 P1 (dpad + fire) ───────────────────
* Coût : ~15 cycles. Appelé 1× par UserIRQ.
* Uses : A, B, X, condition codes
lotus_input.add
        * --- Lecture dpad P1 ($E7CC bits 0-3) ---
        lda   $E7CC
        coma                              ; → 1=pressed (convention TO8)
        anda  #%00001111                  ; isole P1 dpad (= c1_dpad)
        tfr   a,b                         ; B = dpad P1

        * --- Lecture fire P1 ($E7CD bit 6 = c1_button_A_mask) ---
        lda   $E7CD
        coma                              ; → 1=pressed
        anda  #%01000000                  ; isole btn A P1
        pshs  b                           ; tmp dpad
        ora   ,s+                         ; A = dpad | fire

        * --- Push A dans buffer à write.ptr ---
        ldb   >lotus_input.write.ptr
        ldx   #lotus_input.buffer
        sta   b,x                         ; buffer[write_ptr] = A
        incb
        andb  #%00001111                  ; wrap 0..15
        stb   >lotus_input.write.ptr
        rts


* ─── Reader : pop un état (ou $FF si buffer vide) ─────────────────────
* Coût : ~20 cycles. Appelé en boucle dans Player_Main.
* Sortie : A = octet TO8 (format c1_*_mask), OU $FF si plus rien
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
