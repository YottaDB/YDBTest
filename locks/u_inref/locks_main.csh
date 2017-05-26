#!/usr/local/bin/tcsh -f
#=================================
if (!($?test_replic)) then    
#
#	locks2 is not for replication: It uses mulitple gld files.
#
	$gtm_tst/com/dbcreate.csh mumps1
	# The next dbcreate invocation will rename the db/gld files. Since is required for this test, move them away temporarily
	mkdir bak ; mv mumps1.* bak/
	$gtm_tst/com/dbcreate.csh mumps
	mv bak/* .
	$GTM << xxyz
	w "do ^locks1",!     do ^locks1
	w "do ^locks2",!     do ^locks2
	h
xxyz
	$gtm_tst/com/dbcheck.csh mumps1
else
#
	$gtm_tst/com/dbcreate.csh mumps
	$GTM << xxyz
	w "do ^locks1",!     do ^locks1
	h
xxyz
endif

if ($LFE == "L") then   
	$gtm_tst/com/dbcheck.csh -extract
	exit 
endif
#=================================

$GTM << xxyz
w "do ^locksub1",!   do ^locksub1
w "do ^locktst4",!   do ^locktst4
h
xxyz
#
#

$GTM << xxyz
w "do ^per3086",!   do ^per3086
h
xxyz
#

if ($LFE == "F") then   
	$gtm_tst/com/dbcheck.csh -extract
	exit 
endif
#=================================

$GTM << xxyz
w "do ^lockwake",!   do ^lockwake
h
xxyz
#
$LKE show -all
cat lockwake.mjo*
cat lockwake.mje*
$GTM << xxyz
w "do ^clocks",!     do ^clocks
h
xxyz
#
$gtm_tst/com/dbcheck.csh -extract
