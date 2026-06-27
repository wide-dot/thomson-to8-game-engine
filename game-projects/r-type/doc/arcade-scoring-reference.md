# R-Type Arcade — Scoring mechanism & enemy point reference

> Source of truth: the arcade `maincpu.bin` Ghidra database (x86 16-bit, code segment `0x40`),
> queried via the asm-ark bridge. Every address below is verbatim from that DB.
> Purpose: reference for porting the scoring system to the Thomson TO8 version.

---

## 1. TL;DR

- Every scoreable object carries a **reward index** (0–14).
- That index selects a **4-byte packed-BCD point value** from a single flat table, `score_rewards_table` (`0x1000_86E8`): `100, 200, 300, … , 15000`.
- On death (or pickup), the object enqueues a deferred event `update_current_stage_score(reward_ptr)`, where `reward_ptr = score_rewards_table + index*4`. That function does a BCD add into the running score + per-stage score, caps at 7 digits, handles 1UP extends and the top-score.
- **Difficulty does NOT change the points.** The reward pointer each object passes is a *fixed immediate*; difficulty (0–3) only drives enemy behaviour/spawn density and the 1UP thresholds. (This was checked explicitly: no enemy offsets its reward pointer by difficulty, and the award function does not either.)
- 52 award sites total across the whole game; all use the same immediate-pointer form (no stored/computed/indirect variants anywhere).

---

## 2. The scoring pipeline

```
   enemy hit by player weapon
            │
            ▼
   <enemy>_destroy / tick destroy-path
            │   MOV CX, 0xe8bd          ; CX = update_current_stage_score
            │   MOV DX, 0x86xx          ; DX = reward_ptr (into score_rewards_table)
            │   CALL enqueue_event      ; (0x40_0384) defer to next frame
            ▼
   deferred event queue  (63 slots @ 0x4_1E20, 8 bytes each)
            │   dispatched next frame → routine(param1)
            ▼
   update_current_stage_score(reward_ptr)   @ 0x40_E8BD
            │   BCD add reward → running score and per-stage score
            │   cap at 9,999,999 ; 1UP extend check ; top-score check ; redraw HUD
            ▼
   score updated
```

Key addresses:

| Symbol | Addr | Role |
|---|---|---|
| `score_rewards_table` | `0x1000_86E8` | flat list of 15 BCD point values |
| `update_current_stage_score` | `0x40_E8BD` | award routine (input: `CX` = reward ptr) |
| `enqueue_event` | `0x40_0384` | append `(routine=CX, param1=DX, param2=BX)` to deferred queue |
| `difficulty` | `0x4000_2F2E` | 0–3, set in stage init; **not** used for scoring |
| `score_running_p1 / _p2` | `0x4000_2F34 / 2F3C` | 4-byte BCD running score |
| `stage_score_table_p1 / _p2` | `0x4000_2FD8 / 3018` | per-stage 4-byte BCD score slots |

### `update_current_stage_score` (0x40_E8BD) — what it does each call

Given `CX` = pointer to a 4-byte packed-BCD reward:

1. Pick the active player's pointers (`current_player_flag` @ `0x2F20`): running score (`2F34`/`2F3C`) and the current stage's score slot `stage_score_table_p[12] + (current_stage-1)*4`.
2. Two NEC V30 `ADD4S` BCD chained adds (`CL=7` → 8 nibbles): `reward + running_score`, then `reward + per_stage_score`.
   - If the top nibble overflows past 9, **clamp to `0x09999999` = 9,999,999** (R-Type's cap is **7 digits**, not 8 — the HUD shows 7).
3. **Extend (1UP)**: compare running score to `current_extend_threshold_p[12]`; if reached, advance the threshold pointer by 4 (next entry in `extend_threshold_table`), +1 life (unless already `0xFFFF`), play 1UP sound (cmd `0x38`).
4. **Top score**: BCD-compare running vs the displayed top; if beaten, copy it into `score_top_hud_*`.
5. Redraw the HUD digits.

> ⚠ The award is **deferred** (queued via `enqueue_event`, applied next frame), so the score visibly ticks a frame after the kill. For the TO8 port this can be applied immediately — there is no gameplay dependency on the 1-frame delay.

---

## 3. The point-value table — `score_rewards_table` @ `0x1000_86E8`

15 little-endian packed-BCD dwords. `index → reward_ptr = 0x86E8 + index*4`.

| Index | reward_ptr | Bytes (LE) | Points |
|------:|:----------:|:-----------|-------:|
| 0  | `0x86E8` | `00 01 00 00` | **100** |
| 1  | `0x86EC` | `00 02 00 00` | **200** |
| 2  | `0x86F0` | `00 03 00 00` | **300** |
| 3  | `0x86F4` | `00 04 00 00` | **400** |
| 4  | `0x86F8` | `00 05 00 00` | **500** |
| 5  | `0x86FC` | `00 06 00 00` | **600** |
| 6  | `0x8700` | `00 07 00 00` | **700** |
| 7  | `0x8704` | `00 08 00 00` | **800** |
| 8  | `0x8708` | `00 10 00 00` | **1 000** |
| 9  | `0x870C` | `00 15 00 00` | **1 500** |
| 10 | `0x8710` | `00 20 00 00` | **2 000** |
| 11 | `0x8714` | `00 50 00 00` | **5 000** |
| 12 | `0x8718` | `00 80 00 00` | **8 000** |
| 13 | `0x871C` | `00 00 01 00` | **10 000** |
| 14 | `0x8720` | `00 50 01 00` | **15 000** |

Encoding = packed BCD, low byte first. e.g. `00 50 01 00` → dword `0x00015000` → reads as decimal **15000**. All 15 entries are referenced by at least one object across the game.

> Just before the table (`0x1000_86CC`) sits `extend_threshold_table_2` (the 1UP thresholds: 9,999, 19,999, 34,999, 49,999, 69,999, …). Unrelated to enemy points, but adjacent in ROM.

---

## 4. Complete enemy / object inventory (by reward index)

Each scoreable object is listed with the function and exact instruction address that loads its reward pointer. "Site" = the `MOV DX,0x86xx` address. 52 sites total.

### Index 0 — 100 pts
| Object | Function @addr | Site |
|---|---|---|
| Blaster (wall turret) | `blaster_destroy` @`0x40_8733` | `0x40_8741` |
| Wick (tadpole Bydo, swarm) | `run_wick` @`0x40_8861` | `0x40_88EE` |
| Bronco boss — state segment | `tick_bronco_segment_state` @`0x40_BC95` | `0x40_BD08` |

### Index 1 — 200 pts
| Object | Function @addr | Site |
|---|---|---|
| POW Armor (destroyed → drops bonus) | `create_bonus` @`0x40_5811` | `0x40_581A` |
| Pata-Pata | `run_pata_pata` @`0x40_59A2` | `0x40_59F3` |
| Bink | `run_bink_destroy` @`0x40_5C83` | `0x40_5C97` |
| Bug (child) | `run_bug` @`0x40_5E8E` | `0x40_5EDE` |
| Shell ring segment | `run_shell_child` @`0x40_6C37` | `0x40_6CCB` |
| Fast | `fast_destroy` @`0x40_8537` | `0x40_8540` |
| Geld | `run_geld` @`0x40_8F86` | `0x40_908E` |
| Outslay body segment (single-hit demote) | `outslay_body_explode_init` @`0x40_93FA` | `0x40_9411` |
| Outslay segment (chain death) | `outslay_destroy_with_score` @`0x40_954B` | `0x40_955A` — **awarded per segment (~21×)** |
| Mikun | `run_mikun` @`0x40_96E9` | `0x40_9728` |
| Warship boss — standalone small turret | `tick_warship_small_turret_standalone` @`0x40_E2AA` | `0x40_E34D` |

### Index 2 — 300 pts
| Object | Function @addr | Site |
|---|---|---|
| Pursuer | `run_pursuer` @`0x40_71C7` | `0x40_7278` |
| Newt | `run_newt` @`0x40_72D2` | `0x40_736E` |
| Slither body / tail segment | `destroy_slither_body_or_tail` @`0x40_7C77` | `0x40_7C8A` |
| Cancer | `destroy_cancer` @`0x40_8AD1` | `0x40_8ADF` |
| Dobkeratops — optical nerve (eye) | `run_dobkeratops_optical_nerves` @`0x40_9F84` | `0x40_9FD6` |
| Bellmite — satellite (×12 shield) | `bellmite_satellite_destroy_with_score` @`0x40_B5D3` | `0x40_B5DE` |
| Warship boss — big turret (up-mount) | `tick_warship_big_turret_top` @`0x40_E157` | `0x40_E1ED` |

### Index 3 — 400 pts
| Object | Function @addr | Site |
|---|---|---|
| **Bonus pickup collected** (crystal/POW item, not a kill) | `apply_bonus_pickup` @`0x40_5947` | `0x40_594C` |
| Mid (spinning vessel) | `run_mid` @`0x40_5D2D` | `0x40_5D79` |
| Cytron | `run_cytron` @`0x40_69B4` | `0x40_6A64` |
| Bronco boss — chaser child | `tick_bronco_helper_chaser` @`0x40_BDB2` | `0x40_BE26` |
| Warship boss — front turret (6 variants) | `tick_warship_front_turret` @`0x40_D608` | `0x40_D6CC` |

### Index 4 — 500 pts
| Object | Function @addr | Site |
|---|---|---|
| Gouger | `run_gouger` @`0x40_6FD0` | `0x40_70F7` |
| P-Staff | `destroy_p_staff` @`0x40_777B` | `0x40_777B` |
| Scant | `destroy_scant` @`0x40_82A0` | `0x40_82B4` |
| Zoid | `zoid_killed_by_player` @`0x40_8E86` | `0x40_8E9A` |

### Index 5 — 600 pts
| Object | Function @addr | Site |
|---|---|---|
| Warship boss — sub-part | `warship_part_destroy_wreckage_paint_tick` @`0x40_C8D6` | `0x40_C91B` |
| Warship boss — wreckage sub-part | `warship_wreckage_part_destroy_wreckage_paint_tick` @`0x40_CB14` | `0x40_CB59` |
| Warship boss — detachable falling object (capsule/triangle) | `tick_warship_detachable_falling_object_destroy_drift` @`0x40_D188` | `0x40_D211` |
| Warship boss — bottom reactor (×4) | `tick_warship_bottom_reactor` @`0x40_D90E` | `0x40_D9D1` |

### Index 6 — 700 pts
| Object | Function @addr | Site |
|---|---|---|
| Brood | `brood_destroyed` @`0x40_7FFF` | `0x40_8013` |
| Warship boss — multi-turret (Gatling, 4 orientations) | `tick_warship_multi_turret` @`0x40_DBB5` | `0x40_DC4F` |

### Index 7 — 800 pts
| Object | Function @addr | Site |
|---|---|---|
| Tabrok | `destroy_tabrok` @`0x40_65E4` | `0x40_65F8` |
| Slither head (worth more than its body) | `destroy_slither_head` @`0x40_7C50` | `0x40_7C63` |
| Cheetah | `cheetah_destroy` @`0x40_8628` | `0x40_8637` |
| Warship boss — rear reactor | `tick_warship_rear_reactor_body_fade` @`0x40_CDED` | `0x40_CE6C` |
| Warship boss — escape capsule | `tick_warship_escape_capsule_phase2_drift` @`0x40_D518` | `0x40_D55A` |

### Index 8 — 1 000 pts
| Object | Function @addr | Site |
|---|---|---|
| Dop | `run_dop` @`0x40_5F3C` | `0x40_6057` |

### Index 9 — 1 500 pts
| Object | Function @addr | Site |
|---|---|---|
| Boldo | `run_boldo` @`0x40_6EC4` | `0x40_6F40` |

### Index 10 — 2 000 pts
| Object | Function @addr | Site |
|---|---|---|
| **Bellmite** (Stage-5 boss, parent) | `tick_bellmite_combat` @`0x40_B2DC` | `0x40_B3CF` |

### Index 11 — 5 000 pts
| Object | Function @addr | Site |
|---|---|---|
| **Dobkeratops** (Stage-1 boss) | `init_dobkeratops_explosion` @`0x40_9D10` | `0x40_9D10` |
| **Compiler** boss — RIGHT part | `tick_compiler_right_part` @`0x40_AA0F` | `0x40_AAF2` |
| **Compiler** boss — BOTTOM part | `tick_compiler_bottom_part` @`0x40_AB62` | `0x40_AC3C` |
| **Compiler** boss — LEFT part | `run_compiler` @`0x40_ACE7` | `0x40_ADEC` |

### Index 12 — 8 000 pts
| Object | Function @addr | Site |
|---|---|---|
| **Gomander** boss | `_arm_death_sequence` @`0x40_A4CD` (in `run_gomander_boss` @`0x40_A278`) | `0x40_A4D2` |

### Index 13 — 10 000 pts
| Object | Function @addr | Site |
|---|---|---|
| Bronco boss — main-attack sub-child (phase 2) | `tick_bronco_main_attack_subchild_phase2` @`0x40_C069` | `0x40_C084` |
| **Warship** boss — core, phase 3 (stage-end trigger) | `tick_warship_core_phase_3` @`0x40_DDF4` | `0x40_DE78` |

### Index 14 — 15 000 pts
| Object | Function @addr | Site |
|---|---|---|
| **Bydo Core** (final boss) | `run_bydo` @`0x40_C0CA` | `0x40_C194` |

---

## 5. Notes for the Thomson port

1. **Model**: give every scoreable object a 1-byte `reward_index` (0–14). Keep a 15-entry value table (it can stay BCD, or be plain integers if the TO8 score is stored as binary/decimal differently). On death, `score += value_table[reward_index]`.
2. **No difficulty scaling** to replicate — points are fixed per object. (Difficulty in the arcade only affects spawn density / fire rate / 1UP thresholds.)
3. **Score cap = 7 digits = 9,999,999** (already a project rule — do NOT use the 8-digit `99,999,999`).
4. **Multi-part bosses score per part**: e.g. the Compiler awards 5000 on *each* of its three parts; the Warship awards on a dozen sub-parts (turrets, reactors, capsules, core); Outslay awards 200 *per segment*. Budget the total accordingly when porting a boss.
5. **Bonus pickup also scores** (index 3 = 400) via `apply_bonus_pickup`, distinct from killing the POW Armor that drops it (index 1 = 200).
6. **Deferred vs immediate**: the arcade defers the award by one frame (event queue). The port can add it immediately; nothing depends on the delay.
7. **Stage-1 scope** (what you'll port first): Blaster (100), Wick (100), POW Armor (200), Pata-Pata (200), Bink (200), Bug (200), Tabrok (800), Dobkeratops nerves (300 each), Dobkeratops boss (5000), plus the bonus pickup (400). Indices for these are in the tables above.

---

## 6. Method / provenance (so this can be re-verified or extended)

- The award routine and table were read directly from the Ghidra DB (`update_current_stage_score` @ `0x40_E8BD`, `score_rewards_table` @ `0x1000_86E8`).
- The 52 award sites were found by an exhaustive disassembly scan of the actor code region **`0x40_3000` – `0x40_FC55`** (code ends at `0x40_FC55`; `0x40_FC56`+ is data/padding), matching the canonical pattern `MOV CX,0xe8bd` + nearby `MOV DX,0x86xx` + `CALL enqueue_event`.
- **Completeness caveat**: the scan is exhaustive for the immediate-pointer form. A secondary scan found **zero** stored-field (`MOV DX,[BP+xx]`), computed, direct-`CALL 0xE8BD`, or orphan variants — so within the code region the inventory is complete. Ghidra's auto-xrefs to the table are *incomplete* (only 5 of 52 immediates were auto-linked), which is why a code scan, not an xref query, was used.
