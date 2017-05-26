#!/usr/local/bin/tcsh
#
# D9G01-002592 MUPIP LOAD arbitrarily low record limit impedes large ZWR loads
#
# Test good values of BEGIN and END qualifier as well as bad values for ZWR, GO and BIN formats
#
# 'go' format is not supported in UTF-8 mode 
# Since the intent of the subtest is explicitly check all three formats, it is forced to run in M mode
$switch_chset M >&! switch_chset.out
$gtm_tst/com/dbcreate.csh mumps 1 255 480 512	# keysize=255, recsize=480, blksize=512
$GTM << GTM_EOF
	do ^d002592
GTM_EOF

set dispstr = "-----------------------------------------------------------------"
set echoline = "echo $dispstr"
foreach fmt (zwr go bin)
	echo ""
	echo "######################################################################################"
	echo "                           Testing format=$fmt"
	echo "######################################################################################"
	set verbose
	$MUPIP extract -format=$fmt all.$fmt
	if ($fmt == bin) then
		set fmtstr = "-format=bin"
	else
		set fmtstr = ""	# test that no -format specification assumes -fmt=zwr or -fmt=go and figures the right one
	endif
	$echoline
	$MUPIP load $fmtstr -begin=1 -end=1 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=1 -end=2 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=2 -end=2 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=1 -end=3 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=2 -end=10 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=3 -end=10 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=3         all.$fmt	# without any -end qualifier
	$echoline
	$MUPIP load $fmtstr          -end=9 all.$fmt	# without any -begin qualifier
	$echoline
	$MUPIP load $fmtstr -begin=9 -end=19 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=3 -end=5 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=4 -end=4 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=5 -end=4 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=1000000000 -end=1000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=2000000000 -end=2000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=3000000000 -end=3000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=4000000000 -end=4000000000 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=4294967295 -end=4294967295 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=4294967295 -end=4294967296 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=4294967296 -end=4294967295 all.$fmt
	$echoline
	$MUPIP load $fmtstr -begin=4294967296 -end=4294967296 all.$fmt
	unset verbose
end
$gtm_tst/com/dbcheck.csh
