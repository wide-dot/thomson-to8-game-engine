---
name: thomson-to8-engine-collision
description: "Décrit le système de collision du Thomson TO8/TO9 game engine (Bento8/wide-dot) : système AABB (Axis-Aligned Bounding Box) avec macros _Collision_AddAABB / _Collision_RemoveAABB / _Collision_CleanLinksAABB / _Collision_Do / _Collision_AddAABB_x, structure AABB (potential p, radius rx/ry, center cx/cy, chaînage prev/next — 9 octets), listes typées AABB_list_friend / AABB_list_enemy / AABB_list_player / AABB_list_bonus / AABB_list_foefire / AABB_list_forcepod, déclaration dans ram-data.asm via AABB_lists / AABB_endLists, routines Collision_AddAABB / Collision_RemoveAABB / Collision_Do (test all-pairs entre 2 listes), calcul de collision en center-radius (distance abs centre vs somme rayons), système de potentiel (hitbox invincible -128 à -1, désactivée 0, normale 1-126, weak 127), système terrainCollision pour shoot'em up r-type (init via _terrainCollision.init avec page+address dynamique, terrainCollision.do, terrainCollision.xAxis.doRight/doLeft, terrainCollision.update, terrainCollision.sensor.x/y, terrainCollision.impact.x), pattern de placement de la routine de collision dans MainLoop (entre RunObjects et CheckSpritesRefresh), AABB sur ext_variables_size>=9 dans ram-data.asm. Utiliser pour gérer des collisions entre joueur/ennemis/projectiles, implémenter un système de potentiel HP, organiser les listes de collision par type, configurer une AABB sur un objet, gérer les collisions terrain pour un shoot'em up, choisir entre AABB et terrainCollision. Mots-clés : AABB, AABB_struct, AABB.p, AABB.rx, AABB.ry, AABB.cx, AABB.cy, AABB.prev, AABB.next, _Collision_AddAABB, _Collision_AddAABB_x, _Collision_RemoveAABB, _Collision_CleanLinksAABB, _Collision_Do, Collision_AddAABB, Collision_RemoveAABB, Collision_Do, Collision_Remove_1, Collision_Remove_2, Collision_Remove_3, Collision_Do_1, Collision_Do_2, AABB_list_friend, AABB_list_enemy, AABB_list_ennemy, AABB_list_player, AABB_list_bonus, AABB_list_foefire, AABB_list_forcepod, AABB_list_bubble, AABB_lists, AABB_endLists, AABB_lists.nb, ext_variables, struct_AABB.equ, potential hitbox, center-radius, terrainCollision, terrainCollision.do, terrainCollision.xAxis.doRight, terrainCollision.xAxis.doLeft, terrainCollision.update, terrainCollision.sensor.x, terrainCollision.sensor.y, terrainCollision.impact.x, _terrainCollision.init, terrainCollision.main.page, terrainCollision.main.address, room.checkSolid, hitbox, shoot'em up, plateformer, axis-aligned bounding box, doubly linked list."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Collision — Thomson TO8/TO9 Game Engine

Le système de collision repose sur deux mécanismes complémentaires :

1. **AABB** (Axis-Aligned Bounding Box) — collision entre **objets** via boîtes englobantes alignées, organisées en listes typées
2. **terrainCollision** — collision avec un **terrain statique** (cf. r-type pour les murs et sols de niveau)

Ce skill couvre les deux mécanismes.

---

## Vue d'ensemble — AABB

```
Objet A avec AABB_0 (rx=4, ry=8) dans ext_variables
Objet B avec AABB_0 (rx=6, ry=6) dans ext_variables

Liste AABB_list_player ──→ A
Liste AABB_list_enemy  ──→ B

_Collision_Do AABB_list_player, AABB_list_enemy
   → teste toutes les paires (cross-product)
   → pour chaque paire : 
     - |cx_A - cx_B| < rx_A + rx_B ?
     - |cy_A - cy_B| < ry_A + ry_B ?
     - Si oui : collision → décrement de potential
```

---

## Structure `AABB` (9 octets)

```asm
AABB struct
p       rmb   1                         ; potential (hitbox HP)
rx      rmb   1                         ; radius X (demi-largeur)
ry      rmb   1                         ; radius Y (demi-hauteur)
cx      rmb   1                         ; center X (à l'écran ou playfield)
cy      rmb   1                         ; center Y
prev    rmb   2                         ; chaînage liste (engine)
next    rmb   2                         ; chaînage liste (engine)
 endstruct
```

Total : 9 octets dans `ext_variables`.

### Potential

| Valeur | Sémantique |
|--------|------------|
| -128 à -1 | Invincible (potential ne change jamais) |
| 0 | Hitbox désactivée (pas de collision) |
| 1 à 126 | HP restants (décrémenté à chaque collision) |
| 127 | Weak hitbox (désactivée immédiatement à la 1ère collision) |

```asm
        lda   #-1                       ; hitbox invincible
        sta   AABB_0+AABB.p,u
        
        ; OU
        lda   #5                        ; hitbox avec 5 HP
        sta   AABB_0+AABB.p,u
```

### Coordonnées center-radius

L'AABB est définie par **centre + rayons** :
- `cx`, `cy` : centre (en pixels, **mis à jour par le moteur** à partir de `x_pos`/`y_pos` via le rendering)
- `rx`, `ry` : rayons (demi-largeur, demi-hauteur)

La box couvre `[cx-rx, cx+rx]` × `[cy-ry, cy+ry]`.

> **Important** : `cx`/`cy` sont en **coord écran** (1 octet), mis à jour pendant le rendu (DrawSprites/CheckSpritesRefresh). Pour que les collisions soient cohérentes avec l'affichage, le test doit être appelé **après** RunObjects et **avant** EraseSprites/DrawSprites (cf. position dans MainLoop).

---

## Listes typées

Déclarées dans `ram-data.asm` :

```asm
AABB_lists.nb                 equ   (AABB_endLists-AABB_lists)/2
AABB_lists
AABB_list_player              fdb   0,0
AABB_list_enemy               fdb   0,0
AABB_list_bonus               fdb   0,0
AABB_list_foefire             fdb   0,0
AABB_list_forcepod            fdb   0,0
AABB_endLists
```

Chaque liste = `fdb 0,0` (2 mots = head + tail des chaînages doublement liés). Le bloc `AABB_lists` à `AABB_endLists` permet à l'engine de connaître le nombre de listes.

Convention : noms `AABB_list_<type>` pour clarifier le rôle. Le rôle exact (qui attaque qui) est applicatif.

---

## Macros pour le code utilisateur

### `_Collision_AddAABB`

```asm
        _Collision_AddAABB AABB_0,AABB_list_player
```

Inscrit l'AABB de l'objet courant (`u`) dans la liste. Le moteur prend `u + AABB_0` comme adresse de la struct AABB.

À appeler dans `Init` :
```asm
Init
        lda   #-1                       ; potential infini
        sta   AABB_0+AABB.p,u
        _ldd  4,8                       ; rx=4, ry=8
        std   AABB_0+AABB.rx,u
        _Collision_AddAABB AABB_0,AABB_list_player
        inc   routine,u
```

### `_Collision_AddAABB_x`

Version avec `x` au lieu de `u`. Utile depuis une routine qui a déjà besoin de `u`.

### `_Collision_RemoveAABB`

```asm
        _Collision_RemoveAABB AABB_0,AABB_list_player
```

Retire l'AABB de la liste. À appeler avant `UnloadObject_u` ou avant de basculer dans une autre liste.

### `_Collision_CleanLinksAABB`

```asm
        _Collision_CleanLinksAABB AABB_0
```

Reset `prev` et `next` à 0. **Obligatoire** entre un Remove et un Add (pour passer d'une liste à une autre) :

```asm
        ; Joueur passe de mode normal à invincible :
        _Collision_RemoveAABB AABB_0,AABB_list_player
        _Collision_CleanLinksAABB AABB_0
        _Collision_AddAABB AABB_0,AABB_list_player_invincible
```

### `_Collision_Do`

```asm
        _Collision_Do AABB_list_player,AABB_list_enemy
```

Teste **toutes les paires** entre les deux listes. Pour chaque paire en collision :
- Décrémente le potential des deux AABBs (-1 chacun)
- Si potential atteint 0 : hitbox désactivée

À appeler depuis MainLoop, **après** RunObjects (qui a mis à jour cx/cy via DisplaySprite).

---

## Algorithme `Collision_Do`

```asm
Collision_Do
        ldu   #0                        ; (auto-modif par macro : adresse liste 1)
Collision_Do_1 equ *-2
        beq   @rts                      ; liste vide → fin
@loopu  ldb   AABB.p,u
        beq   @skipu                    ; potential = 0 → skip
        ldx   #0
Collision_Do_2 equ *-2                  ; (adresse liste 2)
        beq   @rts
@loopx  ldb   AABB.p,x
        beq   @skipx
        
        ; calcul collision
        lda   AABB.rx,u
        adda  AABB.rx,x                 ; somme des rayons X
        asla
        sta   @rx
        asra
        adda  AABB.cx,u
        suba  AABB.cx,x
        cmpa  #0
@rx     equ *-1
        bhi   @continue                 ; |dx| > sum_rx → pas de col
        
        lda   AABB.ry,u
        adda  AABB.ry,x
        asla
        sta   @ry
        asra
        adda  AABB.cy,u
        suba  AABB.cy,x
        cmpa  #0
@ry     equ *-1
        bhi   @continue                 ; |dy| > sum_ry → pas de col
        
        ; COLLISION DÉTECTÉE
        ; décrémenter les potentiels
        ; ...
```

Complexité : O(N×M) où N et M = tailles des listes. Pour ~10 objets par liste, ~100 comparaisons = quelques centaines de cycles. OK pour 50 Hz.

---

## terrainCollision — collision avec un terrain

Système plus complexe utilisé par r-type pour les collisions avec les murs/sols du niveau.

### Macro d'init

```asm
        _terrainCollision.init ObjID_collision
```

Charge la page et l'adresse de l'objet `ObjID_collision` (qui contient les données du terrain) dans des variables auto-modifiées :
- `terrainCollision.main.page` / `.address` → routine principale
- `terrainCollision.main.xAxis.doRight.page` / `.address` → check à droite (+3 dans la table)
- `terrainCollision.main.xAxis.doLeft.page` / `.address` → check à gauche (+6)
- `terrainCollision.main.update.page` / `.address` → update (+9)

L'objet `collision` exporte donc **4 entry points** consécutifs (espacés de 3 octets), accessibles via les routines wrapper.

### Routines wrapper

```asm
terrainCollision.do                     ; check vertical (sol/plafond)
        _GetCartPageA
        sta   @page
        lda   #0                        ; (modifié par init)
terrainCollision.main.page equ *-1
        _SetCartPageA
        jsr   >0                        ; (modifié par init)
terrainCollision.main.address equ *-2
        ; restore page
        rts

terrainCollision.xAxis.doRight          ; check à droite
terrainCollision.xAxis.doLeft           ; check à gauche
terrainCollision.update                 ; update lookup tables
```

Pattern d'usage :
```asm
        ; Avant de bouger l'objet, on vérifie qu'il peut
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        jsr   terrainCollision.do
        lda   terrainCollision.impact.x
        bne   @blocked
        ; ... peut bouger ...
@blocked
```

Voir [references/terrain-collision.md](references/terrain-collision.md).

---

## Pattern d'utilisation typique (shoot'em up)

```asm
; Init objet ennemi
Init
        lda   #1                        ; HP de l'ennemi
        sta   AABB_0+AABB.p,u
        _ldd  8,8                       ; rx=8, ry=8
        std   AABB_0+AABB.rx,u
        _Collision_AddAABB AABB_0,AABB_list_enemy
        inc   routine,u

; MainLoop du game-mode
MainLoop
        jsr   RunObjects                ; objets bougent, cx/cy mis à jour à DisplaySprite
        _Collision_Do AABB_list_player,AABB_list_enemy
        _Collision_Do AABB_list_friend_fire,AABB_list_enemy
        _Collision_Do AABB_list_player,AABB_list_foefire
        ; ... autres paires ...
        jsr   CheckSpritesRefresh
        ; ... rendu ...
```

---

## Pattern d'utilisation typique (plateformer)

```asm
; Player vs enemies (touche)
_Collision_Do AABB_list_player,AABB_list_enemy

; Player vs bonus (collecte)
_Collision_Do AABB_list_player,AABB_list_bonus

; Plus terrain collision pour le sol/murs (cf. terrainCollision)
```

---

## Patterns avancés

### Hitbox temporellement active

```asm
; Lors d'une attaque, activer une hitbox
        lda   #1                        ; potential 1 (weak, à 1 hit)
        sta   AABB_attack+AABB.p,u
        ; ... 30 frames plus tard ...
        lda   #0                        ; désactiver
        sta   AABB_attack+AABB.p,u
```

### Plusieurs AABBs par objet

```asm
AABB_0     equ ext_variables             ; corps
AABB_1     equ ext_variables+9           ; tête (zone critique)
AABB_2     equ ext_variables+18          ; pied (slide)
```

Pré-requis : `ext_variables_size >= 27`. Chaque AABB peut être dans une liste différente.

---

## Pitfalls

- **Ajouter une AABB sans nettoyer prev/next d'un précédent usage** : corruption de la liste précédente
- **`ext_variables_size < 9`** : AABB déborde sur `rsv_*` → corruption
- **Modifier `cx,cy` manuellement** : le moteur les met à jour à `DisplaySprite`, override possible mais à éviter
- **Tester collision avant RunObjects** : `cx`/`cy` pas encore mis à jour pour la frame courante
- **Tester collision après EraseSprites** : OK, mais le pattern conventionnel est avant
- **Liste avec head=0 mais des AABBs encore référencées** : crash
- **Potential = 127** (weak) : désactive à la 1ère collision même si la cible aurait pu prendre plus
- **`_Collision_Do` sur la même liste** : possible (auto-collision), mais doit gérer le cas A=B (skip soi-même)
- **Boîte plus grande que sprite** : collision déclenchée hors zone visible (peut être voulu pour gameplay)
- **terrainCollision avec objet `collision` non chargé** : crash (page pas mountable)

---

## Références détaillées

- [references/aabb-system.md](references/aabb-system.md) — Structure AABB détaillée (9 octets : p/rx/ry/cx/cy/prev/next), système de potentiel, algorithme `Collision_Do` complet (center-radius, complexity O(N×M)), patterns hitbox temporaire, plusieurs AABBs par objet, intégration avec cx/cy mis à jour par DisplaySprite
- [references/aabb-lists.md](references/aabb-lists.md) — Listes typées AABB_list_<type>, déclaration dans ram-data.asm avec AABB_lists/AABB_endLists, conventions de nommage (friend/enemy/player/bonus/foefire), passage d'une liste à l'autre (Remove + CleanLinks + Add), choix des listes selon le genre de jeu
- [references/terrain-collision.md](references/terrain-collision.md) — terrainCollision système complet (r-type) : objet `collision` avec 4 entry points (do/doRight/doLeft/update), `_terrainCollision.init` macro, variables sensor.x/sensor.y/impact.x, lookup tables de terrain, integration avec scroll horizontal, comparaison avec AABB pour terrain statique
- [references/collision-patterns.md](references/collision-patterns.md) — Patterns par genre : shoot'em up (player vs enemy vs foefire), plateformer (player vs platform vs bonus), beat'em up (multiples hitbox attack/body), interaction avec scoring, animation de hit (clignotement via render_flags)
