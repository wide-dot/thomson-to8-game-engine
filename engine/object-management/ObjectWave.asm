* ---------------------------------------------------------------------------
* ObjectWave
* ----------
* Routine to instanciate objects based on a 16bit meter
* expected data sequence :
* AAAA (timestamp) BB (id objet) CC (subtype) DDDD (x_pos) EEEE (y_pos) 
* end marker : $FFFF
* ---------------------------------------------------------------------------

ObjectWave
        lda   #0
object_wave_data_page equ *-1          ; wave data page
        _SetCartPageA
        ldy   #0
object_wave_data equ *-2               ; current position in wave data
        ldx   glb_camera_x_pos
!       cmpx  ,y
        bls   @rts
        pshs  x,y
        jsr   LoadObject_u
        puls  x,y
        ldd   2,y
        std   id,u                     ; and subtype,u
        ldd   4,y
        std   x_pos,u
        ldd   6,y
        std   y_pos,u
        leay  8,y
        bra   <
@rts    sty   object_wave_data
        rts