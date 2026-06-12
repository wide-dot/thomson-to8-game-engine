# Système de palette — buffer, refresh, hardware

## ⚠️ Index couleur : PNG vs runtime Thomson — DISTINCTION CRITIQUE

Quand on travaille avec une palette générée depuis un PNG, **les index dans le PNG ne sont PAS les mêmes que les index runtime utilisés par le hardware Thomson**. Il y a un décalage de -1, dû à la convention « index 0 = transparent » dans le PNG.

### Le décalage

Le builder Java (`PaletteTO8.getPaletteData`) lit le PNG ainsi :

```java
// fr.bento8.to8.image.PaletteTO8 (extrait)
for (int colorIndex = 1; colorIndex < 17; colorIndex++) {
    Color couleur = new Color(colorModel.getRGB(colorIndex));
    // couleur écrite dans le slot (colorIndex - 1) de la palette Thomson
}
```

Donc :

| PNG (côté éditeur image)         | Thomson (runtime, registre `$E7DB`) |
|----------------------------------|-------------------------------------|
| index 0 = transparent (implicite) | (rien — la transparence est gérée par le sprite, pas la palette) |
| index 1 = première couleur       | slot 0                              |
| index 2 = deuxième couleur       | slot 1                              |
| ...                              | ...                                 |
| index 16 = seizième couleur      | slot 15                             |

### Conséquence pratique

Quand on écrit du code qui adresse la palette via `$E7DB` (ou les routines `PalRaster_1c`, `PalUpdateNow`), on utilise **les index runtime 0..15**, PAS les index PNG 1..16.

**Exemple concret — table raster pour un sprite road dont la palette PNG contient :**

| PNG index | Couleur sémantique | Index runtime à utiliser dans `fcb idx, M_B, V_R` |
|-----------|-------------------|---------------------------------------------------|
| 0         | (transparent, n'apparaît pas dans la palette Thomson) | — |
| 1         | HERBE             | **0**                                             |
| 2         | BORDURE           | **1**                                             |
| 3         | ROUTE             | **2**                                             |
| 4         | MARQUAGE          | **3**                                             |

```asm
; Table raster — index runtime, pas index PNG !
pal_RoadRaster
        fcb   $00,$00,$80   ; idx 0 = HERBE (PNG idx 1)
        fcb   $01,$00,$0F   ; idx 1 = BORDURE (PNG idx 2)
        fcb   $02,$04,$44   ; idx 2 = ROUTE (PNG idx 3)
        fcb   $03,$0F,$FF   ; idx 3 = MARQUAGE (PNG idx 4)
```

### Vérification

Pour vérifier le shift sur un PNG donné, regarder `PaletteTO8.java` ligne ~50 : la boucle `for (int colorIndex = 1; colorIndex < 17; colorIndex++)` est la source de vérité.

### Pourquoi cette convention

Le PNG-8 garde l'index 0 pour la transparence (utilisé par l'engine au moment du draw du sprite : pixels à 0 ne sont pas écrits). Les couleurs effectivement encodées dans la palette Thomson sont donc PNG[1..16].

**Pitfall classique** : commenter une table raster avec « idx 1 = HERBE » parce que c'est ce qu'on voit dans GIMP/Photoshop, puis écrire `fcb $01,...` dans la table → on tape sur la BORDURE, pas l'HERBE. Bug silencieux, couleurs décalées de 1 slot.

---

## Format d'une couleur

Chaque couleur du TO8 = 2 octets. Décomposition :

```
Octet 1 (haut) :  V V V V  R R R R     ; vert (4 bits) + rouge (4 bits)
Octet 2 (bas)  :  X X X M  B B B B     ; bit marquage + bleu (4 bits)
```

- `V` (Vert) : 4 bits = 16 niveaux (0=noir, 15=max)
- `R` (Rouge) : 4 bits
- `B` (Bleu) : 4 bits
- `M` (Marquage) : 1 bit pour incrustation vidéo (mixing avec vidéo externe). À 0 pour usage standard
- `XXX` : bits ignorés (peuvent être à 0)

Total : 4096 couleurs possibles (16^3), 16 affichables simultanément.

## Table canonique des niveaux RGB (datasheet EF9369)

Le hardware Thomson (gate array palette EF9369) ne produit pas les 16 niveaux de manière linéaire — ils sont espacés selon une courbe logarithmique propre au DAC. La table de conversion officielle est dans `java-generator/src/main/java/fr/bento8/to8/image/PaletteTO8.java` :

```java
private static int to8RGB[] = {0, 97, 122, 143, 158, 171, 184, 194,
                               204, 212, 219, 227, 235, 242, 250, 255};
// relevé de voltage datasheet EF9369
```

| Nibble | RGB 8-bit | Niveau visuel |
|--------|-----------|---------------|
| `$0` | 0 | noir total |
| `$1` | 97 | très foncé |
| `$2` | 122 | foncé |
| `$3` | 143 | gris foncé |
| `$4` | 158 | gris moyen-foncé |
| `$5` | 171 | **gris moyen** |
| `$6` | 184 | gris moyen-clair |
| `$7` | 194 | clair |
| `$8` | 204 | plus clair |
| `$9` | 212 | clair-saturé |
| `$A` | 219 | saturé |
| `$B` | 227 | saturé+ |
| `$C` | 235 | très saturé |
| `$D` | 242 | très saturé+ |
| `$E` | 250 | quasi max |
| `$F` | 255 | max |

**Important** : la courbe n'est PAS `255 * (n/15)` — c'est plus tassé vers le haut. Pour avoir un « gris à 50% perceptuel », `$5` = 171 est plus juste que `$8` = 204.

### Couleurs de référence pour le gameplay

| Couleur voulue | V | R | B | V_R | M_B | RGB rendu |
|----------------|---|---|---|-----|-----|-----------|
| Noir | 0 | 0 | 0 | `$00` | `$00` | (0,0,0) |
| Blanc | F | F | F | `$FF` | `$0F` | (255,255,255) |
| Rouge pur | 0 | F | 0 | `$0F` | `$00` | (255,0,0) |
| Vert pur | E | 0 | 0 | `$E0` | `$00` | (0,250,0) |
| Bleu pur | 0 | 0 | F | `$00` | `$0F` | (0,0,255) |
| Gris moyen | 5 | 5 | 5 | `$55` | `$05` | (171,171,171) |
| Gris clair | 8 | 8 | 8 | `$88` | `$08` | (204,204,204) |
| Cyan | F | 0 | F | `$F0` | `$0F` | (0,255,255) |
| Magenta | 0 | F | F | `$0F` | `$0F` | (255,0,255) |
| Jaune | F | F | 0 | `$FF` | `$00` | (255,255,0) |

**À utiliser** pour les tables raster ou les `Pal_X` custom. Évite de tâtonner et de tomber sur des couleurs visuellement bizarres.

## Buffer en mémoire

```asm
PalRefresh      fcb   $FF              ; flag de refresh
Pal_current     fdb   Pal_buffer       ; pointeur vers la palette courante
Pal_buffer      fill  0,$20            ; 32 octets (16 couleurs × 2)
```

### `PalRefresh` — sémantique inversée

| Valeur | Effet |
|--------|-------|
| `$FF` (positif après `tst`) | Pas de refresh demandé, `PalUpdateNow` skip |
| `$00` (zéro, neutre) | Refresh demandé, `PalUpdateNow` s'exécute |
| Toute valeur != $FF | Refresh demandé |

> Le `com PalRefresh` à la fin de `PalUpdateNow` flip $00 → $FF, marquant la fin.

Usage :
```asm
        clr   PalRefresh                ; demander refresh
        ; ... éventuellement modifier Pal_buffer ...
        ; à la prochaine PalUpdateNow (typiquement depuis UserIRQ), le refresh s'applique
```

### `Pal_current`

Pointeur 2 octets vers la palette **active**. Peut pointer :
- Vers `Pal_buffer` (palette modifiable en RAM)
- Vers une palette en ROM (`Pal_TitleScreen`, `Pal_game`, `Pal_black`, ...)

Switch de palette :
```asm
        ldd   #Pal_TitleScreen          ; palette en ROM
        std   Pal_current
        clr   PalRefresh                ; demander refresh
        jsr   PalUpdateNow              ; appliquer
```

Pour modifier la palette dynamiquement (fade, cycling), pointer vers `Pal_buffer` et modifier directement les 32 octets.

## Accès hardware

| Registre | Adresse | Sémantique |
|----------|---------|------------|
| Index couleur | `$E7DB` | Pose l'index 0-15 de la couleur à modifier |
| Donnée | `$E7DA` | Écrit un octet de couleur, auto-incrémente l'index après chaque écriture |
| Bordure | `$E7DD` | Couleur de la bordure (bits 0-3 = index) |
| Mode page | `$E7E5/$E7E6/$E7E7` | Sélection pages physiques (cf. autre skill) |

Pour écrire les 16 couleurs (32 octets) :
```asm
        lda   #0
        sta   $E7DB                     ; init index = 0
        ; pour chaque couleur (16 fois) :
        lda   #couleur_V_R
        sta   $E7DA                     ; index incrémente automatiquement
        lda   #couleur_M_B
        sta   $E7DA
```

L'auto-incrément évite d'avoir à toucher `$E7DB` pour chaque couleur.

## `PalUpdateNow` — algorithme

```asm
PalUpdateNow 
        tst   PalRefresh
        bne   @rts                      ; $FF → skip
        pshs  dp
        ldd   #$E7
        tfr   b,dp                      ; DP = $E7 pour adressage direct
        ldx   Pal_current               ; X = adresse palette
        sta   <$DB                      ; index 0 dans $E7DB (A déjà à 0 ?)
        
        ; Boucle déroulée — 16 itérations de :
        ldd   ,x                        ; load couleur 0
        sta   <$DA                      ; V_R dans $E7DA
        stb   <$DA                      ; M_B dans $E7DA (auto-inc)
        ldd   2,x                       ; couleur 1
        sta   <$DA
        stb   <$DA
        ; ... 14 fois de plus
        
        com   PalRefresh                ; flag → $FF (plus de refresh)
        puls  dp,pc
@rts    rts
```

### Boucle déroulée vs lean

`PalUpdateNow` (déroulée) :
- ~150 cycles d'exécution
- ~140 octets de code

`PalUpdateNowLean` (compacte) :
- ~225 cycles
- ~50 octets

Choix : la déroulée est utilisée par défaut (perf > taille). Lean utilisée par r-type (cf. `PalUpdateNowLean.asm` inclus dans le main.asm).

### Setup DP

`PalUpdateNow` utilise DP=$E7 temporairement pour accéder à `<$DA` et `<$DB` (=`$E7DA`, `$E7DB`). C'est plus rapide que `sta $E7DA` (mode direct vs étendu).

`pshs dp` au début et `puls dp,pc` à la fin pour préserver le DP de l'appelant.

## Quand appeler `PalUpdateNow`

Cas typiques :

### Au boot du game-mode

```asm
        ldd   #Pal_TitleScreen
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow              ; appliquer immédiatement
```

### Depuis UserIRQ (recommandé)

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow              ; refresh palette à chaque VBL
        ; ... audio ...
        rts
```

C'est le pattern le plus courant : `PalUpdateNow` est appelée à chaque VBL, mais ne fait rien si `PalRefresh = $FF`. Quand un fade/cycling/changement met `PalRefresh = 0`, le refresh s'applique au prochain VBL.

Avantage : pas de tearing palette (la palette change pendant la VBL, donc invisible).

### En milieu de frame (raster)

Pour des effets raster, `PalRaster_1c` change la palette pendant le tracé (cf. `raster-effects.md`).

## Pipeline build — palette depuis PNG

```properties
palette.Pal_TitleScreen=./game-mode/00/images/title.png
```

Le builder (`Palette.java` + `PaletteTO8.getPaletteData`) :
1. Lit le PNG (mode palette indexée, max 16 couleurs)
2. Extrait les 16 couleurs (RGB)
3. Convertit en format TO8 (4 bits par composante, format V_R / M_B)
4. Génère 32 octets dans le code asm, label `Pal_TitleScreen`

Exemple généré :
```asm
Pal_TitleScreen
        fcb $00,$00     ; couleur 0 = noir
        fcb $FF,$0F     ; couleur 1 = blanc
        fcb $0F,$00     ; couleur 2 = rouge
        ; ... 13 couleurs supplémentaires
```

### Quirks du builder

- PNG en mode RGB sans palette : le builder peut échouer ou prendre les 16 premières couleurs trouvées
- PNG avec moins de 16 couleurs : les slots non utilisés sont à 0 (noir)
- Mode palette 8-bit avec > 16 couleurs : tronqué aux 16 premières

Convention : utiliser GIMP / Photoshop pour exporter en PNG palette indexée 4-bit.

## Pitfalls

- **Sens inversé de `PalRefresh`** : confusion classique. `clr` = refresh, `lda #$FF; sta` = skip
- **`Pal_current` mal aligné** : 2 octets bien sûr, mais la palette doit être à une adresse paire ? Non, `ldd` accepte n'importe quelle adresse.
- **Pointer `Pal_current` vers une page non-mountée** : lecture aléatoire au refresh. Toujours pointer vers du code/data résident OU mount avant le refresh
- **Modifier `Pal_buffer` puis basculer `Pal_current` vers une autre palette** : les modifications de Pal_buffer sont perdues si on n'y repointe pas après
- **Appeler `PalUpdateNow` depuis le code utilisateur** sans coordination avec UserIRQ : possible race condition, glitches visuels
- **PNG palette non indexée** : le builder peut générer une palette n'importe comment. Toujours vérifier en mode palette indexée 4-bit
- **Mettre le bit M (marquage)** par erreur : peut produire un effet d'incrustation indésirable. À 0 pour usage standard
