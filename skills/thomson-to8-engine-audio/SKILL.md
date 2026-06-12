---
name: thomson-to8-engine-audio
description: "Décrit l'architecture audio du Thomson TO8/TO9 game engine (Bento8/wide-dot) : matériel YM2413 OPLL FM 9 voies (6 mélodie + 3 percussion via DAM) et SN76489 PSG 4 voies (3 mélodie + 1 bruit) accessibles via $E7F4-$E7F7 (sound card prototype SOUND_CARD_PROTOTYPE) ou $E7F8 (jumper SN76489_JUMPER_LOW), objet engine ymm (YM2413vgm player avec ymm.command.PLAY/STOP/RESTART, YVGM_MusicData/Page/Status, ym2413zx0_decompress), objet engine vgc (VGC compressed VGM player avec vgcplayer.h.asm/vgcplayer.asm, vgc_init, vgc_update, exomiser support), macros _MusicInit_objymm / _MusicInit_objvgc / _MusicFrame_objymm / _MusicFrame_objvgc (paramètres : track number, MUSIC_LOOP/MUSIC_NO_LOOP, fade), macro _MountObject pour mounter l'objet avant l'appel, ChiP réinitialisation ym2413.reset / sn76489.reset, system Smps (Sega Sample Music Playback System pour 6809, Smps.asm/Smps_S1.asm/SmpsMidi.asm/SmpsObj.asm/Smidi.asm, SMPS_VOICE/NB_FM/NB_PSG/TEMPO/DELAY headers), MusicFrame routine, IrqObjSmps integration, Svgm small VGM player, YM2413vgm player direct, samples PCM/DPCM via PlayDPCM16kHz / PlayDPCM8kHz / PlayPCM, DAC drums dans engine/sound/dac/, soundFX system avec _soundFX.play (sound id + priority, soundFX.newSound, soundFX.curSound), PSGlib librairie SN76489, déclaration des objets sound dans game-mode (object.ymm=engine/objects/sound/ymm/ymm.properties, object.vgc=engine/objects/sound/vgc/vgc.properties), pattern UserIRQ avec _ymm.processFrame et _MusicFrame_objvgc, formats binaires (VGC, VGM, .ymm.zx0, .dmf source). Utiliser pour intégrer une musique, jouer un effet sonore, choisir entre YM2413 et SN76489, configurer SMPS pour port Mega Drive, gérer DAC pour percussion, comprendre les players VGC/VGM, mettre en place l'audio engine via gameModeCommon. Mots-clés : YM2413, SN76489, OPLL, PSG, FM, vgc, ymm, ym2413vgm, vgcplayer, Smps, SMPS_S1, SmpsMidi, SmpsObj, Smidi, Svgm, YM2413vgm, soundFX, PSGlib, PlayDPCM16kHz, PlayDPCM8kHz, PlayPCM, sn76489.reset, ym2413.reset, vgc_init, vgc_update, ym2413zx0_decompress, YVGM_MusicData, YVGM_MusicPage, YVGM_MusicStatus, YVGM_WaitFrame, YVGM_loop, YVGM_callback, YM2413_buffer, YM2413.A, YM2413.D, SN76489.D, $E7F4, $E7F5, $E7F6, $E7F7, $E7F8, ymm.command, ymm.command.PLAY, ymm.command.STOP, ymm.command.RESTART, _MusicInit_objvgc, _MusicInit_objymm, _MusicFrame_objvgc, _MusicFrame_objymm, _ymm.processFrame, _ymm.play, _ymm.stop, _ymm.restart, _soundFX.play, soundFX.newSound, soundFX.curSound, MUSIC_LOOP, MUSIC_NO_LOOP, SOUND_CARD_PROTOTYPE, SN76489_JUMPER_LOW, MusicFrame, IrqObjSmps, SMPS_VOICE, SMPS_NB_FM, SMPS_NB_PSG, SMPS_TEMPO, SMPS_DELAY, SMPS_TEMPO_DELAY, DAC drums, vgmconverter, vgmpacker, ymvgm, vgc compression, dpcm, pcm."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Audio — Thomson TO8/TO9 Game Engine

L'engine fournit plusieurs systèmes audio cohabitant :

| Système | Type | Utilisation |
|---------|------|-------------|
| **ymm** (YM2413vgm) | Player FM (YM2413) | Musique mélodique riche |
| **vgc** | Player VGM compressé (SN76489) | Musique PSG |
| **Smps** | SMPS Sega port (multi-driver) | Compatible Sonic 2 / Mega Drive |
| **Svgm** | Small VGM | Lecture VGM brut (moins compressé) |
| **soundFX** | Effets sonores | One-shot SFX |
| **DAC/PCM/DPCM** | Samples | Drums, voix |

Hardware ciblé :
- **YM2413** (OPLL) : 9 voies FM (ou 6+3 percussion), via `$E7F4-$E7F5`
- **SN76489** (PSG) : 4 voies (3 mélodie + 1 bruit), via `$E7F6` ou `$E7F8`

---

## Hardware audio

```asm
YM2413.A         equ   $E7F4            ; address register
YM2413.D         equ   $E7F5            ; data register

SN76489.D        equ   $E7F6            ; data (SOUND_CARD_PROTOTYPE)
; OR
SN76489.D        equ   $E7F8            ; data (jumper low)
```

Le `SOUND_CARD_PROTOTYPE` est défini au début du `main.asm` pour signaler quelle carte son est utilisée (ancien prototype vs version finale) :

```asm
SOUND_CARD_PROTOTYPE equ 1              ; ancien port SN79486
SN76489_JUMPER_LOW   equ 1              ; jumper bas
```

Ces flags conditionnent les `IFDEF` dans les routines engine.

### Reset des chips

```asm
        jsr   sn76489.reset             ; coupe le PSG
        jsr   ym2413.reset              ; coupe le FM
```

À appeler au boot ou à la fin d'un game-mode pour silence garanti.

---

## Objet `ymm` (YM2413vgm)

Player YM2413 utilisant un format compressé (.ymm.zx0).

### Déclaration

```properties
object.ymm=./engine/objects/sound/ymm/ymm.properties
```

Génère `ObjID_ymm`.

### Commandes

```asm
ymm.command.PLAY           equ $80
ymm.command.STOP           equ $81
ymm.command.RESTART        equ $82
```

### Macros

```asm
_MusicInit_objymm MACRO
        lda   \1                        ; param 1 : track number
        ldy   \3                        ; param 3 : fade (typiquement 0)
        ldb   \2                        ; param 2 : MUSIC_LOOP / MUSIC_NO_LOOP
        jsr   ,x                        ; entry point de l'objet ymm
        ENDM

_MusicFrame_objymm MACRO
        ldb   #$80                      ; PLAY tick
        jsr   ,x
        ENDM
```

### Pattern d'usage

```asm
; Init au boot
        _MountObject ObjID_ymm
        _MusicInit_objymm #0,#MUSIC_LOOP,#0     ; track 0, en boucle, fade 0

; Tick à chaque VBL (UserIRQ)
UserIRQ
        ; ...
        _MountObject ObjID_ymm
        _ymm.processFrame                ; macro qui lit ymm.command + jsr ,x
        rts
```

`_ymm.processFrame` est défini dans `ymm.macro.asm` :
```asm
_ymm.processFrame MACRO
        ldb   ymm.command
        jsr   ,x
        ENDM
```

### Macros de contrôle dynamique

```asm
_ymm.play MACRO
        lda   #ymm.command.PLAY
        sta   ymm.command
        ENDM

_ymm.stop MACRO
        lda   #ymm.command.STOP
        sta   ymm.command
        ENDM

_ymm.restart MACRO
        lda   #ymm.command.RESTART
        sta   ymm.command
        ENDM
```

À appeler pour changer l'état du player en cours.

### Variables internes

```asm
YVGM_MusicData    fdb 0       ; pointeur vers les data musique
YVGM_MusicPage    fcb 0       ; page mémoire
YVGM_MusicStatus  fcb 0       ; 0/1
YVGM_WaitFrame    fcb 0       ; compteur d'attente
YVGM_loop         fcb 0       ; flag boucle
YVGM_callback     fdb 0       ; routine callback fin
YM2413_buffer                 ; buffer de décompression
```

Voir [references/ymm-player.md](references/ymm-player.md).

---

## Objet `vgc` (VGC compressed)

Player VGM compressé (SN76489). Plus compact que VGM brut, lecture rapide.

### Déclaration

```properties
object.vgc=./engine/objects/sound/vgc/vgc.properties
```

Génère `ObjID_vgc`.

### Macros (idem ymm)

```asm
_MusicInit_objvgc MACRO
        lda   \1
        ldy   \3
        ldb   \2
        jsr   ,x
        ENDM

_MusicFrame_objvgc MACRO
        ldb   #$80
        jsr   ,x
        ENDM
```

### Usage

```asm
        _MountObject ObjID_vgc
        _MusicInit_objvgc #0,#MUSIC_LOOP,#0

UserIRQ
        ; ...
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts
```

### Player interne

L'objet `vgc` s'appuie sur `engine/sound/vgc/lib/vgcplayer.asm` (et `.h.asm`). Player optimisé 6809 par Bentoc.

Variables :
```asm
vgc_port_01..04                ; auto-modif pour les écritures SN76489
```

Voir [references/vgc-player.md](references/vgc-player.md).

---

## SMPS (Sonic Mega Player System)

Port 6809 du driver musical Sonic 2 (basé sur la disassembly Z80 par Xenowhirl/RAS/Flamewing).

Fichiers :
- `Smps.asm` — driver principal
- `Smps_S1.asm` — variante Sonic 1
- `SmpsMidi.asm` — MIDI integration
- `SmpsObj.asm` — wrapper objet
- `Smidi.asm` — Small MIDI

### Header SMPS

```asm
SMPS_VOICE                   equ   0   ; offset vers les voices FM
SMPS_NB_FM                   equ   2   ; nb tracks FM
SMPS_NB_PSG                  equ   3   ; nb tracks PSG
SMPS_TEMPO                   equ   4
SMPS_TEMPO_DELAY             equ   4
SMPS_DELAY                   equ   5
```

### Usage

```asm
        lda   #$01
        sta   Smps.60HzData             ; force 60 Hz playback
        jsr   YM2413_DrumModeOn

        ; ... load song ...

; UserIRQ
UserIRQ_Pal_Smps
        jsr   PalUpdateNow
        jmp   MusicFrame                ; routine SMPS de tick
```

Utilisé exclusivement par sonic-2.

Voir [references/smps-player.md](references/smps-player.md).

---

## soundFX — effets sonores

Système séparé pour les effets sonores **one-shot** (saut, tir, explosion).

### Macro

```asm
_soundFX.play MACRO
        ; param 1 : sound id
        ; param 2 : priority (0-127)
        ; Check prio nouvelle vs précédente
        lda   soundFX.newSound+1
        anda  #$7F
        sta   @prevPri
        lda   #\2
        anda  #$7F
        cmpa  #0
@prevPri equ   *-1
        blo   @exit                     ; nouvelle prio < ancienne → skip
        bhi   @set                      ; nouvelle > ancienne → set
        lda   soundFX.curSound+1
        bmi   @exit                     ; si current locked, skip
@set
        ldd   #((\1)*256)+\2
        std   soundFX.newSound
@exit
        ENDM
```

Système de priorité :
- bit 7 = lock (le son ne peut pas être interrompu)
- bits 0-6 = priorité (0-127)

```asm
        _soundFX.play SND_jump,5         ; priorité 5
        _soundFX.play SND_die,127        ; priorité max
        _soundFX.play SND_explosion,$87  ; priorité 7 + lock
```

### Variables

```asm
soundFX.newSound    fdb 0       ; demandé
soundFX.curSound    fdb 0       ; en cours
```

Le tick (à appeler depuis UserIRQ) consulte `newSound`, le compare au current, puis joue.

Utilisé exclusivement par r-type.

Voir [references/soundfx-system.md](references/soundfx-system.md).

---

## Samples PCM/DPCM

Pour les drums et voix, l'engine fournit des routines de lecture de samples :

- `PlayDPCM16kHz.asm` : Differential PCM 16 kHz
- `PlayDPCM8kHz.asm` : DPCM 8 kHz (moins de qualité, plus de samples)
- `PlayPCM.asm` : PCM brut

Les samples sont dans `engine/sound/dac/` :
```
DAC_81.bin ... DAC_87.bin       ; 7 samples drums
DefDrum.txt                     ; définitions
sample_rates.txt                ; détail kHz
dpcm2pcm.exe                    ; outil conversion
```

Outil `dpcm2pcm.exe` pour convertir PCM → DPCM.

Voir [references/dac-pcm-samples.md](references/dac-pcm-samples.md).

---

## Patterns d'intégration

### MainLoop avec ymm + vgc

```asm
; Init au boot
        _MountObject ObjID_ymm
        _MusicInit_objymm #0,#MUSIC_LOOP,#0
        _MountObject ObjID_vgc
        _MusicInit_objvgc #0,#MUSIC_LOOP,#0

; UserIRQ
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        _MountObject ObjID_ymm
        _ymm.processFrame
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts
```

### Partage via gameModeCommon

Audio engine partagé entre tous les game-modes (cf. skill `engine-new-game/references/gamemode-properties.md`) :

```properties
# global/common-audio.properties
object.ymm=./engine/objects/sound/ymm/ymm.properties
object.vgc=./engine/objects/sound/vgc/vgc.properties

# game-mode/X/main.properties
gameModeCommon.0=./global/common-audio.properties
```

Économie ROM T2 : le code audio n'est écrit qu'une fois.

### Changement de musique

```asm
        ; Stop current
        _ymm.stop
        
        ; Wait some frames for fade-out
        ; ...
        
        ; Init new track
        _MountObject ObjID_ymm
        _MusicInit_objymm #5,#MUSIC_LOOP,#$60   ; track 5, fade in $60
```

### Désactiver YM (force silence)

bubble-bobble fait :
```asm
        ; disable ym soundtrack temporarily
        ldd   #$E7F4
        std   DYN.YM2413.A              ; redirige les writes vers RAM
        std   DYN.YM2413.D

        ; ... plus tard, restaurer ...
        ldd   #YM2413.A
        std   DYN.YM2413.A
        ldd   #YM2413.D
        std   DYN.YM2413.D
```

Astuce : auto-modif les adresses cible pour qu'elles écrivent en RAM (sans effet) au lieu du chip.

---

## Conversion de formats

| Format source | Outil | Cible |
|---------------|-------|-------|
| .vgm (raw VGM) | `vgmpacker.py` | .vgc (VGC compressé) |
| .vgm | (direct) | Svgm input |
| .ymm.zx0 | (déjà compressé) | ymm input |
| .dmf (DefleMask) | (export ext) | .vgm puis .vgc |

Pipeline goldorak observé : `bb-sn.vgc`, `bb-ym-ym2413.ymm.zx0`, `bubbleBubble2024.dmf` (source DefleMask).

---

## Pitfalls

- **`SOUND_CARD_PROTOTYPE` mal défini** : adresses hardware fausses, son inaudible ou crash
- **`_MountObject` avant l'init** : page non set, lecture random
- **YMM et VGC initialisés mais pas tickés** : pas de son après quelques frames
- **`ym2413.reset` oublié** au changement de game-mode : drone résiduel
- **Multiples `_soundFX.play` avec même priorité** : seule la dernière jouée (lock requis pour persister)
- **Tick audio dans MainLoop au lieu d'UserIRQ** : timing musical incorrect, tempo qui dérive
- **`_MountObject ObjID_X`** dans le code utilisateur sans restaurer la page : si l'objet est appelé depuis RunObjects, crash au retour
- **VGC sans `vgc_init`** : crash à la première frame
- **DAC drum mode pas activé** : drums YM2413 inaudibles (`YM2413_DrumModeOn`)
- **Mélange ymm et vgc sur même channel** : conflits hardware (le SN76489 ne peut faire qu'un seul truc à la fois)

---

## Références détaillées

- [references/audio-architecture.md](references/audio-architecture.md) — Hardware YM2413+SN76489 : adresses $E7F4-$E7F8, SOUND_CARD_PROTOTYPE vs SN76489_JUMPER_LOW, registres FM (instruments/feedback/key on), registres PSG (volume/freq/noise), drum mode, schéma fonctionnel
- [references/ymm-player.md](references/ymm-player.md) — Objet ymm complet : YVGM_MusicData/Page/Status/WaitFrame/loop/callback, ym2413zx0_decompress, commandes PLAY/STOP/RESTART, format .ymm.zx0, intégration avec UserIRQ, exemples de callback
- [references/vgc-player.md](references/vgc-player.md) — Objet vgc : vgcplayer.asm/.h.asm, vgc_init/vgc_update, format VGC, exomiser support, vgc_port_01..04 auto-modif, format binaire compressé, conversion .vgm → .vgc via vgmpacker.py
- [references/smps-player.md](references/smps-player.md) — SMPS Mega Drive : Smps.asm/Smps_S1.asm/SmpsMidi.asm/SmpsObj.asm/Smidi.asm, header SMPS_VOICE/NB_FM/NB_PSG/TEMPO/DELAY, MusicFrame, IrqObjSmps, 60Hz/50Hz, intégration avec Sonic 2 disassembly, Smps.60HzData
- [references/soundfx-system.md](references/soundfx-system.md) — soundFX : _soundFX.play macro, système de priorité (0-127 + bit lock), soundFX.newSound vs curSound, queue, tick depuis UserIRQ, intégration avec ymm/vgc, exemples (saut, tir, explosion)
- [references/dac-pcm-samples.md](references/dac-pcm-samples.md) — Samples : PlayDPCM16kHz vs DPCM8kHz vs PCM, format DPCM (différentiel), conversion via dpcm2pcm.exe, drums DAC_81-87.bin, intégration avec ym2413 drum mode, taux d'échantillonnage et qualité
- [references/audio-via-common.md](references/audio-via-common.md) — Pattern de partage via gameModeCommon : structure common-audio.properties, économie ROM T2, intégration avec d'autres game-modes, transition de musique entre game-modes
