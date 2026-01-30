* ==============================================================================
* Memory Test Object - Page 12
* Fill 16KB with value $0C
* ==============================================================================


Page12Data
        fill  $0C,$2000                ; Fill 8KB with value $0C
        fill  $8C,$2000                ; Fill 8KB with value $8C ($0C + $80)
