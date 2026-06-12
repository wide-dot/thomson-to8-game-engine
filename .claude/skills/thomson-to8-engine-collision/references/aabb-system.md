# AABB — système de collision objet-objet

L'**AABB** (Axis-Aligned Bounding Box) est une boîte rectangulaire alignée sur les axes X et Y utilisée pour détecter les collisions entre objets. L'engine utilise la représentation **center-radius** : centre + demi-largeur/demi-hauteur.

## Structure de l'AABB (9 octets)

```asm
AABB struct
p       rmb   1                         ; potential (1 octet)
rx      rmb   1                         ; radius X
ry      rmb   1                         ; radius Y
cx      rmb   1                         ; center X (à l'écran)
cy      rmb   1                         ; center Y
prev    rmb   2                         ; chaînage précédent
next    rmb   2                         ; chaînage suivant
 endstruct                              ; total = 9 octets
```

Convention d'inclusion :
```asm
        INCLUDE "./engine/collision/struct_AABB.equ"

; Dans ext_variables de l'objet
AABB_0  equ ext_variables               ; 9 octets
```

`AABB.p`, `AABB.rx`, ... sont des **offsets** dans la struct, à utiliser avec un offset de base.

## Le système de potential

Le champ `p` (1 octet signé) sert d'**HP de la hitbox** :

```
Valeur          | Sémantique
----------------|---------------------------------------------------
-128 à -1       | Invincible — potential ne change jamais
0               | Désactivée — pas de collision détectée
1 à 126         | HP — décrémenté à chaque collision (min 0)
127             | Weak — désactivée après 1 seule collision
```

### Sémantique du décrément

Quand `Collision_Do` détecte une collision entre A et B :
- Si `A.p > 0` et `A.p < 128` : `A.p -= 1`
- Si `B.p > 0` et `B.p < 128` : `B.p -= 1`
- Si `A.p = -1..-128` : aucun changement (invincible)
- Si `A.p = 127` : `A.p = 0` (désactivation)

Quand `p = 0`, l'AABB est skipée par les tests suivants (cf. `beq @skipu` dans Collision_Do).

### Exemples de configuration

```asm
; Joueur invincible (frames d'invincibilité après touche)
        lda   #-1
        sta   AABB_0+AABB.p,u

; Ennemi avec 3 HP
        lda   #3
        sta   AABB_0+AABB.p,u

; Projectile qui se détruit au 1er impact
        lda   #127                      ; weak
        sta   AABB_0+AABB.p,u

; Bonus déjà ramassé (désactivé)
        clr   AABB_0+AABB.p,u
```

## Coord center-radius

```
AABB couvre [cx - rx, cx + rx] × [cy - ry, cy + ry]
```

Exemples :
- `cx=80, cy=100, rx=4, ry=8` → box de 9×17 pixels centrée en (80,100)
- `cx=160, cy=100, rx=8, ry=4` → box de 17×9 pixels

> **Mise à jour de cx/cy** : le moteur les met à jour automatiquement à `DisplaySprite` (à partir de `x_pos`/`y_pos`/`x_pixel`/`y_pixel`). Ne pas écrire `cx`/`cy` manuellement sauf cas particulier.

## Algorithme `Collision_Do`

```asm
Collision_Do
        ldu   #0                        ; auto-modif : adresse head liste 1
Collision_Do_1 equ *-2
        beq   @rts
@loopu  ldb   AABB.p,u
        beq   @skipu                    ; potential = 0 → skip
        ldx   #0                        ; auto-modif : adresse head liste 2
Collision_Do_2 equ *-2
        beq   @rts
@loopx  ldb   AABB.p,x
        beq   @skipx
        
        ; Test collision X
        lda   AABB.rx,u
        adda  AABB.rx,x                 ; A = rx_u + rx_x
        asla                            ; A = 2*(rx_u + rx_x)
        sta   @rx                       ; auto-modif l'opérande de cmp
        asra                            ; A = rx_u + rx_x (récupère)
        adda  AABB.cx,u                 ; A = cx_u + (rx_u+rx_x) (= max boundary)
        suba  AABB.cx,x                 ; A = (cx_u + rx_u + rx_x) - cx_x
        cmpa  #0                        ; (modif par @rx)
@rx     equ *-1
        bhi   @continue                 ; pas de collision X
        
        ; Test collision Y (idem)
        ; ...
        
        ; COLLISION
        ; décrément A.p, B.p (si dans range 1-126)
        ; ...

@continue
        ldx   AABB.next,x
        bne   @loopx
        ; ... boucle U ...
```

Mathématiquement, la collision X est :
```
|cx_u - cx_x| < rx_u + rx_x
```

Le code utilise une astuce : `(rx_u + rx_x)*2` permet de tester en signed avec `cmpa #0` après ajustement signé.

### Complexité

O(N × M) où N et M sont les tailles des deux listes. Pour deux listes de 10 AABBs : 100 paires testées.

À 50 Hz, cycle budget par paire : 20000/100 = 200 cycles → largement suffisant (le test fait ~30 cycles).

Pour 50 AABBs par liste : 2500 paires × 30 cycles = 75000 cycles → ne tient pas en 1 frame.

**Mitigation** : segmenter en sous-listes (ex: ennemis proches de la caméra vs distants), prioritiser certaines paires.

## Chaînage doublement lié

Chaque AABB a `prev` et `next` (2 octets chacun). Une liste typée a un head et un tail :

```
AABB_list_player : [head, tail]
   head ──→ AABB_A
              prev = 0
              next ──→ AABB_B
                        prev ──→ AABB_A
                        next = 0
                        ←─── tail
```

`Collision_AddAABB` insère en queue. `Collision_RemoveAABB` délink l'AABB.

## Macro `_Collision_AddAABB`

```asm
_Collision_AddAABB MACRO
        pshs  u,x,y
        leax  \1,u                      ; X = adresse de l'AABB
        ldy   #\2                       ; Y = adresse de la liste
        jsr   Collision_AddAABB
        puls  u,x,y
 ENDM
```

Préserve `u`, `x`, `y`. La routine `Collision_AddAABB` insère X dans la liste Y.

## Macro `_Collision_RemoveAABB`

Plus complexe car la routine modifie des adresses auto-modifiées :
```asm
_Collision_RemoveAABB MACRO
        pshs  d,u,x,y
        ldx   #\2
        stx   Collision_Remove_1        ; adresse head pour cas @noPrev
        stx   Collision_Remove_3        ; idem
        leax  2,x
        stx   Collision_Remove_2        ; adresse tail
        leax  \1,u
        jsr   Collision_RemoveAABB
        puls  d,u,x,y
 ENDM
```

C'est un peu intrusif (modification de mémoire engine) mais permet de gérer head/tail dynamiquement.

## Patterns multi-AABBs

Un objet peut avoir plusieurs AABBs (corps + tête + pied) :

```asm
AABB_body     equ ext_variables
AABB_head     equ ext_variables+9
AABB_feet     equ ext_variables+18

Init
        lda   #1
        sta   AABB_body+AABB.p,u
        sta   AABB_head+AABB.p,u
        sta   AABB_feet+AABB.p,u
        ; rayons différents par AABB
        ; ...
        _Collision_AddAABB AABB_body,AABB_list_enemy
        _Collision_AddAABB AABB_head,AABB_list_enemy_crit
        _Collision_AddAABB AABB_feet,AABB_list_enemy_slide
        inc   routine,u
```

Pré-requis : `ext_variables_size >= 27`.

## Décalage cx/cy par rapport à xy_pixel

Par défaut, `cx = x_pixel` et `cy = y_pixel` (ou conversion depuis x_pos/y_pos). Si on veut une AABB **décalée** par rapport au centre du sprite, il faut écrire `cx`/`cy` manuellement après chaque mise à jour engine :

```asm
        ; Hitbox de la tête, 8 pixels au-dessus du centre sprite
        lda   x_pixel,u
        sta   AABB_head+AABB.cx,u
        lda   y_pixel,u
        suba  #8
        sta   AABB_head+AABB.cy,u
```

À faire **après** `DisplaySprite` (qui a mis à jour `x_pixel`/`y_pixel`) et **avant** `_Collision_Do`.

## Pitfalls

- **`ext_variables_size < 9`** : la struct AABB déborde sur `rsv_*` → corruption
- **Add sans Remove préalable** : double-link, la liste devient cyclique
- **Remove sans CleanLinks puis Add dans une autre liste** : prev/next pointent vers la liste précédente → corruption
- **Modifier `cx,cy` après DisplaySprite** : valide pour décalage, mais penser à le refaire chaque frame
- **Plusieurs AABBs dans la même liste** : possible mais attention à l'auto-collision (`Collision_Do A,A`)
- **Potential signed mal géré** : oublier que -1 = invincible, pas « -1 HP »
- **`Collision_Do` avant que DisplaySprite ait mis à jour cx/cy** : collision basée sur l'ancienne frame
- **AABB sur objet caché (`render_hide_mask`)** : si cx/cy ne sont plus mis à jour, la collision reste à l'ancienne position
