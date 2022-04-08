********************************************************************************
* LoadGameMode - Charge un nouveau niveau de jeu si requis
* ------------------------------------------------------------------------------
* 
*
********************************************************************************

GameMode           fcb   $00
ChangeGameMode     fcb   $00
glb_Cur_Game_Mode  fcb   $00
glb_Next_Game_Mode fcb   $00

LoadGameMode
        lda   ChangeGameMode
        bne   LoadGameModeNow
        rts
        
LoadGameModeNow

 IFDEF T2
        lda   #$80                     ; ROM page 0
        _SetCartPageA
               
        lda   GameMode
        ldb   glb_Cur_Game_Mode
        jmp   Build_RAMLoaderManager          
 ELSE
        ldb   #$64                     ; Page 4 contains RAMLoaderManager
        stb   $E7E6
        lda   GameMode
        ldb   glb_Cur_Game_Mode
        jmp   >$0000          
 ENDC
            