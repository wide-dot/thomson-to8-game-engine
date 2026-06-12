# State machines — `routine` et `routine_secondary/tertiary/quaternary`

Chaque objet a **4 indices de routine** indépendants permettant d'implémenter jusqu'à 4 state machines en parallèle :

| Offset | Symbole | Usage typique |
|--------|---------|---------------|
| 34 | `routine` | State machine principale (Init/Main/Die) |
| 35 | `routine_secondary` | Animation / déplacement secondaire |
| 36 | `routine_tertiary` | IA / comportement scripté |
| 37 | `routine_quaternary` | Effets visuels / sub-effects |

## Pattern de base — `routine` principale

```asm
<Name>
        lda   routine,u
        asla                            ; *2 (fdb = 2 octets)
        ldx   #<Name>_Routines
        jmp   [a,x]                     ; saut indirect

<Name>_Routines
        fdb   Init                      ; routine 0
        fdb   Main                      ; routine 1
        fdb   Die                       ; routine 2

Init
        ; ... config initiale ...
        inc   routine,u                 ; passe en routine 1
        rts

Main
        ; ... logique frame par frame ...
        jsr   AnimateSprite
        jmp   DisplaySprite

Die
        ; ... animation de mort ...
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u
        rts
```

## Sous-state machine — `routine_secondary`

```asm
Main
        ; Dispatcher principal
        ldb   routine,u
        ; ... main logic ...
        
        ; Dispatcher secondaire (e.g. animation)
        lda   routine_secondary,u
        asla
        ldx   #Anim_SubRoutines
        jmp   [a,x]

Anim_SubRoutines
        fdb   AnimWalk
        fdb   AnimRun
        fdb   AnimJump

AnimWalk
        ldd   #Ani_Walk
        std   anim,u
        jsr   AnimateSprite
        rts

; ...
```

## Patterns observés

### Convention `_routine` suffixe

Plutôt que de hardcoder les indices (0, 1, 2), définir des constantes nommées au début de l'objet :

```asm
Init_routine       equ 0
Ground_routine     equ 1
Jump_routine       equ 2
Fall_routine       equ 3
FallSlowly_routine equ 4
Fly_routine        equ 5
```

Et basculer entre états en nommé :
```asm
        lda   #Jump_routine
        sta   routine,u
```

C'est le pattern de bubble-bobble. Bien plus lisible que `lda #2; sta routine,u`.

### Pattern Init terminé par routine choisie

Plutôt que `inc routine,u` (qui passe en routine 1 systématiquement), choisir explicitement :

```asm
Init
        ; ... config initiale ...
        lda   #Ground_routine           ; passe directement en Ground
        sta   routine,u
        ; pas de rts ici, on tombe sur le code de Ground
        ; (ou rts si on veut attendre la prochaine frame)
Ground
        ; ...
```

Permet de chaîner immédiatement (gain d'une frame) ou différer (`rts` à la fin de Init).

### Sub-routines pour animation découplée

L'animation peut avoir sa propre state machine indépendante du déplacement :

```asm
Main
        ; déplacement (routine principale)
        ; ...
        
        ; animation (routine_secondary)
        lda   routine_secondary,u
        asla
        ldx   #Anim_Routines
        jmp   [a,x]

Anim_Routines
        fdb   AnimIdle
        fdb   AnimAttack
        fdb   AnimDamage

AnimIdle
        ldd   #Ani_Idle
        std   anim,u
        rts

; transition depuis un autre point du code :
        lda   #Anim_Attack
        sta   routine_secondary,u
```

### Triple state machine (routine + secondary + tertiary)

Pattern observé chez r-type (player1) :
- `routine` : état physique (Air, Ground, ChargingBeam)
- `routine_secondary` : forme du tir (Wave, Reflect, Search)
- `routine_tertiary` : forcepod actif ou non

Permet de combiner ces états sans explosion combinatoire de routines.

## Interaction avec animation v00/v02 — tag `_nextRoutine`

L'animation v00 peut terminer par `_nextRoutine` :
```properties
animation.Ani_Die=2;Img_die_a;Img_die_b;Img_die_c;_nextRoutine
```

Quand `AnimateSprite` rencontre ce tag, il appelle `inc routine,u`. Cela permet de **chaîner une transition d'état via l'animation** : « quand l'animation de mort est finie, passer à la routine suivante (typiquement la libération du slot) ».

Variante : `_resetAnimAndSubRoutine` (clear `routine_secondary` à 0 et reset l'anim), `_nextSubRoutine` (`inc routine_secondary,u`).

## Cas pratique — objet ennemi avec 3 phases

```asm
Spider
        lda   routine,u
        asla
        ldx   #Spider_Routines
        jmp   [a,x]

Spider_Routines
        fdb   Init                      ; 0 : entrer
        fdb   Patrol                    ; 1 : patrouille
        fdb   Attack                    ; 2 : attaque
        fdb   Stunned                   ; 3 : sonné
        fdb   Die                       ; 4 : mort

Init
        ldd   #Ani_Spider_Walk
        std   anim,u
        ldb   #3
        stb   priority,u
        ; ... AABB ...
        inc   routine,u
        rts

Patrol
        ; déplacement
        jsr   ObjectMoveSync
        ; détection joueur
        jsr   Obj_GetOrientationToPlayer
        ldd   Gotp_Player_H_Distance
        cmpd  #100
        bhs   @no_attack
        lda   #2                        ; routine Attack
        sta   routine,u
@no_attack
        jsr   AnimateSprite
        jmp   DisplaySprite

Attack
        ; ... ouvre la mâchoire, etc ...

Stunned
        ; ... timer ...

Die
        ; ... animation puis suppression ...
```

## Pitfalls

- **Oublier `inc routine,u` ou `sta routine,u` à la fin d'Init** : Init est rappelée à chaque frame
- **Modifier `routine_secondary,u` sans avoir initialisé la sub-state machine** : crash sur jump indirect
- **Confondre `routine` (8 bits, 0-127) et `anim` (16 bits, pointeur)** : `routine` est un index, `anim` est une adresse
- **`asla` après une routine > 127** : on déborde sur le bit de signe, la table d'adresses indirecte plante. Limiter à 128 routines max (de toute façon irréaliste)
- **Modifier `routine,u` avec la routine actuellement en cours** : OK, le changement prend effet à la frame suivante (sauf si on continue à exécuter du code après le changement, attention à pas faire les deux logiques en parallèle)
