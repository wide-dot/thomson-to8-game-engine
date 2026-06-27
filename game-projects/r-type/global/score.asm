* ---------------------------------------------------------------------------
* Score system (arcade-equivalent: reward index -> value table -> capped add)
* globals.score is 24-bit, unit = 100 points, cap 99999 ($01869F = 9 999 900).
* scoreTable values are the arcade score_rewards_table / 100.
* ---------------------------------------------------------------------------
scoreTable
        fdb   1,2,3,4,5,6,7,8,10,15,20,50,80,100,150 ; idx 0..14 (100..15000 pts)

; AwardScore - add reward scoreTable[B] to globals.score, capped at 99999.
; INPUT  : B = reward index (0..14)
; CLOBBERS: A,B,X,CC
AwardScore
        pshs  d,x                     ; transparent : preserve caller's D et X (CC clobbered)
        aslb                          ; index*2 (word table)
        ldx   #scoreTable
        ldd   b,x                     ; D = reward (in hundreds)
        addd  globals.score+1         ; + low 16 bits
        std   globals.score+1
        bcc   >
        inc   globals.score           ; carry -> MSB
!       lda   globals.score           ; --- cap at 99999 = $01_869F ---
        cmpa  #1
        blo   @done                   ; MSB 0 -> below cap
        bne   @clamp                  ; MSB >=2 -> over cap
        ldd   globals.score+1
        cmpd  #$869F
        bls   @done
@clamp  lda   #1
        sta   globals.score
        ldd   #$869F
        std   globals.score+1
@done   puls  d,x,pc                  ; restore D,X et return
