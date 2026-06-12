# Lecture des joypads — détails

## Configuration PIA — `InitJoypads`

Le MC6821 (PIA) du TO8 a deux ports A et B, chacun avec 8 lignes data + 2 lignes de contrôle :

| Port | Adresse OR/DDR | Adresse CR | Sémantique |
|------|----------------|------------|------------|
| A | `$E7CC` | `$E7CE` | Joypad directions (8 bits = 4 par joueur) |
| B | `$E7CD` | `$E7CF` | Joypad boutons + DAC son |

Selon le bit 2 du Control Register :
- `bit 2 = 0` : `$E7CC`/`$E7CD` accède au **DDR** (Data Direction Register)
- `bit 2 = 1` : `$E7CC`/`$E7CD` accède au **OR** (Output Register = data)

### Algorithme InitJoypads

```asm
InitJoypads
        ; 1. Passer en DDRA
        lda   $E7CE                     ; lit CRA
        anda  #$FB                      ; clear bit 2 → DDRA accessible
        sta   $E7CE
        
        ; 2. DDRA = 0 (toutes lignes en input)
        andb  #0
        stb   $E7CC                     ; lignes input
        
        ; 3. Passer en ORA
        ora   #$04                      ; set bit 2
        sta   $E7CE                     ; CRA bit 2 = 1
        
        ; (symétrique pour CRB / DDRB / ORB)
        lda   $E7CF
        anda  #$FB
        sta   $E7CF
        andb  #0
        stb   $E7CD
        ora   #$04
        sta   $E7CF
        rts
```

Après cet appel : `$E7CC` et `$E7CD` peuvent être lus pour avoir l'état du joypad.

## Format des bits sur le hardware

### `$E7CC` — Directions

Les bits sont **inversés** (0 = pressé, 1 = relâché) :

```
Bit : 7 6 5 4   3 2 1 0
       └ P2 ┘   └ P1 ┘
       R L D U  R L D U
```

Exemple : si player 1 appuie « Right + Up », `$E7CC = %11110110` (les 2 bits relachés à 1, les 2 pressés à 0).

### `$E7CD` — Boutons + DAC

```
Bit : 7 6   5 4 3 2   1 0
      A A   D D D D   B B
      P2 P1 [6 bits DAC] P2 P1
```

Note : 6 bits centraux servent pour le DAC audio (Convertisseur Numérique-Analogique), pas pour les boutons.

## `ReadJoypads` — algorithme

```asm
ReadJoypads
        ; Lit la direction et les boutons
        lda   $E7CC
        coma                            ; inverse (0 = relachée → 1 = pressé)
        sta   Dpad_Read                 ; brut
        
        ; Calcule Press = (nouveau & ~ancien)
        ldb   Dpad_Held                 ; ancien
        comb                            ; ~ancien
        anda  Dpad_Held...              ; (simplifié)
        sta   Dpad_Press
        
        ; Met à jour Held
        lda   Dpad_Read
        sta   Dpad_Held
        
        ; Idem pour Fire ($E7CD)
        ; ...
        rts
```

### Distinction Press / Held

- `Held` : état courant après inversion (`coma`). 1 = pressé maintenant.
- `Press` : front montant. 1 = pressé **cette frame** pour la première fois.

Algorithme du front montant :
```
Press(t) = Held(t) AND NOT Held(t-1)
```

Utile pour distinguer :
- **Mouvement continu** : tester `Held` (gauche tenu = déplace gauche)
- **Action ponctuelle** : tester `Press` (saut tenu = saute une fois)

## Variables exposées

```asm
; Player 1 (Dpad sur 4 bits bas, Fire sur 2 bits)
Dpad_Read       fcb 0                   ; brut (read direct du hardware inversé)
Dpad_Press      fcb 0                   ; front montant
Dpad_Held       fcb 0                   ; maintenu

Fire_Read       fcb 0
Fire_Press      fcb 0
Fire_Held       fcb 0
```

### Version 2 (V2) avec `ReadJoypads2`

`ReadJoypads2` sépare clairement player 1 et player 2 dans deux variables distinctes (plus pratique pour les 2 joueurs).

```asm
; Player 1
Joypad1_Press
Joypad1_Held

; Player 2
Joypad2_Press
Joypad2_Held
```

(noms exacts à vérifier dans le code engine)

## Masques détaillés

### Player 1

```asm
c1_button_up_mask            equ %00000001
c1_button_down_mask          equ %00000010
c1_button_left_mask          equ %00000100
c1_button_right_mask         equ %00001000
c1_button_A_mask             equ %01000000
c1_button_B_mask             equ %00000100
```

**Important** : `c1_button_B_mask` ($04) et `c1_button_left_mask` ($04) ont la même valeur. Mais ils s'appliquent à des registres différents (`Fire_Held` pour B, `Dpad_Held` pour left). Donc pas de conflit en pratique.

### Player 2

```asm
c2_button_up_mask            equ %00010000
c2_button_down_mask          equ %00100000
c2_button_left_mask          equ %01000000
c2_button_right_mask         equ %10000000
c2_button_A_mask             equ %10000000
c2_button_B_mask             equ %00001000
```

Player 2 occupe les bits hauts (4-7) sur les mêmes octets.

### Patterns d'usage

```asm
        ; Test direction P1 maintenu
        lda   Dpad_Held
        bita  #c1_button_left_mask
        bne   @go_left
        bita  #c1_button_right_mask
        bne   @go_right

        ; Test saut P1 (front montant)
        lda   Fire_Press
        bita  #c1_button_A_mask
        bne   @jump
```

## Pattern d'utilisation typique

```asm
; Au boot
        jsr   InitJoypads

; MainLoop
MainLoop
        jsr   ReadJoypads
        ; les variables Dpad_Press/Held/Fire_*sont à jour pour la frame
        jsr   RunObjects                ; les objets peuvent les lire
        ; ...
```

## Coût

`ReadJoypads` : ~30-40 cycles.

À 50 Hz, 50 × 40 = 2000 cycles/seconde dédiés. Négligeable.

## Pitfalls

- **`InitJoypads` oublié** : `$E7CC`/`$E7CD` peuvent être en output (selon état précédent) → écrasement
- **Tester `Dpad_Held` avec masque Fire** : OK théoriquement (bits différents) mais source de confusion
- **Modifier `Dpad_Press` / `Held`** : casse la mécanique
- **Confondre P1 et P2 sur `Dpad_Held`** : utiliser les bons masques (`c1_*` ou `c2_*`)
- **Lire `Press` plusieurs fois et compter sur la mise à 0** : `Press` reste à 1 toute la frame, c'est `ReadJoypads` qui le clear à la frame suivante
- **`ReadJoypads` dans IRQ + MainLoop** : double lecture, perte d'events
