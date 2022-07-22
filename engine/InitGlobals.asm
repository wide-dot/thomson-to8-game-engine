
InitGlobals
        ldd   #0

        ; clear direct_page data
        ldx   #dp
        lda   #0
!       sta   ,x+
        cmpx  #dp+256
        bne   <

        lda   #screen_left
        sta   glb_camera_x_offset
        lda   #screen_top
        sta   glb_camera_y_offset

        lda   #1
        sta   glb_alphaTiles
        rts