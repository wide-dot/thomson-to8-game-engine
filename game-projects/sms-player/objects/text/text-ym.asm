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

nbgames equ 4
nbsongs equ 31

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

        ldd   #Text_0A
        std   DrawText_0A
        ldd   #Text_0C
        std   DrawText_0C
        ldd   #Text_0D
        std   DrawText_0D

        lda   #7
        sta   line_height

Text_Main

        ldb   snd_tst_sel_type
        beq   >
        jsr   GameSelect
        bra   @exit
!       jsr   SongSelect
@exit

        _DrawTextSetPos 2,0,6
        std   DrawText_pos

        lda   #0
        ldb   snd_tst_sel_song
        ldx   #FirstSongIdx
@loop
        cmpb  a,x
        ble   @draw
        inca
        bra   @loop
@draw
        sta   snd_tst_sel_game
        ldb   Fire_Press
        bitb  #c_button_A_mask|c_button_B_mask
        beq   >
        sta   snd_tst_new_game
!       asla
        ldx   #Txt_Game
        ldy   a,x
        ldx   #fnt_4x6_shd
        jsr   DrawText

        _DrawTextSetPos 2,32,6
        std   DrawText_pos

        lda   snd_tst_sel_song
        asla
        ldx   #TxtLst_Song
        ldy   a,x
        ldx   #fnt_4x6_shd
        jsr   DrawText

        ldb   snd_tst_sel_type
        beq   >
        _DrawTextSetPos 0,0,6
        bra   @exit
!       _DrawTextSetPos 0,32,6
@exit
        std   DrawText_pos
        ldy   #Txt_Selector
        ldx   #fnt_4x6_shd_sel
        jsr   DrawText

        rts

; -------------------------------------

SongSelect
        lda   Dpad_Press
        ldb   snd_tst_sel_song
        bita  #c_button_left_mask
        beq   >
        decb
        bpl   >
        ldb   #nbsongs-1
!       bita  #c_button_right_mask
        beq   >
        incb
        cmpb  #nbsongs
        blo   >
        ldb   #0
!       stb   snd_tst_sel_song
        ldb   snd_tst_sel_type
        bita  #c_button_up_mask|c_button_down_mask
        beq   >
        comb
        stb   snd_tst_sel_type
!       lda   Fire_Press
        bita  #c_button_A_mask|c_button_B_mask
        beq   @rts
        ldb   snd_tst_sel_song
        stb   snd_tst_new_song
        ldb   #-1
        stb   snd_tst_cur_song
@rts    rts

GameSelect
        lda   Dpad_Press
        ldb   snd_tst_sel_game
        bita  #c_button_left_mask
        beq   >
        decb
        bpl   @apply
        ldb   #nbgames-1
        bra   @apply
!       bita  #c_button_right_mask
        beq   >
        incb
        cmpb  #nbgames
        blo   @apply
        ldb   #0
@apply  stb   snd_tst_sel_game
        ldx   #FirstSongStartIdx
        ldb   b,x
        stb   snd_tst_sel_song
!       ldb   snd_tst_sel_type
        bita  #c_button_up_mask|c_button_down_mask
        beq   >
        comb
        stb   snd_tst_sel_type
!       lda   Fire_Press
        bita  #c_button_A_mask|c_button_B_mask
        beq   @rts
        ldb   snd_tst_sel_song
        stb   snd_tst_new_song
        ldb   snd_tst_sel_game
        stb   snd_tst_new_game
        ldb   #-1
        stb   snd_tst_cur_song
@rts    rts

; -------------------------------------

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

; -------------------------------------

Txt_Game
        fdb   Txt_OutRun
        fdb   Txt_WBIII
        fdb   Txt_DD
        fdb   Txt_Ys

FirstSongStartIdx
        fcb   0
        fcb   4
        fcb   18
        fcb   20

FirstSongIdx
        fcb   3
        fcb   17
        fcb   19
        fcb   30

TxtLst_Song
        fdb   Txt_OutRun_01
        fdb   Txt_OutRun_02
        fdb   Txt_OutRun_03
        fdb   Txt_OutRun_04
        fdb   Txt_WBIII_01
        fdb   Txt_WBIII_02
        fdb   Txt_WBIII_03
        fdb   Txt_WBIII_04
        fdb   Txt_WBIII_05
        fdb   Txt_WBIII_06
        fdb   Txt_WBIII_07
        fdb   Txt_WBIII_08
        fdb   Txt_WBIII_09
        fdb   Txt_WBIII_10
        fdb   Txt_WBIII_11
        fdb   Txt_WBIII_12
        fdb   Txt_WBIII_13
        fdb   Txt_WBIII_14
        fdb   Txt_DD_01
        fdb   Txt_DD_02
        fdb   Txt_Ys_01
        fdb   Txt_Ys_02
        fdb   Txt_Ys_04
        fdb   Txt_Ys_05
        fdb   Txt_Ys_06
        fdb   Txt_Ys_07
        fdb   Txt_Ys_08
        fdb   Txt_Ys_09
        fdb   Txt_Ys_10
        fdb   Txt_Ys_11
        fdb   Txt_Ys_12

; -------------------------------------

Txt_Selector
        fcc   " !"
        fcb   $D,$A,0

; -------------------------------------

Txt_OutRun
        fcc   "Out Run 3-D"
        fcb   $D,$A,0
    
Txt_OutRun_01
        fcc   "01 - Magical Sound Shower"
        fcb   $D,$A,0
Txt_OutRun_02
        fcc   "02 - Midnight Highway"
        fcb   $D,$A,0
Txt_OutRun_03
        fcc   "03 - Color Ocean"
        fcb   $D,$A,0
Txt_OutRun_04
        fcc   "04 - Shining Wind"
        fcb   $D,$A,0

; -------------------------------------

Txt_WBIII
        fcc   "Wonder Boy III"
        fcb   $D,$A,0
        
Txt_WBIII_01
        fcc   "01 - The Last Dungeon"
        fcb   $D,$A,0
Txt_WBIII_02
        fcc   "02 - Vs. Dragon"
        fcb   $D,$A,0
Txt_WBIII_03
        fcc   "03 - And Now..."
        fcb   $D,$A,0
Txt_WBIII_04
        fcc   "04 - Monster-Town"
        fcb   $D,$A,0
Txt_WBIII_05
        fcc   "05 - Shop (The Dragon's Trap)"
        fcb   $D,$A,0
Txt_WBIII_06
        fcc   "06 - Continue"
        fcb   $D,$A,0
Txt_WBIII_07
        fcc   "07 - Mind of Hero"
        fcb   $D,$A,0
Txt_WBIII_08
        fcc   "08 - Side-Crawler's Dance"
        fcb   $D,$A,0
Txt_WBIII_09
        fcc   "09 - The Danger Zone"
        fcb   $D,$A,0
Txt_WBIII_10
        fcc   "10 - Mouse-Man Falling"
        fcb   $D,$A,0
Txt_WBIII_11
        fcc   "11 - It's a Treasure Box"
        fcb   $D,$A,0
Txt_WBIII_12
        fcc   "12 - The Monster's Lair"
        fcb   $D,$A,0
Txt_WBIII_13
        fcc   "13 - Endless War"
        fcb   $D,$A,0
Txt_WBIII_14
        fcc   "14 - The Dragon's Trap"
        fcb   $D,$A,0

; -------------------------------------

Txt_DD
        fcc   "Double Dragon"
        fcb   $D,$A,0
        
Txt_DD_01
        fcc   "01 - Title"
        fcb   $D,$A,0

Txt_DD_02
        fcc   "02 - Mission 1"
        fcb   $D,$A,0

; -------------------------------------

Txt_Ys
        fcc   "Ys"
        fcb   $D,$A,0

Txt_Ys_01
        fcc   "01 - Feena"
        fcb   $D,$A,0

Txt_Ys_02
        fcc   "02 - Fountain of Love"
        fcb   $D,$A,0

Txt_Ys_03
        fcc   "04 - The Syonin"
        fcb   $D,$A,0

Txt_Ys_04
        fcc   "05 - First Step Towards Wars"
        fcb   $D,$A,0

Txt_Ys_05
        fcc   "06 - Palace"
        fcb   $D,$A,0

Txt_Ys_06
        fcc   "07 - Holders of Power"
        fcb   $D,$A,0

Txt_Ys_07
        fcc   "08 - Palace of Destruction"
        fcb   $D,$A,0

Txt_Ys_08
        fcc   "09 -  Beat of the Terror"
        fcb   $D,$A,0

Txt_Ys_09
        fcc   "10 - Temple del Sol"
        fcb   $D,$A,0

Txt_Ys_10
        fcc   "11 - Tower of the Shadow of Death"
        fcb   $D,$A,0

Txt_Ys_11
        fcc   "12 - Devil's Wind"
        fcb   $D,$A,0

Txt_Ys_12
        fcc   "13 - The Last Moment of the Dark"
        fcb   $D,$A,0

 INCLUDE "./engine/graphics/font/DrawText/DrawText.asm"
 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded/asm/font_upper.asm"

 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_28_DN0.asm"
 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_30_DN0.asm"
fnt_4x6_shd_sel
        fdb   adr_fnt_4x6_shd_sel_28_DN0
        fdb   adr_fnt_4x6_shd_sel_30_DN0
