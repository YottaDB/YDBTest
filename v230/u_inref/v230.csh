# The following programs do not access a database.
# Encryprion cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
        setenv test_encryption NON_ENCRYPT
endif
$GTM << \xyz
w "d ^bug2",! d ^bug2
w "d ^bug3",! d ^bug3
w "d ^bug8",! d ^bug8
w "d ^bug9",! d ^bug9
w "d ^bug10",! d ^bug10
w "d ^bug11",! d ^bug11
w "d ^bug12",! d ^bug12
w "d ^bug13",! d ^bug13
w "d ^bug15",! d ^bug15
w "d ^bug20",! d ^bug20
w "d ^bug21",! d ^bug21
w "d ^bug23",! d ^bug23
w "d ^bug24",! d ^bug24
w "d ^bug26",! d ^bug26
w "d ^bug28",! d ^bug28
w "d ^bug29",! d ^bug29
w "d ^bug31",! d ^bug31
w "d ^bug32",! d ^bug32
w "d ^bug33",! d ^bug33
w "d ^bug34",! d ^bug34
w "d ^bug35",! d ^bug35
w "d ^bug36",! d ^bug36
w "d ^bug37",! d ^bug37
w "d ^bug38",! d ^bug38
w "d ^bug39",! d ^bug39
w "d ^bug40",! d ^bug40
w "d ^bug41",! d ^bug41
w "d ^bug42",! d ^bug42
w "d ^bug45",! d ^bug45
w "d ^bug55",! d ^bug55
w "d ^bug56",! d ^bug56
w "d ^bug57",! d ^bug57
w "d ^bug61",! d ^bug61
w "d ^bug68",! d ^bug68
w "d ^bug69",! d ^bug69
zcontinue
w "d ^bug71",! d ^bug71
w "d ^bug78",! d ^bug78
w "d ^bug80",! d ^bug80
w "d ^bug84",! d ^bug84
w "d ^bug91",! d ^bug91
w "d ^bug92",! d ^bug92
zcontinue
w "d ^bug93",! d ^bug93
w "d ^bug98",! d ^bug98
w "d ^bug107",! d ^bug107
w "d ^bug120",! d ^bug120
w "d ^bug121",! d ^bug121
w "d ^bug122",! d ^bug122
w "d ^bug303",! d ^bug303
w "d ^bug306",! d ^bug306
w "d ^bug307",! d ^bug307
w "d ^bug310",! d ^bug310
w "d ^bug311",! d ^bug311
w "d ^bug313",! d ^bug313
w "d ^per0010",! d ^per0010
w "d ^per0025",! d ^per0025
w "d ^per0088",! d ^per0088
w "d ^per0119",! d ^per0119
w "d ^per0122",! d ^per0122
w "d ^per0285",! d ^per0285
w "d ^per0288",! d ^per0288
w "d ^per0305",! d ^per0305
w "d ^per0324",! d ^per0324
w "d ^per0337",! d ^per0337
w "d ^per0343",! d ^per0343
w "d ^per0348",! d ^per0348
w "d ^per0356",! d ^per0356
w "d ^per0358",! d ^per0358
w "d ^per0360",! d ^per0360
w "d ^per0369",! d ^per0369
w "d ^per0371",! d ^per0371
w "d ^per0394",! d ^per0394
w "d ^per0407",! d ^per0407
w "d ^per0416",! d ^per0416
w "d ^per0429",! d ^per0429
w "d ^per0431",! d ^per0431
w "d ^per0432",! d ^per0432
w "d ^per0470",! d ^per0470
w "d ^per0481",! d ^per0481
w "d ^per0499",! d ^per0499
w "d ^per0508",! d ^per0508
w "d ^per0510",! d ^per0510
w "d ^per0525",! d ^per0525
h
\xyz
# The following programs access a database.
$gtm_tst/com/dbcreate.csh . 3
$GTM << zyx
w "d ^bug000",! d ^bug000
w "d ^bug1",! d ^bug1
zcontinue
zcontinue
w "d ^bug25",! d ^bug25
w "d ^bug27",! d ^bug27
w "d ^bug73",! d ^bug73
w "d ^bug81",! d ^bug81
w "d ^bug82",! d ^bug82
w "d ^bug97",! d ^bug97
w "d ^bug301",! d ^bug301
w "d ^bug302",! d ^bug302
500
w "d ^bug305",! d ^bug305
w "d ^per0318",! d ^per0318
w "d ^per0335",! d ^per0335
w "d ^per0507",! d ^per0507
w "d ^per0509",! d ^per0509
h
zyx
$gtm_tst/com/dbcheck.csh -extract
