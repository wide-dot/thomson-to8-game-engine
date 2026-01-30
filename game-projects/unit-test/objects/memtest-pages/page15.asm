* ==============================================================================
* Memory Test Object - Page 15
* Fill 16KB with value $0F
* ==============================================================================


Page15Data
        fill  $0F,$2000                ; Fill 8KB with value $0F
        fill  $8F,$2000                ; Fill 8KB with value $8F ($0F + $80)
