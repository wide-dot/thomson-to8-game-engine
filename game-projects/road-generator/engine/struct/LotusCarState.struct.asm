********************************************************************************
* LotusCarState — État d'une voiture (player ou AI) — port de Lotus Esprit
* Turbo Challenge.
*
* Source : reverse engineering Atari ST, struct 182 oct à $7c546 (player 1),
* $7c5fc (player 2), $7c6b2.. (AI cars). Cf :
*   lotus-ste/doc/extraction/09_player_struct.md
*   lotus-ste/doc/extraction/21_TICK_PHYSIQUE_JOUEUR.md
*
* Layout compact 32 oct (= seuls les champs utilisés par notre port).
* Convention d'accès : U pointe sur le state courant (= équivalent A4 ST).
*
*     ldu  #PlayerOne_State          ; ou &AI_States[i]
*     lda  LotusCarState.input_held,u
*     std  LotusCarState.speed,u
*     jsr  Lotus_PhysicsTick         ; (= FUN_75e30 port)
*
* Adaptation TO8 : valeurs horizontales (lateral_pos, steering, etc.) sont
* halvées par rapport à ST. Cf engine/physics/PhysicsTables.asm pour les
* EQU constantes (PHYS_LATERAL_HI = $C0, PHYS_STEERING_MAX = $10, etc.).
********************************************************************************

 ifndef struct_LotusCarState
struct_LotusCarState equ 1

LotusCarState         struct
* ── Position / vitesse forward ──────────────────────────────────────────
track_pos             rmb   4   ; 32-bit cumulatif (high=compteur seg, low=fraction)
segment_idx           rmb   2   ; cache ∈ [0, NB_SEGMENTS[ — maintenu par
                                ; Lotus_PhysicsTick : incrémenté quand le low-word
                                ; de track_pos overflow propage (wrap mod N).
                                ; Évite de recalculer (track_pos>>16)%N à chaque
                                ; consommation (projection, AI steering, collision).
                                ; Pas de hardware divu sur 6809 → cache obligatoire.
speed                 rmb   2   ; ushort, forward velocity
gear                  rmb   2   ; 0..4
rpm                   rmb   2   ; régime moteur, clampé [1000, 7999]
* ── Position / vitesse latérale (horizontal X écran) ────────────────────
lateral_pos           rmb   4   ; 32-bit (integer clampé ±PHYS_LATERAL_HI)
steering              rmb   2   ; short, angle (clamp ±PHYS_STEERING_MAX)
lat_impulse           rmb   2   ; short — impulsion latérale collision
lat_impulse_dir       rmb   2   ; short — direction impulsion (±8)
* ── Limites / état ──────────────────────────────────────────────────────
max_speed             rmb   2   ; ushort, = Lotus struct[+0x68]
event_flag            rmb   2   ; short, 0=normal, ≠0=crash
recovery_timer        rmb   2   ; short, décrémente sur crash
off_road              rmb   1   ; flag throttle/wheel-slip (= struct[+0x8a])
gearbox_b0            rmb   1   ; flag mode gearbox alt (= struct[+0xb0])
* ── Input (= post-FUN_0007abbe, format LRDU+FIRE) ───────────────────────
input_held            rmb   1   ; courant (bits : 0=L 1=R 2=D 3=U 4=FIRE)
input_last            rmb   1   ; précédent (pour calcul edges)
input_edges           rmb   1   ; just pressed = held AND (held XOR last)
                      ; (1 oct spare pour alignement)
_pad0                 rmb   1
                      endstruct

 endc
