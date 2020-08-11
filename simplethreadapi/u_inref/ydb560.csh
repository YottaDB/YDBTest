#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

echo "-----------------------------------------------------------------------------------------------------"
echo "# Test that ydb_eintr_handler_t() helps terminate SimpleThreadAPI application if a SIGINT/SIGTERM is received"
echo "-----------------------------------------------------------------------------------------------------"
set file = "ydb560"

echo "# Create ydb560loop.c from ydb560halt.c by removing ydb_eintr_handler_t() call"
cp $gtm_tst/$tst/inref/ydb560halt.c .
sed 's/ydb_eintr_handler_t(.*);//;' ydb560halt.c > ydb560loop.c

foreach file ("ydb560loop" "ydb560halt")
	echo "# Comple/Link $file.c"
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file.c
	$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map

	foreach sig (15 2)
		echo "# Run SimpleThreadAPI application [`pwd`/$file] in background with signal number [SIG-$sig]"
		(`pwd`/$file < /dev/null > $file.$sig.out & ; echo $! >&! $file.$sig.pid) >& $file.$sig.err

		echo "# Sleep 1 second to give process some time to start"
		sleep 1

		echo "# Sending : [kill -$sig] to backgrounded SimpleThreadAPI application"
		set bgpid = `cat $file.$sig.pid`
		kill -$sig $bgpid

		echo "# Waiting for backgrounded SimpleThreadAPI application to terminate"
		if ("ydb560loop" == "$file") then
			echo "# No ydb_eintr_handler_t() used : Process is not expected to terminate"
			set sleeptime = 1
		else
			echo "# ydb_eintr_handler_t() is used : Process is expected to terminate"
			set sleeptime = 60
		endif
		$gtm_tst/com/wait_for_proc_to_die.csh $bgpid $sleeptime >& wait_for_proc.$file.$sig.outx
		if (! $status) then
			if ("ydb560halt" == "$file") then
				echo " --> Process terminated just like it was expected to"
			else
				echo " --> Process terminated but was not expected to"
			endif
		else
			if ("ydb560halt" == "$file") then
				echo " --> Process did not terminate but was expected to"
			else
				echo " --> Process did not terminate just like it was expected to"
			endif
		endif
		if ("ydb560loop" == "$file") then
			echo "# Sending : [kill -9] to backgrounded SimpleThreadAPI application to terminate it"
			kill -9 $bgpid
			set sleeptime = 60
			$gtm_tst/com/wait_for_proc_to_die.csh $bgpid $sleeptime
		else if (15 == $sig) then
			echo "# Expected to see FORCEDHALT message in stderr"
			set message = "YDB-F-FORCEDHALT"
			$gtm_tst/com/check_error_exist.csh $file.$sig.err $message >& /dev/null
			if (0 == $status) then
				echo " -> $message seen in stderr as expected"
			else
				echo " -> $message expected in stderr but not found"
			endif
			mv $file.$sig.errx $file.$sig.outx	# rename as test framework only knows to skip errors in *.outx
		endif
		echo ""
	end
end

$gtm_tst/com/dbcheck.csh
