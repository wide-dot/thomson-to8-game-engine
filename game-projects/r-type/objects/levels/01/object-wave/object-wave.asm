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

; First bug wave
wave_bug_01       equ 230
wave_bug_01_space equ 3
        fdb   wave_bug_01-140+wave_bug_01_space*0,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*0,60
        fdb   wave_bug_01-140+wave_bug_01_space*1,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*1,60
        fdb   wave_bug_01-140+wave_bug_01_space*2,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*2,60
        fdb   wave_bug_01-140+wave_bug_01_space*3,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*3,60
        fdb   wave_bug_01-140+wave_bug_01_space*4,(ObjID_bug*256)+02,wave_bug_01+wave_bug_01_space*4,60        

; Second bug wave
wave_bug_02       equ 260
wave_bug_02_space equ 3
        fdb   wave_bug_02-140+wave_bug_02_space*0,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*0,60
        fdb   wave_bug_02-140+wave_bug_02_space*1,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*1,60
        fdb   wave_bug_02-140+wave_bug_02_space*2,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*2,60
        fdb   wave_bug_02-140+wave_bug_02_space*3,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*3,60
        fdb   wave_bug_02-140+wave_bug_02_space*4,(ObjID_bug*256)+02,wave_bug_02+wave_bug_02_space*4,60    

        fdb   -1 ; end marker