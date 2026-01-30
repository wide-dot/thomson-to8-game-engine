* ==============================================================================
* Memory Test Object - Page 30
* Fill 16KB with value $1E
* ==============================================================================


Page30Data
        fill  $1E,$2000                ; Fill 8KB with value $1E
        fill  $9E,$2000                ; Fill 8KB with value $9E ($1E + $80)
