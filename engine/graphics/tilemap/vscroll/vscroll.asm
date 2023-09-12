; -----------------------------------------------------------------------------
; Vertical Scroll
; -----------------------------------------------------------------------------
; wide-dot - Benoit Rousseau - 11/09/2023
; ---------------------------------------
; - use a cycling code buffer to render a vertical scroll
; - buffer use stack blasting (pshs d,x,y,u)
; - buffer is only updated few lines per frame (only the new lines)
; - scroll is bi-directionnal
; - speed is a fixed point value and adjusted in regard of frame drop
; - handle up to 512 lines in map
; -----------------------------------------------------------------------------

; constants
; -----------------------------------------------------------------------------
m6809.OPCODE_JMP_E     equ   $7E

vscroll.LINE_SIZE      equ   75
 IFNDEF  vscroll.BUFFER_LINES
vscroll.BUFFER_LINES   equ   201   ; nb lines in buffer is 201 (0-200 to fit JMP return)
 ENDC

; parameters
; -----------------------------------------------------------------------------
; scroll data is split in 5 pages
vscroll.obj.map        fcb   0
vscroll.obj.tileA      fcb   0
vscroll.obj.tileB      fcb   0
vscroll.obj.bufferA    fcb   0
vscroll.obj.bufferB    fcb   0
vscroll.camera.speed   fdb   0     ; (signed 8.8 fixed point) nb of pixels/50hz

; private variables
; -----------------------------------------------------------------------------
vscroll.speed          fcb   0     ; (signed) nb of line to scroll in current frame
vscroll.map.cache.y    fdb   -1    ; current cached map line
vscroll.map.cache      fill  0,40  ; a full unpacked map line with 20x tile ids
vscroll.viewport.y     fcb   0     ; y position of viewport on screen
vscroll.camera.lastY   fdb   0     ; last camera position in map

; -----------------------------------------------------------------------------
; vscroll.move
; -----------------------------------------------------------------------------
; input  REG : none
; -----------------------------------------------------------------------------
vscroll.loop_cnt equ dp_extreg
vscroll.move

; update position in map and buffer
; ---------------------------------
        lda   gfxlock.frameDrop.count
        bne   >
        rts
!       sta   <vscroll.loop_cnt
        ldd   #$0000
@loop   addd  vscroll.camera.speed            ; mult speed by frame drop
        dec   <vscroll.loop_cnt
        bne   @loop
        sta   vscroll.speed                  ; set int part of 8.8
        bmi   @neg
        adda  vscroll.cursor              
        cmpa  #vscroll.BUFFER_LINES
        bls   @exit                          ; branch if in buffer range
        suba  #vscroll.BUFFER_LINES          ; cycling in buffer
        bra   @exit
@neg    adda  vscroll.cursor              
        cmpa  #vscroll.BUFFER_LINES
        bls   @exit                          ; branch if in buffer range
        adda  #vscroll.BUFFER_LINES          ; cycling in buffer
@exit   sta   vscroll.cursor
        ldx   vscroll.camera.y               ; update camera position in map
        stx   vscroll.camera.lastY
        ldb   vscroll.speed                  ; get int part of 8.8
        negb
        leax  b,x                            ; do not use abx, b is signed
        stx   vscroll.camera.y

; update the horizontal line of tile id in map cache
; --------------------------------------------------
        ldd   #0
vscroll.camera.y equ *-2               ; y position in map
        _lsrd
        _lsrd
        _lsrd
        _lsrd                          ; tile height is 16px
        cmpd  vscroll.map.cache.y
        beq   @updategfx               ; cache match current position in map
        std   vscroll.map.cache.y      ; load cache at a new position
        ldb   vscroll.obj.map
        ldx   #Obj_Index_Page
        lda   b,x   
        _SetCartPageA                  ; mount page that contain map data
        aslb
        ldx   #Obj_Index_Address
        ldx   b,x
        lda   vscroll.map.cache.y      ; handle up to 512 lines in map
        beq   >                        ; multiply map vertical pos (9bits)
        lda   #30                      ; by 30 bytes (12bits id * 20 tiles)
!       adda  #30
        ldb   vscroll.map.cache.y+1
        mul
        leax  d,x                      ; x point to desired map line
        ldy   #vscroll.map.cache
        lda   #20/2                    ; nb byte to load/2
        sta   <vscroll.loop_cnt
@loop   ldd   ,x+                      ; load cache by unpacking tile id
        _lsrd                          ; from 12bit to 16bit
        _lsrd
        _lsrd
        _lsrd
        std   ,y++
        ldd   ,x++
        anda  #$0F
        std   ,y++
        dec   <vscroll.loop_cnt
        bne   @loop
;
; update gfx in buffer code
; -------------------------
@updategfx
        rts
        ; mount bufferA in cartridge space

        ; mount tilesetA in cartridge space

        ; process lines

        ; mount bufferB in cartridge space

        ; mount tilesetB in cartridge space

        ; process lines

        rts

; -----------------------------------------------------------------------------
; vscroll.do
; -----------------------------------------------------------------------------
; input  REG : none
; -----------------------------------------------------------------------------
; When the first screen line is part of the scroll, as S register is used
; to write in video buffer, you should expect that irq call will write 12 bytes
; in or just before video memory. If it occurs at the end of the buffer routine
; before S is retored, this can erase bytes at $9FF4-$9FFF, so leave this aera
; unsed
; -----------------------------------------------------------------------------
vscroll.do
        ldb   vscroll.obj.bufferA
@loop   ldx   #Obj_Index_Page
        lda   b,x   
        _SetCartPageA                  ; mount page that contain buffer code
        aslb
        ldx   #Obj_Index_Address
        ldx   b,x                      ; set buffer code address in x
        ldb   vscroll.cursor           ; screen start line (0-199)
        addb  #200                     ; viewport size (1-200)
vscroll.viewport.height equ *-1
        bcs   @undo
        cmpb  #vscroll.BUFFER_LINES
        bls   >
@undo   subb  #vscroll.BUFFER_LINES    ; cycling in buffer
!       lda   #vscroll.LINE_SIZE
        mul
        leau  d,x                      ; set u where a jump should be placed for return to caller
        pulu  a,y
        stu   @save_u
        pshs  a,y                      ; save 3 bytes in buffer that will be erased by the jmp return
        lda   #m6809.OPCODE_JMP_E      ; build jmp instruction
        ldy   #@ret                    ; this works even at the end of table because there is 
        sta   -3,u                     ; already a jmp for looping into the buffer
        sty   -2,u                     ; no need to have some padding
        sts   @save_s
        lds   #$BF40
vscroll.viewport.ram equ *-2
        lda   #0
vscroll.cursor equ *-1
        ldb   #vscroll.LINE_SIZE
        mul
        leax  d,x                      ; set starting position in buffer code
        jmp   ,x
@ret    lds   #0
@save_s equ   *-2
        ldu   #0
@save_u equ   *-2
        puls  a,x
        pshu  a,x                      ; restore 3 bytes in buffer
        lda   vscroll.viewport.ram
        cmpa  #$C0
        bhs   >                        ; exit if second buffer code as been executed
        adda  #$20                     ; else execute second buffer code
        sta   vscroll.viewport.ram
        ldb   vscroll.obj.bufferB
        bra   @loop
!       lda   vscroll.viewport.ram
        suba  #$20
        sta   vscroll.viewport.ram     ; restore to first buffer
        rts