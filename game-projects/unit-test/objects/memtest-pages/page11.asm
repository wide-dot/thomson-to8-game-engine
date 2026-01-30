* ==============================================================================
* Memory Test Object - Page 11
* Fill 16KB with value $0B
* ==============================================================================


Page11Data
        fill  $0B,$2000                ; Fill 8KB with value $0B
        fill  $8B,$2000                ; Fill 8KB with value $8B ($0B + $80)
