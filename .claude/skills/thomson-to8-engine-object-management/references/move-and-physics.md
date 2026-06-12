# Déplacements et physique des objets

## Format fixed-point 8.8

Les vitesses et accélérations sont stockées en **signed 8.8 fixed-point** (16 bits, partie entière 8 bits + partie fractionnaire 8 bits) :

```
x_vel = $0100 → +1.0 pixel/frame
x_vel = $0080 → +0.5 pixel/frame
x_vel = $FF80 → -0.5 pixel/frame  (256.0 - 0.5 = 255.5 en non-signé, donc -0.5 en signé)
x_vel = $0040 → +0.25 pixel/frame
```

Les positions `x_pos`/`y_pos` sont en **signed 16.8 fixed-point** (3 octets) :
- 2 octets de partie entière (`x_pos`, `y_pos`) — peut représenter une map de -32768 à +32767 pixels
- 1 octet de partie fractionnaire (`x_sub`, `y_sub`) — sub-pixel pour précision

C'est pour ça que `x_pos`+`x_sub` doivent être contigus : `addd x_pos+1,u` (avec `x_pos+1 = x_sub`) met à jour la partie basse en un coup.

## `ObjectMove` — déplacement non-synchronisé

```asm
ObjectMove
        ldb   x_vel,u
        sex                             ; sign extend B → A (A = $00 ou $FF)
        sta   @a+1                      ; modifie l'instruction adca # ci-dessous
        ldd   x_vel,u
        addd  x_pos+1,u                 ; addition basse partie (x_pos low + x_sub)
        std   x_pos+1,u
        lda   x_pos,u                   ; partie haute
@a      adca  #$00                      ; <- modifié par le sex pour gérer la propagation signed
        sta   x_pos,u
        ; idem pour y
        rts
```

Astuce : `sex` (sign extend) met `A = $00` si `B` positif, `$FF` si négatif. Le `sta @a+1` modifie l'opérande immédiat de `adca #$00` au-dessus, qui devient donc `adca #$FF` pour propager le bit de signe vers la partie haute. **Code auto-modifié** pour économiser une branche.

Appel typique :
```asm
        jsr   ObjectMove
```

Effet : `x_pos += x_vel` et `y_pos += y_vel`, en signed 16.8.

## `ObjectMoveSync` — synchronisé framerate

Identique mais boucle `gfxlock.frameDrop.count_w` fois (nombre de frames 50 Hz écoulées depuis le dernier rendu) :

```asm
ObjectMoveSync
        ldx   gfxlock.frameDrop.count_w
        bne   @loop1
        ldx   #1                         ; minimum 1 frame
@loop1
        ; ... même code que ObjectMove ...
        leax  -1,x
        bne   @loop1
        rts
```

Utiliser quand on a `gfxlock` actif et qu'on veut un déplacement **stable visuellement** même si le rendu drop des frames. Sans sync, un drop entraîne un ralentissement perçu (l'objet se déplace moins par frame visible).

## `ObjectFall` — gravité non-synchronisée

```asm
ObjectFall
        ldd   x_vel,u
        addd  x_acl,u                   ; x_vel += x_acl
        std   x_vel,u
        ldd   y_vel,u
        addd  y_acl,u                   ; y_vel += y_acl
        std   y_vel,u
        rts
```

Applique `x_acl`/`y_acl` à `x_vel`/`y_vel`. C'est la **gravité** (ou une accélération constante).

## `ObjectFallSync` — gravité synchronisée

Identique mais boucle `gfxlock.frameDrop.count_w` fois.

## Patterns d'usage

### Plateformer avec saut (pattern bubble-bobble)

```asm
; Constantes
h_top_speed      equ $A0     ; vitesse horizontale max (~0.625 px/frame)
gravity          equ $40     ; gravité (~0.25 px/frame²)
vel_jump         equ $4D0    ; vitesse initiale saut (~4.8 px/frame, ascendant)

; Init
Ground
        lda   Dpad_Press
        bita  #c1_button_up_mask
        beq   @no_jump
        ldd   #-vel_jump                ; saut → y_vel négative
        std   y_vel,u
        lda   #Jump_routine
        sta   routine,u
@no_jump

Jump
        ; appliquer gravité
        ldd   y_acl,u
        cmpd  #gravity                  ; (le calcul est ici simplifié)
        bne   >
        jsr   ObjectFallSync            ; y_vel += y_acl
        jsr   ObjectMoveSync            ; y_pos += y_vel
        ; vérifier si touche le sol et basculer en Ground
        ; ...
```

### Shoot 'em up — projectile à vitesse constante

```asm
; Projectile init
        ldd   #-$300                    ; vitesse horizontale = -3.0 pixels/frame
        std   x_vel,u
        ldd   #0
        std   y_vel,u                   ; pas de gravité
        std   x_acl,u
        std   y_acl,u

; Projectile main
        jsr   ObjectMoveSync            ; déplacement
        jmp   MarkObjGone               ; se supprime si hors écran
```

### Mouvement sinusoïdal

Si on veut une trajectoire non-linéaire (vague, courbe), il faut soit utiliser `moveByScript` (cf. skill animation), soit calculer manuellement `x_vel`/`y_vel` à chaque frame en fonction d'un compteur :

```asm
        lda   <my_counter
        jsr   CalcSine                  ; D = sin(my_counter), X = cos
        ; ajuster y_vel selon D, etc.
        std   y_vel,u
        jsr   ObjectMoveSync
```

## Conversion playfield ↔ écran

L'engine maintient deux jeux de coordonnées :

- **Playfield** : `x_pos`/`y_pos` (16 bits), coordonnées absolues dans la map
- **Écran** : `x_pixel`/`y_pixel` (8 bits), coordonnées dans l'écran visible

La conversion est faite **automatiquement par les routines de rendu** (cf. `DrawSprites`) en utilisant la caméra :
```
x_pixel ≈ x_pos - glb_camera_x_pos
y_pixel ≈ y_pos - glb_camera_y_pos
```

Le flag `render_playfieldcoord_mask` (`render_flags` bit 3) indique au moteur d'utiliser `x_pos`/`y_pos` (1) ou `xy_pixel` (0). À choisir selon que l'objet :
- est dans le monde scrollé (HUD exclu) → playfield
- est fixe à l'écran (HUD, menu) → écran

## Pitfalls

- **Oublier que `x_vel` est signed** : un objet immobile a `x_vel = 0`, pas `x_vel = $0100`
- **Confondre `ObjectMove` et `ObjectMoveSync`** : sans gfxlock, `_Sync` ne sert à rien (frameDrop.count_w est toujours 1) mais consomme des cycles supplémentaires
- **Modifier `x_pos` sans `x_sub`** : la partie haute change sans la basse, l'objet « saute » à l'écran. Toujours utiliser `ObjectMove` ou faire `std x_pos+1,u` puis adjuster `x_pos,u`
- **Gravité trop forte** : un objet peut traverser le sol en une frame si `y_vel > épaisseur du sol`. Limiter avec un `cmpd #v_top_speed`
- **Compteurs internes en 8.8** : si tu utilises `ext_variables` pour un compteur fixed-point, garder la convention 8.8 pour la cohérence (e.g. `my_speed_x = ext_variables` sur 2 octets)
