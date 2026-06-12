# Exécution cross-page — `_MountObject`, `_RunObject*`, `RunPgSubRoutine`

Le code asm de chaque objet est typiquement placé sur une page mémoire différente (placement automatique par le builder Java via knapsack packing). Pour appeler une routine d'un autre objet, il faut **mount sa page** avant l'appel.

## Tables `Obj_Index_Page` et `Obj_Index_Address`

Le builder génère deux tables résidentes (page 1, toujours accessibles) :

| Table | Taille | Contenu |
|-------|--------|---------|
| `Obj_Index_Page` | 1 octet par ObjID_ | Numéro de page physique où réside le code de l'objet |
| `Obj_Index_Address` | 2 octets par ObjID_ | Adresse du point d'entrée de l'objet dans sa page |

Exemple généré :
```asm
Obj_Index_Page
        fcb 0                   ; ObjID_0 (réservé)
        fcb 4                   ; ObjID_Player (page 4)
        fcb 4                   ; ObjID_Bubble (page 4)
        fcb 5                   ; ObjID_Background (page 5)

Obj_Index_Address
        fdb 0                   ; ObjID_0
        fdb $A100               ; ObjID_Player entry
        fdb $A800               ; ObjID_Bubble entry
        fdb $A000               ; ObjID_Background entry
```

## `_MountObject` — mount + setup, pas de jsr

```asm
_MountObject MACRO
        ; param 1 : ObjID_
        lda   Obj_Index_Page+\1         ; charge la page
        _SetCartPageA                   ; mount en zone cartouche
        ldx   Obj_Index_Address+2*\1    ; charge l'adresse
 ENDM
```

Effets : `A` = page, `X` = adresse du point d'entrée, **page mountée**.

Usage typique : on veut appeler l'objet avec un setup particulier (passer `U` à une adresse, appeler une routine spécifique) :
```asm
        _MountObject ObjID_MusicEngine
        ldb   #1                        ; commande PLAY
        jsr   ,x                        ; appelle l'objet
```

**ATTENTION** : `_MountObject` **ne sauvegarde pas** la page sortante. Si on est dans une routine appelée par `RunObjects` (qui a déjà mounté la page de l'objet courant), un `_MountObject X` casse cette page sans la restaurer. Le retour au code de l'objet courant après le `jsr ,x` se fait sur la page de X, qui peut contenir n'importe quoi à l'adresse du `rts`. **Crash garanti**.

Pour appeler depuis une routine d'objet, utiliser `_RunObjectSwap` au lieu de `_MountObject`.

## `_RunObject` — `_MountObject` + setup ldu + jsr

```asm
_RunObject MACRO
        ; param 1 : ObjID_
        ; param 2 : adresse RAM des données objet (typiquement #player1 ou autre OST)
        _MountObject \1
        ldu   \2
        jsr   ,x
 ENDM
```

Usage : exécuter le code d'un objet **non géré par `RunObjects`** (e.g. joueur en Direct Page) :

```asm
MainLoop
        ; ... RunObjects (gère tous les objets dynamiques) ...
        _RunObject ObjID_Player,#player1    ; exécute le joueur (en DP)
        ; ... suite du main loop ...
```

Idem `_MountObject` : ne préserve pas la page sortante. À utiliser uniquement depuis la page **résidente** (page 1, contenant le `MainLoop` du game-mode), pas depuis le code d'un objet.

## `_RunObjectSwap` — sécurisé pour usage cross-page

```asm
_RunObjectSwap MACRO
        ; param 1 : ObjID_
        ; param 2 : adresse RAM des données objet
        lda   Obj_Index_Page+\1
        sta   PSR_Page
        ldd   Obj_Index_Address+2*\1
        std   PSR_Address
        ldu   \2
        jsr   RunPgSubRoutine
 ENDM
```

Préfère `_RunObjectSwap` à `_MountObject`+`jsr` ou `_RunObject` quand on est dans le code d'un objet. C'est la version sûre.

## `RunPgSubRoutine` — sous-jacent

```asm
RunPgSubRoutine
        _GetCartPageA                   ; sauve la page courante dans A
        sta   @page                     ; stocke pour restauration
        lda   #0
PSR_Page equ *-1                        ; (modifié par _RunObjectSwap)
        _SetCartPageA                   ; mount la page cible
        lda   #0
PSR_Param equ *-1                       ; paramètre optionnel
        jsr   >0
PSR_Address equ *-2                     ; (modifié par _RunObjectSwap)
RunPgSubRoutine_return
        lda   #0
@page   equ *-1
        _SetCartPageA                   ; restaure la page sortante
        rts
```

Mécanique :
1. Sauve la page courante via `_GetCartPageA` (= `lda $E7E6` ou routine T2)
2. Mount la page cible (`PSR_Page`)
3. Appelle l'adresse cible (`PSR_Address`)
4. Au retour, restaure la page sauvée

C'est du **code auto-modifié** : `_RunObjectSwap` écrit dans les opérandes `PSR_Page`, `PSR_Address`, `PSR_Param` avant l'appel.

## Variantes

### `_RunObjectSwapRoutine`

Permet d'appeler une **routine spécifique** d'un objet (pas le point d'entrée principal). Utile pour appeler une sub-routine exportée :

```asm
_RunObjectSwapRoutine MACRO
        ; param 1 : ObjID_
        ; param 2 : adresse de la routine (e.g. #Player_GetHealth)
        ; param 3 : adresse RAM des données objet
        ; ...
```

### `_RunObjectRoutineA`

```asm
_RunObjectRoutineA MACRO
        ; param 1 : ObjID_
        ; param 2 : adresse de la routine
        ; manual launch from resident page 1
        _MountObject \1
        ldx   \2
        jsr   ,x
 ENDM
```

Usage : exécuter une routine spécifique d'un objet, sans setup `ldu`. Comme `_RunObject` : à utiliser **uniquement depuis la page résidente**.

## Quand utiliser quoi — décision

```
Tu es dans :         Tu veux appeler :          Macro à utiliser :
------------         ----------------           -------------------
MainLoop (rés.)      le point d'entrée          _RunObject (suffit)
MainLoop (rés.)      une routine spécifique     _RunObjectRoutineA
Code d'objet         le point d'entrée          _RunObjectSwap
Code d'objet         une routine spécifique     _RunObjectSwapRoutine
UserIRQ              le point d'entrée (audio)  _MountObject + jsr ,x
                                                 (pas de cross-page risk car IRQ
                                                  ne retournera pas dans un autre objet)
```

L'usage de `_MountObject` direct dans `UserIRQ` est fréquent pour les ticks audio (`_MountObject ObjID_ymm; _ymm.processFrame`) — c'est OK car l'IRQ n'a pas de contexte à préserver.

## Cas d'usage typiques

### Appel audio depuis UserIRQ

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        _MountObject ObjID_ymm
        _ymm.processFrame               ; macro qui fait jsr ,x avec B = commande
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts
```

### Joueur en Direct Page

```asm
; ram-data.asm
player1                  equ   dp

; main.asm — MainLoop
MainLoop
        jsr   RunObjects                ; gère tous les objets sauf le joueur
        _RunObject ObjID_Player,#player1 ; exécute le joueur manuellement
        ; ... suite ...
```

### Communication entre objets

L'objet A veut faire une action sur l'objet B (par exemple, lui infliger des dégâts) :

```asm
; Dans le code de l'objet A
        ldu   B_ost_address             ; trouvé via une variable globale
        _RunObjectSwapRoutine ObjID_B,#B_TakeDamage,u
```

ou plus simple : modifier directement les champs OST de B (si on connaît son adresse), sans passer par une routine. Souvent suffisant et plus rapide.

## Pitfalls

- **`_MountObject` depuis le code d'un objet sans restaurer** : crash après le retour
- **Modifier `PSR_Page`/`PSR_Address` manuellement** sans utiliser `_RunObjectSwap` : à faire seulement si on est expert
- **Appeler `_RunObjectSwap` pendant un `_RunObjectSwap` imbriqué** : la sauvegarde de page est dans `@page` (variable globale), pas re-entrante. Évite les appels récursifs cross-page.
- **`_RunObjectSwap` depuis IRQ** : techniquement OK mais ajoute du delay au tick audio. Préférer `_MountObject` direct si le code IRQ ne navigue pas entre plusieurs pages.
- **Confondre `_SetCartPageA` (instant) avec `jsr SetCartPageA` (T2)** : sous T2, `_SetCartPageA` se résout en `jsr` car la pagination demande plusieurs instructions ; sous FD, c'est juste `sta $E7E6`. Le `IFDEF T2` dans les macros engine gère ça automatiquement.
