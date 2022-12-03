************************************************************************************************
* PrintString
*
* usage :
*    LDA #0
*    STA LOCATE_X
*    STA LOCATE_Y
*    LDX #WELCOME
*    JSR PrintString
*
*    WELCOME FCN "az 0..9 A..Z [] _ {} : Joshua"
************************************************************************************************

VIDEO           EQU $A000
RAM_A_OFFSET    EQU $2000
RAM_VIDEO_SIZE  EQU 8000
RAM_A           EQU VIDEO+RAM_A_OFFSET
RAM_A_END       EQU RAM_A+RAM_VIDEO_SIZE
RAM_B           EQU VIDEO
RAM_B_END       EQU RAM_B+RAM_VIDEO_SIZE

************************************************************************************************
    
RASTER_COLORS   FCB $01,$02,$03,$04,$05,$06,$07,$08   * 8 couleurs différentes par ligne
COLOR           FCB $02

LOCATE_X FCB $00
LOCATE_Y FCB $00
    fill 0,32
USER_STACK

PrintString
    * X pointe sur la chaine de caractères
    PSHS D,X,Y,U

    LDU #USER_STACK

    LDB LOCATE_Y
    LSLB 
    LSLB 
    LSLB      * x8
    LDA #40
    MUL
    TFR D,Y
    LDA LOCATE_X
    LEAY A,Y

!   LDB ,X+
    BEQ >   * si c'est 0 On sort
    CMPB #$20
    BEQ @next
    BSR PUTCHAR
@next    
    LEAY 1,Y
    BRA <
!   PULS U,Y,X,D,PC   

PUTCHAR
   * B contient le caractère à écrire en ASCII
   * Y contient l'adresse de destination
   * X va être calculé pour pointer sur le bon caractère

   PSHU B,X
   LDX  #CHAR_POINTERS+94 * on se place au mileu de la table pour l'adresse indexé negatif.
   SUBB #33+47            * le caractère 33 est le premier affichable
   LSLB                   * on multiplie B par 2
   LDX B,X
   JSR DRAW_CHAR_FAST
   PULU B,X
   RTS      

POPULATE_B 
 * A contient 4 bits à transformer. Chaque bit doit devenir 4 bit de la couleur en cours dans B 
    CLRB
    BITA #%10000000
    BEQ @next
    ADDB COLOR
@next 
    LSLA
    LSLB   
    LSLB   
    LSLB   
    LSLB   
    BITA #%10000000
    BEQ @finish
    ADDB COLOR
@finish   
 * B est pret ici
    LSLA * on avance A
    RTS

COUNTER FCB $04    

DRAW_CHAR_PIX_2
    * COLOR contient la couleur à mettre quand on rencontre un 1
    LEAX VIDEO,X 
    LDA  #$04
    STA COUNTER     
!   LDA ,Y+

    PSHU X
    LDX #RASTER_COLORS
    LDB COUNTER
    DECB
    LEAX B,X
    LDB ,X
    STB COLOR
    PULU X
     
    BSR POPULATE_B
    STB 8192,X          * on écrit B en RAM A ces 2 premiers pixels dans B
    BSR POPULATE_B
    STB ,X              * on écrit B en RAM B les 2 autres pixels

    LEAX 40,X           * va à la ligne car on vient d'écrire 4 pixels

    PSHU X
    LDX #RASTER_COLORS
    LDB COUNTER
    ADDB #3
    LEAX B,X
    LDB ,X
    STB COLOR
    PULU X

    BSR POPULATE_B
    STB 8192,X          * on écrit B en RAM A ces 2 premiers pixels dans B
    BSR POPULATE_B
    STB ,X              * on écrit B en RAM B les 2 autres pixels
    LEAX 40,X           * va à la ligne car on vient d'écrire 4 pixels 

    DEC COUNTER
    BNE <
!   RTS

LINE_COUNTER FCB $00

DRAW_CHAR  
    TFR X,D                     
    ADDD #16                    * 16 octets par caractère, on calcule l'adresse de fin,
    STD @val+1                  * que l'on écrit dynamiquement après de CMPY ci dessous
    LEAY RAM_B,Y                * On décale X par rapport à RAM_B
!   LDD ,X++                    * on lit 2 octets d'un coup
    STA RAM_A_OFFSET,Y          * on écrit A en RAMA les 2 premiers pixels de la ligne (1 octet)
    STB ,Y                      * on écrit B en RAMB les 2 derniers pixels de la ligne (1 octet)
    LEAY 40,Y                   * va à la ligne tous les 4 pixels
@val 
    CMPX #$0000                 * valeur générique remplacée dymaniquement
    BNE <
!   * fin de boucle
    RTS 

DRAW_LINE MACRO
    LDD \1,X                  
    STA \2,U                   
    STB \2,Y 
    ENDM

ZERO EQU $00

DRAW_CHAR_FAST  
    PSHS U,Y,D
    LEAU RAM_A+120,Y
    LEAY RAM_B+120,Y
    DRAW_LINE 0,-120
    DRAW_LINE 2,-80
    DRAW_LINE 4,-40
    * DRAW_LINE 6,0
    LDD 6,X 
    STA ZERO,U
    STB ZERO,Y
    DRAW_LINE 8,40
    DRAW_LINE 10,80
    DRAW_LINE 12,120
    DRAW_LINE 14,160
    PULS D,Y,U,PC  

CHAR_POINTERS
    FDB LETTER_33,LETTER_34,LETTER_35,LETTER_36,LETTER_37,LETTER_38,LETTER_39
    FDB LETTER_40,LETTER_41,LETTER_42,LETTER_43,LETTER_44,LETTER_45,LETTER_46,LETTER_47,LETTER_48,LETTER_49
    FDB LETTER_50,LETTER_51,LETTER_52,LETTER_53,LETTER_54,LETTER_55,LETTER_56,LETTER_57,LETTER_58,LETTER_59
    FDB LETTER_60,LETTER_61,LETTER_62,LETTER_63,LETTER_64,LETTER_65,LETTER_66,LETTER_67,LETTER_68,LETTER_69
    FDB LETTER_70,LETTER_71,LETTER_72,LETTER_73,LETTER_74,LETTER_75,LETTER_76,LETTER_77,LETTER_78,LETTER_79
    FDB LETTER_80,LETTER_81,LETTER_82,LETTER_83,LETTER_84,LETTER_85,LETTER_86,LETTER_87,LETTER_88,LETTER_89
    FDB LETTER_90,LETTER_91,LETTER_92,LETTER_93,LETTER_94,LETTER_95,LETTER_96,LETTER_97,LETTER_98,LETTER_99
    FDB LETTER_100,LETTER_101,LETTER_102,LETTER_103,LETTER_104,LETTER_105,LETTER_106,LETTER_107,LETTER_108,LETTER_109
    FDB LETTER_110,LETTER_111,LETTER_112,LETTER_113,LETTER_114,LETTER_115,LETTER_116,LETTER_117,LETTER_118,LETTER_119  
    FDB LETTER_120,LETTER_121,LETTER_122,LETTER_123,LETTER_124,LETTER_125,LETTER_126,LETTER_127

LETTER_33
    FCB $00,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00
    FCB $01,$00
    FCB $00,$00

LETTER_34
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00

LETTER_35
    FCB $00,$00
    FCB $00,$00
    FCB $01,$01
    FCB $11,$11
    FCB $11,$11
    FCB $01,$01
    FCB $00,$00
    FCB $00,$00

LETTER_36
    FCB $00,$00
    FCB $00,$10
    FCB $01,$11
    FCB $01,$11
    FCB $00,$01
    FCB $01,$11
    FCB $00,$10
    FCB $00,$00

LETTER_37
    FCB $00,$00
    FCB $00,$00
    FCB $01,$00
    FCB $00,$01
    FCB $00,$10
    FCB $01,$00
    FCB $00,$01
    FCB $00,$00

LETTER_38
    FCB $00,$00
    FCB $00,$00
    FCB $00,$11
    FCB $01,$01
    FCB $01,$00
    FCB $11,$11
    FCB $00,$00
    FCB $00,$00

LETTER_39
    FCB $00,$00
    FCB $01,$00
    FCB $11,$00
    FCB $10,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00

LETTER_40
    FCB $00,$00
    FCB $00,$10
    FCB $01,$00
    FCB $10,$00
    FCB $10,$00
    FCB $01,$00
    FCB $00,$10
    FCB $00,$00

LETTER_41
    FCB $00,$00
    FCB $10,$00
    FCB $01,$00
    FCB $00,$10
    FCB $00,$10
    FCB $01,$00
    FCB $10,$00
    FCB $00,$00

LETTER_42
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $10,$10
    FCB $01,$00
    FCB $10,$10
    FCB $00,$00
    FCB $00,$00

LETTER_43
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $01,$00
    FCB $11,$10
    FCB $01,$00
    FCB $00,$00
    FCB $00,$00

LETTER_44
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $01,$00
    FCB $10,$00
    FCB $00,$00

LETTER_45
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $11,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00

LETTER_46
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00

LETTER_47
    FCB $00,$00
    FCB $00,$10
    FCB $00,$10
    FCB $01,$00
    FCB $01,$00
    FCB $10,$00
    FCB $10,$00
    FCB $00,$00

LETTER_48
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_49
    FCB $00,$00
    FCB $11,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00

LETTER_50
    FCB $00,$00
    FCB $11,$00
    FCB $00,$10
    FCB $01,$00
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_51
    FCB $00,$00
    FCB $11,$10
    FCB $00,$10
    FCB $11,$10
    FCB $00,$10
    FCB $00,$10
    FCB $11,$10
    FCB $00,$00

LETTER_52
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$00

LETTER_53
    FCB $00,$00
    FCB $11,$10
    FCB $10,$00
    FCB $11,$10
    FCB $00,$10
    FCB $00,$10
    FCB $11,$00
    FCB $00,$00

LETTER_54
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $11,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_55
    FCB $00,$00
    FCB $11,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$00

LETTER_56
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_57
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$00

LETTER_58
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $01,$00
    FCB $00,$00
    FCB $00,$00
    FCB $01,$00
    FCB $00,$00

LETTER_59
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $01,$00
    FCB $00,$00
    FCB $00,$00
    FCB $01,$00
    FCB $01,$00

LETTER_60
    FCB $00,$00
    FCB $00,$00
    FCB $01,$10
    FCB $11,$00
    FCB $01,$00
    FCB $01,$10
    FCB $00,$00
    FCB $00,$00

LETTER_61
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $11,$10
    FCB $00,$00
    FCB $11,$10
    FCB $00,$00
    FCB $00,$00

LETTER_62
    FCB $00,$00
    FCB $00,$00
    FCB $11,$00
    FCB $01,$10
    FCB $01,$00
    FCB $11,$00
    FCB $00,$00
    FCB $00,$00

LETTER_63
    FCB $00,$00
    FCB $01,$10
    FCB $00,$10
    FCB $01,$10
    FCB $01,$00
    FCB $00,$00
    FCB $01,$00
    FCB $00,$00

LETTER_64
    FCB $00,$00
    FCB $00,$00
    FCB $01,$11
    FCB $10,$11
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00
    FCB $00,$00

LETTER_65
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_66
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_67
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_68
    FCB $00,$00
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_69
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $11,$10
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_70
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $11,$10
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $00,$00

LETTER_71
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$00
    FCB $00,$00

LETTER_72
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_73
    FCB $00,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00

LETTER_74
    FCB $00,$00
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $11,$00
    FCB $00,$00

LETTER_75
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_76
    FCB $00,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_77
    FCB $00,$00
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_78
    FCB $00,$00
    FCB $10,$00
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_79
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_80
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $00,$00

LETTER_81
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$00
    FCB $01,$10
    FCB $00,$00

LETTER_82
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_83
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $01,$00
    FCB $00,$10
    FCB $00,$10
    FCB $11,$10
    FCB $00,$00

LETTER_84
    FCB $00,$00
    FCB $11,$10
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00

LETTER_85
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_86
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $01,$00
    FCB $00,$00

LETTER_87
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $00,$00

LETTER_88
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $01,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_89
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00

LETTER_90
    FCB $00,$00
    FCB $11,$10
    FCB $00,$10
    FCB $01,$00
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_91
    FCB $00,$00
    FCB $11,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $11,$00
    FCB $00,$00

LETTER_92
    FCB $00,$00
    FCB $10,$00
    FCB $10,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$10
    FCB $00,$10
    FCB $00,$00

LETTER_93
    FCB $00,$00
    FCB $11,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $11,$00
    FCB $00,$00

LETTER_94
    FCB $00,$00
    FCB $01,$00
    FCB $10,$10
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00

LETTER_95
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $11,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00

LETTER_96
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $11,$11
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00

LETTER_97
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_98
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_99
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_100
    FCB $00,$00
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_101
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $11,$10
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_102
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $11,$10
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $00,$00

LETTER_103
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$00
    FCB $00,$00

LETTER_104
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_105
    FCB $00,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00

LETTER_106
    FCB $00,$00
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $00,$10
    FCB $11,$00
    FCB $00,$00

LETTER_107
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_108
    FCB $00,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_109
    FCB $00,$00
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_110
    FCB $00,$00
    FCB $10,$00
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_111
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_112
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$00
    FCB $10,$00
    FCB $10,$00
    FCB $10,$00
    FCB $00,$00

LETTER_113
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$00
    FCB $01,$10
    FCB $00,$00

LETTER_114
    FCB $00,$00
    FCB $01,$10
    FCB $10,$10
    FCB $11,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_115
    FCB $00,$00
    FCB $01,$10
    FCB $10,$00
    FCB $01,$00
    FCB $00,$10
    FCB $00,$10
    FCB $11,$10
    FCB $00,$00

LETTER_116
    FCB $00,$00
    FCB $11,$10
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00

LETTER_117
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $00,$00

LETTER_118
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $01,$00
    FCB $00,$00

LETTER_119
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $10,$10
    FCB $00,$00

LETTER_120
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $01,$00
    FCB $10,$10
    FCB $10,$10
    FCB $10,$10
    FCB $00,$00

LETTER_121
    FCB $00,$00
    FCB $10,$10
    FCB $10,$10
    FCB $11,$10
    FCB $01,$00
    FCB $01,$00
    FCB $01,$00
    FCB $00,$00

LETTER_122
    FCB $00,$00
    FCB $11,$10
    FCB $00,$10
    FCB $01,$00
    FCB $10,$00
    FCB $10,$00
    FCB $11,$10
    FCB $00,$00

LETTER_123
    FCB $00,$00
    FCB $01,$10
    FCB $01,$00
    FCB $11,$00
    FCB $01,$00
    FCB $01,$00
    FCB $01,$10
    FCB $00,$00

LETTER_124
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00

LETTER_125
    FCB $00,$00
    FCB $11,$00
    FCB $01,$00
    FCB $01,$10
    FCB $01,$00
    FCB $01,$00
    FCB $11,$00
    FCB $00,$00

LETTER_126
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $11,$10
    FCB $00,$00

LETTER_127
    FCB $00,$00
    FCB $00,$00
    FCB $00,$00
    FCB $11,$10
    FCB $11,$10
    FCB $11,$10
    FCB $11,$10
    FCB $00,$00
   


   
   





