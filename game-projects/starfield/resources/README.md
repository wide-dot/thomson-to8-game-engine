# starfield — music assets

Track: **"Aleste"** — main theme of *Power Strike / Aleste* (Compile, 1988,
Sega Master System). Rips from [SMS Power!](https://www.smspower.org/Music/VGMs).

## Why two source VGMs for one tune

A Master System **muted its SN76489 PSG when the FM Sound Unit was fitted** —
the two chips carry different arrangements and never played together on real
hardware. So no single commercial rip contains both, and SMS Power publishes
them as separate packs:

| file | pack | chip | writes |
|---|---|---|---|
| `aleste-01-psg.vgm` | `PowerStrike-SMS-PSG` | SN76489 | PSG only |
| `aleste-01-fm.vgm`  | `PowerStrike-SMS-FM`  | YM2413  | 2824 FM vs 11 PSG |

Goldorak's single dual-chip VGM is not a counter-example: it was *composed*
that way in DefleMask targeting SMS+FM, not ripped.

Download pattern (the `-e` referer is required, else HTTP 500):

    curl -L -e "https://www.smspower.org/Music/PowerStrike-SMS-FM" \
      https://www.smspower.org/uploads/Music/PowerStrike-SMS-FM.zip -o fm.zip

Note: SMS Power `.vgm` files are **gzipped despite the extension** (magic
`1f 8b`). The converters cope; homemade scripts must gunzip first.

## Regenerating the binaries

Tools live in the sibling repo `6809-game-builder` (build them once with
`mvn package -pl toolbox/audio/vgm2vgc,toolbox/audio/vgm2ymm -am -DskipTests`;
`-o` offline fails, it needs the network for `plexus-archiver`).

The generated `bin/unix/*` launchers are broken — `BASEDIR=$PRGDIR/..` resolves
to `bin/`, so they look for a nonexistent `bin/repo`. Invoke the classes
directly:

    cd ../../../6809-game-builder      # adjust to taste
    R=repo
    CP="$R/com/wide-dot/vgm2vgc/0.0.1/vgm2vgc-0.0.1.jar:\
    $R/com/wide-dot/vgm2ymm/0.0.1/vgm2ymm-0.0.1.jar:\
    $R/info/picocli/picocli/4.7.7/picocli-4.7.7.jar:\
    $R/com/wide-dot/6809-gamebuilder-util/0.0.1/6809-gamebuilder-util-0.0.1.jar:\
    $R/org/python/jython-standalone/2.7.3/jython-standalone-2.7.3.jar:\
    $R/org/apache/commons/commons-lang3/3.20.0/commons-lang3-3.20.0.jar:\
    $R/commons-io/commons-io/2.22.0/commons-io-2.22.0.jar:\
    $R/ch/qos/logback/logback-classic/1.5.3/logback-classic-1.5.3.jar:\
    $R/ch/qos/logback/logback-core/1.5.3/logback-core-1.5.3.jar:\
    $R/org/slf4j/slf4j-api/2.0.12/slf4j-api-2.0.12.jar"

    java -cp "$CP" com.widedot.toolbox.audio.vgm2vgc.MainCommand \
      -f resources/aleste-01-psg.vgm -g objects/music/starfield/aleste-SN76489.vgc

    java -cp "$CP" com.widedot.toolbox.audio.vgm2ymm.MainCommand \
      -f resources/aleste-01-fm.vgm -g objects/music/starfield/aleste-YM2413.ymm.zx0 -c zx0

`vgm2vgc` needs the `0x70`-`0x7F` ("wait n+1 samples") case in
`VGMInterpreter.java` — absent from upstream, added locally. Without it any
NTSC-authored VGM dies on `Unknown VGM command`.

## Vetting a candidate VGM before converting

Only the SN76489 and YM2413 are supported (`engine/system/to8/memory-map.equ`).
A **Mega Drive** VGM is useless: its music is YM2612, which nothing here plays.
Check the header clocks first:

    python3 -c "
    import struct,sys,gzip
    d=open(sys.argv[1],'rb').read()
    if d[:2]==b'\x1f\x8b': d=gzip.decompress(d)
    sn,ym13,ym12=[struct.unpack_from('<I',d,o)[0] for o in (0x0C,0x10,0x2C)]
    print('SN76489',sn,'YM2413',ym13,'YM2612',ym12)
    print('Mega Drive -> unusable' if ym12 else 'SMS -> OK')" file.vgm

The two earlier starfield tracks tried here are the counter-example, and are not
committed: both were Mega Drive exports (YM2612 = 7670965 / 7670453, YM2413 = 0).
v2 yielded a thin PSG-only `.vgc` from its 3472 stray PSG writes; v1's 22 writes
yielded silence. Neither could produce a `.ymm`.
