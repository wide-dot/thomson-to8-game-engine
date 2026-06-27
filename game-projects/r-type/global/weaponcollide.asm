; ---------------------------------------------------------------------------
; WeaponContactTick — arcade-faithful force-pod + bit-device contact damage
; ---------------------------------------------------------------------------
; Resident helper (page 1). Called ONCE per frame in the collision phase
; (alongside the _Collision_Do calls, i.e. using the weapon/enemy AABBs as
; positioned at the end of the previous frame).
;
; ARCADE MODEL (verified in the maincpu Ghidra DB):
;   collision_to_force_pod (0x40f493) is a short-circuit OR test: force pod,
;   then fall-through into collision_to_top_and_bottom_bit_devices (0x40f49b).
;   It returns "hit" if the enemy overlaps the pod OR the top bit OR the bottom
;   bit. The HP-tracking dispatchers (v2 0x40f6da, v3 0x40f777, v4 0x40f7f0)
;   then apply ONE gated damage point:
;       TEST byte ptr [0x2eb6], 0x0F   ; global frame counter
;       JNZ  skip                      ; only when (counter & 0x0F) == 0
;       INC  [BP+0x1F]                 ; +1 to the enemy's accumulated damage
;   i.e. the force pod AND both bit devices share ONE global 1-damage-per-16-
;   frames gate, and a single enemy touched by several of them still takes only
;   1 point per window (single chained test -> single INC). The plate at v2 reads
;   "Forcepod hits are gated ... 1 dmg per 16 global frames", v3 "Forcepod only
;   apply one damage point every 16 frames". (The v1 dispatcher for one-shot /
;   invincible obstacles does not gate, but those enemies die on any hit anyway.)
;
; PORT MODEL (this routine):
;   weaponGateAccum is the frame-drop-compensated equivalent of [0x2eb6]: it is
;   advanced by gfxlock.frameDrop.count once per frame and "fires" every
;   WEAPON_GATE_PERIOD (16) elapsed frames, carrying the remainder. The enemy
;   list is walked EVERY frame; each enemy that overlaps any ARMED contact weapon
;   (force pod OR top bit OR bottom bit) takes 1 damage (dec AABB.p), once. The
;   weapons are static OSTs at fixed addresses (forcepodOST / bitdevTopOST /
;   bitdevBotOST), so this single pass reads all three AABBs directly.
;
;   ONE-SHOT vs HP (arcade v1 vs v2/v3 fidelity, without a per-enemy flag):
;   the arcade gates the pod/bits only in the HP-tracking dispatchers; v1
;   one-shot enemies die on any contact, ungated. The port collapses every
;   enemy's HP into AABB.p, and the stage-1 values split cleanly into 1 (small/
;   one-shot: patapata, blaster, ..., dobkeratops eye) and >=2 (tabrok, boss).
;   So the gate is applied PER ENEMY: p == 1 takes instant contact every frame
;   (a 1-HP enemy dies in one hit just like a basic shot -> nothing to throttle);
;   p >= 2 takes 1 dmg only on a fire frame (the arcade 1/16 throttle that stops
;   the pod melting durable enemies). Principled, and exact for this roster.
;
;   "Armed" = the slot is in an active state whose tick has positioned its
;   AABB_0 this/last frame:
;     - force pod : routine in {RunFloating, RunEjected, RunAttached} = 1..3
;       (Init=0 has not run its first frame yet; Dormant is idle).
;     - bit device: routine == ActiveTick (the frame after ActiveInit, which is
;       the first frame its AABB_0 is positioned; Dormant/ActiveInit are skipped
;       so a freshly-activated slot with a stale AABB never spuriously hits).
;
; The enemy's own AABB.p is the damage budget (>=1). p<0 = invincible (never
; touched), p==0 = already disabled (skipped). The weapons are never consumed.
; ---------------------------------------------------------------------------

        INCLUDE "./engine/collision/struct_AABB.equ"        ; AABB.* (guarded)
        INCLUDE "./objects/player1/forcepods/forcepod.equ"  ; rtnid.*  (guarded)
        INCLUDE "./objects/player1/bitdevice/bitdevice.equ" ; bitdev.rtnid.* (guarded)

WEAPON_GATE_PERIOD equ 16        ; elapsed 50Hz frames between two contact-damage passes

WeaponContactTick
        ; --- advance the global frame-drop-compensated gate (= [0x2eb6]&0x0F) ---
        ; B := 1 on a fire frame (every 16 elapsed frames), else 0. B is preserved
        ; across the whole enemy walk (the armed tests + wctk_overlap touch only A).
        lda   weaponGateAccum
        adda  gfxlock.frameDrop.count
        cmpa  #WEAPON_GATE_PERIOD
        blo   @noFire
        suba  #WEAPON_GATE_PERIOD        ; carry the remainder into the next window
        sta   weaponGateAccum
        ldb   #1                         ; gate fired this frame
        bra   @walk
@noFire
        sta   weaponGateAccum
        clrb                             ; not a fire frame
@walk
        ; One pass over the enemy list, EVERY frame:
        ;   p == 1  -> one-shot enemy (arcade v1): instant contact, every frame.
        ;   p >= 2  -> HP enemy (arcade v2/v3): 1 dmg only on a fire frame (gated).
        ; The gate throttles the pod/bits only against enemies that survive a hit;
        ; a 1-HP enemy dies on contact exactly as a single basic shot would.
        ldx   AABB_list_ennemy           ; head of the enemy list
        beq   @rts                       ; empty -> nothing to do
@eloop
        lda   AABB.p,x
        bmi   @enext                     ; p < 0  : invincible, never damaged
        beq   @enext                     ; p == 0 : already disabled, skip
        cmpa  #1
        beq   @contact                   ; one-shot enemy: contact every frame
        tstb
        beq   @enext                     ; HP enemy on a non-fire frame: skip
@contact
        ; force pod armed (routine 1..3) ?
        lda   forcepodOST+routine
        beq   @tryTop                    ; 0 = Init, AABB not positioned yet
        cmpa  #rtnid.Dormant             ; >= Dormant : idle, not armed
        bhs   @tryTop
        ldu   #forcepodOST
        bsr   wctk_overlap
        bcs   @hit
@tryTop
        ; top bit device armed (routine == ActiveTick) ?
        lda   bitdevTopOST+routine
        cmpa  #bitdev.rtnid.ActiveTick
        bne   @tryBot
        ldu   #bitdevTopOST
        bsr   wctk_overlap
        bcs   @hit
@tryBot
        ; bottom bit device armed (routine == ActiveTick) ?
        lda   bitdevBotOST+routine
        cmpa  #bitdev.rtnid.ActiveTick
        bne   @enext
        ldu   #bitdevBotOST
        bsr   wctk_overlap
        bcc   @enext
@hit
        dec   AABB.p,x                    ; 1 damage, once (p>=1 here -> clamps at 0)
@enext
        ldx   AABB.next,x
        bne   @eloop
@rts
        rts

; @overlap : X = enemy AABB, U = weapon OST (its AABB_0 = ext_variables).
; Returns CY=1 if the two boxes overlap, CY=0 otherwise. Same separating-axis
; test as Collision_Do (engine/collision/collision.asm); does not modify X.
wctk_overlap
        lda   ext_variables+AABB.rx,u
        adda  AABB.rx,x
        asla
        sta   @rx
        asra
        adda  ext_variables+AABB.cx,u
        suba  AABB.cx,x
        cmpa  #0
@rx     equ   *-1
        bhi   @miss                      ; no x overlap
        lda   ext_variables+AABB.ry,u
        adda  AABB.ry,x
        asla
        sta   @ry
        asra
        adda  ext_variables+AABB.cy,u
        suba  AABB.cy,x
        cmpa  #0
@ry     equ   *-1
        bhi   @miss                      ; no y overlap
        orcc  #1                         ; CY=1 : overlap
        rts
@miss
        andcc #$fe                       ; CY=0 : no overlap
        rts
