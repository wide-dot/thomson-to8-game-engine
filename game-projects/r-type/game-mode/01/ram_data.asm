* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 50 ; +4 static (player, forcepod, bitdevice, bitdevice)
nb_graphical_objects         equ 64 ; max 64 total
ext_variables_size           equ 20 ; ext_variables_size is for dynamic objects (shell=20, cancer=19 : ne PAS reduire, ennemis tireurs -> reserve base = champs fire)

* ===========================================================================
* Object Status Table - OST
* ===========================================================================
player1                      equ   dp
palettefade                  fcb   ObjID_fade
                             fill  0,object_size-1 ; NE PAS trimmer : le fade utilise o_fade_curwait (ext+9) -> deborde sur forcepodOST si reduit
; static player-weapon slots - run via _RunObject right after player1 each frame.
; routine starts at 0 (id only); set to their Dormant routine at Level01_Start so they
; idle in place until collected, then activated by the pow pickup.
forcepodOST                  fcb   ObjID_forcepod
                             fill  0,object_size-1
bitdevTopOST                 fcb   ObjID_bitdevice
                             fill  0,object_size-1
bitdevBotOST                 fcb   ObjID_bitdevice
                             fill  0,object_size-1

Dynamic_Object_RAM           fill  0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End

* ===========================================================================
* Collision lists
* ===========================================================================
AABB_lists.nb                equ   (AABB_endLists-AABB_lists)/2
AABB_lists
AABB_list_friend             fdb   0,0
AABB_list_ennemy             fdb   0,0
AABB_list_ennemy_unkillable  fdb   0,0
AABB_list_player             fdb   0,0
AABB_list_bonus              fdb   0,0
AABB_list_foefire            fdb   0,0
AABB_list_forcepod           fdb   0,0
AABB_endLists

player_pos_ring_buffer_ptr  fdb   player_pos_ring_buffer
player_pos_ring_buffer      fill  0,4*32 ; saves position of player one: x (2 bytes), y (2 bytes), repeated 32 times

* ===========================================================================
* Arme missile joueur — état manager TRANSITOIRE (in-stage ; remis à 0 au chargement de stage)
*   (le statut persistant missileUnlocked est dans globals., cf. global/variables.asm)
* ===========================================================================
missilePairCount            fcb   0      ; missiles vivants (gate du re-tir)
missileTgtTop               fdb   0      ; OST cible missile TOP (no-double-lock)
missileTgtBot               fdb   0      ; OST cible missile BOTTOM

* ===========================================================================
* Force-pod / bit-device CONTACT gate — accumulateur frame-drop global
*   Equivalent porté du compteur arcade [0x10002eb6] & 0x0F : un seul gate
*   partagé par le force pod et les 2 bit devices (WeaponContactTick).
* ===========================================================================
weaponGateAccum             fcb   0      ; +frameDrop.count/frame, fire tous les 16

* Flag transitoire : !=0 pendant le replay catch-up d'un cancer au spawn (un seul
* a la fois, synchrone). Lu par RunCancerDisplacement pour s'arreter apres le move
* (pas de sprite/stuck/Live). Cf objects/enemies/cancer/obj.asm.
cancerCatchup               fcb   0

* ===========================================================================
* Table d'effacement des shells (rotonde) — remplace les 14 objets shellmask.
* Indexee par (subtype-1) du shell : 14 slots x [old_pos_0(2), old_pos_1(2)].
* Pas de shellPtr : le shell ecrit sa position dans son slot (ShellSavePos),
* l'effaceur (objets/enemies/shell/eraser.asm) blitte les slots non-nuls.
* slot a 0 = vide (shell absent/supprime). DOIT etre remise a 0 au chargement
* niveau ET au reload checkpoint (sinon positions fantomes).
* ===========================================================================
shellEraseTable             fill  0,14*4
shellEraseTable_end

* ===========================================================================
* Starfield PROCEDURAL - 22 etoiles (8 + 7 + 7), 39 octets de RAM AU TOTAL.
*
* La RAM residente du niveau 1 est PLEINE : sans le starfield le module
* s'arrete deja a $9E4C, et la pile systeme descend depuis $9F00
* (glb_system_stack equ dp) -> il ne reste que ~180 octets, et ce sont ceux de
* la pile. Le plafond est donc $9F00, PAS $A000 : une table de 30 etoiles x
* 12 o (360 o) poussait le module a $9FC2 -- sous $A000, donc "ca tient" en
* apparence -- et ecrasait la pile ET la page directe. Resultat mesure : PC
* dans la VRAM ($4F45), ecran noir.
*
* D'ou ce modele : les etoiles n'ont AUCUN etat mutable par etoile.
*   - toutes les etoiles d'un plan partagent le meme offset de defilement,
*     puisqu'elles ont la meme vitesse ;
*   - l'adresse VRAM d'une etoile ne dependant que de (plan, tour, offset,
*     etoile), toutes connues a la COMPILATION, elle est PRECALCULEE dans
*     starTab_p* (stardata.asm) : 8640 o de PAGE CARTOUCHE, gratuits en RAM
*     residente, et valables pour les deux buffers ;
*   - l'effacement relit la meme table a l'offset ET au tour du dernier trace
*     dans CE buffer -- ni adresse ni octet sauve a stocker.
* Le plan 0 a 2 tours (voir gen_stardata.py) : a chaque passage ses etoiles
* reapparaissent a une hauteur differente, ce qui casse la periodicite de 144
* trames trop visible sur le plan rapide. D'ou le "tour courant/precedent".
* Seul reste en RAM : 3 offsets + 3 tours courants, 3x2 offsets + 3x2 tours
* "dernier trace par buffer", et le scratch.
*
* Cf. docs/rtype-starfield-rapport.md (le spec 2026-07-15 decrit, lui, le
* modele save/restore initial, qui est PERIME).
* ===========================================================================
star_x_span                 equ   144  ; 8..151 inclus -> 144 colonnes ; sert a
                                       ; borner l'offset dans [0, 144.0). Le wrap
                                       ; des positions, lui, est precalcule dans
                                       ; stardata.asm (cf. gen_stardata.py).
star_cam_max                equ   436  ; extinction quand l'entree du vaisseau (le
                                       ; mur plein, colonne 49 du tilemap) touche le
                                       ; bord droit. Le modele (col N au bord gauche
                                       ; <=> camera = 12*N) donnait ~428 ; 436 est le
                                       ; reglage A L'OEIL valide en jeu (424 coupait
                                       ; encore un peu trop tot). La camera va a
                                       ; 0.1875 px/trame (scroll_vel $0030) : +/-12
                                       ; ici = +/-1 colonne = ~1,3 s.

; -- ces 4 blocs (27 o) sont contigus et remis a 0 en bloc par StarfieldInit --
starCurOff                  fdb   0,0,0        ; offset 8.8 courant, par plan (6 o)
starPrevOff                 fdb   0,0,0,0,0,0  ; offset du dernier trace [plan][buffer] (12 o)
                                               ; index = plan*4 + buffer*2
starCurLap                  fcb   0,0,0        ; tour courant, par plan (3 o) ; plan 0 : 0/1
starPrevLap                 fcb   0,0,0,0,0,0  ; tour du dernier trace [plan][buffer] (6 o)
                                               ; index = plan*2 + buffer
; -- fin du bloc remis a 0 par StarfieldInit --
starBufOff                  fcb   0    ; 0 ou 2 selon gfxlock.backBuffer.id
starPlaneIdx                fcb   0    ; plan courant 0..2
starCurIdx                  fcb   0    ; index dans starCurOff  (= plan*2)
starPrevIdx                 fcb   0    ; index dans starPrevOff (= plan*4 + buffer*2)
starPrevLapIdx              fcb   0    ; index dans starPrevLap  (= plan*2 + buffer)
starLapDisp                 fdb   0    ; deplacement de tour passe a StarSetup (tour*lapStride)
starOffInt                  fcb   0    ; partie entiere de l'offset du plan
starFrameCnt                fcb   0    ; compteur de la boucle frame-drop
starNoDraw                  fcb   0    ; !=0 : extinction en cours (effacer, ne plus tracer)
starOffCnt                  fcb   0    ; rendus d'effacement effectues pendant l'extinction (compte jusqu'a 4)
starDead                    fcb   0    ; !=0 : starfield termine, l'objet ne coute plus rien

