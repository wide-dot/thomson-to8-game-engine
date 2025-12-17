# build dist files

    java -jar ../../java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./config-macos.properties

# launch on retroarch macos

    /Volumes/SSD-suite/oxumini-suite/GAMES/RetroArch/RetroArch.app/Contents/MacOS//RetroArch -L /Volumes/SSD-suite/oxumini-suite/GAMES/RetroArch/RetroArch.app/Contents/Resources/cores/theodore_libretro.dylib /Volumes/SSD-suite/oxumini-suite/GAMES/to8_2/_TO8_engine/thomson-to8-game-engine/game-projects/2026/dist/bonneannee2026.rom