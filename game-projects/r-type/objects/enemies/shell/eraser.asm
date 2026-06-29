; ===========================================================================
; Object - effaceur de la rotonde de shells. OBJET NON DYNAMIQUE (hors pool),
; monte via _Obj_Run ObjID_shellEraser depuis le main loop ENTRE DrawTiles et
; DrawSprites. Boucle + blit inline vivent sur une PAGE CARTOUCHE -> aucune RAM
; residente consommee. La table est indexee par (subtype-1) du shell ; chaque
; shell y ecrit sa position (ShellSavePos dans shell/obj.asm, double-buffer).
; L'effaceur ne fait que blitter les old_pos non-nuls du buffer courant.
;   shellEraseTable : 14 x [old_pos_0(2), old_pos_1(2)] ; slot a 0 = vide.
; ===========================================================================
        INCLUDE "./engine/macros.asm"
Object
        ldx   #shellEraseTable
        tst   gfxlock.backBuffer.id      ; selectionne l'old_pos du buffer courant (cf mask.asm)
        beq   @loop                       ; id==0 -> old_pos_0 (slot+0)
        leax  2,x                         ; id!=0 -> old_pos_1 (slot+2)
@loop   ldd   ,x                          ; D = position a effacer ; 0 = slot vide
        beq   @next
        suba  #1                          ; image_center_offset du Img_shell_mask
        pshs  x                           ; DRS_XYToAddress/blit clobbent X
        jsr   DRS_XYToAddress             ; -> glb_screen_location_2 = adresse ecran
        ldu   glb_screen_location_2       ; etendu (objet sur page cartouche)
        jsr   ShellMaskBlit               ; stamp uni a U
        puls  x
@next   leax  4,x                         ; slot suivant (4 o/slot)
        cmpx  #shellEraseTable_end
        blo   @loop
        rts

; --- blit compile, copie de generated-code/shellmask/Img_shell_mask_0_ND0.asm
; --- entree: U = adresse ecran ; stamp uniforme ; auto-suffisant ; RTS
ShellMaskBlit
	LEAU 322,U

	LDD #$ffff
	STD 118,U
	STD 78,U
	STD 38,U
	LDX #$ffff
	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	STD -42,U
	STD -82,U
	STD -122,U
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU 322,U

	LDD #$ffff
	STD 117,U
	STD 77,U
	STD 37,U
	LDX #$ffff
	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	PSHU A,X
	LEAU -37,U

	STD -43,U
	STD -83,U
	STD -123,U
	PSHU A,X
	RTS

