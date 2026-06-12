# Tags de fin d'animation — sémantique précise

Les tags ($FA-$FF) terminent (ou modifient le flux de) une animation. Chaque tag a une sémantique précise lue par `AnimateSprite`.

## Table de référence

| Mnémonique | Hex | Octets | Effet |
|------------|-----|--------|-------|
| `_resetAnim` | $FF | 1 | Boucle au début |
| `_goBackNFrames` | $FE | 2 (FE + N) | Recule de N frames |
| `_goToAnimation` | $FD | 3 (FD + addr) | Bascule sur une autre animation |
| `_nextRoutine` | $FC | 1 | `inc routine,u` + reset anim_frame_duration |
| `_resetAnimAndSubRoutine` | $FB | 1 | Reset anim_frame=0 ET routine_secondary=0 |
| `_nextSubRoutine` | $FA | 1 | `inc routine_secondary,u` |

Détection : `cmpa #$FA; bhs Anim_End_FF` (tout octet >= $FA est un tag).

## `_resetAnim` ($FF) — boucle infinie

```asm
Anim_End_FF
        inca                            ; A passe de $FF à $00
        bne   Anim_End_FE
        ; A = 0 → tag est $FF
        ldb   #0
        stb   anim_frame,u              ; reset à la frame 0
        ldd   ,x                        ; relit la première frame
        bra   Anim_Next                 ; affiche immédiatement
```

Usage :
```properties
animation.Ani_Idle=2;Img_001;Img_002;Img_003;_resetAnim
```

Animation en boucle infinie. Le moteur revient à `Img_001` après `Img_003`.

## `_goBackNFrames` ($FE) — recul

```asm
Anim_End_FE
        inca                            ; $FE + 1 = $FF? non, +1 = $FF, vérifie via inca puis bne
        ; ... (le code utilise inca pour distinguer FE de FD et FC)
        lda   anim_frame,u
        stb   Anim_End_FE_dyn+1         ; B = N (le param du tag)
        suba  #$00                      ; dynamic : soustrait N
        sta   anim_frame,u
        ldb   #2
        mul                             ; ajuste l'index dans la table d'images
        ldd   d,x
        bra   Anim_Next
```

Param : 1 octet (N) après le $FE.

Usage :
```properties
animation.Ani_PingPong=2;Img_a;Img_b;Img_c;Img_d;_goBackNFrames;3
```

Le moteur joue `a, b, c, d` puis recule de 3 frames → revient à `b` → joue `b, c, d` puis recule à `b` → ainsi de suite. Effet ping-pong.

## `_goToAnimation` ($FD) — chaînage

```asm
Anim_End_FD
        inca
        bne   Anim_End_FC
        ldd   1,y                       ; lire les 2 octets après FD = adresse de la nouvelle anim
        std   anim,u
        bra   Anim_Rts                  ; sortir, la nouvelle anim sera jouée à la prochaine frame
```

Param : 2 octets (adresse `Ani_<X>`) après le $FD.

Usage :
```properties
animation.Ani_Intro=4;Img_intro_a;Img_intro_b;Img_intro_c;_goToAnimation;Ani_Loop
animation.Ani_Loop=2;Img_loop_a;Img_loop_b;_resetAnim
```

Le moteur joue `Ani_Intro` une fois puis bascule sur `Ani_Loop` en boucle.

> Le moteur ne **reset pas** `anim_frame` au passage à la nouvelle animation. C'est `AnimateSprite` qui détecte le changement via `prev_anim != anim` et reset.

## `_nextRoutine` ($FC) — transition d'état

```asm
Anim_End_FC
        inca
        bne   Anim_End_FB
        inc   routine,u                 ; passe à la routine suivante
        lda   #0
        sta   anim_frame_duration,u
        inc   anim_frame,u
        bra   Anim_Rts
```

Effet :
- `inc routine,u` → l'objet passe à la routine suivante
- Reset `anim_frame_duration` à 0
- Incrémente `anim_frame` (pour ne pas revoir le tag à la prochaine frame de cette même animation)

Usage :
```properties
animation.Ani_Die=3;Img_die_a;Img_die_b;Img_die_c;_nextRoutine
```

Quand `Ani_Die` finit, l'objet passe à `routine+1` (typiquement la routine de cleanup ou suppression). Permet de chaîner « animation puis logique » en mode déclaratif.

## `_resetAnimAndSubRoutine` ($FB)

```asm
Anim_End_FB
        inca
        bne   Anim_End_FA
        lda   #0
        sta   anim_frame,u              ; reset frame 0
        sta   routine_secondary,u       ; reset sous-routine
        bra   Anim_Rts
```

Combinaison `_resetAnim` + reset de `routine_secondary,u`. Usage : terminer une sub-séquence et revenir à un état initial.

```properties
animation.Ani_AttackCombo_a=2;Img_atk_a;Img_atk_b;_resetAnimAndSubRoutine
```

Si l'attaque a été interrompue dans sa séquence (`routine_secondary=2` était utilisé pour tracker l'étape), reset à 0.

## `_nextSubRoutine` ($FA)

```asm
Anim_End_FA
        inca
        bne   Anim_End                  ; (n'est pas un tag connu)
        inc   routine_secondary,u
        bra   Anim_Rts                  ; (via Anim_End)
```

Effet : `inc routine_secondary,u`. Animation finie → passe à la sous-routine suivante.

```properties
animation.Ani_AttackCombo_step1=2;Img_001;Img_002;_nextSubRoutine
animation.Ani_AttackCombo_step2=2;Img_003;Img_004;_nextSubRoutine
animation.Ani_AttackCombo_step3=2;Img_005;Img_006;_resetAnim
```

Permet une state-machine d'animation au niveau de la sub-routine, indépendante de `routine`.

## Combinaisons

Tu peux combiner plusieurs tags dans une animation, mais ils s'excluent mutuellement (le moteur lit le premier tag rencontré et n'évalue pas les suivants).

```properties
animation.Ani_Conditional=2;Img_a;Img_b;_nextRoutine;Img_c   ← Img_c jamais joué
```

`_nextRoutine` est exécuté après `Img_b`, l'objet passe à `routine+1` qui peut sélectionner une autre animation.

## Tags v02

En format v02, les tags sont placés **après** la dernière frame (5 octets/frame). Sémantique identique. Le moteur (`AnimateSpriteAdv`) détecte les tags par la valeur >= $FA après l'avancement.

## Conventions de nommage

L'équivalence asm est dans `engine/graphics/animation/constants-animation.equ` :

```asm
_resetAnim                    equ $FF
_goBackNFrames                equ $FE
_goToAnimation                equ $FD
_nextRoutine                  equ $FC
_resetAnimAndSubRoutine       equ $FB
_nextSubRoutine               equ $FA
```

Ce fichier est inclus via `builder.constAnim=./engine/graphics/animation/constants-animation.equ` (cf. config-windows.properties).

## Pitfalls

- **Tag accidentel dans les données** : si l'animation déborde, le moteur peut tomber sur un octet $FA-$FF dans la mémoire suivante et déclencher un tag involontaire. Toujours terminer par un tag explicite.
- **`_goBackNFrames` avec N > nb_frames** : sous-flow de `anim_frame`, comportement imprévisible. Toujours N < frame courante.
- **`_goToAnimation` avec adresse invalide** : crash. Vérifier que `Ani_<X>` est bien défini.
- **`_nextRoutine` sans routine suivante définie** : `routine,u` passe à un index hors range → jump indirect sur une mauvaise adresse → crash
- **Tag dans une animation à 1 frame** : pas de réelle « fin » à atteindre, le tag s'exécute à chaque frame
- **Mélange `_resetAnim` (boucle) et `_nextRoutine`** : choisir un seul ; le second est exécuté seulement si le `anim_frame` traverse le `_nextRoutine` et le `_resetAnim` est passé
- **Convention « -1 » du builder** : `duration=2` dans .properties → stocké en mémoire comme `01` ; n'oublie pas que le `0` (1 frame d'affichage) est valide
