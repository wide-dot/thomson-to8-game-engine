# Thomson TO8 Engine Subsystems

Auto-generated catalog of all engine subsystems.
Last updated: $(date)

## boot (engine/boot/)
**Purpose:** Game initialization, bootloader, memory setup for Thomson TO8.


**Used in:** goldorak, r-type

**Core Files:**
- engine/boot/boot-t2.asm
- engine/boot/boot-t2-flash.asm
- engine/boot/boot-fd.asm

## collision (engine/collision/)
**Purpose:** Rectangle-based collision detection and hitbox management for game objects.


**Used in:** r-type

**Core Files:**
- engine/collision/macros.asm
- engine/collision/collision.asm

## compression (engine/compression/)
**Purpose:** Data compression for sprites, tiles, and other large resources.


**Used in:** 

**Core Files:**
- engine/compression/exomizer/exomizer.asm
- engine/compression/zx0/zx0_6809_standard.asm
- engine/compression/zx0/zx0_6809_mega_back.asm
- engine/compression/zx0/zx0_6809_mega.asm
- engine/compression/zx0/zx0_6809_turbo.asm

## graphics (engine/graphics/)
**Purpose:** Sprite and tile rendering to Thomson TO8 video memory. Handles blitting and display.


**Used in:** 

**Core Files:**
- engine/graphics/vbl/WaitVBL.asm
- engine/graphics/camera/CheckCameraMove.asm
- engine/graphics/camera/AutoScroll.asm
- engine/graphics/animation/moveByScript.asm
- engine/graphics/animation/AnimateMove.asm
- engine/graphics/animation/AnimateSprite.asm
- engine/graphics/animation/AnimateSpriteAdvSync.asm
- engine/graphics/animation/AnimateSpriteAdv.asm
- engine/graphics/animation/AnimateSpriteSync.asm
- engine/graphics/animation/AnimateSpriteAdvLoad.asm
- engine/graphics/animation/AnimateSpriteLoad.asm
- engine/graphics/draw/DrawFullscreenInterlacedImage.asm
- engine/graphics/draw/DrawHLine.asm
- engine/graphics/draw/DrawFullscreenImage.asm
- engine/graphics/line/hline.asm
- engine/graphics/image/GetImgIdA.asm
- engine/graphics/buffer/gfxlock.asm
- engine/graphics/buffer/gfxlock.macro.asm
- engine/graphics/tilemap/TilemapBuffer.asm
- engine/graphics/tilemap/vscroll/tiles.const.asm
- engine/graphics/tilemap/vscroll/vscroll.macro.asm
- engine/graphics/tilemap/vscroll/vscroll.asm
- engine/graphics/tilemap/vscroll/tiles.asm
- engine/graphics/tilemap/vscroll/buffer.asm
- engine/graphics/tilemap/Tilemap.asm
- engine/graphics/tilemap/Spritemap.asm
- engine/graphics/tilemap/TileAnimScript.asm
- engine/graphics/tilemap/Tilemaps.asm
- engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-even.asm
- engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-odd.asm
- engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered.asm
- engine/graphics/tilemap/horizontal-scroll/scroll-map-buffered-16x16.asm
- engine/graphics/tilemap/Tilemap16bits.asm
- engine/graphics/clear/ClearInterlacedDataMemory.asm
- engine/graphics/clear/ClearVerticalBandLR.asm
- engine/graphics/sprite/sprite-background-erase-pack.asm
- engine/graphics/sprite/background-erase-mode/BgBufferAlloc.asm
- engine/graphics/sprite/background-erase-mode/CheckSpritesRefresh.asm
- engine/graphics/sprite/background-erase-mode/DeleteObject.asm
- engine/graphics/sprite/background-erase-mode/EraseSprites.asm
- engine/graphics/sprite/background-erase-mode/DrawSprites.asm
- engine/graphics/sprite/background-erase-mode/DrawSpritesExtEnc.asm
- engine/graphics/sprite/background-erase-mode/DisplaySprite.asm
- engine/graphics/sprite/background-erase-mode/UnsetDisplayPriority.asm
- engine/graphics/sprite/overlay-mode/BuildSprites.asm
- engine/graphics/sprite/overlay-mode/DeleteObject.asm
- engine/graphics/sprite/overlay-mode/DisplaySprite.asm
- engine/graphics/sprite/sprite-background-erase-ext-pack.asm
- engine/graphics/sprite/sprite-overlay-pack.asm
- engine/graphics/codec/bm4.drawChunbks.asm
- engine/graphics/codec/zx0_mega.asm
- engine/graphics/codec/DecRLE00.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_90_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_01_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_82_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_09_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_57_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_28_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_38_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_15_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_45_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_07_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_31_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_27_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_93_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_48_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_59_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_69_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_54_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_87_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_92_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_67_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_62_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/font.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_06_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_55_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/font_upper.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_89_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_74_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_19_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_02_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_41_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_63_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_17_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_26_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_61_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_52_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_34_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_78_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_22_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_05_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_14_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_30_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_66_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_86_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_11_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_68_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_77_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_12_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_81_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_21_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_43_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_71_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_39_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_32_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_91_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_94_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_88_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_37_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_85_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_25_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_33_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_73_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_49_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_75_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_35_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_16_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_42_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_23_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_20_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_40_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_95_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_56_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_51_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_72_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_47_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_36_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_70_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_00_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_60_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_65_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_44_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_84_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_76_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_53_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_24_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_08_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_83_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_13_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_04_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_46_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_03_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_58_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_10_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_50_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_79_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_18_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_29_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_80_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_selected/asm/fnt_4x6_shd_sel_64_DN0.asm
- engine/graphics/font/DrawText/DrawOneChar.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_65_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_84_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_40_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_27_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_05_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_70_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_02_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_06_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_47_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_64_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_04_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_81_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_71_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_15_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_33_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_14_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_19_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_57_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_79_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_49_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_66_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_83_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_77_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/font.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_48_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_56_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_89_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_78_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_69_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_50_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_16_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_07_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/font_upper.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_32_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_01_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_67_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_03_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_43_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_87_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_88_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_82_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_53_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_44_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_17_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_22_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_21_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_41_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_29_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_90_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_63_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_42_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_08_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_92_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_54_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_76_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_51_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_25_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_68_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_58_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_36_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_62_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_37_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_35_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_38_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_73_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_80_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_10_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_86_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_39_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_60_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_09_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_52_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_23_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_59_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_46_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_26_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_91_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_24_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_30_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_94_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_28_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_12_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_61_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_34_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_85_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_93_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_00_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_45_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_20_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_95_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_31_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_13_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_75_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_18_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_72_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_11_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_74_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded_disabled/asm/fnt_4x6_shd_dis_55_DN0.asm
- engine/graphics/font/DrawText/DrawText.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_75_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_86_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_30_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_51_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_80_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_26_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_83_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_76_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_00_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_72_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_33_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_43_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_16_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_20_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_15_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_92_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_27_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_45_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_52_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_11_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_57_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_31_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/font.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_18_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_58_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_04_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_06_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_12_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_71_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_82_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/font_upper.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_74_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_37_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_17_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_68_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_38_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_46_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_35_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_84_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_90_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_32_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_91_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_59_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_55_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_23_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_13_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_34_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_70_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_61_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_22_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_40_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_14_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_21_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_49_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_54_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_73_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_89_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_19_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_05_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_56_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_87_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_66_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_63_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_95_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_02_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_79_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_81_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_53_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_62_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_09_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_07_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_64_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_42_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_67_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_94_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_85_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_08_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_39_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_77_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_88_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_24_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_93_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_48_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_01_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_60_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_28_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_44_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_03_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_65_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_50_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_78_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_36_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_29_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_41_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_69_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_10_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_47_DN0.asm
- engine/graphics/font/DrawText/3x5_shaded/asm/fnt_4x6_shd_25_DN0.asm
- engine/graphics/font/PrintString/PrintString.asm

## irq (engine/irq/)
**Purpose:** Interrupt request handling (timer, keyboard, joystick interrupts).


**Used in:** 

**Core Files:**
- engine/irq/Irq.asm
- engine/irq/IrqObjSmps.asm
- engine/irq/IrqSecond.asm

## joypad (engine/joypad/)
**Purpose:** Joystick and gamepad input polling and management.


**Used in:** 

**Core Files:**
- engine/joypad/joypad.md6.asm
- engine/joypad/joypad.buffer.asm
- engine/joypad/ReadJoypads2.asm
- engine/joypad/ReadJoypads.asm
- engine/joypad/InitJoypads.asm

## keyboard (engine/keyboard/)
**Purpose:** Keyboard input handling and event processing.


**Used in:** 

**Core Files:**
- engine/keyboard/ReadKeyboard.asm
- engine/keyboard/MapKeyboardToJoypads.asm

## level-management (engine/level-management/)
**Purpose:** Level loading, scrolling backgrounds, tilemap management.


**Used in:** 

**Core Files:**
- engine/level-management/LoadGameMode.asm

## main (engine/main/)
**Purpose:** Main game loop framework and core engine functions.


**Used in:** goldorak, r-type

**Core Files:**
- engine/main/main.macro.asm
- engine/main/main.asm

## math (engine/math/)
**Purpose:** Mathematical utilities: multiply, divide, trigonometry, fixed-point math.


**Used in:** 

**Core Files:**
- engine/math/Mul9x16.asm
- engine/math/RandomNumber.asm
- engine/math/CalcSine.asm
- engine/math/CalcAngle.asm
- engine/math/tmp/castelvaniaII_atan2_cosine.asm
- engine/math/tmp/atan2.asm
- engine/math/rnd.macro.asm

## megarom-t2 (engine/megarom-t2/)
**Purpose:** MegaROM cartridge and multi-bank ROM support for larger games.


**Used in:** 

**Core Files:**
- engine/megarom-t2/t2-test.asm
- engine/megarom-t2/t2-flash.asm

## object-management (engine/object-management/)
**Purpose:** Spawning, updating, and destroying game objects. Object pool management.


**Used in:** 

**Core Files:**
- engine/object-management/ObjectWave-subtype.asm
- engine/object-management/objectWave.asm
- engine/object-management/MarkObjGone.asm
- engine/object-management/ObjectDp.asm
- engine/object-management/ObjectMoveSync.asm
- engine/object-management/ObjectMove.asm
- engine/object-management/RunObjects.asm
- engine/object-management/RunPgSubRoutine.asm
- engine/object-management/objectWave.macro.asm
- engine/object-management/ObjectFallSync.asm
- engine/object-management/objectWaveDesc.asm
- engine/object-management/ObjectFall.asm
- engine/object-management/Obj_GetOrientationToPlayer.asm

## objects (engine/objects/)
**Purpose:** Object definitions and templates shared across games.


**Used in:** 

**Core Files:**
- engine/objects/collision/terrainCollision.asm
- engine/objects/collision/terrainCollision.macro.asm
- engine/objects/collision/terrainCollision.main.asm
- engine/objects/sound/objects.sound.macro.asm
- engine/objects/sound/vgc/vgc.asm
- engine/objects/sound/ymm/ymm.asm
- engine/objects/sound/ymm/ymm.const.asm
- engine/objects/sound/ymm/ymm.data.asm
- engine/objects/sound/ymm/ymm.macro.asm
- engine/objects/palette/fade/fade.asm
- engine/objects/palette/raster-fade/raster-fade.asm

## palette (engine/palette/)
**Purpose:** Color palette management and animation support.


**Used in:** sonic-2

**Core Files:**
- engine/palette/PalUpdateNow.asm
- engine/palette/PalCycling.asm
- engine/palette/PalRaster_1c.asm
- engine/palette/PalUpdateNowLean.asm
- engine/palette/color/Pal_black.asm
- engine/palette/color/Pal_white.asm

## ram (engine/ram/)
**Purpose:** RAM layout, memory allocation, and variable management.


**Used in:** 

**Core Files:**
- engine/ram/RAMLoaderManagerT2.asm
- engine/ram/DynCode.asm
- engine/ram/BankSwitch.asm
- engine/ram/exo/RAMLoaderFd.asm
- engine/ram/exo/RAMLoaderT2.asm
- engine/ram/ClearDataMemoryRAMx.asm
- engine/ram/RAMLoaderManagerFd.asm
- engine/ram/ClearCartMemory.asm
- engine/ram/CopyPageATo0.asm
- engine/ram/zx0/RAMLoaderFd.asm
- engine/ram/zx0/RAMLoaderT2.asm
- engine/ram/ClearDataMemory.asm

## sound (engine/sound/)
**Purpose:** Music playback and sound effect generation for Thomson TO8 hardware.


**Used in:** r-type

**Core Files:**
- engine/sound/PlayDPCM8kHz.asm
- engine/sound/Smps.asm
- engine/sound/soundFX.data.asm
- engine/sound/PlayDPCM16kHz.asm
- engine/sound/SmpsObj.asm
- engine/sound/SmpsMidi.asm
- engine/sound/PSGlib.asm
- engine/sound/YM2413vgm.asm
- engine/sound/soundFX.asm
- engine/sound/vgc/lib/vgcplayer_config.h.asm
- engine/sound/vgc/lib/fx.asm
- engine/sound/vgc/lib/exomiser.h.asm
- engine/sound/vgc/lib/vgcplayer_bass.asm
- engine/sound/vgc/lib/vgcplayer.asm
- engine/sound/vgc/lib/vgmplayer.asm
- engine/sound/vgc/lib/exomiser.asm
- engine/sound/vgc/lib/irq.asm
- engine/sound/vgc/lib/vgcplayer.h.asm
- engine/sound/vgc/vgm_demo.asm
- engine/sound/vgc/vgc_bass_demo.asm
- engine/sound/vgc/vgc_demo.asm
- engine/sound/vgc/testbed.asm
- engine/sound/PlayPCM.asm
- engine/sound/Smidi.asm
- engine/sound/sn76489.asm
- engine/sound/soundFX.macro.asm
- engine/sound/Smps_S1.asm
- engine/sound/ym2413.asm
- engine/sound/Svgm.asm

## system (engine/system/)
**Purpose:** System utilities, debugging, and hardware utilities.


**Used in:** 

**Core Files:**
- engine/system/to8/macros.asm
- engine/system/to8/map.const.asm

