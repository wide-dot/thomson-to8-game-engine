# Bank switching — macros et routines

Le 6809 adresse 64 Ko, mais le TO8 a jusqu'à 512 Ko de RAM + ROM cartouche. La **commutation de pages** permet d'accéder à toute cette mémoire en remappant dynamiquement les zones $0000-$3FFF (cartouche) et $A000-$DFFF (données).

## Hardware

Trois registres pour la pagination :

| Registre | Adresse | Rôle |
|----------|---------|------|
| `$E7E5` | `CF74021.DATA` | Sélection page RAM en zone donnée ($A000-$DFFF) |
| `$E7E6` | `CF74021.CART` | Sélection page RAM ou ROM en zone cartouche ($0000-$3FFF) |
| `$E7E7` | `CF74021.SYS1` | Sélection page vidéo visible |

### `$E7E5` (page données)

```
Bits :  0 0 0 X X X X X     ; X = numéro de page (0-31)
```

Exemple :
```asm
        ldb   #2
        stb   $E7E5                     ; page 2 en $A000-$DFFF
```

Maintenant la zone $A000-$DFFF correspond physiquement à la page 2 de RAM (16 Ko).

### `$E7E6` (page cartouche)

```
Bits :  W R x x x X X X X X
        | |       └─ numéro de page (0-31)
        | └─────── 0 = ROM cartouche (T2), 1 = RAM
        └───────── write enable
```

- **bit 5 = 0** : zone cartouche pointe vers ROM cartouche T2
- **bit 5 = 1** : zone cartouche pointe vers RAM (la page indiquée)

C'est plus complexe que $E7E5 car la zone cartouche peut être ROM ou RAM.

## Routines BankSwitch

### `SetCartPageA`

```asm
SetCartPageA
        sta   >glb_Page                 ; sauve la page demandée
        bpl   @RAMPg                    ; positif (bit 7=0) → RAM
        
        ; Page T2 ROM : séquence spéciale
        lda   >$E7E6
        anda  #$DF                      ; clear bit 5 → ROM cartouche
        sta   >$E7E6
        
        ; Séquence de commutation T2 (Megarom)
        lda   #$F0                      ; sortie mode commande T.2
        sta   >$0555                    ; sécurité IRQ
        lda   #$AA                      ; séquence
        sta   >$0555
        lsra                            ; = $55
        sta   >$02AA
        lda   #$C0
        sta   >$0555
        
        lda   >glb_Page
        anda  #$7F                      ; bit 7 = 0
        sta   >$0555                    ; sélection page T2
        bra   @rts
        
@RAMPg  sta   >$E7E6                    ; RAM en zone cartouche
@rts    rts
```

Sémantique :
- **Page positive** (bit 7 = 0) : page RAM, écriture directe `sta $E7E6`
- **Page négative** (bit 7 = 1) : page T2 ROM, séquence Megarom

`glb_Page` mémorise la page demandée (utile pour `GetCartPageA`).

### `SetCartPageB`

Identique mais via le registre B.

### `GetCartPageA`

```asm
GetCartPageA
        lda   >glb_Page
        bne   @rts                      ; glb_Page != 0 → utiliser cette valeur
        lda   >$E7E6                    ; sinon, lire le hardware
@rts    rts
```

**Si `glb_Page = 0`** : lit le hardware directement (mode optimisé sans tracking applicatif).
**Si `glb_Page != 0`** : retourne la valeur mémorisée (évite la lecture hardware).

### `GetCartPageB`

Idem via B.

## Macros utilisateur

### `_SetCartPageA`

```asm
_SetCartPageA MACRO
 IFDEF T2
        jsr   SetCartPageA              ; gère T2 ROM
 ELSE
        sta   $E7E6                     ; direct (RAM seulement)
 ENDC
 ENDM
```

`_SetCartPageA` est la macro recommandée. Selon `IFDEF T2` :
- Build T2 : utilise la routine `SetCartPageA` (gère ROM cartouche)
- Build FD/RAM : utilise `sta $E7E6` directement (plus rapide)

Le builder définit `T2` automatiquement quand on build pour cartouche T2.

### `_GetCartPageA`

```asm
_GetCartPageA MACRO
 IFDEF T2
        jsr   GetCartPageA
 ELSE
        lda   $E7E6
 ENDC
 ENDM
```

### `_SetCartPageB` / `_GetCartPageB`

Versions équivalentes pour `B`.

## Usage typique

### Mounter une page pour exécuter du code

```asm
        ldb   #ObjID_X
        ldx   #Obj_Index_Page
        lda   b,x                       ; charge la page de l'objet
        _SetCartPageA                   ; mount
        ; ... maintenant la zone $0000-$3FFF contient le code de l'objet ...
        ldx   #Obj_Index_Address+2*ObjID_X
        ldx   ,x                        ; charge l'adresse
        jsr   ,x                        ; exécute
```

### Mounter une page pour lire des données

```asm
        ldb   #data_page
        stb   $E7E5                     ; mount en zone donnée
        ; ... maintenant $A000-$DFFF contient les data ...
        ldx   #data_addr
        ldd   ,x                        ; lit
```

## `glb_Page = 0` — special mode

Si `glb_Page = 0`, l'engine **assume RAM toujours**. Économie :
- `GetCartPageA` lit directement `$E7E6` au lieu de `glb_Page`
- Pas de test bit 7 (T2 vs RAM)

Utilisé pour les modes intensifs comme le tile rendering où les pages sont contrôlées de bout en bout.

À mettre :
```asm
        clr   glb_Page                  ; ou ldb #0; stb glb_Page
        ; ... mode rapide ...
```

À remettre à une valeur non-zéro avant de réutiliser BankSwitch.

## Pagination de la zone vidéo

Différente : `$E7DD` (`CF74021.SYS2`) et `$E7E7` (`CF74021.SYS1`).

```asm
$E7DD :  bits 0-3 = couleur bordure, bits 6-7 = page vidéo visible
$E7E7 :  bits 0-1 = mode RAM/ROM/écran, ...
```

C'est `gfxlock.bufferSwap.do` qui gère ça (cf. skill graphics-pipeline).

## Calcul des pages générées par le builder

Le builder Java affecte automatiquement les objets à des pages RAM via un **knapsack packing** (algorithme d'optimisation pour minimiser le nombre de pages utilisées).

Convention :
- **Page 1** : résidente (boot, code engine commun, tables d'index)
- **Page 2-3** : double-buffer vidéo (gfxlock)
- **Page 4+** : code des objets (compilés sprites + routines)

Voir skill `build-pipeline` pour le détail du packing.

## Pitfalls

- **Mounter une page sans `_SetCartPageA`** : `sta $E7E6` direct ignore la logique T2 → si on est en build T2, crash
- **Oublier de restaurer la page** après usage : la routine suivante exécute la mauvaise page
- **`glb_Page` désynchronisé du hardware** : si on écrit `$E7E6` direct sans MAJ `glb_Page`, GetCartPageA retourne la mauvaise valeur
- **Page > 31** : pages physiques inexistantes → comportement imprévisible
- **Bit 7 mal géré** : on peut accidentellement passer en T2 ROM au lieu de RAM
- **`_GetCartPageA` après modification directe** : retourne `glb_Page` mémorisé, pas la vraie valeur hardware
- **Mounter pendant une IRQ** : si la IRQ termine, la page mountée par IRQ écrase la page utilisée par le main → race condition. Sauver/restaurer DP+page si nécessaire
- **`glb_Page = 0`** activé puis appel à une routine qui suppose tracking : la page sera lue directement, peut être incohérente
