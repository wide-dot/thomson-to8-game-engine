# Les variables globales

## Principe

Une variable globale doit être accéssible de n'importe quel endroit dans le code. Il s'agit donc d'identifier une zone mémoire non commutable (qui ne peut pas être recouverte par une page de ram ou de rom).

Pour aller plus loin on peut imaginer que cette variable globale ne soit pas impactée, ni par le changement du programme principal, ni par un redémarrage système de type reset. On pourra alors y stocker un score ou un nombre de vies par exemple.

Il existe un autre usage aux variables globales, auquel on ne pense pas tout de suite, il s'agit des variables temporaires partagées. En effet on peut avoir besoin, dans une routine, de stocker des valeurs sans pour autant vouloir conserver ces valeurs à la prochaine exécution de la routine. L'utilisation d'une variable temporaire partagée permet donc un gain de mémoire.

Le processeur 6809 offre un système de "direct page" qui permet un accès rapide à la mémoire dans une plage de 256 octets. Ce système est très utile dans le cas de l'utilisation de variables globales (temporaires ou non), il permet de palier au manque de registres processeur et donne un accès plus rapide aux variables couramment utilisées.

Chaque machine a sa propre organisation mémoire, mais le principe reste le même : il faut trouver cette zone mémoire.
Jusqu'ici la problématique semble simple, mais il va falloir s'organiser pour faire face à quelques problématiques.
La zone mémoire non commutable héberge :
- le code principal du programme, qui peut changer au fil du temps (différents niveaux de jeu) et qui est donc de taille variable
- la pile système, qui empile les addresses lors des appels de routines, mais également des données
- la "direct page"

Voici donc l'organisation mémoire proposée dans le cadre de ce modèle de conception :

(ici diagramme, mais sans adresses)

## Cas d'usage

Dans le cadre du moteur de jeu pour le TO8, la mémoire non commutable peut être utilisée ainsi :

(diagramme avec adresses)

Les variables globales persistantes sont stockées à partir de $9DFF inclus en remontant.
Les variables globales temporaires et persistantes pour le moteur de jeu sont stockées en zone dp $9F00-$9FFF

Dans cet exemple, l'espace pour la pile système est de 256 octets, il peut être réduit ou augmenté en fonction des besoins du programmeur.

Dans le cadre du moteur de jeu, la zone "direct page" ne contient pas uniquement des variables temporaires.
dp_engine                     equ glb_Page-32  ; engine routines tmp var space
dp_extreg                     equ dp_engine-28 ; extra register space (user and engine common)
dp                            equ $9F00        ; user space (149 bytes max)
glb_system_stack              equ dp


glb_ram_end                   equ $A000-12
; compilated sprite
glb_register_s                equ glb_ram_end-2             ; reverved space to store S from ROM routines
; DrawSprites
glb_screen_location_1         equ glb_register_s-2          ; start address for rendering of current sprite Part1     
glb_screen_location_2         equ glb_screen_location_1-2   ; start address for rendering of current sprite Part2 (DEPENDENCY Must follow Part1)
glb_camera_height             equ glb_screen_location_2-2
glb_camera_width              equ glb_camera_height-2
glb_camera_x_pos_coarse       equ glb_camera_width-2        ; ((glb_camera_x_pos - 64) / 64) * 64
glb_camera_x_pos              equ glb_camera_x_pos_coarse-2 ; camera x position in palyfield coordinates
glb_camera_y_pos              equ glb_camera_x_pos-2        ; camera y position in palyfield coordinates
glb_camera_x_min_pos          equ glb_camera_y_pos-2
glb_camera_y_min_pos          equ glb_camera_x_min_pos-2
glb_camera_x_max_pos          equ glb_camera_y_min_pos-2
glb_camera_y_max_pos          equ glb_camera_x_max_pos-2
glb_camera_x_offset           equ glb_camera_y_max_pos-2
glb_camera_y_offset           equ glb_camera_x_offset-2
glb_force_sprite_refresh      equ glb_camera_y_offset-1
glb_camera_move               equ glb_force_sprite_refresh-1
glb_alphaTiles                equ glb_camera_move-1
glb_timer_second              equ glb_alphaTiles-1
glb_timer_minute              equ glb_timer_second-1
glb_timer                     equ glb_timer_minute
glb_timer_frame               equ glb_timer-1
; BankSwitch
glb_Page                      equ glb_timer_frame-1

Tu peux utiliser la fin de la page residente mais avant $9E00. En $9DFE-9DFF par exemple. 
Il y a un « trou » entre la fin de chacun de tes game mode et :
- la zone dp $9F00-$9FFF
- la pile qui remonte depuis $9EFF inclus
Si tu laisse 256 octets à la pile ce qui est "très large", tu peux donc te placer en dessous Par contre tu dois init ta variable car elle n’est pas set a zero. 
A toi de vérifier dans les .lst de tes GameMode (répertoire generated code) jusqu’où va ton utilisation de cette page

## Cas d'erreur

Etant donné qu'il n'y a pas de contrôle de la taille des données écrites lors du chargement du programme principal, il est recommandé de positionner une alerte dans le code qui indiquera si un recouvrement mémoire intervient sur les variables globales.

Dans l'exemple ci dessous on considère que le code principal doit s'arrêter en $9DFD, pour ne pas écraser les variables globales positionnées en $9DFE et $9DFF :

```
_end
 ifge _end-$9DFE
    error "Main overflow (>=$9DFE)"
 endc 
```

Ce code sera interprété durant la phase d'assemblage ou de lien par LWASM et indiquera une erreur si le dépassement se produit.
