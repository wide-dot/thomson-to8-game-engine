; ---------------------------------------------------------------------------
; Subroutine to calculate sine and cosine of an angle
; b = input byte = angle (360 degrees == 256)
; d = output word = 255 * sine(angle)
; x = output word = 255 * cosine(angle)
; ---------------------------------------------------------------------------

CalcSine
        ldx   #Sine_Data
        anda  #0
        aslb
        rola
        leax  d,x
        ldd   ,x     ; sin
        leax  $80,x
        ldx   ,x     ; cos
        rts

Sine_Data
        INCLUDEBIN "./engine/math/sinewave.bin"     