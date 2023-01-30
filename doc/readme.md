# Développer un jeu vidéo ... retro ?

## Un peu de magie

Si vous lisez ceci, c'est que, comme moi à une époque, vous avez envie de perçer ce mystère : Comment ont-ils réussi a coder ce jeu vidéo ?

Un bon jeu vidéo c'est comme un bon tour de magie, ça vous plonge dans un univers où ce qui semble impossible devient réel ...
Derrière tout ça il y a du travail et de la technique. Que vous vouliez devenir magicien ou comprendre le tour, il va falloir y passer du temps, et utiliser les bons accessoires ...

L'idée de ce manuel est de vous fournir toutes les informations pour comprendre et maitriser à 
votre tour l'implémentation des jeux vidéos.

## La plateforme

Avant de se lancer il va falloir faire deux choix. Pour rendre ce manuel possible j'ai fait ces choix pour vous :
- la plateforme d'exécution sera le Thomson TO8/TO8D/TO9+
- le langage de programmation sera l'assembleur

Rien ne vous empêche cependant d'utiliser ce manuel pour d'autres plateformes et d'autres langages, les concepts restent les mêmes.

Pourquoi ces choix ? Un manuel sur la programmation de jeu Megadrive ou NES aurait été tout aussi pertinent. Pas de panique, justement le code mis en oeuvre dans ce manuel s'inspire de celui des jeux sur console, il est simplement transposé à une autre machine.

Cette plateforme est intéressante car elle ne bénéficie pas d'accélération materielle particulière, de ce fait le code sera relativement peu dépendant du matériel, même si le code sera bien entendu spécifique au processeur Motorola 6809.
De plus c'est une machine très répandue en France, vous n'aurez pas de mal à vous la procuprer.

La machine bénéficie des caractéristiques suivantes :
- processeur Motorola 6809 @1Mhz
- 256Ko de RAM (512Ko au total avec l'extension de RAM)
- port cartouche
- port extension (midi, carte son)
- port 2 manettes (2 boutons)
- port crayon optique
- sortie audio (6 bits)
- sortie vidéo RVB (50Hz)
- palette de couleurs programmable
- timer irq

## Le processeur Motorola 6809

L'apprentissage de l'assembleur est un prérequis indispensable à la lecture de ce manuel. Bonne nouvelle : le 6809 est un processeur simple à aborder.

à rédiger - historique

à rédiger - architecture et fonctionnement

à rédiger - instructions

à rédiger - ressources (livres et sites internet)

## Les modèles de conception

à rédiger - La boucle principale

à rédiger - Le double buffering

en cours de rédaction - [La gestion des objets][objects]

en cours de rédaction - [La gestion des collisions][collision]

à rédiger - Les interruptions

à rédiger - Les manettes

à rédiger - L'affichage de sprites

à rédiger - Le scrolling

à rédiger - La streaming

à rédiger - La gestion des cartes son et midi

## Les composants

à rédiger - Le déplacement des sprites

à rédiger - Les effets de palette

à rédiger - Les contrôles utilisateur

## Les routines pour Thomson TO8

à rédiger - Le lancement automatique

à rédiger - La lecture de disquette

à rédiger - L'accès aux manettes

à rédiger - L'accès au clavier

à rédiger - La palette de couleur

[objects]: chapters/object.md
[collision]: chapters/collision.md