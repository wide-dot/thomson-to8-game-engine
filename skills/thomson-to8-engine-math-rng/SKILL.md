---
name: thomson-to8-engine-math-rng
description: "Décrit les routines mathématiques et le RNG du Thomson TO8/TO9 game engine (Bento8/wide-dot) : CalcSine pour sinus/cosinus rapide via table (input B = angle 0-255 = 0-360 degrés, output D = 255*sin, X = 255*cos, table sinewave.bin de 256 entrées + 128 offset cos), CalcAngle pour arctangente y/x via division logarithmique + table atan + ajustement octants (input D=y signed 16 bits, X=x signed 16 bits, output B = angle 0-255 avec 0 à l'est et progression horaire), Mul9x16 pour multiplication signed 9 bits × signed 16 bits (result = product/256, input D=multiplier 9-bit, X=multiplicand 16-bit, output D), RandomNumber et InitRNG pour pseudo-random (seed initialisé depuis $E7C6 timer hardware, algorithme par Samuel Devulder utilisant lsra/rorb/eorb), macro _rnda pour générer un nombre aléatoire entre min et max (range = max-min+1 multiplié par RandomNumber + min), format fixed-point 8.8 et 16.8 pour positions/vitesses, conventions d'angle 0-255 (256 degrés au lieu de 360 pour exploiter l'arithmétique 8 bits, 255=360°, 192=90°, 128=180°, 64=270°), tables pré-calculées (sinewave.bin), code par Johan Forslof (doynax) pour atan2 6502 porté en 6809. Utiliser pour calculer un déplacement angulaire, trouver l'angle vers le joueur (IA d'ennemis), générer un déplacement aléatoire, tirer au sort une variante d'objet, multiplier des coordonnées (e.g. position * vitesse), initialiser le RNG au boot. Mots-clés : CalcSine, CalcAngle, Mul9x16, RandomNumber, InitRNG, RNG_seed, _rnda, _rnd, Sine_Data, sinewave.bin, atan2, arctangent, sinus, cosinus, 256 degrees, 360 degrees, angle 0-255, signed 9 bit, signed 16 bit, fixed-point 8.8, multiplier, multiplicand, doynax, Forslof, Samuel Devulder, pseudo-random, seed, $E7C6 timer."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Math et RNG — Thomson TO8/TO9 Game Engine

L'engine fournit des **routines mathématiques** optimisées 6809 pour le gameplay :

| Routine | Rôle | Cycles ~ |
|---------|------|----------|
| `CalcSine` | sin + cos | ~30 |
| `CalcAngle` | atan2 | ~150-200 |
| `Mul9x16` | multiplication 9×16 | ~50 |
| `RandomNumber` | PRNG | ~25 |
| `InitRNG` | init PRNG | ~10 |
| `_rnda` macro | aléatoire entre min et max | ~50 |

---

## Convention d'angle — 0-255 (256 degrés)

```
255 = 360°  (= 0°)
192 = 270°
128 = 180°
64  = 90°
0   = 0°
```

Note : c'est **256 degrés** au lieu de 360. Choix : exploite l'arithmétique 8 bits (overflow automatique à 255+1 = 0).

Sens horaire :
```
       0
       ↑
 192 ←   → 64
       ↓
      128
```

(0 = est, progression horaire)

---

## `CalcSine` — sinus et cosinus

```asm
        ldb   #angle                    ; angle 0-255
        jsr   CalcSine
        ; D = 255 * sin(angle)
        ; X = 255 * cos(angle)
```

Implémentation :
```asm
CalcSine
        ldx   #Sine_Data
        anda  #0                        ; A = 0
        aslb                            ; *2 (table 2 octets/entrée)
        rola
        leax  d,x
        ldd   ,x                        ; sin
        leax  $80,x                     ; cos = sin + 90° (= +128 → +256 entries × 2 = +$80)
        ldx   ,x                        ; cos
        rts

Sine_Data
        INCLUDEBIN "./engine/math/sinewave.bin"
```

Table : `sinewave.bin` = 256 entrées de 2 octets (512 octets total). Chaque entrée = `255 * sin(angle * 360/256)` en signed 16.

Le cos est calculé en lisant l'entrée à `+$80` (= +128 angles = +90°).

### Output signed 16-bit

`D` et `X` sont signed 16 bits (-255 à +255 environ).

Pour utiliser comme vitesse 8.8 :
```asm
        jsr   CalcSine
        ; D = sin scalé sur 255
        ; Pour vitesse : divisible par une vitesse
        ;   D / 4 = vitesse modulée par sin
```

Voir [references/sine-cosine-table.md](references/sine-cosine-table.md).

---

## `CalcAngle` — arctangente y/x

```asm
        ldd   #y                        ; D = y signed 16-bit
        ldx   #x                        ; X = x signed 16-bit
        jsr   CalcAngle
        ; B = angle 0-255
```

Calcule `atan2(y, x)` = angle pour aller du point (0,0) au point (x,y).

Algorithme (par Johan Forslof / doynax, porté en 6809) :
1. Down-scale les valeurs 16-bit en 9-bit (perte de précision mais OK pour angles)
2. Division logarithmique de y/x
3. Lookup dans table atan
4. Ajustement d'octant (selon les signes de x et y)

Coût : ~150-200 cycles selon le chemin.

### Usage typique — IA qui vise

```asm
        ; Ennemi en (enemy_x, enemy_y), cible en (player_x, player_y)
        ldd   <player_y
        subd  <enemy_y                  ; D = delta y
        ldx   <player_x                 ; (load player_x)
        ; sub X from current enemy_x...
        ; (calcul du delta x via une intermédiation)
        ldx   <delta_x_computed
        jsr   CalcAngle
        stb   <enemy_angle              ; angle vers le joueur

        ; Maintenant on peut faire avancer l'ennemi dans cette direction
        ldb   <enemy_angle
        jsr   CalcSine
        ; D = sin(angle), X = cos(angle)
        ; Utilise comme x_vel/y_vel scalé
```

Voir [references/atan2-logarithmic.md](references/atan2-logarithmic.md).

---

## `Mul9x16` — multiplication 9×16

```asm
        ldd   #multiplier               ; D = signed 9-bit
        ldx   #multiplicand             ; X = signed 16-bit
        jsr   Mul9x16
        ; D = (product / 256)
```

Multiplication signed sur 9 et 16 bits, résultat scalé par 1/256.

Le 6809 a un `MUL` natif (8×8 → 16) mais pas plus. Pour multiplier 9×16, il faut une routine logicielle.

Variables internes (DP) :
```asm
@m      equ dp_engine                   ; multiplier signé
@m_h    equ dp_engine+1                 ; multiplicand high
@m_l    equ dp_engine+2                 ; multiplicand low
@r_h    equ dp_engine+3                 ; result high
@r_l    equ dp_engine+4                 ; result low
@r      equ dp_engine+5                 ; ?
```

### Cas d'usage

- Multiplier une vitesse par un facteur scalable
- Calculer une position depuis vitesse × temps
- Apply sin/cos pour rotation

---

## `RandomNumber` — PRNG

```asm
        jsr   RandomNumber
        ; D = nombre aléatoire (16 bits)
        ; B = octet bas (souvent suffisant)
```

Algorithme par Samuel Devulder (LFSR/XOR-shift variant) :

```asm
RandomNumber
        ldd   #0
RNG_seed equ *-2                        ; seed mémorisée (auto-modif)
        lsra
        rorb
        eorb  RNG_seed
        stb   @a
        rorb
        eorb  RNG_seed+1
        tfr   b,a
        eora  #0
@a      equ *-1
        std   RNG_seed
        rts
```

Coût : ~25 cycles. Distribution acceptable pour le gameplay (pas crypto).

### `InitRNG`

```asm
InitRNG
        ldd   $E7C6                     ; timer 6846 MSB:LSB
        std   RNG_seed
        rts
```

Seed depuis le timer hardware (= valeur imprévisible au boot). À appeler une fois au démarrage.

> **Pourquoi `$E7C6`** : c'est le timer 6846 (`MC6846.TMSB`). Sa valeur dépend du temps écoulé depuis le power-on / reset, donc unpredictable.

### Macro `_rnda`

```asm
_rnda MACRO
        jsr   RandomNumber
        lda   #\2-\1+1                  ; range = max - min + 1
        mul                             ; multiplie B (du RNG) par range
        ; B*range / 256 dans A
 IFEQ \1-1
        inca
 ELSE IFNE \1
        adda  #\1                       ; ajoute min
 ENDC
 ENDM
```

Usage :
```asm
        _rnda 0,9                       ; A = nombre aléatoire 0-9
        _rnda 1,6                       ; A = nombre aléatoire 1-6 (dé)
        _rnda 0,255                     ; A = octet aléatoire complet
```

Pratique pour positionner aléatoirement, tirer un subtype, etc.

Voir [references/random-number.md](references/random-number.md).

---

## Fixed-point 8.8

Format utilisé par `x_vel`, `y_vel`, `x_acl`, `y_acl` :
- **8 bits partie entière** (signed, -128 à +127)
- **8 bits partie fractionnaire** (0 à 0.996)

Exemples :
- `$0100` = 1.0
- `$0080` = 0.5
- `$0040` = 0.25
- `$FF80` = -0.5 (signed)
- `$FE00` = -2.0

### Multiplication 8.8 × 8.8

Difficile sur 6809 sans MUL 16×16. Utilise `Mul9x16` ou décompose en plusieurs MUL 8×8.

Pour multiplier `(a.b) × c` (un scaling par 8 bits) :
- `mul a × c` → produit haut
- `mul b × c` → produit bas
- Combine

### Format 16.8

Pour `x_pos`/`y_pos` : 2 octets entier + 1 octet sub-pixel = 3 octets.

Permet positions absolues sur une map jusqu'à -32768/+32767.

Voir [references/fixed-point-88.md](references/fixed-point-88.md).

---

## Patterns d'usage

### Mouvement circulaire

```asm
        ; Objet qui décrit un cercle autour d'un centre
        lda   <my_angle                 ; angle courant
        ldb   #1                        ; speed angle
        adda  ,
        sta   <my_angle                 ; avance l'angle
        
        ldb   <my_angle
        jsr   CalcSine
        ; D = sin, X = cos
        
        ; Position = centre + radius * (cos, sin)
        ldd   <center_x
        addd  ,                         ; (X scaled par radius)
        std   x_pos,u
        ; idem pour y
```

### Visée vers le joueur

```asm
        ldd   <player_y_pos
        subd   <y_pos,u                 ; delta y
        ldx   <player_x_pos
        ldx   <x_pos,u                  ; ... delta x
        jsr   CalcAngle
        stb   <ennemy_aim_angle

        ; Calcule vitesse dans cette direction
        ldb   <ennemy_aim_angle
        jsr   CalcSine
        ; D = sin/cos, scale and store as x_vel/y_vel
```

### Random spawn

```asm
        ; Position X aléatoire 0-159
        _rnda 0,159
        sta   x_pixel,u
        
        ; Position Y aléatoire 0-199
        _rnda 0,199
        sta   y_pixel,u
```

### Random subtype

```asm
        ; Tirer un type d'ennemi parmi 5
        _rnda 0,4
        sta   subtype,u
```

---

## Pitfalls

- **`InitRNG` non appelé** : RNG_seed = 0 → séquence prévisible identique à chaque boot
- **Appel `RandomNumber` depuis IRQ + MainLoop** : potentielle race condition sur RNG_seed
- **`CalcSine` avec angle > 255** : pas un problème (B est 8 bits), wrap-around automatique
- **`CalcAngle` avec x=y=0** : indéfini mathématiquement, comportement variable
- **`Mul9x16` avec multiplier > 9 bits** : truncation à 9 bits, résultat incorrect
- **Mélanger 256-deg et 360-deg** : convertir explicitement (256/360 ≈ 0.711)
- **Format fixed-point non cohérent** : un côté `$0100`=1.0 et l'autre `$0080`=1.0, déphasage
- **Distribution `_rnda` non uniforme** pour grand range : `B*range/256` peut être biaisé sur les extrêmes

---

## Références détaillées

- [references/sine-cosine-table.md](references/sine-cosine-table.md) — CalcSine algorithm, table sinewave.bin (256 entrées × 2 octets), output scaled by 255, cos via offset $80, conversion 256-deg vers 360-deg, génération de la table (script Python ou pré-calculé)
- [references/atan2-logarithmic.md](references/atan2-logarithmic.md) — CalcAngle algorithm by doynax (originally 6502, port 6809), division logarithmique pour ratio y/x, table atan, ajustement octant, scaling 16-bit → 9-bit, variables DP, performance ~150 cycles
- [references/random-number.md](references/random-number.md) — RandomNumber algorithm by Samuel Devulder, RNG_seed auto-modif, InitRNG from timer $E7C6, _rnda macro pour range, qualité statistique du PRNG, alternative SBCL plus complexe si besoin crypto
- [references/fixed-point-88.md](references/fixed-point-88.md) — Format 8.8 fixed-point signed, exemples ($0100, $0080, $FF80), x_vel/y_vel/x_acl/y_acl, format 16.8 pour x_pos/y_pos avec sub-pixel, multiplication 8.8 × 8.8 (via MUL 8x8 ou Mul9x16), conversion vers entier
