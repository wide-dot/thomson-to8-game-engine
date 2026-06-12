# `config-<os>.properties` — référence exhaustive

Le fichier `config-<os>.properties` à la racine du game-project est le **point d'entrée du builder Java** (classe `Game` chargée par `BuildDisk.main`). Il déclare le loader engine, les game-modes et tous les paramètres de build.

Format : `clé=valeur` (java.util.Properties, supporté par `OrderedProperties` qui préserve l'ordre d'insertion). Les commentaires commencent par `#` ou `!`.

---

## Convention de variantes par OS

Le builder ne distingue pas les OS par le suffixe ; c'est juste une convention humaine. On choisit le fichier à passer en argument :

```bash
java -jar build-disk.jar ./config-windows.properties
java -jar build-disk.jar ./config-macos.properties
java -jar build-disk.jar ./config-linux.properties
```

La seule différence entre les variantes est typiquement le chemin de `builder.lwasm` (binaire spécifique à la plateforme) et `builder.exobin` / `builder.hxcfe`.

---

## Section 1 — Engine ASM source code (loader)

Les chemins vers le code asm du **loader** que le builder copie en mémoire ROM/RAM/cartouche.

| Clé | Obligatoire ? | Rôle |
|-----|---------------|------|
| `engine.asm.boot.fd` | OUI | Bootloader disquette (lit le secteur 0 et lance `RAMLoaderManager`) |
| `engine.asm.RAMLoaderManager.fd` | OUI | Manager qui décompresse les pages RAM depuis la disquette |
| `engine.asm.RAMLoader.fd` | OUI | Routine de décompression (zx0 ou exomizer) |
| `engine.asm.boot.t2` | OUI | Bootloader cartouche T2 (ROM Mega) |
| `engine.asm.RAMLoaderManager.t2` | OUI | Manager de pages pour T2 |
| `engine.asm.RAMLoader.t2` | OUI | Routine de décompression pour T2 |
| `engine.asm.boot.t2flash` | OUI | Bootloader cartouche T2 flash (SDDRIVE) |
| `engine.asm.t2flash` | OUI | Module spécifique à la cartouche flash |

> Toutes ces clés sont **obligatoires** même si on ne build que pour disquette. Le builder lève une exception sinon (cf. `Game.java` lignes 105-145).

**Pattern standard** (chemins relatifs depuis le game-project) :

```properties
engine.asm.boot.fd=../../engine/boot/boot-fd.asm
engine.asm.RAMLoaderManager.fd=../../engine/ram/RAMLoaderManagerFd.asm
engine.asm.RAMLoader.fd=../../engine/ram/zx0/RAMLoaderFd.asm

engine.asm.boot.t2=../../engine/boot/boot-t2.asm
engine.asm.RAMLoaderManager.t2=../../engine/ram/RAMLoaderManagerT2.asm
engine.asm.RAMLoader.t2=../../engine/ram/zx0/RAMLoaderT2.asm

engine.asm.boot.t2flash=../../engine/boot/boot-t2-flash.asm
engine.asm.t2flash=../../engine/megarom-t2/t2-flash.asm
```

**Variantes de compression** :

```properties
# Compression ZX0 (recommandée — meilleur ratio)
engine.asm.RAMLoader.fd=../../engine/ram/zx0/RAMLoaderFd.asm

# Compression Exomizer (plus rapide à décoder)
# engine.asm.RAMLoader.fd=../../engine/ram/exo/RAMLoaderFd.asm
```

Le choix se fait aussi en posant ou non `builder.exobin=...` (voir section 3).

---

## Section 2 — Game definition

| Clé | Obligatoire ? | Rôle |
|-----|---------------|------|
| `gameModeBoot` | OUI | Nom du game-mode chargé au démarrage (doit matcher une clé `gameMode.X`) |
| `gameMode.<X>=path` | OUI (≥ 1) | Déclare un game-mode et son `main.properties` |

```properties
gameModeBoot=TitleScreen
gameMode.TitleScreen=./game-mode/00/main.properties
gameMode.level01=./game-mode/01/main.properties
gameMode.level02=./game-mode/02/main.properties
```

Le builder génère une constante `GmID_<X>` pour chaque entrée, indexée selon l'ordre d'apparition (préservé grâce à `OrderedProperties`).

**Désactiver temporairement un game-mode** : commenter la ligne (`#gameMode.level02=...`). Le builder ignore les `gameMode` commentés mais conserve les autres.

---

## Section 3 — Build parameters (LWASM)

Paramètres passés à l'assembleur LWASM.

| Clé | Obligatoire ? | Valeur | Rôle |
|-----|---------------|--------|------|
| `builder.lwasm` | OUI | chemin | Exécutable LWASM (Linux/macOS/Windows) |
| `builder.lwasm.pragma` | OUI (vide accepté) | `undefextern`, `autobranchlength,noforwardrefmax`, ... | Pragmas LWASM, transmis en `--pragma=...` |
| `builder.lwasm.includeDirs` | OUI | `./,../..` | Liste séparée par virgules, transmise en `--includedir=...` à LWASM |
| `builder.lwasm.define` | OUI (vide accepté) | `DEBUG,boot_color_gr=$00,invincible` | Liste de `--define=...` |

```properties
builder.lwasm=../../tools/win/lwasm.exe
builder.lwasm.pragma=undefextern
builder.lwasm.includeDirs=../..,.
builder.lwasm.define=boot_color_gr=$00,boot_color_b=$00
```

**`builder.lwasm.includeDirs`** doit pointer la racine d'où partent les chemins `./engine/...` utilisés dans le code asm. Typiquement `../..` (la racine du repo engine) plus `.` (le game-project lui-même).

**`builder.lwasm.define`** se transmet aux directives `IFDEF` du code. Exemples observés dans le repo :

- `DEBUG=1` — active des logs/traces
- `TRACK_INTERLACED` — mode disque entrelacé
- `TRACK_HALFLINES` — mode demi-lignes
- `T2` — auto-défini quand on build pour T2
- `boot_color_gr=$00`, `boot_color_b=$00` — couleurs du splash boot
- `invincible` — flag projet-spécifique

> Pragma utile pour rechercher des optimisations manquantes : `builder.lwasm.pragma=autobranchlength,noforwardrefmax`. Très lent à compiler, à utiliser seulement pour un diff/audit.

---

## Section 4 — Build parameters (générique)

| Clé | Obligatoire ? | Valeur | Rôle |
|-----|---------------|--------|------|
| `builder.debug` | OUI | `Y`/`N` | Si `Y`, génère listings + symboles dans `generated-code/debug/` |
| `builder.logToConsole` | OUI | `Y`/`N` | Si `Y`, logs Log4j en console pendant le build |
| `builder.parallel` | OUI | `Y`/`N` | Si `Y`, build parallèle (multi-thread, plus rapide) |
| `builder.diskName` | OUI | chemin sans extension | Nom de la disquette produite ; `./dist/<nom>` → produit `dist/<nom>.fd` |
| `builder.t2Name` | OUI | nom court | Nom de la cartouche T2 ; **max 22 caractères** (tronqué automatiquement) |
| `builder.generatedCode` | OUI | dossier | Sortie des fichiers asm intermédiaires (créé automatiquement) |
| `builder.constAnim` | OUI | fichier `.equ` | Inclut les constantes d'animation (`_resetAnim`, `_goBackNFrames`, ...) |
| `builder.to8.memoryExtension` | OUI | `Y`/`N` | `Y` = 32 pages RAM (512 Ko, recommandé) ; `N` = 16 pages (256 Ko) |
| `builder.compilatedSprite.useCache` | OUI | `Y`/`N` | `Y` = réutilise les `.asm`/`.bin`/`.lst` déjà générés (build incrémental) |
| `builder.compilatedSprite.maxTries` | OUI | entier | Nb d'essais aléatoires pour optimiser les permutations de + de 10 éléments. Rapide: `500000`. Lent: `5000000` |
| `builder.exobin` | optionnel | chemin | Si défini, compresse les données RAM avec Exomizer ; sinon ZX0 |
| `builder.hxcfe` | optionnel | chemin | Outil HxC-FloppyEmulator pour produire des images en formats supplémentaires |

```properties
builder.debug=Y
builder.logToConsole=Y
builder.parallel=Y
builder.diskName=./dist/<nom>
builder.t2Name=<nom>
builder.generatedCode=./generated-code
builder.constAnim=./engine/graphics/animation/constants-animation.equ
builder.to8.memoryExtension=Y
builder.compilatedSprite.useCache=Y
builder.compilatedSprite.maxTries=500000

# builder.exobin=../../tools/win/exomizer.exe       # décommenter pour Exomizer
# builder.hxcfe=../../tools/win/hxcfe.exe           # décommenter pour HxC
```

### Notes sur `builder.to8.memoryExtension`

- `Y` : `nbMaxPagesRAM = 32` (TO8 + extension 512 Ko), recommandé pour tout jeu non-trivial
- `N` : `nbMaxPagesRAM = 16` (TO8 seul, 256 Ko)
- Détermine combien de pages RAM le builder peut allouer pour placer les objets, sprites compilés, sons, etc.

### Notes sur `builder.compilatedSprite.useCache`

- `Y` : réutilise les `.asm`/`.bin`/`.lst` générés précédemment dans `generated-code/`. Build incrémental rapide quand seuls le code asm a changé.
- `N` : recompile intégralement tous les sprites. À utiliser quand on a changé les PNG sources ou les options de compilation des sprites.

---

## Configurations spéciales — variantes par target

### Variante T2 (cartouche megarom)

Convention : fichier `config-windows.t2.properties` séparé.

Différences typiques par rapport à la variante FD :
- `gameMode.<X>=./game-mode/X/main.t2.properties` (au lieu de `.properties`)
- `builder.lwasm.define=T2,...` (pour activer les `IFDEF T2` dans le code asm)
- `builder.diskName` parfois omis (on n'utilise que `.t2Name`)

### Variante T2 flash (SDDRIVE)

Utilise les clés `engine.asm.boot.t2flash` et `engine.asm.t2flash`. La build produit en plus un `<t2Name>.t2flash` dans `dist/`.

---

## Exemple complet commenté

```properties
# ============================================================================
# BuildDisk - Configuration file
# ============================================================================

# Section 1 — Engine ASM source code (loader)
# ----------------------------------------------------------------------------
engine.asm.boot.fd=../../engine/boot/boot-fd.asm
engine.asm.RAMLoaderManager.fd=../../engine/ram/RAMLoaderManagerFd.asm
engine.asm.RAMLoader.fd=../../engine/ram/zx0/RAMLoaderFd.asm

engine.asm.boot.t2=../../engine/boot/boot-t2.asm
engine.asm.RAMLoaderManager.t2=../../engine/ram/RAMLoaderManagerT2.asm
engine.asm.RAMLoader.t2=../../engine/ram/zx0/RAMLoaderT2.asm

engine.asm.boot.t2flash=../../engine/boot/boot-t2-flash.asm
engine.asm.t2flash=../../engine/megarom-t2/t2-flash.asm

# Section 2 — Game definition
# ----------------------------------------------------------------------------
gameModeBoot=TitleScreen
gameMode.TitleScreen=./game-mode/title/main.properties
gameMode.level01=./game-mode/01/main.properties

# Section 3 — Build parameters (LWASM)
# ----------------------------------------------------------------------------
builder.lwasm=../../tools/win/lwasm.exe
builder.lwasm.pragma=undefextern
builder.lwasm.includeDirs=../..,.
builder.lwasm.define=boot_color_gr=$00,boot_color_b=$00

# Section 4 — Build parameters (générique)
# ----------------------------------------------------------------------------
builder.debug=Y
builder.logToConsole=Y
builder.parallel=Y
builder.diskName=./dist/mygame
builder.t2Name=mygame
builder.generatedCode=./generated-code
builder.constAnim=./engine/graphics/animation/constants-animation.equ
builder.to8.memoryExtension=Y
builder.compilatedSprite.useCache=Y
builder.compilatedSprite.maxTries=500000

# Section 5 — Optionnels
# ----------------------------------------------------------------------------
#builder.exobin=../../tools/win/exomizer.exe
#builder.hxcfe=../../tools/win/hxcfe.exe
```

---

## Erreurs de build courantes

| Message du builder | Cause | Solution |
|--------------------|-------|----------|
| `engine.asm.boot.fd not found in <file>` | Une clé `engine.asm.*` manque | Ajouter toutes les 8 clés section 1 |
| `gameModeBoot not found in <file>` | Clé `gameModeBoot` absente | Ajouter `gameModeBoot=<nom-d-un-gameMode>` |
| `gameMode not found in <file>` | Aucune clé `gameMode.X` déclarée | Ajouter au moins un `gameMode.<X>=...` |
| `builder.to8.memoryExtension not found in <file>` | Clé absente | Ajouter `builder.to8.memoryExtension=Y` |
| `builder.compilatedSprite.useCache not found in <file>` | Clé absente | Ajouter `builder.compilatedSprite.useCache=Y` |
| `Impossible de charger le fichier de configuration: <path>` | Chemin référencé par `gameMode.X` introuvable | Corriger le chemin du `main.properties` |

> Toutes les vérifications « not found » sont dans `Game.java` constructeur. Le builder est strict et bloquant : il faut TOUTES les clés obligatoires.
