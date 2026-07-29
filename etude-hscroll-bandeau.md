# Étude — Scroll horizontal par buffer de code : bandeau 160 px bouclant (BM16)

> Branche : `feat/hscroll-code-buffer` — 2026-07-28
> Références : [wide-dot.com/scroll.html](https://www.wide-dot.com/scroll.html), `engine/graphics/tilemap/vscroll/`, tooling `6809-game-builder/toolbox/graphics/png2bin`

## TL;DR

On dérive le scroll vertical à buffer de code (stack blast + code automodifié) en une version **horizontale simplifiée** pour afficher un **bandeau de 160 px de large qui boucle sur lui-même** (cas d'usage : montagnes parallaxe du port Lotus, `game-projects/road-generator`).

Le point clé qui rend le système *plus simple* que le vertical : comme la largeur du bandeau = largeur écran = période de bouclage, **aucune donnée nouvelle n'entre jamais à l'écran**. Le buffer de code est généré une fois au build et n'est **jamais mis à jour au runtime** (pas de tilemap, pas de `copyBitmap`, pas de cache). Le scroll se réduit à :

1. **Rotation grossière (pas de 16 px)** : variation du point d'entrée dans le code (1 chunk uniforme de la 1re ligne) ;
2. **Décalage fin (pas de 4 px)** : offset de ±2 octets sur le pointeur de destination (`S`) — absorbé par la bordure d'artefacts de 8 px ;
3. **Phase 2 px** : échange des destinations RAMA/RAMB entre les deux buffers de code (technique even/odd).

Deux modes sont étudiés : le **mode ruban** (simple, avec une couture de cisaillement de 1 px qui traverse l'écran, cf. §3.5.b) et le **mode sans couture** (rotation par ligne avec lignes doublées, cf. §3.6) qui élimine totalement l'artefact pour ~2× la mémoire code et un léger surcoût runtime.

Coût runtime estimé pour un bandeau de 24 lignes : **~6 800 cycles/frame brut, ~4 700 avec optimisation ciel** (vs ~20 000+ en blit générique). Code : ~4 Ko pour les 2 banques (mode ruban), ~8 Ko (mode sans couture). Driver runtime : ~60 lignes d'asm.

---

## 1. Contexte et besoin

Besoin exprimé (conversation Benoît / __sam__, projet road-generator / Lotus) :

- Bandeau décor (montagnes) **160 px de large × ~24 px de haut**, mode **BM16**, qui **boucle en X** : « ce qui part à gauche revient à droite ».
- Résolution de scroll **chunky 2 px** (pas d'offset au pixel près — c'est déjà la résolution du jeu).
- On accepte des **artefacts de 8 px à gauche et 8 px à droite** de l'écran, soit **16 px continus en RAM** (l'écran boucle en X : la fin de la ligne *n* est contiguë au début de la ligne *n+1*).
- Objectif perf : gagner ~4 fps sur le rendu d'un tour de circuit (cible ~13-14 fps de moyenne).
- Le pré-traitement (image → buffer de code) va **dans l'engine et le tooling**, comme pour le scroll vertical.

### Pourquoi pas les systèmes existants

| Système | Localisation | Verdict |
|---|---|---|
| `vscroll` | `engine/graphics/tilemap/vscroll/` | Vertical uniquement. Mais **c'est la base architecturale à dériver** (buffer de code cyclique + stack blast). |
| `horizontal-scroll` (R-Type) | `engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered*.asm` | Réécriture **différentielle** des données de tiles (comme BattleSquadron) : nécessaire quand la map est plus large que l'écran, mais « pas le top niveau perf ». Inutile ici : le bandeau boucle sur 160 px. |
| Blit générique / 4 buffers preshiftés (skill `bm16-pixel-blit`) | — | ~3-4× plus lent pour redessiner 24×160 px chaque frame ; le pixel près est superflu (2 px suffit). |

---

## 2. Rappels sur l'existant (ce qu'on réutilise)

### 2.1 L'algo vertical (wide-dot.com/scroll.html + `vscroll.asm`)

- **Scroll-chunk** : `ldd # / ldx # / ldy # / ldu # / pshs d,x,y,u` = 15 octets de code, 8 octets de pixels écrits, 26 cycles. Les données pixel sont **persistées dans les opérandes du code** (sprites compilés).
- **Buffer de code déroulé** : 1 ligne écran/banque = 40 octets = 5 chunks = 75 octets de code (`vscroll.LINE_SIZE`). Buffer de 208 lignes (`vscroll.BUFFER_LINES`), un par banque (A et B), chacun dans sa page RAM montée en espace cartouche (`_SetCartPageA`).
- **Point d'entrée variable** : entrer à la ligne *c* du buffer fait défiler l'affichage de *c* lignes. Le buffer boucle sur lui-même via un `jmp @loop` final.
- **Point de sortie automodifié** : un `JMP` de 3 octets est patché à `(cursor + hauteur_viewport) mod 208`, après sauvegarde des 3 octets écrasés, puis restauré (`vscroll.do`, lignes 455-500 de `vscroll.asm`).
- **S détourné** comme pointeur d'écriture ⇒ une IRQ peut écrire 12 octets sous S : zones `$9FF4-$9FFF` / `$BFF4-$BFFF` à laisser libres.
- **Mise à jour différentielle** : seules les lignes qui *entrent* à l'écran sont réécrites dans le code (`vscroll.updategfx` + `vscroll.copyBitmap` + cache de map). **C'est toute cette machinerie qui disparaît en horizontal.**

### 2.2 Le layout BM16 (déterminant pour l'horizontal)

- 160×200, 4 bpp. 1 octet = 2 px. Une ligne = 80 octets **entrelacés octet par octet** entre deux banques :

```
Pixels écran : p0 p1 p2 p3 p4 p5 p6 p7 ...
RAMA (bytes) : [p0|p1]       [p4|p5]        → 40 octets/ligne
RAMB (bytes) :       [p2|p3]       [p6|p7]  → 40 octets/ligne
```

- Donc : **+1 octet dans les deux banques = +4 px** ; **+2 px = échange des rôles RAMA/RAMB** (+1 octet sur l'une des deux).
- Spécificité Thomson : dans la fenêtre donnée `$A000-$DF3F`, les plans sont physiquement inversés : `$A000-$BF3F` = RAMB, `$C000-$DF3F` = RAMA (cf. skill `thomson-to8-engine-bm16-pixel-blit`).

### 2.3 Le tooling existant

- `png2bin` (repo voisin `6809-game-builder/toolbox/graphics/png2bin`) : convertit un PNG indexé en binaires planaires par banque (`-lb 4 -pb 8 -p 2 -pd 4`), option `-slc` pour décaler les index couleur.
- Option `-vs` → `VerticalScroll.java` (~60 lignes) : lit le bin planaire **en ordre inverse** (car `pshs` écrit en descendant) et enrobe chaque groupe de 8 octets en `ldd/ldx/ldy/ldu/pshs` → fichier `.bin.vscroll`, inclus tel quel par `INCLUDEBIN` dans un objet (cf. `game-projects/vertical-scroll-tilemap/objects/scroll/A.asm` et `engine/graphics/tilemap/vscroll/vscroll.md`).

---

## 3. Conception proposée : `hscroll` bandeau bouclant

### 3.1 Vue d'ensemble

Deux buffers de code (un par banque), générés au build à partir du PNG 160×H du bandeau. Chaque buffer contient le **bandeau entier** sous forme de code, ordonné en octets inversés (écriture descendante), structuré ainsi :

```
        ┌────────────────────────────────────────────────┐
entrée→ │ LIGNE BASSE (uniforme)   10 chunks de 4 octets │  ← point d'entrée : chunk h (h = 0..9)
        │ CORPS (optimisé)         lignes H-2 .. 1       │  ← taille de code variable, librement optimisé
sortie→ │ LIGNE HAUTE (uniforme)   10 chunks de 4 octets │  ← patch JMP @ret au chunk 10-h (+3 o de pad)
        └────────────────────────────────────────────────┘
```

- **Ligne basse = point d'entrée dynamique** : structure strictement uniforme (chunks de taille constante) pour que l'offset d'entrée soit un calcul trivial (`h × TAILLE_CHUNK`). C'est la contrainte « la première ligne doit être pleine ».
- **Corps** : aucune contrainte de taille — le générateur peut omettre tout `ld_` dont la valeur est déjà dans le registre (zones de ciel = enchaînements de `psh_` purs). Avantage majeur sur le vertical, où *chaque* ligne devait faire 75 octets.
- **Ligne haute = point de sortie dynamique** : uniforme elle aussi, JMP patché à `EXIT_OFFSET + (10-h) × TAILLE_CHUNK` (constante produite au précalcul, +3 octets de pad en fin de buffer pour le cas h=0). Pas de `jmp @loop` de rebouclage : l'exécution est linéaire et couvre H×40 − 4·h octets par banque — les 4·h octets « wrappés » (haut-gauche du bandeau) ne sont **jamais écrits**, on n'affiche donc pas le retour de la ligne du bas : cette zone garde le contenu du back buffer (bandeau d'il y a 2 frames), invisible à vitesse ≤ 2 px/frame.

À chaque frame on exécute les deux buffers en entier sur le back buffer (redraw complet du bandeau — il est petit, et ça élimine tout problème de cohérence du double buffering).

### 3.2 Décomposition de la position de scroll

Position X du bandeau ∈ [0, 160), pas de 2 px. Décomposition :

```
X = 16·h + 4·b + 2·w      h ∈ [0..9]   : chunk d'entrée (rotation grossière 16 px)
                          b ∈ [-2..+1] : offset destination en octets/banque (pas de 4 px)
                          w ∈ {0, 1}   : phase 2 px (échange RAMA/RAMB)
```

(on choisit `h` au plus proche, d'où `b` symétrique dans [-2..+1] ⇒ débordement max **8 px** de chaque côté — c'est exactement le budget d'artefacts accepté).

Application par banque, tout au runtime, **sans aucune variante de code** :

| Levier | Mécanisme | Coût |
|---|---|---|
| `h` | entrée à `code + h×8` ; JMP patché à `exit + (10-h)×8` | shifts triviaux, 3 octets sauvegardés/restaurés |
| `b` | `S = fin_zone_bandeau + b` | 0 |
| `w` | buffer A → zone `$A000` au lieu de `$C000` (et inversement), +1 octet sur l'une des deux destinations | 0 |

C'est la réponse au problème initial de __sam__ (« le décalage de 1 octet nécessite 6 versions du code ») : **une seule version du code, on décale le pointeur de destination**, la bordure de 16 px absorbe le débordement.

### 3.3 Structure des chunks — variante `pshs` (décision actée)

On garde la convention du vscroll : **`pshs d,x,y,u`**, débit maximal (8 octets de données / 26 cy = 3,25 cy/octet, chunk ciel = `pshs` seul à 13 cy).

**Sur la question des IRQ** (S détourné comme pointeur d'écriture) : ce n'est pas bloquant, pas besoin de masquer. Mécanisme précis :

- Pendant le blast, une IRQ écrit 12 octets **sous S**, c'est-à-dire dans la zone du bandeau *pas encore écrite* — ces octets sont écrasés par les `pshs` suivants quelques chunks plus tard. Corruption transitoire sur le back buffer, jamais affichée (le buffer n'est visible qu'après `_gfxlock` swap).
- Le seul débordement résiduel : si l'IRQ tombe entre le dernier `pshs` et la restauration de S, les 12 octets **au-dessus du début du bandeau** (= fin de la ligne écran au-dessus) sont corrompus. **À la charge du développeur** : ne pas placer le haut du bandeau trop haut dans l'écran, et faire en sorte que la ligne au-dessus soit tolérante (ciel repeint, zone morte…). Même esprit que la contrainte `$9FF4-$9FFF`/`$BFF4-$BFFF` du vscroll plein écran.

Structure retenue (par banque, mode ruban) :

```asm
; lignes basse (entrée) et haute (sortie) : 10 chunks uniformes de 8 octets de code / 4 octets de données
        ldd   #$xxxx        ; 3 o, 3 cy
        ldx   #$xxxx        ; 3 o, 3 cy
        pshs  d,x           ; 2 o, 9 cy   → 4 octets écrits, granularité d'entrée = 16 px écran

; corps : 5 chunks de 8 octets de données par ligne (40 octets/banque), optimisables
        ldd   #$xxxx        ; omis si D inchangé
        ldx   #$xxxx        ; omis si X inchangé
        ldy   #$xxxx        ; omis si Y inchangé
        ldu   #$xxxx        ; omis si U inchangé
        pshs  d,x,y,u       ; 26 cy plein, 13 cy ciel
```

Un chunk uniforme = **8 octets de code** ⇒ offset d'entrée/sortie = `h << 3`, aucun besoin de table (en mode ruban).

Le point de sortie est un **`JMP` étendu de 3 octets patché** (sauvegarde/restauration des 3 octets écrasés), exactement comme `vscroll.do` — un `RTS` est impossible puisque S est détourné ; l'entrée se fait par `jmp ,x` et le retour par `jmp @ret` avec S sauvegardé en automodifié.

### 3.4 Driver runtime (pseudocode)

```asm
hscroll.do                                ; ~60 lignes, appelé chaque frame rendue
        ; 1. décomposer hscroll.pos en h, b, w
        ; 2. pour chaque banque k (buffer A, buffer B) :
        ;    - monter la page du buffer k en espace cartouche (_SetCartPageA)
        ;    - dest = base_zone(k XOR w) + 40*(band_y + band_h) + b (+1 selon w)
        ;    - patcher : sauver les 3 octets à exit_k + ((10-h)<<3), écrire jmp @ret
        ;    - sts @save_s ; lds #dest ; jmp [code_k + (h<<3)]
        ; @ret - restaurer S et les 3 octets patchés
        rts

hscroll.move                              ; même squelette que vscroll.move :
        ; vitesse 8.8 signée × gfxlock.frameDrop.count (compensation frame drop),
        ; accumulation sub-pixel, position modulo 160, arrondi au pas de 2 px
        rts
```

Ce qui **disparaît** par rapport au vertical : `updategfx`, `copyBitmap`, `updateTileCache`, la map, les tilesets, le cache, la gestion bidirectionnelle des lignes entrantes, le viewport variable. Le contenu est figé au build.

### 3.5 Artefacts (analyse honnête)

**a) Débordement du décalage fin (budgété, accepté).** L'offset `b` (±2 octets/banque = ±8 px) fait déborder la zone écrite : jusqu'à 8 px écrits au-delà d'un bord du bandeau (sur la ligne écran adjacente, côté opposé à cause du bouclage RAM), et 8 px **non réécrits** (contenu périmé) à l'autre bord. Soit les 16 px continus en RAM annoncés. Dans le cas Lotus : la ligne au-dessus = ciel uni, la ligne en dessous = horizon/route repeinte chaque frame ⇒ invisibles gratuitement. Sinon : prévoir 8 px de garde à chaque extrémité du bandeau (contenu « don't care » ou repeint après).

**b) Couture de cisaillement 1 ligne (mode ruban).** La rotation du ruban de code fait qu'à la colonne écran `x ≈ X mod 160`, le contenu à gauche de la couture provient de la ligne bandeau adjacente (décalage vertical de 1 px, la couture se déplace avec le scroll). Cause structurelle : une **coulée d'écriture unique et linéaire** ne peut produire qu'une rotation du *ruban entier*, alors qu'un scroll horizontal exact exige H rotations *indépendantes, une par ligne*. Cas particulier de la ligne du haut : grâce au point de sortie dynamique (§3.1), les octets wrappés (qui montreraient la ligne du **bas**) ne sont pas écrits — la zone garde le contenu du back buffer (bandeau à X−2·vitesse), quasi identique. Sur un décor organique chunky 2 px (silhouette de montagnes), c'est indétectable en mouvement — et ça se contourne complètement, voir §3.6.

### 3.6 Parade à la couture : mode « sans couture » (rotation par ligne)

L'idée : faire boucler **chaque ligne sur elle-même** dans le code, au lieu de faire boucler le ruban global. Pour ça, chaque ligne du buffer contient **deux copies consécutives de son propre code** (code périodique), et on chaîne les lignes par des `JMP` :

```
        ┌─ ligne H (basse) ──────────────────────────────────┐
entrée→ │ copie 1 : chunks 0..4   copie 2 : chunks 0..4      │
        │           ↑ entrée au chunk h        ↑ jmp patché  │──jmp──▶ ligne H-1, chunk h
        ├─ ligne H-1 ────────────────────────────────────────┤
        │ copie 1 : chunks 0..4   copie 2 : chunks 0..4      │──jmp──▶ ligne H-2, chunk h
        ├─ ...                                               │
        ├─ ligne 1 (haute) ──────────────────────────────────┤
        │ copie 1 : chunks 0..4   copie 2 : chunks 0..4      │──jmp──▶ @ret (driver)
        └────────────────────────────────────────────────────┘
```

Pour une phase `h`, chaque ligne exécute copie 1 chunks `h..fin` puis copie 2 chunks `début..h-1` = exactement les 40 octets de la ligne, **rotationnés de 16·h px, sans jamais déborder sur la ligne voisine** ⇒ zéro cisaillement. S descend continûment d'une ligne à l'autre, aucun ajustement entre lignes.

**Gestion des jumps inter-lignes** — le point clé qui rend ça bon marché : la phase `h` est **la même pour toutes les lignes**, et elle ne change qu'à chaque franchissement de 16 px. Donc :

- Les `JMP` (3 octets, patchés à `copie2 + h×TAILLE_CHUNK` de chaque ligne, cible = entrée `copie1 + h×TAILLE_CHUNK` de la ligne suivante) ne sont **repatchés que quand `h` change** — au plus une fois toutes les 16 px de scroll, soit H×2 banques patches (~2 000-2 500 cy) une frame sur 4 à 16 selon la vitesse ⇒ **~150-600 cy/frame amortis**.
- Chaque frame ne paye que l'exécution des H `JMP` : 24 × 4 cy × 2 banques ≈ **200 cy**.
- Entre deux valeurs de `h`, le décalage fin `b`/`w` (offset de S, échange de banques) couvre les pas de 2 px comme en mode ruban — le débordement fin ne touche que les bords haut/bas du bandeau (§3.5.a), les bords gauche/droite sont **parfaitement propres**.

**Conséquences sur le générateur** (tooling) :

- Le tool émet par banque deux **tables générées** : `entryAddr[ligne][h]` et `patchAddr[ligne][h]` — du coup plus besoin d'uniformité des chunks : l'optimisation (omission des `ld_`) reste possible, il suffit que les *frontières de chunk* existent à chaque phase.
- Contrainte d'optimisation supplémentaire : un chunk susceptible d'être un point d'entrée de ligne (= tous les chunks de copie 1) ne peut omettre un `ld_` que si la bonne valeur est garantie par **ses deux prédécesseurs possibles** : le chunk précédent de la même ligne (exécution linéaire) *et* le chunk de même phase de la ligne en dessous (arrivée par le `jmp` inter-lignes). Pour du ciel uniforme verticalement — le cas payant — les deux conditions sont satisfaites : **l'optimisation ciel survit**.
- La ligne basse (première exécutée) doit charger complètement ses registres (état inconnu à l'entrée du driver).

**Deux calibres possibles**, selon le budget d'artefact haut/bas qu'on s'autorise (même logique « à la charge du développeur » que pour les IRQ) :

| Calibre | Chunks | Phases `h` | Offset fin `b` | Débordement haut/bas | Surcoût cycles vs ruban |
|---|---|---|---|---|---|
| (i) chunks pleins | `pshs d,x,y,u` (8 o) | 5 × 32 px | ±4 octets | jusqu'à **16 px** | ~0 % (mêmes chunks) |
| (ii) budget strict 8 px | `pshs d,x` (4 o) | 10 × 16 px | ±2 octets | 8 px | ~+15 % (9 cy/4 o en ciel vs 13 cy/8 o) |

Dans le contexte Lotus (ciel uni au-dessus, horizon repeint en dessous), le calibre (i) est indolore : **zéro couture, zéro perte de débit**, pour 2× la mémoire code.

**Alternative artistique (mentionnée pour mémoire)** : si le bandeau comporte de larges colonnes « neutres » (ciel pur entre deux massifs), on peut rester en mode ruban et générer 2-3 variantes du buffer pré-tournées (ex. 0 et 80 px), en choisissant à chaque frame celle dont la couture tombe dans un trou. Zéro surcoût runtime, mais contrainte forte sur le graphisme — le mode sans couture est la solution générale.

### 3.7 Budgets

Pour H = 24 lignes (montagnes Lotus), variante `pshs` :

| Poste | Mode ruban | Mode sans couture (calibre i) |
|---|---|---|
| Cycles/frame, pire cas (0 optimisation) | ~6 800 cy | ~7 200 cy (jmp + patchs amortis) |
| Cycles/frame avec optimisation ciel (~50 %) | ~4 700 cy | ~5 000 cy |
| Coût | **constant**, indépendant de la vitesse (vs vscroll ∝ vitesse) | idem + pic de patch au changement de `h` |
| Code généré (2 banques) | ~4 Ko | ~8 Ko + tables ~1 Ko |
| Artefacts | 8 px G/D + couture 1 px mobile | haut/bas du bandeau uniquement (≤16 px) |

À ~13 fps de jeu (budget réel ≈ 75 000+ cy/frame rendue), le bandeau coûte **~6-9 % du budget frame** dans les deux modes.

---

## 4. Tooling à créer

Dans `6809-game-builder/toolbox/graphics/png2bin` (là où vit `-vs`) :

1. **Nouvelle option `-hs`** (mode ruban) → classe `HorizontalScroll.java`, sur le modèle de `VerticalScroll.java` :
   - entrée : les bins planaires par banque déjà produits par png2bin (PNG 160×H, H ≤ ~48) ;
   - lecture en ordre inverse (écriture descendante), génération : ligne basse uniforme (`ldd/ldx/pshs d,x` ×10) + corps optimisé + ligne haute uniforme (sortie) + 3 octets de pad ;
   - **optimiseur** : suivi linéaire des valeurs de D/X/Y/U, émission d'un `ld_` seulement si la valeur change. Chargements complets forcés dans les lignes d'entrée et de sortie (état des registres inconnu à l'entrée, chunks de sortie atteignables individuellement). Le corps peut réutiliser l'état hérité de la ligne d'entrée ;
   - sorties : `<nom>.<plane>.bin.hscroll` (code) + `<nom>.hscroll.equ` (constantes : `HEIGHT`, `ENTRY_CHUNK_SIZE=8`, `EXIT_OFFSET` — le corps étant optimisé, l'offset de la ligne de sortie diffèrera par banque, `CODE_SIZE`).
2. **Option `-hs-seamless`** (mode sans couture, §3.6) : lignes doublées périodiques + émission des tables `entryAddr[ligne][h]` / `patchAddr[ligne][h]` (en `.asm` de données, incluses par l'objet), contrainte du double prédécesseur sur l'optimiseur, calibre (i) ou (ii) en paramètre.
3. Étapes : d'abord `-hs` sans optimiseur (corps uniforme) pour valider la chaîne, puis optimiseur, puis `-hs-seamless`.

Côté projet de jeu, même intégration que le vscroll : un objet `.properties`/`.asm` par buffer avec `INCLUDEBIN` du `.hscroll`.

## 5. API engine (implémentée)

Nouveau module `engine/graphics/tilemap/hscroll/` (`hscroll.asm`, `hscroll.macro.asm`) :

```asm
        INCLUDE "./objects/band/band.0.0.bin.hscroll.equ"  ; équates générées par png2bin -hs

        _hscroll.setBuffer #ObjID_bandA,#ObjID_bandB   ; objets buffers de code (pages + adresses)
        _hscroll.setExitOffset #hscroll.band.EXIT_OFFSET ; équate générée
        _hscroll.setViewport #0,#hscroll.band.HEIGHT   ; ligne écran du haut + hauteur
        _hscroll.setCameraPos #0                       ; X initial 8.8 (int 0..159, pair)
        _hscroll.setCameraSpeed #$0080                 ; 8.8 signé, px/frame 50 Hz

MainLoop
        ...
        _gfxlock.on
        jsr   hscroll.do                               ; redraw complet du bandeau (back buffer)
        jsr   hscroll.move                             ; intègre la vitesse, compense les frame drops
        _gfxlock.off
```

V1 mono-instance (variables globales, comme vscroll). La généralisation multi-bandeaux (plusieurs plans de parallaxe) = passer les variables en struct pointée — à ne faire que si le besoin apparaît.

## 6. Plan d'implémentation

1. ~~**Tooling**~~ ✅ : `HorizontalScroll.java` + option `-hs` dans png2bin (repo `6809-game-builder`), sans optimiseur (corps uniforme), avec le `.equ` généré.
2. ~~**Engine**~~ ✅ : `engine/graphics/tilemap/hscroll/hscroll.asm` + macros (driver, variante S/JMP comme vscroll).
3. ~~**Projet de démo**~~ ✅ : `game-projects/horizontal-band-scroll` (bandeau de test 160×24, vitesse au joypad, franchissement du wrap).
4. ~~**Validation**~~ ✅ sur émulateur toje — cf. §8 (rendu pixel-perfect, wrap, couture conforme, 6 715 cy mesurés).
5. **Optimiseur ciel** dans le tooling + re-mesure.
6. **Mode sans couture** (`-hs-seamless` + patcher de phase dans le driver) si la couture éditée dans l'art ne suffit pas.
7. **Intégration road-generator / lotus** (bandeau montagnes, vitesse pilotée par la courbure/direction).

## 7. Points ouverts

- ~~Variante S vs U~~ — **tranché : `pshs`** (débit max ; la corruption IRQ sous S est transitoire car réécrite par les chunks suivants ; le débordement de fin de run est à la charge du développeur, cf. §3.3).
- ~~Mode ruban vs sans couture en v1~~ — **tranché : mode ruban** (décision : la couture est visible en quasi-permanence, donc l'art est édité en en tenant compte ; sur un paysage c'est jouable). Le mode sans couture reste une évolution possible (§3.6).
- ~~Signe/convention exacte de `b` et `w`~~ — **tranché à l'implémentation** (validé pixel-perfect sur émulateur, cf. §8) : phase `w=1` ⇒ plan B → zone `$C000` avec **+1 octet** sur S, plan A → zone `$A000` ; `bo ∈ [-2..+1]` s'ajoute à S sur les deux zones ; vitesse positive = contenu qui défile vers la droite.
- **Hauteur max du bandeau** : le code doit tenir dans la fenêtre cartouche 16 Ko par banque ⇒ H ≤ ~190 lignes en mode ruban, ~95 en mode sans couture — largement suffisant (usage visé : 16-48 lignes).
- ~~2 px en v1 ?~~ — **inclus et validé** (l'échange de banques est quasi gratuit).
- **Optimiseur ciel** (omission des `LD_` redondants dans le corps) : pas encore implémenté — étape suivante, gain estimé jusqu'à ~40 % sur les zones uniformes.

## 8. Implémentation v1 — réalisée et validée (07/2026)

Chaîne complète livrée sur la branche `feat/hscroll-code-buffer` (engine) :

- **Tooling** : `HorizontalScroll.java` + option `-hs` dans png2bin (repo `6809-game-builder`).
  Entrée : bin d'un plan (40 o/ligne). Sortie : `<plan>.hscroll` (code) + `<plan>.hscroll.equ`
  (constantes `hscroll.band.HEIGHT / EXIT_OFFSET / CODE_SIZE`). Structure : ligne d'entrée
  uniforme 10×(`ldd#`/`ldx#`/`pshs d,x` = 8 o), corps 5×(H−2) chunks `pshs d,x,y,u` (15 o),
  ligne de sortie uniforme (ligne haute, `jmp` patché à `EXIT_OFFSET + (10-h)×8`), 3 o de pad.
- **Engine** : `engine/graphics/tilemap/hscroll/hscroll.asm` (+ `hscroll.macro.asm`) —
  `hscroll.move` (8.8 signé, compensation frame drop, wrap [0,160)), `hscroll.do`
  (décomposition x = 16h + 4bo + 2w, swap de zones en phase w=1, patch/run/restore
  par plan, même mécanique S/JMP que vscroll).
- **Démo** : `game-projects/horizontal-band-scroll` (bandeau montagnes 160×24 de
  lotus-adnz, vitesse joypad gauche/droite clampée à ±2 px/frame, build FD/T2 OK).

Validation sur émulateur toje (MCP) :

| Critère | Résultat |
|---|---|
| Rendu statique | conforme au PNG source (couleurs, formes) |
| Pas de 2 px (toutes phases h/bo/w) | +2.0 px exacts, 100 % de correspondance pixel entre pas consécutifs |
| Wrap 159→0 | continu, aucun glitch (bug de wrap signé trouvé et corrigé : à x=160 la partie entière $A0 était vue négative ⇒ saut de +64 px) |
| Retour de la ligne du bas en haut-gauche | **supprimé** par le point de sortie dynamique (les octets wrappés ne sont pas écrits, zone stale du back buffer invisible à ≤2 px/frame) |
| Couture ruban (corps) | conforme §3.5 : cisaillement vertical d'1 ligne à gauche de la colonne de wrap |
| **Coût mesuré `hscroll.do`** (H=24, 2 plans) | **6 769 cycles** ≈ 34 % d'une trame (théorie ~6 650 ✓, ~280 cy/ligne) |

Contrainte d'usage : garder |vitesse| ≤ 2 px/frame pour que la zone haut-gauche non réécrite
(back buffer, contenu à X−2·vitesse) reste indiscernable ; le driver borne par ailleurs le
déplacement compensé à ±96 px par frame (wrap non signé).
