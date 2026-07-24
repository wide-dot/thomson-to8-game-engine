 opt c
; ========================================================================
; Road RAM v4 — pattern bank dark @ $4000
; Structure identique dark/light, valeurs uniquement diffèrent.
; ========================================================================
        ORG   $4000

* ─── Stub pshu (palette-agnostique, dupliqué 2 banks) ───
Road_pshu_dx
        pshu  d,x
        rts

* ─── 267 routines ld (dark) ───
* uses=4  D=$4222 X=$2222
Road_R00000
        ldd   #$4222
        ldx   #$2222
        pshu  d,x
        rts
* uses=250  D=$2222 X=$2222
Road_R00001
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts
* uses=2  D=$2422 X=$2222
Road_R00002
        ldd   #$2422
        ldx   #$2222
        pshu  d,x
        rts
* uses=2  D=$4422 X=$2222
Road_R00003
        ldd   #$4422
        ldx   #$2222
        pshu  d,x
        rts
* uses=3  D=$2222 X=$2224
Road_R00004
        ldd   #$2222
        ldx   #$2224
        pshu  d,x
        rts
* uses=6  D=$4422 X=$2222
Road_R00005
        ldd   #$4422
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$2222 X=$2224
Road_R00006
        ldd   #$2222
        ldx   #$2224
        pshu  d,x
        rts
* uses=4  D=$4422 X=$2222
Road_R00007
        ldd   #$4422
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$4222 X=$2222
Road_R00008
        ldd   #$4222
        ldx   #$2222
        pshu  d,x
        rts
* uses=61  D=$0222 X=$2222
Road_R00009
        ldd   #$0222
        ldx   #$2222
        pshu  d,x
        rts
* uses=13  D=$2222 X=$2204
Road_R00010
        ldd   #$2222
        ldx   #$2204
        pshu  d,x
        rts
* uses=11  D=$4022 X=$2222
Road_R00011
        ldd   #$4022
        ldx   #$2222
        pshu  d,x
        rts
* uses=68  D=$2222 X=$2220
Road_R00012
        ldd   #$2222
        ldx   #$2220
        pshu  d,x
        rts
* uses=3  D=$2222 X=$2244
Road_R00013
        ldd   #$2222
        ldx   #$2244
        pshu  d,x
        rts
* uses=17  D=$2222 X=$2244
Road_R00014
        ldd   #$2222
        ldx   #$2244
        pshu  d,x
        rts
* uses=4  D=$4402 X=$2222
Road_R00015
        ldd   #$4402
        ldx   #$2222
        pshu  d,x
        rts
* uses=10  D=$4422 X=$2222
Road_R00016
        ldd   #$4422
        ldx   #$2222
        pshu  d,x
        rts
* uses=7  D=$4402 X=$2222
Road_R00017
        ldd   #$4402
        ldx   #$2222
        pshu  d,x
        rts
* uses=3  D=$4440 X=$2222
Road_R00018
        ldd   #$4440
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$4442 X=$2222
Road_R00019
        ldd   #$4442
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$4444 X=$2222
Road_R00020
        ldd   #$4444
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$4440 X=$2222
Road_R00021
        ldd   #$4440
        ldx   #$2222
        pshu  d,x
        rts
* uses=5  D=$2222 X=$2044
Road_R00022
        ldd   #$2222
        ldx   #$2044
        pshu  d,x
        rts
* uses=3  D=$4444 X=$2222
Road_R00023
        ldd   #$4444
        ldx   #$2222
        pshu  d,x
        rts
* uses=4  D=$4402 X=$2222
Road_R00024
        ldd   #$4402
        ldx   #$2222
        pshu  d,x
        rts
* uses=4  D=$4444 X=$2222
Road_R00025
        ldd   #$4444
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$2222 X=$2444
Road_R00026
        ldd   #$2222
        ldx   #$2444
        pshu  d,x
        rts
* uses=1  D=$4442 X=$2222
Road_R00027
        ldd   #$4442
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$4444 X=$2222
Road_R00028
        ldd   #$4444
        ldx   #$2222
        pshu  d,x
        rts
* uses=3  D=$2222 X=$0444
Road_R00029
        ldd   #$2222
        ldx   #$0444
        pshu  d,x
        rts
* uses=1  D=$4440 X=$2222
Road_R00030
        ldd   #$4440
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$2222 X=$2244
Road_R00031
        ldd   #$2222
        ldx   #$2244
        pshu  d,x
        rts
* uses=4  D=$2222 X=$0444
Road_R00032
        ldd   #$2222
        ldx   #$0444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$2222
Road_R00033
        ldd   #$4444
        ldx   #$2222
        pshu  d,x
        rts
* uses=6  D=$4440 X=$2222
Road_R00034
        ldd   #$4440
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$2222 X=$2044
Road_R00035
        ldd   #$2222
        ldx   #$2044
        pshu  d,x
        rts
* uses=6  D=$2222 X=$2044
Road_R00036
        ldd   #$2222
        ldx   #$2044
        pshu  d,x
        rts
* uses=10  D=$2222 X=$4444
Road_R00037
        ldd   #$2222
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$0222
Road_R00038
        ldd   #$4444
        ldx   #$0222
        pshu  d,x
        rts
* uses=7  D=$4444 X=$2222
Road_R00039
        ldd   #$4444
        ldx   #$2222
        pshu  d,x
        rts
* uses=2  D=$2222 X=$0444
Road_R00040
        ldd   #$2222
        ldx   #$0444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$0222
Road_R00041
        ldd   #$4444
        ldx   #$0222
        pshu  d,x
        rts
* uses=2  D=$4444 X=$0222
Road_R00042
        ldd   #$4444
        ldx   #$0222
        pshu  d,x
        rts
* uses=21  D=$2222 X=$0044
Road_R00043
        ldd   #$2222
        ldx   #$0044
        pshu  d,x
        rts
* uses=1  D=$4444 X=$0022
Road_R00044
        ldd   #$4444
        ldx   #$0022
        pshu  d,x
        rts
* uses=1  D=$4444 X=$2222
Road_R00045
        ldd   #$4444
        ldx   #$2222
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4022
Road_R00046
        ldd   #$4444
        ldx   #$4022
        pshu  d,x
        rts
* uses=2  D=$2222 X=$4444
Road_R00047
        ldd   #$2222
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$0022
Road_R00048
        ldd   #$4444
        ldx   #$0022
        pshu  d,x
        rts
* uses=9  D=$2220 X=$4444
Road_R00049
        ldd   #$2220
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4022
Road_R00050
        ldd   #$4444
        ldx   #$4022
        pshu  d,x
        rts
* uses=7  D=$2222 X=$0044
Road_R00051
        ldd   #$2222
        ldx   #$0044
        pshu  d,x
        rts
* uses=5  D=$4444 X=$0222
Road_R00052
        ldd   #$4444
        ldx   #$0222
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4022
Road_R00053
        ldd   #$4444
        ldx   #$4022
        pshu  d,x
        rts
* uses=2  D=$2222 X=$4444
Road_R00054
        ldd   #$2222
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4422
Road_R00055
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=1  D=$2222 X=$0444
Road_R00056
        ldd   #$2222
        ldx   #$0444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4022
Road_R00057
        ldd   #$4444
        ldx   #$4022
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4422
Road_R00058
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4022
Road_R00059
        ldd   #$4444
        ldx   #$4022
        pshu  d,x
        rts
* uses=9  D=$2200 X=$4444
Road_R00060
        ldd   #$2200
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4422
Road_R00061
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=15  D=$4444 X=$0022
Road_R00062
        ldd   #$4444
        ldx   #$0022
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4422
Road_R00063
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=5  D=$2204 X=$4444
Road_R00064
        ldd   #$2204
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4022
Road_R00065
        ldd   #$4444
        ldx   #$4022
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4422
Road_R00066
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=1  D=$2204 X=$4444
Road_R00067
        ldd   #$2204
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4402
Road_R00068
        ldd   #$4444
        ldx   #$4402
        pshu  d,x
        rts
* uses=1  D=$2222 X=$4444
Road_R00069
        ldd   #$2222
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4022
Road_R00070
        ldd   #$4444
        ldx   #$4022
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4422
Road_R00071
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=1  D=$2244 X=$4444
Road_R00072
        ldd   #$2244
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4422
Road_R00073
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4402
Road_R00074
        ldd   #$4444
        ldx   #$4402
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4022
Road_R00075
        ldd   #$4444
        ldx   #$4022
        pshu  d,x
        rts
* uses=2  D=$2244 X=$4444
Road_R00076
        ldd   #$2244
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4400
Road_R00077
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4422
Road_R00078
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=4  D=$2204 X=$4444
Road_R00079
        ldd   #$2204
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4400
Road_R00080
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4422
Road_R00081
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=3  D=$2044 X=$4444
Road_R00082
        ldd   #$2044
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4440
Road_R00083
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4402
Road_R00084
        ldd   #$4444
        ldx   #$4402
        pshu  d,x
        rts
* uses=4  D=$2244 X=$4444
Road_R00085
        ldd   #$2244
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4422
Road_R00086
        ldd   #$4444
        ldx   #$4422
        pshu  d,x
        rts
* uses=1  D=$2044 X=$4444
Road_R00087
        ldd   #$2044
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4440
Road_R00088
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4402
Road_R00089
        ldd   #$4444
        ldx   #$4402
        pshu  d,x
        rts
* uses=1  D=$2244 X=$4444
Road_R00090
        ldd   #$2244
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4440
Road_R00091
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4402
Road_R00092
        ldd   #$4444
        ldx   #$4402
        pshu  d,x
        rts
* uses=22  D=$0044 X=$4444
Road_R00093
        ldd   #$0044
        ldx   #$4444
        pshu  d,x
        rts
* uses=185  D=$4444 X=$4444
Road_R00094
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=21  D=$4444 X=$4400
Road_R00095
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=2  D=$2044 X=$4444
Road_R00096
        ldd   #$2044
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4440
Road_R00097
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=2  D=$2044 X=$4444
Road_R00098
        ldd   #$2044
        ldx   #$4444
        pshu  d,x
        rts
* uses=24  D=$4444 X=$4400
Road_R00099
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=24  D=$0044 X=$4444
Road_R00100
        ldd   #$0044
        ldx   #$4444
        pshu  d,x
        rts
* uses=7  D=$4444 X=$4444
Road_R00101
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=361  D=$4444 X=$4444
Road_R00102
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=12  D=$0444 X=$4444
Road_R00103
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=13  D=$4444 X=$4440
Road_R00104
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=12  D=$4444 X=$4444
Road_R00105
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=5  D=$0044 X=$4444
Road_R00106
        ldd   #$0044
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$0444 X=$4444
Road_R00107
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=174  D=$0022 X=$2222
Road_R00108
        ldd   #$0022
        ldx   #$2222
        pshu  d,x
        rts
* uses=5  D=$4444 X=$4444
Road_R00109
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4440
Road_R00110
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4440
Road_R00111
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=2962  D=$4444 X=$4444
Road_R00112
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=3  D=$0444 X=$4444
Road_R00113
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=109  D=$4444 X=$4444
Road_R00114
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=295  D=$4444 X=$4444
Road_R00115
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=6  D=$4444 X=$4444
Road_R00116
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=169  D=$2222 X=$2200
Road_R00117
        ldd   #$2222
        ldx   #$2200
        pshu  d,x
        rts
* uses=4  D=$4444 X=$4444
Road_R00118
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$0444 X=$4444
Road_R00119
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4022 X=$2222
Road_R00120
        ldd   #$4022
        ldx   #$2222
        pshu  d,x
        rts
* uses=2  D=$0444 X=$4444
Road_R00121
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=71  D=$4444 X=$4444
Road_R00122
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=4  D=$4444 X=$4444
Road_R00123
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=78  D=$4444 X=$4444
Road_R00124
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=7  D=$4400 X=$2222
Road_R00125
        ldd   #$4400
        ldx   #$2222
        pshu  d,x
        rts
* uses=19  D=$4400 X=$2222
Road_R00126
        ldd   #$4400
        ldx   #$2222
        pshu  d,x
        rts
* uses=8  D=$2222 X=$0044
Road_R00127
        ldd   #$2222
        ldx   #$0044
        pshu  d,x
        rts
* uses=100  D=$4444 X=$4444
Road_R00128
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=90  D=$4444 X=$4444
Road_R00129
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=3  D=$2222 X=$2004
Road_R00130
        ldd   #$2222
        ldx   #$2004
        pshu  d,x
        rts
* uses=7  D=$4440 X=$0222
Road_R00131
        ldd   #$4440
        ldx   #$0222
        pshu  d,x
        rts
* uses=1  D=$4444 X=$0222
Road_R00132
        ldd   #$4444
        ldx   #$0222
        pshu  d,x
        rts
* uses=8  D=$4444 X=$0022
Road_R00133
        ldd   #$4444
        ldx   #$0022
        pshu  d,x
        rts
* uses=9  D=$2220 X=$0444
Road_R00134
        ldd   #$2220
        ldx   #$0444
        pshu  d,x
        rts
* uses=10  D=$4444 X=$0022
Road_R00135
        ldd   #$4444
        ldx   #$0022
        pshu  d,x
        rts
* uses=4  D=$4444 X=$4444
Road_R00136
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=10  D=$2200 X=$4444
Road_R00137
        ldd   #$2200
        ldx   #$4444
        pshu  d,x
        rts
* uses=7  D=$4444 X=$4444
Road_R00138
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=11  D=$2200 X=$4444
Road_R00139
        ldd   #$2200
        ldx   #$4444
        pshu  d,x
        rts
* uses=7  D=$4444 X=$4002
Road_R00140
        ldd   #$4444
        ldx   #$4002
        pshu  d,x
        rts
* uses=1  D=$4444 X=$0022
Road_R00141
        ldd   #$4444
        ldx   #$0022
        pshu  d,x
        rts
* uses=35  D=$4444 X=$4400
Road_R00142
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=2  D=$2200 X=$4444
Road_R00143
        ldd   #$2200
        ldx   #$4444
        pshu  d,x
        rts
* uses=8  D=$4444 X=$4000
Road_R00144
        ldd   #$4444
        ldx   #$4000
        pshu  d,x
        rts
* uses=12  D=$2000 X=$4444
Road_R00145
        ldd   #$2000
        ldx   #$4444
        pshu  d,x
        rts
* uses=7  D=$2200 X=$0444
Road_R00146
        ldd   #$2200
        ldx   #$0444
        pshu  d,x
        rts
* uses=5  D=$4444 X=$0002
Road_R00147
        ldd   #$4444
        ldx   #$0002
        pshu  d,x
        rts
* uses=2  D=$2004 X=$4444
Road_R00148
        ldd   #$2004
        ldx   #$4444
        pshu  d,x
        rts
* uses=13  D=$4444 X=$4400
Road_R00149
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=10  D=$0004 X=$4444
Road_R00150
        ldd   #$0004
        ldx   #$4444
        pshu  d,x
        rts
* uses=15  D=$4444 X=$4400
Road_R00151
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=35  D=$0044 X=$4444
Road_R00152
        ldd   #$0044
        ldx   #$4444
        pshu  d,x
        rts
* uses=593  D=$4444 X=$4444
Road_R00153
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=295  D=$4444 X=$4444
Road_R00154
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=13  D=$0044 X=$4444
Road_R00155
        ldd   #$0044
        ldx   #$4444
        pshu  d,x
        rts
* uses=14  D=$0044 X=$4444
Road_R00156
        ldd   #$0044
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4444
Road_R00157
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=51  D=$0002 X=$2222
Road_R00158
        ldd   #$0002
        ldx   #$2222
        pshu  d,x
        rts
* uses=124  D=$0000 X=$2222
Road_R00159
        ldd   #$0000
        ldx   #$2222
        pshu  d,x
        rts
* uses=10  D=$4000 X=$2222
Road_R00160
        ldd   #$4000
        ldx   #$2222
        pshu  d,x
        rts
* uses=49  D=$2222 X=$2000
Road_R00161
        ldd   #$2222
        ldx   #$2000
        pshu  d,x
        rts
* uses=120  D=$2222 X=$0000
Road_R00162
        ldd   #$2222
        ldx   #$0000
        pshu  d,x
        rts
* uses=6  D=$4400 X=$2222
Road_R00163
        ldd   #$4400
        ldx   #$2222
        pshu  d,x
        rts
* uses=10  D=$2222 X=$0004
Road_R00164
        ldd   #$2222
        ldx   #$0004
        pshu  d,x
        rts
* uses=5  D=$4400 X=$0222
Road_R00165
        ldd   #$4400
        ldx   #$0222
        pshu  d,x
        rts
* uses=4  D=$4400 X=$0222
Road_R00166
        ldd   #$4400
        ldx   #$0222
        pshu  d,x
        rts
* uses=9  D=$4400 X=$0022
Road_R00167
        ldd   #$4400
        ldx   #$0022
        pshu  d,x
        rts
* uses=7  D=$2220 X=$0044
Road_R00168
        ldd   #$2220
        ldx   #$0044
        pshu  d,x
        rts
* uses=8  D=$4440 X=$0022
Road_R00169
        ldd   #$4440
        ldx   #$0022
        pshu  d,x
        rts
* uses=1  D=$2220 X=$0044
Road_R00170
        ldd   #$2220
        ldx   #$0044
        pshu  d,x
        rts
* uses=7  D=$2200 X=$0044
Road_R00171
        ldd   #$2200
        ldx   #$0044
        pshu  d,x
        rts
* uses=2  D=$4400 X=$0022
Road_R00172
        ldd   #$4400
        ldx   #$0022
        pshu  d,x
        rts
* uses=4  D=$2200 X=$0444
Road_R00173
        ldd   #$2200
        ldx   #$0444
        pshu  d,x
        rts
* uses=5  D=$4444 X=$0002
Road_R00174
        ldd   #$4444
        ldx   #$0002
        pshu  d,x
        rts
* uses=2  D=$4440 X=$0022
Road_R00175
        ldd   #$4440
        ldx   #$0022
        pshu  d,x
        rts
* uses=5  D=$2200 X=$0044
Road_R00176
        ldd   #$2200
        ldx   #$0044
        pshu  d,x
        rts
* uses=12  D=$4444 X=$0000
Road_R00177
        ldd   #$4444
        ldx   #$0000
        pshu  d,x
        rts
* uses=23  D=$4444 X=$0000
Road_R00178
        ldd   #$4444
        ldx   #$0000
        pshu  d,x
        rts
* uses=6  D=$4444 X=$0000
Road_R00179
        ldd   #$4444
        ldx   #$0000
        pshu  d,x
        rts
* uses=206  D=$4444 X=$4444
Road_R00180
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=5  D=$2200 X=$0044
Road_R00181
        ldd   #$2200
        ldx   #$0044
        pshu  d,x
        rts
* uses=1  D=$2000 X=$4444
Road_R00182
        ldd   #$2000
        ldx   #$4444
        pshu  d,x
        rts
* uses=25  D=$0000 X=$4444
Road_R00183
        ldd   #$0000
        ldx   #$4444
        pshu  d,x
        rts
* uses=5  D=$4444 X=$4000
Road_R00184
        ldd   #$4444
        ldx   #$4000
        pshu  d,x
        rts
* uses=12  D=$0000 X=$4444
Road_R00185
        ldd   #$0000
        ldx   #$4444
        pshu  d,x
        rts
* uses=4  D=$0000 X=$4444
Road_R00186
        ldd   #$0000
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$2000 X=$0444
Road_R00187
        ldd   #$2000
        ldx   #$0444
        pshu  d,x
        rts
* uses=7  D=$0004 X=$4444
Road_R00188
        ldd   #$0004
        ldx   #$4444
        pshu  d,x
        rts
* uses=6  D=$0000 X=$4444
Road_R00189
        ldd   #$0000
        ldx   #$4444
        pshu  d,x
        rts
* uses=194  D=$4444 X=$4444
Road_R00190
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=8  D=$4444 X=$4440
Road_R00191
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=8  D=$0444 X=$4444
Road_R00192
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=17  D=$0444 X=$4444
Road_R00193
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=4  D=$4000 X=$0222
Road_R00194
        ldd   #$4000
        ldx   #$0222
        pshu  d,x
        rts
* uses=34  D=$0000 X=$0222
Road_R00195
        ldd   #$0000
        ldx   #$0222
        pshu  d,x
        rts
* uses=13  D=$4000 X=$0022
Road_R00196
        ldd   #$4000
        ldx   #$0022
        pshu  d,x
        rts
* uses=12  D=$4400 X=$0022
Road_R00197
        ldd   #$4400
        ldx   #$0022
        pshu  d,x
        rts
* uses=32  D=$2220 X=$0000
Road_R00198
        ldd   #$2220
        ldx   #$0000
        pshu  d,x
        rts
* uses=12  D=$2200 X=$0004
Road_R00199
        ldd   #$2200
        ldx   #$0004
        pshu  d,x
        rts
* uses=8  D=$4400 X=$0022
Road_R00200
        ldd   #$4400
        ldx   #$0022
        pshu  d,x
        rts
* uses=13  D=$2200 X=$0044
Road_R00201
        ldd   #$2200
        ldx   #$0044
        pshu  d,x
        rts
* uses=2  D=$2220 X=$0004
Road_R00202
        ldd   #$2220
        ldx   #$0004
        pshu  d,x
        rts
* uses=5  D=$4400 X=$0002
Road_R00203
        ldd   #$4400
        ldx   #$0002
        pshu  d,x
        rts
* uses=1  D=$4440 X=$0002
Road_R00204
        ldd   #$4440
        ldx   #$0002
        pshu  d,x
        rts
* uses=17  D=$4440 X=$0000
Road_R00205
        ldd   #$4440
        ldx   #$0000
        pshu  d,x
        rts
* uses=4  D=$4440 X=$0000
Road_R00206
        ldd   #$4440
        ldx   #$0000
        pshu  d,x
        rts
* uses=6  D=$2000 X=$0044
Road_R00207
        ldd   #$2000
        ldx   #$0044
        pshu  d,x
        rts
* uses=18  D=$4444 X=$0000
Road_R00208
        ldd   #$4444
        ldx   #$0000
        pshu  d,x
        rts
* uses=2  D=$4400 X=$0002
Road_R00209
        ldd   #$4400
        ldx   #$0002
        pshu  d,x
        rts
* uses=2  D=$2000 X=$0044
Road_R00210
        ldd   #$2000
        ldx   #$0044
        pshu  d,x
        rts
* uses=6  D=$4444 X=$0000
Road_R00211
        ldd   #$4444
        ldx   #$0000
        pshu  d,x
        rts
* uses=5  D=$0000 X=$0044
Road_R00212
        ldd   #$0000
        ldx   #$0044
        pshu  d,x
        rts
* uses=3  D=$4400 X=$0000
Road_R00213
        ldd   #$4400
        ldx   #$0000
        pshu  d,x
        rts
* uses=19  D=$0000 X=$0444
Road_R00214
        ldd   #$0000
        ldx   #$0444
        pshu  d,x
        rts
* uses=1  D=$0000 X=$0444
Road_R00215
        ldd   #$0000
        ldx   #$0444
        pshu  d,x
        rts
* uses=18  D=$0000 X=$4444
Road_R00216
        ldd   #$0000
        ldx   #$4444
        pshu  d,x
        rts
* uses=22  D=$4444 X=$4000
Road_R00217
        ldd   #$4444
        ldx   #$4000
        pshu  d,x
        rts
* uses=20  D=$0004 X=$4444
Road_R00218
        ldd   #$0004
        ldx   #$4444
        pshu  d,x
        rts
* uses=17  D=$4444 X=$4440
Road_R00219
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=45  D=$0044 X=$4444
Road_R00220
        ldd   #$0044
        ldx   #$4444
        pshu  d,x
        rts
* uses=70  D=$0000 X=$0022
Road_R00221
        ldd   #$0000
        ldx   #$0022
        pshu  d,x
        rts
* uses=69  D=$2200 X=$0000
Road_R00222
        ldd   #$2200
        ldx   #$0000
        pshu  d,x
        rts
* uses=6  D=$4400 X=$0002
Road_R00223
        ldd   #$4400
        ldx   #$0002
        pshu  d,x
        rts
* uses=71  D=$4400 X=$0000
Road_R00224
        ldd   #$4400
        ldx   #$0000
        pshu  d,x
        rts
* uses=6  D=$2000 X=$0004
Road_R00225
        ldd   #$2000
        ldx   #$0004
        pshu  d,x
        rts
* uses=2  D=$4000 X=$0002
Road_R00226
        ldd   #$4000
        ldx   #$0002
        pshu  d,x
        rts
* uses=2  D=$2000 X=$0044
Road_R00227
        ldd   #$2000
        ldx   #$0044
        pshu  d,x
        rts
* uses=13  D=$4400 X=$0000
Road_R00228
        ldd   #$4400
        ldx   #$0000
        pshu  d,x
        rts
* uses=69  D=$0000 X=$0044
Road_R00229
        ldd   #$0000
        ldx   #$0044
        pshu  d,x
        rts
* uses=12  D=$0000 X=$0044
Road_R00230
        ldd   #$0000
        ldx   #$0044
        pshu  d,x
        rts
* uses=45  D=$4444 X=$0000
Road_R00231
        ldd   #$4444
        ldx   #$0000
        pshu  d,x
        rts
* uses=43  D=$0000 X=$4444
Road_R00232
        ldd   #$0000
        ldx   #$4444
        pshu  d,x
        rts
* uses=3  D=$4444 X=$0000
Road_R00233
        ldd   #$4444
        ldx   #$0000
        pshu  d,x
        rts
* uses=5  D=$0000 X=$4444
Road_R00234
        ldd   #$0000
        ldx   #$4444
        pshu  d,x
        rts
* uses=44  D=$4444 X=$4400
Road_R00235
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=39  D=$4444 X=$4444
Road_R00236
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=3  D=$0004 X=$4444
Road_R00237
        ldd   #$0004
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4000
Road_R00238
        ldd   #$4444
        ldx   #$4000
        pshu  d,x
        rts
* uses=31  D=$4444 X=$4444
Road_R00239
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=4  D=$4444 X=$4400
Road_R00240
        ldd   #$4444
        ldx   #$4400
        pshu  d,x
        rts
* uses=3  D=$4444 X=$4440
Road_R00241
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=22  D=$4444 X=$4444
Road_R00242
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=3  D=$0044 X=$4444
Road_R00243
        ldd   #$0044
        ldx   #$4444
        pshu  d,x
        rts
* uses=16  D=$0000 X=$0002
Road_R00244
        ldd   #$0000
        ldx   #$0002
        pshu  d,x
        rts
* uses=4  D=$0444 X=$4444
Road_R00245
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=87  D=$0000 X=$0000
Road_R00246
        ldd   #$0000
        ldx   #$0000
        pshu  d,x
        rts
* uses=20  D=$4000 X=$0000
Road_R00247
        ldd   #$4000
        ldx   #$0000
        pshu  d,x
        rts
* uses=16  D=$2000 X=$0000
Road_R00248
        ldd   #$2000
        ldx   #$0000
        pshu  d,x
        rts
* uses=20  D=$0000 X=$0004
Road_R00249
        ldd   #$0000
        ldx   #$0004
        pshu  d,x
        rts
* uses=13  D=$4440 X=$0000
Road_R00250
        ldd   #$4440
        ldx   #$0000
        pshu  d,x
        rts
* uses=11  D=$0000 X=$0444
Road_R00251
        ldd   #$0000
        ldx   #$0444
        pshu  d,x
        rts
* uses=8  D=$4444 X=$4000
Road_R00252
        ldd   #$4444
        ldx   #$4000
        pshu  d,x
        rts
* uses=8  D=$0004 X=$4444
Road_R00253
        ldd   #$0004
        ldx   #$4444
        pshu  d,x
        rts
* uses=9  D=$4444 X=$4440
Road_R00254
        ldd   #$4444
        ldx   #$4440
        pshu  d,x
        rts
* uses=7  D=$0444 X=$4444
Road_R00255
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$0444 X=$4444
Road_R00256
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$4444 X=$4444
Road_R00257
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=3  D=$4444 X=$4444
Road_R00258
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=2  D=$4444 X=$4444
Road_R00259
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=1  D=$0444 X=$4444
Road_R00260
        ldd   #$0444
        ldx   #$4444
        pshu  d,x
        rts
* uses=4  D=$4444 X=$4444
Road_R00261
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=8  D=$4444 X=$4444
Road_R00262
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=5  D=$4444 X=$4444
Road_R00263
        ldd   #$4444
        ldx   #$4444
        pshu  d,x
        rts
* uses=3  D=$4440 X=$0000
Road_R00264
        ldd   #$4440
        ldx   #$0000
        pshu  d,x
        rts
* uses=2  D=$4444 X=$0000
Road_R00265
        ldd   #$4444
        ldx   #$0000
        pshu  d,x
        rts
* uses=1  D=$0000 X=$0444
Road_R00266
        ldd   #$0000
        ldx   #$0444
        pshu  d,x
        rts

* ─── 66 variants Road_draw_KX_JY (dark) ───
*   herbe : D=$2222 X=$2222
*   Optim : si Y libre et N≥3, on fait `leay ,x` puis pshu d,x,y
*           (11cy/6o vs 9cy/4o de pshu d,x). Setup = +4cy (leay).

* Road_draw_K0_J0 : K'=0 prélude / F=10 cœur / J'=0 épilogue
Road_draw_K0_J0
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        jsr   [14,y]
        jsr   [16,y]
        jsr   [18,y]
        rts

* Road_draw_K0_J1 : K'=0 prélude / F=9 cœur / J'=1 épilogue
Road_draw_K0_J1
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        jsr   [14,y]
        jsr   [16,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K0_J2 : K'=0 prélude / F=8 cœur / J'=2 épilogue
Road_draw_K0_J2
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        jsr   [14,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K0_J3 : K'=0 prélude / F=7 cœur / J'=3 épilogue
Road_draw_K0_J3
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K0_J4 : K'=0 prélude / F=6 cœur / J'=4 épilogue
Road_draw_K0_J4
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K0_J5 : K'=0 prélude / F=5 cœur / J'=5 épilogue
Road_draw_K0_J5
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K0_J6 : K'=0 prélude / F=4 cœur / J'=6 épilogue
Road_draw_K0_J6
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K0_J7 : K'=0 prélude / F=3 cœur / J'=7 épilogue
Road_draw_K0_J7
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K0_J8 : K'=0 prélude / F=2 cœur / J'=8 épilogue
Road_draw_K0_J8
        jsr   [,y]
        jsr   [2,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K0_J9 : K'=0 prélude / F=1 cœur / J'=9 épilogue
Road_draw_K0_J9
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K0_J10 : K'=0 prélude / F=0 cœur / J'=10 épilogue
Road_draw_K0_J10
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K1_J0 : K'=1 prélude / F=9 cœur / J'=0 épilogue
Road_draw_K1_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        jsr   [14,y]
        jsr   [16,y]
        rts

* Road_draw_K1_J1 : K'=1 prélude / F=8 cœur / J'=1 épilogue
Road_draw_K1_J1
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        jsr   [14,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K1_J2 : K'=1 prélude / F=7 cœur / J'=2 épilogue
Road_draw_K1_J2
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K1_J3 : K'=1 prélude / F=6 cœur / J'=3 épilogue
Road_draw_K1_J3
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K1_J4 : K'=1 prélude / F=5 cœur / J'=4 épilogue
Road_draw_K1_J4
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K1_J5 : K'=1 prélude / F=4 cœur / J'=5 épilogue
Road_draw_K1_J5
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K1_J6 : K'=1 prélude / F=3 cœur / J'=6 épilogue
Road_draw_K1_J6
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K1_J7 : K'=1 prélude / F=2 cœur / J'=7 épilogue
Road_draw_K1_J7
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K1_J8 : K'=1 prélude / F=1 cœur / J'=8 épilogue
Road_draw_K1_J8
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K1_J9 : K'=1 prélude / F=0 cœur / J'=9 épilogue
Road_draw_K1_J9
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K2_J0 : K'=2 prélude / F=8 cœur / J'=0 épilogue
Road_draw_K2_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        jsr   [14,y]
        rts

* Road_draw_K2_J1 : K'=2 prélude / F=7 cœur / J'=1 épilogue
Road_draw_K2_J1
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K2_J2 : K'=2 prélude / F=6 cœur / J'=2 épilogue
Road_draw_K2_J2
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K2_J3 : K'=2 prélude / F=5 cœur / J'=3 épilogue
Road_draw_K2_J3
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K2_J4 : K'=2 prélude / F=4 cœur / J'=4 épilogue
Road_draw_K2_J4
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K2_J5 : K'=2 prélude / F=3 cœur / J'=5 épilogue
Road_draw_K2_J5
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K2_J6 : K'=2 prélude / F=2 cœur / J'=6 épilogue
Road_draw_K2_J6
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K2_J7 : K'=2 prélude / F=1 cœur / J'=7 épilogue
Road_draw_K2_J7
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K2_J8 : K'=2 prélude / F=0 cœur / J'=8 épilogue
Road_draw_K2_J8
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K3_J0 : K'=3 prélude / F=7 cœur / J'=0 épilogue
Road_draw_K3_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        jsr   [12,y]
        rts

* Road_draw_K3_J1 : K'=3 prélude / F=6 cœur / J'=1 épilogue
Road_draw_K3_J1
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K3_J2 : K'=3 prélude / F=5 cœur / J'=2 épilogue
Road_draw_K3_J2
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K3_J3 : K'=3 prélude / F=4 cœur / J'=3 épilogue
Road_draw_K3_J3
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K3_J4 : K'=3 prélude / F=3 cœur / J'=4 épilogue
Road_draw_K3_J4
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K3_J5 : K'=3 prélude / F=2 cœur / J'=5 épilogue
Road_draw_K3_J5
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K3_J6 : K'=3 prélude / F=1 cœur / J'=6 épilogue
Road_draw_K3_J6
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K3_J7 : K'=3 prélude / F=0 cœur / J'=7 épilogue
Road_draw_K3_J7
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K4_J0 : K'=4 prélude / F=6 cœur / J'=0 épilogue
Road_draw_K4_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        jsr   [10,y]
        rts

* Road_draw_K4_J1 : K'=4 prélude / F=5 cœur / J'=1 épilogue
Road_draw_K4_J1
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K4_J2 : K'=4 prélude / F=4 cœur / J'=2 épilogue
Road_draw_K4_J2
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K4_J3 : K'=4 prélude / F=3 cœur / J'=3 épilogue
Road_draw_K4_J3
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K4_J4 : K'=4 prélude / F=2 cœur / J'=4 épilogue
Road_draw_K4_J4
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K4_J5 : K'=4 prélude / F=1 cœur / J'=5 épilogue
Road_draw_K4_J5
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d
        rts

* Road_draw_K4_J6 : K'=4 prélude / F=0 cœur / J'=6 épilogue
Road_draw_K4_J6
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K5_J0 : K'=5 prélude / F=5 cœur / J'=0 épilogue
Road_draw_K5_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        jsr   [8,y]
        rts

* Road_draw_K5_J1 : K'=5 prélude / F=4 cœur / J'=1 épilogue
Road_draw_K5_J1
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K5_J2 : K'=5 prélude / F=3 cœur / J'=2 épilogue
Road_draw_K5_J2
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K5_J3 : K'=5 prélude / F=2 cœur / J'=3 épilogue
Road_draw_K5_J3
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K5_J4 : K'=5 prélude / F=1 cœur / J'=4 épilogue
Road_draw_K5_J4
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K5_J5 : K'=5 prélude / F=0 cœur / J'=5 épilogue
Road_draw_K5_J5
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K6_J0 : K'=6 prélude / F=4 cœur / J'=0 épilogue
Road_draw_K6_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        jsr   [6,y]
        rts

* Road_draw_K6_J1 : K'=6 prélude / F=3 cœur / J'=1 épilogue
Road_draw_K6_J1
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K6_J2 : K'=6 prélude / F=2 cœur / J'=2 épilogue
Road_draw_K6_J2
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K6_J3 : K'=6 prélude / F=1 cœur / J'=3 épilogue
Road_draw_K6_J3
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        rts

* Road_draw_K6_J4 : K'=6 prélude / F=0 cœur / J'=4 épilogue
Road_draw_K6_J4
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K7_J0 : K'=7 prélude / F=3 cœur / J'=0 épilogue
Road_draw_K7_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        jsr   [4,y]
        rts

* Road_draw_K7_J1 : K'=7 prélude / F=2 cœur / J'=1 épilogue
Road_draw_K7_J1
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K7_J2 : K'=7 prélude / F=1 cœur / J'=2 épilogue
Road_draw_K7_J2
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        rts

* Road_draw_K7_J3 : K'=7 prélude / F=0 cœur / J'=3 épilogue
Road_draw_K7_J3
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K8_J0 : K'=8 prélude / F=2 cœur / J'=0 épilogue
Road_draw_K8_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        jsr   [2,y]
        rts

* Road_draw_K8_J1 : K'=8 prélude / F=1 cœur / J'=1 épilogue
Road_draw_K8_J1
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        rts

* Road_draw_K8_J2 : K'=8 prélude / F=0 cœur / J'=2 épilogue
Road_draw_K8_J2
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K9_J0 : K'=9 prélude / F=1 cœur / J'=0 épilogue
Road_draw_K9_J0
        ldd   #$2222
        ldx   #$2222
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        pshu  d,x
        jsr   [,y]
        rts

* Road_draw_K9_J1 : K'=9 prélude / F=0 cœur / J'=1 épilogue
Road_draw_K9_J1
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts

* Road_draw_K10_J0 : K'=10 prélude / F=0 cœur / J'=0 épilogue
Road_draw_K10_J0
        ldd   #$2222
        ldx   #$2222
        leay  ,x
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x,y
        pshu  d,x
        rts
