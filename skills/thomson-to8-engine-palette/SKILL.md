---
name: thomson-to8-engine-palette
description: "Décrit le système de palette du Thomson TO8/TO9 game engine (Bento8/wide-dot) : double buffer Pal_current / Pal_buffer (32 octets, 16 couleurs sur 2 octets chacune), flag PalRefresh (-1 = pas de refresh, 0 = refresh demandé), routines PalUpdateNow (boucle déroulée optimisée) et PalUpdateNowLean (boucle compacte avec ldd ,x++), accès hardware via $E7DA (donnée couleur, auto-incrément) et $E7DB (index couleur), couleur de bordure $E7DD, palette cycling rotatif PalCycling sur les 3 premières couleurs, effets raster PalRaster_1c pour changer 1 couleur par scanline (lecture $E7 pour wait spot column), structure d'une couleur (2 octets : VVVVRRRR puis XXXMBBBB avec M = bit de marquage incrustation), palettes engine Pal_black et Pal_white (constantes), objet PaletteFade pour transition progressive (init source/dest, nb_frames, mask alternance V/R, callback fin, auto-unload), objet raster-fade pour fade par scanline avec subtypes (Sub_RasterFadeInColor, Sub_RasterFadeOutColor, Sub_RasterMain, Sub_RasterCycle), intégration avec gfxlock.screenBorder.update, palette générée par builder depuis PNG (Palette.java + PaletteTO8.getPaletteData). Utiliser pour comprendre comment charger une palette, déclencher un fade, faire du cycling, programmer un effet raster, gérer la bordure d'écran, ou implémenter une transition d'écran avec PaletteFade. Mots-clés : Pal_current, Pal_buffer, PalRefresh, PalUpdateNow, PalUpdateNowLean, PalCycling, PalCyc_frames, PalCyc_frames_init, PalRaster_1c, PalRas_page, PalRas_start, PalRas_end, $E7DA, $E7DB, $E7DD, $E7DC, $E7E5, Pal_black, Pal_white, ObjID_fade, ObjID_PaletteFade, ObjID_raster-fade, PaletteFade, PaletteFade_Init, PaletteFade_Wait, PaletteFade_Main, PaletteFade_Idle, o_fade_src, o_fade_dst, o_fade_mask, o_fade_cycles, o_fade_save, o_fade_idx, o_fade_curwait, o_fade_wait, o_fade_callback, o_fade_sleep, o_fade_unload, o_fade_routine_idle, raster_pal_dst, raster_nb_fade_colors, raster_cycle_idx, raster_color, raster_cycles, raster_inc, raster_frames, raster_cur_frame, raster_nb_colors, raster_cycle_frame, Sub_RasterFadeInColor, Sub_RasterFadeOutColor, Sub_RasterMain, Sub_RasterCycle, PALETTE_FADER, NO_CALLBACK, MUSIC_LOOP, gfxlock.screenBorder.color, gfxlock.screenBorder.update, _palette.set, _palette.show, _palette.fade, color VVVVRRRR XXXMBBBB, 16 couleurs, 4096 couleurs, fondu, transition, screen border, incrustation."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Palette — Thomson TO8/TO9 Game Engine

Le TO8 dispose d'une palette de **16 couleurs** simultanément affichables, choisies parmi 4096 (4 bits par composante R/V/B). La palette est stockée dans un buffer de 32 octets (2 octets par couleur) et appliquée au hardware via des registres I/O.

Ce skill couvre : le **buffer palette** et son refresh, les routines `PalUpdateNow*`, le **palette cycling**, les **effets raster** (changement à mi-écran), l'objet **PaletteFade** pour transitions progressives, et l'objet **raster-fade** pour fades par scanline.

---

## Format d'une couleur

Chaque couleur occupe **2 octets** :

```
Octet 1 :  V V V V  R R R R
           |─bleu*─| (fond. V)  |─rouge─|  (fond. R)

Octet 2 :  X X X M  B B B B
           bit marquage         |─bleu─|  (fond. B)
           (incrustation)
```

> **Note hardware** : Le bit M (marquage / incrustation vidéo) sert au mode incrustation (mixing avec source vidéo externe). À 0 pour usage standard.

Donc une couleur prend les 2 octets `$VR $MB` :
- `V` (vert) : 4 bits
- `R` (rouge) : 4 bits
- `M` (marquage) : 1 bit
- `B` (bleu) : 4 bits (les bits XXX en haut sont ignorés)

Pour 16 couleurs : 32 octets en mémoire.

---

## Buffer palette

```asm
PalRefresh      fcb   $FF              ; -1 = pas de refresh demandé, 0 = refresh à faire
Pal_current     fdb   Pal_buffer       ; pointeur vers la palette courante (lue par PalUpdateNow)
Pal_buffer      fill  0,$20            ; 32 octets de palette
```

Trois éléments :
- `PalRefresh` : flag de demande de refresh. À `$FF` (positif après `tst`), `PalUpdateNow` est skipée. À `$00` ou `$80` (négatif après `tst`), le refresh est exécuté.
- `Pal_current` : pointeur 2 octets vers la palette **active**. Peut pointer vers `Pal_buffer` (palette modifiable) ou vers une palette en ROM (`Pal_game`, `Pal_black`, etc.).
- `Pal_buffer` : palette de travail (32 octets, modifiable par fade/cycling).

### Pattern d'usage

```asm
        ; Activer une palette en ROM
        ldd   #Pal_TitleScreen          ; généré par builder depuis palette.Pal_TitleScreen=...
        std   Pal_current
        clr   PalRefresh                ; demander refresh
        jsr   PalUpdateNow              ; appliquer immédiatement
```

Le `clr PalRefresh` (mettre à 0) est interprété par `PalUpdateNow` comme « refresh demandé » (`bne @rts` ne saute pas).

> **Sens inversé du flag** : si on lit `PalRefresh` avec `tst`, **0 = refresh demandé**, **non-0 = ignorer**. Le `com PalRefresh` à la fin de `PalUpdateNow` remet à `$FF` (donc « plus de refresh ») et la prochaine appel sera ignoré.

---

## `PalUpdateNow` — application instantanée

```asm
PalUpdateNow
        tst   PalRefresh                ; 0 = refresh demandé
        bne   @rts                      ; sinon, sortir
        pshs  dp
        ldd   #$E7
        tfr   b,dp                      ; positionner DP à $E7
        ldx   Pal_current               ; X = adresse de la palette à appliquer
        sta   <$DB                      ; écrit l'index dans $E7DB (auto-init à 0)
!       ldd   ,x                        ; lit la couleur
        sta   <$DA                      ; écrit V/R dans $E7DA (auto-increment)
        stb   <$DA                      ; écrit M/B
        ldd   2,x                       ; couleur 2
        sta   <$DA
        stb   <$DA
        ; ... 16 fois en tout (boucle déroulée)
        com   PalRefresh                ; flag à $FF (plus de refresh)
        puls  dp,pc
@rts    rts
```

Approche **boucle déroulée** : 16 paires de `ldd; sta <$DA; stb <$DA` pour les 16 couleurs. Optimisé pour la vitesse (~150 cycles vs ~250 avec une boucle).

Variables hardware :
- `$E7DB` : index de la couleur à modifier (0-15)
- `$E7DA` : donnée de couleur, **auto-incrémente** l'index après chaque écriture

Donc une seule `sta <$DB` au début (index 0), puis 32 écritures successives à `$E7DA` (pour 16 couleurs × 2 octets).

### `PalUpdateNowLean` — version compacte

```asm
PalUpdateNow 
        tst   PalRefresh
        bne   @rts
        pshs  dp
        ldd   #$E7
        tfr   b,dp  
        ldx   Pal_current
        leay  32,x
        sty   @end
        sta   <$DB
!       ldd   ,x++                      ; auto-increment X
        sta   <$DA
        stb   <$DA
        cmpx  #0
@end    equ   *-2
        bne   <
        com   PalRefresh
        puls  dp,pc
@rts    rts
```

Boucle compacte avec `ldd ,x++` (auto-incr). Plus court en mémoire (~50 octets vs ~150) mais ~50% plus lent à l'exécution (~225 cycles).

À utiliser quand on a beaucoup de palettes différentes (ROM compact) et qu'on peut tolérer le délai.

---

## `PalCycling` — rotation des 3 premières couleurs

```asm
PalCyc_frames      fcb 0
PalCyc_frames_init fcb 0

PalCycling
        dec   PalCyc_frames
        bne   >
        lda   PalCyc_frames_init
        sta   PalCyc_frames
        clr   PalRefresh
        ldx   Pal_current
        ldu   4,x
        ldd   2,x
        std   4,x
        ldd   ,x
        std   2,x
        stu   ,x
!       jmp   PalUpdateNow
```

Tous les `PalCyc_frames_init` frames, rotate les **3 premières couleurs** : `[0,1,2] → [2,0,1]`.

Pré-requis : `PalCyc_frames_init` initialisé à la cadence souhaitée (e.g. 4 = rotation tous les 4 frames).

Usage typique : effet d'eau, lave, feu, plasma — palette qui « bouge ».

```asm
        ; Init
        lda   #4
        sta   PalCyc_frames_init
        sta   PalCyc_frames             ; pour le premier tour

        ; Dans MainLoop
        jsr   PalCycling                ; à chaque frame
```

**Limites** : rotate seulement les 3 premières couleurs. Pour cycling sur d'autres couleurs ou plus de slots, écrire une variante custom.

---

## `PalRaster_1c` — palette à mi-écran (raster effect)

Change **1 couleur de la palette** à chaque scanline pour produire un effet visuel impossible avec une palette statique (dégradé, halo, plasma).

```asm
PalRas_page   fdb $00                   ; page mémoire des données raster
PalRas_start  fdb $0000                 ; adresse début des données
PalRas_end    fdb $0000                 ; adresse fin

PalRaster_1c 
        lda   PalRas_page
        _SetCartPageA
        ldx   PalRas_start
        lda   #32        
!       bita  <$E7                      ; attend que le spot soit hors zone visible
        beq   <
!       bita  <$E7 
        bne   <                         ; attend que le spot soit dans zone visible
        mul                             ; tempo (sync précise)
        ; ...
        ldd   1,x                       ; lit la donnée raster
        sta   <$DB
        ldd   #0
        stb   <$DA 
        sta   <$DA
        leax  3,x                       ; 3 octets par entrée
        cmpx  PalRas_end
        bne   <
        rts
```

Données raster : suite de tuples `(index_couleur, blue_green, marker_red)` (3 octets).

À appeler depuis `UserIRQ` (sur synchronisation VBL) pour avoir le bon timing.

Voir [references/raster-effects.md](references/raster-effects.md).

---

## Palettes engine prédéfinies

- `Pal_black.asm` : palette tout-noir (32 octets de 0)
- `Pal_white.asm` : palette tout-blanc

Constantes générées : `Pal_black`, `Pal_white` (pointeurs).

Usage : transitions (fade vers/depuis noir/blanc).

```asm
        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow
```

---

## Couleur de bordure — `$E7DD`

La bordure d'écran (zone hors viewport) est gérée séparément par `$E7DD` :

```asm
        lda   $E7DD
        anda  #$F0                      ; préserver bits hauts
        ora   #couleur_index            ; ajouter index 0-15
        sta   $E7DD
```

Le builder Java génère ce code automatiquement dans `LoadAct` quand `act.X.screenBorder=N` est défini.

`gfxlock.screenBorder.update` est la routine engine recommandée :

```asm
        ldb   #couleur_index
        jsr   gfxlock.screenBorder.update
```

Cela synchronise aussi `gfxlock.screenBorder.color` (utilisé par `gfxlock.bufferSwap.do`).

---

## Objet PaletteFade (`engine/objects/palette/fade/`)

Objet engine prêt à l'emploi pour faire un **fade progressif** d'une palette source vers une palette destination.

### `fade.equ` — offsets OST

```asm
o_fade_src       equ ext_variables       ; ptr palette source
o_fade_dst       equ ext_variables+2     ; ptr palette destination
o_fade_mask      equ ext_variables+4     ; masque alternance V/R par frame
o_fade_cycles    equ ext_variables+5     ; nb de pas (16 typiquement)
o_fade_save      equ ext_variables+6     ; buffer temporaire
o_fade_idx       equ ext_variables+8     ; index courant
o_fade_curwait   equ ext_variables+9     ; wait time courant
o_fade_wait      equ ext_variables+10    ; wait time entre pas
o_fade_callback  equ ext_variables+11    ; routine à appeler à la fin (2 octets)
o_fade_sleep     equ ext_variables+13    ; prochain trigger
o_fade_unload    equ ext_variables+15    ; 0 = pas de unload, non-zero = auto-unload
```

### Pattern d'usage

```asm
        jsr   LoadObject_u
        beq   @no_slot
        lda   #ObjID_fade
        sta   id,u
        ldd   Pal_current
        std   o_fade_src,u              ; palette source
        ldd   #Pal_game
        std   o_fade_dst,u              ; palette destination
        lda   #10
        sta   o_fade_wait,u             ; 10 frames entre chaque pas
        ; (callback et unload optionnels)
@no_slot
```

L'objet exécute automatiquement le fade frame par frame, modifie `Pal_buffer`, met `PalRefresh = 0` pour déclencher le refresh.

À la fin (16 pas), si `o_fade_unload != 0`, l'objet se supprime automatiquement.

Si `o_fade_callback` est non-null, la routine est appelée à la fin du fade (callback applicatif).

Voir [references/fade-object.md](references/fade-object.md).

---

## Objet raster-fade

Variante plus avancée qui combine **fade + raster** : la palette est faite avec des couleurs différentes à différentes scanlines.

### Subtypes

```asm
Sub_RasterFadeInColor  equ 1            ; fade-in à une couleur cible
Sub_RasterFadeOutColor equ 2            ; fade-out depuis couleur source
Sub_RasterMain         equ 3            ; affichage permanent avec raster
Sub_RasterCycle        equ 4            ; cycling
```

Voir [references/raster-fade-object.md](references/raster-fade-object.md).

---

## Build pipeline — palette depuis PNG

Le builder Java (`Palette.java` + `PaletteTO8.getPaletteData`) lit la palette du PNG indiqué dans `palette.Pal_<X>=path.png` et génère 32 octets de palette au bon format.

```properties
palette.Pal_TitleScreen=./game-mode/00/images/logo_pal.png
```

Génère un label `Pal_TitleScreen` (adresse 2 octets) pointant vers les 32 octets palette dans le code asm. Utilisé dans le code : `ldd #Pal_TitleScreen; std Pal_current`.

Le PNG doit être en **palette indexée** (4-bit ou 8-bit, max 16 couleurs effectives).

---

## Pitfalls

- **Confusion index PNG vs index runtime Thomson** : le builder `PaletteTO8.java` lit les couleurs du PNG aux index 1..16 et les écrit dans les slots Thomson 0..15 (shift de -1, car PNG idx 0 = transparent implicite). Dans le code asm (tables raster, `sta $E7DB`), il faut utiliser les **index runtime 0..15**. Erreur classique : commenter « idx 1 = HERBE » d'après ce que montre GIMP, puis écrire `fcb $01,...` → on adresse en fait la 2ème couleur. Cf. [references/palette-system.md](references/palette-system.md) section "Index couleur : PNG vs runtime Thomson".
- **Ordre des bytes inversé dans la table raster** (`PalRaster_1c`) : chaque entrée DOIT être `fcb idx, M_B, V_R` — l'octet `M_B` (bleu+marquage) AVANT `V_R` (vert+rouge). Contre-intuitif mais imposé par la séquence `stb` puis `sta` sur `$E7DA` (auto-incrémenté) qui écrit `byte[2]` à position N (= V_R) puis `byte[1]` à position N+1 (= M_B). Si on inverse, les couleurs sont visuellement aberrantes (vert ↔ bleu) sans aucune erreur. Cf. [references/raster-effects.md](references/raster-effects.md) section "ORDRE BYTES CRITIQUE".
- **Sens inversé de `PalRefresh`** : `$FF` = pas de refresh, `0` = refresh demandé. Erreur classique.
- **`PalUpdateNow` sans `clr PalRefresh`** avant : la routine est skipée silencieusement
- **Modifier `Pal_buffer` directement** sans `clr PalRefresh` : changement non appliqué visuellement (jusqu'au prochain trigger)
- **Pointer `Pal_current` vers une zone non-résidente** : si la palette est sur une page commutable et que la page n'est pas mountée au moment du refresh, lecture aléatoire → couleurs cassées
- **Appeler `PalUpdateNow` pendant une frame de rendu** : possible glitches visuels (changement de palette en milieu d'image). Préférer l'appel depuis `UserIRQ` (sur VBL)
- **`PalCycling` sans `PalCyc_frames_init`** : décrément infini, jamais de rotate
- **`PalRaster_1c` mal timé** : le `bita <$E7` synchronise sur le spot, mais le délai initial doit matcher exactement la première scanline du raster. Calibrage critique
- **Bordure changée sans `gfxlock.screenBorder.update`** : `gfxlock.bufferSwap.do` peut overwriter à la prochaine VBL
- **PNG palette mal indexée** : le builder peut générer du n'importe quoi si le PNG n'est pas en mode palette

---

## Références détaillées

- [references/palette-system.md](references/palette-system.md) — Buffer Pal_buffer/Pal_current, PalRefresh sémantique, format couleur 16-bit (V/R puis M/B), accès hardware $E7DA/$E7DB/$E7DD, comparaison PalUpdateNow vs Lean (boucle déroulée vs compacte), génération depuis PNG par builder Java (Palette.java, PaletteTO8)
- [references/palette-cycling.md](references/palette-cycling.md) — `PalCycling` algorithme, rotation des 3 premières couleurs, `PalCyc_frames`/`PalCyc_frames_init`, patterns water/lava/plasma, variantes custom (cycling sur d'autres couleurs ou plus de slots)
- [references/raster-effects.md](references/raster-effects.md) — `PalRaster_1c` détaillé : synchronisation spot via `bita <$E7`, format données raster (3 octets/entrée : color_idx + V_R + M_B), placement dans UserIRQ, timing critique, exemples sky gradient / horizon
- [references/fade-object.md](references/fade-object.md) — `PaletteFade` objet engine complet : 4 routines (Init/Wait/Main/Idle), offsets OST détaillés, exemple chargement, callback applicatif, auto-unload, masque alternance V/R par frame (16 pas = 16 niveaux entre source et dest), interaction avec Pal_buffer
- [references/raster-fade-object.md](references/raster-fade-object.md) — `raster-fade` objet avancé : subtypes (FadeIn/FadeOut/Main/Cycle), offsets OST raster_*, intégration avec PalRaster_1c, patterns dégradé d'écran (sky, sunset, eau), cycling raster
- [references/screen-border.md](references/screen-border.md) — Couleur bordure `$E7DD`, `gfxlock.screenBorder.color`, `gfxlock.screenBorder.update`, intégration avec `gfxlock.bufferSwap.do`, `act.X.screenBorder` property et code généré par builder, conventions de couleur (typiquement noir 0 ou couleur de la palette)
