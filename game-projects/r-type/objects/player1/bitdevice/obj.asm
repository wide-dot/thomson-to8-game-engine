; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/player1/player1.equ"
        INCLUDE "./objects/player1/bitdevice/bitdevice.equ" ; bitdev.rtnid.* (static-slot seeding)
AABB_0            equ ext_variables    ; AABB struct (9 bytes)
old_xpos1         equ ext_variables+9  ; word
old_ypos1         equ ext_variables+11 ; word
old_xpos2         equ ext_variables+13 ; word
old_ypos2         equ ext_variables+15 ; word
offsety           equ ext_variables+17 ; word

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   InitOptionBox            ; 0 floating pickup
        fdb   LiveOptionBox            ; 1 floating pickup
        fdb   AlreadyDeletedOptionBox  ; 2 floating pickup
        fdb   Dormant                  ; 3 (legacy slot; unreachable, parked at Dormant)
        fdb   ActiveInit               ; 4 static slot: seed orbit + fall into tick
        fdb   ActiveTick               ; 5 static slot: orbit + AABB_0 + gated tick dmg
        fdb   Dormant                  ; 6 static slot: idle until activated / when lost

; Dormant : a static slot (bitdevTopOST/bitdevBotOST) idles here, drawing nothing
; and doing nothing, until the player collects a bit-device pickup (LiveOptionBox
; below activates a free slot by writing bitdev.rtnid.ActiveInit to slot+routine).
; A bit returns here (instead of DeleteObject) when it is lost/unloaded.
Dormant
        rts

InitOptionBox
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldx   #25
        stx   offsety,u
        ldx   #Ani_bitdevice1
        stx   anim,u
        inc   routine,u                 ; Set routine to LiveOptionBox

        _Collision_AddAABB AABB_0,AABB_list_bonus        
        lda   #127                        ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  3,6                       ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
LiveOptionBox
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   @delete
        lda   player1+bitdevice
        cmpa  #2
        bhs   >                        ; ignore contact if player1 already has the 2 bit devices
        lda   AABB_0+AABB.p,u
        beq   Collect                  ; was touched -> activate a static slot
!
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
@delete
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        inc   routine,u
        jmp   DeleteObject
AlreadyDeletedOptionBox
        rts

; ---------------------------------------------------------------------------
; Collect : the floating pickup was touched. Activate a free static bit-device
; slot (bitdevTopOST first, then bitdevBotOST), then delete the pickup. The bit
; count player1+bitdevice picks the slot: 0 -> TOP, 1 -> BOTTOM. The slot is
; activated by writing bitdev.rtnid.ActiveInit to slot+routine; ActiveInit seeds
; its orbit side/anim from player1+bitdevice and falls into ActiveTick.
;   [u] = floating pickup OST (deleted here)
; ---------------------------------------------------------------------------
Collect
        ldx   #bitdevTopOST            ; bit 0 (count 0) -> top slot
        lda   player1+bitdevice
        beq   >
        ldx   #bitdevBotOST            ; bit 1 (count 1) -> bottom slot
!
        lda   #bitdev.rtnid.ActiveInit
        sta   routine,x                ; activate the static slot (ActiveInit next frame)
        inc   player1+bitdevice        ; one more active bit device

        ; delete the floating pickup (transient): drop its bonus hitbox and free it
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        lda   #AlreadyDeletedRtn
        sta   routine,u
        jmp   DeleteObject

AlreadyDeletedRtn equ bitdev.rtnid.AlreadyDeleted

; ---------------------------------------------------------------------------
; ActiveInit : a static slot has just been activated by Collect. Seed its render
; state, orbit side (offsety + anim from the bit index), tracking history (from
; the player) and tick accumulator, then fall straight into ActiveTick. The slot
; is NOT registered in AABB_list_friend (it does its own gated tick collision).
;   [u] = static slot OST (bitdevTopOST / bitdevBotOST)
; ---------------------------------------------------------------------------
ActiveInit
        ldb   #2
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        ; orbit side from the bit index: TOP (count was 0 -> now 1) above the
        ; ship (offsety +25, Ani_bitdevice1), BOTTOM (count now 2) below it
        ; (offsety -25, Ani_bitdevice2). player1+bitdevice was already
        ; incremented by Collect, so 1 -> top, 2 -> bottom.
        ldx   #25
        ldy   #Ani_bitdevice1
        lda   player1+bitdevice
        cmpa  #1
        beq   >
        ldx   #-25
        ldy   #Ani_bitdevice2
!       stx   offsety,u
        sty   anim,u

        ; seed delayed tracking history from the player's current position
        ldd   player1+x_pos
        std   old_xpos1,u
        std   old_xpos2,u
        ldd   player1+y_pos
        std   old_ypos1,u
        std   old_ypos2,u

        lda   #bitdev.rtnid.ActiveTick
        sta   routine,u
        ; fall through into ActiveTick for the first frame

; ---------------------------------------------------------------------------
; ActiveTick : per-frame active bit device. Orbit/track the player (the original
; in-place Live logic) and position AABB_0 for this frame. Enemy contact is NOT
; applied here: the force pod and BOTH bit devices share one global, frame-drop-
; gated pass (WeaponContactTick, collision phase in main.asm) that hits each
; overlapping enemy for 1 every 16 frames -- the arcade [0x2eb6]&0x0F gate. The
; slot is never in any friend list and is never consumed.
;   [u] = static slot OST
; ---------------------------------------------------------------------------
ActiveTick
        ldd   glb_camera_x_pos
        subd  glb_camera_x_pos_old
        addd  old_xpos1,u
        std   old_xpos1,u

        ldd   glb_camera_x_pos
        subd  glb_camera_x_pos_old
        addd  old_xpos2,u
        std   x_pos,u

        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldd   old_ypos2,u
        subd  offsety,u
        std   y_pos,u
        stb   AABB_0+AABB.cy,u

        ldd   old_xpos1,u
        std   old_xpos2,u
        ldd   old_ypos1,u
        std   old_ypos2,u

        ldd   player1+x_pos
        std   old_xpos1,u
        ldd   player1+y_pos
        std   old_ypos1,u

        ; position the hitbox radius (small, from the original pickup: 3,6)
        _ldd  3,6
        std   AABB_0+AABB.rx,u

        ; enemy contact is applied by the shared, frame-drop-gated WeaponContactTick
        ; (collision phase, main.asm). Arcade: the force pod and BOTH bit devices
        ; share ONE global 1/16-frame gate ([0x2eb6]&0x0F), 1 dmg per enemy/window.
        jsr   AnimateSpriteSync
        jmp   DisplaySprite

