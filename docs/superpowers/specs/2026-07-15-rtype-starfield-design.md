# R-Type — Starfield sur l'intro du niveau 1

**Date** : 2026-07-15
**Branche** : `wip-rtype-starfield`
**Statut** : ⚠️ **PARTIELLEMENT PÉRIMÉ — le modèle mémoire décrit plus bas est IMPOSSIBLE.**

> ## ⚠️ Correction (2026-07-15, après implémentation — commit `1dbea80c`)
>
> **Le modèle de données de ce document (30 étoiles × 12 o = 360 o en RAM résidente,
> save/restore de l'octet recouvert) NE TIENT PAS et a été remplacé.**
>
> Le plafond de la RAM d'un game mode est **`$9F00`, pas `$A000`** : `engine/constants.asm`
> définit `dp equ $9F00` et `glb_system_stack equ dp`. Le module monte depuis `$6100`, la pile
> système descend depuis `$9F00`, et **l'espace entre les deux EST la pile**. Le module de base
> finit à `$9E4C` : il ne reste que ~180 o, et ce sont ceux de la pile. La table de 360 o
> poussait le module à `$9FC2`, écrasait pile + page directe, et le CPU exécutait la VRAM
> (`PC=$4F45`, écran noir — sous Theodore aussi : ce n'était pas un problème d'émulateur).
>
> Le pool d'objets n'est pas une réserve non plus : pic mesuré à **44/50 slots** avant le boss.
>
> **Conception réellement implémentée — starfield procédural, 28 o de RAM :** les étoiles n'ont
> aucun état mutable. Leurs constantes (`x_base`, `y`) vivent dans la **page cartouche** de
> l'objet (gratuit) ; toutes les étoiles d'un plan partagent un offset de défilement, donc
> `x = wrap(x_base - offset)` se recalcule chaque trame ; l'effacement recalcule l'ancienne
> position depuis l'offset du dernier tracé **dans ce buffer**. Plus de save/restore : on trace
> uniquement si le nibble vaut `$F` (ciel, mesuré uniformément `$FF`) et on efface en réécrivant
> `$F` — les étoiles ne touchent donc jamais le décor (nibble 0), ce qui est le rendu voulu.
> RAM = 3 offsets courants + 3×2 offsets par buffer + scratch = **28 o**. Module à `$9E69`.
>
> Restent valides ci-dessous : l'objectif, les couleurs (1 blanc / 2 gris / 5 bleu foncé),
> le modèle d'adressage BM16, les vitesses (1 / 0,5 / 0,25 px/trame), la zone de ciel.
> Voir `game-projects/r-type/objects/levels/01/starfield/obj.asm` pour la conception réelle.
>
> ### Coût réel mesuré (tâche 5) — le chiffre « 2,7 % » du plan était faux d'un facteur ~3,7
>
> | | annoncé | **mesuré** |
> |---|---|---|
> | cycles par image rendue | ~2 400 | **~8 850** |
> | part d'une image rendue | 2,7 % | **~11,7 %** |
> | taux de rendu | 4,44 trames/image (11 img/s) | **3,8 trames/image (~13 img/s)** |
>
> Méthode : `StarAddr` est appelé exactement 60× par image (30 effacements + 30 tracés).
> Le profiler donne **3 180 hits sur son `mul`** en 200 trames → **53 images rendues**, ce qui
> recoupe `gfxlock.bufferSwap.count`. Les coûts par instruction viennent du `.lst`
> (`generated-code/level01/T2/starfield/obj.lst`), pas d'une estimation.
>
> ⚠️ **L'ancien chiffre « 45 rendus / 200 trames » avait été lu à `$819E`, une adresse
> périmée.** Les symboles `gfxlock` BOUGENT à chaque ajout de code : `bufferSwap.count` valait
> `$819E` puis `$81AB` (build de base) puis **`$81CB`** (build actuel). Toujours relire
> l'adresse dans `generated-code/level01/T2/main.glb`, jamais la coder en dur.
>
> ⚠️ **Un A/B en activant/désactivant le starfield à chaud (`starDead`) ne mesure RIEN ici** :
> 38 → 47 → 52 images/200 trames sur trois fenêtres consécutives. La variance de charge
> (ennemis) noie complètement le signal. C'est le comptage d'appels qui donne le vrai chiffre.
>
> ### Optimisation (2026-07-16) — 11,3 % → **6,0 %** d'une image
>
> | | avant | **après** |
> |---|---|---|
> | étoiles | 30 (3×10) | **21 (3×7)** |
> | coût d'un tracé/effacement | 140 cycles | **96 cycles** (-31 %) |
> | cycles par image rendue | ~10 980 | **5 840** (-47 %) |
> | part d'une image | 11,3 % | **6,0 %** |
> | RAM | 28 o | **26 o** |
>
> Trois changements, tous sur le chemin chaud parcouru 42× par image :
> 1. **`StarAddr` inlinée** dans `StarDraw`/`StarErase` (elle n'existe plus dans le binaire) :
>    supprime `jsr`+`rts` = 13 cycles par appel.
> 2. **`40*y` précalculé** en constante cartouche (`x_base(1) + ybase(2)`, stride 3) : supprime
>    le `mul` (11 cycles). La page cartouche est gratuite en RAM résidente, donc c'est sans coût.
> 3. **Banque VRAM choisie AVANT le calcul de l'offset** : `X` porte la base, `D` l'offset,
>    `leax d,x` conclut. Supprime les deux allers-retours `std`/`ldd starTmpW` — et `starTmpW`
>    a disparu de la RAM.
>
> **Méthode de mesure (celle qui marche) :** `profile_loops` donne 738 arêtes arrière sur la
> boucle étoiles ; +123 entrées (41 rendus × 3 plans) = **861 exécutions = 21 × 41**, ce qui
> confirme d'un coup le nombre d'étoiles ET le taux de rendu lu dans `bufferSwap.count`.
> ⚠️ `total_cycles` de `profile_loops` est **exclusif** de la routine appelée (la plage
> d'adresses de la boucle ne contient pas `StarDraw`) — il faut y ajouter `appels × coût du
> chemin exécuté` relevé dans le `.lst`. Le modèle prédisait 5772, la mesure donne 5840 (1,2 %
> d'écart) : les deux méthodes se valident mutuellement.

## Objectif

Ajouter un starfield à parallaxe sur le ciel ouvert qui ouvre le niveau 1 de R-Type :
2 à 3 plans, 30 étoiles maximum, très léger en RAM et en cycles, implémenté comme
objet géré par le moteur.

## Contraintes mesurées

Tout ce qui suit a été vérifié sur le build Linux tournant dans TOJE, pas déduit.

### Le niveau 1 est CPU-bound

| Mesure | Valeur | Méthode |
|---|---|---|
| Référence trame | 300 hits `gfxlock.bufferSwap.check` / 300 trames | profiler |
| Boucle d'attente VBL (`$81D5`) | **~2 % du temps** | profiler |
| Images rendues | **45 / 200 trames** | `read_memory $819E len=2` (`gfxlock.bufferSwap.count`, 16 bits) |
| Taux de rendu | **4,44 trames par image ≈ 11 img/s** | dérivé |
| Cycles par image rendue | **~88 700** (4,44 × 19968) | dérivé |
| `gfxlock.frameDrop.count` | 4–6 en échantillon | `read_memory $81A3` |
| `gfxlock.frameDrop.max` | 8 | `main.asm:139` |

**Correction d'une mesure antérieure.** Une première estimation annonçait ~2,75 trames/image (~18 img/s), tirée d'une arête arrière `$621A` à 109 itérations/300 trames vue dans `profile_loops` : cette boucle **n'était pas la boucle de rendu**. Le compteur du moteur (`gfxlock.bufferSwap.count`, incrémenté à chaque swap) tranche à 4,44 trames/image, ce qui concorde avec les relevés de `frameDrop.count` (4–6). Ne pas déduire le taux de rendu de `profile_loops`.

Le niveau ne dort quasiment jamais : il n'y a pas de marge de cycles à consommer,
toute addition se paie directement en taux de rafraîchissement.

Le profil est **plat** : aucun point chaud au-dessus de 2,19 % (`empty_tile_loop`).
Il n'y a donc pas d'optimisation évidente à récupérer ailleurs pour financer le
starfield.

### Conséquence directe sur les vitesses

Le starfield ne se dessine **qu'une fois par image affichée**, pas par trame. Avec
la compensation `frameDrop.count` (obligatoire, sinon le starfield accélère quand
une image saute) :

```
2 px/trame × 4,44 trames/image = ~8,9 px de saut par image
```

Une étoile d'1 px qui saute de 8,9 px à 11 img/s se lit comme un pointillé
clignotant, pas comme un mouvement. Le plafond pour un mouvement continu est
**≤ ~3 px par image affichée**.

Le plancher est symétrique et vient d'un bug déjà payé (`to8-game-mode-gotchas`
règle #4) : le rendu n'utilise que la partie entière du 8.8, donc **en dessous
d'1 px par image le mouvement quantise** (1,0,1,0 = saccade).

**Vitesses retenues : 1 / 0,5 / 0,25 px par trame** = **4,4 / 2,2 / 1,1 px par
image**. Les trois plans passent le plancher d'1 px/image. Le plan blanc, à
4,4 px/image, dépasse le plafond de continuité : c'est le seul point à juger à
l'œil, et une seule constante à baisser s'il clignote.

### Géométrie du décor

Carte du niveau 1 (`objects/levels/01/map/0/0.0.bin`, 132 colonnes × 15 rangées,
1 mot par cellule, rangement en colonnes) :

```
col  0      ###############   colonne de tuiles noires pleines (init écran)
col  1..47  ............###   ciel ouvert : rangées 0..11 TOUJOURS vides
col 48      ##.#########.##   mur : fin du ciel
col 49+     ######...######   tunnel (plafond + sol)
```

- Ciel ouvert = colonnes 1→47 → caméra x = 12→564 px.
- À `scroll_vel = $0030` (0,1875 px/trame), l'intro dure **~60 secondes**.
- Zone sûre : rangées de tuiles 0..11 → **écran y = 11..154**, **x = 8..151**
  (viewport 12×15 tuiles de 12×12 en (8,11), `objects/levels/01/obj.asm`).

## Le fond : mesuré, pas déduit

> **Cette section a été entièrement réécrite après vérification sur machine.**
> La version initiale affirmait « ciel = index 0, noir du décor = index 1, donc
> `nibble == 0` ⟺ ciel vierge ». **Les deux moitiés étaient fausses**, et le test
> `nibble == 0` ne se serait jamais déclenché : zéro étoile, sans aucun message
> d'erreur. Voir « Comment l'erreur a tenu si longtemps » plus bas.

### La palette est décalée d'un cran

`PaletteTO8.getPaletteData()` boucle sur `colorIndex = 1..16` : il **supprime
l'index 0 du PNG** (la clé de transparence `#CC00FF`) et émet PNG 1..16 comme
couleurs matérielles 0..15. Table réellement émise, lue dans
`generated-code/level01/BuilderMainGenCode.asm` (source de vérité — **pas** la
mémoire : `Pal_game` est précédé de `Pal_black`, qui finit par deux `fdb $0000`,
et lire 2 octets trop tôt fabrique un noir fantôme qui décale toute la table) :

| nibble | octets émis | = index PNG | couleur | rôle |
|----|--------|------|-------|------|
| **0** | `$0000` | PNG 1 | noir `#000000` | **noir *peint* par le décor** |
| **1** | `$ee0d` | PNG 2 | blanc `#FAFAF2` | étoile plan proche |
| **2** | `$1101` | PNG 3 | gris `#616161` | étoile plan moyen |
| **5** | `$1003` | PNG 6 | bleu foncé `#00618F` | étoile plan lointain |
| **15** | `$0000` | PNG 16 (hors palette → 0) | noir | **ciel vierge** |

### Le ciel vaut `$FF`, et les deux noirs sont indiscernables à l'écran

Mesuré par une sonde de balayage **exécutée dans l'objet** (donc pendant
`gfxlock`, VRAM mappée) : `AND` et `OR` de **chaque octet** de la zone
x 8..151 / y 11..154, sur les deux plans → `$FF` / `$FF` / `$FF` / `$FF`.
**Le ciel entier est uniformément `$FF`.** Le terrain, lui, peint son noir en `$00`.

Le ciel est noir à l'écran **parce que le nibble 15 est noir aussi** (`fdb $0000`),
pas parce qu'il vaut 0. Un ciel à `$00` et un ciel à `$FF` sont **visuellement
identiques** — d'où l'erreur initiale.

La sonde confirme au passage la prémisse d'insertion : au point d'appel (après
`EraseSprites`, avant `DrawSprites`) le ciel est propre **même là où se trouve le
vaisseau**.

**Point non élucidé, assumé :** `LoadAct` génère `ldx #$0000 ; jsr ClearDataMem`
sur les pages 2 **et** 3, ce qui devrait donner un ciel à `$00`. Qui écrit `$FF`
n'est pas établi. Le `$FF` est uniforme et stable sur 900+ trames et les deux
buffers, mais le design **ne repose pas dessus** (cf. ci-dessous).

## L'invariant réel : sauver et restaurer

Puisque la valeur du fond est un fait mesuré dont la cause est inconnue, le design
ne s'y fie pas :

- **Tracer** : lire l'octet ; si le pixel est **noir** (nibble ∈ {`0`, `$F`} — les
  deux entrées noires de la palette, critère indépendant de la valeur du ciel) →
  **mémoriser l'octet** puis écrire notre nibble.
- **Effacer** : lire l'octet ; si notre nibble vaut encore **notre couleur** →
  restaurer **le nibble mémorisé**. Sinon, le décor a repris la place → ne rien
  toucher.

La restauration ne réécrit que *notre* nibble à partir de l'octet sauvegardé, pour
ne pas piétiner une étoile voisine logée dans l'autre nibble du même octet.

Conséquences :

- Le starfield **ne peut rien corrompre** : il ne modifie que des pixels qu'il a
  lui-même lus et sauvegardés, et il les rend à l'identique.
- Aucune dépendance à la valeur du ciel : si `$FF` devenait `$00` demain, tout
  continue de marcher.
- Aucune lecture de tilemap, aucun cas particulier au mur de la colonne 48 : quand
  le décor monte, le test « pixel noir » cesse de passer et les étoiles s'éteignent
  seules.
- Accepté : une étoile peut se poser sur un pixel **noir du décor** (nibble 0),
  puisque le critère est « noir », pas « ciel ». Sans effet dans l'intro (la zone
  x 8..151 / y 11..154 ne contient aucun décor sur les colonnes 1..47), et couvert
  par l'extinction à `camMax` pour le tunnel.

## Comment l'erreur a tenu si longtemps

À retenir, parce que le piège se retendra :

1. **`read_memory` à l'arrêt ne lit pas la VRAM.** La fenêtre `$A000-$DFFF` est
   mappée sur ce que le pager y a mis *à cet instant*, ce qui n'est en général pas
   le buffer vidéo → elle renvoie `$FF`. J'ai lu `$FF` deux fois et conclu « la
   fenêtre n'est pas mappée » — c'était la vraie valeur. Seule une sonde
   **exécutée dans l'objet** lit ce que le code voit.
2. **Deux entrées noires rendent le bug invisible.** Nibble 0 et nibble 15 sont
   tous deux `$0000` : aucun screenshot ne pouvait distinguer un ciel à `$00` d'un
   ciel à `$FF`.
3. **Lire la palette en mémoire est fragile.** Lire la table *émise* dans
   `BuilderMainGenCode.asm`.

## Architecture

### Un seul objet, pas trente

Objet code-only sur **page cartouche → zéro RAM résidente pour le code**, sur le
modèle exact de `objects/enemies/shell/eraser.asm` (`ObjID_shellEraser`), qui est
déjà appelé au bon endroit et gère déjà le double buffer via
`gfxlock.backBuffer.id`.

- Code : `objects/levels/01/starfield/obj.asm`, point d'entrée `Object`.
- Déclaration : `object.starfield=./objects/levels/01/starfield/obj.d7.properties`
  dans `game-mode/01/main.d7.properties` → génère `ObjID_starfield`.

### Insertion dans la boucle

Dans `mainloop.routine.running` (`game-mode/01/main.asm`) :

```
        jsr   EraseSprites
        jsr   DrawTiles
        _Obj_Run ObjID_starfield    ; <-- ici : après le décor, avant les sprites
        jsr   DrawSprites
```

Cette position est la seule correcte, et c'est démontrable :

- `EraseSprites` s'exécute **avant** → le fond sauvegardé (donc les étoiles cachées
  sous un sprite) est déjà restauré quand on efface. Pas de rémanence.
- `DrawSprites` s'exécute **après** → il sauvegarde le fond *avec* nos étoiles puis
  dessine par-dessus. Le vaisseau passe devant les étoiles, et la restauration de
  la trame suivante est cohérente.

### Le test au pixel

Le mécanisme est décrit en détail dans « L'invariant réel : sauver et restaurer »
plus haut : tracer si le pixel est **noir** (nibble ∈ {`0`, `$F`}) après avoir
mémorisé l'octet, effacer en restaurant le nibble mémorisé si notre couleur est
toujours là.

L'objet est réutilisable ailleurs sans réglage lié au niveau 1.

### Adressage VRAM

Calcul en ligne (~33 cycles), pixel (x,y) avec x ∈ 0..159, y ∈ 0..199 :

```
offset = (x >> 2) + 40*y
base   = $C000 si (x AND 2) = 0, sinon $A000
nibble = haut si x pair, bas si x impair
```

**Les plans BM16 sont inversés en espace data : RAM B est à `$A000`, RAM A à
`$C000`.** L'encodeur (`PngToBottomUpB16Bin`) écrit RAM A dans ses *8000 premiers*
octets = colonnes de pixels 0,1 de chaque groupe de 4 ; RAM B ensuite = colonnes
2,3. La lecture intuitive de `scroll-map-buffered-even.asm` (`$A000` d'abord) est
donc **à l'envers**. Diagnostiqué et corrigé sur le projet `starfield`
(commit `77c558e4`) : s'y tromper décale chaque pixel de ±2 px selon la parité de
`x>>1`, ce qui fait **vibrer** l'étoile (elle semble reculer) au lieu de la
déplacer proprement. Vérifier l'ordre des plans **par position**, pas en comptant
les couleurs — c'est ce qui avait masqué le bug.

**Ne pas appeler `DRS_XYToAddress` pour un pixel isolé.** Sa branche « colonne
impaire » renvoie `location_1 = $C000 + (x>>2) + 40y + **1**` : le `+1` est correct
pour un blit de sprite pré-décalé et faux d'un octet pour un pixel seul. Le calcul
en ligne est aussi moins cher (~33 vs ~50 cycles).

### Double buffer

Piège déjà payé sur le projet `starfield` (fantômes / doublons) : 2 pages VRAM.
Chaque étoile garde **son adresse d'effacement par buffer**, indexée par
`gfxlock.backBuffer.id`, sur le modèle de `eraser.asm` :

```
        tst   gfxlock.backBuffer.id
        beq   @buf0
        leax  <décalage slot buffer 1>,x
```

Une adresse à 0 = « rien à effacer dans ce buffer » (étoile neuve ou respawnée).

### Modèle de données

3 plans × 10 étoiles = 30. Par étoile :

| champ | taille | note |
|---|---|---|
| `st_x` | 2 o | x en 8.8 fixe (octet haut = pixel 0..159) |
| `st_ybase` | 2 o | 40 × y précalculé au spawn (évite un `mul` par étoile et par image) |
| `st_e0` / `st_e1` | 2+2 o | adresse d'effacement par buffer ; **0 = rien à effacer** |
| `st_s0` / `st_s1` | 1+1 o | **octet sauvegardé** par buffer (le fond recouvert) |
| `st_m0` / `st_m1` | 1+1 o | nibble écrit par buffer (`$F0` haut / `$0F` bas) |

= **12 octets/étoile → 360 octets de RAM**, statique, aucune allocation dynamique.
La couleur et la vitesse sont portées par le plan (3 constantes), pas par l'étoile.

Plus 4 octets de scratch résident (`starEraseOff`, `starMaskOff`, `starFrameCnt`,
`starXTmp`) : l'objet vit sur une page cartouche, **lecture seule dans le build
T2**, donc il ne peut ni s'auto-modifier ni stocker d'état chez lui.

`st_s0`/`st_s1` sont le prix de l'indépendance à la valeur du fond : +2 octets par
étoile (60 au total) contre un design qui ne peut structurellement rien corrompre.

### Mouvement

- `x -= vitesse × gfxlock.frameDrop.count` en 8.8, sur le modèle de `Scroll`
  (`scroll-map-buffered-even.asm`), sinon le starfield accélère quand une image
  saute.
- Sortie à gauche (`x < 8`) → respawn à droite (`x = 151`), `y` aléatoire dans
  `[11,154]` via `engine/math/RandomNumber.asm`.
- Seed initial : étoiles réparties aléatoirement sur tout l'écran à l'init.

### Extinction

Le test nibble==0 suffit à la correction. Pour éviter des étoiles qui apparaîtraient
dans les poches de vide du tunnel, **arrêter le respawn** quand
`glb_camera_x_pos >= ~530` (colonne ~44). Les étoiles déjà à l'écran finissent leur
course et disparaissent naturellement avant le mur de la colonne 48.

## Budget

| Poste | Coût |
|---|---|
| Adresse (`DRS_XYToAddress`) | ~50 cycles × 30 |
| Effacement + tracé (RMW) | ~30 cycles × 30 |
| **Total** | **~2400 cycles par image** |
| Part d'une image (~88 700 cycles) | **~2,7 %** |
| RAM | **360 octets** (+4 de scratch) |

Si c'est trop cher à l'arrivée, leviers dans l'ordre : descendre à 20 étoiles ;
puis remplacer `DRS_XYToAddress` par un calcul dédié (y étant fixe par étoile,
`adresse = xtable[x] + ybase` précalculé au respawn).

## Vérification

1. Build Linux : `./build-linux.sh` → `dist/r-type.rom`.
2. TOJE : `load_cartridge` sur le `.rom`, `run_frames 150`, `type_keys ["1E"]`
   (**0 du pavé numérique**), `run_frames 900` → niveau 1.
3. Screenshot : étoiles blanches/grises/bleues sur le ciel, aucune sur le décor.
4. Régression décor : screenshot à l'approche du mur (colonne 48) et dans le
   tunnel → aucun pixel noir parasite dans le terrain.
5. Fantômes : screenshots sur 2 images consécutives → pas de doublon d'étoile
   (bug double-buffer).
6. Coût : `profile_loops` avant/après → vérifier que la boucle de rendu ne dépasse
   pas ~+5 %.

## Modifications de la config de build (dev)

Sur `config-linux.properties`, pour le développement uniquement :

- `gameMode.level01=./game-mode/01/main.d7.properties` — **correction d'un bug** :
  pointait sur `main.properties`, qui n'existe pas. La config Linux était cassée.
- `gameModeBoot=level01` — boot direct sur le niveau 1.
- `builder.lwasm.define=invincible,...` — le vaisseau clignote au lieu de mourir
  (`IFDEF invincible`, `objects/player1/player1.asm:309`). Sans ça, le boot direct
  fait mourir le vaisseau en boucle : TOJE n'a pas de commande joystick, donc
  personne ne pilote.
- `build-linux.sh` — nouveau, calqué sur `game-projects/starfield/build-linux.sh`.

**À reverter avant merge** : `gameModeBoot` et `invincible`. La correction de
`main.d7.properties` et `build-linux.sh` sont à garder.

## Risques

| Risque | Traitement |
|---|---|
| Ordre des nibbles inconnu | Vérifié par screenshot dès la 1re étoile tracée |
| Coût > estimation | Leviers listés dans Budget ; mesurable avant/après |
| Fantômes double-buffer | Pattern `eraser.asm` + test de non-régression dédié |
| `gameModeBoot`/`invincible` fuient dans un build de prod | Listés ci-dessus comme à reverter |

## Écarté

- **30 objets moteur** (1 par étoile) : coût RAM du pool et sauvegarde/restauration
  de fond par étoile, pour un pixel.
- **Test de la tilemap par étoile** : le test au pixel est plus simple, plus sûr et
  ne nécessite pas de lire une page cartouche.
- **Parallaxe plus lente que le terrain** (physiquement juste) : à 0,1875 px/trame,
  les étoiles seraient quasi statiques. Écarté au profit de la lisibilité.
- **Ne redessiner qu'au changement de pixel** : aurait rendu le coût quasi nul,
  mais incompatible avec des étoiles plus rapides que le terrain.
