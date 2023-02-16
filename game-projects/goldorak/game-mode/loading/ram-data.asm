
; ext_variables_size is for dynamic objects
ext_variables_size                equ 20 ;
nb_dynamic_objects                equ 10 ; dynamic allocation
nb_graphical_objects              equ 10 ; only count objects that will be rendered on screen (max 64 total)

Dynamic_Object_RAM 
        fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End



;SlideShowData 
;        FDB #Img_Vignette_01, $0060
;        FDB #Img_Bulle_01, $0060
;        FDB #Img_Vignette_02, $0060
;        FDB #Img_Bulle_02, $0060
;        FDB $0000

