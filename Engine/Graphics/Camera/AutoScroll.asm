* ---------------------------------------------------------------------------
* AutoScroll - Subroutine to automate camera move
*
*   This function move camera and check submap limit.
*
* input REG : none
*
* ---------------------------------------------------------------------------

        INCLUDE "./Engine/Graphics/Camera/AutoScroll.equ" 

glb_camera_x_min                    fdb   $0000             ; min and max are initialized at submap loading
glb_camera_y_min                    fdb   $0000
glb_camera_x_max                    fdb   $0000
glb_camera_y_max                    fdb   $0000  
glb_vp_x_min                        fdb   $0000             ; min and max are initialized at submap loading
glb_vp_y_min                        fdb   $0000
glb_vp_x_max                        fdb   $0000
glb_vp_y_max                        fdb   $0000

glb_auto_scroll_state               fcb   scroll_state_stop ; tell engine to enter a scroll mode
glb_auto_scroll_frames              fdb   $0000             ; number of auto scroll frames
glb_auto_scroll_step                fdb   $0000             ; msb: nb of pixel moves per frame, lsb: nb of sub pixel moves per frame (8 bit decimal, 1/256 resolution)
glb_auto_scroll_step_remainder16bit fcb   $00               ; should stay at 0, used for 16bit operation
glb_auto_scroll_step_remainder      fdb   $0000             ; msb: nb of pixel moves per frame, lsb: nb of sub pixel moves per frame (8 bit decimal, 1/256 resolution)

AutoScroll
        lda   glb_auto_scroll_state                         ; check if auto scroll is set
        beq   ATS_Return
        ldd   glb_auto_scroll_frames
        subd  #1
        bmi  ATS_Stop                                      ; check if auto scroll is still running
        
ATS_Up
        std   glb_auto_scroll_frames
        lda   glb_auto_scroll_state
        deca
        bne   ATS_Down  
        ldd   glb_auto_scroll_step_remainder                ; this code allow
        addd  glb_auto_scroll_step                          ; sub pixel move by
        std   glb_auto_scroll_step_remainder                ; storing remainder
        ldd   <glb_camera_y_pos
        subd  glb_auto_scroll_step_remainder16bit    
        clr   glb_auto_scroll_step_remainder   
        cmpd  glb_camera_y_min
        blt   ATS_Stop
        std   <glb_camera_y_pos
        rts
        
ATS_Down
        deca
        bne   ATS_Left
        ldd   glb_auto_scroll_step_remainder
        addd  glb_auto_scroll_step
        std   glb_auto_scroll_step_remainder
        ldd   <glb_camera_y_pos
        addd  glb_auto_scroll_step_remainder16bit
        clr   glb_auto_scroll_step_remainder
        cmpd  glb_camera_y_max
        bgt   ATS_Stop      
        std   <glb_camera_y_pos    
        rts

ATS_Stop
        ldd   #0
        sta   glb_auto_scroll_state 
        std   glb_auto_scroll_frames        
        std   glb_auto_scroll_step       
        std   glb_auto_scroll_step_remainder
ATS_Return
        rts 

ATS_Left
        deca
        bne   ATS_Right
        ldd   glb_auto_scroll_step_remainder
        addd  glb_auto_scroll_step
        std   glb_auto_scroll_step_remainder
        ldd   <glb_camera_x_pos
        subd  glb_auto_scroll_step_remainder16bit
        clr   glb_auto_scroll_step_remainder
        cmpd  glb_camera_x_min
        blt   ATS_Stop      
        std   <glb_camera_x_pos    
        rts

ATS_Right
        deca
        bne   ATS_Return
        ldd   glb_auto_scroll_step_remainder
        addd  glb_auto_scroll_step
        std   glb_auto_scroll_step_remainder
        ldd   <glb_camera_x_pos
        addd  glb_auto_scroll_step_remainder16bit
        clr   glb_auto_scroll_step_remainder
        cmpd  glb_camera_x_max
        bgt   ATS_Stop      
        std   <glb_camera_x_pos    
        rts                   
        