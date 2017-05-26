#! /usr/local/bin/tcsh -f
#
#
echo ENTERING ONLINE2
#
#
setenv gtmgbldir online2.gld
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh online2 1 125 700 1536 9000 256
else
	$gtm_tst/com/dbcreate.csh online2 1 125 700 1536 100 256
endif
$GTM << \onlinetest
d main^online2
h
\onlinetest
$gtm_tst/com/dbcheck.csh
#
#
echo LEAVING ONLINE2
