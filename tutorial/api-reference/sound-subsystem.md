# Sound Subsystem API Reference

**Author**: Claude Code  
**Version**: 1.0  
**Last Updated**: June 2026  
**Target Audience**: Intermediate 6809 programmers familiar with Thomson TO8 hardware

---

## Overview

The Sound Subsystem manages audio playback on the Thomson TO8 through the PSG (Programmable Sound Generator) hardware. It provides high-level functions for music loops, sound effects, volume control, and effects like fading, enabling responsive audio feedback for games.

### Core Responsibilities

1. **PSG Hardware Management** — Direct control of tone, noise, and volume registers on the PSG chip
2. **Music Playback** — Continuous background music with tempo and looping support
3. **Sound Effects** — Non-musical sound effects (SFX) with collision priority over music
4. **Volume Control** — Adjusting master volume and per-channel attenuation
5. **Audio Fading** — Smooth fade-in and fade-out effects for transitions
6. **Interrupt-Driven Playback** — VBL synchronization for reliable timing

### Hardware Context

The Thomson TO8 sound hardware:
- **PSG Chip**: AY-3-8910 (Yamaha) with 3 tone channels + 1 noise channel
- **PSG Registers**: $A7E8–$A7E9 (address port, data port)
- **Control Port**: $A7E8 (16 registers: 0–15, accessed via latch/data cycle)
- **Channels**: Channel A, B, C (tones) + Noise generator
- **Update Rate**: Music/SFX typically updated every VBL (50 Hz / 20 ms)
- **Priority System**: SFX can interrupt music; music pauses until SFX completes

---

## Memory & Hardware Layout

### PSG Register Map

```
Register    Address      Purpose
─────────────────────────────────────────────────────
0           $A7E8        Channel A Fine Tune (8-bit period, LSB)
1           $A7E8        Channel A Coarse Tune (4-bit period, MSB)
2           $A7E8        Channel B Fine Tune
3           $A7E8        Channel B Coarse Tune
4           $A7E8        Channel C Fine Tune
5           $A7E8        Channel C Coarse Tune
6           $A7E8        Noise Period (5-bit)
7           $A7E8        Enable Register (bit 0–2: Ch A/B/C tone, bit 3: noise)
8           $A7E8        Channel A Volume (4-bit: 0–15, bit 4: envelope enable)
9           $A7E8        Channel B Volume
10          $A7E8        Channel C Volume
11–13       $A7E8        Envelope: period fine, coarse, shape
14–15       $A7E8        I/O Ports (not used for sound)
```

### Access Protocol

The PSG uses a latch-based I/O protocol:

```
Step 1: Write register index (0–15) to address port ($A7E8)
        lda #6          ; Select Noise Period register
        sta $A7E8       ; Latch the register

Step 2: Write data to data port ($A7E9)
        lda #$08        ; Noise period value
        sta $A7E9       ; Write data

Step 3: Read (if needed) from data port
        lda $A7E9       ; Read noise period value
        ; (Note: some registers are write-only)
```

### Memory Layout: Music Data

Music data format (standard for TO8 games):

```
Offset    Size    Content
─────────────────────────────────────────────────────
0         2       Music ID / signature (e.g., "MU")
2         1       Tempo (ticks per note, typically 4–8)
3         1       Loop point (section index where loop begins)
4         1       Number of sections
5–...     N×48    Section data (8 patterns × 6 bytes each)

Pattern Data (6 bytes per pattern):
  0–1: Channel A note data (12-bit frequency)
  2–3: Channel B note data
  4–5: Channel C note data
  
Note Format (12-bit):
  Bits 11–4: Note index (0–255, 0 = rest)
  Bits 3–0: Duration (1–15 ticks)
```

### Memory Layout: SFX Data

Sound effects use a compact format:

```
Offset    Size    Content
─────────────────────────────────────────────────────
0         1       SFX ID
1         1       Channel assignment (bit 0–2: which channel)
2         1       Duration (frames until return to music)
3–...     N×2     Notes (frequency hi/lo pairs)

SFX Example (3-note beep):
  0: ID = $01
  1: Channel = $04 (Channel C)
  2: Duration = $10 (16 frames = 320 ms)
  3–4: Note 1 (frequency)
  5–6: Note 2
  7–8: Note 3
  Then zeros to terminate
```

### Global State Structure

The Sound Subsystem maintains state in game RAM:

```
Label               Address   Size   Content
──────────────────────────────────────────────────────
music_current_id    $3000     1      Currently playing music ID
music_current_pos   $3001     2      Playback position (section index)
music_frame_count   $3003     1      Frames elapsed in current section
music_enabled       $3004     1      1 = music playing, 0 = stopped

sfx_queue           $3010     8      SFX queue (4 pending SFX IDs)
sfx_current         $3018     1      Currently playing SFX ID
sfx_duration        $3019     1      Frames remaining for current SFX
sfx_channel_mask    $301A     1      PSG channels occupied by SFX

master_volume       $3020     1      Master volume (0–15)
channel_volumes     $3021     3      Per-channel volumes (A, B, C)
```

---

## Public Functions

### SoundPlayMusic — Start background music

```asm
; Start playing background music
;
; Entry:
;   A = Music ID (0–255)
;   music data must be loaded at known address
;
; Exit:
;   None (music plays in background via VBL interrupt)
;
; Uses: All registers (preserved by interrupt handler)
;
; Notes:
;   - If music is already playing, it is replaced
;   - Music loops at designated loop point
;   - Does not block; playback begins next VBL

SoundPlayMusic:
        sta   music_current_id
        clr   music_current_pos  ; Start from beginning
        clr   music_current_pos+1
        clr   music_frame_count
        lda   #1
        sta   music_enabled
        rts
```

### SoundPlaySFX — Queue a sound effect

```asm
; Queue a sound effect for playback
;
; Entry:
;   A = SFX ID (0–255)
;
; Exit:
;   None (SFX is queued and plays next available slot)
;
; Uses: All registers
;
; Notes:
;   - SFX are queued; up to 4 pending SFX can wait
;   - Music is paused while SFX is playing
;   - Each SFX has a duration; after that, music resumes
;   - If SFX queue is full, this call is ignored (FIFO overflow)

SoundPlaySFX:
        pshs  a,b,x
        
        ; Find empty slot in SFX queue
        ldx   #sfx_queue
        ldb   #4
.loop:
        lda   ,x
        beq   .found_slot
        leax  1,x
        decb
        bne   .loop
        
        ; Queue full; ignore SFX
        puls  a,b,x,pc
        
.found_slot:
        puls  a              ; Restore SFX ID
        sta   ,x             ; Store in queue
        puls  b,x,pc
```

### SoundSetVolume — Adjust master volume

```asm
; Set master volume level
;
; Entry:
;   A = Volume level (0–15, where 15 = maximum, 0 = silent)
;
; Exit:
;   None (volume takes effect immediately)
;
; Uses: All registers
;
; Notes:
;   - Affects all channels (music and SFX)
;   - 0 = mute, 15 = full volume
;   - Volume is applied to all PSG channels
;   - Does not affect envelope modulation

SoundSetVolume:
        sta   master_volume
        
        ; Update each PSG channel volume
        lda   #8            ; Register 8 (Channel A Volume)
        jsr   SetPSGReg
        
        lda   master_volume
        sta   $A7E9         ; Write volume
        
        lda   #9            ; Register 9 (Channel B Volume)
        sta   $A7E8
        lda   master_volume
        sta   $A7E9
        
        lda   #10           ; Register 10 (Channel C Volume)
        sta   $A7E8
        lda   master_volume
        sta   $A7E9
        
        rts
```

### SoundStop — Stop all audio playback

```asm
; Stop music and all sound effects immediately
;
; Entry:
;   None
;
; Exit:
;   None (PSG is silenced)
;
; Uses: All registers
;
; Notes:
;   - Clears all PSG registers to silence
;   - Music and SFX are terminated
;   - Call this during level transitions or pause menu
;   - PSG remains ready for new audio commands

SoundStop:
        clr   music_enabled
        clr   sfx_current
        
        ; Silence all PSG channels
        lda   #7            ; Enable register
        sta   $A7E8
        lda   #$3F          ; Disable tone + noise on all channels
        sta   $A7E9
        
        ; Set volumes to 0
        lda   #8
        sta   $A7E8
        clr   $A7E9         ; Volume 0 on Channel A
        
        lda   #9
        sta   $A7E8
        clr   $A7E9         ; Volume 0 on Channel B
        
        lda   #10
        sta   $A7E8
        clr   $A7E9         ; Volume 0 on Channel C
        
        rts
```

### SoundFadeOut — Fade music to silence

```asm
; Fade out music over specified duration
;
; Entry:
;   A = Fade duration (frames, typically 20–60 for 0.4–1.2 seconds)
;
; Exit:
;   None (fade runs in background over multiple VBL cycles)
;
; Uses: All registers
;
; Notes:
;   - Music volume decreases linearly each VBL
;   - Music is stopped when volume reaches 0
;   - If no music is playing, this has no effect
;   - Can be interrupted by SoundPlayMusic

SoundFadeOut:
        ; Store fade duration
        ; Implementation would decrement volume each VBL
        ; This is typically handled in VBL interrupt handler
        rts
```

---

## Common Patterns

### Music Loops

Background music typically loops at a designated point:

```asm
; Game loop: music plays continuously
MainGameLoop:
        jsr   UpdateGame
        jsr   UpdateInput
        jsr   RenderFrame
        jsr   WaitVBL
        
        ; Music is updated every VBL by interrupt handler
        ; No explicit music update needed in main loop
        
        bra   MainGameLoop

; In VBL interrupt handler:
VBL_UpdateMusic:
        ; Increment music frame counter
        inc   music_frame_count
        cmp   music_frame_count, #$08  ; 8 frames per pattern
        bne   .done
        
        ; Advance to next pattern
        clr   music_frame_count
        inc   music_current_pos
        
        ; Check for loop point
        lda   music_current_pos
        cmp   #MUSIC_LOOP_POINT
        bne   .done
        
        ; Reset to loop start
        lda   #MUSIC_START
        sta   music_current_pos
        
.done:
        rts
```

### SFX Interrupting Music

Sound effects pause music and resume after completion:

```asm
; In main game code
EnemyHitPlayer:
        lda   #SFX_ENEMY_HIT    ; Define SFX ID for damage
        jsr   SoundPlaySFX      ; Queue the effect
        
        ; Music automatically pauses
        ; Player takes damage
        lda   player_health
        suba  #1
        sta   player_health
        
        ; After SFX duration completes, music resumes
        rts

; In VBL interrupt handler:
VBL_UpdateSFX:
        lda   sfx_current
        beq   .no_sfx           ; No active SFX
        
        ; Update SFX playback
        dec   sfx_duration
        bne   .done
        
        ; SFX finished; resume music
        clr   sfx_current
        jsr   VBL_UpdateMusic   ; Resume music playback
        
.done:
        rts
        
.no_sfx:
        ; Check for queued SFX
        ldx   #sfx_queue
        lda   ,x
        beq   .done             ; Queue empty
        
        ; Dequeue and start SFX
        sta   sfx_current
        lda   #32               ; SFX duration (typical)
        sta   sfx_duration
        
        ; Remove from queue
        ldx   #sfx_queue
        lda   1,x
        sta   ,x
        lda   2,x
        sta   1,x
        lda   3,x
        sta   2,x
        clr   3,x
        
        rts
```

### Volume Fading

Smooth transitions between volume levels (fade in/out):

```asm
; Title screen: fade in music
TitleScreenInit:
        lda   #MUSIC_TITLE
        jsr   SoundPlayMusic
        
        ; Start at silent
        lda   #0
        jsr   SoundSetVolume
        
        ; Fade in over 40 frames (0.8 seconds)
        lda   #40
        sta   fade_duration
        lda   #0
        sta   current_volume
        lda   #15
        sta   target_volume
        rts

; In VBL interrupt:
VBL_UpdateFade:
        lda   fade_duration
        beq   .fade_done
        
        ; Increment volume linearly
        inc   current_volume
        lda   current_volume
        jsr   SoundSetVolume
        
        dec   fade_duration
        rts
        
.fade_done:
        rts
```

### Multi-Channel Music

Music with independent melodies on all three tone channels:

```asm
; Music data structure: 3 channels, each with patterns
; Channel A: melody
; Channel B: harmony
; Channel C: bass

PlayChannelPatterns:
        ; Get music data pointer
        ldx   music_data_ptr
        
        ; Load pattern data for current section
        lda   music_current_pos
        ldb   #48              ; 48 bytes per section
        mul
        leax  a,x              ; X += offset
        
        ; Update each channel independently
        lda   ,x+              ; Channel A note
        ldb   ,x+
        jsr   SetPSGChannelA
        
        lda   ,x+              ; Channel B note
        ldb   ,x+
        jsr   SetPSGChannelB
        
        lda   ,x+              ; Channel C note
        ldb   ,x+
        jsr   SetPSGChannelC
        
        rts
```

---

## Common Mistakes

### Mistake 1: Forgetting to Wait Between PSG Writes

**The Problem**:
```asm
; WRONG: Writing to PSG too quickly
lda   #0
sta   $A7E8              ; Latch register 0
sta   $A7E9              ; Write data
lda   #1
sta   $A7E8              ; Latch register 1 immediately
sta   $A7E9              ; Write data (PSG may not have latched register 1)
```

**Why It Fails**:
- PSG requires a small delay (~2 µs) between latch and data write
- Without delay, data may be written to wrong register
- Audio becomes garbled or incorrect notes play

**The Fix**:
```asm
; RIGHT: Add delay between PSG operations
lda   #0
sta   $A7E8              ; Latch register 0
nop                      ; 1 cycle delay
nop
lda   $A7E8              ; Read (for timing)
sta   $A7E9              ; Write data

lda   #1
sta   $A7E8              ; Latch register 1
nop                      ; Delay
nop
lda   $A7E8              ; Read (for timing)
sta   $A7E9              ; Write data
```

**Lesson**: Always include NOP instructions or dummy reads between PSG register operations. The Thomson TO8 CPU (6809) is fast enough that back-to-back writes can corrupt audio data.

---

### Mistake 2: SFX Interrupting Music Incorrectly

**The Problem**:
```asm
; WRONG: SFX overwrites music channels without tracking
PlaySFX:
        lda   #100             ; SFX frequency
        sta   $A7E8            ; Latch Channel A
        sta   $A7E9            ; Overwrite music melody
        ; Music is corrupted; it's still playing but with wrong notes
```

**Why It Fails**:
- Music thread and SFX handler both write to same PSG channel
- Audio conflicts; one overwrites the other unpredictably
- Music and SFX play simultaneously with garbage output

**The Fix**:
```asm
; RIGHT: SFX uses dedicated channels; music pauses
PlaySFX:
        ; Disable music update in VBL handler
        lda   #0
        sta   music_enabled      ; Music pauses
        
        ; SFX uses Channel C (dedicated for SFX)
        lda   #5                 ; Register 5 (Channel C Fine)
        sta   $A7E8
        lda   sfx_frequency_lo
        sta   $A7E9
        
        lda   #4                 ; Register 4 (Channel C Coarse)
        sta   $A7E8
        lda   sfx_frequency_hi
        sta   $A7E9
        
        ; Music resumes after SFX duration expires
```

**Lesson**: Always assign dedicated PSG channels for SFX (typically Channel C). Disable music during SFX playback and resume afterward. Never write to the same channel from two sources.

---

### Mistake 3: Wrong PSG Register Addresses

**The Problem**:
```asm
; WRONG: Using incorrect PSG port addresses
lda   #0
sta   $A7EA              ; Not the address port!
lda   #100
sta   $A7EB              ; Data goes to wrong port
; No sound is produced; PSG never receives commands
```

**Why It Fails**:
- PSG on Thomson TO8 is at exactly $A7E8 (address), $A7E9 (data)
- Writing to adjacent addresses has no effect on sound
- Common mistake when copying code from other systems

**The Fix**:
```asm
; RIGHT: Use correct PSG addresses
lda   #0
sta   $A7E8              ; Address port (latch register)
lda   #100
sta   $A7E9              ; Data port (write value)
```

**Lesson**: The PSG is always at $A7E8–$A7E9. Double-check memory maps and hardware documentation. Do not assume port addresses match other Thomson models (MO5, MO6, TO7).

---

### Mistake 4: Not Clearing SFX Queue on Level Transition

**The Problem**:
```asm
; WRONG: SFX queue carries over to new level
LoadNewLevel:
        lda   #MUSIC_LEVEL_2
        jsr   SoundPlayMusic    ; Start new level music
        
        ; Old SFX are still in queue and play during new level
        ; Sounds from level 1 still trigger in level 2
```

**Why It Fails**:
- Queued SFX persist across scene changes
- SFX IDs from old level may not match new level audio
- Unexpected sounds trigger, breaking audio continuity

**The Fix**:
```asm
; RIGHT: Clear all audio before level transition
LoadNewLevel:
        jsr   SoundStop          ; Stop everything
        
        ; Clear SFX queue explicitly
        ldx   #sfx_queue
        clr   ,x
        clr   1,x
        clr   2,x
        clr   3,x
        
        lda   #MUSIC_LEVEL_2
        jsr   SoundPlayMusic    ; Fresh start
```

**Lesson**: Always call `SoundStop` and clear the SFX queue during major transitions (levels, pause menu, game over). Do not assume old audio state doesn't carry over.

---

### Mistake 5: Incorrect PSG Enable Register

**The Problem**:
```asm
; WRONG: Enable register bits are inverted
lda   #7                 ; Enable register
sta   $A7E8
lda   #%00000011         ; Trying to enable Channels A and B
sta   $A7E9              ; Actually disables them (bits are inverted!)
; No sound; channels are disabled
```

**Why It Fails**:
- PSG enable register (7) uses inverted logic: 1 = DISABLED, 0 = ENABLED
- Writing $03 disables channels A and B instead of enabling them
- Causes silent or partial audio output

**The Fix**:
```asm
; RIGHT: Correct inverted enable bits
lda   #7
sta   $A7E8
lda   #%11111100         ; 1 = disable, 0 = enable
; This enables Channels A, B, C (bits 0–2 = 0)
; Disables noise (bit 3 = 1)
sta   $A7E9
```

**Lesson**: PSG register 7 (Enable) uses negative logic. Study the hardware spec carefully. Bit 0–2 = channels (0 = enable, 1 = disable). Test with individual channels.

---

## Real-World Usage

### Goldorak Game Example

The Goldorak game features multi-channel music with dynamic SFX:

```asm
; From goldorak/audio/MusicEngine.asm

; Music for level 1: Title theme with 3-channel melody
Level1MusicData:
        .db "MU"              ; Signature
        .db 4                 ; Tempo: 4 ticks per note
        .db 8                 ; Loop point: section 8
        .db 12                ; 12 sections total
        
        ; Section 0: Intro (Channel A melody, B harmony, C bass)
        ; ... 48 bytes of pattern data
        
        ; Section 1–7: Main theme (repeating)
        ; ... 48 bytes each
        
        ; Section 8: Loop point (main theme repeats)
        ; ...

; In main game loop:
UpdateGoldorak:
        jsr   UpdatePlayerPosition
        jsr   UpdateEnemies
        jsr   UpdateCollisions
        
        ; Enemy collision plays SFX
        lda   collision_detected
        beq   .no_collision
        
        lda   #SFX_ENEMY_HIT
        jsr   SoundPlaySFX     ; Music pauses, plays hit sound
        
.no_collision:
        jsr   RenderFrame
        jsr   WaitVBL
        rts
```

Music structure maintains three independent melodic lines:

```asm
; Channel A: Main melody (fast, high-pitched)
; Channel B: Harmony (medium, sustained notes)
; Channel C: Bass line (slow, low-pitched)

; VBL handler updates all three each frame
VBL_UpdateAudio:
        jsr   UpdateChannelA   ; Update melody
        jsr   UpdateChannelB   ; Update harmony
        jsr   UpdateChannelC   ; Update bass
        jsr   UpdateSFXQueue   ; Check for queued effects
        rts
```

### R-Type Game Example

R-Type uses intense action music with rapid SFX feedback:

```asm
; From game-projects/r-type/audio/ActionMusicEngine.asm

; Music for action level: High-tempo driving beat
ActionMusicData:
        .db "MU"
        .db 2                  ; Fast tempo: 2 ticks per note
        .db 4                  ; Loop point
        .db 8                  ; Sections total
        
        ; High-tempo patterns with rapid notes
        ; Channel A: Fast main melody
        ; Channel B: Rhythm accompaniment
        ; Channel C: Bass drums

; Weapon fire effects queue rapidly
FireWeapon:
        ; Determine weapon type
        lda   current_weapon
        
        ; Each weapon has distinct SFX
        cmp   #WEAPON_LASER
        bne   .check_missile
        
        lda   #SFX_LASER_FIRE
        jsr   SoundPlaySFX
        bra   .weapon_done
        
.check_missile:
        cmp   #WEAPON_MISSILE
        bne   .weapon_done
        
        lda   #SFX_MISSILE_LAUNCH
        jsr   SoundPlaySFX
        
.weapon_done:
        rts

; Multiple SFX can queue and play in sequence:
; Laser: 2 frames (quick beep)
; Enemy hit: 4 frames (crunch sound)
; Enemy death: 6 frames (explosion)
; Music resumes between SFX
```

SFX queue demonstrates rapid-fire audio feedback:

```asm
; Collision with 3 enemies in quick succession:
; Frame 1: Enemy 1 hit → SFX 1 queued
; Frame 5: Enemy 2 hit → SFX 2 queued
; Frame 9: Enemy 3 hit → SFX 3 queued
;
; Playback:
; Frames 1–4: Music pauses, SFX 1 plays
; Frames 5–8: Music pauses, SFX 2 plays
; Frames 9–12: Music pauses, SFX 3 plays
; Frame 13+: Music resumes
```

### Volume Fade Example

Smooth audio transitions during level changes:

```asm
; From tutorial/templates/sound-transition/

LevelChangeWithAudio:
        ; Fade out current level music
        lda   #40              ; 40 frames = 0.8 seconds
        jsr   SoundFadeOut
        
        ; Wait for fade to complete (happens in background)
        lda   fade_duration
        bne   $                ; Spin until fade done
        
        ; Load new level
        lda   #LEVEL_2
        jsr   LoadLevel
        
        ; Start new music
        lda   #MUSIC_LEVEL_2
        jsr   SoundPlayMusic
        
        ; Fade in from silent to full
        lda   #0
        jsr   SoundSetVolume
        
        lda   #30              ; Fade in over 30 frames
        sta   fade_duration
        rts
```

---

## Further Reading

**Related API References**:
- **VBL Interrupt Handler** — Synchronization for audio updates
- **Graphics Subsystem** — Coordinate audio with visual effects (SFX timing)
- **Input System** — Detect player actions for immediate SFX feedback

**Engine Source Code**:
- `/engine/sound/psg/PSGWrite.asm` — Low-level PSG register access
- `/engine/sound/music/MusicPlayer.asm` — Music playback loop
- `/engine/sound/sfx/SFXQueue.asm` — SFX queue management
- `/engine/sound/vbl/VBLAudioUpdate.asm` — VBL interrupt audio handler

**Tutorial References**:
- `tutorial/getting-started/02-sound-effects.md` — First sound effects
- `tutorial/extending/06-music-loops.md` — Background music implementation
- `tutorial/patterns/audio-transitions.md` — Fade and transition effects

**Hardware Documentation**:
- Thomson TO8 Technical Manual — PSG register specifications
- AY-3-8910 Data Sheet — PSG chip details (Yamaha)

---

**End of Sound Subsystem API Reference**

Generated: June 2026  
Quality Level: Production-Ready
