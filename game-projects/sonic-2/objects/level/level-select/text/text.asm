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

        _DrawTextSetPos 20,1,6
        std   ff_pos

Text_Main
        lda   Ctrl_1_Press
        bita  #button_up_mask
        beq   >
        dec   Current_Selection
        bpl   >
        clr   Current_Selection
!       bita  #button_down_mask
        beq   >
        ldb   Current_Selection
        incb
        stb   Current_Selection
        cmpb  #nb_select_items
        bne   >
        decb
        stb   Current_Selection
!       ldb   Current_Selection
        ldx   #Select_Item
        aslb
        ldd   b,x
        std   Current_ZoneAndAct

 ; draw zone names
 ; ***************

        _DrawTextSetPos 1,1,6   
        std   line_start
        std   DrawText_pos

        clr   render_line
        ldb   render_line
@loop   
        ldx   #Text_Zone_Index
        lda   b,x
        cmpa  Current_Zone
        beq   @drawSelected
        ldx   #fnt_4x6_shd
        bra   >
@drawSelected
        ldx   #fnt_4x6_shd_sel
!       ldy   #Text_Zone
        asla
        ldy   a,y
        jsr   DrawText
        ldb   render_line
        incb
        stb   render_line
        cmpb  #nb_select_items
        bne   @loop

 ; draw act numbers
 ; ****************

        _DrawTextSetPos 16,1,6   
        std   line_start
        std   DrawText_pos

        clr   render_line
        ldb   render_line
@loop   
        ldx   #Select_Item
        aslb
        ldd   b,x
        cmpd  Current_ZoneAndAct
        beq   @drawSelected
        ldx   #fnt_4x6_shd
        bra   >
@drawSelected
        ldx   #fnt_4x6_shd_sel
!       ldy   #Text_Act
        ldb   render_line
        aslb
        ldy   b,y
        jsr   DrawText
        ldb   render_line
        incb
        stb   render_line
        cmpb  #nb_select_acts
        bne   @loop

 ; draw sound hex value
 ; ********************

        lda   Current_Selection
        cmpa  #24
        beq   @drawSelected
        ldx   #fnt_4x6_shd
        bra   >
@drawSelected
        ldx   #fnt_4x6_shd_sel
!
        lda   Sound_test_sound
        ldy   #SoundHex
        jsr   HexToText
        _DrawTextSetPos 32+(4*40),12,6   
        std   DrawText_pos
        ldy   #SoundHex
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

Txt_EHZ       fcc   "EMERALD HILL"
              fcb   $D,$A,0
Txt_CPZ       fcc   "CHEMICAL PLANT"
              fcb   $D,$A,0
Txt_ARZ       fcc   "AQUATIC RUIN"
              fcb   $D,$A,0
Txt_CNZ       fcc   "CASINO NIGHT"
              fcb   $D,$A,0
Txt_HTZ       fcc   "HILL TOP"
              fcb   $D,$A,0
Txt_MCZ       fcc   "MYSTIC CAVE"
              fcb   $D,$A,0
Txt_HPZ       fcc   "HIDDEN PALACE"
              fcb   $D,$A,0
Txt_OOZ       fcc   "OIL OCEAN"
              fcb   $D,$A,0
Txt_MTZ       fcc   "METROPOLIS"
              fcb   $D,$A,0
Txt_SCZ       fcc   "SKY CHASE"
              fcb   $D,$A,$A,0
Txt_WFZ       fcc   "WING FORTRESS"
              fcb   $D,$A,$A,0
Txt_DEZ       fcc   "DEATH EGG"
              fcb   $D,$A,$A,0
Txt_SST       fcc   "SPECIAL STAGE"
              fcb   $D,$A,$A,0
Txt_SndCard   fcc   "SOUND CARD *PSG+FM*"
              fcb   $D,$A,$A,0
Txt_SndTest   fcc   "SOUND TEST *  *"
              fcb   $D,$A,$A,0
Txt_CRLF      fcb   $D,$A,0    ; Carriage Return, Line Feed
Txt_CRLFLF    fcb   $D,$A,$A,0 ; Carriage Return, Line Feed, Line Feed
Txt_FF        fcb   $C,0       ; Form Feed

Text_Zone
        fdb   Txt_EHZ
        fdb   Txt_CPZ
        fdb   Txt_ARZ
        fdb   Txt_CNZ
        fdb   Txt_HTZ
        fdb   Txt_MCZ
        fdb   Txt_HPZ
        fdb   Txt_OOZ
        fdb   Txt_MTZ
        fdb   Txt_SST
        fdb   Txt_SCZ
        fdb   Txt_WFZ
        fdb   Txt_DEZ
        fdb   Txt_SST
        fdb   Txt_SndCard
        fdb   Txt_SndTest
CRLF    equ   (*-Text_Zone)/2
        fdb   Txt_CRLF
CRLFLF  equ   (*-Text_Zone)/2
        fdb   Txt_CRLFLF
FF      equ   (*-Text_Zone)/2
        fdb   Txt_FF

Select_Item
        fcb emerald_hill_zone,0
        fcb emerald_hill_zone,1
        fcb chemical_plant_zone,0
        fcb chemical_plant_zone,1
        fcb aquatic_ruin_zone,0
        fcb aquatic_ruin_zone,1
        fcb casino_night_zone,0
        fcb casino_night_zone,1
        fcb hill_top_zone,0
        fcb hill_top_zone,1
        fcb mystic_cave_zone,0
        fcb mystic_cave_zone,1
        fcb hidden_palace_zone,0
        fcb hidden_palace_zone,1
        fcb oil_ocean_zone,0
        fcb oil_ocean_zone,1
        fcb metropolis_zone,0
        fcb metropolis_zone,1
        fcb metropolis_zone_2,0
        fcb sky_chase_zone,0
        fcb wing_fortress_zone,0
        fcb death_egg_zone,0
        fcb special_stage_id,0
        fcb sound_card_id,0
        fcb sound_test_id,0
nb_select_items equ (*-Select_Item)/2

Text_Zone_Index
        fcb emerald_hill_zone
        fcb CRLFLF
        fcb chemical_plant_zone
        fcb CRLFLF
        fcb aquatic_ruin_zone
        fcb CRLFLF
        fcb casino_night_zone
        fcb CRLFLF
        fcb hill_top_zone
        fcb CRLFLF
        fcb mystic_cave_zone
        fcb CRLFLF
        fcb hidden_palace_zone
        fcb CRLFLF
        fcb oil_ocean_zone
        fcb CRLFLF
        fcb metropolis_zone
        fcb CRLF
        fcb FF
        fcb sky_chase_zone
        fcb wing_fortress_zone
        fcb death_egg_zone
        fcb special_stage_id
        fcb sound_card_id
        fcb sound_test_id

Txt_1   fcc   "1"
        fcb   $D,$A,0
Txt_2b  fcc   "2"
        fcb   $D,$A,$A,0
Txt_2   fcc   "2"
        fcb   $D,$A,0
Txt_3   fcn   "3"

Text_Act
        fdb   Txt_1
        fdb   Txt_2b
        fdb   Txt_1
        fdb   Txt_2b
        fdb   Txt_1
        fdb   Txt_2b
        fdb   Txt_1
        fdb   Txt_2b
        fdb   Txt_1
        fdb   Txt_2b
        fdb   Txt_1
        fdb   Txt_2b
        fdb   Txt_1
        fdb   Txt_2b
        fdb   Txt_1
        fdb   Txt_2b
        fdb   Txt_1
        fdb   Txt_2
        fdb   Txt_3
nb_select_acts equ (*-Text_Act)/2

SoundHex fcn "00"

 INCLUDE "./engine/graphics/font/DrawText/DrawText.asm"
 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded/asm/font_upper.asm"
 INCLUDE "./engine/graphics/font/DrawText/3x5_shaded_selected/asm/font_upper.asm"