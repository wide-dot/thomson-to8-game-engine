GetImgIdA

        _GetCartPageA
        sta   GetImgId_Rts+1                ; backup cart page     
        ldx   #Img_Page_Index               ; call page that store imageset for this object
        ldb   id,u
        abx
        lda   ,x
        _SetCartPageA
                
        ldx   image_set,u
        lda   -1,x

GetImgId_Rts
        ldb   #$00                          ; (dynamic)
        _SetCartPageB                       ; restore data page
        rts