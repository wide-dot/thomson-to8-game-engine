        INCLUDE "./engine/macros.asm"

        ; register object wave
        ldd   #Level_data
        std   object_wave_data
        std   object_wave_data_start
        _GetCartPageA
        sta   object_wave_data_page
        rts

Level_data
        INCLUDE "./objects/levels/08/object-wave/object-wave-data.asm"