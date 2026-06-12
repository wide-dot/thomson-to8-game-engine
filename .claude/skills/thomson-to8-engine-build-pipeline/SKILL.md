---
name: thomson-to8-engine-build-pipeline
description: "Décrit le pipeline de build Java du Thomson TO8/TO9 game engine (Bento8/wide-dot) : application Java `java-generator/` qui produit les images disquette .fd / cartouche .t2 / .t2flash à partir des sources ASM 6809 et des fichiers .properties, classe principale BuildDisk avec main() qui charge le config via Game.java, parse les game-modes via GameMode.java et leurs game-mode communs via GameModeCommon.java, charge les objets via Object.java avec leurs sprites/animations/sounds/data/tilesets, charge les palettes via Palette.java + PaletteTO8, charge les acts via Act.java (screenBorder/backgroundSolid/backgroundImage/objectPlacement/palette), gestion des sprites compilés (compiledSprite/) avec variants NB/ND/XB/etc, encoders MapRleEncoder (DMAP) et ZX0Encoder (DZX0), compilation via LWASM avec pragma/includeDirs/define paramétrables, knapsack packing (util.knapsack.Knapsack + Item + Solution) pour optimiser le placement des objets en pages RAM, générateurs writeObjIndex/writeAniIndex/writeImgIndex pour les tables d'index, génération de LoadAct depuis Act, génération des constants ObjID_X / GmID_X / Bgi_X / Pal_X / Img_X / Ani_X dans les .glb (SHARED_ASSETS, ObjectId.glb, Game.glb, MainEngine.glb), dédup T2 (un même blob écrit une seule fois si plusieurs game-modes le partagent), parallel build via builder.parallel=Y, compression ZX0 (default) ou Exomizer (builder.exobin), création image fd via FdUtil + image t2 via T2Util + ROM image RamImage, propriétés OrderedProperties pour préserver l'ordre, PropertyList helper pour les listes object./palette./animation./sprite./etc. Utiliser pour comprendre les étapes de build, débugger une erreur de compilation, optimiser le placement des pages, contribuer au builder Java, comprendre la génération des constantes, ajuster les paramètres LWASM. Mots-clés : BuildDisk, BuildT2CheckDisk, Game, GameMode, GameModeCommon, Object, ObjectBin, ObjectCode, Act, Palette, AsmSourceCode, PropertyList, OrderedProperties, FileNames, ChecksumUtils, DynamicContent, Globals, knapsack, Knapsack, Item, ItemBin, Solution, compiledSprite, AssemblyGenerator, SimpleAssemblyGenerator, Encoder, MapRleEncoder, ZX0Encoder, SpriteSheet, Sprite, SubSprite, SubSpriteBin, ImageSetBin, AnimationBin, Animation, TileBin, Tileset, PngToBottomUpB16Bin, PaletteTO8, Sound, SoundBin, RamImage, DataIndex, RAMLoaderIndex, FdUtil, SdUtil, T2Util, LWASMUtil, FileUtil, ZX0Compressor, Optimizer, generated-code directory, debug directory, .glb files, ObjectId.glb, Game.glb, MainEngine.glb, FileIndex.asm, _ImageSet.asm, _Animation.asm, _TileSet.asm, SHARED_ASSETS, writeObjIndex, writeAniIndex, writeImgIndex, writeLoadActIndex, writePalIndex, builder.lwasm, builder.lwasm.pragma, builder.lwasm.includeDirs, builder.lwasm.define, builder.parallel, builder.compilatedSprite.useCache, builder.compilatedSprite.maxTries, builder.exobin, builder.hxcfe, builder.constAnim, --pragma, --includedir, --define, lwasm, exomizer, maven, mvn clean compile assembly:single."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Build pipeline — Thomson TO8/TO9 Game Engine

Le **java-generator** (`java-generator/` du repo) est l'application Java qui produit les images disquette/cartouche à partir des sources ASM 6809 et des fichiers `.properties`. Classe principale : **`BuildDisk`**.

Ce skill couvre : les étapes de build, le knapsack packing, la génération des constantes, l'intégration LWASM, la dédup T2.

---

## Architecture des classes

```
fr.bento8.to8.build/
├── BuildDisk.java               # main() — pipeline principal
├── BuildT2CheckDisk.java        # validation post-build T2
├── Game.java                    # config racine (game)
├── GameMode.java                # un game-mode
├── GameModeCommon.java          # objets communs partagés
├── Object.java                  # un objet avec sprites/anims/data
├── ObjectBin.java               # binaire compilé d'un objet
├── ObjectCode.java              # code asm d'un objet
├── Act.java                     # un acte (palette/border/bg)
├── Palette.java                 # palette
├── AsmSourceCode.java           # builder de fichiers asm
├── PropertyList.java            # helper pour parsing prop.X.Y
├── OrderedProperties.java       # Properties qui préserve l'ordre
└── FileNames.java               # constantes de noms de fichiers

fr.bento8.to8.image/
├── Sprite.java
├── SpriteSheet.java
├── SubSprite.java
├── SubSpriteBin.java
├── Animation.java
├── AnimationBin.java
├── ImageSetBin.java
├── Tileset.java
├── TileBin.java
├── PngToBottomUpB16Bin.java     # PNG → BM16 format
├── PaletteTO8.java              # extraction palette PNG
└── encoder/
    ├── Encoder.java             # interface
    ├── MapRleEncoder.java       # DMAP
    └── ZX0Encoder.java          # DZX0

fr.bento8.to8.util.knapsack/
├── Knapsack.java                # algorithme packing
├── Item.java                    # élément à packer
├── ItemBin.java
└── Solution.java                # solution trouvée

fr.bento8.to8.audio/
├── Sound.java
└── SoundBin.java

fr.bento8.to8.ram/
└── RamImage.java                # image RAM 32 pages

fr.bento8.to8.storage/
├── FdUtil.java                  # image disquette
├── T2Util.java                  # image T2 megarom
├── SdUtil.java                  # SDDRIVE
├── DataIndex.java
└── RAMLoaderIndex.java

fr.bento8.to8.util/
├── LWASMUtil.java               # invocation LWASM
├── FileUtil.java
└── knapsack/ (cf. dessus)

fr.bento8.to8.compiledSprite/
├── backupDrawErase/
│   └── AssemblyGenerator.java   # génère le code asm d'un sprite NB
└── draw/
    └── SimpleAssemblyGenerator.java   # ND seul

fr.bento8.to8.boot/
└── Bootloader.java
```

---

## Pipeline de build — étapes

### 1. Chargement du config

```java
Game game = new Game(args[0]);          // config-windows.properties
```

`Game` parse :
- engine.asm.boot.fd/t2/t2flash
- engine.asm.RAMLoader/Manager
- gameModeBoot + gameMode.X (liste)
- builder.* (LWASM, debug, parallel, etc.)

### 2. Chargement des game-modes

Pour chaque `gameMode.X` :
```java
gameModes.put(name, new GameMode(name, fileName));
```

`GameMode` parse :
- engine.asm.mainEngine
- gameModeCommon.X (objets partagés)
- object.X (objets)
- palette.X (palettes)
- actBoot + act.X.Y (acts)

### 3. Chargement des objets

Pour chaque objet (unique par nom), `Object` parse :
- code= (ou common-code=)
- sprite.X (avec variants)
- animation.X (v00 ou v02)
- animation-data (1 max)
- sound.X / data.X (alias)
- tileset.X

Réutilisation : si le même nom d'objet est référencé par plusieurs game-modes, l'objet n'est créé qu'une fois (cf. `Game.allObjects` HashMap).

### 4. Compilation des sprites

Pour chaque sprite, pour chaque variant (NB0, NB1, XB0, etc.) :
- Lit le PNG
- Génère le code asm pour ce variant (boucle d'écritures pixels)
- Mode B : génère aussi le code d'erase (sauvegarde + restore)
- Mode D : code de draw seul
- DMAP : encodage RLE map
- DZX0 : compression ZX0

Cache : si `builder.compilatedSprite.useCache=Y`, le builder réutilise les `.asm`/`.bin`/`.lst` déjà générés (gros gain sur builds incrémentaux).

`maxTries` (typiquement 500000) : nombre d'essais aléatoires pour optimiser les permutations de pixels (> 10 éléments). Plus = meilleure compression mais plus lent.

### 5. Génération des fichiers .glb

```java
// Pour chaque game-mode :
//   ObjectId.glb (ObjID_X et adresses)
//   <gameMode>.glb (constantes générées)

// Globaux :
//   Game.glb
//   MainEngine.glb

// Communs partagés :
//   SHARED_ASSETS/<common>.glb
```

Ces `.glb` sont inclus automatiquement dans le code asm pour fournir les constantes (ObjID_X, GmID_X, Pal_X, Img_X, Ani_X, Bgi_X).

### 6. Knapsack packing — placement RAM

Le builder doit décider sur quelle page RAM placer chaque objet (chacun a un code de taille variable, doit tenir dans 16 Ko par page).

`fr.bento8.to8.util.knapsack.Knapsack` résout ce problème (variante du **bin packing**) :
- Items = chaque objet (avec sa taille)
- Bins = pages RAM (16 Ko chacune, jusqu'à 32 pages selon `builder.to8.memoryExtension`)
- Solution = affectation item → bin minimisant le nombre de bins utilisés

Si trop d'items pour les bins disponibles : abort avec message « Plus de place en RAM ».

### 7. Génération de `LoadAct`

Depuis les properties `act.X.*` (cf. `Act.java`), le builder génère le code asm de `LoadAct` :

```java
private static void writeLoadActIndex(AsmSourceCode asmBuilder, GameMode gameMode) {
    asmBuilder.add("LoadAct");
    Act act = gameMode.acts.get(gameMode.actBoot);
    if (act != null) {
        if (act.bgColorIndex != null || act.bgFileName != null) {
            asmBuilder.add("        ldb   #$02");
            asmBuilder.add("        stb   $E7E5");
        }
        if (act.bgColorIndex != null) {
            asmBuilder.add("        ldx   #$XXXX");
            asmBuilder.add("        jsr   ClearDataMem");
        }
        if (act.bgFileName != null) {
            asmBuilder.add("        ldx   #Bgi_" + act.name);
            asmBuilder.add("        jsr   DrawFullscreenImage");
        }
        // ... screenBorder, palette, etc.
    }
}
```

### 8. Invocation LWASM

`LWASMUtil` lance LWASM avec :
- `--pragma=` + `builder.lwasm.pragma`
- `--includedir=` + `builder.lwasm.includeDirs` (séparés par virgules)
- `--define=` + `builder.lwasm.define`
- Source : `engine.asm.mainEngine` ou autre

Sortie : `.bin` (binaire) + `.lst` (listing) dans `generated-code/`.

### 9. Compression ZX0 ou Exomizer

Pour chaque page RAM, compresse le binaire :
- ZX0 (défaut) via `zx0.Compressor` + `zx0.Optimizer` (lib Java intégrée)
- Exomizer via `builder.exobin` (outil externe Windows)

### 10. Création de l'image

- **Disquette** : `FdUtil` assemble les pages compressées en image `.fd`
- **Cartouche T2** : `T2Util` assemble en `.t2`
- **T2 Flash** : `SdUtil` génère les 4 disquettes SDDRIVE en `.t2flash`

### 11. Validation T2

`BuildT2CheckDisk` vérifie l'intégrité de l'image T2 (checksums via `ChecksumUtils`).

---

## Constantes générées

Le builder génère des **constantes** asm que le code utilise :

| Préfixe | Source property | Exemple |
|---------|-----------------|---------|
| `ObjID_<X>` | `object.<X>=...` | `ObjID_Player` |
| `GmID_<X>` | `gameMode.<X>=...` | `GmID_TitleScreen` |
| `Pal_<X>` | `palette.<X>=...` | `Pal_game` |
| `Img_<X>` | `sprite.Img_<X>=...` | `Img_Player_001` |
| `Ani_<X>` | `animation.Ani_<X>=...` | `Ani_Idle` |
| `Bgi_<X>` | `act.<X>.backgroundImage=...` | `Bgi_default` |
| `Obj_Index_Page` | (tables auto-générées) | (table 1 octet/objet = page) |
| `Obj_Index_Address` | (idem) | (table 2 octets/objet = adresse) |

Les `Obj_Index_Page` et `Obj_Index_Address` sont **résidentes** (page 1) pour être accessibles depuis n'importe quelle page.

Voir [references/build-stages.md](references/build-stages.md).

---

## Knapsack — détails

```java
public class Knapsack {
    private List<Item> items;
    private int binSize;
    
    public Solution solve() {
        // Algorithme First-Fit Decreasing ou variant
        // Trie items par taille décroissante
        // Place chacun dans le premier bin où il rentre
        // Sinon crée un nouveau bin
        // Retourne le placement optimal
    }
}
```

Item = un objet avec sa taille en octets.
Bin = une page RAM (16 Ko).

L'objectif : **minimiser le nombre de bins** pour économiser l'espace cartouche T2 et le temps de chargement disquette.

Pour T2 avec mémoire = 128 pages : limite hard.
Pour FD : limite hard liée à la taille disquette (~320 Ko).

Voir [references/knapsack-packing.md](references/knapsack-packing.md).

---

## Dédup T2

En cartouche T2, si plusieurs game-modes ont la **même page** (même contenu, même page logique), le builder ne l'écrit **qu'une fois** dans le ROM cartouche.

Comparaison via :
```java
if (commons.containsKey(di.gmc)) {
    for (RAMLoaderIndex dic : commons.get(di.gmc)) {
        if (dic.ram_page == di.ram_page && 
            dic.ram_address == di.ram_address && 
            dic.ram_endAddress == di.ram_endAddress && 
            Arrays.equals(di.encBin, dic.encBin)) {
            fdic = dic;
            break;
        }
    }
}
```

Si fdic trouvé → **partage** la même position ROM. Économie.

C'est ce qui rend `gameModeCommon` si efficace : 1 seul write au lieu de N.

Voir [references/t2-deduplication.md](references/t2-deduplication.md).

---

## Compilation parallèle

Si `builder.parallel=Y`, certaines étapes utilisent des Java Streams parallel :

```java
forEach(game.gameModes.entrySet(), gameMode -> {
    // processBackgroundImages...
});
```

`forEach` peut être séquentiel (`forEachSeq`) ou parallèle (`forEach`) selon le flag.

Gain : compile sprites en parallèle (utilise tous les cores). Réduit de moitié le temps de build sur multi-core.

---

## Invocation Maven

```bash
cd java-generator
mvn clean compile assembly:single
```

Produit : `target/build-disk-*-jar-with-dependencies.jar`.

Exécution :
```bash
java -jar target/build-disk-*-jar-with-dependencies.jar <chemin/config.properties>
```

---

## Fichiers générés

Dans `<game-project>/generated-code/` :
```
<objet>/
├── <sprite_variant>.asm         # code compilé du sprite
├── <sprite_variant>.bin         # binaire
├── <sprite_variant>.lst         # listing LWASM
├── _ImageSet.asm                # index des images
├── _Animation.asm               # index des animations
└── _TileSet.asm                 # tilesets (si applicable)

debug/
├── <fichiers>.lst               # versions debug avec symbols
└── <fichiers>.sym               # symboles

Game.glb                         # constantes globales
ObjectId.glb                     # ObjID_X
MainEngine.glb                   # constantes main engine
SHARED_ASSETS/                   # communs partagés
```

Dans `dist/` :
```
<diskName>.fd                    # image disquette
<t2Name>.t2                      # image cartouche T2
<t2Name>.t2flash                 # image SDDRIVE
```

---

## Pitfalls

- **`builder.lwasm.includeDirs` incorrect** : LWASM ne trouve pas les `INCLUDE` → erreur de compilation
- **`builder.compilatedSprite.useCache=Y` avec PNG modifiés** : utilise l'ancien sprite → image incorrecte. Mettre `=N` pour force recompile
- **`maxTries` trop bas** : compression sub-optimale. Augmenter pour des sprites complexes
- **Plus d'items que de bins** : abort avec "Plus de place en RAM". Réduire ou paginer
- **Cache stale** : supprimer `generated-code/` et rebuild si comportement incohérent
- **`builder.parallel=Y` avec build instable** : bug rare de concurrence. Mettre `N` pour debug
- **Pages T2 dépassant 128** : aborts. Réduire ou utiliser `gameModeCommon` pour mutualiser
- **PNG palette non indexée** : palette extraite incorrecte
- **Sprite trop gros** (> 1 page après compilation) : impossible à allouer en RAM
- **Confusion index PNG / index runtime palette Thomson** : `PaletteTO8.java` lit le PNG sur les index 1..16 (le 0 du PNG est implicitement la transparence) et écrit dans les slots Thomson 0..15. Donc PNG idx N → Thomson slot (N−1). Quand on écrit du code asm qui adresse la palette via `$E7DB` ou des tables raster, il faut utiliser l'index **runtime Thomson** (PNG idx − 1). Commenter un fcb « idx 1 = HERBE » d'après ce qu'on voit dans GIMP et écrire `fcb $01,...` adresse en fait la 2ème couleur — bug visuel silencieux. Cf. [thomson-to8-engine-palette/references/palette-system.md](../thomson-to8-engine-palette/references/palette-system.md) section "Index couleur : PNG vs runtime Thomson".

## Références détaillées

- [references/build-stages.md](references/build-stages.md) — Étapes détaillées du pipeline : load config, parse game-modes, charge objets, compile sprites avec variants, génère .glb (Game/ObjectId/MainEngine/SHARED_ASSETS), invoque LWASM, compresse, assemble image. Fichiers intermédiaires dans generated-code/. Constantes générées (ObjID_X, GmID_X, Pal_X, Img_X, Ani_X, Bgi_X)
- [references/knapsack-packing.md](references/knapsack-packing.md) — Algorithme knapsack/bin-packing : Item / Bin / Solution, première-fit decreasing, contraintes 16 Ko/page et 32 pages max (avec builder.to8.memoryExtension), gestion d'échec ("Plus de place en RAM"), optimisation via gameModeCommon
- [references/t2-deduplication.md](references/t2-deduplication.md) — Dédup ROM T2 : comparaison par page+adresse+contenu, économie via gameModeCommon, HashMap commons, RAMLoaderIndex.encBin, impact sur taille finale .t2, validation BuildT2CheckDisk
