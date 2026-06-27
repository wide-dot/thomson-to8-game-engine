* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects           equ 50 ; was 55 : -3 for the static weapon slots below + -2 spare headroom
nb_graphical_objects         equ 55 * max 64 total
ext_variables_size           equ 20 ; ext_variables_size is for dynamic objects

* ===========================================================================
* Object Status Table - OST
* ===========================================================================
player1                      equ   dp
palettefade                  fcb   ObjID_fade
                             fill  0,object_size-1
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

