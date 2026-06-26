terrainCollision.sensor.x fdb 0
terrainCollision.sensor.y fdb 0
terrainCollision.impact.x fdb 0

; --- background lookup boss-follow offset (loadMap) ---
; while the camera/foreground scroll is held during the boss advance, the BACKGROUND
; collision (boss solid silhouette) is shifted right by the boss travel so it tracks
; the moving boss. 0 the rest of the time -> no effect. Set by main.followDobkeratops.
terrainCollision.bgFlag     fcb 0   ; 0 = background lookup, 2 = foreground (set per loadMap call)
terrainCollision.bgByteOff  fcb 0   ; boss advance, whole map bytes (24px each)
terrainCollision.bgBitShift fcb 0   ; boss advance, sub-byte tiles (0..7, 3px each)
terrainCollision.bgColTmp   fcb 0   ; loadMap scratch (column carry during the bit shift)

terrainCollision.do
        _GetCartPageA
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
        _GetCartPageA
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
        _GetCartPageA
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

