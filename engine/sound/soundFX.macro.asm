; -----------------------------------------------------------------------------
; _soundFX.play
; -----------------------------------------------------------------------------
; input : sound id, priority
; -----------------------------------------------------------------------------
_soundFX.play MACRO
        ; Check if the new sound request has a higher priority than the previous new sound request
	lda   soundFX.newSound+1
	anda  #$7f
	sta   @prevPri
        lda   #\2
        anda  #$7f
        cmpa  #0
@prevPri equ   *-1
        blo   @exit ; if the new sound has a lower priority, do nothing
        bhi   @set  ; if the new sound has a higher priority, set the new sound
        lda   soundFX.curSound+1
        bmi   @exit ; if same sound priority and current sound is locked, skip playing the new sound
@set    equ   *
	ldd   #((\1)*256)+\2
	std   soundFX.newSound
@exit   equ   *
 ENDM
 