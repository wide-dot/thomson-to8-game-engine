# `objects/<objet>/<objet>.properties` — référence exhaustive

Le `.properties` d'un objet déclare son **code asm**, ses **sprites** (frames d'images), ses **animations**, et optionnellement des **sons**, **données binaires**, **tilesets** et **données d'animation**.

Format : `clé=valeur` (java.util.Properties via `OrderedProperties`). Chargé par `Object.java`.

---

## Clés au niveau objet

| Clé | Obligatoire ? | Multiple ? | Rôle |
|-----|---------------|------------|------|
| `code` | OUI (sauf si `common-code`) | non | Chemin vers le `.asm` de l'objet, suivi optionnellement de `;RAM` |
| `common-code` | OUI (sauf si `code`) | non | Marque le code comme commun (réservé pour usage futur) |
| `sprite.Img_<Nom>` | OUI si l'objet est graphique | oui | Déclare un sprite avec son image et ses variantes |
| `animation.Ani_<Nom>` | optionnel | oui | Déclare une séquence d'animation |
| `animation-data` | optionnel | **1 seule** | Données binaires d'animation pré-générées (ex: scripts moveByScript) |
| `sound.<Nom>` | optionnel | oui | Déclare un son ou une donnée binaire |
| `data.<Nom>` | optionnel | oui | Alias de `sound.X` (mêmes propriétés, nom plus parlant pour des binaires non-audio) |
| `tileset.<Nom>` | optionnel | oui | Déclare un tileset (pour scrolling, maps) |
| `spriteIndex` | optionnel | non | Si vaut `RAM`, l'index des sprites est placé en RAM (sinon ROM) |
| `animationIndex` | optionnel | non | Si vaut `RAM`, l'index des animations est placé en RAM (sinon ROM) |

> Le builder lève une exception si **les deux** `code` et `common-code` sont définis, ou si **aucun des deux** ne l'est (cf. `Object.java` lignes 62-69).

---

## 1. `code` — chemin du code asm de l'objet

```properties
code=./objects/player/player.asm
code=./objects/enemy/enemy.asm;RAM
```

- Le chemin est relatif à la racine du game-project.
- Le suffixe optionnel `;RAM` (`codeInRAM=true`) force le placement du code en RAM. Par défaut, le code va en ROM cartouche T2 (s'il y a une cible T2) et en page chargée sur disquette pour FD.

### `common-code` (réservé)

```properties
common-code=./global/common/audio-shared.asm
```

Marque ce code comme partagé. **Pas encore implémenté** : commentaire `// TODO common-code is not yet implemented` dans `Object.java`. Évite de l'utiliser pour l'instant.

---

## 2. `sprite.Img_<Nom>=<image>;<variants>;<RAM?>`

Déclare un sprite (= une frame d'image avec ses transformations possibles).

### Syntaxe complète

```
sprite.Img_<Nom>=<file>[:<assoc>][,<refFile>[,<assoc>][,<interlaceFlag>]];<variants>[;RAM]
```

| Position | Champ | Description |
|----------|-------|-------------|
| 1 | `file` | Chemin du PNG source (obligatoire) |
| 1 (après `:`) | `assoc` | Index palette associé, ex: `_autopal(2-5)` |
| 1 (après `,`) | `refFile` | PNG de référence pour diff (compression delta) |
| 1 (après `,,`) | `assoc` (alternative) | Même que `:` mais en 3e champ csv |
| 1 (après `,,,`) | `interlace` | `_full` = pas d'entrelacement (par défaut entrelacé) |
| 2 | `variants` | Liste séparée par virgules des variantes à compiler |
| 3 | `RAM` | Si présent, place le sprite en RAM |

### Exemples

```properties
# Sprite simple : draw seul, position 0
sprite.Img_logo=./objects/logo/logo.png;ND0

# Sprite avec backup/draw/erase, positions 0 et 1 (pour shifts de 1px)
sprite.Img_Player_Idle_001=./objects/player/image/idle-001.png;NB0,NB1

# Sprite + flip horizontal (X) avec backup, positions 0/1 normales + flip
sprite.Img_Player_Run_001=./objects/player/image/run0001.png;NB0,NB1,XB0,XB1

# Sprite plein écran (background)
sprite.Img_titleScreen=./objects/background/title.png,./objects/background/title.png,,_full;ND0

# Sprite delta (image diff par rapport à ref)
sprite.Img_anim_001=./objects/anim/001.png,./objects/anim/000.png;ND0

# Sprite forcé en RAM
sprite.Img_critical=./objects/critical/img.png;NB0;RAM
```

### ⚠️ Règle critique côté code asm pour les variants `D` (Draw seul)

Si tu déclares un variant `ND0`, `ND1`, `XD0`, `XD1`, `YD*`, `XYD*` (mode Draw **sans backup**), le code asm de l'objet doit **obligatoirement** poser `render_overlay_mask` dans `render_flags,u` dans la routine `Init` :

```asm
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
```

**Sans ce flag**, l'engine traite le sprite comme un mode backup (B) et cherche un code d'erase qui n'a pas été compilé → **le sprite est invisible**, sans message d'erreur. Bug très piégeux : on cherche pendant des heures.

Pour les variants `NB*`/`XB*`/`YB*`/`XYB*` (mode Backup), `render_overlay_mask` doit **rester à 0**.

### Syntaxe des **variantes**

Une variante est une chaîne du type `<orientation><mode><shift>`. Plusieurs variantes par sprite sont séparées par virgules dans le 2e champ.

| Code | Élément | Description |
|------|---------|-------------|
| `N` | orientation | **N**ormal (orientation source) |
| `X` | orientation | flip horizontal (mi**X**) |
| `Y` | orientation | flip vertical |
| `XY` | orientation | flip horizontal + vertical |
| `B` | mode | **B**ackup background + draw + erase (sprite mobile sur fond) |
| `D` | mode | **D**raw seul, pas de sauvegarde de fond (sprite statique ou fond) |
| `0` | shift | position pair (pixel 0) |
| `1` | shift | position impair (décalage 1 pixel) |
| `DMAP` | mode spécial | Draw avec encodage RLE map |
| `DZX0` | mode spécial | Draw avec compression ZX0 |

Composition typique : `<orientation><mode><shift>`

| Variante | Signification |
|----------|---------------|
| `NB0` | Normal, Backup mode, position 0 |
| `NB1` | Normal, Backup mode, position 1 (shift 1px) |
| `ND0` | Normal, Draw seul, position 0 |
| `ND1` | Normal, Draw seul, position 1 |
| `XB0` / `XB1` | Flip horizontal, Backup |
| `YB0` / `YB1` | Flip vertical, Backup |
| `XYB0` / `XYB1` | Flip H+V, Backup |
| `XD0` / `XD1` | Flip horizontal, Draw seul |
| `DMAP` | Draw avec encodage MAP RLE (compression d'images de fond) |
| `DZX0` | Draw avec compression ZX0 |

### Quelle variante utiliser ?

- **Sprite mobile** (joueur, ennemi qui bouge à 1px près) : `NB0,NB1` au minimum, **plus** `XB0,XB1` si le sprite doit être miroir → `NB0,NB1,XB0,XB1`
- **Sprite fixe** (icône, HUD, logo) : `NB0` suffit
- **Image de fond** : `ND0` ou `ND0;_full` (cas `Img_intro_000=path,path,,_full;ND0`)
- **Sprite tilemap** : `DMAP` (compression RLE optimisée pour tiles)
- **Données de scroll** : `DZX0` (compression ZX0)

### `_autopal(min-max)` — palette automatique

Permet au builder de tester différentes permutations de palette pour optimiser la compression :

```properties
sprite.Img_anim_001=./image.png:_autopal(2-5),./image_ref.png;ND0
```

Le builder essaiera différentes permutations des index palette 2 à 5 (4 couleurs) pour minimiser la taille compressée.

> ⚠️ **Index PNG vs index runtime Thomson** : les valeurs `2-5` dans `_autopal(2-5)` sont des **index PNG** (indexation côté éditeur image, avec 0 = transparent). À l'exécution, ils correspondent aux slots Thomson `1-4` (shift de -1, cf. `PaletteTO8.java` qui lit le PNG sur les index 1..16 et écrit dans les slots Thomson 0..15). Si on adresse manuellement la palette via `$E7DB` ou des tables raster, utiliser l'index **runtime** = idx PNG − 1. Voir [thomson-to8-engine-palette/references/palette-system.md](../../thomson-to8-engine-palette/references/palette-system.md) section "Index couleur : PNG vs runtime Thomson".

### `_full` — désactiver l'entrelacement

```properties
sprite.Img_intro_000=./000.png,./000.png,,_full;ND0
```

Force le mode plein écran non-entrelacé. Utile pour les images de splash / titre statiques.

---

## 3. `animation.Ani_<Nom>=...` — séquence d'animation

Le builder supporte **deux formats** d'animation. La distinction se fait sur la **présence d'une virgule** dans le premier champ après le `=`.

### Format v00 — simple (legacy)

Le 1er champ est un entier : **duration globale** (durée commune en frames pour toutes les images).

```
animation.Ani_<Nom>=<duration>;<Img_1>;<Img_2>;...;<endTag>[;<param>]
```

```properties
animation.Ani_Idle=2;Img_Idle_000;Img_Idle_001;Img_Idle_002;Img_Idle_003;_resetAnim
animation.Ani_Run=4;Img_Run_001;Img_Run_002;Img_Run_003;Img_Run_004;_goBackNFrames;3
animation.Ani_Die=0;Img_Die_001;_nextRoutine
```

- `duration` est stockée **moins 1** en mémoire (`0` = 1 frame par image, `1` = 2 frames, etc.)
- Chaque `Img_<X>` est résolu en pointeur vers le sprite (2 octets `fdb`)
- Les `_endTags` (cf. ci-dessous) terminent la séquence

### Format v02 — avancé (durée + flags par frame)

Le 1er champ contient des virgules : chaque frame est `<Img>,<duration>,<flags>` :

```
animation.Ani_<Nom>=<Img_1>,<duration>,<flags>;<Img_2>,<duration>,<flags>;...;<endTag>[;<param>]
```

```properties
animation.Ani_PlayerWalk=Img_Walk_001,4,$00;Img_Walk_002,4,$00;Img_Walk_003,4,$00;_resetAnim
animation.Ani_AttackCombo=Img_Atk_001,3,$00;Img_Atk_002,2,$01;Img_Atk_003,5,$02;_nextRoutine
```

- `duration` (per frame, décrémentée de 1 par le builder) — nombre de frames d'affichage de cette image
- `flags` (1 octet) — offset dans une `anim_flags` LUT, sert à déclencher des callbacks (hitbox, son) au moment précis de cette frame
- Format stocké en mémoire : 5 octets par frame (`fdb image; fcb duration; fcb flags`)

> **Important** : Le builder déclenche `Animation v02 need three comma separated parameters` si le champ contient une virgule mais pas exactement deux virgules.

### Tags de fin d'animation

| Tag | Taille (octets) | Effet |
|-----|-----------------|-------|
| `_resetAnim` | 1 | Recommence l'animation depuis le début (boucle infinie) |
| `_goBackNFrames` | 2 | `_goBackNFrames;<N>` — Recule de N frames dans la séquence |
| `_goToAnimation` | 3 | `_goToAnimation;<Ani_X>` — Bascule sur une autre animation (pointeur 2 octets) |
| `_nextRoutine` | 1 | `inc routine,u` — passe à la routine suivante de l'objet |
| `_resetAnimAndSubRoutine` | 1 | Reset anim ET routine secondaire (`routine_secondary=0`) |
| `_nextSubRoutine` | 1 | `inc routine_secondary,u` |

Exemples :
```properties
animation.Ani_LoopForever=2;Img_a;Img_b;Img_c;_resetAnim

animation.Ani_PingPong=2;Img_a;Img_b;Img_c;Img_d;_goBackNFrames;3
; Lecture : a,b,c,d puis recule de 3 = revient à b, donc lit b,c,d,b,c,d,... 

animation.Ani_ChainToOther=2;Img_intro_a;Img_intro_b;_goToAnimation;Ani_loop
; Joue Ani_intro_a puis Ani_intro_b puis bascule sur Ani_loop

animation.Ani_AnimateThenStateChange=2;Img_die_a;Img_die_b;_nextRoutine
; Joue l'anim puis incrémente routine,u — l'objet passe à sa logique suivante
```

---

## 4. `animation-data` — données binaires associées à l'animation

```properties
animation-data=./global/preset/loadFirePreset.bin
```

Place un blob binaire **au début** des données d'animation de l'objet (référencé par `AnimationBin`). Cas d'usage : scripts précompilés `moveByScript`, tables de constantes spécifiques.

> Limité à **1 seule** entrée par objet (`if (animationDataProperties.size()>1) throw new Exception`).

---

## 5. `sound.<Nom>` et `data.<Nom>` — données binaires

Mêmes propriétés (le builder fusionne les deux maps : `soundsProperties.putAll(dataProperties)`).

```
sound.<Nom>=<file>[;RAM]
data.<Nom>=<file>[;RAM]
```

```properties
# Audio
sound.Snd_jump=./objects/player/sounds/jump.bin
sound.Snd_die=./objects/player/sounds/die.bin;RAM

# Données binaires non-audio (préférer data.)
data.Lvl_map=./objects/levels/01/map.bin
data.Lvl_tiles=./objects/levels/01/tiles.bin;RAM
```

Le suffixe `;RAM` force le placement en RAM (sinon ROM).

> Note du code source : `// TODO sound is to be renamed by data — we are using an alias here`. Préférer `data.X` pour les binaires non-audio.

---

## 6. `tileset.<Nom>` — tilesets pour scrolling

Syntaxe :
```
tileset.<Nom>=<file>;<nbTiles>,<nbColumns>,<nbRows>[,<centerMode>[,<mapFile>[,<mapBitDepth>]]]
```

| Champ | Valeur | Description |
|-------|--------|-------------|
| `file` | chemin PNG | Image du tileset (une grille de tiles) |
| `nbTiles` | entier | Nb total de tiles dans l'image |
| `nbColumns` | entier | Nb de colonnes de la grille |
| `nbRows` | entier | Nb de lignes de la grille |
| `centerMode` | `CENTER`/`TOP_LEFT`/`TILE8x16`/`TILE16x16` | Mode de centrage (défaut `TOP_LEFT`) |
| `mapFile` | chemin | Fichier de map de tiles (optionnel) |
| `mapBitDepth` | `8` ou autre | Profondeur de bit pour les ID de tiles dans la map (défaut 8) |

```properties
tileset.TileSet_levelA=./objects/scroll/levelTilesetA.png;61,8,8,TILE16x16
tileset.TileSet_with_map=./objects/scroll/tiles.png;100,10,10,TILE16x16,./objects/scroll/map.bin,16
```

> Les tilesets sont **toujours placés en RAM** (`tileset.inRAM = true;` codé en dur, commentaire : « tileset should always be in RAM for rendering speed »).

---

## 7. `spriteIndex=RAM` / `animationIndex=RAM`

Place respectivement l'**index des sprites** et l'**index des animations** en RAM au lieu de ROM. Utile quand on a beaucoup de sprites/animations et qu'on veut éviter le bank switching.

```properties
spriteIndex=RAM
animationIndex=RAM
```

Aucun effet si la valeur n'est pas `RAM` (équivalent à absent).

---

## Exemples complets

### Objet minimal — un fond non-animé

```properties
code=./objects/background/background.asm

sprite.Img_background=./objects/background/image/bg.png;ND0
```

### Player avec idle + run + flip horizontal (pattern bubble-bobble)

```properties
code=./objects/player/player.asm

# Sprites en mode Backup, positions 0/1, et leurs miroirs horizontaux
sprite.Img_Player_Run_001=./objects/player/image/run0001.png;NB0,NB1,XB0,XB1
sprite.Img_Player_Run_002=./objects/player/image/run0002.png;NB0,NB1,XB0,XB1
sprite.Img_Player_Run_003=./objects/player/image/run0003.png;NB0,NB1,XB0,XB1
sprite.Img_Player_Jump_001=./objects/player/image/jump0001.png;NB0,NB1,XB0,XB1
sprite.Img_Player_Fall_001=./objects/player/image/fall0001.png;NB0,NB1,XB0,XB1

# Animations
animation.Ani_Player_Wait=20;Img_Player_Run_001;Img_Player_Run_003;_resetAnim
animation.Ani_Player_Run=4;Img_Player_Run_001;Img_Player_Run_002;Img_Player_Run_003;_resetAnim
animation.Ani_Player_Jump=4;Img_Player_Jump_001;_resetAnim
animation.Ani_Player_Fall=4;Img_Player_Fall_001;_resetAnim
```

### Background animé (image plein écran, pattern 2026)

```properties
code=./objects/background/background.asm

# Sprite chaque frame est un delta de la frame précédente
sprite.Img_intro_000=./objects/background/frameintro/000.png,./objects/background/frameintro/000.png,,_full;ND0
sprite.Img_intro_006=./objects/background/frameintro/006.png,./objects/background/frameintro/000.png,,_full;ND0
sprite.Img_intro_010=./objects/background/frameintro/010.png,./objects/background/frameintro/006.png,,_full;ND0
# ... (chaque frame = delta avec une frame précédente, le builder compresse)

# Animation
animation.Ani_Background=7;Img_intro_000;Img_intro_006;Img_intro_010;_goToAnimation;Ani_Background_loop
```

### Objet avec tileset + maps (pattern bubble-bobble scroll)

```properties
code=./objects/scroll/scroll.asm

tileset.TileSet=./objects/scroll/map.tiles.png;61,8,8,TILE16x16
data.Map_level1=./objects/scroll/map_level1.bin;RAM

spriteIndex=RAM
animationIndex=RAM
```

---

## Erreurs courantes au niveau objet

| Message | Cause | Solution |
|---------|-------|----------|
| `Only one code or common-code property allowed` | Les deux sont définis | Garder uniquement `code=` |
| `One code or common-code property mandatory` | Aucun des deux | Ajouter `code=./path/to/<obj>.asm` |
| `Only one animation-data allowed` | Plusieurs `animation-data` | N'en garder qu'un |
| `Animation v02 need three comma separated parameters` | Format animation v02 incorrect | Vérifier `Img,duration,flags` avec exactement 2 virgules |
| Sprite ne s'affiche pas après un flip | Variante miroir manquante | Ajouter `XB0,XB1` ou `XD0,XD1` aux variants |
| `Undefined symbol: Img_<X>` lors de l'assembly | Sprite référencé dans le code mais pas déclaré | Ajouter le `sprite.Img_<X>=...` |
| `Undefined symbol: Ani_<X>` | Animation référencée mais pas déclarée | Ajouter le `animation.Ani_<X>=...` |
