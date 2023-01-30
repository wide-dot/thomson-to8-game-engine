	opt   c,ct
	INCLUDE "./generated-code/game/FD/main.glb"
	org   $0000
	setdp $FF

        INCLUDE "./engine/macros.asm"   
        SETDP   dp/256

; *****************************************************************************

_DrawTextSetPos MACRO
        ; param 1 : col number (0-39)
        ; param 2 : line number
        ; param 3 : pixels between lines
        ldd   #$C000+\1+\2*(\3*40)
 ENDM

; *****************************************************************************

Text
        lda   routine,u
        asla
        ldx   #Text_Routines
        jmp   [a,x]

Text_Routines
        fdb   Text_Init
        fdb   Text_Main

Text_Init    
        inc   routine,u
        lda   #24
        sta   Current_Selection

        ldd   #Text_0A
        std   DrawText_0A
        ldd   #Text_0C
        std   DrawText_0C
        ldd   #Text_0D
        std   DrawText_0D

        lda   #7
        sta   line_height

Text_Main

 ; draw sound value
 ; ****************
        _DrawTextSetPos 8,16,6
        std   DrawText_pos
        ldx   #TextSong
        lda   Sound_test_sound
        asla
        ldy   a,x
        ldx   #fnt_4x6_shd
        jsr   DrawText
        rts

 ; ascii routines
 ; **************

Text_0A 
        lda   #0
line_height equ *-1
        ldb   #40
        mul
        addd  DrawText_pos
        std   DrawText_pos
        std   line_start
        rts

Text_0C
        ldd   #0
ff_pos  equ *-2
        std   DrawText_pos
        std   line_start
        rts

Text_0D
        ldd   #0
line_start equ *-2
        std   DrawText_pos
        rts

render_line       fcb   0

TextSong
        fdb   Txt_01
        fdb   Txt_02
        fdb   Txt_03
        fdb   Txt_04

Txt_01        fcc   "< MAGICAL SOUND SHOWER >"
              fcb   $D,$A,0
Txt_02        fcc   "< PASSING BREEZE       >"
              fcb   $D,$A,0
Txt_03        fcc   "< SPLASH WAVE          >"
              fcb   $D,$A,0
Txt_04        fcc   "< LAST WAVE            >"
              fcb   $D,$A,0

 INCLUDE "./engine/graphics/font/DrawText/DrawText.asm"
 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded/asm/font_upper.asm"
