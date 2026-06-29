terrainCollision.sensor.x fdb 0
terrainCollision.sensor.y fdb 0
terrainCollision.impact.x fdb 0

; --- terrain "efface" : court-circuite toutes les requetes de collision ---
; quand != 0, .do renvoie B=0 (aucun mur) et .xAxis renvoie impact.x=0 (sentinelle
; "pas de mur", identique au cas "aucune tuile solide" de l'impl) -> tout le jeu
; (force pod, armes, vaisseau) joue son code normal libere du terrain, comme si le
; tilemap etait vide. Pose par le jeu a la mort du boss (cf MonsterKill), remis a 0
; au debut de niveau (cf obj_endstage INIT). Simule le nettoyage arcade des tilemaps.
terrainCollision.disabled fcb 0

; --- background lookup boss-follow offset (loadMap) ---
; while the camera/foreground scroll is held during the boss advance, the BACKGROUND
; collision (boss solid silhouette) is shifted right by the boss travel so it tracks
; the moving boss. 0 the rest of the time -> no effect. Set by main.followDobkeratops.
terrainCollision.bgFlag     fcb 0   ; 0 = background lookup, 2 = foreground (set per loadMap call)
terrainCollision.bgByteOff  fcb 0   ; boss advance, whole map bytes (24px each)
terrainCollision.bgBitShift fcb 0   ; boss advance, sub-byte tiles (0..7, 3px each)
terrainCollision.bgColTmp   fcb 0   ; loadMap scratch (column carry during the bit shift)

terrainCollision.do
        lda   terrainCollision.disabled    ; tilemap "efface" (boss tue) ?
        beq   @active
        clrb                               ; -> aucune collision (B=0)
        rts
@active _GetCartPageA
        sta   @page
        lda   #0
terrainCollision.main.page equ *-1
        _SetCartPageA
        jsr   >0
terrainCollision.main.address equ *-2
        lda   #0
@page   equ *-1
        _SetCartPageA
        rts

terrainCollision.xAxis.doRight
        lda   terrainCollision.disabled    ; tilemap "efface" (boss tue) ?
        beq   @active
        ldd   #0                           ; -> pas de mur (impact.x=0, cf @noImpact impl)
        std   terrainCollision.impact.x
        rts
@active _GetCartPageA
        sta   @page
        lda   #0
terrainCollision.main.xAxis.doRight.page equ *-1
        _SetCartPageA
        jsr   >0
terrainCollision.main.xAxis.doRight.address equ *-2
        lda   #0
@page   equ *-1
        _SetCartPageA
        rts

terrainCollision.xAxis.doLeft
        lda   terrainCollision.disabled    ; tilemap "efface" (boss tue) ?
        beq   @active
        ldd   #0                           ; -> pas de mur (impact.x=0, cf @noImpact impl)
        std   terrainCollision.impact.x
        rts
@active _GetCartPageA
        sta   @page
        lda   #0
terrainCollision.main.xAxis.doLeft.page equ *-1
        _SetCartPageA
        jsr   >0
terrainCollision.main.xAxis.doLeft.address equ *-2
        lda   #0
@page   equ *-1
        _SetCartPageA
        rts

terrainCollision.update
        sta   @a
        _GetCartPageA
        sta   @page
        lda   #0
terrainCollision.main.update.page equ *-1
        _SetCartPageA
        lda   #0
@a   equ *-1
        jsr   >0
terrainCollision.main.update.address equ *-2
        lda   #0
@page   equ *-1
        _SetCartPageA
        rts

