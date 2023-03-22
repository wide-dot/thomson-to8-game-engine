; RAM variables - Level Select

; ext_variables_size is for dynamic objects
ext_variables_size                equ 14

* ===========================================================================
* Object Constants
* ===========================================================================
nb_dynamic_objects                equ 20
nb_graphical_objects              equ 20 * max 64 total

* ---------------------------------------------------------------------------
* Object Status Table - OST
* ---------------------------------------------------------------------------
        
Dynamic_Object_RAM            fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End

snd_tst_cur_game fcb -1 ; current playing
snd_tst_cur_song fcb -1
snd_tst_new_game fcb 0 ; when a new selection is made
snd_tst_new_song fcb 0
snd_tst_sel_game fcb 0 ; current text selection
snd_tst_sel_song fcb 0
snd_tst_sel_type fcb 0
