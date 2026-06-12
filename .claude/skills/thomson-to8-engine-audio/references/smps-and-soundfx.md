# SMPS et soundFX

## SMPS — port 6809 du Sample Music Playback System

SMPS est le driver musical de Sonic the Hedgehog (Mega Drive). Le port 6809 par Bentoc (juin 2021) reprend la disassembly Z80 de Xenowhirl/RAS/Flamewing.

Utilisé exclusivement par **sonic-2**.

### Fichiers

| Fichier | Rôle |
|---------|------|
| `Smps.asm` | Driver principal |
| `Smps_S1.asm` | Variante Sonic 1 |
| `SmpsMidi.asm` | Lecture MIDI |
| `SmpsObj.asm` | Wrapper objet |
| `Smidi.asm` | Small MIDI |
| `ChangesFromOriginalSmpsFormat.txt` | Notes de port |

### Header SMPS

```asm
SMPS_VOICE                   equ   0      ; offset vers définition des voices FM
SMPS_NB_FM                   equ   2      ; nb tracks FM
SMPS_NB_PSG                  equ   3      ; nb tracks PSG
SMPS_TEMPO                   equ   4      ; tempo (BPM)
SMPS_TEMPO_DELAY             equ   4      ; alias
SMPS_DELAY                   equ   5      ; delay
```

### Init

```asm
        lda   #$01
        sta   Smps.60HzData             ; force 60Hz playback mode
        jsr   YM2413_DrumModeOn         ; drum mode YM2413

        ; charger une chanson
        ldx   #my_smps_song
        jsr   SmpsLoadSong              ; (à vérifier)
```

### MusicFrame — tick

```asm
UserIRQ_Pal_Smps
        jsr   PalUpdateNow
        jmp   MusicFrame                ; SMPS tick (= jsr puis rts via jmp)
```

`MusicFrame` est l'entry point standard du driver. Lit la chanson, applique les commandes au YM2413 + SN76489.

### IrqObjSmps

Wrapper pour intégrer SMPS dans le système d'objet :

```asm
        INCLUDE "./engine/irq/IrqObjSmps.asm"
```

Permet d'avoir SMPS comme un objet avec son propre OST. Plus complexe que ymm/vgc mais cohérent avec l'architecture engine.

### 50 Hz vs 60 Hz

Le SMPS original est conçu pour Mega Drive (60 Hz). Le port 6809 supporte les deux :
- `Smps.60HzData = 1` : compatibilité Mega Drive (1.2× plus rapide)
- `Smps.60HzData = 0` : 50 Hz natif

À choisir selon que la musique a été composée pour Mega Drive ou pour Thomson.

### Format SMPS

Le format SMPS est complexe (cf. doc disassembly Sonic 2). Compose des morceaux SMPS demande un éditeur spécialisé.

Sonic-2 utilise des morceaux pré-existants extraits de la cartouche originale, adaptés au YM2413+SN76489 du Thomson.

### Pattern UserIRQ avec SMPS + raster

```asm
UserIRQ_Raster_Smps
        jsr   PalRaster_1c              ; effet raster palette
        jmp   MusicFrame                ; SMPS tick

UserIRQ_Pal_Smps
        jsr   PalUpdateNow              ; pal update standard
        jmp   MusicFrame
```

Plusieurs UserIRQ selon le besoin (raster vs normal). Bascule par modification de `Irq_user_routine`.

### Comparaison avec ymm/vgc

| Aspect | SMPS | ymm + vgc |
|--------|------|-----------|
| Hardware | YM2413 + SN76489 | YM2413 (ymm) + SN76489 (vgc) |
| Format | SMPS (Sega) | .ymm.zx0 + .vgc |
| Complexité | Élevée (multi-track, jingles, FX) | Modérée |
| CPU | ~2000-3000 cycles/frame | ~2500 cycles/frame |
| Capacité | Drums multi, jingles, fadeouts | Single track + boucle |
| Cas d'usage | Sonic 2 (ré-arrangement portage) | Composition originale |

Pour un nouveau projet, **ymm + vgc** est recommandé (plus simple, mieux documenté).

---

## soundFX — effets sonores prioritaires

Système séparé pour les **effets sonores one-shot** (saut, tir, explosion, bonus). Indépendant de la musique en cours.

Utilisé exclusivement par r-type.

### Fichiers

| Fichier | Rôle |
|---------|------|
| `soundFX.asm` | Driver |
| `soundFX.data.asm` | Données (sons compilés) |
| `soundFX.macro.asm` | Macros utilisateur |

### Macro `_soundFX.play`

```asm
_soundFX.play MACRO
        ; param 1 : sound id
        ; param 2 : priority (0-127) — bit 7 = lock
        
        lda   soundFX.newSound+1
        anda  #$7f
        sta   @prevPri
        
        lda   #\2
        anda  #$7f
        cmpa  #0
@prevPri equ *-1
        blo   @exit                     ; nouvelle prio < ancienne → skip
        bhi   @set                      ; nouvelle > ancienne → set
        
        lda   soundFX.curSound+1
        bmi   @exit                     ; current locked → skip
        
@set
        ldd   #((\1)*256)+\2            ; sound id (haut) + priority (bas)
        std   soundFX.newSound
@exit
        ENDM
```

### Système de priorité

```
Priority value (1 byte) :
   Bit 7  : Lock — si 1, le son ne peut pas être interrompu
   Bits 6-0 : Priority 0-127 (plus haut = plus prioritaire)
```

Exemples :
- `$01` (1) : priorité basse, can be replaced
- `$7F` (127) : priorité max, can be replaced by another 127
- `$87` (135 = 7+lock) : priorité 7 mais lockée, can't be replaced

### Variables

```asm
soundFX.newSound    fdb 0       ; demande pendante (sound_id high, priority low)
soundFX.curSound    fdb 0       ; en cours (idem)
```

Format : MSB = sound id, LSB = priority.

### Tick (depuis UserIRQ)

```asm
UserIRQ
        ; ...
        jsr   soundFX.tick               ; (à vérifier le nom exact)
        rts
```

Le tick :
1. Si `newSound` != current : consume nouveau son, copie vers `curSound`
2. Tick le son courant (avance dans son script)
3. Si fini : reset `curSound`, prêt pour le prochain

### Exemples d'usage

```asm
; Player saute
        _soundFX.play SND_jump,5

; Player tir
        _soundFX.play SND_shoot,10

; Player meurt — priorité max + lock (rien ne peut interrompre)
        _soundFX.play SND_death,$FF

; Explosion grosse (lock)
        _soundFX.play SND_bigExplosion,$87
```

### Conventions de priorité

Pratique pour les jeux d'arcade :

| Priorité | Type de son |
|----------|-------------|
| 1-9 | Sons ambiance (pas, eau, vent) |
| 10-19 | Tirs réguliers |
| 20-29 | Bonus collecte |
| 30-49 | Tirs puissants, explosions petites |
| 50-79 | Explosions importantes |
| 80-99 | Sons de hit (joueur touché) |
| 100-126 | Critiques (game over, boss) |
| 127 | Priorité max, peut être remplacée par un autre 127 |
| 128-255 (avec lock) | Locked, ne peut pas être interrompue |

### Compilation des sons

Les sons sont compilés en code asm (pas en data) par le builder. Voir `soundFX.data.asm` pour les définitions.

Pattern :
```asm
SND_jump
        ; séquence d'écritures YM2413/SN76489 pour reproduire le son
        fcb   $30, $40                  ; reg YM, value
        fcb   $20, $10                  ; ...
        fcb   $FF                       ; fin
```

### Pattern d'intégration

```asm
; main.asm
        INCLUDE "./engine/sound/soundFX.asm"
        INCLUDE "./engine/sound/soundFX.data.asm"
        INCLUDE "./engine/sound/soundFX.macro.asm"

; Dans MainLoop
MainLoop
        ; ...
        jsr   RunObjects
        ; (les objets peuvent appeler _soundFX.play)
        ; ...

; Dans UserIRQ
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        jsr   soundFX.tick               ; consume + tick
        ; (puis ymm + vgc si présents)
        rts
```

## Pitfalls

### SMPS
- **`Smps.60HzData` mal configuré** : tempo incorrect (musique trop lente ou trop rapide)
- **`YM2413_DrumModeOn` oublié** : drums silencieux
- **Mélange SMPS et ymm** : conflit sur YM2413, sons cassés
- **MusicFrame non appelé** : pas de musique
- **MIDI sans SmpsMidi** : symbol undefined

### soundFX
- **Priorité < lock courant** : son skipé silencieusement (peut surprendre en debug)
- **Priorité 0** : son effectivement désactivé
- **Plus de 1 son simultané** : soundFX n'a qu'1 voice, le nouveau remplace l'ancien (sauf si lock)
- **Conflit avec musique sur SN76489** : si soundFX utilise le SN, peut couper momentanément la musique
- **Sons mal compilés** : crash ou bruit aléatoire
- **`_soundFX.play` depuis IRQ** : possible race condition
