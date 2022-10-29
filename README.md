# thomson-to8-game-engine
Thomson TO8 game engine (sprites, music, etc.) and its generator written in ASM 6809 and Java.

## How to compile the Java Generator

### Prerequisites

The Java project uses **Java** and **Maven**. You need it to be installed first.

**You need JAVA 11+ and Maven 3.6.x+.**

Check your installation first.

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



### Compiling and building the executable JAR

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
$ cd ./game-projects/sonic-2
$ java -jar ../../java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./s2-EHZ-halfline2-linux.properties

...
...

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
-rw-rw-r-- 1 robin robin  655360 sept. 13 10:35 sonic-2.fd
-rw-rw-r-- 1 robin robin 2097152 sept. 13 10:35 sonic-2.rom
-rw-rw-r-- 1 robin robin 1310720 sept. 13 10:35 sonic-2.sd
-rw-rw-r-- 1 robin robin 5242880 sept. 13 10:35 sonic-2_t2_flash.sd
```

Now you can run your program on your prefered emulator or a real Thomson TO8 computer.



