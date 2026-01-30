* ==============================================================================
* Memory Test Object - Page 10
* Fill 16KB with value $0A
* ==============================================================================


Page10Data
        fill  $0A,$2000                ; Fill 8KB with value $0A
        fill  $8A,$2000                ; Fill 8KB with value $8A ($0A + $80)
