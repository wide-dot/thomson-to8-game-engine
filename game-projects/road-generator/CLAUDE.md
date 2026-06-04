# road-generator — Port Lotus Esprit Turbo Challenge sur Thomson TO8

Port fidèle du jeu Atari ST (1990, Gremlin Graphics) vers TO8 6809. La règle d'or : **on porte le code original 68000, on n'approxime pas**. Sauf adaptation explicite (résolution X /2 pour BM16 160px, conventions registres 6809).

## Référence primaire : code 68000 désassemblé

`lotus-ste/gamefiles/source/CARS.REL.asm.txt` (25198 lignes, disasm Ghidra). Base : file offset = `ram_addr - 0x70400`. Donc `FUN_00075e30` se trouve à l'offset `0x5A30` dans ce fichier.

## Architecture du port

Convention TO8 :

- `U` = équivalent A4 ST = pointer sur `LotusCarState` (player1 ou AI car courant)
- `player1 equ dp` = OST du joueur en DP `$9F00` (adressage direct fast)
- `PlayerOne_State` = struct `LotusCarState` en RAM résidente
- `AI_States` = table contiguë de 18 × `LotusCarState`
- Coord horizontales : ST/2 (160 px BM16)
- Coord verticales : identiques (200 lignes)
- Forward speed / RPM / gear / temps : identiques (pas pixel-horizontal)

## État du port (au 2026-05-27)

### Pipeline tick physique
- ✅ Input buffer IRQ + drain (`game-mode/road/input/lotus.input.buffer.asm`)
- ✅ Jump table chargement circuit générique
- ✅ `segment_idx` cached dans `LotusCarState` (= optimisation 6809 sans hardware divu — voir « Gotchas » plus bas)
- ⏳ `Lotus_PhysicsTick` STUB (track_pos += speed sur UP, maintient `segment_idx` sur carry overflow). Port complet de `FUN_75e30` = TODO task #87.

### Pipeline rendu route (objectif v1 : afficher la piste qui défile)
Doc détaillée : `lotus-ste/doc/extraction/40_road_v1_pipeline_status.md`

- ✅ **#A** Tables perspective (FILE59 → `engine/projection/PerspectiveTables.asm`) via `tools/extract_perspective_tables.py`
- ❌ **#B** Look-ahead courbure : **PAS nécessaire pour v1** (découverte clé documentée dans doc 40)
- ⏳ **#C** Projection sparse — port de `FUN_78a98` (offset 8698 CARS.REL.asm.txt)
- ⏳ **#D** Interpolateur linéaire — port de `FUN_78f3a` (offset 8B3A)
- ⏳ **#E** DRAW_FRAME_ROAD version TO8 — remplace SMC blitter 68000 par blit des sprites preshiftés `tools/road_sprites_source/`

## Documentation key

Docs reverse engineering Lotus (`lotus-ste/doc/extraction/`) :
- `11_circuit_format_CONFIRMED.md` — format segments 12 oct source / 16 oct runtime
- `14_rendering_pipeline.md` — pipeline rendu en 5 phases
- `21_TICK_PHYSIQUE_JOUEUR.md` — pseudo-C de FUN_75e30
- `33_interpolateur_FUN_78f3a.md` — algo interpolateur
- `40_road_v1_pipeline_status.md` — **status précis du port + découvertes #B**

## Build (sandbox Linux aarch64)

```bash
cd game-projects/road-generator
rm -rf generated-code dist
java -Xverify:none -jar ../../java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar config-linux-aarch64.properties 2>&1 | grep -iE 'error|undefined|réussi'
```

Sortie attendue : `Build réussi pour FD et T2`. Outputs dans `dist/road-generator.fd`.

## Gotchas connus

### lwasm 4.24 — la directive `struct` casse le scope des @-labels

Tout fichier qui inclut `LotusCarState.struct.asm` puis utilise des `@xxx` les voit comme `Undefined symbol`. **Workaround** : préfixer les labels (`LPT_xxx` pour Lotus_PhysicsTick, `CS_xxx` pour Circuit_step, `P1M_xxx` pour PlayerOne_Main).

### Base address CARS.REL = $70400

**PAS $70000.** Erreur facile à faire — toujours utiliser 0x70400 dans les tools d'extraction.

### Pas de `Circuit_step` séparé — `segment_idx` cached dans `LotusCarState`

Lotus 68000 recalcule `(track_pos >> 16) % NB_SEGMENTS` à chaque consommation via `divu.w` hardware (~80 cycles). 10 occurrences réparties dans physique, projection et rendu sprites. Sur 19 voitures (joueur + 18 AI), ça coûte ~15000 cycles ST = négligeable.

Sur 6809 sans hardware divu, le même pattern naïf (boucle de soustraction) coûterait ~57000 cycles = 285% du budget frame 50 Hz. **Architecture du port** : un champ `segment_idx` (rmb 2) dans `LotusCarState`, incrémenté par `Lotus_PhysicsTick` quand le carry du low-word de `track_pos` propage (= 1 segment franchi). Coût amorti O(1). Les consommateurs (projection, AI steering, collision) lisent `segment_idx,u` directement, et calculent le pointeur segment via `Circuit_base + segment_idx × 16` à la demande.

### Le format runtime des segments diffère du source

- Source : 12 oct (`+0..0xB`)
- Runtime à `$31140` : 16 oct = 12 source + 4 octets padding `+0xC..0xF`. Padding rempli par `FUN_74dac` au load (et lu par AI/sprites, **pas par la route**).
- Les 8 derniers segments sont une copie des 8 premiers (wraparound look-ahead).

### Format segment (12 oct source) — vérifié

```
+0  delta_curve (int8)   +1  delta_pitch (int8)
+2  sprite_id_0  +3  lat_pos_0 (signed) — mot 1
+4  sprite_id_1  +5  lat_pos_1                   — mot 2
+6  sprite_id_2  +7  lat_pos_2                   — mot 3
+8  sprite_id_3  +9  lat_pos_3                   — mot 4
+A..B  flags  (bit 0 = PIT lane / route stands, bit 1 = START line)
```

4 sprites par segment (confirmé par FUN_40B4 : 4 appels FUN_4190 = add_file). Chaque mot = (sprite_id ∈ $80..$AB, lateral_pos signed). lat < 0 = gauche, > 0 = droite.

## Prochaine étape

Continuer le pipeline route : **task #95 (#C — port FUN_78a98 projection sparse)**. Lire d'abord la doc 40 pour le contexte précis, puis CARS.REL.asm.txt offset 8698 pour le code 68000 source.
