#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Creating database with 5 regions"
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh mumps 5 > newdbcreate.out
if ("ENCRYPT" == $test_encryption) then
	sed 's/a\.dat/b.dat/' $gtm_dbkeys > ${gtm_dbkeys}.all
	sed 's/b\.dat/a.dat/' $gtm_dbkeys >> ${gtm_dbkeys}.all
	cat $gtm_dbkeys >> ${gtm_dbkeys}.all
	$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.all gtmcrypt.cfg.all
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! $gtmcrypt_config
	cat ${gtmcrypt_config}.all >>&! $gtmcrypt_config
endif

set bftok = `$MUPIP ftok b.dat |& grep 'b.dat' | $tst_awk '{print $9}' | tee bftok.txt`
set cftok = `$MUPIP ftok c.dat |& grep 'c.dat' | $tst_awk '{print $9}' | tee cftok.txt`

# Change file names so that file with the larger ftok id comes first. This test assumes ftok list is in alphabetical order
if ($bftok < $cftok) then
    \mv a.dat acopy.dat
    \mv b.dat a.dat
    \mv acopy.dat b.dat
endif

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 95 # WBTEST_HOLD_CRIT_ENABLED

echo "# Launching crit holder process (holding BREG crit)"
($gtm_exe/mumps -run %XCMD 'do critholder^gtm7614' >& crit_holder.log &)

echo "# Launching crit waiter process (will hold CREG and wait on BREG crit)"
set syslog_before1 = `date +"%b %e %H:%M:%S"`
($gtm_exe/mumps -run %XCMD 'do critwaiter^gtm7614' >& crit_waiter.log &)

echo "# Waiting for MUTEXRELEASED message on the syslog"
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "MUTEXRELEASED"

set killpid1 = `cat pidholder.txt`
set killpid2 = `cat pidwaiter.txt`

$MUPIP intrpt $killpid1

echo "# Waiting for processes to die"
$gtm_tst/com/wait_for_proc_to_die.csh $killpid1
$gtm_tst/com/wait_for_proc_to_die.csh $killpid2

$gtm_tst/com/dbcheck.csh
