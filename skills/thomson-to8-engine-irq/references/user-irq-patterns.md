# Patterns d'UserIRQ

## Variable `Irq_user_routine`

```asm
Irq_user_routine    fdb   0
```

Pointeur 2 octets vers la routine utilisateur. Configurée au boot :

```asm
        ldd   #UserIRQ
        std   Irq_user_routine
```

L'IRQ manager fait `jsr [Irq_user_routine]` à chaque tick.

## ⚠️ Important : DP = $E7 dans UserIRQ

Quand UserIRQ s'exécute, le registre **DP du 6809 vaut `$E7`** — c'est garanti par :
1. Le monitor système TO8 qui pose DP=$E7 avant de sauter au handler IRQ
2. `IrqManager` qui confirme via `setdp $E7` au début

Cela permet d'utiliser **l'adressage direct page** dans UserIRQ pour accéder aux registres hardware en `$E7xx` (palette, PIA, gate array) avec 1 cycle économisé par instruction :

```asm
UserIRQ
        ; DP = $E7 ici → <$DB ≡ $E7DB (1 cycle de moins que $E7DB)
        lda   <$DB                ; palette index register
        lda   <$DD                ; screen border
        rts
```

C'est ce qui rend `PalUpdateNow`, `PalRaster_1c`, etc. très rapides — elles utilisent massivement `<$DA`/`<$DB`.

**Inversement, dans le code main résident**, DP n'est PAS positionné automatiquement → ne **JAMAIS** utiliser `<addr` dans le code main d'un game-mode sauf setup explicite. Cf. `thomson-to8-engine-memory-model/references/direct-page-usage.md`.

**Si tu modifies DP dans UserIRQ** (e.g. tu set DP=$9F pour accéder à ta zone DP user), pense à le restaurer à $E7 avant `rts` — sinon les hooks engine post-UserIRQ ne fonctionneront pas. Le pattern recommandé :

```asm
UserIRQ
        pshs  dp                   ; sauve DP=$E7
        ; ... change DP, fait du travail ...
        puls  dp                   ; restaure DP=$E7
        rts
```

## Patterns courants

### 1. Minimal (palette seule)

```asm
UserIRQ
        jmp   PalUpdateNow              ; (termine par rts, donc jmp OK)
```

Pour un game-mode sans gfxlock ni audio. Suffit pour appliquer les changements de palette demandés.

### 2. Avec gfxlock + double-buffer

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check  ; swap buffers si rendu prêt
        jsr   PalUpdateNow
        rts
```

Le `bufferSwap.check` est crucial : il fait le swap **uniquement si** `gfxlock.status = 0` (rendu fini). Sinon il attend.

### 3. Avec audio ymm + vgc (pattern courant)

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        _MountObject ObjID_ymm
        _ymm.processFrame
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts
```

L'ordre est important :
1. Buffer swap (avant que la nouvelle frame commence à être tracée)
2. Palette update (les changements de palette demandés dans la frame précédente)
3. Audio tick (les chips audio sont updatés à la fin)

### 4. Avec SMPS (sonic-2 style)

```asm
UserIRQ_Pal_Smps
        jsr   PalUpdateNow
        jmp   MusicFrame                ; SMPS tick + rts
```

Plus simple : pas de gfxlock dans sonic-2 (utilise `WaitVBL`).

### 5. Avec raster (mid-screen palette change)

```asm
UserIRQ_Raster
        jsr   PalRaster_1c              ; change palette ligne par ligne
        jsr   PalUpdateNow              ; restore palette normale en fin
        jmp   MusicFrame
```

L'ordre permet d'avoir l'effet raster pendant l'affichage, puis revenir à la palette normale pour la prochaine frame.

### 6. Avec timer (compteur temps réel)

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        jsr   IrqSecond                  ; compte le temps
        ; audio ...
        rts
```

## Bascule entre plusieurs UserIRQ

```asm
        ; Configuration 1 : intro avec raster
        ldd   #UserIRQ_Raster
        std   Irq_user_routine

        ; ... attendre que l'intro soit finie ...

        ; Configuration 2 : gameplay normal
        ldd   #UserIRQ_Normal
        std   Irq_user_routine
```

La modification de `Irq_user_routine` est immédiate (prochaine IRQ utilise la nouvelle adresse).

> **Race condition possible** : si on modifie `Irq_user_routine` pendant que l'IRQ est en cours, le `jsr [Irq_user_routine]` peut sauter à mi-modification. Pour être 100% safe : `IrqPause` avant la modif, `IrqUnpause` après.

## Ordre d'appel — règles

### À mettre AVANT l'audio
- `gfxlock.bufferSwap.check` : peut être bloquant si rendu non fini, doit être tôt
- `PalUpdateNow` : applique les couleurs avant que l'IRQ déclenche d'autres effets

### À mettre APRÈS l'audio
- `IrqSecond` : compte le temps, indépendant du reste
- Mises à jour de variables globales non-critiques

### Tout au début
- `gfxlock.bufferSwap.check` : si on lui fait le swap, on veut que ça soit aussi tôt que possible pour minimiser le tearing

### Tout à la fin
- Routines qui peuvent prendre du temps si on est sûr qu'elles ne ratent pas la fin de la frame

## Budget temps

L'IRQ a un budget **strict** : doit finir avant la prochaine IRQ (= 20 ms = 20000 cycles à 1 MHz).

En pratique :
- `bufferSwap.check` : ~50-100 cycles
- `PalUpdateNow` : ~150 cycles (déroulée) ou ~225 (lean)
- `_ymm.processFrame` : ~1500 cycles (avec compression)
- `_MusicFrame_objvgc` : ~1000-1500 cycles
- `IrqSecond` : ~30 cycles
- **Total typique** : ~3000-4000 cycles (~15-20 % du budget)

Reste ~16000 cycles pour la MainLoop par frame.

### Dépassement du budget

Si UserIRQ prend > 20000 cycles, la prochaine IRQ arrive **avant** la fin → re-entrée. Le CPU 6809 a un flag I qui masque les IRQ pendant l'exécution d'une IRQ, donc la re-entrée n'a pas lieu *immédiatement*, mais la MainLoop n'a aucun temps CPU → freeze visuel.

## Pattern complexe (r-type level01)

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        _MountObject ObjID_ymm01
        _ymm.processFrame
        ; soundFX tick (si applicable)
        rts
```

Note : r-type a aussi un soundFX system qui tick depuis l'IRQ. Pas vu de `vgc` dans level01 (commenté dans le code).

## Pattern WaitVBL (sans IRQ pour le rendu)

```asm
; Pas d'IRQ pour le rendu (cas legacy ou simple)
MainLoop
        jsr   WaitVBL                   ; attend le VBL manuellement
        jsr   RunObjects
        ; ...

UserIRQ
        jmp   PalUpdateNow              ; juste la palette via IRQ
```

`WaitVBL` est une attente bloquante synchronisée sur le VBL. Plus simple mais bloque le CPU.

## Ne PAS faire dans UserIRQ

- **Allouer/désallouer des objets** (`LoadObject_u`) : modifierait des structures partagées avec MainLoop sans protection
- **Modifier `Irq_user_routine`** depuis UserIRQ : meta-modification, race condition
- **Appels longs** (cinématique, fade complet) : déborde le budget
- **Modifier `gfxlock.status`** : casse la mécanique du double-buffer
- **`jsr` vers du code en page commutée sans `_MountObject`** : crash si la page n'est pas la bonne

## À faire dans UserIRQ

- Lectures de variables non-critiques
- Tick audio (mécanique synchronisée timer)
- Updates de palette (synchro VBL)
- Compteurs temps
- Buffer swap (gfxlock)

## Restauration d'état

Le 6809 sauve automatiquement à l'IRQ : `PC, U, Y, X, DP, B, A, CC` sur la pile S. À la `rti`, il restore.

Si on modifie d'autres choses dans UserIRQ (bank, DP, etc.), il faut explicitement **restaurer avant `rts`** :

```asm
UserIRQ
        pshs  dp                        ; sauve DP
        ldd   #$E7
        tfr   b,dp                      ; DP = $E7 pour accès direct page
        ; ... travail ...
        puls  dp                        ; restore DP
        rts
```

`PalUpdateNow` le fait (`pshs dp` / `puls dp,pc`).

## Pitfalls

- **`Irq_user_routine` à 0** : `jsr` vers $0000 → crash
- **UserIRQ qui se termine sans `rts`** : tombe sur du code aléatoire → crash
- **`rti` au lieu de `rts` dans UserIRQ** : pop additionnel sur la pile, déséquilibre
- **Modifications non protégées de variables partagées** : MainLoop voit des valeurs incohérentes
- **Allocation d'objet dans UserIRQ** : race condition avec MainLoop
- **`pshs` sans `puls`** : pile corrompue
- **DP non restauré** : appelant crash
