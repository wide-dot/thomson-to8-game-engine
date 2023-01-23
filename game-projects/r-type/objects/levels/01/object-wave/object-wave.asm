; enemies width

enemies_patapata equ 20
enemies_bink     equ 28
enemies_bug      equ 24

; x_pos to instanciate object,object id,subtype,x_pos,y_pos


; First pata-pata wave
wave_patapata_01       equ 168
wave_patapata_01_space equ 4
        fdb   wave_patapata_01-140+wave_patapata_01_space*0,(ObjID_patapata*256)+01,wave_patapata_01+enemies_patapata+wave_patapata_01_space*0,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*1,(ObjID_patapata*256)+02,wave_patapata_01+enemies_patapata+wave_patapata_01_space*1,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*2,(ObjID_patapata*256)+01,wave_patapata_01+enemies_patapata+wave_patapata_01_space*2,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*3,(ObjID_patapata*256)+02,wave_patapata_01+enemies_patapata+wave_patapata_01_space*3,50

; Second pata-pata wave
wave_patapata_02       equ 196
wave_patapata_02_space equ 4
        fdb   wave_patapata_02-140+wave_patapata_02_space*0,(ObjID_patapata*256)+01,wave_patapata_02+enemies_patapata+wave_patapata_02_space*0,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*1,(ObjID_patapata*256)+02,wave_patapata_02+enemies_patapata+wave_patapata_02_space*1,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*2,(ObjID_patapata*256)+01,wave_patapata_02+enemies_patapata+wave_patapata_02_space*2,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*3,(ObjID_patapata*256)+02,wave_patapata_02+enemies_patapata+wave_patapata_02_space*3,100   

; solo bink
        fdb   220-140,(ObjID_bink*256)+00,220+enemies_bink,140



; First bug wave
wave_bug_01       equ 224
test equ 16
wave_bug_01_space equ 2
        fdb   wave_bug_01-140+wave_bug_01_space*0,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*0,50
        fdb   wave_bug_01-140+wave_bug_01_space*1,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*1,50
        fdb   wave_bug_01-140+wave_bug_01_space*2,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*2,50
        fdb   wave_bug_01-140+wave_bug_01_space*3,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*3,50
        fdb   wave_bug_01-140+wave_bug_01_space*4,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*4,50  


; Second bug wave
wave_bug_02       equ 260
wave_bug_02_space equ 2
        fdb   wave_bug_02-140+wave_bug_02_space*0,(ObjID_bug*256)+2,wave_bug_02+enemies_bug+wave_bug_02_space*0,60
        fdb   wave_bug_02-140+wave_bug_02_space*1,(ObjID_bug*256)+2,wave_bug_02+enemies_bug+wave_bug_02_space*1,60
        fdb   wave_bug_02-140+wave_bug_02_space*2,(ObjID_bug*256)+2,wave_bug_02+enemies_bug+wave_bug_02_space*2,60
        fdb   wave_bug_02-140+wave_bug_02_space*3,(ObjID_bug*256)+2,wave_bug_02+enemies_bug+wave_bug_02_space*3,60
        fdb   wave_bug_02-140+wave_bug_02_space*4,(ObjID_bug*256)+2,wave_bug_02+enemies_bug+wave_bug_02_space*4,60    


; Third pata-pata wave
wave_patapata_03       equ 268
wave_patapata_03_space equ 4
        fdb   wave_patapata_03-140+wave_patapata_03_space*1,(ObjID_patapata*256)+02,wave_patapata_03+enemies_patapata+wave_patapata_03_space*1,100
        fdb   wave_patapata_03-140+wave_patapata_03_space*2,(ObjID_patapata*256)+01,wave_patapata_03+enemies_patapata+wave_patapata_03_space*2,100
        fdb   wave_patapata_03-140+wave_patapata_03_space*3,(ObjID_patapata*256)+02,wave_patapata_03+enemies_patapata+wave_patapata_03_space*4,110   

; Fourth pata-pata wave
wave_patapata_04       equ 280
wave_patapata_04_space equ 14
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+02,wave_patapata_04+enemies_patapata+wave_patapata_04_space*1,50
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*2,40
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*3,35
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+02,wave_patapata_04+enemies_patapata+wave_patapata_04_space*4,95
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*5,45
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+02,wave_patapata_04+enemies_patapata+wave_patapata_04_space*6,55
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*8,100
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+02,wave_patapata_04+enemies_patapata+wave_patapata_04_space*9,40
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*10,40
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+02,wave_patapata_04+enemies_patapata+wave_patapata_04_space*11,95
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*12,45
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+02,wave_patapata_04+enemies_patapata+wave_patapata_04_space*14,40
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*15,55
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+02,wave_patapata_04+enemies_patapata+wave_patapata_04_space*16,35
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*18,50
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+02,wave_patapata_04+enemies_patapata+wave_patapata_04_space*20,100
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*21,95
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+01,wave_patapata_04+enemies_patapata+wave_patapata_04_space*24,80

; Shell wave
wave_shell        equ 870
wave_shell_width  equ 8
        fdb   wave_shell-140-8,(ObjID_shell*256)+00,916,139

        fdb   -1 ; end marker


