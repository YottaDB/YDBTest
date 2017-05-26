#! /usr/local/bin/tcsh -f
# C9C01-001878 GTM fails for multi-process journaling test with ZTS/ZTC
# Subtest makes sense only when run with TP as it tests some features of ZTP/ZTC.
if ($gtm_test_tp == "NON_TP") then
	echo "zt_multi must be executed in TP mode."
	exit 1
endif
$gtm_tst/com/dbcreate.csh mumps 4 125 1000
if (0 == $?test_replic) then
        $MUPIP set -journal=enable,on,before -reg "*" |& sort -f 
endif
echo "GTM Processes will start now"
setenv gtm_test_jobcnt 4
setenv gtm_test_dbfill "IMPZTP"
$gtm_tst/com/imptp.csh >&! multi_ztp.out
sleep 60
echo "GTM Processes will end"
$gtm_tst/com/endtp.csh >>&! endtp.out
echo "All GTM Processes exited"
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
echo "$MUPIP journal -recover -back * -since=0 0:0:50\"
$MUPIP journal -recover -back "*" -since=\"0 0:0:50\"
