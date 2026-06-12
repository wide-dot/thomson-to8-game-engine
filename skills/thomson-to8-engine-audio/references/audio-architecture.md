# Architecture audio — hardware YM2413 + SN76489

## Vue d'ensemble

Le TO8 utilise typiquement **deux chips audio** ajoutés via une carte d'extension :

- **YM2413 (OPLL)** : synthèse FM 9 voies (ou 6 mélodie + 3 percussion en drum mode)
- **SN76489 (DCSG)** : PSG 4 voies (3 mélodie + 1 bruit)

Les deux peuvent jouer simultanément (chacun a son propre canal de sortie).

## Adresses hardware

```asm
YM2413.A         equ   $E7F4            ; address register (sélection registre)
YM2413.D         equ   $E7F5            ; data register

SN76489.D        equ   $E7F6            ; data (SOUND_CARD_PROTOTYPE défini)
; OR
SN76489.D        equ   $E7F8            ; data (jumper low = SN76489_JUMPER_LOW)
```

### `SOUND_CARD_PROTOTYPE`

```asm
SOUND_CARD_PROTOTYPE equ 1
```

Indique l'utilisation de l'ancienne carte son prototype (port SN76489 en `$E7F6`). Si absent ou commenté, la carte finale est utilisée (`$E7F8`).

Conditionne les `IFDEF` dans les routines engine pour pointer le bon registre.

### `SN76489_JUMPER_LOW`

```asm
SN76489_JUMPER_LOW equ 1
```

Variante : jumper bas du SN76489. Modifie l'adresse cible.

À déterminer selon la carte son réelle utilisée (ancienne prototype vs version finale).

## YM2413 — synthèse FM

### Registres

| Range | Rôle |
|-------|------|
| `$00-$07` | Custom instrument (8 octets) |
| `$0E` | Rhythm mode + drums on/off |
| `$0F` | Test (à 0) |
| `$10-$18` | Voice 0-8 frequency low |
| `$20-$28` | Voice 0-8 freq high + key on + sustain |
| `$30-$38` | Voice 0-8 instrument + volume |

### Init (silence)

```asm
ym2413.reset
        ldd   #$200E
        stb   YM2413.A                  ; sélectionne $0E
        nop                             ; tempo
        ldb   #0
        sta   YM2413.D                  ; data = 0 → drums off
        
        lda   #$20                      ; start at register $20
        brn   *                         ; tempo
@c      exg   a,b                       ; tempo
        exg   a,b
        sta   YM2413.A
        nop
        inca
        stb   YM2413.D                  ; data = 0 → key off + freq=0
        cmpa  #$29                      ; jusqu'à voice 8
        bne   @c
        rts
```

Met toutes les voices à 0 (key off, freq 0) → silence.

### Drum mode

Le YM2413 a 9 voies normales OU 6 mélodie + 3 drums (kick + snare + hi-hat). Activé via bit 5 de `$0E` :

```asm
        lda   #$0E
        sta   YM2413.A
        lda   #$20                      ; bit 5 = rhythm mode on
        sta   YM2413.D
```

Pour les drums individuelles :
- bit 4 (`$10`) : BD (kick)
- bit 3 (`$08`) : SD (snare)
- bit 2 (`$04`) : TOM
- bit 1 (`$02`) : TC (top cymbal)
- bit 0 (`$01`) : HH (hi-hat)

```asm
        lda   #$0E
        sta   YM2413.A
        lda   #$3F                      ; rhythm on + tous les drums frappés
        sta   YM2413.D
```

### Instruments preset (1-15)

Le YM2413 a 15 instruments preset + 1 custom :
1. Violin
2. Guitar
3. Piano
4. Flute
5. Clarinet
6. Oboe
7. Trumpet
8. Organ
9. Horn
10. Synthesizer
11. Harpsichord
12. Vibraphone
13. Synthesizer Bass
14. Wood Bass
15. Electric Guitar

Sélectionnés via les 4 bits hauts du registre `$30-$38`.

## SN76489 — PSG

### Registres

Le SN76489 a 8 registres internes pilotés par le **byte écrit** sur le data port :

```
Byte : 1 R R R T D D D D    ; latch + register + type + data
```

Où :
- bit 7 (`1`) : latch (le byte est une commande)
- bits 6-4 : register (0-7) :
  - 0/1 : Voice 0 freq
  - 2/3 : Voice 1 freq
  - 4/5 : Voice 2 freq
  - 6/7 : Voice 3 noise/freq
- bit 4 : type (0 = freq, 1 = attenuation)
- bits 3-0 : data (4 bits)

Pour des fréquences complètes (10 bits), il faut 2 écritures (latch puis data sans bit 7).

### Reset

```asm
sn76489.reset
        lda   #$9F                      ; voice 0 atten = max (silence)
        sta   SN76489.D
        nop
        nop
        lda   #$BF                      ; voice 1 silence
        sta   SN76489.D
        nop
        nop
        lda   #$DF                      ; voice 2 silence
        sta   SN76489.D
        nop
        nop
        lda   #$FF                      ; voice 3 (noise) silence
        sta   SN76489.D
        rts
```

Met toutes les voices à atténuation max (= silence).

Les `nop` sont là pour respecter le temps minimum entre écritures (le chip a besoin de cycles pour traiter).

## Schéma fonctionnel

```
6809 (CPU)
   │
   ├── $E7F4 / $E7F5 ──→ YM2413 (FM 9 voies) ──→ Audio Out
   │
   └── $E7F6 (ou $E7F8) ──→ SN76489 (PSG 4 voies) ──→ Audio Out
                                                      │
                                                      └→ Mix → Sortie audio Thomson (6 bits)
```

Le mix est analogique (sur la carte son).

## Players engine vs hardware direct

Quasi-tous les game-projects utilisent les **players engine** (ymm, vgc, Smps) plutôt que d'écrire directement aux registres. Les players :
- Gèrent le décodage de format (VGM, VGC, .ymm.zx0, SMPS)
- Synchronisent avec le tempo
- Optimisent les écritures (compression, batch)

Les écritures directes (`sta YM2413.D`) sont réservées à :
- Reset (silence)
- Test hardware (debugging)
- Effets sonores très simples (1-2 voices, durée fixe)

## Performance

Le YM2413 et SN76489 sont **passive** : ils n'interrompent pas le CPU, c'est le CPU qui écrit à chaque frame les valeurs (~50 Hz pour la musique, jusqu'à 200 Hz pour les drums DPCM).

Budget par frame pour audio : ~3000-5000 cycles (15-25% du budget total à 50 Hz).

## Pitfalls

- **Mauvais `SOUND_CARD_PROTOTYPE`** : écriture sur la mauvaise adresse, silence
- **Sans `nop` entre écritures SN76489** : le chip rate des commandes → notes fausses
- **Drums mode sans `bit 5` de `$0E`** : drums attendus mais c'est 9 voices mélodie
- **Mix YM/SN** : les deux chips peuvent jouer en même temps, mais attention à la balance volume
- **Reset au boot mais pas après transition** : drone résiduel
- **Écriture pendant un VBL ou pas** : si on écrit pendant l'affichage, possible bruit
