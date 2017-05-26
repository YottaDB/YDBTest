#!/usr/local/bin/tcsh -f
#
# makemm.csh 	--	make the current databases in MM mode.
#
# requires	--	corresponding global directory and database files exist
#
$gtm_dist/mupip set -reg DEFAULT -a=mm -defer_time=1
$gtm_dist/mupip set -reg ACCT -a=mm -defer_time=1
$gtm_dist/mupip set -reg ACNM -a=mm -defer_time=1
$gtm_dist/mupip set -reg JNL -a=mm -defer_time=1

$gtm_dist/dse << \ccc
change -fileheader -flush_time=00:00:01:00
f -r=ACNM
change -fileheader -flush_time=00:00:01:00
f -r=DEFAULT
change -fileheader -flush_time=00:00:01:00
f -r=JNL
change -fileheader -flush_time=00:00:01:00
exit
\ccc

echo END of makemm.csh

