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

patapata_score		equ 1
patapata_hitbox_x	equ 4
patapata_hitbox_y	equ 8
patapata_hitdamage	equ 1
