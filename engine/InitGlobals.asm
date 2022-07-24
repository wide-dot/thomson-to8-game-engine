
InitGlobals
        ldd   #0

        ; clear direct_page data
        ldx   #dp
        lda   #0
!       sta   ,x+
        cmpx  #dp+256
        bne   <

 ifdef DrawSprites
        ldd   #screen_left
        std   glb_camera_x_offset
        ldd   #screen_top
        std   glb_camera_y_offset
 endc

        lda   #1
        sta   glb_alphaTiles
        rts