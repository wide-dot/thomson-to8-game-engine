; Thomson TO8 - Memory map

; -----------------------------------------------------------------------------
; system addresses

; mc6846
map.MC6846.CSR      equ $E7C0 ; (bit2) set mute
map.MC6846.CRC      equ $E7C1
map.MC6846.DDRC     equ $E7C2
map.MC6846.PRC      equ $E7C3 ; (bit0) set half ram page 0 (low or high) in video area ($4000-$5FFF)
map.MC6846.CSR2     equ $E7C4
map.MC6846.TCR      equ $E7C5 ; irq timer ctrl
map.MC6846.TMSB     equ $E7C6 ; irq timer MSB
map.MC6846.TLSB     equ $E7C7 ; irq timer LSB

; mc6821 system
map.MC6821.PRA      equ $E7C8
map.MC6821.PRB      equ $E7C9
map.MC6821.CRA      equ $E7CA
map.MC6821.CRB      equ $E7CB

; mc6821 music and game
map.MC6821.PRA1     equ $E7CC
map.MC6821.PRA2     equ $E7CD
map.MC6821.CRA1     equ $E7CE
map.MC6821.CRA2     equ $E7CF

; thmfc01 gate controler floppy disk
map.THMFC01.STAT0   equ $E7D0
map.THMFC01.CMD0    equ $E7D0
map.THMFC01.STAT1   equ $E7D1
map.THMFC01.CMD1    equ $E7D1
map.THMFC01.CMD2    equ $E7D2
map.THMFC01.WDATA   equ $E7D3
map.THMFC01.RDATA   equ $E7D3
map.THMFC01.WCLK    equ $E7D4
map.THMFC01.WSECT   equ $E7D5
map.THMFC01.TRCK    equ $E7D6
map.THMFC01.CELL    equ $E7D7

; ef9369 palette
map.EF9369.D        equ $E7DA
map.EF9369.A        equ $E7DB

; cf74021 gate array page mode - (TO8D: EFG2021FN)
map.CF74021.LGAMOD  equ $E7DC
map.CF74021.SYS2    equ $E7DD ; (bit0-3) set screen border color, (bit6-7) set onscreen video memory page
map.CF74021.COM     equ $E7E4
map.CF74021.DATA    equ $E7E5 ; (bit0-4) set ram page in data area ($A000-$DFFF)
map.CF74021.CART    equ $E7E6 ; (bit0-4) set page in cartridge area ($0000-$3FFF), (bit5) set ram over cartridge, (bit6) enable write
map.CF74021.SYS1    equ $E7E7 ; (bit4) set ram over data area

; extension port
map.EXTPORT         equ $E7
map.IEEE488         equ $E7F0 ; to E7F7
map.EF5860.CTRL     equ $E7F2 ; MIDI
map.EF5860.TX       equ $E7F3 ; MIDI
 ifndef SOUND_CARD_PROTOTYPE
map.YM2413.A        equ $E7FC
map.YM2413.D        equ $E7FD
 ifndef SN76489_JUMPER_LOW
map.SN76489.D       equ $E7F7
 else
map.SN76489.D       equ $E7F6
 endc
 else
map.YM2413.A        equ $E7FC
map.YM2413.D        equ $E7FD
 ifndef SN76489_JUMPER_LOW
map.SN76489.D       equ $E7FF
 else
map.SN76489.D       equ $E7FE
 endc
 endc
map.MEA8000.D       equ $E7FE
map.MEA8000.A       equ $E7FF

; ROM routines
map.DKCONT          equ $E004 ; TO:DKCO, MO:SWI $26
map.DKBOOT          equ $E007 ; boot
map.DKFMT           equ $E00A ; format
map.LECFA           equ $E00D ; read FAT
map.RECFI           equ $E010 ; search file
map.RECUP           equ $E010 ; clear file
map.ECRSE           equ $E010 ; sector write
map.ALLOD           equ $E019 ; catalog file allocation
map.ALLOB           equ $E01C ; bloc allocation
map.MAJCL           equ $E01F ; cluster update
map.FINTR           equ $E022 ; transfert end
map.QDDSTD          equ $E025 ; QDD std functions
map.QDDSYS          equ $E028 ; QDD sys functions

map.PUTC            equ $E803
map.GETC            equ $E806
map.KTST            equ $E809
map.DKCO            equ $E82A ; read or write floppy disk routine
map.IRQ.EXIT        equ $E830 ; to exit an irq

; system monitor registers
map.REG.DP          equ $20   ; direct page for system monitor registers
map.STATUS          equ $6019 ; status bitfield
map.DK.OPC          equ $6048 ; operation
map.DK.DRV          equ $6049 ; drive
map.DK.SEC          equ $604C ; sector
map.DK.TRK          equ $604A ; $604B ; track
map.DK.STA          equ $604E ; return status
map.DK.BUF          equ $604F ; $6050 ; data write location
map.FIRQPT          equ $6023 ; routine firq
map.TIMERPT         equ $6027 ; routine irq timer
map.CF74021.SYS1.R  equ $6081 ; reading value for map.CF74021.SYS1

; -----------------------------------------------------------------------------
; constants

map.EF5860.TX_IRQ_ON  equ %00110101 ; 8bits, no parity check, stop 1, tx interrupt
map.EF5860.TX_IRQ_OFF equ %00010101 ; 8bits, no parity check, stop 1, no interrupt
map.IRQ.ONE_FRAME     equ 312*64-1  ; one frame timer (lines*cycles_per_lines-1), timer launch at -1

; -----------------------------------------------------------------------------
; mapping to generic names

map.DAC            equ map.MC6821.PRA2
map.RND            equ map.MC6846.TMSB
