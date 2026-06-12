---
name: thomson-to8-engine-dyncode
description: "Décrit le système de code auto-modifié (DynCode) du Thomson TO8/TO9 game engine (Bento8/wide-dot) : routine DynCode_ApplyAToListX pour écrire une valeur dans une liste d'adresses (terminée par -1, $FFFF), pattern d'optimisation 6809 pour éviter les indirections, exemples d'usage dans engine (terrainCollision avec terrainCollision.main.page / terrainCollision.main.address auto-modifiés, _vscroll.setTileset_ qui modifie 16 instances de vscroll.tiles.nbLinesByPage.x2.XXXX, AnimateSprite avec Anim_End_FE_dyn qui modifie une opérande suba, vscroll.obj.map.page / vscroll.obj.map.address auto-modifiés par _vscroll.setMap, objectWave.data.page / objectWave.data.cursor, ObjectMove avec @a+1 modifié par sex pour propagation de signe, BankSwitch avec @page modifié, RunPgSubRoutine avec PSR_Page / PSR_Address / PSR_Param, gfxlock.screenBorder.color, gfxlock.backProcess.routine auto-modifiés), gain de cycles vs lecture variable (économise 1-2 cycles par accès), conventions de naming (equ *-1 ou equ *-2 pour pointer l'opérande), risques (re-entrée, IRQ pendant modification, page commutation). Utiliser pour comprendre le code engine qui apparaît étrange (jmp/jsr vers $0000 auto-modifiés), implémenter une optimisation de code auto-modifié, déboguer une routine avec valeur auto-modifiée, propager une valeur dans plusieurs instances. Mots-clés : DynCode, DynCode_ApplyAToListX, self-modifying code, auto-modif, equ *-1, equ *-2, jsr >0, lda #0, modif opérande, terrainCollision.main.page, vscroll.tiles.nbLinesByPage, PSR_Page, PSR_Address, PSR_Param, Anim_End_FE_dyn, optimization, cycle saving, dynamic code generation, code patching, runtime patch."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# DynCode — code auto-modifié

L'engine utilise massivement la technique du **code auto-modifié** (self-modifying code) pour optimiser les routines critiques. Le 6809 le permet trivialement (pas de cache, mémoire = mémoire).

Cette technique consiste à **modifier les opérandes d'instructions à runtime** pour économiser une indirection (lecture de variable). Économie : ~2 cycles par accès.

---

## Pattern de base

```asm
        lda   #0                        ; valeur dynamique
my_var  equ *-1                          ; pointe vers l'opérande de lda

        ; ailleurs dans le code :
        ldb   #42
        stb   my_var                     ; modifie l'opérande
        ; maintenant lda #42 sera exécuté
```

Au lieu de :
```asm
        lda   my_var                    ; lecture mémoire (3 cycles)
my_var  fcb 0
```

L'auto-modif fait `lda #imm` (2 cycles) qu'on peut modifier en place.

## `DynCode_ApplyAToListX` — utilitaire

```asm
DynCode_ApplyAToListX
        pshs  u
@loop   ldu   ,x++                      ; lit une adresse depuis la liste
        cmpu  #-1                       ; -1 = fin
        beq   @end
        sta   ,u                        ; écrit A à cette adresse
        bra   @loop
@end    puls  u,pc
```

Usage :
```asm
        lda   #new_value
        ldx   #targets
        jsr   DynCode_ApplyAToListX
        
targets fdb   target_1                  ; liste d'adresses à modifier
        fdb   target_2
        fdb   target_3
        fdb   $FFFF                     ; fin (= -1 en signed)
```

Permet de **propager une valeur dans plusieurs instances** d'un seul coup. Utile quand une valeur (e.g. page mémoire) est utilisée à plusieurs endroits du code.

Voir [references/dyncode-utilities.md](references/dyncode-utilities.md).

---

## Exemples massifs dans l'engine

### `terrainCollision` (r-type)

```asm
terrainCollision.do
        _GetCartPageA
        sta   @page
        lda   #0
terrainCollision.main.page equ *-1      ; opérande dynamique
        _SetCartPageA
        jsr   >0
terrainCollision.main.address equ *-2   ; opérande dynamique (2 octets)
```

Le `lda #0` et `jsr >0` ont leurs opérandes modifiés à l'init par `_terrainCollision.init` :
```asm
_terrainCollision.init MACRO
        lda   Obj_Index_Page+\1
        sta   terrainCollision.main.page
        ldd   Obj_Index_Address+2*\1
        std   terrainCollision.main.address
        ; ... idem pour doRight, doLeft, update ...
 ENDM
```

Économie : pas de lookup à runtime, juste une instruction `jsr` directe.

### `vscroll`

```asm
_vscroll.setUpdateRoutine_ MACRO
        sta   vscroll.tiles.nbLinesByPage
        asra
        ldx   #vscroll.tiles.dyncall
        ldx   a,x
        stx   vscroll.tiles.updateTilesForNLines.address
        lda   vscroll.tiles.nbLinesByPage
        asla
        sta   vscroll.tiles.nbLinesByPage.x2.0001    ; 16 instances
        sta   vscroll.tiles.nbLinesByPage.x2.0010
        sta   vscroll.tiles.nbLinesByPage.x2.0011
        ; ... 16 fois ...
 ENDM
```

Le même octet est propagé dans 16 endroits du code (un par mode de scroll selon la position).

### `ObjectMove` — propagation du signe

```asm
ObjectMove
        ldb   x_vel,u
        sex                             ; sign extend : A = $00 si B+, $FF si B-
        sta   @a+1                      ; auto-modif l'opérande qui suit
        ldd   x_vel,u
        addd  x_pos+1,u
        std   x_pos+1,u
        lda   x_pos,u
@a
        adca  #$00                      ; (modifié dynamiquement)
        sta   x_pos,u
        rts
```

Au lieu d'une branche conditionnelle (positif/négatif), on modifie l'opérande de `adca #imm` pour gérer la propagation signed. Économie : 4-5 cycles par appel.

### `RunPgSubRoutine`

```asm
RunPgSubRoutine
        _GetCartPageA
        sta   @page                     ; sauve page sortante
        lda   #0
PSR_Page equ *-1                        ; modif par _RunObjectSwap
        _SetCartPageA
        lda   #0
PSR_Param equ *-1                       ; param optionnel
        jsr   >0
PSR_Address equ *-2                     ; modif par _RunObjectSwap
        lda   #0
@page   equ *-1
        _SetCartPageA                   ; restore
        rts
```

Permet d'appeler n'importe quelle routine dans n'importe quelle page sans table de dispatch.

### `gfxlock.bufferSwap.do`

```asm
gfxlock.bufferSwap.do
        ldb   gfxlock.backBuffer.status
        andb  #%01000000
        orb   #%10000000
gfxlock.screenBorder.color equ *-1      ; opérande modifiée par update
        stb   map.CF74021.SYS2
        ; ...
```

La couleur de bordure est l'opérande d'un `orb #imm`. Modifiée par `gfxlock.screenBorder.update`.

### `AnimateSprite`

```asm
Anim_End_FE
        ; ...
        lda   anim_frame,u
        stb   Anim_End_FE_dyn+1         ; auto-modif
        suba  #$00                      ; (modifié dynamiquement)
Anim_End_FE_dyn
        ; ...
```

Le `suba #imm` a son opérande modifié par l'octet lu depuis le script d'animation.

---

## Conventions de naming

### `equ *-1` / `equ *-2`

```asm
        lda   #0                        ; instruction lda #imm (2 octets)
my_label equ *-1                         ; pointe vers le byte imm
```

`*` = position courante. `*-1` = adresse du byte d'opérande. C'est l'endroit où on écrit pour modifier.

Pour `ldd #imm16` ou `jsr >abs16` (3 octets) :
```asm
        ldd   #0
my_d_label equ *-2                       ; pointe vers les 2 octets opérande
        jsr   >0
my_jsr_label equ *-2                     ; idem pour jsr abs16
```

### Naming conventions

- `<routine>.<purpose>.page` / `<routine>.<purpose>.address` pour mount cross-page
- `@dyn`, `@dynb` (préfixe @) pour les noms locaux à une routine
- `PSR_<X>` pour `RunPgSubRoutine`
- `<routine>_dyn` pour des modifications dans la même routine

---

## Risques

### Re-entrée

Si une routine auto-modifiée est appelée depuis l'IRQ pendant qu'elle est en cours d'exécution dans MainLoop, l'IRQ peut modifier les opérandes en plein milieu. Comportement imprévisible.

Mitigation :
- Routines auto-modifiées **NON re-entrantes** : ne pas appeler depuis IRQ
- Si nécessaire : `IrqPause` autour de l'appel

### IRQ pendant modification

Même problème dans l'autre sens : si on modifie une opérande pendant qu'une IRQ tire la routine, l'IRQ peut exécuter avec un opérande à moitié écrit (1 octet sur 2 modifié).

Mitigation : modifier les opérandes 1 octet (rare) ou utiliser des couplages cohérents.

### Mémoire ROM

Le code auto-modifié **ne peut pas** vivre en ROM (ROM = read-only). Doit être en RAM.

C'est pour ça que les routines auto-modifiées comme `RunPgSubRoutine`, `terrainCollision`, `gfxlock` sont placées dans des modules engine **inclus dans le code du game-mode** (pas en cartouche T2 read-only). En T2, le main engine est copié en RAM au boot.

---

## Quand utiliser DynCode

- **Routines critiques** appelées des milliers de fois par frame (gain cumulé important)
- **Valeurs stables** entre les appels (page mémoire, paramètre invariant pendant N frames)
- **Pas re-entrant** (pas appelée depuis IRQ)
- **Code en RAM** (impossible en ROM)

## Quand NE PAS utiliser

- Code re-entrant (IRQ + MainLoop)
- Valeurs qui changent souvent (autant lire la variable)
- Code partagé entre game-modes en ROM
- Lisibilité critique (le code auto-modifié est plus dur à débugger)

## Patterns avancés

### Patch de plusieurs sites depuis un point

```asm
update_color
        sta   target_1+2                ; modif opérande
        sta   target_2+2
        sta   target_3+2
        ; ...
        rts
```

Ou via `DynCode_ApplyAToListX` pour des listes longues.

### Dispatch dynamique sans table

```asm
        ; Modifier directement le jmp pour basculer entre modes
        ldx   #routine_a
        stx   my_jmp+1                  ; modif l'opérande de jmp
        ; ...
my_jmp  jmp   >0                        ; (modifié dynamiquement)
```

Plus rapide qu'un `jmp [d,x]` indirect.

### Combo avec page commutation

```asm
        ; Setup pour appeler une routine dans une autre page
        lda   #page_target
        sta   PSR_Page
        ldd   #routine_target
        std   PSR_Address
        jsr   RunPgSubRoutine
```

Très efficace pour les appels cross-page.

---

## Débugging

Le code auto-modifié est **difficile à débugger** :
- Le listing LWASM montre les valeurs initiales (typiquement `0`)
- Le runtime utilise les valeurs modifiées
- Les outils statiques (grep, analyse de code) peuvent passer à côté

Astuces :
- Documenter les `equ *-1` clairement dans les commentaires
- Tracer les écritures vers les opérandes
- Utiliser un émulateur (DCMOTO) avec breakpoints sur écritures

## Pitfalls

- **Confondre opérande et instruction** : `lda #0` a son opérande à offset +1 (`*-1`), `ldd #0` à offset +1 sur 2 octets
- **Modifier 1 octet sur 2** : si l'opérande fait 2 octets et qu'on n'écrit qu'un, valeur garbage
- **Re-entrée IRQ** : modification écrasée par l'IRQ
- **Code en ROM** : modification silencieusement ignorée (la write disparaît)
- **Oublier le `*-2`** pour les opérandes 2 octets
- **Modifier sans cleaner avant** : valeur résiduelle d'un usage précédent
- **`DynCode_ApplyAToListX` sans `$FFFF` à la fin** : lecture infinie, crash

## Références détaillées

- [references/dyncode-utilities.md](references/dyncode-utilities.md) — DynCode_ApplyAToListX algorithm et usage, format liste $FFFF terminator, propagation de valeurs vers multiples sites
- [references/selfmod-patterns.md](references/selfmod-patterns.md) — Patterns observés : `equ *-1` / `*-2`, propagation de signe (ObjectMove avec sex), dispatch dynamique sans table, page mounting cross-page (PSR_Page/Address), patch de plusieurs sites, cas terrainCollision/vscroll/gfxlock
