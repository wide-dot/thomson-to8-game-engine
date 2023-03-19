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
        ldb   #59
!       bita  #c_button_right_mask
        beq   >
        incb
        cmpb  #60
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
@rts    rts

GameSelect
        lda   Dpad_Press
        ldb   snd_tst_sel_game
        bita  #c_button_left_mask
        beq   >
        decb
        bpl   @apply
        ldb   #4
        bra   @apply
!       bita  #c_button_right_mask
        beq   >
        incb
        cmpb  #5
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
        fdb   Txt_SOR
        fdb   Txt_SORII
        fdb   Txt_WBIII
        fdb   Txt_WBMW

FirstSongStartIdx
        fcb   0
        fcb   4
        fcb   15
        fcb   30
        fcb   44

FirstSongIdx
        fcb   3
        fcb   14
        fcb   29
        fcb   43
        fcb   60

TxtLst_Song
        fdb   Txt_OutRun_01
        fdb   Txt_OutRun_02
        fdb   Txt_OutRun_03
        fdb   Txt_OutRun_04
        fdb   Txt_SOR_01
        fdb   Txt_SOR_02
        fdb   Txt_SOR_03
        fdb   Txt_SOR_04
        fdb   Txt_SOR_05
        fdb   Txt_SOR_06
        fdb   Txt_SOR_07
        fdb   Txt_SOR_08
        fdb   Txt_SOR_09
        fdb   Txt_SOR_10
        fdb   Txt_SOR_11
        fdb   Txt_SORII_01
        fdb   Txt_SORII_02
        fdb   Txt_SORII_03
        fdb   Txt_SORII_04
        fdb   Txt_SORII_05
        fdb   Txt_SORII_07
        fdb   Txt_SORII_08
        fdb   Txt_SORII_09
        fdb   Txt_SORII_10
        fdb   Txt_SORII_11
        fdb   Txt_SORII_12
        fdb   Txt_SORII_13
        fdb   Txt_SORII_14
        fdb   Txt_SORII_15
        fdb   Txt_SORII_16
        fdb   Txt_WBIII_01
        fdb   Txt_WBIII_02
        fdb   Txt_WBIII_03
        fdb   Txt_WBIII_04
        fdb   Txt_WBIII_05
        fdb   Txt_WBIII_07
        fdb   Txt_WBIII_08
        fdb   Txt_WBIII_09
        fdb   Txt_WBIII_10
        fdb   Txt_WBIII_11
        fdb   Txt_WBIII_12
        fdb   Txt_WBIII_13
        fdb   Txt_WBIII_14
        fdb   Txt_WBIII_15
        fdb   Txt_WBMW_01
        fdb   Txt_WBMW_02
        fdb   Txt_WBMW_03
        fdb   Txt_WBMW_04
        fdb   Txt_WBMW_05
        fdb   Txt_WBMW_06
        fdb   Txt_WBMW_07
        fdb   Txt_WBMW_08
        fdb   Txt_WBMW_09
        fdb   Txt_WBMW_10
        fdb   Txt_WBMW_11
        fdb   Txt_WBMW_12
        fdb   Txt_WBMW_13
        fdb   Txt_WBMW_14
        fdb   Txt_WBMW_15
        fdb   Txt_WBMW_17

; -------------------------------------

Txt_Selector
        fcc   " !"
        fcb   $D,$A,0

; -------------------------------------

Txt_OutRun
        fcc   "Out Run"
        fcb   $D,$A,0
    
Txt_OutRun_01
        fcc   "01 - Magical Sound Shower"
        fcb   $D,$A,0
Txt_OutRun_02
        fcc   "02 - Passing Breeze"
        fcb   $D,$A,0
Txt_OutRun_03
        fcc   "03 - Splash Wave"
        fcb   $D,$A,0
Txt_OutRun_04
        fcc   "04 - Last Wave"
        fcb   $D,$A,0

; -------------------------------------

Txt_SOR
        fcc   "Streets of Rage"
        fcb   $D,$A,0

Txt_SOR_01
        fcc   "01 - The Streets of Rage"
        fcb   $D,$A,0
Txt_SOR_02
        fcc   "02 - Player Select"
        fcb   $D,$A,0
Txt_SOR_03
        fcc   "03 - Fighting in the Street"
        fcb   $D,$A,0
Txt_SOR_04
        fcc   "04 - Attack the Barbarian"
        fcb   $D,$A,0
Txt_SOR_05
        fcc   "05 - Round Clear"
        fcb   $D,$A,0
Txt_SOR_06
        fcc   "06 - Keep the Groovin'"
        fcb   $D,$A,0
Txt_SOR_07
        fcc   "07 - Beating on the Ship"
        fcb   $D,$A,0
Txt_SOR_08
        fcc   "08 - Back to the Industry"
        fcb   $D,$A,0
Txt_SOR_09
        fcc   "09 - The Last Soul"
        fcb   $D,$A,0
Txt_SOR_10
        fcc   "10 - Big Boss"
        fcb   $D,$A,0
Txt_SOR_11
        fcc   "11 - My Little Baby"
        fcb   $D,$A,0

; -------------------------------------

Txt_SORII
        fcc   "Streets of Rage II"
        fcb   $D,$A,0
        
Txt_SORII_01
        fcc   "01 - The Streets of Rage Super Mix"
        fcb   $D,$A,0
Txt_SORII_02
        fcc   "02 - Player Select"
        fcb   $D,$A,0
Txt_SORII_03
        fcc   "03 - Go Straight"
        fcb   $D,$A,0
Txt_SORII_04
        fcc   "04 - In the Bar"
        fcb   $D,$A,0
Txt_SORII_05
        fcc   "05 - Never Return Alive"
        fcb   $D,$A,0
Txt_SORII_07
        fcc   "07 - Dreamer"
        fcb   $D,$A,0
Txt_SORII_08
        fcc   "08 - Under Logic"
        fcb   $D,$A,0
Txt_SORII_09
        fcc   "09 - Spin on the Bridge"
        fcb   $D,$A,0
Txt_SORII_10
        fcc   "10 - Too Deep"
        fcb   $D,$A,0
Txt_SORII_11
        fcc   "11 - Slow Moon"
        fcb   $D,$A,0
Txt_SORII_12
        fcc   "12 - The Super Three"
        fcb   $D,$A,0
Txt_SORII_13
        fcc   "13 - Expander"
        fcb   $D,$A,0
Txt_SORII_14
        fcc   "14 - Max Man"
        fcb   $D,$A,0
Txt_SORII_15
        fcc   "15 - Revenge of Mr. X"
        fcb   $D,$A,0
Txt_SORII_16
        fcc   "16 - Good End"
        fcb   $D,$A,0

; -------------------------------------

Txt_WBIII
        fcc   "Wonder Boy III"
        fcb   $D,$A,0
        
Txt_WBIII_01
        fcc   "01 - Title Screen"
        fcb   $D,$A,0
Txt_WBIII_02
        fcc   "02 - The Last Dungeon"
        fcb   $D,$A,0
Txt_WBIII_03
        fcc   "03 - Vs. Dragon"
        fcb   $D,$A,0
Txt_WBIII_04
        fcc   "04 - And Now..."
        fcb   $D,$A,0
Txt_WBIII_05
        fcc   "05 - Monster-Town"
        fcb   $D,$A,0
Txt_WBIII_07
        fcc   "07 - Continue"
        fcb   $D,$A,0
Txt_WBIII_08
        fcc   "08 - Mind of Hero"
        fcb   $D,$A,0
Txt_WBIII_09
        fcc   "09 - Side-Crawler's Dance"
        fcb   $D,$A,0
Txt_WBIII_10
        fcc   "10 - The Danger Zone"
        fcb   $D,$A,0
Txt_WBIII_11
        fcc   "11 - Mouse-Man Falling"
        fcb   $D,$A,0
Txt_WBIII_12
        fcc   "12 - It's a Treasure Box"
        fcb   $D,$A,0
Txt_WBIII_13
        fcc   "13 - The Monster's Lair"
        fcb   $D,$A,0
Txt_WBIII_14
        fcc   "14 - Endless War"
        fcb   $D,$A,0
Txt_WBIII_15
        fcc   "15 - The Dragon's Trap"
        fcb   $D,$A,0

; -------------------------------------

Txt_WBMW
        fcc   "Wonder Boy in Monster World"
        fcb   $D,$A,0
                
Txt_WBMW_01
        fcc   "01 - Title Screen"
        fcb   $D,$A,0
Txt_WBMW_02
        fcc   "02 - Home Stage"
        fcb   $D,$A,0
Txt_WBMW_03
        fcc   "03 - Beach Stage"
        fcb   $D,$A,0
Txt_WBMW_04
        fcc   "04 - Alsedo the Fairy Village"
        fcb   $D,$A,0
Txt_WBMW_05
        fcc   "05 - Castle in Cave Stage"
        fcb   $D,$A,0
Txt_WBMW_06
        fcc   "06 - Passageway in tree Stage"
        fcb   $D,$A,0
Txt_WBMW_07
        fcc   "07 - Begoni the Dragon Village"
        fcb   $D,$A,0
Txt_WBMW_08
        fcc   "08 - Jungle Stage"
        fcb   $D,$A,0
Txt_WBMW_09
        fcc   "09 - Aztec Village"
        fcb   $D,$A,0
Txt_WBMW_10
        fcc   "10 - Desert Stage"
        fcb   $D,$A,0
Txt_WBMW_11
        fcc   "11 - Desert after Egypt Stage"
        fcb   $D,$A,0
Txt_WBMW_12
        fcc   "12 - Snow fields and under sea stages"
        fcb   $D,$A,0
Txt_WBMW_13
        fcc   "13 - Inside Pyramid Stage"
        fcb   $D,$A,0
Txt_WBMW_14
        fcc   "14 - Boss Stage"
        fcb   $D,$A,0
Txt_WBMW_15
        fcc   "15 - Ending"
        fcb   $D,$A,0
Txt_WBMW_17
        fcc   "17 - The Last Dungeon Remix (unused)"
        fcb   $D,$A,0

; -------------------------------------

 INCLUDE "./engine/graphics/font/DrawText/DrawText.asm"
 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded/asm/font_upper.asm"

 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_28_DN0.asm"
 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_30_DN0.asm"
fnt_4x6_shd_sel
        fdb   adr_fnt_4x6_shd_sel_28_DN0
        fdb   adr_fnt_4x6_shd_sel_30_DN0
