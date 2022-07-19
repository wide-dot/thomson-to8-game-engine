                                                      *; ===========================================================================
                                                      *; ---------------------------------------------------------------------------
                                                      *; Objects Manager
                                                      *; Subroutine that keeps track of any objects that need to remember
                                                      *; their state, such as monitors or enemies.
                                                      *;
                                                      *; input variables:
                                                      *;  -none-
                                                      *;
                                                      *; writes:
                                                      *;  d0, d1
                                                      *;  d2 = respawn index of object to load
                                                      *;  d6 = camera position
                                                      *;
                                                      *;  a0 = address in object placement list
                                                      *;  a2 = respawn table
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; loc_17AA4
ObjectsManager                                        *ObjectsManager:
                                                      *        moveq   #0,d0
        ; b is set by caller                          *        move.b  (Obj_placement_routine).w,d0
        ldx   #ObjectsManager_States                  *        move.w  ObjectsManager_States(pc,d0.w),d0
        jmp   [b,x]                                   *        jmp     ObjectsManager_States(pc,d0.w)
                                                      *; ===========================================================================
ObjectsManager_States                                 *ObjectsManager_States: offsetTable
        fdb   ObjectsManager_Init                     *        offsetTableEntry.w ObjectsManager_Init          ; 0
        fdb   ObjectsManager_Main                     *        offsetTableEntry.w ObjectsManager_Main          ; 2
        ;fdb   ObjectsManager_2P_Main                 *        offsetTableEntry.w ObjectsManager_2P_Main       ; 4
                                                      *; ===========================================================================
                                                      *; loc_17AB8
ObjectsManager_Init                                   *ObjectsManager_Init:
        ;                                             *        addq.b  #2,(Obj_placement_routine).w
        ;ldd   Current_ZoneAndAct                     *        move.w  (Current_ZoneAndAct).w,d0 ; If level == $0F01 (ARZ 2)...
                                                      *        ror.b   #1,d0                   ; then this yields $0F80...
                                                      *        lsr.w   #6,d0                   ; and this yields $003E.
        ldd   #0
        ldx   #Off_Objects                            *        lea     (Off_Objects).l,a0      ; Next, we load the first pointer in the object layout list pointer index,
        ldx   d,x
                                                      *        movea.l a0,a1                   ; then copy it for quicker use later.
                                                      *        adda.w  (a0,d0.w),a0            ; (Point1 * 2) + $003E
                                                      *        tst.w   (Two_player_mode).w     ; skip if not in 2-player vs mode
                                                      *        beq.s   +
                                                      *        cmpi.b  #casino_night_zone,(Current_Zone).w     ; skip if not Casino Night Zone
                                                      *        bne.s   +
                                                      *        lea     (Objects_CNZ1_2P).l,a0  ; CNZ 1 2-player object layout
                                                      *        tst.b   (Current_Act).w         ; skip if not past act 1
                                                      *        beq.s   +
                                                      *        lea     (Objects_CNZ2_2P).l,a0  ; CNZ 2 2-player object layout
                                                      *+
                                                      *        ; initialize each object load address with the first object in the layout
        stx   Obj_load_addr_right                     *        move.l  a0,(Obj_load_addr_right).w
        stx   Obj_load_addr_left                      *        move.l  a0,(Obj_load_addr_left).w
        stx   Obj_load_addr_2                         *        move.l  a0,(Obj_load_addr_2).w
        stx   Obj_load_addr_3                         *        move.l  a0,(Obj_load_addr_3).w
        ldx   #Object_Respawn_Table                   *        lea     (Object_Respawn_Table).w,a2
        ldd   #$101
        std   ,x++                                    *        move.w  #$101,(a2)+     ; the first two bytes are not used as respawn values
                                                      *        ; instead, they are used to keep track of the current respawn indexes
                                                      *
                                                      *        ; Bug: The '+7E' shouldn't be here; this loop accidentally clears an additional $7E bytes
        ldd   #0                                      *        move.w  #bytesToLcnt(Obj_respawn_data_End-Obj_respawn_data+$7E),d0 ; set loop counter
!       std   ,x++                                    *-       clr.l   (a2)+           ; loop clears all other respawn values
        cmpx  #Obj_respawn_data_End
        bne   <                                       *        dbf     d0,-
                                                      *
        ldy   #Obj_respawn_index                      *        lea     (Obj_respawn_index).w,a2        ; reset a2
        sta   glb_d2_b                                *        moveq   #0,d2
        ldd   glb_camera_x_pos                        *        move.w  (Camera_X_pos).w,d6
        subd  #$40                                    *        subi.w  #$80,d6 ; look one chunk to the left
        bcc   >                                       *        bcc.s   +       ; if the result was negative,
        ldd   #0                                      *        moveq   #0,d6   ; cap at zero
!                                                     *+
        andb  #$C0                                    *        andi.w  #$FF80,d6       ; limit to increments of $80 (width of a chunk)
        std   glb_d6
        ldx   Obj_load_addr_right                     *        movea.l (Obj_load_addr_right).w,a0      ; load address of object placement list
                                                      *
@a                                                    *-       ; at the beginning of a level this gives respawn table entries to any object that is one chunk
                                                      *        ; behind the left edge of the screen that needs to remember its state (Monitors, Badniks, etc.)
        cmpd  ,x                                      *        cmp.w   (a0),d6         ; is object's x position >= d6?
        bls   loc_17B3E                               *        bls.s   loc_17B3E       ; if yes, branch
        tst   2,x                                     *        tst.b   2(a0)   ; does the object get a respawn table entry?
        bpl   >                                       *        bpl.s   +       ; if not, branch
        lda   ,y                                      *        move.b  (a2),d2
        sta   glb_d2_b
        inca
        sta   ,y                                      *        addq.b  #1,(a2) ; respawn index of next object to the right
!                                                     *+
        leax  6,x                                     *        addq.w  #6,a0   ; next object
        ldd   glb_d6
        bra   @a                                      *        bra.s   -
                                                      *; ---------------------------------------------------------------------------
                                                      *
loc_17B3E                                             *loc_17B3E:
        stx   Obj_load_addr_right                     *        move.l  a0,(Obj_load_addr_right).w      ; remember rightmost object that has been processed, so far (we still need to look forward)
        stx   Obj_load_addr_2                         *        move.l  a0,(Obj_load_addr_2).w
        ldx   Obj_load_addr_left                      *        movea.l (Obj_load_addr_left).w,a0       ; reset a0
        subd  #$40                                    *        subi.w  #$80,d6         ; look even farther left (any object behind this is out of range)
        std   glb_d6
        bcs   loc_17B62                               *        bcs.s   loc_17B62       ; branch, if camera position would be behind level's left boundary
                                                      *
@b                                                    *-       ; count how many objects are behind the screen that are not in range and need to remember their state
        cmpd  ,x                                      *        cmp.w   (a0),d6         ; is object's x position >= d6?
        bls   loc_17B62                               *        bls.s   loc_17B62       ; if yes, branch
        tst   2,x                                     *        tst.b   2(a0)   ; does the object get a respawn table entry?
        bpl   >                                       *        bpl.s   +       ; if not, branch
        lda   1,y
        inca     
        sta   1,y                                     *        addq.b  #1,1(a2)        ; respawn index of current object to the left
                                                      *
!                                                     *+
        leax  6,x                                     *        addq.w  #6,a0
        ldd   glb_d6
        bra   @b                                      *        bra.s   -       ; continue with next object
                                                      *; ---------------------------------------------------------------------------
                                                      *
loc_17B62                                             *loc_17B62:
        stx   Obj_load_addr_left                      *        move.l  a0,(Obj_load_addr_left).w       ; remember current object from the left
        stx   Obj_load_addr_3                         *        move.l  a0,(Obj_load_addr_3).w
        ldd   #-1
        std   Camera_X_pos_last                       *        move.w  #-1,(Camera_X_pos_last).w       ; make sure ObjectsManager_GoingForward is run
                                                      *        move.w  #-1,(Camera_X_pos_last_P2).w
        ; continue                                    *        tst.w   (Two_player_mode).w     ; is it two player mode?
        ;                                             *        beq.s   ObjectsManager_Main     ; if not, branch
        ;                                             *        addq.b  #2,(Obj_placement_routine).w
        ;                                             *        bra.w   ObjectsManager_2P_Init
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_17B84
ObjectsManager_Main                                   *ObjectsManager_Main:
        ldd   glb_camera_x_pos                        *        move.w  (Camera_X_pos).w,d1
        subd  #$40                                    *        subi.w  #$80,d1
        andb  #$C0                                    *        andi.w  #$FF80,d1
        std   Camera_X_pos_coarse                     *        move.w  d1,(Camera_X_pos_coarse).w
                                                      *
        ldy   #Obj_respawn_index                      *        lea     (Obj_respawn_index).w,a2
        ldd   #0                                      *        moveq   #0,d2
        sta   glb_d2_b
        ldd   glb_camera_x_pos                        *        move.w  (Camera_X_pos).w,d6
        andb  #$C0                                    *        andi.w  #$FF80,d6
        cmpd  Camera_X_pos_last                       *        cmp.w   (Camera_X_pos_last).w,d6        ; is the X range the same as last time?
        lbeq  ObjectsManager_SameXRange               *        beq.w   ObjectsManager_SameXRange       ; if yes, branch (rts)
        bge   ObjectsManager_GoingForward             *        bge.s   ObjectsManager_GoingForward     ; if new pos is greater than old pos, branch
                                                      *        ; if the player is moving back
        std   Camera_X_pos_last                       *        move.w  d6,(Camera_X_pos_last).w        ; remember current position for next time
        ldx   Obj_load_addr_left                      *        movea.l (Obj_load_addr_left).w,a0       ; get current object from the left
        subd  #$40                                    *        subi.w  #$80,d6         ; look one chunk to the left
        bcs   loc_17BE6                               *        bcs.s   loc_17BE6       ; branch, if camera position would be behind level's left boundary
        std   glb_d6
                                                      *
@c                                                    *-       ; load all objects left of the screen that are now in range
        cmpd  -6,x                                    *        cmp.w   -6(a0),d6       ; is the previous object's X pos less than d6?
        bge   loc_17BE6                               *        bge.s   loc_17BE6       ; if it is, branch
        leax  -6,x                                    *        subq.w  #6,a0           ; get object's address
        tst   2,x                                     *        tst.b   2(a0)   ; does the object get a respawn table entry?
        bpl   >                                       *        bpl.s   +       ; if not, branch
        lda   1,y
        deca
        sta   1,y                                     *        subq.b  #1,1(a2)        ; respawn index of this object
        sta   glb_d2_b                                *        move.b  1(a2),d2
!                                                     *+
        jsr   ChkLoadObj                              *        bsr.w   ChkLoadObj      ; load object
        bne   >                                       *        bne.s   +               ; branch, if SST is full
        leax  -6,x                                    *        subq.w  #6,a0
        ldd   glb_d6
        bra   @c                                      *        bra.s   -       ; continue with previous object
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *+       ; undo a few things, if the object couldn't load
        tst   2,x                                     *        tst.b   2(a0)   ; does the object get a respawn table entry?
        bpl   >                                       *        bpl.s   +       ; if not, branch
        lda   1,y
        inca
        sta   1,y                                     *        addq.b  #1,1(a2)        ; since we didn't load the object, undo last change
!                                            *+
        leax  6,x                                     *        addq.w  #6,a0   ; go back to last object
        ldd   glb_d6
                                                      *
loc_17BE6                                             *loc_17BE6:
        stx   Obj_load_addr_left                      *        move.l  a0,(Obj_load_addr_left).w       ; remember current object from the left
        ldx   Obj_load_addr_right                     *        movea.l (Obj_load_addr_right).w,a0      ; get next object from the right
        addd  #$300
        std   glb_d6                                  *        addi.w  #$300,d6        ; look two chunks beyond the right edge of the screen
                                                      *
@d                                                    *-       ; subtract number of objects that have been moved out of range (from the right side)
        cmpd  -6,x                                    *        cmp.w   -6(a0),d6       ; is the previous object's X pos less than d6?
        bgt   loc_17C04                               *        bgt.s   loc_17C04       ; if it is, branch
        tst   -4,x                                    *        tst.b   -4(a0)  ; does the previous object get a respawn table entry?
        bpl   >                                       *        bpl.s   +       ; if not, branch
        lda   ,y
        deca
        sta   ,y                                      *        subq.b  #1,(a2)         ; respawn index of next object to the right
!                                                     *+
        leax  -6,x                                    *        subq.w  #6,a0
        ldd   glb_d6
        bra   @d                                      *        bra.s   -       ; continue with previous object
                                                      *; ---------------------------------------------------------------------------
                                                      *
loc_17C04                                             *loc_17C04:
        stx   Obj_load_addr_right                     *        move.l  a0,(Obj_load_addr_right).w      ; remember next object from the right
        rts                                           *        rts
                                                      *; ---------------------------------------------------------------------------
                                                      *
ObjectsManager_GoingForward                           *ObjectsManager_GoingForward:
        std   Camera_X_pos_last                       *        move.w  d6,(Camera_X_pos_last).w
        ldx   Obj_load_addr_right                     *        movea.l (Obj_load_addr_right).w,a0      ; get next object from the right
        addd  #$200                                   *        addi.w  #$280,d6        ; look two chunks forward
        std   glb_d6
                                                      *
@e                                                    *-       ; load all objects right of the screen that are now in range
        ldd   glb_d6
        cmpd  ,x                                      *        cmp.w   (a0),d6         ; is object's x position >= d6?
        bls   loc_17C2A                               *        bls.s   loc_17C2A       ; if yes, branch
        tst   2,x                                     *        tst.b   2(a0)   ; does the object get a respawn table entry?
        bpl   >                                       *        bpl.s   +       ; if not, branch
        lda   ,y
        sta   glb_d2_b                                *        move.b  (a2),d2         ; respawn index of this object
        inc   ,y                                      *        addq.b  #1,(a2)         ; respawn index of next object to the right
!                                                     *+
        jsr   ChkLoadObj                              *        bsr.w   ChkLoadObj      ; load object (and get address of next object)
        beq   @e                                      *        beq.s   -       ; continue loading objects, if the SST isn't full
                                                      *
loc_17C2A                                             *loc_17C2A:
        stx   Obj_load_addr_right                     *        move.l  a0,(Obj_load_addr_right).w      ; remember next object from the right
        ldx   Obj_load_addr_left                      *        movea.l (Obj_load_addr_left).w,a0       ; get current object from the left
        subd  #$300                                   *        subi.w  #$300,d6        ; look one chunk behind the left edge of the screen
        std   glb_d6
        bcs   loc_17C4A                               *        bcs.s   loc_17C4A       ; branch, if camera position would be behind level's left boundary
                                                      *
@f                                                    *-       ; subtract number of objects that have been moved out of range (from the left)
        cmpd  ,x                                      *        cmp.w   (a0),d6         ; is object's x position >= d6?
        bls   loc_17C4A                               *        bls.s   loc_17C4A       ; if yes, branch
        tst   2,x                                     *        tst.b   2(a0)   ; does the object get a respawn table entry?
        bpl   >                                       *        bpl.s   +       ; if not, branch
        lda   1,y
        inca
        sta   1,y                                     *        addq.b  #1,1(a2)        ; respawn index of next object to the left
!                                                     *+
        leax  6,x                                     *        addq.w  #6,a0
        ldd   glb_d6
        bra   @f                                      *        bra.s   -       ; continue with previous object
                                                      *; ---------------------------------------------------------------------------
                                                      *
loc_17C4A                                             *loc_17C4A:
        stx   Obj_load_addr_left                      *        move.l  a0,(Obj_load_addr_left).w       ; remember current object from the left
                                                      *
ObjectsManager_SameXRange                             *ObjectsManager_SameXRange:
        rts                                           *        rts
                                                      *; ---------------------------------------------------------------------------
                                                      *; loc_17C50
                                                      *ObjectsManager_2P_Init:
                                                      *        moveq   #-1,d0
                                                      *        move.l  d0,(unk_F780).w
                                                      *        move.l  d0,(unk_F780+4).w
                                                      *        move.l  d0,(unk_F780+8).w
                                                      *        move.l  d0,(Camera_X_pos_last_P2).w     ; both words that this sets to -1 are overwritten directly underneath, so this line is rather pointless...
                                                      *        move.w  #0,(Camera_X_pos_last).w
                                                      *        move.w  #0,(Camera_X_pos_last_P2).w
                                                      *        lea     (Obj_respawn_index).w,a2
                                                      *        move.w  (a2),(Obj_respawn_index_P2).w   ; mirrior first two bytes (respawn indices) for player 2(?)
                                                      *        moveq   #0,d2
                                                      *        ; run initialization for player 1
                                                      *        lea     (Obj_respawn_index).w,a5
                                                      *        lea     (Obj_load_addr_right).w,a4
                                                      *        lea     (unk_F786).w,a1 ; = -1, -1, -1
                                                      *        lea     (unk_F789).w,a6 ; = -1, -1, -1
                                                      *        moveq   #-2,d6
                                                      *        bsr.w   ObjMan2P_GoingForward
                                                      *        lea     (unk_F786).w,a1
                                                      *        moveq   #-1,d6
                                                      *        bsr.w   ObjMan2P_GoingForward
                                                      *        lea     (unk_F786).w,a1
                                                      *        moveq   #0,d6
                                                      *        bsr.w   ObjMan2P_GoingForward
                                                      *        ; run initialization for player 2
                                                      *        lea     (Obj_respawn_index_P2).w,a5
                                                      *        lea     (Obj_load_addr_2).w,a4
                                                      *        lea     (unk_F789).w,a1
                                                      *        lea     (unk_F786).w,a6
                                                      *        moveq   #-2,d6
                                                      *        bsr.w   ObjMan2P_GoingForward
                                                      *        lea     (unk_F789).w,a1
                                                      *        moveq   #-1,d6
                                                      *        bsr.w   ObjMan2P_GoingForward
                                                      *        lea     (unk_F789).w,a1
                                                      *        moveq   #0,d6
                                                      *        bsr.w   ObjMan2P_GoingForward
                                                      *
                                                      *; loc_17CCC
                                                      *ObjectsManager_2P_Main:
                                                      *        move.w  (Camera_X_pos).w,d1
                                                      *        andi.w  #$FF00,d1
                                                      *        move.w  d1,(Camera_X_pos_coarse).w
                                                      *
                                                      *        move.w  (Camera_X_pos_P2).w,d1
                                                      *        andi.w  #$FF00,d1
                                                      *        move.w  d1,(Camera_X_pos_coarse_P2).w
                                                      *
                                                      *        move.b  (Camera_X_pos).w,d6     ; get upper byte of camera positon
                                                      *        andi.w  #$FF,d6
                                                      *        move.w  (Camera_X_pos_last).w,d0
                                                      *        cmp.w   (Camera_X_pos_last).w,d6        ; is the X range the same as last time?
                                                      *        beq.s   +                               ; if yes, branch
                                                      *        move.w  d6,(Camera_X_pos_last).w        ; remember current position for next time
                                                      *        lea     (Obj_respawn_index).w,a5
                                                      *        lea     (Obj_load_addr_right).w,a4
                                                      *        lea     (unk_F786).w,a1
                                                      *        lea     (unk_F789).w,a6
                                                      *        bsr.s   ObjectsManager_2P_Run
                                                      *+
                                                      *        move.b  (Camera_X_pos_P2).w,d6  ; get upper byte of camera positon
                                                      *        andi.w  #$FF,d6
                                                      *        move.w  (Camera_X_pos_last_P2).w,d0
                                                      *        cmp.w   (Camera_X_pos_last_P2).w,d6     ; is the X range the same as last time?
                                                      *        beq.s   return_17D34                    ; if yes, branch (rts)
                                                      *        move.w  d6,(Camera_X_pos_last_P2).w
                                                      *        lea     (Obj_respawn_index_P2).w,a5
                                                      *        lea     (Obj_load_addr_2).w,a4
                                                      *        lea     (unk_F789).w,a1
                                                      *        lea     (unk_F786).w,a6
                                                      *        bsr.s   ObjectsManager_2P_Run
                                                      *
                                                      *return_17D34:
                                                      *        rts
                                                      *; ===========================================================================
                                                      *
                                                      *ObjectsManager_2P_Run:
                                                      *        lea     (Obj_respawn_index).w,a2
                                                      *        moveq   #0,d2
                                                      *        cmp.w   d0,d6                           ; is the X range the same as last time?
                                                      *        beq.w   ObjectsManager_SameXRange       ; if yes, branch (rts)
                                                      *        bge.w   ObjMan2P_GoingForward   ; if new pos is greater than old pos, branch
                                                      *        ; if the player is moving back
                                                      *        move.b  2(a1),d2
                                                      *        move.b  1(a1),2(a1)
                                                      *        move.b  (a1),1(a1)
                                                      *        move.b  d6,(a1)
                                                      *        cmp.b   (a6),d2
                                                      *        beq.s   +
                                                      *        cmp.b   1(a6),d2
                                                      *        beq.s   +
                                                      *        cmp.b   2(a6),d2
                                                      *        beq.s   +
                                                      *        bsr.w   ObjectsManager_2P_UnkSub3
                                                      *        bra.s   loc_17D70
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *+
                                                      *        bsr.w   ObjMan_2P_UnkSub2
                                                      *
                                                      *loc_17D70:
                                                      *        bsr.w   ObjMan_2P_UnkSub1
                                                      *        bne.s   loc_17D94       ; if whatever checks were just performed were all not equal, branch
                                                      *        movea.l 4(a4),a0
                                                      *
                                                      *-
                                                      *        cmp.b   -6(a0),d6
                                                      *        bne.s   loc_17D8E
                                                      *        tst.b   -4(a0)
                                                      *        bpl.s   +
                                                      *        subq.b  #1,1(a5)
                                                      *+
                                                      *        subq.w  #6,a0
                                                      *        bra.s   -
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_17D8E:
                                                      *        move.l  a0,4(a4)
                                                      *        bra.s   loc_17DCA
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_17D94:
                                                      *        movea.l 4(a4),a0
                                                      *        move.b  d6,(a1)
                                                      *
                                                      *-
                                                      *        cmp.b   -6(a0),d6
                                                      *        bne.s   loc_17DC6
                                                      *        subq.w  #6,a0
                                                      *        tst.b   2(a0)
                                                      *        bpl.s   +
                                                      *        subq.b  #1,1(a5)
                                                      *        move.b  1(a5),d2
                                                      *+
                                                      *        bsr.w   ChkLoadObj_2P
                                                      *        bne.s   loc_17DBA
                                                      *        subq.w  #6,a0
                                                      *        bra.s   -
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_17DBA:
                                                      *        tst.b   2(a0)
                                                      *        bpl.s   +
                                                      *        addq.b  #1,1(a5)
                                                      *+
                                                      *        addq.w  #6,a0
                                                      *
                                                      *loc_17DC6:
                                                      *        move.l  a0,4(a4)
                                                      *
                                                      *loc_17DCA:
                                                      *        movea.l (a4),a0
                                                      *        addq.w  #3,d6
                                                      *
                                                      *-
                                                      *        cmp.b   -6(a0),d6
                                                      *        bne.s   loc_17DE0
                                                      *        tst.b   -4(a0)
                                                      *        bpl.s   +
                                                      *        subq.b  #1,(a5)
                                                      *+
                                                      *        subq.w  #6,a0
                                                      *        bra.s   -
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *loc_17DE0:
                                                      *        move.l  a0,(a4)
                                                      *        rts
                                                      *; ===========================================================================
                                                      *;loc_17DE4:
                                                      *ObjMan2P_GoingForward:
                                                      *        addq.w  #2,d6           ; look forward two chunks
                                                      *
                                                      *        move.b  (a1),d2         ; shift positions in array left once
                                                      *        move.b  1(a1),(a1)      ; nearest chunk to the right
                                                      *        move.b  2(a1),1(a1)     ; middle chunk to the right
                                                      *        move.b  d6,2(a1)        ; farthest chunk to the right
                                                      *
                                                      *        cmp.b   (a6),d2         ; compare farthset distance
                                                      *        beq.s   +
                                                      *        cmp.b   1(a6),d2
                                                      *        beq.s   +
                                                      *        cmp.b   2(a6),d2
                                                      *        beq.s   +
                                                      *
                                                      *        bsr.w   ObjectsManager_2P_UnkSub3       ; if not, run this sub-routine
                                                      *        bra.s   loc_17E10
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *+
                                                      *        bsr.w   ObjMan_2P_UnkSub2
                                                      *
                                                      *loc_17E10:
                                                      *        bsr.w   ObjMan_2P_UnkSub1
                                                      *        bne.s   loc_17E2C       ; if whatever checks were just performed were all not equal, branch
                                                      *        movea.l (a4),a0
                                                      *
                                                      *-
                                                      *        cmp.b   (a0),d6
                                                      *        bne.s   loc_17E28
                                                      *        tst.b   2(a0)   ; does the object get a respawn table entry?
                                                      *        bpl.s   +       ; if not, branch
                                                      *        addq.b  #1,(a5)
                                                      *+
                                                      *        addq.w  #6,a0
                                                      *        bra.s   -
                                                      *; ===========================================================================
                                                      *
                                                      *loc_17E28:
                                                      *        move.l  a0,(a4)
                                                      *        bra.s   loc_17E46
                                                      *; ===========================================================================
                                                      *
                                                      *loc_17E2C:
                                                      *        movea.l (a4),a0
                                                      *        move.b  d6,(a1)
                                                      *
                                                      *-
                                                      *        cmp.b   (a0),d6
                                                      *        bne.s   loc_17E44
                                                      *        tst.b   2(a0)   ; does the object get a respawn table entry?
                                                      *        bpl.s   +       ; if not, branch
                                                      *        move.b  (a5),d2
                                                      *        addq.b  #1,(a5)
                                                      *+
                                                      *        bsr.w   ChkLoadObj_2P
                                                      *        beq.s   -
                                                      *
                                                      *loc_17E44:
                                                      *        move.l  a0,(a4)
                                                      *
                                                      *loc_17E46:
                                                      *        movea.l 4(a4),a0
                                                      *        subq.w  #3,d6
                                                      *        bcs.s   loc_17E60
                                                      *
                                                      *loc_17E4E:
                                                      *        cmp.b   (a0),d6
                                                      *        bne.s   loc_17E60
                                                      *        tst.b   2(a0)
                                                      *        bpl.s   loc_17E5C
                                                      *        addq.b  #1,1(a5)
                                                      *
                                                      *loc_17E5C:
                                                      *        addq.w  #6,a0
                                                      *        bra.s   loc_17E4E
                                                      *; ===========================================================================
                                                      *
                                                      *loc_17E60:
                                                      *        move.l  a0,4(a4)
                                                      *        rts
                                                      *; ===========================================================================
                                                      *;loc_17E66:
                                                      *ObjMan_2P_UnkSub1:
                                                      *        move.l  a1,-(sp)
                                                      *        lea     (unk_F780).w,a1
                                                      *        cmp.b   (a1)+,d6
                                                      *        beq.s   +
                                                      *        cmp.b   (a1)+,d6
                                                      *        beq.s   +
                                                      *        cmp.b   (a1)+,d6
                                                      *        beq.s   +
                                                      *        cmp.b   (a1)+,d6
                                                      *        beq.s   +
                                                      *        cmp.b   (a1)+,d6
                                                      *        beq.s   +
                                                      *        cmp.b   (a1)+,d6
                                                      *        beq.s   +
                                                      *        moveq   #1,d0
                                                      *+
                                                      *        movea.l (sp)+,a1
                                                      *        rts
                                                      *; ===========================================================================
                                                      *;loc_17E8A:
                                                      *ObjMan_2P_UnkSub2:
                                                      *        lea     (unk_F780).w,a1
                                                      *        lea     (Dynamic_Object_RAM_2P_End).w,a3
                                                      *        tst.b   (a1)+
                                                      *        bmi.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$C*object_size).w,a3
                                                      *        tst.b   (a1)+
                                                      *        bmi.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$18*object_size).w,a3
                                                      *        tst.b   (a1)+
                                                      *        bmi.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$24*object_size).w,a3
                                                      *        tst.b   (a1)+
                                                      *        bmi.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$30*object_size).w,a3
                                                      *        tst.b   (a1)+
                                                      *        bmi.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$3C*object_size).w,a3
                                                      *        tst.b   (a1)+
                                                      *        bmi.s   +
                                                      *        nop
                                                      *        nop
                                                      *+
                                                      *        subq.w  #1,a1
                                                      *        rts
                                                      *; ===========================================================================
                                                      *; this sub-routine appears to determine which 12 byte block of object RAM
                                                      *; corresponds to the current out-of-range camera positon (in d2) and deletes
                                                      *; the objects in this block. This most likely takes over the functionality
                                                      *; of markObjGone, as that routine isn't called in two player mode.
                                                      *;loc_17EC6:
                                                      *ObjectsManager_2P_UnkSub3:
                                                      *        lea     (unk_F780).w,a1
                                                      *        lea     (Dynamic_Object_RAM_2P_End).w,a3
                                                      *        cmp.b   (a1)+,d2
                                                      *        beq.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$C*object_size).w,a3
                                                      *        cmp.b   (a1)+,d2
                                                      *        beq.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$18*object_size).w,a3
                                                      *        cmp.b   (a1)+,d2
                                                      *        beq.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$24*object_size).w,a3
                                                      *        cmp.b   (a1)+,d2
                                                      *        beq.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$30*object_size).w,a3
                                                      *        cmp.b   (a1)+,d2
                                                      *        beq.s   +
                                                      *        lea     (Dynamic_Object_RAM_2P_End+$3C*object_size).w,a3
                                                      *        cmp.b   (a1)+,d2
                                                      *        beq.s   +
                                                      *        nop
                                                      *        nop
                                                      *+
                                                      *        move.b  #-1,-(a1)
                                                      *        movem.l a1/a3,-(sp)
                                                      *        moveq   #0,d1           ; used later to delete objects
                                                      *        moveq   #$C-1,d2
                                                      *
                                                      *;loc_17F0A:
                                                      *ObjMan2P_UnkSub3_DeleteBlockLoop:
                                                      *        tst.b   (a3)
                                                      *        beq.s   ObjMan2P_UnkSub3_DeleteBlock_SkipObj    ; branch if slot is empty
                                                      *        movea.l a3,a1
                                                      *        moveq   #0,d0
                                                      *        move.b  respawn_index(a1),d0    ; does object remember its state?
                                                      *        beq.s   +                       ; if not, branch
                                                      *        bclr    #7,2(a2,d0.w)   ; else, clear entry in respawn table
                                                      *
                                                      *        ; inlined DeleteObject2:
                                                      *+
                                                      *        moveq   #bytesToLcnt(next_object),d0 ; we want to clear up to the next object
                                                      *        ; note: d1 is already 0
                                                      *
                                                      *        ; delete the object by setting all of its bytes to 0
                                                      *-       move.l  d1,(a1)+
                                                      *        dbf     d0,-
                                                      *    if object_size&3
                                                      *        move.w  d1,(a1)+
                                                      *    endif
                                                      *
                                                      *;loc_17F26:
                                                      *ObjMan2P_UnkSub3_DeleteBlock_SkipObj:
                                                      *        lea     next_object(a3),a3 ; a3=object
                                                      *        dbf     d2,ObjMan2P_UnkSub3_DeleteBlockLoop
                                                      *        moveq   #0,d2
                                                      *        movem.l (sp)+,a1/a3
                                                      *        rts
                                                      *; ===========================================================================

                                                      *; ---------------------------------------------------------------------------
                                                      *; Subroutine to check if an object needs to be loaded.
                                                      *;
                                                      *; input variables:
                                                      *;  d2 = respawn index of object to be loaded
                                                      *;
                                                      *;  a0 = address in object placement list
                                                      *;  a2 = object respawn table
                                                      *;
                                                      *; writes:
                                                      *;  d0, d1
                                                      *;  a1 = object
                                                      *; ---------------------------------------------------------------------------
                                                      *;loc_17F36:
ChkLoadObj                                            *ChkLoadObj:
        tst   2,x                                     *        tst.b   2(a0)   ; does the object get a respawn table entry?
        bpl   >                                       *        bpl.s   +       ; if not, branch
        ldb   glb_d2_b
        addb  #2
        lda   b,y
        bpl   >
        ;                                             *        bset    #7,2(a2,d2.w)   ; mark object as loaded
        ;                                             *        beq.s   +               ; branch if it wasn't already loaded
        leax  6,x                                     *        addq.w  #6,a0   ; next object
        orcc  #%00000100 ; set zero flag              *        moveq   #0,d0   ; let the objects manager know that it can keep going
        rts                                           *        rts
!       ora   #%10000000
        sta   b,y
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *+
        jsr   _SingleObjLoad                          *        bsr.w   SingleObjLoad   ; find empty slot
        bne   @rts                                    *        bne.s   return_17F7E    ; branch, if there is no room left in the SST
        ldd   ,x++
        std   x_pos,u                                 *        move.w  (a0)+,x_pos(a1)
        ldd   ,x++                                    *        move.w  (a0)+,d0        ; there are three things stored in this word
        sta   glb_d0
        bpl   >                                       *        bpl.s   +               ; branch, if the object doesn't get a respawn table entry
        lda   glb_d2_b
        sta   respawn_index,u                         *        move.b  d2,respawn_index(a1)
!                                                     *+
        lda   glb_d0
        sta   glb_d1_b                                *        move.w  d0,d1           ; copy for later
        anda  #$F                                     *        andi.w  #$FFF,d0        ; get y-position
        std   y_pos,u                                 *        move.w  d0,y_pos(a1)
        lda   glb_d1_b
        rola
        rola
        rola
        rola                                          *        rol.w   #3,d1   ; adjust bits
        anda  #3 ; get x and y mirror flags           *        andi.b  #3,d1   ; get render flags
        sta   render_flags,u                          *        move.b  d1,render_flags(a1)
        sta   status_flags,u                          *        move.b  d1,status(a1)
        ldd   ,x++
        std   id,u ; and subtype,u                    *        _move.b (a0)+,id(a1) ; load obj
        ;                                             *        move.b  (a0)+,subtype(a1)
                                                      *        moveq   #0,d0
                                                      *
@rts                                                  *return_17F7E:
        rts                                           *        rts
                                                      *; ===========================================================================
                                                      *;loc_17F80:
                                                      *ChkLoadObj_2P:
                                                      *        tst.b   2(a0)           ; does the object get a respawn table entry?
                                                      *        bpl.s   +               ; if not, branch
                                                      *        bset    #7,2(a2,d2.w)   ; mark object as loaded
                                                      *        beq.s   +               ; branch if it wasn't already loaded
                                                      *        addq.w  #6,a0   ; next object
                                                      *        moveq   #0,d0   ; let the objects manager know that it can keep going
                                                      *        rts
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *+
                                                      *        btst    #4,2(a0)        ; the bit that's being tested for here should always be zero,
                                                      *        beq.s   +               ; but assuming it weren't and this branch isn't taken,
                                                      *        bsr.w   SingleObjLoad   ; then this object would not be loaded into one of the 12
                                                      *        bne.s   return_17FD8    ; byte blocks after Dynamic_Object_RAM_2P_End and would most
                                                      *        bra.s   ChkLoadObj_2P_LoadData  ; likely end up somwhere before this in Dynamic_Object_RAM
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *+
                                                      *        bsr.w   SingleObjLoad3  ; find empty slot in current 12 object block
                                                      *        bne.s   return_17FD8    ; branch, if there is no room left in this block
                                                      *;loc_17FAA:
                                                      *ChkLoadObj_2P_LoadData:
                                                      *        move.w  (a0)+,x_pos(a1)
                                                      *        move.w  (a0)+,d0        ; there are three things stored in this word
                                                      *        bpl.s   +               ; branch, if the object doesn't get a respawn table entry
                                                      *        move.b  d2,respawn_index(a1)
                                                      *+
                                                      *        move.w  d0,d1           ; copy for later
                                                      *        andi.w  #$FFF,d0        ; get y-position
                                                      *        move.w  d0,y_pos(a1)
                                                      *        rol.w   #3,d1   ; adjust bits
                                                      *        andi.b  #3,d1   ; get render flags
                                                      *        move.b  d1,render_flags(a1)
                                                      *        move.b  d1,status(a1)
                                                      *        _move.b (a0)+,id(a1) ; load obj
                                                      *        move.b  (a0)+,subtype(a1)
                                                      *        moveq   #0,d0
                                                      *
                                                      *return_17FD8:
                                                      *        rts
                                                      *; ===========================================================================

                                                      *; ---------------------------------------------------------------------------
                                                      *; Single object loading subroutine
                                                      *; Find an empty object array
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_17FDA: ; allocObject:
_SingleObjLoad                                        *SingleObjLoad:
        ldu   #Dynamic_Object_RAM                     *        lea     (Dynamic_Object_RAM).w,a1 ; a1=object
                                                      *        move.w  #(Dynamic_Object_RAM_End-Dynamic_Object_RAM)/object_size-1,d0 ; search to end of table
                                                      *        tst.w   (Two_player_mode).w
                                                      *        beq.s   +
                                                      *        move.w  #(Dynamic_Object_RAM_2P_End-Dynamic_Object_RAM)/object_size-1,d0 ; search to $BF00 exclusive
                                                      *
                                                      */
!       tst   ,u                                      *        tst.b   id(a1)  ; is object RAM slot empty?
        beq   @rts                                    *        beq.s   return_17FF8    ; if yes, branch
        leau  next_object,u                           *        lea     next_object(a1),a1 ; load obj address ; goto next object RAM slot
        cmpu  #Dynamic_Object_RAM_End   
        bne   <                                       *        dbf     d0,-    ; repeat until end
        ; implicit return zero when not found         *
@rts                                                  *return_17FF8:
        rts                                           *        rts
                                                      *; ===========================================================================
                                                      *; ---------------------------------------------------------------------------
                                                      *; Single object loading subroutine
                                                      *; Find an empty object array AFTER the current one in the table
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_17FFA: ; allocObjectAfterCurrent:
                                                      *SingleObjLoad2:
                                                      *        movea.l a0,a1
                                                      *        move.w  #Dynamic_Object_RAM_End,d0      ; $D000
                                                      *        sub.w   a0,d0   ; subtract current object location
                                                      *    if object_size=$40
                                                      *        lsr.w   #6,d0   ; divide by $40
                                                      *        subq.w  #1,d0   ; keep from going over the object zone
                                                      *        bcs.s   return_18014
                                                      *    else
                                                      *        lsr.w   #6,d0                   ; divide by $40
                                                      *        move.b  +(pc,d0.w),d0           ; load the right number of objects from table
                                                      *        bmi.s   return_18014            ; if negative, we have failed!
                                                      *    endif
                                                      *
                                                      *-
                                                      *        tst.b   id(a1)  ; is object RAM slot empty?
                                                      *        beq.s   return_18014    ; if yes, branch
                                                      *        lea     next_object(a1),a1 ; load obj address ; goto next object RAM slot
                                                      *        dbf     d0,-    ; repeat until end
                                                      *
                                                      *return_18014:
                                                      *        rts
                                                      *
                                                      *    if object_size<>$40
                                                      *+       dc.b -1
                                                      *.a :=   1               ; .a is the object slot we are currently processing
                                                      *.b :=   1               ; .b is used to calculate when there will be a conversion error due to object_size being > $40
                                                      *
                                                      *        rept (LevelOnly_Object_RAM-Reserved_Object_RAM_End)/object_size-1
                                                      *                if (object_size * (.a-1)) / $40 > .b+1  ; this line checks, if there would be a conversion error
                                                      *                        dc.b .a-1, .a-1                 ; and if is, it generates 2 entries to correct for the error
                                                      *                else
                                                      *                        dc.b .a-1
                                                      *                endif
                                                      *
                                                      *.b :=           (object_size * (.a-1)) / $40            ; this line adjusts .b based on the iteration count to check
                                                      *.a :=           .a+1                                    ; run interation counter
                                                      *        endm
                                                      *        even
                                                      *    endif
                                                      *; ===========================================================================
                                                      *; ---------------------------------------------------------------------------
                                                      *; Single object loading subroutine
                                                      *; Find an empty object at or within < 12 slots after a3
                                                      *; ---------------------------------------------------------------------------
                                                      *
                                                      *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                                      *
                                                      *; loc_18016:
                                                      *SingleObjLoad3:
                                                      *        movea.l a3,a1
                                                      *        move.w  #$B,d0
                                                      *
                                                      *-
                                                      *        tst.b   id(a1)  ; is object RAM slot empty?
                                                      *        beq.s   return_18028    ; if yes, branch
                                                      *        lea     next_object(a1),a1 ; load obj address ; goto next object RAM slot
                                                      *        dbf     d0,-    ; repeat until end
                                                      *
                                                      *return_18028:
                                                      *        rts
                                                      *; ===========================================================================

Camera_X_pos_last    fdb   0
Camera_X_pos_coarse  fdb   0

Obj_load_addr_right  fdb   0 ; contains the address of the next object to load when moving right
Obj_load_addr_left   fdb   0 ; contains the address of the last object loaded when moving left
Obj_load_addr_2      fdb   0
Obj_load_addr_3      fdb   0

Object_Respawn_Table
Obj_respawn_index    fdb    0      ; respawn table indices of the next objects when moving left or right for the first player
Obj_respawn_data     fill   0,$7C  ; Maximum possible number of respawn entries that S2 can handle; for stock S2, $80 is enough
Obj_respawn_data_End               ; 2 byte index + $7C is max. reachable pair value with 8bit signed adressing mode

; --------------------------------------------------------------------------------------
; Offset index of object locations
; --------------------------------------------------------------------------------------
Off_Objects
        fdb   Objects_EHZ_1
        fdb   Objects_EHZ_2

; Macro for marking the boundaries of an object layout file
ObjectLayoutBoundary macro
        fdb   $FFFF,$0000,$0000
        endm

        ObjectLayoutBoundary
Objects_EHZ_1 INCLUDEBIN "./objects/managers/objects/EHZ_1.bin"
        ObjectLayoutBoundary

        ObjectLayoutBoundary
Objects_EHZ_2 INCLUDEBIN "./objects/managers/objects/EHZ_2.bin"
        ObjectLayoutBoundary
