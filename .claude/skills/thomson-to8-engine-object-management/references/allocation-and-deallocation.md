# Allocation et libération d'objets

## Initialisation au boot — `InitStack`

Au démarrage du game-mode, **avant tout `LoadObject_u`**, il faut initialiser la pile des slots libres :

```asm
        jsr   InitStack
```

`InitStack` remplit `STACK_SLOT_ADDRESS` avec les adresses de tous les slots du pool `Dynamic_Object_RAM` :

```asm
InitStack
        ldu   #STACK_SLOT_ADDRESS_END
        ldx   #Dynamic_Object_RAM_End-object_size
@loop   pshu  x                              ; empile l'adresse du slot
        leax  -object_size,x
        cmpu  #STACK_SLOT_ADDRESS
        bne   @loop
        stu   STACK_POINTER                  ; pointe sur le sommet de pile
        rts
```

Structure :
- `STACK_SLOT_ADDRESS` (taille `nb_dynamic_objects*2`) : tableau d'adresses de slots
- `STACK_POINTER` (2 octets) : pointeur courant ; pointe `STACK_SLOT_ADDRESS_END` quand vide

## `LoadObject_u` — allocation, retour dans `u`

```asm
LoadObject_u
        ldu   STACK_POINTER                  ; sommet de pile
        cmpu  #STACK_SLOT_ADDRESS_END        ; pile vide ?
        bne   @link
        rts                                  ; ÉCHEC : retourne Z=1
@link
        pshs  x
        leax  2,u                            ; dépile (2 octets = adresse)
        stx   STACK_POINTER                  ; met à jour le sommet
        ldu   ,u                             ; u = adresse du slot libre
        ldx   object_list_last
        beq   >                              ; liste vide → premier
        stu   run_object_next,x              ; sinon → lie en queue
        stu   object_list_last
        stx   run_object_prev,u
        puls  x,pc                           ; SUCCÈS : Z=0
!       stu   object_list_last               ; cas liste vide
        stu   object_list_first
        puls  x,pc
```

Effets :
- Dépile un slot de `STACK_SLOT_ADDRESS`
- Le lie en **queue** de la run-list (chaînée via `run_object_prev/next`)
- Retourne `u` = pointeur vers le slot, `Z=0` si succès, `Z=1` si pool plein

## `LoadObject_x` — allocation, retour dans `x`

Strictement identique mais retourne dans `x` (et préserve `u`). Implémentation symétrique.

Usage typique : **depuis une routine d'objet** qui a `u` pointant sur son OST courant et qui veut créer un enfant sans perdre `u`.

```asm
; Dans une routine d'objet, créer un projectile fils
        jsr   LoadObject_x              ; alloue dans x, u parent préservé
        beq   @no_slot
        lda   #ObjID_Bullet
        sta   id,x
        ldd   x_pos,u                   ; recopie position parent
        std   x_pos,x
        ldd   #-$200                    ; vitesse vers la gauche
        std   x_vel,x
@no_slot
```

## `UnloadObject_u` / `UnloadObject_x` — libération

```asm
UnloadObject_u
        pshs  d,x,y,u
        ldx   STACK_POINTER
        stu   ,--x                      ; repush l'adresse dans la pile
        stx   STACK_POINTER
        cmpu  object_list_next          ; si on supprime le NEXT du parcours en cours
        bne   >
        ldy   run_object_next,u
        sty   object_list_next          ; ajuster object_list_next
        beq   @noNext
!       ldy   run_object_next,u
        beq   @noNext
        ldx   run_object_prev,u
        stx   run_object_prev,y
        beq   @noPrev
        sty   run_object_next,x
        bra   @clearObj
@noPrev sty   object_list_first
        ; ... etc
@clearObj
        leau  object_size,u             ; pointer après l'objet
UnloadObject_clear
        ldd   #$0000
        ldx   #$0000
        leay  ,x
        fill $36,(object_size/6)*2      ; pshu d,x,y répété (efface 6 octets/instruction)
        ; ... suffix pour les derniers octets
        puls  d,x,y,u,pc
```

Effets :
- Délink l'objet du chaînage `run_object_prev/next`
- Repush le slot dans `STACK_SLOT_ADDRESS`
- Efface les `object_size` octets via une boucle `pshu d,x,y` **générée à la compilation** (très optimisée — 6 octets par instruction)
- Gère le cas où l'objet supprimé est le `next` du parcours `RunObjects` en cours

Après l'appel, **`u` n'est plus valide**. Toujours `rts` immédiatement après.

## `ManagedObjects_ClearAll` — reset total

```asm
        jsr   ManagedObjects_ClearAll
```

Efface l'intégralité de `Dynamic_Object_RAM` (de `Dynamic_Object_RAM_End` jusqu'à `Dynamic_Object_RAM+6`) via `pshu d,x,y` puis `pshu a` pour les derniers octets, et remet `object_list_first` / `object_list_last` à 0.

Usage : transition de game-mode (`LoadGameMode` appelle cette routine indirectement) pour repartir d'un pool propre.

**Attention** : `ManagedObjects_ClearAll` ne reset PAS `STACK_SLOT_ADDRESS` / `STACK_POINTER`. Il faut rappeler `InitStack` après si on veut un état propre. Ou alors, c'est implicite dans le nouveau game-mode qui appelle `InitStack` au boot.

## Comparaison `UnloadObject_u` vs `render_todelete_mask`

| Approche | Quand | Pour | Précautions |
|----------|-------|------|-------------|
| `UnloadObject_u` | Suppression immédiate | Objet sans sprite, ou quand on veut être sûr du nettoyage | Pas d'effacement de sprite ; `u` invalide après ; appeler depuis init seulement ou éviter dans RunObjects |
| `render_todelete_mask` | Suppression différée | Objet avec sprite à effacer proprement | Le moteur s'occupe de l'effacement écran via `EraseSprites` |

Préférer `render_todelete_mask` dans la plupart des cas :

```asm
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u
        rts                             ; ne pas appeler DisplaySprite
```

## Cas limite : pile pleine

Si `LoadObject_u` retourne Z=1, **ne pas modifier `u`** : il contient encore `STACK_POINTER` (qui pointe `STACK_SLOT_ADDRESS_END`). Modifier `id,u` à ce moment-là écraserait la mémoire de la pile.

Pattern correct :
```asm
        jsr   LoadObject_u
        beq   @failed                   ; sortir si pas de slot
        ; ... usage de u ...
        rts
@failed
        ; pas de slot disponible — alternative ou simplement ignorer
        rts
```

## Diagnostic d'épuisement du pool

Si `LoadObject_u` retourne souvent Z=1 :
- Augmenter `nb_dynamic_objects` dans `ram-data.asm`
- Vérifier qu'aucun objet ne fuit (création sans libération)
- Vérifier les flags `render_todelete_mask` (l'objet est-il vraiment supprimé ou seulement masqué via `render_hide_mask` ?)
- Compter les `LoadObject_u` vs `UnloadObject_u` via traces debug

## Allocation pendant `RunObjects`

Quand `LoadObject_u` est appelée **depuis une routine d'objet** (donc pendant `RunObjects`) :
- Le nouvel objet est ajouté en **queue** (`object_list_last`)
- `RunObjects` continue son parcours via `run_object_next`
- **Le nouvel objet sera exécuté dans la MÊME frame** (utile pour un projectile qui doit bouger dès l'apparition, ou indésirable si on veut un délai d'une frame)

Pour différer l'exécution d'une frame, il faut soit attendre la prochaine frame avant le `LoadObject_u`, soit utiliser un flag intermédiaire dans l'objet enfant.

## Suppression pendant `RunObjects`

Quand un objet se supprime lui-même via `UnloadObject_u` :
- `object_list_next` est ajusté pour pointer vers le suivant (sauvegardé par `RunObjects` avant l'exécution)
- Le parcours continue normalement

Quand un objet supprime un AUTRE objet via `UnloadObject_u` ou `UnloadObject_x` :
- Si la cible est le `next` du parcours en cours (`object_list_next`), l'engine met à jour `object_list_next` automatiquement
- Sinon le parcours continue depuis `run_object_next` de l'objet courant, intact
