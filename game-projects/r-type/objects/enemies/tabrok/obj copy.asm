; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/enemies_properties.asm"
        INCLUDE "./engine/collision/macros.asm"
        INCLUDE "./engine/collision/struct_AABB.equ"
        INCLUDE "./objects/animation/index.equ"
        INCLUDE "./global/projectile.macro.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"

AABB_0                  equ ext_variables    ; AABB struct (9 bytes)   
tabrok_0xe              equ ext_variables+9 ; 1 bytes - Shooting counter
tabrok_0x20             equ ext_variables+10 ; 1 byte (landing counter in run mode 2)
                                             ; Re-using for running / no running cycle (0x38)
tabrok_0x2e             equ ext_variables+11 ; 1 byte - 0 if player 1 is on the left, otherwise 1
tabrok_0x28             equ ext_variables+12 ; 2 bytes - gfxlock.frame.count at init time
tabrok_0x30             equ ext_variables+14 ; 2 bytes - some counter (most likely after running)
tabrok_0x38             equ ext_variables+16 ; 1 byte - next routine (used at the end of run mode 3)
tabrok_0x3a             equ ext_variables+17 ; 1 byte - missile shooting timing
tabrok_0xc              equ ext_variables+18 ; 1 byte - shouting frequency based on difficulty and table at 1x2b40

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   FUN_0000_650d_RunTabrokMode1
        fdb   AlreadyDeleted
        fdb   FUN_0000_65e3_RunTabrokMode2
        fdb   FUN_0000_66bd_RunTabrokMode3
        fdb   FUN_0000_6643_RunTabrokMode4
        fdb   FUN_0000_671b_RunTabrokPause
        fdb   FUN_0000_6792_RunTabrokMode5
        fdb   FUN_0000_6774_RunTabrokMode6
        fdb   FUN_0000_678c_RunTabrokMode7
        fdb   FUN_0000_6780_RunTabrokMode8
        fdb   FUN_0000_6859_RunTabrokMode9
        fdb   FUN_0000_692f_RunTabrokMode10
        fdb   FUN_0000_697c_RunTabrokMode11

Init
        ldb   subtype_w+1,u
        andb  #$0F
        aslb
        ldx   #PresetXYIndex
        abx
        clra
        ldb   1,x
        std   y_pos,u
        ldb   ,x
        addd  glb_camera_x_pos
        std   x_pos,u
        ldb   subtype,u
        andb  #$01
        stb   subtype,u
        ; set subtype based on preset
        ldb   #6
        stb   priority,u
        lda   #render_playfieldcoord_mask
        sta   render_flags,u
        _Collision_AddAABB AABB_0,AABB_list_ennemy
        lda   #tabrok_hitdamage                   ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  tabrok_hitbox_x,tabrok_hitbox_y       ; set hitbox xy radius
        std   AABB_0+AABB.rx,u


        ;0000:64e5 c6 44 3d 00     MOV        byte ptr [SI + 0x3d],0x0
        ;0000:64e9 8a 1e 2e 2f     MOV        BL,byte ptr [difficulty]
        ;0000:64ed 32 ff           XOR        BH,BH
        ;0000:64ef 03 db           ADD        BX,BX
        ;0000:64f1 26 8b 87        MOV        AX,word ptr ES:[BX + 0x2b40]
        ;          40 2b
        ;0000:64f6 89 44 0c        MOV        word ptr [SI + 0xc],AX

        ldb   globals.difficulty
        ldx   #tabrok_0x2b40
        lda   b,x
        sta   tabrok_0xc,u
        ldd   #Img_tabrok_7
        std   image_set,u


        ;0000:64f9 c7 44 0e        MOV        word ptr [SI + 0xe],0x0
        ;          00 00
        ;0000:64fe e8 e8 8c        CALL       FUN_0000_f1e9_RandomAX                           undefined FUN_0000_f1e9_RandomAX
        ;0000:6501 25 3f 00        AND        AX,0x3f
        ;0000:6504 c6 44 1f 00     MOV        byte ptr [SI + 0x1f],0x0    ; Damage
        ;0000:6508 c6 44 2f 1e     MOV        byte ptr [SI + 0x2f],0x1e   ; Max damage

        ; Does not seem to do anything with AX ... so skipping ... for now

        clr   tabrok_0xe,u

        inc   routine,u

        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_650d_RunTabrokMode1()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_650d_RunTabrokMode1
        ;0000:650d c6 46 2e 00     MOV        byte ptr [BP + 0x2e],0x0
        ;0000:6511 a1 24 00        MOV        AX,[0x24]
        ;0000:6514 3b 46 04        CMP        AX,word ptr [BP + 0x4]
        ;0000:6517 72 04           JC         LAB_0000_651d
        ;0000:6519 c6 46 2e 01     MOV        byte ptr [BP + 0x2e],0x1

FUN_0000_650d_RunTabrokMode1

        clr   tabrok_0x2e,u
        ldx   player1+x_pos
        cmpx  x_pos,u
        bmi   LAB_0000_651d
        ldb   #$01
        stb   tabrok_0x2e,u


        ;                     LAB_0000_651d                                   XREF[1]:     0000:6517(j)  
        ;0000:651d b8 80 ff        MOV        AX,0xff80
        ;0000:6520 e8 4f a5        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos
        ;0000:6523 b8 00 ff        MOV        AX,0xff00
        ;0000:6526 e8 60 a5        CALL       FUN_0000_0a89_MoveYPos8.8                        undefined FUN_0000_0a89_MoveYPos
        ;0000:6529 a1 b6 2e        MOV        AX,[0x2eb6_globalCounter]
        ;0000:652c 03 46 28        ADD        AX,word ptr [BP + 0x28]

LAB_0000_651d
        ;ldb   #($80*scale.XP1PX)/256
        ;lda   gfxlock.frameDrop.count
        ;mul
        ;_negd
        ;jsr   moveXPos8.8        

        ldb   #($ff*scale.YP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveYPos8.8    

        ldd   gfxlock.frame.count
        addd  tabrok_0x28,u


        ;                     LAB_0000_652f                                   XREF[1]:     0000:6929(*)  
        ;0000:652f f6 46 2e 01     TEST       byte ptr [BP + 0x2e],0x1
        ;0000:6533 75 0e           JNZ        LAB_0000_6543
        ;0000:6535 bb c8 2b        MOV        BX,0x2bc8
        ;0000:6538 a9 04 00        TEST       AX,0x4
        ;0000:653b 74 11           JZ         LAB_0000_654e
        ;0000:653d bb d4 2b        MOV        BX,0x2bd4
        ;0000:6540 e9 0b 00        JMP        LAB_0000_654e
        ;                     LAB_0000_6543                                   XREF[1]:     0000:6533(j)  
        ;0000:6543 bb 28 2c        MOV        BX,0x2c28
        ;0000:6546 a9 04 00        TEST       AX,0x4
        ;0000:6549 74 03           JZ         LAB_0000_654e
        ;0000:654b bb 34 2c        MOV        BX,0x2c34

LAB_0000_652f

        tst   tabrok_0x2e,u
        beq   LAB_0000_6543
        ldx   #Img_tabrok_15
        andb  #$04
        beq   LAB_0000_654e
        ldx   #Img_tabrok_14
        jmp   LAB_0000_654e
LAB_0000_6543
        ldx   #Img_tabrok_7
        andb  #$04
        beq   LAB_0000_654e
        ldx   #Img_tabrok_6

        ;                     LAB_0000_654e                                   XREF[3]:     0000:653b(j), 0000:6540(j), 
        ;                                                                                  0000:6549(j)  
        ;0000:654e e8 c9 04        CALL       FUN_0000_6a1a_TabrokChoosePalette                                    undefined FUN_0000_6a1a_TabrokChoosePalette()
        ;0000:6551 e8 ea 04        CALL       FUN_0000_6a3e_ShouldTabrokFire                                    undefined FUN_0000_6a3e_ShouldTabrokFire()
        ;0000:6554 bf 40 2c        MOV        DI,0x2c40
        ;0000:6557 e8 80 95        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:655a 74 09           JZ         LAB_0000_6565
        ;0000:655c c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:6560 b1 56           MOV        CL,0x56
        ;0000:6562 e8 9e a1        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                     LAB_0000_6565                                   XREF[1]:     0000:655a(j)  
        ;0000:6565 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:6568 38 46 1f        CMP        byte ptr [BP + 0x1f],AL   ; Check for damage
        ;0000:656b 72 03           JC         LAB_0000_6570
        ;0000:656d e9 74 04        JMP        FUN_0000_69e4_DestroyTabrok                                    undefined FUN_0000_69e4_DestroyTabrok()
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)

LAB_0000_654e
        stx   image_set,u
        ;jsr   FUN_0000_6a1a_TabrokChoosePalette
        jsr   FUN_0000_6a3e_ShouldTabrokFire
        lda   AABB_0+AABB.p,u
        beq   FUN_0000_69e4_DestroyTabrok        ; was killed  

        ;                     LAB_0000_6570                                   XREF[1]:     0000:656b(j)  
        ;0000:6570 ff 76 04        PUSH       word ptr [BP + 0x4]
        ;0000:6573 ff 76 08        PUSH       word ptr [BP + 0x8]
        ;0000:6576 83 46 04 fc     ADD        word ptr [BP + 0x4],-0x4
        ;0000:657a 83 46 08 e8     ADD        word ptr [BP + 0x8],-0x18
        ;0000:657e e8 eb bc        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
        ;0000:6581 8f 46 08        POP        word ptr [BP + 0x8]
        ;0000:6584 8f 46 04        POP        word ptr [BP + 0x4]
        ;0000:6587 3d fc 0d        CMP        AX,0xdfc
        ;0000:658a 72 2a           JC         LAB_0000_65b6
        ;0000:658c ff 76 04        PUSH       word ptr [BP + 0x4]
        ;0000:658f ff 76 08        PUSH       word ptr [BP + 0x8]
        ;0000:6592 8b 46 14        MOV        AX,word ptr [BP + 0x14]
        ;0000:6595 83 46 04 e8     ADD        word ptr [BP + 0x4],-0x18
        ;0000:6599 83 46 08 e8     ADD        word ptr [BP + 0x8],-0x18
        ;0000:659d e8 cc bc        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
        ;0000:65a0 8f 46 08        POP        word ptr [BP + 0x8]
        ;0000:65a3 8f 46 04        POP        word ptr [BP + 0x4]
        ;0000:65a6 3d fc 0d        CMP        AX,0xdfc
        ;0000:65a9 72 0b           JC         LAB_0000_65b6
        ;0000:65ab f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;         2f ff
        ;0000:65b0 74 03           JZ         LAB_0000_65b5
        ;0000:65b2 e9 52 04        JMP        FUN_0000_6a07_DeleteTabrok                                    undefined FUN_0000_6a07()
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                     LAB_0000_65b5                                   XREF[1]:     0000:65b0(j)  
        ;0000:65b5 c3              RET


LAB_0000_6570
        ldd   x_pos,u
        subd  #($4*scale.XP1PX)/256
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #($16*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do        
        tstb   
        lbne  LAB_0000_65b6
        ldd   x_pos,u
        subd  #($18*scale.XP1PX)/256
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #($16*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do        
        tstb   
        lbne  LAB_0000_65b6
        jmp   CommonLife

LAB_0000_65b5
        jmp   CommonLife


CommonLife
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        bmi   FUN_0000_6a07_DeleteTabrok                  ; branch if out of screen's left
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        jmp   DisplaySprite


        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                    **************************************************************
        ;                    undefined __cdecl16near FUN_0000_69e4_DestroyTabrok()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_69e4_DestroyTabrok                                   XREF[9]:     FUN_0000_650d:0000:656d(c), 
        ;                                                                                  0000:6617(c), 0000:6684(c), 
        ;                                                                                  FUN_0000_66bd:0000:66f7(c), 
        ;                                                                                  0000:674c(c), 0000:67ec(c), 
        ;                                                                                  0000:68b9(c), 0000:6963(c), 
        ;                                                                                  0000:69d1(c)  
        ;0000:69e4 e8 25 8f        CALL       FUN_0000_f90c                                    undefined FUN_0000_f90c()
        ;0000:69e7 8a 5e 06        MOV        BL,byte ptr [BP + 0x6]
        ;0000:69ea e8 51 ec        CALL       FUN_0000_563e_UnloadPalette                      undefined FUN_0000_563e_UnloadPa
        ;0000:69ed 8a 5e 3c        MOV        BL,byte ptr [BP + 0x3c]
        ;0000:69f0 e8 4b ec        CALL       FUN_0000_563e_UnloadPalette                      undefined FUN_0000_563e_UnloadPa
        ;0000:69f3 b1 53           MOV        CL,0x53
        ;0000:69f5 e8 0b 9d        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;0000:69f8 b9 bd e8        MOV        CX,0xe8bd
        ;0000:69fb ba 04 87        MOV        DX,0x8704
        ;0000:69fe e8 83 9d        CALL       FUN_0000_0784                                    undefined FUN_0000_0784()
        ;0000:6a01 c7 46 00        MOV        word ptr [BP + 0x0],0xe817
        ;         17 e8
        ;0000:6a06 c3              RET


FUN_0000_69e4_DestroyTabrok                       
        ldd   score
        addd  #tabrok_score
        std   score
        jsr   LoadObject_x ; make then die early ... to be removed
        beq   FUN_0000_6a07_DeleteTabrok
        _ldd  ObjID_explosion,explosion.subtype.big
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x

        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6a07_DeleteTabrok()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_6a07_DeleteTabrok                      XREF[10]:    FUN_0000_650d_RunTabrokMode1:000
        ;                                                                                  RunTabrokMode2:0000:6626(c), 
        ;                                                                                  0000:668e(c), 
        ;                                                                                  FUN_0000_66bd:0000:6701(c), 
        ;                                                                                  0000:6756(c), 0000:67f6(c), 
        ;                                                                                  0000:68fe(c), 0000:6972(c), 
        ;                                                                                  0000:69db(c), 0000:69e1(j)  
        ;0000:6a07 e8 02 8f        CALL       FUN_0000_f90c                                    undefined FUN_0000_f90c()
        ;0000:6a0a 8a 5e 06        MOV        BL,byte ptr [BP + 0x6]
        ;0000:6a0d e8 2e ec        CALL       FUN_0000_563e_UnloadPalette                      undefined FUN_0000_563e_UnloadPa
        ;0000:6a10 8a 5e 3c        MOV        BL,byte ptr [BP + 0x3c]
        ;0000:6a13 e8 28 ec        CALL       FUN_0000_563e_UnloadPalette                      undefined FUN_0000_563e_UnloadPa
        ;0000:6a16 e8 d3 9d        CALL       FUN_0000_07ec_UnloadManagedObject                undefined FUN_0000_07ec_UnloadMa
        ;0000:6a19 c3              RET

FUN_0000_6a07_DeleteTabrok
        lda   #2
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject


        ;                     LAB_0000_65b6                                   XREF[2]:     0000:658a(j), 0000:65a9(j)  
        ;0000:65b6 83 46 08 07     ADD        word ptr [BP + 0x8],0x7
        ;0000:65ba 81 66 08        AND        word ptr [BP + 0x8],0xfff8
        ;         f8 ff
        ;0000:65bf c7 46 20        MOV        word ptr [BP + 0x20],0xf
        ;         0f 00
        ;0000:65c4 b8 08 00        MOV        AX,0x8
        ;0000:65c7 bb 68 2b        MOV        BX,0x2b68
        ;0000:65ca f7 46 2e        TEST       word ptr [BP + 0x2e],0x1
        ;         01 00
        ;0000:65cf 75 06           JNZ        LAB_0000_65d7
        ;0000:65d1 b8 f8 ff        MOV        AX,0xfff8
        ;0000:65d4 bb 60 2b        MOV        BX,0x2b60
        ;                     LAB_0000_65d7                                   XREF[1]:     0000:65cf(j)  
        ;0000:65d7 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:65da 89 5e 22        MOV        word ptr [BP + 0x22],BX
        ;0000:65dd c7 46 00        MOV        word ptr [BP + 0x0],0x61e3
        ;         e3 61
        ;0000:65e2 c3              RET

LAB_0000_65b6

        lda   y_pos+1,u
                                        ; This is how sam divides by 6
        nega
        adda  #6
        ldb   #85
        mul
        lsra
        ldb   #6
        mul
        negb                            
                                        ; This was how sam divided by 6
        stb   y_pos+1,u
        ldd   y_pos,u
        addd  #($7*scale.YP1PX)/256
        anda  #$ff
        andb  #$f8
        std   y_pos,u

        lda   #$f
        sta   tabrok_0x20,u
        lda   #3
        sta   routine,u
        jmp   CommonLife



        ;                     **************************************************************
        ;                     * FUN_0000_65e3_RunTabrokMode2                            *
        ;                     **************************************************************
        ;                     undefined __cdecl16near RunTabrokMode2()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     RunTabrokMode2
        ;0000:65e3 a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]                         Tabrok related
        ;0000:65e6 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:65e9 8b 76 22        MOV        SI,word ptr [BP + 0x22]
        ;0000:65ec 8b 5e 20        MOV        BX,word ptr [BP + 0x20]
        ;0000:65ef 81 e3 0c 00     AND        BX,0xc
        ;0000:65f3 d1 eb           SHR        BX,0x1
        ;0000:65f5 26 8b 18        MOV        BX,word ptr ES:[BX + SI]

FUN_0000_65e3_RunTabrokMode2

        ldx   #tabrok_0x2b68
        ldb   tabrok_0x2e,u
        bne   FUN_0000_65e3_RunTabrokMode2_continue
        ldx   #tabrok_0x2b60
FUN_0000_65e3_RunTabrokMode2_continue

        lda    tabrok_0x20,u
        anda   #$0c
        asra   
        ldd    a,x
        std    image_set,u

        ;0000:65f8 e8 1f 04        CALL       FUN_0000_6a1a_TabrokChoosePalette                                    undefined FUN_0000_6a1a_TabrokChoosePalette()
        ;0000:65fb e8 40 04        CALL       FUN_0000_6a3e_ShouldTabrokFire                                    undefined FUN_0000_6a3e_ShouldTabrokFire()
        ;0000:65fe bf 40 2c        MOV        DI,0x2c40
        ;0000:6601 e8 d6 94        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:6604 74 09           JZ         LAB_0000_660f
        ;0000:6606 c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:660a b1 56           MOV        CL,0x56
        ;0000:660c e8 f4 a0        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                    LAB_0000_660f                                   XREF[1]:     0000:6604(j)  
        ;0000:660f 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:6612 38 46 1f        CMP        byte ptr [BP + 0x1f],AL
        ;0000:6615 72 03           JC         LAB_0000_661a
        ;0000:6617 e9 ca 03        JMP        DestroyTabrok                                    undefined DestroyTabrok()
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)


        ;jsr   FUN_0000_6a1a_TabrokChoosePalette
        jsr   FUN_0000_6a3e_ShouldTabrokFire
        lda   AABB_0+AABB.p,u
        lbeq  FUN_0000_69e4_DestroyTabrok        ; was killed 

        ;                     LAB_0000_661a                                   XREF[1]:     0000:6615(j)  
        ;0000:661a ff 4e 20        DEC        word ptr [BP + 0x20]
        ;0000:661d 74 0b           JZ         LAB_0000_662a
        ;0000:661f f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;          2f ff
        ;0000:6624 74 03           JZ         LAB_0000_6629
        ;0000:6626 e9 de 03        JMP        FUN_0000_6a07_DeleteTabrok                       undefined FUN_0000_6a07_DeleteTa
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                     LAB_0000_6629                                   XREF[1]:     0000:6624(j)  
        ;0000:6629 c3              RET

        lda   tabrok_0x20,u
        suba  gfxlock.frameDrop.count
        ble   LAB_0000_662a
        sta   tabrok_0x20,u
        jmp   CommonLife

        ;                     LAB_0000_662a                                   XREF[1]:     0000:661d(j)  
        ;0000:662a c6 46 2e 00     MOV        byte ptr [BP + 0x2e],0x0
        ;0000:662e c7 46 38        MOV        word ptr [BP + 0x38],0x6243
        ;          43 62
        ;0000:6633 c7 46 3a        MOV        word ptr [BP + 0x3a],0x40
        ;          40 00
        ;0000:6638 c7 46 30        MOV        word ptr [BP + 0x30],0x50
        ;          50 00
        ;0000:663d c7 46 00        MOV        word ptr [BP + 0x0],0x62bd
        ;          bd 62
        ;0000:6642 c3              RET

LAB_0000_662a
        lda   #5 ; FUN_0000_6643_RunTabrokMode4
        sta   tabrok_0x38,u
        lda   #40
        sta   tabrok_0x3a,u
        ldd   #$50
        std   tabrok_0x30,u
        clr   tabrok_0x2e,u
        lda   #4 ; FUN_0000_66bd_RunTabrokMode3
        sta   routine,u
        jmp   CommonLife




        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6643_RunTabrokMode4()
        ;0000:6643 a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]
        ;0000:6646 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:6649 b8 00 ff        MOV        AX,0xff00
        ;0000:664c e8 23 a4        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos
        
        
        
 
FUN_0000_6643_RunTabrokMode4

   
        ldb   #($ff*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        _negd
        jsr   moveXPos8.8

        ;0000:664f 8b 1e b6 2e     MOV        BX,word ptr [0x2eb6_globalCounter]
        ;0000:6653 03 5e 28        ADD        BX,word ptr [BP + 0x28]
        ;0000:6656 81 e3 38 00     AND        BX,0x38
        ;0000:665a d1 eb           SHR        BX,0x1
        ;0000:665c d1 eb           SHR        BX,0x1
        ;0000:665e 81 c3 70 2b     ADD        BX,0x2b70
        ;0000:6662 26 8b 1f        MOV        BX,word ptr ES:[BX]
        ;0000:6665 e8 b2 03        CALL       FUN_0000_6a1a_TabrokChoosePalette                  undefined FUN_0000_6a1a_TabrokCh
        ;0000:6668 e8 d3 03        CALL       FUN_0000_6a3e_ShouldTabrokFire                   undefined FUN_0000_6a3e_ShouldTa
        ;0000:666b bf 40 2c        MOV        DI,0x2c40
        ;0000:666e e8 69 94        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:6671 74 09           JZ         LAB_0000_667c
        ;0000:6673 c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:6677 b1 56           MOV        CL,0x56
        ;0000:6679 e8 87 a0        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                      LAB_0000_667c                                   XREF[1]:     0000:6671(j)  
        ;0000:667c 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:667f 38 46 1f        CMP        byte ptr [BP + 0x1f],AL
        ;0000:6682 72 03           JC         LAB_0000_6687
        ;0000:6684 e9 5d 03        JMP        DestroyTabrok                                    undefined DestroyTabrok()
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)

        ldx   #tabrok_0x2b70
        ldb   gfxlock.frame.count+1
        andb  #$38
        asrb
        asrb
        ldd   b,x
        std   image_set,u

        ;jsr   FUN_0000_6a1a_TabrokChoosePalette
        jsr   FUN_0000_6a3e_ShouldTabrokFire
        lda   AABB_0+AABB.p,u
        lbeq  FUN_0000_69e4_DestroyTabrok        ; was killed 

LAB_0000_6687

        ;                      LAB_0000_6687                                   XREF[1]:     0000:6682(j)  
        ;0000:6687 f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;          2f ff
        ;0000:668c 74 03           JZ         LAB_0000_6691
        ;0000:668e e9 76 03        JMP        FUN_0000_6a07_DeleteTabrok                       undefined FUN_0000_6a07_DeleteTa
        ;                      -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                      LAB_0000_6691                                   XREF[1]:     0000:668c(j)  
        ;0000:6691 ff 4e 30        DEC        word ptr [BP + 0x30]
        ;0000:6694 74 01           JZ         LAB_0000_6697
        ;0000:6696 c3              RET

        ldd   tabrok_0x30,u
        subd  gfxlock.frameDrop.count_w
        std   tabrok_0x30,u
        ble   LAB_0000_6697
        jmp   CommonLife

        ;                      LAB_0000_6697                                   XREF[1]:     0000:6694(j)  
        ;0000:6697 c7 46 00        MOV        word ptr [BP + 0x0],0x62bd
        ;          bd 62
        ;0000:669c c7 46 3a        MOV        word ptr [BP + 0x3a],0x40
        ;          40 00
        ;0000:66a1 c7 46 38        MOV        word ptr [BP + 0x38],0x631b
        ;          1b 63
        ;0000:66a6 c7 46 30        MOV        word ptr [BP + 0x30],0xf
        ;          0f 00
        ;0000:66ab bb 60 2b        MOV        BX,0x2b60
        ;0000:66ae a1 24 00        MOV        AX,[0x24]
        ;0000:66b1 3b 46 04        CMP        AX,word ptr [BP + 0x4]
        ;0000:66b4 72 03           JC         LAB_0000_66b9
        ;0000:66b6 bb 68 2b        MOV        BX,0x2b68
        ;                      LAB_0000_66b9                                   XREF[1]:     0000:66b4(j)  
        ;0000:66b9 89 5e 22        MOV        word ptr [BP + 0x22],BX
        ;                      LAB_0000_66bc                                   XREF[1]:     0000:c73f(*)  
        ;0000:66bc c3              RET
LAB_0000_6697
        lda   #40
        sta   tabrok_0x3a,u
        ldx   #tabrok_0x2b70
        ldd   ,x
        std   image_set,u
        lda   #4   ;FUN_0000_6643_RunTabrokMode4
        sta   routine,u
        ldd   #$f
        std   tabrok_0x30,u
        lda   #6 ; FUN_0000_671b_RunTabrokPause
        sta   tabrok_0x38,u
        jmp   CommonLife

        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_66bd_RunTabrokMode3()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_66bd_RunTabrokMode3
        ;0000:66bd 83 7e 3a 10     CMP        word ptr [BP + 0x3a],0x10
        ;0000:66c1 75 03           JNZ        LAB_0000_66c6
        ;0000:66c3 e8 4f 04        CALL       FUN_0000_6b15_TabrokShoots4Missiles              undefined FUN_0000_6b15_TabrokSh
        ;                      LAB_0000_66c6                                   XREF[1]:     0000:66c1(j)  
        ;0000:66c6 a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]
        ;0000:66c9 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:66cc bb 80 2b        MOV        BX,0x2b80
        ;0000:66cf f6 46 2e 01     TEST       byte ptr [BP + 0x2e],0x1
        ;0000:66d3 74 03           JZ         LAB_0000_66d8
        ;0000:66d5 bb e0 2b        MOV        BX,0x2be0




FUN_0000_66bd_RunTabrokMode3
        lda   tabrok_0x3a,u
        bne   LAB_0000_66c6
        jsr   FUN_0000_6b15_TabrokShoots4Missiles
LAB_0000_66c6

        ldx   #Img_tabrok_4
        ldb   tabrok_0x2e,u
        andb  $1
        beq   LAB_0000_66d8
        ldx   #Img_tabrok_12

        ;                     LAB_0000_66d8                                   XREF[1]:     0000:66d3(j)  
        ;0000:66d8 e8 3f 03        CALL       FUN_0000_6a1a_TabrokChoosePalette                  undefined FUN_0000_6a1a_TabrokCh
        ;0000:66db e8 60 03        CALL       FUN_0000_6a3e_ShouldTabrokFire                   undefined FUN_0000_6a3e_ShouldTa
        ;0000:66de bf 40 2c        MOV        DI,0x2c40
        ;0000:66e1 e8 f6 93        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:66e4 74 09           JZ         LAB_0000_66ef
        ;0000:66e6 c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:66ea b1 56           MOV        CL,0x56
        ;0000:66ec e8 14 a0        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                             LAB_0000_66ef                                   XREF[1]:     0000:66e4(j)  
        ;0000:66ef 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:66f2 38 46 1f        CMP        byte ptr [BP + 0x1f],AL
        ;0000:66f5 72 03           JC         LAB_0000_66fa
        ;0000:66f7 e9 ea 02        JMP        DestroyTabrok                                    undefined DestroyTabrok()
        ;                      -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                      LAB_0000_66fa                                   XREF[1]:     0000:66f5(j)  
        ;0000:66fa f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;          2f ff
        ;0000:66ff 74 03           JZ         LAB_0000_6704
        ;0000:6701 e9 03 03        JMP        FUN_0000_6a07_DeleteTabrok                       undefined FUN_0000_6a07_DeleteTa
        ;                      -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                      LAB_0000_6704                                   XREF[1]:     0000:66ff(j)  
        ;0000:6704 ff 4e 3a        DEC        word ptr [BP + 0x3a]
        ;0000:6707 74 01           JZ         LAB_0000_670a
        ;0000:6709 c3              RET

LAB_0000_66d8
        stx   image_set,u
        ;jsr   FUN_0000_6a1a_TabrokChoosePalette
        jsr   FUN_0000_6a3e_ShouldTabrokFire
        lda   AABB_0+AABB.p,u
        lbeq  FUN_0000_69e4_DestroyTabrok        ; was killed 

        lda   tabrok_0x3a,u
        suba  gfxlock.frameDrop.count
        ble   LAB_0000_670a
        sta   tabrok_0x3a,u
        jmp   CommonLife

        ;                      LAB_0000_670a                                   XREF[1]:     0000:6707(j)  
        ;0000:670a 8b 46 38        MOV        AX,word ptr [BP + 0x38]
        ;0000:670d 89 46 00        MOV        word ptr [BP + 0x0],AX
        ;0000:6710 3d 1b 63        CMP        AX,0x631b
        ;0000:6713 75 05           JNZ        LAB_0000_671a
        ;0000:6715 b1 61           MOV        CL,0x61
        ;0000:6717 e8 e9 9f        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                      LAB_0000_671a                                   XREF[1]:     0000:6713(j)  
        ;0000:671a c3              RET


LAB_0000_670a
        lda   tabrok_0x38,u
        sta   routine,u
        jmp   CommonLife



        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_671b_RunTabrokPause()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_671b_RunTabrokPause
        ;0000:671b a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]
        ;0000:671e 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:6721 8b 76 22        MOV        SI,word ptr [BP + 0x22]
        ;0000:6724 8b 5e 30        MOV        BX,word ptr [BP + 0x30]
        ;0000:6727 81 e3 0c 00     AND        BX,0xc
        ;0000:672b d1 eb           SHR        BX,0x1
        ;0000:672d 26 8b 18        MOV        BX,word ptr ES:[BX + SI]
        ;0000:6730 e8 e7 02        CALL       FUN_0000_6a1a_TabrokChoosePalette                undefined FUN_0000_6a1a_TabrokCh
        ;0000:6733 bf 40 2c        MOV        DI,0x2c40
        ;0000:6736 e8 a1 93        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:6739 74 09           JZ         LAB_0000_6744
        ;0000:673b c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:673f b1 56           MOV        CL,0x56
        ;0000:6741 e8 bf 9f        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                      LAB_0000_6744                                   XREF[1]:     0000:6739(j)  
        ;0000:6744 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:6747 38 46 1f        CMP        byte ptr [BP + 0x1f],AL
        ;0000:674a 72 03           JC         LAB_0000_674f
        ;0000:674c e9 95 02        JMP        DestroyTabrok                                    undefined DestroyTabrok()
        ;                      -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                      LAB_0000_674f                                   XREF[1]:     0000:674a(j)  
        ;0000:674f f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;          2f ff
        ;0000:6754 74 03           JZ         LAB_0000_6759
        ;0000:6756 e9 ae 02        JMP        FUN_0000_6a07_DeleteTabrok                       undefined FUN_0000_6a07_DeleteTa
        ;                      -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                      LAB_0000_6759                                   XREF[1]:     0000:6754(j)  
        ;0000:6759 ff 4e 30        DEC        word ptr [BP + 0x30]
        ;0000:675c 74 01           JZ         LAB_0000_675f
        ;0000:675e c3              RET



FUN_0000_671b_RunTabrokPause
        lda   AABB_0+AABB.p,u
        lbeq  FUN_0000_69e4_DestroyTabrok        ; was killed 
        lda   tabrok_0x30,u
        suba  gfxlock.frameDrop.count
        ble   LAB_0000_675f
        sta   tabrok_0x30,u
        jmp   CommonLife

        ;                     LAB_0000_675f                                   XREF[1]:     0000:675c(j)  
        ;0000:675f c7 46 00        MOV        word ptr [BP + 0x0],0x6392
        ;          92 63
        ;0000:6764 c7 46 34        MOV        word ptr [BP + 0x34],0x0
        ;          00 00
        ;0000:6769 c7 46 36        MOV        word ptr [BP + 0x36],0x100
        ;          00 01
        ;0000:676e c7 46 30        MOV        word ptr [BP + 0x30],0x48
        ;          48 00
        ;0000:6773 c3              RET

LAB_0000_675f

        lda   #7 ; FUN_0000_6792_RunTabrokMode5
        sta   routine,u

        lda   #$48
        sta   tabrok_0x30,u

        jmp   CommonLife


        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6774_RunTabrokMode6()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_6774_RunTabrokMode6
        ;0000:6774 83 7e 30 10     CMP        word ptr [BP + 0x30],0x10
        ;0000:6778 75 1e           JNZ        LAB_0000_6798
        ;0000:677a e8 98 03        CALL       FUN_0000_6b15_TabrokShoots4Missiles              undefined FUN_0000_6b15_TabrokSh
        ;0000:677d e9 18 00        JMP        LAB_0000_6798
        ;0000:6780 83 7e 30 10     CMP        word ptr [BP + 0x30],0x10
        ;0000:6784 75 12           JNZ        LAB_0000_6798
        ;0000:6786 e8 8c 03        CALL       FUN_0000_6b15_TabrokShoots4Missiles              undefined FUN_0000_6b15_TabrokSh
        ;0000:6789 e9 0c 00        JMP        LAB_0000_6798
        ;0000:678c 8b 46 34        MOV        AX,word ptr [BP + 0x34]
        ;0000:678f e8 e0 a2        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos

FUN_0000_6774_RunTabrokMode6
        lda   tabrok_0x30,u
        cmpa  #$10
        bne   LAB_0000_6798
        jsr   FUN_0000_6b15_TabrokShoots4Missiles
        jmp   LAB_0000_6798

FUN_0000_6780_RunTabrokMode8
        lda   tabrok_0x30,u
        cmpa  #$10
        bne   LAB_0000_6798
        jsr   FUN_0000_6b15_TabrokShoots4Missiles
        jmp   LAB_0000_6798        

FUN_0000_678c_RunTabrokMode7
        ldb   #($100*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveXPos8.8    
        ldd   x_pos,u
        addd  glb_camera_x_pos
        subd  glb_camera_x_pos_old
        std   x_pos,u
        jmp   LAB_0000_6798 

        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6792_RunTabrokMode5()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_6792_RunTabrokMode5
        ;0000:6792 8b 46 36        MOV        AX,word ptr [BP + 0x36]
        ;0000:6795 e8 f1 a2        CALL       FUN_0000_0a89_MoveYPos8.8                        undefined FUN_0000_0a89_MoveYPos
        ;                     LAB_0000_6798                                   XREF[4]:     0000:6778(j), 0000:677d(j), 
        ;                                                                                  0000:6784(j), 0000:6789(j)  
        ;0000:6798 c6 46 2e 00     MOV        byte ptr [BP + 0x2e],0x0
        ;0000:679c a1 24 00        MOV        AX,[0x24]
        ;0000:679f 3b 46 04        CMP        AX,word ptr [BP + 0x4]
        ;0000:67a2 72 04           JC         LAB_0000_67a8
        ;0000:67a4 c6 46 2e 01     MOV        byte ptr [BP + 0x2e],0x1

FUN_0000_6792_RunTabrokMode5

        ldb   #($100*scale.YP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        _negd
        jsr   moveYPos8.8    

LAB_0000_6798

        ldd   x_pos,u
        addd  glb_camera_x_pos
        subd  glb_camera_x_pos_old
        std   x_pos,u


        ;                     LAB_0000_67a8                                   XREF[1]:     0000:67a2(j)  
        ;0000:67a8 a1 b6 2e        MOV        AX,[0x2eb6_globalCounter]
        ;0000:67ab 03 46 28        ADD        AX,word ptr [BP + 0x28]
        ;0000:67ae f6 46 2e 01     TEST       byte ptr [BP + 0x2e],0x1
        ;0000:67b2 75 0e           JNZ        LAB_0000_67c2
        ;0000:67b4 bb c8 2b        MOV        BX,0x2bc8
        ;0000:67b7 a9 04 00        TEST       AX,0x4
        ;0000:67ba 74 11           JZ         LAB_0000_67cd
        ;                     LAB_0000_67bc                                   XREF[1]:     0000:c73f(*)  
        ;0000:67bc bb d4 2b        MOV        BX,0x2bd4
        ;0000:67bf e9 0b 00        JMP        LAB_0000_67cd
        ;                     LAB_0000_67c2                                   XREF[1]:     0000:67b2(j)  
        ;0000:67c2 bb 28 2c        MOV        BX,0x2c28
        ;0000:67c5 a9 04 00        TEST       AX,0x4
        ;0000:67c8 74 03           JZ         LAB_0000_67cd
        ;0000:67ca bb 34 2c        MOV        BX,0x2c34


        ldd   gfxlock.frame.count
        addd  tabrok_0x28,u

        tst   tabrok_0x2e,u
        beq   LAB_0000_67c2
        ldx   #Img_tabrok_15
        andb  #$04
        beq   LAB_0000_67cd
        ldx   #Img_tabrok_14
        jmp   LAB_0000_67cd
LAB_0000_67c2
        ldx   #Img_tabrok_7
        andb  #$04
        beq   LAB_0000_67cd
        ldx   #Img_tabrok_6
LAB_0000_67cd
        stx   image_set,u

        ;                     LAB_0000_67cd                                   XREF[3]:     0000:67ba(j), 0000:67bf(j), 
        ;                                                                                  0000:67c8(j)  
        ;0000:67cd e8 4a 02        CALL       FUN_0000_6a1a_TabrokChoosePalette                undefined FUN_0000_6a1a_TabrokCh
        ;0000:67d0 e8 6b 02        CALL       FUN_0000_6a3e_ShouldTabrokFire                   undefined FUN_0000_6a3e_ShouldTa
        ;0000:67d3 bf 40 2c        MOV        DI,0x2c40
        ;0000:67d6 e8 01 93        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:67d9 74 09           JZ         LAB_0000_67e4
        ;0000:67db c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:67df b1 56           MOV        CL,0x56
        ;0000:67e1 e8 1f 9f        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                     LAB_0000_67e4                                   XREF[1]:     0000:67d9(j)  
        ;0000:67e4 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:67e7 38 46 1f        CMP        byte ptr [BP + 0x1f],AL
        ;0000:67ea 72 03           JC         LAB_0000_67ef
        ;0000:67ec e9 f5 01        JMP        DestroyTabrok                                    undefined DestroyTabrok()
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                     LAB_0000_67ef                                   XREF[1]:     0000:67ea(j)  
        ;0000:67ef f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;         2f ff
        ;0000:67f4 74 03           JZ         LAB_0000_67f9
        ;0000:67f6 e9 0e 02        JMP        FUN_0000_6a07_DeleteTabrok                       undefined FUN_0000_6a07_DeleteTa
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                     LAB_0000_67f9                                   XREF[1]:     0000:67f4(j)  
        ;0000:67f9 ff 4e 30        DEC        word ptr [BP + 0x30]
        ;0000:67fc 74 01           JZ         LAB_0000_67ff
        ;0000:67fe c3              RET




        jsr   FUN_0000_6a3e_ShouldTabrokFire
        lda   AABB_0+AABB.p,u
        lbeq  FUN_0000_69e4_DestroyTabrok        ; was killed 

        lda   tabrok_0x30,u
        suba  gfxlock.frameDrop.count
        ble   LAB_0000_67ff
        sta   tabrok_0x30,u
        jmp   CommonLife

        ;                     LAB_0000_67ff                                   XREF[1]:     0000:67fc(j)  
        ;0000:67ff 81 7e 00        CMP        word ptr [BP + 0x0],0x6380
        ;0000:6804 74 4d           JZ         LAB_0000_6853
        ;0000:6806 81 7e 00        CMP        word ptr [BP + 0x0],0x638c
        ;0000:680b 74 31           JZ         LAB_0000_683e
        ;0000:680d 81 7e 00        CMP        word ptr [BP + 0x0],0x6374
        ;0000:6812 74 15           JZ         LAB_0000_6829
        ;0000:6814 c7 46 00        MOV        word ptr [BP + 0x0],0x6374
        ;0000:6819 c7 46 30        MOV        word ptr [BP + 0x30],0x40
        ;0000:681e c7 46 34        MOV        word ptr [BP + 0x34],0x0
        ;0000:6823 c7 46 36        MOV        word ptr [BP + 0x36],0x0
        ;0000:6828 c3              RET
        ;                     LAB_0000_6829                                   XREF[1]:     0000:6812(j)  
        ;0000:6829 c7 46 00        MOV        word ptr [BP + 0x0],0x638c
        ;0000:682e c7 46 30        MOV        word ptr [BP + 0x30],0x80
        ;0000:6833 c7 46 34        MOV        word ptr [BP + 0x34],0x100
        ;0000:6838 c7 46 36        MOV        word ptr [BP + 0x36],0x0
        ;0000:683d c3              RET
        ;                     LAB_0000_683e                                   XREF[1]:     0000:680b(j)  
        ;0000:683e c7 46 00        MOV        word ptr [BP + 0x0],0x6380
        ;0000:6843 c7 46 30        MOV        word ptr [BP + 0x30],0x40
        ;0000:6848 c7 46 34        MOV        word ptr [BP + 0x34],0x0
        ;0000:684d c7 46 36        MOV        word ptr [BP + 0x36],0x0
        ;0000:6852 c3              RET

LAB_0000_67ff

        lda   routine,u
        cmpa  #10
        beq   LAB_0000_6853
        cmpa  #9
        beq   LAB_0000_683e
        cmpa  #8
        beq   LAB_0000_6829

        lda   #8 ; FUN_0000_6774_RunTabrokMode6
        sta   routine,u
        lda   #40
        sta   tabrok_0x30,u
        jmp   CommonLife
LAB_0000_6829
        lda   #9 ; FUN_0000_678c_RunTabrokMode7
        sta   routine,u
        lda   #80
        sta   tabrok_0x30,u
        jmp   CommonLife
LAB_0000_683e
        lda   #10 ; FUN_0000_6780_RunTabrokMode8
        sta   routine,u
        lda   #40
        sta   tabrok_0x30,u
        jmp   CommonLife


        ;                     LAB_0000_6853                                   XREF[1]:     0000:6804(j)  
        ;0000:6853 c7 46 00        MOV        word ptr [BP + 0x0],0x6459
        ;         59 64
LAB_0000_6853

        lda   #11 ; FUN_0000_6859_RunTabrokMode9
        sta   routine,u
        jmp   CommonLife


        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6859_RunTabrokMode9()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_6859_RunTabrokMode9
        ;0000:6859 c6 46 2e 00     MOV        byte ptr [BP + 0x2e],0x0
        ;0000:685d a1 24 00        MOV        AX,[0x24]
        ;0000:6860 3b 46 04        CMP        AX,word ptr [BP + 0x4]
        ;0000:6863 72 04           JC         LAB_0000_6869
        ;0000:6865 c6 46 2e 01     MOV        byte ptr [BP + 0x2e],0x1
        ;                     LAB_0000_6869                                   XREF[1]:     0000:6863(j)  
        ;0000:6869 b8 80 00        MOV        AX,0x80
        ;0000:686c e8 03 a2        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos
        ;0000:686f b8 00 ff        MOV        AX,0xff00
        ;0000:6872 e8 14 a2        CALL       FUN_0000_0a89_MoveYPos8.8                        undefined FUN_0000_0a89_MoveYPos
        ;0000:6875 a1 b6 2e        MOV        AX,[0x2eb6_globalCounter]
        ;0000:6878 03 46 28        ADD        AX,word ptr [BP + 0x28]
        ;0000:687b f6 46 2e 01     TEST       byte ptr [BP + 0x2e],0x1
        ;0000:687f 75 0e           JNZ        LAB_0000_688f
        ;0000:6881 bb c8 2b        MOV        BX,0x2bc8
        ;0000:6884 a9 04 00        TEST       AX,0x4
        ;0000:6887 74 11           JZ         LAB_0000_689a
        ;0000:6889 bb d4 2b        MOV        BX,0x2bd4
        ;0000:688c e9 0b 00        JMP        LAB_0000_689a
        ;                     LAB_0000_688f                                   XREF[1]:     0000:687f(j)  
        ;0000:688f bb 28 2c        MOV        BX,0x2c28
        ;0000:6892 a9 04 00        TEST       AX,0x4
        ;0000:6895 74 03           JZ         LAB_0000_689a
        ;0000:6897 bb 34 2c        MOV        BX,0x2c34


FUN_0000_6859_RunTabrokMode9

        clr   tabrok_0x2e,u
        ldx   player1+x_pos
        cmpx  x_pos,u
        bmi   LAB_0000_6869
        ldb   #$01
        stb   tabrok_0x2e,u
LAB_0000_6869
        ldb   #($80*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveXPos8.8    
        ldd   x_pos,u
        addd  glb_camera_x_pos
        subd  glb_camera_x_pos_old
        std   x_pos,u
        ldb   #($ff*scale.YP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveYPos8.8    
        ldd   gfxlock.frame.count
        addd  tabrok_0x28,u

        tst   tabrok_0x2e,u
        beq   LAB_0000_688f
        ldx   #Img_tabrok_15
        andb  #$04
        beq   LAB_0000_689a
        ldx   #Img_tabrok_14
        jmp   LAB_0000_689a
LAB_0000_688f
        ldx   #Img_tabrok_7
        andb  #$04
        beq   LAB_0000_689a
        ldx   #Img_tabrok_6



        ;                     LAB_0000_689a                                   XREF[3]:     0000:6887(j), 0000:688c(j), 
        ;                                                                                  0000:6895(j)  
        ;0000:689a e8 7d 01        CALL       FUN_0000_6a1a_TabrokChoosePalette                undefined FUN_0000_6a1a_TabrokCh
        ;0000:689d e8 9e 01        CALL       FUN_0000_6a3e_ShouldTabrokFire                   undefined FUN_0000_6a3e_ShouldTa
        ;0000:68a0 bf 40 2c        MOV        DI,0x2c40
        ;0000:68a3 e8 34 92        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:68a6 74 09           JZ         LAB_0000_68b1
        ;0000:68a8 c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:68ac b1 56           MOV        CL,0x56
        ;0000:68ae e8 52 9e        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                     LAB_0000_68b1                                   XREF[1]:     0000:68a6(j)  
        ;0000:68b1 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:68b4 38 46 1f        CMP        byte ptr [BP + 0x1f],AL
        ;0000:68b7 72 03           JC         LAB_0000_68bc
        ;0000:68b9 e9 28 01        JMP        DestroyTabrok                                    undefined DestroyTabrok()
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)


LAB_0000_689a
        stx   image_set,u

        jsr   FUN_0000_6a3e_ShouldTabrokFire
        lda   AABB_0+AABB.p,u
        lbeq  FUN_0000_69e4_DestroyTabrok        ; was killed 

        lda   tabrok_0x30,u
        suba  gfxlock.frameDrop.count
        ble   LAB_0000_68bc
        sta   tabrok_0x30,u
        jmp   CommonLife


        ;                     LAB_0000_68bc                                   XREF[2]:     0000:68b7(j), 0000:c73f(*)  
        ;0000:68bc ff 76 04        PUSH       word ptr [BP + 0x4]
        ;0000:68bf ff 76 08        PUSH       word ptr [BP + 0x8]
        ;0000:68c2 83 46 04 04     ADD        word ptr [BP + 0x4],0x4
        ;0000:68c6 83 6e 08 18     SUB        word ptr [BP + 0x8],0x18
        ;0000:68ca e8 9f b9        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
        ;0000:68cd 8f 46 08        POP        word ptr [BP + 0x8]
        ;0000:68d0 8f 46 04        POP        word ptr [BP + 0x4]
        ;0000:68d3 3d fc 0d        CMP        AX,0xdfc
        ;0000:68d6 72 2a           JC         LAB_0000_6902
        ;0000:68d8 ff 76 04        PUSH       word ptr [BP + 0x4]
        ;0000:68db ff 76 08        PUSH       word ptr [BP + 0x8]
        ;0000:68de 8b 46 14        MOV        AX,word ptr [BP + 0x14]
        ;0000:68e1 83 46 04 18     ADD        word ptr [BP + 0x4],0x18
        ;0000:68e5 83 6e 08 18     SUB        word ptr [BP + 0x8],0x18
        ;0000:68e9 e8 80 b9        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
        ;0000:68ec 8f 46 08        POP        word ptr [BP + 0x8]
        ;0000:68ef 8f 46 04        POP        word ptr [BP + 0x4]
        ;0000:68f2 3d fc 0d        CMP        AX,0xdfc
        ;0000:68f5 72 0b           JC         LAB_0000_6902
        ;0000:68f7 f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;         2f ff
        ;0000:68fc 74 03           JZ         LAB_0000_6901
        ;0000:68fe e9 06 01        JMP        FUN_0000_6a07_DeleteTabrok                       undefined FUN_0000_6a07_DeleteTa
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                     LAB_0000_6901                                   XREF[1]:     0000:68fc(j)  
        ;0000:6901 c3              RET

LAB_0000_68bc
        ldd   x_pos,u
        subd  #($4*scale.XP1PX)/256
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #($16*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do        
        tstb   
        lbne  LAB_0000_6902
        ldd   x_pos,u
        subd  #($16*scale.XP1PX)/256
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        addd  #($18*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do        
        tstb   
        lbne  LAB_0000_6902
        jmp   CommonLife

        ;                     LAB_0000_6902                                   XREF[2]:     0000:68d6(j), 0000:68f5(j)  
        ;0000:6902 83 46 08 07     ADD        word ptr [BP + 0x8],0x7
        ;0000:6906 81 66 08        AND        word ptr [BP + 0x8],0xfff8
        ;          f8 ff
        ;0000:690b c7 46 20        MOV        word ptr [BP + 0x20],0xf
        ;          0f 00
        ;0000:6910 b8 08 00        MOV        AX,0x8
        ;0000:6913 bb 68 2b        MOV        BX,0x2b68
        ;0000:6916 f7 46 2e        TEST       word ptr [BP + 0x2e],0x1
        ;          01 00
        ;0000:691b 75 06           JNZ        LAB_0000_6923
        ;0000:691d b8 f8 ff        MOV        AX,0xfff8
        ;0000:6920 bb 60 2b        MOV        BX,0x2b60



LAB_0000_6902

        ldb   #($07*scale.YP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveYPos8.8  
        ldb   y_pos+1,u
        andb  #$f8
        stb   y_pos+1,u
        ldb   #$f
        stb   tabrok_0x20,u
        ldb   #($08*scale.XP1PX)/256
        tst   tabrok_0x2e,u
        bne   LAB_0000_6923
        ldb   #($08*scale.XN1PX)/256
 
        ;                     LAB_0000_6923                                   XREF[1]:     0000:691b(j)  
        ;0000:6923 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:6926 89 5e 22        MOV        word ptr [BP + 0x22],BX
        ;0000:6929 c7 46 00        MOV        word ptr [BP + 0x0],LAB_0000_652f
        ;         2f 65
        ;0000:692e c3              RET
        ;0000:692f a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]
        ;0000:6932 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:6935 8b 76 22        MOV        SI,word ptr [BP + 0x22]
        ;0000:6938 8b 5e 20        MOV        BX,word ptr [BP + 0x20]
        ;0000:693b 81 e3 0c 00     AND        BX,0xc
        ;0000:693f d1 eb           SHR        BX,0x1
        ;0000:6941 26 8b 18        MOV        BX,word ptr ES:[BX + SI]

LAB_0000_6923
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveXPos8.8  
        lda   #12   ; FUN_0000_692f_RunTabrokMode10
        sta   routine,u
        jmp   CommonLife



        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_692f_RunTabrokMode10()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_692f_RunTabrokMode10
        ;0000:692f a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]
        ;0000:6932 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:6935 8b 76 22        MOV        SI,word ptr [BP + 0x22]
        ;0000:6938 8b 5e 20        MOV        BX,word ptr [BP + 0x20]
        ;0000:693b 81 e3 0c 00     AND        BX,0xc
        ;0000:693f d1 eb           SHR        BX,0x1
        ;0000:6941 26 8b 18        MOV        BX,word ptr ES:[BX + SI]
        ;0000:6944 e8 d3 00        CALL       FUN_0000_6a1a_TabrokChoosePalette                undefined FUN_0000_6a1a_TabrokCh
        ;0000:6947 e8 f4 00        CALL       FUN_0000_6a3e_ShouldTabrokFire                   undefined FUN_0000_6a3e_ShouldTa
        ;0000:694a bf 40 2c        MOV        DI,0x2c40
        ;0000:694d e8 8a 91        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:6950 74 09           JZ         LAB_0000_695b
        ;0000:6952 c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:6956 b1 56           MOV        CL,0x56
        ;0000:6958 e8 a8 9d        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                     LAB_0000_695b                                   XREF[1]:     0000:6950(j)  
        ;0000:695b 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:695e 38 46 1f        CMP        byte ptr [BP + 0x1f],AL
        ;0000:6961 72 03           JC         LAB_0000_6966
        ;0000:6963 e9 7e 00        JMP        DestroyTabrok                                    undefined DestroyTabrok()
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                     LAB_0000_6966                                   XREF[1]:     0000:6961(j)  
        ;0000:6966 ff 4e 20        DEC        word ptr [BP + 0x20]
        ;0000:6969 74 0b           JZ         LAB_0000_6976
        ;0000:696b f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;          2f ff
        ;0000:6970 74 03           JZ         LAB_0000_6975
        ;0000:6972 e9 92 00        JMP        FUN_0000_6a07_DeleteTabrok                       undefined FUN_0000_6a07_DeleteTa
        ;                     -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                     LAB_0000_6975                                   XREF[1]:     0000:6970(j)  
        ;0000:6975 c3              RET



FUN_0000_692f_RunTabrokMode10

        ldx   #tabrok_0x2b68
        ldb   tabrok_0x2e,u
        bne   FUN_0000_692f_RunTabrokMode10_continue
        ldx   #tabrok_0x2b60
FUN_0000_692f_RunTabrokMode10_continue

        lda    tabrok_0x20,u
        anda   #$0c
        asra   
        ldd    a,x
        std    image_set,u

        ;jsr   FUN_0000_6a1a_TabrokChoosePalette
        jsr   FUN_0000_6a3e_ShouldTabrokFire
        lda   AABB_0+AABB.p,u
        lbeq  FUN_0000_69e4_DestroyTabrok        ; was killed 

        lda   tabrok_0x20,u
        suba  gfxlock.frameDrop.count
        ble   LAB_0000_6976
        sta   tabrok_0x20,u
        jmp   CommonLife
 

        ;                     LAB_0000_6976                                   XREF[1]:     0000:6969(j)  
        ;0000:6976 c7 46 00        MOV        word ptr [BP + 0x0],0x657c
        ;          7c 65


LAB_0000_6976

        lda   #13  ; FUN_0000_697c_RunTabrokMode11
        sta   routine,u
        jmp   CommonLife


        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_697c_RunTabrokMode11()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_697c_RunTabrokMode11
        ;0000:697c f7 06 b6        TEST       word ptr [0x2eb6_globalCounter],0x7f
        ;          2e 7f 00
        ;0000:6982 75 03           JNZ        LAB_0000_6987
        ;0000:6984 e8 8e 01        CALL       FUN_0000_6b15_TabrokShoots4Missiles              undefined FUN_0000_6b15_TabrokSh
        ;                      LAB_0000_6987                                   XREF[1]:     0000:6982(j)  
        ;0000:6987 c6 46 2e 00     MOV        byte ptr [BP + 0x2e],0x0
        ;0000:698b a1 24 00        MOV        AX,[0x24]
        ;0000:698e 3b 46 04        CMP        AX,word ptr [BP + 0x4]
        ;0000:6991 72 04           JC         LAB_0000_6997
        ;0000:6993 c6 46 2e 01     MOV        byte ptr [BP + 0x2e],0x1
        ;                      LAB_0000_6997                                   XREF[1]:     0000:6991(j)  
        ;0000:6997 a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]
        ;0000:699a 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:699d bb 48 2c        MOV        BX,0x2c48
        ;0000:69a0 f6 46 2e 01     TEST       byte ptr [BP + 0x2e],0x1
        ;0000:69a4 74 03           JZ         LAB_0000_69a9
        ;0000:69a6 bb 60 2c        MOV        BX,0x2c60
        ;                      LAB_0000_69a9                                   XREF[1]:     0000:69a4(j)  
        ;0000:69a9 f6 46 2e 30     TEST       byte ptr [BP + 0x2e],0x30
        ;0000:69ad 74 03           JZ         LAB_0000_69b2
        ;0000:69af 83 c3 06        ADD        BX,0x6
        ;                      LAB_0000_69b2                                   XREF[1]:     0000:69ad(j)  
        ;0000:69b2 e8 65 00        CALL       FUN_0000_6a1a_TabrokChoosePalette                undefined FUN_0000_6a1a_TabrokCh
        ;0000:69b5 e8 86 00        CALL       FUN_0000_6a3e_ShouldTabrokFire                   undefined FUN_0000_6a3e_ShouldTa
        ;0000:69b8 bf 40 2c        MOV        DI,0x2c40
        ;0000:69bb e8 1c 91        CALL       FUN_0000_fada_DoCollisionWithPlayerAndWeapons_v2 undefined FUN_0000_fada_DoCollis
        ;0000:69be 74 09           JZ         LAB_0000_69c9
        ;0000:69c0 c6 46 3d 0c     MOV        byte ptr [BP + 0x3d],0xc
        ;0000:69c4 b1 56           MOV        CL,0x56
        ;0000:69c6 e8 3a 9d        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                      LAB_0000_69c9                                   XREF[1]:     0000:69be(j)  
        ;0000:69c9 8a 46 2f        MOV        AL,byte ptr [BP + 0x2f]
        ;0000:69cc 38 46 1f        CMP        byte ptr [BP + 0x1f],AL
        ;0000:69cf 72 03           JC         LAB_0000_69d4
        ;0000:69d1 e9 10 00        JMP        DestroyTabrok                                    undefined DestroyTabrok()
        ;                      -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                      LAB_0000_69d4                                   XREF[1]:     0000:69cf(j)  
        ;0000:69d4 f6 06 c4        TEST       byte ptr [0x2fc4_stageStatus],0xff
        ;          2f ff
        ;0000:69d9 74 03           JZ         LAB_0000_69de
        ;0000:69db e9 29 00        JMP        FUN_0000_6a07_DeleteTabrok                       undefined FUN_0000_6a07_DeleteTa
        ;                      -- Flow Override: CALL_RETURN (CALL_TERMINATOR)
        ;                      LAB_0000_69de                                   XREF[1]:     0000:69d9(j)  
        ;0000:69de e8 8a b7        CALL       FUN_0000_216b_IsVisibleRange                     undefined FUN_0000_216b_IsVisibl
        ;0000:69e1 72 24           JC         FUN_0000_6a07_DeleteTabrok
        ;0000:69e3 c3              RET


FUN_0000_697c_RunTabrokMode11

        ldb   gfxlock.frame.count+1
        andb  #$7f
        bne   LAB_0000_6987
        jsr   FUN_0000_6b15_TabrokShoots4Missiles
LAB_0000_6987
        clra  
        ldd   #Img_tabrok_4
        tst   tabrok_0x2e,u
        ldx   player1+x_pos
        cmpx  x_pos,u
        bmi   LAB_0000_69b2
        ldd   #Img_tabrok_12

LAB_0000_69b2
        std   image_set,u
        
        ;jsr   FUN_0000_6a1a_TabrokChoosePalette
        jsr   FUN_0000_6a3e_ShouldTabrokFire
        lda   AABB_0+AABB.p,u
        lbeq  FUN_0000_69e4_DestroyTabrok        ; was killed 
        jmp   CommonLife


        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6b15_TabrokShoots4Missi
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_6b15_TabrokShoots4Missiles             XREF[4]:     FUN_0000_66bd_RunTabrokMode3:000
        ;                                                                                  FUN_0000_6774_RunTabrokMode6:000
        ;                                                                                  FUN_0000_6780_RunTabrokMode8:000
        ;                                                                                  FUN_0000_697c_RunTabrokMode11:00
        ;0000:6b15 bf 94 2c        MOV        DI,0x2c94
        ;0000:6b18 8a 1e 2e 2f     MOV        BL,byte ptr [difficulty]
        ;0000:6b1c 32 ff           XOR        BH,BH
        ;0000:6b1e 03 db           ADD        BX,BX
        ;0000:6b20 26 8b 9f        MOV        BX,word ptr ES:[BX + 0x2b58]
        ;         58 2b
        ;0000:6b25 89 5e 24        MOV        word ptr [BP + 0x24],BX
        ;0000:6b28 57              PUSH       DI
        ;0000:6b29 b9 00 50        MOV        CX,0x5000
        ;0000:6b2c ba d5 67        MOV        DX,0x67d5
        ;0000:6b2f e8 74 9c        CALL       FUN_0000_07a6_LoadManagedObject                  byte FUN_0000_07a6_LoadManagedOb
        ;0000:6b32 5f              POP        DI
        ;0000:6b33 73 03           JNC        LAB_0000_6b38
        ;0000:6b35 e9 4a 00        JMP        LAB_0000_6b82
        ;                     LAB_0000_6b38                                   XREF[1]:     0000:6b33(j)  
        ;0000:6b38 e8 4d 00        CALL       FUN_0000_6b88_ConfigureTabrokMissile                                    undefined FUN_0000_6b88_ConfigureTabrokMissile()
        ;0000:6b3b a1 24 00        MOV        AX,[0x24]
        ;0000:6b3e 39 46 04        CMP        word ptr [BP + 0x4],AX
        ;0000:6b41 73 06           JNC        LAB_0000_6b49
        ;0000:6b43 83 c7 08        ADD        DI,0x8
        ;0000:6b46 e9 13 00        JMP        LAB_0000_6b5c
FUN_0000_6b15_TabrokShoots4Missiles
        jmp   FUN_0000_69e4_DestroyTabrok
        ldy   #tabrok_0x2c94
        ldb   globals.difficulty
        ldx   #tabrok_0x2b58
        lda   b,x
        sta   @tabrok0x24
        pshs  y
        jsr   LoadObject_x
        beq   LAB_0000_6b81
        puls  y
        lda   #ObjID_tabrokmissile
        sta   id,x
        jsr   FUN_0000_6b88_ConfigureTabrokMissile
        ldd   player1+x_pos
        cmpd  x_pos,u
        bpl   LAB_0000_6b49
        leay  8,y
        jmp   LAB_0000_6b5c
        ;                     LAB_0000_6b49                                   XREF[1]:     0000:6b41(j)  
        ;0000:6b49 57              PUSH       DI
        ;0000:6b4a b9 00 50        MOV        CX,0x5000
        ;0000:6b4d ba d5 67        MOV        DX,0x67d5
        ;0000:6b50 e8 53 9c        CALL       FUN_0000_07a6_LoadManagedObject                  byte FUN_0000_07a6_LoadManagedOb
        ;0000:6b53 5f              POP        DI
        ;0000:6b54 73 03           JNC        LAB_0000_6b59
        ;0000:6b56 e9 29 00        JMP        LAB_0000_6b82
        ;                     LAB_0000_6b59                                   XREF[1]:     0000:6b54(j)  
        ;0000:6b59 e8 2c 00        CALL       FUN_0000_6b88_ConfigureTabrokMissile                                    undefined FUN_0000_6b88_ConfigureTabrokMissile()
LAB_0000_6b49
        ;                     LAB_0000_6b5c                                   XREF[1]:     0000:6b46(j)  
        ;0000:6b5c 57              PUSH       DI
        ;0000:6b5d b9 00 50        MOV        CX,0x5000
        ;0000:6b60 ba d5 67        MOV        DX,0x67d5
        ;0000:6b63 e8 40 9c        CALL       FUN_0000_07a6_LoadManagedObject                  byte FUN_0000_07a6_LoadManagedOb
        ;0000:6b66 5f              POP        DI
        ;0000:6b67 73 03           JNC        LAB_0000_6b6c
        ;0000:6b69 e9 16 00        JMP        LAB_0000_6b82
LAB_0000_6b5c 
        ;                     LAB_0000_6b6c                                   XREF[1]:     0000:6b67(j)  
        ;0000:6b6c e8 19 00        CALL       FUN_0000_6b88_ConfigureTabrokMissile                                    undefined FUN_0000_6b88_ConfigureTabrokMissile()
        ;0000:6b6f 57              PUSH       DI
        ;0000:6b70 b9 00 50        MOV        CX,0x5000
        ;0000:6b73 ba d5 67        MOV        DX,0x67d5
        ;0000:6b76 e8 2d 9c        CALL       FUN_0000_07a6_LoadManagedObject                  byte FUN_0000_07a6_LoadManagedOb
        ;0000:6b79 5f              POP        DI
        ;0000:6b7a 73 03           JNC        LAB_0000_6b7f
        ;0000:6b7c e9 03 00        JMP        LAB_0000_6b82
        ;                     LAB_0000_6b7f                                   XREF[1]:     0000:6b7a(j)  
        ;0000:6b7f e8 06 00        CALL       FUN_0000_6b88_ConfigureTabrokMissile                                    undefined FUN_0000_6b88_ConfigureTabrokMissile()
        ;                     LAB_0000_6b82                                   XREF[4]:     0000:6b35(j), 0000:6b56(j), 
        ;                                                                                  0000:6b69(j), 0000:6b7c(j)  
        ;0000:6b82 b1 5d           MOV        CL,0x5d
        ;0000:6b84 e8 7c 9b        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;0000:6b87 c3              RET
LAB_0000_6b81
        puls y
LAB_0000_6b82
        rts
FUN_0000_6b88_ConfigureTabrokMissile
        ;0000:6b88 26 8b 05        MOV        AX,word ptr ES:[DI]
        ;0000:6b8b 89 44 30        MOV        word ptr [SI + 0x30],AX
        ;0000:6b8e 26 8b 45 02     MOV        AX,word ptr ES:[DI + 0x2]
        ;0000:6b92 89 44 32        MOV        word ptr [SI + 0x32],AX
        ;0000:6b95 c7 44 20        MOV        word ptr [SI + 0x20],0x20
        ;        20 00
        ;0000:6b9a 8b 46 04        MOV        AX,word ptr [BP + 0x4]
        ;0000:6b9d 89 44 04        MOV        word ptr [SI + 0x4],AX
        ;0000:6ba0 8b 46 08        MOV        AX,word ptr [BP + 0x8]
        ;0000:6ba3 89 44 08        MOV        word ptr [SI + 0x8],AX
        ;0000:6ba6 8b 46 24        MOV        AX,word ptr [BP + 0x24]
        ;0000:6ba9 89 44 24        MOV        word ptr [SI + 0x24],AX
        ;0000:6bac 26 8b 45 04     MOV        AX,word ptr ES:[DI + 0x4]
        ;0000:6bb0 89 44 16        MOV        word ptr [SI + 0x16],AX
        ;0000:6bb3 a1 24 00        MOV        AX,[0x24]
        ;0000:6bb6 39 46 04        CMP        word ptr [BP + 0x4],AX
        ;0000:6bb9 73 0a           JNC        LAB_0000_6bc5
        ;0000:6bbb f7 5c 30        NEG        word ptr [SI + 0x30]
        ;0000:6bbe 26 8b 45 06     MOV        AX,word ptr ES:[DI + 0x6]
        ;0000:6bc2 89 44 16        MOV        word ptr [SI + 0x16],AX
        ;                     LAB_0000_6bc5                                   XREF[1]:     0000:6bb9(j)  
        ;0000:6bc5 83 c7 08        ADD        DI,0x8
        ;0000:6bc8 56              PUSH       SI
        ;0000:6bc9 57              PUSH       DI
        ;0000:6bca b0 3c           MOV        AL,0x3c
        ;0000:6bcc e8 1f ea        CALL       FUN_0000_55ee_GetPaletteId                       undefined FUN_0000_55ee_GetPalet
        ;0000:6bcf 88 5c 06        MOV        byte ptr [SI + 0x6],BL
        ;0000:6bd2 5f              POP        DI
        ;0000:6bd3 5e              POP        SI
        ;0000:6bd4 c3              RET
        ldd   ,y
        std   x_vel,x
        ldd   2,y
        std   y_vel,x
        lda   #$20
        sta   ext_variables+13,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   #0
@tabrok0x24 equ   *-1
        sta   ext_variables+10,x
        ldd   4,y
        std   ext_variables+11,x
        ldd   player1+x_pos
        cmpd  x_pos,u
        bpl   LAB_0000_6bc5
        ldd   6,y
        std   ext_variables+11,x
        neg   ext_variables+10,x
LAB_0000_6bc5
        leay  8,y
        rts








AlreadyDeleted
        rts

        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6a1a_TabrokChoosePalette()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_6a1a_TabrokChoosePalette                 XREF[9]:     FUN_0000_650d_RunTabrokMode1:000
        ;0000:6a1a f6 46 3d ff     TEST       byte ptr [BP + 0x3d],0xff
        ;0000:6a1e 74 1a           JZ         LAB_0000_6a3a
        ;0000:6a20 fe 4e 3d        DEC        byte ptr [BP + 0x3d]
        ;0000:6a23 8a 46 3d        MOV        AL,byte ptr [BP + 0x3d]
        ;0000:6a26 24 03           AND        AL,0x3
        ;0000:6a28 75 10           JNZ        LAB_0000_6a3a
        ;0000:6a2a ff 76 06        PUSH       word ptr [BP + 0x6]
        ;0000:6a2d 8a 46 3c        MOV        AL,byte ptr [BP + 0x3c]
        ;0000:6a30 88 46 06        MOV        byte ptr [BP + 0x6],AL
        ;0000:6a33 e8 e5 b5        CALL       FUN_0000_201b_Write2Sprites                      undefined FUN_0000_201b_Write2Sp
        ;0000:6a36 8f 46 06        POP        word ptr [BP + 0x6]
        ;0000:6a39 c3              RET
        ;                     LAB_0000_6a3a                                   XREF[2]:     0000:6a1e(j), 0000:6a28(j)  
        ;0000:6a3a e8 de b5        CALL       FUN_0000_201b_Write2Sprites                      undefined FUN_0000_201b_Write2Sp
        ;0000:6a3d c3              RET


FUN_0000_6a1a_TabrokChoosePalette
        rts



        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6a3e_ShouldTabrokFire()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_6a3e_ShouldTabrokFire                                   XREF[8]:     FUN_0000_650d:0000:6551(c), 
        ;0000:6a3e ff 46 0e        INC        word ptr [BP + 0xe]
        ;0000:6a41 8b 46 0e        MOV        AX,word ptr [BP + 0xe]
        ;0000:6a44 3b 46 0c        CMP        AX,word ptr [BP + 0xc]
        ;0000:6a47 72 7e           JC         LAB_0000_6ac7
        ;0000:6a49 c7 46 0e        MOV        word ptr [BP + 0xe],0x0
        ;         00 00


FUN_0000_6a3e_ShouldTabrokFire
        ldb   tabrok_0xe,u
        addb  gfxlock.frameDrop.count
        stb   tabrok_0xe,u
        cmpb  tabrok_0xc,u
        bmi   LAB_0000_6ac7
        clr   tabrok_0xe,u

        ;0000:6a4e 8b 46 08        MOV        AX,word ptr [BP + 0x8]
        ;0000:6a51 05 20 00        ADD        AX,0x20
        ;0000:6a54 3b 06 28 00     CMP        AX,word ptr [0x28]
        ;0000:6a58 72 6d           JC         LAB_0000_6ac7
        ;0000:6a5a 2d 38 00        SUB        AX,0x38
        ;0000:6a5d 3b 06 28 00     CMP        AX,word ptr [0x28]
        ;0000:6a61 73 64           JNC        LAB_0000_6ac7

        ;ldd   player1+y_pos             
        ;subd  #($20*scale.YP1PX)/256
        ;cmpd  y_pos,u
        ;blt   LAB_0000_6ac7

        ldd   y_pos,u
        subd  #($20*scale.YP1PX)/256
        cmpd  player1+y_pos
        bgt   LAB_0000_6ac7
        
        addd  #($38*scale.YP1PX)/256
        cmpd  player1+y_pos
        blt   LAB_0000_6ac7

        ;0000:6a63 8b 46 04        MOV        AX,word ptr [BP + 0x4]
        ;0000:6a66 3b 06 24 00     CMP        AX,word ptr [0x24]
        ;0000:6a6a 72 0a           JC         LAB_0000_6a76
        ;0000:6a6c f7 46 2e        TEST       word ptr [BP + 0x2e],0x1
        ;         01 00
        ;0000:6a71 75 54           JNZ        LAB_0000_6ac7
        ;0000:6a73 e9 07 00        JMP        FUN_0000_6a7d_TabrokShootsCanon

        ldd   player1+x_pos
        cmpd  x_pos,u
        bgt   LAB_0000_6a76

        tst   tabrok_0x2e,u
        bne   LAB_0000_6ac7
        jmp   FUN_0000_6a7d_TabrokShootsCanon


        ;                     LAB_0000_6a76                                   XREF[1]:     0000:6a6a(j)  
        ;0000:6a76 f7 46 2e        TEST       word ptr [BP + 0x2e],0x1
        ;         01 00
        ;0000:6a7b 74 4a           JZ         LAB_0000_6ac7

LAB_0000_6a76
        tst   tabrok_0x2e,u
        beq   LAB_0000_6ac7


        ;                     **************************************************************
        ;                     *                          FUNCTION                          *
        ;                     **************************************************************
        ;                     undefined __cdecl16near FUN_0000_6a7d_TabrokShootsCanon()
        ;     undefined         <UNASSIGNED>   <RETURN>
        ;                     FUN_0000_6a7d_TabrokShootsCanon                XREF[1]:     FUN_0000_6a3e_ShouldTabrokFire:0
        ;0000:6a7d b9 00 60        MOV        CX,0x6000
        ;0000:6a7d b9 00 60        MOV        CX,0x6000
        ;0000:6a80 ba c8 66        MOV        DX,0x66c8
        ;0000:6a83 e8 20 9d        CALL       FUN_0000_07a6_LoadManagedObject                  byte FUN_0000_07a6_LoadManagedOb
        ;0000:6a86 72 3f           JC         LAB_0000_6ac7
        ;0000:6a88 8b 46 04        MOV        AX,word ptr [BP + 0x4]
        ;0000:6a8b 89 44 04        MOV        word ptr [SI + 0x4],AX
        ;0000:6a8e 8b 46 08        MOV        AX,word ptr [BP + 0x8]
        ;0000:6a91 05 0a 00        ADD        AX,0xa
        ;0000:6a94 89 44 08        MOV        word ptr [SI + 0x8],AX
        ;0000:6a97 c7 44 1f        MOV        word ptr [SI + 0x1f],0x1
        ;         01 00
        ;0000:6a9c b0 21           MOV        AL,0x21
        ;0000:6a9e e8 4d eb        CALL       FUN_0000_55ee_GetPaletteId                       undefined FUN_0000_55ee_GetPalet
        ;0000:6aa1 88 5c 06        MOV        byte ptr [SI + 0x6],BL
        ;0000:6aa4 8a 1e 2e 2f     MOV        BL,byte ptr [difficulty]
        ;0000:6aa8 32 ff           XOR        BH,BH
        ;0000:6aaa 03 db           ADD        BX,BX
        ;0000:6aac 26 8b 87        MOV        AX,word ptr ES:[BX + 0x2b48]
        ;         48 2b
        ;0000:6ab1 f7 46 2e        TEST       word ptr [BP + 0x2e],0x1
        ;         01 00
        ;0000:6ab6 75 07           JNZ        LAB_0000_6abf
        ;0000:6ab8 26 8b 87        MOV        AX,word ptr ES:[BX + 0x2b50]
        ;         50 2b
        ;0000:6abd f7 d8           NEG        AX
        ;                     LAB_0000_6abf                                   XREF[1]:     0000:6ab6(j)  
        ;0000:6abf 89 44 30        MOV        word ptr [SI + 0x30],AX
        ;0000:6ac2 b1 5d           MOV        CL,0x5d
        ;0000:6ac4 e8 3c 9c        CALL       FUN_0000_0703_EnqueueSoundFx                     undefined FUN_0000_0703_EnqueueS
        ;                     LAB_0000_6ac7                                   XREF[6]:     0000:6a47(j), 0000:6a58(j), 
        ;                                                                                  0000:6a61(j), 0000:6a71(j), 
        ;                                                                                  0000:6a7b(j), 0000:6a86(j)  
        ;0000:6ac7 c3              RET

FUN_0000_6a7d_TabrokShootsCanon

        jsr   LoadObject_x
        beq   LAB_0000_6ac7
        lda   #ObjID_tabrokcanon
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        subd  #($a*scale.YP1PX)/256
        std   y_pos,x
        ldy   #tabrok_0x2b48
        lda   tabrok_0x2e,u
        sta   subtype,x
        bne   LAB_0000_6abf
        ldy   #tabrok_0x2b50
LAB_0000_6abf
        ldb   globals.difficulty
        aslb
        ldd   b,y
        std   ext_variables+10,x
LAB_0000_6ac7
        rts



tabrok_0x2b60
        fdb   Img_tabrok_4
        fdb   Img_tabrok_4
        fdb   Img_tabrok_5
        fdb   Img_tabrok_4

tabrok_0x2b68
        fdb   Img_tabrok_12
        fdb   Img_tabrok_12
        fdb   Img_tabrok_13
        fdb   Img_tabrok_12

tabrok_0x2b70
        fdb   Img_tabrok_4
        fdb   Img_tabrok_0
        fdb   Img_tabrok_1
        fdb   Img_tabrok_0
        fdb   Img_tabrok_4
        fdb   Img_tabrok_2
        fdb   Img_tabrok_3
        fdb   Img_tabrok_2

tabrok_0x2b40
        fcb   $26
        fcb   $10
        fcb   $0C
        fcb   $08


tabrok_0x2b48
        fdb   $00F0   ; $0280
        fdb   $0240   ; $0600
        fdb   $02A0   ; $0700
        fdb   $0300   ; $0800
tabrok_0x2b50
        fdb   $FEB0   ; $0380
        fdb   $FDC0   ; $0600
        fdb   $FD60   ; $0700
        fdb   $FD00   ; $0800

tabrok_0x2b58
        fcb   $10
        fcb   $08
        fcb   $04
        fcb   $02

tabrok_0x2c94
        fdb   $fe00 ; missile 1
        fdb   $0000
        fdb   $000c
        fdb   $0004
        fdb   $fe00 ; missile 2
        fdb   $0000
        fdb   $000d
        fdb   $0003
        fdb   $ff40 ; missile 3
        fdb   $01c0
        fdb   $000f 
        fdb   $0001 
        fdb   $00c0 ; missile 4
        fdb   $00c0
        fdb   $0001 
        fdb   $000f



PresetXYIndex
        INCLUDE "./global/preset/18dd0_preset-xy.asm"