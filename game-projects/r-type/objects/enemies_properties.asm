; ***********************************************************************************************
;
; Defines the properties for each enemies. A properties is declined into 4 equates :
; 
; - spritename_score     : Number of points (multiples of 100) to increment the score with
; - spritename_hitbox_x  : X radius of collision sensibility
; - spritename_hitbox_y  : Y radius of collision sensibility
; - spritename_hitdamage : Damage sensibility
;                          -128 to -1 : invincible hitbox, potential is never changed
;                          0          : disabled hitbox
;                          1 to 126   : hitbox with remaining potential, when collide potential decrease (min 0)
;                          127        : weak hitbox, when collide hitbox is directly disabled and do no harm to other hitbox
; ***********************************************************************************************

patapata_score		equ 2
patapata_hitbox_x	equ 4
patapata_hitbox_y	equ 8
patapata_hitdamage	equ 1

bug_score		equ 2
bug_hitbox_x	        equ 4
bug_hitbox_y	        equ 8
bug_hitdamage	        equ 1

blaster_score           equ 1
blaster_hitbox_x	equ 4
blaster_hitbox_y	equ 7
blaster_hitdamage	equ 1

bink_score		equ 2
bink_hitbox_x		equ 6
bink_hitbox_y		equ 13
bink_hitdamage		equ 1

cancer_score		equ 3
cancer_hitbox_x		equ 6
cancer_hitbox_y		equ 13
cancer_hitdamage	equ 1

tabrok_score		equ 20
tabrok_hitbox_x		equ 8
tabrok_hitbox_y		equ 16
tabrok_hitdamage	equ $1e

dobkeratops_monster_score     equ 1
dobkeratops_monster_hitbox_x  equ 4
dobkeratops_monster_hitbox_y  equ 8
dobkeratops_monster_hitdamage equ 30 ; ARCADE OK

dobkeratops_tail_hitbox_x  equ 2
dobkeratops_tail_hitbox_y  equ 4
dobkeratops_tail_hitdamage equ -128

dobkeratops_saw_score     equ 1
dobkeratops_saw_hitbox_x  equ 3
dobkeratops_saw_hitbox_y  equ 6
dobkeratops_saw_hitdamage equ -128

dobkeratops_eye_score     equ 5
dobkeratops_eye_hitbox_x  equ 3
dobkeratops_eye_hitbox_y  equ 6
dobkeratops_eye_hitdamage equ 1
