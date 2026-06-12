# Usage du Direct Page (DP)

Le 6809 a un registre **DP** (Direct Page) de 8 bits qui définit la page haute pour le mode d'adressage **direct** (notation asm `<addr` ou `addr,dp`). Une instruction en mode direct économise **1 octet et 1 cycle** par accès — c'est tentant pour optimiser, mais le DP doit être **positionné explicitement** sinon les accès tombent au mauvais endroit.

---

## ⚠️ Règle critique : DP n'est PAS auto-positionné

| Contexte | Valeur de DP au runtime | Conséquence |
|----------|-------------------------|-------------|
| Code résident (`org $6100` du game-mode, MainLoop, routines applicatives) | **Inconnue** (souvent 0, ou valeur résiduelle) | `<addr` lit/écrit à `(DP_actuel)*256 + offset` — généralement en `$00xx` au lieu de la zone attendue → **bug silencieux** |
| `UserIRQ` (appelée par `IrqManager`) | **$E7** (positionné par le monitor + confirmé par `setdp $E7` dans IrqManager) | `<addr` accède aux registres `$E7xx` (palette, hardware) sans surcoût — **OK** |
| Routine engine avec `setdp` + `tfr a,dp` explicite (ex: `PalUpdateNow`) | Valeur définie par la routine, restaurée à la sortie via `pshs dp`/`puls dp` | OK dans le périmètre de la routine |

**Erreur classique** : écrire dans le code main d'un game-mode :
```asm
        lda   #50
        sta   <horizon_y     ; ← FAUX si DP n'est pas set
```

Si DP vaut 0 au moment de cet appel, `sta <horizon_y` écrit en `$0000 + (horizon_y & $FF)`, c'est-à-dire **en zone cartouche** (page 0). Pas du tout là où la variable réside.

**Correction** :
```asm
        lda   #50
        sta   horizon_y      ; mode étendu — toujours correct
```

L'adressage étendu fait référence à l'adresse absolue (16 bits), indépendamment du DP.

---

## Quand utiliser le DP, quand l'éviter

### ❌ Ne PAS utiliser `<addr` dans le code résident

Sauf si tu **maîtrises** la valeur du DP à ce moment précis (e.g. tu viens de faire `lda #$XX; tfr a,dp` toi-même), n'utilise pas l'adressage direct.

**Coût** : ~1 cycle/accès — négligeable dans 95% des cas. La sécurité prime.

### ✅ Utiliser `<addr` dans `UserIRQ`

Le monitor positionne **DP = $E7** avant d'appeler l'IRQ handler. `IrqManager` confirme ça avec `setdp $E7` au début. Donc dans UserIRQ :

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow       ; cette routine gère son propre DP
        ; ICI : DP = $E7
        ; lda <$DB                ← OK, équivalent à lda $E7DB
        ; ...
        rts
```

C'est ce qui permet à `PalUpdateNow` et `PalRaster_1c` d'utiliser massivement `<$DA`, `<$DB`, etc. pour les registres palette — c'est ~30% plus rapide que `$E7DA`/`$E7DB` en mode étendu.

### ✅ Utiliser `<addr` dans une routine spécialisée qui set DP localement

Pattern classique pour les routines engine optimisées :

```asm
MyOptimizedRoutine
        pshs  dp                  ; sauve DP de l'appelant
        ldd   #$9F
        tfr   b,dp                ; positionne DP = $9F
        setdp $9F                 ; (directive LWASM, statique)
        
        ; ... maintenant on peut utiliser <addr pour accéder à $9F00-$9FFF rapidement ...
        ldd   <ma_var             ; = ldd $9F00 + offset(ma_var)
        
        setdp dp/256              ; (reset directive pour la suite)
        puls  dp,pc               ; restaure DP de l'appelant
```

Note les **deux** opérations :
1. `tfr b,dp` : positionne DP **au runtime**
2. `setdp $9F` : indique au **compilateur LWASM** la valeur de DP, pour qu'il génère des `<addr` correctement

L'oubli de `setdp` provoque des erreurs de compilation (`addr` hors range direct page) OU des `<addr` mal calculés. L'oubli de `tfr` provoque des bugs runtime.

À la sortie, **toujours restaurer DP** via `puls dp` (ou via `setdp dp/256` qui n'est qu'une directive de compilation et ne change pas DP runtime — il faut bien faire les deux).

### ✅ Objet joueur en Direct Page (ObjectDp)

L'engine propose `ObjectDp` qui place tout un OST en Direct Page ($9F00) pour économiser des cycles sur les accès `<x_pos`, `<x_vel`, etc. Cf. skill `object-management`, référence `direct-page-object.md`. Dans ce cas, DP est mis à $9F par le code d'init et le code du joueur peut utiliser `<` librement.

---

## Hiérarchie de la zone DP utilisateur (`$9F00-$9FFF`)

```
$9F00  ┌───────────────────────────────────────────────────────────┐
       │ Zone utilisateur (149 octets max)                         │
       │  → variables globales temporaires partagées (cur_priority, │
       │    cur_ptr_*, etc. — utilisées par les routines engine    │
       │    qui set DP=$9F)                                         │
       │  → OU OST du joueur principal si pattern ObjectDp         │
       │  → OU variables applicatives au choix                     │
       │                                                            │
$9F95  ├───────────────────────────────────────────────────────────┤
       │ dp_extreg (28 octets) — registres étendus (glb_a0/d0,     │
       │ partagés entre routines engine type moveByScript)         │
$9FB1  ├───────────────────────────────────────────────────────────┤
       │ dp_engine (32 octets) — variables temporaires de l'engine │
       │ (cur_priority, cur_ptr_sub_obj_erase/draw, p0..p6 pour    │
       │ DrawHLine, etc.)                                          │
       │                                                            │
$9FE0  ├───────────────────────────────────────────────────────────┤
       │ glb_Page (1 octet) + autres flags globaux                 │
       │                                                            │
       │ ↑ pile système descend depuis $9EFF, voire $9FFF si       │
       │   l'application le permet                                  │
$9FFF  └───────────────────────────────────────────────────────────┘
```

**Important** : les zones `dp_engine` et `dp_extreg` sont utilisées par des routines engine qui font `setdp $9F` localement. Ne PAS modifier ces emplacements depuis le code applicatif sauf si on sait exactement ce qu'on fait — sinon corruption silencieuse.

---

## Patterns concrets

### Code main (résident) — accès variables globales

```asm
        org $6100
        ; ... init ...
        lda   #50
        sta   horizon_y        ; ✅ mode étendu — toujours correct
        ; sta <horizon_y       ← ❌ NE PAS faire : DP non défini ici

MainLoop
        lda   horizon_y        ; ✅ lecture étendue OK
        ; ...
```

### UserIRQ — peut utiliser `<` pour les registres $E7xx

```asm
UserIRQ
        ; DP = $E7 garanti par le monitor + IrqManager
        jsr   gfxlock.bufferSwap.check    ; gère son DP en interne
        jsr   PalUpdateNow                ; idem
        
        ; Si on veut écrire directement à un registre hardware $E7xx :
        ; lda <$DC             ← OK ≡ lda $E7DC
        ; sta <$DD             ← OK ≡ sta $E7DD
        rts
```

### Routine engine optimisée (e.g. PalUpdateNow)

```asm
PalUpdateNow
        tst   PalRefresh
        bne   @rts
        pshs  dp               ; sauve DP (peut être $E7 si appelée depuis IRQ, autre sinon)
        ldd   #$E7
        tfr   b,dp             ; positionne DP = $E7
        ; (à ce point, setdp $E7 est en vigueur côté compilation)
        ldx   Pal_current
        sta   <$DB             ; = sta $E7DB (1 cycle économisé)
        ; ... boucle qui écrit dans <$DA, <$DB ...
        com   PalRefresh
        puls  dp,pc            ; restaure DP de l'appelant
        setdp dp/256           ; reset directive pour le code suivant
@rts    rts
```

L'idée : **set DP dans le périmètre de la routine, restore à la sortie**. C'est le seul moyen sûr de bénéficier du DP optimisé dans un environnement où le DP global n'est pas garanti.

---

## Pitfalls

- **`sta <var` dans le code résident** : DP non défini → écriture au mauvais endroit. Le bug est silencieux (pas de crash, juste une valeur perdue).
- **`setdp $XX` sans `tfr a,dp`** : la directive compile bien (en supposant DP=$XX) mais le runtime utilise un autre DP → mauvais accès.
- **`tfr a,dp` sans `setdp $XX`** : le runtime est correct mais LWASM peut refuser de compiler `<addr` s'il ne pense pas que addr est dans la page DP.
- **Oublier `pshs dp / puls dp`** dans une routine qui change DP : casse l'appelant.
- **Modifier `dp_engine` / `dp_extreg`** depuis le code applicatif : corrompt les routines engine (cur_priority, glb_a0/d0, etc.) → bugs erratiques.
- **Compter sur DP=$00 par défaut** : c'est probablement le cas au boot mais pas garanti après que le code engine en ait modifié.
- **`<addr` dans une fonction appelée depuis plusieurs contextes** (résident + IRQ) : DP variable selon le contexte → comportement erratique. Préférer adressage étendu OU set DP localement.
