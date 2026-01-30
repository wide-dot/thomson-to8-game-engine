* ==============================================================================
* Memory Test Object - Page 29
* Fill 16KB with value $1D
* ==============================================================================


Page29Data
        fill  $1D,$2000                ; Fill 8KB with value $1D
        fill  $9D,$2000                ; Fill 8KB with value $9D ($1D + $80)
