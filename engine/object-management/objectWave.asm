* ---------------------------------------------------------------------------
* ObjectWave
* ----------
* Routine to instanciate objects based on a 16bit meter
* expected data sequence :
* AAAA (time meter) BB (id objet) CC (subtype) DDDD (x_pos) EEEE (y_pos) 
* end marker : $FFFF
* ---------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; objectWave.do
; -----------------------------------------------------------------------------
; input  REG : [X] time
; -----------------------------------------------------------------------------
; load objects when time is elapsed
; -----------------------------------------------------------------------------
objectWave.do
        lda   #0
objectWave.data.page equ *-1           ; wave data page
        _SetCartPageA
        ldy   #0
objectWave.data.cursor equ *-2         ; current position in wave data
!       cmpx  ,y
        blo   @rts
        pshs  x,y
        jsr   LoadObject_u
        puls  x,y                      ; puls does not change zero
        beq   @bypass
        ldd   2,y
        std   id,u                     ; and subtype,u
        ldd   4,y
        std   x_pos,u
        ldd   6,y
        std   y_pos,u
@bypass leay  8,y
        bra   <
@rts    sty   objectWave.data.cursor
        rts

; -----------------------------------------------------------------------------
; objectWave.init
; -----------------------------------------------------------------------------
; input  REG : [X] time
; -----------------------------------------------------------------------------
; move to desired position in wave
; -----------------------------------------------------------------------------
objectWave.init
        pshs  a,x,y
        lda   objectWave.data.page
        _SetCartPageA
        ldy   objectWave.data.address
!       cmpx  ,y
        blo   @end
        leay  8,y
        bra   <
@end    sty   objectWave.data.cursor
        puls  a,x,y,pc

objectWave.data.address fdb 0