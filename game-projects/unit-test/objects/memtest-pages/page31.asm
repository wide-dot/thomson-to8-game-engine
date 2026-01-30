* ==============================================================================
* Memory Test Object - Page 31
* Fill 16KB with value $1F
* ==============================================================================


Page31Data
        fill  $1F,$2000                ; Fill 8KB with value $1F
        fill  $9F,$1000                ; Fill 8KB with value $9F ($1F + $80)
