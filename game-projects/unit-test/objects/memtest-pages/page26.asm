* ==============================================================================
* Memory Test Object - Page 26
* Fill 16KB with value $1A
* ==============================================================================


Page26Data
        fill  $1A,$2000                ; Fill 8KB with value $1A
        fill  $9A,$2000                ; Fill 8KB with value $9A ($1A + $80)
