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

