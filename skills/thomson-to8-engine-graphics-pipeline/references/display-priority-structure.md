# DPS — Display Priority Structure

La DPS est la structure de données qui mémorise, pour chaque niveau de priorité (1 à 8), la **liste des objets à afficher**. Chaque buffer (0 et 1 du double buffering) a sa propre DPS.

## Structure

```asm
DPS_buffer_0+buf_Tbl_Priority_First_Entry+0     ; (réservé)
DPS_buffer_0+buf_Tbl_Priority_First_Entry+2     ; priorité 1 (front)
DPS_buffer_0+buf_Tbl_Priority_First_Entry+4     ; priorité 2
DPS_buffer_0+buf_Tbl_Priority_First_Entry+6     ; priorité 3
DPS_buffer_0+buf_Tbl_Priority_First_Entry+8     ; priorité 4
DPS_buffer_0+buf_Tbl_Priority_First_Entry+10    ; priorité 5
DPS_buffer_0+buf_Tbl_Priority_First_Entry+12    ; priorité 6
DPS_buffer_0+buf_Tbl_Priority_First_Entry+14    ; priorité 7
DPS_buffer_0+buf_Tbl_Priority_First_Entry+16    ; priorité 8 (back)
```

Chaque entrée stocke un pointeur (2 octets) vers le **premier objet** de cette priorité. Les objets sont chaînés via une **liste doublement chaînée ouverte** dans des `rsv_*` fields de l'OST.

## Sémantique des priorités

| Priority | Nom | Ordre de rendu |
|----------|-----|----------------|
| 0 | (réservé, non affiché) | — |
| 1 | Front | Dessiné en **dernier** (par-dessus tout) |
| 2 | | |
| 3 | | |
| 4 | (milieu typique) | |
| 5 | | |
| 6 | | |
| 7 | | |
| 8 | Back | Dessiné en **premier** (en arrière-plan) |

## Algorithme de rendu — `DrawSprites`

Parcours **back to front** (priorité 8 → 1) pour la superposition correcte :

```asm
DrawSprites
        lda   gfxlock.backBuffer.id
        bne   DRS_P8B1
        
DRS_P8B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+16  ; prio 8
        beq   DRS_P7B0
        jsr   DRS_ProcessEachPriorityLevelB0
DRS_P7B0
        ldx   DPS_buffer_0+buf_Tbl_Priority_First_Entry+14  ; prio 7
        beq   DRS_P6B0
        jsr   DRS_ProcessEachPriorityLevelB0
        ; ... (priorités 6, 5, 4, 3, 2, 1) ...
```

Pour chaque priorité, parcourir la liste chaînée des objets et appeler la routine de draw spécifique au sprite.

## Algorithme d'effacement — `EraseSprites`

Parcours **front to back** (priorité 1 → 8) — l'inverse de DrawSprites — pour restaurer les fonds dans le bon ordre :

```
EraseSprites :
    Pour priorité 1 (front), 2, 3, ..., 8 (back) :
        Pour chaque objet de cette priorité avec flag erase :
            Restaurer le fond depuis sa cellule BBC
            Libérer la cellule
```

## `DisplaySprite` — inscription dans la DPS

Quand un objet est prêt à être affiché (typiquement en fin de `Main`), on l'inscrit dans la DPS via :

```asm
        jmp   DisplaySprite              ; U = OST, lit priority,u
```

Variantes :
```asm
        jmp   DisplaySprite_x            ; X = OST (préserve U)
        jmp   DisplaySprite2             ; (alias de DisplaySprite_x)

        jmp   DisplaySprite_priority     ; U = OST, A = priorité forcée
        jmp   DisplaySprite3             ; (alias de _priority)
```

L'objet est inséré dans la liste de la priorité indiquée par `priority,u` (ou par A si `_priority`).

## `UnsetDisplayPriority` — supprimer les sprites de la DPS

Appelée chaque frame entre `EraseSprites` et `DrawSprites` :

```asm
UnsetDisplayPriority
        lda   gfxlock.backBuffer.id
        bne   UDP_B1
UDP_B0
        ldx   #Lst_Priority_Unset_0+2

UDP_CheckEndB0
        cmpx  Lst_Priority_Unset_0       ; end of priority unset list
        ; ... délier les objets de la DPS ...
```

Parcourt `Lst_Priority_Unset_0/1` (liste des objets à délier) et les retire de la DPS. Cela arrive quand :
- `priority,u` a été mis à 0 par le code utilisateur
- L'objet a été marqué via `render_todelete_mask`

## Listes par priorité — chaînage interne

Chaque objet dans la DPS a (dans sa zone `rsv_*`) :
- Un pointeur vers l'**objet précédent** dans sa priorité
- Un pointeur vers l'**objet suivant**

C'est une liste doublement chaînée **par priorité** (pas globale comme la run-list). L'objet peut donc être présent dans la DPS d'un buffer mais pas dans l'autre (cas où il vient d'apparaître et n'a été inscrit que dans la DPS du back-buffer).

## Buffer 0 vs Buffer 1

Le double buffering oblige à maintenir **deux DPS séparées** :
- `DPS_buffer_0` : sprites à afficher quand backBuffer.id = 0
- `DPS_buffer_1` : sprites à afficher quand backBuffer.id = 1

À chaque frame, on alterne. Mais un sprite mobile doit être présent dans les **deux** DPS pour être affiché en continu — c'est `CheckSpritesRefresh` qui synchronise ça via les `rsv_*` flags.

## `Tbl_Sub_Object_Erase` / `Tbl_Sub_Object_Draw`

Listes auxiliaires utilisées par `CheckSpritesRefresh` :

```asm
Tbl_Sub_Object_Erase   fill  0,nb_graphical_objects*2  ; à effacer cette frame
Tbl_Sub_Object_Draw    fill  0,nb_graphical_objects*2  ; à redessiner cette frame
```

Construites pendant `CheckSpritesRefresh` et consommées par `EraseSprites` / `DrawSprites`.

## `cur_priority` et pointeurs DP

Pendant `CheckSpritesRefresh`, des variables DP sont utilisées :

```asm
cur_priority                  equ dp_engine          ; priorité courante (1 octet)
cur_ptr_sub_obj_erase         equ dp_engine+1        ; pointeur courant erase (2 octets)
cur_ptr_sub_obj_draw          equ dp_engine+3        ; pointeur courant draw (2 octets)
```

Ces emplacements dans `dp_engine` sont **partagés** entre tous les modules engine. Ne pas y écrire depuis le code utilisateur.

## Pattern d'utilisation

### Inscription d'un objet

```asm
Init
        ldb   #4                        ; priority 4 (milieu)
        stb   priority,u
        ; ...
        inc   routine,u
        rts

Main
        ; ... logique frame ...
        jsr   AnimateSprite
        jmp   DisplaySprite              ; inscrit dans la DPS (lit priority,u)
```

### Changement de priorité

```asm
        lda   #2                        ; passe en front
        sta   priority,u
        ; au prochain DisplaySprite, l'objet sera inscrit dans la liste prio 2
```

Si l'objet était déjà dans une autre priorité, l'engine le délie automatiquement avant de l'inscrire dans la nouvelle.

### Cacher temporairement

```asm
        lda   render_flags,u
        ora   #render_hide_mask         ; cache sans toucher à priority
        sta   render_flags,u
```

Le sprite est dans la DPS mais ne sera pas dessiné. Cela évite de devoir re-inscrire au moment du show.

### Suppression complète

```asm
        clr   priority,u                ; priority = 0
        ; à la prochaine frame, UnsetDisplayPriority retirera l'objet de la DPS
```

ou via `render_todelete_mask` (qui aussi libère le slot et nettoie le sprite).

## Dimensionnement

`nb_graphical_objects` (déclaré dans `ram-data.asm`) détermine la taille de `Tbl_Sub_Object_Erase` et `Tbl_Sub_Object_Draw` :

```asm
nb_graphical_objects              equ 12              ; max 64
```

Limite hard : 64 (cf. constantes engine). En pratique, viser le **nombre max de sprites visibles simultanément**, pas le nombre total d'objets dans le pool (un objet sans sprite ne consomme pas de slot graphique).

## Pitfalls

- **`priority = 0`** dans l'init : l'objet existe mais n'est jamais affiché. Pas un bug si c'est voulu (objets purement logiques).
- **Modifier `priority` sans rappeler `DisplaySprite`** : la DPS n'est pas mise à jour, le sprite reste dans la mauvaise priorité.
- **Trop de sprites en même priorité** : ralentissement (parcours de liste long).
- **`nb_graphical_objects > 64`** : crash au build (overflow des structures internes).
- **Inscrire l'objet sans incrémenter `priority`** : si `priority,u = 0` à l'appel de `DisplaySprite`, l'objet est silencieusement non-inscrit.
