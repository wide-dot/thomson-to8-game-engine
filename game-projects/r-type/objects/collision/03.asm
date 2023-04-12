lvlMapWidth equ 48 ; stage 03 width

        INCLUDE "./engine/objects/collision/terrainCollision.asm"

terrainCollision.maps
        fdb   collisionMapBackground
        fdb   collisionMapForeground

collisionMapBackground
        INCLUDEBIN "./objects/collision/map/level3_bc.bin"

collisionMapForeground
        INCLUDEBIN "./objects/collision/map/level3_fc.bin"