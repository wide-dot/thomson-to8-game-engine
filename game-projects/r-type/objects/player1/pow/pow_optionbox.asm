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
        INCLUDE "./objects/player1/forcepods/forcepod.equ"  ; rtnid.* (activate the static force pod)
        INCLUDE "./objects/soundFX/soundFX.const.asm"
        INCLUDE "./engine/sound/soundFX.macro.asm"

AABB_0            equ ext_variables   ; AABB struct (9 bytes)
Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live
	    fdb   AlreadyDeleted

Init
	lda   subtype,u
        ;bne   >  ; rebound laser code is unfinished
        ;lda   #4 ; replace by counter-air
        ;sta   subtype,u
!       lsla
        ldx   #optionboxes
        ldd   a,x
        bne   >                         ; type non implemente (entree a 0 dans la table :
        jmp   DeleteObject              ;   subtypes 2, 5 et 6). Sans cette garde le bonus
                                        ;   etait INVISIBLE (image_set=0 -> DisplaySprite
                                        ;   sort tout de suite) mais bien ramassable, et
                                        ;   @captured le traitait en counter-air par defaut.
!       std   image_set,u
        ldb   #7
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
	inc   routine,u

        _Collision_AddAABB AABB_0,AABB_list_bonus
        
        lda   #127                      ; set weak hitbox type
        sta   AABB_0+AABB.p,u
        _ldd  4,7                       ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        ldd   y_pos,u
        stb   AABB_0+AABB.cy,u

Live
        jsr   ObjectMoveSync
        lda   AABB_0+AABB.p,u
        beq   @captured                ; was captured  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #4                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        jmp   DisplaySprite
@captured
        lda   subtype,u                 ; Rebound laser ?
        beq   >
        cmpa  #3                        ; Speed ?
        beq   @speed
        cmpa  #7                        ; Missiles ?
        beq   @missiles
        cmpa  #1                        ; Counter-ground laser ?
        beq   >
        lda   #2                        ; reste : subtype 4 = counter-air (les subtypes sans
                                        ;   image sont filtres a l'Init, cf. optionboxes)
!
        sta   player1+forcepodtype
                                        ; Do we need to activate the force pod ?
        lda   player1+forcepodlevel
        bne   >
                                        ; Yes : the force pod is the static forcepodOST slot.
                                        ; Activate it by kicking its routine to Init (its spawn/
                                        ; setup routine), which seeds position and AABB. The slot's
                                        ; id is already ObjID_forcepod (ram_data); it was idling in
                                        ; Dormant. Init runs next frame via _RunObject in the loop.
                                        ; NB: write via the absolute slot address, not routine,u -
                                        ; U is this optionbox's own OST (still needed at @delete).
        lda   #rtnid.Init
        sta   forcepodOST+routine
!
        lda   player1+forcepodlevel
        cmpa  #3
        beq   >
        inca  
        sta   player1+forcepodlevel
!
        _soundFX.play soundFX.BonusSound,4
@delete
        inc   routine,u     
        _Collision_RemoveAABB AABB_0,AABB_list_bonus
        jmp   DeleteObject
@speed
        ldd   player1+speedlevel
        addd  #32
        cmpd  #32*5             ; arcade : 5 paliers (0..4). On plafonne a l'offset
        beq   >                 ;   128 (Configuration 5 = niveau 4, le plus rapide) ;
        std   player1+speedlevel ;  sans ca on restait bloque au niveau 3 (config 4).
!
        jmp   @delete
@missiles
        lda   #1                        ; débloque l'arme missile sous-nacelle (paire homing)
        sta   globals.missileUnlocked
        _soundFX.play soundFX.BonusSound,4
        jmp   @delete
AlreadyDeleted
        rts


; 0 = type non implemente : l'objet se supprime a l'Init (cf. garde ci-dessus).
; Les types instancies au stage 1 (quartet haut du 5e octet de la wave, cf. pow.asm)
; sont 0, 3, 4, 7 ; le type 5 est intercepte par pow.asm et devient un bit device.
optionboxes

        fdb Img_pow_optionbox_0    ; 0 Bounce laser
        fdb Img_pow_optionbox_1    ; 1 Counter ground laser
        fdb 0                      ; 2 (non implemente)
        fdb Img_pow_optionbox_3    ; 3 Speed up
        fdb Img_pow_optionbox_4    ; 4 Counter air laser
        fdb 0                      ; 5 (bit device : intercepte par pow.asm)
        fdb 0                      ; 6 (non implemente)
        fdb Img_pow_optionbox_7    ; 7 Missiles