# Protocole
1. Lancer r-type avec un point d'arret de type "EXEC" sur 01DA. Cela nous ammèner à un certain endroit du début du jeu.
2. A partir de là, on lance la production d'une trace de 32s, et DCMoto produit un fichier `dcmoto_trace.txt` 
3. lancer l'analyse de ce fichier depuis la racine "r-type" avec par un truc genre: ```
Samuel@LENOVO-PC MINGW64 /e/Users/Samuel/dev/thomson-to8-game-engine/game-projects/r-type (main)
$ ../../../DCMoto_MemMap/lua.exe ../../../DCMoto_MemMap/memmap.lua \
 	-trace=<chemin/vers/dcmoto>/dcmoto_trace.txt \
    -equ=generated-code/level01/FD/main.lwmap \
    -map -hot=colors -hints -mach=TO -verbose=1 -times=LevelMainLoop -html 
Analyzed 963.228 Mb of trace (23.080 Mb/s).
Created CSV writer (tab=8).
Created HTML writer.
Created Parallel writer.
Finding hot spots.
```
4. Un fichier HTML est produit qui contient des infos utiles poru l'optimisation. 
En particulier l'option `-times=LevelMainLoop` mesure empiriquemen le temps moyen passé entre chaque appel de la boucle principale. On peut en déduire le FPS moyen sur ces 32 secondes tracées. L'info est présente dans le tableau.
5. Modifier l'asm en coinséquence de l'analyse
6. recompiler et retourner en 1.

Note les options de l'étape 3 sont un peu longue. Cependant si on lance ```
$ ../../../DCMoto_MemMap/lua.exe ../../../DCMoto_MemMap/memmap.lua -prev-args
```
alors l'outil ira retrouver les arguments de la ligne de commande dans le fichier CSV accompagnant le HTML.

# mesures initiales
La vitesse moyenne mesurée est d'environ 11fps, soit un peu plus de 4VBL par image. plus précisément le temps entrer deux passage par la routine LevelMainLoop s'étale environ de 400µs à 161ms pour une moyenne de 92ms avec une erreur-standard de +/- 30%. Cela montre que les frames sont loin d'êtr calculées en temps constant.

Environ 14 "hotspots" représantant 12s des 32s joués sont trouvés. Chacun de ces hotspots correspond à une routine spécifique:
1. CSR_ProcessEachPriorityLevel (23% du temps)
2. DrawTiles (13%)
3. empty_tile (12%)
4. DRS_ProcessEachPriorityLevelB0 (4%)
5. DRS_ProcessEachPriorityLevelB1 (4%)
6. BgBufferAlloc (4%)
7. ESP_ProcessEachPriorityLevelB0 (3%)
8. ESP_ProcessEachPriorityLevelB1 (3%)
9. BgBufferFree (3%)
10. ObjectMoveSync (3%)
11. DisplaySprite (3%)
12 RunObjects (2%)
13. tryFoeFire (2%)
14. Collision_Do (2%)

En plus l'outil suggèrer 118 modifications d'instructions résultant sur environ 200ms de gain à elles seules sur l'ensemble de la séquence de 32s. Ca parait peu, mais c'est toujours ca de gain à prendre sans avoir à changer trop massivement l'implémentation.

# optim 1: remplacement des long-branch par des short-branch
Il y en a 7 de trouvés durant les 32s enregistrés, chaun représantant plus de 5% duy temps gagnable. Rien qu'avec cette série d'optim on couvre 30% des 200ms facilement optimisabler.

Pour cela on utilisera les pragma [autobranchlength](http://www.lwtools.ca/manual/x676.html) dans les portions du moteur qui sont incluse dans plusieurs fichiers. On portègera le statut de ce pragma en utilisant *PRAGMAPUSH/*PRAGMAPOP.

# mesure no 2
TBD.