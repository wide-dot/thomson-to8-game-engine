---
name: thomson-to8-engine-irq
description: "Décrit le système d'interruption (IRQ) du Thomson TO8/TO9 game engine (Bento8/wide-dot) : IRQ manager via timer 6846 MC6846, routines IrqInit (init TIMERPT, default IrqManager), IrqSet50Hz (timer precision x8, déclenchement chaque frame, $42 dans MC6846.TCR), IrqOn / IrqOff / IrqPause / IrqUnpause, IrqSync pour synchroniser le timer avec une ligne écran spécifique (input A=line 0-255, X=timer value), variables Irq_user_routine (FDB vers la routine utilisateur), Irq_one_frame (= 312*64-1, timer pour 1 frame), Irq_one_line (= 64 cycles), IrqManager (entry IRQ avec dp=$E7, exécute Irq_user_routine), patterns UserIRQ pour PalUpdateNow / PalCycling / PalRaster_1c / MusicFrame / IrqObjSmps / IrqTimer, raster IRQ pour effets de palette à mi-écran, IrqObjSmps pour le driver SMPS (mount page Smps, jmp ,x), IrqSecond pour compter les secondes (glb_timer_frame, glb_timer compté 50 frames = 1 seconde, mn ss = 60s + s), integration avec gfxlock.bufferSwap.check pour double buffer, special mode glb_Page=0 pour éviter test RAM/ROM page switch (lecture/écriture rapide <$E6), pre/post hook user routine. Utiliser pour configurer l'IRQ utilisateur, synchroniser le rendu avec le VBL, mettre en place des effets raster (changement palette ou registre vidéo à mi-écran), intégrer un driver audio dans l'IRQ, gérer un timer en secondes, mettre/lever en pause les IRQ pendant une opération critique. Mots-clés : IrqInit, IrqOn, IrqOff, IrqPause, IrqUnpause, IrqSync, IrqSet50Hz, IrqManager, IrqObjSmps, IrqSecond, IrqTimer, Irq_user_routine, Irq_one_frame, Irq_one_line, UserIRQ, TIMERPT, MC6846.TCR, MC6846.TMSB, $6019 STATUS, $42 timer precision, 6846 timer, 312 lignes, 64 cycles per line, 50Hz, 60Hz, gfxlock.bufferSwap.check, glb_Page, glb_timer, glb_timer_frame, glb_timer_minute, glb_timer_second, raster IRQ, palette raster, scanline IRQ, Smps integration, SFXPriorityVal, TempoTimeout, CurrentTempo, StopMusic, FadeOut, FadeIn, VoiceTblPtr, SFXVoiceTblPtr, DACEnabled, andcc EF, orcc 10, sei, cli."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# IRQ — Thomson TO8/TO9 Game Engine

Le système d'IRQ permet d'exécuter du code **à intervalle régulier** (typiquement chaque VBL = 50 Hz) en parallèle de la `MainLoop`. C'est ce qui rend possibles : la musique synchronisée, le double-buffer vidéo, les effets raster palette, et le compteur temps réel.

Ce skill couvre : la mécanique du timer 6846, les routines de gestion (`IrqInit`/`IrqSync`/`IrqOn`/`IrqOff`), les patterns de `UserIRQ`, l'intégration avec `gfxlock` et l'audio.

---

## Vue d'ensemble

```
Boot :  IrqInit  →  TIMERPT = IrqManager
        IrqSet50Hz  ou  IrqSync  →  configure timer
        configure Irq_user_routine = UserIRQ
        IrqOn  →  active CPU IRQ

Run :   À chaque tick timer (50 Hz typiquement) :
          Hardware → IRQ → IrqManager
          IrqManager : pre-hooks engine
                       jsr Irq_user_routine (= UserIRQ)
                       post-hooks engine
                       RTI
```

## Hardware — timer 6846 (MC6846)

Le 6846 est le timer hardware du TO8.

```asm
MC6846.TCR    equ  $6010-$6018          ; Timer Control Register (selon offset)
MC6846.TMSB   equ  $6014                ; Timer MSB
MC6846.TLSB   equ  $6015                ; Timer LSB
```

(Adresses exactes selon `engine/system/to8/map.const.asm`.)

Le timer décompte du value `TMSB:TLSB` vers 0 ; à 0, il déclenche une IRQ et redémarre.

### `IrqInit`

```asm
IrqInit
        ldd   #IrqManager
        std   TIMERPT                   ; pointer IRQ vers notre manager
        rts
```

`TIMERPT` (`$6024`) est le vecteur IRQ. On y pose `IrqManager` (notre routine engine).

### `IrqSet50Hz`

```asm
IrqSet50Hz
        ldb   #$42
        stb   MC6846.TCR                ; timer precision x8
        ldd   #Irq_one_frame
        std   MC6846.TMSB
        jsr   IrqOn
        rts
```

Configure le timer pour 1 IRQ par frame (50 Hz).

`Irq_one_frame = 312*64-1 = 19967` :
- 312 lignes par frame (PAL)
- 64 cycles par ligne (à 1 MHz)
- -1 car le timer launch à -1 (compte 0 → -1 → reload)

### `IrqSync`

Synchronise le timer avec une **ligne écran spécifique**. Utile pour les effets raster.

```asm
IrqSync                                 ; A=ligne, X=timer
        ; ... attend que la ligne soit atteinte ...
        ldd   #...
        std   MC6846.TMSB
        rts
```

Usage :
```asm
        lda   #255                      ; sync ligne 255 (hors zone visible)
        ldx   #Irq_one_frame
        jsr   IrqSync
```

L'IRQ se déclenche désormais à la ligne 255 (juste avant le retour de balayage, donc pendant le VBL → safe pour modifier la palette).

## `IrqOn` / `IrqOff` / `IrqPause` / `IrqUnpause`

```asm
IrqOn
        lda   $6019
        ora   #$20
        sta   $6019                     ; STATUS bit 5 = IRQ enable
        andcc #$EF                      ; CPU : flag I = 0 (IRQ enabled)
        rts

IrqOff
        lda   $6019
        anda  #$DF
        sta   $6019                     ; STATUS bit 5 = 0
        orcc  #$10                      ; CPU : flag I = 1 (IRQ masked)
        rts
```

`IrqOn` / `IrqOff` modifient **à la fois** le hardware (registre STATUS) et le CPU (flag I).

`IrqPause` / `IrqUnpause` sont des versions « stack-safe » qui se souviennent de l'état précédent :

```asm
        jsr   IrqPause                  ; off + remember
        ; ... section critique ...
        jsr   IrqUnpause                ; restore previous state
```

Permet d'imbriquer sans risque d'oublier de réactiver les IRQ.

## `IrqManager` — le dispatcher

```asm
IrqManager
        ; pre-hooks engine (e.g. read joypads, save bank)
        jsr   Irq_user_routine          ; appel utilisateur
        ; post-hooks engine
        rti
```

L'IRQ est lancée par le hardware. `IrqManager` :
1. Sauve les registres si nécessaire (le 6809 sauvegarde automatiquement A,B,DP,X,Y,U,PC sur la pile à l'IRQ, mais pas tous selon flags)
2. Exécute des hooks engine (pre)
3. Appelle `Irq_user_routine`
4. Exécute des hooks engine (post)
5. `rti` (return from interrupt)

### `glb_Page = 0` — special mode

Quand `glb_Page = 0`, le manager **ne fait pas** le test RAM/ROM pour le page switch — il assume RAM toujours. Économie de cycles pour les modes intensifs (tile rendering).

## `Irq_user_routine`

```asm
Irq_user_routine    fdb   0             ; pointeur 2 octets vers UserIRQ
```

Variable globale qui pointe la routine utilisateur appelée à chaque IRQ. À configurer au boot :

```asm
        jsr   IrqInit
        ldd   #UserIRQ                  ; notre routine
        std   Irq_user_routine
        lda   #255
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn
```

## Patterns de `UserIRQ`

### Minimal (palette seule)

```asm
UserIRQ
        jmp   PalUpdateNow
```

Saute directement à PalUpdateNow qui termine par `rts`.

### Avec gfxlock + audio (typique)

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

### Avec raster

```asm
UserIRQ
        jsr   PalRaster_1c              ; raster palette
        jsr   PalUpdateNow              ; (overwrite ce que raster a fait pour la zone normale)
        rts
```

### Avec SMPS (sonic-2)

```asm
UserIRQ_Pal_Smps
        jsr   PalUpdateNow
        jmp   MusicFrame                ; SMPS tick
```

Plusieurs UserIRQ peuvent coexister, bascule par modification de `Irq_user_routine`.

## `IrqObjSmps`

Wrapper pour appeler le driver SMPS comme un objet :

```asm
IrqObjSmps
        lda   Obj_Index_Page+ObjID_Smps
        sta   <$E6                      ; mount Smps page
        lda   #4                        ; MusicFrame routine id
        ldx   Obj_Index_Address+2*ObjID_Smps
        jmp   ,x                        ; call Smps + rti
```

Intégration de SMPS dans le système d'objet. Utilisé par sonic-2.

## `IrqSecond` — compteur temps réel

```asm
IrqSecond
        lda   glb_timer_frame
        inca
        cmpa  #50                       ; 50 frames = 1 seconde
        bne   @skip
        ldd   glb_timer
        incb                            ; +1 seconde
        cmpb  #60                       ; 60 secondes = 1 minute
        bne   >
        ldb   #0
        inca                            ; +1 minute
!       std   glb_timer
        lda   #0
@skip   sta   glb_timer_frame
        rts
```

Variables :
```asm
glb_timer_frame                ; compte 0-49
glb_timer_second               ; compte 0-59
glb_timer_minute               ; compte 0-99 typiquement
glb_timer  = glb_timer_minute  ; alias 2 octets pour ldd
```

À appeler dans UserIRQ pour avoir un compteur précis :
```asm
UserIRQ
        jsr   IrqSecond                  ; compte le temps écoulé
        ; ...
        rts
```

Affichage : `glb_timer_minute:glb_timer_second` (e.g. pour un score / time bonus).

## Effets raster — palette à mi-écran

```asm
        ; Setup
        lda   #100                      ; ligne 100 (milieu écran)
        ldx   #Irq_one_frame
        jsr   IrqSync
        ldd   #UserIRQ_RasterMid
        std   Irq_user_routine

UserIRQ_RasterMid
        ; on est à la ligne 100, on peut changer une couleur
        lda   #new_color
        sta   $E7DA
        ; reconfigurer pour la prochaine IRQ (fin de frame typiquement)
        lda   #255
        ldx   #Irq_one_frame
        jsr   IrqSync                   ; OK depuis IRQ ? cf. doc
        rti
```

Pattern plus avancé : multiples IRQ par frame pour cascade d'effets raster.

## DP dans UserIRQ — important

Le monitor système TO8 positionne `DP = $E7` **avant d'appeler le handler IRQ**, et `IrqManager` confirme ça avec `setdp $E7`. C'est ce qui permet aux routines appelées depuis UserIRQ (PalUpdateNow, PalRaster_1c, ...) d'utiliser `<$DA`/`<$DB`/`<$DC` etc. pour accéder aux registres hardware $E7xx en 1 cycle de moins.

**Conséquence pratique** :
- Dans UserIRQ et dans les routines appelées depuis UserIRQ : `<addr` OK pour $E7xx
- Si tu modifies DP dans UserIRQ : restaurer avant le `rts` (`pshs dp` / `puls dp`)
- Dans le code main résident : DP non garanti, **ne pas** utiliser `<addr` sans setup explicite

Voir `thomson-to8-engine-memory-model/references/direct-page-usage.md` pour les patterns DP complets.

## Pitfalls

- **`<addr` (Direct Page) appelé depuis le code main** : DP n'est pas garanti dans le code résident, écriture au mauvais endroit. Bug silencieux. À ne JAMAIS faire dans `org $6100` / MainLoop sans setup explicite.
- **Modifier DP dans UserIRQ sans restore** : casse les routines suivantes qui assument DP=$E7. Toujours `pshs dp` / `puls dp` autour des modifications.
- **`Irq_user_routine` à 0** : `jsr` vers $0000 → crash
- **`IrqOn` sans `IrqInit`** : `TIMERPT` non set, IRQ saute n'importe où
- **`Irq_user_routine` qui ne se termine pas par `rts`** : la `rti` de IrqManager n'est pas atteinte → état CPU instable
- **`andcc #$EF`** au lieu de `orcc #$10` (ou inverse) : inversion du flag I
- **Modifier `Irq_user_routine` pendant une IRQ** : race condition, peut sauter à la mauvaise routine
- **Routine UserIRQ trop longue** : déborde sur le frame suivant, l'IRQ suivante arrive avant la fin → re-entrée
- **`rti` au lieu de `rts` dans UserIRQ** : pop le PC + flags depuis la pile (incorrect, le manager s'occupe du rti)
- **Modifier `glb_Page`** : casse le special mode, ralentissement
- **Effet raster avec mauvais timing IRQ** : changement de palette au mauvais moment → flicker

---

## Références détaillées

- [references/irq-init-and-sync.md](references/irq-init-and-sync.md) — IrqInit / IrqSet50Hz / IrqSync détaillés, calcul Irq_one_frame (312*64-1), MC6846 hardware, TIMERPT vecteur, configuration timer precision x8, IrqOn / IrqOff / IrqPause / IrqUnpause stack-safe
- [references/user-irq-patterns.md](references/user-irq-patterns.md) — Patterns UserIRQ : minimal (palette), gfxlock + audio (ymm/vgc), SMPS, raster, IrqSecond compteur, intégration multiple, IRQ routine length budget, ordre d'appel
- [references/raster-irq.md](references/raster-irq.md) — IRQ pour effets raster : IrqSync sur ligne spécifique, multiples IRQ par frame, changement palette mi-écran, sync hardware spot via `<$E7`, calibrage tempo, intégration avec PalRaster_1c
