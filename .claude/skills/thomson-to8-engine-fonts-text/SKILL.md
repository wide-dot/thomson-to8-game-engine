---
name: thomson-to8-engine-fonts-text
description: "Décrit les routines d'affichage de texte du Thomson TO8/TO9 game engine (Bento8/wide-dot) : DrawText pour afficher des chaînes ASCII via une font compilée (font 3x5 et variantes 3x5_selected / 3x5_shaded / 3x5_shaded_disabled / 3x5_shaded_selected), DrawOneChar pour 1 caractère, indexation par offset 32 (caractère - 32 → index), variable DrawText_pos pour positionner à l'écran (auto-incrémenté), callbacks DrawText_0A / DrawText_0C / DrawText_0D pour gérer LF/FF/CR (par défaut rts), HexToText pour conversion hex→ascii 2 chiffres, PrintString pour afficher avec font 3x7-normal (utilise LOCATE_X / LOCATE_Y pour la position, RAM_A / RAM_B pour les plans, LETTER_X labels pour chaque lettre), USER_STACK pour fonctions imbriquées, format VRAM TO8 (VIDEO = $A000, RAM_A_OFFSET = $2000), génération des fonts via .txt source. Utiliser pour afficher un HUD (score, vies, time), un menu de sélection, des messages texte, des codes de couleurs, des dialogues, créer une nouvelle police, basculer entre fonts (normale vs sélectionnée pour menus), gérer les retours à la ligne automatiques. Mots-clés : DrawText, DrawOneChar, DrawText_pos, DrawText_0A, DrawText_0C, DrawText_0D, DrawText_start_pos, HexToText, PrintString, LOCATE_X, LOCATE_Y, RAM_A, RAM_B, RAM_VIDEO_SIZE, VIDEO $A000, RAM_A_OFFSET $2000, fnt_4x6_shd, font 3x5, 3x5_selected, 3x5_shaded, 3x5_shaded_disabled, 3x5_shaded_selected, font 3x7-normal, USER_STACK, RASTER_COLORS, COLOR, LETTER_, fcn ASCIIZ, fcb null-terminated, ascii 32 space, $A LF, $C FF, $D CR, sprite engine integration."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Fonts et texte — Thomson TO8/TO9 Game Engine

L'engine fournit deux systèmes d'affichage de texte :

1. **`DrawText`** (`engine/graphics/font/DrawText/`) — system moderne avec font 3×5 + variantes (sélectionnée, shaded, disabled). Utilisé par sonic-2.
2. **`PrintString`** (`engine/graphics/font/PrintString/`) — system simple avec font 3×7 normale. Utilisé par sonic-2 et goldorak.

---

## `DrawText` — texte via font compilée

### Signature

```asm
; X : pointeur vers la font (e.g. fnt_4x6_shd)
; Y : pointeur vers le texte (chaîne ASCIIZ ou null-terminated)
; DrawText_pos : position écran (variable auto-modif)
        jsr   DrawText
```

### Algorithme

```asm
DrawText
        pshs  d,u,y
@loop   ldb   ,y+                       ; lit caractère
        beq   @rts                      ; null = fin
        cmpb  #32
        bge   @r_char                   ; caractère normal
        ; Caractère spécial (< 32)
        cmpb  #$A                       ; LF
        bne   >
        jsr   [DrawText_0A]
        bra   @loop
!       cmpb  #$C                       ; FF
        bne   >
        jsr   [DrawText_0C]
        bra   @loop
!       cmpb  #$D                       ; CR
        bne   @loop
        jsr   [DrawText_0D]
        bra   @loop
@r_char
        clra
        subb  #32                       ; index dans la font (caractère - 32)
        aslb                            ; *2 (table de fdb)
        ldu   #0
DrawText_pos equ *-2                    ; position écran (auto-modif)
        jsr   [d,x]                     ; appel indirect — chaque char est une routine compilée
        inc   DrawText_pos+1            ; avance position (+1 byte = +4 pixels en mode 160)
        bne   @loop
        inc   DrawText_pos
        bra   @loop
@rts    puls  d,u,y,pc
```

Chaque **caractère** est une **routine compilée** (pas un bitmap statique). C'est une **font sprite compilée** : chaque char a son code asm optimisé qui écrit ses pixels en VRAM.

Avantage : très rapide à dessiner (~30 cycles/caractère).
Inconvénient : taille en code (chaque caractère = ~30-50 octets de code).

### Callbacks LF/FF/CR

```asm
DrawText_0A fdb @rts                    ; LF (Line Feed) — par défaut rts
DrawText_0C fdb @rts                    ; FF (Form Feed)
DrawText_0D fdb @rts                    ; CR (Carriage Return)
```

À redéfinir pour gérer les retours à la ligne :

```asm
DrawText_0A fdb MyLineFeed              ; LF custom

MyLineFeed
        ; reset position X, descend Y
        lda   DrawText_pos              ; high byte = X
        anda  #%11000000                ; clear X
        ; ... add Y offset ...
        sta   DrawText_pos
        rts
```

### Variantes de font

```
3x5/                          # normale 3×5 pixels
3x5_selected/                 # surlignée (pour menus)
3x5_shaded/                   # avec ombre
3x5_shaded_disabled/          # ombre + gris (option désactivée)
3x5_shaded_selected/          # ombre + surlignée
```

Permet un look cohérent avec des variantes pour les menus.

### `HexToText`

```asm
        lda   #$3F                      ; valeur à afficher (en hex)
        ldy   #buffer                   ; buffer ASCIIZ 2 octets + null
        jsr   HexToText
        ; buffer = "3F", 0
```

Convertit un octet en 2 caractères ASCII hex.

Voir [references/drawtext.md](references/drawtext.md).

---

## `PrintString` — texte simple avec font 3×7

### Signature

```asm
        lda   #0
        sta   LOCATE_X
        sta   LOCATE_Y
        ldx   #WELCOME
        jsr   PrintString

WELCOME
        fcn   "Bienvenue dans le jeu !"  ; FCN = string ASCIIZ
```

### Variables

```asm
VIDEO           equ $A000
RAM_A_OFFSET    equ $2000
RAM_VIDEO_SIZE  equ 8000
RAM_A           equ VIDEO+RAM_A_OFFSET   ; plan A (couleur)
RAM_A_END       equ RAM_A+RAM_VIDEO_SIZE
RAM_B           equ VIDEO                ; plan B (forme)
RAM_B_END       equ RAM_B+RAM_VIDEO_SIZE

LOCATE_X        fcb $00                  ; position X (caractère)
LOCATE_Y        fcb $00                  ; position Y (ligne)

COLOR           fcb $02                  ; couleur du texte
RASTER_COLORS   fcb $01,$02,$03,$04,$05,$06,$07,$08   ; 8 couleurs (raster)
```

### Algorithme

```asm
PrintString
        pshs  d,x,y,u
        ldu   #USER_STACK               ; pile locale
        
        ; Calcul de l'adresse VRAM : Y_pixel = LOCATE_Y * 8, addr = (Y*40) + X
        ldb   LOCATE_Y
        lslb
        lslb
        lslb                            ; *8 lignes
        lda   #40
        mul                             ; *40 octets/ligne
        tfr   d,y
        lda   LOCATE_X
        leay  a,y                       ; offset final
        
        ; Boucle sur chaque caractère
!       ldb   ,x+                       ; lit caractère
        beq   >                         ; null = fin
        cmpb  #$20                      ; >= space ?
        ; ... dessine le caractère via la table LETTER_<c> ...
        bra   <
!       puls  d,x,y,u,pc
```

### Définition des lettres

```asm
LETTER_<char>
        fcb $00,$00                     ; ligne 0 : 2 octets (plan A + plan B)
        fcb $01,$00                     ; ligne 1
        ; ... 8 lignes au total ...
```

Format brut : 8 lignes × 2 octets (plan A + plan B). Total 16 octets/caractère.

Exemples :
```asm
LETTER_<space>
        fcb $00,$00 [...8 fois]         ; tout vide

LETTER_!
        fcb $00,$00
        fcb $01,$00                     ; pixel
        fcb $01,$00
        fcb $01,$00
        fcb $01,$00
        fcb $00,$00
        fcb $01,$00                     ; point
        fcb $00,$00
```

Caractères supportés : ASCII de space ($20) jusqu'à 'Z' / 'z' + ponctuation. Le source `3x7-normal.txt` décrit la grille.

Voir [references/printstring.md](references/printstring.md).

---

## Comparaison `DrawText` vs `PrintString`

| Aspect | `DrawText` | `PrintString` |
|--------|------------|---------------|
| Font | 3×5 + variantes | 3×7 normale |
| Stockage | Code compilé (routines) | Data brut (bitmap par lettre) |
| Vitesse | Très rapide | Modéré |
| Taille mémoire | Moyenne | Plus compact |
| Variantes | Selected/Shaded/Disabled | Pas de variantes |
| Position | `DrawText_pos` (auto-incr) | `LOCATE_X` / `LOCATE_Y` |
| LF/FF/CR | Callbacks customisables | Pas de gestion |
| Couleur | Implicite (via font) | `COLOR` variable |
| Usage repo | sonic-2 | sonic-2, goldorak |

### Quand utiliser quoi

- **`DrawText`** :
  - Menus avec items sélectionnés/désélectionnés
  - HUD nécessitant plusieurs variantes (highlight, disabled)
  - Performances critiques (50 chars / frame)

- **`PrintString`** :
  - Affichage simple (score, message)
  - Faible variation de style
  - Économie de mémoire

---

## Patterns d'usage

### HUD score (DrawText)

```asm
DisplayScore
        ldx   #fnt_3x5_shaded
        ldy   #score_text
        ldd   #$0000                    ; position $0000 = haut-gauche
        std   DrawText_pos
        jsr   DrawText
        ; Conversion score → ASCII
        lda   <globals.score
        ldy   #score_buffer
        jsr   HexToText
        ldd   #$0010                    ; position après "Score: "
        std   DrawText_pos
        ldy   #score_buffer
        jsr   DrawText
        rts

score_text fcn "Score: "                ; ASCIIZ
score_buffer fcb 0,0,0,0
```

### Menu (DrawText avec variantes)

```asm
        ; Item 1 (sélectionné)
        ldx   #fnt_3x5_selected
        ldy   #menu_start
        ldd   #$2020
        std   DrawText_pos
        jsr   DrawText

        ; Item 2 (normal)
        ldx   #fnt_3x5_shaded
        ldy   #menu_options
        ldd   #$2040
        std   DrawText_pos
        jsr   DrawText

        ; Item 3 (désactivé)
        ldx   #fnt_3x5_shaded_disabled
        ldy   #menu_exit
        ldd   #$2060
        std   DrawText_pos
        jsr   DrawText
```

### Message simple (PrintString)

```asm
        lda   #5
        sta   LOCATE_X
        lda   #10
        sta   LOCATE_Y
        ldx   #message
        jsr   PrintString

message fcn "GAME OVER"
```

---

## Génération de fonts

Le fichier `3x7-normal.txt` décrit chaque caractère sous forme ASCII art :

```
char ' '
.........
.........
.........
...

char '!'
.X.......
.X.......
.X.......
.X.......
.X.......
.........
.X.......
.........
```

Un outil de génération (à identifier dans tools/) convertit ce txt en `fcb` asm.

Pour `DrawText`, les caractères sont compilés en routines via le builder Java (cf. skill `build-pipeline`).

---

## Pitfalls

### `DrawText`

- **`DrawText_pos` non init** : caractères dessinés à la mauvaise adresse, possible crash hors VRAM
- **Pointeur font invalide** : crash sur `jsr [d,x]` (saute à 0)
- **Caractère < 32** non géré : callbacks `DrawText_0A/0C/0D` à `@rts` par défaut → ignore les LF/FF/CR
- **Buffer texte non null-terminated** : DrawText continue de dessiner indéfiniment
- **Caractère > 127** : index hors range de la font, lecture aléatoire

### `PrintString`

- **`LOCATE_X` > 39** : déborde sur la ligne suivante
- **`LOCATE_Y` > 24** : hors écran (mode 200 lignes / 8 = 25 lignes max)
- **`fcn` sans null final** : lecture infinie
- **Caractère non défini** (e.g. accent) : crash ou dessine garbage
- **`USER_STACK` chevauchant la pile système** : corruption

### Communs

- **Modifier la VRAM pendant l'affichage** : tearing visible
- **Préférer écrire pendant VBL** ou via gfxlock pour éviter le tearing

---

## Références détaillées

- [references/drawtext.md](references/drawtext.md) — `DrawText` complet : algorithme, callbacks LF/FF/CR customisation, variantes de font (3x5 + selected/shaded/disabled/shaded_selected), HexToText, intégration avec sprite engine, performance ~30 cycles/char
- [references/printstring.md](references/printstring.md) — `PrintString` détails : algorithme, calcul adresse VRAM (LOCATE_X/Y → A000+offset), format LETTER_<c> (8 lignes × 2 plans), font 3x7-normal.txt source, USER_STACK pour appels imbriqués, RASTER_COLORS, génération via .txt
