; enemies width

enemies_patapata equ 20
enemies_bink     equ 28
enemies_bug      equ 24
enemies_scant    equ 24
enemies_pstaff   equ 14

; x_pos to instanciate object,object id,subtype,x_pos,y_pos

tilesizex        equ 24
tilesizey        equ 12
offset_y         equ 0




; Scant #1
        ;fdb   250-140,(ObjID_scant*256)+00,250+enemies_scant,80

        ;fdb 10,(ObjID_collision*256),165+tilesizex*00,161-tilesizey*2
        ;fdb 10,(ObjID_collision*256),165+tilesizex*00,161-tilesizey*1        
        ;fdb 10,(ObjID_collision*256),165+tilesizex*01,161-tilesizey*1

; First pata-pata wave
wave_patapata_01       equ 252
wave_patapata_01_space equ 4
        fdb   wave_patapata_01-140+wave_patapata_01_space*0,(ObjID_patapata*256)+00,wave_patapata_01+enemies_patapata+wave_patapata_01_space*0,50+offset_y
        fdb   wave_patapata_01-140+wave_patapata_01_space*1,(ObjID_patapata*256)+01,wave_patapata_01+enemies_patapata+wave_patapata_01_space*1,50+offset_y
        fdb   wave_patapata_01-140+wave_patapata_01_space*2,(ObjID_patapata*256)+00,wave_patapata_01+enemies_patapata+wave_patapata_01_space*2,50+offset_y
        fdb   wave_patapata_01-140+wave_patapata_01_space*3,(ObjID_patapata*256)+31,wave_patapata_01+enemies_patapata+wave_patapata_01_space*3,50+offset_y


; Second pata-pata wave
wave_patapata_02       equ 278
wave_patapata_02_space equ 4
        fdb   wave_patapata_02-140+wave_patapata_02_space*0,(ObjID_patapata*256)+31,wave_patapata_02+enemies_patapata+wave_patapata_02_space*0,100+offset_y
        fdb   wave_patapata_02-140+wave_patapata_02_space*1,(ObjID_patapata*256)+30,wave_patapata_02+enemies_patapata+wave_patapata_02_space*1,100+offset_y
        fdb   wave_patapata_02-140+wave_patapata_02_space*2,(ObjID_patapata*256)+31,wave_patapata_02+enemies_patapata+wave_patapata_02_space*2,100+offset_y
        fdb   wave_patapata_02-140+wave_patapata_02_space*3,(ObjID_patapata*256)+30,wave_patapata_02+enemies_patapata+wave_patapata_02_space*3,100+offset_y   

; solo bink
        fdb   304-140,(ObjID_bink*256)+55,332+enemies_bink,140+offset_y

        ;fdb 10,(ObjID_collision*256),165+tilesizex*07,161-tilesizey*1

; First bug wave
wave_bug_01       equ 308
wave_bug_01_space equ 2
        fdb   wave_bug_01-140+wave_bug_01_space*0,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*0,50+offset_y
        fdb   wave_bug_01-140+wave_bug_01_space*1,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*1,50+offset_y
        fdb   wave_bug_01-140+wave_bug_01_space*2,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*2,50+offset_y
        fdb   wave_bug_01-140+wave_bug_01_space*3,(ObjID_bug*256)+31,wave_bug_01+enemies_bug+wave_bug_01_space*3,50+offset_y
        fdb   wave_bug_01-140+wave_bug_01_space*4,(ObjID_bug*256)+1,wave_bug_01+enemies_bug+wave_bug_01_space*4,50+offset_y


; Second bug wave
wave_bug_02       equ 372
wave_bug_02_space equ 2
        fdb   wave_bug_02-140+wave_bug_02_space*0,(ObjID_bug*256)+0,wave_bug_02+enemies_bug+wave_bug_02_space*0,60+offset_y
        fdb   wave_bug_02-140+wave_bug_02_space*1,(ObjID_bug*256)+0,wave_bug_02+enemies_bug+wave_bug_02_space*1,60+offset_y
        fdb   wave_bug_02-140+wave_bug_02_space*2,(ObjID_bug*256)+0,wave_bug_02+enemies_bug+wave_bug_02_space*2,60+offset_y
        fdb   wave_bug_02-140+wave_bug_02_space*3,(ObjID_bug*256)+30,wave_bug_02+enemies_bug+wave_bug_02_space*3,60+offset_y
        fdb   wave_bug_02-140+wave_bug_02_space*4,(ObjID_bug*256)+0,wave_bug_02+enemies_bug+wave_bug_02_space*4,60+offset_y


; Third pata-pata wave
wave_patapata_03       equ 380
wave_patapata_03_space equ 4
        fdb   wave_patapata_03-140+wave_patapata_03_space*1,(ObjID_patapata*256)+26,wave_patapata_03+enemies_patapata+wave_patapata_03_space*1,100+offset_y
        fdb   wave_patapata_03-140+wave_patapata_03_space*2,(ObjID_patapata*256)+27,wave_patapata_03+enemies_patapata+wave_patapata_03_space*2,100+offset_y
        fdb   wave_patapata_03-140+wave_patapata_03_space*3,(ObjID_patapata*256)+26,wave_patapata_03+enemies_patapata+wave_patapata_03_space*4,110+offset_y


        ;fdb 10,(ObjID_collision*256),165+tilesizex*09,161-tilesizey*1
        ;fdb 10,(ObjID_collision*256),165+tilesizex*09,161-tilesizey*2

; Fourth pata-pata wave
wave_patapata_04       equ 392
wave_patapata_04_space equ 4
        fdb   wave_patapata_04-140+wave_patapata_04_space*1,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*1,50+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*2,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*2,40+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*3,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*3,35+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*4,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*4,95+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*5,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*5,45+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*6,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*6,55+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*8,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*8,100+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*9,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*9,40+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*10,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*10,40+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*11,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*11,95+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*12,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*12,45+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*14,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*14,40+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*15,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*15,55+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*16,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*16,35+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*18,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*18,50+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*20,(ObjID_patapata*256)+26,wave_patapata_04+enemies_patapata+wave_patapata_04_space*20,100+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*21,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*21,95+offset_y
        fdb   wave_patapata_04-140+wave_patapata_04_space*24,(ObjID_patapata*256)+27,wave_patapata_04+enemies_patapata+wave_patapata_04_space*24,80+offset_y

; Solo bink #2
        fdb   504-140,(ObjID_bink*256)+55,504+enemies_bink,140+offset_y

; Fifth pata-pata wave
wave_patapata_05       equ 507
wave_patapata_05_space equ 4
        fdb   wave_patapata_05-140+wave_patapata_05_space*1,(ObjID_patapata*256)+27,wave_patapata_05+enemies_patapata+wave_patapata_05_space*1,50+offset_y
        fdb   wave_patapata_05-140+wave_patapata_05_space*2,(ObjID_patapata*256)+26,wave_patapata_05+enemies_patapata+wave_patapata_05_space*2,90+offset_y

; Solo bink #3
        fdb   532-140,(ObjID_bink*256)+55,532+enemies_bink,140+offset_y


; Sixth pata-pata wave
wave_patapata_06       equ 534
wave_patapata_06_space equ 4
        fdb   wave_patapata_06-140+wave_patapata_06_space*1,(ObjID_patapata*256)+27,wave_patapata_06+enemies_patapata+wave_patapata_06_space*1,50+offset_y
        fdb   wave_patapata_06-140+wave_patapata_06_space*3,(ObjID_patapata*256)+26,wave_patapata_06+enemies_patapata+wave_patapata_06_space*3,70+offset_y

; Scant #1
        fdb   560-140,(ObjID_scant*256)+00,560+enemies_scant,80+offset_y

; Solo bink #4
        fdb   562-140,(ObjID_bink*256)+55,562+enemies_bink,140+offset_y

; P-Staff #1
        fdb   588-140,(ObjID_pstaff*256)+00,588+enemies_pstaff,141+offset_y

; Solo bink #5
        fdb   592-140,(ObjID_bink*256)+55,592+enemies_bink,140+offset_y

; Third bug wave
wave_bug_03       equ 650
wave_bug_03_space equ 2
        ;fdb   wave_bug_03-140+wave_bug_03_space*0,(ObjID_bug*256)+30,wave_bug_03+enemies_bug+wave_bug_03_space*0,30+offset_y
        ;fdb   wave_bug_03-140+wave_bug_03_space*1,(ObjID_bug*256)+0,wave_bug_03+enemies_bug+wave_bug_03_space*1,30+offset_y
        ;fdb   wave_bug_03-140+wave_bug_03_space*2,(ObjID_bug*256)+0,wave_bug_03+enemies_bug+wave_bug_03_space*2,30+offset_y
        ;fdb   wave_bug_03-140+wave_bug_03_space*3,(ObjID_bug*256)+30,wave_bug_03+enemies_bug+wave_bug_03_space*3,30+offset_y
        ;fdb   wave_bug_03-140+wave_bug_03_space*4,(ObjID_bug*256)+0,wave_bug_03+enemies_bug+wave_bug_03_space*4,30+offset_y

; Bink falling
        ;fdb   664-140,(ObjID_bink*256)+183,644+enemies_bink,0+offset_y


; Cancer wave
wave_cancer_01  equ 539
        ;fdb  wave_cancer_01-140,(ObjID_cancer*256)+0,wave_cancer_01+14,40+offset_y
        ;fdb  wave_cancer_01-140,(ObjID_cancer*256)+1,wave_cancer_01+14,120+offset_y
        ;fdb  wave_cancer_01-140+7,(ObjID_cancer*256)+0,wave_cancer_01+14+7,50+offset_y
        ;fdb  wave_cancer_01-140+7,(ObjID_cancer*256)+1,wave_cancer_01+14+7,110+offset_y
        ;fdb  wave_cancer_01-140+14,(ObjID_cancer*256)+1,wave_cancer_01+14+14,100+offset_y
        ;fdb  wave_cancer_01-140+14,(ObjID_cancer*256)+0,wave_cancer_01+14+14,60+offset_y
        ;fdb  wave_cancer_01-140+21,(ObjID_cancer*256)+0,wave_cancer_01+14+21,90+offset_y
        ;fdb  wave_cancer_01-140+21,(ObjID_cancer*256)+1,wave_cancer_01+14+21,70+offset_y
        ;fdb  wave_cancer_01-140+28,(ObjID_cancer*256)+0,wave_cancer_01+14+28,80+offset_y
        ;fdb  wave_cancer_01-140+28,(ObjID_cancer*256)+1,wave_cancer_01+14+28,60+offset_y
        ;fdb  wave_cancer_01-140+35,(ObjID_cancer*256)+0,wave_cancer_01+14+35,120+offset_y
        ;fdb  wave_cancer_01-140+40,(ObjID_cancer*256)+1,wave_cancer_01+14+40,100+offset_y
        ;fdb  wave_cancer_01-140+40,(ObjID_cancer*256)+0,wave_cancer_01+14+40,80+offset_y
        ;fdb  wave_cancer_01-140+42,(ObjID_cancer*256)+1,wave_cancer_01+14+42,70+offset_y
        ;fdb  wave_cancer_01-140+45,(ObjID_cancer*256)+1,wave_cancer_01+14+45,60+offset_y
        ;fdb  wave_cancer_01-140+45,(ObjID_cancer*256)+0,wave_cancer_01+14+45,110+offset_y
        ;fdb  wave_cancer_01-140+47,(ObjID_cancer*256)+1,wave_cancer_01+14+47,30+offset_y


; Solo bink #5
        fdb  628-140,(ObjID_bink*256)+55,628+enemies_bink,140+offset_y

wave_blasters_01      equ 693
        fdb wave_blasters_01-140,(ObjID_blaster*256)+230,wave_blasters_01+20,30+offset_y
        fdb wave_blasters_01-140,(ObjID_blaster*256)+241,wave_blasters_01+20,148+offset_y

        fdb wave_blasters_01-140+12,(ObjID_blaster*256)+250,wave_blasters_01+20+12,30+offset_y
        fdb wave_blasters_01-140+12,(ObjID_blaster*256)+221,wave_blasters_01+20+12,148+offset_y

        fdb 715-140,(ObjID_fadetotunnel*256),715,100+offset_y
        
        fdb wave_blasters_01-140+24,(ObjID_blaster*256)+230,wave_blasters_01+20+24,42+offset_y
        fdb wave_blasters_01-140+24,(ObjID_blaster*256)+223,wave_blasters_01+20+24,136+offset_y
        fdb wave_blasters_01-140+36,(ObjID_blaster*256)+240,wave_blasters_01+20+36,42+offset_y
        fdb wave_blasters_01-140+36,(ObjID_blaster*256)+231,wave_blasters_01+20+36,136+offset_y



        fdb wave_blasters_01-140+120,(ObjID_blaster*256)+220,wave_blasters_01+20+120,18+offset_y
        fdb wave_blasters_01-140+132,(ObjID_blaster*256)+250,wave_blasters_01+20+132,18+offset_y

; Shell wave
wave_shell        equ 828
wave_shell_width  equ 8
        fdb   wave_shell-140,(ObjID_shell*256)+00,882,139+offset_y





; P-Staff #2
        fdb   928-140,(ObjID_pstaff*256)+00,928+enemies_pstaff*4,141+offset_y






wave_blasters_02      equ 957

        fdb wave_blasters_02-140,(ObjID_blaster*256)+230,wave_blasters_02+20,30+offset_y

; Seventh pata-pata wave
wave_patapata_07       equ 987
wave_patapata_07_space equ 4

        fdb wave_blasters_02-140+12,(ObjID_blaster*256)+240,wave_blasters_02+20+12,30+offset_y
        ;fdb wave_patapata_07-140+wave_patapata_06_space*0,(ObjID_patapata*256)+27,wave_patapata_07+enemies_patapata+wave_patapata_07_space*0,90+offset_y
        ;fdb wave_patapata_07-140+wave_patapata_06_space*2,(ObjID_patapata*256)+26,wave_patapata_07+enemies_patapata+wave_patapata_07_space*2,80+offset_y
        fdb wave_blasters_02-140+24,(ObjID_blaster*256)+250,wave_blasters_02+20+24,18+offset_y
        ;fdb wave_patapata_07-140+wave_patapata_06_space*5,(ObjID_patapata*256)+27,wave_patapata_07+enemies_patapata+wave_patapata_07_space*5,85+offset_y
        fdb wave_blasters_02-140+36,(ObjID_blaster*256)+230,wave_blasters_02+20+36,18+offset_y
        ;fdb wave_patapata_07-140+wave_patapata_06_space*7,(ObjID_patapata*256)+26,wave_patapata_07+enemies_patapata+wave_patapata_07_space*7,60+offset_y        
        fdb wave_blasters_02-140+48,(ObjID_blaster*256)+240,wave_blasters_02+20+48,18+offset_y
 ; P-Staff #3
        ;fdb 1176-140,(ObjID_pstaff*256)+00,1176+enemies_pstaff*4,141+offset_y
        fdb wave_blasters_02-140+60,(ObjID_blaster*256)+230,wave_blasters_02+20+60,18+offset_y

        ;fdb wave_patapata_07-140+wave_patapata_06_space*15,(ObjID_patapata*256)+26,wave_patapata_07+enemies_patapata+wave_patapata_07_space*15,70+offset_y

        fdb wave_blasters_02-140+72,(ObjID_blaster*256)+230,wave_blasters_02+20+72,18+offset_y
        fdb wave_blasters_02-140+84,(ObjID_blaster*256)+220,wave_blasters_02+20+84,18+offset_y



wave_blasters_03      equ 1077

        fdb wave_blasters_03-140,(ObjID_blaster*256)+230,wave_blasters_03+20,42+offset_y
        fdb wave_blasters_03-140,(ObjID_blaster*256)+221,wave_blasters_03+20,136+offset_y
        fdb wave_blasters_03-140+12,(ObjID_blaster*256)+240,wave_blasters_03+20+12,42+offset_y
        fdb wave_blasters_03-140+12,(ObjID_blaster*256)+251,wave_blasters_03+20+12,136+offset_y

        fdb 1404-140,(ObjID_fadetotunnel*256)+1,1404,100+offset_y

        fdb   -1 ; end marker


