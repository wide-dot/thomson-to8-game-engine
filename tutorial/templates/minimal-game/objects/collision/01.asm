lvlMapWidth equ 66 ; stage 01 width

        INCLUDE "./engine/objects/collision/terrainCollision.asm"

terrainCollision.maps
        fdb   collisionMapBackground
        fdb   collisionMapForeground

collisionMapBackground
        INCLUDEBIN "./objects/collision/map/level1_bc.bin"

collisionMapForeground
        INCLUDEBIN "./objects/collision/map/level1_fc.bin"