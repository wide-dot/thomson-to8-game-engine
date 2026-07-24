        opt   c,ct
********************************************************************************
* Banc de test tailmgr (master tail) - mode background-erase minimal
********************************************************************************
        INCLUDE "./engine/system/to8/memory-map.equ"
        INCLUDE "./engine/constants.asm"
        INCLUDE "./engine/macros.asm"
        org   $6100

        jsr   InitGlobals
        jsr   InitStack
        jsr   LoadAct
        jsr   ReadJoypads

        ; instancie UN objet master
        jsr   LoadObject_u
        lda   #ObjID_tailmgr
        sta   id,u
        ; routine=0 -> Init au premier RunObjects

        lda   #GmID_tailtest
        sta   glb_Cur_Game_Mode

LevelMainLoop
        jsr   WaitVBL
        jsr   PalUpdateNow
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   CheckSpritesRefresh
        jsr   EraseSprites
        jsr   UnsetDisplayPriority
        jsr   DrawSprites
        jmp   LevelMainLoop

        INCLUDE "./game-mode/tailtest/ram-data.asm"

        INCLUDE "./engine/graphics/sprite/sprite-background-erase-pack.asm"
        INCLUDE "./engine/object-management/RunObjects.asm"
        INCLUDE "./engine/InitGlobals.asm"
        INCLUDE "./engine/ram/ClearDataMemory.asm"
        INCLUDE "./engine/graphics/vbl/WaitVBL.asm"
        INCLUDE "./engine/ram/BankSwitch.asm"
        INCLUDE "./engine/object-management/RunPgSubRoutine.asm"
        INCLUDE "./engine/joypad/ReadJoypads.asm"
        INCLUDE "./engine/palette/PalUpdateNow.asm"
        INCLUDE "./engine/level-management/LoadGameMode.asm"
