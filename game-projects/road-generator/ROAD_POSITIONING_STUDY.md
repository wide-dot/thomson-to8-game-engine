# Étude — Méthode de positionnement route TO8 → fidélité Lotus 68000

État : 2026-06-03. Étude exploratoire, **aucune implémentation**. Objectif :
rapprocher la méthode de positionnement de la cible 68k validée, sous contraintes
mémoire et cycles 6809.

---

## 0. Contraintes posées

**À CONSERVER** :
- Structure buffer + "compression" par chunk pré-compilé `Road_R* : ldd #D ; ldx #X ; pshu d,x ; rts`.
- Appel du cœur route via `jsr [,y++]` (le buffer stocke les pointeurs de chunks).
- Mécanisme sous-pixel existant : **4 variants** (s0/s1 × RAMA/RAMB-first = 0..3 px) **+ byte_offset** (sub_pix>>2 = 0/4/8/12 px) → 16 sous-positions px. *C'est notre équivalent des edge-sprites 68k, mais appliqué à toute la route.*

**À REFONDRE / SUPPRIMABLE** :
- Grass début/fin de ligne (actuellement préambule/postlude `pshu` dans les routines KJM).
- Système de dispatch `Road_draw_K{K'}_J{J'}` (66 routines + table 11×11) → **peut sauter**.

---

## 1. La cible 68k (FUN_0007661e), rappel

```
centerX   = $90 - (combined × width × 2) >> 16        ; TO8 : 72 - product (product = (combined×width)>>16)
halfwidth = width >> 4                                ; CONTINU (TO8 : width>>5)
leftEdge  = centerX - halfwidth                       ; pixel continu
rightEdge = centerX + halfwidth
leftEdge_chunks  = leftEdge  >> 4 (signé, peut = -1)  ; + sub_pix_LEFT  = leftEdge  & 15
rightEdge_chunks = rightEdge >> 4                     ; + sub_pix_RIGHT = rightEdge & 15
road_width_chunks = rightEdge_chunks - leftEdge_chunks  ; DÉRIVÉ des bords (varie ±1 lissé)
```
Ladder : `grass(var) | sprite bord gauche (sub_pix_LEFT) | asphalte(var, dither D2/D3) | sprite bord droit (sub_pix_RIGHT) | grass(var)`.
**Clé de fidélité 68k** : les deux bords sont positionnés **indépendamment** au sous-pixel (sprites de bord `$2bd40`, 256 entrées × 64 o = 16 Ko, indexés sub_pix×bucket-largeur×dither), et la largeur asphalte est **variable** (remplie au chunk près entre les deux bords).

---

## 2. Les DEUX écarts de fidélité (à traiter séparément)

| # | Écart | Cause | Relève de |
|---|-------|-------|-----------|
| **G1** | Le rumble (bord) saute ±8-14 px sur les transitions de M | position = `M*8` quantifié, et le contenu chunk porte la quantif | **méthode de positionnement** (objet de l'étude) |
| **G2** | Route trop large à l'horizon (réf = 27 px, port = 48 px) | `M` du buffer a un **minimum** (~3 chunks) ; ne descend pas vers 0 | **contenu buffer** (granularité largeur), orthogonal |

> G2 ne se règle PAS par le positionnement : il faut des buffers à granularité de largeur plus fine (M jusqu'à 0-1 chunk, ou demi-chunks). Coût : plus de `line_idx`/mémoire buffer. **À traiter à part.** Le reste de l'étude porte sur G1.

---

## 3. Le verrou physique du body M-chunk

`pshu` écrit de **droite à gauche** (U décrémente). Le body = M chunks rigides (`core[0]` = rumble droit dessiné en premier = adresse haute = droite écran ; `core[M-1]` = rumble gauche). Conséquence : avec **un seul** body rigide ancré par **un** point, on ne peut rendre **qu'UN** bord exact au sous-pixel ; l'autre dérive de l'erreur de largeur `M*16 − width>>4` (≤ ±8 px, la route étant quantifiée à 16 px).

Pour rendre **les deux** bords exacts, il faut **découpler** les bords ⇒ largeur asphalte variable entre deux bords indépendants (= le choix 68k). Mais l'asphalte "fill uniforme" **perd les lignes blanches centrales** bakées dans les chunks → il faut les redessiner. C'est le cœur du compromis ci-dessous.

---

## 4. Solutions de positionnement

### Solution A — Ancrage CENTRE continu (body M-chunk conservé)

Calcule `centerX = 72 - product` (continu). Ancre le **centre** du body M-chunk sur `centerX` :
`U_droite = centerX + M*8` (en px → octet), sous-pixel `(centerX+M*8)&15` via variant+byte_offset existant. Clip aux bords écran (comme `coreOff`/`F` actuels). Grass fill variable de chaque côté.

- **Fidélité** : **centre route LISSE** (fin du zigzag G1), bords ±4 px symétriques (quantif 16 px répartie). **Garde tout le contenu baké** : lignes blanches, dither dark/light, rumble (dans les chunks). G2 reste.
- **Mémoire** : −66 routines KJM −table 11×11 (~1,5-2 Ko), +1 routine fill grass + 1 routine cœur paramétrée. **Bilan négatif (gain).**
- **Cycles/scanline** : calc bords (~40 cyc, les muls sont déjà faits) + grass fill + `F × ~31` (cœur jsr[,y], inchangé) + grass fill. ≈ **neutre vs actuel** (le dispatch lookup ~30 cyc est remplacé par le calc bords ; cœur identique).
- **Risque** : faible (réutilise tout, change le calcul de position + le grass).

### Solution B — Bords découplés, sous-pixel indépendant, asphalte fill variable

Dessine droite→gauche : `grass | rumble droit @rightEdge (sub_pix_RIGHT) | asphalte fill (count = road_width_chunks, jsr[,y]) | leau (ajuste U du delta sous-pixel) | rumble gauche @leftEdge (sub_pix_LEFT) | grass`.

- **Fidélité** : **les DEUX bords exacts au sous-pixel** (= 68k). MAIS asphalte uniforme ⇒ **lignes blanches centrales perdues** → passe de tracé des lignes séparée (positions track-relatives). Le rumble doit devenir un élément positionnable isolé (réutilise variant+byte_offset, ou mini edge-sprite).
- **Mémoire** : +contenu rumble isolé (petit, réutilise variants) + LUT/logique lignes blanches. **Modéré.**
- **Cycles/scanline** : +`leau` d'ajustement par bord (~6×2) + **passe lignes blanches** (~50-100 cyc/ligne selon nb lignes). **+~100 cyc/ligne** ⇒ ~+19 k cyc/frame (192 passes). Notable.
- **Risque** : moyen-élevé (gestion lignes blanches = nouveau sous-système).

### Solution C — Sprites de bord pré-rendus (full 68k)

Rumble + lignes-de-bord pré-rendus en sprites 16 sous-pixel × buckets-largeur × dark/light (transposition du `$2bd40`). Place edge-sprite gauche + asphalte fill + edge-sprite droit.

- **Fidélité** : **maximale (= 68k)**, lignes de bord incluses dans les sprites.
- **Mémoire** : **la plus grosse** — tables sprites. Estimation TO8 (demi-rés, 160 px) : ~16 sub × ~8 buckets × 2 dark/light × ~8 o = ~2 Ko/bord (×2 bords = ~4 Ko), + lignes centrales à part. À valider vs budget banque 16 Ko (déjà : patterns 4,5 Ko + buffers 15,8 Ko + Road_lines 17,7 Ko).
- **Cycles** : **rapides** (pas de calcul sous-pixel runtime, juste index sprite + copie) — potentiellement < A pour les bords.
- **Risque** : élevé (génération sprites dans les tools + refonte draw + budget mémoire serré).

---

## 5. Grass fill — méthode (commun A/B/C)

Le grass est uniforme. **Ne pas régresser** : le KJM actuel a le grass **déroulé** (rapide). Donc :

| Méthode | Cycles | Mémoire | Note |
|---------|--------|---------|------|
| Boucle `pshu d,x` + dec/bne | ~9 + ~5 / 4 o = **3,5 cyc/o** | minime | overhead boucle |
| **Ladder déroulé + jump-in** (style 68k) | **~2,25 cyc/o** (`pshu d,x`, pas d'overhead) | ~14 o (séquence max) + calc entrée | **recommandé** : `ldd/ldx #grass` une fois, `pshu d,x ×N`, entrée = max−N |
| `pshu d,x,y` (6 o/instr) | ~1,83 cyc/o | idem | + rapide mais granularité 6 o ≠ chunk 4 o (désaligne le bord) |

→ **Ladder grass déroulé en `pshu d,x` (4 o, aligné chunk), jump-in par nb de chunks.** Remplace les 66 préambules/postludes KJM par **1** séquence partagée. Gain mémoire + cycles neutres. À l'horizon (grass large ~33 o/passe) c'est le poste dominant → le déroulé compte.

---

## 6. Synthèse comparative

| | Centre lisse (G1) | Bords sous-pixel | Lignes blanches | Mémoire Δ | Cycles Δ/frame | Risque |
|---|---|---|---|---|---|---|
| **Actuel** | ✗ (zigzag) | partiel | bakées ✓ | — | — | — |
| **A** ancrage centre | ✓ | ±4 px | bakées ✓ | **−** (gain) | ~0 | faible |
| **B** bords découplés | ✓ | exact | **à redessiner** | + modéré | +~19 k | moyen-élevé |
| **C** edge-sprites | ✓ | exact | sprites ✓ | **++** | ~0/− | élevé |

*(G2 — largeur horizon — non résolu par A/B/C ; nécessite buffers plus fins, séparément.)*

---

## 7. Recommandation (à discuter)

1. **Solution A en premier** : meilleur ratio fidélité/coût. Supprime le zigzag (centre continu = méthode 68k), garde le contenu baké (lignes/rumble/dither), **drop KJM**, mémoire en gain, cycles neutres, risque faible. Le résiduel = ±4 px symétrique aux bords + G2.
2. **Mesurer A avec l'oracle bitmap** (`render_road_frame.py`) avant tout ASM : implémenter A dans le rendu sim, comparer à la référence validée. Si ±4 px acceptable → porter.
3. Si ±4 px insuffisant **et** budget mémoire OK → **Solution C** (fidélité 68k totale, lignes dans les sprites) plutôt que B (B perd les lignes et coûte des cycles à les refaire).
4. **G2 (horizon trop large)** : traiter en parallèle via granularité buffer (demi-chunks ou plus de niveaux), indépendamment du choix A/B/C.

**Question ouverte clé** : tolère-t-on ±4 px symétrique aux bords (⇒ A, peu coûteux) ou exige-t-on le sous-pixel exact des deux bords (⇒ C, gros, mémoire) ? Et G2 (largeur horizon) : priorité ou plus tard ?
