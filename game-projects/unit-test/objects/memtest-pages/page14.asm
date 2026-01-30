* ==============================================================================
* Memory Test Object - Page 14
* Fill 16KB with value $0E
* ==============================================================================


Page14Data
        fill  $0E,$2000                ; Fill 8KB with value $0E
        fill  $8E,$2000                ; Fill 8KB with value $8E ($0E + $80)
