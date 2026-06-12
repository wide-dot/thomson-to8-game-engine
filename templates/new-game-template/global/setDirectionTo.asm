; -----------------------------------------------------------------------------
; setDirectionTo
; --------------
; input
; X : target object
; U : source object
;
; output
; Y : offset to preset data
; -----------------------------------------------------------------------------

setDirectionTo ; 0x2189
        ldd   y_pos,u
        addd  #6
        subd  y_pos,x
        blo   LAB_0000_21b5            ; branch if (source.y_pos + 8) < target.y_pos

        ldd   y_pos,u
        subd  #6 
        subd  y_pos,x
        bhs   LAB_0000_21ca            ; branch if (source.y_pos - 8) >= target.y_pos

        ldd   x_pos,u
        subd  x_pos,x
        bhs   LAB_0000_21b1            ; branch if source.x >= target.x_pos

        ldy   #$10                     ; target is on right in a vertical area of -7 +8 px
        rts

LAB_0000_21b1
        ldy   #$30                     ; target is on left in a vertical area of -7 +8 px
        rts

LAB_0000_21b5 ; target is on bottom
        ldd   x_pos,u
        addd  #3
        subd  x_pos,x
        blo   LAB_0000_21e0            ; branch if (source.x_pos + 8) < target.x_pos

        ldd   x_pos,u
        subd  #3
        subd  x_pos,x
        bhs   LAB_0000_2203            ; branch if (source.x_pos - 8) >= target.x_pos

        ldy   #$20                     ; target is on top in an horizontal area of -7 +8 px
        rts

LAB_0000_21ca ; target is on top
        ldd   x_pos,u
        addd  #3
        subd  x_pos,x
        blo   LAB_0000_2226            ; branch if (source.x_pos + 8) < target.x_pos

        ldd   x_pos,u
        subd  #3
        subd  x_pos,x
        lbhs  LAB_0000_2249            ; branch if (source.x_pos - 8) >= target.x_pos

        ldy   #$00                     ; target is on bottom in an horizontal area of -7 +8 px
        rts

LAB_0000_21e0 ; target is bootom right
        ldd   y_pos,x
        subd  y_pos,u
        std   glb_d0
        ldd   x_pos,x
        subd  x_pos,u
        _asld
        subd  glb_d0
        addd  #24
        cmpd  #48
        blo   LAB_0000_21fb
        tsta
        bpl   LAB_0000_21ff
        ldy   #$1C
        rts

LAB_0000_21fb
        ldy   #$18
        rts

LAB_0000_21ff
        ldy   #$14
        rts

LAB_0000_2203 ; target is bottom left
        ldd   y_pos,x
        subd  y_pos,u
        std   glb_d0
        ldd   x_pos,u
        subd  x_pos,x
        _asld
        subd  glb_d0
        addd  #24
        cmpd  #48
        blo   LAB_0000_221e
        tsta
        bpl   LAB_0000_2222
        ldy   #$24
        rts

LAB_0000_221e
        ldy   #$28
        rts

LAB_0000_2222
        ldy   #$2C
        rts

LAB_0000_2226 ; target is top right
        ldd   y_pos,u
        subd  y_pos,x
        std   glb_d0
        ldd   x_pos,x
        subd  x_pos,u
        _asld
        subd  glb_d0
        addd  #24
        cmpd  #48
        blo   LAB_0000_2241
        tsta
        bpl   LAB_0000_2245
        ldy   #$04
        rts

LAB_0000_2241
        ldy   #$08
        rts

LAB_0000_2245
        ldy   #$0C
        rts

LAB_0000_2249 ; target is top left
        ldd   y_pos,u
        subd  y_pos,x
        std   glb_d0
        ldd   x_pos,u
        subd  x_pos,x
        _asld
        subd  glb_d0
        addd  #24
        cmpd  #48
        blo   LAB_0000_2264
        tsta
        bpl   LAB_0000_2268
        ldy   #$3C
        rts

LAB_0000_2264
        ldy   #$38
        rts

LAB_0000_2268
        ldy   #$34
        rts
