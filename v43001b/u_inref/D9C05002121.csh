#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv > setenv.out
unsetenv GTM_BAKTMPDIR
unsetenv TMPDIR
setenv gtm_test_sprgde_exclude_reglist DEFAULT	# No globals to DEFAULT region, to maintain consistent output
if ($?test_replic) then
	#this test handles it's own replication
	setenv v43001b_test_replic
	unsetenv test_replic
	# Since this test handles its own replication, the MUPIP INTEG run by the helper script results in FTOKERR/ENO2
	# errors. So, unsetenv gtm_custom_errors for the duration of the test.
	unsetenv gtm_custom_errors
endif

# dbcreate.csh called by init_gld.csh
$gtm_tst/$tst/u_inref/init_gld.csh
setenv gtmgbldir mumps.gld

if ($?v43001b_test_replic) then
	setenv test_replic
	$sec_shell "cd $SEC_SIDE; $gtm_tst/$tst/u_inref/init_gld.csh"
	$gtm_tst/com/RF_START.csh
endif
setenv gtmgbldir `pwd`/mumps.gld
#####
echo "==================================================================="
echo "Non-incremental backup is not supported to pipes and tcp:"
set verbose
$MUPIP backup -nonew -o DEFAULT '"| gzip -c > mumpsbak.dat.gz"'
$MUPIP backup -nonew -o -nettimeout=120 DEFAULT "tcp://`hostname`:6200"
unset verbose
# run the mupip commands with -dbg to get more info, but we need to filter them out:
$gtm_tst/$tst/u_inref/D9C05002121a.csh >& D9C05002121a.log
if ($status) then
	echo "Error inside D9C05002121a.csh. Exiting..."
	exit -1
endif

echo "Check D9C05002121a.log for more detailed info"
# convert AREG_19999__0 to AREG_XXXX__0, AREG_4e2b_r9cNBV to AREG_YYYY_ZZZZZZ, etc:
$grep -v "Restoring block" D9C05002121a.log  | $grep -v "shmpool lock preventing backup buffer flush" | $tst_awk -f $gtm_tst/$tst/u_inref/filter.awk

setenv gtmgbldir mumps.gld
if ($?test_replic) then
	$gtm_tst/com/RF_sync.csh
endif
$gtm_tst/com/dbcheck.csh
