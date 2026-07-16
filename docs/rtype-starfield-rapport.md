# Starfield R-Type niveau 1 — rapport technique

**Branche** : `wip-rtype-starfield` · **Cible** : Thomson TO8, 6809, moteur wide-dot
**État** : fonctionnel, vérifié sur machine (cartouche T2 sous TOJE)

---

## 1. Résumé

Un starfield à parallaxe de **21 étoiles sur 3 plans** défile sur le ciel ouvert qui ouvre le niveau 1, puis s'éteint au mur de la colonne 48.

| | valeur |
|---|---|
| étoiles | 21 (3 plans × 7) |
| couleurs | blanc (nibble 1), gris (2), bleu foncé (5) |
| vitesses | 1,0 / 0,5 / 0,25 px par trame (8.8 point fixe) |
| **RAM résidente** | **27 octets** (`$7EB7-$7ED1`) |
| page cartouche | 6645 o, dont 6048 o de table précalculée |
| **coût CPU** | **2052 cycles par image rendue ≈ 2,5 %** |
| coût par étoile | 24 cycles (nibble haut) / 28 (nibble bas) |
| après extinction | 0 cycle |

Le point de départ (360 o de RAM, ~140 cycles par étoile) était **infaisable** : il plantait la machine. Le design final tient en 27 octets et coûte 5× moins cher, non pas en optimisant le code d'origine mais en **supprimant le travail** : ni état par étoile, ni calcul d'adresse à l'exécution.

---

## 2. Deux contraintes découvertes par la mesure

Ces deux faits ont dicté toute l'architecture. Aucun des deux n'était déductible du code, et **aucun n'est visible à l'écran**.

### 2.1 Le plafond RAM est `$9F00`, pas `$A000`

`engine/constants.asm` :

```asm
dp               equ $9F00        ; user space (149 o max)
glb_system_stack equ dp           ; -> lds #$9F00
```

Le module du niveau monte depuis `$6100`, la **pile système descend depuis `$9F00`**, et l'espace entre les deux *est* la pile. Le module de base finit à `$9E4C` : il ne reste que **~180 octets, et ce sont ceux de la pile**.

Une table de 30 étoiles × 12 o (360 o) poussait le module à `$9FC2` — sous `$A000`, donc « ça tient » en apparence — et écrasait pile **et** page directe. Résultat : CPU exécutant la VRAM (`PC=$4F45`), écran noir. Bisect : `$9E4C` boote, `$9E7E` boote, `$9FC2` plante.

> **Règle** : avant d'ajouter de la donnée résidente à un game mode, vérifier `module_end + besoin_pile < $9F00`. Un build propre ne prouve rien.

Le pool d'objets n'est pas une réserve non plus : occupation mesurée en direct via `STACK_POINTER` — **44 slots sur 50** au pic, avant même le boss.

### 2.2 Le ciel est à `$FF`, pas à `$00`

La palette compte **deux entrées noires** : le nibble `0` et le nibble `$F` (PNG index 16, hors plage → `$0000`). Le ciel jamais dessiné est uniformément **`$FF`** ; le décor peint son noir en nibble `0`. **Les deux sont identiques à l'écran.**

Un test « si le nibble vaut 0, écris une étoile » aurait donc dessiné **zéro étoile, silencieusement**, sans qu'aucune capture puisse dire pourquoi.

Corollaire méthodologique : `read_memory` à l'arrêt **ne lit pas la VRAM** (la fenêtre `$A000-$DFFF` mappe ce que le pager y a laissé et renvoie un `$FF` trompeur). La seule lecture fiable est une sonde **exécutée dans l'objet**, qui recopie vers la RAM résidente.

---

## 3. Architecture

### 3.1 Le renversement : aucun état mutable par étoile

Le design initial stockait par étoile : position, adresse d'effacement par buffer, octet recouvert sauvegardé — 12 o × 30 = 360 o. Impossible (§2.1).

La sortie n'a pas été de **déplacer** cet état mais de le **supprimer** :

- **Les constantes d'une étoile** (`x_base`, `y`) vivent dans la **page cartouche** de l'objet — mémoire morte, gratuite en RAM résidente. C'est le pivot du design.
- **Toutes les étoiles d'un plan partagent un seul offset de défilement**, puisqu'elles ont la même vitesse. La position se déduit : `x = wrap(x_base − offset)`.
- **L'effacement se recalcule** depuis l'offset du dernier tracé dans *ce* buffer — ni adresse ni octet sauvé à stocker.

L'amas ne se déforme jamais : il glisse en bloc et boucle sur les 144 colonnes du ciel. Les `x_base` ne fixent que la **phase** de chaque étoile.

### 3.2 Les 21 étoiles ne coûtent que 27 octets

```
starCurOff    3 × 2 o    offset courant par plan (8.8 point fixe)
starPrevOff   6 × 2 o    offset du dernier tracé, [plan][buffer]
scratch           9 o    index, parité, compteurs, drapeaux d'extinction
```

`starPrevOff` est indexé **par buffer** : en double buffer, chaque page VRAM a été tracée à un offset différent. Se tromper là produit des étoiles fantômes ou doublées.

### 3.3 Parallaxe

| plan | couleur | nibble | vitesse | px / image rendue |
|---|---|---|---|---|
| 0 | blanc | 1 | `$0100` = 1,0 px/trame | 4,4 |
| 1 | gris | 2 | `$0080` = 0,5 | 2,2 |
| 2 | bleu foncé | 5 | `$0040` = 0,25 | 1,1 |

Les offsets sont en **8.8 point fixe** : la partie fractionnaire s'accumule, seul l'octet haut sert de position. C'est ce qui permet 0,25 px/trame sans quantifier le mouvement en saccades. Les trois plans franchissent le plancher de 1 px par image rendue.

Le mouvement est **compensé frame-drop** (`offset += vitesse × gfxlock.frameDrop.count`), sinon le starfield accélérerait à chaque trame sautée.

### 3.4 Tracer et effacer sont le même XOR

Le test porte sur `$F` (ciel vierge) et non sur « noir » : les étoiles **ne touchent donc jamais le décor** (nibble 0) — ce qui est aussi le rendu voulu, pas d'étoile dans la silhouette de la ville.

```asm
tracer  : lda ,x / cmpa #$F0 / blo skip / eora 4,y / sta ,x
effacer : lda ,x / eora 4,y / cmpa #$F0 / blo skip / sta ,x
```

Avec `masque = $F0 ^ couleur`, les deux opérations sont **le même XOR, dans l'ordre inverse** : tracer teste `$F` puis XOR ; effacer XOR puis teste `$F`. Et le test du nibble haut se réduit à `cmpa #$F0`, car `(octet AND $F0) == $F0` ⟺ `octet >= $F0`.

L'effacement ne rend le ciel que là où **notre** couleur est encore présente : si un sprite est passé par-dessus, on ne touche à rien.

### 3.5 Séquencement

Appelé entre `DrawTiles` et `DrawSprites` : `EraseSprites` a déjà restauré le fond (pas de rémanence), et `DrawSprites` sauvegarde le fond **avec** nos étoiles, donc le vaisseau passe devant.

Par plan : **effacer** (à l'ancien offset de ce buffer) → **avancer** → **tracer** → mémoriser l'offset.

L'ordre « effacer toutes, puis tracer toutes » est délibéré : fusionner en une passe par étoile économiserait ~5 % mais permettrait à une étoile d'effacer le pixel qu'une autre vient de tracer.

### 3.6 Extinction

Ciel ouvert = colonnes 1..47 = `glb_camera_x_pos` 12..564. Passé **530**, l'objet cesse de tracer mais continue d'effacer 4 images — le temps de nettoyer les **deux** buffers — puis `starDead` le fait sortir immédiatement : **coût nul** pour tout le reste du niveau.

---

## 4. Les optimisations, dans l'ordre

Le coût par étoile et par passe est la métrique de référence : exacte (relevée dans le `.lst`, comptes de cycles de l'assembleur) et comparable entre versions.

| étape | cycles/étoile | cycles/image | ce qui a été supprimé |
|---|---|---|---|
| procédural, 30 étoiles | 140 | ~10 980 | — |
| **inline + `ybase` précalculé**, 21 étoiles | **96** | ~5840 | `jsr`/`rts`, `mul`, temporaires mémoire |
| **table d'adresses précalculée** | **38** | ~2600 | tout le calcul d'adresse, le wrap |
| **déroulage ×7** | **26** | **2052** | `dec`/`bne`, `ldx ,u++` → `ldx n,u` |

**Gain total : -81 % par étoile**, à nombre d'étoiles constant.

### 4.1 Inline + `ybase` précalculé (140 → 96)

Trois suppressions sur le chemin chaud :

- `StarAddr` **inlinée** dans les deux appelants — la routine n'existe plus dans le binaire (`jsr`+`rts` = 13 cycles/appel).
- **`40*y` précalculé** en constante cartouche (`x_base(1) + ybase(2)`, stride 3) : supprime le `mul` (11 cycles). La cartouche est gratuite en RAM.
- **Banque VRAM choisie AVANT le calcul de l'offset** : `X` porte la base, `D` l'offset, `leax d,x` conclut. Supprime les deux allers-retours `std`/`ldd` par un temporaire mémoire, qui disparaît de la RAM.

### 4.2 Table d'adresses précalculée (96 → 38)

L'adresse VRAM d'une étoile ne dépend que de `(plan, offset, étoile)` — et ces trois valeurs sont **toutes connues à la compilation** : `x_base` et `y` sont des constantes, et l'offset ne prend que **144 valeurs entières**. Le calcul d'adresse (banque + `x/4` + `ybase` + wrap) pesait **57 % du coût** ; tracer devient un `ldx ,u++`.

- Table : 3 plans × 144 offsets × 7 étoiles × 2 o = **6048 o de cartouche**.
- Valable pour les **deux buffers** : le pager permute les pages physiques, l'adresse logique ne bouge pas. C'est ce qui rend l'idée viable.
- Générée par `gen_stardata.py`, avec assertions (x_base pair, x dans 8..151, adresse dans `$A000-$DFFF`, parité conforme) : une erreur casse la génération, pas l'écran.

**La parité est déterministe.** Le wrap ajoute 144, qui est **pair**, donc `parité(x) = parité(x_base) XOR parité(off)`. En imposant tous les `x_base` **pairs**, on obtient `parité(x) == parité(off)` pour toutes les étoiles d'un plan : le nibble est connu **une fois par plan**, pas par étoile. Cela supprime l'octet de parité de la table (2 o/entrée au lieu de 3, soit **6048 o au lieu de 9072**) et le test par étoile, au profit de deux boucles spécialisées.

Contrainte de page vérifiée avant d'écrire : `LevelInit/obj.bin` fait déjà 11 935 o, donc un objet de 6,6 Ko est dans les clous.

### 4.3 Déroulage ×7 (38 → 26)

Le coût résiduel était dominé par la boucle, pas par le travail utile :

- `dec starCnt` + `bne` (10 cycles) disparaissent — `starCnt` quitte la RAM ;
- `ldx ,u++` (8) devient `ldx n,u` à offset constant 5 bits (6).

Le code ×7 ne coûte que de la cartouche (6358 → 6645 o).

### 4.4 Pistes écartées

- **Adresses d'effacement stockées en RAM** (-21 %) : coûterait 84 o, ramenant la marge de pile de 152 à ~78 o — exactement le terrain qui a produit le crash initial.
- **Fusionner effacement et tracé** (-5 %) : risque de correction, cf. §3.5.
- **Sauter des images pour les plans lents** : le plan 2 est déjà à 1,1 px/image, au plancher de quantification.
- **Page directe pour le scratch** : `dp` (`$9F00`, 149 o max) est plein — `player1` en occupe 117.

---

## 5. Bugs notables

### 5.1 Bande verticale sans étoiles — comparaison non signée

**Symptôme** : les étoiles disparaissaient sur une bande verticale, toute hauteur, tous plans, et réapparaissaient plus à gauche.

```asm
suba  starOffInt        ; d = x_base - offset  ->  peut être NÉGATIF
cmpa  #star_x_min       ; 8
bhs   >                 ; <-- NON SIGNÉ : voit 248 >= 8, ne wrappe jamais
```

`12 - 20 = -8 = $F8 = 248` en non signé. Toute étoile dont `x_base < offset` atterrissait à `d+256` au lieu de `d+144` — **112 px trop à droite** — et passé x=159, écrivait sur la ligne suivante. Signature reproduite exactement hors machine (offset=100 : visible 8-51 et 144-151, **bande vide 52-143**).

**Correctif** : tester l'emprunt (`bcs`) *avant* la comparaison non signée. `adda #144` était déjà juste — seul le test était cassé. Validé exhaustivement hors machine (144 offsets × 144 `x_base`) avant de builder : c'est une fonction pure, donc prouvable sans émulateur.

### 5.2 Piège `ldd` = A:B — invisible à l'écran

```asm
ldd   ,x           ; D = A:B
ldb   starPrevIdx  ; <-- écrase B = l'octet BAS de D
std   ,x           ; range l'octet haut + l'index
```

Les parties fractionnaires de `starPrevOff` contenaient l'index (`02,04,06,08,0A`). **Inoffensif par chance** — l'effacement ne lit que l'octet haut — mais faux. Trouvé en **lisant la RAM**, jamais par une capture. Correctif : calculer les deux pointeurs *avant* le `ldd`.

---

## 6. Métrologie : ce qui marche et ce qui ment

Trois méthodes de mesure ont produit des chiffres faux avant d'en trouver une fiable.

| méthode | verdict |
|---|---|
| A/B en activant/désactivant le starfield | **inutilisable** : 38 → 47 → 52 images/200 trames sur trois fenêtres consécutives ; la fenêtre *sans* était plus lente que celle *avec*. La variance de charge noie le signal. |
| `total_cycles` de `profile_loops` | **non attribuable** : compte les cycles écoulés entre deux arêtes arrière, IRQ comprises. Ni exclusif ni inclusif. |
| adresses `gfxlock` codées en dur | **périmées** : `bufferSwap.count` a valu `$819E`, `$81AB`, `$81CB`, `$81C7` au fil des ajouts de code. Les symboles bougent. |
| **`.lst` + compteur d'itérations** | **fiable** : les cycles par instruction viennent de l'assembleur (déterministes), le nombre d'images d'un compteur pur. |

**Ce qui rend une mesure crédible, c'est qu'elle se recoupe.** Sur la version à table : 147 passes / 3 plans = 49 images, et 42 exécutions par image = 21 tracés + 21 effacements. Si le nombre d'étoiles ou le taux de rendu était faux, ces deux égalités tomberaient.

Les cycles/image sont indépendants de la charge ; le **pourcentage** ne l'est pas (37 à 49 images/200 trames selon les ennemis à l'écran). D'où « ~2,5 % » et non un chiffre au dixième.

---

## 7. Fichiers

| fichier | rôle |
|---|---|
| `objects/levels/01/starfield/obj.asm` | l'objet : init, extinction, effacer/avancer/tracer, macros déroulées |
| `objects/levels/01/starfield/stardata.asm` | **généré** — 6048 o d'adresses VRAM. Ne pas éditer. |
| `objects/levels/01/starfield/gen_stardata.py` | générateur + assertions ; à relancer si positions ou vitesses changent |
| `objects/levels/01/starfield/starfield.const.asm` | `starfield.INIT` / `.FRAME`, partagé avec `main.asm` |
| `game-mode/01/ram_data.asm` | les 27 octets résidents |
| `game-mode/01/main.asm` | `_Obj_RunB` à l'init et entre `DrawTiles` et `DrawSprites` |

L'objet est **code-only sur page cartouche** : lecture seule dans le build T2, donc **aucune auto-modification** (`equ *-1` interdit, contrairement au code résident du moteur) et tout l'état en RAM résidente.

---

## 8. Avant merge

- Rétablir `gameModeBoot=title` dans `config-linux.properties` (dev : `level01`).
- Retirer le define `invincible` (dev).
- **Garder** le correctif `gameMode.level01=./game-mode/01/main.d7.properties` et `build-linux.sh`.
- Vérifier le chemin normal titre → loading → niveau 1.

---

## Annexe — corrections d'estimations publiées en cours de route

Par honnêteté, trois chiffres donnés puis corrigés :

1. **« ~2400 cycles, 2,7 % »** (plan initial) → mesuré **8850, 11,7 %** : facteur 3,7.
2. **« 45 rendus / 200 trames »** → lu à `$819E`, adresse périmée. Non fiable.
3. **« 2805 cycles/image, -52 % »** → **faux** : reposait sur l'hypothèse que `profile_loops.total_cycles` était inclusif (§6). Le bon chiffre pour cette version est **~2600**, soit 96 → 38 cycles par étoile. Le message de commit a été corrigé depuis (`5fb4c6a4`) ; c'est ce qui a rendu le tableau du §4 fiable.
