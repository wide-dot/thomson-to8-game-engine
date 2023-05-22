; ***********************************************************************************************
;
; Defines the properties for each enemies. A properties is declined into 4 equates :
; 
; - spritename_score     : Number of points (multiples of 100) to increment the score with
; - spritename_hitbox_x  : X radius of collision sensibility
; - spritename_hitbox_y  : Y radius of collision sensibility
; - spritename_hitdamage : Damage sensibility (e.g. 255 = no damage, 1= simple player 1 fire ...) 

; ***********************************************************************************************
; Patapata

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
