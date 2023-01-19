; First pata-pata wave

        fdb   210-140                  ; x_pos to instanciate object
        fcb   ObjID_patapata           ; object id
        fcb   01                       ; object subtype
        fdb   220,40                   ; x_pos, y_pos

        fdb   213-140
        fcb   ObjID_patapata
        fcb   01
        fdb   223,40

        fdb   216-140
        fcb   ObjID_patapata
        fcb   01
        fdb   226,40

        fdb   219-140
        fcb   ObjID_patapata
        fcb   01
        fdb   229,40

        fdb   222-140
        fcb   ObjID_patapata
        fcb   01
        fdb   232,40


; solo bink


        fdb   223-140
        fcb   ObjID_bink
        fcb   00
        fdb   233,140


; Second pata-pata wave

        fdb   222-140                
        fcb   ObjID_patapata         
        fcb   01                      
        fdb   232,114                  

        fdb   225-140
        fcb   ObjID_patapata
        fcb   02
        fdb   235,114

        fdb   228-140
        fcb   ObjID_patapata
        fcb   01
        fdb   238,114

        fdb   231-140
        fcb   ObjID_patapata
        fcb   02
        fdb   241,114

        fdb   234-140
        fcb   ObjID_patapata
        fcb   01
        fdb   244,114


; First bug wave

        fdb   232-140                
        fcb   ObjID_bug        
        fcb   00                      
        fdb   242,60      

        fdb   235-140                
        fcb   ObjID_bug        
        fcb   00                      
        fdb   245,60   

        fdb   238-140                
        fcb   ObjID_bug        
        fcb   00                      
        fdb   248,60

        fdb   241-140                
        fcb   ObjID_bug        
        fcb   00                      
        fdb   251,60

        fdb   244-140                
        fcb   ObjID_bug        
        fcb   00                      
        fdb   254,60

        fdb   247-140                
        fcb   ObjID_bug        
        fcb   00                      
        fdb   257,60                                

        fdb   -1 ; end marker