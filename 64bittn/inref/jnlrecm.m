jnlrecm ;jnlrec multi region, used from multiple subtests
	; makes sure all types of records are generated
	set fencing=$zsearch("test_replic.txt")	; if this file exists, then it is a replic test so do not use ZTS/ZTC
        K ^acn
        h 1
	set unix=$zv'["VMS"
	if unix set command="$gtm_tst/com/abs_time.csh "
	else  d
	. set command="pipe write sys$output f$time() > "
	. if $ZCMDLINE="NOTIME" s command=""
	if ""'=command zsystem command_"time1_GTM_TEST_DEBUGINFO" 
        h 1
        w "SET,TSET,USET,GSET,FSET",!
        S (^acn(1),^bcn(1),^cn(1),^dcn(1))="this is SET"
        TS ():(transaction="BATCH")
        S (^acn(2),^bcn(2),^ccn(2),^dcn(2))="this is TSET"
        S (^acn(3),^bcn(3),^ccn(3),^dcn(3))="this is USET"
        S (^acn(3,1),^bcn(3,1),^ccn(3,1),^dcn(3,1))="this is USET"
        h 1
	if ""'=command zsystem command_"time2_GTM_TEST_DEBUGINFO" 
        h 1
        TC
        if (""=fencing) ZTS
        S (^acn(5),^bcn(5),^ccn(5),^dcn(5))="this is FSET"
        S (^acn(6),^bcn(6),^ccn(6),^dcn(6))="this is GSET"
        S (^acn(6,1),^bcn(6,1),^ccn(6,1),^dcn(6,1))="this is GSET"
        h 1
	if ""'=command zsystem command_"time3_GTM_TEST_DEBUGINFO" 
        h 1
        if (""=fencing) ZTC
        ;
        w "KILL,TKILL,UKILL,GKILL,FKILL",!
        K ^acn(1),^bcn(1),^ccn(1),^dcn(1)
        TS
        K ^acn(2),^bcn(2),^ccn(2),^dcn(2)
        K ^acn(3),^bcn(3),^ccn(3),^dcn(3)
        K ^acn(3,1),^bcn(3,1),^ccn(3,1),^dcn(3,1)
        TC
        if (""=fencing) ZTS
        K ^acn(5),^bcn(5),^ccn(5),^dcn(5)
        K ^acn(6),^bcn(6),^ccn(6),^dcn(6)
        K ^acn(6,1),^bcn(6,1),^ccn(6,1),^dcn(6,1)
        if (""=fencing) ZTC
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
        if (""=fencing) ZTS
        S (^acn(13),^bcn(13),^ccn(13),^dcn(13))="this is FSET"
        S (^acn(13,13),^bcn(13,13),^ccn(13,13),^dcn(13,13))="this is GSET"
        S (^acn(14),^bcn(14),^ccn(14),^dcn(14))="this is GSET"
        S (^acn(14,14),^bcn(14,14),^ccn(14,14),^dcn(14,14))="this is GSET"
        h 1
	if ""'=command zsystem command_"time4_GTM_TEST_DEBUGINFO" 
        h 1
        if (""=fencing) ZTC
        ;
        w "ZKILL,TZKILL,UZKILL,GZKILL,FZKILL",!
        ZKILL ^acn(10),^bcn(10),^ccn(10),^dcn(10)
        TS
        ZKILL ^acn(11),^bcn(11),^ccn(11),^dcn(11)
        ZKILL ^acn(12),^bcn(12),^ccn(12),^dcn(12)
        TC
        if (""=fencing) ZTS
        ZKILL ^acn(13),^bcn(13),^ccn(13),^dcn(13)
        ZKILL ^acn(14),^bcn(14),^ccn(14),^dcn(14)
        if (""=fencing) ZTC
        h 1
	if ""'=command zsystem command_"time5_GTM_TEST_DEBUGINFO" 
        h 1
        W "Check that only ^acn(11,11),^acn(12,12),^acn(13,13),^acn(14,14) are present",!
        ZWR ^acn
        q
verify
	s fail=0
	if "this is USET"'=^acn(11,11) s fail=1
	if "this is USET"'=^acn(12,12) s fail=1
	if "this is GSET"'=^acn(13,13) s fail=1
	if "this is GSET"'=^acn(14,14) s fail=1
	if "this is USET"'=^bcn(11,11) s fail=1
	if "this is USET"'=^bcn(12,12) s fail=1
	if "this is GSET"'=^bcn(13,13) s fail=1
	if "this is GSET"'=^bcn(14,14) s fail=1
	if "this is USET"'=^ccn(11,11) s fail=1
	if "this is USET"'=^ccn(12,12) s fail=1
	if "this is GSET"'=^ccn(13,13) s fail=1
	if "this is GSET"'=^ccn(14,14) s fail=1
	if "this is SET"'=^cn(1) s fail=1
	if "this is USET"'=^dcn(11,11) s fail=1
	if "this is USET"'=^dcn(12,12) s fail=1
	if "this is GSET"'=^dcn(13,13) s fail=1
	if "this is GSET"'=^dcn(14,14) s fail=1
	if 1=fail w "FAILED VERIFY"
	e  w "PASSED VERIFY"
	q

