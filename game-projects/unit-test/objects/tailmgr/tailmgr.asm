; ===========================================================================
; tailmgr (banc de test) - MASTER fan-out COMPLET : 1 objet engine bg-erase,
; TailDrawAll/TailEraseAll eclatent vers 19 tails via les VRAIS blits compiles
; bg-erase (BCKDRAW save+draw, ERASE restore), buffer de fond sur la page.
; Chaine de test a positions fixes (validation rendu + save/restore).
; ===========================================================================
        INCLUDE "./engine/macros.asm"

TM_N     equ 19
TM_SLICE equ 128                     ; octets buffer par element (max saved ~103)
TM_NCELL equ TM_N*2                  ; cellules engine (128 o = 2 cellules/element)
TM_BOXW  equ 40                      ; bbox chaine (x_size)
TM_BOXH  equ 90                      ; bbox chaine (y_size)
TM_CENT  equ 2                       ; image_center_offset des tails

Object
        lda   routine,u
        beq   Init
        jmp   Run

Init
        _GetCartPageA
        ldb   id,u
        ldx   #Img_Page_Index
        sta   b,x
        sta   TMMf
        sta   TMMf+3
        ldd   #TMImg
        std   image_set,u
        lda   #60                    ; ancre ecran de la bbox master
        sta   x_pixel,u
        lda   #36
        sta   y_pixel,u
        ldb   #6
        stb   priority,u
        lda   #render_hide_mask      ; cache jusqu'a Run (evite draw avant setup)
        sta   render_flags,u
        lda   #1
        sta   routine,u
        jmp   DisplaySprite

Run
        clr   render_flags,u         ; bg-erase, coords ecran, visible
        lda   #1
        sta   glb_force_sprite_refresh ; TEST : force erase+draw chaque trame
        ; --- mouvement de test : oscillation horizontale (valide l'erase) ---
        lda   TMShiftX
        tst   TMShiftDir
        bne   @dec
        inca
        cmpa  #40
        blo   >
        lda   #1
        sta   TMShiftDir
        lda   #40
        bra   >
@dec    deca
        bne   >
        clr   TMShiftDir
!       sta   TMShiftX
        jmp   DisplaySprite

; --- image-set fabrique : bg-erase -> parites {0,2} (B0,B1) ---
TMImg
        fcb   TMSub-TMImg,TMSub-TMImg,TMSub-TMImg,TMSub-TMImg
        fcb   TM_BOXW,TM_BOXH,0
TMSub
        fcb   TMMf-TMSub             ; [0] B0
        fcb   0                      ; [1] D0
        fcb   TMMf-TMSub             ; [2] B1
        fcb   0                      ; [3] D1
        fcb   0,0                    ; x1,y1 off
TMMf
        fcb   0                      ; page_draw (patche)
        fdb   TailDrawAll
        fcb   0                      ; page_erase (patche)
        fdb   TailEraseAll
        fcb   TM_NCELL               ; erase_nb_cell : tas cellules engine (pas de buffer page)

; ===========================================================================
; TailDrawAll - appele par DrawSprites. Etat de boucle en variables PAGE (la
; page est mappee ici). BCKDRAW clobbe tout (S restaure via glb_register_s).
; ===========================================================================
TailDrawAll
        sty   TMcellY               ; Y = haut region cellules (BgBufferAlloc)
        jsr   TM_BufOff
        clr   TMi
@loop
        ; --- pointeur position table[TMi] ---
        lda   TMi
        ldb   #3
        mul
        ldx   #TMPos
        leax  d,x                    ; X -> [x_pixel,y_pixel,img]
        ; --- index dispatch = img*4 + parite*2 (parite = (x+shift)&1) ---
        ldb   2,x
        lslb
        lslb
        lda   ,x
        adda  TMShiftX
        anda  #1
        beq   >
        addb  #2
!       stb   TMidx
        ; --- adresse ecran ---
        lda   ,x
        adda  TMShiftX               ; decalage de test
        suba  #TM_CENT
        ldb   1,x
        pshs  x
        jsr   DRS_XYToAddress        ; -> glb_screen_location_2/1
        puls  x
        ; --- Y = haut du slice buffer de l'element TMi ---
        jsr   TM_SlicePtr            ; Y = buffer_top[buf][TMi]
        ; --- appel BCKDRAW (Y=buffer, U=ecran) -> U=bgdata ---
        ldu   <glb_screen_location_2
        ldx   #TMDrawTab
        ldb   TMidx
        ldx   b,x
        jsr   ,x                     ; clobbe tout, retourne U=bgdata
        ; --- stocke bgdata + erase_rtn de l'element TMi ---
        jsr   TM_RecPtr              ; X = &record[buf][TMi] (4 o : bgdata,erase)
        stu   ,x                     ; bgdata
        ldu   #TMEraseTab
        ldb   TMidx
        ldu   b,u
        stu   2,x                    ; erase_rtn
        inc   TMi
        lda   TMi
        cmpa  #TM_N
        lblo  @loop
        ; U pour le free engine : bas de region +16 (l'engine fait -16 puis
        ; arrondit a la cellule -> retombe sur cell_start aligne)
        ldd   TMcellY
        subd  #TM_N*TM_SLICE-16
        tfr   d,u
        rts

; ===========================================================================
; TailEraseAll - appele par EraseSprites. Restaure les 19 en ORDRE INVERSE.
; ===========================================================================
TailEraseAll
        jsr   TM_BufOff             ; buffer courant (erase tourne AVANT le draw !)
        lda   #TM_N-1
        sta   TMi
@loop
        jsr   TM_RecPtr              ; X = &record[buf][TMi]
        ldu   ,x                     ; bgdata
        beq   @next
        ldx   2,x                    ; erase_rtn
        jsr   ,x                     ; U=bgdata -> restaure
@next
        dec   TMi
        bpl   @loop
        rts

; --- helpers (etat sur la page) ------------------------------------------
; TM_BufOff : range dans TMbufhi le hi-offset du bloc buffer du buffer courant
TM_BufOff
        clr   TMbufsel
        lda   gfxlock.backBuffer.id
        beq   >
        lda   #1
        sta   TMbufsel
!       rts

; TM_SlicePtr : Y = TMcellY - TMi*SLICE (haut du slice de l'element, tas engine)
TM_SlicePtr
        lda   TMi
        ldb   #TM_SLICE
        mul                          ; D = TMi*SLICE
        pshs  d
        ldd   TMcellY
        subd  ,s++
        tfr   d,y
        rts

; TM_RecPtr : X = TMRec + bufsel*(N*4) + TMi*4
TM_RecPtr
        lda   TMi
        ldb   #4
        mul
        addd  #TMRec
        tst   TMbufsel
        beq   >
        addd  #TM_N*4
!       tfr   d,x
        rts

; --- data / buffers sur la page ------------------------------------------
TMi        fcb 0
TMidx      fcb 0
TMbufsel   fcb 0
TMShiftX   fcb 0
TMShiftDir fcb 0
TMcellY    fdb 0

; chaine de test : 19 x [x_pixel, y_pixel, img(0..3)]
TMPos
        fcb 60,40,0
        fcb 66,44,0
        fcb 72,48,1
        fcb 78,52,1
        fcb 84,56,2
        fcb 90,60,2
        fcb 96,64,0
        fcb 102,68,0
        fcb 108,72,1
        fcb 114,76,1
        fcb 120,80,2
        fcb 126,84,2
        fcb 132,88,0
        fcb 138,92,0
        fcb 144,96,1
        fcb 150,100,1
        fcb 156,104,2
        fcb 162,108,2
        fcb 168,112,3

TMRec      fill 0,2*TM_N*4           ; records [bgdata(2),erase_rtn(2)] x 19 x 2 buffers

        INCLUDE "./objects/tailmgr/tailmgr_blits.asm"
