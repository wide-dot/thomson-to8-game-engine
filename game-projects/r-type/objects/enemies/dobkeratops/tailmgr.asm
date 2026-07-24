; ===========================================================================
; tailmgr - MASTER fan-out COMPLET : 1 objet engine bg-erase qui PILOTE les
; 19 vraies tails du boss (hors-pool). Portage 1:1 de tail.asm (Run/follow/
; gating moveAlienStart, WaitEndStage/bossDefeated/hold, Explode) eclate sur
; 19 records d'etat ; TailDrawAll/TailEraseAll eclatent vers les 19 blits
; compiles bg-erase. Etat + preset + scripts : tout sur la page master.
; COLLISION sans AABB stockees : les tails sont des boites invincibles (p=-128),
; on duplique l'algo Collision_Do et on teste directement les listes player et
; friend au recalcul de position (1 element sur 2 porte une hitbox, et on
; alterne les elements testes une trame sur deux, comme l'arcade). Un hit ->
; clr AABB.p de l'adversaire (le joueur detecte sa mort, l'arme se stoppe).
; ===========================================================================
        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/explosion/explosion.const.asm"
        INCLUDE "./objects/enemies_properties.asm"

TM_N     equ 19
TM_SLICE equ 128                     ; octets buffer par element (max saved ~103)
TM_NCELL equ TM_N*2                  ; cellules engine (128 o = 2 cellules/element)
TM_BOXW  equ 8                       ; bbox PETITE : la box sert juste a la detection
TM_BOXH  equ 8                       ; de changement (refresh) + in-range ; le draw/erase
                                     ; custom couvrent le vrai cluster (plus large que l'ecran)
TM_CENT  equ 2                       ; image_center_offset des tails
TM_ST    equ 18                      ; octets d'etat par tail

; --- layout record d'etat (Y-relatif), 18 o ---
TS_XHI   equ 0                       ; x_pos int (hi)
TS_XLO   equ 1                       ; x_pos int (lo)   [XLO:XSUB] = mot fraction basse
TS_XSUB  equ 2                       ; x sous-pixel
TS_YHI   equ 3                       ; y_pos int (hi)
TS_YLO   equ 4                       ; y_pos int (lo)
TS_YSUB  equ 5                       ; y sous-pixel
TS_XVHI  equ 6                       ; x_vel 8.8 (hi)
TS_XVLO  equ 7
TS_YVHI  equ 8                       ; y_vel 8.8 (hi)
TS_YVLO  equ 9
TS_ANHI  equ 10                      ; anim ptr courant
TS_ANLO  equ 11
TS_PANHI equ 12                      ; prev_anim (base script, constant)
TS_PANLO equ 13
TS_AFR   equ 14                      ; anim_frame
TS_IMG   equ 15                      ; img 0..3
TS_RTN   equ 16                      ; etat : 1=Run 2=WaitEndStage 3=Explode 4=Deleted
TS_EXPD  equ 17                      ; explodeDelay (compte a rebours avant explosion)

Object
        lda   routine,u
        beq   Init
        jmp   Run

Init
        _GetCartPageA
        ldb   id,u
        ldx   #Img_Page_Index
        sta   b,x
        sta   TMMf
        sta   TMMf+3
        ldd   #TMImg
        std   image_set,u
        lda   #120                   ; ancre ecran de la bbox master (cluster tail)
        sta   x_pixel,u
        lda   #135
        sta   y_pixel,u
        ldb   #4                     ; priorite d'affichage des tails d'origine
        stb   priority,u
        lda   #render_hide_mask      ; cache jusqu'a Run (evite draw avant setup)
        sta   render_flags,u

        ; --- init des 19 records d'etat depuis le preset data_143AC ---
        ldx   #data_143AC            ; preset : 5 o/tail {x_off,y_off,img,anim(2)}
        ldy   #TMState
        clr   TMi
@iloop
        clra
        ldb   ,x                     ; x_off
        addd  glb_camera_x_pos       ; -> x_pos playfield (int)
        std   TS_XHI,y
        clr   TS_XSUB,y
        clra
        ldb   1,x                    ; y_off
        std   TS_YHI,y               ; y_hi=0
        clr   TS_YSUB,y
        clr   TS_XVHI,y              ; vel = 0
        clr   TS_XVLO,y
        clr   TS_YVHI,y
        clr   TS_YVLO,y
        ldd   3,x                    ; script ptr
        std   TS_ANHI,y              ; anim
        std   TS_PANHI,y             ; prev_anim (base)
        lda   #$20
        sta   TS_AFR,y               ; anim_frame initial
        ldb   2,x                    ; img preset 0,2,4,6
        lsrb                         ; -> 0,1,2,3
        stb   TS_IMG,y
        lda   #1
        sta   TS_RTN,y               ; etat initial = Run
        lda   TMi                    ; explodeDelay = 20 + 4*index (staggered)
        lsla
        lsla
        adda  #20
        sta   TS_EXPD,y
        leax  5,x
        leay  TM_ST,y
        inc   TMi
        lda   TMi
        cmpa  #TM_N
        blo   @iloop

        lda   #1
        sta   routine,u
        jmp   DisplaySprite

Run
        clr   render_flags,u         ; bg-erase, coords ecran, visible
        lda   TMcolPhase             ; alternance arcade : trame paire = elements
        eora  #1                     ; pairs (10), trame impaire = impairs (9) ->
        sta   TMcolPhase             ; les 19 couverts en 2 trames
        jsr   TailUpdateAll          ; anime les 19, remplit TMPos, cull les hors-champ,
                                     ; et met a jour la BOX du master = bbox des tails
                                     ; VISIBLES. Cette box couvre les tails -> l'overlap
                                     ; co-refresh (CSR_SubEraseSpriteSearchInit) rafraichit
                                     ; le master quand un sprite mobile passe dessus.
        jmp   DisplaySprite

; ===========================================================================
; TailUpdateAll - porte 1:1 le fonctionnement de tail.asm pour les 19 tails :
; boss-follow (glissement partage), gating moveAlienStart, bossDefeated/hold,
; Explode (spawn explosion + suppression), et l'animation (scripts velocite
; avec rattrapage frameDrop). Calcule les coords ecran dans TMPos et le drapeau
; de visibilite TMalive. Preserve U (OST master).
; ===========================================================================
TailUpdateAll
        ; --- nb de pas d'anim (rattrapage frame-drop) ---
        ldd   gfxlock.frameDrop.count_w
        bne   >
        ldd   #1                     ; au moins 1 pas d'anim
!       std   TMnf
        ; NB : le master NE calcule PAS le glissement (pas de jsr followDobkeratops :
        ; effet global qui perturbe la garde de trame partagee du boss -> flicker).
        ; Le corps du boss (monster/jaw/obj) calcule move.step ; on ne fait que le LIRE.
        lda   #255                   ; bbox des tails visibles (min x/y init 255, max init 0)
        sta   TMbxmin
        sta   TMbymin
        clr   TMbxmax
        clr   TMbymax
        clr   TMdead                 ; compte des tails supprimees (cleanup master)
        clr   TMi
        ldy   #TMState
@loop
        lda   TS_RTN,y
        cmpa  #4
        lbeq  @dead                  ; deja supprimee : juste non-visible
        cmpa  #3
        lbeq  @explode
        ; --- Run(1) / WaitEndStage(2) ---
        lda   globals.bossDefeated
        beq   @alive
        ; boss vaincu -> WaitEndStage : gele, ou Explode si demande
        lda   #2
        sta   TS_RTN,y
        lda   main.dobkeratops.explode
        beq   @live                  ; @hold : fige, encore visible
        lda   #3
        sta   TS_RTN,y               ; -> Explode
        lbra  @live                  ; visible cette trame, fige
@alive
        ; boss vivant : applique le glissement partage (move.step, LU depuis l'etat
        ; calcule par le corps du boss) puis l'animation. 0 hors phase de glissement.
        ldd   main.dobkeratops.move.step
        beq   @wiggle
        _negd                        ; x_pos -= move.step (comme followDobkeratops @apply)
        addd  TS_XLO,y
        std   TS_XLO,y
        lda   TS_XHI,y
        adca  #-1
        sta   TS_XHI,y
        ldd   main.dobkeratops.move.left ; butee atteinte ? -> WaitEndStage
        bne   @wiggle
        lda   #2
        sta   TS_RTN,y
@wiggle
        ; --- animation : TMnf pas (rattrapage frame-drop) ---
        ldx   TMnf
@step
        pshs  x
        ldd   TS_XVHI,y              ; x_pos += x_vel (signe 24 bits)
        addd  TS_XLO,y
        std   TS_XLO,y
        lda   TS_XHI,y
        ldb   TS_XVHI,y
        bmi   @xneg
        adca  #0
        bra   @xdone
@xneg   adca  #$FF
@xdone  sta   TS_XHI,y
        ldd   TS_YVHI,y             ; y_pos += y_vel
        addd  TS_YLO,y
        std   TS_YLO,y
        lda   TS_YHI,y
        ldb   TS_YVHI,y
        bmi   @yneg
        adca  #0
        bra   @ydone
@yneg   adca  #$FF
@ydone  sta   TS_YHI,y
        dec   TS_AFR,y             ; avance du script d'animation
        bne   @noadv
        lda   #$10
        sta   TS_AFR,y
        ldx   TS_ANHI,y
        lda   ,x
        cmpa  #$80                  ; marqueur fin -> boucle sur la base
        bne   @nores
        ldx   TS_PANHI,y
@nores  ldd   ,x                    ; x_vel
        std   TS_XVHI,y
        ldd   2,x                   ; y_vel
        std   TS_YVHI,y
        leax  4,x
        stx   TS_ANHI,y
@noadv
        puls  x
        leax  -1,x
        bne   @step
@live
        ; --- coords ecran -> TMPos[TMi] + visible=1 ---
        ; x_pixel = (x_pos - camera_x) + glb_camera_x_offset  (screen_left=48)
        ; y_pixel = (y_pos - camera_y) + glb_camera_y_offset  (screen_top=28)
        ; MEME transposition que l'engine (CheckSpritesRefresh, mode bg-erase).
        ldd   TS_XHI,y
        subd  glb_camera_x_pos
        stb   TMccx                  ; cx collision (coords camera, SANS +48 - cf tail.asm @end)
        addb  glb_camera_x_offset+1
        stb   TMtx
        ldd   TS_YHI,y
        subd  glb_camera_y_pos
        stb   TMccy                  ; cy collision (SANS +28)
        addb  glb_camera_y_offset+1
        stb   TMty
        ; --- collision : TOUS les elements portent une hitbox, testes un sur
        ; deux en alternance par trame (pairs puis impairs, arcade-style) ---
        lda   TMi
        anda  #1
        cmpa  TMcolPhase
        bne   @nocol
        jsr   TM_Collide             ; teste listes player+friend, clr p si hit
@nocol
        ; --- stocke TMPos[TMi] (x,y,img) ---
        lda   TMi
        ldb   #3
        mul
        ldx   #TMPos
        leax  d,x
        ldb   TMtx
        stb   ,x
        ldb   TMty
        stb   1,x
        ldb   TS_IMG,y
        stb   2,x
        ; --- on-screen ? (tail 6px + center 2 : x_pixel dans [50,203]) ---
        ldb   TMi
        ldx   #TMalive
        lda   TMtx
        cmpa  #50
        blo   @cull
        cmpa  #203
        bhi   @cull
        ; visible : TMalive=1 + maj bbox (min/max x et y)
        lda   #1
        sta   b,x
        lda   TMtx
        cmpa  TMbxmin
        bhs   >
        sta   TMbxmin
!       cmpa  TMbxmax
        bls   >
        sta   TMbxmax
!       lda   TMty
        cmpa  TMbymin
        bhs   >
        sta   TMbymin
!       cmpa  TMbymax
        bls   >
        sta   TMbymax
!       lbra  @next
@cull
        clr   b,x                    ; hors-champ : culled (TailDrawAll sautera)
        lbra  @next
@explode
        ; --- Explode : compte a rebours explodeDelay ---
        lda   TS_EXPD,y
        bmi   @doExplode
        suba  gfxlock.frameDrop.count
        sta   TS_EXPD,y
        lbra  @live                  ; encore visible, fige
@doExplode
        ; spawn explosion (collision RemoveAABB DEFEREE) + marque supprimee
        pshs  y
        jsr   LoadObject_x           ; X = nouvel OST (ou beq si pool plein)
        beq   @noexp
        _ldd  ObjID_explosion,explosion.subtype.smallx2
        std   id,x                   ; id + subtype
        ldy   ,s                     ; state ptr (sans depiler)
        ldd   TS_XHI,y
        std   x_pos,x
        ldd   TS_YHI,y
        std   y_pos,x
@noexp  puls  y
        lda   #4
        sta   TS_RTN,y               ; -> supprimee
@dead
        inc   TMdead
        ldb   TMi
        ldx   #TMalive
        clr   b,x                    ; non-visible
@next
        leay  TM_ST,y
        inc   TMi
        lda   TMi
        cmpa  #TM_N
        lbne  @loop
        ; --- cleanup : toutes les tails supprimees -> suppression du master
        ; (l'engine efface et libere le slot via render_todelete, comme le
        ; DeleteObject des tails d'origine) ---
        lda   TMdead
        cmpa  #TM_N
        bne   >
        lda   render_flags,u
        ora   #render_todelete_mask
        sta   render_flags,u
!
        ; --- box du master = bbox des tails visibles (U = OST master) ---
        ; clampee in-range par construction (visibles => x dans [50,203]).
        ; x_pixel=minx-2 (center), BOXW=maxx-minx+6 ; y_pixel=miny, BOXH=maxy-miny+12.
        ; TMImg+4/+5 = x_size/y_size (auto-modifies pour l'out-of-range + overlap).
        lda   TMbxmin
        cmpa  #255                   ; aucun tail visible ?
        beq   @nobox
        suba  #2
        sta   x_pixel,u
        lda   TMbxmax
        suba  TMbxmin
        adda  #6
        sta   TMImg+image_x_size
        lda   TMbymin
        sta   y_pixel,u
        lda   TMbymax
        suba  TMbymin
        adda  #12
        sta   TMImg+image_y_size
        rts
@nobox
        lda   #100                   ; defaut in-range (rien de visible)
        sta   x_pixel,u
        sta   y_pixel,u
        lda   #4
        sta   TMImg+image_x_size
        sta   TMImg+image_y_size
        rts

; ===========================================================================
; TM_Collide - teste la tail courante (TMccx/TMccy, boite invincible p=-128,
; rx=dobkeratops_tail_hitbox_x, ry=..._y) contre AABB_list_player puis
; AABB_list_friend (armes). Duplication fidele de l'algo Collision_Do :
; |cx1-cx2| <= rx1+rx2 (test non-signe via asla/sta/asra + cmp auto-modifie).
; Semantique boite invincible : l'adversaire perd -> clr AABB.p (le joueur
; detecte p=0 -> mort ; l'arme detecte p=0 -> se stoppe), SAUF s'il est
; lui-meme invincible (p<0 : aucun changement) ou desactive (p=0).
; Pas d'AABB stockee ni Add/Remove : zero etat, zero maj cx/cy par trame.
; Preserve Y (state ptr) et U (OST master). Clobbe D,X.
; ===========================================================================
TM_Collide
        ldx   AABB_list_player       ; tete de liste (0 si vide)
        beq   >
        bsr   TM_ColScan
!       ldx   AABB_list_friend
        beq   >
        bsr   TM_ColScan
!       rts

TM_ColScan
@loop
        ldb   AABB.p,x
        beq   @next                  ; boite desactivee
        bmi   @next                  ; invincible vs invincible : aucun changement
        lda   #dobkeratops_tail_hitbox_x
        adda  AABB.rx,x
        asla
        sta   @rx
        asra
        adda  TMccx
        suba  AABB.cx,x
        cmpa  #0
@rx     equ *-1
        bhi   @next
        lda   #dobkeratops_tail_hitbox_y
        adda  AABB.ry,x
        asla
        sta   @ry
        asra
        adda  TMccy
        suba  AABB.cy,x
        cmpa  #0
@ry     equ *-1
        bhi   @next
        clr   AABB.p,x               ; hit : l'adversaire perd (tail invincible)
@next
        ldx   AABB.next,x
        bne   @loop
        rts

; --- image-set fabrique : bg-erase -> parites {0,2} (B0,B1) ---
TMImg
        fcb   TMSub-TMImg,TMSub-TMImg,TMSub-TMImg,TMSub-TMImg
        fcb   TM_BOXW,TM_BOXH,0
TMSub
        fcb   TMMf-TMSub             ; [0] B0
        fcb   0                      ; [1] D0
        fcb   TMMf-TMSub             ; [2] B1
        fcb   0                      ; [3] D1
        fcb   0,0                    ; x1,y1 off
TMMf
        fcb   0                      ; page_draw (patche)
        fdb   TailDrawAll
        fcb   0                      ; page_erase (patche)
        fdb   TailEraseAll
        fcb   TM_NCELL               ; erase_nb_cell : tas cellules engine

; ===========================================================================
; TailDrawAll - appele par DrawSprites. Saute les tails supprimees (TMalive=0)
; en effacant leur record pour stopper l'erase.
; ===========================================================================
TailDrawAll
        sty   TMcellY               ; Y = haut region cellules (BgBufferAlloc)
        jsr   TM_BufOff
        clr   TMi
@loop
        ldb   TMi                    ; tail visible ?
        ldx   #TMalive
        lda   b,x
        bne   @draw
        jsr   TM_RecPtr              ; supprimee : efface le record (stoppe l'erase)
        ldd   #0
        std   ,x
        lbra  @next
@draw
        ; --- pointeur position table[TMi] ---
        lda   TMi
        ldb   #3
        mul
        ldx   #TMPos
        leax  d,x                    ; X -> [x_pixel,y_pixel,img]
        ; --- index dispatch = img*4 + parite*2 (parite = x&1) ---
        ldb   2,x
        lslb
        lslb
        lda   ,x
        anda  #1
        beq   >
        addb  #2
!       stb   TMidx
        ; --- adresse ecran ---
        lda   ,x
        suba  #TM_CENT
        ldb   1,x
        pshs  x
        jsr   DRS_XYToAddress        ; -> glb_screen_location_2/1
        puls  x
        ; --- Y = haut du slice buffer de l'element TMi ---
        jsr   TM_SlicePtr            ; Y = buffer_top[buf][TMi]
        ; --- appel BCKDRAW (Y=buffer, U=ecran) -> U=bgdata ---
        ldu   <glb_screen_location_2
        ldx   #TMDrawTab
        ldb   TMidx
        ldx   b,x
        jsr   ,x                     ; clobbe tout, retourne U=bgdata
        ; --- stocke bgdata + erase_rtn de l'element TMi ---
        jsr   TM_RecPtr              ; X = &record[buf][TMi] (4 o : bgdata,erase)
        stu   ,x                     ; bgdata
        ldu   #TMEraseTab
        ldb   TMidx
        ldu   b,u
        stu   2,x                    ; erase_rtn
@next
        inc   TMi
        lda   TMi
        cmpa  #TM_N
        lblo  @loop
        ; U pour le free engine : bas de region +16 (l'engine fait -16 puis
        ; arrondit a la cellule -> retombe sur cell_start aligne)
        ldd   TMcellY
        subd  #TM_N*TM_SLICE-16
        tfr   d,u
        rts

; ===========================================================================
; TailEraseAll - appele par EraseSprites. Restaure les 19 en ORDRE INVERSE.
; CONTRAT ENGINE : a l'entree U = rsv_bgdata (= TMcellY - (TM_N*TM_SLICE-16),
; la valeur retournee par TailDrawAll) ; en SORTIE il faut retourner U = cell_end
; (= TMcellY) pour BgBufferFree (EraseSprites: stu BBF_cell_end). On NE PEUT PAS
; deduire cell_end du dernier blit d'erase : avec le culling, le tail 0 (slice du
; haut = cell_end) peut etre culled -> U perime -> free-list de cellules corrompue
; -> BgBufferAlloc echoue -> plus aucun tail affiche. On recalcule cell_end depuis
; l'U d'entree, independamment du culling.
; ===========================================================================
TailEraseAll
        stu   TMeraseU             ; sauve rsv_bgdata (U d'entree)
        jsr   TM_BufOff             ; buffer courant (erase tourne AVANT le draw !)
        lda   #TM_N-1
        sta   TMi
@loop
        jsr   TM_RecPtr              ; X = &record[buf][TMi]
        ldu   ,x                     ; bgdata
        beq   @next
        ldx   2,x                    ; erase_rtn
        jsr   ,x                     ; U=bgdata -> restaure
@next
        dec   TMi
        bpl   @loop
        ldd   TMeraseU               ; U = cell_end = rsv_bgdata + (TM_N*TM_SLICE-16)
        addd  #TM_N*TM_SLICE-16      ; = TMcellY (independant du culling)
        tfr   d,u
        rts

; --- helpers (etat sur la page) ------------------------------------------
; TM_BufOff : selectionne le buffer courant (double buffer gfxlock)
TM_BufOff
        clr   TMbufsel
        lda   gfxlock.backBuffer.id
        beq   >
        lda   #1
        sta   TMbufsel
!       rts

; TM_SlicePtr : Y = TMcellY - TMi*SLICE (haut du slice de l'element, tas engine)
TM_SlicePtr
        lda   TMi
        ldb   #TM_SLICE
        mul                          ; D = TMi*SLICE
        pshs  d
        ldd   TMcellY
        subd  ,s++
        tfr   d,y
        rts

; TM_RecPtr : X = TMRec + bufsel*(N*4) + TMi*4
TM_RecPtr
        lda   TMi
        ldb   #4
        mul
        addd  #TMRec
        tst   TMbufsel
        beq   >
        addd  #TM_N*4
!       tfr   d,x
        rts

; --- data / buffers sur la page ------------------------------------------
TMi        fcb 0
TMidx      fcb 0
TMbufsel   fcb 0
TMbxmin    fcb 0
TMbxmax    fcb 0
TMbymin    fcb 0
TMbymax    fcb 0
TMccx      fcb 0
TMccy      fcb 0
TMcolPhase fcb 0
TMdead     fcb 0
TMtx       fcb 0
TMty       fcb 0
TMcellY    fdb 0
TMeraseU   fdb 0
TMnf       fdb 0

TMalive    fill 0,TM_N              ; 19 x drapeau visible (1) / supprimee (0)
TMPos      fill 0,3*TM_N            ; 19 x [x_pixel, y_pixel, img] (calcule par Run)
TMState    fill 0,TM_ST*TM_N        ; 19 x etat complet (18 o)
TMRec      fill 0,2*TM_N*4          ; records [bgdata(2),erase_rtn(2)] x 19 x 2 buffers

        INCLUDE "./objects/enemies/dobkeratops/tail_animation.asm"
        INCLUDE "./objects/enemies/dobkeratops/tailmgr_blits.asm"
