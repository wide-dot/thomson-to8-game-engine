OverlayMode equ 1
DEBUG EQU 1

        INCLUDE "./global/global-preambule-includes.asm"

        org   $6100

        opt cd


; DEV SCROLL BUFFER
_mountScrollBuffer MACRO
       ldb   VS_ObjID\1
       ldx   #Obj_Index_Page
       lda   b,x   
       _SetCartPageA
       aslb
       ldx   #Obj_Index_Address
       ldx   b,x                      ; set buffer code address in x
       ENDM   


* ============================================================================== 
* Init
* ============================================================================== 
        _gameMode.init #GmID_gamescreen
        _music.init.SN76489 #Vgc_ingameSN,#MUSIC_LOOP,#0                 ; initialize the SN76489 player
        _music.init.YM2413 #Vgc_ingameYM,#MUSIC_LOOP,#0                  ; initialize the YM2413 player 
        _music.init.IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame         ; Setting IRQ for music
        _palette.set #Palette_gamescreen
        _palette.show
        
        #_PaletteFade #Pal_black,#Palette_gamescreen,Obj_PaletteFade,#$20

* load object
        _objectManager.new.u #ObjID_Goldorak
        _objectManager.new.u #ObjID_Cockpit


* init scroll
        lda   #ObjID_scrollA
        sta   VS_ObjIDA
        lda   #ObjID_scrollB
        sta   VS_ObjIDB

        lda   #1
        sta   VS_scroll_step

        lda   #10
        sta   VS_viewport_line_pos
        lda   #120
        sta   VS_viewport_size
        jsr   VerticalScrollUpdateViewport

        _mountScrollBuffer A ; X points to the address of the Scroll Buffer A
        jsr InitScrollBuffer
        _mountScrollBuffer B ; X points to the address of the Scroll Buffer B
        jsr InitScrollBuffer

* ============================================================================== * Main Loop
* ==============================================================================
LevelMainLoop
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   VerticalScrollMoveUp
        jsr   VerticalScroll                        
        jsr   BuildSprites        
        jsr   WaitVBL
        bra   LevelMainLoop

UserIRQ        
        jsr   PalUpdateNow
        jsr   YVGM_MusicFrame
        jmp   vgc_update

 

ScrollChunk_Start
       LDD #$0000
       LDX #$0000
       LDY #$0000
       LDU #$0000
       PSHS D,X,Y,U
ScrollChunk_End

currentColor FCB $0F

UpdateScrollChunkColor
       _breakpoint
       PSHS D,X
       LDU #ScrollChunk_Start
       LDA currentColor
       LSLA
       LSLA
       LSLA
       LSLA
       ORA currentColor
       TFR A,B
       STD 1,U  ; offset 1
       STD 4,U  ; offset 4
       STD 8,U  ; offset 8
       STD 11,U ; offset 11
       DEC currentColor
       BNE @exit
       LDA #$0F
       STA currentColor
@exit  PULS D,X
       RTS

 

WriteScrollChunk ; X contains the address to write the scroll chunk
       LDU #ScrollChunk_Start ; U will iterate over the scroll chunk data
@loop     
       LDA ,U+                  ; loading byte         
       STA ,X+                  ; storing A
       CMPU #ScrollChunk_End
       BNE @loop                ; end of the scroll chunk is not reached
       RTS

WriteScrollLine ; X contains the address to write the scroll chunk
      JSR UpdateScrollChunkColor
      LDB #5    ; 5 scroll chunks in a ligne

@loop JSR WriteScrollChunk
      DECB
      BNE @loop        
      RTS

InitScrollBuffer
      _breakpoint
      LDA #$0F
      STA currentColor
      LDY #VS_buffer_size
      STX buffer_loop_addr
@loop
      JSR WriteScrollLine
      LEAY -1,Y
      BNE @loop
      LDA #$7E
      STA ,X+
      LDD #$0000
buffer_loop_addr EQU *-2      
      STD ,X
      _breakpoint
      RTS



     
                  

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------

        INCLUDE "./game-mode/gamescreen/gamescreenRamData.asm"
        
* ============================================================================== * Routines
* ==============================================================================
        INCLUDE "./engine/graphics/sprite/sprite-overlay-pack.asm"
        INCLUDE "./engine/graphics/animation/AnimateSprite.asm"
        INCLUDE "./engine/graphics/codec/DecRLE00.asm"
        INCLUDE "./engine/graphics/codec/zx0_mega.asm" 
        INCLUDE "./engine/graphics/tilemap/vertical-scroll/scrolling.asm"

        INCLUDE "./engine/palette/color/Pal_black.asm"

        INCLUDE "./global/global-trailer-includes.asm"
        