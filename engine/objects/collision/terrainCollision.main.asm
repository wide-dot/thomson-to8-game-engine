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

terrainCollision.xAxis.do
        _GetCartPageA
        sta   @page
        lda   #0
terrainCollision.main.xAxis.page equ *-1
        _SetCartPageA
        jsr   >0
terrainCollision.main.xAxis.address equ *-2
        lda   #0
@page   equ *-1
        _SetCartPageA
        rts
