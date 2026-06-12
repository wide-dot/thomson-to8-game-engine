# Listes typées d'AABB

Pour organiser les tests de collision, l'engine permet de regrouper les AABBs en **listes typées**. Chaque test `_Collision_Do A,B` croise toutes les paires entre 2 listes.

## Déclaration dans `ram-data.asm`

```asm
* ===========================================================================
* Collision lists
* ===========================================================================
AABB_lists.nb                 equ   (AABB_endLists-AABB_lists)/2
AABB_lists
AABB_list_player              fdb   0,0       ; head, tail
AABB_list_enemy               fdb   0,0
AABB_list_bonus               fdb   0,0
AABB_list_foefire             fdb   0,0
AABB_list_forcepod            fdb   0,0
AABB_endLists
```

Chaque liste = `fdb 0,0` (2 mots = head + tail des chaînages doublement liés).

Le bloc `AABB_lists` → `AABB_endLists` permet de calculer `AABB_lists.nb` (nombre de listes), utilisé par certaines routines de cleanup pour itérer sur toutes les listes (e.g. clear all à la transition de game-mode).

## Conventions de nommage par genre

### Shoot'em up (cf. r-type)

```asm
AABB_list_friend              fdb   0,0       ; entités amies (joueur, allié)
AABB_list_enemy               fdb   0,0       ; entités ennemies (avions, ennemis)
AABB_list_enemy_unkillable    fdb   0,0       ; ennemis qui font des dégâts mais sont invincibles (e.g. boss en charge)
AABB_list_player              fdb   0,0       ; spécifique au joueur (zone critique)
AABB_list_bonus               fdb   0,0       ; objets à collecter
AABB_list_foefire             fdb   0,0       ; projectiles ennemis (font des dégâts au joueur)
AABB_list_forcepod            fdb   0,0       ; le pod du joueur (peut bloquer les balles)
```

Paires testées :
```asm
        _Collision_Do AABB_list_player,AABB_list_foefire   ; joueur prend les tirs ennemis
        _Collision_Do AABB_list_friend_fire,AABB_list_enemy ; tirs joueur sur ennemis
        _Collision_Do AABB_list_player,AABB_list_enemy     ; collision physique
        _Collision_Do AABB_list_player,AABB_list_bonus     ; collecte
        _Collision_Do AABB_list_forcepod,AABB_list_foefire ; pod bloque les tirs
```

### Plateformer (cf. bubble-bobble)

```asm
AABB_list_player              fdb   0,0
AABB_list_bubble              fdb   0,0       ; les bulles (de bubble-bobble)
```

Paires simples :
```asm
        _Collision_Do AABB_list_player,AABB_list_bubble    ; le joueur monte sur les bulles
```

### Beat'em up / fighting

```asm
AABB_list_player_body         fdb   0,0       ; corps du joueur (peut être touché)
AABB_list_player_attack       fdb   0,0       ; hitbox d'attaque (temporaire)
AABB_list_enemy_body          fdb   0,0
AABB_list_enemy_attack        fdb   0,0
```

Paires :
```asm
        _Collision_Do AABB_list_player_attack,AABB_list_enemy_body  ; joueur tape ennemi
        _Collision_Do AABB_list_enemy_attack,AABB_list_player_body  ; ennemi tape joueur
```

## Passage d'une liste à l'autre

Cas typique : joueur normal → invincible (post-touche). Il faut :
1. Retirer l'AABB de l'ancienne liste
2. Nettoyer les liens (CleanLinks)
3. Ajouter à la nouvelle liste

```asm
        _Collision_RemoveAABB AABB_0,AABB_list_player
        _Collision_CleanLinksAABB AABB_0
        _Collision_AddAABB AABB_0,AABB_list_player_invincible
```

> **Oublier `CleanLinks`** est l'erreur classique → corruption (les prev/next pointent vers l'ancienne liste).

## Configuration du potential par liste

Une convention pratique : configurer le potential selon le type de liste :

| Liste | Potential typique |
|-------|-------------------|
| `AABB_list_player` | 1-5 (HP du joueur) |
| `AABB_list_player_invincible` | -1 (invincible) |
| `AABB_list_enemy` | 1-10 (HP des ennemis) |
| `AABB_list_enemy_unkillable` | -128 (invincible mais fait des dégâts) |
| `AABB_list_foefire` | 127 (weak, disparaît à 1 hit) |
| `AABB_list_bonus` | 127 (weak, collecté à 1 hit) |
| `AABB_list_friend_fire` | 1-5 selon arme |

## Listes vs sub-types

Alternative aux listes multiples : utiliser **une seule liste** + le champ `subtype,u` (8 bits dans l'OST) pour différencier. Le test de collision se fait depuis la routine de l'objet :

```asm
On_Collision
        lda   subtype,u                 ; type de l'objet en collision
        ; ... logique conditionnelle ...
```

Trade-off :
- **Listes multiples** : moins de tests dans `Collision_Do` (filtrage à la source), plus rapide
- **Une liste + subtype** : flexibilité (tout objet peut interagir avec tout objet), plus lent

En pratique : utiliser des listes pour les **catégories majeures** (player/enemy/bonus), subtype pour les **variantes** dans une catégorie.

## Limites

Pas de limite hard sur le nombre de listes. Mais chaque liste = 4 octets en RAM + cycle CPU à `_Collision_Do`. Au-delà de ~10 listes, le management devient lourd.

Limite par liste : O(N) sur la complexité du test. ~50 AABBs/liste reste tenable.

## Patterns d'optimisation

### Listes spatiales

Diviser les ennemis en sous-listes selon leur position (e.g. `AABB_list_enemy_left`, `AABB_list_enemy_right`). Le joueur ne teste que celle de son côté.

### Activation conditionnelle

Mettre `p = 0` (désactivation) plutôt que retirer de la liste — la liste reste mais l'AABB est skipée par `Collision_Do`. Coûte cycles à l'iter mais évite Remove/Add coûteux.

## Pitfalls

- **Liste non-déclarée** mais référencée dans le code : symbol undefined au build
- **AABB_endLists oublié** : `AABB_lists.nb` mal calculé
- **Plusieurs AABBs sur la même AABB struct** dans plusieurs listes : corruption (warning explicite dans macros.asm : « Never use a single box in two or more lists »)
- **Liste partagée entre game-modes** : OK si déclarée dans la zone résidente, mais attention à la pagination
- **Reset de liste sans clear les AABBs** : les head/tail sont à 0 mais les objets contiennent encore des prev/next pointeurs → corruption à la prochaine Add
- **Trop de listes** : maintenance lourde, moins clair
