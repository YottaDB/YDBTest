#!/usr/local/bin/tcsh -f
set alternate_maximums="65024 1024 4000"
if ( "osf1" == "$gtm_test_osname" || "sunos" == "$gtm_test_osname" ) then
	set alternate_maximums="61440 1024"
endif
source $gtm_tst/com/dbcreate.csh mumps 1 255 32767 $alternate_maximums

source $gtm_tst/$tst/u_inref/maxparse_base.csh

$gtm_tst/com/dbcheck.csh -extract
