; ------ fixed-point-math.asm ------
; From: r-type game engine
; Example: Fixed-point arithmetic for smooth movement and angles
;
; Dependencies: math subsystem

; Multiply two 16-bit numbers (fixed-point)
; Input: D = operand1, X = operand2
; Output: D = result (16-bit)
multiply-fixed:
    jsr math:multiply
    rts

; Divide two 16-bit numbers (fixed-point)
; Input: D = dividend, X = divisor
; Output: D = quotient, remainder in X
divide-fixed:
    jsr math:divide
    rts

; Calculate sine/cosine (lookup table based)
; Input: A = angle (0-255 maps to 0-360 degrees)
; Output: D = sin(angle) as fixed-point
sin-lookup:
    jsr math:sin
    rts

; See full context: game-projects/r-type/math module
