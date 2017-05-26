#! /usr/local/bin/tcsh -f
set exit_status = 0
mkdir online1 baktmp
setenv GTM_BAKTMPDIR `pwd`/baktmp
source $gtm_tst/$tst/u_inref/createdb_start_updates.csh 1
($gtm_tst/$tst/u_inref/find_tmpfiles.csh >>& find_tmpfiles.out&) >&! find_tmpfiles.log
$MUPIP backup -online "*" ./online1 >&! online1.out
date >>& online1.out
$grep "BACKUP COMPLETED" online1.out
if ($status) then
        echo "PASS! BACKUP did fail as expected"
        # sometimes MUPIP backup errors out before it starts itself
        # in such cases we will not get MUNOFINISH error, we get only a message like
        # Error re-opening temporary file created by mkstemp(). So MUNOFINISH might or might not exist
        $gtm_tst/com/check_error_exist.csh online1.out "MUNOFINISH" >&! check_MUNOFINISH_exist.outx
        # in both cases however ENO13 (ENO111 on OS390) , Permission denied error is a must
        if ("os390" == $gtm_test_osname) then
                set errno = "ENO111"
        else
                set errno = "ENO13"
endif
        $gtm_tst/com/check_error_exist.csh online1.out $errno >&! check_error.outx
	if ($status) set exit_status = 1
else
	set exit_status = 2
endif
exit $exit_status

