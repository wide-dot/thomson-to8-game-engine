---
name: thomson-to8-engine-animation
description: "Décrit le système d'animation du Thomson TO8/TO9 game engine (Bento8/wide-dot) : routines AnimateSprite (basique), AnimateSpriteSync (synchro framerate via gfxlock.frameDrop.count), AnimateSpriteLoad et AnimateSpriteAdvLoad (reload frame sans avancer), AnimateSpriteAdv et AnimateSpriteAdvSync (animation avancée v02 avec durée et flags par frame, callbacks dynamiques via anim_flags LUT), AnimateMove (animation pilotée par script de mouvement avec bitfield frame/x_vel/y_vel), moveByScript (scripts déclaratifs de trajectoire), format binaire d'une animation v00 (legacy : duration globale + suite de pointeurs Img_) et v02 (advanced : (Img_, duration, flags) par frame, 5 octets), tags de fin _resetAnim FF, _goBackNFrames FE, _goToAnimation FD, _nextRoutine FC, _resetAnimAndSubRoutine FB, _nextSubRoutine FA, mécanique du champ anim,u (positif = adresse directe, négatif = offset signed dans Ani_Asd_Index LUT), résolution de anim par Ani_Page_Index/Ani_Asd_Index, état anim_frame/anim_frame_duration/anim_flags/prev_anim/sub_anim, application des status_flags (xflip/yflip) sur render_flags pendant l'animation, anim_link_mask pour charger une nouvelle anim sans reset, image_set mis à jour à chaque frame, intégration avec routine/routine_secondary via _nextRoutine/_nextSubRoutine. Utiliser pour comprendre comment animer un sprite, choisir entre v00 et v02, débugger une animation qui ne progresse pas, scripter une chaîne d'animations (intro → loop), déclencher un changement d'état via animation finie, programmer une trajectoire scriptée. Mots-clés : AnimateSprite, AnimateSpriteSync, AnimateSpriteLoad, AnimateSpriteAdv, AnimateSpriteAdvSync, AnimateSpriteAdvLoad, AnimateMove, AnimateMoveInit, moveByScript, moveByScript.register, moveByScript.initialize, moveByScript.runByFrameDrop, moveByScript.runByB, moveByScript.NEGXSTEP, moveByScript.POSXSTEP, moveByScript.NEGYSTEP, moveByScript.POSYSTEP, anim, anim+1, prev_anim, sub_anim, anim_frame, anim_frame_duration, anim_flags, anim_link_mask, image_set, status_flags, status_xflip_mask, status_yflip_mask, render_flags, render_xmirror_mask, render_ymirror_mask, Ani_Page_Index, Ani_Asd_Index, Ani_, Img_, _resetAnim, _goBackNFrames, _goToAnimation, _nextRoutine, _resetAnimAndSubRoutine, _nextSubRoutine, $FF, $FE, $FD, $FC, $FB, $FA, animation v00, animation v02, animation script, animation data, animation-data property, frame duration, animation rate, frameDrop adaptive."
machines: [to8, to8d, to9, to9+]
user-invocable: false
---

# Animation — Thomson TO8/TO9 Game Engine

L'animation des sprites est pilotée par des **scripts** déclaratifs (déclarés dans le `.properties` de l'objet) qui sont compilés en binaire par le builder Java et placés en mémoire. À chaque frame, une routine d'animation lit le script courant, met à jour `image_set,u` (sprite à afficher), gère la progression (`anim_frame`, `anim_frame_duration`), et déclenche des callbacks (changement d'animation, transition de routine).

Ce skill couvre : les 7 routines d'animation (`AnimateSprite*`), les deux formats de script (v00 legacy et v02 advanced), les tags de fin, l'intégration avec les state machines via `_nextRoutine`, et le système `moveByScript` (scripts de trajectoire).

---

## Vue d'ensemble

```
Objet OST :
  anim,u (offset 8-9)            → pointeur vers le script binaire courant
  prev_anim,u (offset 10-11)     → script précédent (pour détecter changement)
  anim_frame,u (offset 12)       → index de la frame courante dans le script
  anim_frame_duration,u (off 13) → décompte de frames restantes pour image
  anim_flags,u (offset 14)       → flags ou LUT offset (v02)
  status_flags,u (offset 14)     → orientation (xflip/yflip) — overlap avec anim_flags
  image_set,u (offset 16-17)     → pointeur vers Img_ courant (lu par DrawSprites)

Mécanique frame :
  1. Charger anim,u → script address
  2. Comparer avec prev_anim,u → détection de changement
     - Si changé : reset anim_frame=0, anim_frame_duration=0 (sauf anim_link)
  3. Décrémenter anim_frame_duration
     - Si > 0 : pas de changement de frame, rts
     - Si <= 0 : avancer anim_frame, lire le nouveau frame
  4. Si la nouvelle frame est un tag ($FF..$FA), exécuter le tag
  5. Sinon : mettre à jour image_set,u avec le pointeur Img_
  6. Appliquer status_flags (xflip/yflip) sur render_flags
  7. Incrémenter anim_frame pour le prochain tour
```

---

## Les 7 routines d'animation

### `AnimateSprite` (basique)

```asm
        jsr   AnimateSprite             ; U = OST
```

Routine standard. Décrémente `anim_frame_duration` de 1 par frame. Si arrive à 0, charge la frame suivante.

### `AnimateSpriteSync` (synchro framerate)

```asm
        jsr   AnimateSpriteSync
```

Identique mais décrémente `anim_frame_duration` de `gfxlock.frameDrop.count` (typiquement 1 à 50 Hz, 2 à 25 Hz). Permet une vitesse d'animation **stable visuellement** même en cas de frame drop.

> **Pré-requis** : `gfxlock` doit être actif (`_gfxlock.loop` appelé chaque frame). Sans gfxlock, `frameDrop.count = 0`, ce qui fait que l'animation ne progresse jamais.

### `AnimateSpriteLoad`

Recharge le sprite courant **sans avancer**. Utile quand on a modifié `anim,u` mais qu'on veut afficher la frame immédiatement (au lieu d'attendre le prochain `AnimateSprite`).

### `AnimateSpriteAdv` (v02 avancée)

Pour le format animation v02 (5 octets/frame avec duration et flags). Lit `anim_flags,u` comme offset dans une LUT applicative pour déclencher des **callbacks** au moment précis de chaque frame (e.g. hitbox, son).

### `AnimateSpriteAdvSync`

Version sync de `AnimateSpriteAdv` (`gfxlock.frameDrop.count` appliqué).

### `AnimateSpriteAdvLoad`

Version load de `AnimateSpriteAdv` (recharge sans avancer).

### `AnimateMove`

Animation **dirigée par un script de mouvement** (`AnimateMoveInit` + `AnimateMove`). Le script définit pour chaque pas : frame à afficher, vélocité X, vélocité Y. Utile pour des trajectoires scriptées avec animation synchronisée.

---

## Format animation v00 (legacy)

Déclaration dans le `.properties` de l'objet :

```properties
animation.Ani_Idle=2;Img_Idle_000;Img_Idle_001;Img_Idle_002;_resetAnim
```

Le `2` est la **duration globale** (frames par image, **stockée en mémoire moins 1** par le builder).

Format binaire généré :
```
adresse_label    : (rien — label seulement)
adresse_label-1  : 01           ; duration-1 (donc 2 frames par image)
adresse_label+0  : pointeur Img_Idle_000 (2 octets)
adresse_label+2  : pointeur Img_Idle_001 (2 octets)
adresse_label+4  : pointeur Img_Idle_002 (2 octets)
adresse_label+6  : $FF (_resetAnim)
```

> **Détail crucial** : la duration est stockée **avant** le label, accessible via `-1,x`. C'est pour ça que le code asm fait `ldb -1,x; stb anim_frame_duration,u`.

## Format animation v02 (advanced)

Détecté automatiquement par le builder par la **présence d'une virgule** dans le premier champ.

```properties
animation.Ani_Attack=Img_Atk_001,3,$00;Img_Atk_002,2,$01;Img_Atk_003,5,$02;_nextRoutine
```

Chaque frame = `Img,duration,flags` (5 octets stockés : `fdb image; fcb duration-1; fcb flags`).

Format binaire :
```
adresse_label    : pointeur Img_Atk_001 (2)
adresse_label+2  : 02 (duration-1, soit 3 frames)
adresse_label+3  : 00 (flags = offset 0 dans LUT applicative)
adresse_label+4  : pointeur Img_Atk_002 (2)
adresse_label+6  : 01
adresse_label+7  : 01
adresse_label+8  : pointeur Img_Atk_003 (2)
adresse_label+10 : 04
adresse_label+11 : 02
adresse_label+12 : $FC (_nextRoutine)
```

Le builder lève une exception si une frame v02 n'a pas exactement 3 champs séparés par virgules.

## Tags de fin

| Tag | Hex | Octets | Effet |
|-----|-----|--------|-------|
| `_resetAnim` | $FF | 1 | Boucle au début (reset anim_frame=0, lit la première frame) |
| `_goBackNFrames` | $FE | 2 | `_goBackNFrames;<N>` — recule de N frames dans la séquence |
| `_goToAnimation` | $FD | 3 | `_goToAnimation;<Ani_X>` — bascule sur l'animation X (pointeur 2 octets) |
| `_nextRoutine` | $FC | 1 | `inc routine,u` (passe à la routine suivante de l'objet) |
| `_resetAnimAndSubRoutine` | $FB | 1 | Reset anim_frame=0 ET routine_secondary=0 |
| `_nextSubRoutine` | $FA | 1 | `inc routine_secondary,u` |

Voir [references/animation-formats.md](references/animation-formats.md) pour les détails binaires.

## Mécanisme `anim,u` — adresse vs offset

Le champ `anim,u` peut être :
- **Positif** (`bpl @a`) : adresse directe du script en mémoire
- **Négatif** : offset signé 8-bit dans `Ani_Asd_Index` LUT (animation set descriptor)

Le second mécanisme permet d'utiliser des **index courts** plutôt que des adresses pleines, économisant de la mémoire dans certains cas (animation set descriptors).

```asm
        ldx   anim,u
        bpl   @a                        ; positif → adresse directe
        ldx   #Ani_Asd_Index            ; négatif → consulte la LUT
        ldb   id,u                      ; B = ObjID_
        aslb
        abx
        ldx   [,x]                      ; load Ani_LUT premier
        ldb   anim+1,u                  ; load offset
        abx
        ldx   ,x                        ; load target anim address
@a      ; X = adresse du script
```

## `anim_link_mask` — chaînage sans reset

Quand l'utilisateur change `anim,u` pour passer à une autre animation, le moteur **reset** `anim_frame=0` et `anim_frame_duration=0` par défaut.

Si on veut continuer **à la même frame index** (par exemple pour une transition fluide), mettre le bit `anim_link_mask` dans `anim_flags,u` :

```asm
        ldd   #Ani_RunFast
        std   anim,u
        lda   anim_flags,u
        ora   #anim_link_mask
        sta   anim_flags,u
```

Le moteur ne reset pas et l'animation continue à la frame où elle était. Pratique pour passer de `Ani_Walk` à `Ani_Run` (mêmes frames, vitesse différente).

## Application de `status_flags` sur `render_flags`

Pendant `AnimateSprite`, le moteur applique `status_flags` (orientation locale de l'objet) sur les bits 0-1 de `render_flags` (orientation de rendu) :

```asm
        lda   status_flags,u
        anda  #status_xflip_mask|status_yflip_mask  ; bits 0-1
        sta   @dyn+1
        lda   render_flags,u
        anda  #^(render_xmirror_mask|render_ymirror_mask)
@dyn    ora   #0                                     ; modifié dynamiquement
        sta   render_flags,u
```

Effet : si `status_flags = $01` (xflip), alors `render_xmirror_mask` est mis dans `render_flags` au moment de l'animation. Permet de contrôler l'orientation via `status_flags` (variable de logique) sans toucher à `render_flags` (variable de rendu).

## Patterns d'usage

### Animation simple en boucle

```properties
animation.Ani_Idle=2;Img_Idle_001;Img_Idle_002;Img_Idle_003;_resetAnim
```

```asm
Init
        ldd   #Ani_Idle
        std   anim,u
        inc   routine,u
        rts

Main
        jsr   AnimateSprite
        jmp   DisplaySprite
```

### Chaînage intro → loop

```properties
animation.Ani_intro=4;Img_intro_001;Img_intro_002;Img_intro_003;_goToAnimation;Ani_loop
animation.Ani_loop=2;Img_loop_001;Img_loop_002;_resetAnim
```

### Animation puis transition d'état

```properties
animation.Ani_Die=2;Img_die_001;Img_die_002;Img_die_003;_nextRoutine
```

```asm
Init
        ; ...
        inc   routine,u                 ; passe à Live

Live
        ; si HP=0, déclencher Die
        tst   <my_hp
        bne   @alive
        ldd   #Ani_Die
        std   anim,u
        ; routine reste 1 (Live), mais l'animation Die va déclencher _nextRoutine
@alive
        jsr   AnimateSprite             ; va exécuter _nextRoutine → routine 2
        jmp   DisplaySprite

; routine 2 — cleanup après animation Die
        ; ... cleanup ...
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u
        rts
```

### Animation v02 avec callbacks

```properties
animation.Ani_Punch=Img_atk_001,2,$00;Img_atk_002,3,$04;Img_atk_003,4,$00;_resetAnim
```

Avec une LUT applicative qui associe `flags=$04` à une callback de dégâts :

```asm
; LUT
Punch_FlagLut
        fdb   Punch_NoOp                ; flags = $00
        fdb   Punch_NoOp                ; flags = $01
        fdb   Punch_NoOp                ; flags = $02
        fdb   Punch_NoOp                ; flags = $03
        fdb   Punch_DamageHitbox        ; flags = $04 → ICI
        ; ...
```

Le moteur (via `AnimateSpriteAdv`) lit `anim_flags,u`, indexe dans `Punch_FlagLut`, et appelle la routine. Cela permet de placer des hitboxes exactement à la bonne frame.

---

## `moveByScript` — scripts de trajectoire

Système plus avancé : un script décrit une trajectoire complète (déplacements + animations + speeds), exécutée frame par frame.

Format d'un script : segments, chaque segment définit une suite de pas (`POSXSTEP`, `NEGXSTEP`, `POSYSTEP`, `NEGYSTEP`, ...).

L'objet a deux pointeurs OST :
- `anim,u` : pointeur vers le script global
- `sub_anim,u` : pointeur vers le segment courant

Routines :
- `moveByScript.register` : enregistre l'object_id contenant les données d'animation
- `moveByScript.initialize` : charge un script (`X = index dans LUT`)
- `moveByScript.runByFrameDrop` : exécute le script (compense automatique frame drop)
- `moveByScript.runByB` : exécute B fois

Voir [references/movebyscript.md](references/movebyscript.md) pour les détails.

---

## Pitfalls

- **`anim,u` non initialisé** : pointeur `0` → adresse invalide → crash ou affichage random
- **`AnimateSpriteSync` sans gfxlock** : `frameDrop.count = 0` permanent → animation figée
- **Modifier `anim,u` sans `anim_link_mask`** : reset automatique de `anim_frame` (peut être voulu ou non)
- **Format v02 mal formé** : exception au build « need three comma separated parameters »
- **Animation infinie sans `_resetAnim`** : le moteur lit après la fin du script → comportement erratique
- **`_nextRoutine` dans une animation v02** : OK, fonctionne identiquement à v00
- **Tag `$FF` non géré** : si l'animation déborde et tombe sur un octet $FF, c'est `_resetAnim` qui se déclenche → boucle accidentelle
- **`Ani_Page_Index`/`Ani_Asd_Index`** : tables générées par le builder, ne pas y écrire manuellement
- **`anim_frame` non reset après changement d'animation** : `anim_link_mask` mis → le moteur ne reset pas, frame index hors range
- **Confusion `anim_flags` et `status_flags`** : même offset (14), choisir lequel utiliser selon le mode (v00 → `status_flags` pour orient, v02 → `anim_flags` pour LUT)

---

## Références détaillées

- [references/animation-formats.md](references/animation-formats.md) — Format v00 binaire détaillé, format v02, comparaison, parsing par le builder Java, génération du `.glb` d'animation, layouts mémoire exacts
- [references/animate-routines.md](references/animate-routines.md) — Comparaison des 7 routines : `AnimateSprite`, `Sync`, `Load`, `Adv`, `AdvSync`, `AdvLoad`, et leurs cas d'usage, coûts CPU, dépendances (`gfxlock`, ALU)
- [references/end-tags.md](references/end-tags.md) — Sémantique précise de chaque tag $FF/$FE/$FD/$FC/$FB/$FA : effet sur `anim_frame`, `routine`, `routine_secondary`, comment ils sont parsés par `AnimateSprite`, comment les utiliser pour chaîner des animations ou déclencher des transitions
- [references/animation-callbacks-v02.md](references/animation-callbacks-v02.md) — Format v02 callbacks : `anim_flags` comme offset, construction d'une LUT applicative, patterns hitbox, son, particules synchronisées avec frames spécifiques
- [references/movebyscript.md](references/movebyscript.md) — Système `moveByScript` complet : format binaire des scripts (bitfield frame/x_vel/y_vel), segments, `moveByScript.register`/`initialize`/`runByFrameDrop`/`runByB`, équates `POSXSTEP`/`NEGXSTEP`/`POSYSTEP`/`NEGYSTEP`, intégration avec `glb_a0`/`glb_d0`, callbacks objet à chaque step
- [references/animate-internals.md](references/animate-internals.md) — Mécanique interne d'`AnimateSprite` : résolution `anim,u` (adresse directe vs Ani_Asd_Index LUT), application `status_flags` sur `render_flags`, gestion du `prev_anim` pour détection de changement, interaction avec `image_set` lu par `DrawSprites`
