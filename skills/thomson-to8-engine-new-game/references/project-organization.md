# Organisation d'un game-project — arborescence canonique

Ce document décrit la **structure de dossiers** d'un game-project dans le repo `thomson-to8-game-engine`. Tous les game-projects vivent dans `game-projects/<nom>/`. Cette organisation est imposée par le builder Java (`BuildDisk`) et par les chemins relatifs codés dans le `config-<os>.properties`.

---

## Arborescence canonique

```
game-projects/<nom-du-jeu>/
├── config-windows.properties          [obligatoire — au moins une variante]
├── config-macos.properties            [optionnel]
├── config-linux.properties            [optionnel]
├── config-windows.t2.properties       [optionnel — build cartouche T2]
├── config-<x>.t2flash.properties      [optionnel — build cartouche T2 flash SDDRIVE]
├── README.md                          [optionnel]
├── <jeu>.code-workspace               [optionnel — config VSCode]
├── dcmoto.lnk                         [optionnel — raccourci émulateur Windows]
├── to8.config.xml                     [optionnel — config TEO/autre émulateur]
├── memmap.csv / memmap.html           [optionnel — sortie diagnostique de build]
├── music.xml                          [optionnel — métadonnées musique]
├── genfont.php                        [optionnel — script utilitaire spécifique au projet]
│
├── game-mode/                         [obligatoire — au moins un sous-dossier]
│   ├── <mode-A>/
│   │   ├── main.properties            [obligatoire]
│   │   ├── main.asm                   [obligatoire — point d'entrée ASM]
│   │   ├── ram-data.asm               [obligatoire — déclaration Dynamic_Object_RAM]
│   │   ├── main.t2.properties         [optionnel — variante T2]
│   │   ├── main.d7.properties         [optionnel — variante disquette d7]
│   │   ├── images/                    [optionnel — images spécifiques au mode]
│   │   └── music/                     [optionnel — fichiers musicaux du mode]
│   ├── <mode-B>/
│   └── ...
│
├── objects/                           [obligatoire dès qu'un object.X est référencé]
│   ├── <objet-A>/
│   │   ├── <objet-A>.properties       [obligatoire]
│   │   ├── <objet-A>.asm              [obligatoire — code de l'objet]
│   │   ├── image/                     [convention — PNG sources]
│   │   │   ├── frame_001.png
│   │   │   └── ...
│   │   └── ...                        [optionnel — sous-dossiers libres]
│   └── ...
│
├── global/                            [optionnel — code partagé entre game-modes]
│   ├── macro.asm
│   ├── variables.asm
│   ├── object.const.asm
│   ├── scale.asm
│   └── objects/                       [objets globaux partagés (ex: r-type/global/objects/)]
│
├── cfg/                               [optionnel — fichiers de config émulateur DCMOTO/lwtools]
├── resources/                         [optionnel — assets sources hors PNG (musique brute, etc.)]
├── tmp/                               [optionnel — scratch, ignoré par .gitignore]
│
├── generated-code/                    [généré par le build — à mettre dans .gitignore]
│   ├── debug/
│   └── ... fichiers .asm intermédiaires
│
└── dist/                              [généré par le build — produit final]
    ├── <diskName>.fd
    ├── <t2Name>.t2
    └── <t2Name>.t2flash
```

---

## Fichiers obligatoires vs optionnels

| Élément | Obligatoire ? | Référencé par |
|---------|---------------|---------------|
| `config-<os>.properties` (au moins un) | OUI | passé en argument au builder Java |
| `game-mode/<X>/main.properties` | OUI (≥ 1) | `gameMode.<X>=...` dans config racine |
| `engine.asm.mainEngine` (fichier asm) | OUI | dans `main.properties` du game-mode |
| Au moins une `palette.X=...` | OUI | builder lève « palette not found » sinon |
| Au moins un `object.X=...` | OUI | builder lève « object not found » sinon |
| `actBoot` | recommandé | si absent, `LoadAct` est généré vide |
| `act.<actBoot>.palette/screenBorder/backgroundImage` | recommandé | sinon l'écran reste tel quel au démarrage |
| `ram-data.asm` | OUI | inclus depuis `main.asm` (sinon `Dynamic_Object_RAM` non défini → erreur LWASM) |

---

## Conventions de nommage

Le builder ne **transforme pas** les noms : ce que tu écris dans le `.properties` devient la constante asm. Les conventions de fait observées dans le repo :

### Game-modes (`gameMode.<X>=...`)
- **PascalCase** pour les titres et écrans : `TitleScreen`, `LevelSelect`, `EHZ`, `Loading`
- **Lowercase ou avec digits** pour les niveaux numérotés : `level01`, `bonneannee`, `gamescreen`, `01`, `02`
- Le builder génère `GmID_<X>` → `GmID_TitleScreen`, `GmID_level01`

### Objets (`object.<X>=...`)
- **PascalCase** pour les types : `Player`, `Bubble`, `Background`, `Player1`, `Weapon`, `Pow`
- Multi-mots avec préfixes de namespace : `Player1`, `dobkeratops_jaw`, `forcepod_simplefire`
- Le builder génère `ObjID_<X>` → `ObjID_Player`, `ObjID_dobkeratops_jaw`

### Palettes (`palette.<X>=...`)
- **Toujours préfixé `Pal_`** : `Pal_Background`, `Pal_TitleScreen`, `Pal_black`, `Pal_game`, `Pal_messages`

### Sprites (`sprite.Img_<X>=...`)
- **Toujours préfixé `Img_`** : `Img_Idle_000`, `Img_Player_Run_001`, `Img_bink_0`
- Numérotation par frame de l'animation source : `_000`, `_001`, ... ou `_001`, `_002` (au choix du projet)

### Animations (`animation.Ani_<X>=...`)
- **Toujours préfixé `Ani_`** : `Ani_Idle`, `Ani_Player_Wait`, `Ani_Player_Jump`
- Lien direct avec les routines : `Ani_Player_Run` ↔ routine `Run` ou `Ground_routine`

### Backgrounds d'act (`act.<X>.backgroundImage=...`)
- Le builder génère un label `Bgi_<actName>` → `Bgi_default`, `Bgi_titleScreen`

### Game-modes communs (`gameModeCommon.<n>=...`)
- La clé est un **index numérique** (`gameModeCommon.0`, `gameModeCommon.1`), pas un nom
- Le builder lève une exception sinon (cf. `GameMode.java`)

---

## Variantes par target (.t2, .d7, .fd)

Le builder accepte plusieurs game-mode `.properties` cohabitant pour différents targets. Convention observée :

- `main.properties` — variante par défaut (souvent .fd)
- `main.t2.properties` — variante cartouche T2 (ressources en ROM Mega)
- `main.d7.properties` — variante disquette d7 (organisation RAM différente)

Le choix est fait au niveau du `config-<os>.properties` :
```properties
gameMode.level01=./game-mode/01/main.d7.properties     ← cible disquette
# Pour cartouche T2, on aurait :
# gameMode.level01=./game-mode/01/main.t2.properties
```

Les variantes diffèrent typiquement par :
- la quantité d'objets / sons placés en RAM (`,RAM` suffix sur les déclarations)
- les chemins vers des objets variantes (`./objects/X/obj.d7.properties` vs `./objects/X/obj.t2.properties`)
- les images de fond (compression différente)

---

## Dossier `global/` (pattern goldorak et r-type)

Pour les jeux complexes qui ont plusieurs game-modes partageant du code, la convention émergente est de placer dans `global/` :

- des **macros locales** (`global/macro.asm`, `global/macros.asm`)
- des **constantes/équivalences** (`global/variables.asm`, `global/object.const.asm`, `global/scale.asm`)
- des **routines partagées** (`global/projectile.asm`, `global/checkpoint.asm`)
- des **objets globaux** (`global/objects/createFoeFire.properties`)
- éventuellement un **préambule/trailer d'includes** factorisés (`global/global-preambule-includes.asm`, `global/global-trailer-includes.asm` — pattern goldorak)

Ce dossier est inclus depuis le `main.asm` de chaque game-mode :
```asm
        INCLUDE "./global/macro.asm"
        INCLUDE "./global/variables.asm"
```

---

## Dossiers générés par le build

À ajouter au `.gitignore` :

```
dist/
generated-code/
tmp/
memmap.csv
memmap.html
*.fd
*.t2
*.t2flash
```

- `dist/` : produits finaux (`.fd`, `.t2`, `.t2flash`)
- `generated-code/` : asm intermédiaires générés par le builder (un sous-dossier par objet, contenant les sprites compilés `.asm`/`.bin`/`.lst`)
- `generated-code/debug/` : versions debug (assemblées avec listings et symboles)
- `tmp/` : scratch libre du développeur

---

## Référencer le moteur depuis le game-project

Deux schémas observés selon que le game-project est dans le **même repo** que l'engine ou dans un repo séparé :

### Game-project dans `thomson-to8-game-engine/game-projects/<X>/` (cas standard)
Chemins relatifs **deux crans au-dessus** :
```properties
engine.asm.boot.fd=../../engine/boot/boot-fd.asm
builder.lwasm.includeDirs=../..,.
builder.lwasm=../../tools/win/lwasm.exe
```

### Game-project dans un repo séparé (cas r-type observé)
Chemins relatifs **trois crans au-dessus** vers le repo engine voisin :
```properties
engine.asm.boot.fd=../../../thomson-to8-game-engine/engine/boot/boot-fd.asm
builder.lwasm.includeDirs=.,../..
builder.lwasm=../../../thomson-to8-game-engine/tools/win/lwasm.exe
```

Attention : `builder.lwasm.includeDirs` contrôle ce qui est résolu par les `INCLUDE` du code asm — il doit pointer la racine d'où partent les chemins `./engine/...` utilisés dans le code.
