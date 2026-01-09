terrainCollision.sensor.x fdb 0
terrainCollision.sensor.y fdb 0
terrainCollision.impact.x fdb 0

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

