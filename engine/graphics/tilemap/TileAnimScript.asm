; ===========================================================================
; ZONE ANIMATION SCRIPTS - TODO mettre dans une lib
;

ZACurIndex equ   0 ; current index in animation script
ZACurFrame equ   1 ; current frame in animation
ZADuration equ   2 ; remaining duration of current frame (20ms by step)
ZAMaxFrame equ   3 ; max index in animation script
ZASize     equ   4 ; size of this data structure
TileAnimScriptData
        fill  0,16*ZASize

TileAnimScriptInit
	stx   TileAnimScriptList
        ldu   #TileAnimScriptData
@loop	ldy   ,x++
        beq   @rts
        ldd   ,y                       ; load global frame duration, number of frames in animation
	bpl   @globalduration
        stb   ZAMaxFrame,u
        ldd   2,y
        incb
        std   ZACurFrame,u             ; and ZADuration
        bra   @common 
@globalduration
        inca
        std   ZADuration,u             ; and ZAMaxFrame
        lda   2,y
        sta   ZACurFrame,u
@common lda   #0
        sta   ZACurIndex,u
        leau  ZASize,u
        bra   @loop
@rts    rts

TileAnimScript
        ldx   #0                       ; (dynamic)
TileAnimScriptList equ *-2
        beq   @rts                     ; no animation script to process
        ldu   #TileAnimScriptData
@loop	ldy   ,x++                     ; process a script
        beq   @rts                     ; at the end of script list ?
        lda   ZADuration,u
        suba  Vint_Main_runcount       ; tick down animation frame in sync with elapsed 50hz IRQ
        bcs   @loadScript
        sta   ZADuration,u             ; animation is not over
        leau  ZASize,u
        bra   @loop
@loadScript
        sta   @delta                   ; report skipped frames to next one
        lda   ZACurIndex,u             ; animation frame is over, load next one
        inca  
        cmpa  ZAMaxFrame,u             ; at the end of script ?
        bne   @a                       ; if not continue
        lda   #0                       ; otherwise reset animation
@a      sta   ZACurIndex,u             ; save new index
        ldb   1,y
        stb   ZAMaxFrame,u
        ldb   ,y                       ; load global frame duration
	bpl   @globalduration
        asla                           ; 2 data bytes per index
        adda  #2                       ; skip header
        ldd   a,y
        bra   @b 
@globalduration
        adda  #2                       ; skip header
        lda   a,y
@b      subb  #0
@delta  equ   *-1
        std   ZACurFrame,u             ; and ZADuration
        leau  ZASize,u
        bra   @loop
@rts    rts

TileAnimRun
	ldb   a,x
        stb   $E7E6
        inca
        jmp   [a,x]
