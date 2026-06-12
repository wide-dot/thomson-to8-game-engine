# Players `ymm` et `vgc` — objets engine

Les players `ymm` et `vgc` sont les deux mécanismes principaux pour jouer de la musique dans l'engine. Tous deux sont **packagés en objets** (avec ObjID, dans engine/objects/sound/), permettant un usage uniforme via `_MountObject` et les macros `_MusicInit_*`/`_MusicFrame_*`.

## Objet `ymm` — YM2413vgm player

### Localisation

```
engine/objects/sound/ymm/
├── ymm.asm                              # code de l'objet
├── ymm.const.asm                        # constantes (commandes)
├── ymm.data.asm                         # données (buffer, état)
├── ymm.macro.asm                        # macros utilisateur
└── ymm.properties                       # déclaration objet
```

### Variables internes

```asm
YVGM_MusicData    fdb 0                  ; pointeur vers les données de musique
YVGM_MusicPage    fcb 0                  ; page mémoire des données
YVGM_MusicStatus  fcb 0                  ; 0 = stop, 1 = playing
YVGM_WaitFrame    fcb 0                  ; compteur d'attente entre commandes
YVGM_loop         fcb 0                  ; flag boucle (0 ou 1)
YVGM_callback     fdb 0                  ; routine à appeler à la fin (ou 0)
YVGM_MusicDataPos fdb 0                  ; position courante dans les données

YM2413_buffer                            ; buffer décompressé
```

### Format des données

`ymm` lit des données compressées **ZX0** (.ymm.zx0). La décompression se fait au boot via `ym2413zx0_decompress` :

```asm
; Init de l'objet
        bmi   @update                   ; commande négative = update
        pshs  u
        ldx   #Snd_index
        asla
        ldx   a,x                       ; charge l'adresse du morceau
@init
 IFDEF ymm.command
        lda   #ymm.command.PLAY
        sta   ymm.command
 ENDC
        stb   YVGM_loop
        stx   YVGM_MusicData
        sty   YVGM_callback
        _GetCartPageA
        sta   YVGM_MusicPage
        lda   #1
        sta   YVGM_MusicStatus
        sta   YVGM_WaitFrame
        ldu   #YM2413_buffer
        stu   YVGM_MusicDataPos
        leax  2,x                       ; skip 2 octets (offset loop)
        jsr   ym2413zx0_decompress
        puls  u,pc
```

Stratégie : décompression **streaming** dans le buffer YM2413_buffer, lecture au fur et à mesure.

### Cycle de tick

À chaque appel `_ymm.processFrame` :
1. Décrémente `YVGM_WaitFrame`
2. Si 0, lit la prochaine commande du buffer
3. Applique sur le YM2413 (`sta YM2413.A` + `sta YM2413.D`)
4. Si buffer épuisé, re-decompresse depuis YVGM_MusicData
5. Si fin de musique : loop ou stop (selon YVGM_loop)

### Macros utilisateur

```asm
; Définies dans ymm.macro.asm

_ymm.processFrame MACRO
        ldb   ymm.command
        jsr   ,x                        ; appelle l'objet
        ENDM

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

### Commandes

```asm
ymm.command.PLAY      equ $80
ymm.command.STOP      equ $81
ymm.command.RESTART   equ $82
```

`ymm.command` (variable RAM) stocke la commande courante. Le tick lit cette variable et agit.

### Pattern d'usage complet

```asm
; Au boot
        _MountObject ObjID_ymm
        _MusicInit_objymm #0,#MUSIC_LOOP,#0     ; track 0, loop, fade 0

; UserIRQ
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow
        _MountObject ObjID_ymm
        _ymm.processFrame                ; tick
        rts

; Plus tard : pause
        _ymm.stop

; Plus tard : reprise
        _ymm.restart

; Changer de morceau
        _MountObject ObjID_ymm
        _MusicInit_objymm #5,#MUSIC_NO_LOOP,#0  ; track 5, no loop
```

## Objet `vgc` — VGC compressed VGM player

### Localisation

```
engine/objects/sound/vgc/
└── vgc.asm                              # code de l'objet
engine/sound/vgc/
├── lib/
│   ├── vgcplayer.asm                    # player core
│   ├── vgcplayer.h.asm                  # header (constantes, vars)
│   ├── vgcplayer_bass.asm               # variante avec basse
│   ├── vgcplayer_config.h.asm           # config
│   ├── exomiser.asm                     # support Exomizer
│   ├── exomiser.h.asm
│   ├── irq.asm                          # gestion IRQ
│   ├── fx.asm                           # effets
│   └── vgmplayer.asm                    # player VGM brut
└── modules/
    └── *.py                             # outils Python
```

### Player

`vgc_init` et `vgc_update` sont les routines exposées :

```asm
        ldx   #my_vgc_data
        ldb   #MUSIC_LOOP
        ldy   #0                        ; fade
        jsr   vgc_init                  ; initialise le player

        ; Dans UserIRQ :
        jsr   vgc_update                ; tick une frame
```

### Format VGC

VGC = VGM **compressé** via `vgmpacker.py`. Format pensé pour décodage rapide sur 6809 :
- Indexation par track
- Compression huffman + LZ4
- Lookup tables précalculées

### Conversion .vgm → .vgc

```bash
python vgmpacker.py input.vgm output.vgc
```

Outils dans `engine/sound/vgc/modules/`.

### Auto-modif `vgc_port_01..04`

Le player utilise du code auto-modifié pour optimiser les écritures SN76489 :

```asm
sn76489.reset
        lda   #$9F
        sta   SN76489.D
vgc_port_01 equ *-1                     ; adresse du sta SN76489.D
        ; ...
```

`vgc_port_01..04` sont les **adresses où le port SN76489 est écrit** dans la routine reset. Le player peut les patcher pour rediriger vers d'autres ports (test, désactivation).

### Cycle de tick

`vgc_update` :
1. Lit la prochaine commande compressée
2. Décompresse (LZ4 + huffman si nécessaire)
3. Écrit sur SN76489 via les ports auto-modifiés
4. Gère le sub-tick (les commandes peuvent avoir une durée fractionnaire)

### Pattern d'usage

Idem que ymm (via macros) :

```asm
        _MountObject ObjID_vgc
        _MusicInit_objvgc #0,#MUSIC_LOOP,#0

UserIRQ
        ; ...
        _MountObject ObjID_vgc
        _MusicFrame_objvgc
        rts
```

## ymm vs vgc — choix

| Aspect | ymm | vgc |
|--------|-----|-----|
| Hardware cible | YM2413 (FM) | SN76489 (PSG) |
| Format | .ymm.zx0 (YM2413vgm + ZX0) | .vgc (VGM compressé) |
| Compression | ZX0 (streaming) | Huffman + LZ4 |
| Qualité | Riche (FM 9 voies) | Limitée (4 voies PSG) |
| Taille typique | 5-20 Ko | 2-10 Ko |
| CPU usage / frame | ~1500 cycles | ~1000 cycles |

**Recommandation** : utiliser **les deux ensemble** pour profiter des 9 voies YM + 4 voies PSG = 13 voies simultanées.

Pattern observé : YM2413 pour la mélodie/harmonie, SN76489 pour les drums/effets.

## Pipeline .dmf → .vgm → .vgc

Outils :
- **DefleMask** (DAW) : compose la musique, export .dmf
- **DefleMask export VGM** : .dmf → .vgm (raw VGM)
- **vgmpacker.py** : .vgm → .vgc
- **(autre outil ?) → .ymm.zx0** pour YM2413

Convention de naming observée dans bubble-bobble :
```
music/
├── bubbleBubble2024.dmf                ; source DefleMask
├── bubbleBubble2024.vgm                ; export raw VGM
├── bubbleBubble2024.vgm.sn76489.loop.vgm   ; VGM ciblé SN76489
├── bb-sn.vgc                            ; SN76489 compressé pour vgc player
└── bb-ym-ym2413.ymm.zx0                 ; YM2413 compressé pour ymm player
```

## Callback

Les deux players supportent un **callback** appelé en fin de morceau (utile pour transition automatique) :

```asm
        _MusicInit_objymm #0,#MUSIC_NO_LOOP,#OnMusicEnd

OnMusicEnd
        ; ... e.g. lancer le morceau suivant ...
        rts
```

Si `MUSIC_LOOP`, le callback n'est jamais appelé (la musique reboucle).

## Pitfalls

- **`_MusicInit_obj*` avant `_MountObject`** : la page n'est pas chargée, init crash
- **Track number > nb tracks** : lecture aléatoire, possible plantage
- **Décompression sans buffer alloué** : crash
- **Mélange ymm sur SN76489 ou vgc sur YM2413** : impossible (chaque player a son hardware cible)
- **vgc.asm utilisé sans vgcplayer.asm inclus** : symbols undefined
- **Plusieurs init du même player** : double-mount, comportement imprévisible
- **Callback à une adresse invalide** : crash en fin de morceau
