pcm2dpcm is a tool from ValleyBell's SMPS research pack

# pcm2dpcm

create raw bin file for thomson (dont forget add BIN header for LOADM TO8 after export with python script split16k.py)

--
### compile pcm2dpcm on macos

    gcc -o DPCM pcm2dpcm.c
    
---
# 1 - Create RAW from WAV/MP3 in audacity

- open your audio file
- ressample in 8000 Hz
- select 8000 Hz output for project
- export format non-compressed > RAW head-less > unsigned 8bit PCM

---

# 2 - Convert audio to dpcm raw bin

Options to encode for DPCM players (values should match @DACDecodeTbl in the players) :

-dpcmdata "000408102030406080FCF8F0E0D0C0A0" -aos 2 test.raw test.bin

test.raw should be encoded in 8bit 16kHz or 8kHz

command :

    ./DPCM -dpcmdata "000408102030406080FCF8F0E0D0C0A0" -aos 2 test.raw test.bin

    ./DPCM -dpcmdata "000408102030406080FCF8F0E0D0C0A0" -aos 2 audio_raw/pacman_beginning-8000.raw audio_bin/pacman_beginning-8000.bin

    ./DPCM -dpcmdata "000408102030406080FCF8F0E0D0C0A0" -aos 2 audio_raw/splashscreen-01-version-LOOP2.raw audio_bin/splashscreen-01-version-LOOP2.bin
    
    ./DPCM -dpcmdata "000408102030406080FCF8F0E0D0C0A0" -aos 2 audio_raw/ALLR.raw audio_bin/ALLR.bin

---
# use split16k.py

Split BIN to multiple 16k Thomson BIN file ready to use in Bentoc audio player routine.

Set dpcm raw binary source file name in `filename` variable inside split16k.py script

	 python split16k.py

It generate multiple OUT[x].BIN files ready to load for Thomson TO8

	filename='audio_bin/dpcm_raw.bin'

---

