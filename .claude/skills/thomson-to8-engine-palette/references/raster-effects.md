# Effets raster — `PalRaster_1c` et palette à mi-écran

Les effets raster consistent à **changer la palette pendant le tracé de l'écran**, pour obtenir des dégradés ou des effets de couleur impossibles avec une palette statique unique.

## Principe hardware

Le TO8 a une palette de 16 couleurs. Si on change une couleur **juste après que le faisceau cathodique soit passé sur une scanline**, les pixels suivants utiliseront la nouvelle couleur. En répétant à chaque scanline, on peut afficher des dégradés verticaux dans le même slot palette.

Le bit utile pour la synchro est dans `$E7` : 0 = spot dans zone visible, 1 = spot dans zone non-visible (HBlank).

## `PalRaster_1c` — change 1 couleur par scanline

```asm
PalRas_page   fdb $00                   ; page mémoire des données
PalRas_start  fdb $0000                 ; adresse début
PalRas_end    fdb $0000                 ; adresse fin

PalRaster_1c 
        lda   PalRas_page
        _SetCartPageA                   ; mount la page des données raster
        ldx   PalRas_start
        lda   #32        
!       bita  <$E7                      ; attend zone non-visible
        beq   <
!       bita  <$E7 
        bne   <                         ; attend zone visible (= début scanline)
        mul                             ; tempo
        mul
        nop
!       tfr   a,b                       ; tempo
        tfr   a,b
        tfr   a,b
        ldd   1,x                       ; lit V_R, M_B (octets 1-2 de l'entrée)
        std   >*+8                      ; auto-modif pour l'instruction qui suit
        lda   ,x                        ; lit index couleur (octet 0)
        sta   <$DB                      ; pose l'index
        ldd   #0                        ; (auto-modifié plus haut)
        stb   <$DA 
        sta   <$DA
        leax  3,x                       ; 3 octets par entrée
        cmpx  PalRas_end
        bne   <
        rts
```

## ⚠️ Index couleur runtime, pas index PNG

Le premier octet de chaque entrée (`color_idx`) est l'**index RUNTIME** Thomson (0..15), à poser tel quel dans `$E7DB`. Si la palette vient d'un PNG, le builder fait un shift `PNG[1..16] → Thomson[0..15]`, donc **l'idx PNG est = idx runtime + 1**.

Pour adresser la couleur dont l'index visible dans GIMP est 3 (= 3ème couleur du PNG après le 0 transparent), il faut écrire `fcb $02,...` (pas `$03,...`). Cf. [palette-system.md](palette-system.md) section « Index couleur : PNG vs runtime Thomson ».

## Format des données raster — ⚠️ ORDRE BYTES CRITIQUE

Chaque entrée = **3 octets** dans l'ordre :

```
Offset | Taille | Contenu                  | Sémantique
-------|--------|--------------------------|--------------------------------------------------
0      | 1      | Index couleur (0-15)     | Slot palette à modifier
1      | 1      | M_B = (M<<4)|B           | bleu — écrit en SECOND à $E7DA (position N+1)
2      | 1      | V_R = (V<<4)|R           | vert+rouge — écrit en PREMIER à $E7DA (position N)
```

**L'ordre M_B AVANT V_R dans la table est contre-intuitif** mais **obligatoire**. Pourquoi :

1. **Format Thomson palette** : pour la couleur d'index N, 2 octets contigus en mémoire :
   - position N   = `VVVV RRRR` (vert + rouge)
   - position N+1 = `XXXM BBBB` (marquage + bleu)

2. **PalRaster_1c** lit l'entrée et l'écrit en 2 fois à `$E7DA` (auto-incrément interne) :
   ```asm
   ldd   1,x        ; A = byte[1], B = byte[2]
   std   >*+8       ; mémorise dans ldd #imm ci-dessous
   lda   ,x
   sta   <$DB       ; pose l'index de la couleur cible
   ldd   #0         ; (modifié → ldd #imm avec A=byte[1], B=byte[2])
   stb   <$DA       ; écrit B (= byte[2]) EN PREMIER → position N = V_R
   sta   <$DA       ; écrit A (= byte[1]) EN SECOND → position N+1 = M_B
   ```

3. **Conséquence pour la table** :
   - `byte[2]` (offset 2) doit contenir `V_R` (pour aller en position N)
   - `byte[1]` (offset 1) doit contenir `M_B` (pour aller en position N+1)

### Vérification via `Pal_white`

Le fichier `engine/palette/color/Pal_white.asm` contient pour chaque couleur :
```asm
fdb $ff0f
```
Soit en mémoire `[$FF, $0F]` :
- byte[0] = `$FF` → `V=F, R=F` (= blanc V_R)
- byte[1] = `$0F` → `M=0, B=F` (= bleu max M_B)

Cohérent avec la convention « V_R en premier en mémoire, M_B après ». Pour une entrée raster, on a juste un index couleur ajouté **avant**, donc structure : `[idx, M_B, V_R]` car les bytes [1,2] vont être écrits dans l'ordre inverse de leur lecture par `std`.

### Exemple d'entrée — ciel bleu clair (idx 0)

Niveaux Thomson : voir [palette-system.md](palette-system.md) section « Table canonique des niveaux RGB ». La courbe n'est PAS linéaire ; nibble `$F` = 255, `$5` = 171, `$0` = 0.

Pour faire un bleu clair avec V=4, R=4, B=15 (= 0x4, 0x4, 0xF) :
```
V_R = (4<<4) | 4 = $44
M_B = (0<<4) | $F = $0F     (marquage=0)
```

Rendu Thomson : `V=4` → 158, `R=4` → 158, `B=15` → 255 = RGB(158, 158, 255) = bleu clair désaturé.

Dans la table raster :
```asm
fcb   $00,$0F,$44     ; idx=0 (ciel), puis M_B, puis V_R
```

**Si on inverse l'ordre** (`fcb $00,$44,$0F`), les couleurs sont aussi inversées : V_R devient $0F (V=0, R=15) = rouge pur, et M_B devient $44 (M=4 → incrustation activée!, B=4) → jaune-orange étrange. C'est le bug typique.

### Couleurs « primaires » prêtes à l'emploi

Pour les tables raster, voici les codes des couleurs canoniques (cf. table to8RGB) :

| Couleur | `fcb idx, M_B, V_R` |
|---------|---------------------|
| Noir | `fcb $XX,$00,$00` |
| Blanc | `fcb $XX,$0F,$FF` |
| Rouge pur | `fcb $XX,$00,$0F` |
| Vert pur (V=E plutôt que F pour éviter saturation) | `fcb $XX,$00,$E0` |
| Bleu pur | `fcb $XX,$0F,$00` |
| Gris moyen | `fcb $XX,$05,$55` |
| Cyan | `fcb $XX,$0F,$F0` |
| Jaune | `fcb $XX,$00,$FF` |
| Magenta | `fcb $XX,$0F,$0F` |

### Pour un dégradé

Pour un dégradé sur 200 lignes : 200 × 3 = 600 octets de données.

## Pré-requis et synchronisation

`PalRaster_1c` doit être appelée depuis **UserIRQ** (au déclenchement du VBL) pour avoir le bon timing. La boucle interne attend chaque scanline via `bita <$E7`.

```asm
UserIRQ
        jsr   PalRaster_1c              ; effet raster pour cette frame
        ; ... autres ...
        rts
```

⚠️ **Pas appelable depuis MainLoop** : la synchro spot serait perdue.

## Setup typique

```asm
        ; au boot du game-mode
        ldd   #raster_data_pal_page     ; page contenant les données
        std   PalRas_page
        ldd   #raster_data_start
        std   PalRas_start
        ldd   #raster_data_end
        std   PalRas_end

raster_data_start
        fcb   0, $80, $0F               ; ligne X : couleur 0 = bleu clair
        fcb   0, $70, $0E               ; ligne X+1 : couleur 0 = légèrement plus foncé
        fcb   0, $60, $0D
        ; ...
raster_data_end
```

Effet : la couleur 0 change graduellement au fil des scanlines, créant un dégradé vertical.

## Tempo et calibrage

Les instructions `mul` / `nop` / `tfr a,b` dans le code servent de **tempo** pour synchroniser précisément avec le timing scanline. Le 6809 à 1 MHz fait ~250 cycles par scanline visible (TO8 a ~63µs/scanline = 63 cycles à 1 MHz × ... — chiffres à vérifier).

Le calibrage est délicat : si on est en retard, on change la couleur au milieu de la scanline → glitch. Si on est en avance, on attend trop → on rate la scanline.

Code optimal pour un changement = ~30 cycles. Au-delà, on peut louper une scanline.

## Cas d'usage

### Sky gradient

```
ligne 0..30 : couleur 0 = bleu très clair (haut du ciel)
ligne 31..60 : transitions...
ligne 61..90 : bleu plus foncé
ligne 91..120 : couleurs sunset (orange/rouge)
ligne 121..150 : transitions
ligne 151..200 : noir (silhouette)
```

Génère un dégradé de coucher de soleil en utilisant seulement 1 slot palette (la couleur 0 du fond).

### Horizon

Changement d'index 1 couleur à la ligne où l'horizon coupe l'image → permet d'avoir un ciel et un sol avec la même slot palette.

### Effet plasma vertical

Combiner cycling temporel + change spatial pour créer un plasma.

## Variantes

L'engine ne fournit que `PalRaster_1c` (1 couleur). Pour changer plusieurs couleurs par scanline, il faudrait :
- Augmenter le tempo pour chaque écriture supplémentaire (1 couleur prend ~10 cycles)
- Vérifier que le total tient dans le HBlank (~50 cycles disponibles)

Pratique : `PalRaster_2c` (2 couleurs) serait faisable. `PalRaster_3c` (3 couleurs) tendu.

Sonic-2 utilise `PalRaster_1c` extensivement (cf. game-mode/title-screen).

## Pitfalls

- **Ordre des bytes inversé** (V_R avant M_B dans la table) : couleurs visuellement fausses (canal vert ↔ canal bleu). Le code compile et tourne, mais les teintes sont absurdes (e.g. ciel jaunâtre au lieu de bleu). Bug très piégeux car aucune erreur ne remonte. Ordre correct : **`idx, M_B, V_R`** — cf. section dédiée plus haut.
- **Appel depuis MainLoop** : sync spot perdue, glitches visuels
- **`PalRas_page` non mountée** : lecture de données aléatoires, couleurs random
- **`PalRas_end` < `PalRas_start`** : boucle infinie
- **`PalRas_start` mal aligné** : décalage de scanline (raster qui « bouge » d'une ligne au tour suivant)
- **Tempo modifié dans `PalRaster_1c`** : le calibrage est perdu, glitches
- **Mode graphique modifié au milieu du raster** : le timing change avec la résolution
- **Trop de scanlines à parcourir** : si la routine n'a pas fini avant la fin de la frame, le débordement écrase la trame suivante
- **Conflit avec `PalUpdateNow`** : si `PalRaster_1c` et `PalUpdateNow` sont appelés tous deux dans UserIRQ, le `PalUpdateNow` doit être avant (ou après mais sans débordement)
