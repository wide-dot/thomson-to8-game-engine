* ---------------------------------------------------------------------------
* PalRaster_1c
* ------------
* Change a single palette color at the end of each screen line
* until all values of the source table are read
* ---------------------------------------------------------------------------

PalRas_page   fdb $00   ; raster data page
PalRas_start  fdb $0000 ; raster data start address (data is $0bgr b=blue g=green r=red)
PalRas_end    fdb $0000 ; raster data end address                           

        setdp $E7

PalRaster_1c 
        lda   PalRas_page
         _SetCartPageA                 ; load Raster data page
        ldx   PalRas_start

        lda   #32        
!       bita  <$E7
        beq   <                        ; while spot is not in a visible screen col
!       bita  <$E7 
        bne   <                        ; while spot is in a visible screen col
        mul                            ; tempo
        mul                            ; tempo
        nop                            ; tempo
!       tfr   a,b                      ; tempo
        tfr   a,b                      ; tempo
        tfr   a,b                      ; tempo
        ldd   1,x
        std   >*+8
        lda   ,x        
        sta   <$DB
        ldd   #0
        stb   <$DA 
        sta   <$DA
        leax  3,x
        cmpx  PalRas_end
        bne   <
        rts

        setdp dp/256
