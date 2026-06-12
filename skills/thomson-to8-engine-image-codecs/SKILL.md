---
name: thomson-to8-engine-image-codecs
description: "Décrit les codecs et routines de rendu d'images du Thomson TO8/TO9 game engine (Bento8/wide-dot) : DrawFullscreenImage pour dessiner une image plein écran rapide (technique stack blasting pshs/pulu pour vitesse, lds $DF40 puis $BF40, sync IRQ critique pour 12 octets de marge), DrawFullscreenInterlacedImage pour images entrelacées (effets visuels), DrawHLine pour ligne horizontale 320x200x16 (paramètres dans dp_engine : p0/p1 x MSB/LSB, p2 y, p3/p4 nb pixels, p5/p6 couleurs), DecRLE00 / DecMapAlpha codec RLE avec transparence par Samuel Devulder (encodage 2 octets : 00 nnnnnn = ptr offset, 01 = right transparent ou repeat, 10 = left transparent ou write, 11 = ptr offset 14-bit signed), zx0_mega pour décompression ZX0 (zx0_6809_mega_wrap pour 2 parts via glb_screen_location_1/2, zx0_decompress), bm4.drawChunks pour rendu chunky bm4 (bytes par ligne, nb lignes, copy avec PULS/PSHS optimisé), variant sprites DMAP via MapRleEncoder et DZX0 via ZX0Encoder dans le builder, ClearDataMemory / ClearInterlacedDataMemory / ClearVerticalBandLR pour clear zones VRAM (stack blasting lds $DF40 + pshu pour vitesse, IRQ off requise), GetImgIdA helper. Utiliser pour afficher un splash screen, dessiner un fond de niveau, décompresser une image ZX0 ou RLE, blitter un chunk d'image, clearer une zone VRAM rapidement, optimiser le rendering avec stack tricks. Mots-clés : DrawFullscreenImage, DrawFullscreenInterlacedImage, DrawHLine, DecRLE00, DecMapAlpha, DecRLE00_alpha, zx0_mega, zx0_6809_mega_wrap, zx0_decompress, bm4.drawChunbks, bm4.drawChunks, ClearDataMem, ClearDataMemory, ClearInterlacedDataMemory, ClearVerticalBandLR, GetImgIdA, p0, p1, p2, p3, p4, p5, p6, dhl_routine, $DF40, $BF40, $C014, RLE format, stack blasting, pulu / pshs, lds, glb_screen_location_1, glb_screen_location_2, DMAP, DZX0, MapRleEncoder, ZX0Encoder, Bgi_, transparency, alpha, Samuel Devulder, sprite background, IRQ off."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Codecs et routines d'image — Thomson TO8/TO9 Game Engine

L'engine fournit des routines optimisées pour le rendu d'images :

| Routine | Rôle |
|---------|------|
| `DrawFullscreenImage` | Image plein écran rapide (stack blasting) |
| `DrawFullscreenInterlacedImage` | Image entrelacée (effets) |
| `DrawHLine` | Ligne horizontale (mode 320×200) |
| `DecRLE00` | Décodeur RLE avec transparence |
| `zx0_mega` | Décompresseur ZX0 (wrapper) |
| `bm4.drawChunbks` | Rendu chunky bm4 |
| `ClearDataMem*` | Clear VRAM |

---

## `DrawFullscreenImage` — image plein écran rapide

### Technique stack blasting

```asm
        lds   #$DF40                    ; positionne S en fin de RAMA
DFI_a
        pulu  a,b,dp,x,y                ; lit 5 octets depuis source
        pshs  y,x,dp,b,a                ; écrit 5 octets dans dest (via pile)
        ; ... répété 6× ...
        cmps  #$C014
        bne   DFI_a
```

Astuce 6809 : `pulu` lit depuis `u` (source) en incrémentant, `pshs` écrit dans `s` (dest) en décrémentant. Avec U pointant le PNG source et S pointant la VRAM, on peut transférer 5 octets par instruction (~12 cycles vs ~30 pour 5 `lda/sta`).

### Performance

- 5 octets par paire `pulu`/`pshs` (~12 cycles)
- 8000 octets de VRAM (160×200×4 bits / 8 = 16000 octets / 2 plans = 8000 octets par plan)
- Ratio : 8000 / 5 × 12 = 19200 cycles ≈ 1 frame complète à 50 Hz

C'est juste à la limite du frame budget. Pour ça, **IRQ doit être désactivée** pendant le draw (sauf si on accepte 12 octets de garbage en tête de pile).

### Pré-requis

```asm
        jsr   IrqPause                  ; ou IrqOff
        ldx   #my_image_data            ; pointeur image
        jsr   DrawFullscreenImage
        jsr   IrqUnpause                ; ou IrqOn
```

Sans `IrqOff`, l'IRQ peut interrompre en plein `pshs`/`pulu` et écraser des octets (les 12 derniers de la pile).

### Format de l'image

Le pointeur `X` doit pointer vers une structure :
```
+0 : page mémoire des data (1 octet)
+1 : pointeur vers data (2 octets)
+3+ : data brute (8000 octets RAMA + 8000 RAMB ou similaire)
```

Le builder Java génère cette structure depuis un PNG via `palette.X` et `act.X.backgroundImage`.

Constantes générées : `Bgi_<actName>` pointe vers cette structure.

Voir [references/fullscreen-images.md](references/fullscreen-images.md).

## `DrawFullscreenInterlacedImage` — variantes

Variante pour effets entrelacés (palette qui alterne ligne par ligne, mode interlaced). Plus complexe, utilisée pour des modes graphiques avancés.

## `DrawHLine` — ligne horizontale (320×200)

Pour mode 320×200×16 (non standard dans Bento8). Note : marqué comme **UNFINISHED** dans le code.

```asm
p0   equ dp_engine                      ; x MSB
p1   equ dp_engine+1                    ; x LSB
p2   equ dp_engine+2                    ; y
p3   equ dp_engine+3                    ; nb pixels MSB
p4   equ dp_engine+4                    ; nb pixels LSB
p5   equ dp_engine+5                    ; couleur 0 (s0000bvr)
p6   equ dp_engine+6                    ; couleur 1 (0sbvr000)
```

À utiliser avec parcimonie (pas finalisée).

## `DecRLE00` — codec RLE avec transparence

Par Samuel Devulder. Format compact pour images avec transparence (e.g. tile alpha).

### Format

```
00 000000              → end of data
00 nnnnnn              → write ptr offset n (1-63 unsigned)
01 000000 vvvvvvvv     → right pixel transparent, v = byte to add
01 nnnnnn vvvvvvvv     → repeat n bytes of value v
10 000000 vvvvvvvv     → left pixel transparent, v = byte to add
10 nnnnnn vvvvvvvv ... → n bytes to write with values v0,v1,...
11 nnnnnn nnnnnnnn     → write ptr offset n (-8192 to +8191, signed)
```

### Registres d'entrée

```asm
        ldy   #data_part1               ; (RAMA)
        ldu   #data_part2               ; (RAMB)
        ; glb_screen_location_1/2 = pointeurs VRAM (déjà set)
        jsr   DecMapAlpha               ; (ou variante)
```

Le codec gère **2 parts** (RAMA et RAMB) en parallèle. Très utilisé pour les tiles avec couleurs transparentes.

Voir [references/rle-decoders.md](references/rle-decoders.md).

## `zx0_mega` — décompresseur ZX0

```asm
zx0_6809_mega_wrap
        stu   @x
        ldu   glb_screen_location_1
        cmpx  #0
        beq   >
        jsr   zx0_decompress            ; décompresse part 1
!
        ldx   #0                        ; (dynamic) data part 2
@x      equ *-2
        beq   @rts
        ldd   #0
        std   @x                        ; clear exit flag
        ldu   glb_screen_location_2
        jmp   zx0_decompress            ; décompresse part 2
@rts    rts
```

Wrapper qui décompresse une image ZX0 en 2 parts (RAMA et RAMB).

Pré-requis : `glb_screen_location_1/2` initialisés.

`zx0_decompress` est dans `engine/compression/zx0/zx0_6809_mega.asm` (variantes mega / mega_back / standard / turbo selon perf/taille).

Variants sprite `DZX0` utilisent ce codec.

Voir [references/zx0-decoders.md](references/zx0-decoders.md).

## `bm4.drawChunbks` — rendu chunky BM4

```asm
bm4.drawChunks
        pshs  d,x,y,u

        ldd   ,u++                      ; A = nb bytes/line, B = nb lines
        sta   @bytes
        stb   @nbln
        
@drawline
        leax  a,u                       ; end of source for this line
        stx   @cmpu+2
        
        ; Optimisation par multiples de bytes
        lsra
        bcc   >
        pulu  b
        stb   ,y+                       ; 1 byte
!       lsra
        bcc   >
        pulu  x
        stx   ,y++                      ; 2 bytes
!       lsra
        bcc   @cmpu
        pulu  d,x
        std   ,y++
        stx   ,y++                      ; 4 bytes
@cmpu   ; reste = multiples de 8 → pshu d,x,y (6 bytes en 1 instruction)
```

Affichage rapide de chunks (8×8 ou plus) en mode BM4. Utilisé pour les fonds avec compression légère.

## Clear de VRAM

### `ClearDataMem`

Clear toute la page courante en zone donnée ($A000-$DFFF) avec une couleur.

```asm
        ldx   #$XXXX                    ; couleur sur 4 pixels (8 bits = 2 pixels en BM16)
        jsr   ClearDataMem
```

Utilisé par `LoadAct` quand `act.X.backgroundSolid=N` est défini.

### `ClearInterlacedDataMemory`

Version pour mode entrelacé.

### `ClearVerticalBandLR` — clear bande verticale

```asm
ClearVerticalBandLR
        tfr   x,y                       ; X = couleur, dupliquée dans Y
        ldu   #$DF40                    ; haut de RAMA
@a
        pshu  x                         ; 1 paire pixels
        leau  -36,U                     ; descend 36 octets (1 ligne en BM16)
        pshu  x,y                       ; 2 paires
        leau  -36,U
        ; ... répété pour clearer une bande verticale
```

Stack blasting pour clear rapide. **IRQ off requis**.

Utile pour clearer une zone partielle (e.g. zone HUD à droite).

Voir [references/clear-routines.md](references/clear-routines.md).

## `GetImgIdA` — utilitaire

```asm
GetImgIdA                                ; charge l'image ID dans A depuis...?
```

Petit helper, à vérifier dans le code.

## Pipeline complet — image de fond

```
1. Property : act.default.backgroundImage=./images/bg.png

2. Builder Java :
   - Convertit PNG en format BM16 (deux plans RAMA + RAMB)
   - Compresse via ZX0 ou stocke brut
   - Génère structure : page + adresse + data
   - Génère label Bgi_default

3. Code asm dans LoadAct :
   - ldb #$02; stb $E7E5 (mount page 2)
   - ldx #Bgi_default
   - jsr DrawFullscreenImage
   - ldb #$03; stb $E7E5 (mount page 3 — pour double buffer)
   - jsr DrawFullscreenImage (deuxième fois)
   
4. Runtime : image affichée, gfxlock alterne entre pages 2 et 3
```

Pour les sprites mobiles, le fond reste intact grâce au mode B (Background backup).

## Pitfalls

- **`DrawFullscreenImage` sans `IrqOff`** : 12 octets garbage en tête de stack
- **`DrawFullscreenImage` qui ne pointe pas une page valide** : crash
- **`ClearDataMem` sans mount préalable** : clear la mauvaise page
- **`DecRLE00` sans `glb_screen_location_1/2`** init : écrit à des adresses random
- **`zx0_mega` sur data non compressé ZX0** : output garbage
- **`bm4.drawChunbks` avec format incorrect** : crash dès la 1ère iter
- **`DrawFullscreenImage` pendant que `DrawSprites` est en cours** : conflit de stack S
- **Format BM4 vs BM16** : différent (4 bits/pixel vs 16-couleurs). Routines pas interchangeables
- **`pshs`/`pulu` avec mauvais alignement** : décalage des pixels
- **IRQ `MarkObjGone`** ou similaire pendant `DrawFullscreenImage` : interruption du blast → glitch

---

## Références détaillées

- [references/fullscreen-images.md](references/fullscreen-images.md) — DrawFullscreenImage stack-blasting technique (lds $DF40 puis $BF40, pulu/pshs), IRQ off requirement, format Bgi_X (page + adresse + data brute ou compressée), génération par builder depuis act.X.backgroundImage property, double-buffer pages 2 et 3
- [references/rle-decoders.md](references/rle-decoders.md) — DecRLE00 / DecMapAlpha format binaire complet (00/01/10/11 + nnnnnn + vvvvvvvv), gestion transparence left/right, ptr offset signé 14-bit, registres y/u/glb_screen_location_1/2, variants pour BM4 vs BM16, performance
- [references/zx0-decoders.md](references/zx0-decoders.md) — ZX0 décompresseur (zx0_6809_mega.asm + variants standard/turbo/mega/mega_back), zx0_decompress entry point, wrapper zx0_6809_mega_wrap pour 2-parts, variant sprite DZX0, intégration avec RAMLoader, compression ratio
- [references/clear-routines.md](references/clear-routines.md) — ClearDataMem / ClearInterlacedDataMemory / ClearVerticalBandLR / ClearCartMemory / ClearDataMemoryRAMx, technique stack blasting (lds + pshu), IRQ off requirement, usage dans LoadAct (backgroundSolid)
