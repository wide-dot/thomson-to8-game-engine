        setdp   dp/256


HudUpdate
        ldd   #$C6C2
        std   glb_screen_location_1
        ldd   #$A6C1
        std   glb_screen_location_2
        ldb   #3   ; nb digits
        ldu   glb_angle
        jmp   DisplayDigit

        INCLUDE "./objects/hud/number/digit-counter.asm"