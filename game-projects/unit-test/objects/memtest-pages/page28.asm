* ==============================================================================
* Memory Test Object - Page 28
* Fill 16KB with value $1C
* ==============================================================================


Page28Data
        fill  $1C,$2000                ; Fill 8KB with value $1C
        fill  $9C,$2000                ; Fill 8KB with value $9C ($1C + $80)
