	INCLUDE "./Engine/Graphics/ConstantsAnimation.asm"
	INCLUDE "./generated-code/TitleScreen/T2/TitleScreen/TitleScreen_ImageSet.glb"
	org   $0349
	setdp $FF

* Generated Code

        fcb   1
Ani_sonic 
        fdb   Img_sonic_1
        fdb   Img_sonic_2
        fdb   Img_sonic_3
        fdb   Img_sonic_5
        fcb   _nextSubRoutine
        fcb   1
Ani_tails 
        fdb   Img_tails_1
        fdb   Img_tails_2
        fdb   Img_tails_3
        fdb   Img_tails_4
        fdb   Img_tails_5
        fcb   _nextSubRoutine
        fcb   1
Ani_largeStar 
        fdb   Img_star_1
        fdb   Img_star_2
        fdb   Img_star_3
        fdb   Img_star_2
        fdb   Img_star_1
        fcb   _nextSubRoutine
        fcb   1
Ani_smallStar 
        fdb   Img_star_2
        fdb   Img_star_1
        fcb   _resetAnim
