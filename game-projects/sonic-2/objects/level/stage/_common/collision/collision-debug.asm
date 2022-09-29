
 ; Collision debug

dbg_sensor_T        fcb 0
dbg_sensor_pos_TL
dbg_sensor_x_pos_TL fdb 0
dbg_sensor_y_pos_TL fdb 0
dbg_sensor_pos_TR
dbg_sensor_x_pos_TR fdb 0
dbg_sensor_y_pos_TR fdb 0

dbg_sensor_C        fcb 0
dbg_sensor_pos_CL
dbg_sensor_x_pos_CL fdb 0
dbg_sensor_y_pos_CL fdb 0
dbg_sensor_pos_CR
dbg_sensor_x_pos_CR fdb 0
dbg_sensor_y_pos_CR fdb 0

dbg_sensor_B        fcb 0
dbg_sensor_pos_BL
dbg_sensor_x_pos_BL fdb 0
dbg_sensor_y_pos_BL fdb 0
dbg_sensor_pos_BR
dbg_sensor_x_pos_BR fdb 0
dbg_sensor_y_pos_BR fdb 0

dbg_angle fcb 0

dbg_color fcb 0

; display slots
dbg_slot1 equ 0
dbg_slot2 equ 1
dbg_slot3 equ 2

DBG_Display
	lda   dbg_sensor_T
        beq   >
	ldx   #dbg_sensor_pos_TL
	jsr   DBG_Display_Sensor
	ldx   #dbg_sensor_pos_TR
        jsr   DBG_Display_Sensor

!	lda   dbg_sensor_C
        beq   >
	ldx   #dbg_sensor_pos_CL
	jsr   DBG_Display_Sensor
	ldx   #dbg_sensor_pos_CR
	jsr   DBG_Display_Sensor

!	lda   dbg_sensor_B
        beq   >
	ldx   #dbg_sensor_pos_BL
        lda   #$B0
        sta   dbg_color
	jsr   DBG_Display_Sensor
	ldx   #dbg_sensor_pos_BR
        lda   #$F0
        sta   dbg_color
	jsr   DBG_Display_Sensor

!       lda   dp+top_solid_bit
        cmpa  #8
        beq   >
        lda   #$BB
        bra   @a
!       lda   #$FF
@a	ldb   #dbg_slot1
        jsr   DBG_Display_Slot

        ldd   Collision_addr
        andb  #1
        bne   >
        lda   #$BB
        bra   @a
!       lda   #$FF
@a	ldb   #dbg_slot2
        jsr   DBG_Display_Slot


	;lda   dbg_angle
	;ldb   #dbg_slot3
	;jsr   DBG_Display_Slot

        rts

DBG_Display_Slot
        ldy   #$A000
        leay  b,y
        sta   ,y        
	rts

DBG_Display_Sensor
        ldd   2,x 
        addd  glb_camera_y_offset
        subd  glb_camera_y_pos        
        stb   @ypx
        ldd   ,x
        addd  glb_camera_x_offset
        subd  glb_camera_x_pos
        bcc   >
        subb  #$60
        dec   @ypx
!       tfr   b,a
        ldb   #0 ; d is loaded with xy_pixel
@ypx    equ   *-1        
        lsra                                ; x=x/2, sprites moves by 2 pixels on x axis
        lsra                                ; x=x/2, RAMA RAMB enterlace  
        bcs   @ram2                         ; Branch if write must begin in RAM2 first
@ram1
        sta   @lbyte1
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$C000                        ; (dynamic)
@lbyte1 equ   *-1
        bra   >
@ram2
        sta   @lbyte2
        lda   #40                           ; 40 bytes per line in RAMA or RAMB
        mul
        addd  #$A000                        ; (dynamic)
@lbyte2 equ   *-1      

!       tfr   d,y
        lda   ,y
        anda  #$0F
        adda  dbg_color
        sta   ,y
	rts
