
; soundFX.curSound / newSound
; ---------------------------
; sound id:
; value between 0 and 127
; $FF = none
;
; priority:
; bits 0-6 = priority level (0-127)
; bit 7 ("lock") = if set, the sound cannot be overridden by another of equal priority.

soundFX.curSound   fdb $FF00 ; MSB: sound ID ($FF = none), LSB: priority (0:low, no lock)
soundFX.newSound   fdb $FF00 ; MSB: sound ID ($FF = none), LSB: priority (0:low, no lock)


