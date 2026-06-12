# Formats d'animation — v00 et v02

L'engine supporte deux formats de script d'animation : **v00** (legacy, duration globale) et **v02** (advanced, duration et flags par frame). Le format est **auto-détecté** par le builder Java en regardant si le premier champ contient une virgule.

## Auto-détection (builder Java)

Dans `BuildDisk.java` (`writeAniIndex`) :

```java
if (!animationProperties.getValue()[0].contains(",")) {
    // ** Animation v00 ** — premier champ = duration (entier)
} else {
    // ** Animation v02 ** — premier champ = "Img,duration,flags"
}
```

## Format v00 — legacy

### Syntaxe `.properties`

```properties
animation.Ani_<X>=<duration>;<Img_1>;<Img_2>;...;<end-tag>[;<param>]
```

`<duration>` est un entier (frames par image, **commun à toutes les frames**).

Exemples :
```properties
animation.Ani_Idle=2;Img_Idle_001;Img_Idle_002;Img_Idle_003;_resetAnim
animation.Ani_Fall=0;Img_Fall_001;_resetAnim
animation.Ani_Walk=4;Img_Walk_001;Img_Walk_002;Img_Walk_003;Img_Walk_004;_goBackNFrames;3
animation.Ani_Die=3;Img_die_a;Img_die_b;Img_die_c;_nextRoutine
```

### Binaire généré

```
adresse_label_courant-1 : fcb duration   ; mais le builder stocke duration-1 (cf. ci-dessous)
adresse_label_courant   : fdb Img_<1>    ; pointeur premier sprite (2 octets)
adresse_label_courant+2 : fdb Img_<2>
adresse_label_courant+4 : ...
                          fcb tag_FX     ; tag + param éventuel
```

> **Important** : `duration` est stockée **moins 1** par le builder. C'est pour ça que `0` dans le .properties signifie « 1 frame par image ». La routine `AnimateSprite` décrémente `anim_frame_duration` jusqu'à passer à -1 (`bpl` est faux), puis charge la frame suivante.

> **Position de duration** : juste **avant** le label. Le code asm fait `ldb -1,x; stb anim_frame_duration,u` pour la lire après avoir indexé sur `x = adresse_label`.

### Calcul de taille

```java
size++;                          // duration (1 byte)
for chaque frame :
  if frame != tag : size += 2;   // pointeur Img_ (2 bytes)
  else : size += taille_tag;     // 1, 2 ou 3 bytes selon tag
```

### Génération asm (extrait `BuildDisk.java`)

```java
asm.addFcb(new String[] { animationProperties.getValue()[0] });   // duration-1
asm.addLabel(animationProperties.getKey() + " ");                  // Ani_<X>
for (int i = 1; i < animationProperties.getValue().length; i++) {
    if (Animation.tagSize.get(...) == null) {
        asm.addFdb(new String[] { animationProperties.getValue()[i] });   // Img_
        size += 2;
    } else {
        // tag : 1, 2, ou 3 octets
        asm.addFcb(new String[] { animationProperties.getValue()[i] });
        // params éventuels
    }
}
```

### Tags

| Tag | Hex | Bytes |
|-----|-----|-------|
| `_resetAnim` | $FF | 1 |
| `_goBackNFrames` | $FE | 2 (FE + N) |
| `_goToAnimation` | $FD | 3 (FD + 2 bytes adresse) |
| `_nextRoutine` | $FC | 1 |
| `_resetAnimAndSubRoutine` | $FB | 1 |
| `_nextSubRoutine` | $FA | 1 |

## Format v02 — advanced

### Syntaxe `.properties`

```properties
animation.Ani_<X>=<Img_1>,<duration>,<flags>;<Img_2>,<duration>,<flags>;...;<end-tag>[;<param>]
```

Chaque frame fait **3 champs séparés par virgules** :
- `Img_<X>` : pointeur sprite
- `duration` : nombre de frames d'affichage (1 = 1 frame, etc.) — stocké en **moins 1** par le builder
- `flags` : octet de flag (interprété par `AnimateSpriteAdv` comme offset dans une LUT applicative)

Exemple :
```properties
animation.Ani_Attack=Img_atk_001,3,$00;Img_atk_002,2,$01;Img_atk_003,5,$02;_resetAnim
```

### Binaire généré

```
adresse_label : fdb Img_atk_001    ; 2 octets
                fcb duration-1     ; 1 octet (= 2 = 3 frames d'affichage)
                fcb flags          ; 1 octet (= $00)
                ; total 4 octets... mais le builder écrit 5 octets en réalité

                fdb Img_atk_002
                fcb 1              ; duration-1 = 1 = 2 frames
                fcb $01

                fdb Img_atk_003
                fcb 4              ; duration-1 = 4 = 5 frames
                fcb $02

                fcb $FF            ; _resetAnim
```

> **Détail** : le code java `BuildDisk.java` écrit `fdb image + fcb duration + fcb flags` = **5 octets par frame**. À vérifier dans le binaire généré (peut être 4 ou 5 selon les commits).

### Différence clé avec v00

- **Pas de duration globale** : chaque frame a sa propre duration
- **Flag par frame** : offset dans une LUT applicative pour callbacks (hitbox, son, particle)
- **5 octets par frame** au lieu de 2 (pointeur seul)

### Avantage v02

Animation où la durée varie (attaque qui ralentit en fin de mouvement, anticipation/recovery) :

```properties
animation.Ani_AttackCombo=Img_anticipate,8,0;Img_strike,1,1;Img_recover_a,4,0;Img_recover_b,8,0;_resetAnim
```

- Anticipation lente (8 frames sur la première image)
- Strike rapide (1 frame seulement, mais avec flag $01 pour la hitbox)
- Recovery progressive

## Format combiné (rare)

Mélanger v00 et v02 dans une même animation n'est **pas supporté**. Une animation est soit l'un soit l'autre (détecté sur la première frame).

## `animation-data` — données pré-générées

```properties
animation-data=./path/to/preset.bin
```

Un blob binaire placé **avant** les animations dans le `.glb` généré. Cas d'usage : scripts `moveByScript` pré-compilés, tables custom.

**Limite** : `if (animationDataProperties.size()>1) throw new Exception` — une seule entrée `animation-data` par objet.

## Génération du fichier `.glb`

Pour chaque objet, le builder génère un fichier `<obj>_Animation.asm` qui contient :
1. Les données `animation-data` (si présentes)
2. Toutes les animations de l'objet (labels Ani_X + données binaires)

Inclus dans le code asm de l'objet via prepend automatique :
```asm
        INCLUDE "<generated-code>/<objname>_Animation.asm"
```

C'est ce fichier qui fournit les labels `Ani_<X>` utilisés par le code (`ldd #Ani_Idle; std anim,u`).

## Pitfalls

- **Confondre duration et nb de frames affichées** : `duration=2` = 2 frames d'affichage par image (1 frame d'affichage = `duration=0` dans v00, `duration=1` dans v02 .properties — le builder ajuste)
- **Format v02 avec moins de 3 champs** : exception au build « need three comma separated parameters »
- **Animation v02 mais routine AnimateSprite** (non Adv) : les flags par frame ne sont pas lus, comportement v00 sur structure v02 → désynchronisation
- **`_goToAnimation` avec adresse mal formée** : 2 octets après le tag $FD doivent pointer un label `Ani_<X>` valide
- **Tag $FF accidentel** dans les données (mauvais alignement) : trigger _resetAnim involontaire
- **Modifier le binaire d'animation à la main** : risque de désaligner les frames (5 octets en v02, 2 en v00)
