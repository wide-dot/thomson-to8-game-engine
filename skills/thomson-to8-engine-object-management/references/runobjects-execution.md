# `RunObjects` — exécution cyclique des objets

`RunObjects` est appelée chaque frame depuis la `MainLoop` du game-mode. C'est elle qui exécute le code de chaque objet vivant.

## Algorithme

```asm
RunObjects
        ldu   object_list_first         ; tête de liste
        beq   @rts                      ; liste vide
!       ldb   id,u                      ; ObjID logique
        beq   @skip                     ; slot booké mais id=0 → skip
        ldx   #Obj_Index_Page
        abx
        lda   ,x                        ; page mémoire de l'objet
        _SetCartPageA                   ; mount cette page en cartouche
        aslb                            ; *2 (adresse 2 octets/entry)
        ldx   #Obj_Index_Address
        abx
        ldd   run_object_next,u         ; sauve le suivant AVANT exec
        std   object_list_next          ; (cf. self-suppression)
        jsr   [,x]                      ; saut indirect vers le code
        ldu   run_object_next,u
        bne   <
        ldu   #0
object_list_next equ *-2
        bne   <
@rts    rts
@skip   ldu   run_object_next,u
        bne   <
        rts
```

## Mécanique du cross-page mount

Le code asm de chaque objet est typiquement placé sur une page différente que celle qui exécute `RunObjects` (la page « résidente », contenant le main engine du game-mode).

L'engine mount automatiquement la bonne page avant d'appeler la routine :

```
Obj_Index_Page[ObjID_X]    = 4    ; l'objet X est en page 4
Obj_Index_Address[ObjID_X] = $A100 ; et son entry point est à $A100
```

Ces deux tables sont **générées par le builder Java** (cf. `BuildDisk.java` — fonctions `writeObjIndex` etc.). Elles sont placées en zone résidente (page 1), accessibles depuis n'importe où.

Le `_SetCartPageA` est équivalent à `sta $E7E6` (mappe la page A en zone cartouche $0000-$3FFF) — sur les variantes T2, c'est `jsr SetCartPageA` qui passe via la routine engine.

## Sauvegarde du `next` avant exécution

```asm
        ldd   run_object_next,u         ; sauve AVANT exec
        std   object_list_next
        jsr   [,x]                      ; exec — l'objet peut se supprimer
        ldu   run_object_next,u         ; mais on lit le next sauvé via object_list_next
```

Cette indirection est cruciale : si l'objet se supprime via `UnloadObject_u`, son `run_object_next` est mis à 0 ET `object_list_next` est mis à jour par `UnloadObject_u` pour pointer vers le bon objet suivant. Sans cette sauvegarde, on accéderait à un slot effacé.

## Création d'un objet fils pendant l'exécution

L'allocation via `LoadObject_u`/`x` ajoute en queue (`object_list_last`). Si on est en train de parcourir et qu'on est avant la queue, le nouvel objet **sera exécuté dans la même frame** car le parcours va l'atteindre.

Si on est l'objet en queue (dernier de la liste), le nouvel objet est en queue mais **ne sera pas exécuté immédiatement** car le parcours sort de la boucle avec `ldu run_object_next,u → 0`. Néanmoins, l'engine fait :

```asm
        ldu   run_object_next,u         ; obj courant.next (peut être le nouvel objet)
        bne   <
        ldu   #0
object_list_next equ *-2                ; lecture de object_list_next
        bne   <
```

Le `object_list_next` est consulté en fallback → si entre-temps un fils a été créé et `object_list_next` mis à jour, le parcours reprend. Donc en pratique tous les objets créés pendant la frame sont exécutés dans la frame.

## `RunFrozenObjects` — mode pause

```asm
RunFrozenObjects
        ldu   object_list_first
        beq   @rts
!       lda   render_flags,u
        anda  #^render_hide_mask        ; unset hide flag
        sta   render_flags,u
        ldu   run_object_next,u
        bne   <
@rts    rts
```

Ne **n'exécute pas** le code des objets. Se contente de lever le bit `render_hide_mask` sur tous les objets. Utilisé pour faire réapparaître les sprites figés à la sortie d'une pause/cinematic.

## Diagrammes — chaînage de la run-list

```
object_list_first ──→ Obj A
                       prev = 0
                       next ──→ Obj B
                                 prev ──→ Obj A
                                 next ──→ Obj C
                                            prev ──→ Obj B
                                            next = 0
                                            ←─ object_list_last
```

Lors d'un `UnloadObject_u(B)` :
1. `B.prev (A).next = B.next (C)`
2. `B.next (C).prev = B.prev (A)`
3. `B` est effacé et son adresse repush dans `STACK_SLOT_ADDRESS`

```
object_list_first ──→ Obj A
                       prev = 0
                       next ──→ Obj C   ← maintenant direct
                                 prev ──→ Obj A
                                 next = 0
                                 ←─ object_list_last
```

## Cas particulier : `id=0` (slot réservé)

Un slot peut être alloué mais avec `id=0`. Dans ce cas `RunObjects` le **skip sans erreur** et passe au suivant. Pattern d'usage : réserver un slot maintenant pour un objet à initialiser plus tard.

## Ordre d'exécution

L'ordre est **strictement celui d'insertion** (FIFO sur la chaîne). Si on veut un ordre de priorité différent, il faut le gérer applicativement (pas de tri automatique sur `priority`, `priority` ne sert que pour l'**affichage**).

## Coût CPU

À chaque appel `RunObjects` : pour chaque objet,
- 4-5 instructions de setup (~20 cycles)
- 1 `_SetCartPageA` (~10 cycles en T2 via routine, ~6 cycles en FD via store direct)
- 1 `jsr [,x]` (~9 cycles)
- 4-5 instructions de fin de tour (~20 cycles)
- Soit ~60 cycles de bookkeeping par objet, hors code utilisateur

Avec 22 objets et un budget 50 Hz (~20000 cycles/frame), on a ~19000 cycles pour le code utilisateur de tous les objets — soit ~860 cycles/objet en moyenne. Suffisant pour la plupart des objets simples ; les boss/joueurs principaux mangent plus.

## Pitfalls

- **Ne pas modifier `run_object_next,u`** depuis le code utilisateur — c'est géré par l'engine
- **Modifier `id,u` à 0 sans `UnloadObject_u`** : le slot n'est pas remis dans la pile, fuite
- **Allouer un objet pendant que la pile est presque vide** : un autre objet pourrait avoir le même slot ; gérer le Z=1
- **Mounter manuellement une page dans un objet** : doit être restauré avant `rts` (ou utiliser `_RunObjectSwap`)
- **Compter sur l'ordre d'exécution** : si tu inserts un objet après le tien, il sera exécuté dans la frame ; si avant, dans la prochaine
