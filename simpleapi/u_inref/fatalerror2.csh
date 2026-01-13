#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test of FATALERROR2 error"
#

echo "Copy all C programs that need to be tested"
cp $gtm_tst/$tst/inref/fatalerror.c .

echo "# Create database for TP transaction"
$gtm_tst/com/dbcreate.csh mumps 1

set syslog_time1 = `date +"%b %e %H:%M:%S"`

foreach file (fatalerror.c)
	echo " --> Running $file <---"
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "FATALERROR2-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		continue
	endif

	echo "# Set vmemoryuse limit to 400Mb; Eventually triggers YDB-F-MEMORY (and in turn FATALERROR2 error in syslog)"
	# Note: A value of 200Mb causes occasional NONUTF8LOCALE errors on RHEL 10 with -unicode. Hence the 400Mb choice.
	source $gtm_tst/com/limit_vmemoryuse.csh 400000
	echo "# unsetenv gtmdbglvl (needed for FATALERROR2)"
	unsetenv gtmdbglvl
	# We background the executable to get its pid. This is needed so we can search for FATALERROR2 message in syslog
	# from just this pid. That way we avoid failing the test due to other FATALERROR2 messages in syslog from concurrent tests.
	# Normally we would use the test output directory in the syslog search string to address such issues but this is not
	# possible because FATALERROR2 message does not include the absolute path of the current directory.
	( `pwd`/$exefile & ; echo $! >&! bg.pid)
	set bgpid = `cat bg.pid`
	# The process could take a while to reach the FATALERROR1 point and some more time to generate a core file on
	# slower/loaded systems (e.g. ARMV6L or ARMV7L) so wait generously of instead of the default 1 minute hence the -1 below.
	$gtm_tst/com/wait_for_proc_to_die.csh $bgpid -1
	echo ""
end

echo "# Reset vmemoryuse back to unlimited to avoid memory errors in the getoper.csh call (or dbcheck.csh) below"
limit vmemoryuse unlimited

$gtm_tst/com/getoper.csh "$syslog_time1" "" syslog1.txt "" "FATALERROR2"
$grep "\<$bgpid\>.*FATALERROR2" syslog1.txt | sed 's/.*%YDB-F-FATALERROR2/%YDB-F-FATALERROR2/;s/ Error:.*//;'
# Unlike the FATALERROR1 case, we do not expect a core file in the FATALERROR2 case.
# But we do not need to do any checks for this. The test framework will automatically fail the test if it finds a core file.
if (-e YDB_FATAL_ERROR*) then
	set ferrfile = YDB_FATAL_ERROR*
	mv $ferrfile fatalerror1_$ferrfile
else
	echo "FATALERROR1-E-NOFATALERRFILE : YDB_FATAL_ERROR_* file expected but not found after FATALERROR1 error"
endif

$gtm_tst/com/dbcheck.csh
