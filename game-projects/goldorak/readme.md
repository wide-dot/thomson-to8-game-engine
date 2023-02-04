# Journal de Dev de Goldorak

## Day 1 : Ecran simple d'introduction

Structuration des répertoires :
* `game-mode` : contient tous les "écrans" du jeu
* `objects` : contient tous les objets (images, animations, musiques) manipulés par les *game-modes*
* `resources` : contient des ressources graphiques génériques (lib).
* `global` : contient des définitions communes entre chaque game-mode (equates, macros)

Les répertoires suivants sont générés automatiquement par le *Builder*
* `generated-code` : contient notamment les .lst issus de la compilation des *game-modes* et des *objects*.
  
La racine contient les fichiers de configuration pour le *Builder* :
* `config-linux.properties` : pour Linux
* `config-win.properties` : pour Windows

Le répertoire `/dist` contient la génération du jeu :
* au format cartouche .rom
* au format disquette double densité : .fd

## Day 2 : Musique d'introduction



