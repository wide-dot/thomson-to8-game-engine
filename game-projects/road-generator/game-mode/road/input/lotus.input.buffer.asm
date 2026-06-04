********************************************************************************
* OBSOLETE — fichier remplacé par lecture directe de Dpad_Held.
*
* Le buffer producer/consumer (IRQ → PlayerOne_Main drain) avait un comportement
* edge-trigger involontaire en cas de buffer overflow (write_ptr catchup read_ptr
* → drain interprétait comme empty). De plus, c'était over-engineered pour notre
* besoin.
*
* Remplacement : PlayerOne_Main lit Dpad_Held (= mis à jour par ReadJoypads à
* chaque main loop), stocke dans LotusCarState.input_held, appelle Lotus_PhysicsTick
* `gfxlock.frameDrop.count` fois pour rattrapage frame drop.
*
* Ce fichier peut être supprimé (= ne plus INCLUDE-d depuis main.asm).
********************************************************************************
