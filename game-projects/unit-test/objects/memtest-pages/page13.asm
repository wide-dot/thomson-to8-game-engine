* ==============================================================================
* Memory Test Object - Page 13
* Fill 16KB with value $0D
* ==============================================================================


Page13Data
        fill  $0D,$2000                ; Fill 8KB with value $0D
        fill  $8D,$2000                ; Fill 8KB with value $8D ($0D + $80)
