lvlMapWidth equ 66 ; stage 01 width

        INCLUDE "./objects/collision/obj.asm"

terrainCollision.maps
        fdb   collisionMapBackground
        fdb   collisionMapForeground

collisionMapBackground
        INCLUDE "./objects/collision/map/level1_bc.bin"

collisionMapForeground
        INCLUDE "./objects/collision/map/level1_fc.bin"