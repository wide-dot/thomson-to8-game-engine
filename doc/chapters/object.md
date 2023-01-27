# La gestion des objets

## Un embryon d'objet

Dans la boucle principale d'un programme, on peut exécuter librement un ensemble de routines. Un problème se pose cependant lorsque l'on veut exécuter plusieurs fois la même routine, mais associée à un ensemble de données différent.

Pour répondre à ce besoin, la première chose qui nous vient à l'esprit est de passer un pointeur vers un ensemble de données en paramètre de cette routine.

Pour cela nous allons utiliser le registre U.
```
        ; ...

        ldu   #data1
        jsr   routine

        ldu   #data2
        jsr   routine

        ; ...

routine
        ldd   x_pos,u ; horizontal position
        ; processing ...

        ldd   y_pos,u ; vertical position
        ; processing ...

        rts

; offsets to data structure
x_pos equ 0
y_pos equ 2

data1
        fill  0,4 ; an array of 4 bytes

data2
        fill  0,4 ; an array of 4 bytes
```

Une autre stratégie est d'utiliser le registre DP (direct page). le traitement sera alors plus rapide, l'inconvénient étant que la structure de donnée a une taille fixe de 256 octets et doit être positionnée en mémoire à une adresse multiple de 256.

```
        ; ...

        lda   #data1
        tfr   a,dp
        jsr   routine

        lda   #data2
        tfr   a,dp
        jsr   routine

        ; ...

routine
        ldd   <x_pos ; horizontal position
        ; processing ...

        ldd   <y_pos ; vertical position
        ; processing ...

        rts

; offsets to data structure
x_pos equ 0
y_pos equ 2

        align 256
data1
        fill  0,4 ; an array of 4 bytes

        align 256
data2
        fill  0,4 ; an array of 4 bytes
```

Même si ce principe reste rudimentaire on peut considérer que c'est un début de gestion d'objet, en effet nous avons ici un comportement associé à un ensemble d'attributs propres, dont les données sont persistantes.

Cela n'est cependant pas suffisant si l'on souhaite créer ces objets à plus grande échelle et de manière dynamique.

## Instancier un objet

## Détruire un objet

## Définir des attributs

## Définir des comportements

## Exécuter un comportement

## Utiliser la Direct Page

Un moyen d'accéder plus rapidement aux données est l'utilisation de la Direct Page.
Ce principe peut être mis en oeuvre our les données de l'objet du joueur principal.
Dans ce cas de figure on ne fait pas appel à la routine d'allocation d'objet.
la methode runObjects n'executera donc pas le code.
Première étape, déclarer l'objet :
```
        lda   #ObjID_Sonic
        sta   id+dp
```

On peut positionner des valeurs pour les variables de la même manière :
```
        ldd   #$60
        std   x_pos+dp
        ldd   #$028F
        std   y_pos+dp
```
Vous voyez ici qu'on a pas besoin de ,u pour accéder aux données objets.
On utilise l'offset de la variable + la constante dp

Seconde étape, executer le code objet 
Dans la boucle principale, ajouter ce code : 
```
    _RunObject ObjID_Sonic,#dp 
```

Dans le code objet l'utilisation de ,u fonctionnera toujours (on charge u avec la zone mémoire pointée par dp) , ça permet de garder la compatibilité avec les routines d'animation ...
mais dans votre code utilisez x_pos+dp pour aller plus vite
Voila c'est tout !
