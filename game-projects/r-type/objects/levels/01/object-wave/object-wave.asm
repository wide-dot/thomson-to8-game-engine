; x_pos to instanciate object,object id,subtype,x_pos,y_pos

; First pata-pata wave
wave_patapata_01       equ 180
wave_patapata_01_space equ 4
        fdb   wave_patapata_01-140+wave_patapata_01_space*0,(ObjID_patapata*256)+01,wave_patapata_01+wave_patapata_01_space*0,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*1,(ObjID_patapata*256)+02,wave_patapata_01+wave_patapata_01_space*1,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*2,(ObjID_patapata*256)+01,wave_patapata_01+wave_patapata_01_space*2,50
        fdb   wave_patapata_01-140+wave_patapata_01_space*3,(ObjID_patapata*256)+02,wave_patapata_01+wave_patapata_01_space*3,50

; Second pata-pata wave
wave_patapata_02       equ 205
wave_patapata_02_space equ 4
        fdb   wave_patapata_02-140+wave_patapata_02_space*0,(ObjID_patapata*256)+01,wave_patapata_02+wave_patapata_02_space*0,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*1,(ObjID_patapata*256)+02,wave_patapata_02+wave_patapata_02_space*1,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*2,(ObjID_patapata*256)+01,wave_patapata_02+wave_patapata_02_space*2,100
        fdb   wave_patapata_02-140+wave_patapata_02_space*3,(ObjID_patapata*256)+02,wave_patapata_02+wave_patapata_02_space*3,100   

; solo bink
        fdb   220-140,(ObjID_bink*256)+00,220,140



        fdb   223-140
        fcb   ObjID_enemiesblastsmall
        fcb   00
        fdb   223,80

        fdb   228-140
        fcb   ObjID_enemiesblastsmall
        fcb   00
        fdb   228,110

        fdb   233-140
        fcb   ObjID_enemiesblastsmall
        fcb   00
        fdb   233,90



; First bug wave
wave_bug_01       equ 230
wave_bug_01_space equ 2
        fdb   wave_bug_01-140+wave_bug_01_space*0,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*0,60
        fdb   wave_bug_01-140+wave_bug_01_space*1,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*1,60
        fdb   wave_bug_01-140+wave_bug_01_space*2,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*2,60
        fdb   wave_bug_01-140+wave_bug_01_space*3,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*3,60
        fdb   wave_bug_01-140+wave_bug_01_space*4,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*4,60        


        fdb   245-140
        fcb   ObjID_enemiesblastbig
        fcb   00
        fdb   230,90

        fdb   250-140
        fcb   ObjID_enemiesblastbig
        fcb   00
        fdb   235,130

        fdb   255-140
        fcb   ObjID_enemiesblastbig
        fcb   00
        fdb   240,110

        fdb   260-140
        fcb   ObjID_enemiesblastbig
        fcb   00
        fdb   242,130

        fdb   260-140
        fcb   ObjID_enemiesblastbig
        fcb   00
        fdb   243,30

        fdb   260-140
        fcb   ObjID_enemiesblastbig
        fcb   00
        fdb   245,70


; Second bug wave
wave_bug_02       equ 260
wave_bug_02_space equ 2
        fdb   wave_bug_02-140+wave_bug_02_space*0,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*0,60
        fdb   wave_bug_02-140+wave_bug_02_space*1,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*1,60
        fdb   wave_bug_02-140+wave_bug_02_space*2,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*2,60
        fdb   wave_bug_02-140+wave_bug_02_space*3,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*3,60
        fdb   wave_bug_02-140+wave_bug_02_space*4,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*4,60    


        fdb   270-140
        fcb   ObjID_Weapon4
        fcb   00
        fdb   280,90

        fdb   270-140
        fcb   ObjID_Weapon3
        fcb   00
        fdb   280,50

        fdb   270-140
        fcb   ObjID_Weapon2
        fcb   00
        fdb   280,10

        fdb   270-140
        fcb   ObjID_Weapon5
        fcb   00
        fdb   280,130

; Shell wave
wave_shell        equ 870
wave_shell_width  equ 8
        fdb   wave_shell-140-8,(ObjID_shell*256)+00,916,139

        fdb   -1 ; end marker


