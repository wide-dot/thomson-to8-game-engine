#!/usr/local/bin/php
<?php

$dir = "./generated-code/text";

$output = "";

if ($handle = opendir($dir)) {

    while (false !== ($entry = readdir($handle))) {
        if (
            (pathinfo($dir."/".$entry, PATHINFO_EXTENSION) == "asm")
            && (strpos($entry, "ImageSet") === false) 
            && (strpos($entry, "Animation") === false) 
            && (strpos($entry, "merged_code.asm") === false) 
            ){
                echo $entry."\n";
                $mycode = "";
                $start = false;
                $spritename = "";
                $asmfile = fopen ($dir."/".$entry,"r");
                while (($buffer = fgets($asmfile, 4096)) !== false) {
                    if (strpos($buffer, "DRAW_text_") !== false) {
                        $start=true;
                        $output .= substr($buffer,0,-3)."\r\n";
                        $output .= "        pshs u\r\n";
                    } else if ($start) {
                        $buffer = str_replace ("LDU <glb_screen_location_1","LEAU -$2000,U",$buffer);
                        $buffer = str_replace ("RTS","puls u,pc",$buffer);
                        $output .= $buffer;
                    }
                }

                fclose ($asmfile);
        }
    }
}

closedir ($handle);

$handle = fopen ($dir."/merged_code.asm","w");
fputs($handle,$output);
fclose ($handle);



?>