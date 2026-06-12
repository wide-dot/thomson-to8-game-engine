---
name: thomson-to8-engine-input
description: "Décrit le système d'entrées (joypads, clavier) du Thomson TO8/TO9 game engine (Bento8/wide-dot) : routine InitJoypads pour configurer le MC6821 PIA (registres CRA/CRB $E7CE/$E7CF, DDRA/DDRB, ORA/ORB $E7CC/$E7CD), ReadJoypads (Joypads_Read / Dpad_Read / Fire_Read, mode V1 16 bits combinés ou V2 1 byte/joueur), masques c1_button_up_mask / c1_button_down_mask / c1_button_left_mask / c1_button_right_mask / c1_button_A_mask / c1_button_B_mask (et c2_*), masques communs c_button_*_mask, masques de joueur c1_dpad / c2_dpad / c1_butn / c2_butn, variables Dpad_Press / Dpad_Held / Fire_Press / Fire_Held pour player 1, Dpad2_Press / Dpad2_Held / Fire2_Press / Fire2_Held pour player 2, ReadJoypads2 pour version 2-bytes, joypad.buffer pour historique des directions (circular buffer 16 entrées, joypad.buffer.direction.write.ptr / read.ptr, joypad.buffer.addDirection / getDirection), joypad.md6 driver Mega Drive 6 boutons (cycle line select Z/Y/X/Mode + Start/A/B/C, pinout TO8 vs Mega Drive), ReadKeyboard pour clavier (Key_Press / Key_Held, appel KTST monitor et GETC), MapKeyboardToJoypads pour mapper clavier → masques joypad (touches 8/9/10/11 = directions, autres = boutons), pattern Dpad_Press (front montant) vs Dpad_Held (maintenu). Utiliser pour configurer les joypads, lire les inputs joueur 1 et 2, gérer le clavier comme alternative au joypad, ajouter le support manette Mega Drive 6 boutons, enregistrer un historique d'inputs (combos), distinguer touche pressée vs maintenue. Mots-clés : InitJoypads, ReadJoypads, ReadJoypads2, Joypads, Joypads_Read, Joypads_Held, Joypads_Press, Dpad_Read, Dpad_Press, Dpad_Held, Dpad2_Press, Dpad2_Held, Fire_Read, Fire_Press, Fire_Held, Fire2_Press, Fire2_Held, Key_Press, Key_Held, ReadKeyboard, MapKeyboardToJoypads, joypad.buffer, joypad.buffer.direction, joypad.buffer.direction.write.ptr, joypad.buffer.direction.read.ptr, joypad.buffer.addDirection, joypad.buffer.getDirection, joypad.md6, KTST, GETC, MC6821, PIA, CRA, CRB, DDRA, DDRB, ORA, ORB, $E7CC, $E7CD, $E7CE, $E7CF, c1_button_up_mask, c1_button_down_mask, c1_button_left_mask, c1_button_right_mask, c1_button_A_mask, c1_button_B_mask, c2_button_up_mask, c2_button_down_mask, c2_button_left_mask, c2_button_right_mask, c2_button_A_mask, c2_button_B_mask, c_button_up_mask, c_button_down_mask, c_button_left_mask, c_button_right_mask, c_button_A_mask, c_button_B_mask, c1_dpad, c2_dpad, c1_butn, c2_butn, megadrive 6 buttons, TH TR TL line select, pin 6 7 9, Start C A B, X Y Z Mode."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Input — Thomson TO8/TO9 Game Engine

Le système d'entrées gère **joypads** (2 manettes Thomson standard) et **clavier**. Tout est accédé via le PIA MC6821 sur les ports `$E7CC-$E7CF`.

L'engine fournit des routines pour :
- **Joypads standard** (2 boutons) : `InitJoypads`, `ReadJoypads`, `ReadJoypads2`
- **Buffer d'historique** : `joypad.buffer` (combo detection)
- **Joypad Megadrive 6 boutons** : `joypad.md6`
- **Clavier** : `ReadKeyboard`, `MapKeyboardToJoypads`

---

## Hardware — PIA MC6821

Le TO8 utilise un MC6821 (PIA = Peripheral Interface Adapter) pour les manettes :

```asm
$E7CC : ORA / DDRA  (direction des joypads — selon bit 2 de CRA)
$E7CD : ORB / DDRB  (boutons + DAC son — selon bit 2 de CRB)
$E7CE : CRA         (Control Register A)
$E7CF : CRB         (Control Register B)
```

CRA/CRB bit 2 :
- `= 0` : accès au registre **DDR** (Data Direction)
- `= 1` : accès au registre **OR** (Output Register)

## `InitJoypads`

Configure le PIA pour lire les joypads :

```asm
InitJoypads
        ; CRA : passage en DDRA
        lda   $E7CE
        anda  #$FB                      ; clear bit 2
        sta   $E7CE
        andb  #0
        stb   $E7CC                     ; DDRA = $00 → toutes les lignes en input
        ora   #$04                      ; set bit 2
        sta   $E7CE                     ; CRA bit 2 = 1 → accès ORA
        
        ; CRB : idem pour DDRB/ORB
        lda   $E7CF
        anda  #$FB
        sta   $E7CF
        andb  #0
        stb   $E7CD                     ; DDRB = $00 → input
        ora   #$04
        sta   $E7CF
        rts
```

Après cet appel, `$E7CC` lit les directions (4 bits player 1 + 4 bits player 2) et `$E7CD` lit les boutons (2 bits/joueur, plus DAC dans les autres bits).

## Format des données joypads

### `$E7CC` — Directions

```
Bit : 7 6 5 4   3 2 1 0
       └ player2 ┘ └ player1 ┘
       R L D U   R L D U
```

`0 = press, 1 = release` (inversé !).

### `$E7CD` — Boutons + DAC

```
Bit : 7 6   5 4 3 2 1 0
      A A   [6 bits DAC]   B B
      P2 P1               P2 P1
```

Bits 6-7 : boutons A des deux joueurs.
Bit 2-3 : boutons B (note : bit 2 pour P1, bit 3 pour P2).
Bits 0-5 : 6 bits DAC (utilisés pour le son hardware).

## `ReadJoypads` — version V1 (16 bits combinés)

```asm
ReadJoypads
        ; Lit $E7CC et $E7CD, inverse, distribue dans :
        ; Dpad_Read    (bas)   : directions player 1+2 sur 1 octet
        ; Fire_Read    (haut)  : boutons player 1+2 sur 1 octet
        ; Dpad_Held    : dpad maintenu (full byte)
        ; Dpad_Press   : dpad pressé cette frame (front montant uniquement)
        ; Fire_Held    : boutons maintenus
        ; Fire_Press   : boutons pressés cette frame
```

Format combiné 16 bits :
```
Dpad_Held :  bits 0-3 = player1 (URDL), bits 4-7 = player2 (URDL)
Fire_Held :  bits 0-1 = player1 (B,...) , bits 6-7 = player2 (A,...)
```

> **Format simplifié pour solo** : utiliser `c1_*_mask` qui ciblent les bits player 1 seulement.

## `ReadJoypads2` — version V2 (1 byte/joueur)

Variante qui sépare les deux joueurs en deux octets distincts (plus pratique pour 2 joueurs).

## Masques bits

### Player 1 (`c1_*_mask`)

```asm
c1_button_up_mask            equ %00000001
c1_button_down_mask          equ %00000010
c1_button_left_mask          equ %00000100
c1_button_right_mask         equ %00001000
c1_button_A_mask             equ %01000000
c1_button_B_mask             equ %00000100      ; ATTENTION : même valeur que left_mask
```

> **Conflit `c1_button_B_mask` et `c1_button_left_mask`** : tous deux à $04. C'est parce que Dpad et Fire sont dans **deux variables différentes** (`Dpad_Read` vs `Fire_Read`). Le test `bita #c1_button_B_mask` doit être fait sur `Fire_Held`, pas `Dpad_Held`.

### Player 2 (`c2_*_mask`)

```asm
c2_button_up_mask            equ %00010000      ; bits hauts
c2_button_down_mask          equ %00100000
c2_button_left_mask          equ %01000000
c2_button_right_mask         equ %10000000
c2_button_A_mask             equ %10000000
c2_button_B_mask             equ %00001000
```

### Masques communs (les deux joueurs)

```asm
c_button_up_mask             equ %00010001      ; bits player1 + player2
c_button_down_mask           equ %00100010
c_button_left_mask           equ %01000100
c_button_right_mask          equ %10001000
c_button_A_mask              equ %11000000
c_button_B_mask              equ %00001100
```

### Masques de joueur (filtres)

```asm
c1_dpad                      equ %00001111      ; isole les 4 bits dpad player1
c2_dpad                      equ %11110000
c1_butn                      equ %01000100      ; isole les 2 bits boutons player1
c2_butn                      equ %10001000
```

## Press vs Held

```asm
Dpad_Press                   ; 1 si la direction vient d'être pressée cette frame
Dpad_Held                    ; 1 si la direction est tenue (depuis n frames)
Fire_Press
Fire_Held
```

`Press` : détection de **front montant** (passe de 0 à 1) — utile pour un saut, un tir une fois.
`Held` : état courant — utile pour un mouvement continu, une accélération.

```asm
        lda   Dpad_Press
        bita  #c1_button_up_mask
        beq   @no_jump
        ; le joueur vient d'appuyer sur up
@no_jump

        lda   Dpad_Held
        bita  #c1_button_left_mask
        beq   @no_left
        ; le joueur tient gauche (déplacement continu)
@no_left
```

## Pattern d'usage typique

```asm
; Au boot
        jsr   InitJoypads

; Dans MainLoop
MainLoop
        jsr   ReadJoypads
        ; Test inputs et logique gameplay
        jsr   RunObjects
        ; ...
```

`ReadJoypads` doit être appelée **chaque frame** avant `RunObjects` (les objets vont lire les inputs).

## `joypad.buffer` — historique pour combos

Circular buffer de 16 entrées pour mémoriser les directions récentes.

```asm
joypad.buffer.direction           fill 0,16
joypad.buffer.direction.write.ptr fcb 0
joypad.buffer.direction.read.ptr  fcb 0
```

Routines :
- `joypad.buffer.addDirection` : ajoute la direction courante au buffer
- `joypad.buffer.getDirection` : lit la direction suivante depuis le read pointer

Pattern :
```asm
; Chaque frame
        jsr   ReadJoypads
        jsr   joypad.buffer.addDirection

; Quand on veut analyser
        ; Boucle qui lit getDirection jusqu'à $FF (fin)
        ; Détecte une séquence type "down, down-forward, forward, punch"
```

Utile pour fighting games, combos, codes secrets (Konami code).

## `joypad.md6` — Megadrive 6 boutons

Driver pour la manette Megadrive 3 ou 6 boutons branchée sur le port joypad TO8.

Mécanisme : multiplex via la ligne TH (pin 7). Le driver toggle TH et lit les boutons par cycles.

```
Cycle  TH   TR  TL   D3   D2   D1   D0
1      HI   C   B    R    L    D    U
2      LO   Start A  0    0    D    U
3-7    ... (cycles supplémentaires pour les 6 boutons : X, Y, Z, Mode)
```

Le driver simule un état complet (Up, Down, Left, Right, A, B, C, Start, X, Y, Z, Mode) sur la base de ces 7 cycles.

### Pinout

| Pin | Megadrive | TO8 |
|-----|-----------|-----|
| 1 | Up | Up |
| 2 | Down | Down |
| 3 | Left | Left |
| 4 | Right | Right |
| 5 | +5V | +5V |
| 6 | A/B | A |
| 7 | TH (line select) | B |
| 8 | GND | GND |
| 9 | C/Start | NC |

L'adaptateur Megadrive→TO8 utilise la pin 7 (B sur TO8) pour le multiplexing.

Voir [references/megadrive-6-buttons.md](references/megadrive-6-buttons.md).

## `ReadKeyboard` — clavier

```asm
Key_Press                   fcb $00
Key_Held                    fcb $00

ReadKeyboard
        clrb
        stb   Key_Press
        jsr   KTST                      ; monitor : test si touche pressée
        bcc   @clearHeld                ; non → exit
        jsr   GETC                      ; oui → lit code dans B
        cmpb  Key_Held                  ; déjà maintenue ?
        beq   @rts                      ; oui → Press = 0, Held inchangé
        stb   Key_Press                 ; non → enregistre press cette frame
@clearHeld
        stb   Key_Held
@rts    rts
```

Utilise les routines monitor `KTST` (Key TeST) et `GETC` (GET Character).

Voir [references/keyboard-input.md](references/keyboard-input.md).

## `MapKeyboardToJoypads`

Permet de jouer **au clavier** en mappant des touches sur les masques joypad. Le code dispatch :
```asm
        cmpa  #8                        ; touche flèche gauche
        bne   >
        orb   #c1_button_left_mask
        ; ...
        cmpa  #9                        ; touche flèche droite
        ; ...
        cmpa  #10                       ; flèche bas
        ; ...
        cmpa  #11                       ; flèche haut
        ; ...
        (autres touches = boutons)
```

Codes :
- 8 = LEFT
- 9 = RIGHT
- 10 = DOWN
- 11 = UP
- (autres = mapping custom pour A/B)

## Pitfalls

- **`InitJoypads` non appelé** : `$E7CC`/`$E7CD` non configurés → lectures incohérentes
- **Lire `$E7CC` directement sans `ReadJoypads`** : pas de débouncing, pas de Press/Held
- **Confondre `c1_button_B_mask` ($04) et `c1_button_left_mask` ($04)** : même valeur mais sur registres différents (Fire vs Dpad)
- **Tester `Dpad_Held` avec `c1_button_A_mask`** : masque pour Fire, pas Dpad
- **`Dpad_Press` non clear après use** : peut déclencher plusieurs fois la même action si testé plusieurs fois
- **`joypad.buffer` non init** : buffer plein de 0, comportement bizarre
- **Megadrive 6 boutons sans le driver md6** : seuls 2 boutons accessibles
- **`KTST` / `GETC` depuis IRQ** : monitor routines pas re-entrant, possible crash

## Références détaillées

- [references/joypad-reading.md](references/joypad-reading.md) — InitJoypads détaillé (config PIA CRA/CRB/DDRA/ORA), ReadJoypads V1 vs V2, masques c1_* / c2_* / c_* / dpad/butn, format $E7CC / $E7CD (bits inversés), distinction Press/Held (front montant), pattern d'usage par frame
- [references/joypad-buffer.md](references/joypad-buffer.md) — Circular buffer 16 entrées, joypad.buffer.direction / write.ptr / read.ptr, addDirection / getDirection, pattern combo detection (fighter, codes secrets)
- [references/megadrive-6-buttons.md](references/megadrive-6-buttons.md) — joypad.md6 driver, mécanique TH/TR/TL multiplex, 7 cycles de line select, pinout TO8 vs Megadrive, états Up/Down/Left/Right + A/B/C/Start + X/Y/Z/Mode, adaptateur physique
- [references/keyboard-input.md](references/keyboard-input.md) — ReadKeyboard via KTST + GETC monitor, Key_Press / Key_Held, codes touches Thomson, MapKeyboardToJoypads (mapping 8=LEFT, 9=RIGHT, 10=DOWN, 11=UP, autres=boutons), alternative pour test sans joypad
