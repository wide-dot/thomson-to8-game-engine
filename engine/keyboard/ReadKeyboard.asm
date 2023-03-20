********************************************************************************
* Get Keyboard codes
*
********************************************************************************

Key_Press                   fcb   $00
Key_Held                    fcb   $00 

ReadKeyboard
        clrb
        stb   Key_Press
        jsr   KTST       ; was a key pressed ?
        bcc   @clearHeld ; no exit
        jsr   GETC       ; read new key code in b
        cmpb  Key_Held
        beq   @rts       ; return if key is already held, Press was cleared, but not Held
        stb   Key_Press  ; store new key for one main loop
@clearHeld
        stb   Key_Held   ; new key code was read
@rts    rts
