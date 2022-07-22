* ---------------------------------------------------------------------------
* Spritemap - Dynamically allocate sprites based on a map
*
* input REG : none
*
* ---------------------------------------------------------------------------

        INCLUDE "./engine/graphics/tilemap/data-types/spritemap.equ" 

glb_spritemap_obj             fdb   0
glb_spritemap_addr            fdb   0
glb_spritemap_page            fcb   0
glb_spritemap_index           fdb   0
glb_spritemap_index_old       fdb   0
spritemap_cur_index_end       fdb   0
spritemap_cur_index           fdb   0
spritemap_cur_index_old       fdb   0
spritemap_cur_index_old_end   fdb   0

Spritemap
        lda   glb_spritemap_page
        ldy   glb_spritemap_addr
        _SetCartPageA        

        ; Transform a camera position into an index to spritemap table
        leau  spmap_map,y
        stu   dyn2+1
        ldb   spmap_tile_size_divider_x,y
        stb   @dynb1+1
	ldd   <glb_camera_x_pos
	subd  spmap_x_pos,y
@dynb1  bra   *+2
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd
        _lsrd                                                
dyn2    addd  #0                       ; (dynamic) add map data address to index
        
        cmpd  glb_spritemap_index_old  ; check old index value in map
        bne   @continue
	rts                            ; index is the same so return
@continue

	; Read Spritemap and allocate new sprites
	std   spritemap_cur_index
	addd  spmap_vp_tiles_x,y
	std   spritemap_cur_index_end

	ldd   glb_spritemap_index_old
	std   spritemap_cur_index_old
	addd  spmap_vp_tiles_x,y
	std   spritemap_cur_index_old_end

	ldu   spritemap_cur_index
	stu   glb_spritemap_index_old

@loop	lda   ,u+                      ; or process new sprite
	beq   @next                    ; no sprite at this map index
	cmpu  spritemap_cur_index_old
	bhi   @a                       ; skip
@do     jsr   SingleObjLoad            ; return a free object in x
	cmpx  #0
	beq   @rts                     ; no more free sprite available
	sta   subtype,x                ; store sprite img id in subtype
	lda   glb_spritemap_obj
	sta   id,x
        lda   render_flags,x
        ora   #render_playfieldcoord_mask
        sta   render_flags,x
	tfr   u,d
	subd  dyn2+1
	decb
	lda   smpap_tile_x_size,y
	mul
	addd  #screen_left+8+4
	std   x_pos,x
	ldd   #$0067
	std   y_pos,x
	bra   @next
@a      cmpu  spritemap_cur_index_old_end
	bhs   @do                      ; process new sprite
@next	cmpu  spritemap_cur_index_end  ; is the end of sprites in viewport ?
	bls   @loop
@rts	rts
