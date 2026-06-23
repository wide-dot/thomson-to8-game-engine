; ---------------------------------------------------------------------------
; Player Missile (homing weapon) — subtype 2 de l'objet commun commonmissile
;
; INCLUDE depuis ./objects/foefire/obj_commonmissile.asm : scope commun
;   (Img_missile_*, MissileImagesIndex, ObjID_commonmissileflame, layout
;   ext_variables, AABB_0, terrainCollision, explosion.const, glb_camera_x_pos,
;   ObjectMoveSync). Hitbox sur AABB_list_friend (arme joueur).
;
; PHASE 1 — PORT FIDÈLE du vol libre arcade (run_top_missile 0x4033a1 /
;   run_bottom_missile 0x40366d). AUCUNE gravité.
;   Modèle réel :
;     - compteur de phase (+0x13, init 0x10).
;     - sonde look-ahead à pos_x+0x20 : devant NON-solide -> terrain_class "clair"
;       -> phase++ et, si phase>=0x24, AVANCE HORIZONTALE pos_x += phase*24.
;     - devant SOLIDE -> NUDGE VERTICAL pos_y += 3 (top) / -= 3 (bottom), miroir.
;     - position réelle solide -> explose.
;   L'index de tuile arcade = frontière solide/non-solide => terrainCollision.do
;   est l'équivalent direct de la sonde arcade.
;
; Conversion arcade->TO8 (mémoire rtype-arcade-to-to8-conventions) :
;   x*0.375 -> phase*24*0.375 = phase*9 ;  y*0.75 -> nudge 3*0.75 ~= 2 ;
;   look-ahead 0x20*0.375 ~= 12 ;  Y inversé : signe du nudge à valider visuellement.
;   Tout compensé frame-drop.
;
; homing/abonnement = phase 2+ ; paire top/bottom + sens du nudge = phase 3/4.
; ---------------------------------------------------------------------------

PM_PHASE0   equ $10        ; compteur de phase au lancement
PM_PHX      equ $24        ; seuil de phase pour démarrer l'avance horizontale
PM_PHMAX    equ $F0        ; garde anti-wrap du compteur (arcade : pas de cap ; X=phase*24 accélère
                           ;   jusqu'à sortie d'écran ; le missile sort bien avant ce seuil)
PM_XMUL     equ 9          ; vitesse X 8.8 = phase*9  (arcade phase*24 *0.375)
PM_VNUDGE   equ $0240      ; nudge vertical 8.8 = 2.25 px/frame (arcade pos_y_int += 3, ×0.75)
; trail/jitter = dérives de trajectoire LIBRE -> on préserve l'ANGLE visuel arcade en
;   échelonnant le Y par le facteur X (0.375), sinon l'anamorphose (Y×0.75 vs X×0.375)
;   double l'angle d'écartement de la paire (top↑/bottom↓). Le nudge terrain garde ×0.75.
PM_TRAIL_DY equ $0030      ; trail drift Y/frame (arcade frac 0x80 ×0.375, préserve l'angle)
PM_JIT_DY   equ $0036      ; jitter Y/frame      (arcade frac 0x90 ×0.375, préserve l'angle)
PM_JIT_DX   equ $0048      ; jitter X/frame      (arcade frac 0xC0 ×0.375, droite)
PM_LOOKAHD  equ 12         ; look-ahead px           (arcade 0x20=32 *0.375)
PM_PROBE_PH equ $14        ; phase d'armement de la sonde look-ahead (arcade 0x14)
PM_HOME_PH  equ $18        ; seuil de phase pour démarrer le seek/homing (arcade 0x18)
PM_FLAME_PH equ $22        ; phase d'allumage de la flamme (arcade 0x346c : flamme dès 0x22)
; lock-volume arcade (0x1a08/10/18) = dalle fine DEVANT le missile, haute, mirroir top/bottom.
PM_LOCK_XN  equ 6          ; bord proche dalle (arcade 16 ×0.375) — DEVANT le missile
PM_LOCK_XF  equ 12         ; bord loin   dalle (arcade 32 ×0.375)
PM_LOCK_YA  equ 96         ; extent Y long  (arcade 128 ×0.75) — côté "couvert" du slot
PM_LOCK_YB  equ 24         ; extent Y court (arcade 32 ×0.75)  — côté opposé

; --- ext_variables réutilisés (subtype 2 / missile joueur) ---
;   missile_0x20 (ext+12) = compteur de phase   ; missile_0x16 (ext+11) = direction 16
;   missile_b    (ext+15) = cible de rampe       ; missile_flame(ext+16) = OST flamme
pm_target   equ ext_variables+13   ; 2 octets - OST ennemi verrouillé (abonnement)
pm_token    equ ext_variables+18   ; 1 octet  - id ennemi au lock (validation Option A)
pm_terrain  equ ext_variables+9    ; 1 octet  - terrain_class (arcade +0x02), état différé 1 frame
pm_trailseed equ ext_variables+10  ; 1 octet  - graine de traînée (arcade image seed +0x16)
; seek : cx/cy missile sur la PILE (plus d'ext dédié) ; ext+19 libre

PlayerMissile_Init
        ; SFX lancement : TOP seulement (arcade : bottom omet pour éviter le double-trigger)
        lda   subtype,u
        cmpa  #3
        beq   PM_noLaunchSfx
        _soundFX.play soundFX.FireBlastSound,1
PM_noLaunchSfx
        ; flamme : PAS allumée ici. Allumage retardé à phase>=0x22 (arcade 0x346c), cf. AfterMove.
        lda   #4                    ; direction initiale = droite (arcade +0x12 = 4)
        sta   missile_0x16,u
        ldx   #MissileImagesIndex
        ldd   8,x                   ; MissileImagesIndex[4] (2 octets/entrée) = vers la droite
        std   image_set,u
        ldb   #4                    ; priorité 4 = derrière le vaisseau (priorité 3)
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ; hitbox dégâts sur la liste ARME JOUEUR
        _Collision_AddAABB AABB_0,AABB_list_friend
        lda   #1
        sta   AABB_0+AABB.p,u
        _ldd  6,4
        std   AABB_0+AABB.rx,u
        lda   #PM_PHASE0            ; compteur de phase (arcade +0x13 = 0x10)
        sta   missile_0x20,u
        lda   #4                    ; terrain_class init = 4 (dégagé) -> sortie horizontale
        sta   pm_terrain,u
        jsr   RandomNumber          ; graine de traînée (arcade +0x16 = 0x30 + rnd&0x3f)
        andb  #$3f
        addb  #$30
        stb   pm_trailseed,u
        lda   #6                    ; routine PlayerMissile_FreeFlight
        sta   routine,u
        ; fall-through

PlayerMissile_FreeFlight
        ; ===== transposition exacte de run_top_missile (arcade 0x4033a1) =====
        ; --- éligibilité homing (0x33aa) : phase>=0x18 ; cible acquise par le seek (Option A) ---
        lda   missile_0x20,u
        cmpa  #PM_HOME_PH                   ; 0x18
        blo   PM_motion
        ldd   pm_target,u
        bne   PM_goHoming
        jsr   PlayerMissile_Seek            ; acquérir (dalle avant)
        ldd   pm_target,u
        beq   PM_motion
PM_goHoming
        lda   #7
        sta   routine,u
        lbra  PlayerMissile_Homing
PM_motion
        ; --- décision mouvement (0x33ba) : terrain_class (état de la frame précédente) == 4 ? ---
        lda   pm_terrain,u
        cmpa  #4
        bne   PM_vertical
        ; == 4 (dégagé) : phase++ (frame-drop, cap) ; si phase>=0x24 : pos_x += phase*24
        lda   missile_0x20,u
        adda  gfxlock.frameDrop.count
        cmpa  #PM_PHMAX
        blo   >
        lda   #PM_PHMAX
!       sta   missile_0x20,u
        cmpa  #PM_PHX                        ; 0x24
        blo   PM_lookAhead
        ldb   #PM_XMUL                       ; X 8.8 = phase*9 (arcade phase*24 ×0.375)
        mul
        std   x_vel,u
        ldd   #0
        std   y_vel,u
        jsr   ObjectMoveSync
        bra   PM_lookAhead
PM_vertical
        ; != 4 (solide devant) : pos_y ±2.25px ×frameDrop ; PAS de phase++, PAS de X (arcade 0x33c0)
        ldx   gfxlock.frameDrop.count_w
        bne   >
        ldx   #1
!       lda   subtype,u
        cmpa  #3
        beq   PM_vertLoopB
PM_vertLoopT
        ldd   y_pos+1,u                      ; [int_low:frac] de pos_y (16.8)
        subd  #PM_VNUDGE                      ; top : vers le HAUT (arcade +3, axe Y inversé)
        std   y_pos+1,u
        bcc   >
        dec   y_pos,u
!       leax  -1,x
        bne   PM_vertLoopT
        bra   PM_lookAhead
PM_vertLoopB
        ldd   y_pos+1,u
        addd  #PM_VNUDGE                      ; bottom : vers le BAS (arcade -3)
        std   y_pos+1,u
        bcc   >
        inc   y_pos,u
!       leax  -1,x
        bne   PM_vertLoopB
PM_lookAhead
        ; --- sonde look-ahead (0x33e2) : pose terrain_class pour la frame SUIVANTE ---
        lda   #4                             ; défaut = dégagé
        sta   pm_terrain,u
        lda   missile_0x20,u
        cmpa  #PM_PROBE_PH                   ; phase < 0x14 -> reste forcé 4 (pas de sonde)
        blo   PM_rampTarget
        ldd   x_pos,u                        ; sonde avant-plan à pos_x + 0x20 (×0.375)
        addd  #PM_LOOKAHD
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1
        jsr   terrainCollision.do
        tstb
        bne   PM_lookSolid
        lda   globals.backgroundSolid        ; arcade teste fg ET bg : arrière-plan si actif
        beq   PM_rampTarget
        ldd   x_pos,u
        addd  #PM_LOOKAHD
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #0
        jsr   terrainCollision.do
        tstb
        beq   PM_rampTarget
PM_lookSolid
        ; solide devant -> terrain_class = 0 (top) / 8 (bottom)  [arcade BL=0 / BL=8]
        lda   subtype,u
        cmpa  #3
        beq   PM_lookBot
        clra
        sta   pm_terrain,u                    ; top -> 0
        bra   PM_rampTarget
PM_lookBot
        lda   #8
        sta   pm_terrain,u                    ; bottom -> 8
PM_rampTarget
        ; cible de rampe du sprite = terrain_class (arcade : la dir se rampe vers terrain_class)
        lda   pm_terrain,u
        sta   missile_b,u

; --- tail FREE-FLIGHT uniquement (le homing saute ce bloc) : trail drift + jitter ---
PM_freeTail
        ; trail-Y drift (arcade 0x3428), COMPENSÉ frame-drop : 1 décrément seed + drift par frame
        ldx   gfxlock.frameDrop.count_w
        bne   PM_trailHave
        ldx   #1
PM_trailHave
        lda   pm_trailseed,u
        beq   PM_noTrail                ; seed 0 -> fini
        deca
        sta   pm_trailseed,u
        cmpa  #$10
        bhs   PM_trailNext              ; >=0x10 -> pas de drift, mais continue à décrémenter
        lda   subtype,u
        cmpa  #3
        beq   PM_trailB
        ldd   y_pos+1,u                 ; TOP : haut (arcade ADD 0x80)
        subd  #PM_TRAIL_DY
        std   y_pos+1,u
        bcc   PM_trailNext
        dec   y_pos,u
        bra   PM_trailNext
PM_trailB
        ldd   y_pos+1,u                 ; BOTTOM : bas (arcade SUB 0x80)
        addd  #PM_TRAIL_DY
        std   y_pos+1,u
        bcc   PM_trailNext
        inc   y_pos,u
PM_trailNext
        leax  -1,x
        bne   PM_trailHave
PM_noTrail
        ; jitter (arcade 0x34ae) : phase>=0x24, COMPENSÉ frame-drop (delta par frame écoulée)
        lda   missile_0x20,u
        cmpa  #PM_PHX
        blo   PM_noJit
        ldx   gfxlock.frameDrop.count_w
        bne   PM_jitHave
        ldx   #1
PM_jitHave
        lda   subtype,u
        cmpa  #3
        beq   PM_jitB
        ldd   y_pos+1,u                 ; TOP : haut (arcade ADD 0x90)
        subd  #PM_JIT_DY
        std   y_pos+1,u
        bcc   PM_jitX
        dec   y_pos,u
        bra   PM_jitX
PM_jitB
        ldd   y_pos+1,u                 ; BOTTOM : bas (arcade SUB 0x90)
        addd  #PM_JIT_DY
        std   y_pos+1,u
        bcc   PM_jitX
        inc   y_pos,u
PM_jitX
        ldd   x_pos+1,u                 ; X droite (commun, arcade ADD 0xC0)
        addd  #PM_JIT_DX
        std   x_pos+1,u
        bcc   PM_jitNext
        inc   x_pos,u
PM_jitNext
        leax  -1,x
        bne   PM_jitHave
PM_noJit
        ; fall-through

PlayerMissile_AfterMove
        ; sonde terrain position RÉELLE (arcade 0x340c) : fg OU bg solide -> explose
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1
        jsr   terrainCollision.do
        tstb
        lbne  PlayerMissile_Explode
        lda   globals.backgroundSolid
        beq   PM_amViewport
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #0
        jsr   terrainCollision.do
        tstb
        lbne  PlayerMissile_Explode
PM_amViewport
        ; hors viewport (axe x)
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        lble  PlayerMissile_Delete
        subd  #160-8/2
        cmpd  glb_camera_x_pos
        lbge  PlayerMissile_Delete
        ; potentiel épuisé (touché) ?
        lda   AABB_0+AABB.p,u
        lbeq  PlayerMissile_Explode
        ; rampe direction vers la cible : ±1 pas/frame, fenêtre ±8 (jamais de 180 instantané),
        ;   COMPENSÉE frame-drop = autant de pas que de frames écoulées (arcade = 1 pas/frame).
        ldx   gfxlock.frameDrop.count_w
        bne   PM_dirStep
        ldx   #1
PM_dirStep
        ldb   missile_b,u
        tfr   b,a
        suba  missile_0x16,u                ; A = (cible - dir) mod 16
        anda  #$0f
        beq   PM_dirDraw                     ; aligné -> stop
        cmpa  #8
        bhi   PM_dirDecr                     ; diff 9..15 -> dir-- (plus court par l'autre sens)
        inc   missile_0x16,u                 ; diff 1..8  -> dir++
        bra   PM_dirMask
PM_dirDecr
        dec   missile_0x16,u
PM_dirMask
        lda   missile_0x16,u
        anda  #$0f
        sta   missile_0x16,u
        leax  -1,x
        bne   PM_dirStep                     ; pas suivant (frame-drop)
PM_dirDraw
        ldx   #MissileImagesIndex
        lda   missile_0x16,u
        asla
        ldd   a,x
        std   image_set,u
        ; maj hitbox
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        ; --- flamme : allumage RETARDÉ (arcade : dessinée dès phase>=0x22, ou toujours en homing) ---
        ldy   missile_flame,u
        bne   PM_flamePos                ; déjà allumée -> positionne
        lda   routine,u                  ; pas allumée : homing (routine 7) ?
        cmpa  #7
        beq   PM_flameIgnite
        lda   missile_0x20,u             ; sinon phase >= 0x22 ?
        cmpa  #PM_FLAME_PH
        blo   PM_flameDone
PM_flameIgnite
        jsr   LoadObject_x
        beq   PM_flameDone
        lda   #ObjID_commonmissileflame
        sta   id,x
        stx   missile_flame,u
        tfr   x,y
PM_flamePos
        ldx   #pm_flame_off                ; table arcade JOUEUR 0x1a58 (≠ Tabrok, flamme moins en arrière)
        lda   missile_0x16,u
        asla
        asla
        leax  a,x
        ldd   ,x
        addd  x_pos,u
        std   x_pos,y
        ldd   2,x
        addd  y_pos,u
        std   y_pos,y
PM_flameDone
        jmp   DisplaySprite

PlayerMissile_Explode
        jsr   LoadObject_x
        beq   PlayerMissile_Delete
        _ldd  ObjID_explosion,explosion.subtype.fwk
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
PlayerMissile_Delete
        lda   missilePairCount  ; un missile de moins (gate du re-tir), sans underflow
        beq   PM_delCell
        dec   missilePairCount
PM_delCell
        ; libère MA cellule cible (no-double-lock)
        lda   subtype,u
        cmpa  #3
        beq   PM_delBot
        ldd   #0
        std   missileTgtTop
        bra   PM_delFlame
PM_delBot
        ldd   #0
        std   missileTgtBot
PM_delFlame
        ldx   missile_flame,u           ; tue la flamme enfant
        beq   >
        lda   #1
        sta   ext_variables,x           ; commonmissileflame.kill_me
!       lda   #2                        ; AlreadyDeleted (réutilisé)
        sta   routine,u
        _Collision_RemoveAABB AABB_0,AABB_list_friend
        jmp   DeleteObject

; ---------------------------------------------------------------------------
; Homing (routine 7) — poursuite d'un ennemi verrouillé (Option A)
; ---------------------------------------------------------------------------
PlayerMissile_Homing
        ; validation cible : OST non nul + id inchangé (sinon ennemi mort/recyclé)
        ldx   pm_target,u
        beq   PM_homeLost
        lda   id,x
        cmpa  pm_token,u
        bne   PM_homeLost
        ; direction vers la cible (X=cible, U=self) -> Y = dir*4
        jsr   setDirectionTo            ; Y = dir*4 (direction INSTANTANÉE vers la cible)
        ; cible de rampe du SPRITE = index direction (Y>>2), façon arcade (SHR BX,1 x2)
        tfr   y,d
        lsrb
        lsrb
        stb   missile_b,u
        ; vélocité = table arcade du missile JOUEUR (0x1a98 convertie), indexée
        ;   par la direction INSTANTANÉE (pas la dir rampée), comme run_top_missile_homing
        tfr   y,d
        ldx   #pm_homing_vel
        leax  d,x
        ldd   ,x
        std   x_vel,u
        ldd   2,x
        std   y_vel,u
        jsr   ObjectMoveSync
        lbra  PlayerMissile_AfterMove     ; rampe sprite + terrain + hitbox + flamme + display

PM_homeLost
        ldd   #0
        std   pm_target,u
        ; libère MA cellule (no-double-lock)
        lda   subtype,u
        cmpa  #3
        beq   PM_hlBot
        ldd   #0
        std   missileTgtTop
        bra   PM_hlDone
PM_hlBot
        ldd   #0
        std   missileTgtBot
PM_hlDone
        lda   #6                          ; retour vol libre
        sta   routine,u
        lbra  PlayerMissile_FreeFlight

; ---------------------------------------------------------------------------
; Seek — scan AABB_list_ennemy, verrouille le 1er ennemi dans la boîte de lock.
;   sortie : CY=1 + pm_target/pm_token si trouvé, sinon CY=0.  (U préservé)
; ---------------------------------------------------------------------------
PlayerMissile_Seek
        ldd   x_pos,u
        subd  glb_camera_x_pos
        pshs  b                            ; [1,s] = cx missile (octet bas écran)
        ldb   y_pos+1,u
        pshs  b                            ; [,s]  = cy missile
        ldx   AABB_list_ennemy             ; tête de liste
PM_seekLoop
        beq   PM_seekMiss
        lda   AABB.p,x
        beq   PM_seekNext                  ; potentiel 0 -> ignore
        ; X : ennemi DEVANT, dans la dalle [mcx+XN, mcx+XF] (arcade : lock-volume 16..32 px en avant)
        lda   AABB.cx,x
        suba  1,s                           ; A = enemy_cx - missile_cx (mcx en pile ; + = devant)
        cmpa  #PM_LOCK_XN
        blt   PM_seekNext                   ; pas assez devant (ou derrière) -> suivant
        cmpa  #PM_LOCK_XF
        bgt   PM_seekNext                   ; trop loin -> suivant
        ; Y : plage haute biaisée selon le slot (top couvre vers le bas, bottom vers le haut)
        lda   AABB.cy,x
        suba  ,s                            ; A = enemy_cy - missile_cy (mcy en pile ; + = bas)
        ldb   subtype,u
        cmpb  #3
        beq   PM_seekYbot
        cmpa  #-PM_LOCK_YB                   ; TOP : Y in [-24, +96]
        blt   PM_seekNext
        cmpa  #PM_LOCK_YA
        bgt   PM_seekNext
        bra   PM_seekHit
PM_seekYbot
        cmpa  #-PM_LOCK_YA                   ; BOTTOM : Y in [-96, +24]
        blt   PM_seekNext
        cmpa  #PM_LOCK_YB
        bgt   PM_seekNext
PM_seekHit
        ; dans la dalle -> candidat : OST ennemi = noeud - ext_variables
        tfr   x,d
        subd  #ext_variables
        ; no-double-lock : déjà ciblé (par le sibling) ? -> ennemi suivant
        cmpd  missileTgtTop
        beq   PM_seekNext
        cmpd  missileTgtBot
        beq   PM_seekNext
        std   pm_target,u                  ; verrouille
        ; écrit MA cellule (subtype 2 = top, 3 = bottom)
        lda   subtype,u
        cmpa  #3
        beq   PM_seekMyBot
        ldd   pm_target,u
        std   missileTgtTop
        bra   PM_seekTok
PM_seekMyBot
        ldd   pm_target,u
        std   missileTgtBot
PM_seekTok
        ldx   pm_target,u
        lda   id,x
        sta   pm_token,u
        leas  2,s                          ; nettoie le scratch pile (préserve CC)
        orcc  #1                           ; CY=1 (verrouillé)
        rts
PM_seekNext
        ldx   AABB.next,x
        bra   PM_seekLoop
PM_seekMiss
        leas  2,s                          ; nettoie le scratch pile
        andcc #$fe                         ; CY=0
        rts

; ---------------------------------------------------------------------------
; Table de vélocité homing du missile JOUEUR — transcrite de l'arcade ES:[0x1a98]
;   (maincpu.bin), indexée par setDirectionTo (dir*4, 0x00..0x3C).
;   Conversion arcade->TO8 : vx * 0.375 ; vy * 0.75 puis NÉGATÉ (axe Y inversé).
;   Magnitude arcade L1 = 4.5 px ; 16 directions, 0x00=haut .. sens horaire.
; ---------------------------------------------------------------------------
pm_homing_vel
        fdb   $0000,$FCA0   ; 0  haut        (arcade 0,+4.5)
        fdb   $0090,$FDC0   ; 1  haut-droite
        fdb   $00D8,$FE50   ; 2
        fdb   $0120,$FEE0   ; 3
        fdb   $01B0,$0000   ; 4  droite      (arcade +4.5,0)
        fdb   $0120,$0120   ; 5
        fdb   $00D8,$01B0   ; 6
        fdb   $0090,$0240   ; 7
        fdb   $0000,$0360   ; 8  bas         (arcade 0,-4.5)
        fdb   $FF70,$0240   ; 9
        fdb   $FF28,$01B0   ; 10
        fdb   $FEE0,$0120   ; 11
        fdb   $FE50,$0000   ; 12 gauche      (arcade -4.5,0)
        fdb   $FEE0,$FEE0   ; 13
        fdb   $FF28,$FE50   ; 14
        fdb   $FF70,$FDC0   ; 15 haut-gauche

; offset flamme par direction = table ARCADE JOUEUR 0x1a58 (≠ Tabrok) : X×0.375, Y×-0.75,
;   arrondi serré (flamme collée au missile). 4 octets/dir (dx word, dy word).
;   knob : pour rapprocher/éloigner la flamme en vol horizontal, ajuster dir 4 / dir 12 (X).
pm_flame_off
        fdb   $0000,$0009   ; 0  haut        (arcade 0,-12)
        fdb   $FFFE,$0007   ; 1
        fdb   $FFFD,$0006   ; 2
        fdb   $FFFC,$0004   ; 3
        fdb   $FFFC,$0000   ; 4  droite      (arcade -12,0 -> -4px ; Tabrok faisait -5)
        fdb   $FFFC,$FFFC   ; 5
        fdb   $FFFD,$FFFA   ; 6
        fdb   $FFFE,$FFF9   ; 7
        fdb   $0000,$FFF7   ; 8  bas         (arcade 0,+12)
        fdb   $0002,$FFF9   ; 9
        fdb   $0003,$FFFA   ; 10
        fdb   $0004,$FFFC   ; 11
        fdb   $0004,$0000   ; 12 gauche      (arcade +12,0)
        fdb   $0004,$0004   ; 13
        fdb   $0003,$0006   ; 14
        fdb   $0002,$0007   ; 15
