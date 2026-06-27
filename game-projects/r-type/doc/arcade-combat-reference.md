# R-Type Arcade — Combat reference: enemy HP & player weapon power

> Source of truth: the arcade `maincpu.bin` Ghidra database (x86 16-bit, code seg 0x40),
> queried via the asm-ark bridge. Companion to `arcade-scoring-reference.md`.
> Purpose: model enemy durability and player firepower for the Thomson TO8 port.

---

## 1. The damage model (the link between weapons and enemies)

Every enemy ObjectRecord carries two bytes:
- **`+0x1F`** = damage accumulated so far (starts at 0)
- **`+0x2F`** = max damage = **HP / "life potential"**

Each frame, an enemy's tick calls one of the **player-collision dispatchers**
(`do_collision_with_player_and_weapons_v1..v4` @ 0x40f694+). Each player weapon that
overlaps the enemy **adds its power to `+0x1F`**. The enemy dies when **`+0x1F >= +0x2F`**.

```
   player weapon AABB overlaps enemy
            │
            ▼
   do_collision_with_player_and_weapons_vN  (enemy tick calls one)
            │   for each weapon helper that returns CY=1:
            │       enemy.+0x1F += weapon_power
            ▼
   enemy run-routine:  if +0x1F >= +0x2F  →  destroy
   →  hits_to_kill = +0x2F / weapon_power
```

Two enemy families — exactly the "some have no potential" intuition:

| Dispatcher | Behaviour |
|---|---|
| **v1** (`0x40f694`) | "minimal pipeline for invincible obstacles / **one-shot kills**" — no damage accumulation. The enemy dies on the first damaging hit (CY=1). **Effective HP = 1.** |
| **v2** `0x40f6da`, **v3** `0x40f75f`, **v3_skip** `0x40f7e4`, **v4** `0x40f7f1` | full accumulating pipeline → real **HP at `+0x2F`** (set in the enemy's create routine). |

`+0x2F` is written as an immediate in each HP-bearing enemy's **create/constructor** (`MOV byte ptr [SI+0x2f], imm`). One-shot enemies never write it.

---

## 2. Player One weapon damage

| Weapon | Damage / hit | Source |
|---|---:|---|
| **Basic forward shot** (tap, no crystal) | **1** | `create_simple_fire` @0x4f0c → `+0x17 = 1` |
| **Wave cannon — charge tier 1** | **4** | `beam_power_image_table` @ES:0x188C = `{0,4,8,12,16,20}` |
| **Wave cannon — tier 2** | **8** | |
| **Wave cannon — tier 3** | **12** | |
| **Wave cannon — tier 4** | **16** | |
| **Wave cannon — tier 5 (full charge)** | **20** | power = beam `image_id`, **constant** (no time/distance decay) — it's a penetration budget, see below |
| **Force-pod laser — rebound (bleu, type 0)** | **2** | head/damage cell `+0x17 = 2` (filler segs 0, a few mid-cells 1) |
| **Force-pod laser — ground (jaune, type 2)** | **2** | `+0x17 = 2` |
| **Force-pod laser — counter-air (rouge, type 6)** | **5** | `+0x17 = 5` |
| **Force-pod simple fire / "3x"** | **1** | dispatcher `INC +0x1F` |
| **Missiles** | **1** | dispatcher `INC +0x1F` |
| **Force-pod body contact** | **1 per 16 frames** | **shared** gate `[0x10002eb6] & 0x0F == 0` (see below) |
| **Bit devices** (side orbiters) | **1 per 16 frames** | **same shared** gate `[0x10002eb6] & 0x0F == 0` |

**The force pod and both bit devices share ONE contact-damage gate.** `collision_to_force_pod` (0x40f493) is a short-circuit OR test that falls through into `collision_to_top_and_bottom_bit_devices` (0x40f49b): it returns "hit" if the enemy overlaps the pod **OR** the top bit **OR** the bottom bit. The HP-tracking dispatchers (v2 0x40f6da plate *"Forcepod hits are gated … 1 dmg per 16 global frames"*, v3 0x40f777 *"Forcepod only apply one damage point every 16 frames"*, v4 0x40f7f0 for bits-only) then apply a **single** gated `INC +0x1F`:

```
TEST byte ptr [0x2eb6], 0x0F   ; global frame counter
JNZ  skip                      ; only when (counter & 0x0F) == 0  -> every 16 frames
INC  [BP+0x1F]                 ; +1 to the enemy's accumulated damage
```

So a single enemy touched simultaneously by the pod **and** a bit still takes only **1** point per 16-frame window (one chained test → one INC). The v1 dispatcher (0x40f694, one-shot / invincible obstacles) does **not** gate — but those enemies die on any hit regardless. **Port:** `WeaponContactTick` (`global/weaponcollide.asm`) reproduces this — one frame-drop-compensated global gate (`weaponGateAccum`, period 16) driving a single enemy-list pass that decrements each enemy overlapping any armed pod/bit by 1.

**Port — one-shot vs HP fidelity.** The arcade only gates the pod/bits in the HP-tracking dispatchers (v2/v3/v4); the v1 one-shot enemies die on *any* contact, ungated. The port has no per-enemy dispatcher — it collapses every enemy's HP into `AABB.p`. For stage 1 those values split cleanly: **1** for the small/one-shot fry (patapata, bug, blaster, bink, cancer, **dobkeratops eye**) and **≥2** for the durable ones (tabrok, **dobkeratops monster** = 30); tail/saw are invincible (−128). So `WeaponContactTick` applies the gate **per enemy**: `p == 1` takes instant contact every frame (a 1-HP enemy dies in one hit just like a basic shot — nothing to throttle), `p ≥ 2` takes 1 dmg only on a fire frame (the 1/16 throttle that stops the pod melting durable enemies). Principled in general, and exact for this roster — the only theoretical gap (a v2/v3 enemy with *max* HP exactly 1, which doesn't exist here) would lose ≤16 frames on its single point.

Charge tiers are set by `player_one_fire_beam` @0x4023ea (charge < 0x18/0x30/0x48/0x50/0x68/else → tier 0..5). **Tier 0 = no beam** (the visible shot is the basic forward shot, 1 dmg).

**The charged beam does NOT decay with time or distance** — its power (`image_id`) is constant per tier. It is a **penetration budget**: each enemy the beam overlaps takes the beam's **full** power (so it one-shots anything with HP ≤ the tier value), and the beam's budget then drops by that enemy's HP (`run_fire_beam` @0x3291 `SUB image_id, absorbed_HP`; the collision feeds the absorbed HP via `ADD beam+0x17, remaining_HP`). When the budget underflows the beam dies; otherwise it flies right at **8 px/frame** until world-X `0x2D0` (right edge → recycle) or a solid terrain tile (→ `fire_beam_ring_explosion`). So a full-charge beam (20) plows through ≈20 HP worth of enemies before expiring, at full strength the whole way in open space. (Earlier "−1/frame decay" was a misread — corrected.)

**`image_id` is one unified byte** — simultaneously the beam's damage/penetration budget, its **sprite**, and its **hitbox size** (and the death counter at 0). `run_fire_beam` derives both the sprite (`beam_sprite_table` @ES:0x1898, index `(image_id-1) & 0x1C`) and the hitbox extent (`@ES:0x1856 + ((image_id-1) & 0x1C)*2`) from it. The `& 0x1C` quantises `image_id` into **5 bands of 4**:

| `image_id` | sprite / hitbox |
|---|---|
| 17–20 | tier 5 (largest beam) |
| 13–16 | tier 4 |
| 9–12 | tier 3 |
| 5–8 | tier 2 |
| 1–4 | tier 1 (smallest) |
| 0 | dead → ring explosion |

So as the beam penetrates enemies and its budget drops, it **shrinks tier-by-tier** in both the sprite and the collision box (absorbing ≈one tier of HP = one visual step down), until it expires. For the port this is a clean single-byte model: store the beam's "strength", pick its sprite + hitbox by `strength÷4`, and subtract each penetrated enemy's HP from it.

---

## 3. Enemy HP — full inventory

**One-shot (`v1`, no `+0x2F`):** Mikun · Pata-Pata · Bink · Mid · Bug · POW Armor · Blaster · Fast · Geld · **Cancer** · Outslay (only damageable segment).
**HP = 1 (tracking dispatcher):** Dobkeratops optical nerve (eye).

| Enemy / boss (function @addr) | Disp. | HP `+0x2F` | Hits (1-dmg) |
|---|:--:|--:|--:|
| Newt (`create_newt` @0x7294) | v2 | 2 | 2 |
| Warship small turret (`@0xe281`) | v2 | 2 | 2 |
| Cytron (`create_cytron` @0x696e) | v2 | **{3,5,8,14}** per difficulty | 3–14 |
| Warship big / multi-turret · Zoid | v2 | 4 | 4 |
| Slither body/tail · P-Staff (`create_p_staff` @0x74b4) | v2 | 6 | 6 |
| Gomander boss (`create_gomander` @0xa22e) | v3 | 8 | 8 |
| Dop (`create_dop` @0x5eed) · Gouger (`create_gouger` @0x6f89) | v2 | 10 | 10 |
| Slither head · Warship front turret / falling triangle · Bellmite satellite | v2/v3/v4 | 14 | 14 |
| Warship bottom reactor | v2 | 18 | 18 |
| Warship rear reactor / core / capsule | v2/v3 | 20 *(→250 hard loop)* | 20 |
| **Tabrok** (`create_tabrok` @0x60ba) · **Scant** · **Cheetah** · **Dobkeratops face** (`run_dobkeratops_monster_main` @0x9c70) | v2/v3 | **30** (`0x1E`) | 30 |
| Brood · **Compiler** ×3 segments · **Bellmite** parent (boss) | v2/v4 | **40** (`0x28`) | 40 |
| **Boldo** (`create_boldo` @0x6e9b) | v2 | **200** (`0xC8`) | 200 |

**Special HP semantics (not a simple count):**
- **Bronco segments & Bydo Core (final boss):** `+0x2F` (and Bronco's `+0x1F`) **re-stamped every frame** → cannot be worn down by fire; die by scripted parent signal. **Bydo Core** dies via the Force-in-mouth accumulator (`+0x38 ≥ 0x500`) or a frame timeout.
- **Dobkeratops tail / tail-end, Outslay head/neck/tail:** `+0x2F` clamped to `0x80` every frame → **invulnerable by design**.
- **Shell:** held at 128 (invincible) until the player crosses the level-progress anchor; real kill = the exposed blue core.
- **Rear reactor:** only part with difficulty-conditional HP (20 → 250 on the second loop).
- **Cytron:** only regular enemy with table-driven HP (`{3,5,8,14}` by difficulty).
- **Zoid:** `+0x2F` written in its hatch tick (4 → 70 on second loop).

---

## 4. Stage 1 roster (port wave) — verified complete

The port's Stage-1 wave spawns the enemies below (`objects/levels/01/object-wave/object-wave-data.asm`). Every one is accounted for, including all five Dobkeratops sub-parts.

| Stage-1 enemy | Disp. | HP | Hits (1-dmg) | Notes |
|---|:--:|--:|--:|---|
| Blaster | v1 | one-shot | 1 | wall turret |
| Pata-Pata | v1 | one-shot | 1 | |
| Bink | v1 | one-shot | 1 | |
| Bug | v1 | one-shot | 1 | |
| Cancer | v1 | one-shot | 1 | arcade = Stage-7 enemy; port reuses it in St.1 |
| P-Staff | v2 | 6 | 6 | |
| Tabrok | v2 | **30** | 30 | sub-pods near the boss |
| Scant | v2 | 30 | 30 | arcade = Stage-7; port reuses |
| Shell | v2 | 128 (invincible until anchor) | special | real kill = blue core |
| **Dobkeratops — optical nerve (eye)** | v3 | **1** | 1 | ×4; the wall-eyes |
| **Dobkeratops — monster / face** (boss core) | v3 | **30** (`0x1E`) | 30 | this is "the boss" — HP 30 |
| **Dobkeratops — jaw** | — | **invulnerable** | — | visual only; explodes with the boss (`parent+0x32`) |
| **Dobkeratops — tail / tail-end** | v3 | **invulnerable** | — | `+0x2F` re-stamped `0x80` each frame |
| **Dobkeratops — saw (chain)** | — | **indestructible** | — | hazard: tests the *player* AABB to deal ship damage; no player-weapon collision |

So the Dobkeratops fight: you can only damage the **face (30 HP)** and the **four nerves (1 HP each)**; the jaw, tail, and saw blades are indestructible. (Port already mirrors this: `dobkeratops_tail_hitdamage` / `dobkeratops_saw_hitdamage = -128`.)

---

## 5. Hits-to-kill cross-reference (a few worked examples)

| Enemy (HP) | Basic shot (1) | Counter-air laser, red (5) | Wave cannon full charge (20) |
|---|--:|--:|--:|
| any one-shot | 1 | 1 | 1 |
| Newt (2) | 2 | 1 | 1 |
| P-Staff (6) | 6 | 2 | 1 |
| Tabrok / Dobkeratops face (30) | 30 | 6 | 2 |
| Compiler segment (40) | 40 | 8 | 2 |
| Boldo (200) | 200 | 40 | 10 |

Wave-cannon column = ⌈HP / 20⌉ full-charge beams: against a **single** big enemy each beam delivers its full 20 then expires (budget spent absorbing that enemy's HP). Against a **line** of weak enemies one beam penetrates many (it can absorb ≈20 HP total). **No range decay** — the value is the same near or far.

---

## 6. Mapping to the port

The port **already encodes HP** as `<enemy>_hitdamage` in `objects/enemies_properties.asm`
(= the enemy's `AABB.p` — the player's shots decrement it, death at 0). Cross-checked:

| Port equate | Port value | Arcade `+0x2F` |
|---|---:|---:|
| `dobkeratops_monster_hitdamage` | 30 (`$1E`) | 30 ✓ |
| `tabrok_hitdamage` | `$1E` = 30 | 30 ✓ |
| `dobkeratops_eye_hitdamage` | 1 | 1 ✓ (nerve) |
| `blaster_hitdamage` | 1 | one-shot ✓ |
| `dobkeratops_tail_hitdamage` / `_saw_hitdamage` | −128 | invulnerable ✓ |

So this reference lets you (a) set every `<enemy>_hitdamage` to its arcade HP, and (b) model
the player weapons' per-hit damage (basic 1, blue laser 2, yellow laser 5, wave cannon 4–20).
Note the port collision is binary 1-damage-per-shot today; reproducing the wave-cannon tiers
and laser powers (2/5) would require the port's player shots to carry a damage value like the arcade.

---

## 7. Coverage & caveats

- **Stage 1: complete** (all port-wave enemies + all five Dobkeratops sub-parts verified).
- **Whole game:** ~36 actors + 7 bosses resolved across the 133 collision call sites.
- **Not confirmed:** Worm/Insuloo (not surfaced as a distinct run-routine), Win (indestructible windmill, no damage model). 5 collision sites sit on un-named code but were bound to their owning enemy by context.
- HP values are the create-time immediates; "special semantics" rows above die by script/anchor/accumulator rather than by reaching `+0x2F`.
