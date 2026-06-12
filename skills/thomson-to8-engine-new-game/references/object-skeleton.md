# Squelette d'un objet — `objects/<name>/<name>.asm`

Tout objet du framework suit la même architecture : un **point d'entrée** qui saute via une **table de routines indexée par `routine,u`**, et un ensemble de **routines** (Init, Main, et autres états) qui modifient les champs de l'OST (Object Status Table) pointée par `u`.

---

## Architecture en 4 sections

```
┌─ HEADER : INCLUDE macros + constantes locales
│
├─ ENTRY POINT : <Name>  (= nom exact de l'objet déclaré dans main.properties)
│      lda routine,u
│      asla
│      ldx #<Name>_Routines
│      jmp [a,x]
│
├─ ROUTINES TABLE : <Name>_Routines  (fdb vers chaque routine)
│      fdb Init       ← routine 0
│      fdb Main       ← routine 1
│      fdb ...
│
└─ ROUTINES : Init, Main, ... (logique métier)
```

---

## Squelette canonique

```asm
; ---------------------------------------------------------------------------
; Object - <Name>
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        ; INCLUDE "./engine/collision/macros.asm"      ; si l'objet utilise des AABB
        ; INCLUDE "./engine/collision/struct_AABB.equ" ; idem

; -------- Constantes locales à l'objet --------
Init_routine    equ 0
Main_routine    equ 1
Die_routine     equ 2

; -------- Variables locales (offsets dans ext_variables) --------
; Si ext_variables_size >= N dans ram-data.asm, on peut réserver des slots :
my_counter      equ ext_variables       ; 1 octet à l'offset ext_variables (souvent +38)
my_target_addr  equ ext_variables+1     ; 2 octets

; -------- Entry point (= nom exact de l'objet) --------
<Name>
        lda   routine,u
        asla                            ; *2 (table de fdb donc 2 octets par entrée)
        ldx   #<Name>_Routines
        jmp   [a,x]                     ; saut indirect

; -------- Table de routines --------
<Name>_Routines
        fdb   Init                      ; routine 0 — exécutée une fois
        fdb   Main                      ; routine 1 — exécutée à chaque frame
        fdb   Die                       ; routine 2 — état "mort" éventuel

; ============================================================================
; ROUTINE 0 — Init
; Exécutée la première frame après allocation. Doit terminer par inc routine,u
; (sinon Init est rappelée à l'infini)
; ============================================================================
Init
        ; --- Sélectionner l'animation par défaut ---
        ldd   #Ani_<defaultAnim>
        std   anim,u

        ; --- Priorité d'affichage (1=front, 8=back) ---
        ldb   #4
        stb   priority,u

        ; --- Position initiale (en coord ÉCRAN, sur 1 octet) ---
        ; ATTENTION — règle de positionnement du centre :
        ;   center_pos = ceil(sprite_size/2) - 1
        ; Pour un sprite 16x16 centré sur (X=80, Y=100) à l'écran :
        ;   x_pixel = 80 - 7 = 73  (= 80 - (ceil(16/2)-1))
        ;   y_pixel = 100 - 7 = 93
        ; Si le sprite déborde de l'écran ET que render_xloop_mask n'est
        ; PAS activé, l'engine peut décider de ne rien afficher du tout
        ; (clipping out total) — le sprite disparaît silencieusement !
        ldd   #$80AF                    ; x=$80=128, y=$AF=175
        std   xy_pixel,u

        ; --- CRITIQUE pour sprites ND* (Normal Draw sans backup) ---
        ; Si le sprite est compilé en variant ND0/ND1/XD0/etc. (donc sans
        ; sauvegarde du fond), il FAUT poser render_overlay_mask. Sinon
        ; l'engine traite le sprite comme un background-erase et cherche
        ; un backup qui n'existe pas → rien ne s'affiche (silencieux).
        ; Cette ligne est INUTILE pour les variants NB*/XB* (mode backup).
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ; Variante : position en coord PLAYFIELD (sur 2 octets pour scrolling)
        ; ldd   #200
        ; std   x_pos,u
        ; ldd   #100
        ; std   y_pos,u
        ; lda   render_flags,u
        ; ora   #render_playfieldcoord_mask
        ; sta   render_flags,u

        ; --- Render flags additionnels (optionnel) ---
        ; lda   render_flags,u
        ; ora   #render_overlay_mask    ; sprite sans backup de fond
        ; sta   render_flags,u

        ; --- Orientation initiale (optionnel) ---
        ; lda   status_flags,u
        ; ora   #status_xflip_mask
        ; sta   status_flags,u

        ; --- Variables locales ---
        clr   my_counter,u

        ; --- Si l'objet a une AABB de collision ---
        ; lda   #-1                     ; potentiel infini (toujours actif)
        ; sta   AABB_0+AABB.p,u
        ; _ldd  4,8                     ; rayon hitbox (rx=4, ry=8)
        ; std   AABB_0+AABB.rx,u
        ; _Collision_AddAABB AABB_0,AABB_list_player

        ; --- Passer en routine 1 (NE PAS OUBLIER !) ---
        inc   routine,u

; ============================================================================
; ROUTINE 1 — Main (exécutée à chaque frame)
; ============================================================================
Main
        ; --- Lecture inputs (joypad) ---
        lda   Dpad_Held
        bita  #c1_button_left_mask
        beq   @notLeft
        dec   x_pixel,u
@notLeft
        bita  #c1_button_right_mask
        beq   @notRight
        inc   x_pixel,u
@notRight

        ; --- Animation + rendu (TOUJOURS en queue de Main) ---
        jsr   AnimateSprite
        jmp   DisplaySprite

; ============================================================================
; ROUTINE 2 — Die
; ============================================================================
Die
        ; Marquer pour suppression au prochain frame
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u
        rts
```

---

## Offsets OST complets

Tous ces offsets sont définis dans `engine/constants.asm`. Ils s'utilisent avec le suffixe `,u` (ou `,x` selon le registre passé).

### Identité

| Offset | Symbole | Taille | Rôle |
|--------|---------|--------|------|
| 0 | `id` | 1 octet | `ObjID_<nom>` (0 = slot libre) |
| 1 | `subtype` | 1 octet | `Sub_<nom>` — variante de l'objet (ex: ennemi de tel niveau) |
| 1 | `subtype_w` | 2 octets | Variante 2 octets (chevauche `render_flags`) |
| 2 | `render_flags` | 1 octet | Flags de rendu (cf. tableau ci-dessous) |
| 3 | `run_object_prev` | 2 octets | Chaînage liste — précédent (géré par engine) |
| 5 | `run_object_next` | 2 octets | Chaînage liste — suivant (géré par engine) |

### Affichage

| Offset | Symbole | Taille | Rôle |
|--------|---------|--------|------|
| 7 | `priority` | 1 octet | Priorité 0-8. **0 = invisible**, 1 = devant (1er plan), 8 = arrière |
| 8 | `anim` | 2 octets | Pointeur vers `Ani_<X>` |
| 10 | `prev_anim` | 2 octets | Animation précédente (pour transitions) |
| 10 | `sub_anim` | 2 octets | Animation secondaire (overlap avec `prev_anim`) |
| 12 | `anim_frame` | 1 octet | Index de la frame courante dans l'animation |
| 13 | `anim_frame_duration` | 1 octet | Compteur restant de frames pour l'image courante (0-127) |
| 13 | `wave_frame_drop` | 1 octet | (overlap) Frame drop pour object wave |
| 14 | `anim_flags` | 1 octet | Offset dans LUT `anim_flags` (v02 advanced) ou flag de link |
| 14 | `status_flags` | 1 octet | (overlap) Orientation : xflip/yflip |
| 16 | `image_set` | 2 octets | Pointeur vers `Img_<X>` actuel (0000 = pas d'image) |

### Position et vitesse

| Offset | Symbole | Taille | Rôle |
|--------|---------|--------|------|
| 18 | `x_pos` | 2 octets | Position X en coord playfield (signed) |
| 20 | `x_sub` | 1 octet | Sub-pixel X (1/256 de pixel) — doit suivre `x_pos` |
| 21 | `y_pos` | 2 octets | Position Y en coord playfield (signed) |
| 23 | `y_sub` | 1 octet | Sub-pixel Y — doit suivre `y_pos` |
| 24 | `xy_pixel` | 2 octets | Position écran (x_pixel + y_pixel groupés) |
| 24 | `x_pixel` | 1 octet | Position X écran (0-159 selon mode) |
| 25 | `y_pixel` | 1 octet | Position Y écran (0-199) — doit suivre `x_pixel` |
| 26 | `x_vel` | 2 octets | Vitesse horizontale signed 8.8 (fixed point) |
| 28 | `y_vel` | 2 octets | Vitesse verticale signed 8.8 |
| 30 | `x_acl` | 2 octets | Accélération horizontale 8.8 (gravité) |
| 32 | `y_acl` | 2 octets | Accélération verticale 8.8 |

### Routines

| Offset | Symbole | Rôle |
|--------|---------|------|
| 34 | `routine` | Index de la routine principale (table primaire) |
| 35 | `routine_secondary` | Index de la routine secondaire |
| 36 | `routine_tertiary` | Index de la routine tertiaire |
| 37 | `routine_quaternary` | Index de la routine quaternaire |

### Extensions

| Symbole | Rôle |
|---------|------|
| `ext_variables` | = `object_base_size` (souvent 38). Start de l'espace utilisateur si `ext_variables_size > 0` |

---

## `render_flags` — table des bits

### Mode background-erase (par défaut)

| Bit | Mask | Symbole | Effet |
|-----|------|---------|-------|
| 0 | $01 | `render_xmirror_mask` | Mirroir horizontal du sprite |
| 1 | $02 | `render_ymirror_mask` | Mirroir vertical du sprite |
| 2 | $04 | `render_overlay_mask` | Mode overlay : pas de backup du fond (sprite "additif") |
| 3 | $08 | `render_playfieldcoord_mask` | Coord playfield (1) vs écran (0) |
| 4 | $10 | `render_xloop_mask` | Loop sprite hors écran X |
| 5 | $20 | `render_todelete_mask` | Marquer pour suppression par engine |
| 6 | $40 | `render_subobjects_mask` | Render sous-objets |
| 7 | $80 | `render_hide_mask` | Cacher sprite sans libérer la prio/mapping |

### Mode overlay (`OverlayMode equ 1`)

| Bit | Mask | Symbole | Effet |
|-----|------|---------|-------|
| 0 | $01 | `render_xmirror_mask` | Mirroir horizontal |
| 1 | $02 | `render_ymirror_mask` | Mirroir vertical |
| 3 | $08 | `render_playfieldcoord_mask` | Coord playfield |
| 4 | $10 | `render_xloop_mask` | Loop X |
| 5 | $20 | `render_no_range_ctrl_mask` | **DANGER** : skip out-of-range (peut corrompre la mémoire) |
| 6 | $40 | `render_subobjects_mask` | Sous-objets |
| 7 | $80 | `render_hide_mask` | Cacher |

> Le mode est sélectionné par la présence de `OverlayMode equ 1` au début du `main.asm`. `render_overlay_mask` n'existe **pas** en mode overlay.

---

## `status_flags` — bits d'orientation

| Bit | Mask | Symbole | Effet |
|-----|------|---------|-------|
| 0 | $01 | `status_xflip_mask` | Flip horizontal (s'applique pendant AnimateSprite) |
| 1 | $02 | `status_yflip_mask` | Flip vertical |

---

## `priority` — sémantique

| Valeur | Signification |
|--------|---------------|
| 0 | **Rien à afficher** (sprite invisible mais routine continue à tourner) |
| 1 | Front (1er plan) — dessiné en dernier, masque les autres |
| 2-7 | Intermédiaires (plus la valeur est faible, plus l'objet est devant) |
| 8 | Back (arrière-plan) — dessiné en premier |

---

## Routines auxiliaires (secondary, tertiary, quaternary)

On peut implémenter des **state machines en parallèle** dans un même objet :

```asm
Main
        ; sous-machine principale
        lda   routine_secondary,u
        asla
        ldx   #Main_Secondary_Table
        jmp   [a,x]

Main_Secondary_Table
        fdb   Walking
        fdb   Jumping
        fdb   Crouching
```

Pratique pour découpler la logique (animation/déplacement/IA) sans avoir à multiplier les routines de niveau 1.

---

## Patterns de routines

### Init + Main (le plus simple)

```asm
<Name>_Routines
        fdb   Init
        fdb   Main

Init
        ldd   #Ani_Idle
        std   anim,u
        ldb   #4
        stb   priority,u
        inc   routine,u

Main
        jsr   AnimateSprite
        jmp   DisplaySprite
```

### Init + Main avec destruction conditionnelle

```asm
<Name>_Routines
        fdb   Init
        fdb   Main
        fdb   Die

Init
        ldd   #Ani_alive
        std   anim,u
        ldb   #2
        stb   priority,u
        inc   routine,u

Main
        ; ... logique ...
        tst   <my_health
        bne   @alive
        ldb   #Die_routine
        stb   routine,u
        rts
@alive
        jsr   AnimateSprite
        jmp   DisplaySprite

Die
        ; lance une animation "explosion" puis se supprime
        ldd   #Ani_explosion
        std   anim,u
        lda   render_flags,u
        ora   #render_todelete_mask     ; sera supprimé après l'animation
        sta   render_flags,u
        jsr   AnimateSprite
        jmp   DisplaySprite
```

### Avec switch sur subtype (un même objet, plusieurs ennemis)

```asm
Init
        lda   subtype,u
        asla
        ldx   #Init_BySubtype
        jmp   [a,x]

Init_BySubtype
        fdb   Init_Subtype0
        fdb   Init_Subtype1
        fdb   Init_Subtype2

Init_Subtype0
        ldd   #Ani_TypeA
        std   anim,u
        ; ...
        inc   routine,u
        rts

Init_Subtype1
        ldd   #Ani_TypeB
        std   anim,u
        ; ...
        inc   routine,u
        rts
```

---

## Création d'un objet fils

Pendant `Init` ou `Main`, on peut allouer un sous-objet :

```asm
        pshs  u                         ; sauve l'OST du parent
        jsr   LoadObject_u              ; alloue, retourne u (Z=1 si plein)
        beq   @noslot
        lda   #ObjID_Bullet
        sta   id,u                      ; l'objet créé est mis dans la queue
        ldd   x_pos,s                   ; recopier position parent
        std   x_pos,u
        ; ... init complémentaire du fils ...
@noslot
        puls  u                         ; restaure l'OST du parent
```

Variante avec `LoadObject_x` (préserve `u`) :

```asm
        jsr   LoadObject_x              ; alloue, retourne x (Z=1 si plein)
        beq   @noslot
        lda   #ObjID_Bullet
        sta   id,x
        ldd   x_pos,u                   ; u parent reste accessible
        std   x_pos,x
@noslot
```

---

## Différences entre routines moteur

| Routine | Quand l'utiliser |
|---------|------------------|
| `AnimateSprite` | Animation simple, indépendant du framerate |
| `AnimateSpriteSync` | Animation synchronisée au framerate effectif (`gfxlock.frameDrop.count`). Préférable pour gameplay homogène |
| `DisplaySprite` | Termine la routine ET marque l'objet pour affichage |
| `ObjectMove` | Applique x_vel/y_vel à x_pos/y_pos |
| `ObjectMoveSync` | Version sync (multiplie le vel par le frame drop) |
| `ObjectFall` / `ObjectFallSync` | Applique y_acl à y_vel puis y_vel à y_pos (gravité) |

> **Règle** : terminer `Main` par `jmp DisplaySprite` (pas `jsr`) — `DisplaySprite` se finit par `rts`, donc le saut direct est équivalent à un `jsr` suivi de `rts`, mais 4 cycles plus rapide.

---

## Suppression / déchargement d'un objet

Deux approches :

### Suppression auto via `render_todelete_mask`

```asm
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u
        ; l'engine supprimera l'objet au prochain EraseSprites
```

### Suppression manuelle

```asm
        jsr   UnloadObject_u            ; libère le slot et délink de la run-list
        ; après cet appel, u n'est plus valide
        rts                             ; sortir immédiatement
```

---

## Patterns spéciaux

### Objet en Direct Page (joueur principal, accès rapide)

Si dans `ram-data.asm` on a `player1 equ dp`, alors le code du joueur peut utiliser :

```asm
        ; au lieu de ldd x_pos,u (3 cycles + offset)
        ldd   <x_pos                    ; (2 cycles, mode direct page)
```

L'objet n'est pas alloué via `LoadObject_u` — il occupe directement la zone DP. Sa routine doit être appelée manuellement (par exemple avec `_RunObjectSwap` ou `_MountObject` + `jsr ,x`).

### Objet sans rendu (audio, logique pure)

```asm
        ldb   #0
        stb   priority,u                ; aucune priorité = pas d'affichage
        ; la routine principale ne fait pas jmp DisplaySprite, juste rts
```

### Objet self-referencing dans Main (suppression de slot)

Quand un objet se supprime lui-même mais doit laisser passer au suivant sans crasher la chaîne :

```asm
Main
        ; ... condition de suppression ...
        ldb   render_flags,u
        orb   #render_todelete_mask
        stb   render_flags,u
        ; le moteur sauvegarde run_object_next AVANT d'appeler la routine
        ; donc la suppression auto fonctionne sans précautions
        rts
```

---

## Règles critiques à connaître (sous peine de sprite invisible)

### 1. `render_overlay_mask` OBLIGATOIRE pour les variants ND*

Si le sprite est déclaré dans `.properties` avec un variant `ND0`, `ND1`, `XD0`, `XD1`, `YD*`, `XYD*` (mode Draw seul, sans backup du fond), il faut **impérativement** poser `render_overlay_mask` dans `render_flags,u` dans la routine `Init` :

```asm
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
```

**Pourquoi** : sans ce flag, l'engine considère que le sprite est un sprite « backup-and-restore » et cherche le code d'erase compilé — qui n'existe pas pour les variants ND. Résultat : **le sprite ne s'affiche pas** (échec silencieux, aucune erreur).

**Quand le flag est inutile** : pour les variants `NB0`/`NB1`/`XB*`/`YB*`/`XYB*` (mode Backup), `render_overlay_mask` doit rester à 0 (l'engine utilise alors le backup compilé).

### 2. Position du centre du sprite = `ceil(taille/2)-1`

Pour positionner un sprite avec sa convention CENTER (origine = centre interne), l'engine utilise comme offset interne :

```
center_internal_offset = ceil(sprite_size / 2) - 1
```

Pas `taille/2` direct. Pour les tailles paires, c'est **un pixel avant** ce qu'on attendrait :

| Taille sprite | center_internal_offset | Pour centrer le sprite à l'écran X=80 |
|---------------|------------------------|--------------------------------------|
| 8 px | 3 | x_pixel = 80 - 3 = 77 |
| 16 px | 7 | x_pixel = 80 - 7 = 73 |
| 32 px | 15 | x_pixel = 80 - 15 = 65 |
| 100 px | 49 | x_pixel = 80 - 49 = 31 |
| 160 px | 79 | x_pixel = 80 - 79 = 1 |

**Pour qu'un sprite 160 px occupe parfaitement les 160 colonnes de l'écran (0-159)** :
- center_internal_offset = 79
- top-left souhaité à x=0 → x_pixel = 79 (et non 80)

**Risque si on se trompe d'un pixel** : le sprite peut déborder de l'écran. Et si `render_xloop_mask` n'est PAS activé, l'engine peut décider de **ne pas dessiner le sprite du tout** (clipping out total). Le sprite disparaît silencieusement → on se demande pourquoi pendant des heures.

**Sécurité** : si le sprite est trop large/déborde par design, poser aussi `render_xloop_mask` pour permettre le wrap horizontal hors écran.

---

## Pitfalls

- **`Init` qui ne fait pas `inc routine,u`** : la routine 0 est rappelée à chaque frame → l'objet ne fait jamais autre chose qu'initialiser.
- **`asla` oublié** dans le saut indirect : `[a,x]` lit 1 octet au lieu de 2 → JMP vers une adresse fausse → crash.
- **`<Name>_Routines` mal indexé** : si la table n'a que 2 entrées et que `routine,u = 2`, le `jmp [a,x]` lit la mémoire suivante (peut tomber sur du code valide → comportement erratique).
- **Modifier `id,u` à 0 dans Main** : marque le slot comme libre et l'engine peut le réattribuer immédiatement.
- **Oublier `jmp DisplaySprite` en fin de Main** : le sprite n'est pas affiché. Si on veut conditionnellement ne pas afficher, mettre `priority = 0`.
- **Référencer un `Ani_X` non déclaré** dans le .properties de l'objet : `Undefined symbol` au build.
- **Init qui place le sprite à une position avec `xy_pixel`, mais `render_flags` a le bit `render_playfieldcoord_mask`** : le moteur utilise `x_pos`/`y_pos` (qui valent 0), pas `xy_pixel`. Choisir l'un OU l'autre, cohérent avec le flag.
- **`AnimateSpriteSync` sans gfxlock** : la sync utilise `gfxlock.frameDrop.count`, qui n'est pas mis à jour sans `_gfxlock.loop`. Utiliser `AnimateSprite` (non-sync) avec `WaitVBL`.
