---
name: thomson-to8-engine-bm16-pixel-blit
description: "Affichage horizontal à la granularité d'1 pixel en mode BM16 sur Thomson TO8/TO9, malgré l'entrelacement RAMA/RAMB byte-par-byte qui ne donne nativement que 2 px d'alignement. Technique des 4 buffers pré-compilés indexés par intra=(x&3) : 2 buffers (un par banque) sélectionnés sur 4 à chaque rendu selon le variant. Combine ordre d'écriture des banques (RAMA-first vs RAMB-first = ±2 px) et shift de contenu source (s0 vs s1 par rotation droite 1 px = ±1 px). Couvre la spécificité Thomson : les plans RAMA/RAMB sont physiquement inversés dans la zone $A000-$DF3F (RAMB à $A000, RAMA à $C000). Utile pour : sprites au pixel près, scrolling fluide horizontal, road rendering 3D (Pole Position / OutRun / Lotus / Power Drift-likes), HUD précis. Pour des positions x > 4 px, byte_x=(x>>2) ajoute un décalage entier de bytes au curseur U. Mots-clés : pixel-precise, pixel-perfect, 1px, BM16, RAMA, RAMB, entrelacement, byte interlace, 4 variants, content shift, s0, s1, RAMA-first, RAMB-first, bank order, plane_to_chunks, pixels_to_bm16, U cursor, pshu, pre-compiled buffers, $A000, $C000, plans inversés."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Affichage horizontal au pixel près en BM16 — Thomson TO8/TO9

## Le problème

En BM16 (160×200×16 couleurs), la VRAM est divisée en deux banques **RAMA** et **RAMB** entrelacées **byte par byte**. 1 byte (= 2 nibbles) = 2 pixels écran.

```
Pixels screen   : p0 p1 p2 p3 p4 p5 p6 p7
RAMA bytes      : [p0|p1]       [p4|p5]        ; high nibble | low nibble
RAMB bytes      :       [p2|p3]       [p6|p7]
```

**L'alignement byte natif d'un blitter = 2 px**. Pour positionner au pixel près, il faut un mécanisme additionnel.

### Spécificité Thomson — plans physiquement inversés en zone donnée

Dans la zone `$A000-$DF3F` (= zone donnée vidéo), les adresses physiques RAMA/RAMB sont **inversées** vs le nommage logique :

```
$A000-$BF3F : banque physique RAMB     (40 oct/ligne × 200 lignes)
$C000-$DF3F : banque physique RAMA     (40 oct/ligne × 200 lignes)
```

Le pack logique du contenu reste inchangé (= RAMA bytes encodent la paire gauche, RAMB bytes la paire droite de chaque groupe de 4). Seul le mapping vers les adresses physiques est inversé.

## Mécanisme — 4 buffers, 2 utilisés par rendu

Deux leviers **orthogonaux** combinés donnent 4 sous-positions de 1 px chacune :

| Levier | Effet | Pas |
|---|---|---|
| **Ordre des banques** | RAMA-first vs RAMB-first | ±2 px |
| **Shift contenu source** | s0 vs s1 (= rotation droite 1 px en content) | ±1 px |

Pour chaque unité (= scanline, ligne de sprite, etc.) on pré-compile **4 buffers** mono-banque :

```asm
UnitXXX_table
        fdb   UnitXXX_RAMA_s0       ; offset 0
        fdb   UnitXXX_RAMA_s1       ; offset 2
        fdb   UnitXXX_RAMB_s0       ; offset 4
        fdb   UnitXXX_RAMB_s1       ; offset 6
```

À chaque rendu, le variant `intra = x & 3` (0..3) sélectionne **2 buffers sur 4** :

| intra | bank order | buffer pour banque RAMB ($A000) | buffer pour banque RAMA ($C000) | RAMA cursor +1 |
|:-:|:-:|:-:|:-:|:-:|
| 0 | RAMA-first s0 | RAMB_s0 (off 4) | RAMA_s0 (off 0) | non |
| 1 | RAMA-first s1 | RAMB_s1 (off 6) | RAMA_s1 (off 2) | non |
| 2 | RAMB-first s0 | RAMA_s0 (off 0) | RAMB_s0 (off 4) | **oui** |
| 3 | RAMB-first s1 | RAMA_s1 (off 2) | RAMB_s1 (off 6) | **oui** |

Pour intra 2/3, les deux buffers sont **swappés** entre banques + le curseur d'écriture U de la banque RAMA est avancé d'1 byte (= 2 px) pour aligner le décalage.

## Build pipeline — Python

```python
def compile_variants(content_pixels):
    buffers = {}
    for shift_name, content in [
        ('s0', content_pixels),
        ('s1', content_pixels[-1:] + content_pixels[:-1]),  # rotate right 1 px
    ]:
        rama, ramb = pixels_to_bm16(content)
        buffers[f'RAMA_{shift_name}'] = plane_to_chunks(rama)
        buffers[f'RAMB_{shift_name}'] = plane_to_chunks(ramb)
    return buffers   # 4 buffers de bytes mono-banque

def pixels_to_bm16(content):
    rama, ramb = [], []
    for k in range(len(content) // 4):
        rama.append((content[4*k]   << 4) | content[4*k+1])
        ramb.append((content[4*k+2] << 4) | content[4*k+3])
    return bytes(rama), bytes(ramb)

def plane_to_chunks(plane_bytes):
    """4 bytes/chunk, rightmost en premier (= ordre pshu d,x)."""
    return [plane_bytes[i-4:i] for i in range(len(plane_bytes), 0, -4)]
```

Chaque buffer émet inline une séquence `ldd / ldx / pshu d,x` qui écrit 4 bytes à `U-4..U-1` puis décrémente U.

## Runtime — `BlitAtXY` optimisée

```asm
* ==============================================================================
* BlitAtXY — rend une unité au pixel près à la position (x, y)
* ------------------------------------------------------------------------------
* Sélectionne 2 buffers sur 4 (= variant intra=x&3) et appelle un par banque.
*
* Inputs :
*   A = x (pixel position, 0..max)
*   B = y (scanline, 0..199)
*   X = ptr table 4-buffer (fdb RAMA_s0, RAMA_s1, RAMB_s0, RAMB_s1)
*
* Trashes : A, B, D, X, Y, U
* ==============================================================================

UNIT_WIDTH      equ   40              ; W = bytes/scanline/banque

BlitAtXY
        stx   <bx_tbl                   ; save 4-buf table ptr
        pshs  a,b                       ; sauve x et y sur stack (B=y, A=x intacts)

        * --- D = y * 40 + W (offset rightmost+1 dans la scanline) ---
        lda   #40                       ; B = y déjà en register depuis l'entrée
        mul                             ; D = y * 40
        addd  #UNIT_WIDTH               ; D = y * 40 + W

        * --- D += byte_x (= x >> 2) ---
        pshs  d                         ; sauve D (y*40+W)
        ldb   3,s                       ; B = x (à S+3 après pshs d)
        lsrb
        lsrb                            ; B = byte_x
        clra                            ; D = 00:byte_x
        addd  ,s++                      ; D = byte_x + (y*40+W), pop saved
        std   <bx_scanl_off             ; sauve pour les 2 passes

        * --- A = intra, lookup variant_tbl (entrées 4 oct = intra<<2) ---
        lda   1,s                       ; A = x
        anda  #3                        ; A = intra
        leas  2,s                       ; pop x, y
        asla
        asla                            ; A = intra * 4
        ldx   #variant_tbl
        leax  a,x                       ; X -> entry [ramb_off, rama_off, rama_shift, _]
        stx   <bx_variant               ; sauve (sous-routine buffer peut clobber X)

        * ===== Passe banque RAMB ($A000-$BF3F) =====
        ldu   <bx_scanl_off             ; (LDU+LEAU plus rapide que LDD+ADDD+TFR)
        leau  $A000,u                   ; U = $A000 + y*40 + W + byte_x

        ldy   <bx_tbl                   ; Y = 4-buf table
        ldb   ,x                        ; B = ramb_off (X reste = variant entry)
        jsr   [b,y]                     ; jsr vers *(Y+B) = ptr buffer RAMB pass

        * ===== Passe banque RAMA ($C000-$DF3F, +1 byte si RAMB-first) =====
        ldx   <bx_variant               ; recharge entry
        ldu   <bx_scanl_off
        leau  $C000,u                   ; U = $C000 + y*40 + W + byte_x
        ldb   2,x                       ; B = rama_shift (0 ou 1)
        leau  b,u                       ; U += rama_shift

        ldy   <bx_tbl
        ldb   1,x                       ; B = rama_off
        jmp   [b,y]                     ; tail call vers *(Y+B) = ptr buffer RAMA pass

* --- Table 4 entrées × 4 oct (intra*4 = leax direct) ---
*       ramb_off  rama_off  rama_shift  _
variant_tbl
        fcb       4,        0,         0, 0    ; intra 0 : RAMA-first s0
        fcb       6,        2,         0, 0    ; intra 1 : RAMA-first s1
        fcb       0,        4,         1, 0    ; intra 2 : RAMB-first s0 (swap + RAMA +1)
        fcb       2,        6,         1, 0    ; intra 3 : RAMB-first s1 (swap + RAMA +1)
```

Une seule mul (y × 40), une seule lecture du variant_tbl, indexation 4-aligned sans calcul, tail call sur la 2ᵉ passe. Les 2 passes partagent `bx_scanl_off` en DP pour éviter de recomputer.
