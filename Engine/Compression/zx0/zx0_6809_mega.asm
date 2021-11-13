; zx0_6809_mega.asm - ZX0 decompressor for M6809 - 198 bytes
;
; Copyright (c) 2021 Doug Masten
; ZX0 compression (c) 2021 Einar Saukas, https://github.com/einar-saukas/ZX0
;
; This software is provided 'as-is', without any express or implied
; warranty. In no event will the authors be held liable for any damages
; arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.


; rotate next bit into elias value
zx0_elias_rotate   macro
                   lsla                ; get next bit
                   rolb                ; rotate bit into elias value
                   rol <zx0_code+1     ;   "     "   "    "
                   lsla                ; get next bit
                   endm

; only get one bit from stream
zx0_get_1bit       macro
                   lsla                ; get next bit
                   bne done@           ; is bit stream empty? no, branch
                   lda ,x+             ; load another group of 8 bits
                   rola                ; get next bit
done@              equ *
                   endm

; get elias value
zx0_get_elias      macro
                   bcs done@
loop@              zx0_elias_rotate
                   bcc loop@           ; loop until done
                   bne done@           ; is bit stream empty? no, branch
                   bsr zx0_reload      ; process rest of elias until done
done@              equ *
                   endm


;------------------------------------------------------------------------------
; Function    : zx0_decompress
; Entry       : Reg X = start of compressed data
;             : Reg U = start of decompression buffer
; Exit        : Reg X = end of compressed data + 1
;             : Reg U = end of decompression buffer + 1
; Destroys    : Regs D, Y
; Description : Decompress ZX0 data (version 1)
;------------------------------------------------------------------------------
; Options:
;
;   ZX0_ONE_TIME_USE
;     Defined variable to disable re-initialization of variables. Enable
;     this option for one-time use of depacker for smaller code size.
;       ex. ZX0_ONE_TIME_USE equ 1
;
;   ZX0_DISABLE_SAVE_REGS
;     Defined variable to disable saving registers CC and DP. Enable
;     this option for smaller code size and if calling program will take
;     care of registers CC and DP.
;       ex. ZX0_DISABLE_SAVE_REGS equ 1
;
;   ZX0_DISABLE_DISABLING_INTERRUPTS
;     Defined variable to disable the disabling of interrupts. Enable
;     this option if interrupts are already disable or if IRQ and FIRQ
;     code won't mind register DP being changed.
;       ex. ZX0_DISABLE_DISABLING_INTERRUPTS
;
zx0_decompress
                   ifndef ZX0_DISABLE_SAVE_REGS
                   pshs cc,dp          ; save registers
                   endc

                   ifndef ZX0_DISABLE_DISABLING_INTERRUPTS
                   orcc #$50           ; disable interrupts
                   endc

                   ifndef ZX0_ONE_TIME_USE
                   ldd #$ffff          ; init offset = -1
                   std >zx0_offset+2
                   endc

zx0_dp             equ */256
                   ldd #($80*256)+zx0_dp  ; init bit stream and register DP
                   tfr b,dp
                   setdp zx0_dp
                   bra zx0_literals    ; start with literals

                   ifndef ZX0_DISABLE_SAVE_REGS
zx0_eof            puls cc,dp,pc       ; restore registers and exit
                   else
zx0_eof            equ zx0_rts         ; just exit
                   endc


; 1 - copy from new offset (repeat N bytes from new offset)
zx0_new_offset     ldb #1              ; set elias = 1 (not necessary to set MSB)
                   zx0_get_1bit        ; obtain MSB offset
                   zx0_get_elias       ;  "      "   "
                   clr <zx0_code+1     ; set MSB elias for below
                   negb                ; adjust for negative offset (set carry for RORB below)
                   beq zx0_eof         ; eof? (length = 256) if so exit
                   rorb                ; last offset bit becomes first length bit
                   stb <zx0_offset+2   ; save MSB offset
                   ldb ,x+             ; load LSB offset
                   rorb                ; last offset bit becomes first length bit
                   stb <zx0_offset+3   ; save LSB offset
                   ldb #1              ; set elias = 1
                   zx0_get_elias       ; get elias but skip first bit
skip@              incb                ; elias = elias + 1
                   stb <zx0_code+2     ;  " "
                   bne zx0_copy        ;  " "
                   inc <zx0_code+1     ;  " "
zx0_copy           stx <save_x@+1      ; save reg X
zx0_code           ldx #$ffff          ; setup length
zx0_offset         leay >$ffff,u       ; calculate offset address
loop@              ldb ,y+             ; copy match
                   stb ,u+             ;  "    "
                   leax -1,x           ; decrement loop counter
                   bne loop@           ; loop until done
save_x@            ldx #$ffff          ; restore reg X
                   lsla                ; get next bit
                   bcs zx0_new_offset  ; branch if next block is new offset

; 0 - literal (copy next N bytes from compressed data)
zx0_literals       ldb #1              ; set elias = 1
                   clr <zx0_code+1     ;  "    "
                   zx0_get_1bit        ; obtain length
                   zx0_get_elias       ;  "      "
                   stb <zx0_code+2     ; save LSB elias
                   ldy <zx0_code+1     ; setup length
loop@              ldb ,x+             ; copy literals
                   stb ,u+             ;  "    "
                   leay -1,y           ; decrement loop counter
                   bne loop@           ; loop until done
                   lsla                ; get next bit
                   bcs zx0_new_offset  ; branch if next block is new offset
                   bra zx0_last_offset ; jump to last offset branch

; interlaced elias gamma coding
loop@              zx0_elias_rotate
zx0_reload         lda ,x+             ; load another group of 8 bits
                   rola
                   bcs zx0_rts
                   zx0_elias_rotate
                   bcs zx0_rts
                   zx0_elias_rotate
                   bcs zx0_rts
                   zx0_elias_rotate
                   bcc loop@
zx0_rts            rts

; 0 - copy from last offset (repeat N bytes from last offset)
zx0_last_offset    ldb #1              ; set elias = 1
                   clr <zx0_code+1     ;  "    "
                   zx0_get_1bit        ; obtain length
                   zx0_get_elias       ;  "      "
                   stb <zx0_code+2     ; save LSB elias
                   bra zx0_copy        ; go copy last offset block


; safety check
zx0_dp_end         equ */256
                   ifne zx0_dp-zx0_dp_end
                   error "zx0_decompress code crossed over DP memory space"
                   endc
