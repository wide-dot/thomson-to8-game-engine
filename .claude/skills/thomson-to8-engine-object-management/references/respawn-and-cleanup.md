# Marquer un objet hors-écran — `MarkObjGone` / `Object_Respawn_Table`

Les routines `MarkObjGone*` permettent de supprimer automatiquement un objet quand il sort de la zone autour de la caméra, **tout en mémorisant qu'il a été supprimé** afin de pouvoir le re-spawner si la caméra revient sur sa position d'origine.

## `Object_Respawn_Table` — table globale

```asm
Object_Respawn_Table
Obj_respawn_index    fdb    0           ; indices des prochains objets pour movement L/R
Obj_respawn_data     fill   0,$7C       ; max d'entrées (124 paires)
Obj_respawn_data_End
```

Format : table de paires `(2 octets index + 1 octet flag)` (3 octets par entrée, max 124 entrées). Le bit 7 du flag est mis à 1 quand l'objet est « live » (spawné), 0 quand il a été marqué supprimé et peut respawn.

Chaque objet a un champ `respawn_index,u` (typiquement dans `ext_variables`) qui pointe vers son entrée dans la table. À noter : ce champ doit être déclaré dans le projet — il n'a pas d'offset standard dans `engine/constants.asm`.

## `MarkObjGone` — version standard

```asm
MarkObjGone
        ldd   x_pos,u                   ; position playfield X
MarkObjGone2
        andb  #$C0                      ; wide-dot factor (align sur 64 pixels)
        subd  glb_camera_x_pos_coarse   ; relative à caméra
        cmpd  #$40+160+$20+$40          ; $E0 = limite hors écran
        bhi   >                         ; > limite → supprimer
        jmp   DisplaySprite             ; toujours dans la zone → afficher

!       ldx   #Object_Respawn_Table
        ldb   respawn_index,u           ; entry dans la table
        beq   >                         ; pas d'entrée respawn → skip
        addb  #2                        ; offset vers le flag
        lda   b,x
        anda  #%01111111                ; clear bit 7 (mark as despawnable)
        sta   b,x
!       jmp   DeleteObject
```

Sémantique :
- Si l'objet est dans la zone autour de la caméra (`x_pos ≤ camera + 320 px env.`), appeler `DisplaySprite`
- Sinon : nettoyer son entrée respawn (clear bit 7) et appeler `DeleteObject` (= unload + erase)

Le `wide-dot factor` (`andb #$C0`) aligne sur 64 pixels — c'est lié à la résolution effective du TO8 en mode wide-dot (160 colonnes).

## `MarkObjGone2`

Variante qui prend la position dans `D` plutôt que via `x_pos,u`. Utile si on a déjà calculé une position modifiée :

```asm
        ldd   computed_x_pos
        jsr   MarkObjGone2              ; D = position à comparer
```

## `MarkObjGone3`

Différence : si l'objet est encore dans la zone, fait **`rts`** au lieu de `DisplaySprite`. Utile quand on a déjà affiché l'objet plus tôt dans la routine.

```asm
        ; ... logique ...
        jsr   DisplaySprite             ; on affiche déjà
        ; ... autre logique ...
        jmp   MarkObjGone3              ; check unload seulement (sans réafficher)
```

## Le wide-dot factor expliqué

```asm
cmpd  #$40+160+$20+$40
```

- `160` = largeur visible en pixels (mode 160x200 BM16)
- `$40` à gauche = marge avant la caméra (64 pixels)
- `$20` à droite = round-up de 160 sur multiple de 64
- `$40` supplémentaire = marge après la caméra

Total $E0 = 224 pixels de tolérance autour de la caméra avant de supprimer l'objet.

> **Note** : la version asm du repo a `wide-dot factor` (factor 64 = `$C0` mask) car le TO8 utilise un mode 160 pixels où chaque pixel est 2 pixels physiques (wide-dot). En mode 80 colonnes ou autre, ajuster.

## Système respawn — flux complet

```
1. Niveau démarre, ObjectWave crée des ennemis aux frames prédéfinies
   → chaque ennemi a un respawn_index unique pointant dans Object_Respawn_Table
   → bit 7 = 1 (live)

2. Joueur progresse, certains ennemis sortent par la gauche
   → MarkObjGone détecte, clear bit 7, DeleteObject

3. Joueur fait demi-tour, la caméra revient sur la zone
   → ObjectWave (en re-scrolling arrière) check le bit 7
   → bit 7 = 0 → respawn l'objet (re-LoadObject_u)
   → bit 7 = 1 (live à nouveau)

4. Joueur tue l'ennemi (game logic)
   → KillObject met bit 7 à 1 ET ajoute un flag « killed » dans la table
   → l'objet ne respawn plus, même si la caméra revient
```

## Object_Respawn_Table — entrées

Format d'une entrée (3 octets) :
```
Offset | Taille | Contenu
-------|--------|--------
0      | 2      | (réservé pour index ou pointeur)
2      | 1      | flags
              bit 7 = 1 si live (spawné)
              bit 7 = 0 si peut respawn
              autres bits = libre pour usage applicatif
```

Le code engine ne touche que le bit 7. Les autres bits sont à disposition du jeu (e.g. bit 6 = « killed définitivement »).

## Intégration avec `ObjectWave`

`ObjectWave` (ou `objectWave.do`) parcourt le script de spawn. Pour chaque entrée :
- Lit le timestamp et compare à `gfxlock.frame.count`
- Si timestamp atteint, alloue l'objet
- **Si l'objet a un `respawn_index`**, set le bit 7 dans la table

Quand `MarkObjGone` est appelé, l'objet est supprimé mais le bit 7 est claré → si on revient sur la zone, `ObjectWave` détectera l'entrée non-live et re-spawnera.

## Pitfalls

- **`respawn_index` non initialisé** : `MarkObjGone` skip le clear de bit 7 (cf. `beq` après `ldb respawn_index,u`), pas grave mais l'objet ne pourra pas respawn
- **Wide-dot factor incorrect** pour le mode graphique utilisé : utiliser `$C0` (64 pixels) en mode 160 pixels, `$F8` (8 pixels) en mode 320 pixels (ajuster `andb`)
- **Limite hors écran** trop serrée : objets supprimés trop tôt (avant de sortir visuellement). Augmenter le `cmpd #...` si nécessaire (au prix de plus d'objets actifs)
- **Confusion avec `render_todelete_mask`** : `MarkObjGone` appelle `DeleteObject` (= unload+erase). Pas besoin de poser `render_todelete_mask` en plus
- **`Object_Respawn_Table` placée sur une page paginable** : doit être en zone résidente (page 1) ou explicitement mountée. Sinon `MarkObjGone` lit/écrit sur une page random
- **`MarkObjGone` appelé sur un objet sans sprite** (priority=0) : `DisplaySprite` ne fait rien, mais le check de zone reste utile. OK.

## Pattern d'usage

```asm
; Objet ennemi typique
Ennemi
        lda   routine,u
        ; ...

Main
        ; ... logique ...
        jsr   ObjectMoveSync
        jsr   AnimateSprite
        jmp   MarkObjGone               ; au lieu de jmp DisplaySprite
                                        ; → display si visible, delete sinon
```

C'est le pattern standard pour les ennemis qui peuvent sortir/rentrer de l'écran (shoot 'em up à scrolling).
