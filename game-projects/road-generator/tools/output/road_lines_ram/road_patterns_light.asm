 opt c
; ========================================================================
; Road RAM v4 — pattern bank light @ $4000
; Structure identique dark/light, valeurs uniquement diffèrent.
; ========================================================================
        ORG   $4000

* ─── Stub pshu (palette-agnostique, dupliqué 2 banks) ───
Road_pshu_dx
        pshu  d,x
        rts

* ─── 246 routines ld (light) ───
* uses=4  D=$7333 X=$3333
Road_R00000
        ldd   #$7333
        ldx   #$3333
        pshu  d,x
        rts
* uses=4  D=$3333 X=$3337
Road_R00001
        ldd   #$3333
        ldx   #$3337
        pshu  d,x
        rts
* uses=1  D=$7733 X=$3333
Road_R00002
        ldd   #$7733
        ldx   #$3333
        pshu  d,x
        rts
* uses=1  D=$3333 X=$3377
Road_R00003
        ldd   #$3333
        ldx   #$3377
        pshu  d,x
        rts
* uses=6  D=$7533 X=$3333
Road_R00004
        ldd   #$7533
        ldx   #$3333
        pshu  d,x
        rts
* uses=1  D=$3333 X=$3335
Road_R00005
        ldd   #$3333
        ldx   #$3335
        pshu  d,x
        rts
* uses=1  D=$5333 X=$3333
Road_R00006
        ldd   #$5333
        ldx   #$3333
        pshu  d,x
        rts
* uses=6  D=$3333 X=$3357
Road_R00007
        ldd   #$3333
        ldx   #$3357
        pshu  d,x
        rts
* uses=52  D=$1333 X=$3333
Road_R00008
        ldd   #$1333
        ldx   #$3333
        pshu  d,x
        rts
* uses=15  D=$3333 X=$3315
Road_R00009
        ldd   #$3333
        ldx   #$3315
        pshu  d,x
        rts
* uses=15  D=$5133 X=$3333
Road_R00010
        ldd   #$5133
        ldx   #$3333
        pshu  d,x
        rts
* uses=52  D=$3333 X=$3331
Road_R00011
        ldd   #$3333
        ldx   #$3331
        pshu  d,x
        rts
* uses=6  D=$3333 X=$3375
Road_R00012
        ldd   #$3333
        ldx   #$3375
        pshu  d,x
        rts
* uses=6  D=$5733 X=$3333
Road_R00013
        ldd   #$5733
        ldx   #$3333
        pshu  d,x
        rts
* uses=19  D=$3333 X=$3355
Road_R00014
        ldd   #$3333
        ldx   #$3355
        pshu  d,x
        rts
* uses=19  D=$5533 X=$3333
Road_R00015
        ldd   #$5533
        ldx   #$3333
        pshu  d,x
        rts
* uses=9  D=$7513 X=$3333
Road_R00016
        ldd   #$7513
        ldx   #$3333
        pshu  d,x
        rts
* uses=9  D=$3333 X=$3157
Road_R00017
        ldd   #$3333
        ldx   #$3157
        pshu  d,x
        rts
* uses=1  D=$7573 X=$3333
Road_R00018
        ldd   #$7573
        ldx   #$3333
        pshu  d,x
        rts
* uses=1  D=$3333 X=$3757
Road_R00019
        ldd   #$3333
        ldx   #$3757
        pshu  d,x
        rts
* uses=1  D=$7551 X=$3333
Road_R00020
        ldd   #$7551
        ldx   #$3333
        pshu  d,x
        rts
* uses=11  D=$3333 X=$3155
Road_R00021
        ldd   #$3333
        ldx   #$3155
        pshu  d,x
        rts
* uses=11  D=$5513 X=$3333
Road_R00022
        ldd   #$5513
        ldx   #$3333
        pshu  d,x
        rts
* uses=1  D=$3333 X=$1557
Road_R00023
        ldd   #$3333
        ldx   #$1557
        pshu  d,x
        rts
* uses=4  D=$7555 X=$3333
Road_R00024
        ldd   #$7555
        ldx   #$3333
        pshu  d,x
        rts
* uses=1  D=$3333 X=$3555
Road_R00025
        ldd   #$3333
        ldx   #$3555
        pshu  d,x
        rts
* uses=1  D=$5553 X=$3333
Road_R00026
        ldd   #$5553
        ldx   #$3333
        pshu  d,x
        rts
* uses=4  D=$3333 X=$5557
Road_R00027
        ldd   #$3333
        ldx   #$5557
        pshu  d,x
        rts
* uses=1  D=$7557 X=$3333
Road_R00028
        ldd   #$7557
        ldx   #$3333
        pshu  d,x
        rts
* uses=5  D=$3333 X=$1755
Road_R00029
        ldd   #$3333
        ldx   #$1755
        pshu  d,x
        rts
* uses=5  D=$5571 X=$3333
Road_R00030
        ldd   #$5571
        ldx   #$3333
        pshu  d,x
        rts
* uses=1  D=$3333 X=$7557
Road_R00031
        ldd   #$3333
        ldx   #$7557
        pshu  d,x
        rts
* uses=2  D=$5713 X=$3333
Road_R00032
        ldd   #$5713
        ldx   #$3333
        pshu  d,x
        rts
* uses=11  D=$3333 X=$1555
Road_R00033
        ldd   #$3333
        ldx   #$1555
        pshu  d,x
        rts
* uses=11  D=$5551 X=$3333
Road_R00034
        ldd   #$5551
        ldx   #$3333
        pshu  d,x
        rts
* uses=2  D=$3333 X=$3175
Road_R00035
        ldd   #$3333
        ldx   #$3175
        pshu  d,x
        rts
* uses=2  D=$5751 X=$3333
Road_R00036
        ldd   #$5751
        ldx   #$3333
        pshu  d,x
        rts
* uses=9  D=$3333 X=$5555
Road_R00037
        ldd   #$3333
        ldx   #$5555
        pshu  d,x
        rts
* uses=9  D=$5555 X=$3333
Road_R00038
        ldd   #$5555
        ldx   #$3333
        pshu  d,x
        rts
* uses=2  D=$3333 X=$1575
Road_R00039
        ldd   #$3333
        ldx   #$1575
        pshu  d,x
        rts
* uses=2  D=$7555 X=$1333
Road_R00040
        ldd   #$7555
        ldx   #$1333
        pshu  d,x
        rts
* uses=30  D=$3333 X=$1155
Road_R00041
        ldd   #$3333
        ldx   #$1155
        pshu  d,x
        rts
* uses=30  D=$5511 X=$3333
Road_R00042
        ldd   #$5511
        ldx   #$3333
        pshu  d,x
        rts
* uses=2  D=$3331 X=$5557
Road_R00043
        ldd   #$3331
        ldx   #$5557
        pshu  d,x
        rts
* uses=2  D=$5557 X=$3333
Road_R00044
        ldd   #$5557
        ldx   #$3333
        pshu  d,x
        rts
* uses=2  D=$3333 X=$7555
Road_R00045
        ldd   #$3333
        ldx   #$7555
        pshu  d,x
        rts
* uses=1  D=$7575 X=$1133
Road_R00046
        ldd   #$7575
        ldx   #$1133
        pshu  d,x
        rts
* uses=7  D=$3331 X=$5555
Road_R00047
        ldd   #$3331
        ldx   #$5555
        pshu  d,x
        rts
* uses=7  D=$5555 X=$1333
Road_R00048
        ldd   #$5555
        ldx   #$1333
        pshu  d,x
        rts
* uses=1  D=$3311 X=$5757
Road_R00049
        ldd   #$3311
        ldx   #$5757
        pshu  d,x
        rts
* uses=1  D=$7575 X=$5133
Road_R00050
        ldd   #$7575
        ldx   #$5133
        pshu  d,x
        rts
* uses=1  D=$3333 X=$5575
Road_R00051
        ldd   #$3333
        ldx   #$5575
        pshu  d,x
        rts
* uses=1  D=$5755 X=$3333
Road_R00052
        ldd   #$5755
        ldx   #$3333
        pshu  d,x
        rts
* uses=1  D=$3315 X=$5757
Road_R00053
        ldd   #$3315
        ldx   #$5757
        pshu  d,x
        rts
* uses=1  D=$7555 X=$7133
Road_R00054
        ldd   #$7555
        ldx   #$7133
        pshu  d,x
        rts
* uses=1  D=$3317 X=$5557
Road_R00055
        ldd   #$3317
        ldx   #$5557
        pshu  d,x
        rts
* uses=172  D=$5555 X=$7555
Road_R00056
        ldd   #$5555
        ldx   #$7555
        pshu  d,x
        rts
* uses=2881  D=$5555 X=$5555
Road_R00057
        ldd   #$5555
        ldx   #$5555
        pshu  d,x
        rts
* uses=140  D=$3333 X=$3311
Road_R00058
        ldd   #$3333
        ldx   #$3311
        pshu  d,x
        rts
* uses=140  D=$1133 X=$3333
Road_R00059
        ldd   #$1133
        ldx   #$3333
        pshu  d,x
        rts
* uses=172  D=$5557 X=$5555
Road_R00060
        ldd   #$5557
        ldx   #$5555
        pshu  d,x
        rts
* uses=2  D=$5555 X=$7557
Road_R00061
        ldd   #$5555
        ldx   #$7557
        pshu  d,x
        rts
* uses=69  D=$5755 X=$5555
Road_R00062
        ldd   #$5755
        ldx   #$5555
        pshu  d,x
        rts
* uses=4  D=$3333 X=$3317
Road_R00063
        ldd   #$3333
        ldx   #$3317
        pshu  d,x
        rts
* uses=4  D=$7133 X=$3333
Road_R00064
        ldd   #$7133
        ldx   #$3333
        pshu  d,x
        rts
* uses=69  D=$5555 X=$5575
Road_R00065
        ldd   #$5555
        ldx   #$5575
        pshu  d,x
        rts
* uses=2  D=$7557 X=$5555
Road_R00066
        ldd   #$7557
        ldx   #$5555
        pshu  d,x
        rts
* uses=9  D=$7555 X=$5575
Road_R00067
        ldd   #$7555
        ldx   #$5575
        pshu  d,x
        rts
* uses=9  D=$5755 X=$5557
Road_R00068
        ldd   #$5755
        ldx   #$5557
        pshu  d,x
        rts
* uses=5  D=$5557 X=$1333
Road_R00069
        ldd   #$5557
        ldx   #$1333
        pshu  d,x
        rts
* uses=3  D=$5755 X=$7555
Road_R00070
        ldd   #$5755
        ldx   #$7555
        pshu  d,x
        rts
* uses=235  D=$5555 X=$5557
Road_R00071
        ldd   #$5555
        ldx   #$5557
        pshu  d,x
        rts
* uses=235  D=$7555 X=$5555
Road_R00072
        ldd   #$7555
        ldx   #$5555
        pshu  d,x
        rts
* uses=3  D=$5557 X=$5575
Road_R00073
        ldd   #$5557
        ldx   #$5575
        pshu  d,x
        rts
* uses=5  D=$3331 X=$7555
Road_R00074
        ldd   #$3331
        ldx   #$7555
        pshu  d,x
        rts
* uses=20  D=$5555 X=$1133
Road_R00075
        ldd   #$5555
        ldx   #$1133
        pshu  d,x
        rts
* uses=20  D=$3311 X=$5555
Road_R00076
        ldd   #$3311
        ldx   #$5555
        pshu  d,x
        rts
* uses=2  D=$5575 X=$3333
Road_R00077
        ldd   #$5575
        ldx   #$3333
        pshu  d,x
        rts
* uses=2  D=$3333 X=$5755
Road_R00078
        ldd   #$3333
        ldx   #$5755
        pshu  d,x
        rts
* uses=2  D=$7555 X=$1133
Road_R00079
        ldd   #$7555
        ldx   #$1133
        pshu  d,x
        rts
* uses=4  D=$7555 X=$7555
Road_R00080
        ldd   #$7555
        ldx   #$7555
        pshu  d,x
        rts
* uses=4  D=$5557 X=$5557
Road_R00081
        ldd   #$5557
        ldx   #$5557
        pshu  d,x
        rts
* uses=2  D=$3311 X=$5557
Road_R00082
        ldd   #$3311
        ldx   #$5557
        pshu  d,x
        rts
* uses=2  D=$7555 X=$5133
Road_R00083
        ldd   #$7555
        ldx   #$5133
        pshu  d,x
        rts
* uses=2  D=$3315 X=$5557
Road_R00084
        ldd   #$3315
        ldx   #$5557
        pshu  d,x
        rts
* uses=1  D=$5555 X=$7133
Road_R00085
        ldd   #$5555
        ldx   #$7133
        pshu  d,x
        rts
* uses=1  D=$3317 X=$5555
Road_R00086
        ldd   #$3317
        ldx   #$5555
        pshu  d,x
        rts
* uses=4  D=$7555 X=$5755
Road_R00087
        ldd   #$7555
        ldx   #$5755
        pshu  d,x
        rts
* uses=4  D=$5575 X=$5557
Road_R00088
        ldd   #$5575
        ldx   #$5557
        pshu  d,x
        rts
* uses=13  D=$5711 X=$3333
Road_R00089
        ldd   #$5711
        ldx   #$3333
        pshu  d,x
        rts
* uses=13  D=$3333 X=$1175
Road_R00090
        ldd   #$3333
        ldx   #$1175
        pshu  d,x
        rts
* uses=84  D=$5575 X=$5555
Road_R00091
        ldd   #$5575
        ldx   #$5555
        pshu  d,x
        rts
* uses=84  D=$5555 X=$5755
Road_R00092
        ldd   #$5555
        ldx   #$5755
        pshu  d,x
        rts
* uses=2  D=$3333 X=$3115
Road_R00093
        ldd   #$3333
        ldx   #$3115
        pshu  d,x
        rts
* uses=2  D=$5113 X=$3333
Road_R00094
        ldd   #$5113
        ldx   #$3333
        pshu  d,x
        rts
* uses=9  D=$5551 X=$1333
Road_R00095
        ldd   #$5551
        ldx   #$1333
        pshu  d,x
        rts
* uses=13  D=$3333 X=$1157
Road_R00096
        ldd   #$3333
        ldx   #$1157
        pshu  d,x
        rts
* uses=13  D=$7511 X=$3333
Road_R00097
        ldd   #$7511
        ldx   #$3333
        pshu  d,x
        rts
* uses=9  D=$3331 X=$1555
Road_R00098
        ldd   #$3331
        ldx   #$1555
        pshu  d,x
        rts
* uses=20  D=$5575 X=$1133
Road_R00099
        ldd   #$5575
        ldx   #$1133
        pshu  d,x
        rts
* uses=20  D=$3311 X=$5755
Road_R00100
        ldd   #$3311
        ldx   #$5755
        pshu  d,x
        rts
* uses=9  D=$5557 X=$1133
Road_R00101
        ldd   #$5557
        ldx   #$1133
        pshu  d,x
        rts
* uses=9  D=$3311 X=$7555
Road_R00102
        ldd   #$3311
        ldx   #$7555
        pshu  d,x
        rts
* uses=3  D=$5555 X=$5113
Road_R00103
        ldd   #$5555
        ldx   #$5113
        pshu  d,x
        rts
* uses=2  D=$5577 X=$1133
Road_R00104
        ldd   #$5577
        ldx   #$1133
        pshu  d,x
        rts
* uses=2  D=$3311 X=$7755
Road_R00105
        ldd   #$3311
        ldx   #$7755
        pshu  d,x
        rts
* uses=3  D=$3115 X=$5555
Road_R00106
        ldd   #$3115
        ldx   #$5555
        pshu  d,x
        rts
* uses=9  D=$5555 X=$5111
Road_R00107
        ldd   #$5555
        ldx   #$5111
        pshu  d,x
        rts
* uses=6  D=$3111 X=$5555
Road_R00108
        ldd   #$3111
        ldx   #$5555
        pshu  d,x
        rts
* uses=6  D=$5555 X=$1113
Road_R00109
        ldd   #$5555
        ldx   #$1113
        pshu  d,x
        rts
* uses=9  D=$1115 X=$5555
Road_R00110
        ldd   #$1115
        ldx   #$5555
        pshu  d,x
        rts
* uses=10  D=$5555 X=$7511
Road_R00111
        ldd   #$5555
        ldx   #$7511
        pshu  d,x
        rts
* uses=2  D=$7555 X=$5557
Road_R00112
        ldd   #$7555
        ldx   #$5557
        pshu  d,x
        rts
* uses=10  D=$1157 X=$5555
Road_R00113
        ldd   #$1157
        ldx   #$5555
        pshu  d,x
        rts
* uses=43  D=$1113 X=$3333
Road_R00114
        ldd   #$1113
        ldx   #$3333
        pshu  d,x
        rts
* uses=13  D=$3333 X=$1115
Road_R00115
        ldd   #$3333
        ldx   #$1115
        pshu  d,x
        rts
* uses=13  D=$5111 X=$3333
Road_R00116
        ldd   #$5111
        ldx   #$3333
        pshu  d,x
        rts
* uses=43  D=$3333 X=$3111
Road_R00117
        ldd   #$3333
        ldx   #$3111
        pshu  d,x
        rts
* uses=3  D=$7711 X=$3333
Road_R00118
        ldd   #$7711
        ldx   #$3333
        pshu  d,x
        rts
* uses=3  D=$3333 X=$1177
Road_R00119
        ldd   #$3333
        ldx   #$1177
        pshu  d,x
        rts
* uses=249  D=$5555 X=$7755
Road_R00120
        ldd   #$5555
        ldx   #$7755
        pshu  d,x
        rts
* uses=249  D=$5577 X=$5555
Road_R00121
        ldd   #$5577
        ldx   #$5555
        pshu  d,x
        rts
* uses=7  D=$5511 X=$1333
Road_R00122
        ldd   #$5511
        ldx   #$1333
        pshu  d,x
        rts
* uses=7  D=$3331 X=$1155
Road_R00123
        ldd   #$3331
        ldx   #$1155
        pshu  d,x
        rts
* uses=17  D=$5551 X=$1133
Road_R00124
        ldd   #$5551
        ldx   #$1133
        pshu  d,x
        rts
* uses=5  D=$3331 X=$1175
Road_R00125
        ldd   #$3331
        ldx   #$1175
        pshu  d,x
        rts
* uses=5  D=$5711 X=$1333
Road_R00126
        ldd   #$5711
        ldx   #$1333
        pshu  d,x
        rts
* uses=17  D=$3311 X=$1555
Road_R00127
        ldd   #$3311
        ldx   #$1555
        pshu  d,x
        rts
* uses=15  D=$5511 X=$1133
Road_R00128
        ldd   #$5511
        ldx   #$1133
        pshu  d,x
        rts
* uses=15  D=$3311 X=$1155
Road_R00129
        ldd   #$3311
        ldx   #$1155
        pshu  d,x
        rts
* uses=5  D=$5557 X=$1113
Road_R00130
        ldd   #$5557
        ldx   #$1113
        pshu  d,x
        rts
* uses=5  D=$3111 X=$7555
Road_R00131
        ldd   #$3111
        ldx   #$7555
        pshu  d,x
        rts
* uses=8  D=$5557 X=$1111
Road_R00132
        ldd   #$5557
        ldx   #$1111
        pshu  d,x
        rts
* uses=3  D=$3111 X=$7755
Road_R00133
        ldd   #$3111
        ldx   #$7755
        pshu  d,x
        rts
* uses=3  D=$5577 X=$1113
Road_R00134
        ldd   #$5577
        ldx   #$1113
        pshu  d,x
        rts
* uses=8  D=$1111 X=$7555
Road_R00135
        ldd   #$1111
        ldx   #$7555
        pshu  d,x
        rts
* uses=9  D=$5555 X=$5511
Road_R00136
        ldd   #$5555
        ldx   #$5511
        pshu  d,x
        rts
* uses=9  D=$1155 X=$5555
Road_R00137
        ldd   #$1155
        ldx   #$5555
        pshu  d,x
        rts
* uses=4  D=$3111 X=$5755
Road_R00138
        ldd   #$3111
        ldx   #$5755
        pshu  d,x
        rts
* uses=4  D=$5575 X=$1113
Road_R00139
        ldd   #$5575
        ldx   #$1113
        pshu  d,x
        rts
* uses=6  D=$7511 X=$1333
Road_R00140
        ldd   #$7511
        ldx   #$1333
        pshu  d,x
        rts
* uses=115  D=$3333 X=$1111
Road_R00141
        ldd   #$3333
        ldx   #$1111
        pshu  d,x
        rts
* uses=115  D=$1111 X=$3333
Road_R00142
        ldd   #$1111
        ldx   #$3333
        pshu  d,x
        rts
* uses=6  D=$3331 X=$1157
Road_R00143
        ldd   #$3331
        ldx   #$1157
        pshu  d,x
        rts
* uses=3  D=$7711 X=$1333
Road_R00144
        ldd   #$7711
        ldx   #$1333
        pshu  d,x
        rts
* uses=253  D=$5555 X=$5577
Road_R00145
        ldd   #$5555
        ldx   #$5577
        pshu  d,x
        rts
* uses=253  D=$7755 X=$5555
Road_R00146
        ldd   #$7755
        ldx   #$5555
        pshu  d,x
        rts
* uses=3  D=$3331 X=$1177
Road_R00147
        ldd   #$3331
        ldx   #$1177
        pshu  d,x
        rts
* uses=10  D=$5711 X=$1133
Road_R00148
        ldd   #$5711
        ldx   #$1133
        pshu  d,x
        rts
* uses=10  D=$3311 X=$1175
Road_R00149
        ldd   #$3311
        ldx   #$1175
        pshu  d,x
        rts
* uses=12  D=$7711 X=$1133
Road_R00150
        ldd   #$7711
        ldx   #$1133
        pshu  d,x
        rts
* uses=4  D=$3311 X=$1575
Road_R00151
        ldd   #$3311
        ldx   #$1575
        pshu  d,x
        rts
* uses=4  D=$5751 X=$1133
Road_R00152
        ldd   #$5751
        ldx   #$1133
        pshu  d,x
        rts
* uses=12  D=$3311 X=$1177
Road_R00153
        ldd   #$3311
        ldx   #$1177
        pshu  d,x
        rts
* uses=44  D=$5575 X=$1111
Road_R00154
        ldd   #$5575
        ldx   #$1111
        pshu  d,x
        rts
* uses=44  D=$1111 X=$5755
Road_R00155
        ldd   #$1111
        ldx   #$5755
        pshu  d,x
        rts
* uses=22  D=$5577 X=$1111
Road_R00156
        ldd   #$5577
        ldx   #$1111
        pshu  d,x
        rts
* uses=22  D=$1111 X=$7755
Road_R00157
        ldd   #$1111
        ldx   #$7755
        pshu  d,x
        rts
* uses=8  D=$5557 X=$5111
Road_R00158
        ldd   #$5557
        ldx   #$5111
        pshu  d,x
        rts
* uses=8  D=$1115 X=$7555
Road_R00159
        ldd   #$1115
        ldx   #$7555
        pshu  d,x
        rts
* uses=14  D=$7511 X=$1133
Road_R00160
        ldd   #$7511
        ldx   #$1133
        pshu  d,x
        rts
* uses=14  D=$3311 X=$1157
Road_R00161
        ldd   #$3311
        ldx   #$1157
        pshu  d,x
        rts
* uses=2  D=$3331 X=$1115
Road_R00162
        ldd   #$3331
        ldx   #$1115
        pshu  d,x
        rts
* uses=2  D=$5111 X=$1333
Road_R00163
        ldd   #$5111
        ldx   #$1333
        pshu  d,x
        rts
* uses=6  D=$5751 X=$1113
Road_R00164
        ldd   #$5751
        ldx   #$1113
        pshu  d,x
        rts
* uses=6  D=$3111 X=$1575
Road_R00165
        ldd   #$3111
        ldx   #$1575
        pshu  d,x
        rts
* uses=1  D=$5551 X=$1113
Road_R00166
        ldd   #$5551
        ldx   #$1113
        pshu  d,x
        rts
* uses=1  D=$3111 X=$1555
Road_R00167
        ldd   #$3111
        ldx   #$1555
        pshu  d,x
        rts
* uses=17  D=$5555 X=$1111
Road_R00168
        ldd   #$5555
        ldx   #$1111
        pshu  d,x
        rts
* uses=17  D=$1111 X=$5555
Road_R00169
        ldd   #$1111
        ldx   #$5555
        pshu  d,x
        rts
* uses=1  D=$3111 X=$1577
Road_R00170
        ldd   #$3111
        ldx   #$1577
        pshu  d,x
        rts
* uses=36  D=$5755 X=$1111
Road_R00171
        ldd   #$5755
        ldx   #$1111
        pshu  d,x
        rts
* uses=36  D=$1111 X=$5575
Road_R00172
        ldd   #$1111
        ldx   #$5575
        pshu  d,x
        rts
* uses=1  D=$7751 X=$1113
Road_R00173
        ldd   #$7751
        ldx   #$1113
        pshu  d,x
        rts
* uses=4  D=$1111 X=$1575
Road_R00174
        ldd   #$1111
        ldx   #$1575
        pshu  d,x
        rts
* uses=4  D=$5751 X=$1111
Road_R00175
        ldd   #$5751
        ldx   #$1111
        pshu  d,x
        rts
* uses=33  D=$5577 X=$5111
Road_R00176
        ldd   #$5577
        ldx   #$5111
        pshu  d,x
        rts
* uses=33  D=$1115 X=$7755
Road_R00177
        ldd   #$1115
        ldx   #$7755
        pshu  d,x
        rts
* uses=19  D=$1155 X=$7555
Road_R00178
        ldd   #$1155
        ldx   #$7555
        pshu  d,x
        rts
* uses=19  D=$5557 X=$5511
Road_R00179
        ldd   #$5557
        ldx   #$5511
        pshu  d,x
        rts
* uses=4  D=$7711 X=$1113
Road_R00180
        ldd   #$7711
        ldx   #$1113
        pshu  d,x
        rts
* uses=4  D=$3311 X=$1115
Road_R00181
        ldd   #$3311
        ldx   #$1115
        pshu  d,x
        rts
* uses=4  D=$5111 X=$1133
Road_R00182
        ldd   #$5111
        ldx   #$1133
        pshu  d,x
        rts
* uses=4  D=$3111 X=$1177
Road_R00183
        ldd   #$3111
        ldx   #$1177
        pshu  d,x
        rts
* uses=34  D=$7751 X=$1111
Road_R00184
        ldd   #$7751
        ldx   #$1111
        pshu  d,x
        rts
* uses=4  D=$3111 X=$1157
Road_R00185
        ldd   #$3111
        ldx   #$1157
        pshu  d,x
        rts
* uses=4  D=$7511 X=$1113
Road_R00186
        ldd   #$7511
        ldx   #$1113
        pshu  d,x
        rts
* uses=34  D=$1111 X=$1577
Road_R00187
        ldd   #$1111
        ldx   #$1577
        pshu  d,x
        rts
* uses=7  D=$1111 X=$1177
Road_R00188
        ldd   #$1111
        ldx   #$1177
        pshu  d,x
        rts
* uses=7  D=$7711 X=$1111
Road_R00189
        ldd   #$7711
        ldx   #$1111
        pshu  d,x
        rts
* uses=23  D=$7511 X=$1111
Road_R00190
        ldd   #$7511
        ldx   #$1111
        pshu  d,x
        rts
* uses=5  D=$3111 X=$1155
Road_R00191
        ldd   #$3111
        ldx   #$1155
        pshu  d,x
        rts
* uses=5  D=$5511 X=$1113
Road_R00192
        ldd   #$5511
        ldx   #$1113
        pshu  d,x
        rts
* uses=23  D=$1111 X=$1157
Road_R00193
        ldd   #$1111
        ldx   #$1157
        pshu  d,x
        rts
* uses=32  D=$5511 X=$1111
Road_R00194
        ldd   #$5511
        ldx   #$1111
        pshu  d,x
        rts
* uses=32  D=$1111 X=$1155
Road_R00195
        ldd   #$1111
        ldx   #$1155
        pshu  d,x
        rts
* uses=94  D=$7755 X=$1111
Road_R00196
        ldd   #$7755
        ldx   #$1111
        pshu  d,x
        rts
* uses=94  D=$1111 X=$5577
Road_R00197
        ldd   #$1111
        ldx   #$5577
        pshu  d,x
        rts
* uses=81  D=$5577 X=$5511
Road_R00198
        ldd   #$5577
        ldx   #$5511
        pshu  d,x
        rts
* uses=81  D=$1155 X=$7755
Road_R00199
        ldd   #$1155
        ldx   #$7755
        pshu  d,x
        rts
* uses=1  D=$3111 X=$1115
Road_R00200
        ldd   #$3111
        ldx   #$1115
        pshu  d,x
        rts
* uses=1  D=$5111 X=$1113
Road_R00201
        ldd   #$5111
        ldx   #$1113
        pshu  d,x
        rts
* uses=9  D=$5775 X=$1111
Road_R00202
        ldd   #$5775
        ldx   #$1111
        pshu  d,x
        rts
* uses=9  D=$1111 X=$5775
Road_R00203
        ldd   #$1111
        ldx   #$5775
        pshu  d,x
        rts
* uses=22  D=$5775 X=$5555
Road_R00204
        ldd   #$5775
        ldx   #$5555
        pshu  d,x
        rts
* uses=7  D=$1115 X=$5755
Road_R00205
        ldd   #$1115
        ldx   #$5755
        pshu  d,x
        rts
* uses=7  D=$5575 X=$5111
Road_R00206
        ldd   #$5575
        ldx   #$5111
        pshu  d,x
        rts
* uses=22  D=$5555 X=$5775
Road_R00207
        ldd   #$5555
        ldx   #$5775
        pshu  d,x
        rts
* uses=30  D=$1111 X=$1333
Road_R00208
        ldd   #$1111
        ldx   #$1333
        pshu  d,x
        rts
* uses=30  D=$3331 X=$1111
Road_R00209
        ldd   #$3331
        ldx   #$1111
        pshu  d,x
        rts
* uses=2  D=$5557 X=$7511
Road_R00210
        ldd   #$5557
        ldx   #$7511
        pshu  d,x
        rts
* uses=2  D=$1157 X=$7555
Road_R00211
        ldd   #$1157
        ldx   #$7555
        pshu  d,x
        rts
* uses=59  D=$1111 X=$1133
Road_R00212
        ldd   #$1111
        ldx   #$1133
        pshu  d,x
        rts
* uses=59  D=$3311 X=$1111
Road_R00213
        ldd   #$3311
        ldx   #$1111
        pshu  d,x
        rts
* uses=3  D=$5555 X=$7551
Road_R00214
        ldd   #$5555
        ldx   #$7551
        pshu  d,x
        rts
* uses=3  D=$1557 X=$5555
Road_R00215
        ldd   #$1557
        ldx   #$5555
        pshu  d,x
        rts
* uses=17  D=$7551 X=$1111
Road_R00216
        ldd   #$7551
        ldx   #$1111
        pshu  d,x
        rts
* uses=17  D=$1111 X=$1557
Road_R00217
        ldd   #$1111
        ldx   #$1557
        pshu  d,x
        rts
* uses=14  D=$1115 X=$5775
Road_R00218
        ldd   #$1115
        ldx   #$5775
        pshu  d,x
        rts
* uses=14  D=$5775 X=$5111
Road_R00219
        ldd   #$5775
        ldx   #$5111
        pshu  d,x
        rts
* uses=10  D=$1111 X=$1113
Road_R00220
        ldd   #$1111
        ldx   #$1113
        pshu  d,x
        rts
* uses=4  D=$5557 X=$7551
Road_R00221
        ldd   #$5557
        ldx   #$7551
        pshu  d,x
        rts
* uses=4  D=$1557 X=$7555
Road_R00222
        ldd   #$1557
        ldx   #$7555
        pshu  d,x
        rts
* uses=10  D=$3111 X=$1111
Road_R00223
        ldd   #$3111
        ldx   #$1111
        pshu  d,x
        rts
* uses=20  D=$1111 X=$1111
Road_R00224
        ldd   #$1111
        ldx   #$1111
        pshu  d,x
        rts
* uses=30  D=$5557 X=$7555
Road_R00225
        ldd   #$5557
        ldx   #$7555
        pshu  d,x
        rts
* uses=28  D=$5577 X=$7555
Road_R00226
        ldd   #$5577
        ldx   #$7555
        pshu  d,x
        rts
* uses=28  D=$5557 X=$7755
Road_R00227
        ldd   #$5557
        ldx   #$7755
        pshu  d,x
        rts
* uses=3  D=$7755 X=$5111
Road_R00228
        ldd   #$7755
        ldx   #$5111
        pshu  d,x
        rts
* uses=1  D=$1111 X=$5557
Road_R00229
        ldd   #$1111
        ldx   #$5557
        pshu  d,x
        rts
* uses=1  D=$7555 X=$1111
Road_R00230
        ldd   #$7555
        ldx   #$1111
        pshu  d,x
        rts
* uses=3  D=$1115 X=$5577
Road_R00231
        ldd   #$1115
        ldx   #$5577
        pshu  d,x
        rts
* uses=3  D=$7775 X=$5111
Road_R00232
        ldd   #$7775
        ldx   #$5111
        pshu  d,x
        rts
* uses=3  D=$1115 X=$5777
Road_R00233
        ldd   #$1115
        ldx   #$5777
        pshu  d,x
        rts
* uses=3  D=$5775 X=$5511
Road_R00234
        ldd   #$5775
        ldx   #$5511
        pshu  d,x
        rts
* uses=3  D=$1155 X=$5775
Road_R00235
        ldd   #$1155
        ldx   #$5775
        pshu  d,x
        rts
* uses=2  D=$1155 X=$7775
Road_R00236
        ldd   #$1155
        ldx   #$7775
        pshu  d,x
        rts
* uses=2  D=$5777 X=$5511
Road_R00237
        ldd   #$5777
        ldx   #$5511
        pshu  d,x
        rts
* uses=3  D=$5555 X=$7775
Road_R00238
        ldd   #$5555
        ldx   #$7775
        pshu  d,x
        rts
* uses=3  D=$5777 X=$5555
Road_R00239
        ldd   #$5777
        ldx   #$5555
        pshu  d,x
        rts
* uses=2  D=$5577 X=$5551
Road_R00240
        ldd   #$5577
        ldx   #$5551
        pshu  d,x
        rts
* uses=2  D=$1555 X=$7755
Road_R00241
        ldd   #$1555
        ldx   #$7755
        pshu  d,x
        rts
* uses=1  D=$1557 X=$7755
Road_R00242
        ldd   #$1557
        ldx   #$7755
        pshu  d,x
        rts
* uses=1  D=$5577 X=$7551
Road_R00243
        ldd   #$5577
        ldx   #$7551
        pshu  d,x
        rts
* uses=1  D=$5555 X=$5777
Road_R00244
        ldd   #$5555
        ldx   #$5777
        pshu  d,x
        rts
* uses=1  D=$7775 X=$5555
Road_R00245
        ldd   #$7775
        ldx   #$5555
        pshu  d,x
        rts

* ─── 40 variants Road_draw_KX_JY (light) ───
*   herbe : D=$3333 X=$3333
*   Optim : si Y libre et N≥3, on fait `leay ,x` puis pshu d,x,y
*           (11cy/6o vs 9cy/4o de pshu d,x). Setup = +4cy (leay).

* Road_draw_K0_J0 : K'=0 prélude / F=10 cœur / J'=0 épilogue
Road_draw_K0_J0
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        rts

* Road_draw_K0_J1 : K'=0 prélude / F=9 cœur / J'=1 épilogue
Road_draw_K0_J1
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        rts

* Road_draw_K0_J2 : K'=0 prélude / F=8 cœur / J'=2 épilogue
Road_draw_K0_J2
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K0_J3 : K'=0 prélude / F=7 cœur / J'=3 épilogue
Road_draw_K0_J3
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K0_J4 : K'=0 prélude / F=6 cœur / J'=4 épilogue
Road_draw_K0_J4
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K0_J5 : K'=0 prélude / F=5 cœur / J'=5 épilogue
Road_draw_K0_J5
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K1_J0 : K'=1 prélude / F=9 cœur / J'=0 épilogue
Road_draw_K1_J0
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        rts

* Road_draw_K1_J1 : K'=1 prélude / F=8 cœur / J'=1 épilogue
Road_draw_K1_J1
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        rts

* Road_draw_K1_J2 : K'=1 prélude / F=7 cœur / J'=2 épilogue
Road_draw_K1_J2
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K1_J3 : K'=1 prélude / F=6 cœur / J'=3 épilogue
Road_draw_K1_J3
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K1_J4 : K'=1 prélude / F=5 cœur / J'=4 épilogue
Road_draw_K1_J4
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K1_J5 : K'=1 prélude / F=4 cœur / J'=5 épilogue
Road_draw_K1_J5
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K2_J0 : K'=2 prélude / F=8 cœur / J'=0 épilogue
Road_draw_K2_J0
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        rts

* Road_draw_K2_J1 : K'=2 prélude / F=7 cœur / J'=1 épilogue
Road_draw_K2_J1
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        rts

* Road_draw_K2_J2 : K'=2 prélude / F=6 cœur / J'=2 épilogue
Road_draw_K2_J2
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K2_J3 : K'=2 prélude / F=5 cœur / J'=3 épilogue
Road_draw_K2_J3
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K2_J4 : K'=2 prélude / F=4 cœur / J'=4 épilogue
Road_draw_K2_J4
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K2_J5 : K'=2 prélude / F=3 cœur / J'=5 épilogue
Road_draw_K2_J5
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K2_J6 : K'=2 prélude / F=2 cœur / J'=6 épilogue
Road_draw_K2_J6
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K3_J0 : K'=3 prélude / F=7 cœur / J'=0 épilogue
Road_draw_K3_J0
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        rts

* Road_draw_K3_J1 : K'=3 prélude / F=6 cœur / J'=1 épilogue
Road_draw_K3_J1
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        rts

* Road_draw_K3_J2 : K'=3 prélude / F=5 cœur / J'=2 épilogue
Road_draw_K3_J2
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K3_J3 : K'=3 prélude / F=4 cœur / J'=3 épilogue
Road_draw_K3_J3
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K3_J4 : K'=3 prélude / F=3 cœur / J'=4 épilogue
Road_draw_K3_J4
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K3_J5 : K'=3 prélude / F=2 cœur / J'=5 épilogue
Road_draw_K3_J5
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K3_J6 : K'=3 prélude / F=1 cœur / J'=6 épilogue
Road_draw_K3_J6
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K4_J0 : K'=4 prélude / F=6 cœur / J'=0 épilogue
Road_draw_K4_J0
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        rts

* Road_draw_K4_J1 : K'=4 prélude / F=5 cœur / J'=1 épilogue
Road_draw_K4_J1
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        rts

* Road_draw_K4_J2 : K'=4 prélude / F=4 cœur / J'=2 épilogue
Road_draw_K4_J2
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K4_J3 : K'=4 prélude / F=3 cœur / J'=3 épilogue
Road_draw_K4_J3
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K4_J4 : K'=4 prélude / F=2 cœur / J'=4 épilogue
Road_draw_K4_J4
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K4_J5 : K'=4 prélude / F=1 cœur / J'=5 épilogue
Road_draw_K4_J5
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K5_J0 : K'=5 prélude / F=5 cœur / J'=0 épilogue
Road_draw_K5_J0
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        rts

* Road_draw_K5_J1 : K'=5 prélude / F=4 cœur / J'=1 épilogue
Road_draw_K5_J1
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        rts

* Road_draw_K5_J2 : K'=5 prélude / F=3 cœur / J'=2 épilogue
Road_draw_K5_J2
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K5_J3 : K'=5 prélude / F=2 cœur / J'=3 épilogue
Road_draw_K5_J3
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K5_J4 : K'=5 prélude / F=1 cœur / J'=4 épilogue
Road_draw_K5_J4
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K6_J2 : K'=6 prélude / F=2 cœur / J'=2 épilogue
Road_draw_K6_J2
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K6_J3 : K'=6 prélude / F=1 cœur / J'=3 épilogue
Road_draw_K6_J3
        ldd   #$3333
        ldx   #$3333
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y++]
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K10_J0 : K'=10 prélude / F=0 cœur / J'=0 épilogue
Road_draw_K10_J0
        ldd   #$3333
        ldx   #$3333
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts
