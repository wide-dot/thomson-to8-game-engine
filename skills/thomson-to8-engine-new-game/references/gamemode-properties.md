# `game-mode/<X>/main.properties` — référence exhaustive

Le fichier `main.properties` d'un game-mode déclare :
- le code asm principal du mode
- les **objets** actifs dans ce mode (génère les `ObjID_<X>`)
- les **palettes** utilisées (génère les `Pal_<X>`)
- éventuellement des **game-modes communs** (`gameModeCommon.<n>=...`)
- les **actes** (sous-états qui ne déclenchent pas de rechargement disquette)

Format : `clé=valeur` (java.util.Properties via `OrderedProperties`). Chargé par `GameMode.java`.

---

## Clés au niveau game-mode

| Clé | Obligatoire ? | Multiple ? | Rôle |
|-----|---------------|------------|------|
| `engine.asm.mainEngine` | OUI | non | Chemin vers le `main.asm` du game-mode (généralement `./game-mode/<X>/main.asm`) |
| `object.<Nom>` | OUI (≥ 1) | oui | Déclare un objet et son `.properties`. Génère `ObjID_<Nom>` |
| `palette.<Nom>` | OUI (≥ 1) | oui | Déclare une palette (depuis un PNG). Génère `Pal_<Nom>` |
| `gameModeCommon.<n>` | optionnel | oui (n numérique) | Référence un game-mode commun (code/objets partagés entre game-modes) |
| `actBoot` | recommandé | non | Nom de l'acte chargé au démarrage du game-mode |
| `act.<acte>.palette` | optionnel | un par acte | Palette à activer pour cet acte |
| `act.<acte>.screenBorder` | optionnel | un par acte | Couleur de bordure (0-15) |
| `act.<acte>.backgroundImage` | optionnel | un par acte | Chemin PNG pour fond d'écran |
| `act.<acte>.backgroundSolid` | optionnel | un par acte | Index couleur unie (0-15) pour fond uni |
| `act.<acte>.objectPlacement` | optionnel | un par acte | Fichier de placement d'objets pré-définis |

---

## 1. `engine.asm.mainEngine`

```properties
engine.asm.mainEngine=./game-mode/TitleScreen/main.asm
```

C'est le fichier ASM 6809 qui sera assemblé pour produire le binaire du game-mode. Le builder y inclut automatiquement des prepends (org $6100, etc. — cf. `BuildDisk.compileObjectWithImageRef`).

Le chemin est relatif à la **racine du game-project**, pas au `main.properties`.

---

## 2. `object.<Nom>=path`

```properties
object.Player=./objects/player/player.properties
object.Bubble=./objects/bubble/bubble.properties
object.Background=./objects/background/background.properties
```

Chaque entrée :
- charge le fichier `.properties` de l'objet
- enregistre l'objet dans `gameMode.objects` (liste ordonnée)
- génère la constante `ObjID_<Nom>` avec un index séquentiel **selon l'ordre d'apparition**

> L'ordre des `object.X=...` est conservé par `OrderedProperties`. Le premier objet déclaré aura `ObjID_<Nom> = 1`, le second `2`, etc. (l'index `0` est réservé pour « slot libre »).

### Réutilisation d'objets entre game-modes

Si le **même nom d'objet** est référencé par plusieurs game-modes, l'objet n'est créé qu'une fois et est partagé : c'est `GameMode.java` ligne 109-117 qui détecte via `Game.allObjects.containsKey(...)`. Cela permet de définir un `Player` une seule fois et de l'utiliser dans `TitleScreen`, `level01`, `level02`, etc.

Mais attention : **chaque game-mode peut référencer un `.properties` différent** pour le même nom logique. Exemple chez r-type :
```properties
# Dans game-mode/01/main.d7.properties
object.Player1=./objects/player1/player1.d7.properties
# Dans game-mode/01/main.t2.properties
object.Player1=./objects/player1/player1.t2.properties
```

Le builder ne se base que sur le **nom** pour la dédup ; deux fichiers différents avec le même nom donnent le même `ObjID_` mais peuvent embarquer des sprites / code différents par target.

---

## 3. `palette.<Nom>=path/to/image.png`

```properties
palette.Pal_Background=./objects/background/frameintro/000.png
palette.Pal_TitleScreen=./game-mode/00/images/logo_pal.png
palette.Pal_black=../../engine/palette/color/Pal_black.png
```

La palette est **extraite du PNG** par le builder (`Palette.java`). Le PNG doit être en mode palette indexée (4-bit ou 8-bit, max 16 couleurs).

> **Au moins une palette est obligatoire**. Le builder lève `"palette not found in <file>"` sinon.

Conventions observées :
- `palette.Pal_<nom-de-l-image>` quand la palette vient d'une image de fond
- `palette.Pal_black=../../engine/palette/color/Pal_black.png` pour la palette noire engine (utilisée pour les fades)

La constante générée `Pal_<Nom>` est l'adresse de la data palette (16 entrées de 2 octets) en mémoire ; elle s'utilise typiquement avec :
```asm
        ldd   #Pal_Background
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow
```

---

## 4. `gameModeCommon.<n>=path` — objets partagés entre game-modes

> **Feature importante mais sous-utilisée**. Permet de partager le **code et les données d'objets** entre plusieurs game-modes, avec deux bénéfices majeurs :
> 1. **Économie de ROM cartouche T2** : un objet partagé n'est écrit **qu'une seule fois** dans le ROM si plusieurs game-modes y font référence, au lieu d'une copie par game-mode.
> 2. **Économie de temps de chargement disquette** : les pages RAM contenant les objets communs peuvent être réutilisées entre game-modes (pas de rechargement complet à chaque transition).

### Syntaxe

```properties
gameModeCommon.0=./global/common/audio.properties
gameModeCommon.1=./global/common/hud.properties
gameModeCommon.2=./global/common/projectiles.properties
```

- La clé doit être **un entier** (`gameModeCommon.0`, `gameModeCommon.1`, ...). Le builder lève une exception sinon (cf. `GameMode.java` lignes 88-92 : `Integer.parseInt(curGameModeCommon.getKey())`).
- L'index numérique fixe l'**ordre de chargement** des communs : `.0` avant `.1` avant `.2`. Cet ordre est exploité par certains modules engine.

### Format du fichier `.properties` référencé

Le fichier référencé est un `.properties` allégé qui **ne contient que des objets** :

```properties
# common-audio.properties (partagé entre tous les game-modes)
object.ymm=./engine/objects/sound/ymm/ymm.properties
object.vgc=./engine/objects/sound/vgc/vgc.properties
object.soundFX=./objects/soundFX/soundFX.properties
object.fade=./engine/objects/palette/fade/fade.properties
```

Clés acceptées dans un `gameModeCommon` :

| Clé | Acceptée ? | Note |
|-----|------------|------|
| `object.<Nom>` | OUI, ≥ 1 obligatoire | Au moins un objet, sinon « object not found » |
| `engine.asm.mainEngine` | NON | Pas de code main dans un common |
| `palette.<Nom>` | NON | Les palettes restent dans le main.properties du game-mode |
| `act.<X>.*` | NON | Les actes restent par game-mode |
| `gameModeCommon.<n>` | NON | Un common ne peut pas référencer d'autres communs |

> Voir `GameModeCommon.java` : seul `PropertyList.get(prop, "object")` est appelé, les autres clés sont ignorées.

### Mécanisme côté builder

Lorsque le builder traite un game-mode :

1. **Phase de parsing** : chaque `gameModeCommon.<n>` est résolu en instance `GameModeCommon`. Si un même fichier est référencé par plusieurs game-modes, **la même instance est partagée** (déduplication par chemin de fichier, cf. `GameMode.java` lignes 95-102 : `Game.allGameModeCommons.containsKey(...)`).
2. **Phase de fusion d'objets** : les objets déclarés dans le common sont fusionnés dans la liste d'objets du game-mode parent — ils reçoivent un `ObjID_<Nom>` comme s'ils étaient déclarés directement dans le `main.properties`.
3. **Phase d'allocation RAM (knapsack packing)** : le code des objets communs est ajouté aux items à placer en RAM, **par game-mode**. Chaque game-mode aura ses objets communs en RAM lorsqu'il sera chargé.
4. **Phase d'écriture ROM T2** : c'est là que la mutualisation opère pleinement. Le builder compare les blobs (page+adresse+contenu) des objets communs entre game-modes. **Si deux game-modes ont un objet commun stocké à la même page/adresse avec le même contenu, le builder n'écrit qu'une copie dans le ROM** (cf. `BuildDisk.java` lignes 1990-2010, dédup via `HashMap<GameModeCommon, List<RAMLoaderIndex>>`).
5. **Phase d'écriture du .glb partagé** : un fichier `SHARED_ASSETS/<commonName>.glb` est généré, contenant les constantes `ObjID_<Nom>` partagées, pour que tous les game-modes utilisateurs voient les mêmes IDs.

### Pourquoi c'est important

Sans `gameModeCommon`, si tu déclares dans 10 game-modes :
```properties
object.ymm=./engine/objects/sound/ymm/ymm.properties
object.vgc=./engine/objects/sound/vgc/vgc.properties
object.fade=./engine/objects/palette/fade/fade.properties
```

Le code de chaque objet est **dupliqué 10 fois dans le ROM T2** (1 fois par game-mode). Sur 128 pages disponibles en cartouche, ça consomme inutilement de l'espace.

Avec `gameModeCommon`, ces objets sont écrits **1 seule fois** dans le ROM, et tous les game-modes le pointent.

### Cas d'usage typiques

- **Audio engine partagé** : `ymm`, `vgc`, `soundFX` réutilisés dans tous les game-modes
- **HUD/score commun** : objets `scores`, `lives`, `messages` réutilisés entre niveaux
- **Palette fade** : `fade` (engine/objects/palette/fade/) utilisé partout pour les transitions
- **Joueur + projectiles** dans un shoot'em up : `Player1`, `Weapon`, `Bullet` partagés entre `level01`, `level02`, ...
- **Ennemis récurrents** : un mini-boss qui apparaît dans plusieurs niveaux

### Exemple complet — audio commun à tous les game-modes

```
game-projects/<jeu>/
├── config-windows.properties
├── global/
│   └── common-audio.properties     ← le common
├── game-mode/
│   ├── TitleScreen/main.properties ← référence le common
│   ├── level01/main.properties     ← référence le common
│   └── level02/main.properties     ← référence le common
└── objects/
    ├── soundFX/soundFX.properties
    └── ...
```

`global/common-audio.properties` :
```properties
object.ymm=./engine/objects/sound/ymm/ymm.properties
object.vgc=./engine/objects/sound/vgc/vgc.properties
object.soundFX=./objects/soundFX/soundFX.properties
object.fade=./engine/objects/palette/fade/fade.properties
```

`game-mode/TitleScreen/main.properties` :
```properties
engine.asm.mainEngine=./game-mode/TitleScreen/main.asm

# référence du common
gameModeCommon.0=./global/common-audio.properties

# objets spécifiques au game-mode
object.titleLogo=./objects/title/logo.properties
object.pressStart=./objects/title/pressStart.properties

palette.Pal_title=./game-mode/TitleScreen/images/title.png
actBoot=default
act.default.palette=Pal_title
act.default.backgroundImage=./game-mode/TitleScreen/images/title.png
```

`game-mode/level01/main.properties` :
```properties
engine.asm.mainEngine=./game-mode/level01/main.asm

gameModeCommon.0=./global/common-audio.properties

object.Player=./objects/player/player.properties
object.Enemy=./objects/enemy/enemy.properties

palette.Pal_level=./game-mode/level01/images/level.png
actBoot=default
act.default.palette=Pal_level
```

Les constantes `ObjID_ymm`, `ObjID_vgc`, `ObjID_soundFX`, `ObjID_fade` sont disponibles dans les deux game-modes avec **la même valeur d'index**, et le code de ces objets n'occupe qu'une page ROM partagée.

### Bonnes pratiques

- **Placer le `.properties` du common dans `global/`** (par convention) — c'est de la responsabilité projet, pas game-mode
- **Inclure les objets vraiment réutilisés** dans le common — pas tout — sinon on charge inutilement du code en RAM pour des game-modes qui ne l'utilisent pas
- **Ordre des `gameModeCommon.<n>`** : si plusieurs communs, mettre le plus stable (audio) en `.0`, les optionnels après
- **Ne pas mettre les sprites/animations dans le common** : les `sprite.X` et `animation.X` sont déclarés dans l'`.properties` de chaque objet, pas dans le common. Le common ne déclare que `object.X=path`.
- **Tester sur cartouche T2** la dédup : sur disquette, le bénéfice est essentiellement en temps de chargement ; en cartouche T2 c'est en espace ROM.

### Limites

- Un `gameModeCommon` ne peut **pas** lui-même référencer d'autres `gameModeCommon` (pas de hiérarchie)
- Les **palettes ne sont pas partageables** via common (toujours déclarées par game-mode)
- La dédup en T2 est faite **par contenu de blob** : si deux game-modes utilisent le même objet mais avec des sprites différents (variantes `.t2.properties`), la dédup ne s'applique pas
- L'ordre `.0`, `.1`, `.2` est **strictement numérique** — les noms type `gameModeCommon.audio` lèvent une exception au build

---

## 5. Actes — sous-états sans rechargement

Un **acte** est un sous-état d'un game-mode qui n'entraîne **aucun rechargement disquette/cartouche**. Tous les actes partagent le code et les objets du game-mode, mais peuvent avoir des palettes/fonds différents et des placements d'objets différents.

### `actBoot=<nom>`

```properties
actBoot=default
```

Désigne quel acte est chargé au démarrage. **Si absent**, `LoadAct` est généré vide et l'écran n'est pas initialisé.

> `actBoot` peut être nul (`null` en Java). Dans ce cas le builder ne génère pas de code dans `LoadAct` (cf. `BuildDisk.writeLoadActIndex` ligne 814).

### Propriétés d'un acte

| Clé | Valeur | Effet généré dans `LoadAct` |
|-----|--------|----------------------------|
| `act.<X>.palette` | nom d'une `palette.Pal_<X>` déclarée | `ldd #<paletteName>; std Pal_current; clr PalRefresh` |
| `act.<X>.screenBorder` | entier 0-15 | écrit la couleur de bordure dans `$E7DD` et `gfxlock.screenBorder.color` (si présent) |
| `act.<X>.backgroundImage` | chemin PNG | génère un `Bgi_<X>` et appelle `DrawFullscreenImage` sur les pages 2 et 3 (double buffering) |
| `act.<X>.backgroundSolid` | index 0-15 | remplit les pages 2 et 3 avec la couleur (`ldx #$XXXX; jsr ClearDataMem`) |
| `act.<X>.objectPlacement` | chemin fichier | placement d'objets pré-définis (rare, lecture du champ uniquement — pas vu de traitement actif récent) |

### Exemple complet

```properties
actBoot=default

act.default.palette=Pal_TitleScreen
act.default.screenBorder=8
act.default.backgroundImage=./game-mode/00/images/title.png

# Acte alternatif (basculement par changement de variable + LoadAct)
act.menu.palette=Pal_TitleScreen
act.menu.screenBorder=0
act.menu.backgroundSolid=0
```

### Notes sur le code généré par `LoadAct`

Le builder Java écrit dans `LoadAct` (cf. `BuildDisk.writeLoadActIndex`) **uniquement** pour l'acte référencé par `actBoot`. Les autres `act.<X>.*` ne sont pas exploités directement.

Si `backgroundImage` ou `backgroundSolid` est défini, le code généré charge l'image sur **deux pages physiques** (2 et 3, via `$E7E5`) pour assurer que le double-buffering soit cohérent (gfxlock alterne entre les deux pages) :

```asm
LoadAct
        ldb   #$02                     * load page 2
        stb   $E7E5                    * in data space ($A000-$DFFF)
        ldx   #Bgi_default
        jsr   DrawFullscreenImage
        ; ...
        IFDEF gfxlock.bufferSwap.do
        jsr   gfxlock.bufferSwap.do
        ENDC
        ; ...
        ldb   #$03                     * load page 3
        stb   $E7E5
        ldx   #Bgi_default
        jsr   DrawFullscreenImage
        ; ...
```

Si on n'utilise pas gfxlock, le bloc est protégé par `IFDEF`. Si on n'utilise pas `WaitVBL`, idem.

---

## Exemples de `main.properties`

### Game-mode minimal (un objet, un fond uni)

```properties
engine.asm.mainEngine=./game-mode/test/test.asm

object.Player=./objects/player/player.properties

palette.Pal_default=./objects/player/image/idle-000.png

actBoot=default
act.default.palette=Pal_default
act.default.screenBorder=0
act.default.backgroundSolid=0
```

### Game-mode TitleScreen avec musique (pattern 2026)

```properties
engine.asm.mainEngine=./game-mode/TitleScreen/main.asm

object.background=./objects/background/background.properties
object.ymm=./objects/music/ymm.properties
object.vgc=./objects/music/vgc.properties

palette.Pal_Background=./objects/background/frameintro/000.png

actBoot=titleScreen
act.titleScreen.palette=Pal_Background
act.titleScreen.screenBorder=8
act.titleScreen.backgroundImage=./objects/background/frameintro/000.png
```

### Game-mode complexe (pattern r-type level01, extrait)

```properties
engine.asm.mainEngine=./game-mode/01/main.asm

# Palettes
palette.Pal_game=./game-mode/01/images/pal.png
palette.Pal_tunnel=./game-mode/01/images/pal-inside.png
palette.Pal_black=../../engine/palette/color/Pal_black.png
palette.Pal_messages=./objects/messages/images/messages.png

# Objets globaux
object.fade=../../engine/objects/palette/fade/fade.properties
object.animation=./objects/animation/obj.d7.properties

# Objets jeu
object.LevelInit=./objects/levels/01/obj.d7.properties
object.LevelWave=./objects/levels/01/object-wave/obj.d7.properties
object.Player1=./objects/player1/player1.d7.properties
object.Weapon=./objects/player1/weapon/obj.d7.properties
# ... (50+ objets pour un niveau)

# Audio
object.ymm01=./objects/levels/01/music/ymm.d7.properties
object.soundFX=./objects/soundFX/soundFX.d7.properties

# Acte
actBoot=default
act.default.palette=Pal_black
act.default.screenBorder=0
act.default.backgroundSolid=0
```

---

## Erreurs courantes au niveau game-mode

| Message | Cause | Solution |
|---------|-------|----------|
| `engine.asm.mainEngine not found in <file>` | Clé absente | Ajouter la ligne |
| `object not found in <file>` | Aucun `object.X=...` | Déclarer au moins un objet |
| `palette not found in <file>` | Aucun `palette.X=...` | Déclarer au moins une palette |
| `gameModeCommon.<X> should be of type gameModeCommon.<n>` | Clé non-numérique | `gameModeCommon.audio` → `gameModeCommon.0` |
| L'écran est noir au boot | `actBoot` absent ou ne matche aucun `act.X.*` | Ajouter `actBoot=<nom>` + au moins une propriété `act.<nom>.*` |
| `Bgi_<actName>` non défini lors de l'assemblage | `act.<X>.backgroundImage` manquant mais code asm utilise `Bgi_<X>` | Soit ajouter la prop, soit retirer la ref dans le code |
