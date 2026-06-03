# Step 04: Sound & Music

**Objective**: Play background music throughout the game and sound effects for game events (bullet fire, collision).

**Time**: 30-40 minutes

**Build on**: Step 03 (collision detection complete)

---

## Subsystems in Play

- **Sound Engine** — Music playback, SFX triggering
- **Hardware Registers** — PSG (Programmable Sound Generator) access
- **Audio Memory** — Music ROM layout, SFX sample storage
- **Game Loop Integration** — Play SFX during collision/fire events

This step adds audio without modifying sprite behavior, collision, or rendering. Audio runs on its own interrupt-driven playback.

---

## Walkthrough: Thomson TO8 Audio Architecture

The Thomson TO8 has:

- **PSG (Programmable Sound Generator)** at `$A7E8-$A7EB` — tone generation
- **Sound ROM** — Music and SFX data in cartridge or disk
- **Music Player** — Sequencer that plays notes from ROM
- **SFX Triggers** — Event callbacks that start sound samples

### Audio Memory Layout

```
$7000-$7FFF  Sound code (player, mixer)
$8000-$8FFF  Music data (notes, timing)
$9000-$9FFF  SFX samples (bullet fire, explosion, etc.)
```

### PSG Register Map

```
$A7E8  Data write (to selected register)
$A7E9  Address select (0-15 for PSG register)

Typical sequence:
  lda   #register_number
  sta   $A7E9                 ; Select register
  lda   #value
  sta   $A7E8                 ; Write value
```

PSG has 16 registers controlling:
- Registers 0-1: Channel A frequency (12-bit)
- Registers 2-3: Channel B frequency
- Registers 4-5: Channel C frequency
- Register 6: Noise frequency
- Register 7: I/O control (which channels on/off)
- Registers 8-10: Channel A/B/C volume (0-15)

---

## Code Template: Simple Music Player

### Initialize Music

```asm
InitMusic:
        * Music ROM starts at $8000
        * Structure: header (4 bytes), then note entries
        * Each note: pitch (2 bytes) + duration (1 byte)

        lda   #0
        sta   music_playing         ; Clear flag

        lda   #<$8000
        sta   <music_pc_low
        lda   #>$8000
        sta   <music_pc_high        ; PC = $8000

        lda   #0
        sta   <music_counter        ; Frame counter for timing

        rts
```

### Play Frame of Music

Call this every frame (or every N frames if music is 4 times slower than animation):

```asm
UpdateMusic:
        lda   music_playing
        beq   no_music_update
        rts

        * Read current note
        lda   music_counter
        beq   fetch_next_note
        deca
        sta   music_counter
        rts

fetch_next_note:
        * Get byte from music ROM at (music_pc_high, music_pc_low)
        ldx   #0
        lda   @(music_pc_low, music_pc_high)

        * Byte = 0 means end of song
        beq   stop_music

        * Byte = $FF means rest/pause
        cmpa  #$FF
        beq   rest_note

        * Otherwise: play tone
        jsr   PlayNoteNumber
        bra   music_advance

rest_note:
        * Silence for one frame
        jsr   SilenceChannels

music_advance:
        * Advance PC
        lda   <music_pc_low
        adda  #1
        sta   <music_pc_low
        bcc   no_pc_high_carry
        lda   <music_pc_high
        adda  #1
        sta   <music_pc_high
no_pc_high_carry:

        lda   #4                    ; Play each note for 4 frames
        sta   <music_counter
        rts

stop_music:
        lda   #0
        sta   music_playing
        jsr   SilenceChannels
        rts

no_music_update:
        rts
```

### Play Single Note

```asm
PlayNoteNumber:
        * A = MIDI note number (0-127)
        * Converts to PSG frequency and plays on channel A

        * Note frequency table (simplified)
        * Maps 12-tone scale to PSG counts
        * Standard tuning: A4 = 440 Hz

        * For simplicity, use pre-calculated table
        leay  NoteFrequencyTable
        lda   b,y                   ; Get frequency for note
        sta   <freq_low
        lda   a,y
        sta   <freq_high

        * Write to PSG channel A
        lda   #0
        sta   $A7E9                 ; Register 0 (freq low)
        lda   <freq_low
        sta   $A7E8

        lda   #1
        sta   $A7E9                 ; Register 1 (freq high)
        lda   <freq_high
        sta   $A7E8

        * Set volume (register 8, channel A) to 15 (full)
        lda   #8
        sta   $A7E9
        lda   #15
        sta   $A7E8

        * Enable channel A (register 7)
        lda   #7
        sta   $A7E9
        lda   #$FE                  ; 1111 1110 = enable A, B, C off
        sta   $A7E8

        rts
```

### Note Frequency Table

Place this in memory or ROM:

```asm
NoteFrequencyTable:
        * Frequencies for C4 to B4 (octave 4)
        * Each entry: low byte, high byte
        * PSG freq = master_clock / note_frequency

        * C4: ~262 Hz
        fdb   $0D4C

        * D4: ~294 Hz
        fdb   $0C18

        * E4: ~330 Hz
        fdb   $0AA9

        * F4: ~349 Hz
        fdb   $09FF

        * G4: ~392 Hz
        fdb   $08D2

        * A4: ~440 Hz (standard)
        fdb   $07E9

        * B4: ~494 Hz
        fdb   $0700

        * Repeat for other octaves (2x/2 frequency)
```

---

## Sound Effects: Event Callbacks

When a bullet fires or hits an enemy, play a SFX:

### Fire Sound Effect

```asm
PlayFireSound:
        * Simple beep: high pitch, short duration

        * Set PSG channel B for fire sound
        lda   #2
        sta   $A7E9                 ; Register 2 (freq low, channel B)
        lda   #$F0                  ; High frequency
        sta   $A7E8

        lda   #3
        sta   $A7E9
        lda   #$00
        sta   $A7E8

        * Volume up
        lda   #9
        sta   $A7E9
        lda   #12
        sta   $A7E8

        * Enable channel B
        lda   #7
        sta   $A7E9
        lda   #$FD                  ; Enable only B
        sta   $A7E8

        * Set counter (will silence after 1 frame)
        lda   #1
        sta   <sfx_fire_counter
        rts
```

### Collision Sound Effect

```asm
PlayCollisionSound:
        * Descending "bonk" sound

        * Channel C, lower frequency
        lda   #4
        sta   $A7E9                 ; Register 4 (freq low, channel C)
        lda   #$80
        sta   $A7E8

        lda   #5
        sta   $A7E9
        lda   #$02
        sta   $A7E8

        * Volume
        lda   #10
        sta   $A7E9
        lda   #14
        sta   $A7E8

        * Enable channel C
        lda   #7
        sta   $A7E9
        lda   #$FB                  ; Enable only C
        sta   $A7E8

        lda   #2
        sta   <sfx_collision_counter
        rts
```

### SFX Update in Main Loop

```asm
UpdateSoundEffects:
        * Fire sound timeout
        lda   <sfx_fire_counter
        beq   sfx_fire_done
        deca
        sta   <sfx_fire_counter
        bne   sfx_fire_done
        jsr   SilenceChannelB

sfx_fire_done:
        * Collision sound timeout
        lda   <sfx_collision_counter
        beq   sfx_collision_done
        deca
        sta   <sfx_collision_counter
        bne   sfx_collision_done
        jsr   SilenceChannelC

sfx_collision_done:
        rts
```

### Silence Routine

```asm
SilenceChannels:
        * Turn off all channels
        lda   #8
        sta   $A7E9                 ; Volume A
        lda   #0
        sta   $A7E8

        lda   #9
        sta   $A7E9                 ; Volume B
        lda   #0
        sta   $A7E8

        lda   #10
        sta   $A7E9                 ; Volume C
        lda   #0
        sta   $A7E8

        rts

SilenceChannelB:
        lda   #9
        sta   $A7E9
        lda   #0
        sta   $A7E8
        rts

SilenceChannelC:
        lda   #10
        sta   $A7E9
        lda   #0
        sta   $A7E8
        rts
```

---

## Integration: Call SFX from Event Handlers

Modify your collision handler from Step 03:

```asm
OnBulletHitEnemy:
        * X = bullet, Y = enemy

        * Play collision sound
        jsr   PlayCollisionSound

        * Despawn bullet and enemy (from Step 03)
        lda   #0
        sta   sprite_active,x
        sta   sprite_active,y

        * Spawn explosion
        lda   x_pos,y
        jsr   SpawnExplosion

        * Update score
        lda   score
        adda  #10
        sta   score

        rts
```

And modify your fire routine from Step 02:

```asm
FireBullet:
        * Y = player sprite address

        * Play fire sound
        jsr   PlayFireSound

        * Find bullet slot and spawn (from Step 02)
        ldx   #BulletTable
bullet_search:
        lda   sprite_active,x
        beq   bullet_found
        leax  SpriteStride,x
        cmpx  #BulletTableEnd
        bne   bullet_search
        rts

bullet_found:
        lda   x_pos,y
        sta   x_pos,x
        lda   y_pos,y
        suba  #8
        sta   y_pos,x

        lda   #1
        sta   sprite_active,x
        lda   #2
        sta   x_vel,x
        lda   #0
        sta   y_vel,x

        rts
```

---

## Real-World Example: Goldorak Music System

Open `/game-projects/goldorak/music/` and examine:
- `MusicGoldorak/` — Main theme data (encoded tile map or note list)
- Music player in `/game-projects/goldorak/game-mode/gamescreen/main.asm`

Look for patterns:

```asm
        * At every VBL interrupt
        jsr   UpdateMusic            ; Play next music frame
        jsr   UpdateSoundEffects     ; Timeout SFX

        * When weapon fires
        jsr   PlayFireSound

        * When collision detected
        jsr   PlayExplosionSound
```

Goldorak uses a more sophisticated system (PSG modules with channel mixing), but the core pattern is:
1. Initialize music at game start
2. Update player every frame
3. Trigger SFX on events
4. Use volume control for mixing

---

## Sound ROM Organization

If loading music from disk/ROM:

```asm
LoadMusicROM:
        * Load from disk at offset $1000
        lda   #>$8000               ; Destination high
        sta   <load_addr_high
        lda   #<$8000
        sta   <load_addr_low

        lda   #>1024                ; Size (16KB = $4000)
        sta   <load_size_high
        lda   #<$4000
        sta   <load_size_low

        * Call disk loader
        jsr   LoadFromDisk
        rts
```

---

## Volume Control

Adjust volume with register 8 (channel A), 9 (B), 10 (C):

```asm
SetMusicVolume:
        * A = volume (0-15)
        sta   <music_volume

        lda   #8
        sta   $A7E9                 ; Channel A volume
        lda   <music_volume
        sta   $A7E8

        rts

SetSFXVolume:
        * A = volume (0-15)
        sta   <sfx_volume

        lda   #9
        sta   $A7E9                 ; Channel B volume
        lda   <sfx_volume
        sta   $A7E8

        rts
```

---

## Performance Considerations

1. **Music update**: Should take <1ms per frame (minimal CPU)
2. **SFX triggering**: Instant (just set PSG registers)
3. **Multiple SFX**: Only 3 channels available; queue if needed

Simple solution: Prioritize SFX (bullets > collisions > events). If too many fire simultaneously, discard lowest priority.

---

## What You've Built

Your game now has:

1. **Background music** — Plays from ROM/disk at start
2. **Fire sound** — Beep when player fires
3. **Collision sound** — Bonk when bullet hits enemy
4. **Integration** — SFX triggered by game events

This completes the audio subsystem. Sound is fully independent from graphics/collision/object-management.

---

## What's Next

The **Extending** tutorials continue with:

- **Step 05**: Level scrolling — Load large levels, camera following player
- **Step 06**: Advanced collision — Wall collision, multi-type responses

You now have a **complete interactive game with audio**. The next steps add visual and level complexity.

---

## Modifications & Challenges

1. **Add more notes**: Extend `NoteFrequencyTable` to support full range (C2-B7)
2. **Add melody**: Create a simple 8-note melody in memory and play it
3. **Noise SFX**: Use register 6 (noise frequency) for percussion sounds
4. **Music loops**: When song ends, jump back to start address
5. **Fade volume**: Gradually reduce volume over N frames when stopping

---

## Deep Dive: API Reference

- **Sound API** → `api-reference/sound-api.md`
  - PSG register details
  - Frequency calculations
  - Music sequencer design
  - Audio memory layout

- **Interrupt System** → `api-reference/timer-api.md`
  - VBL sync for audio frame timing

---

## Summary

You've learned:

1. **PSG hardware**: 3 tone channels, controlled via registers
2. **Music playback**: Simple sequencer reading notes from ROM
3. **Sound effects**: Event-driven sounds (fire, collision)
4. **Integration**: Hook SFX into collision/fire routines
5. **Volume control**: Adjust channel volumes 0-15

Your game is now **audio-complete**. Add music at boot, trigger SFX on events, and let the audio hardware handle playback independently.

---

## Further Exploration

### Study Goldorak Audio

Examine `/game-projects/goldorak/` for:
- Full PSG module implementation
- Multi-channel music with effects
- Multiple SFX simultaneous playback
- Volume fading and transitions

### Advanced Topics

After completing this step:
1. **PSG modules** — Pre-composed multi-track arrangements
2. **SMPS player** — Sega Master System format (more sophisticated)
3. **PCM samples** — Raw audio playback (needs more memory)

For now, simple 3-channel PSG is sufficient for most games.

---

## Congratulations!

You've completed **Step 04: Sound & Music**.

Your game now has:
- ✓ Graphics rendering (Step 00)
- ✓ Object management (Step 01)
- ✓ Input handling (Step 02)
- ✓ Collision detection (Step 03)
- ✓ **Sound & music (Step 04)**

You've built a full sensory experience: visual feedback (sprites, collisions) and audio feedback (music, SFX). The game feels complete.

**Ready for more?** Proceed to Step 05: Level Scrolling.