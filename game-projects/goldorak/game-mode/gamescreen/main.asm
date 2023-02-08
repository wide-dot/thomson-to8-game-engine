OverlayMode equ 1

        INCLUDE "./global/global-preambule-includes.asm"

        org   $6100


* ============================================================================== 
* Init
* ============================================================================== 
        _GameModeInit
        _MusicInit_SN76489 #Vgc_introSN,#vgc_stream_buffers,#MUSIC_LOOP ; initialize the SN76489 vgm player with a vgc data stream
        _MusicInit_YM2413 #Vgc_introYM,#MUSIC_LOOP                      ; initialize the YM2413 player 
        _MusicInit_IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame         ; Setting IRQ for music
    

* load object
        _NewManagedObject_U #ObjID_Player1
        _NewManagedObject_U #ObjID_Cockpit
        _SetPalette #Pal_gamescreen
        _ShowPalette

* init scroll
        lda   #ObjID_scrollA
        sta   VS_ObjIDA
        lda   #ObjID_scrollB
        sta   VS_ObjIDB

        lda   #1
        sta   VS_scroll_step

        lda   #0
        sta   VS_viewport_line_pos
        lda   #190
        sta   VS_viewport_size
        jsr   VerticalScrollUpdateViewport


* ============================================================================== * Main Loop
* ==============================================================================
LevelMainLoop
        jsr   ReadJoypads
        jsr   RunObjects
        jsr   VerticalScroll                        
        jsr   BuildSprites
        jsr   WaitVBL
        bra   LevelMainLoop

UserIRQ
        jsr   VerticalScrollMoveUp
        jsr   PalUpdateNow
        jsr   YVGM_MusicFrame
        jmp   vgc_update

* ============================================
* Vertical Scroll
* ============================================

OPCODE_JMP_E equ $7E
VS_line_size equ 75
VS_buffer_size equ 192          ; nb lines in buffer is 201 (0-200 to fit JMP return)

VS_ObjIDA fcb 0
VS_ObjIDB fcb 0
VS_scroll_step fcb 0

VerticalScrollUpdateViewport
        lda   #0
VS_viewport_line_pos equ *-1
        adda  VS_viewport_size
        ldb   #40 ; nb of bytes in a line
        mul
        addd  #$A000
        std   VS_mem_pos
        rts

VerticalScrollMoveUp
        ; TODO update buffer code with tilemap
        ldb   VS_cur_line
        addb  VS_scroll_step
        cmpb  #VS_buffer_size
        bls   >
        subd  #VS_buffer_size           ; cycling in buffer
!       stb   VS_cur_line
        rts

VerticalScrollMoveDown
        ; TODO update buffer code with tilemap
        ldb   VS_cur_line
        subb  VS_scroll_step
        bcc   >
        addb  #VS_buffer_size           ; cycling in buffer
!       stb   VS_cur_line
        rts


; when the first screen line is part of the scroll, as S is used to write in video buffer,
; you should expect 12 bytes to be written in or near video memory by the irq call.
; if it occurs at the end of the buffer routine, before S is retored, this can 
; erase bytes at $9FF4-$9FFF, so live this aera unsed

VerticalScroll
        ldb   VS_ObjIDA
@loop   ldx   #Obj_Index_Page
        lda   b,x   
        _SetCartPageA                  ; mount page that contain buffer code
        aslb
        ldx   #Obj_Index_Address
        ldx   b,x                      ; set buffer code address in x
        ldb   VS_cur_line              ; screen start line (0-199)
        addb  #200                     ; viewport size (1-200)
VS_viewport_size equ *-1
        bcs   @undo
        cmpb  #VS_buffer_size
        bls   >
@undo   subb  #VS_buffer_size          ; cycling in buffer
!       lda   #VS_line_size
        mul
        leau  d,x                      ; set u where a jump should be placed for return to caller
        pulu  a,y
        stu   @save_u
        pshs  a,y                      ; save 3 bytes in buffer that will be erased by the jmp return
        lda   #OPCODE_JMP_E            ; build jmp instruction
        ldy   #@ret                    ; this works even at the end of table because there is 
        sta   -3,u                     ; already a jmp for looping into the buffer
        sty   -2,u                     ; no need to have some padding
        sts   @save_s
        lds   #$BF40
VS_mem_pos equ *-2
        lda   #0
VS_cur_line equ *-1
        ldb   #VS_line_size
        mul
        leax  d,x                      ; set starting position in buffer code
        jmp   ,x
@ret    lds   #0
@save_s equ   *-2
        ldu   #0
@save_u equ   *-2
        puls  a,x
        pshu  a,x                      ; restore 3 bytes in buffer
        lda   VS_mem_pos
        cmpa  #$C0
        bhs   >                        ; exit if second buffer code as been executed
        adda  #$20                     ; else execute second buffer code
        sta   VS_mem_pos
        ldb   VS_ObjIDB
        bra   @loop
!       lda   VS_mem_pos
        suba  #$20
        sta   VS_mem_pos               ; restore to first buffer
        rts

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
        ;INCLUDE "./engine/graphics/sprite/sprite-background-erase-ext-pack.asm"

        INCLUDE "./global/global-trailer-includes.asm"
        