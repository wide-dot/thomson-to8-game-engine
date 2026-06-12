# Dirty rendering — `CheckSpritesRefresh`

L'engine optimise le rendu en ne redessinant que les sprites qui ont changé (« dirty rendering »). `CheckSpritesRefresh` est appelée chaque frame entre `RunObjects` et `EraseSprites` pour déterminer ce qui doit bouger.

## Pourquoi ce mécanisme ?

Un sprite immobile **n'a pas besoin** d'être effacé/redessiné chaque frame — c'est gaspillage. Le moteur détecte si position/animation/render_flags ont changé depuis la frame précédente, et marque seulement les sprites dirty.

## `rsv_render_flags` — les flags engine

```
Bit | Mask  | Symbole                       | Sémantique
----|-------|-------------------------------|---------------------------------------------
0   | $01   | rsv_render_checkrefresh_mask  | déjà traité par CheckSpritesRefresh cette frame
1   | $02   | rsv_render_erasesprite_mask   | doit être effacé
2   | $04   | rsv_render_displaysprite_mask | doit être redessiné
3   | $08   | rsv_render_outofrange_mask    | hors écran (cull)
7   | $80   | rsv_render_onscreen_mask      | a été rendu sur le dernier buffer
```

Ces flags sont gérés par l'engine, dans la zone `rsv_*` (hors `ext_variables`).

## Algorithme — `CheckSpritesRefresh`

```asm
CheckSpritesRefresh
        ; Init buffers
        ldd   #Tbl_Sub_Object_Erase
        std   cur_ptr_sub_obj_erase
        ldd   #Tbl_Sub_Object_Draw
        std   cur_ptr_sub_obj_draw
        
        ; Choisir le buffer (0 ou 1)
        lda   gfxlock.backBuffer.id
        bne   CSR_SetBuffer1
        
CSR_SetBuffer0
        lda   #rsv_buffer_0              ; offset pour rsv_*
        sta   CSR_ProcessEachPriorityLevel+2
        
CSR_P8B0
        ; Parcourir priorité 8 (back)
        ldu   DPS_buffer_0+buf_Tbl_Priority_First_Entry+16
        beq   CSR_P7B0
        lda   #$08
        sta   cur_priority
        jsr   CSR_ProcessEachPriorityLevel
CSR_P7B0
        ; ... priorité 7 ... 6 ... 5 ... 4 ... 3 ... 2 ... 1 ...
```

Parcours **back to front** (priorité 8 → 1), construisant deux listes :
- `Tbl_Sub_Object_Erase` : sprites à effacer (avaient été dessinés au tour précédent)
- `Tbl_Sub_Object_Draw` : sprites à redessiner (encore visibles, ou nouveaux)

Pour chaque sprite, la routine compare son état courant (`position`, `anim`, `render_flags`) avec son état au tour précédent (mémorisé dans `rsv_*`).

## Décision dirty/clean

Un sprite est marqué **dirty** si au moins une de ces conditions est vraie :
- Sa position (`x_pos`/`y_pos` ou `x_pixel`/`y_pixel`) a changé
- Son animation (`anim`, `image_set`) a changé
- Ses `render_flags` ont changé (e.g. flip Y activé)
- Son `status_flags` a changé
- `glb_force_sprite_refresh = 1` (force refresh global)

Si dirty : `rsv_render_erasesprite_mask` ET `rsv_render_displaysprite_mask` sont mis.
Si clean : aucun des deux, le sprite n'est pas dans `Tbl_Sub_Object_Erase/Draw`.

## `glb_force_sprite_refresh`

Variable globale (dans la zone `glb_*`) qui force le refresh complet :

```asm
        lda   #1
        sta   <glb_force_sprite_refresh
```

Utile après :
- Un scroll (toute l'image bouge, tous les sprites doivent être redessinés)
- Un changement de palette (les couleurs ont changé)
- Une transition d'act ou de niveau

`CheckSpritesRefresh` lit ce flag et marque tous les sprites comme dirty si à 1. Le flag est ensuite remis à 0 par le moteur.

## Gestion du double buffer

Chaque buffer (0 et 1) a son propre état dirty :
- `rsv_buffer_0` : sprite a été rendu sur le buffer 0 au dernier tour qui utilisait 0
- `rsv_buffer_1` : idem buffer 1

Sur deux frames consécutifs, un sprite peut être :
- Tour N : rendu sur buffer 0
- Tour N+1 : il faut le rendre sur buffer 1 (le précédent rendu était sur buffer 1 il y a 2 frames)

Donc même un sprite « immobile » doit être redessiné **alternativement** sur les deux buffers tant qu'il existe — car les buffers ne sont jamais nettoyés entre frames (sauf via Erase).

C'est pour ça que `rsv_render_onscreen_mask` est dédoublé via `rsv_buffer_0`/`rsv_buffer_1`. Le moteur sait sur quel buffer le sprite a été rendu en dernier.

## `Tbl_Sub_Object_Erase` / `Tbl_Sub_Object_Draw`

Construites pendant `CheckSpritesRefresh`, consommées par `EraseSprites` et `DrawSprites` :

```asm
Tbl_Sub_Object_Erase   fill  0,nb_graphical_objects*2   ; entrées back to front
Tbl_Sub_Object_Draw    fill  0,nb_graphical_objects*2   ; entrées back to front
```

Chaque entrée = 2 octets (pointeur OST).

`EraseSprites` parcourt `Tbl_Sub_Object_Erase` **front to back** (l'inverse de Draw) pour gérer le z-order à l'effacement correctement.

## Variables Direct Page

```asm
cur_priority                  equ dp_engine             ; 1 byte
cur_ptr_sub_obj_erase         equ dp_engine+1           ; 2 bytes
cur_ptr_sub_obj_draw          equ dp_engine+3           ; 2 bytes
```

Utilisées pendant `CheckSpritesRefresh` pour le bookkeeping. Allouées dans `dp_engine` (zone réservée moteur, $9F00 + offset).

## Coût

`CheckSpritesRefresh` est en O(N) où N = `nb_graphical_objects`. Pour N=64 (limite hard) c'est ~500-1000 cycles selon la complexité des comparaisons. Négligeable comparé à `DrawSprites` qui peut prendre des milliers de cycles.

## Pattern d'usage

```asm
MainLoop
        jsr   RunObjects                ; les objets bougent
        jsr   CheckSpritesRefresh       ; détermine ce qui a changé
        _gfxlock.on
        jsr   EraseSprites              ; restaure les fonds des sprites dirty
        jsr   UnsetDisplayPriority      ; supprime les sprites avec priority=0
        jsr   DrawSprites               ; redessine les sprites dirty
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop
```

## Cas spéciaux

### Sprite qui ne bouge jamais

Si un sprite est strictement immobile (animation non plus), `CheckSpritesRefresh` ne le marque dirty **qu'une fois sur deux** (alternance des buffers). Si on veut qu'il soit redessiné chaque frame, il faut soit le marquer manuellement, soit utiliser `glb_force_sprite_refresh = 1`.

### Sprite teint dynamiquement (palette cycling)

Si on change la palette sans toucher au sprite, le sprite **n'est pas marqué dirty** automatiquement. Mais visuellement les couleurs changent (car la palette est partagée). Pas besoin de refresh sprite, donc OK.

Si on change le contenu d'un sprite (cas rare), il faut forcer le refresh :
```asm
        ; Modifier le sprite directement en RAM
        ; ... 
        lda   render_flags,u
        ora   #render_subobjects_mask   ; ou autre flag de change détecté
        sta   render_flags,u
        ; (à la prochaine frame, CheckSpritesRefresh détectera le changement de render_flags)
```

ou plus simple :
```asm
        lda   #1
        sta   <glb_force_sprite_refresh ; force tous les sprites
```

## Pitfalls

- **Compter sur `rsv_*`** depuis le code utilisateur : ces flags sont **internes** au moteur, ne pas les modifier
- **Modifier `cur_priority` / `cur_ptr_sub_obj_*`** : c'est de la mémoire engine, corrompt le rendu
- **Lire `glb_force_sprite_refresh`** après l'avoir mis à 1 : il sera resetté à 0 par le moteur après `CheckSpritesRefresh`
- **Modifier `priority`** sans redéclencher un cycle complet de refresh : la DPS sera désynchronisée
- **Oublier `CheckSpritesRefresh`** dans MainLoop : aucun sprite ne sera dirty détecté, écran figé
