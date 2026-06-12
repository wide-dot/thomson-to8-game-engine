# Objet en Direct Page — optimisation accès OST

Le 6809 a un mode d'adressage Direct Page (`<addr` ou setting du registre DP) qui économise 1 octet (1 cycle) par accès comparé à l'adressage indexé. Pour le joueur principal, qui est exécuté à chaque frame avec de nombreux accès à `x_pos`, `y_pos`, `x_vel`, etc., placer son OST en Direct Page peut représenter un gain notable.

## Principe

Le 6809 a un registre DP de 8 bits qui définit la page haute pour l'adressage direct. Si `DP = $9F`, alors `<x_pos` (avec `x_pos = 18`) accède à `$9F12`.

L'engine réserve `$9F00-$9FFF` comme zone Direct Page utilisateur :
```asm
dp                            equ $9F00        ; user space (149 bytes max)
glb_system_stack              equ dp
```

Les premiers 149 octets sont disponibles pour l'application. Le reste contient :
- `dp_engine` (32 octets) — variables temporaires de l'engine
- `dp_extreg` (28 octets) — registres étendus partagés

## Pattern — joueur en DP

### Déclaration dans `ram-data.asm`

```asm
player1                  equ   dp                ; alias pour l'OST du joueur en DP
```

### Init au boot du game-mode

```asm
        ; Init de la zone DP
        jsr   ObjectDp_Clear            ; clear de dp à dp_extreg

        ; Init du joueur en DP
        lda   #ObjID_Player
        sta   id+player1                ; = sta <id (équivalent)
        ldd   #Ani_PlayerIdle
        std   anim+player1
        ldb   #4
        stb   priority+player1
        ; ... etc
```

### Exécution dans `MainLoop`

```asm
MainLoop
        jsr   RunObjects                ; gère les objets dynamiques (ennemis, projectiles)
        _RunObject ObjID_Player,#player1 ; exécute le joueur manuellement
        ; ...
```

`_RunObject` charge `U = #player1` puis fait `jsr ,x` sur le code du joueur. Le code du joueur peut donc utiliser `U` comme d'habitude pour accéder à son OST.

### Code du joueur en DP

```asm
Player
        ; Le code peut utiliser AU CHOIX :
        ; - U,offset (équivalent à un objet normal)
        ; - <offset (direct page, plus rapide)
        
        lda   <routine                  ; = lda routine,u (mais 1 cycle plus rapide)
        asla
        ldx   #Player_Routines
        jmp   [a,x]

Player_Routines
        fdb   Init
        fdb   Main

Init
        ; ...
        inc   <routine
        rts

Main
        ldd   <x_pos                    ; accès direct-page rapide
        ; ... logique ...
        jsr   AnimateSprite
        jmp   DisplaySprite
```

## `ObjectDp_Clear`

```asm
ObjectDp_Clear
        ldx   #dp
        lda   #0
!       sta   ,x+
        cmpx  #dp_extreg
        bne   <
        rts
```

Efface la zone DP utilisateur (de `dp` à `dp_extreg`). À appeler une seule fois au boot, ou à chaque transition de game-mode si on veut un état propre.

## Sémantique du registre DP

Par défaut, le 6809 a `DP = $00` au reset. L'engine **ne reset pas DP** explicitement (il reste à $00 sauf si tu le mets toi-même).

Pour utiliser `<addr` correctement, il faut :
1. Soit utiliser `tfr a,dp` pour positionner DP sur la bonne page haute
2. Soit utiliser `setdp $9F` directive LWASM pour indiquer au compilateur la valeur de DP

Le repo utilise typiquement la directive `setdp` :
```asm
        setdp $9F
```

Cela permet à LWASM de remplacer automatiquement `lda x_pos` (extended) par `lda <x_pos` (direct) quand l'adresse résolue est dans la page DP.

> **Attention** : `setdp` n'**émet pas** d'instruction CPU. C'est juste une directive de compilation. Il faut **aussi** que `DP` soit positionné à runtime via `lda #$9F; tfr a,dp` (ce qui est fait par le boot loader engine).

## Limites et précautions

### Taille limitée à 256 octets

DP couvre **256 octets** (`$9F00-$9FFF`). L'OST occupe `object_size ≈ 50-58` octets. Donc :
- 1 joueur en DP = OK, reste ~200 octets pour d'autres variables globales
- 2-3 objets en DP = OK
- Tout le pool d'objets en DP = **impossible** (dépasse 256 octets)

### Pas dans la run-list

L'objet en DP n'est **pas dans `Dynamic_Object_RAM`**. Il faut le faire tourner manuellement (`_RunObject`) car `RunObjects` ne le voit pas.

### Collisions et autres références

Si l'objet en DP utilise des AABB de collision, ses listes `AABB_list_*` doivent pointer correctement vers son OST (en DP). Aucun problème particulier, mais l'adresse est `#player1`, pas un slot du pool dynamique.

### Réutilisation par d'autres game-modes

Quand on change de game-mode, la zone DP n'est pas forcément effacée. Si le nouveau game-mode utilise aussi un joueur en DP, il faut appeler `ObjectDp_Clear` ou réinitialiser explicitement.

### Conflit avec engine

`dp_engine` et `dp_extreg` (haut de la page DP) sont utilisés par l'engine pour des variables temporaires (e.g. registres étendus). **Ne pas placer un objet dans cette zone** — il serait écrasé par les routines engine.

L'espace utilisateur disponible est de `dp` à `dp_engine` exclus, soit environ 149 octets. Pour 1 objet de ~58 octets, ça laisse ~91 octets pour des variables globales du game-mode.

## Pattern r-type (player1)

Dans r-type, le joueur est en DP via :
```asm
player1                       equ   dp
palettefade                   fcb   ObjID_fade        ; objet fade pré-chargé après player1
                              fill  0,object_size-1
```

`palettefade` (le fade) est aussi en DP, juste après player1. L'objet fade est créé au boot (`LoadObject_u`) mais son adresse est forcée à pointer juste après player1 dans la zone DP — pattern un peu hacky mais efficace.

## Quand utiliser DP ?

Critères pour mettre un objet en DP :
- ✅ Objet exécuté à chaque frame (joueur principal)
- ✅ Objet avec beaucoup d'accès à son OST (lecture/écriture `x_pos`, `x_vel`, etc.)
- ✅ Code de l'objet relativement long (l'économie de cycles compte)
- ❌ Objet peu actif (économie négligeable)
- ❌ Objet temporaire (pas de bénéfice persistant)
- ❌ Multiple instances (DP est limité)

Pour la plupart des objets dynamiques (ennemis, projectiles, effets), le pool dynamique est suffisant. **DP est réservé au joueur principal** (et éventuellement à 1-2 objets singletons comme le fade).

## Pitfalls

- **`setdp` sans positionner DP runtime** : le code compilé utilise direct-page mais DP = $00 au runtime → accès à $0012 au lieu de $9F12 → crash
- **DP changé par une routine appelée et non restauré** : si une routine fait `tfr a,dp` sans préserver DP, le code de retour utilise une mauvaise valeur. Toujours `pshs dp` au début et `puls dp` à la fin si on change DP
- **Mélanger `<x_pos` et `x_pos,u` pour le même objet** : OK si U pointe sur DP, mais source de confusion. Préférer une convention cohérente (toujours `<` ou toujours `,u`)
- **Effacer DP pendant une routine** (`ObjectDp_Clear` au mauvais moment) : efface l'objet courant
- **Conflict avec `glb_system_stack`** : `dp = $9F00` et `glb_system_stack = dp` (alias). La pile **partage** la zone DP. La pile descend depuis le haut, l'OST monte depuis le bas. Vérifier qu'ils ne se rencontrent pas (pile typique 32-64 octets utilisés → ~$9FC0-$9FFF, OST de 58 octets → ~$9F00-$9F39, marge ~150 octets)
