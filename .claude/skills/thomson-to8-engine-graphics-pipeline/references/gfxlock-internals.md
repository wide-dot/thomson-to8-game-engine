# `gfxlock` — internals du double buffering

`gfxlock` (engine/graphics/buffer/gfxlock.asm et gfxlock.macro.asm) gère le **double buffering vidéo** : deux pages physiques alternent, l'une affichée par le hardware vidéo et l'autre en cours d'écriture par la `MainLoop`. L'échange se fait pendant le **VBL** (Vertical Blank Interval) pour éviter le tearing.

## Hardware mappé

Le TO8 utilise deux registres hardware pour la sélection des pages :

| Registre | Adresse | Rôle |
|----------|---------|------|
| `map.CF74021.SYS2` | `$E7E7` | Sélection du buffer **visible** (lu par hardware vidéo) |
| `map.CF74021.DATA` | `$E7E5` | Sélection de la page en zone **donnée** (`$A000-$DFFF`) |
| `map.CF74021.SYS1` | `$E7E6` | Sélection page en zone cartouche (utilisé par BankSwitch) |
| `map.MC6846.PRC` | `$E7C3` | Bit de forme (swap demi-page écran $4000-$5FFF) |
| `$E7DD` | (idem) | Couleur de bordure |

Pour le double buffering :
- `map.CF74021.SYS2 = $80 + (page << 6)` : choisit la page visible (2 ou 3) + couleur de bordure dans le bit 0-3
- `map.CF74021.DATA` : sélectionne la page en `$A000-$DFFF` pour permettre d'y dessiner

## Variables d'état complètes

```asm
gfxlock.status             fcb   0     ; 1 = rendu en cours, 0 = inactif
gfxlock.bufferSwap.status  fcb   0     ; -1 = swap fait, 0 = pas swap
gfxlock.backProcess.status fcb   0     ; 1 = back process actif pendant wait

gfxlock.bufferSwap.count   fdb   0     ; compteur de swaps depuis init
gfxlock.backBuffer.id      fcb   0     ; 0 ou 1, index back-buffer courant
gfxlock.backBuffer.status  fcb   0     ; 0 ou -1, flip/flop interne

gfxlock.frameDrop.count_w  fcb   0     ; zero pad (MSB de count)
gfxlock.frameDrop.count    fcb   0     ; nb 50 Hz frames écoulées depuis main loop
gfxlock.frame.count        fdb   0     ; total 50 Hz frames depuis init
gfxlock.frame.lastCount    fdb   0     ; frame count au dernier render

gfxlock.screenBorder.color fcb $80     ; couleur bordure courante (auto-modifié)
gfxlock.backProcess.routine fdb 0     ; adresse routine back-process
```

## Cycle complet — étape par étape

### 1. `_gfxlock.init` — au boot

```asm
_gfxlock.init MACRO
        lda   #-1
        sta   gfxlock.status            ; status = -1 (init)
        lda   gfxlock.backBuffer.status
        anda  #%00000001
        sta   gfxlock.backBuffer.id     ; id = 0 ou 1 selon status
 ENDM
```

À appeler **après IrqInit et IrqSync, avant IrqOn**. Place `gfxlock.status = -1` (état initial spécial qui empêche le premier `bufferSwap.check` de faire un swap accidentel).

### 2. `_gfxlock.on` — début phase rendu

```asm
_gfxlock.on MACRO
        lda   gfxlock.status
        bne   >                         ; status != 0 → on a déjà rendu cette frame
        jsr   gfxlock.bufferSwap.wait   ; on attend la prochaine VBL
!       lda   #1
        sta   gfxlock.status            ; status = 1 (rendu en cours)
        ; bascule la page de données pour pointer vers le back-buffer
        ldb   gfxlock.backBuffer.status
        andb  #%00000001
        orb   #%00000010                ; valeur 2 ou 3
        stb   map.CF74021.DATA          ; map back-buffer en $A000-$DFFF
        ldb   map.MC6846.PRC
        eorb  #%00000001                ; swap half-page $4000-$5FFF
        stb   map.MC6846.PRC
 ENDM
```

Effet :
- Si on a déjà rendu cette frame (status != 0), on attend (`gfxlock.bufferSwap.wait`) que l'IRQ fasse le swap
- Une fois libre, on mount le back-buffer en zone donnée (`$A000-$DFFF`)
- On swap aussi le bit de forme `map.MC6846.PRC` pour l'écran principal

### 3. Phase rendu — `EraseSprites` / `DrawSprites` / ...

Pendant ce temps, le hardware affiche **l'autre** page (la « visible »). Notre code écrit dans la « back ».

### 4. `_gfxlock.off` — fin phase rendu

```asm
_gfxlock.off MACRO
        clr   gfxlock.status            ; status = 0 (rendu terminé)
 ENDM
```

Très simple : juste un clear. La signalisation au reste du système (l'IRQ qui va swap) se fait via cette variable.

### 5. `_gfxlock.loop` — fin de l'itération

```asm
_gfxlock.loop MACRO
        lda   gfxlock.backBuffer.id     ; flip l'id à la fin
        eora  #%00000001
        sta   gfxlock.backBuffer.id
        ldd   gfxlock.frame.count
        subd  gfxlock.frame.lastCount
        stb   gfxlock.frameDrop.count   ; nb de frames écoulées (1-2 typiquement)
        ldd   gfxlock.frame.count
        std   gfxlock.frame.lastCount
 ENDM
```

Effet :
- Flip `backBuffer.id` (le buffer rendu cette frame deviendra visible à la prochaine VBL)
- Met à jour `frameDrop.count` (combien de frames 50 Hz se sont écoulées depuis le dernier `_gfxlock.loop`)

`frameDrop.count` est crucial pour les routines synchronisées (`AnimateSpriteSync`, `ObjectMoveSync`, `ObjectFallSync`).

### 6. `gfxlock.bufferSwap.check` — appelé depuis UserIRQ

```asm
gfxlock.bufferSwap.check
        lda   gfxlock.status
        bne   >                         ; status != 0 → rendu en cours → pas de swap
        jsr   gfxlock.bufferSwap.do     ; rendu fini → swap
        lda   #-1
        sta   gfxlock.status            ; status = -1 (post-swap, attend prochain on)
!       rts
```

Appelée à chaque VBL via UserIRQ. Si le rendu est complet (status=0), fait le swap et marque -1.

### 7. `gfxlock.bufferSwap.do` — exécute le swap hardware

```asm
gfxlock.bufferSwap.do
        ldb   gfxlock.backBuffer.status
        andb  #%01000000                ; bit 6 basé sur flip/flop
        orb   #%10000000                ; bit 7 = 1, bits 0-3 = couleur frame
gfxlock.screenBorder.color equ *-1      ; (modifié pour bordure)
        stb   map.CF74021.SYS2          ; écrit dans $E7E7 → swap visible buffer
        com   gfxlock.backBuffer.status ; flip status
        inc   gfxlock.bufferSwap.count+1 ; incrémente compteur
        bne   >
        inc   gfxlock.bufferSwap.count
!
        com   gfxlock.bufferSwap.status  ; marque swap fait (-1)
        rts
```

L'écriture dans `$E7E7` est ce qui **change instantanément** la page visible côté hardware.

### 8. `gfxlock.bufferSwap.wait` — attente bloquante

```asm
gfxlock.bufferSwap.wait
        clr   gfxlock.bufferSwap.status
@loop   tst   gfxlock.backProcess.status
        beq   >
        jsr   $1234                     ; do back processing
gfxlock.backProcess.routine equ *-2     ; (modifié par _gfxlock.backProcess.on)
!       lda   gfxlock.status
        bne   >                         ; status != 0 → out
        tst   gfxlock.bufferSwap.status
        beq   @loop                     ; loop jusqu'à swap (status négatif)
!       rts
```

Attente active jusqu'à ce que l'IRQ ait fait un swap. Si une back-process routine est enregistrée, elle est appelée pendant l'attente (utile pour faire du travail asynchrone — décompression, chargement de données).

### 9. `_gfxlock.backProcess.on` — back process

```asm
_gfxlock.backProcess.on MACRO
        ; param 1 : routine address
        ldd   #\1
        std   gfxlock.backProcess
        lda   #1
        sta   gfxlock.backProcess.status
 ENDM
```

Enregistre une routine à appeler pendant `bufferSwap.wait`. Permet de profiter de l'attente pour des opérations en arrière-plan.

## Couleur de bordure — `gfxlock.screenBorder`

```asm
gfxlock.screenBorder.update
        andb  #$0F
        orb   #%10000000
        stb   gfxlock.screenBorder.color
```

Modifie la couleur de bordure (bits 0-3 dans `$E7E7`). Appelée typiquement depuis le code utilisateur pour matcher une palette spécifique :

```asm
        ldb   #15                       ; couleur 15 (blanc en palette par défaut)
        jsr   gfxlock.screenBorder.update
```

## Pattern d'usage canonique

```asm
; Au boot du game-mode
        jsr   InitGlobals
        jsr   InitDrawSprites
        jsr   InitStack
        ; ... autres inits ...
        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255
        ldx   #Irq_one_frame
        jsr   IrqSync
        _gfxlock.init                   ; après IrqSync, AVANT IrqOn
        jsr   IrqOn

MainLoop
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        _gfxlock.on                     ; verrou + mount back-buffer
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        _gfxlock.off                    ; libère
        _gfxlock.loop                   ; flip + update frameDrop
        bra   MainLoop

UserIRQ
        jsr   gfxlock.bufferSwap.check  ; swap si prêt
        jsr   PalUpdateNow
        ; ... audio ...
        rts
```

## `frameDrop.count` — sémantique

| Valeur | Interprétation |
|--------|----------------|
| 1 | Frame rendue dans 1 VBL → 50 fps stable |
| 2 | Frame rendue dans 2 VBL → 25 fps (frame skip) |
| 3+ | Drop massif (lag) |
| 0 | Anormal (cas init seulement) |

Les routines `*Sync` utilisent cette valeur pour multiplier les vitesses/animations :
- À 50 fps : `frameDrop.count_w = 1` → vitesse normale
- À 25 fps : `frameDrop.count_w = 2` → vitesse doublée pour compenser

C'est le mécanisme du **framerate adaptatif** : le gameplay reste « réel-temps » même si le rendu drop.

## Synchronisation IRQ

`IrqSync` configure l'IRQ pour se déclencher juste avant le VBL :

```asm
        lda   #255                      ; ligne 255 (juste avant ligne 0 du prochain frame)
        ldx   #Irq_one_frame            ; une fois par frame
        jsr   IrqSync
```

C'est essentiel pour que `gfxlock.bufferSwap.check` (appelé depuis UserIRQ) ait le temps de faire le swap **avant** que la nouvelle frame commence à être affichée — sinon on aurait du tearing.

## Pitfalls

- **`_gfxlock.init` après `IrqOn`** : la première IRQ peut faire un swap avant init → corruption visuelle. Toujours dans l'ordre : `IrqInit → IrqSync → _gfxlock.init → IrqOn`
- **`_gfxlock.on` sans `_gfxlock.off`** : `gfxlock.status` reste à 1 → `bufferSwap.check` ne fait jamais de swap → écran figé
- **`_gfxlock.off` sans `_gfxlock.loop`** : `frameDrop.count` ne se met pas à jour → routines `*Sync` cassées
- **Écrire en zone donnée sans mount le back-buffer** : on écrit dans la visible → tearing immédiat
- **Modifier `gfxlock.status` directement** : court-circuit la mécanique, comportement imprévisible
- **Background process trop long dans `_gfxlock.backProcess.on`** : pas de protection — si le job dépasse le frame budget, l'écran lag
- **Couleur de bordure changée pendant le frame** sans passer par `gfxlock.screenBorder.update` : peut être écrasée au prochain `bufferSwap.do`
