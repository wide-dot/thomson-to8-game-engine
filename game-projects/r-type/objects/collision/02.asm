lvlMapWidth equ 48 ; stage 02 width

        INCLUDE "./engine/objects/collision/terrainCollision.asm"

terrainCollision.maps
        fdb   collisionMapBackground
        fdb   collisionMapForeground

collisionMapBackground
collisionMapForeground
        INCLUDEBIN "./objects/collision/map/level2_fc.bin"