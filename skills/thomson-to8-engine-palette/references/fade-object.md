# Objet `PaletteFade` — transition progressive

L'objet engine `PaletteFade` (à `engine/objects/palette/fade/`) gère une **transition progressive** d'une palette source vers une palette destination, sur N frames.

## `fade.properties`

```properties
code=./engine/objects/palette/fade/fade.asm
```

À déclarer dans le game-mode :
```properties
object.fade=./engine/objects/palette/fade/fade.properties
# ou via gameModeCommon
```

Génère `ObjID_fade` et `ObjID_PaletteFade`.

## Offsets OST

```asm
o_fade_src       equ ext_variables       ; ptr palette source (2)
o_fade_dst       equ ext_variables+2     ; ptr palette destination (2)
o_fade_mask      equ ext_variables+4     ; masque alternance V/R (1)
o_fade_cycles    equ ext_variables+5     ; nb pas (typiquement 16) (1)
o_fade_save      equ ext_variables+6     ; buffer compare (2)
o_fade_idx       equ ext_variables+8     ; index couleur courant (1)
o_fade_curwait   equ ext_variables+9     ; wait courant (1)
o_fade_wait      equ ext_variables+10    ; wait entre pas (1)
o_fade_callback  equ ext_variables+11    ; routine callback fin (2)
o_fade_sleep     equ ext_variables+13    ; prochain trigger (2)
o_fade_unload    equ ext_variables+15    ; 0 = pas unload, !0 = auto-unload (1)
```

Total : 16 octets dans `ext_variables`. Pré-requis : `ext_variables_size >= 16` dans `ram-data.asm`.

## Routines

```asm
PaletteFade_Routines
        fdb   PaletteFade_Init           ; 0
        fdb   PaletteFade_Wait           ; 1
        fdb   PaletteFade_Main           ; 2
        fdb   PaletteFade_Idle           ; 3
```

État machine :
- **Init (0)** : recopie la palette source dans `Pal_buffer`, prépare les compteurs
- **Wait (1)** : attend `o_fade_curwait` frames avant chaque pas
- **Main (2)** : applique un pas de fade (modifie 1 ou 2 composantes de la palette en cours)
- **Idle (3)** : fade terminé, attend ou se supprime

## Pattern d'usage — chargement

```asm
        jsr   LoadObject_u
        beq   @no_slot
        lda   #ObjID_fade
        sta   id,u
        
        ldd   Pal_current               ; source = palette actuelle
        std   o_fade_src,u
        
        ldd   #Pal_game                  ; destination
        std   o_fade_dst,u
        
        lda   #10                        ; 10 frames entre pas
        sta   o_fade_wait,u
        
        ldd   #my_callback               ; (optionnel) routine à appeler à la fin
        std   o_fade_callback,u
        
        lda   #1                         ; auto-unload à la fin
        sta   o_fade_unload,u
@no_slot
```

## Mécanique du fade

1. **Init** : recopie `Pal_buffer = source`. Init `o_fade_cycles = $10` (16 pas), `o_fade_mask = $0F`.
2. **Pas par pas** :
   - Compare `Pal_buffer[i]` avec `dest[i]`
   - Si différent, incrémente/décrémente la composante (V, R, ou B selon mask)
   - L'alternance V/R par frame permet de faire un fade plus visible (chaque composante avance ~1 niveau par 2 frames)
3. **Wait** : entre chaque pas, `o_fade_wait` frames d'attente
4. **Fin** : quand toutes les couleurs égalent la destination, appelle `o_fade_callback` (si non-null) puis :
   - Si `o_fade_unload != 0` : `UnloadObject_u`
   - Sinon : passe en `PaletteFade_Idle`

## Durée totale

`durée_totale = o_fade_cycles × o_fade_wait` frames

Avec `o_fade_cycles = 16` (constante) et `o_fade_wait = 10` : 160 frames = ~3.2s à 50 Hz.

Pour un fade plus rapide : `o_fade_wait = 5` → 80 frames = 1.6s.
Pour très rapide : `o_fade_wait = 1` → 16 frames = 320 ms.

## Callback de fin

```asm
my_callback
        ; ce code s'exécute quand le fade est terminé
        ; ... (e.g. déclencher un changement de game-mode, jouer un son, ...)
        rts
```

Permet de chaîner des actions au moment précis de fin de fade.

## Auto-unload

Si `o_fade_unload != 0`, l'objet se supprime après la fin. Pratique pour les fades one-shot (intro, transition).

Si `o_fade_unload = 0`, l'objet reste en routine `Idle` — peut être réutilisé en remettant `o_fade_src`/`o_fade_dst` et en passant `routine = 0` (re-init).

## Patterns courants

### Fade-in (apparition)

```asm
        ; à l'init du game-mode
        ldd   #Pal_black
        std   Pal_current               ; commence en noir
        clr   PalRefresh
        jsr   PalUpdateNow

        ; lancer le fade vers la palette du niveau
        jsr   LoadObject_u
        beq   @no_slot
        lda   #ObjID_fade
        sta   id,u
        ldd   #Pal_black
        std   o_fade_src,u
        ldd   #Pal_game
        std   o_fade_dst,u
        lda   #6
        sta   o_fade_wait,u
        lda   #$FF
        sta   o_fade_unload,u
@no_slot
```

### Fade-out (disparition)

```asm
        ; trigger : fin du niveau
        jsr   LoadObject_u
        beq   @no_slot
        lda   #ObjID_fade
        sta   id,u
        ldd   Pal_current
        std   o_fade_src,u
        ldd   #Pal_black
        std   o_fade_dst,u
        lda   #6
        sta   o_fade_wait,u
        ldd   #ChangeToNextLevel        ; callback déclenche le change
        std   o_fade_callback,u
        lda   #$FF
        sta   o_fade_unload,u
@no_slot
```

### Cross-fade entre palettes

```asm
        ; bascule de Pal_level1 vers Pal_level2 sans passer par noir
        ldd   #Pal_level1
        std   o_fade_src,u
        ldd   #Pal_level2
        std   o_fade_dst,u
        ; ...
```

## Pattern goldorak — `_palette.fade` macro

Dans goldorak (cf. `global/global-macros.asm`), une macro encapsule l'init :

```asm
_palette.fade #Pal_black,#Palette_splash,PALETTE_FADER,#$60,#NO_CALLBACK,#$FF
```

Paramètres :
- `\1` : source
- `\2` : destination
- `\3` : objet ID du fader
- `\4` : wait time
- `\5` : callback (ou `NO_CALLBACK`)
- `\6` : unload flag

Pattern d'abstraction qui pourrait être intégré dans `engine/` (cf. note utilisateur sur l'école goldorak).

## Pitfalls

- **`o_fade_src` / `o_fade_dst` mal pointés** : crash (palette lue à mauvaise adresse)
- **`o_fade_wait = 0`** : fade instantané (en 16 frames) — pas un bug mais surprenant
- **`o_fade_callback` à une adresse invalide** : crash en fin de fade
- **`o_fade_unload = 0` mais on relance un autre fade** : il faut re-init `routine = 0`
- **Plusieurs `PaletteFade` actifs simultanément** : conflit sur `Pal_buffer` (les deux modifient en même temps) → résultat imprévisible. Toujours un seul fade actif à la fois
- **Fade source = `Pal_buffer`** : OK, mais alors le fade modifie sa propre source (la source change pendant le fade). Pas un bug, mais subtil
- **Modifier `Pal_current` pendant un fade** : le fade continue d'écrire dans `Pal_buffer` mais le hardware affiche autre chose
- **`ext_variables_size < 16`** : les offsets du fade débordent → corruption mémoire
