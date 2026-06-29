* ===========================================================================
* obj_mainext - extension non graphique du code main du game-mode.
*
* Porte hors de la page residente ($6100-$9EFF) le code "prive" du main : du
* code uniquement appele par le main, dont aucun autre objet ne depend. Monte
* comme obj_endstage ; dispatch sur B (commande). Les constantes mainext.* sont
* definies dans game-mode/01/main.asm.
*
* Contrainte page : un objet monte tourne dans la fenetre cartouche. Il ne peut
* appeler que des routines page-neutres (qui ne touchent pas la page cartouche,
* ou la restaurent). Collision_Do et WeaponContactTick sont purement calculatoires
* (verifie) -> surs ici. Pour appeler un autre OBJET, utiliser _RunObjectSwapRoutine
* (RunPgSubRoutine sauve/restaure la page), jamais _MountObject/_RunObject (qui ne
* valent que depuis la page residente 1).
* ===========================================================================
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"

* ---------------------------------------------------------------------------
* Dispatcher : B = commande (mainext.*). Voir game-mode/01/main.asm.
* IMPORTANT : ce label Object DOIT etre le premier octet emis de l'objet (= son
* point d'entree / org). Donc tout INCLUDE qui EMET du code (ex: collision-do.asm)
* doit venir APRES, en fin de fichier. Les INCLUDE ci-dessus ne sont que macros/equ.
* ---------------------------------------------------------------------------
Object
        tstb
        beq   doInit                  ; 0 = mainext.INIT      (sequence d'init du niveau)
        jmp   doCollision              ; 1 = mainext.COLLISION (passe collision du main loop)
*       commandes futures : inserer des "cmpb #mainext.X / beq doX" avant le jmp.

* ---------------------------------------------------------------------------
* mainext.INIT - sequence d'init du niveau.
* TODO (etape 2) : migrer ici le corps de Level01_Start (appels d'init + routines
* specifiques a l'init). Place tenante pour l'instant.
* ---------------------------------------------------------------------------
doInit
        rts

* ---------------------------------------------------------------------------
* mainext.COLLISION - passe de detection de collision du main loop.
* Detection AABB pure : Collision_Do marque les potentiels (AABB.p) de chaque
* paire de listes ; WeaponContactTick applique le contact arme (force pod + bit
* devices vs ennemis). Aucune dependance objet : les objets reagissent a leur
* tour en lisant leur AABB.p (RunObjects). Les data des listes restent residentes.
* ---------------------------------------------------------------------------
doCollision
        _Collision_Do AABB_list_friend,AABB_list_ennemy
        _Collision_Do AABB_list_player,AABB_list_bonus
        _Collision_Do AABB_list_player,AABB_list_foefire
        _Collision_Do AABB_list_player,AABB_list_ennemy_unkillable
        _Collision_Do AABB_list_player,AABB_list_ennemy
        _Collision_Do AABB_list_forcepod,AABB_list_foefire ; pod still blocks enemy bullets (generic)
        ; Force pod + both bit devices vs enemies: NOT generic. Arcade-faithful
        ; shared contact pass - one global 1/16-frame gate ([0x2eb6]&0x0F) for HP
        ; enemies (p>=2), instant contact for one-shot enemies (p==1); weapons
        ; never consumed. Static slots positioned their AABBs in the prev run phase.
        jsr   WeaponContactTick
        rts

* ---------------------------------------------------------------------------
* Collision_Do (passe de detection AABB) embarquee ici, APRES le dispatcher, pour
* que l'entree de l'objet reste le label Object. Hors resident : seul le main
* l'appelle, calcul pur (page-neutre). Add/Remove restent residents
* (collision-list.asm) car appeles par les objets. jsr Collision_Do ci-dessus =
* reference avant (resolue en passe 2).
* ---------------------------------------------------------------------------
        INCLUDE "./engine/collision/collision-do.asm"
