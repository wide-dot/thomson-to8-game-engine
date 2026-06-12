---
name: thomson-to8-engine-memory-model
description: "Décrit le modèle mémoire en runtime du Thomson TO8/TO9 game engine (Bento8/wide-dot) : carte mémoire 64 Ko adressable + jusqu'à 32 pages de 16 Ko commutables, organisation par zones (cartouche $0000-$3FFF, vidéo $4000-$5FFF, système $6000-$9FFF, données paginables $A000-$DFFF, I/O $E000-$E7FF, ROM $E800-$FFFF), point d'entrée code game-mode à $6100, zone Direct Page utilisateur $9F00-$9FFF (149 octets), DP engine dp_engine ($9F00+offset), dp_extreg pour registres étendus, pile système glb_system_stack = dp (descend depuis $9FFF), variables globales en $9DFE-$9DFF, glb_ram_end = $A000-12 (marge sprites), zone des cellules BBC $6000-$7FFF, BankSwitch routines SetCartPageA / SetCartPageB / GetCartPageA / GetCartPageB pour commutation de pages cartouche (zone $0000-$3FFF), glb_Page = 0 special mode (pas de test RAM/ROM), gestion T2 vs RAM via bit 7 (négatif = T2 ROM, positif = RAM), zone data paginable via $E7E5 (CF74021.DATA), zone cartouche via $E7E6 (CF74021.CART), zone vidéo via $E7E7 (CF74021.SYS1) et $E7DD (CF74021.SYS2 = border + buffer), bit de forme MC6846.PRC $E7C3 pour half-page swap, registres globaux glb_camera_x_pos / glb_screen_location / glb_register_s, organisation des sprites compilés et leurs débordements possibles au-delà de $A000 (jusqu'à 12 octets, d'où glb_ram_end = $A000-12), distinction Variables globales persistantes (à partir de $9DFF en remontant) vs temporaires partagées (zone dp $9F00-$9FFF), nbMaxPagesRAM 16 ou 32 selon builder.to8.memoryExtension. Utiliser pour comprendre où placer du code/data, calculer l'espace disponible pour les game-modes, débugger un dépassement mémoire, comprendre la pagination, utiliser correctement SetCartPageA/B, allouer des variables globales, comprendre la pile système et ses limites. Mots-clés : memory map, $6100, $9F00, $9E00, $9DFE, $9DFF, $A000, $DFFF, $E7C0-$E7FF, dp, dp_engine, dp_extreg, glb_system_stack, glb_ram_end, glb_camera_x_pos, glb_camera_y_pos, glb_screen_location_1, glb_screen_location_2, glb_register_s, glb_force_sprite_refresh, glb_Page, MC6846, MC6821, THMFC01, EF9369, CF74021, $E7C3 PRC, $E7C5 TCR, $E7C6 TMSB, $E7C7 TLSB, $E7C8-$E7CB PIA system, $E7CC-$E7CF PIA music/game, $E7D0-$E7D7 floppy controller, $E7DA-$E7DB palette, $E7DC LGAMOD, $E7DD border, $E7E4 COM, $E7E5 DATA, $E7E6 CART, $E7E7 SYS1, $E7F4-$E7FF audio, SetCartPageA, SetCartPageB, GetCartPageA, GetCartPageB, _SetCartPageA, _SetCartPageB, BankSwitch, page commutable, T2, cartouche, RAM, ROM, builder.to8.memoryExtension, 256K, 512K, nbMaxPagesRAM, half page, GETC, KTST, DKCO, IRQ.EXIT, TIMERPT, ROM routines, Monitor."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Modèle mémoire — Thomson TO8/TO9 Game Engine

Le 6809 du TO8 adresse 64 Ko (16 bits). Le TO8 utilise un système de **pagination** pour accéder à plus (jusqu'à 512 Ko avec extension). Ce skill décrit la carte mémoire en runtime et les mécanismes de commutation de pages.

---

## Carte mémoire 64 Ko

```
Adresse      | Zone              | Contenu                                  | Mode
-------------|-------------------|------------------------------------------|----------
$0000-$3FFF  | Cartouche         | Page ROM cartouche (T2) ou RAM (16 Ko)  | Commutable
$4000-$5FFF  | Vidéo (8 Ko)      | VRAM (page écran 0 ou 1)                | Half-page swap
$6000-$9FFF | Système (16 Ko)   | RAM résidente                            | Fixe
$A000-$DFFF | Données (16 Ko)   | Page RAM 2-31 (selon $E7E5)             | Commutable
$E000-$E7FF | I/O               | Registres hardware                       | Fixe
$E800-$FFFF | ROM système       | Monitor (KTST, GETC, DKCO, etc.)       | Fixe
```

## Détail zone système ($6000-$9FFF)

C'est la zone où vit le code du game-mode :

```
$6000-$7FFF  : Background Backup Cells (BBC) — 128 cellules de 64 octets
$6100        : Point d'entrée du code game-mode (org $6100)
$6100-$9DFD  : Code et données du game-mode
$9DFE-$9DFF  : Variables globales persistantes (descendant)
$9E00-$9EFF  : Espace pile système (~256 octets)
$9F00-$9FFF  : Zone Direct Page utilisateur (149 octets max)
              + dp_extreg + dp_engine (haut de DP)
```

### Détails

- **`org $6100`** : tout code de game-mode commence là (laisse $6000-$60FF pour le bootloader)
- **`glb_system_stack = dp = $9F00`** : la pile descend depuis $9EFF (limite haute), donc collide avec les variables globales si trop profonde
- **`glb_ram_end = $A000-12`** : marge de 12 octets car les sprites compilés peuvent déborder de $A000 par `glb_camera_x_offset/4` octets

Voir [references/memory-map-runtime.md](references/memory-map-runtime.md).

## Direct Page utilisateur ($9F00-$9FFF)

```asm
dp                            equ $9F00        ; user space (149 bytes max)
dp_engine                     equ glb_Page-32  ; engine routines tmp var space (32 bytes)
dp_extreg                     equ dp_engine-28 ; extra register space (28 bytes)
glb_system_stack              equ dp           ; pile = DP zone basse
```

- **DP user** : 149 octets pour l'application (variables globales temporaires, OST joueur en DP, etc.)
- **`dp_engine`** : 32 octets réservés au moteur (cur_priority, cur_ptr_*, etc.)
- **`dp_extreg`** : 28 octets pour les registres étendus (glb_a0, glb_d0, ...)

### ⚠️ Règle critique : DP n'est pas auto-positionné

L'adressage **direct page** (`<addr` ou `addr,dp`) suppose que le registre DP du 6809 contient la bonne valeur. Or **DP n'est pas garanti** au démarrage d'un game-mode (souvent à 0 ou valeur résiduelle).

| Contexte | DP positionné ? | Usage de `<addr` |
|----------|-----------------|------------------|
| Code résident game-mode (`org $6100`, MainLoop) | NON | ❌ ne pas utiliser (sauf si tu fais `tfr` toi-même) |
| `UserIRQ` (appelée par IrqManager) | OUI, DP=$E7 | ✅ OK pour accéder à `<$DA`, `<$DB`, etc. (registres $E7xx) |
| Routine engine qui set DP localement (PalUpdateNow, etc.) | OUI dans la routine | ✅ OK dans le périmètre, doit restaurer DP à la sortie |

**Pour le code résident, utiliser TOUJOURS l'adressage étendu** (sans `<`) :

```asm
        lda   #50
        sta   horizon_y      ; ✅ étendu — correct quel que soit DP
        ; sta <horizon_y     ← ❌ écrit en (DP<<8 | offset) — pas où on pense !
```

Pour set DP localement à une routine :
```asm
        pshs  dp
        ldd   #$XX
        tfr   b,dp
        setdp $XX            ; directive LWASM (compile-time)
        ; ... usage de <addr ...
        setdp dp/256         ; reset directive
        puls  dp             ; restore DP de l'appelant
```

Voir [references/direct-page-usage.md](references/direct-page-usage.md) pour les patterns détaillés.

## Variables globales

```asm
glb_ram_end                   equ $A000-12     ; marge sprites
glb_register_s                equ glb_ram_end-2 ; sauvegarde S
glb_screen_location_1         equ glb_register_s-2
glb_screen_location_2         equ glb_screen_location_1-2
glb_camera_height             equ glb_screen_location_2-2
glb_camera_width              equ glb_camera_height-2
; ... descend de 2 octets par variable globale ...
glb_Page                      equ glb_timer_frame-1
```

Toutes les variables globales `glb_*` sont déclarées avec `equ <précédent>-<taille>`, formant une chaîne descendante depuis `$A000`.

Voir [references/global-variables.md](references/global-variables.md).

## Hardware I/O ($E7C0-$E7FF)

```
$E7C0-$E7C7 : MC6846 (timer, IRQ)
$E7C8-$E7CF : MC6821 PIA (système + audio/joypads)
$E7D0-$E7D7 : THMFC01 (contrôleur disquette)
$E7DA-$E7DB : EF9369 (palette)
$E7DC-$E7DD : CF74021 (mode page + screen border)
$E7E4-$E7E7 : CF74021 (gates : COM, DATA, CART, SYS1)
$E7F2-$E7F3 : EF5860 MIDI
$E7F4-$E7FF : Audio (YM2413, SN76489, MEA8000)
```

Voir constants `engine/system/to8/memory-map.equ` et `map.const.asm`.

## Pages mémoire commutables

### Zone $A000-$DFFF (données)

Sélection de page via `$E7E5` (`CF74021.DATA`) :
```asm
        ldb   #2
        stb   $E7E5                     ; mount page 2 en $A000-$DFFF
```

Pages disponibles : 0-31 (= 32 pages × 16 Ko = 512 Ko avec extension, 0-15 sinon).

### Zone $0000-$3FFF (cartouche)

Sélection via `$E7E6` (`CF74021.CART`) :
```asm
        ; bit 5 = 1 : RAM en zone cartouche
        ; bit 5 = 0 : ROM cartouche (T2 ou autre)
        ; bits 0-4 : numéro de page
```

L'engine utilise cette zone pour mounter dynamiquement le code des **objets** (chaque objet est sur une page paginée, mounté avant exécution par `RunObjects`).

### `BankSwitch.asm` — routines de commutation

```asm
SetCartPageA
        sta   >glb_Page                 ; sauve la page demandée
        bpl   @RAMPg                    ; positif → page RAM
        ; ... négatif → page T2 ROM
        ; séquence T2 spéciale ($0555, $02AA, $0555)
        bra   @rts
@RAMPg  sta   >$E7E6                    ; sélection simple RAM
@rts    rts

GetCartPageA
        lda   >glb_Page
        bne   @rts                      ; glb_Page != 0 → utilisé
        lda   >$E7E6                    ; sinon, lit le hardware
@rts    rts
```

`SetCartPageA` est utilisée via la macro `_SetCartPageA` :
```asm
_SetCartPageA MACRO
 IFDEF T2
        jsr   SetCartPageA              ; via routine (gère T2)
 ELSE
        sta   $E7E6                     ; directement (RAM seulement)
 ENDC
 ENDM
```

`IFDEF T2` permet de choisir au build entre version RAM-only (rapide) et version T2-aware (gère ROM cartouche).

### `glb_Page = 0` — special mode

Si `glb_Page = 0`, les routines `GetCartPageA` lisent **directement le hardware** (`lda $E7E6`). Sinon elles retournent `glb_Page` (qui mémorise la dernière page demandée).

Usage : permet d'éviter le test RAM/ROM dans certains modes intensifs (tile rendering). Tu mets `glb_Page = 0` quand tu sais que tout est RAM.

Voir [references/bank-switching-macros.md](references/bank-switching-macros.md).

## Routines monitor ROM ($E800-$FFFF)

```asm
GETC            equ $E806               ; lit un caractère clavier
KTST            equ $E809               ; test si touche pressée
DKCO            equ $E82A               ; routine disque (read/write)
IRQ.EXIT        equ $E830               ; exit IRQ propre
```

À utiliser avec parcimonie (la ROM monitor n'est pas re-entrant).

## Sprite buffer overflow

```asm
glb_ram_end                   equ $A000-12     ; marge !
```

Les sprites compilés peuvent déborder de $A000 (zone système → données) jusqu'à `glb_camera_x_offset/4` octets. La marge de 12 octets en haut de la zone système empêche la collision.

```asm
; compilatedsprite peut écrire jusqu'à $9FFC sans collision
glb_register_s                equ glb_ram_end-2   ; à $9FFE - 2 = $9FFC
glb_screen_location_1         equ glb_register_s-2 ; à $9FFA
```

À surveiller si on a beaucoup de variables globales : le code peut s'étendre vers le bas et risquer de toucher la pile.

## Variables globales du moteur

Liste partielle (du haut vers le bas) :

```asm
glb_ram_end                   equ $A000-12
glb_register_s                equ glb_ram_end-2
glb_screen_location_1         equ glb_register_s-2
glb_screen_location_2         equ glb_screen_location_1-2
glb_camera_height             equ glb_screen_location_2-2
glb_camera_width              equ glb_camera_height-2
glb_camera_x_pos_coarse       equ glb_camera_width-2
glb_camera_x_pos              equ glb_camera_x_pos_coarse-2
glb_camera_x_sub              equ glb_camera_x_pos-1
glb_camera_y_pos              equ glb_camera_x_pos-2
glb_camera_y_sub              equ glb_camera_y_pos-1
glb_camera_x_min_pos          equ glb_camera_y_pos-2
glb_camera_y_min_pos          equ glb_camera_x_min_pos-2
glb_camera_x_max_pos          equ glb_camera_y_min_pos-2
glb_camera_y_max_pos          equ glb_camera_x_max_pos-2
glb_camera_x_offset           equ glb_camera_y_max_pos-2
glb_camera_y_offset           equ glb_camera_x_offset-2
glb_force_sprite_refresh      equ glb_camera_y_offset-1
glb_camera_move               equ glb_force_sprite_refresh-1
glb_alphaTiles                equ glb_camera_move-1
glb_timer_second              equ glb_alphaTiles-1
glb_timer_minute              equ glb_timer_second-1
glb_timer                     equ glb_timer_minute
glb_timer_frame               equ glb_timer-1
glb_Page                      equ glb_timer_frame-1
```

Total ~50-60 octets dans le haut de la zone système.

Variables applicatives à placer **après glb_Page** (descend depuis là) — par convention `globals.X` :

```asm
GLOBAL_VARIABLES              equ $9E28           ; cf r-type/global/variables.asm
globals.nextGameMode          equ GLOBAL_VARIABLES+0
globals.score                 equ GLOBAL_VARIABLES+1
globals.lives                 equ GLOBAL_VARIABLES+3
; ... etc
```

## `builder.to8.memoryExtension`

Configure le nombre max de pages RAM :
- `Y` (recommandé) : 32 pages (= 512 Ko avec extension)
- `N` : 16 pages (= 256 Ko, TO8 sans extension)

Limite dure : pas plus de **32 pages physiques** sur le TO8.

## Patterns d'usage

### Calcul de la mémoire restante

```asm
; Pour un game-mode :
;   space_available = $A000 - glb_Page - taille_pile - taille_vars_app
;                   = $9F00 - $9F00 (DP) - 256 (pile) - X
;                   = ($9F00 - $9F00 - 256) sous-zone DP
;                   environ 7 Ko après le code à $6100
```

À vérifier dans les `.lst` générés par le builder Java (dans `generated-code/debug/`).

### Limite supérieure du code

Le code doit s'arrêter **avant `$9DFE`** (ou avant les variables globales applicatives). Si on dépasse, le moteur écrase les variables → comportement erratique.

L'engine peut placer une **alerte** au build :
```asm
        ifgt *,$9DFD
        error "Code dépasse $9DFD"
        endc
```

### Direct Page partagée

`dp` est partagée entre :
- Variables globales temporaires (top de la page)
- OST joueur en DP (`player1 equ dp`, occupe ~50 octets)
- `glb_system_stack` (descend depuis $9EFF mais commence à $9FFF si on déclare la pile en haut)

Attention aux collisions !

## Pitfalls

- **`<addr` (direct page) dans le code résident** : DP n'est pas garanti, écriture/lecture au mauvais endroit. Toujours utiliser l'adressage étendu (`sta var` sans `<`) dans le code main du game-mode, sauf si on a explicitement positionné DP juste avant via `tfr a,dp`. Bug silencieux, pas de crash. Cf. [references/direct-page-usage.md](references/direct-page-usage.md).
- **Code > $9DFD** : écrase les variables globales → bugs incompréhensibles
- **Pile trop profonde** : descend dans la zone DP utilisateur → corrompt les variables
- **Modifier `glb_Page` directement** : casse le système BankSwitch
- **Mounter une page sans `_SetCartPageA`** : crash si T2 (séquence spéciale requise)
- **Reading `$E7E6` directement** : OK si `glb_Page = 0`, sinon il faut lire `glb_Page` à la place
- **Sprite compilé qui déborde de plus de 12 octets** : touche `glb_register_s` → corruption registre S
- **Variables `globals.X` en zone DP** : conflict avec OST si player en DP
- **Page > 31** : pas existante sur TO8 → crash
- **DP non set runtime** : `setdp` est statique, doit être complété par `tfr a,dp` runtime

---

## Références détaillées

- [references/memory-map-runtime.md](references/memory-map-runtime.md) — Carte mémoire 64 Ko complète : zones cartouche/vidéo/système/données/IO/ROM, $6100 boot game-mode, $A000-12 sprite overflow margin, zone BBC $6000-$7FFF, distribution typique du code + data + vars
- [references/direct-page-usage.md](references/direct-page-usage.md) — Zone DP $9F00-$9FFF : dp_engine (32 octets engine), dp_extreg (28 octets), DP user (149 octets), pattern setdp + tfr a,dp, accès `<addr` rapide, conflits potentiels avec pile, ObjectDp pour joueur principal en DP
- [references/global-variables.md](references/global-variables.md) — Variables globales engine glb_* (camera, screen_location, timer, page) chaînées par equ -2, layout descendant depuis $A000, GLOBAL_VARIABLES applicatives ($9E28 r-type), conventions de nommage globals.X, persistance entre game-modes
- [references/bank-switching-macros.md](references/bank-switching-macros.md) — SetCartPageA/B + GetCartPageA/B + macros _SetCartPageA/B (IFDEF T2), glb_Page semantics (0 = special mode, bit 7 = T2), séquence T2 commutation ($0555/$02AA), différence RAM vs ROM cartouche, intégration avec RunObjects
- [references/system-stack-and-boundaries.md](references/system-stack-and-boundaries.md) — Pile système $9EFF descendante, glb_system_stack = dp, limites supérieures du code ($9DFD), conflits potentiels code/data/stack/DP, alertes au build, marge sprites $A000-12, builder.to8.memoryExtension 16 vs 32 pages
