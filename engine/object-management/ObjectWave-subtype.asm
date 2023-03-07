* ---------------------------------------------------------------------------
* ObjectWaveSimple
* ----------------
* Routine to instanciate objects based on a 16bit meter
* expected data sequence :
* AAAA (timestamp) BB (id objet) CC (subtype)
* end marker : $FFFF
*
* store missed frames to anim_frame_duration value
* ---------------------------------------------------------------------------

ObjectWave
        lda   #0
object_wave_data_page equ *-1          ; wave data page
        _SetCartPageA
        ldy   #0
object_wave_data equ *-2               ; current position in wave data
        ldx   Vint_runcount
!       cmpx  ,y
        blo   @rts
        pshs  x,y
        jsr   LoadObject_u
        puls  x,y                      ; puls does not change zero
        beq   @bypass
        ldd   2,y
        std   id,u                     ; and subtype,u
        ldd   ,y
        subd  Vint_runcount
        stb   anim_frame_duration,u
@bypass leay  4,y
        bra   <
@rts    sty   object_wave_data
        rts

ObjectWave_Init
        pshs  a,x,y
        lda   object_wave_data_page
        _SetCartPageA
        ldy   object_wave_data_start
        ldx   Vint_runcount
!       cmpx  ,y
        blo   @end
        leay  4,y
        bra   <
@end    sty   object_wave_data
        puls  a,x,y,pc

object_wave_data_start fdb 0