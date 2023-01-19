<!-- Output copied to clipboard! -->

<!-----

Yay, no errors, warnings, or alerts!

Conversion time: 0.49 seconds.


Using this Markdown file:

1. Paste this output into your source file.
2. See the notes and action items below regarding this conversion run.
3. Check the rendered output (headings, lists, code blocks, tables) for proper
   formatting and use a linkchecker before you publish this page.

Conversion notes:

* Docs to Markdown version 1.0β34
* Thu Jan 19 2023 07:13:08 GMT-0800 (PST)
* Source doc: Doc - Sprites
* Tables are currently converted to HTML tables.
----->



## obj.properties


### Assembly code

The sprite is firstly associated to its own assembly code, using the following syntax :


```
code=./objects/enemies/01/bink/obj.asm
```


(The root is the project itself)


### Frames

Each frame of a sprite is to be specified with the following syntax (one line for each frame) : 


```
sprite.Img_bink_0=./objects/enemies/01/bink/images/bink_00.png;NB0,NB1
```


<table>
  <tr>
   <td>

Object
   </td>
   <td>Definition
   </td>
   <td>Description
   </td>
  </tr>
  <tr>
   <td><code>sprite.<strong>Img_bink_0</strong></code>
   </td>
   <td>The sprite name
   </td>
   <td>The object starts with sprite. followed by a chosen name (for example, the sprite name and frame number)
<p>
In the given example, “bink” represents the sprite name, and 0 its frame.
   </td>
  </tr>
  <tr>
   <td><strong><code>./objects/enemies/01/bink/images/bink_00.png</code></strong>
   </td>
   <td>The path to the PNG file
   </td>
   <td>The path is always relative to the project root folder.
   </td>
  </tr>
  <tr>
   <td><strong><code>NB0,NB1</code></strong>
   </td>
   <td>Compilation options
   </td>
   <td>You can define how the engine is going to compile the sprite. You can select multiple options, using a comma in between each.
<p>
First option : 
<ul>

<li>N specifies a “normal” sprite, oriented as you designed it

<li>X specified a horizontal flip of the sprite

<li>Y specifies a vertical flip of the sprite

<li>XY specifies both a horizontal and  vertical flip of the sprite

<p>
Second option : 
<ul>

<li>B (background) specifies that the backgroun of the sprite will need to be saved and restored

<li>D (draw) means that the background does not need to be saved (and restored)

<p>
Third option :  \

<ul>

<li>0 : Create the sprite at position 0

<li>1 : Create the sprite at position 1 (shift by 1 pixel to the right). This is to allow a single pixel movement

<p>
Example : 
<p>
I want my sprite frame to be compiled with the possibility of moving by 1 pixel (hence with 1 shift), with saving of the background and its equivalent with horizontal flipping (mirror) as my sprite can move right or left with a flipped design.
<p>
My sprite options would therefore be : 
<p>
<code>NB0,NB1,XB0,XB1</code>
</li>
</ul>
</li>
</ul>
</li>
</ul>
   </td>
  </tr>
</table>



### Animations

The sequence of animation between a same sprite frames can be specified with the following syntax : 


```
animation.Ani_bink=2;Img_bink_3;Img_bink_2;Img_bink_3;Img_bink_1;_resetAnim
```

<table>
  <tr>
   <td>

Object
   </td>
   <td>Definition
   </td>
   <td>Description
   </td>
  </tr>
  <tr>
   <td><code>sprite.<strong>Ani_bink</strong></code>
   </td>
   <td>Assembly jump point
   </td>
   <td>This defines where, in the assembly code (obj.asm) the sprite will be executed.
   </td>
  </tr>
  <tr>
   <td><strong><code>2</code></strong>
   </td>
   <td>Frame rate
   </td>
   <td>This defines when the sprite is rotated to its next frame : 
<ul>

<li>1 means every game frame

<li>2 means every other game frames

<li>3 means every 3 game frames

<li>… etc …
</li>
</ul>
   </td>
  </tr>
  <tr>
   <td><strong><code>Img_bink_3;Img_bink_2;Img_bink_3;Img_bink_1;_resetAnim</code></strong>
   </td>
   <td>Animation sequence
   </td>
   <td>This specifies the frames order the sprite will be animated.
<p>
Each frame name refers to the frames created (See “Frames” section above) and are separated by a semicolon ;
<p>
The animation is closed by <code>_resetAnim</code>
<p>
(Is there anything like _loopbackAnim or something ?)
   </td>
  </tr>
</table>

