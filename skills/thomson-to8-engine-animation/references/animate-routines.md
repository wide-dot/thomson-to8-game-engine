# Routines `AnimateSprite*` — comparaison

L'engine fournit 7 variantes de la routine d'animation, à choisir selon le format de script et les besoins de synchronisation.

## Tableau récap

| Routine | Format script | Sync framerate | Avance | Cas d'usage |
|---------|--------------|----------------|--------|-------------|
| `AnimateSprite` | v00 | non | oui | Animation simple sans gfxlock |
| `AnimateSpriteSync` | v00 | oui | oui | Animation v00 avec gfxlock (recommandé) |
| `AnimateSpriteLoad` | v00 | non | **non** | Recharger sans avancer |
| `AnimateSpriteAdv` | v02 | non | oui | Animation avancée sans gfxlock |
| `AnimateSpriteAdvSync` | v02 | oui | oui | Animation avancée avec gfxlock |
| `AnimateSpriteAdvLoad` | v02 | non | **non** | Recharger v02 sans avancer |
| `AnimateMove` | (script mvt) | (variable) | (variable) | Animation pilotée par script de trajectoire |

## `AnimateSprite` — basique

```asm
        jsr   AnimateSprite             ; U = OST
```

Algorithme :
1. Mount la page d'animation (`Ani_Page_Index[id]`)
2. Charger `X = anim,u` (résoudre adresse ou LUT via `Ani_Asd_Index`)
3. Comparer avec `prev_anim,u` → si différent, reset anim_frame
4. `dec anim_frame_duration,u`
5. Si > 0 → fin (pas de changement de frame)
6. Si <= 0 → lire la prochaine frame, mettre à jour `image_set,u`, traiter tag éventuel
7. Appliquer `status_flags` sur `render_flags`
8. Restaurer la page sortante

Coût : ~80-120 cycles (selon le chemin pris)

## `AnimateSpriteSync` — synchro framerate

Identique à `AnimateSprite` SAUF la décrémentation :

```asm
@Anim_Run
        ldb   anim_frame_duration,u
        subb  gfxlock.frameDrop.count   ; au lieu de dec
        stb   anim_frame_duration,u
        bpl   @Anim_Rts                 ; si > 0, fin
        ; ...
@b      ldb   -1,x
        addb  anim_frame_duration,u     ; reload + report du delta
        subb  gfxlock.frameDrop.count
        stb   anim_frame_duration,u
        bpl   @Anim_Reload
        clr   anim_frame_duration,u     ; cap à 0 si overflow
```

Si `gfxlock.frameDrop.count = 2` (frame drop), l'animation avance de 2 frames d'un coup. Permet de garder la vitesse perçue stable.

**Pré-requis** : gfxlock actif (cf. `_gfxlock.loop` qui met à jour `frameDrop.count`).

## `AnimateSpriteLoad` — recharger sans avancer

Identique à `AnimateSprite` mais **n'incrémente pas `anim_frame`** et **ne décrémente pas `anim_frame_duration`**. Recharge juste l'image courante dans `image_set,u`.

Usage : quand on a modifié `anim,u` à la main et qu'on veut voir le résultat **immédiatement** (sans attendre une frame).

```asm
        ldd   #Ani_Idle
        std   anim,u
        jsr   AnimateSpriteLoad         ; affiche la première frame de Idle maintenant
        jmp   DisplaySprite
```

Sans `Load`, le sprite afficherait l'image précédente jusqu'au prochain `AnimateSprite`.

## `AnimateSpriteAdv` — v02

Pour le format v02 (5 octets/frame avec duration et flags). Différences par rapport à `AnimateSprite` :

```asm
@b
        ldb   1,x                       ; lire duration-1 (1 octet)
        stb   anim_frame_duration,u
        ldd   ,x                        ; lire image_set (2 octets)
        std   image_set,u
        ldb   3,x                       ; lire flags (1 octet)
        stb   anim_flags,u              ; pour callback applicatif
        ; ...
```

Le champ `anim_flags,u` est mis à jour à chaque frame. L'application peut le consulter pour déclencher des callbacks.

**Note importante** : `anim_flags` overlap `status_flags` (offset 14). En mode v02, on perd l'usage de `status_flags` pour l'orientation — il faut gérer xflip/yflip via `render_flags` directement.

## `AnimateSpriteAdvSync`

Version sync de `AnimateSpriteAdv`. Comme Sync : applique `frameDrop.count`.

## `AnimateSpriteAdvLoad`

Version load de `AnimateSpriteAdv`. Recharge l'image courante (v02) sans avancer.

## `AnimateMove` — script de trajectoire

Différent de tous les autres : ne lit pas un script d'animation classique. Lit un **script de mouvement** dont les segments définissent `x_vel`, `y_vel`, `anim_frame` à chaque pas.

```asm
AnimateMoveInit
        stx   anim,u                    ; X = adresse du script
        ldd   ,x
        std   sub_anim,u                ; sub_anim = adresse du premier segment
        rts

AnimateMove
        ldy   sub_anim,u
        beq   @rts                      ; fin de script
        ldd   #0
        std   x_vel,u
        std   y_vel,u
        ldb   ,y+                       ; lire bitfield frame
@frame  lslb
        bcc   @xvel
        lda   ,y+
        sta   anim_frame,u              ; modif frame
@xvel   lslb
        bcc   @yvel
        ldx   ,y++
        stx   x_vel,u                   ; modif vitesse X
@yvel   ; ...
```

Le bitfield indique quels champs sont présents dans le segment :
- Bit 7 : nouveau `anim_frame` (1 octet)
- Bit 6 : nouvelle `x_vel` (2 octets)
- Bit 5 : nouvelle `y_vel` (2 octets)
- (autres bits...)

Permet d'avoir des séquences scriptées complexes : « avance 5 pixels à droite, change de frame, avance vers le haut, ... » sans avoir besoin de logique dans la routine de l'objet.

## Quand utiliser quoi

```
Tu fais :                                    → Routine à utiliser
──────────────────────────────────────────  ─────────────────────────
Animation simple avec frame duration globale  AnimateSpriteSync (si gfxlock)
                                                AnimateSprite (sinon)
Animation avec durations variables par frame   AnimateSpriteAdvSync (si gfxlock)
                                                AnimateSpriteAdv (sinon)
Animation avec callbacks (hitbox, son)         AnimateSpriteAdvSync + LUT applicative
Recharger l'image instantanément               AnimateSpriteLoad ou AnimateSpriteAdvLoad
Trajectoire scriptée avec frames variables     AnimateMove
```

Recommandation : **AnimateSpriteSync** par défaut (gfxlock recommandé pour tout nouveau projet).

## Dépendances communes

Toutes ces routines :
- Mount la page de l'objet pour accéder à `Ani_Page_Index` et `Ani_Asd_Index`
- Sauvent et restaurent la page courante (via `_GetCartPageA` / `_SetCartPageA`)
- Lisent `anim,u`, écrivent `anim_frame`, `anim_frame_duration`, `image_set`
- Pour Sync : lisent `gfxlock.frameDrop.count`
- Pour Adv : lisent et écrivent `anim_flags`

Toutes utilisent le **registre U** pour pointer l'OST. Aucune n'utilise `X` en input.

## Coût CPU

| Routine | Cycles approximatifs |
|---------|----------------------|
| `AnimateSprite` | ~80 (chemin standard, pas de tag) |
| `AnimateSpriteSync` | ~85 |
| `AnimateSpriteLoad` | ~70 |
| `AnimateSpriteAdv` | ~95 |
| `AnimateSpriteAdvSync` | ~100 |
| `AnimateMove` | variable (~50-150 selon bitfield) |

Sur 50 Hz (20000 cycles/frame), ~25 sprites animés = 2000-2500 cycles soit ~10-12% du budget. Largement OK.

## Pitfalls

- **Mélanger v00 et v02 sur le même objet** : impossible, le format est par animation
- **`AnimateSprite` (v00) sur une animation v02** : lit les pointeurs d'image comme si c'étaient des frames v00, sortie visuellement cassée
- **`AnimateSpriteAdv` sur v00** : lit la duration comme un pointeur Img_, crash
- **`AnimateSpriteSync` sans `_gfxlock.loop`** : `frameDrop.count = 0` → animation figée
- **Appeler `AnimateSpriteLoad` puis `AnimateSprite` la même frame** : double avance possible
- **Modifier `anim,u` puis appeler `AnimateSprite` sans `AnimateSpriteLoad`** : l'image change avec un délai d'une frame (le moteur lit ancien `prev_anim` la frame en cours)
- **`AnimateMove` sans `AnimateMoveInit`** : `sub_anim,u` non init → crash
