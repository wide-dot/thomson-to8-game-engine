lvlMapWidth equ 31 ; stage 08 width

        INCLUDE "./engine/objects/collision/terrainCollision.asm"

terrainCollision.maps
        fdb   collisionMapBackground
        fdb   collisionMapForeground

collisionMapBackground
collisionMapForeground
        INCLUDEBIN "./objects/collision/map/level8_fc.bin"