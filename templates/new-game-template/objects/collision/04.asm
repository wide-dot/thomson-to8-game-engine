lvlMapWidth equ 48 ; stage 04 width

        INCLUDE "./engine/objects/collision/terrainCollision.asm"

terrainCollision.maps
        fdb   collisionMapBackground
        fdb   collisionMapForeground

collisionMapBackground
collisionMapForeground
        INCLUDEBIN "./objects/collision/map/level4_fc.bin"