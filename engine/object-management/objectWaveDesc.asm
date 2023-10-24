* ---------------------------------------------------------------------------
* ObjectWave
* ----------
* Routine to instanciate objects based on a 16bit meter
* expected data sequence :
* AAAA (time meter) BB (id objet) CC (subtype) DDDD (x_pos) EEEE (y_pos) 
* end marker : 0
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
!       ldd   ,y                       
        beq   @rts                     ; end marker found
        cmpx  ,y
        bhi   @rts
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
; input  REG : [A] data page
; input  REG : [Y] data address
; input  REG : [X] time
; -----------------------------------------------------------------------------
; move to desired position in wave
; -----------------------------------------------------------------------------
objectWave.init
        sta   objectWave.data.page
        _SetCartPageA
        sty   objectWave.data.address
!       cmpx  ,y
        bhi   @end
        leay  8,y
        bra   <
@end    sty   objectWave.data.cursor
        rts

objectWave.data.address fdb 0