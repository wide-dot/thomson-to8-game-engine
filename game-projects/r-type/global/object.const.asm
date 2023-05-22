; rtype object constant override
; ------------------------------
fireCounter         equ x_acl             ; 2 bytes - var 26
fireDirectionPreset equ y_acl             ; 1 byte  - var 28 - 8bit index (thomson) instead of 16bit address (arcade) (0 means no fire)
fireThreshold       equ y_acl+1           ; 1 byte  - var 2a - 8bit value (thomson) instead of 16bit value (arcade)
fireDisplayDelay    equ routine_secondary ; 1 byte  - var 20 - 8bit value (thomson) instead of 16bit value (arcade)
fireReset           equ routine_tertiary  ; 2 bytes - var 2c
