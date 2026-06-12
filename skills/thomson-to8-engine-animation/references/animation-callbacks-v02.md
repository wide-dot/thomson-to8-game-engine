# Callbacks d'animation v02

Le format v02 (5 octets/frame avec duration et flags) permet de **déclencher des callbacks applicatifs** synchronisés avec les frames de l'animation. Mécanisme : le champ `flags` (1 octet par frame) est lu par `AnimateSpriteAdv` et stocké dans `anim_flags,u`. Le code applicatif peut le consulter pour exécuter une action.

## Principe

```properties
animation.Ani_Punch=Img_anticipate,4,$00;Img_strike,1,$01;Img_recover,4,$00;_resetAnim
```

À chaque frame, après l'appel à `AnimateSpriteAdv`, le code peut faire :

```asm
        jsr   AnimateSpriteAdv
        lda   anim_flags,u
        cmpa  #$01
        bne   @no_hitbox
        jsr   DamageHitbox              ; appliquer dégâts maintenant
@no_hitbox
        jmp   DisplaySprite
```

`$01` est arbitraire — c'est l'application qui définit la sémantique.

## Pattern avec LUT applicative

Pour découpler la logique de la valeur de flag, utiliser une **LUT (Look-Up Table)** :

```asm
; LUT — une routine par valeur de flag
Punch_FlagLut
        fdb   Punch_NoOp                ; $00 → rien
        fdb   Punch_Hitbox              ; $01 → dégâts
        fdb   Punch_SoundFX             ; $02 → son
        fdb   Punch_Particle            ; $03 → particule

Punch_NoOp
        rts

Punch_Hitbox
        ; ... appliquer dégâts ...
        rts

Punch_SoundFX
        ; ... jouer son ...
        rts

Punch_Particle
        ; ... émettre particule ...
        rts
```

Dans la routine principale :

```asm
Main
        jsr   AnimateSpriteAdvSync      ; met à jour anim_flags,u
        ldb   anim_flags,u
        aslb
        ldx   #Punch_FlagLut
        jsr   [b,x]                     ; appel indirect
        jmp   DisplaySprite
```

Coût : ~25 cycles pour le dispatch + cycles de la callback. Comparable à un test conditionnel direct mais beaucoup plus extensible.

## Plusieurs flags simultanés (bitfield)

Si `flags` est interprété comme un **bitfield** plutôt qu'un index, on peut combiner :

```asm
HITBOX_FLAG     equ $01
SFX_FLAG        equ $02
PARTICLE_FLAG   equ $04

Main
        jsr   AnimateSpriteAdvSync
        lda   anim_flags,u
        bita  #HITBOX_FLAG
        beq   @no_hitbox
        jsr   ApplyHitbox
@no_hitbox
        bita  #SFX_FLAG
        beq   @no_sfx
        jsr   PlaySFX
@no_sfx
        bita  #PARTICLE_FLAG
        beq   @no_particle
        jsr   EmitParticle
@no_particle
        jmp   DisplaySprite
```

Permet par exemple : `flags = $03` → hitbox ET son.

## Conventions de flag

Choisir une convention par animation ou globale au projet :

### Convention par animation (locale)

```properties
animation.Ani_Slash=Img_a,2,$00;Img_b,1,$01;Img_c,2,$00;_resetAnim   ; $01 = slash hitbox
animation.Ani_Punch=Img_a,2,$00;Img_b,1,$01;Img_c,2,$00;_resetAnim   ; $01 = punch hitbox
```

Avantage : pas de table globale, chaque animation a sa sémantique. Code de l'objet teste `flags = $01` et déclenche l'action de l'animation courante.

### Convention globale (table)

Tous les `$01` du jeu = hitbox, tous les `$02` = son, etc. Plus de cohérence mais moins de flexibilité.

## Cas pratique — combo avec timing

```properties
animation.Ani_Combo=Img_anticipate,6,$00;Img_strike1,1,$01;Img_recover,3,$00;Img_anticipate,4,$00;Img_strike2,1,$03;Img_recover,5,$00;_resetAnim
```

Avec `$01 = HITBOX_FLAG`, `$02 = HITSTUN_FLAG`, `$03 = HITBOX | HITSTUN` :

- Frame 1 (anticipate) : rien
- Frame 2 (strike1) : hitbox (1er coup léger)
- Frame 3 (recover) : rien
- Frame 4 (anticipate) : rien
- Frame 5 (strike2) : hitbox + hitstun (2ème coup + immobilise la cible)
- Frame 6 (recover) : rien

Tout est piloté par le script d'animation, sans logique conditionnelle complexe.

## Interaction avec `routine_secondary`

L'animation v02 peut piloter directement `routine_secondary` via `_nextSubRoutine` ou `_resetAnimAndSubRoutine` (tags $FA/$FB), ce qui complète le mécanisme de callbacks par flag.

```properties
animation.Ani_Sequence_step1=Img_a,2,$01;Img_b,2,$00;_nextSubRoutine
animation.Ani_Sequence_step2=Img_c,2,$02;Img_d,2,$00;_resetAnimAndSubRoutine
```

Chaque étape se termine par un tag de transition.

## Coût

`AnimateSpriteAdv` lit le flag à chaque frame et stocke dans `anim_flags,u` (~5 cycles supplémentaires par rapport à `AnimateSprite`).

Le code applicatif (LUT, bita, jsr) ajoute ~15-30 cycles selon la complexité.

## `anim_flags` overlap avec `status_flags`

`anim_flags` est à l'offset 14 — **même offset que `status_flags`**. En mode v02 :
- `anim_flags,u` est écrit à chaque frame par `AnimateSpriteAdv`
- `status_flags,u` est donc **écrasé**

Implication : en v02, on **perd l'usage de `status_flags`** pour l'orientation xflip/yflip. Il faut gérer xflip/yflip directement via `render_flags,u`.

```asm
; Avant (v00) — orientation via status_flags
        lda   status_flags,u
        ora   #status_xflip_mask
        sta   status_flags,u

; Avec v02 — orientation directement via render_flags
        lda   render_flags,u
        ora   #render_xmirror_mask
        sta   render_flags,u
```

C'est un trade-off du format v02.

## Pitfalls

- **`AnimateSprite` (v00) sur animation v02** : flags non lus, callbacks pas déclenchées
- **`AnimateSpriteAdv` sur v00** : interprète la duration comme un pointeur Img_, crash
- **LUT avec moins d'entrées que de valeurs de flag possibles** : flag $05 sur LUT de 4 entrées → lecture hors range
- **Modifier `anim_flags,u` après `AnimateSpriteAdv`** : valide, mais sera écrasé à la prochaine frame
- **Confondre `anim_flags` et `render_flags`** : ce sont deux champs différents (offset 14 vs 2). `anim_flags` est mis à jour par AnimateSpriteAdv, `render_flags` par l'utilisateur
- **Callbacks coûteuses** : si la callback met 1000 cycles, sur 25 sprites animés ça pète le budget frame
- **State pollution via `anim_flags`** : si on utilise aussi `status_flags`, choisir lequel a priorité
