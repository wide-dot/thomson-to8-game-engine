lvlMapWidth equ 48 ; stage 07 width

        INCLUDE "./engine/objects/collision/terrainCollision.asm"

terrainCollision.maps
        fdb   collisionMapBackground
        fdb   collisionMapForeground

collisionMapBackground
collisionMapForeground
        INCLUDEBIN "./objects/collision/map/level7_fc.bin"