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

AABB_0                  equ ext_variables    ; AABB struct (9 bytes)
cancer_0x1e             equ ext_variables+9  ; 1 byte, movement indicator ($02 = has not moved, other value = has moved)
cancer_0x20             equ ext_variables+10 ; 2 bytes, player 1 tracking reactivity setting (also renders Cancer inactive if > $400)
cancer_0x22             equ ext_variables+12 ; 2 bytes
cancer_0x2e             equ ext_variables+14 ; 1 byte, horizontal and vertical direction
                                             ; bit 0 = going up
                                             ; bit 1 = goind down
                                             ; bit 2 = going left
                                             ; bit 3 = going right
cancer_0x30             equ ext_variables+15 ; 2 bytes, reactivity degree (the smaller the more reactive)
firsttime               equ ext_variables+17 ; 1 bytes (=0 has not run yet, =1 has run)

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   FUN_0000_8db0_RunCancerMode1
        fdb   FUN_0000_8db0_RunCancerMode2
        fdb   AlreadyDeleted

Init

        ldb   subtype_w+1,u
        _loadFirePreset

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
        lda   #bink_hitdamage                   ; set damage potential for this hitbox
        sta   AABB_0+AABB.p,u
        _ldd  cancer_hitbox_x,cancer_hitbox_y       ; set hitbox xy radius
        std   AABB_0+AABB.rx,u
        

       ;0000:8d91 c7 44 20        MOV        word ptr [SI + 0x20],0x7f
       ;0000:8d96 8a 1e 2e 2f     MOV        BL,byte ptr [difficulty]
       ;0000:8d9a 32 ff           XOR        BH,BH
       ;0000:8d9c 03 db           ADD        BX,BX
       ;0000:8d9e 26 8b 87        MOV        AX,word ptr ES:[BX + 0x3c1a]

        ldd   #$7f
        std   cancer_0x20,u
        ldb   globals.difficulty
        aslb
        clra
        ldx   #cancer_0x3c1a
        ldd   d,x

        ;ldd   #$90              ; manually override (not in original source code)
        std   cancer_0x30,u

        lda   #1
        sta   routine,u

FUN_0000_8db0_RunCancerMode1

        jsr   tryFoeFire

        lda   firsttime,u
        beq   skip_reactivity

       ;0000:8db3 ff 46 20        INC        word ptr [BP + 0x20]
       ;0000:8db6 8b 46 30        MOV        AX,word ptr [BP + 0x30]
       ;0000:8db9 85 46 20        TEST       word ptr [BP + 0x20],AX
       ;0000:8dbc 75 29           JNZ        LAB_0000_8de7
       ;0000:8dbe 81 7e 20        CMP        word ptr [BP + 0x20],0x400
       ;          00 04
       ;0000:8dc3 73 22           JNC        LAB_0000_8de7

        ldd   gfxlock.frameDrop.count_w
        clra
        addd  cancer_0x20,u
        std   cancer_0x20,u
        anda  cancer_0x30,u
        andb  cancer_0x30+1,u
        std   -2,s
        bne   LAB_0000_8de7
        cmpd  #$400
        bge   LAB_0000_8de7

skip_reactivity

        lda   #1
        sta   firsttime,u        


       ;0000:8dc5 b3 01           MOV        BL,0x1
       ;0000:8dc7 8b 46 08        MOV        AX,word ptr [BP + 0x8]
       ;0000:8dca 3b 06 28 00     CMP        AX,word ptr [0x28]
       ;0000:8dce 72 02           JC         LAB_0000_8dd2
       ;0000:8dd0 b3 02           MOV        BL,0x2

LAB_0000_8dc5

        ldb   #$01
        ldx   player1+y_pos
        cmpx  y_pos,u
        bmi   LAB_0000_8dd2             
        ldb   #$02

LAB_0000_8dd2
 
       ;0000:8dd2 8b 46 04        MOV        AX,word ptr [BP + 0x4]
       ;0000:8dd5 3b 06 24 00     CMP        AX,word ptr [0x24]
       ;0000:8dd9 72 06           JC         LAB_0000_8de1
       ;0000:8ddb 80 cb 04        OR         BL,0x4
       ;0000:8dde e9 03 00        JMP        LAB_0000_8de4
       ;                      LAB_0000_8de1                                   XREF[1]:     0000:8dd9(j)  
       ;0000:8de1 80 cb 08        OR         BL,0x8
       ;                      LAB_0000_8de4                                   XREF[1]:     0000:8dde(j)  
       ;0000:8de4 88 5e 2e        MOV        byte ptr [BP + 0x2e],BL


        ldx   player1+x_pos
        cmpx  x_pos,u
        bpl   LAB_0000_8de1
        orb   #$04
        jmp   LAB_0000_8de4

LAB_0000_8de1
        orb   #$08

LAB_0000_8de4
        stb   cancer_0x2e,u


       ; LAB_0000_8de7                                   XREF[2]:     0000:8dbc(j), 0000:8dc3(j)  
       ;0000:8de7 c6 46 1e 02     MOV        byte ptr [BP + 0x1e],0x2
       ;0000:8deb f6 46 2e 01     TEST       byte ptr [BP + 0x2e],0x1
       ;0000:8def 74 1b           JZ         LAB_0000_8e0c
       ;0000:8df1 ff 76 08        PUSH       word ptr [BP + 0x8]
       ;0000:8df4 83 46 08 18     ADD        word ptr [BP + 0x8],0x18
       ;0000:8df8 e8 71 94        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
       ;0000:8dfb 8f 46 08        POP        word ptr [BP + 0x8]
       ;0000:8dfe 3d fc 0d        CMP        AX,0xdfc
       ;0000:8e01 72 09           JC         LAB_0000_8e0c
       ;0000:8e03 fe 4e 1e        DEC        byte ptr [BP + 0x1e]
       ;0000:8e06 b8 c0 00        MOV        AX,0xc0
       ;0000:8e09 e8 7d 7c        CALL       FUN_0000_0a89_MoveYPos8.8                        undefined FUN_0000_0a89_MoveYPos

LAB_0000_8de7                           ; Going down ?
        ldb   #$02
        stb   cancer_0x1e,u
        ldb   cancer_0x2e,u
        andb  #$02                      ; originally $01 but Y axis inverted on Arcade
        beq   LAB_0000_8e0c
        ldd   y_pos,u
        addd  #($18*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   LAB_0000_8e0c
        dec   cancer_0x1e,u
        ldb   #($c0*scale.YP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveYPos8.8

       ;                      LAB_0000_8e0c                                   XREF[2]:     0000:8def(j), 0000:8e01(j)  
       ;0000:8e0c f6 46 2e 02     TEST       byte ptr [BP + 0x2e],0x2
       ;0000:8e10 74 1b           JZ         LAB_0000_8e2d
       ;0000:8e12 ff 76 08        PUSH       word ptr [BP + 0x8]
       ;                      LAB_0000_8e15                                   XREF[1]:     0000:9204(*)  
       ;0000:8e15 83 6e 08 18     SUB        word ptr [BP + 0x8],0x18
       ;0000:8e19 e8 50 94        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
       ;0000:8e1c 8f 46 08        POP        word ptr [BP + 0x8]
       ;0000:8e1f 3d fc 0d        CMP        AX,0xdfc
       ;0000:8e22 72 09           JC         LAB_0000_8e2d
       ;0000:8e24 fe 4e 1e        DEC        byte ptr [BP + 0x1e]
       ;0000:8e27 b8 40 ff        MOV        AX,0xff40
       ;0000:8e2a e8 5c 7c        CALL       FUN_0000_0a89_MoveYPos8.8                        undefined FUN_0000_0a89_MoveYPos


LAB_0000_8e0c                           ; Going up ?
        ldb   cancer_0x2e,u
        andb  #$01                      ; originally $02 but Y axis inverted on Arcade
        beq   LAB_0000_8e2d
LAB_0000_8e15
        ldd   y_pos,u
        subd  #($18*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   LAB_0000_8e2d
        dec   cancer_0x1e,u
        ldb   #($c0*scale.YP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        _negd
        jsr   moveYPos8.8


       ;                      LAB_0000_8e2d                                   XREF[2]:     0000:8e10(j), 0000:8e22(j)  
       ;0000:8e2d f6 46 2e 04     TEST       byte ptr [BP + 0x2e],0x4
       ;0000:8e31 74 1b           JZ         LAB_0000_8e4e
       ;0000:8e33 ff 76 04        PUSH       word ptr [BP + 0x4]
       ;0000:8e36 83 6e 04 18     SUB        word ptr [BP + 0x4],0x18
       ;0000:8e3a e8 2f 94        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
       ;0000:8e3d 8f 46 04        POP        word ptr [BP + 0x4]
       ;0000:8e40 3d fc 0d        CMP        AX,0xdfc
       ;0000:8e43 72 09           JC         LAB_0000_8e4e
       ;0000:8e45 fe 4e 1e        DEC        byte ptr [BP + 0x1e]
       ;0000:8e48 b8 40 ff        MOV        AX,0xff40
       ;0000:8e4b e8 24 7c        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos

LAB_0000_8e2d                           ; Going left ?
        ldb   cancer_0x2e,u
        andb  #$04
        beq   LAB_0000_8e4e
        ldd   x_pos,u
        subd  #($18*scale.XP1PX)/256
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   LAB_0000_8e4e
        dec   cancer_0x1e,u
        ldb   #($c0*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        _negd
        jsr   moveXPos8.8


       ;                      LAB_0000_8e4e                                   XREF[2]:     0000:8e31(j), 0000:8e43(j)  
       ;0000:8e4e f6 46 2e 08     TEST       byte ptr [BP + 0x2e],0x8
       ;0000:8e52 74 1b           JZ         LAB_0000_8e6f
       ;0000:8e54 ff 76 04        PUSH       word ptr [BP + 0x4]
       ;0000:8e57 83 46 04 18     ADD        word ptr [BP + 0x4],0x18
       ;0000:8e5b e8 0e 94        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
       ;0000:8e5e 8f 46 04        POP        word ptr [BP + 0x4]
       ;0000:8e61 3d fc 0d        CMP        AX,0xdfc
       ;0000:8e64 72 09           JC         LAB_0000_8e6f
       ;0000:8e66 fe 4e 1e        DEC        byte ptr [BP + 0x1e]
       ;0000:8e69 b8 c0 00        MOV        AX,0xc0
       ;0000:8e6c e8 03 7c        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos

LAB_0000_8e4e                           ; Going right ?
        ldb   cancer_0x2e,u
        andb  #$08
        beq   LAB_0000_8e6f
        ldd   x_pos,u
        addd  #($18*scale.XP1PX)/256
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   LAB_0000_8e6f
        dec   cancer_0x1e,u
        ldb   #($c0*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveXPos8.8


       ;                      LAB_0000_8e6f                                   XREF[2]:     0000:8e52(j), 0000:8e64(j)  
       ;0000:8e6f be 2a 3c        MOV        SI,0x3c2a
       ;0000:8e72 f6 46 2e 08     TEST       byte ptr [BP + 0x2e],0x8
       ;0000:8e76 75 03           JNZ        LAB_0000_8e7b
       ;0000:8e78 be 22 3c        MOV        SI,0x3c22
       ;                             LAB_0000_8e7b                                   XREF[1]:     0000:8e76(j)  
       ;0000:8e7b a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]
       ;0000:8e7e 01 46 04        ADD        word ptr [BP + 0x4],AX
       ;0000:8e81 8b 1e b6 2e     MOV        BX,word ptr [0x2eb6_globalCounter]
       ;0000:8e85 81 e3 30 00     AND        BX,0x30
       ;0000:8e89 c1 eb 03        SHR        BX,0x3
       ;0000:8e8c 26 8b 18        MOV        BX,word ptr ES:[BX + SI]
       ;0000:8e8f e8 3a 91        CALL       FUN_0000_1fcc_Write1Sprite_A                     undefined FUN_0000_1fcc_Write1Sp

LAB_0000_8e6f
        ldy   #ImageIndex+8
        ldb   cancer_0x2e,u
        andb  #$08
        bne   LAB_0000_8e7b
        ldy   #ImageIndex
LAB_0000_8e7b
        ldb   gfxlock.frame.count+1
        andb  #$30
        asrb
        asrb
        asrb
        ldd   b,y
        std   image_set,u


        ; LAB_0000_8eaf                                   XREF[1]:     0000:8eaa(j)  
        ;0000:8eaf 80 7e 1e 02     CMP        byte ptr [BP + 0x1e],0x2
        ;0000:8eb3 75 03           JNZ        LAB_0000_8eb8
        ;0000:8eb5 e9 01 00        JMP        LAB_0000_8eb9
        ;                            LAB_0000_8eb8                                   XREF[1]:     0000:8eb3(j)  
        ;0000:8eb8 c3              RET
        ;                            LAB_0000_8eb9                                   XREF[1]:     0000:8eb5(j)  
        ;0000:8eb9 c7 46 00        MOV        word ptr [BP + 0x0],0x8aee  -> FUN_0000_8db0_RunCancerMode2 
        ;0000:8ebe c7 46 22        MOV        word ptr [BP + 0x22],0x3ff

LAB_0000_8eaf
        ldb   cancer_0x1e,u
        cmpb  #$02
        lbne  Live
LAB_0000_8eb9
        lda   #2
        sta   routine,u
        ldd   #$3ff
        std   cancer_0x22,u
        jmp   Live

       ;                              FUN_0000_8db0_RunCancerMode2
       ;0000:8eee e8 49 6b        CALL       FUN_0000_fa3a_TryFoeFire                         undefined FUN_0000_fa3a_TryFoeFi
       ;0000:8ef1 ff 46 20        INC        word ptr [BP + 0x20]
       ;0000:8ef4 8b 46 30        MOV        AX,word ptr [BP + 0x30]
       ;0000:8ef7 85 46 20        TEST       word ptr [BP + 0x20],AX
       ;0000:8efa 75 29           JNZ        LAB_0000_8f25
       ;0000:8efc 81 7e 20        CMP        word ptr [BP + 0x20],0x400
       ;          00 04
       ;0000:8f01 73 22           JNC        LAB_0000_8f25
       ;0000:8f03 b3 01           MOV        BL,0x1
       ;0000:8f05 8b 46 08        MOV        AX,word ptr [BP + 0x8]
       ;0000:8f08 3b 06 28 00     CMP        AX,word ptr [0x28]
       ;0000:8f0c 73 02           JNC        LAB_0000_8f10
       ;0000:8f0e b3 02           MOV        BL,0x2

FUN_0000_8db0_RunCancerMode2

        jsr   tryFoeFire

        ldd   gfxlock.frameDrop.count_w
        clra
        addd  cancer_0x20,u
        std   cancer_0x20,u
        anda  cancer_0x30,u
        andb  cancer_0x30+1,u
        std   -2,s
        bne   LAB_0000_8f25
        cmpd  #$400
        bpl   LAB_0000_8f25

        ldb   #$01
        ldx   player1+y_pos
        cmpx  y_pos,u
        bmi   LAB_0000_8f10
        ldb   #$02

       ;                      LAB_0000_8f10                                   XREF[1]:     0000:8f0c(j)  
       ;0000:8f10 8b 46 04        MOV        AX,word ptr [BP + 0x4]
       ;0000:8f13 3b 06 24 00     CMP        AX,word ptr [0x24]
       ;0000:8f17 72 06           JC         LAB_0000_8f1f
       ;0000:8f19 80 cb 04        OR         BL,0x4
       ;0000:8f1c e9 03 00        JMP        LAB_0000_8f22
       ;                      LAB_0000_8f1f                                   XREF[1]:     0000:8f17(j)  
       ;0000:8f1f 80 cb 08        OR         BL,0x8
       ;                      LAB_0000_8f22                                   XREF[1]:     0000:8f1c(j)  
       ;0000:8f22 88 5e 2e        MOV        byte ptr [BP + 0x2e],BL

LAB_0000_8f10

        ldx   player1+x_pos
        cmpx  x_pos,u
        bpl   LAB_0000_8f1f
        orb   #$04
        jmp   LAB_0000_8f22
LAB_0000_8f1f
        orb   #$08
LAB_0000_8f22
        stb   cancer_0x2e,u

       ;                      LAB_0000_8f25                                   XREF[2]:     0000:8efa(j), 0000:8f01(j)  
       ;0000:8f25 c6 46 1e 02     MOV        byte ptr [BP + 0x1e],0x2
       ;0000:8f29 f6 46 2e 01     TEST       byte ptr [BP + 0x2e],0x1
       ;0000:8f2d 74 1e           JZ         LAB_0000_8f4d
       ;0000:8f2f ff 76 08        PUSH       word ptr [BP + 0x8]
       ;0000:8f32 83 46 08 18     ADD        word ptr [BP + 0x8],0x18
       ;0000:8f36 e8 33 93        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
       ;0000:8f39 8f 46 08        POP        word ptr [BP + 0x8]
       ;0000:8f3c 3d fc 0d        CMP        AX,0xdfc
       ;0000:8f3f 72 0c           JC         LAB_0000_8f4d
       ;0000:8f41 fe 4e 1e        DEC        byte ptr [BP + 0x1e]
       ;0000:8f44 b8 c0 00        MOV        AX,0xc0
       ;0000:8f47 e8 3f 7b        CALL       FUN_0000_0a89_MoveYPos8.8                        undefined FUN_0000_0a89_MoveYPos
       ;0000:8f4a e9 05 00        JMP        LAB_0000_8f52

LAB_0000_8f25
        ldb   #$02
        stb   cancer_0x1e,u
        ldb   cancer_0x2e,u
        andb  #$02                      ; originally $01 but Y axis inverted on Arcade
        beq   LAB_0000_8f4d
        ldd   y_pos,u
        addd  #($18*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bmi   LAB_0000_8f4d
        dec   cancer_0x1e,u
        ldb   #($c0*scale.YP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveYPos8.8
        jmp   LAB_0000_8f52


        ;                            LAB_0000_8f4d                                   XREF[2]:     0000:8f2d(j), 0000:8f3f(j)  
        ;0000:8f4d c7 46 22        MOV        word ptr [BP + 0x22],0x1
        ;                            LAB_0000_8f52                                   XREF[1]:     0000:8f4a(j)  
        ;0000:8f52 f6 46 2e 02     TEST       byte ptr [BP + 0x2e],0x2
        ;0000:8f56 74 1e           JZ         LAB_0000_8f76
        ;0000:8f58 ff 76 08        PUSH       word ptr [BP + 0x8]
        ;0000:8f5b 83 6e 08 18     SUB        word ptr [BP + 0x8],0x18
        ;0000:8f5f e8 0a 93        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
        ;0000:8f62 8f 46 08        POP        word ptr [BP + 0x8]
        ;0000:8f65 3d fc 0d        CMP        AX,0xdfc
        ;0000:8f68 72 0c           JC         LAB_0000_8f76
        ;0000:8f6a fe 4e 1e        DEC        byte ptr [BP + 0x1e]
        ;0000:8f6d b8 40 ff        MOV        AX,0xff40
        ;0000:8f70 e8 16 7b        CALL       FUN_0000_0a89_MoveYPos8.8                        undefined FUN_0000_0a89_MoveYPos
        ;0000:8f73 e9 05 00        JMP        LAB_0000_8f7b
LAB_0000_8f4d
        ldx   #$01
        stx   cancer_0x22,u
LAB_0000_8f52
        ldb   cancer_0x2e,u
        andb  #$02                      ; originally $02 but Y axis inverted on Arcade
        beq   LAB_0000_8f76
        ldd   y_pos,u
        subd  #($18*scale.YP1PX)/256
        std   terrainCollision.sensor.y
        ldd   x_pos,u
        std   terrainCollision.sensor.x
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   LAB_0000_8f76
        dec   cancer_0x1e,u
        ldb   #($c0*scale.YP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        _negd
        jsr   moveYPos8.8
        jmp   LAB_0000_8f7b

        ;                            LAB_0000_8f76                                   XREF[2]:     0000:8f56(j), 0000:8f68(j)  
        ;0000:8f76 c7 46 22        MOV        word ptr [BP + 0x22],0x1
        ;                            LAB_0000_8f7b                                   XREF[1]:     0000:8f73(j)  
        ;0000:8f7b f6 46 2e 04     TEST       byte ptr [BP + 0x2e],0x4
        ;0000:8f7f 74 1b           JZ         LAB_0000_8f9c
        ;0000:8f81 ff 76 04        PUSH       word ptr [BP + 0x4]
        ;0000:8f84 83 6e 04 18     SUB        word ptr [BP + 0x4],0x18
        ;0000:8f88 e8 e1 92        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
        ;0000:8f8b 8f 46 04        POP        word ptr [BP + 0x4]
        ;0000:8f8e 3d fc 0d        CMP        AX,0xdfc
        ;0000:8f91 72 09           JC         LAB_0000_8f9c
        ;0000:8f93 fe 4e 1e        DEC        byte ptr [BP + 0x1e]
        ;0000:8f96 b8 40 ff        MOV        AX,0xff40
        ;0000:8f99 e8 d6 7a        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos

LAB_0000_8f76
        ldx   #$01
        stx   cancer_0x22,u        
LAB_0000_8f7b
        ldb   cancer_0x2e,u
        andb  #$04
        beq   LAB_0000_8f9c
        ldd   x_pos,u
        subd  #($18*scale.XP1PX)/256
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   LAB_0000_8f9c
        dec   cancer_0x1e,u
        ldb   #($c0*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        _negd
        jsr   moveXPos8.8

        ;                    LAB_0000_8f9c                                   XREF[2]:     0000:8f7f(j), 0000:8f91(j)  
        ;0000:8f9c f6 46 2e 08     TEST       byte ptr [BP + 0x2e],0x8
        ;0000:8fa0 74 1b           JZ         LAB_0000_8fbd
        ;0000:8fa2 ff 76 04        PUSH       word ptr [BP + 0x4]
        ;0000:8fa5 83 46 04 18     ADD        word ptr [BP + 0x4],0x18
        ;0000:8fa9 e8 c0 92        CALL       FUN_0000_226c_DoForeTerrainCollision             undefined FUN_0000_226c_DoForeTe
        ;0000:8fac 8f 46 04        POP        word ptr [BP + 0x4]
        ;0000:8faf 3d fc 0d        CMP        AX,0xdfc
        ;0000:8fb2 72 09           JC         LAB_0000_8fbd
        ;0000:8fb4 fe 4e 1e        DEC        byte ptr [BP + 0x1e]
        ;0000:8fb7 b8 c0 00        MOV        AX,0xc0
        ;0000:8fba e8 b5 7a        CALL       FUN_0000_0a72_MoveXPos8.8                        undefined FUN_0000_0a72_MoveXPos

LAB_0000_8f9c
        ldb   cancer_0x2e,u
        andb  #$08
        beq   LAB_0000_8fbd
        ldd   x_pos,u
        addd  #($18*scale.XP1PX)/256
        std   terrainCollision.sensor.x
        ldd   y_pos,u
        std   terrainCollision.sensor.y
        ldb   #1 ; foreground
        jsr   terrainCollision.do
        tstb
        bne   LAB_0000_8fbd
        dec   cancer_0x1e,u
        ldb   #($c0*scale.XP1PX)/256
        lda   gfxlock.frameDrop.count
        mul
        jsr   moveXPos8.8


        ;                            LAB_0000_8fbd                                   XREF[2]:     0000:8fa0(j), 0000:8fb2(j)  
        ;0000:8fbd be 2a 3c        MOV        SI,0x3c2a
        ;0000:8fc0 f6 46 2e 08     TEST       byte ptr [BP + 0x2e],0x8
        ;0000:8fc4 75 03           JNZ        LAB_0000_8fc9
        ;0000:8fc6 be 22 3c        MOV        SI,0x3c22
        ;                            LAB_0000_8fc9                                   XREF[1]:     0000:8fc4(j)  
        ;0000:8fc9 a1 d0 2e        MOV        AX,[0x2ed0_scrollAmount]
        ;0000:8fcc 01 46 04        ADD        word ptr [BP + 0x4],AX
        ;0000:8fcf 8b 1e b6 2e     MOV        BX,word ptr [0x2eb6_globalCounter]
        ;0000:8fd3 81 e3 30 00     AND        BX,0x30
        ;0000:8fd7 c1 eb 03        SHR        BX,0x3
        ;0000:8fda 26 8b 18        MOV        BX,word ptr ES:[BX + SI]
        ;0000:8fdd e8 ec 8f        CALL       FUN_0000_1fcc_Write1Sprite_A                     undefined FUN_0000_1fcc_Write1Sp


LAB_0000_8fbd
        ldy   #ImageIndex+8
        ldb   cancer_0x2e,u
        andb  #$08
        bne   LAB_0000_8fc9
        ldy   #ImageIndex
LAB_0000_8fc9
        ldb   gfxlock.frame.count+1
        andb  #$30
        asrb
        asrb
        asrb
        ldd   b,y
        std   image_set,u

        ;                            LAB_0000_8ffd                                   XREF[1]:     0000:8ff8(j)  
        ;0000:8ffd 80 7e 1e 02     CMP        byte ptr [BP + 0x1e],0x2
        ;0000:9001 75 03           JNZ        LAB_0000_9006
        ;0000:9003 e9 06 00        JMP        LAB_0000_900c
        ;                            LAB_0000_9006                                   XREF[1]:     0000:9001(j)  
        ;0000:9006 ff 4e 22        DEC        word ptr [BP + 0x22]
        ;0000:9009 74 01           JZ         LAB_0000_900c
        ;0000:900b c3              RET
        ;                            LAB_0000_900c                                   XREF[2]:     0000:9003(j), 0000:9009(j)  
        ;0000:900c c7 46 00        MOV        word ptr [BP + 0x0],LAB_0000_89b0   --> FUN_0000_8db0_RunCancerMode1

LAB_0000_8ffd

        ldb   cancer_0x1e,u
        cmpb  #$02
        beq   LAB_0000_900c
LAB_0000_9006
        ldd   cancer_0x22,u
        subd  gfxlock.frameDrop.count_w
        std   cancer_0x22,u
        bpl   Live
LAB_0000_900c
        lda   #1
        sta   routine,u   



; rest of the original code

Live
        lda   AABB_0+AABB.p,u
        beq   @destroy                  ; was killed  
        ldd   x_pos,u
        subd  glb_camera_x_pos
        stb   AABB_0+AABB.cx,u
        addd  #5                       ; add x radius
        bmi   @delete                  ; branch if out of screen's left
        ldb   y_pos+1,u
        stb   AABB_0+AABB.cy,u
        jmp   DisplaySprite
@destroy 
        ldd   score
        addd  #cancer_score
        std   score
        jsr   LoadObject_x ; make then die early ... to be removed
        beq   @delete
        lda   #ObjID_enemiesblastsmall
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        ldd   x_vel,u
        std   x_vel,x
        clr   y_vel,x
@delete 
        lda   #3
        sta   routine,u      
        _Collision_RemoveAABB AABB_0,AABB_list_ennemy
        jmp   DeleteObject
AlreadyDeleted
        rts

ImageIndex
        fdb   Img_cancer_0
        fdb   Img_cancer_1
        fdb   Img_cancer_2
        fdb   Img_cancer_1
        fdb   Img_cancer_3
        fdb   Img_cancer_4
        fdb   Img_cancer_5
        fdb   Img_cancer_4


cancer_0x3c1a
        fdb   $000f ;$007f
        fdb   $0007 ;$001f 
        fdb   $0003 ;$000f
        fdb   $0001 ;$0007

PresetXYIndex
        INCLUDE "./global/preset/18dd0_preset-xy.asm"
