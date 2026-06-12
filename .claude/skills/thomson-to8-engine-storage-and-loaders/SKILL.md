---
name: thomson-to8-engine-storage-and-loaders
description: "Décrit le pipeline de stockage et chargement du Thomson TO8/TO9 game engine (Bento8/wide-dot) : trois cibles principales disquette .fd / cartouche T2 megarom .t2 / cartouche T2 flash SDDRIVE .t2flash, boot loaders boot-fd.asm (FD, animation palette fade vers couleur cible, init commutation page espace données, chargement Game Mode Engine en page 4, ORG $6200) et boot-t2.asm (T2, ORG $0000 avec header Megarom) et boot-t2-flash.asm (SDDRIVE), RAMLoaderManager Fd et T2 pour gérer le chargement des pages RAM, RAMLoader (zx0/ ou exo/) pour décompresser, mécanisme RLM_SkipCommon pour skip les pages communes entre game-modes (économie chargement), LoadGameMode / LoadGameModeNow pour basculer entre game-modes avec auto-load, variables GameMode / ChangeGameMode / glb_Cur_Game_Mode / glb_Next_Game_Mode, format des index Gm_Index pour résoudre game-mode → adresse, T2 flash via t2-flash.asm + megarom-t2/t2-test.asm avec multi-disques SDDRIVE (4 disquettes pour 128 pages, 4 pistes x 16 secteurs par page, pistes 16-79 face 0 + face 1), formats compression ZX0 (zx0_6809_mega / zx0_6809_mega_back / zx0_6809_standard / zx0_6809_turbo, compresseur Java) vs Exomizer (exomizer.asm + exobin tool), routines ClearDataMem / ClearCartMemory / ClearDataMemoryRAMx pour clear pages, knapsack packing par le builder Java pour optimiser le placement des pages RAM. Utiliser pour comprendre le boot du jeu, choisir entre fd/t2/t2flash, configurer LoadGameMode pour les transitions, optimiser le packing des pages, comprendre la compression ZX0 vs Exomizer, gérer une cartouche multi-disques SDDRIVE. Mots-clés : boot-fd, boot-t2, boot-t2-flash, RAMLoaderManager, RAMLoaderManagerFd, RAMLoaderManagerT2, RAMLoader, RAMLoaderFd, RAMLoaderT2, LoadGameMode, LoadGameModeNow, GameMode, ChangeGameMode, glb_Cur_Game_Mode, glb_Next_Game_Mode, Build_RAMLoaderManager, Gm_Index, RLM_SkipCommon, RLM_SetPage, RLM_CopyCode, .fd disquette, .t2 megarom, .t2flash SDDRIVE, zx0, zx0_6809_mega, zx0_6809_standard, zx0_6809_turbo, zx0_mega.asm, exomizer, exobin, megarom T.2, SDDRIVE, IFDEF T2, page 4 RAMLoaderManager, page 0 RAM, $0555, $02AA, Megarom commands, boot palette fade, boot_color_gr, boot_color_b, builder.diskName, builder.t2Name, dist directory, knapsack, ClearDataMem, ClearCartMemory, ClearDataMemoryRAMx."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Storage et loaders — Thomson TO8/TO9 Game Engine

L'engine supporte **3 cibles de stockage** :

| Cible | Format | Boot loader | RAM Loader | Capacité |
|-------|--------|-------------|------------|----------|
| Disquette | `.fd` | `boot-fd.asm` | `RAMLoaderFd.asm` | 320 Ko / disque, multi-disques |
| Cartouche T2 | `.t2` | `boot-t2.asm` | `RAMLoaderT2.asm` | 2 Mo (128 pages × 16 Ko) |
| Cartouche T2 Flash | `.t2flash` | `boot-t2-flash.asm` | (SDDRIVE) | Multi-Mo via carte SD |

Ce skill couvre le pipeline complet : boot, chargement des pages, transitions de game-modes, compression.

---

## Boot loaders

### `boot-fd.asm` — démarrage disquette

```asm
        org   $6200

PalInit
        setdp $62
        lda   #$62
        tfr   a,dp                      ; DP = $62

        ; Animation palette fade vers couleur cible (boot_color_gr/b)
        ; ...
        
        ; Init commutation page espace données
        ; ...
        
        ; Chargement Game Mode Engine en page 4
        ; via routine disque
        
        ; Appel du Game Mode Engine
        jmp   $6100
```

Caractéristiques :
- ORG `$6200` (laisse de la place pour le secteur de boot)
- Animation palette pendant le chargement (boot fade)
- Charge le premier game-mode en page 4
- Saute à `$6100` (point d'entrée standard)

### `boot-t2.asm` — démarrage cartouche T2

```asm
        org   $0000

; Header Megarom T.2 (caractères "S T 2")
        fcb   $20, $53, $54, $32, $20   ; " ST2 " header
        ; ...
```

Cartouche T2 :
- ORG `$0000` (zone cartouche)
- Header Megarom obligatoire (signature)
- Charge le game-mode initial depuis la cartouche
- Jump à `$6100`

### `boot-t2-flash.asm` — SDDRIVE cartouche flash

Pour le hardware SDDRIVE de Daniel Coulom (multi-disques sur carte SD). Multi-disques :
- 4 disquettes pour 128 pages
- 4 pistes × 16 secteurs par page
- Pistes 16-79 face 0 + face 1 (16 inutilisées)

Plus complexe que T2 classique car gère le changement de disque dynamique.

---

## RAMLoaderManager

Responsable du **chargement des pages RAM** depuis le storage.

### `RAMLoaderManagerFd.asm`

```asm
        org $0000

RAMLoaderManager
        ; input : A = nouveau game-mode, B = game-mode courant
        sts   RLM_CopyCode_restore_s+2
        ldu   #Gm_Index
        aslb
        ldx   b,u                       ; adresse data du game-mode courant
        asla
        ldu   a,u                       ; adresse data du nouveau

        lds   -2,u                      ; destination address
        tstb
        bmi   RLM_SetPage                ; -1 = premier load
        
RLM_SkipCommon
        ; Compare les 7 premiers octets pour skipper les pages communes
        ldd   ,u
        cmpd  ,x
        bne   RLM_SetPage
        ; ... compare octets 2-7 ...
        ; si tout pareil :
        leas  -7,s
        leau  7,u
        leax  7,x
        bra   RLM_SkipCommon
        
RLM_SetPage
        ; ... charge la page depuis le disque/cartouche ...
```

### `RLM_SkipCommon` — optimisation

Si le **game-mode courant** et le **nouveau** partagent des pages identiques (e.g. via `gameModeCommon`), le manager **skip** ces pages au chargement. Économie majeure de temps disque.

Compare les 7 premiers octets de l'index pour détecter les pages communes (identique = déjà en RAM, pas besoin de recharger).

C'est ce qui rend `gameModeCommon` si efficace (cf. skill new-game).

### Gm_Index — table des game-modes

Generated par le builder Java. Format :
```asm
Gm_Index
        fdb  gm_TitleScreen_data        ; index 0 = TitleScreen
        fdb  gm_level01_data            ; index 1 = level01
        fdb  gm_level02_data            ; index 2 = level02
        ; ...
```

Chaque adresse pointe vers une zone qui contient :
- Adresse destination (où charger)
- Liste des pages à charger (chacune sur 7 octets)
- Marqueur de fin ($FF négatif)

---

## RAMLoader (compression)

### Variantes

```
engine/ram/
├── zx0/
│   ├── RAMLoaderFd.asm           # ZX0 pour FD
│   └── RAMLoaderT2.asm           # ZX0 pour T2
└── exo/
    ├── RAMLoaderFd.asm           # Exomizer pour FD
    └── RAMLoaderT2.asm           # Exomizer pour T2
```

### ZX0 (recommandé)

Compresseur moderne, bon ratio, décodeur rapide.

```
engine/compression/zx0/
├── zx0_6809_mega.asm
├── zx0_6809_mega_back.asm
├── zx0_6809_standard.asm
├── zx0_6809_turbo.asm
└── LICENSE / README.md
```

4 variantes selon vitesse vs taille :
- `standard` : équilibré
- `turbo` : décode plus rapide, légèrement plus de mémoire
- `mega` : optimisé pour gros blobs
- `mega_back` : décode en arrière (utile pour certains layouts)

Sélectionné via `engine.asm.RAMLoader.fd=../../engine/ram/zx0/RAMLoaderFd.asm` dans config-windows.properties.

### Exomizer

Alternative légèrement moins compact mais décodeur très rapide :

```properties
builder.exobin=../../tools/win/exomizer.exe
engine.asm.RAMLoader.fd=../../engine/ram/exo/RAMLoaderFd.asm
```

Nécessite `exomizer.exe` (outil externe Windows). Pas dans le repo par défaut.

### Choix

| Critère | ZX0 | Exomizer |
|---------|-----|----------|
| Ratio compression | Excellent | Bon |
| Vitesse décode | Très rapide | Très rapide |
| Mémoire décodeur | ~256 octets | ~1 Ko |
| Disponibilité | Inclus engine | Outil externe |
| **Recommandation** | **Défaut** | Si besoin spécifique |

---

## `LoadGameMode` — transitions

```asm
GameMode           fcb   $00            ; game-mode à charger
ChangeGameMode     fcb   $00            ; flag : 1 = changement demandé
glb_Cur_Game_Mode  fcb   $00            ; en cours
glb_Next_Game_Mode fcb   $00            ; prochain (info utile pour transitions)

LoadGameMode
        lda   ChangeGameMode
        bne   LoadGameModeNow
        rts                             ; pas de changement, no-op

LoadGameModeNow
 IFDEF T2
        lda   #$80                      ; ROM page 0
        _SetCartPageA
        lda   GameMode
        ldb   glb_Cur_Game_Mode
        jmp   Build_RAMLoaderManager
 ELSE
        ldb   #$64                      ; page 4 = RAMLoaderManager
        stb   $E7E6
        lda   GameMode
        ldb   glb_Cur_Game_Mode
        jmp   >$0000
 ENDC
```

### Pattern d'usage

```asm
        ; trigger : aller au level 2
        lda   #GmID_level02
        sta   GameMode
        lda   #1
        sta   ChangeGameMode

        ; Dans MainLoop, après l'IRQ off et cleanup :
        jsr   LoadGameMode               ; ne retourne pas si change effectif
```

`LoadGameModeNow` :
1. Mount le RAMLoaderManager (page 4 en FD, ROM en T2)
2. Saute dedans avec A=destination, B=source
3. Le manager charge les pages nécessaires
4. Saute au point d'entrée du nouveau game-mode ($6100)

**Pas de retour** : c'est un saut, pas un appel.

### Variables globales préservées

Tu peux poser des variables persistantes dans `globals.X` (à $9E28 par exemple, cf. r-type) qui survivent à la transition. Le nouveau game-mode les lit.

Exemple :
```asm
globals.nextGameMode     equ GLOBAL_VARIABLES+0
globals.score            equ GLOBAL_VARIABLES+1
globals.lives            equ GLOBAL_VARIABLES+3
; ...
```

`globals.score` = 0 init dans le premier game-mode, puis incrémenté pendant le gameplay, conservé à travers les niveaux.

---

## Format du disque .fd

Format Thomson standard :
- 80 pistes × 16 secteurs × 256 octets = 320 Ko
- Piste 0 : boot + RAMLoaderManager
- Pistes 1-79 : pages RAM compressées

Le builder Java place les pages selon un **knapsack packing** pour minimiser le nombre de pistes utilisées.

## Format de la cartouche .t2

Megarom T2 (par Prehisto) :
- 128 pages × 16 Ko = 2 Mo
- Page 0 : boot + RAMLoaderManager
- Page 1+ : code (page commune) + données

Commutation via séquence Megarom :
```asm
        ; séquence T2 (cf. SetCartPageA)
        sta   >$0555    ; $F0 sortie commande
        sta   >$0555    ; $AA
        sta   >$02AA    ; $55
        sta   >$0555    ; $C0
        sta   >$0555    ; numéro de page
```

## Format .t2flash (SDDRIVE)

Multi-fichier sur carte SD. 4 disquettes pour les 128 pages :
- Disquette 1 : pistes 0-15 (boot) + pages 0-31
- Disquette 2 : pages 32-63
- Disquette 3 : pages 64-95
- Disquette 4 : pages 96-127

Changement de disquette automatique par le hardware SDDRIVE.

## Routines de clear mémoire

```asm
ClearDataMem                            ; clear page courante en zone donnée ($A000-$DFFF)
        ldx   #$0000
        ; ... rempli avec une valeur ...

ClearCartMemory                         ; clear zone cartouche ($0000-$3FFF)
ClearDataMemoryRAMx                     ; clear une RAM page spécifique
```

Utilisées au boot ou aux transitions pour reset l'état.

## Patterns observés

### Game-mode unique (test, demo)

```properties
gameModeBoot=test
gameMode.test=./game-mode/test/test.properties
```

Pas de LoadGameMode, le game-mode reste en boucle main.

### Game-mode multi (jeu normal)

```properties
gameModeBoot=TitleScreen
gameMode.TitleScreen=./game-mode/00/main.properties
gameMode.level01=./game-mode/01/main.properties
gameMode.level02=./game-mode/02/main.properties
```

Transitions via `LoadGameMode`.

### Build multi-target

```properties
# config-windows.properties pour FD
gameMode.level01=./game-mode/01/main.d7.properties

# config-windows.t2.properties pour T2
gameMode.level01=./game-mode/01/main.t2.properties
```

Variantes de game-mode par target.

## Pitfalls

- **`gameModeBoot` invalide** : crash au boot (pas de fallback)
- **`LoadGameMode` sans `ChangeGameMode = 1`** : no-op silencieux
- **Modifier `GameMode` sans `ChangeGameMode`** : ignoré
- **Page T2 incorrecte** dans le bit 7 : crash au mount
- **Mélange ZX0 et Exomizer** : un seul compresseur par projet (le RAMLoader doit matcher la compression utilisée)
- **`RLM_SkipCommon` mal aligné** : pages communes pas détectées → recharge inutile
- **`builder.to8.memoryExtension=N` mais > 16 pages** : crash au build
- **Cartouche T2 sans header** : ne boot pas
- **SDDRIVE non détectée** : t2flash inutilisable
- **`LoadGameMode` pendant IRQ** : crash (l'IRQ peut être appelée pendant la transition)

---

## Références détaillées

- [references/boot-loaders.md](references/boot-loaders.md) — boot-fd.asm / boot-t2.asm / boot-t2-flash.asm détaillés : palette fade au démarrage, init commutation page, header Megarom T2, pin layout SDDRIVE, ORG, premier chargement
- [references/ram-loader-manager.md](references/ram-loader-manager.md) — RAMLoaderManagerFd / RAMLoaderManagerT2, Gm_Index format, RLM_SkipCommon optimization, RLM_SetPage, RLM_CopyCode, transition entre game-modes, économie via gameModeCommon
- [references/compression-zx0-exo.md](references/compression-zx0-exo.md) — Compression ZX0 (variantes standard/turbo/mega/mega_back, performance et trade-offs) vs Exomizer (exomizer.exe externe), choix selon le projet, intégration avec RAMLoader, ratio typique
- [references/load-game-mode.md](references/load-game-mode.md) — LoadGameMode / LoadGameModeNow détails, variables GameMode / ChangeGameMode / glb_Cur_Game_Mode / glb_Next_Game_Mode, transition vs reset, variables globales persistantes (globals.X), patterns d'usage (intro→game→game over→retry)
