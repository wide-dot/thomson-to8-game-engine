* ==============================================================================
* Memory Test Object - Page 27
* Fill 16KB with value $1B
* ==============================================================================


Page27Data
        fill  $1B,$2000                ; Fill 8KB with value $1B
        fill  $9B,$2000                ; Fill 8KB with value $9B ($1B + $80)
