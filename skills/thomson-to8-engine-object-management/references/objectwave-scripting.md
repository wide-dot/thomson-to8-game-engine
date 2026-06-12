# `ObjectWave` — spawn d'ennemis par script

Le système `ObjectWave` permet de **scripter l'apparition d'objets** (typiquement des ennemis) à des moments précis basés sur un compteur de frames. Deux variantes existent : la **legacy 8-octets** et la **moderne 5-octets subtype**.

## Variante moderne — `ObjectWave-subtype.asm`

### Format binaire du script

Chaque entrée = **5 octets** :

```
Offset | Taille | Contenu
-------|--------|--------
0      | 2      | timestamp (gfxlock.frame.count auquel spawner)
2      | 1      | ObjID_ de l'objet à créer
3      | 2      | subtype_w (16 bits, chevauche render_flags)
```

Marqueur de fin : `$FFFF` à la place du timestamp.

```asm
; Exemple de script
wave_data
        fdb   $0100                     ; à la frame 256
        fcb   ObjID_PataPata
        fdb   $0001                     ; subtype 1 (left), render_flags 0

        fdb   $0150                     ; à la frame 336
        fcb   ObjID_PataPata
        fdb   $0102                     ; subtype 2, render_flags 1

        fdb   $0200                     ; à la frame 512
        fcb   ObjID_Bink
        fdb   $0001

        fdb   $FFFF                     ; fin
```

### Routine `ObjectWave`

```asm
ObjectWave
        lda   #0
object_wave_data_page equ *-1           ; modifié au init avec la page
        _SetCartPageA
        ldy   #0
object_wave_data equ *-2                ; cursor courant
        ldx   gfxlock.frame.count
!       cmpx  ,y                        ; current frame >= timestamp ?
        blo   @rts                      ; non, sortir
        pshs  x,y
        jsr   LoadObject_u
        puls  x,y
        beq   @bypass                   ; pas de slot, skip cet objet
        lda   2,y
        sta   id,u
        ldd   3,y                       ; subtype_w (2 octets)
        std   subtype_w,u               ; ECRASE render_flags
        ldd   gfxlock.frame.count
        subd  ,y
        stb   wave_frame_drop,u         ; nb de frames de retard
@bypass leay  5,y
        bra   <
@rts    sty   object_wave_data
        rts
```

### Initialisation

```asm
ObjectWave_Init
        pshs  a,x,y
        lda   object_wave_data_page
        _SetCartPageA
        ldy   object_wave_data_start
        ldx   gfxlock.frame.count
        ; ... saute les entrées dont le timestamp < frame.count
        ; (utile en cas de spawn pré-générés à des frames négatives ou démarrage tardif)
        sty   object_wave_data
        puls  a,x,y
        rts
```

### Usage typique

```asm
; main.asm
        lda   Obj_Index_Page+ObjID_LevelWave
        sta   object_wave_data_page
        ldd   Obj_Index_Address+2*ObjID_LevelWave
        std   object_wave_data
        std   object_wave_data_start
        jsr   ObjectWave_Init

MainLoop
        jsr   ObjectWave                ; spawn les objets dont le timestamp est atteint
        jsr   RunObjects
        ; ...
```

`ObjectWave` est appelée **avant** `RunObjects` pour que les objets créés cette frame puissent être exécutés.

### Attention au `subtype_w` qui chevauche `render_flags`

Le `subtype_w` (offset 1, 2 octets) chevauche `render_flags` (offset 2). Si le script définit `subtype_w = $0102`, alors :
- `subtype = $01` (octet bas du `subtype_w`)
- `render_flags = $02` (octet haut du `subtype_w` = `render_ymirror_mask`)

Donc le script peut **set render_flags via subtype_w**. C'est volontaire — permet de placer un ennemi avec un mirror Y prédéfini.

**Précaution** : si on veut modifier `render_flags` après le spawn, il faut **lire d'abord `subtype` (octet bas)** avant d'écrire `render_flags` (octet haut) sinon on écrase l'info de subtype.

```asm
        lda   subtype,u                 ; AVANT toute écriture de render_flags
        sta   <my_subtype_save          ; save somewhere
        ; ... maintenant on peut écrire render_flags ...
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u
```

## Variante legacy — `objectWave.asm` (8 octets)

### Format binaire

Chaque entrée = **8 octets** :

```
Offset | Taille | Contenu
-------|--------|--------
0      | 2      | timestamp
2      | 1      | ObjID_
3      | 1      | subtype (8 bits — pas de chevauchement avec render_flags)
4      | 2      | x_pos (position initiale playfield)
6      | 2      | y_pos
```

Marqueur de fin : `0` (le timestamp 0 est traité comme fin de script).

```asm
wave_data_legacy
        fdb   $0100                     ; frame 256
        fcb   ObjID_Bug
        fcb   1                         ; subtype
        fdb   200                       ; x_pos
        fdb   100                       ; y_pos

        fdb   $0150
        fcb   ObjID_Bug
        fcb   2
        fdb   220
        fdb   120

        fdb   0                         ; fin
```

### Macros

```asm
_objectWave.init MACRO
        ldb   \1                        ; ObjID_ de l'objet de script
        ldx   #Obj_Index_Page
        lda   b,x
        aslb
        ldx   #Obj_Index_Address
        ldy   b,x
        ldx   \2                        ; cursor (typiquement #0)
        jsr   objectWave.init
 ENDM

_objectWave.do MACRO
        ldx   \1                        ; current time (typiquement gfxlock.frame.count)
        jsr   objectWave.do
 ENDM
```

### Routine `objectWave.do`

```asm
objectWave.do
        lda   #0
objectWave.data.page equ *-1
        _SetCartPageA
        ldy   #0
objectWave.data.cursor equ *-2
!       ldd   ,y
        beq   @rts                      ; marker 0 = fin
        cmpx  ,y
        bhi   @rts                      ; current time > timestamp ? continue
        pshs  x,y
        jsr   LoadObject_u
        puls  x,y
        beq   @bypass
        ldd   2,y                       ; id + subtype (8 bits)
        std   id,u                      ; écrit id + subtype
        ldd   4,y
        std   x_pos,u
        ldd   6,y
        std   y_pos,u
        ldd   ,y                        ; (compute missed frames)
        subd  -4,s
        stb   wave_frame_drop,u
@bypass leay  8,y
        bra   <
@rts    sty   objectWave.data.cursor
        rts
```

### Différence avec subtype-w

- `subtype` est **1 octet** (pas de chevauchement avec render_flags)
- `x_pos` et `y_pos` sont définis par le script
- Marqueur de fin = `0` (pas `$FFFF`)

## `wave_frame_drop` — gérer le retard

Quand un objet est spawné avec un timestamp inférieur à la frame courante (cas d'un script qui démarre à une frame déjà avancée, ou d'un drop massif), la différence est stockée dans `wave_frame_drop,u` (= `anim_frame_duration`).

L'animation peut ensuite utiliser cette valeur pour **rattraper** l'animation à la bonne frame :
- Si l'objet apparaît avec un retard de 5 frames, son animation peut sauter 5 frames pour être au bon endroit du cycle visuel

Cela suppose que l'objet utilise `AnimateSpriteSync` ou un système d'animation qui consulte `wave_frame_drop`.

## Pattern de niveau (level structure)

```asm
; main.asm du game-mode level01
        ; init wave data
        _MountObject ObjID_LevelInit
        jsr   ,x

        _MountObject ObjID_LevelWave
        jsr   ,x

        ; ...

MainLoop
        ; tick wave (avant RunObjects pour que les objets spawnés bougent dès cette frame)
        _objectWave.do gfxlock.frame.count
        ; OU pour la variante subtype-w :
        ; jsr ObjectWave
        
        jsr   RunObjects
        ; ...
```

L'objet `LevelWave` n'est pas un objet « actif » au sens classique — c'est juste un container du script binaire. Son `code=` peut pointer vers un fichier asm vide (ou contenant juste une `rts`), et ses `data.X=...` (ou `sound.X`) contiennent le binaire du script.

## Pitfalls

- **Marqueur de fin oublié** : `objectWave.do` continue de lire au-delà du script → comportement erratique
- **Script non trié par timestamp** : les entrées avec timestamp futur seront sautées si le cursor a dépassé
- **`subtype_w` modifié sans précaution dans la variante moderne** : écrasement de `render_flags` accidentel
- **Init pas fait** : `objectWave.data.cursor` reste à 0 → comportement aléatoire
- **`LoadObject_u` échoue** (pool plein) : l'entrée est **skipée** sans réessai → l'objet est manqué pour toujours. Sur des scripts critiques, dimensionner large
- **Compteur de référence** : si on utilise `gfxlock.frame.count` mais que le game-mode n'utilise pas `gfxlock`, le compteur ne progresse pas. Adapter à `IrqSync` ou un compteur global du game-mode.
