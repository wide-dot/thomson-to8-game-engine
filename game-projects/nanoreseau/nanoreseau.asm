;*----------------------------------------------------------------------------*
;* nanoreseau custom library for Thomson TO8/TO8D
;* based on the work by Jacques BRIGAUD (09/1999)
;* written by Benoit ROUSSEAU (02/2022)
;*----------------------------------------------------------------------------*

IRQPT       equ $6021 ; User IRQ Routine

; TODO need some test to know if this should be relocated or not
; relocate may allow to use floppy disk at the same time as the nanoreseau extension
MICOM_ID    equ $6052 ; MIcro COMputer id (NUMPOSTE)
CODE_INIT   equ $6053
CODE_OP     equ $6054 ; and $6055

MC6854      equ $E7D0 ; to $E7D7
SWITCH      equ $E7D8 ; bit 0-4 (computer id) bit 5 : MO-TO

nano_buffer fill 0,167 ; message buffer (original location in hidden video memory $5f50-$5ff7)
nano_buffer_end

;*----------------------------------------------------------------------------*
;* nanoreseau initialisation
;* Return: Z=0 (success), Z=1 (fail)
;*----------------------------------------------------------------------------*

; TODO some code is missing in Init Nano
InitNano
        ldx   #$9c40                   ; 40000 max connexion retries
@a      jsr   Init6854
	beq   @b                       ; branch if CTS is set (network OK, zero flag on)
	leax  -1,x
	bne   @a                       ; otherwise retry
	andcc #%11111011               ; max retries, init failed, set zero flag off
        rts
@b

        ldx   #nano_buffer
	lda   #0
@a      sta   ,x+                      ; clear message buffer
	cmpx  #nano_buffer_end
	bne   @a

	jsr   ReadNanoId               ; read and save computer nano id from switches

        ldx   #NanoIRQ
	stx   IRQPT                    ; set IRQ routine

        orcc  #%00000100 ; set zero flag on
        rts

;*----------------------------------------------------------------------------*
;* nanoreseau IRQ
;* DP is set at $E7 by native IRQ call
;*----------------------------------------------------------------------------*
NanoIRQ
        ldd   <MC6854+1                ; Read A=SR2 (Status Register 2) B=Data byte (first one)
        bpl   NoData                   ; branch if RDA (Receiver Data Available) is not set (bit 7)
        cmpb  MICOM_ID                 ; first data byte is the message recipient id
        bne   ReleaseExit              ; branch if not the intended recipient
        ;lda   #0                      ; TODO specify a number of retry instead of relying on arbitrary SR2 value
INT_1:  inca                           ; otherwise this message must be read
        beq   ReleaseExit              ; branch if too much retry
        ldb   <MC6854+1                ; Read SR2 (Status Register 2)
        bpl   INT_1                    ; loop if RDA (Receiver Data Available) is not set (bit 7)
        ldd   <MC6854+2                ; A=OP Code, B=Recipient
        std   CODE_OP                  ; store word
        lda   $E7C0                    ; $E7C0 (CSR)
        anda  #$01                     ; csr0=timer interrupt flag
        pshs  a                        ; TODO find puls
        ;ldu   #nano_buffer+15         ; init U=message data
	;ldy   #MICOM_ID               ; init Y=location of microcomputer id
        clr   nano_buffer+7            ; set block number=0 (wait)
        jsr   WaitRDA                  ; wait for next data, and return A=CODE_OP (sucess) or pulsa coma (failure)
        blo   ReleaseExit              ;
        cmpa  #$f0                     ; 
        ble   .A0A9                    ; 
        jsr   .A740                    ; init serial link
        stb   nano_buffer+4            ;
        clr   nano_buffer+163          ;
        clr   nano_buffer+12           ;
        clr   nano_buffer+9            ;
        bsr   ReadCmd                  ; read command from network
        blo   ExecuteCmd               ; execute command stored in B
        bsr   ExecuteCmd
        blo   .A090
        jsr   .A52A
        ldb   -6,u
        bne   .A090
        bcc   .A08E
        ldb   #$0f
        stb   -3,u
        jsr   .A41B                    ; Prise de la ligne
.A08E:  bsr   .A034                    ; Déconnexion
.A090:  tst   nano_buffer+163
        beq   ReleaseExit
        jsr   [nano_buffer+161]        ; TODO execute something
;.A099:  lda   *PIA_SYS
;        anda  #$fe
;        ora   ,s+
;        sta   *PIA_SYS
ReleaseExit
        jsr   Release
        rti
;*--------------------------------------------------
NoData  jsr   Set8bDataMode
        rti
;*--------------------------------------------------
.A0A9:  eora  #$c0
        bita  #$f0
        bne   ReleaseExit
        jsr   *(.E71F - .E700) ; Acquittement de la reception
        bra   ReleaseExit
.A0B3:  jsr   [ADCHPAG]
        bra   .A0D5
.A0B9:  jsr   *(.E77F - .E700)
        bra   .A0D5

;* Set 8 bits data mode
;*----------------------------------------------------------------------------*
Set8bDataMode
	ldd   #$c100
	std   <MC6854                  ; set Address Control Bit to access CR4 instead of Transmitter LastData
	lda   #$1e
	sta   <MC6854+3                ; set Tx WLS1 WLS2 and Rx XLS1 WLS2 to 8 bits data length
@retry  jsr   Init6854
	bne   @failed
	lda   #$82                     ; disable Tx, enable Reception IRQ
	sta   <MC6854
	rts
@failed	bita  #$10                     ; init failed, test only if SR1 CTS is 1
	bne   @retry                   ; if not retry
                                       ; otherwise proceed to release
;* Release network line
;*----------------------------------------------------------------------------*
Release
        jsr   Init6854
	lda   #$c1                     ; set Address Control Bit to access CR3 instead of CR1
	sta   <MC6854
	deca                           ; set loop-back feature (TxD is connected to RxD)
	sta   <MC6854
	rts













; *********************************************************************************************************************************************************************



;*--------------------------------------------------*
;* Analyse de la consigne courante *
;*--------------------------------------------------*
;* Entrée : U : pointe sur le message ($1F5F)
;* Sortie : A : Type de trame : $F0 : Tout est OK
;* $F4 : La longueur du message est impaire
;* $F5 : La longueur du message est de 1
;* $F8 : La longueur du message est nul
;* Reg modifié: CCR,X,U,A,B
;*--------------------------------------------------*
.A0BD:  ldx   3,u ; Lecture de la longueur des donné dans la consigne
	ldu   6,u ; Lecture de l'adresse destination/source dans la consigne
	lda   $1f64 ; Lecture du numero de la page
	beq   .A0D5 ; Si page 0 saut en A0D5
	deca
	beq   .A0D5 ; Si page 1 saut en A0D5
	deca
	beq   .A0B9 ; Si page 2 saut en A0B9
	deca
	bne   .A0B3 ; Si page 4 et + saut en A0D5
	ldd   [ADPUTIL] ; Page 3: appel de ADPUTIL
	leau  d,u ; U = U+13
.A0D5:  tfr   x,d ; Transfert de la longueur du message dans D
	leax  ,x ; Test de la longueur
	beq   .A0E8 ; Si longueur nulle saut en A0E8
	lda   #$f0 ; Initialise le code d'erreur de retour à $F0
	lsrb  ; b = b/2 (traitement par mot)
	bcc   .A0E7 ; Si pas carry (Nombre de mot paire) Saut en A0E7
	ora   #04 ; A = $F4
	leax  -1,x ; Longueur - 1
	bne   .A0E7 ; si different de 0 (longueur >1) saut en A0E7
	inca  ; A = $F5
.A0E7:  rts  ; Fin
;*--------------------------------------------------
.A0E8:  lda #$f8 ; A = $F8
	rts ; Fin
.A0EB:  ldd #$00f8
	pshs b
	bra .A123
ReadCmd ldb 2,y
	lslb
	lslb
	andb #$3c
	stb -1,u
	jsr *(.A78B - .A700)
	bra .A10D
.A0FE:  bsr .A10B
	blo .A107
	cmpa -8,u
	beq .A107
	coma
.A107:  rts
;*--------------------------------------------------
.A108:  lda #$f8
	.db $8c ; Codeop de CMPX
.A10B:  bsr .A0BD
;*--------------------------------------------------
;* Lecture d'une trame sur la liaison série
;*
;* Entrée : U : pointe sur le message
;* X : Longueur du message (peut etre nulle)
.A10D:  pshs a ; Sauvegarde A
	ldd #$c066 ; Mot d'initialistion du 6854
	std *MC_6854
	stb 1,y ; Sauvegarde le mot de commande ($2053)
	asla ; Debloc RX (a=$80)
	sta *MC_6854
	ldd #$1010 ; A=Compteur d'erreur; B=Masque (CTS)
.A11C:  deca
	beq @exit
	bitb *MC_6854 ; Lecture du status du 6854
	bne .A11C ; Si CTS=1, on boucle
.A123:  ldb #1
.A125:  inca
	beq @exit
	bitb *(MC_6854+1) ; Attente de la reception du 1er octet de la trame (adresse)
	beq .A125
	ldb *(MC_6854+2) ; lecture de la donnée
	cmpb ,y ; Est-ce egal à notre numero de poste
	bne @exit ; non, on sort
.A132:  inca
	beq @exit
	ldb *(MC_6854+1) ; Attente de l'arrivé de la donnée suivante (Data Available)
	bpl .A132
	ldd *(MC_6854+2) ; A=CodeOp; B=No du poste source
	cmpb 3,y ; Le No source est correcte?
	bne @exit ; Non -> on sort
	sta   CODE_OP ; Stoc le CodeOp en mémoire ($2054)
	puls cc ; Retrait des flag du type de message
	bmi .A162 ; Si Flag N positionné, on attendait qu'un entête (on sort)
	bne .A14D ; Si Flag Z Positionné
	lda *(MC_6854+2) ; alors lecture d'un octet en plus
	sta ,u+ ; stockage de la donnée
	blo .A162 ; si donnée négative, on sort
.A14D:  ldb *(MC_6854+1)
	bmi .A15A
	lda #6
.A153:  deca
	beq   @exit2
	ldb   MC_6854+1
	bpl   .A153
.A15A:  ldd   MC_6854+2
	std   ,u++
	leax  -2,x
	bne   .A14D
.A162:  jsr   *(.A76F - .A700)
WaitRDA
	ldd   #$0802                   ; A=7 loop of retry, B=2 SR2 Frame Valid bit
@a      deca
	beq   @exit2                   ; failed to wait a Frame Valid flag
	bitb  MC_6854+1                ; read SR2 and check Frame Valid (FV) flag
	beq   @a                       ; loop if FV is not set
	clr   MC_6854+1                ; clear CR2
	lda   MC_6854+1                ; read SR2 Receiver Data Available (RDA)
	bmi   @exit2                   ; branch if flag is set (2 bytes of data are ready)
	lda   CODE_OP
	rts
;*--------------------------------------------------
@exit   puls a
@exit2  coma
	rts

;*--------------------------------------------------
;* Envoi d'une trame sur la liaison série
;*
;* Entrée : U : pointe sur le message
;* X : Longueur du message (peut etre nulle)
; Y : Pointe sur le destinataire, source, codeop
; CC: dans la pile Type de trame à emettre
; N=1 : Emission de l'entete uniquement: SOURCE CODEOP DESTINATAIRE
; N=0 Z=0 : Emission de l'entete + trame dont la longueur est X (U=$1F60)
; N=0 Z=1 : Emission de l'entete + 1 octet + trame dont la longueur est X (U=$1F60) (longueur sur 2octets)
.A17D:  jsr ReadNanoId ; Lecture du Numero de poste du Nanoreseau (Y=$2052)
	ldd 3,y
	sta *(MC_6854+2)
	stb *(MC_6854+2)
	lda ,y
	sta *(MC_6854+2) ; envoi du Numéro de poste
	puls cc
	bmi .A1AF
	bne .A1A5
	pulu a
	sta *(MC_6854+2)
	blo .A1AF
.A196:  ldb *(MC_6854)
	bne .A1A5
	lda #$10
.A19C:  ldb *(MC_6854)
	bne .A1A5
	deca
	bne .A19C
	bra .A1AF
.A1A5:  pulu a,b
	sta *(MC_6854+2)
	stb *(MC_6854+2)
	leax -2,x
	bne .A196
.A1AF:  lda #$9e
	sta *(MC_6854+1)
.A1B3:  inca
	beq .A1BA
	ldb *MC_6854
	beq .A1B3
.A1BA:  jmp *(.A76F-.A700)
;*--------------------------------------------------
.A1BC:  .db $ff,$ff,$ff,$ff,$ff,$ff
.A1C2:  .ascii "SCRATCH DOS"
;*--------------------------------------------------
.A1CD:  ldb *L_F0
	cmpb #2
	beq .A1F6
	dec *L_F0
	bsr .A236
	blo .A209
	tstb
	beq .A1E1
	lbsr .A333
	blo .A209
.A1E1:  inc *L_F0
	bsr .A236
	blo .A209
	ldb #10
	ldx *L_E7
.A1EB:  lda b,x
	sta b,y
	decb
	bge .A1EB
	bsr .A229
	blo .A209
.A1F6:  lda #2
	sta *DK_SEC
	ldb #$14
	clra
	std *DK_TRK
	ldd *L_ED
	std *DK_BUF
	bsr .A229
	blo .A209
	clr *L_F0
.A209:  rts
;*--------------------------------------------------
.A20A:  ldx *L_ED
	stx *DK_BUF
	lda #2
	bra .A21E
.A212:  sta *L_E5
	coma
	rts
.A216:  clra
	rts
;*--------------------------------------------------
.A218:  lda #3
	ldx *L_E9
	stx *DK_BUF
.A21E:  sta *DK_SEC
	ldb #$14
	clra
	std *DK_TRK
	lda #2
	bra .A22B
;*--------------------------------------------------
.A229:  lda #8
.A22B:  sta *DK_OPC
	ldy *L_E9
	lbsr .A004
	lda #3
	rts
;*--------------------------------------------------
.A236:  bsr .A218
.A238:  blo .A212
	ldx #4
	ldy *L_E9
.A240:  ldu *L_E7
	ldb *L_F0
	cmpb #3
	bne .A24C
	leau .A1C2,pcr
.A24C:  clrb
.A24D:  cmpb #$0b
	bcc .A275
	lda b,y
	cmpa #$ff
	beq .A272
	incb
	cmpa ,u+
	beq .A24D
	leay $20,y
	leax -1,x
	bne .A240
	inc *DK_SEC
	lda *DK_SEC
	cmpa #$10
	bhi .A272
	lbsr .A004
	lda #3
	bra .A238
.A272:  clrb
	bra .A290
.A275:  ldb $0b,y
	cmpb *L_EB
	bne .A272
	ldb $0c,y
	cmpb *L_EC
	bne .A272
	ldb *DK_SEC
	lda $0d,y
	sta *L_F6
	clr *L_F5
	ldx $0e,y
	stx *L_F7
	sty *L_FA
.A290:  stb *L_F9
	bra .A216
;*--------------------------------------------------
.A294:  ldy *L_ED
	bsr .A309
.A299:  blo .A238
	stb *L_F6
	lbsr .A218
.A2A0:  blo .A299
	ldy *L_E9
	ldx #4
.A2A8:  ldb ,y
	beq .A2CD
	lda #5
	cmpb #$ff
	beq .A2CD
	leay $20,y
	leax -1,x
	bne .A2A8
	inc *DK_SEC
	lda *DK_SEC
	cmpa #$10
	bhi .A2C8
	lbsr .A004
	lda #3
	bra .A2A0
.A2C8:  lda #5
.A2CA:  jmp .A212
.A2CD:  ldx *L_E7
	ldb *L_F0
	cmpb #3
	bne .A2D9
	leax .A1C2,pcr
.A2D9:  ldb #$0a
.A2DB:  lda b,x
	sta b,y
	decb
	bge .A2DB
	lda *L_EB
	sta $0b,y
	lda *L_EC
	ldb *L_F6
	std $0c,y
	lbra .A229
;*--------------------------------------------------
.A2EF:  ldb *L_F6
	cmpb #$28
	bhi .A303
.A2F5:  tstb
.A2F6:  beq .A309
	lda b,y
	cmpa #$ff
	beq .A32B
	decb
	cmpb #$28
	bls .A2F5
.A303:  addb #2
	cmpb #$51
	bra .A2F6
.A309:  clrb
	leay $28,y
.A30D:  lda #5
	cmpb #$28
	lbhi .A212
	lda b,y
	cmpa #$ff
	beq .A326
	negb
	lda b,y
	cmpa #$ff
	beq .A326
	negb
	incb
	bra .A30D
.A326:  addb #$28
	leay -$28,y
.A32B:  clr b,y
	decb
	stb *L_F9
.A330:  lbra .A216
;*--------------------------------------------------
.A333:  lda $0d,y
	sta *L_F6
	clr ,y
	lbsr .A229
	blo .A2CA
	ldy *L_ED
	ldb *L_F6
.A343:  incb
	lda b,y
	clr b,y
	dec b,y
	tfr a,b
	cmpa #$c0
	blo .A343
	bra .A330
;*--------------------------------------------------
.A352:  ldb *L_F6
	clra
	lsrb
	std *L_FB
	inca
	sta *L_F5
	bcc .A35F
	lda #$09
.A35F:  sta *L_FA
	rts
;*--------------------------------------------------
.A362:  .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	.db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	.db $ff,$ff
;*--------------------------------------------------
.A384:  dec 8,u
	beq .A3BC
	jsr *(.A77F - .A700)
	ldx #0
.A38D:  lda ,x
	ldb ,x
	anda #$78
	asla
	eora #$80
	sta ,x
	andb #$87
	bmi .A39E
	orb #8
.A39E:  andb #$0f
	orb ,x
	stb ,x+
	cmpx #$1f40
	bne .A38D
	jsr *(.A776 - .A700)
	lda 2,u
	tst 8,u
	bpl .A3B3
	ora #4
.A3B3:  lsra
	lsra
	lsra
	blo .A3BA
	ora #$10
.A3BA:  sta 2,u
.A3BC:  ldb #$e1
	andb *PIA_SYS
	orb 2,u
	stb *PIA_SYS
	rts
;*--------------------------------------------------
.A3C5:  com 2,u
	bpl .A384
	jsr *(.A740 - .A700) ; ; Initialisation de la liaison serie
	ldb #$1e
	andb *PIA_SYS
	comb
	lda #$84
	std 1,u
	bsr .A3E8
	blo .A3EB
	ldd #$2018
	std 3,u
	clr 6,u
	clr 7,u
	inc 5,u
	jsr .A037
	blo .A3EB
.A3E8:  jmp .A031 ; Receptions de message
.A3EB:  rts
;*--------------------------------------------------
.A3EC:  sta -4,u
	clr -8,u
	jsr *(.A71F - .A700) ; Acquittement de la reception
	lda 1,u
	eora #$80
	jsr .A52C
	tst   nano_buffer+163
	beq .A402
	jsr   [nano_buffer+161]
.A402:  jsr .A69F
	lda -6,u
	beq .A417
	puls x
	lda -4,u
	cmpa #$0f
	beq .A430
	ora ,s
	sta ,s
	puls cc,dp,x,pc
;*--------------------------------------------------
.A417:  inc -6,u
	puls x,pc
;*--------------------------------------------------
;* Prise de la ligne
.A41B: ldd #$2010 ; A=Nombre de tentative min; B=Masque :  CTS
	ora ITCMPT ; Masque A avec le compteur d'IT
	anda #$3f ; Limite le temps max à 63
.A423:  bitb MC_6854 ; Test le bit CTS du 6854 (Presence Horloge)
	beq .A41B ; S'il est nulle il faut attendre
	deca ; CTS=1; On decremente le compteur d'attente
	bne .A423 ; Compteur!=0; on attend la fin de la tempo
	orcc #$50 ; Blocage des IT FIRQ et IRQ
	jmp .A749 ; Débloque la Liaison Série
;*--------------------------------------------------
.A430:  jsr .A69F
.$A433:  puls cc,dp,x
	swi
	.db INCHR ; Lecture du clavier
	cmpb #3
	bne .A43F
.A43B:  jmp [ADCTRLC]
;*--------------------------------------------------
;* Tempo aléatoire en cas d'erreur *
;*--------------------------------*
.A43F:  lda ITCMPT ; Lecture du compteur d'interuptions
	tfr a,b
	anda #$1f
	inca
.A447:  subd #1
	bne .A447
.A44C:  dec $2057 ; Décrémente le compteur d'essai d'emission
	beq .A43B ; Si on est à zéro, alors saut a la routine de traitement des erreurs
	andcc #$f0
	pshs x,dp,cc ; sauve X,DP,CC
	jsr .A76B ; Fixe DP à $A7, U=$1F5F, Y=$2052
	stb -6,u ; Range B en $1F59
	ldy 2,s ; Recupere la valeur de X mis dans Y
	lda ,y ; Lit la longueur du message
	inca ; A=longueur+1
	leau -1,u ; u-- (U=$1F5E)
	jsr *(.A760 - .A700) ; recopîe du message en $1F5F
	lda ,u
	ldb #$f0
	std 3,y ; stock D en $2055
	stb -$0b,u ; stock B en $1F54
	clr -8,u ; efface le compteur de sequence courant ($1F57)
	bsr .A41B ; prise de ligne
	tst -6,u ; Test $1F56
	beq .A430
	jsr .A5C5
	bmi .A430
	jsr *(.A79E - .A700) ; Envoie du message sur la liaison série
	ldb #$90 ; Code op attendu en retour
	jsr *(.A7B0 - .A700) ; Attente du message venant de la liaison série
	blo .A430
	bsr .A4BD ; Envoie d'un message d'acquittement
.A483:  jsr *(.A737 - .A700)
	ldd #$8010
	sta *MC_6854
	lda *L_C1
.A48C:  leax 1,x
	bne .A494
	eora #$01
	sta *(PIA_SYS+1)
.A494:  bitb *MC_6854
	bne .A48C
	jsr .A0EB ; Attente d'un message sur la liaison série
	blo .A483
	tfr a,b
	lsrb
	lsrb
	lsrb
	andb #$0e
	anda #$0f
	ldx #.A4AD
	jsr [b,x]
	bra .A483
;*--------------------------------------------------
.A4AD:  .dw .A501 ; Vas-y reçois
	.dw .A4BD ; Réenvoie du message
	.dw .A516 ; RTS ne rien faire
	.dw .A4E9 ; Vas-y emet
	.dw .A3EC ; Deconnexion
	.dw .A517 ; Excution d'une tache reseau
	.dw .A516 ; RTS ne rien faire
	.dw .A516 ; RTS ne rien faire
;*--------------------------------------------------
.A4BD:  ldd #$01a1 ; A contient le No du prochain bloc, B contient le Code op d'acquitement
	sta -8,u ; Rangement du No de bloc attendue
	jmp *(.A798 - .A700) ; Envoie du message
;*--------------------------------------------------
.A4C4:  jsr .A034 ; Deconnexion
	bra .A483
;* Vérification du Numéro de bloc reçu *
;*-------------------------------------*
.A4C9:  clr -7,u ; Efface ???????
	cmpa -8,u ; Comparaison au numero de bloc attendue
	beq .A4D7 ; Si equivalence, OK on sort
	cmpa -$0b,u ; Comparaison au Numero de bloc précédent
	bne .A4D8 ; S'il n'y a pas d'équivalence erreur
	sta -8,u ; Stockage du numero en tant que numero attendue
	inc -7,u ; Incrémente????????
.A4D7:  rts
;*--------------------------------------------------
.A4D8: coma ; Erreur :  Invertion de A
	rts ; Sortie
;*--------------------------------------------------
.A4DA:  bsr .A4C9 ; Vérification du numéro de bloc recu
	bls .A4E2 ; Si inférieur ou égal, on sort
.A4DE:  ldd -$0a,u ; Récupération de l'adresse du bloc précédent
	std 6,u ; stockage dans la case de l'adresse a remplir
.A4E2:  rts ; on sort
;*--------------------------------------------------
.A4E3:  bsr .A4DE
.A4E5:  ldb -$0b,u
	bra .A4FE
;*--------------------------------------------------
.A4E9:  bsr .A4DA ; Vérification du numero de bloc
	blo .A516 ; Si négatif, Erreur on sort
	jsr *(.A7A4 - .A700)
.A4EF:  ldd 6,u ; Récupération de l'adresse de chargement
	std -$0a,u ; Stockage de l'adresse du bloc téléchargé
	addd 3,u ; Calcul de la nouvelle adresse: Adresse + offset -> D
	std 6,u ; Mémorise la nouvelle adresse ou faut stocker les prochaines informations
.A4F7:  ldb -8,u ; Recupére le No du bloc recu
	stb -$0b,u ; Mémorise en tant que No recu
	incb ; No de bloc+1
	andb #$07 ; Masque sur No (Pas de bloc > 7)
.A4FE:  stb -8,u ; Memorise le Numéro de bloc a attendre
	rts ; On sort
;*--------------------------------------------------
;* Vas-y reçois
.A501:  jsr *(.A740 - .A700) ; Initialisation de la liaison serie
	lda   CODE_OP
	; Lecture du CodeOp
	anda #$0f
	; Garde que le No de bloc
	bsr .A4DA
	; Verifie le No de bloc et recupere l'adresse de telechargement
	blo .A516
	; Si erreur -> On sort
	jsr .A0FE
	blo .A516
	bsr .A4EF
.A512:  jmp *(.A71F - .A700) ; Acquittement de la reception
;*--------------------------------------------------
.A514:  clr 1,u
.A516:  rts
;*--------------------------------------------------
;* Traitement des tache réseau de 0 à 6
.A517:  jsr *(.A740 - .A700) ; Initialisation de la liaison serie
	jsr ReadCmd ; Reception d'un message de longueur egal à 4*(Codeop & $0f)
	blo .A514 ; si erreur on sort
	bsr .A4C9 ; Verification du numero de bloc recu
	blo .A514 ; si erreur on sort
	bsr .A4F7 ; incrementation du numero de la sequence
	bsr .A512 ; envoie d'une réponse OK avec le prochain No de bloc attendue
	lda -7,u ; Lecture du flag indiquant qu'on a recu le numero de bloc/sequence
	bne .A516 ; Si on a recu le meme numero de bloc, on sort (pourquoi???)
.A52A:  lda 1,u ; Lecture du code tache réseau
.A52C:  bmi .A516 ; Si négatif, on sort
	bita #$f8 ; test les bits 3-7
	bne .A548 ; Si != 0 (Code Tache > 7) saut en A548
	asla ; Code * 2 (pour indexation dans la table)
	ldx #.A538 ; X pointe sur la table de fonction
	jmp [a,x] ; Saut à la routine concernant le code Tache reseau
;*--------------------------------------------------
.A538:  .dw .A516 ; Rien RTS (permets d'initialiser la consigne)
	.dw .A4C4 ; Mise en attente
	.dw .A54C ; Execution du code recu dans la consigne
	.dw .A5FA ; Affichage de la chaine de caractère de la consigne (6,u)
	.dw .A3C5 ; Envoi de l'ecran du poste
	.dw .A031 ; Reception de message
	.dw .A759 ; Recopie du compte rendue
	.dw .A548 ;
;*--------------------------------------------------
.A548:  jmp [ADTRCTR] ; Saut à la procedure de traitement des fonctions > 7
.A54C:  jmp $0a,u
.A54E:  jsr *(Init6854 - .A700)
	coma
	puls b,dp,pc
;*--------------------------------------------------
.A553:  bsr .A4E3
	.db $8c ; code op pour : cmpx #$8d8d
.A556:  bsr .A4E5
.A558:  dec -5,u
	beq .A54E
	jsr .A41B ; Prise de la ligne
	bra .A56D
;*--------------------------------------------------
; B contient le code à executer :
; $B0 : EMVE - Vas-y émets
; $80 : EMVR - Vas-y reçois
; $C0 : EMDISC - Déconnecte-toi
; $00 : Appel sous attente (EMAP)
ExecuteCmd
        pshs dp,b
	jsr .A740 ;; Initialisation de la liaison serie
	jsr .A76B
	lda #6
	sta -5,u
.A56D:  ldb ,s
	beq .A587
	bpl .A5B8
	cmpb #$b0
	beq .A59A
	bmi .A5A7
	orb -3,u
	clr -8,u
	jsr *(.A798 - .A700)
	exg a,b
	jsr *(.A7AE - .A700)
.A583:  blo .A558
	puls b,dp,pc
;*--------------------------------------------------
;* Appel sous attente (EMAP)
;*--------------------------------------------------
.A587:  ldb #$d0
	stb 4,y
	bsr .A5C5
	bmi .A558
	jsr *(.A79E - .A700)
	jsr .A4F7
	jsr *(.A7AE - .A700)
	blo .A556
	puls b,dp,pc
;*--------------------------------------------------
.A59A:  jsr *(.A796 - .A700) ; Envoie d'un acquittement
	jsr .A0FE
	blo .A558
	jsr .A4EF
	clra
	puls b,dp,pc
;*--------------------------------------------------
.A5A7:  jsr *(.A796 - .A700)
	bsr .A5D3
	bmi .A558
	jsr *(.A7A4 - .A700)
	jsr .A4EF
	jsr *(.A7AE - .A700)
	blo .A553
	puls b,dp,pc
;*--------------------------------------------------
.A5B8:  ldb #$90
	jsr *(.A798 - .A700)
	ldd #$01a0
	sta -8,u
	jsr *(.A7B0 - .A700)
	bra .A583
.A5C5:  ldb -1,u
	addb #3
	andb #$3c
	stb -1,u
	lsrb
	lsrb
	orb 4,y
	jsr *(.A798 - .A700)
.A5D3:  jsr *(.A737 - .A700)
	ldb #$0f
.A5D7:  decb
	bmi .A5E6
	bita *MC_6854
	bne .A5D7
	bita *MC_6854
	bne .A5D7
	bita *MC_6854
	bne .A5D7
.A5E6:  rts
;*--------------------------------------------------
; OEE - Ordre d'envoyer l'écran
.A5E7:  bsr .A600
	jsr .A6B7
	ldb #4
	std 1,u
	ldd #$1f40
	std 4,u
	inc 6,u
	jmp .A679
;*--------------------------------------------------
.A5FA:  ldx 6,u
	bra .A605
;* Affichage du caractère contenu dans B *
;*---------------------------------------*
.A5FE:  swi
	.db OUTCHR ; Affiche le contenu de B a l'écran
.A600:  jmp .A776 ; Met la memoire ecran Forme
;* Affichage d'une chaine de caractère pointé par X *
;*--------------------------------------------------*
.A603:  swi
	.db OUTCHR ; Affiche le contenu de B a l'écran
.A605:  bsr .A600 ; Met la memoire ecran Forme
	ldb ,x+ ; Charge le caractere pointé par B
	cmpb #4 ; Est-ce la fin de la chaine de caractère
	bne .A603 ; Non->$ affichage du caractère
	rts ; Fin de la procedure

;* Read nanoreseau id
;*-------------------------------------------------------
ReadNanoId
        lda   SWITCH                   ; read nanoreseau id (switches on network interface)
	anda  #$1f                     ; maximum of 31 computers on network
	sta   MICOM_ID                 ; save current microcomputer id based on switch settings
	rts

;*-------------------------------------------------------
.A68A:  ldu #MC_6854 ; U pointe sur le MC6854
	ldd #$c100 ; A=$C1 et B=00
	std ,u ; Ecriture dans le MC6854
	lda #$1e
	sta 3,u
.A696:  jsr Init6854 ; Reset du MC6854
	beq .A6AD
	bita #$10
	bne .A696
;* RELACH - Relâche de la ligne
.A69F:  jsr Init6854
	ldd #$c180
	jsr .A752 ; Stocke D en $A7D0 et B en $2053
	deca ; A = $C0
	sta MC_6854
	rts
;*-------------------------------------------------------
.A6AD:  lda $2058
	bne .A6B6
	lda #$82
	sta ,u
.A6B6:  rts
;*-------------------------------------------------------
.A6B7:  ldb #$1c
.A6B9:  ldu #$1FA0
	stb ,u
	incb
.A6BF:  clr b,u
	decb
	bne .A6BF
	rts
;* Définition de chaine de caractere
;*-------------------------------------------------------
.A6C5:  .db $0d
	.ascii "NANORESEAU LD USTL V3 p"
	.db 4
CR_LF: .db $0a,$0d,4
;*-------------------------------------------------------
.A6E2:  clr DK_STA ; DK.STA etat courant du controleur
	lda #$0a
	sta DK_OPC ; DK.OPC mot de commande du controleur
	.org $A6EA
;* Zone précédée d'un ORG pour etre sur d'être dans la PAGE A7 *
;* pour les sauts court en page direct. *
;* *
;*---------------------------------------------------------------*
;* Point d'entré du Nanoreseau ($a6ea)
;*----------------------------
BOOT_NANO:
	pshs  u,y,x,b,a
	ldd   #INTERUPT ; D=$A041 (Adresse d'interruption du Nanoreseau)
	subd  IRQPT     ; Retrait de l'adresse d'IRQ
	beq   BOOT_1    ; Si le resultat = 0 ->$ init déja faite, saut en $A6F7
	jsr   .A60E     ; Initialisation de la cartouche Nanoreseau.
BOOT_1: jsr   .A76F     ; Initialise U=$1F5F, Y=$2052 et mise en mémoire Forme
	ldb   #$10
	bsr   .A6B9     ; Vide la zone $1FA0 + marque la longueur de la chaine au début ($AFE0)
	lda   #8
.A700:  ldb   -10,y
	cmpb  #8
	bne   BOOT_2
	ora   #$40
BOOT_2:
	std   2,u
	ldd   -3,y
	std   7,u
	ldd   #$0380
	stb   5,u
	leay  -10,y
	leau  10,u      ; U=$1FAA
	jsr   .A762     ; Recopie la chaine pointé par Y dans le Buffer pointé par U, LNG=A(*2) (X modifié)
	jsr   .A679
	puls  a,b,x,y,u,pc
;*--------------------------------------------------*
;* Acquittement de la reception d'une trame *
;*--------------------------------------------------*
;* Entrée : Rien *
;* Sortie : B : Contient le code op d'acquittement *
;* Reg modifié: CCR,B *
;*--------------------------------------------------*
.A71F:  ldb #$e0
	bsr .A796

;*----------------------------------------------------------------------------*
;* MC6854 initialisation
;* - Reset transmitter and receiver
;* - Clear transmitter and receiver statuses
;* - Flag time fill
;* - 2 Byte mode
;*
;* CR1
;*    7 |    6 |           5 |         4 |         3 |   2 |   1 |  0
;* TxRS | RxRS | Discontinue | TDSR Mode | RDSR Mode | TIE | RIE | AC
;*
;* CR2
;*   7 |        6 |        5 |       4 |              3 |        2 |        1 |   0
;* RTS | CLR TxST | CLR RxST | Tx Last | FC/TDRA Select | F/M Idle | 2/1 Byte | PSE
;*
;* Return: Z=0 (success), Z=1 (fail)
;*----------------------------------------------------------------------------*

Init6854
        ldd   #$c066                   ; CR1 ($c0) : Tx/Rx reset
	std   MC6854                   ; CR2 ($66) : Tx/Rx ST clear ; Flag time fill ; 2 Byte mode
        stb   CODE_INIT                ; store CR2 init setup
	ldd   MC6854                   ; Read SR1 and SR2
	cmpx  MC_6854+2                ; Read 2 bytes of data without affecting any registers
	cmpd  #$1000                   ; Return OK if SR1 CTS is 1 and all other SR1 and SR2 bits are 0
	rts

;*-------------------------------------------------------
.A737:  bsr Init6854
	bne .A737
	rts
;*-------------------------------------------------------
.A73C:  ldb -8,u ; Charge le No de bloc en cours
.A73E:  stb 4,y
.A740:  ldb   CODE_INIT                ; Initialisation de la liaison serie
	bmi   .A749
.A745:  bsr   Init6854
	bne   .A745
.A749:  ldd   #$c100                   ; Tx/Rx reset + Select CR3
	std   MC_6854                  ; CR3=00==> bit DTR = 0 donc signal DTR = 1
	ldd   #$40e6                   ; RX_Frame discontinue + Select CR2
.A752:  std   MC_6854                  ; RTS=1; Tx/Rx status clear; Flag Idle+2byte transfert
	stb   CODE_INIT
	rts
;*-------------------------------------------------------
.A759:  leay 10,u ; Y pointe sur la zone DATA de la consigne
	ldu ADCRDU ; Lecture de l'adresse du compte rendue
	lda ,u+ ; Lecture de la longueur du CR
.A760:  inca ; Longueur +1
	lsra ; On divise par 2 (traitement par mot de 16 bits)
.A762:  ldx ,y++ ; Lecture des informations
	stx ,u++ ; Recopie des infos en mémoire
	deca ; compteur - 1
	bne .A762 ; On boucle tant que le compteur est != 0
	bra .A76F ; Réinitialistions des pointeur U, Y, Memoire forme
.A76B:  ldb #$a7
	tfr b,dp
;*--------------------------------------------------*
;* Initialisation du contexte *
;*--------------------------------------------------*
;* Entrée : Rien
;* Sortie : U : Pointe sur le buffer de la consigne
;* Y : Pointe sur le numéro du poste
;* Mémoire écran positionné sur la mémoire Forme
;*
;* Reg modifié: CCR,Y,U,B
;*--------------------------------------------------*

; USELESS, new code use address instead of relative offset
;.A76F:  ldu #$1f5f ; Initialise U à l'adresse $1F5F:  Message reseau
;	ldy #NUMPOSTE ; Y=$2052 Adresse contenant le numéro du poste
;.A776:  ldb PIA_SYS ; Lecture du Port B du PIA Systeme
;	orb #1 ; Force la mémoire Ecran Forme
;.A77B:  stb PIA_SYS ; Positionne la mémoire ECRAN en mode texte
;	rts ; On sort

;*--------------------------------------------------*
;* Passage en mémoire ecran Texte *
;*--------------------------------------------------*
;* Entrée : Rien
;* Sortie : Rien
;* Mémoire écran positionné sur la mémoire Texte
;*
;* Reg modifié: CCR,B
;*--------------------------------------------------*
.A77F:  ldb PIA_SYS ; Lecture du Port B du PIA Systeme
	andb #$fe ; Force la mémoire Ecran Texte
	bra .A77B
.A786:  ldd TYPORD ; A=Type d'ordinateur; B=Type d'application
	std 8,u ; Rangement info dans la consigne ($1F67, $1F68)
.A78B:  lda #$f0 ; Code pour dire qu'il y a 3+N octets à envoyer
	ldx -2,u ; Charge X avec la longueur de la consigne
	leau 1,u ; U++ ($1F60)
	bne .A795 ; Si Différent de 0, Ok c'est bon
	lda #$f8 ; Code pour dire qu'il n'y a que 3 octets à envoyer
.A795:  rts
;*-------------------------------------------------------
.A796:  orb -8,u ; Ajout dans les poids Faible de B, le No de bloc suivant attendu
.A798:  bsr .A73E ; Initialise la liaison série
	lda #$f8 ; Code pour dire qu'il n'y a que 3 octets à envoyer
	bra .A7A9 ; Envoie de la réponse sur la liaison série.
.A79E:  bsr .A73C ; Init la LS
	bsr .A786 ; Initialise la consigne, le pointeur de message et le type de message à envoyer
	bra .A7A9 ; Envoi de la consigne
.A7A4:  bsr .A73C ; Init la LS
	jsr .A0BD ; Analyse la trame
.A7A9:  pshs a ; Sauvegarde du type de trame à emmetre
	jmp .A17D ; envoie de la trame sur la liaison serie
.A7AE:  ldb #$e0
.A7B0:  pshs b
	jsr .A108
	eora ,s+
	blo .A7BE
	cmpa -8,u
	beq .A7BE
	coma
.A7BE:  rts
	rts ; Derniere adresse de la cartouche Nanoreseau ($A7BF)