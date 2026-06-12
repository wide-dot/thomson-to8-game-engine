; ------ interrupt-handling.asm ------
; From: r-type game engine
; Example: How to handle interrupts (timer, keyboard, joystick)
;
; Dependencies: irq subsystem

; Register an interrupt handler
; Input: A = interrupt type, X = handler function address
register-irq-handler:
    jsr irq:register-handler
    rts

; Disable interrupts (critical section)
disable-irqs:
    orcc #$10            ; Set interrupt mask
    rts

; Enable interrupts
enable-irqs:
    andcc #$ef           ; Clear interrupt mask
    rts

; See full context: game-projects/r-type/irq module
