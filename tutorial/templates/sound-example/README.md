# Sound Example

Minimal code showing how to play music and sound effects on the Thomson TO8.

## What This Does

- Initializes the PSG (Programmable Sound Generator)
- Plays background music
- Triggers sound effects
- Controls volume and frequency

## How to Adapt

1. **Play music**:
   ```asm
   lda #0              ; Music track 0
   jsr PlayMusic
   ```

2. **Play SFX**:
   ```asm
   lda #1              ; SFX index 1
   jsr PlaySFX
   ```

3. **Stop sound**:
   ```asm
   lda #PSG_REG_MIXER
   sta PSG_CTRL
   lda #0              ; Disable all channels
   sta PSG_DATA
   ```

4. **Change pitch**:
   ```asm
   lda #PSG_REG_A_LO   ; Channel A
   ldb #frequency_divider
   jsr SetPSGFrequency
   ```

## Thomson TO8 Sound Hardware

### PSG (YM2149)
- 3 tone channels (A, B, C)
- Noise generator
- Envelope control
- 16 volume levels per channel

### Registers

```
0-1:   Channel A frequency (12-bit)
2-3:   Channel B frequency (12-bit)
4-5:   Channel C frequency (12-bit)
6:     Noise frequency (5-bit)
7:     Mixer control (enable/disable channels)
8-10:  Amplitude (volume) for A, B, C
11-13: Envelope shape registers
```

### Frequency Calculation

```
Frequency = PSG_Clock / (32 * divider)
PSG_Clock = 2 MHz (approx)

divider = 2MHz / (32 * desired_frequency)

Example: 440 Hz = 2MHz / (32 * 142) ≈ 440 Hz
```

## Common Pitches

```
C4: ~262 Hz  (divider ~238)
D4: ~294 Hz  (divider ~212)
E4: ~330 Hz  (divider ~189)
F4: ~349 Hz  (divider ~179)
G4: ~392 Hz  (divider ~159)
A4: ~440 Hz  (divider ~142)
B4: ~494 Hz  (divider ~127)
C5: ~523 Hz  (divider ~119)
```

## Using This Example

### Build
```bash
cd tutorial/templates/sound-example
togen build.properties
```

### Run
```bash
to8 dist/sound.fd
```

## What Happens

- PSG initializes at startup
- Simple tone plays on the first channel
- Control buttons trigger different tones

## Music Integration

For full game music:

1. **Use MOD/SMPS format**:
   - Compose in a tracker (FamiTracker, FTM2ESPS for retro)
   - Convert to SMPS assembly code
   - Include in game

2. **Music Data Structure**:
   ```asm
   MusicTrack0:
       ; List of notes and durations
       fcb Note_C4, Duration_Quarter
       fcb Note_E4, Duration_Quarter
       fcb Note_G4, Duration_Half
   ```

3. **Play in VBL Handler**:
   - Each frame, advance music position
   - Update PSG registers with next note
   - Handle tempo and timing

## Real-World Example

See `game-projects/goldorak/cfg/` for:
- SMPS music data
- Sound effect definitions
- Audio resource organization

See `game-projects/goldorak/global/sound.asm` for:
- Production music player
- SFX queue management
- Envelope handling

## Related Documentation

- `tutorial/api-reference/sound-subsystem.md` — Full sound API
- `tutorial/templates/input-example/` — Reading input for sound tests
- `tutorial/getting-started/` — Integration into full game

## Advanced Topics

### Envelope Control
Use envelope registers to create complex sound shapes (attack, decay, sustain, release).

### Noise Generation
Mix noise with tones for percussion sounds and effects.

### DMA for Music
Use 6844 DMA controller for pre-computed music streams (more polyphonic control).

### Multi-Channel Music
Compose melodies across all 3 channels + noise for richer soundtracks.
