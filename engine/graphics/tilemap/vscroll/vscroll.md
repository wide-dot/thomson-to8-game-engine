# Procédure pour générer les assets du scroll vertical TO8 BM16

1 - depuis pro motion, faire "export all" et choisir export du tileset en un seul fichier avec une seule colonne

	- format de la map : .stm
	- prefixe des fichiers: level1
	- répertoire de destination : thomson-to8-game-engine\game-projects\goldorak\objects\scroll\level1 

2 - ensuite avec les outils 6809-game-builder :

- génération de la map:
    
    La commande suivante effectue la conversion d'un fichier stm avec tile id 32bit en map binaire avec des tile id de 12bit. La valeur des id de tile est doublée (valeurs paires uniquement). Le header stm n'est pas conservé dans le fichier bin de sortie.

		stm2bin -f="C:\Users\bhrou\git\thomson-to8-game-engine\game-projects\goldorak\objects\scroll\level1\level1.stm" -obd=12 -mul=2 

    Signification des paramètres :

    * odb : output bit depth for a tile id = 12bit
    * mul : output tile id multiplicator = 2

- génération des buffers de départ
    
    La commande suivante va générer deux buffers contenant du code et des données. Il s'agit d'encoder l'image qui sert de point de départ au scroll. L'image png en entrée de la conversion doit etre de taille 160x201 pour un scroll plein écran. La derniere ligne sera invisible, l'image doit être calée en haut. Si votre viewport est plus petit en hauteur, il faut tout de même donner une image d'une ligne de pixels supplémentaires en hauteur.

		png2bin -f C:\Users\bhrou\git\thomson-to8-game-engine\game-projects\goldorak\objects\scroll\pro-motion\level1.start.png -lb 4 -pb 8 -p 2 -pd 4 -vs -slc

    Signification des paramètres :

    * lb  : linear bits, number of bits that defines a pixel in a plane = 4bit
    * pb  : planar bits, number of bits to process before going next plane = 8bits
    * p   : planes, number of memory planes = 2
    * pd  : pixel depth, number of bits per pixel = 4
    * vs  : output data buffer for Vertical Scroll
    * slc : shift colors indexes to the left by one position

- génération du tileset

    Dans la version actuelle du scroll vertical, le tileset est de taille fixe (512 tiles). Il faut donc compléter l'image en hauteur pour qu'elle soit de taille 8192 pixels avant de lancer la commande suivante :
		
		png2bin -f C:\Users\bhrou\git\thomson-to8-game-engine\game-projects\goldorak\objects\scroll\pro-motion\level1.tiles.png -lb 4 -pb 8 -p 2 -pd 4 -vst -slc 

    Signification des paramètres :

    * vst : output tile data for Vertical Scroll"
