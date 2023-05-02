	opt   c,ct
	INCLUDE "./generated-code/scrollscreen/T2/main.glb"
	org   $017F
	setdp $FF

        
@loop
        INCLUDEBIN "./objects/scroll/small-map-indexed.1.0.bin.vscroll"
        jmp   @loop
