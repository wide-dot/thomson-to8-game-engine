; enemies width

enemies_patapata equ 20
enemies_bink     equ 28
enemies_bug      equ 24
enemies_scant    equ 24
enemies_pstaff   equ 14

; x_pos to instanciate object,object id,subtype,x_pos,y_pos


; First pata-pata wave
wave_patapata_01       equ 252
wave_patapata_01_space equ 4
        fdb   wave_patapata_01-140+wave_patapata_01_space*0,(ObjID_patapata*256)+00,wave_patapata_01+enemies_patapata+wave_patapata_01_space*0,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*1,(ObjID_patapata*256)+01,wave_patapata_01+enemies_patapata+wave_patapata_01_space*1,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*2,(ObjID_patapata*256)+00,wave_patapata_01+enemies_patapata+wave_patapata_01_space*2,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*3,(ObjID_patapata*256)+31,wave_patapata_01+enemies_patapata+wave_patapata_01_space*3,50


; Second pata-pata wave
wave_patapata_02       equ 278
wave_patapata_02_space equ 4
        fdb   wave_patapata_02-140+wave_patapata_02_space*0,(ObjID_patapata*256)+31,wave_patapata_02+enemies_patapata+wave_patapata_02_space*0,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*1,(ObjID_patapata*256)+30,wave_patapata_02+enemies_patapata+wave_patapata_02_space*1,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*2,(ObjID_patapata*256)+31,wave_patapata_02+enemies_patapata+wave_patapata_02_space*2,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*3,(ObjID_patapata*256)+30,wave_patapata_02+enemies_patapata+wave_patapata_02_space*3,100   

; solo bink
        fdb   304-140,(ObjID_bink*256)+55,332+enemies_bink,140

; First bug wave
wave_bug_01       equ 308
wave_bug_01_space equ 2
        fdb   wave_bug_01-140+wave_bug_01_space*0,(ObjID_bug*256)+0,wave_bug_01+enemies_bug+wave_bug_01_space*0,50
        fdb   wave_bug_01-140+wave_bug_01_space*1,(ObjID_bug*256)+0,wave_bug_01+enemies_bug+wave_bug_01_space*1,50
        fdb   wave_bug_01-140+wave_bug_01_space*2,(ObjID_bug*256)+0,wave_bug_01+enemies_bug+wave_bug_01_space*2,50
        fdb   wave_bug_01-140+wave_bug_01_space*3,(ObjID_bug*256)+30,wave_bug_01+enemies_bug+wave_bug_01_space*3,50
        fdb   wave_bug_01-140+wave_bug_01_space*4,(ObjID_bug*256)+0,wave_bug_01+enemies_bug+wave_bug_01_space*4,50  


; Second bug wave
wave_bug_02       equ 372
wave_bug_02_space equ 2
        fdb   wave_bug_02-140+wave_bug_02_space*0,(ObjID_bug*256)+1,wave_bug_02+enemies_bug+wave_bug_02_space*0,60
        fdb   wave_bug_02-140+wave_bug_02_space*1,(ObjID_bug*256)+1,wave_bug_02+enemies_bug+wave_bug_02_space*1,60
        fdb   wave_bug_02-140+wave_bug_02_space*2,(ObjID_bug*256)+1,wave_bug_02+enemies_bug+wave_bug_02_space*2,60
        fdb   wave_bug_02-140+wave_bug_02_space*3,(ObjID_bug*256)+31,wave_bug_02+enemies_bug+wave_bug_02_space*3,60
        fdb   wave_bug_02-140+wave_bug_02_space*4,(ObjID_bug*256)+1,wave_bug_02+enemies_bug+wave_bug_02_space*4,60    


; Third pata-pata wave
wave_patapata_03       equ 380
wave_patapata_03_space equ 4
        fdb   wave_patapata_03-140+wave_patapata_03_space*1,(ObjID_patapata*256)+26,wave_patapata_03+enemies_patapata+wave_patapata_03_space*1,100
        fdb   wave_patapata_03-140+wave_patapata_03_space*2,(ObjID_patapata*256)+27,wave_patapata_03+enemies_patapata+wave_patapata_03_space*2,100
        fdb   wave_patapata_03-140+wave_patapata_03_space*3,(ObjID_patapata*256)+26,wave_patapata_03+enemies_patapata+wave_patapata_03_space*4,110   

; Fourth pata-pata wave
wave_patapata_04       equ 392
wave_patapata_04_space equ 4
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*1,50
        fdb   wave_patapata_04-140+wave_patapata_04_space*2,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*2,40
        fdb   wave_patapata_04-140+wave_patapata_04_space*3,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*3,35
        fdb   wave_patapata_04-140+wave_patapata_04_space*4,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*4,95
        fdb   wave_patapata_04-140+wave_patapata_04_space*5,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*5,45
        fdb   wave_patapata_04-140+wave_patapata_04_space*6,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*6,55
        fdb   wave_patapata_04-140+wave_patapata_04_space*8,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*8,100
        fdb   wave_patapata_04-140+wave_patapata_04_space*9,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*9,40
        fdb   wave_patapata_04-140+wave_patapata_04_space*10,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*10,40
        fdb   wave_patapata_04-140+wave_patapata_04_space*11,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*11,95
        fdb   wave_patapata_04-140+wave_patapata_04_space*12,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*12,45
        fdb   wave_patapata_04-140+wave_patapata_04_space*14,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*14,40
        fdb   wave_patapata_04-140+wave_patapata_04_space*15,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*15,55
        fdb   wave_patapata_04-140+wave_patapata_04_space*16,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*16,35
        fdb   wave_patapata_04-140+wave_patapata_04_space*18,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*18,50
        fdb   wave_patapata_04-140+wave_patapata_04_space*20,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*20,100
        fdb   wave_patapata_04-140+wave_patapata_04_space*21,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*21,95
        fdb   wave_patapata_04-140+wave_patapata_04_space*24,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*24,80

; Solo bink #2
        fdb   504-140,(ObjID_bink*256)++55,504+enemies_bink,140

; Fifth pata-pata wave
wave_patapata_05       equ 507
wave_patapata_05_space equ 4
        fdb   wave_patapata_05-140+wave_patapata_05_space*1,(ObjID_patapata*256)+27,wave_patapata_05+enemies_patapata+wave_patapata_05_space*1,50
        fdb   wave_patapata_05-140+wave_patapata_05_space*2,(ObjID_patapata*256)+26,wave_patapata_05+enemies_patapata+wave_patapata_05_space*2,90

; Solo bink #3
        fdb   532-140,(ObjID_bink*256)++55,532+enemies_bink,140


; Fifth pata-pata wave
wave_patapata_06       equ 534
wave_patapata_06_space equ 4
        fdb   wave_patapata_06-140+wave_patapata_06_space*1,(ObjID_patapata*256)+27,wave_patapata_06+enemies_patapata+wave_patapata_06_space*1,50
        fdb   wave_patapata_06-140+wave_patapata_06_space*3,(ObjID_patapata*256)+26,wave_patapata_06+enemies_patapata+wave_patapata_06_space*3,70

; Scant #1
        fdb   560-140,(ObjID_scant*256)+00,560+enemies_scant,80

; Solo bink #3
        fdb   562-140,(ObjID_bink*256)+55,562+enemies_bink,140

; P-Staff #1
        fdb   588-140,(ObjID_pstaff*256)+00,588+enemies_pstaff,141

; Solo bink #4
        fdb   592-140,(ObjID_bink*256)+55,592+enemies_bink,140


wave_blasters_01      equ 810
        fdb wave_blasters_01-140,(ObjID_blaster*256)+160,wave_blasters_01+20,34
        fdb wave_blasters_01-140,(ObjID_blaster*256)+241,wave_blasters_01+20,132
        fdb wave_blasters_01-140+14,(ObjID_blaster*256)+250,wave_blasters_01+20+14,34
        fdb wave_blasters_01-140+14,(ObjID_blaster*256)+211,wave_blasters_01+20+14,132
        fdb wave_blasters_01-140+28,(ObjID_blaster*256)+190,wave_blasters_01+20+28,48
        fdb wave_blasters_01-140+28,(ObjID_blaster*256)+223,wave_blasters_01+20+28,118
        fdb wave_blasters_01-140+42,(ObjID_blaster*256)+180,wave_blasters_01+20+42,48
        fdb wave_blasters_01-140+42,(ObjID_blaster*256)+201,wave_blasters_01+20+42,118

        fdb wave_blasters_01-140+140,(ObjID_blaster*256)+160,wave_blasters_01+20+140,20
        fdb wave_blasters_01-140+154,(ObjID_blaster*256)+160,wave_blasters_01+20+154,20



; Shell wave
wave_shell        equ 982
wave_shell_width  equ 8
        fdb   wave_shell-140-8,(ObjID_shell*256)+00,1028,139

        fdb   -1 ; end marker


