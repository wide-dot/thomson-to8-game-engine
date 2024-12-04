* ---------------------------------------------------------------------------
* ObjectWave-subtype
* ------------------
* Routine to instanciate objects based on a 16bit meter
* expected data sequence :
* AAAA (timestamp) BB (id objet) CCCC (subtype)
* end marker : $FFFF
*
* store missed frames to wave_frame_drop/anim_frame_duration value
* WARNING : subtype is stored as a 16 bit value, thus overlapping render_flags
* ---------
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* !!! YOU MUST READ subtype_w lower byte before setting the render_flags !!!
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* ---------------------------------------------------------------------------

ObjectWave
        lda   #0
object_wave_data_page equ *-1          ; wave data page
        _SetCartPageA
        ldy   #0
object_wave_data equ *-2               ; current position in wave data
        ldx   gfxlock.frame.count
!       cmpx  ,y
        blo   @rts
        pshs  x,y
        jsr   LoadObject_u
        puls  x,y                      ; puls does not change zero
        beq   @bypass
        lda   2,y
        sta   id,u
        ldd   3,y
        std   subtype_w,u
        ldd   gfxlock.frame.count
        subd  ,y
        stb   wave_frame_drop,u
@bypass leay  5,y
        bra   <
@rts    sty   object_wave_data
        rts

ObjectWave_Init
        pshs  a,x,y
        lda   object_wave_data_page
        _SetCartPageA
        ldy   object_wave_data_start
        ldx   gfxlock.frame.count
!       cmpx  ,y
        blo   @end
        leay  5,y
        bra   <
@end    sty   object_wave_data
        puls  a,x,y,pc

object_wave_data_start fdb 0