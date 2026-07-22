        opt   c
 ifndef RoadStreamDecode_included
RoadStreamDecode_included equ 1

* ======================================================================
* RoadStreamDecode.asm — décodeur DIFF/KEYFRAME (game-mode road-stream)
*
* REMPLACE SparseProjection+LinearInterp au runtime. Au lieu de calculer la
* projection, on LIT des frames (Dense_Buffer) précalculées hors-ligne et
* streamées depuis des pages cartouche (objets code-only RoadStreamP0..PN,
* 1 page logique = 1 objet de 16384 o, base $0000 garantie).
*
* Données produites par tools/road_pack.py --emit-build :
*   - chunks      : objects/road-stream-data/chunk_NN.{asm,bin}  (pages cart)
*   - index       : objects/road-stream-data/<circuit>_index.asm (RÉSIDENT)
*                   RoadStream_Index : par frame [fcb chunk][fdb addr]
*                   RoadStream_NbFrames / _S / _KF / _NbChunks (EQU)
*
* FORMAT (cf. doc 42 §2). Record (1er octet) :
*   $00..$60 = DIFF      : n(1) min_y(1) [ Y(1) flags(2) width(2) extra(2) ] × n
*   $FE      = KEYFRAME  : $FE min_y(1) [ flags(2) width(2) extra(2) ] × (96-min_y)
*   $FF      = NEXT-PAGE  : (chunk++ ; mount Obj_Index_Page[ObjID_RoadStreamP0+chunk] ; ptr=$0000)
*   (n ≤ 96 < $FE : pas de collision de type.)
*
* MAPPING position -> frame (= ce que road_pack a échantillonné /S) :
*   global_sub = segment_idx*16 + nibble ; nibble = (track_pos+2)>>4
*   frame = global_sub / RoadStream_S        (S=2 -> >>1)
*
* MODES :
*   - forward (conduite) : applique (target-cur) records depuis le pointeur.
*   - seek   (boot/wrap) : saute au keyframe <= cible via l'index, rejoue jusqu'à cible.
*     (keyframe garanti tous les KF frames ; kf = target & ~(KF-1), KF=64.)
*
* ÉCRIT : Dense_Buffer[Y*6] (triplets) + Proj_min_y. (= ce que lit DrawFrameRoad.)
*
* CONVENTION : labels préfixés RSD_ (lwasm 4.24 casse les @-locales dans les
* fichiers incluant LotusCarState.struct.asm). Décodeur RÉSIDENT obligatoire :
* il lit les pages chunk dans la fenêtre $0000-$3FFF, donc ne peut y vivre.
* ======================================================================
        INCLUDE "./engine/struct/LotusCarState.struct.asm"

* --- État résident du décodeur ---
RSD_cur_frame   fdb   $FFFF       ; frame actuellement dans Dense_Buffer ($FFFF = aucune)
RSD_target      fdb   0           ; frame cible calculée cette frame
RSD_chunk       fcb   0           ; pointeur forward : index de chunk (0..NbChunks-1)
RSD_ptr         fdb   0           ; pointeur forward : X dans la page (prochain record)
RSD_count       fcb   0           ; compteur de boucle (scratch)

* ----------------------------------------------------------------------
* RoadStreamDecode — point d'entrée (1×/frame, avant DrawFrameRoad)
* ----------------------------------------------------------------------
RoadStreamDecode
        * --- target = (segment_idx*16 + nibble) / S ---
        * Lire le nibble EN PREMIER (dans un scratch) : `lda track_pos+2,u`
        * écraserait l'octet FORT de segment_idx*16 si fait après le produit
        * (bug initial : target prenait track_pos[2]>>4 comme octet fort -> bonds).
        ldu   #PlayerOne_State
        lda   LotusCarState.track_pos+2,u
        lsra
        lsra
        lsra
        lsra                                ; A = nibble (0..15)
        sta   RSD_count                     ; scratch = nibble
        ldd   LotusCarState.segment_idx,u   ; D = segment_idx
        aslb
        rola
        aslb
        rola
        aslb
        rola
        aslb
        rola                                ; D = segment_idx*16 (A=high intact, low nibble de B = 0)
        addb  RSD_count                     ; B += nibble (pas de carry : low nibble = 0)
        lsra                                ; D >>= 1  (S=2)
        rorb
        std   RSD_target

        * --- dispatch : égal / forward / seek ---
        cmpd  RSD_cur_frame
        beq   RSD_done                      ; même frame -> Dense_Buffer déjà valide
        bhi   RSD_forward                   ; target > cur -> avance forward
        * sinon target < cur (wrap circuit, ou sentinel $FFFF au boot) -> seek

RSD_seek
        ldd   RSD_target
        andb  #$C0                          ; kf = target & ~(KF-1)  (KF=64)
        pshs  d                             ; sauve kf
        aslb
        rola                                ; D = kf*2
        addd  ,s++                          ; D = kf*3
        addd  #RoadStream_Index
        tfr   d,x                           ; X -> entrée index de kf
        lda   ,x                            ; chunk
        sta   RSD_chunk
        ldd   1,x                           ; addr
        std   RSD_ptr
        ldd   RSD_target
        andb  #$C0                          ; D = kf
        subd  #1                            ; cur = kf-1 (advance produira kf en 1er)
        std   RSD_cur_frame
        * FIX kf=0 : cur = 0-1 = $FFFF ferait sortir la boucle forward (bhs non
        * signe : $FFFF >= target) SANS rien appliquer -> Dense_Buffer jamais
        * ecrit au boot / au wrap circuit. On applique donc TOUJOURS le record
        * keyframe ici (advance_one pose cur = kf, correct pour tout kf), puis
        * forward rejoue les diffs kf+1..target. (Fix valide au runtime dans
        * lotus-adnz, commit 3b3adbf — meme fichier.)
        bsr   RSD_advance_one
        * tombe dans forward : rejoue les diffs jusqu'à target

RSD_forward
        ldd   RSD_cur_frame
        cmpd  RSD_target
        bhs   RSD_done                      ; cur >= target -> terminé
        bsr   RSD_advance_one
        bra   RSD_forward
RSD_done
        rts

* ----------------------------------------------------------------------
* RSD_advance_one — applique 1 record (frame cur+1) au Dense_Buffer
*   gère $FF (NEXT-PAGE) en re-montant la page suivante, sans incrémenter.
* ----------------------------------------------------------------------
RSD_advance_one
RSD_remount
        ldb   RSD_chunk
        ldx   #Obj_Index_Page+ObjID_RoadStreamP0
        lda   b,x                           ; A = n° page physique du chunk
        _SetCartPageA                       ; monte la page dans $0000-$3FFF
        ldx   RSD_ptr
        lda   ,x                            ; type de record
        cmpa  #$FF
        bne   RSD_not_np
        * NEXT-PAGE : chunk++, ptr=$0000, remonter et relire
        inc   RSD_chunk
        ldd   #0
        std   RSD_ptr
        bra   RSD_remount
RSD_not_np
        cmpa  #$FE
        lbeq  RSD_apply_kf

        * --- DIFF : A = n_changes ---
        ldb   1,x                           ; min_y
        stb   Proj_min_y
        leax  2,x                           ; X -> 1er change
        sta   RSD_count
        beq   RSD_rec_done                  ; 0 ligne changée (cas plat) -> rien à écrire
RSD_diff_loop
        ldb   ,x+                           ; B = Y (numéro de scanline)
        lda   #6
        mul                                 ; D = Y*6
        addd  #Dense_Buffer
        tfr   d,y                           ; Y = dest dans Dense_Buffer
        ldd   ,x++
        std   ,y++                          ; flags
        ldd   ,x++
        std   ,y++                          ; width
        ldd   ,x++
        std   ,y++                          ; extra
        dec   RSD_count
        bne   RSD_diff_loop
RSD_rec_done
        stx   RSD_ptr
        ldd   RSD_cur_frame
        addd  #1
        std   RSD_cur_frame
        rts

        * --- KEYFRAME : recopie (96-min_y) triplets contigus ---
RSD_apply_kf
        ldb   1,x                           ; min_y
        stb   Proj_min_y
        lda   #6
        mul                                 ; D = min_y*6
        addd  #Dense_Buffer
        tfr   d,y                           ; Y = dest base
        lda   #96
        suba  Proj_min_y                    ; A = nb triplets (96-min_y)
        sta   RSD_count
        leax  2,x                           ; X -> 1er triplet
RSD_kf_loop
        ldd   ,x++
        std   ,y++                          ; flags
        ldd   ,x++
        std   ,y++                          ; width
        ldd   ,x++
        std   ,y++                          ; extra
        dec   RSD_count
        bne   RSD_kf_loop
        stx   RSD_ptr
        ldd   RSD_cur_frame
        addd  #1
        std   RSD_cur_frame
        rts

 endc
