********************************************************************************
* Direction History Buffer
* Keeps track of last 16 directional inputs in a circular buffer
* Buffer format: Each byte contains the directional input state
********************************************************************************

joypad.buffer.direction           fill  0,16     ; 16 bytes circular buffer for directions, initialized to 0
joypad.buffer.direction.write.ptr fcb   0        ; Current position in circular buffer (0-15)
joypad.buffer.direction.read.ptr  fcb   0        ; Read position in circular buffer (0-15)

* Add current direction to history buffer
* Uses: A, B, X registers
* Buffer position cycles using bitmask %00001111 (15 = 16-1)
joypad.buffer.addDirection
        ldx   #joypad.buffer.direction           ; Get buffer base address
        ldb   >joypad.buffer.direction.write.ptr ; Get current pointer position
        lda   $E7CC                              ; Read raw joypad direction data from hardware
	coma					 ; invert the data
        sta   b,x                                ; Store in buffer
        incb                                     ; Increment in B register
        andb  #%00001111                         ; Mask to keep value between 0-15
        stb   >joypad.buffer.direction.write.ptr ; Store masked value back
        rts

* Get next direction from history buffer
* Returns: A = next direction value or $FF if no more values
* Uses: A, B, X registers
joypad.buffer.getDirection
        ldb   >joypad.buffer.direction.read.ptr  ; Get read pointer
        cmpb  >joypad.buffer.direction.write.ptr ; Compare with write pointer
        beq   @no_more_values                    ; If equal, no more values to read
;
        ldx   #joypad.buffer.direction           ; Get buffer base address
        lda   b,x                                ; Load direction value
        incb                                     ; Increment read pointer
        andb  #%00001111                         ; Mask to keep between 0-15
        stb   >joypad.buffer.direction.read.ptr  ; Store new read position
        rts
;
@no_more_values
        lda   #$FF                               ; Load -1 (no more values)
        rts

