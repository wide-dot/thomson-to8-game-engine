# zx0-6x09

**zx0-6x09** is a Motorola 6809 and Hitachi 6309 decompressor for the [ZX0](https://github.com/einar-saukas/ZX0) data compression format by Einar Saukas. ZX0 provides a tradeoff between high compression ratio and extremely simple fast decompression.

## Usage

To compress a file, use the command-line compressor from https://github.com/einar-saukas/ZX0.

_**WARNING**: The ZX0 file format was changed in version 2. This library still uses version 1. Execute the ZX0 compressor using the parameter "-c" to compress using version 1 file format._

## Projects using **zx0-6x09**:

* [Defender CoCo 3](http://www.lcurtisboyle.com/nitros9/defender.html) - A conversion of the official Williams Defender game from the arcades for the Tandy Color Computer 3 that stores all compressed data using **ZX0** to fit on two 160K floppy disks. [Repository](https://github.com/nowhereman999/Defender_CoCo3)

* [Joust CoCo 3](http://www.lcurtisboyle.com/nitros9/joust.html) - A port of arcade game Joust for the Tandy Color Computer 3, that stores all compressed data using **ZX0** to fit on a single 160K floppy disk. [Repository](https://github.com/nowhereman999/Joust_CoCo3)
