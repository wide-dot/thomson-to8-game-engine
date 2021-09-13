# thomson-to8-game-engine
Thomson TO8 game engine (sprites, music, etc.) and its generator written in ASM 6809 and Java.

## How to compile the Java Generator

### Prerequisites

The Java project uses **Java** and **Maven**. You need it to be installed first.

**You need JAVA 11+ and Maven 3.6.x+.**

Check you installation first.

On Linux :

```
$ java -version
openjdk version "11.0.7" 2020-04-14
OpenJDK Runtime Environment GraalVM CE 20.1.0 (build 11.0.7+10-jvmci-20.1-b02)
OpenJDK 64-Bit Server VM GraalVM CE 20.1.0 (build 11.0.7+10-jvmci-20.1-b02, mixed mode, sharing)
```

```
$ mvn -version
Apache Maven 3.6.3 (cecedd343002696d0abb50b32b541b8a6ba2883f)
Maven home: /home/robin/.sdkman/candidates/maven/current
Java version: 11.0.7, vendor: GraalVM Community, runtime: /home/robin/.sdkman/candidates/java/20.1.0.r11-grl
Default locale: fr_FR, platform encoding: UTF-8
OS name: "linux", version: "5.4.0-81-generic", arch: "amd64", family: "unix"
```

*The MAVEN and the JDK versions can vary depending on your current setup.*



### Compiling and building the exectable JAR

```
$ cd java-generator
$ mvn clean compile assembly:single
```

Check that a file named `game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar` has been created in
the folder `/java-generator/target/`.

## How to generate a TO8 Game

*The  generator must have been compiled and built before this step*

On Linux :

```
$ cd ./game-projects/TileDemo 
$ mkdir dist /!\ Only if the directory does not exist /!\
$ java -jar ../../java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./config-linux.properties 

...
...

Write Objects to FLOPPY_DISK image ...
Ecriture Disquette en :888 ($0378)
Ecriture Disquette en :3885 ($0F2D)
Ecriture Disquette en :6742 ($1A56)
Ecriture Disquette en :6982 ($1B46)
Ecriture Disquette en :9310 ($245E)
Ecriture Disquette en :11498 ($2CEA)
Ecriture Disquette en :13390 ($344E)
Write Objects to MEGAROM_T2 image ...
Item: RAMLoaderIndex $0100|$01 $17CC T2 ROM 1 $0FF9 $19AB
Item: RAMLoaderIndex $0000|$05 $0396 T2 ROM 1 $19AC $1C64
Item: RAMLoaderIndex $3CE3|$04 $3D7F T2 ROM 1 $1C65 $1D07
Item: RAMLoaderIndex $2000|$04 $3CE3 T2 ROM 1 $1D08 $2817
Item: RAMLoaderIndex $01FE|$04 $2000 T2 ROM 1 $2818 $33E5
		Found solution for page : 1 start: $0000 end: $33E5 non allocated space: 3098 octets
Compile and Write RAM Loader Manager for FLOPPY_DISK ...
	# Compile /home/robin/github/wide-dot/thomson-to8-game-engine/game-projects/TileDemo/GeneratedCode/RAMLoaderManagerFd.asm
Ecriture Disquette en :256 ($0100)
Compile and Write RAM Loader Manager for MEGAROM_T2 ...
Final t2Idx: 7
	# Compile /home/robin/github/wide-dot/thomson-to8-game-engine/game-projects/TileDemo/GeneratedCode/RAMLoaderManagerT2.asm
Compile boot for FLOPPY_DISK ...
	# Compile /home/robin/github/wide-dot/thomson-to8-game-engine/game-projects/TileDemo/GeneratedCode/BootFd.asm
Ecriture Disquette en :0 ($0000)
Write Floppy Disk Image to output file ...
Build done !
Compile boot for MEGAROM_T2 ...
	# Compile /home/robin/github/wide-dot/thomson-to8-game-engine/game-projects/TileDemo/GeneratedCode/BootT2.asm
Ecriture T2 ...
Write Megarom T.2 Image to output file ...
Build done !
Build T2 Loader for SDDRIVE ...
	# Compile /home/robin/github/wide-dot/thomson-to8-game-engine/game-projects/TileDemo/GeneratedCode/BootT2Loader.asm
Ecriture Disquette en :0 ($0000)
Write Megarom T.2 Boot to output file ...
	# Compile /home/robin/github/wide-dot/thomson-to8-game-engine/game-projects/TileDemo/GeneratedCode/T2Loader.asm
Ecriture Disquette en :256 ($0100)
Write Megarom T.2 Loader to output file ...
Ecriture ROM sur disquette.
Write Megarom T.2 Data to output file ...
Build done !


```

Check that the runnable program is generated in various format inside the `dist` folder.

```
$ ll dist
total 9096
drwxrwxr-x 2 robin robin    4096 sept. 13 10:35 ./
drwxrwxr-x 7 robin robin    4096 sept. 13 10:57 ../
-rw-rw-r-- 1 robin robin  655360 sept. 13 10:35 TileDemo.fd
-rw-rw-r-- 1 robin robin 2097152 sept. 13 10:35 TileDemo.rom
-rw-rw-r-- 1 robin robin 1310720 sept. 13 10:35 TileDemo.sd
-rw-rw-r-- 1 robin robin 5242880 sept. 13 10:35 TileDemo_T2Loader.sd
```

Now you can run your program on your prefered emulator or a real Thomson TO8 computer.



