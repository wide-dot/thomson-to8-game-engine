# IRQ init et synchronisation

## `IrqInit`

```asm
IrqInit
        ldd   #IrqManager
        std   TIMERPT                   ; vecteur IRQ = IrqManager
        rts
```

`TIMERPT` est le vecteur IRQ système du Thomson TO8 (adresse mémoire fixe). En y plaçant `IrqManager`, on s'assure que toute IRQ générée par le timer 6846 sautera dans notre routine.

## `IrqSet50Hz`

```asm
IrqSet50Hz
        ldb   #$42
        stb   MC6846.TCR                ; timer precision x8
        ldd   #Irq_one_frame
        std   MC6846.TMSB               ; timer reload value
        jsr   IrqOn
        rts
```

Configure le timer 6846 pour une IRQ par frame (50 Hz).

### MC6846.TCR (Timer Control Register)

```
Bits :    0 1 2 3 4 5 6 7
          | | | | | | | |
          | | | | | | | └─ pre-set (1) ou pré-set hold (0)
          | | | | | | └─── timer enable (1)
          | | | | | └───── interrupt enable (1)
          | | | | └─────── interrupt mode (1=internal)
          | | | └───────── output ?
          | | └─────────── pre-scaler ÷8 (1) ou ÷1 (0)
          | └───────────── output ?
          └─────────────── ?
```

`$42 = %01000010` :
- bit 1 : timer enable
- bit 6 : pre-scaler ÷8 (?) (à vérifier)

### `Irq_one_frame`

```asm
Irq_one_frame    equ 312*64-1
Irq_one_line     equ 64
```

- **312 lignes** par frame (mode PAL)
- **64 cycles** par ligne (à 1 MHz)
- `-1` car le timer compte 0 → -1 → reload

= 19967 cycles (~ 20 ms)

## `IrqSync`

Synchronise le timer avec une **ligne écran spécifique**. Utile pour les effets raster ou pour aligner l'IRQ sur le VBL.

```asm
IrqSync                                 ; A=ligne (0-255), X=timer value
        ; ... attend que le spot soit à la ligne A ...
        stx   MC6846.TMSB               ; charge le nouveau timer
        rts
```

Usage :
```asm
        lda   #255                      ; sync ligne 255 (~ fin de frame, VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
```

L'IRQ se déclenchera désormais à la ligne 255 — c'est-à-dire **pendant le VBL** (les lignes 256-311 sont hors zone visible). C'est le moment idéal pour :
- Modifier la palette sans tearing
- Swap les buffers vidéo (gfxlock)
- Modifier les registres vidéo

### Pattern recommandé

```asm
        jsr   IrqInit                   ; pointeur vers IrqManager
        ldd   #UserIRQ                  ; notre routine
        std   Irq_user_routine
        lda   #255                      ; sync VBL
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init                   ; init double buffer (après sync)
        jsr   IrqOn                     ; enable IRQ
```

## `IrqOn` / `IrqOff`

```asm
IrqOn
        lda   $6019                     ; STATUS register
        ora   #$20                      ; bit 5 = IRQ enable
        sta   $6019
        andcc #$EF                      ; clear flag I (CPU)
        rts

IrqOff
        lda   $6019
        anda  #$DF                      ; bit 5 = 0
        sta   $6019
        orcc  #$10                      ; set flag I (CPU mask IRQ)
        rts
```

### `$6019` — STATUS register

`$6019` est le registre de statut système (?) du TO8. Bit 5 = IRQ enable.

### Flag I du CPU 6809

Le 6809 a un flag I (Interrupt) dans le registre CC :
- `I = 0` : IRQ enabled (CPU les accepte)
- `I = 1` : IRQ masked (CPU les ignore)

`andcc #$EF` clear le bit 4 ($10) → I = 0 (enable).
`orcc #$10` set le bit 4 → I = 1 (mask).

## `IrqPause` / `IrqUnpause` — stack-safe

```asm
IrqPause
        pshs  a
        lda   $6019
        anda  #$20
        bne   @irqoff                   ; était activé
        lda   #0
        sta   @irqst                    ; mémorise "était off"
        bra   >
@irqoff lda   #1
        sta   @irqst                    ; mémorise "était on"
        jsr   IrqOff
!       puls  a,pc

IrqUnpause
        pshs  a
        lda   #0
@irqst  equ   *-1                       ; lit l'état mémorisé
        beq   >                         ; était off → reste off
        jsr   IrqOn                     ; était on → restore
!       clr   @irqst
        puls  a,pc
```

Pattern d'usage :
```asm
        jsr   IrqPause                  ; off + remember
        ; section critique : accès hardware sensible
        ; pas d'IRQ pendant ce code
        jsr   IrqUnpause                ; restore previous state
```

L'état précédent est stocké dans `@irqst` (variable interne). Permet d'imbriquer plusieurs sections sans perdre l'état initial.

## Cycle complet d'IRQ

```
1. CPU exécute une instruction
2. Timer 6846 atteint 0
3. Hardware déclenche IRQ
4. CPU :
   - Sauve PC, U, Y, X, DP, B, A, CC sur la pile S (auto)
   - I bit = 1 (mask further IRQ)
   - Saute à l'adresse en TIMERPT = IrqManager
5. IrqManager :
   - Pre-hooks engine (read joypads, etc.)
   - jsr [Irq_user_routine] = UserIRQ
   - Post-hooks engine
6. rti :
   - Restore PC, U, Y, X, DP, B, A, CC depuis la pile
   - I bit restoré (= 0 typiquement)
7. CPU reprend l'instruction interrompue
```

Coût total : ~50-100 cycles pour le manager + cycles UserIRQ.

## Calcul de fréquence

À 1 MHz et `Irq_one_frame = 19967` :
```
fréquence = 1000000 / 19968 ≈ 50.08 Hz
```

Suffisamment proche de 50 Hz pour synchroniser avec le VBL PAL.

Pour 60 Hz : `Irq_one_frame_60Hz = 262 * 64 - 1 = 16767` (262 lignes en NTSC). Mais le TO8 est PAL, donc 50 Hz standard.

## Pitfalls

- **`IrqInit` non appelé** : `TIMERPT` non set → IRQ saute n'importe où
- **`IrqOn` sans `IrqSync` ou `IrqSet50Hz`** : timer non configuré, IRQ continue à la mauvaise fréquence (ou jamais)
- **`Irq_one_frame` modifié à la main** : casse la sync 50 Hz
- **`IrqOn` dans une routine appelée depuis IRQ** : double activation, comportement imprévisible
- **`IrqPause` sans `IrqUnpause`** : IRQ reste off → musique coupée, écran figé
- **`andcc #$EF` au lieu de `orcc #$10`** (ou inverse) : inverse l'effet
- **TIMERPT modifié par une autre routine** : redirige les IRQ ailleurs
- **`IrqInit` re-appelé pendant le run** : potentielle race condition (IRQ pendant qu'on change TIMERPT)
