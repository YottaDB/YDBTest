jnlrec;
	; creates TP and non-TP records (no ZTP)
        K ^acn
        h 1
        w "SET,TSET,USET,GSET,FSET",!
        S (^acn(1),^bcn(1),^cn(1),^dcn(1))="this is SET"
        TS ():(transaction="BATCH")
        S (^acn(2),^bcn(2),^ccn(2),^dcn(2))="this is TSET"
        S (^acn(3),^bcn(3),^ccn(3),^dcn(3))="this is USET"
        S (^acn(3,1),^bcn(3,1),^ccn(3,1),^dcn(3,1))="this is USET"
        TC
        ;
        w "KILL,TKILL,UKILL,GKILL,FKILL",!
        K ^acn(1),^bcn(1),^ccn(1),^dcn(1)
        TS
        K ^acn(2),^bcn(2),^ccn(2),^dcn(2)
        K ^acn(3),^bcn(3),^ccn(3),^dcn(3)
        K ^acn(3,1),^bcn(3,1),^ccn(3,1),^dcn(3,1)
        TC
        if $data(^acn)=0 w "Passed SET and KILL",!
        ;
        w "SET,TSET,USET,GSET,FSET",!
        S (^acn(10),^bcn(10),^ccn(10),^dcn(10))="this is SET"
        TS ():(transaction="online")
        S (^acn(11),^bcn(11),^ccn(11),^dcn(11))="this is TSET"
        S (^acn(11,11),^bcn(11,11),^ccn(11,11),^dcn(11,11))="this is USET"
        S (^acn(12),^bcn(12),^ccn(12),^dcn(12))="this is USET"
        S (^acn(12,12),^bcn(12,12),^ccn(12,12),^dcn(12,12))="this is USET"
        TC
        ;
        w "ZKILL,TZKILL,UZKILL,GZKILL,FZKILL",!
        ZKILL ^acn(10),^bcn(10),^ccn(10),^dcn(10)
        TS
        ZKILL ^acn(11),^bcn(11),^ccn(11),^dcn(11)
        ZKILL ^acn(12),^bcn(12),^ccn(12),^dcn(12)
        TC
        q

